import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/device/device_id_service.dart';
import 'package:venta_mobile/core/network/api_client.dart';
import 'package:venta_mobile/core/push/push_token_api.dart';
import 'package:venta_mobile/core/storage/secure_storage_service.dart';
import 'package:venta_mobile/features/auth/data/auth_api.dart';
import 'package:venta_mobile/features/auth/data/auth_repository.dart';

/// What these cover: the device id stopped being a header the server took on
/// trust. It is validated against a registered device now, the three endpoints
/// that read it answer `400 Unknown X-Device-Id '<id>' - register the device
/// first.` for one they don't know, and push tokens carry the device so the
/// backend can address one installation rather than a whole account.
///
/// The client-side consequence is that *not* sending the id, or sending one
/// that was never registered, is no longer a silent degrade to the old
/// single-device behaviour - it is a hard failure on every call action and
/// voice join. Hence a central interceptor rather than per-call-site headers,
/// and a recovery path that re-registers instead of leaving the session unable
/// to place calls.
class _MockAuthRepository extends Mock implements AuthRepository {}

/// Answers each request from a queue of canned responses (last one repeats),
/// recording what it was asked.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.responses);

  final List<ResponseBody Function()> responses;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final index = requests.length - 1;
    return responses[index < responses.length ? index : responses.length - 1]();
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Map<String, dynamic> body, [int status = 200]) =>
    ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

ResponseBody _text(String body, int status) =>
    ResponseBody.fromString(body, status);

const _kDeviceId = 'abc123deviceid';
const _kUnknownDeviceBody =
    "Unknown X-Device-Id 'abc123deviceid' - register the device first.";

