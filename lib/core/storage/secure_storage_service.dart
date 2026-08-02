import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin wrapper around [FlutterSecureStorage] (Keychain on iOS,
/// EncryptedSharedPreferences/Keystore on Android) for auth tokens and the
/// self-hosted server URL override.
///
/// Intentional improvement over the desktop client, which keeps OAuth
/// tokens in plain `localStorage`.
class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage, FlutterSecureStorage? sharedStorage})
    : _storage = storage ?? const FlutterSecureStorage(
        iOptions: _iosOptions,
        aOptions: _androidOptions,
      ),
      _sharedStorage = sharedStorage ?? const FlutterSecureStorage(
        iOptions: _sharedIosOptions,
        aOptions: _androidOptions,
      );

  /// `first_unlock_this_device`, not the plugin's `unlocked` default.
  ///
  /// Two reasons, both of which bit before this was set. `whenUnlocked` items
  /// are unreadable while the device is locked, and the two places that most
  /// need the MLS identity - the notification service extension decrypting a
  /// push, and a background launch after a reboot - both run exactly then. And
  /// `ThisDevice` keeps the keys out of an iCloud Keychain sync, which would
  /// otherwise put one device's MLS leaf on another and produce two devices
  /// sharing a ratchet.
  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  /// `resetOnError: false`, against the plugin's default of **true**.
  ///
  /// The default means: if a read throws - a Keystore fault, a
  /// `KeyStoreException` after an OS update, an app whose signing key changed -
  /// the plugin **deletes every value it holds** and reports success. On this
  /// app those values are the account master key, the MLS signing key and the
  /// account identity key. Deleting them is not a recoverable error state; it is
  /// every encrypted conversation on the handset gone, every backup blob
  /// unopenable, and the account's cryptographic identity lost, in response to a
  /// transient fault.
  ///
  /// Failing the read is strictly better: `MlsService` already distinguishes
  /// "no identity" from "identity missing but groups present" and refuses to
  /// mint over the second, and a user who retries after a reboot gets their keys
  /// back.
  ///
  /// The audit also called for `encryptedSharedPreferences: true`. In
  /// `flutter_secure_storage` 10 that flag is **deprecated and ignored**:
  /// everything is on Keystore-backed ciphers by default and existing values
  /// migrate on first access, so passing it now only earns a deprecation
  /// warning.
  static const _androidOptions = AndroidOptions(resetOnError: false);

  /// The Apple Developer team id, which is also the `$(AppIdentifierPrefix)` the
  /// entitlements files expand at build time.
  ///
  /// Must match `DEVELOPMENT_TEAM` in `ios/Runner.xcodeproj/project.pbxproj`.
  /// Named rather than inlined because it is the one part of
  /// [sharedKeychainGroup] that is a property of *who signs the build* rather
  /// than of this app, and a fork or an enterprise re-sign has to change it.
  /// Getting it wrong is invisible: `kSecAttrAccessGroup` simply stops matching,
  /// every write returns `errSecMissingEntitlement`, and the state files quietly
  /// go unsealed.
  static const _keychainTeamId = 'S33LPKH83B';

  /// The keychain access group the notification-service extension can also
  /// reach. Declared as `$(AppIdentifierPrefix)gg.venta.mobile.shared` under
  /// `keychain-access-groups` in all three entitlements files.
  ///
  /// **Team-prefixed on purpose.** The entitlement is written with the
  /// `$(AppIdentifierPrefix)` variable, but that is a build-time substitution:
  /// at runtime the access group is the expanded string, and querying for the
  /// bare `gg.venta.mobile.shared` matches nothing. This constant read exactly
  /// that way once, and the resulting `errSecMissingEntitlement` was swallowed
  /// by [readOrCreateMlsStateKey] into a null key - so sealing was a silent
  /// no-op on iOS while the Android half worked.
  ///
  /// Must match `MlsNotificationDecryptor.keychainAccessGroup` in Swift.
  ///
  /// Used for **one** value - the MLS state-file key - and never for anything
  /// that already exists. Moving existing items into an access group rewrites
  /// their `kSecAttrAccessGroup`, and an entry the app can no longer find is
  /// indistinguishable from an entry that was never there, which for the MLS
  /// signing key means "this device silently lost every group it was in".
  static const sharedKeychainGroup = '$_keychainTeamId.gg.venta.mobile.shared';

  static const _sharedIosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
    groupId: sharedKeychainGroup,
  );

  final FlutterSecureStorage _storage;
  final FlutterSecureStorage _sharedStorage;

  static const _accessTokenKey = 'venta.auth.access_token';
  static const _refreshTokenKey = 'venta.auth.refresh_token';
  static const _serverUrlKey = 'venta.auth.server_url';

  static const _pendingCallActionKey = 'venta.call.pending_action';
  static const _pendingCallIdKey = 'venta.call.pending_call_id';

  /// Generic key on purpose - this is the app's one stable per-installation
  /// device identifier (see `DeviceIdService`), not call-specific. Named so
  /// it can double as the MLS `ClientDeviceId` once E2EE lands, per the
  /// multi-device calls/voice spec's "don't invent a second ID" note.
  static const _deviceIdKey = 'venta.device.id';

  /// Public half of this installation's device identity key, base64 - which,
  /// once MLS is set up, *is* the MLS signing public key. See
  /// `DeviceIdService.identityPublicKey`.
  static const _deviceIdentityKeyKey = 'venta.device.identity_key';

  /// The call this device is currently connected to, if any - written by
  /// `CallKitService` and read from the FCM background isolate, which has no
  /// access to [CallCubit]. See `showCallKitFromPushData`.
  static const _activeCallIdKey = 'venta.call.active_call_id';

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);
  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);
  Future<String?> readServerUrl() => _storage.read(key: _serverUrlKey);

  Future<String?> readDeviceId() => _storage.read(key: _deviceIdKey);
  Future<void> writeDeviceId(String deviceId) =>
      _storage.write(key: _deviceIdKey, value: deviceId);

  Future<String?> readDeviceIdentityKey() =>
      _storage.read(key: _deviceIdentityKeyKey);
  Future<void> writeDeviceIdentityKey(String key) =>
      _storage.write(key: _deviceIdentityKeyKey, value: key);

  /// One account's MLS identity on this device: an Ed25519 keypair plus the
  /// user id it was minted for.
  ///
  /// Keyed by device *and* account. By device because a reset device identifier
  /// must not pick up the previous installation's keys - those name a leaf in
  /// every group the old device joined. By account because the keypair signs
  /// under a BasicCredential carrying the user id, so a second account signing
  /// with the first's key produces a credential every other group member
  /// rejects.
  ///
  /// The identity is stored alongside rather than inferred from the key, so a
  /// mismatch can be detected rather than discovered when messages start being
  /// refused.
  Future<(String publicKey, String privateKey, String identity)?>
  readMlsIdentity({required String deviceId, required String userId}) async {
    final scope = _mlsScope(deviceId, userId);
    final publicKey = await _storage.read(key: '$scope.pub');
    final privateKey = await _storage.read(key: '$scope.priv');
    final identity = await _storage.read(key: '$scope.identity');
    if (publicKey == null || privateKey == null || identity == null) return null;
    return (publicKey, privateKey, identity);
  }

  Future<void> writeMlsIdentity({
    required String deviceId,
    required String userId,
    required String publicKey,
    required String privateKey,
  }) async {
    final scope = _mlsScope(deviceId, userId);
    await _storage.write(key: '$scope.pub', value: publicKey);
    await _storage.write(key: '$scope.priv', value: privateKey);
    await _storage.write(key: '$scope.identity', value: userId);
  }

  /// On account deletion or "forget this device". Deliberately *not* called on
  /// an ordinary sign-out: the keys belong to this account on this installation,
  /// and throwing them away would lock the handset out of every group it is in.
  Future<void> clearMlsIdentity({
    required String deviceId,
    required String userId,
  }) async {
    final scope = _mlsScope(deviceId, userId);
    await _storage.delete(key: '$scope.pub');
    await _storage.delete(key: '$scope.priv');
    await _storage.delete(key: '$scope.identity');
  }

  static String _mlsScope(String deviceId, String userId) =>
      'venta.mls.$deviceId.$userId';

  // ---------------------------------------------------------------------------
  // Account-scoped secrets (contract §C.1, §G, §H)
  //
  // Scoped by (device, account) for the same reasons the MLS identity is, plus
  // one more: the master key is what admits a *new device* to this account's
  // groups, so a second account reading the first's could admit devices to
  // conversations it is not in.
  // ---------------------------------------------------------------------------

  /// The unwrapped account master key, base64.
  ///
  /// Cached here rather than re-derived because Argon2id at 64 MiB takes long
  /// enough that prompting for the password on every device admission would make
  /// the feature unusable in practice - which is how security features end up
  /// switched off.
  Future<String?> readMasterKey({
    required String deviceId,
    required String userId,
  }) => _storage.read(key: '${_mlsScope(deviceId, userId)}.master');

  Future<void> writeMasterKey({
    required String deviceId,
    required String userId,
    required String masterKey,
  }) => _storage.write(
    key: '${_mlsScope(deviceId, userId)}.master',
    value: masterKey,
  );

  Future<void> clearMasterKey({
    required String deviceId,
    required String userId,
  }) => _storage.delete(key: '${_mlsScope(deviceId, userId)}.master');

  /// The account identity keypair (§H.2), base64. Long-lived and per *account*,
  /// unlike the MLS signing key which is per device.
  Future<(String publicKey, String privateKey)?> readAccountIdentity({
    required String deviceId,
    required String userId,
  }) async {
    final scope = _mlsScope(deviceId, userId);
    final publicKey = await _storage.read(key: '$scope.account.pub');
    final privateKey = await _storage.read(key: '$scope.account.priv');
    if (publicKey == null || privateKey == null) return null;
    return (publicKey, privateKey);
  }

  Future<void> writeAccountIdentity({
    required String deviceId,
    required String userId,
    required String publicKey,
    required String privateKey,
  }) async {
    final scope = _mlsScope(deviceId, userId);
    await _storage.write(key: '$scope.account.pub', value: publicKey);
    await _storage.write(key: '$scope.account.priv', value: privateKey);
  }

  Future<void> clearAccountIdentity({
    required String deviceId,
    required String userId,
  }) async {
    final scope = _mlsScope(deviceId, userId);
    await _storage.delete(key: '$scope.account.pub');
    await _storage.delete(key: '$scope.account.priv');
  }

  /// The device certificate this device last issued for itself (§H.2), as JSON.
  ///
  /// Cached so an ordinary launch does not re-sign and re-upload one that is
  /// still good. That is not only a saved round trip: `PUT .../certificate`
  /// replaces the stored row, so a client that reissued on every start would
  /// churn the value peers are verifying against for no reason, and any peer
  /// mid-verification would see it change under them.
  Future<String?> readDeviceCertificate({
    required String deviceId,
    required String userId,
  }) => _storage.read(key: '${_mlsScope(deviceId, userId)}.cert');

  Future<void> writeDeviceCertificate({
    required String deviceId,
    required String userId,
    required String value,
  }) => _storage.write(
    key: '${_mlsScope(deviceId, userId)}.cert',
    value: value,
  );

  Future<void> clearDeviceCertificate({
    required String deviceId,
    required String userId,
  }) => _storage.delete(key: '${_mlsScope(deviceId, userId)}.cert');

  /// Whether the account's recovery code has been shown to, and confirmed by,
  /// the human on this device.
  ///
  /// Per account rather than per device: the code is the account's. Stored so
  /// the prompt is asked once and not on every launch, and so a user who has
  /// already saved one from another device is never pushed into regenerating -
  /// which would silently invalidate the copy they wrote down.
  Future<bool> readRecoveryCodeAcknowledged(String userId) async =>
      await _storage.read(key: 'venta.mls.recoverycode.ack.$userId') == '1';

  Future<void> writeRecoveryCodeAcknowledged(String userId) =>
      _storage.write(key: 'venta.mls.recoverycode.ack.$userId', value: '1');

  /// The last protection-level assertion this device verified (§G.3).
  ///
  /// Persisted so a client that cannot reach the endpoint enforces the last
  /// level it *saw signed*, rather than whatever the server says today. Without
  /// this, taking the endpoint away would be a downgrade.
  Future<String?> readProtectionLevel({
    required String deviceId,
    required String userId,
  }) => _storage.read(key: '${_mlsScope(deviceId, userId)}.protection');

  Future<void> writeProtectionLevel({
    required String deviceId,
    required String userId,
    required String value,
  }) => _storage.write(
    key: '${_mlsScope(deviceId, userId)}.protection',
    value: value,
  );

  /// The AES-256 key the MLS state files on disk are sealed under, base64.
  ///
  /// Generated on first use and never leaves the keychain. That is the whole
  /// mechanism: `mls_state.json` holds every epoch secret and every leaf HPKE
  /// private key, and `mls_message_cache.json` holds the plaintext of every
  /// message this device has decrypted, but a device backup carries the *files*
  /// and not Keystore/Keychain material - so a restore onto another handset gets
  /// two blobs it cannot open.
  ///
  /// Scoped by account rather than by device, matching the state directory. It
  /// lives in [sharedKeychainGroup] because the iOS notification-service
  /// extension is a separate process that has to read the message cache to
  /// decrypt a push, and the App Group *container* is exactly the thing that is
  /// backed up.
  ///
  /// Returns null when the keychain refused - a misprovisioned build without the
  /// access-group entitlement is the realistic case. Callers must treat that as
  /// "cannot seal", never as "seal under nothing".
  Future<String?> readOrCreateMlsStateKey(String userId) async {
    final key = 'venta.mls.statekey.$userId';
    try {
      final existing = await _sharedStorage.read(key: key);
      if (existing != null) return existing;

      final random = Random.secure();
      final fresh = base64Encode(
        List<int>.generate(32, (_) => random.nextInt(256)),
      );
      await _sharedStorage.write(key: key, value: fresh);
      // Read back rather than trusting the write: a keychain that silently
      // dropped it would leave the next launch unable to open a file this one
      // sealed, which is the same shape of loss as having no key at all.
      final confirmed = await _sharedStorage.read(key: key);
      if (confirmed == null) {
        debugPrint(
          'SecureStorageService: the keychain accepted the MLS state key and '
          'did not store it - the state files will stay unsealed',
        );
        return null;
      }
      return confirmed;
    } catch (e) {
      debugPrint('SecureStorageService: no MLS state key available: $e');
      return null;
    }
  }

  Future<void> clearMlsStateKey(String userId) async {
    try {
      await _sharedStorage.delete(key: 'venta.mls.statekey.$userId');
    } catch (e) {
      debugPrint('SecureStorageService: could not clear the MLS state key: $e');
    }
  }

  /// Peers' account identity keys, TOFU-pinned on first contact (§H.2).
  ///
  /// Per-peer rather than per-account-of-ours: this is the safety number, and
  /// the whole point is that a change in it is *noticed* rather than accepted.
  Future<String?> readPinnedIdentityKey(String peerUserId) =>
      _storage.read(key: 'venta.mls.pin.$peerUserId');

  Future<void> writePinnedIdentityKey({
    required String peerUserId,
    required String identityPublicKey,
  }) => _storage.write(
    key: 'venta.mls.pin.$peerUserId',
    value: identityPublicKey,
  );

  Future<String?> readActiveCallId() => _storage.read(key: _activeCallIdKey);

  /// [callId] of `null` clears it - the call ended.
  Future<void> writeActiveCallId(String? callId) => callId == null
      ? _storage.delete(key: _activeCallIdKey)
      : _storage.write(key: _activeCallIdKey, value: callId);

  /// A call action (accept/decline) that a [CallKitService] background
  /// isolate captured while the main Flutter engine wasn't running yet - see
  /// `call_kit_service.dart`'s background handler for why this hand-off is
  /// needed instead of just acting on it directly from that isolate.
  Future<void> writePendingCallAction({
    required String callId,
    required String action,
  }) async {
    await _storage.write(key: _pendingCallIdKey, value: callId);
    await _storage.write(key: _pendingCallActionKey, value: action);
  }

  Future<(String callId, String action)?> readPendingCallAction() async {
    final callId = await _storage.read(key: _pendingCallIdKey);
    final action = await _storage.read(key: _pendingCallActionKey);
    if (callId == null || action == null) return null;
    return (callId, action);
  }

  Future<void> clearPendingCallAction() async {
    await _storage.delete(key: _pendingCallIdKey);
    await _storage.delete(key: _pendingCallActionKey);
  }

  Future<void> writeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> writeServerUrl(String serverUrl) =>
      _storage.write(key: _serverUrlKey, value: serverUrl);

  Future<void> clearSession() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
