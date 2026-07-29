import 'package:dio/dio.dart';

import '../../features/auth/data/auth_repository.dart';

/// Attaches the bearer token to every request and, on a 401, refreshes once
/// via [AuthRepository.ensureValidToken] and retries the original request.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _authRepository.ensureValidToken();
    options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final alreadyRetried = err.requestOptions.extra['retried'] == true;
    if (err.response?.statusCode == 401 && !alreadyRetried) {
      try {
        final token = await _authRepository.ensureValidToken(
          forceRefresh: true,
        );
        final options = err.requestOptions..extra['retried'] = true;
        options.headers['Authorization'] = 'Bearer $token';
        final retryResponse = await Dio().fetch<dynamic>(options);
        handler.resolve(retryResponse);
        return;
      } catch (_) {
        // Refresh failed — fall through and surface the original error.
      }
    }
    handler.next(err);
  }
}
