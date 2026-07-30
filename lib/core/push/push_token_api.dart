import 'package:flutter/foundation.dart';

import '../network/api_client.dart';

/// Registers device push tokens against the identity service. `/device-token`
/// already exists server-side (used by Alpine desktop) and takes one opaque
/// token - FCM registration token on Android, raw APNs device token on iOS.
/// `/voip-token` is new - see `docs/native-call-push-backend-spec.md` for the
/// server-side contract this assumes.
class PushTokenApi {
  PushTokenApi({required this.client});

  final ApiClient client;

  Future<void> registerDeviceToken(String token) =>
      _postWithRetry('/api/v1/identity/users/self/device-token', token);

  Future<void> registerVoipToken(String token) =>
      _postWithRetry('/api/v1/identity/users/self/voip-token', token);

  /// Both callers fire this off via `unawaited(startPushServices())` at app
  /// boot/login with nothing watching the result - a single transient
  /// failure (network not up yet, backend mid-deploy) used to drop the
  /// token silently for the rest of the session, since VoIP/FCM tokens are
  /// rarely reissued. Retried a few times before giving up and logging, so
  /// a real failure is at least visible instead of indistinguishable from
  /// "never happened to fail".
  Future<void> _postWithRetry(String path, String token) async {
    for (var attempt = 1; ; attempt++) {
      try {
        await client.dio.post<void>(client.url(path), data: {'token': token});
        return;
      } catch (e) {
        if (attempt >= 3) {
          debugPrint(
            'PushTokenApi: giving up on $path after $attempt attempts: $e',
          );
          return;
        }
        await Future<void>.delayed(Duration(seconds: attempt * 2));
      }
    }
  }
}
