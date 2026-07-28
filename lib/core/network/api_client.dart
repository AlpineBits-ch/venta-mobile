import 'package:dio/dio.dart';

import '../../features/auth/data/auth_repository.dart';
import 'auth_interceptor.dart';

/// Shared authenticated HTTP client for every feature repository except
/// [AuthRepository] itself. There's no static `baseUrl` on the underlying
/// [Dio] — the server can change at login time (self-hosted instances), so
/// callers build request paths via [url] against [AuthRepository.baseUrl].
class ApiClient {
  ApiClient({required this.authRepository})
      : dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          ),
        ) {
    dio.interceptors.add(AuthInterceptor(authRepository));
  }

  final Dio dio;
  final AuthRepository authRepository;

  String url(String path) => '${authRepository.baseUrl}$path';
}
