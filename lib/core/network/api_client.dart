import 'package:dio/dio.dart';

import '../../features/auth/data/auth_repository.dart';
import 'auth_interceptor.dart';
import 'device_id_interceptor.dart';

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
  }) : dio = Dio(
         BaseOptions(
           connectTimeout: const Duration(seconds: 15),
           receiveTimeout: const Duration(seconds: 15),
         ),
       ) {
    dio.interceptors.add(AuthInterceptor(authRepository));
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
