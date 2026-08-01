import 'package:flutter/foundation.dart';
import 'package:venta_mls/venta_mls.dart';

import '../storage/secure_storage_service.dart';
import 'master_key_api.dart';

/// Where the account's recovery credentials stand.
enum MasterKeyStatus {
  /// Not looked at yet.
  unknown,

  /// No master key on this account. The next unlock mints one.
  notSetUp,

  /// Both wrappings present and valid.
  ready,

  /// Only the password wrapping exists — every account created before §C.1.1.
  /// One password reset away from losing every backup blob and the account
  /// identity key, so `VerifiedDevices` and cloud engine backup stay unavailable
  /// until a code is saved.
  needsRecoveryCode,

  /// A password reset invalidated the password wrapping. Recoverable: unlocking
  /// with the recovery code rebuilds it.
  needsPasswordRewrap,

  /// **Already lost.** A reset invalidated the password wrapping and there was
  /// no recovery-code wrapping. Every backup blob and the account identity key
  /// are unopenable. Not a warning about the future.
  historyLost,
}

/// The server accepted a recovery-code write and did not store it.
///
/// Not a transport failure - a 200 came back. The server has a path that returns
/// early on a same-version write without persisting the second wrapping, so the
/// only way to know is to re-read. Surfaced rather than swallowed because the
/// alternative is telling someone they now have a recovery code when they do
/// not, which they would discover mid-recovery with no second copy.
class RecoveryCodeNotStoredException implements Exception {
  const RecoveryCodeNotStoredException();

  @override
  String toString() =>
      'RecoveryCodeNotStoredException: the server accepted the recovery code '
      'but did not store it, so it would not open anything';
}

/// What setting up a master key produced.
class MasterKeySetupResult {
  const MasterKeySetupResult({
    required this.masterKey,
    required this.recoveryCode,
  });

  final String masterKey;

  /// Show once, take confirmation, then never again — it is not recoverable from
  /// anything the server holds.
  final String recoveryCode;
}

/// The account master key: one 32-byte secret per account, wrapped under the
/// password, that the server holds only as ciphertext.
///
/// Mirrors Alpine's `MasterKeyService`, and deliberately shares its Rust rather
/// than reimplementing the KDF in Dart - `ApplicationUser.EncryptedMasterKey` is
/// a single row that both clients read, so an Argon2 parameter that differed
/// between them would leave one client unable to unwrap what the other wrapped,
/// and the failure would look exactly like a wrong password.
///
/// Three things depend on it:
///
/// * **Device admission** (contract §G) - a new device proves it holds this key,
///   and an existing device verifies that proof locally. The server relays and
///   cannot forge, which is the entire reason `TrustedSignIn` is a security
///   level rather than "trust the server".
/// * **The account identity key** (§H) - wrapped under it, so a restored backup
///   can produce device certificates.
/// * **Cloud backup** (§C) - the recovery-key envelope generalises it.
///
/// It is cached in the keychain after the first unwrap because Argon2id at 64
/// MiB takes long enough that asking for the password on every admission would
/// make the feature unusable. The cache is scoped to `(deviceId, userId)` like
/// every other secret here.
class MasterKeyService {
  MasterKeyService({
    required this.api,
    required this.secureStorage,
    VentaMls? engine,
  }) : _engine = engine ?? VentaMls();

  final MasterKeyApi api;
  final SecureStorageService secureStorage;
  final VentaMls _engine;

  String? _cached;
  String? _cachedFor;

  /// True when the master key is available without asking for a password.
  bool get isUnlocked => _cached != null;

  /// What the account's recovery credentials look like, for the settings screen
  /// and the unlock flow to branch on.
  ///
  /// A `ValueNotifier` because two of its states demand UI the moment they are
  /// discovered: [MasterKeyStatus.needsRecoveryCode] blocks `VerifiedDevices`
  /// and cloud engine backup, and [MasterKeyStatus.historyLost] is a completed
  /// loss the user has to be *told* about rather than discovering when a restore
  /// fails.
  final ValueNotifier<MasterKeyStatus> status =
      ValueNotifier<MasterKeyStatus>(MasterKeyStatus.unknown);

