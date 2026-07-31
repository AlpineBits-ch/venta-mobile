import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../network/api_client.dart';

/// Which push transport a token addresses - the server's `PushTokenKind`.
enum PushTokenKind {
  /// Firebase: regular notifications on both platforms, and the data-only
  /// message the Android call flow rings on.
  fcm('Fcm'),

  /// The iOS PushKit VoIP token CallKit needs. iOS only.
  apnsVoip('ApnsVoip');

  const PushTokenKind(this.wireName);

  final String wireName;
}

/// Registers and deregisters this installation's push tokens.
///
/// One endpoint for both transports (`self/push-token` with a `kind`), where
/// there used to be `/device-token` and `/voip-token`. The `deviceId` is the
/// part that matters beyond tidiness: a token that carries its device can be
/// left out of a fan-out, which is what stops the device that just answered a
/// call from being told to cancel it. The legacy endpoints still work but
/// register the token unattached.
class PushTokenApi {
  PushTokenApi({required this.client});

  final ApiClient client;

  String get _base => '/api/v1/identity/users/self/push-token';

  /// [deviceId] is optional server-side and always sent here - an unknown one
  /// doesn't fail the call, it just registers the token unattached, which is
  /// the state this endpoint exists to get out of.
  Future<void> registerToken({
    required String token,
    required PushTokenKind kind,
    String? deviceId,
  }) => _withRetry('register ${kind.wireName}', () async {
    await client.dio.post<void>(
      client.url(_base),
      data: {
        'token': token,
        'kind': kind.wireName,
        if (deviceId != null) 'deviceId': deviceId,
      },
    );
  });

  /// Stops this token being rung - call on sign-out, or the handset keeps
  /// receiving calls and messages for an account nobody is signed in to.
  ///
  /// One attempt, on a short timeout, and every failure swallowed - unlike
  /// registration this runs *inside* sign-out, which has to stay responsive
  /// on a bad connection. A `404` is the expected answer whenever the token
  /// was never registered or has already been cleaned up (revoking the
  /// session or forgetting the device both take it), and is not a failure.
  Future<void> deleteToken({
    required String token,
    required PushTokenKind kind,
  }) async {
    try {
      await client.dio.delete<void>(
        client.url(_base),
        queryParameters: {'token': token, 'kind': kind.wireName},
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      debugPrint('PushTokenApi: could not delete ${kind.wireName} token: $e');
    }
  }

  /// Registration is fired off via `unawaited(startAuthenticatedServices())`
  /// at app boot/login with nothing watching the result - a single transient
  /// failure (network not up yet, backend mid-deploy) used to drop the token
  /// silently for the rest of the session, since VoIP/FCM tokens are rarely
  /// reissued. Retried a few times before giving up and logging, so a real
  /// failure is at least visible instead of indistinguishable from "never
  /// happened to fail".
  Future<void> _withRetry(String what, Future<void> Function() send) async {
    for (var attempt = 1; ; attempt++) {
      try {
        await send();
        return;
      } catch (e) {
        if (attempt >= 3) {
          debugPrint(
            'PushTokenApi: giving up on $what after $attempt attempts: $e',
          );
          return;
        }
        await Future<void>.delayed(Duration(seconds: attempt * 2));
      }
    }
  }
}
