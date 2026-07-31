import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:venta_mls/venta_mls.dart';

import '../../features/mls/data/mls_api.dart';
import '../../features/mls/data/models/mls_dtos.dart';
import '../device/device_id_service.dart';
import 'mls_service.dart';

/// A context whose group membership or encryption state just changed under us.
class MlsContextChanged {
  const MlsContextChanged({
    required this.contextId,
    required this.isChannel,
    required this.selfRemoved,
  });

  final String contextId;
  final bool isChannel;

  /// True when this device was removed from the group by someone else's commit.
  final bool selfRemoved;
}

/// A commit produced locally but not yet published.
class StagedCommit {
  const StagedCommit({
    required this.commit,
    required this.epoch,
    this.deviceWelcomes = const [],
    this.fulfilledJoinRequestIds = const [],
  });

  final String commit;

  /// Epoch this commit establishes once merged.
  final int epoch;

  /// Welcomes for devices this commit adds. They travel with the commit so a
  /// device can never end up holding a leaf whose Welcome was lost on the way.
  final List<DeviceWelcomeDto> deviceWelcomes;

  /// Join requests this commit admits. The server closes them only once the
  /// commit lands - a request is fulfilled when the device is genuinely in the
  /// group, and an approval that never produced a commit has to stay open for
  /// someone else to act on.
  final List<String> fulfilledJoinRequestIds;
}

/// Everything that has to happen in a particular order for MLS to stay
/// consistent. Port of Alpine's `MlsSyncService`; three rules drive the class:
///
/// 1. **Commits apply in epoch order, from the server.** The realtime push is
///    only a nudge; group state advances solely by fetching commits above our
///    local epoch and applying them in sequence. Applying them in arrival order
///    would fork this device off the group permanently.
/// 2. **A commit is staged locally, published, and only then merged.** The
///    server takes exactly one commit per epoch. Merging before it accepts means
///    a lost race leaves us advanced on a commit nobody else has - unrecoverable
///    in MLS. On rejection we discard, catch up, and re-issue.
/// 3. **A Welcome is acknowledged only after the join succeeds.** Its init key
///    is single-use, so a Welcome consumed before a failed join locks this
///    device out of the context for good.
class MlsSyncService {
  MlsSyncService({
    required this.mls,
    required this.api,
    required this.deviceIdService,
  });

  final MlsService mls;
  final MlsApi api;
  final DeviceIdService deviceIdService;

  final _contextChanged = StreamController<MlsContextChanged>.broadcast();

  /// Emits whenever a context's group changed - membership, or being removed.
  Stream<MlsContextChanged> get contextChanged => _contextChanged.stream;

  /// One in-flight operation per context.
  ///
  /// A realtime nudge and a launch-time sweep routinely target the same context
  /// at once; letting both walk the commit list would apply the same commit
  /// twice, and the second application fails and looks like corruption.
  final _queues = <String, Future<void>>{};

  /// Contexts that picked up a Remove proposal during catch-up and still owe a
  /// commit for it.
  final _pendingProposalContexts = <String>{};

  // ---------------------------------------------------------------------------
  // Welcomes
  // ---------------------------------------------------------------------------

  /// Joins every group this device has been invited to, then acknowledges only
  /// the ones that actually worked.
  ///
  /// A Welcome that fails to join is deliberately left unacknowledged so the
  /// next attempt sees it again - the alternative is losing the only copy of a
  /// single-use key.
  Future<void> processPendingWelcomes() async {
    if (!mls.isUnlocked) return;

    final deviceId = deviceIdService.deviceIdOrNull;
    if (deviceId == null) return;

    final welcomes = await api.getPendingWelcomes(deviceId);
    if (welcomes.isEmpty) return;

    final joined = <String>[];
    for (final welcome in welcomes) {
      if (await _joinFromWelcome(welcome)) joined.add(welcome.id);
    }

    if (joined.isNotEmpty) await api.ackWelcomes(joined);
  }