void main() {
  late _MockAuthRepository auth;

  setUp(() {
    auth = _MockAuthRepository();
    when(() => auth.baseUrl).thenReturn('https://example.test');
    when(() => auth.ensureValidToken()).thenAnswer((_) async => 'token');
  });

  /// Builds a client whose device wiring is observable: [registrations] counts
  /// re-registration attempts, [retryAdapter] serves the retried request.
  ({ApiClient client, _ScriptedAdapter adapter, List<int> registrations})
  clientWith(
    List<ResponseBody Function()> responses, {
    _ScriptedAdapter? retryAdapter,
    String? deviceId = _kDeviceId,
  }) {
    final registrations = <int>[];
    final client = ApiClient(
      authRepository: auth,
      deviceId: () => deviceId,
      registerDevice: () async => registrations.add(1),
      retryClient: () => Dio()..httpClientAdapter = retryAdapter!,
    );
    final adapter = _ScriptedAdapter(responses);
    client.dio.httpClientAdapter = adapter;
    return (client: client, adapter: adapter, registrations: registrations);
  }

  group('X-Device-Id interceptor', () {
    test('attaches the id to a request that set no header of its own', () async {
      // The reason this moved off the call sites: GuildVoiceApi's Cloudflare
      // endpoints sent nothing while VoiceApi's sent the real id, and the
      // asymmetry was invisible until the server started rejecting it.
      final c = clientWith([() => _json({'ok': true})]);
      await c.client.dio.get<dynamic>(c.client.url('/api/v1/anything'));

      expect(c.adapter.requests.single.headers['X-Device-Id'], _kDeviceId);
    });

    test('leaves an explicitly set header alone', () async {
      final c = clientWith([() => _json({'ok': true})]);
      await c.client.dio.get<dynamic>(
        c.client.url('/api/v1/anything'),
        options: Options(headers: {'X-Device-Id': 'set-by-the-call-site'}),
      );

      expect(
        c.adapter.requests.single.headers['X-Device-Id'],
        'set-by-the-call-site',
      );
    });

    test('sends nothing at all before the id has been loaded', () async {
      // DeviceIdService.init() is awaited at startup, but a request that
      // somehow beats it should degrade to the server's `default` bucket
      // rather than throw a StateError out of an unrelated API call.
      final c = clientWith([() => _json({'ok': true})], deviceId: null);
      await c.client.dio.get<dynamic>(c.client.url('/api/v1/anything'));

      expect(
        c.adapter.requests.single.headers.containsKey('X-Device-Id'),
        isFalse,
      );
    });

    test('re-registers and retries once on the unknown-device 400', () async {
      // The first-run sequence this exists for: the id is real and stable, the
      // account just has no device row for it yet, and every call action and
      // voice join fails identically until one is created.
      final retry = _ScriptedAdapter([() => _json({'ok': true})]);
      final c = clientWith([
        () => _text(_kUnknownDeviceBody, 400),
      ], retryAdapter: retry);

      final response = await c.client.dio.put<dynamic>(
        c.client.url('/api/v1/messaging/voice/call/call-1/accept'),
      );

      expect(response.statusCode, 200);
      expect(c.registrations, hasLength(1));
      expect(retry.requests.single.headers['X-Device-Id'], _kDeviceId);
    });

    test('leaves an ordinary 400 alone', () async {
      // Re-registering wouldn't fix a validation failure, and retrying a
      // rejected write is worse than reporting it.
      final c = clientWith([() => _text('conversationId is required', 400)]);

      await expectLater(
        c.client.dio.post<dynamic>(c.client.url('/api/v1/messaging/voice/call')),
        throwsA(isA<DioException>()),
      );
      expect(c.registrations, isEmpty);
    });

    test('gives up after one retry rather than looping', () async {
      // A server that keeps answering "unknown device" - the registration
      // silently failing, say - must surface as one error, not a retry storm.
      final retry = _ScriptedAdapter([() => _text(_kUnknownDeviceBody, 400)]);
      final c = clientWith([
        () => _text(_kUnknownDeviceBody, 400),
      ], retryAdapter: retry);

      await expectLater(
        c.client.dio.put<dynamic>(c.client.url('/api/v1/messaging/voice/call/c/leave')),
        throwsA(isA<DioException>()),
      );
      expect(c.registrations, hasLength(1));
      expect(retry.requests, hasLength(1));
    });
  });

  group('push tokens', () {
    test('register on the consolidated endpoint, carrying the device', () async {
      // Without the device id the token can't be excluded from a fan-out,
      // which is what stops the phone that just answered a call from being
      // sent the cancel push for it.
      final c = clientWith([() => _json({}, 201)]);
      await PushTokenApi(client: c.client).registerToken(
        token: 'fcm-token',
        kind: PushTokenKind.fcm,
        deviceId: _kDeviceId,
      );

      final request = c.adapter.requests.single;
      expect(request.path, endsWith('/api/v1/identity/users/self/push-token'));
      expect(request.data, {
        'token': 'fcm-token',
        'kind': 'Fcm',
        'deviceId': _kDeviceId,
      });
    });

    test('the VoIP token declares its own transport', () async {
      final c = clientWith([() => _json({}, 201)]);
      await PushTokenApi(client: c.client).registerToken(
        token: 'apns-token',
        kind: PushTokenKind.apnsVoip,
        deviceId: _kDeviceId,
      );

      expect(
        (c.adapter.requests.single.data as Map)['kind'],
        'ApnsVoip',
      );
    });

    test('deletion names the token and gives up quietly', () async {
      // Runs inside sign-out, which must not hang or fail on a bad connection;
      // a 404 is the normal answer when the session was already revoked.
      final c = clientWith([() => _text('', 404)]);
      await PushTokenApi(
        client: c.client,
      ).deleteToken(token: 'fcm-token', kind: PushTokenKind.fcm);

      final request = c.adapter.requests.single;
      expect(request.method, 'DELETE');
      expect(request.queryParameters, {
        'token': 'fcm-token',
        'kind': 'Fcm',
      });
    });
  });

  group('token endpoint', () {
    test('names the device instead of leaving the Dart user-agent to', () async {
      // The visible symptom: this app showed up in the sessions list as
      // `Dart/3.x (dart:io)`, because the server falls back to the User-Agent
      // when a login sends no device_name.
      final adapter = _ScriptedAdapter([
        () => _json({'access_token': 'a', 'refresh_token': 'r', 'expires_in': 3600}),
      ]);
      final api = AuthApi(dio: Dio()..httpClientAdapter = adapter);

      await api.passwordGrant(
        baseUrl: 'https://example.test',
        username: 'alice',
        password: 'hunter2',
        deviceId: _kDeviceId,
      );

      final data = adapter.requests.single.data as Map;
      expect(data['device_name'], kDeviceName);
      expect(data['device_type'], kDeviceType);
      expect(data['device_id'], _kDeviceId);
    });

    test('omits the device id when there is none yet', () async {
      final adapter = _ScriptedAdapter([
        () => _json({'access_token': 'a', 'refresh_token': 'r', 'expires_in': 3600}),
      ]);
      final api = AuthApi(dio: Dio()..httpClientAdapter = adapter);

      await api.passwordGrant(
        baseUrl: 'https://example.test',
        username: 'alice',
        password: 'hunter2',
      );

      expect((adapter.requests.single.data as Map).containsKey('device_id'), isFalse);
    });
  });

  group('DeviceIdService', () {
    test('reports no id rather than throwing before init', () {
      // deviceIdOrNull exists for the callers that legitimately run before
      // startup finishes - the token endpoint and the interceptor.
      final service = DeviceIdService(secureStorage: _MockSecureStorage());
      expect(service.deviceIdOrNull, isNull);
      expect(() => service.deviceId, throwsStateError);
    });
  });
}

/// Stands in for the real service, whose reads go through a platform channel.
class _MockSecureStorage extends Mock implements SecureStorageService {}
