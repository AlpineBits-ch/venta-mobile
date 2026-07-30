import 'package:dio/dio.dart';

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

/// Raw calls against the OAuth2 token endpoint and identity API - used only
/// by [AuthRepository]. Deliberately uses its own plain [Dio] (no auth
/// interceptor): the token endpoint doesn't take a bearer token, and a
/// refresh call must never itself trigger a 401-retry loop.
class AuthApi {
  AuthApi()
    : _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

  final Dio _dio;

  Future<TokenResponse> passwordGrant({
    required String baseUrl,
    required String username,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '$baseUrl/connect/token',
      data: {
        'grant_type': 'password',
        'client_id': 'echo',
        'scope': 'openid offline_access',
        'username': username,
        'password': password,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    return TokenResponse.fromJson(response.data!);
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

  Future<void> register({
    required String baseUrl,
    required String email,
    required String username,
    required String password,
    required DateTime birthdate,
  }) async {
    await _dio.post<void>(
      '$baseUrl/api/v1/identity/authentication/register',
      data: {
        'email': email,
        'username': username,
        'password': password,
        'birthdate': birthdate.toUtc().toIso8601String(),
      },
    );
  }

  Future<ServerConfiguration> getConfiguration(String baseUrl) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$baseUrl/api/v1/configuration',
    );
    return ServerConfiguration.fromJson(response.data!);
  }
}