  /// The master key for the signed-in account, or null when it has not been
  /// unlocked on this device yet.
  ///
  /// Reads the keychain before giving up: a cold start has an empty in-memory
  /// cache but the key is still there from the last session, and prompting for a
  /// password on every launch to re-derive something we already hold would be
  /// theatre.
  Future<String?> peek({
    required String userId,
    required String deviceId,
  }) async {
    if (_cached != null && _cachedFor == userId) return _cached;
    final stored = await secureStorage.readMasterKey(
      deviceId: deviceId,
      userId: userId,
    );
    if (stored == null) return null;
    _cached = stored;
    _cachedFor = userId;
    return stored;
  }

  /// Reads the account's recovery-key state without unwrapping anything.
  ///
  /// Cheap - no Argon2 - so it is safe on a launch path. Updates [status], which
  /// is what puts the "your encrypted history is no longer recoverable" notice
  /// and the "save a recovery code" prompt on screen.
  Future<RecoveryKeyStateDto?> refreshStatus() async {
    final RecoveryKeyStateDto? state;
    try {
      state = await api.fetchRecoveryKey();
    } catch (e) {
      debugPrint('MasterKeyService: could not read the recovery key state: $e');
      return null;
    }

    status.value = switch (state) {
      null => MasterKeyStatus.notSetUp,
      _ when !state.encryptedHistoryRecoverable => MasterKeyStatus.historyLost,
      _ when state.needsPasswordRewrap => MasterKeyStatus.needsPasswordRewrap,
      _ when !state.hasRecoveryCodeWrapping =>
        MasterKeyStatus.needsRecoveryCode,
      _ => MasterKeyStatus.ready,
    };
    return state;
  }

  /// Mints a master key and both of its wrappings (contract §C.1.1).
  ///
  /// Returns the recovery code, which the caller **must** show once and take
  /// confirmation for. It is not recoverable from anything the server holds, and
  /// it is the only credential that survives a password reset.
  Future<MasterKeySetupResult> setUp({
    required String userId,
    required String deviceId,
    required String password,
    String? recoveryCode,
  }) async {
    final minted = await _engine.setupMasterKey(
      password,
      recoveryCode: recoveryCode,
    );

    final passwordWrapping = EncryptedMasterKeyDto.fromEngine(
      Map<String, Object?>.from(minted['passwordWrapping']! as Map),
    );
    final recoveryWrapping = EncryptedMasterKeyDto.fromEngine(
      Map<String, Object?>.from(minted['recoveryCodeWrapping']! as Map),
    );

    await api.putRecoveryKey(
      version: passwordWrapping.version,
      passwordWrapping: passwordWrapping,
      recoveryCodeWrapping: recoveryWrapping,
    );

    final key = minted['masterKey']! as String;
    await _remember(userId: userId, deviceId: deviceId, key: key);
    status.value = MasterKeyStatus.ready;

    return MasterKeySetupResult(
      masterKey: key,
      recoveryCode: minted['recoveryCode']! as String,
    );
  }

