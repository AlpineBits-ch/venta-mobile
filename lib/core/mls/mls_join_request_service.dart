import 'package:flutter/foundation.dart';

import '../../features/mls/data/mls_api.dart';
import '../../features/mls/data/models/mls_dtos.dart';
import '../device/device_id_service.dart';
import 'mls_service.dart';
import 'mls_sync_service.dart';

/// Why an approval did not result in an admission.
///
/// Distinct from an ordinary failure because it might mean tampering rather than
/// breakage, and the UI has to say so rather than showing "something went
/// wrong".
class JoinRequestVerificationException implements Exception {
  const JoinRequestVerificationException(this.message);

  final String message;

  @override
  String toString() => 'JoinRequestVerificationException: $message';
}

/// One context the launch sweep may ask to be admitted to.
///
/// [serverSaysEncrypted] comes off the conversation list the caller already
/// holds, so the sweep needs no per-context request to decide. It is only ever
/// used to decide whether to *ask*: the other direction is answered by the local
/// floor (`MlsService.hasEverHeldGroup`), so a server calling an encrypted
/// context plaintext cannot quietly drop it from the candidate set.
///
/// Alpine's equivalent carries a third field, because its `shouldProbe` reads a
/// health entry whose reason can be `removed`. Mobile answers the same question
/// from `MlsService.wasRemovedHere`, so it is deliberately **not** a candidate
/// field: it is per-installation state written by the §E9 push and it has to
/// survive a relaunch, which a value handed in by a caller does not.
///
/// `MlsFailureLog` is deliberately not its home either. It counts decrypt and
/// join failures with no cause attached, so nothing in it separates "removed on
/// purpose" from "behind on commits", and it resets on restart - fatal for a
/// signal the *launch* sweep is the only reader of.
typedef MlsAdmissionCandidate = ({
  String contextId,
  bool isChannel,
  bool serverSaysEncrypted,
});

/// Getting into, and letting people into, an encrypted context.
///
/// The server cannot admit anyone — it holds no group keys, so only a current
/// member can produce an Add commit. Admission is therefore a request that
/// members review, and the approval that meets the threshold is what makes that
/// member's client mint the Welcome.
///
/// This closes two holes. The first is somebody who joined a guild after a
/// channel was encrypted, who could neither read it nor send to it with nobody
/// able to do anything about it. The second, and the more common one, is a
/// **newly registered device** on an account that already has encrypted DMs: a
/// group member is a device, not a user, so a handset installed after the
/// conversation existed was never welcomed to it and until contract §B there
/// was no route by which it could be.
class MlsJoinRequestService {
  MlsJoinRequestService({
    required this.mls,
    required this.sync,
    required this.api,
    required this.deviceIdService,
  });

  final MlsService mls;
  final MlsSyncService sync;
  final MlsApi api;
  final DeviceIdService deviceIdService;

  Future<List<MlsJoinRequestDto>> list(
    String contextId, {
    bool isChannel = true,
  }) => api.listJoinRequests(contextId: contextId, isChannel: isChannel);

  Future<void> deny({
    required String contextId,
    required String requestId,
    bool isChannel = true,
  }) => api.denyJoinRequest(
    contextId: contextId,
    isChannel: isChannel,
    requestId: requestId,
  );

  Future<void> cancel({
    required String contextId,
    required String requestId,
    bool isChannel = true,
  }) => api.cancelJoinRequest(
    contextId: contextId,
    isChannel: isChannel,
    requestId: requestId,
  );

  /// Asks to be let into an encrypted context.
  ///
  /// Mints a key package specifically for this request rather than pointing at
  /// the pool on the server: reviewers approve exact bytes, and bytes nobody
  /// else can hand out cannot be swapped between approval and add.
  Future<MlsJoinRequestDto> requestAccess(
    String contextId, {
    bool isChannel = true,
  }) async {
    final keyPackage = await _mintRequestKeyPackage();
    final info = await mls.inspectKeyPackage(keyPackage);

    return api.requestAccess(
      contextId: contextId,
      isChannel: isChannel,
      keyPackage: keyPackage,
      deviceId: deviceIdService.deviceId,
      signatureKeyFingerprint: info.signatureKeyFingerprint,
    );
  }

  /// Most contexts one launch will actually probe.
  ///
  /// A device that has just lost its keys is locked out of *everything*, so an
  /// uncapped sweep turns one bad launch into a burst of key-package mints and
  /// join requests - exactly the shape the server's rate limits exist to refuse,
  /// and arriving all at once helps nobody. The rest are deferred to the next
  /// launch, which is minutes away for a phone.
  static const maxContextsPerSweep = 10;

