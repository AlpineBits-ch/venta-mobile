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

  /// Devices that have presented a valid certificate at least once, per
  /// account.
  ///
  /// §L.5: **absence after presence is an attack, not a pending upgrade.** The
  /// three-state rollout exists because no device in the field has a certificate
  /// yet; it must not also excuse a device that had one yesterday and does not
  /// today, which is what a server suppressing the certificate of a leaf it
  /// wants to substitute looks like.
  ///
  /// Session-scoped rather than persisted, which is a real limitation: a
  /// suppression that outlasts a restart is not caught. Persisting it needs a
  /// store this service does not own, and a wrong entry here proposes removing
  /// somebody's device - so the cautious version ships first.
  final Set<String> _hasEverCertified = {};

  /// Leaves whose credential identity was not already known in the group.
  ///
  /// §L.5 again: `Observe` suppresses *removal*, never *detection*. An unknown
  /// identity turning up in a group is the external-commit injection signature
  /// and has to reach the user at every phase.
  final Set<String> unknownIdentitiesSeen = {};

  /// [leafDeviceId] and [leafSignatureKey] come from the **leaf**, not from the
  /// certificate. `check` used to take both and read neither, verifying the
  /// certificate against its own self-reported fields; certificates are public,
  /// so replaying a genuine one against an injected leaf passed at full
  /// enforcement (§L.2).
  ///
  /// [knownIdentities] is the set of credential identities the caller already
  /// expects in this group - the conversation's members. A leaf outside it is
  /// surfaced regardless of phase.
  Future<LeafVerdict> check({
    required String ownerUserId,
    required String leafDeviceId,
    required String leafSignatureKey,
    Set<String> knownIdentities = const {},
  }) async {
    final phase = await policy.resolve();
    final everCertified = _hasEverCertified.contains(
      _seen(ownerUserId, leafDeviceId),
    );

    final unknownIdentity =
        knownIdentities.isNotEmpty && !knownIdentities.contains(ownerUserId);
    if (unknownIdentity) unknownIdentitiesSeen.add(ownerUserId);

    DeviceCertificate? certificate;
    try {
      final raw = await deviceApi.fetchDeviceCertificate(
        userId: ownerUserId,
        clientDeviceId: leafDeviceId,
      );
      if (raw != null) certificate = DeviceCertificate.fromJson(raw);
    } catch (e) {
      // A certificate we could not fetch is not a certificate that failed.
      // Treating a flaky network as forgery would remove leaves over a timeout.
      debugPrint('MLS: could not fetch $leafDeviceId\'s certificate: $e');
    }

    final verdict = await identity.verify(
      ownerUserId: ownerUserId,
      certificate: certificate,
      leafDeviceId: leafDeviceId,
      leafSignatureKey: leafSignatureKey,
    );

    switch (verdict) {
      case CertificateVerdict.valid:
        _hasEverCertified.add(_seen(ownerUserId, leafDeviceId));
        return LeafVerdict(
          action: LeafAction.allow,
          verdict: CertificateVerdict.valid,
          warning: unknownIdentity
              ? '$ownerUserId joined this conversation from a device nobody '
                    'here added. Their certificate checks out, but check with '
                    'them that it was them.'
              : null,
        );

      // Genuine certificate, wrong leaf. Not a rollout artefact and not
      // recoverable by waiting: somebody presented a real certificate for a
      // device other than the one in front of us, which only happens on purpose.
      case CertificateVerdict.wrongLeaf:
        return LeafVerdict(
          action: phase == CertificateEnforcement.enforce
              ? LeafAction.propose
              : LeafAction.flag,
          verdict: verdict,
          warning:
              'A device in this conversation presented $ownerUserId\'s '
              'certificate for a different device. Treat this conversation as '
              'compromised until it is removed.',
        );

      // Absent. The ordinary state of every device that has not upgraded yet, so
      // the phase decides - unless this device has certified before, in which
      // case its certificate going missing is suppression, not a long tail.
      case CertificateVerdict.missing:
      case CertificateVerdict.unknownIssuer:
      case CertificateVerdict.expired:
        uncertifiedLeavesSeen++;

        if (everCertified) {
          return LeafVerdict(
            action: phase == CertificateEnforcement.enforce
                ? LeafAction.propose
                : LeafAction.flag,
            verdict: verdict,
            warning:
                'A device on $ownerUserId\'s account has stopped presenting '
                'the certificate it used to. Treat this conversation as '
                'compromised until it is removed.',
          );
        }

        return LeafVerdict(
          action: switch (phase) {
            CertificateEnforcement.observe => LeafAction.allow,
            CertificateEnforcement.warn => LeafAction.flag,
            CertificateEnforcement.enforce => LeafAction.propose,
          },
          verdict: verdict,
          // §L.5: `Observe` suppresses removal, never detection. An identity
          // that was not already in the group is surfaced at every phase, even
          // though a missing certificate on a known member is not.
          warning: unknownIdentity
              ? '$ownerUserId joined this conversation from a device nobody '
                    'here added, and it has not proved it belongs to them.'
              : phase == CertificateEnforcement.observe
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

  static String _seen(String userId, String deviceId) => '$userId#$deviceId';

  /// Seeds [_hasEverCertified] from a previous session's record.
  @visibleForTesting
  void rememberCertified({required String userId, required String deviceId}) =>
      _hasEverCertified.add(_seen(userId, deviceId));
}