  /// Returns whether the join succeeded and the Welcome may be acknowledged.
  Future<bool> _joinFromWelcome(PendingWelcomeDto welcome) async {
    try {
      if (mls.groupId(welcome.contextId, welcome.generation) != null) {
        // Already joined this generation on a previous run that died before
        // acking. Acknowledging is right: re-joining would fail, and leaving it
        // pending would make every future sweep retry a join that can never
        // succeed.
        return true;
      }

      final info = await mls.joinGroup(welcome.welcome);
      await mls.registerGroup(
        contextId: welcome.contextId,
        generation: welcome.generation,
        mlsGroupId: info.groupId,
      );

      // The Welcome drops us in at its own epoch; anything committed since has
      // to be replayed before we can read current traffic.
      await syncContext(welcome.contextId, welcome.isChannel);
      _contextChanged.add(
        MlsContextChanged(
          contextId: welcome.contextId,
          isChannel: welcome.isChannel,
          selfRemoved: false,
        ),
      );
      return true;
    } catch (e) {
      debugPrint('MLS: failed to join group from Welcome ${welcome.contextId}: $e');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Catch-up
  // ---------------------------------------------------------------------------

  /// Applies every commit the server holds above this device's local epoch, in
  /// order.
  ///
  /// Pages until the server stops returning new commits, so a device that was
  /// offline across more commits than one page holds still converges rather than
  /// silently stopping partway.
  Future<void> syncContext(String contextId, bool isChannel) async {
    await _serialized(contextId, () => _syncContextInner(contextId, isChannel));

    // Outside the queue, because committing publishes and publishing takes the
    // same queue this just released.
    if (_pendingProposalContexts.remove(contextId)) {
      try {
        await commitPendingProposals(contextId, isChannel);
      } catch (e) {
        // Any other member can do this instead; leaving it undone only delays
        // the removal.
        debugPrint('MLS: could not commit pending proposals for $contextId: $e');
      }
    }
  }

  Future<void> _syncContextInner(String contextId, bool isChannel) async {
    final generation = mls.knownGeneration(contextId);
    if (generation == null) return;

    final groupId = mls.groupId(contextId, generation);
    if (groupId == null) return;

    while (true) {
      int epoch;
      try {
        epoch = (await mls.getGroupInfo(groupId)).epoch;
      } catch (_) {
        // The group is gone locally - removed, or the context was wiped.
        return;
      }

      final commits = await api.getCommits(
        contextId: contextId,
        isChannel: isChannel,
        sinceEpoch: epoch,
        generation: generation,
      );
      if (commits.isEmpty) return;

      var applied = 0;
      for (final commit in commits) {
        // Strictly sequential. A gap means the page started above our epoch,
        // which should be impossible - stopping is safer than applying out of
        // order.
        if (commit.epoch != epoch + applied + 1) break;

        final removed = await _applyCommit(
          contextId: contextId,
          isChannel: isChannel,
          groupId: groupId,
          commitB64: commit.commit,
        );
        applied++;
        if (removed) return;
      }

      if (applied == 0) return;
    }
  }

  /// Returns true when the commit removed *this* device from the group.
  Future<bool> _applyCommit({
    required String contextId,
    required bool isChannel,
    required String groupId,
    required String commitB64,
  }) async {
    final processed = await mls.processMessage(
      groupIdB64: groupId,
      messageB64: commitB64,
    );

    if (processed.kind == MlsMessageKind.proposal) {
      // A departing member's Remove-self proposal. MLS does not let anyone
      // commit their own removal, so until a remaining member turns this into a
      // commit the group keeps encrypting to someone who has already thrown
      // their keys away.
      //
      // Queued rather than committed inline: we are mid-catch-up, holding the
      // per-context queue that publishing also needs. `syncContext` drains this
      // once it has let the queue go.
      _pendingProposalContexts.add(contextId);
      return false;
    }

    if (processed.kind != MlsMessageKind.commit) return false;

    if (processed.selfRemoved) {
      // We are out. The group's keys are useless from here, and holding them
      // would only let a stale UI claim it can still read the context.
      await mls.clearActiveGeneration(contextId);
      try {
        await mls.deleteGroup(groupId);
      } catch (e) {
        debugPrint('MLS: failed to delete group after removal from $contextId: $e');
      }
      _contextChanged.add(
        MlsContextChanged(
          contextId: contextId,
          isChannel: isChannel,
          selfRemoved: true,
        ),
      );
      return true;
    }

    if (processed.addedMembers.isNotEmpty ||
        processed.removedLeafIndices.isNotEmpty) {
      _contextChanged.add(
        MlsContextChanged(
          contextId: contextId,
          isChannel: isChannel,
          selfRemoved: false,
        ),
      );
    }

    return false;
  }

  // ---------------------------------------------------------------------------
  // Publishing
  // ---------------------------------------------------------------------------

  /// Stages a commit, publishes it, and merges it only if the server took it.
  ///
  /// On a rejected epoch the staged commit is discarded, this device catches up
  /// to whatever won, and [produce] is called again against the new state. One
  /// retry: a second rejection means something is contending hard enough that
  /// retrying in a loop would just make it worse.
  Future<bool> publish({
    required String contextId,
    required bool isChannel,
    required Future<StagedCommit> Function() produce,
  }) {
    return _serialized(contextId, () async {
      if (await _attemptPublish(contextId, isChannel, produce)) return true;

      await _syncContextInner(contextId, isChannel);
      return _attemptPublish(contextId, isChannel, produce);
    });
  }

  Future<bool> _attemptPublish(
    String contextId,
    bool isChannel,
    Future<StagedCommit> Function() produce,
  ) async {
    final generation = mls.knownGeneration(contextId);
    if (generation == null) return false;

    final groupId = mls.groupId(contextId, generation);
    if (groupId == null) return false;

    final staged = await produce();

    String? groupInfo;
    try {
      groupInfo = await mls.exportGroupInfo(groupId);
    } catch (_) {
      // A refreshed GroupInfo only helps devices that fall too far behind to
      // replay. Losing it is a degraded recovery path, not a reason to abandon
      // the commit.
    }

    try {
      await api.publishCommit(
        contextId: contextId,
        isChannel: isChannel,
        dto: PublishMlsCommitDto(
          epoch: staged.epoch,
          commit: staged.commit,
          senderDeviceId: deviceIdService.deviceId,
          generation: generation,
          groupInfo: groupInfo,
          welcomes: staged.deviceWelcomes,
          fulfilledJoinRequestIds: staged.fulfilledJoinRequestIds,
        ),
      );
      await mls.mergePendingCommit(groupId);
      return true;
    } catch (e) {
      await _discardStagedCommit(groupId);
      if (e is! MlsEpochConflictException) rethrow;
      return false;
    }
  }

  Future<void> _discardStagedCommit(String groupId) async {
    try {
      await mls.clearPendingCommit(groupId);
    } catch (e) {
      debugPrint('MLS: failed to discard a rejected staged commit: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Membership
  // ---------------------------------------------------------------------------

  /// Adds every device of [userIds] to the context's group.
  ///
  /// Returns the devices that had no key package left and were therefore *not*
  /// added. They will never be able to read the context, so callers must surface
  /// them rather than treating a partial add as success.
  Future<List<UnreachableDeviceDto>> addMembers({
    required String contextId,
    required bool isChannel,
    required List<String> userIds,
  }) async {
    final ownDeviceId = deviceIdService.deviceId;
    final tokens = await api.consumeTokensForUsers(userIds);
    final invitees = tokens.deviceTokens
        .where((t) => t.deviceId != ownDeviceId)
        .toList();

    if (invitees.isEmpty) return tokens.unreachableDevices;

    final published = await publish(
      contextId: contextId,
      isChannel: isChannel,
      produce: () async {
        final groupId = mls.activeGroupId(contextId)!;
        final out = await mls.addMembers(
          groupIdB64: groupId,
          keyPackagesB64: invitees.map((t) => t.token).toList(),
        );
        return StagedCommit(
          commit: out.commit,
          epoch: out.epoch,
          deviceWelcomes: invitees
              .map(
                (t) => DeviceWelcomeDto(
                  deviceId: t.deviceId,
                  userId: t.userId,
                  welcome: out.welcome!,
                ),
              )
              .toList(),
        );
      },
    );

    if (!published) {
      throw StateError('Could not add members - the group moved on twice');
    }

    return tokens.unreachableDevices;
  }

  /// Removes members by leaf index. Their devices lose access from the next
  /// epoch onward.
  Future<void> removeMembers({
    required String contextId,
    required bool isChannel,
    required List<int> leafIndices,
  }) async {
    if (leafIndices.isEmpty) return;

    final published = await publish(
      contextId: contextId,
      isChannel: isChannel,
      produce: () async {
        final groupId = mls.activeGroupId(contextId)!;
        final out = await mls.removeMembers(
          groupIdB64: groupId,
          leafIndices: leafIndices,
        );
        return StagedCommit(commit: out.commit, epoch: out.epoch);
      },
    );

    if (!published) {
      throw StateError('Could not remove members - the group moved on twice');
    }
  }

  /// Leaves the context's group.
  ///
  /// MLS does not let a member commit their own removal, so this publishes a
  /// Remove *proposal* and a remaining member turns it into a commit. Local
  /// state is dropped either way - this device gives up access the moment it
  /// asks to leave, whether or not anyone ever commits it.
  Future<void> leaveContext(String contextId, bool isChannel) async {
    if (!mls.isUnlocked) return;

    final generation = mls.knownGeneration(contextId);
    if (generation == null) return;

    final groupId = mls.groupId(contextId, generation);
    if (groupId == null) return;

    final proposal = await mls.leaveGroup(groupId);

    // The proposal is not a commit and does not claim an epoch, so it cannot go
    // through the epoch-ordered publish path. It rides the commit channel
    // because that is the only fanout the group has; a member picks it up and
    // commits it.
    try {
      final state = await api.getState(
        contextId: contextId,
        isChannel: isChannel,
      );
      await api.publishCommit(
        contextId: contextId,
        isChannel: isChannel,
        dto: PublishMlsCommitDto(
          epoch: (state.epoch ?? 0) + 1,
          commit: proposal.commit,
          senderDeviceId: deviceIdService.deviceId,
          generation: generation,
        ),
      );
    } catch (e) {
      // Nothing to undo: local state is already gone, which is the part that
      // matters for our own forward secrecy. The group keeps listing us until
      // someone removes us.
      debugPrint('MLS: leave proposal could not be published for $contextId: $e');
    }

    await mls.clearActiveGeneration(contextId);
  }

  /// Turns a departing member's Remove proposal into a commit.
  Future<void> commitPendingProposals(String contextId, bool isChannel) async {
    if (!mls.isUnlocked) return;

    await publish(
      contextId: contextId,
      isChannel: isChannel,
      produce: () async {
        final groupId = mls.activeGroupId(contextId)!;
        final out = await mls.commitPendingProposals(groupId);
        return StagedCommit(commit: out.commit, epoch: out.epoch);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Encryption state
  // ---------------------------------------------------------------------------

  /// Reconciles this device's local view of a context with the server's.
  ///
  /// Encryption can be switched off and on again while we were away, which mints
  /// a whole new group. Noticing that is what stops us encrypting to a group
  /// that no longer exists.
  Future<MlsContextStateDto> refreshState(
    String contextId,
    bool isChannel,
  ) async {
    final state = await api.getState(
      contextId: contextId,
      isChannel: isChannel,
    );
    final known = mls.knownGeneration(contextId);

    if (!state.encrypted) {
      if (known != null) {
        await mls.clearActiveGeneration(contextId);
        _contextChanged.add(
          MlsContextChanged(
            contextId: contextId,
            isChannel: isChannel,
            selfRemoved: false,
          ),
        );
      }
      return state;
    }

    final active = state.activeGeneration!;
    if (known == active) {
      await syncContext(contextId, isChannel);
      return state;
    }

    // A generation we have never joined. The Welcome for it may already be
    // waiting; if it is not, this device simply cannot read the context until
    // someone adds it back.
    final existing = mls.groupId(contextId, active);
    if (existing != null) {
      await mls.registerGroup(
        contextId: contextId,
        generation: active,
        mlsGroupId: existing,
      );
      await syncContext(contextId, isChannel);
    } else {
      await processPendingWelcomes();
    }

    _contextChanged.add(
      MlsContextChanged(
        contextId: contextId,
        isChannel: isChannel,
        selfRemoved: false,
      ),
    );
    return state;
  }

  // ---------------------------------------------------------------------------

  /// Serialises [op] behind any in-flight work for the same context.
  Future<T> _serialized<T>(String contextId, Future<T> Function() op) {
    final previous = _queues[contextId] ?? Future<void>.value();
    final task = previous.then((_) => op(), onError: (_, _) => op());
    _queues[contextId] = task.then((_) {}, onError: (_, _) {});
    return task;
  }

  Future<void> dispose() => _contextChanged.close();
}
