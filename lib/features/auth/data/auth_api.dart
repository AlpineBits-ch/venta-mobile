import 'package:dio/dio.dart';

import '../../../core/config/site_hosts.dart';
import '../../../core/device/device_id_service.dart';
import '../../../core/network/rate_limit_interceptor.dart';
import 'models/server_configuration.dart';
import 'models/token_response.dart';

/// Thrown by [AuthApi.passwordGrant] on a `401 mfa_required` - the
/// credentials were correct but the account has MFA enabled and no code was
/// supplied yet. Caller should prompt for a 6-digit code and retry.
class MfaRequiredException implements Exception {}

/// Thrown by [AuthApi.passwordGrant] on a `401 mfa_invalid` - a code was
/// supplied but didn't verify (wrong or expired). Caller should let the user
/// retry the code without re-entering their password.
class MfaInvalidException implements Exception {}

/// Thrown by [AuthApi.passwordGrant] on a `403 Email not verified.` - the
/// account exists and the password is right, it just can't sign in until the
/// emailed code is entered.
///
/// Typed rather than left as a bare `DioException` because it isn't really a
/// failure: the caller has proved it holds the password, so the honest move is
/// to show the code form rather than "incorrect username or password". This is
/// the only signup-related refusal that's allowed to be precise, and it is
/// precise on purpose - nothing is leaked to a caller who already authenticated.
class EmailNotVerifiedException implements Exception {}

/// Thrown by [AuthApi.passwordGrant] on the `403 User is not allowed to sign
/// in` - the credentials were right and the account is restricted.
///
/// The response says *that* and nothing more. It does not say which state the
/// account is in - `Banned`, `Inactive`, `PendingDeletion`, `PurgeInProgress`
/// and `Deleted` all answer identically - and it does not carry the ban's
/// reference code. So this exception carries neither, and nothing downstream
/// may guess: the screen it drives says "restricted" and points at the support
/// site, which is where the specifics actually live. When the server starts
/// distinguishing them, that's a field on this class, not an inference.
///
/// [supportUrl] is derived from the instance the attempt was made against, so
/// the link works for a self-hosted account whose server this client is not
/// otherwise pointed at yet. Null only if the URL couldn't be derived.
class SigninNotAllowedException implements Exception {
  const SigninNotAllowedException({this.supportUrl});

  final String? supportUrl;
}

/// Which field on the registration form a [RegistrationFailure] belongs to.
enum RegistrationField { email, username, birthdate, general }

/// One entry of the validation array `POST /register` answers a `400` with.
class RegistrationFailure {
  const RegistrationFailure({
    required this.propertyName,
    required this.message,
    this.errorCode,
  });

  factory RegistrationFailure.fromJson(Map<dynamic, dynamic> json) =>
      RegistrationFailure(
        propertyName: json['propertyName']?.toString() ?? '',
        message: json['errorMessage']?.toString() ?? '',
        errorCode: json['errorCode']?.toString(),
      );

  final String propertyName;
  final String message;
  final String? errorCode;

  /// Which input to hang [message] off.
  ///
  /// Keyed off [errorCode] first, because two of these don't report the
  /// property you'd expect: the age check reports an **empty** `propertyName`
  /// (it validates a bare date, which has no property to name), and the
  /// email-format checks report `Value` because they come from the `Email`
  /// value object rather than from the request DTO.
  RegistrationField get field {
    switch (errorCode) {
      case 'LessThanValidator':
        return RegistrationField.birthdate;
      case 'EmailInvalidFormat':
      case 'EmailDisposableNotAllowed':
        return RegistrationField.email;
    }
    switch (propertyName.toLowerCase()) {
      case 'username':
        return RegistrationField.username;
      case 'email':
      case 'value':
        return RegistrationField.email;
      case 'birthdate':
        return RegistrationField.birthdate;
    }
    return RegistrationField.general;
  }
}

/// Thrown by [AuthApi.register] on a `400` - the request was refused before
/// anything was attempted.
///
/// A `400` here means the *username* is taken, the address is missing or
/// unusable, or the age is under 13. It no longer means "that email is already
/// registered": a taken address answers `202` like everything else.
class RegistrationRejectedException implements Exception {
  const RegistrationRejectedException(this.failures);

