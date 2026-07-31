import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin wrapper around [FlutterSecureStorage] (Keychain on iOS,
/// EncryptedSharedPreferences/Keystore on Android) for auth tokens and the
/// self-hosted server URL override.
///
/// Intentional improvement over the desktop client, which keeps OAuth
/// tokens in plain `localStorage`.
class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

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
