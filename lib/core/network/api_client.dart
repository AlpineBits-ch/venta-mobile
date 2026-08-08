import 'package:dio/dio.dart';

import '../../features/auth/data/auth_repository.dart';
import 'accept_language_interceptor.dart';
import 'auth_interceptor.dart';
import 'device_id_interceptor.dart';
import 'rate_limit_interceptor.dart';
import 'status_probe_interceptor.dart';

/// Shared authenticated HTTP client for every feature repository except
/// [AuthRepository] itself. There's no static `baseUrl` on the underlying
/// [Dio] - the server can change at login time (self-hosted instances), so
/// callers build request paths via [url] against [AuthRepository.baseUrl].
class ApiClient {
  /// [deviceId] and [registerDevice] wire up [DeviceIdInterceptor]; both are
  /// optional so tests can build a client without standing up the device
  /// services. Passed as callbacks rather than as a `DeviceIdService`/
  /// `DeviceRegistrationService` because those resolve *through* this client -
  /// taking them eagerly would close the dependency cycle at construction.
  ApiClient({
    required this.authRepository,
    String? Function()? deviceId,
    Future<void> Function()? registerDevice,
    Dio Function()? retryClient,
    void Function()? onUnreachable,
  }) : dio = Dio(
         BaseOptions(
           connectTimeout: const Duration(seconds: 15),
           receiveTimeout: const Duration(seconds: 15),
         ),
       ) {
    // Ahead of the others: a `429` wait can outlast the access token, and
    // holding the request *before* `AuthInterceptor` stamps it means the token
    // is read when the request actually goes out rather than when it queued.
    dio.interceptors.add(RateLimitInterceptor());
    // First in the error chain, before `AuthInterceptor` can swallow anything
    // by retrying it. Observes only - it never resolves or rejects a request.
    if (onUnreachable != null) {
      dio.interceptors.add(StatusProbeInterceptor(onUnreachable));
    }
    dio.interceptors.add(AuthInterceptor(authRepository));
    // Describes the device rather than the request, so it goes on everything
    // and not only the two endpoints that read it today.
    dio.interceptors.add(AcceptLanguageInterceptor());
    if (deviceId != null && registerDevice != null) {
      dio.interceptors.add(
        DeviceIdInterceptor(
          deviceId: deviceId,
          registerDevice: registerDevice,
          retryClient: retryClient,
        ),
      );
    }
  }

  final Dio dio;
  final AuthRepository authRepository;

  String url(String path) => '${authRepository.baseUrl}$path';
}
