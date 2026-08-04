import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/device/device_id_service.dart';
import '../../../core/diagnostics/secure_storage_fault.dart';
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
  AuthRepository({
    required this.api,
    required this.secureStorage,
    required this.deviceIdService,
  });

  final AuthApi api;
  final SecureStorageService secureStorage;
  final DeviceIdService deviceIdService;

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
  /// it against the server immediately - there's no persisted expiry, so a
  /// forced refresh on cold start is the simplest reliable check.
  ///
  /// **Never throws.** This runs before the first frame, so anything that
  /// escapes means `runApp` is not reached and the user gets a blank screen
  /// naming nothing. Three things here can fail independently and each has to
  /// degrade rather than propagate:
  ///
  /// * the keychain reads - on iOS a refusal arrives as a `PlatformException`,
  ///   and an unreadable keychain is "signed out for this launch", not "no app";
  /// * the forced refresh - already handled, and the reason this exists;
  /// * **the [logout] inside that handler**, which was itself unguarded. It
  ///   writes to the keychain, so whatever makes the reads throw makes this
  ///   throw too - and it sat in the catch for the failure a server change is
  ///   most likely to cause, turning a refused refresh into a dead app.
  Future<void> init() async {
    try {
      _baseUrl = await secureStorage.readServerUrl() ?? AppConfig.defaultApiUrl;
    } catch (e, stack) {
      reportSwallowed('AuthRepository.init/readServerUrl', e, stack);
      _baseUrl = AppConfig.defaultApiUrl;
    }

    final String? refreshToken;
    try {
      refreshToken = await secureStorage.readRefreshToken();
    } catch (e, stack) {
      // Not treated as "no session", and nothing is cleared: a failed read is
      // indistinguishable from a sign-out only if you let it be, and acting on
      // that costs the user their login over a transient fault. Unauthenticated
      // for this launch; the next one tries again.
      reportSwallowed('AuthRepository.init/readRefreshToken', e, stack);
      return;
    }
    if (refreshToken == null) return;
    _refreshToken = refreshToken;

    try {
      _accessToken = await secureStorage.readAccessToken();
    } catch (e, stack) {
      reportSwallowed('AuthRepository.init/readAccessToken', e, stack);
    }

    try {
      await ensureValidToken(forceRefresh: true);
    } catch (_) {
      try {
        await logout();
      } catch (e, stack) {
        // `_clearSession` has already dropped the in-memory tokens; only the
        // keychain delete can still fail, and a stale ciphertext on disk is not
        // worth a blank launch.
        reportSwallowed('AuthRepository.init/logout', e, stack);
      }
    }
  }

  Future<ServerConfiguration> checkServer(String domain) {
    return api.getConfiguration(_resolveBaseUrl(domain));
  }

  /// Signs in, and **does not fail because the keychain did**.
  ///
  /// Accepts `username` or `user@server.com` - the latter points the client at
  /// a self-hosted instance for the rest of the session. [mfaCode] is omitted on
  /// the first attempt; a [MfaRequiredException] from [api] signals the caller
  /// to prompt for one and retry with it set.
  ///
  /// The grant itself is unguarded: a failure there is a real sign-in failure
  /// and the caller has to see it. Everything after it is persistence, which is
  /// a different fact with a different remedy.
  ///
  /// This is the bug that produced "Something went wrong - please try again."
  /// for a login the server had already completed. `_applyTokens` and
  /// `writeServerUrl` both write to the keychain, both were unguarded, and
  /// `AuthBloc` had no branch for a `PlatformException` - so a handset whose
  /// keychain was refusing got a generic failure for a sign-in that had
  /// succeeded, with valid tokens already in memory and nothing wrong with the
  /// account or the password.
  ///
  /// The session is live either way. What a failure costs is durability: the
  /// tokens are not on disk, so the next cold start has nothing to restore and
  /// the user signs in again. [sessionPersisted] says so, and the UI is expected
  /// to tell them - degrading is fine, concealing it is not.
  Future<void> login(String input, String password, {String? mfaCode}) async {
    final (username, resolvedBaseUrl) = _splitLoginInput(input);
    final tokens = await api.passwordGrant(
      baseUrl: resolvedBaseUrl,
      username: username,
      password: password,
      mfaCode: mfaCode,
      deviceId: deviceIdService.deviceIdOrNull,
    );
    _baseUrl = resolvedBaseUrl;
    await _applyTokens(tokens.accessToken, tokens.refreshToken);

    try {
      await secureStorage.writeServerUrl(_baseUrl);
    } catch (e, stack) {
      reportSwallowed('AuthRepository.login/writeServerUrl', e, stack);
      _markSessionNotPersisted();
    }
  }

  /// Uses whatever server the client is currently pointed at ([baseUrl]) -
  /// same default-or-last-used resolution as everywhere else pre-login.
  Future<void> requestPasswordReset(String email) =>
      api.requestPasswordReset(baseUrl: _baseUrl, email: email);

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) => api.resetPassword(
    baseUrl: _baseUrl,
    email: email,
    code: code,
    newPassword: newPassword,
  );

  /// Confirms the address with the emailed code. Throws a `400` DioException
  /// on a wrong or expired code.
  Future<void> verifyEmail({required String email, required String code}) =>
      api.verifyEmail(baseUrl: _baseUrl, email: email, code: code);

  /// Re-sends the verification code. Always succeeds, for any address.
  Future<void> resendVerificationCode(String email) =>
      api.generateVerificationCode(baseUrl: _baseUrl, email: email);

  /// Submits a signup and **does not sign in**.
  ///
  /// There is nothing to sign in with: the response is `202` with no user id
  /// and no token, and it is the same response whether an account was created
  /// or the address already had one - deliberately, so signup can't be used to
  /// test which addresses are registered here.
  ///
  /// This used to call [login] straight after, and lean on the
  /// `EmailNotVerifiedException` that came back to reach the code screen. That
  /// no longer works and is no longer honest: for an address that already has
  /// an account, the username just registered doesn't exist, so the grant
  /// answers a flat `401` and the user would be told their brand-new password
  /// was wrong. The flow is register -> verify -> sign in, and the caller shows
  /// the code screen off the back of this returning.
  ///
  /// Throws [RegistrationRejectedException] on a `400` - the username is taken,
  /// the address is unusable, or the age is under 13.
  Future<void> register({
    required String email,
    required String username,
    required String password,
    required DateTime birthdate,
    String? serverDomain,
  }) async {
    final resolvedBaseUrl = serverDomain != null
        ? _resolveBaseUrl(serverDomain)
        : AppConfig.defaultApiUrl;
    await api.register(
      baseUrl: resolvedBaseUrl,
      email: email,
      username: username,
      password: password,
      birthdate: birthdate,
    );
    // Held so the verify/resend calls that follow reach the same instance.
    _baseUrl = resolvedBaseUrl;
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
        final tokens = await api.refreshGrant(
          baseUrl: _baseUrl,
          refreshToken: refreshToken,
        );
        await _applyTokens(
          tokens.accessToken,
          tokens.refreshToken ?? refreshToken,
        );
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

  /// Adopts a token pair in memory, then tries to persist it.
  ///
  /// **The in-memory half happens first and unconditionally**, because that is
  /// what makes the session work right now; persistence only decides whether it
  /// survives a restart. Doing them in the other order - or treating them as one
  /// operation, which is what an unguarded `await` does - meant a keychain
  /// refusal discarded a perfectly good session.
  Future<void> _applyTokens(String accessToken, String? refreshToken) async {
    _accessToken = accessToken;
    if (refreshToken != null) _refreshToken = refreshToken;

    final storedRefresh = _refreshToken;
    if (storedRefresh == null) {
      // Was `_refreshToken!`. The server is *asked* for `offline_access` and has
      // always answered with a refresh token, but "has always" is not a type,
      // and a null here threw a bare `TypeError` on the login path that
      // presented identically to the keychain fault - "Something went wrong".
      // The access token still works for this session.
      reportSwallowed(
        'AuthRepository/_applyTokens',
        StateError('the token response carried no refresh token'),
        StackTrace.current,
      );
      _markSessionNotPersisted();
      return;
    }

    try {
      await secureStorage.writeTokens(
        accessToken: accessToken,
        refreshToken: storedRefresh,
      );
      _sessionPersisted.value = true;
    } catch (e, stack) {
      reportSwallowed('AuthRepository/_applyTokens/writeTokens', e, stack);
      _markSessionNotPersisted();
    }
  }

  /// Whether the current session is on disk and will survive a cold start.
  ///
  /// False after a keychain write refused. Surfaced rather than hidden: the user
  /// is signed in and everything works, right up until they relaunch and find
  /// themselves at the login screen with no explanation.
  ValueListenable<bool> get sessionPersisted => _sessionPersisted;
  final ValueNotifier<bool> _sessionPersisted = ValueNotifier<bool>(true);

  void _markSessionNotPersisted() => _sessionPersisted.value = false;

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
          jsonDecode(utf8.decode(base64Url.decode(normalized)))
              as Map<String, dynamic>;
      return payload['sub'] as String?;
    } catch (_) {
      return null;
    }
  }
}
