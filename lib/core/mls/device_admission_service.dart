import 'package:flutter/foundation.dart';
import 'package:venta_mls/venta_mls.dart';

import '../../features/mls/data/mls_api.dart';
import '../../features/mls/data/models/mls_dtos.dart';
import '../crypto/master_key_service.dart';
import '../device/device_id_service.dart';
import 'mls_join_request_service.dart';
import 'mls_service.dart';
import 'protection_level_service.dart';

/// What an admission attempt concluded, so the UI can say something true.
enum AdmissionOutcome {
  /// Proof verified and the device was added. Under `TrustedSignIn` nobody
  /// tapped anything - which is why §G.2 makes the *notification* mandatory.
  admitted,

  /// Proof verified, but the account is on `VerifiedDevices`, so a human still
  /// has to approve. Valid proof is necessary, not sufficient.
  awaitingApproval,

  /// No proof yet. The joining device has not answered the challenge, or no
  /// device of that account has been online to issue one.
  awaitingProof,

  /// The proof did not verify. This cannot happen by accident: whoever produced
  /// it did not hold the account master key.
  rejected,

  /// This device cannot decide - it has no master key unlocked, so it can verify
  /// nothing. Another device of the account has to handle it.
  cannotVerify,
}

/// Both halves of contract §G's device admission.
///
/// The naive version of auto-approval — the server says a device belongs to you,
/// so an existing device adds it — hands the server exactly the power MLS exists
/// to remove. What happens instead is that the joining device proves possession
/// of the **account master key**, which the server holds only in wrapped form,
/// and an existing device verifies that proof *locally*. The server relays and
/// cannot forge; a device it injected into your account still cannot get into
/// any group.
///
/// That is what makes `TrustedSignIn` a real security level rather than a
/// convenience flag. Its honest limitation is that it reduces to the password's
/// strength, which is why `VerifiedDevices` exists and why the settings screen
/// has to say so in plain language.
class DeviceAdmissionService {
  DeviceAdmissionService({
    required this.api,
    required this.mls,
    required this.joinRequests,
    required this.masterKeys,
    required this.protectionLevels,
    required this.deviceIdService,
    VentaMls? engine,
  }) : _engine = engine ?? VentaMls();

  final MlsApi api;
  final MlsService mls;
  final MlsJoinRequestService joinRequests;
  final MasterKeyService masterKeys;
  final ProtectionLevelService protectionLevels;
  final DeviceIdService deviceIdService;
  final VentaMls _engine;

  /// §G.2: at most one auto-admitted device per 24h per account. A burst of
  /// admissions is the signature of a compromise, so the second concurrent
  /// request in the window falls back to manual approval rather than failing -
  /// the user is not locked out, they are asked.
  static const _autoAdmitWindow = Duration(hours: 24);
  DateTime? _lastAutoAdmit;

  /// Devices admitted without a tap, surfaced so §G.2's "silent admission, never
  /// silent notification" is enforceable by the UI rather than by hope.
  final ValueNotifier<List<AdmittedDevice>> recentlyAdmitted =
      ValueNotifier<List<AdmittedDevice>>(const []);

  // ---------------------------------------------------------------------------
  // Joining side
  // ---------------------------------------------------------------------------

  /// Answers a challenge raised against one of *our own* pending requests.
  ///
  /// Returns false when there is nothing to answer yet, or when this device
  /// cannot - a handset that has never unlocked the master key on this account
  /// has nothing to prove with, and must fall back to a human approving it.
  Future<bool> answerChallenge({
    required String contextId,
    required bool isChannel,
    required String requestId,
    required String userId,
    required String signatureKeyFingerprint,
  }) async {
    final deviceId = deviceIdService.deviceIdOrNull;
    if (deviceId == null) return false;

    final challenge = await api.fetchChallenge(
      contextId: contextId,
      isChannel: isChannel,
      requestId: requestId,
    );
    if (challenge == null) return false;
    if (challenge.isExpired) {
      debugPrint('MLS: the admission challenge for $requestId has expired');
      return false;
    }

    final masterKey = await masterKeys.peek(userId: userId, deviceId: deviceId);
    if (masterKey == null) {
      debugPrint(
        'MLS: no master key on this device, so it cannot prove it belongs to '
        'this account - admission needs a human',
      );
      return false;
    }

    final proof = await _engine.signAdmissionProof(
      masterKeyB64: masterKey,
      challengeB64: challenge.challenge,
      // Bound to *this* device and *this* signing key: a proof lifted off the
      // wire cannot be used to admit a different device.
      deviceId: deviceId,
      signatureKeyFingerprint: signatureKeyFingerprint,
    );

    await api.submitProof(
      contextId: contextId,
      isChannel: isChannel,
      requestId: requestId,
      challengeId: challenge.id,
      proof: proof,
    );
    return true;
  }

  // ---------------------------------------------------------------------------
  // Admitting side
  // ---------------------------------------------------------------------------

