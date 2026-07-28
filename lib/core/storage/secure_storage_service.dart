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

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);
  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);
  Future<String?> readServerUrl() => _storage.read(key: _serverUrlKey);

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
