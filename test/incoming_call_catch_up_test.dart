import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/device/device_id_service.dart';
import 'package:venta_mobile/core/network/api_client.dart';
import 'package:venta_mobile/features/auth/data/auth_repository.dart';
import 'package:venta_mobile/features/voice/data/voice_api.dart';

/// The gap these cover: `call.IncomingCall` is broadcast once over SignalR and
/// never replayed. Open the app while somebody is already calling you - the
/// socket connects seconds too late - and the client had no way to find out at
/// all; the only other channel is the call push, which is best-effort. The
/// backend now keeps a short-lived "ringing for this user" index and
/// `GET voice/call/pending` reads it, validated against the call itself.
///
/// The 204 is the load-bearing detail on this side. It is the answer almost
/// every time this is called, so getting it wrong turns a routine catch-up into
/// an exception on every connect.
class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockDeviceIdService extends Mock implements DeviceIdService {}

class _CannedAdapter implements HttpClientAdapter {
  _CannedAdapter({required this.status, this.body});

  final int status;
  final Map<String, dynamic>? body;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final payload = body;
    if (payload == null) {
      return ResponseBody.fromString('', status);
    }
    return ResponseBody.fromString(
      jsonEncode(payload),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

VoiceApi _apiWith(_CannedAdapter adapter) {
  final auth = _MockAuthRepository();
  when(() => auth.baseUrl).thenReturn('https://example.test');
  when(() => auth.ensureValidToken()).thenAnswer((_) async => 'token');
  final client = ApiClient(authRepository: auth);
  client.dio.httpClientAdapter = adapter;

  final deviceIds = _MockDeviceIdService();
  when(() => deviceIds.deviceId).thenReturn('device-1');

  return VoiceApi(client: client, deviceIdService: deviceIds);
}

void main() {
  test('a 204 with no body reads as "nothing is ringing"', () async {
    final adapter = _CannedAdapter(status: 204);

    final pending = await _apiWith(adapter).getPendingCall();

    expect(pending, isNull);
    expect(adapter.requests.single.path, contains('/voice/call/pending'));
  });

  test('a ringing call comes back parsed', () async {
    final adapter = _CannedAdapter(
      status: 200,
      body: const {
        'id': 'call-1',
        'creatorId': 'user-caller',
        'conversationId': 'conv-1',
        'status': 'Pending',
        'participants': <dynamic>[
          {'userId': 'user-me'},
          {'userId': 'user-caller'},
        ],
      },
    );

    final pending = await _apiWith(adapter).getPendingCall();

    expect(pending, isNotNull);
    expect(pending!.id, 'call-1');
    // Whoever placed the call, so the ring can be named without guessing at the
    // roster - see incoming_call_identity_test.dart.
    expect(pending.creatorId, 'user-caller');
  });

  test('carries X-Device-Id like every other voice request', () async {
    final adapter = _CannedAdapter(status: 204);

    await _apiWith(adapter).getPendingCall();

    expect(adapter.requests.single.headers['X-Device-Id'], 'device-1');
  });
}