  /// Submits a join request for every encrypted context this device holds no
  /// group for. Contract §B's discovery step, run at launch.
  ///
  /// **Why this exists rather than leaving it to the banner.** Without it,
  /// exclusion is discovered one conversation at a time, by the user opening
  /// each one and reading a notice - which is no use at all to somebody who does
  /// not know which conversations they are missing from, and no use whatsoever
  /// for the ones they never open. A device stranded by a bug stays stranded
  /// until it is noticed. That is not self-healing; this is. Alpine runs the
  /// same sweep from `runMlsLaunch`, which is the only reason a desktop that had
  /// been left out ever managed to ask.
  ///
  /// Client-driven rather than push-driven on purpose: the server has no way to
  /// know a device is missing a group, because it never learns which devices
  /// hold a leaf. Idempotent server-side - resubmitting an open request returns
  /// the existing one - so this is safe to run on every launch.
  ///
  /// **Cheap when nothing is wrong.** [_shouldProbe] decides every candidate
  /// from local state alone, so a healthy device completes the whole sweep
  /// without a single request. It used to call `getState` per context before it
  /// could tell, which made the common case cost one round trip per
  /// conversation.
  ///
  /// Returns the contexts a request was raised for. Failures are per context and
  /// non-fatal: one conversation refusing must not stop the rest.
  Future<List<String>> requestAccessWhereMissing(
    Iterable<MlsAdmissionCandidate> candidates,
  ) async {
    // No signing key loaded means no key package to offer and nothing to join
    // with. Asking would fail on every candidate and leave a wall of failures
    // behind it.
    if (!mls.isUnlocked) return const [];

    final requested = <String>[];
    var probed = 0;

    for (final candidate in candidates) {
      if (!_shouldProbe(candidate)) continue;
      if (probed >= maxContextsPerSweep) {
        debugPrint(
          'MLS: deferring the rest of the admission sweep after '
          '$maxContextsPerSweep contexts',
        );
        break;
      }
      probed++;

      // Sequential on purpose, for the same reason as the cap: these are
      // recovery requests from a device that is already locked out, and firing
      // them in parallel is the burst the limits are there to stop.
      try {
        await requestAccess(candidate.contextId, isChannel: candidate.isChannel);
        requested.add(candidate.contextId);
      } catch (e) {
        debugPrint(
          'MLS: could not ask for access to ${candidate.contextId}: $e',
        );
      }
    }
    return requested;
  }

  /// Whether a candidate is worth a network round trip. Every check is local.
  ///
  /// Returns false for the three cases where asking would be wrong rather than
  /// merely wasteful.
  bool _shouldProbe(MlsAdmissionCandidate candidate) {
    // Already in the group. The overwhelmingly common answer, and it costs
    // nothing to reach.
    if (mls.activeGroupId(candidate.contextId) != null) return false;

    // Somebody removed this device on purpose (§E9). Checked before the floor
    // below rather than after, because a removed device *has* held a group here
    // - the floor is satisfied and would keep it a candidate forever.
    //
    // A sweep that asked to be let back in on every launch would turn one
    // deliberate removal into a recurring approval prompt for the person who
    // performed it: spam, and a way to wear down by repetition a decision that
    // was made once, which is the outcome §E9 exists to prevent. There is
    // deliberately no override. The way back from a removal the user has changed
    // their mind about is the manual re-link affordance, which costs a human
    // pressing a button rather than a loop that runs on its own.
    if (mls.wasRemovedHere(candidate.contextId)) return false;


    // Nothing to join. The local floor outranks the wire: a context this device
    // has ever held a group for stays a candidate even when the server now calls
    // it plaintext, because that claim is the one thing the floor exists to
    // disbelieve.
    return candidate.serverSaysEncrypted ||
        mls.hasEverHeldGroup(candidate.contextId);
  }

  /// Rejoins a context by **external commit**, using the GroupInfo the server
  /// holds for its live generation.
  ///
  /// This is the recovery for a device that fell further behind than the
  /// server's commit retention, where replaying is no longer possible. It is
  /// *not* a substitute for a join request: an external commit only works when
  /// the group's public GroupInfo is available and the group's policy permits
  /// external joins, and it announces itself to the group as a commit like any
  /// other. Callers should try this first and fall back to
  /// [requestAccess] when the server has no GroupInfo to offer.
  ///
  /// Returns false when there was nothing to rejoin with.
  Future<bool> rejoin(String contextId, {required bool isChannel}) async {
    if (!mls.isUnlocked) return false;

    final state = await api.getState(contextId: contextId, isChannel: isChannel);
    final groupInfo = state.mlsGroupInfo;
    final generation = state.activeGeneration;
    if (!state.encrypted || groupInfo == null || generation == null) {
      return false;
    }

    final out = await mls.rejoinGroup(groupInfo);

    // Registered before publishing, unlike the staged-commit dance: an external
    // commit is not staged - the engine has already built the group - so if the
    // publish fails the group exists locally either way and the registry has to
    // know about it or it is unaddressable.
    await mls.registerGroup(
      contextId: contextId,
      generation: generation,
      mlsGroupId: out.groupInfo.groupId,
    );

    await api.publishCommit(
      contextId: contextId,
      isChannel: isChannel,
      dto: PublishMlsCommitDto(
        epoch: out.groupInfo.epoch,
        commit: out.externalCommit,
        senderDeviceId: deviceIdService.deviceId,
        generation: generation,
      ),
    );

    await sync.syncContext(contextId, isChannel);
    return true;
  }