  /// Unwraps the master key with [password], or with [recoveryCode] when the
  /// password wrapping is gone.
  ///
  /// Returns null when neither credential opens it. Deliberately not an
  /// exception: a mistyped password is the expected case, and the caller shows a
  /// field error rather than a crash report.
  ///
  /// When the password wrapping was invalidated by a reset, unlocking with the
  /// recovery code **re-wraps under [password]** before returning, so the next
  /// unlock is ordinary again. That is the whole recovery journey, and doing it
  /// here rather than in a separate step means it cannot be forgotten.
  Future<String?> unlock({
    required String userId,
    required String deviceId,
    required String password,
    String? recoveryCode,
  }) async {
    final state = await refreshStatus();

    if (state == null) {
      // §I.2: an account that predates encryption has no envelope. Minting one
      // here rather than at signup is what lets existing accounts acquire a
      // master key without a migration - and it now gets both wrappings.
      final result = await setUp(
        userId: userId,
        deviceId: deviceId,
        password: password,
        recoveryCode: recoveryCode,
      );
      return result.masterKey;
    }

    // The ordinary path.
    final passwordWrapping = state.passwordWrapping;
    if (passwordWrapping != null) {
      final key = await _tryUnwrap(passwordWrapping, password);
      if (key != null) {
        await _remember(userId: userId, deviceId: deviceId, key: key);
        return key;
      }
    }

    // The recovery path. Reached after a password reset - the wrapping above is
    // sealed under a password nobody has any more - or when the user simply
    // typed the wrong one and offered a code instead.
    final recoveryWrapping = state.recoveryCodeWrapping;
    if (recoveryCode == null || recoveryWrapping == null) {
      if (passwordWrapping == null) {
        // Nothing left to try with. Not a wrong password: there is no door.
        status.value = MasterKeyStatus.historyLost;
      }
      return null;
    }

    // Throws `recoveryCodeInvalid` for a malformed code rather than deriving a
    // key from it. Deliberately propagated: "that is not a recovery code" and
    // "that code did not open it" are different things to tell someone, and only
    // the first is a typo they can fix.
    final normalized = await _engine.normalizeRecoveryCode(recoveryCode);
    final key = await _tryUnwrap(recoveryWrapping, normalized);
    if (key == null) return null;

    await _remember(userId: userId, deviceId: deviceId, key: key);

    // Rebuild the password wrapping so the next unlock does not need the code.
    // No password check server-side: producing a valid wrapping *is* the proof,
    // and requiring the password would gate recovery on the thing that was just
    // reset.
    try {
      final rewrapped = EncryptedMasterKeyDto.fromEngine(
        await _engine.wrapMasterKeyUnder(
          masterKeyB64: key,
          secret: password,
        ),
      );
      await api.rewrapPassword(
        version: state.version,
        passwordWrapping: rewrapped,
      );
      status.value = MasterKeyStatus.ready;
    } catch (e) {
      // The key is unlocked either way; the user just has to use the code again
      // next time. Failing the unlock over this would be strictly worse.
      debugPrint('MasterKeyService: could not re-wrap under the new password: $e');
    }
    return key;
  }

  /// Adds a recovery-code wrapping to an account that only ever had the password
  /// one - which is every account created before §C.1.1.
  ///
  /// Written at the **same version**: the master key has not changed, so nothing
  /// is being replaced and no existing backup blob should be orphaned. Bumping
  /// the version to force the write through would invalidate every device's blob,
  /// which is the opposite of what somebody asking for more safety expects.
  ///
  /// Returns the code to show once, or null when the master key is not unlocked
  /// on this device and there is therefore nothing to wrap.
  ///
  /// Throws [RecoveryCodeNotStoredException] when the server accepted the write
  /// but did not store it - see the §C.1.2 note about `PUT recovery-key`
  /// returning early on a same-version write. Showing someone a code that opens
  /// nothing, while telling them they are now protected, is worse than not
  /// offering the retrofit at all.
  Future<String?> addRecoveryCode({
    required String userId,
    required String deviceId,
    String? recoveryCode,
  }) async {
    final key = await peek(userId: userId, deviceId: deviceId);
    if (key == null) return null;

    final state = await api.fetchRecoveryKey();
    if (state == null) return null;

    final code = recoveryCode ?? await _engine.generateRecoveryCode();
    final normalized = await _engine.normalizeRecoveryCode(code);

    final recoveryWrapping = EncryptedMasterKeyDto.fromEngine(
      await _engine.wrapMasterKeyUnder(masterKeyB64: key, secret: normalized),
    );
    // **Sent back byte-identical to what the GET returned.** Not re-encrypted:
    // wrapping the same master key under the same password again produces
    // different ciphertext from a fresh IV, and at an unchanged version the
    // server rejects a differing `cipherText` with a 400. It has to - different
    // bytes under the same version is either a re-wrap under a new password
    // (which is `rewrap-password`, a different route) or a different master key
    // claiming to be the same one, which would leave every blob at that version
    // unopenable while asserting nothing had changed. The server cannot tell
    // those apart, so it refuses both.
    final passwordWrapping = state.passwordWrapping;
    if (passwordWrapping == null) return null;

    await api.putRecoveryKey(
      version: state.version,
      passwordWrapping: passwordWrapping,
      recoveryCodeWrapping: recoveryWrapping,
    );

    // Verified by re-reading rather than trusting the 200. The server has a path
    // that answers OK to a same-version write and stores nothing, and the cost
    // of believing it is a user who thinks they have a recovery code and does
    // not - discovered during a recovery, with no second copy.
    final confirmed = await api.fetchRecoveryKey();
    if (confirmed == null || !confirmed.hasRecoveryCodeWrapping) {
      await refreshStatus();
      throw const RecoveryCodeNotStoredException();
    }

    status.value = MasterKeyStatus.ready;
    return code;
  }

