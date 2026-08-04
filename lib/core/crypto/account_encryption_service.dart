import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../features/auth/data/auth_repository.dart';
import '../device/device_api.dart';
import '../device/device_id_service.dart';
import '../mls/mls_service.dart';
import '../storage/secure_storage_service.dart';
import 'account_identity_service.dart';
import 'master_key_service.dart';

/// What one run of [AccountEncryptionService.establish] managed to do.
///
/// Reported rather than thrown. Every step here is best-effort by design: an
/// account that cannot establish an identity key is treated as `Observe` and
/// carries on (§I.2), and a launch that blocks on any of it would be a launch
/// that a server outage can stop.
class EncryptionBootstrapResult {
  const EncryptionBootstrapResult({
    this.masterKeyReady = false,
    this.identityKeyReady = false,
    this.certificateIssued = false,
    this.certificateCurrent = false,
    this.needsRecoveryCode = false,
  });

  /// The account has a master key and this device holds it.
  final bool masterKeyReady;

  /// This device holds the account identity key and can sign certificates.
  final bool identityKeyReady;

  /// A certificate was signed and uploaded on this run.
  final bool certificateIssued;

  /// This device has a valid, published certificate - whether or not this run
  /// is what produced it. The number §I.1's coverage telemetry is counting.
  final bool certificateCurrent;

  /// The account's master key has no recovery-code wrapping, so a password reset
  /// would destroy its encrypted history (§C.1.1). The prompt is owed.
  final bool needsRecoveryCode;
}

/// Establishes the §C/§G/§H generation side for the signed-in account.
///
/// This is the piece that was missing. `MasterKeyService`, `AccountIdentityService`
/// and the certificate path were all built and unit-tested with **zero
/// production callers**, so no real account ever acquired a master key, no
/// account identity key was ever published, no device certificate was ever
/// issued, and certificate coverage therefore sat at exactly zero - which is why
/// `certificateEnforcement` could never advance past `Observe` and §H.4's
/// external-commit defence could never turn on.
///
/// **Generation only.** Nothing here validates a leaf, removes a device, or
/// enforces a protection level. It cannot: it issues credentials and reports
/// what it managed to issue. That is deliberate - §I.1 exists because a client
/// that enforced before coverage existed would start proposing the removal of
/// every device in every group it is in, including its owner's.
///
/// ## Why the password matters
///
/// Three of the writes are gated on the account password server-side, and it is
/// not a formality in any of them:
///
/// * `POST users/master` - only to *replace* an envelope, so a first write is
///   free.
/// * `PUT backup/recovery-key` - always. §C.1 requires re-authentication.
/// * `PUT users/identity-key` - always, including a first publication, because
///   whoever publishes first is who every peer TOFU-pins and what every device
///   certificate ever verified chains to.
///
/// So a cold start, which has no password, can do strictly less than a sign-in:
/// it adopts a master key and identity key already in the keychain and refreshes
/// this device's certificate - which needs no password - but it cannot establish
/// either for the first time. That is the §I.2 long tail arriving one sign-in at
/// a time, and it is why nothing here treats an incomplete run as a failure.
class AccountEncryptionService {
  AccountEncryptionService({
    required this.masterKeys,
    required this.identity,
    required this.mls,
    required this.deviceApi,
    required this.deviceIdService,
    required this.authRepository,
    required this.secureStorage,
  });

  final MasterKeyService masterKeys;
  final AccountIdentityService identity;
  final MlsService mls;
  final DeviceApi deviceApi;
  final DeviceIdService deviceIdService;
  final AuthRepository authRepository;
  final SecureStorageService secureStorage;

  /// Reissue this far before expiry rather than at it. A certificate that lapses
  /// between two launches of an app somebody opens weekly is a device peers stop
  /// being able to verify, and under §I.1's `Enforce` phase that is a removal
  /// proposal against a device that did nothing wrong.
  static const renewBefore = Duration(days: 30);

  /// A recovery code that has been minted and is waiting to be shown, or the
  /// standing fact that one is owed.
  ///
  /// A notifier because the UI that can show it does not exist at the moment
  /// this runs - the bootstrap fires from `startAuthenticatedServices`, which is
  /// `unawaited` from `main` before the first frame.
  final ValueNotifier<bool> recoveryCodeOwed = ValueNotifier<bool>(false);

