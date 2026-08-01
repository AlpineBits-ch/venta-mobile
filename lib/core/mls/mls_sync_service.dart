import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:venta_mls/venta_mls.dart';

import '../../features/mls/data/mls_api.dart';
import '../../features/mls/data/models/mls_dtos.dart';
import '../device/device_id_service.dart';
import 'mls_failure_log.dart';
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

/// What one entry off the commit channel did to this device's group.
///
/// Only [advanced] is progress. The distinction exists because the commit
/// channel carries Remove *proposals* too - it is the only fanout a group has -
/// and processing one moves nothing, so treating it as progress makes the
/// catch-up loop non-terminating.
enum _ApplyOutcome { advanced, proposal, selfRemoved, ignored }

/// A commit produced locally but not yet published.
class StagedCommit {
  const StagedCommit({
    required this.commit,
    required this.epoch,
    this.groupInfo,
    this.deviceWelcomes = const [],
    this.fulfilledJoinRequestIds = const [],
  });

  final String commit;

  /// Epoch this commit establishes once merged.
  final int epoch;

  /// GroupInfo for the epoch this commit establishes, straight from the engine.
  ///
  /// Not exported separately: an exported one describes the epoch the group is
  /// on *now*, and this commit is not merged yet, so it would be one behind.
  final String? groupInfo;

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
    MlsFailureLog? failures,
  }) : failures = failures ?? MlsFailureLog.shared;

  final MlsService mls;
  final MlsApi api;
  final DeviceIdService deviceIdService;
  final MlsFailureLog failures;

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

  /// Contexts holding a staged commit whose publish outcome is unknown, and the
  /// epoch it claims.
  ///
  /// A publish that times out after the server committed used to be treated as
  /// a rejection: the staged commit was discarded, and the next catch-up then
  /// tried to `processMessage` this device's own commit, which fails and forks
  /// it off the group permanently. Remembering it instead lets the next
  /// catch-up settle the question - our commit is in the page, so merge it, or
  /// somebody else's is, so drop ours and apply theirs.
  final _unconfirmedCommits = <String, int>{};

  /// Welcomes this session has already failed to join, and how often.
  ///
  /// A structurally broken Welcome is not going to become valid: retrying it on
  /// every launch, every push and every state refresh is an unbounded loop
  /// against a single-use key that can never work. Bounded per process rather
  /// than persisted - a restart is cheap to allow, and the failure is surfaced
  /// through [failures] either way.
  final _welcomeAttempts = <String, int>{};

  static const _maxWelcomeAttempts = 3;

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
      // Given up on for this process. Still deliberately not acked: the ack is
      // what destroys the server's copy, and a restart or a fixed client should
      // get another go at it.
      if ((_welcomeAttempts[welcome.id] ?? 0) >= _maxWelcomeAttempts) continue;
      if (await _joinFromWelcome(welcome)) joined.add(welcome.id);
    }

    if (joined.isNotEmpty) await api.ackWelcomes(joined, deviceId: deviceId);
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
      _welcomeAttempts.remove(welcome.id);
      failures.recordSuccess(welcome.contextId);
      _contextChanged.add(
        MlsContextChanged(
          contextId: welcome.contextId,
          isChannel: welcome.isChannel,
          selfRemoved: false,
        ),
      );
      return true;
    } catch (e) {
      _welcomeAttempts[welcome.id] = (_welcomeAttempts[welcome.id] ?? 0) + 1;
      failures.recordJoinFailure(contextId: welcome.contextId, reason: e);
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

      final ownDeviceId = deviceIdService.deviceIdOrNull;
      var applied = 0;
      for (final commit in commits) {
        final expected = epoch + applied + 1;

        // A genuine gap. The page started above our epoch, which should be
        // impossible - stopping is safer than applying out of order.
        if (commit.epoch > expected) break;

        // Our own commit, still staged because the publish response never came
        // back. It is already in the group's history, so processing it would
        // fail; merging is what this device owes.
        if (commit.senderDeviceId == ownDeviceId &&
            commit.epoch == expected &&
            _unconfirmedCommits[contextId] == commit.epoch) {
          if (!await _mergeOwnCommit(contextId, groupId, commit.epoch)) break;
          applied++;
          continue;
        }

        // Everything else our own device published is already merged - it is in
        // the page because the server keeps it, not because we owe anything.
        if (commit.senderDeviceId == ownDeviceId && commit.epoch < expected) {
          continue;
        }

        final outcome = await _applyCommit(
          contextId: contextId,
          isChannel: isChannel,
          groupId: groupId,
          commit: commit,
          expectedEpoch: expected,
        );

        switch (outcome) {
          case _ApplyOutcome.selfRemoved:
            return;
          case _ApplyOutcome.advanced:
            applied++;
          // A Remove proposal rides the *commit* channel because that is the
          // only fanout a group has, but processing one does not move any
          // client's MLS epoch. Counting it as progress is what made this loop
          // spin forever: the next page returns the same proposal, `applied` is
          // never zero, `while (true)` never exits - all while holding the
          // per-context queue the drain that would resolve it needs.
          case _ApplyOutcome.proposal:
          case _ApplyOutcome.ignored:
            break;
        }
      }

      // Only real commits count as progress. A page of nothing but proposals is
      // a terminating page, not a reason to ask again.
      if (applied == 0) return;
    }
  }

  /// Applies a commit this device published but never got an answer for.
  ///
  /// Returns false when there was nothing staged after all, which means the
  /// local state and the server's have diverged in a way this loop cannot
  /// settle - stopping beats guessing.
  Future<bool> _mergeOwnCommit(
    String contextId,
    String groupId,
    int epoch,
  ) async {
    try {
      final merged = await mls.mergePendingCommit(groupId);
      _unconfirmedCommits.remove(contextId);
      return merged >= epoch;
    } catch (e) {
      debugPrint('MLS: could not merge our own commit in $contextId: $e');
      _unconfirmedCommits.remove(contextId);
      return false;
    }
  }

  Future<_ApplyOutcome> _applyCommit({
    required String contextId,
    required bool isChannel,
    required String groupId,
    required MlsCommitDto commit,
    required int expectedEpoch,
  }) async {
    // Somebody else won the epoch we still hold a commit for. Ours was never
    // taken, so it must never be applied - drop it before theirs goes on.
    if (commit.epoch == expectedEpoch &&
        _unconfirmedCommits.remove(contextId) != null) {
      await _discardStagedCommit(groupId);
    }

    // The server tells us which rows are proposals rather than us guessing from
    // the payload; parsing MLS bytes to find out is not the transport layer's
    // job, and getting it wrong is what made this loop non-terminating.
    if (commit.isProposal) {
      try {
        await mls.processMessage(
          groupIdB64: groupId,
          messageB64: commit.commit,
        );
        _pendingProposalContexts.add(contextId);
      } catch (e) {
        // Already committed away by someone else, most likely. Not progress and
        // not a reason to abandon the rest of the page.
        debugPrint('MLS: could not queue a proposal for $contextId: $e');
      }
      return _ApplyOutcome.proposal;
    }

    final MlsProcessedMessage processed;
    try {
      processed = await mls.processMessage(
        groupIdB64: groupId,
        messageB64: commit.commit,
      );
    } catch (e) {
      // Entries at or below where we already are: an already-applied commit, or
      // a proposal that has since been committed away. Neither is progress and
      // neither is a reason to abandon the rest of the page.
      if (commit.epoch < expectedEpoch) return _ApplyOutcome.ignored;
      failures.recordJoinFailure(contextId: contextId, reason: e);
      rethrow;
    }

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
      return _ApplyOutcome.proposal;
    }

    if (processed.kind != MlsMessageKind.commit) return _ApplyOutcome.ignored;

    failures.recordSuccess(contextId);

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
      return _ApplyOutcome.selfRemoved;
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

    return _ApplyOutcome.advanced;
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

    // The commit's own GroupInfo, which describes the epoch it *establishes*.
    //
    // Exporting one instead was the bug: an export can only describe the epoch
    // the group is on right now, and a commit is deliberately not merged until
    // the server accepts it - so every published GroupInfo was one epoch stale,
    // and a device recovering by external commit landed behind the group it was
    // rejoining. Reordering export-versus-merge does not fix that; only the
    // value openmls hands back with the commit does.
    var groupInfo = staged.groupInfo;
    if (groupInfo == null) {
      try {
        // Fallback for a commit shape that produces none. Stale by one epoch,
        // which is a degraded recovery path rather than no recovery path.
        groupInfo = await mls.exportGroupInfo(groupId);
      } catch (_) {
        // Losing it is not a reason to abandon the commit.
      }
    }

    try {
      final published = await api.publishCommit(
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
      // `duplicate` is a success, not a race: the server matched this exact
      // commit on (senderDeviceId, generation, epoch, payload hash) and returned
      // the row it already had. That is the whole point of contract §E4 - it is
      // how a client recovers from a response that went missing rather than
      // discarding a commit the group has already applied.
      if (published.duplicate) {
        debugPrint(
          'MLS: the server already had our commit for $contextId at epoch '
          '${staged.epoch} - merging rather than re-issuing',
        );
      }
      _unconfirmedCommits.remove(contextId);
      await mls.mergePendingCommit(groupId);
      return true;
    } on MlsEpochConflictException {
      // A definite "no". Somebody else took this epoch, so our commit was never
      // applied anywhere and must not be applied here - discard, catch up, and
      // re-issue against whatever won.
      _unconfirmedCommits.remove(contextId);
      await _discardStagedCommit(groupId);
      return false;
    } catch (e) {
      // Anything else - a timeout, a dropped connection, a 5xx - leaves it
      // genuinely unknown whether the server took the commit. Discarding here
      // is what strands a device for good: if it *was* taken, the commit comes
      // back in the next catch-up page, this device tries to `processMessage`
      // its own commit, fails, and is forked off the group with no way back.
      //
      // Keeping it staged is recoverable in both directions. The next
      // `_syncContextInner` either finds our commit at the epoch we claimed and
      // merges it, or finds somebody else's and drops ours first. Re-publishing
      // is safe meanwhile: the server matches on (senderDeviceId, generation,
      // epoch, payload hash) and returns the stored row (contract §E4).
      _unconfirmedCommits[contextId] = staged.epoch;
      debugPrint(
        'MLS: publish outcome unknown for $contextId at epoch ${staged.epoch}, '
        'keeping the commit staged until catch-up settles it: $e',
      );
      rethrow;
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
          groupInfo: out.groupInfo,
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
        return StagedCommit(
          commit: out.commit,
          epoch: out.epoch,
          groupInfo: out.groupInfo,
        );
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
          // Declared, not inferred. The server does not advance the group's
          // epoch for a proposal, and its unique index is filtered on this flag
          // so the proposal does not occupy the slot the real commit needs.
          isProposal: true,
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
        return StagedCommit(
          commit: out.commit,
          epoch: out.epoch,
          groupInfo: out.groupInfo,
        );
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
  ///
  /// The entry is removed once nothing is queued behind it. This map used to
  /// grow for the lifetime of the process - one entry per context ever synced,
  /// each holding a completed `Future` - which on an account with a few hundred
  /// conversations is a leak that only ever gets worse.
  Future<T> _serialized<T>(String contextId, Future<T> Function() op) {
    final previous = _queues[contextId] ?? Future<void>.value();
    final task = previous.then((_) => op(), onError: (_, _) => op());
    final tail = task.then((_) {}, onError: (_, _) {});
    _queues[contextId] = tail;
    unawaited(
      tail.whenComplete(() {
        // Only if nothing else queued behind us in the meantime; otherwise the
        // next caller would run concurrently with work already in flight.
        if (identical(_queues[contextId], tail)) _queues.remove(contextId);
      }),
    );
    return task;
  }

  Future<void> dispose() => _contextChanged.close();
}
