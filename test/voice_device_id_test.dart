import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/device/device_id_service.dart';
import 'package:venta_mobile/core/network/api_client.dart';
import 'package:venta_mobile/features/auth/data/auth_repository.dart';
import 'package:venta_mobile/features/voice/data/voice_api.dart';

/// The bug these cover: a 1:1 call answered on mobile immediately tore itself
/// down with "You joined this call on another device.", and the caller (the
/// Angular client) never saw an audio session from us.
///
/// Both symptoms came from one omission. The backend runs device-takeover
/// detection (`Call.ConnectDevice`) on two separate requests - `PUT
/// call/{id}/accept` *and* `POST calls/{id}/session` - and compares the
/// `X-Device-Id` header of one against the other, defaulting a missing header
/// to the literal `"default"`. `VoiceApi` sent a real id on the lifecycle
/// endpoints but nothing at all on the Cloudflare ones, so the server saw
/// `accept` from device `<real>` followed by `session` from device
/// `"default"`, concluded the user had answered on a second device, fired
/// `call.CallDeviceTakeover` at the device that had just joined, and nulled
/// out its `CfSessionId`/`AudioTrackName` - which is what left the caller with
/// no audio session to subscribe to.
///
/// It was never a race. Both requests are strictly ordered, so it reproduced
/// on every single call. Angular is unaffected because it sends no device id
/// anywhere - both requests read as `"default"`, and the ids match.
///
/// The same mismatch also silently broke hang-up: `Call.Leave` no-ops unless
/// the header matches the participant's stored `ActiveDeviceId`, which the
/// session request had overwritten with `"default"`.
class _MockAuthRepository extends Mock implements AuthRepository {}

/// Captures each outbound request and answers it with a canned body, so the
/// assertions can be about headers rather than about responses.
class _CapturingAdapter implements HttpClientAdapter {
  _CapturingAdapter(this.body);

  final Map<String, dynamic> body;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Stands in for the real service, whose `init` needs secure storage behind a
/// platform channel. The id value is all these tests care about.
class _MockDeviceIdService extends Mock implements DeviceIdService {}

const _kDeviceId = 'abc123deviceid';

/// Minimal `CallDto`-shaped body - enough for `CallDto.fromJson`.
const _callBody = <String, dynamic>{
  'id': 'call-1',
  'creatorId': 'u1',
  'conversationId': 'c1',
  'status': 'Connected',
  'participants': <dynamic>[],
};

void main() {
  late _CapturingAdapter adapter;
  late VoiceApi api;

  RequestOptions requestFor(String pathFragment) => adapter.requests.firstWhere(
    (r) => r.path.contains(pathFragment),
    orElse: () => throw StateError(
      'no request matching "$pathFragment"; saw '
      '${adapter.requests.map((r) => r.path).toList()}',
    ),
  );

  String? deviceHeaderFor(String pathFragment) =>
      requestFor(pathFragment).headers['X-Device-Id'] as String?;

  setUp(() {
    final auth = _MockAuthRepository();
    when(() => auth.baseUrl).thenReturn('https://example.test');
    when(() => auth.ensureValidToken()).thenAnswer((_) async => 'token');

    final client = ApiClient(authRepository: auth);
    // One body serves every endpoint - a superset of the fields the various
    // DTOs require, since these tests only ever assert on the request side.
    adapter = _CapturingAdapter({
      ..._callBody,
      'cfSessionId': 'cf-session-1',
      'sessionDescription': <String, dynamic>{'type': 'answer', 'sdp': ''},
    });
    client.dio.httpClientAdapter = adapter;

    final deviceIdService = _MockDeviceIdService();
    when(() => deviceIdService.deviceId).thenReturn(_kDeviceId);

    api = VoiceApi(client: client, deviceIdService: deviceIdService);
  });

  group('X-Device-Id', () {
    test('the Cloudflare session request carries it', () async {
      // The regression itself: this endpoint runs ConnectDevice server-side
      // and was the one sending nothing.
      await api.cfCreateSession('call-1');
      expect(deviceHeaderFor('/session'), _kDeviceId);
    });

    test('accept and the session request agree on the id', () async {
      // The comparison the backend actually makes. Equality here is what
      // decides between "same device, carry on" and "takeover, tear down".
      await api.acceptCall('call-1');
      await api.cfCreateSession('call-1');

      expect(deviceHeaderFor('/accept'), isNotNull);
      expect(deviceHeaderFor('/accept'), deviceHeaderFor('/session'));
    });

    test('the session request never falls back to the "default" bucket', () async {
      // Guards the specific value the server substitutes for a missing
      // header - a client that sent the literal string would collide with
      // every other device in that bucket.
      await api.cfCreateSession('call-1');
      expect(deviceHeaderFor('/session'), isNot('default'));
    });

    test('leave sends the same id the session request registered', () async {
      // Call.Leave no-ops unless the header matches the ActiveDeviceId that
      // the session request stored, so a mismatch here leaves the user
      // connected server-side until the alone-timeout fires.
      await api.cfCreateSession('call-1');
      await api.leaveCall('call-1');
      expect(deviceHeaderFor('/leave'), deviceHeaderFor('/session'));
    });

    test('every call-scoped endpoint sends it', () async {
      // The failure mode was one endpoint out of nine being forgotten, so
      // assert the whole surface rather than the endpoints known to matter
      // today - ConnectDevice has already spread from accept to session once.
      await api.createCall(conversationId: 'c1', participantUserIds: ['u2']);
      await api.acceptCall('call-1');
      await api.declineCall('call-1');
      await api.leaveCall('call-1');
      await api.endCall('call-1');
      await api.getCall('call-1');
      await api.cfCreateSession('call-1');
      await api.cfTracksNew(
        callId: 'call-1',
        cfSessionId: 'cf-session-1',
        sessionDescription: const {},
        tracks: const [],
      );
      await api.cfRenegotiate(
        callId: 'call-1',
        cfSessionId: 'cf-session-1',
        sessionDescription: const {},
      );
      await api.cfCloseTracks(
        callId: 'call-1',
        cfSessionId: 'cf-session-1',
        trackNames: const ['audio'],
      );

      expect(adapter.requests, hasLength(10));
      for (final request in adapter.requests) {
        expect(
          request.headers['X-Device-Id'],
          _kDeviceId,
          reason: '${request.method} ${request.path} sent no device id',
        );
      }
    });

    test('the session request declares itself primary', () async {
      // `primary=false` is the branch that deliberately skips ConnectDevice.
      // This client publishes screen share on its mic peer connection, so it
      // only ever opens primary sessions - and must not accidentally opt out
      // of the device bookkeeping the rest of this suite depends on.
      await api.cfCreateSession('call-1');
      expect(requestFor('/session').queryParameters['primary'], true);
    });
  });
}
