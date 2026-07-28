import '../network/api_client.dart';

/// Registers device push tokens against the identity service. `/device-token`
/// already exists server-side (used by Alpine desktop) and takes one opaque
/// token — FCM registration token on Android, raw APNs device token on iOS.
/// `/voip-token` is new — see `docs/native-call-push-backend-spec.md` for the
/// server-side contract this assumes.
class PushTokenApi {
  PushTokenApi({required this.client});

  final ApiClient client;

  Future<void> registerDeviceToken(String token) async {
    await client.dio.post<void>(
      client.url('/api/v1/identity/users/self/device-token'),
      data: {'token': token},
    );
  }

  Future<void> registerVoipToken(String token) async {
    await client.dio.post<void>(
      client.url('/api/v1/identity/users/self/voip-token'),
      data: {'token': token},
    );
  }
}
