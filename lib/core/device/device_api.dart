import 'package:dio/dio.dart';

import '../../features/mls/data/models/mls_dtos.dart';
import '../network/api_client.dart';
import '../network/device_id_interceptor.dart';

/// One key package on its way up to the server.
///
/// [isLastResort] marks the device's single reusable package - the floor that
/// keeps it addable to new groups after its single-use supply runs dry. A device
/// with neither is silently left out of every new conversation, which from the
/// user's side is indistinguishable from the app being broken.
class KeyPackageUpload {
  const KeyPackageUpload({required this.keyPackage, this.isLastResort = false});

  /// Base64 TLS-serialized KeyPackage.
  final String keyPackage;
  final bool isLastResort;
}

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

  /// What this build understands, reported on every registration and launch.
  ///
  /// Contract §I.4. The server uses this rather than a version string to decide
  /// whether an account may enter `VerifiedDevices`, and to compute the
  /// certificate-coverage telemetry that gates flipping enforcement on. A
  /// version string would be a proxy for the same thing that nobody can query
  /// meaningfully across three clients on independent release trains.
  static const capabilities = <String>[
    'mls.device-cert.v1',
    'mls.join-request.conversation.v1',
    'mls.protection-level.v1',
    'mls.backup.v1',
  ];

  /// Idempotent: re-registering an id this account already has returns the
  /// existing row untouched. An id another *account* uses is not a collision -
  /// `clientDeviceId` is unique per user, not globally.
  ///
  /// Returns whether the server rotated this device's identity key. When it did,
  /// it purged the device's key packages with it (contract §A) and the caller
  /// owes an immediate replenish - the packages the server was handing out have
  /// no private halves any more.
  Future<bool> register({
    required String clientDeviceId,
    required String deviceName,
    required String deviceType,
    required String identityPublicKey,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      _base,
      data: {
        'clientDeviceId': clientDeviceId,
        'deviceName': deviceName,
        'deviceType': deviceType,
        'identityPublicKey': identityPublicKey,
        'capabilities': capabilities,
      },
      // This *is* the recovery from an unknown device id - it must never be
      // routed back into it.
      options: Options(extra: {DeviceIdInterceptor.skipRecoveryKey: true}),
    );
    return response.data?['identityRotated'] as bool? ?? false;
  }

  /// Throws away every key package the server holds for this device.
  ///
  /// Contract §A, and the fix for root cause R3. The replenish count is derived
  /// purely from server rows, but the private init keys live only in the
  /// client's local MLS store - so a device that wipes that store leaves ~100
  /// unconsumed packages behind, the server answers `Count = 0`, nothing is
  /// re-uploaded, and **every Welcome sealed to one of them is undecryptable by
  /// the device it was addressed to**. Silently, and permanently.
  ///
  /// Must therefore run *before* re-registering and replenishing, on every path
  /// that clears local MLS state and on every signing-key rotation. Idempotent.
  Future<int> resetKeyPackages(String clientDeviceId) async {
    final response = await client.dio.delete<Map<String, dynamic>>(
      '$_base/client/$clientDeviceId/key-packages',
    );
    return response.data?['deletedCount'] as int? ?? 0;
  }

  /// Publishes this device's certificate (contract §H.2) alongside its key
  /// packages, so peers can verify offline that it belongs to this account.
  Future<void> uploadDeviceCertificate({
    required String clientDeviceId,
    required Map<String, Object?> certificate,
  }) async {
    await client.dio.put<void>(
      '$_base/client/$clientDeviceId/certificate',
      data: certificate,
    );
  }

  /// The certificate for someone else's device, for the §H.4 check on an
  /// unrecognised leaf. Null when that device has not published one - which §I.2
  /// says is the ordinary state until it upgrades.
  Future<Map<String, dynamic>?> fetchDeviceCertificate({
    required String userId,
    required String clientDeviceId,
  }) async {
    try {
      final response = await client.dio.get<Map<String, dynamic>>(
        '/api/v1/identity/users/${Uri.encodeComponent(userId)}'
        '/devices/${Uri.encodeComponent(clientDeviceId)}/certificate',
      );
      final data = response.data;
      return (data == null || data.isEmpty) ? null : data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// How many key packages this device should generate and upload to get back
  /// to the server's target, plus whether it needs a last-resort package.
  ///
  /// Doubles as the server's housekeeping hook - expired and long-consumed rows
  /// are swept here - which is why it is called on every authenticated launch
  /// rather than only when something looks low.
  Future<GenerateKeyPackagesDto> keyPackagesToGenerate(
    String clientDeviceId,
  ) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '$_base/client/$clientDeviceId/generate',
    );
    return GenerateKeyPackagesDto.fromJson(response.data!);
  }

  /// Uploads MLS key packages for this device. Each one is consumed by exactly
  /// one group this device is later added to.
  ///
  /// An empty list is a legitimate no-op, not an error: the replenish flow posts
  /// whatever [keyPackagesToGenerate] asked for, and a fully stocked device is
  /// asked for nothing.
  Future<int> uploadKeyPackages({
    required String clientDeviceId,
    required List<KeyPackageUpload> keyPackages,
  }) async {
    if (keyPackages.isEmpty) return 0;
    final response = await client.dio.post<Map<String, dynamic>>(
      '$_base/client/$clientDeviceId/key-packages',
      data: {
        'keyPackages': keyPackages
            .map(
              (p) => {
                'keyPackage': p.keyPackage,
                'isLastResort': p.isLastResort,
              },
            )
            .toList(),
      },
    );
    return response.data?['added'] as int? ?? 0;
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