  /// This device's own identity fingerprint, so its owner can read it out to a
  /// reviewer over a call.
  ///
  /// Free to call as often as the UI likes: it is a hash of the signing key this
  /// device already holds. It deliberately does *not* mint a key package to
  /// inspect - that writes key material nothing will ever consume into the
  /// engine's store, permanently, and the store is rewritten in full on every
  /// save. The value is identical either way (pinned by
  /// `a_devices_own_fingerprint_needs_no_key_package` in the Rust tests),
  /// because both hash the same long-lived signature key.
  Future<String?> ownFingerprint() => mls.ownFingerprint();

  Future<String> _mintRequestKeyPackage() async {
    final packages = await mls.generateKeyPackages(1);
    if (packages.isEmpty) {
      throw StateError('Could not generate a key package for the request');
    }
    return packages.first.keyPackage;
  }

  /// Vouches for a request, and admits the device when that completes the
  /// threshold.
  ///
  /// Before adding anything this re-derives the fingerprint, hash and claimed
  /// identity from the bytes the server handed back and checks all three against
  /// what was reviewed. Skipping that would make the whole review ceremonial: a
  /// server that substituted its own key package between approval and add would
  /// have its key silently welcomed into the group.
  ///
  /// Returns whether the device was actually admitted by this call.
  Future<bool> approve({
    required String contextId,
    required MlsJoinRequestDto request,
    bool isChannel = true,
  }) async {
    final result = await api.approveJoinRequest(
      contextId: contextId,
      isChannel: isChannel,
      requestId: request.id,
    );

    if (!result.thresholdMet) return false;

    final keyPackage = result.keyPackage;
    if (keyPackage == null) {
      throw const JoinRequestVerificationException(
        'The server reported the threshold met but returned no key package.',
      );
    }

    return admit(
      contextId: contextId,
      request: request,
      keyPackage: keyPackage,
      isChannel: isChannel,
    );
  }

  /// Mints the Add commit and the Welcome for an already-decided request.
  ///
  /// Split out from [approve] because the automatic path (contract §G) reaches
  /// exactly here: what differs between "a human tapped approve" and "the device
  /// proved it holds the account master key" is *how the decision was made*, not
  /// what happens afterwards. The three checks below apply to both, and skipping
  /// them for the automatic path would be the obvious way to reintroduce the
  /// server-substitutes-a-key-package attack.
  Future<bool> admit({
    required String contextId,
    required MlsJoinRequestDto request,
    required String keyPackage,
    bool isChannel = true,
  }) async {
    final info = await mls.inspectKeyPackage(keyPackage);

    if (info.keyPackageHash != request.keyPackageHash) {
      throw const JoinRequestVerificationException(
        'The key package does not match the one that was reviewed. '
        'Nothing was added.',
      );
    }
    if (info.signatureKeyFingerprint != request.signatureKeyFingerprint) {
      throw const JoinRequestVerificationException(
        'The identity key does not match the one that was reviewed. '
        'Nothing was added.',
      );
    }
    if (info.identity != request.requesterUserId) {
      throw const JoinRequestVerificationException(
        'The key package claims a different user than the request. '
        'Nothing was added.',
      );
    }

    final admitted = await sync.publish(
      contextId: contextId,
      isChannel: isChannel,
      produce: () async {
        final groupId = mls.activeGroupId(contextId)!;
        final out = await mls.addMembers(
          groupIdB64: groupId,
          keyPackagesB64: [keyPackage],
        );
        return StagedCommit(
          commit: out.commit,
          epoch: out.epoch,
          groupInfo: out.groupInfo,
          deviceWelcomes: [
            DeviceWelcomeDto(
              deviceId: request.requesterDeviceId,
              userId: request.requesterUserId,
              welcome: out.welcome!,
            ),
          ],
          fulfilledJoinRequestIds: [request.id],
        );
      },
    );

    if (!admitted) {
      throw StateError(
        'The group moved on while admitting; the request is still open.',
      );
    }

    return true;
  }
}