  Future<String?> _tryUnwrap(
    EncryptedMasterKeyDto wrapping,
    String secret,
  ) async {
    try {
      return await _engine.decryptMasterKey(
        encryptedMasterKey: wrapping.toJson(),
        password: secret,
      );
    } catch (e) {
      debugPrint('MasterKeyService: a wrapping did not open: $e');
      return null;
    }
  }

  /// Re-wraps the existing key under a new password. The ordinary password
  /// *change*, where the user still knows the old one and no recovery code is
  /// needed.
  ///
  /// Must never mint a fresh master key. Every backup blob and every admission
  /// proof is bound to the current one; replacing it would orphan all of them,
  /// and the user would find out the next time they needed a restore.
  ///
  /// The recovery-code wrapping is carried across untouched - it seals the same
  /// bytes, so it stays valid, and rewriting only the password side would leave
  /// the two on different versions.
  Future<bool> rewrap({
    required String userId,
    required String deviceId,
    required String newPassword,
  }) async {
    final key = await peek(userId: userId, deviceId: deviceId);
    if (key == null) return false;

    final rewrapped = EncryptedMasterKeyDto.fromEngine(
      await _engine.wrapMasterKeyUnder(
        masterKeyB64: key,
        secret: newPassword,
      ),
    );

    final state = await api.fetchRecoveryKey();
    final recoveryWrapping = state?.recoveryCodeWrapping;
    if (state == null || recoveryWrapping == null) {
      // No recovery-code wrapping to preserve, so the legacy single-wrapping
      // write is all there is. The account stays one reset from losing
      // everything, which `status` is what says out loud.
      await api.upload(rewrapped);
      await refreshStatus();
      return true;
    }

    await api.putRecoveryKey(
      version: state.version,
      passwordWrapping: rewrapped,
      recoveryCodeWrapping: recoveryWrapping,
    );
    return true;
  }

  /// Applies the flags a password reset came back with (contract §C.1.1).
  ///
  /// `masterKeyRewrapRequired` means the next unlock has to go through the
  /// recovery code; `encryptedHistoryRecoverable == false` means it is already
  /// too late and the user has to be told so plainly.
  void applyPasswordResetResult({
    required bool masterKeyRewrapRequired,
    required bool encryptedHistoryRecoverable,
  }) {
    status.value = !encryptedHistoryRecoverable
        ? MasterKeyStatus.historyLost
        : masterKeyRewrapRequired
        ? MasterKeyStatus.needsPasswordRewrap
        : status.value;
  }

  /// Forgets the cached key. Sign-out and account switch - the key belongs to
  /// one account, and a second account reading the first's would be able to
  /// admit devices to its groups.
  Future<void> lock({String? userId, String? deviceId}) async {
    _cached = null;
    _cachedFor = null;
    status.value = MasterKeyStatus.unknown;
    if (userId != null && deviceId != null) {
      await secureStorage.clearMasterKey(deviceId: deviceId, userId: userId);
    }
  }

  Future<void> _remember({
    required String userId,
    required String deviceId,
    required String key,
  }) async {
    _cached = key;
    _cachedFor = userId;
    await secureStorage.writeMasterKey(
      deviceId: deviceId,
      userId: userId,
      masterKey: key,
    );
  }
}
