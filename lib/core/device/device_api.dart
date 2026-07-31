import 'package:dio/dio.dart';

import '../network/api_client.dart';
import '../network/device_id_interceptor.dart';

/// One row of `GET /api/v1/identity/devices` - a registered installation of
/// some client on this account. Deliberately hand-rolled rather than
/// generated: the server returns the whole `UserDevice` facet (identity key,
/// status, timestamps) and this client only reads the three fields it can
/// actually show.
class RegisteredDeviceDto {
  const RegisteredDeviceDto({
    required this.clientDeviceId,
    required this.deviceName,
    required this.deviceType,
  });

  factory RegisteredDeviceDto.fromJson(Map<String, dynamic> json) =>
      RegisteredDeviceDto(
        clientDeviceId: json['clientDeviceId'] as String? ?? '',
        deviceName: json['deviceName'] as String?,
        deviceType: json['deviceType'] as String?,
      );

  /// The client-supplied stable id - the same value this app sends as
  /// `X-Device-Id`. Unique per account, not globally.
  final String clientDeviceId;
  final String? deviceName;

  /// `Desktop`, `Mobile` or `Web`.
  final String? deviceType;
}

/// Device registration against the identity service.
///
/// A registered device is what makes `X-Device-Id` mean anything: the three
/// endpoints that read the header (call accept/decline/leave, the Cloudflare
/// session create, guild voice join) validate it against these rows and
/// answer `400` for an id they don't know. Push tokens hang off the same row,
/// which is what lets the backend leave out the device that just answered a
/// call when it fans the cancel push out to everyone else.
class DeviceApi {
  DeviceApi({required this.client});

  final ApiClient client;

  String get _base => client.url('/api/v1/identity/devices');

  /// Idempotent: re-registering an id this account already has returns the
  /// existing row untouched. An id another *account* uses is not a collision -
  /// `clientDeviceId` is unique per user, not globally.
  Future<void> register({
    required String clientDeviceId,
    required String deviceName,
    required String deviceType,
    required String identityPublicKey,
  }) async {
    await client.dio.post<void>(
      _base,
      data: {
        'clientDeviceId': clientDeviceId,
        'deviceName': deviceName,
        'deviceType': deviceType,
        'identityPublicKey': identityPublicKey,
      },
      // This *is* the recovery from an unknown device id - it must never be
      // routed back into it.
      options: Options(extra: {DeviceIdInterceptor.skipRecoveryKey: true}),
    );
  }

  Future<List<RegisteredDeviceDto>> list() async {
    final response = await client.dio.get<List<dynamic>>(_base);
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(RegisteredDeviceDto.fromJson)
        .toList();
  }

  /// Unregisters a device and, by cascade server-side, its push tokens, MLS
  /// key packages and encrypted backup; its login sessions are revoked. This
  /// is "forget this device", not "sign out" - a plain sign-out keeps the
  /// registration so the next login on this handset reuses it.
  ///
  /// Throws a `404` [DioException] if the id isn't one of this account's.
  Future<void> remove(String clientDeviceId) async {
    await client.dio.delete<void>('$_base/client/$clientDeviceId');
  }
}
