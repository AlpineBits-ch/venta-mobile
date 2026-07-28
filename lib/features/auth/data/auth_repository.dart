import 'dart:async';
import 'dart:convert';

import '../../../core/config/app_config.dart';
import '../../../core/storage/secure_storage_service.dart';
import 'auth_api.dart';
import 'models/server_configuration.dart';

/// Thrown when a request needs a valid session but none can be established
/// (no refresh token, or the server rejected the refresh).
class SessionExpiredException implements Exception {}

/// Owns the current server URL, access/refresh tokens, and the de-duped
/// refresh flow. Mirrors Alpine's `AuthService`/`ApiConfigService`, with
/// tokens in [SecureStorageService] (Keychain/Keystore) instead of
/// `localStorage`.
class AuthRepository {
  AuthRepository({required this.api, required this.secureStorage});

  final AuthApi api;
  final SecureStorageService secureStorage;

  String _baseUrl = AppConfig.defaultApiUrl;
  String? _accessToken;
  String? _refreshToken;
  Future<String>? _activeRefresh;

  final _sessionExpiredController = StreamController<void>.broadcast();

  /// Fires when the session can no longer be renewed (refresh failed) or
  /// after an explicit [logout]. [SessionCubit] listens to this to drop back
  /// to the unauthenticated route.
  Stream<void> get sessionExpired => _sessionExpiredController.stream;

  String get baseUrl => _baseUrl;
  bool get isAuthenticated => _accessToken != null && _refreshToken != null;

  String? get currentUserId {
    final token = _accessToken;
    if (token == null) return null;
    return _subClaimOf(token);
  }

  /// Loads any persisted session and, if a refresh token exists, validates
  /// it against the server immediately — there's no persisted expiry, so a
  /// forced refresh on cold start is the simplest reliable check.
  Future<void> init() async {
    _baseUrl = await secureStorage.readServerUrl() ?? AppConfig.defaultApiUrl;
    final refreshToken = await secureStorage.readRefreshToken();
    if (refreshToken == null) return;
    _refreshToken = refreshToken;
    _accessToken = await secureStorage.readAccessToken();
    try {
      await ensureValidToken(forceRefresh: true);
    } catch (_) {
      await logout();
    }
  }

  Future<ServerConfiguration> checkServer(String domain) {
    return api.getConfiguration(_resolveBaseUrl(domain));
  }

  /// Accepts `username` or `user@server.com` — the latter points the client
  /// at a self-hosted instance for the rest of the session.
  Future<void> login(String input, String password) async {
    final (username, resolvedBaseUrl) = _splitLoginInput(input);
    final tokens = await api.passwordGrant(
      baseUrl: resolvedBaseUrl,
      username: username,
      password: password,
    );
    _baseUrl = resolvedBaseUrl;
    await _applyTokens(tokens.accessToken, tokens.refreshToken);
    await secureStorage.writeServerUrl(_baseUrl);
  }

  Future<void> register({
    required String email,
    required String username,
    required String password,
    required DateTime birthdate,
    String? serverDomain,
  }) async {
    final resolvedBaseUrl =
        serverDomain != null ? _resolveBaseUrl(serverDomain) : AppConfig.defaultApiUrl;
    await api.register(
      baseUrl: resolvedBaseUrl,
      email: email,
      username: username,
      password: password,
      birthdate: birthdate,
    );
    _baseUrl = resolvedBaseUrl;
    await login(username, password);
  }

  /// Returns a valid access token, refreshing first if needed. Concurrent
  /// callers (interceptor 401, realtime accessTokenFactory) share one
  /// in-flight refresh instead of racing the single-use refresh token.
  Future<String> ensureValidToken({bool forceRefresh = false}) async {
    if (!forceRefresh && _accessToken != null) return _accessToken!;

    final refreshToken = _refreshToken;
    if (refreshToken == null) {
      _sessionExpiredController.add(null);
      throw SessionExpiredException();
    }

    final inFlight = _activeRefresh;
    if (inFlight != null) return inFlight;

    final refreshFuture = () async {
      try {
        final tokens = await api.refreshGrant(baseUrl: _baseUrl, refreshToken: refreshToken);
        await _applyTokens(tokens.accessToken, tokens.refreshToken ?? refreshToken);
        return tokens.accessToken;
      } catch (e) {
        await _clearSession();
        _sessionExpiredController.add(null);
        rethrow;
      } finally {
        _activeRefresh = null;
      }
    }();
    _activeRefresh = refreshFuture;
    return refreshFuture;
  }

  Future<void> logout() async {
    await _clearSession();
    _sessionExpiredController.add(null);
  }

  Future<void> _applyTokens(String accessToken, String? refreshToken) async {
    _accessToken = accessToken;
    if (refreshToken != null) _refreshToken = refreshToken;
    await secureStorage.writeTokens(
      accessToken: accessToken,
      refreshToken: _refreshToken!,
    );
  }

  Future<void> _clearSession() async {
    _accessToken = null;
    _refreshToken = null;
    await secureStorage.clearSession();
  }

  String _resolveBaseUrl(String domain) =>
      domain == 'venta.gg' ? AppConfig.defaultApiUrl : 'https://$domain';

  (String username, String baseUrl) _splitLoginInput(String input) {
    final atIndex = input.lastIndexOf('@');
    if (atIndex > 0) {
      final username = input.substring(0, atIndex);
      final domain = input.substring(atIndex + 1);
      return (username, 'https://$domain');
    }
    return (input, AppConfig.defaultApiUrl);
  }

  String? _subClaimOf(String jwt) {
    final parts = jwt.split('.');
    if (parts.length != 3) return null;
    try {
      final normalized = base64Url.normalize(parts[1]);
      final payload =
          jsonDecode(utf8.decode(base64Url.decode(normalized))) as Map<String, dynamic>;
      return payload['sub'] as String?;
    } catch (_) {
      return null;
    }
  }
}