  final List<RegistrationFailure> failures;

  @override
  String toString() =>
      'RegistrationRejectedException(${failures.map((f) => f.message).join('; ')})';
}

/// Raw calls against the OAuth2 token endpoint and identity API - used only
/// by [AuthRepository]. Deliberately uses its own plain [Dio] (no auth
/// interceptor): the token endpoint doesn't take a bearer token, and a
/// refresh call must never itself trigger a 401-retry loop.
///
/// It does carry [RateLimitInterceptor]. The anonymous bucket is smaller than
/// the authenticated one (20/s against 50/s) and covers login, registration and
/// the token endpoint - and a refresh that meets a `429` and isn't retried logs
/// the user out for a reason that had nothing to do with their session.
class AuthApi {
  /// [dio] is for tests only - production always wants the private client
  /// described above.
  AuthApi({Dio? dio})
    : _dio =
          dio ??
          (Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
            ),
          )..interceptors.add(RateLimitInterceptor()));

  final Dio _dio;

  /// Throws [MfaRequiredException]/[MfaInvalidException] instead of the
  /// usual [DioException] when the `401` body signals one of those two
  /// specific cases - a plain wrong-password `401` still surfaces as a
  /// [DioException], same as before.
  ///
  /// The three `device_*` parameters are what the session this login creates
  /// is named and keyed by. Sending nothing left the server naming the session
  /// after the `User-Agent`, i.e. `Dart/3.x (dart:io)` on the sessions screen,
  /// and left the session unlinked from the device row - so revoking it
  /// couldn't clear this handset's push tokens.
  ///
  /// [deviceId] is ignored server-side unless it names a device this account
  /// has registered, which a genuinely first login can't have done yet
  /// (registration needs a token). That's expected: the link is picked up from
  /// the next login onwards.
  Future<TokenResponse> passwordGrant({
    required String baseUrl,
    required String username,
    required String password,
    String? mfaCode,
    String? deviceId,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$baseUrl/connect/token',
        data: {
          'grant_type': 'password',
          'client_id': 'echo',
          'scope': 'openid offline_access',
          'username': username,
          'password': password,
          if (mfaCode != null) 'mfa_code': mfaCode,
          'device_name': kDeviceName,
          'device_type': kDeviceType,
          if (deviceId != null) 'device_id': deviceId,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return TokenResponse.fromJson(response.data!);
    } on DioException catch (e) {
      final marker = _errorMarker(e.response?.data);
      if (e.response?.statusCode == 401) {
        if (marker == 'mfa_required') throw MfaRequiredException();
        if (marker == 'mfa_invalid') throw MfaInvalidException();
      }
      // The body is a bare string here (`Email not verified.`), not the
      // OAuth error/error_description shape the 401s use.
      if (e.response?.statusCode == 403) {
        final text = marker?.toLowerCase() ?? '';
        if (text.contains('email not verified')) {
          throw EmailNotVerifiedException();
        }
        // Everything else the token endpoint answers `403` to is
        // `IsSigninAllowed()` refusing. Deliberately the fallback rather than an
        // exact string match on `User is not allowed to sign in`: a restricted
        // account that fell through to "incorrect username or password" is the
        // worst outcome here - it is the one message that is definitely a lie,
        // and it sends someone into a password reset that cannot help them.
        throw SigninNotAllowedException(
          supportUrl: supportUrlOrNull(baseUrl),
        );
      }
      rethrow;
    }
  }

  String? _errorMarker(Object? body) {
    if (body is String) return body;
    if (body is Map) {
      return (body['error'] ?? body['error_description'])?.toString();
    }
    return null;
  }

  Future<TokenResponse> refreshGrant({
    required String baseUrl,
    required String refreshToken,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '$baseUrl/connect/token',
      data: {
        'grant_type': 'refresh_token',
        'client_id': 'echo',
        'refresh_token': refreshToken,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    return TokenResponse.fromJson(response.data!);
  }

  /// Asks for an account - or, if [email] already has one, doesn't, and answers
  /// exactly the same either way.
  ///
  /// Success is `202 Accepted` (**never `200`**) with a fixed body that is
  /// byte-for-byte identical for a free address and a registered one. It means
  /// "the request was accepted and, if that address could be registered, mail
  /// is on the way" - not "an account was created". There is no user id in it,
  /// and there is deliberately no way to tell the two cases apart: `register`
  /// is anonymous, so an answer that distinguished them let anyone with a list
  /// of addresses read off which of them have accounts here.
  ///
  /// So nothing downstream may claim an account was made, sign the user in off
  /// the back of this, or reconstruct an "email already in use" branch from
  /// timing or anything else. The address owner is told someone tried; the
  /// caller is not.
  ///
  /// A `400` is a validation refusal - taken username, unusable address, under
  /// 13 - and arrives as [RegistrationRejectedException]. There is no `409`.
  Future<void> register({
    required String baseUrl,
    required String email,
    required String username,
    required String password,
    required DateTime birthdate,
  }) async {
    try {
      // Dio accepts any 2xx, so the `202` needs nothing special - but never
      // narrow this to `200`, which this endpoint no longer returns at all.
      await _dio.post<void>(
        '$baseUrl/api/v1/identity/authentication/register',
        data: {
          'email': email,
          'username': username,
          'password': password,
          'birthDate': birthdate.toUtc().toIso8601String(),
        },
      );
    } on DioException catch (e) {
      final failures = _registrationFailures(e.response);
      if (failures.isNotEmpty) throw RegistrationRejectedException(failures);
      rethrow;
    }
  }

  List<RegistrationFailure> _registrationFailures(Response<dynamic>? response) {
    if (response?.statusCode != 400) return const [];
    final data = response?.data;
    if (data is! List) return const [];
    return data
        .whereType<Map<dynamic, dynamic>>()
        .map(RegistrationFailure.fromJson)
        .where((f) => f.message.isNotEmpty)
        .toList(growable: false);
  }

  /// Confirms an address with the 6-digit code that was emailed to it.
  ///
  /// `GET` with query parameters rather than a POST body - matches Alpine's
  /// `EmailVerificationService`, which is the only other client of these two
  /// endpoints.
  ///
  /// `400` is the *only* refusal and it is one message for every cause: wrong
  /// code, expired code, five wrong guesses, unknown address, already verified.
  /// Don't try to tell them apart - render it and offer a resend.
  Future<void> verifyEmail({
    required String baseUrl,
    required String email,
    required String code,
  }) async {
    await _dio.get<void>(
      '$baseUrl/api/v1/identity/user/verify-email',
      queryParameters: {'email': email, 'code': code},
    );
  }

  /// Re-sends the code. Always `202`, for every address, whether or not it
  /// exists - infer nothing from it. Asking again while a code is still live
  /// re-sends the **same** code rather than minting a new one, so pressing
  /// "send it again" can't invalidate the one already in the user's inbox.
  Future<void> generateVerificationCode({
    required String baseUrl,
    required String email,
  }) async {
    await _dio.get<void>(
      '$baseUrl/api/v1/identity/user/generate-verification-code',
      queryParameters: {'email': email},
    );
  }

  Future<ServerConfiguration> getConfiguration(String baseUrl) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$baseUrl/api/v1/configuration',
    );
    return ServerConfiguration.fromJson(response.data!);
  }

  /// Always resolves - `202` regardless of whether the email/username has an
  /// account, deliberately (avoids leaking which emails are registered).
  Future<void> requestPasswordReset({
    required String baseUrl,
    required String email,
  }) async {
    await _dio.get<void>(
      '$baseUrl/api/v1/identity/user/request-password-reset',
      queryParameters: {'email': email},
    );
  }

  /// Throws [DioException] with `400` on an invalid/expired code, or a
  /// `400 ValidationProblem` (`errors.newPassword`) if the new password
  /// fails the server's policy - caller renders either message as-is.
  Future<void> resetPassword({
    required String baseUrl,
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _dio.post<void>(
      '$baseUrl/api/v1/identity/user/reset-password',
      data: {'email': email, 'code': code, 'newPassword': newPassword},
    );
  }
}