  /// Set while a run is in flight, so two launches' worth of triggers do not
  /// mint two identity keys.
  Future<EncryptionBootstrapResult>? _inFlight;

  EncryptionBootstrapResult _last = const EncryptionBootstrapResult();

  /// What the last completed run concluded.
  EncryptionBootstrapResult get last => _last;

  /// Runs the whole generation side once.
  ///
  /// Concurrent callers share one run. `startAuthenticatedServices` and a
  /// sign-in can land within milliseconds of each other, and two concurrent runs
  /// on an account with no identity key would both see "none published" and both
  /// mint one - the loser then holds a private half no peer has pinned, which is
  /// exactly the state §H.5's safety-number warning exists for.
  Future<EncryptionBootstrapResult> establish({String? password}) {
    final inFlight = _inFlight;
    if (inFlight != null) return inFlight;
    final future = _establish(password: password);
    _inFlight = future;
    return future.whenComplete(() => _inFlight = null);
  }

  Future<EncryptionBootstrapResult> _establish({String? password}) async {
    try {
      final userId = authRepository.currentUserId;
      final deviceId = deviceIdService.deviceIdOrNull;
      if (userId == null || deviceId == null) return _last;

      final masterKeyReady = await _ensureMasterKey(
        userId: userId,
        deviceId: deviceId,
        password: password,
      );

      var identityKeyReady = false;
      if (masterKeyReady) {
        try {
          identityKeyReady = await identity.ensure(
            userId: userId,
            deviceId: deviceId,
            password: password,
          );
        } catch (e) {
          // §I.2: an account with no identity key is treated as Observe and
          // carries on. Nothing downstream of here is load-bearing for reading
          // or sending messages.
          debugPrint('AccountEncryptionService: identity key unavailable: $e');
        }
      }

      final certificate = identityKeyReady
          ? await _ensureCertificate(userId: userId, deviceId: deviceId)
          : (issued: false, current: false);

      final needsRecoveryCode = await _recoveryCodeOwed(
        userId,
        masterKeyReady: masterKeyReady,
      );
      recoveryCodeOwed.value = needsRecoveryCode;

      return _last = EncryptionBootstrapResult(
        masterKeyReady: masterKeyReady,
        identityKeyReady: identityKeyReady,
        certificateIssued: certificate.issued,
        certificateCurrent: certificate.current,
        needsRecoveryCode: needsRecoveryCode,
      );
    } catch (e, stack) {
      // Nothing above may stop a launch. A user whose encryption setup failed
      // still has plaintext conversations, a call history and an account.
      debugPrint(
        'AccountEncryptionService: encryption setup did not complete: $e',
      );
      debugPrintStack(stackTrace: stack);
      return _last;
    }
  }

  /// True when this device holds the account master key afterwards.
  Future<bool> _ensureMasterKey({
    required String userId,
    required String deviceId,
    required String? password,
  }) async {
    try {
      // The keychain first: a cold start has an empty in-memory cache and the
      // key is still there from the previous session. Re-deriving it would need
      // a password prompt for something already held.
      final cached = await masterKeys.peek(userId: userId, deviceId: deviceId);

      // Refreshed either way - it is one cheap GET with no Argon2, and it is
      // what puts "your encrypted history is no longer recoverable" and the
      // recovery-code prompt on screen.
      final read = await masterKeys.readStatus();

      if (cached != null) return true;
      if (password == null) {
        debugPrint(
          'AccountEncryptionService: no master key on this device and no '
          'password to unlock one with; deferring to the next sign-in',
        );
        return false;
      }
      if (!read.reachable) {
        // Never mint on an unreadable status. A timeout that looked like "this
        // account has no envelope" is what would write a fresh random master key
        // over the real one, orphaning every backup blob and the identity key.
        return false;
      }

      return await masterKeys.unlock(
            userId: userId,
            deviceId: deviceId,
            password: password,
          ) !=
          null;
    } catch (e) {
      debugPrint('AccountEncryptionService: the master key is unavailable: $e');
      return false;
    }
  }

