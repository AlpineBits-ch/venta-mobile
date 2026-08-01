import 'package:flutter/foundation.dart';

import '../crypto/account_identity_service.dart';
import '../device/device_api.dart';
import 'mls_policy_service.dart';

/// What to do about a leaf that turned up in a group without a verifiable device
/// certificate.
enum LeafAction {
  /// Nothing. Either it verified, or the account is in a rollout phase where a
  /// missing certificate is expected.
  allow,

  /// Allow, but mark the device unverified in the roster UI.
  flag,

  /// Propose removing the leaf and say why.
  propose,
}

/// The verdict plus what the user should be told.
class LeafVerdict {
  const LeafVerdict({
    required this.action,
    required this.verdict,
    this.warning,
  });

  final LeafAction action;
  final CertificateVerdict verdict;

  /// Non-null when something happened that a person needs to know about. An
  /// *invalid* certificate always produces one, at every phase - that case
  /// cannot arise by accident.
  final String? warning;
}

/// Decides whether an unrecognised leaf belongs in a group. Contract §H.4, gated
/// by §I.1.
///
/// Anyone holding a group's `GroupInfo` can external-commit into it - **including
/// the server**, which stores it. So the external-commit recovery that makes
/// full-loss restore possible is also, unguarded, a server-side backdoor into
/// every group. The guard is the device certificate: a peer fetches it, checks
/// it against the account identity key it has pinned, and acts on the result.
///
/// The acting is the part that needs care. §H.4 as written says a leaf with no
/// certificate is proposed for removal - and **no device in the field has one**.
/// A client that shipped that rule flat would start proposing the removal of
/// every other device in every group it is in, including its owner's. So
/// enforcement is three-state and server-driven, defaulting to
/// [CertificateEnforcement.observe], and never inferred from this client's own
/// version.
class LeafVerificationService {
  LeafVerificationService({
    required this.identity,
    required this.deviceApi,
    required this.policy,
  });

  final AccountIdentityService identity;
  final DeviceApi deviceApi;
  final MlsPolicyService policy;

  /// How many leaves this session saw without a certificate. §I.1 asks for the
  /// count during the observe phase, because the decision to advance to `Warn`
  /// and then `Enforce` is supposed to be made on coverage data rather than on a
  /// date in a plan.
  int uncertifiedLeavesSeen = 0;

  Future<LeafVerdict> check({
    required String ownerUserId,
    required String deviceId,
    required String deviceSignatureKey,
  }) async {
    final phase = await policy.resolve();

    DeviceCertificate? certificate;
    try {
      final raw = await deviceApi.fetchDeviceCertificate(
        userId: ownerUserId,
        clientDeviceId: deviceId,
      );
      if (raw != null) certificate = DeviceCertificate.fromJson(raw);
    } catch (e) {
      // A certificate we could not fetch is not a certificate that failed.
      // Treating a flaky network as forgery would remove leaves over a timeout.
      debugPrint('MLS: could not fetch $deviceId\'s certificate: $e');
    }

    final verdict = await identity.verify(
      ownerUserId: ownerUserId,
      certificate: certificate,
    );

    switch (verdict) {
      case CertificateVerdict.valid:
        return const LeafVerdict(
          action: LeafAction.allow,
          verdict: CertificateVerdict.valid,
        );

      // Absent. The ordinary state of every device that has not upgraded yet, so
      // the phase decides.
      case CertificateVerdict.missing:
      case CertificateVerdict.unknownIssuer:
      case CertificateVerdict.expired:
        uncertifiedLeavesSeen++;
        return LeafVerdict(
          action: switch (phase) {
            CertificateEnforcement.observe => LeafAction.allow,
            CertificateEnforcement.warn => LeafAction.flag,
            CertificateEnforcement.enforce => LeafAction.propose,
          },
          verdict: verdict,
          warning: phase == CertificateEnforcement.observe
              ? null
              : 'A device on $ownerUserId\'s account has not proved it belongs '
                    'to them. It can read this conversation.',
        );

      // Present and wrong. This cannot happen by accident - only by forgery - so
      // it is at least a warning at every phase, per §I.1.
      case CertificateVerdict.invalid:
        return LeafVerdict(
          action: phase == CertificateEnforcement.enforce
              ? LeafAction.propose
              : LeafAction.flag,
          verdict: verdict,
          warning:
              'A device claiming to belong to $ownerUserId presented a '
              'certificate that does not check out. Do not treat this '
              'conversation as private until it is removed.',
        );

      // Signed by *something*, but not by the key we pinned. Either the account
      // rotated its identity key (§H.5, which needs re-verifying out of band) or
      // someone is impersonating it. Never auto-accepted, exactly as a changed
      // safety number never is.
      case CertificateVerdict.identityChanged:
        return LeafVerdict(
          action: phase == CertificateEnforcement.enforce
              ? LeafAction.propose
              : LeafAction.flag,
          verdict: verdict,
          warning:
              '$ownerUserId\'s security code has changed. Check it with them '
              'in person or over a call before trusting this conversation '
              'again.',
        );
    }
  }
}