  /// Issues a challenge for someone else's pending request against our account.
  ///
  /// Only for the account's *own* devices: a peer's new device is their
  /// business, and §G.4 is explicit that our level governs our devices only.
  Future<MlsAdmissionChallengeDto?> challenge({
    required String contextId,
    required bool isChannel,
    required MlsJoinRequestDto request,
    required String userId,
  }) async {
    if (request.requesterUserId != userId) return null;

    final challenge = await _engine.randomBytes(32);
    try {
      return await api.issueChallenge(
        contextId: contextId,
        isChannel: isChannel,
        requestId: request.id,
        challenge: challenge,
      );
    } catch (e) {
      debugPrint('MLS: could not issue an admission challenge: $e');
      return null;
    }
  }

  /// Verifies the proof and, under `TrustedSignIn`, admits the device.
  ///
  /// The three checks `MlsJoinRequestService.admit` makes on the key package
  /// still apply - the proof says *whose* device this is, not *which bytes* are
  /// being added, and skipping the latter would reintroduce the
  /// server-substitutes-a-key-package attack in a new place.
  Future<AdmissionOutcome> tryAdmit({
    required String contextId,
    required bool isChannel,
    required MlsJoinRequestDto request,
    required String userId,
    required String keyPackage,
  }) async {
    final deviceId = deviceIdService.deviceIdOrNull;
    if (deviceId == null) return AdmissionOutcome.cannotVerify;

    final masterKey = await masterKeys.peek(userId: userId, deviceId: deviceId);
    if (masterKey == null) return AdmissionOutcome.cannotVerify;

    final challenge = await api.fetchChallenge(
      contextId: contextId,
      isChannel: isChannel,
      requestId: request.id,
    );
    if (challenge == null) return AdmissionOutcome.awaitingProof;
    if (challenge.isExpired) return AdmissionOutcome.awaitingProof;

    final proof = await api.fetchProof(
      contextId: contextId,
      isChannel: isChannel,
      requestId: request.id,
    );
    if (proof == null) return AdmissionOutcome.awaitingProof;
    if (proof.challengeId != challenge.id) {
      // A proof for a challenge nobody is currently asking about. Replay, or a
      // server splicing an old answer onto a new question.
      return AdmissionOutcome.rejected;
    }

    final valid = await _engine.verifyAdmissionProof(
      masterKeyB64: masterKey,
      challengeB64: challenge.challenge,
      deviceId: request.requesterDeviceId,
      signatureKeyFingerprint: request.signatureKeyFingerprint,
      proofB64: proof.proof,
    );
    if (!valid) return AdmissionOutcome.rejected;

    // Valid proof is necessary at both levels and sufficient at only one.
    if (protectionLevels.effectiveLevel == ProtectionLevel.verifiedDevices) {
      return AdmissionOutcome.awaitingApproval;
    }

    // The server's published verdict on the 24h budget (contract §J.4). It
    // cannot enforce this - it holds no group keys, so only this client can
    // decline to mint the Add commit - which is exactly why honouring it is not
    // optional. It also counts *devices* rather than requests, and knows about
    // admissions this handset never saw, so it is the better answer than the
    // local clock below.
    if (request.requiresManualApproval) {
      debugPrint(
        'MLS: the server says ${request.requesterDeviceId} needs approving by '
        'hand - the auto-admission budget is spent',
      );
      return AdmissionOutcome.awaitingApproval;
    }

    // Local backstop for the same rule, for the window where the server has not
    // yet counted an admission this device just made.
    final last = _lastAutoAdmit;
    if (last != null && DateTime.now().difference(last) < _autoAdmitWindow) {
      debugPrint(
        'MLS: an auto-admission already happened on this device in the last '
        '24h, so this one needs approving by hand',
      );
      return AdmissionOutcome.awaitingApproval;
    }

    await joinRequests.admit(
      contextId: contextId,
      request: request,
      keyPackage: keyPackage,
      isChannel: isChannel,
    );
    _lastAutoAdmit = DateTime.now();

    // §G.2, item 1. Admission may be silent; notification may not.
    recentlyAdmitted.value = [
      ...recentlyAdmitted.value,
      AdmittedDevice(
        deviceId: request.requesterDeviceId,
        userId: request.requesterUserId,
        contextId: contextId,
        fingerprint: request.signatureKeyFingerprint,
        at: DateTime.now(),
      ),
    ];
    return AdmissionOutcome.admitted;
  }

  void acknowledge(String deviceId) {
    recentlyAdmitted.value = recentlyAdmitted.value
        .where((d) => d.deviceId != deviceId)
        .toList();
  }
}

/// A device that was let into a group, for the timeline event and the one-tap
/// revoke §G.2 requires.
class AdmittedDevice {
  const AdmittedDevice({
    required this.deviceId,
    required this.userId,
    required this.contextId,
    required this.fingerprint,
    required this.at,
  });

  final String deviceId;
  final String userId;
  final String contextId;

  /// Shown so the owner can compare it out of band, exactly as they would for a
  /// manual approval. An admission nobody can check is an admission nobody can
  /// dispute.
  final String fingerprint;
  final DateTime at;
}