  /// Issues and publishes this device's certificate if it does not already have
  /// a good one.
  ///
  /// Idempotent on the cached certificate: same device id, same signature key,
  /// same identity-key version, and not inside [renewBefore] of expiry means
  /// there is nothing to do. Without that check every launch would sign and
  /// upload a new one.
  Future<({bool issued, bool current})> _ensureCertificate({
    required String userId,
    required String deviceId,
  }) async {
    final signatureKey = mls.signaturePublicKey;
    if (signatureKey == null) {
      // No MLS identity on this device yet, so there is no leaf to vouch for.
      return (issued: false, current: false);
    }

    final existing = await _readCachedCertificate(
      userId: userId,
      deviceId: deviceId,
    );
    if (existing != null &&
        existing.deviceId == deviceId &&
        existing.deviceSignatureKey == signatureKey &&
        existing.expiresAt.isAfter(DateTime.now().toUtc().add(renewBefore))) {
      return (issued: false, current: true);
    }

    try {
      final certificate = await identity.issueForThisDevice(
        userId: userId,
        deviceId: deviceId,
        deviceSignatureKey: signatureKey,
      );
      if (certificate == null)
        return (issued: false, current: existing != null);

      await deviceApi.uploadDeviceCertificate(
        clientDeviceId: deviceId,
        certificate: certificate.certificate,
        issuedAt: certificate.issuedAt,
        expiresAt: certificate.expiresAt,
        identityKeyVersion: identity.version,
      );

      // Cached only after the upload landed. A cache written first would let the
      // idempotency check above suppress the retry that a failed upload needs.
      await secureStorage.writeDeviceCertificate(
        deviceId: deviceId,
        userId: userId,
        value: jsonEncode(certificate.toJson()),
      );
      return (issued: true, current: true);
    } catch (e) {
      debugPrint(
        'AccountEncryptionService: could not publish this device\'s certificate: $e',
      );
      return (issued: false, current: existing != null);
    }
  }

  Future<DeviceCertificate?> _readCachedCertificate({
    required String userId,
    required String deviceId,
  }) async {
    final raw = await secureStorage.readDeviceCertificate(
      deviceId: deviceId,
      userId: userId,
    );
    if (raw == null || raw.isEmpty) return null;
    try {
      return DeviceCertificate.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (e) {
      debugPrint(
        'AccountEncryptionService: the cached certificate is unreadable: $e',
      );
      return null;
    }
  }

  /// Whether to offer the recovery-code flow.
  ///
  /// The condition is [MasterKeyStatus.needsRecoveryCode]: the account has a
  /// master key wrapped under the password alone. Every account created before
  /// §C.1.1 is here, and so is every account this client has just given a master
  /// key to, because [MasterKeyService.establish] writes the password wrapping
  /// only. One path, both cases.
  ///
  /// **A user who already has a recovery code is never prompted**, and that
  /// falls out of the same condition - a wrapping exists, so the status is
  /// `ready` whichever device wrote it. That matters: offering a fresh code to
  /// someone who has one would replace the wrapping and silently invalidate the
  /// copy they wrote down, turning the retrofit into the loss it exists to
  /// prevent.
  ///
  /// The acknowledgement flag is the second guard, for the window between a code
  /// being confirmed and a status read catching up.
  ///
  /// [masterKeyReady] is the third, and it was found the hard way on a real
  /// device: the account's *status* comes from the server, but the code has to
  /// be wrapped around a master key **this device holds**. An account whose
  /// envelope exists because another device wrote it, read from a handset that
  /// has never unlocked it, satisfies the status check and nothing else - so the
  /// banner appeared, the flow ran, and `addRecoveryCode` returned null at the
  /// last step. Offering something that cannot work is worse than not offering.
  Future<bool> _recoveryCodeOwed(
    String userId, {
    required bool masterKeyReady,
  }) async {
    if (!masterKeyReady) return false;
    if (masterKeys.status.value != MasterKeyStatus.needsRecoveryCode) {
      return false;
    }
    return !await secureStorage.readRecoveryCodeAcknowledged(userId);
  }

  /// Records that a code was shown and confirmed, and stops the prompt.
  Future<void> markRecoveryCodeSaved(String userId) async {
    await secureStorage.writeRecoveryCodeAcknowledged(userId);
    recoveryCodeOwed.value = false;
  }
}
