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

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);
  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);
  Future<String?> readServerUrl() => _storage.read(key: _serverUrlKey);

  /// A call action (accept/decline) that a [CallKitService] background
  /// isolate captured while the main Flutter engine wasn't running yet — see
  /// `call_kit_service.dart`'s background handler for why this hand-off is
  /// needed instead of just acting on it directly from that isolate.
  Future<void> writePendingCallAction({required String callId, required String action}) async {
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
