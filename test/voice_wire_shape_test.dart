import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/device/device_id_service.dart';
import 'package:venta_mobile/core/network/api_client.dart';
import 'package:venta_mobile/core/voice/track_naming.dart';
import 'package:venta_mobile/core/voice/voice_media_dto.dart';
import 'package:venta_mobile/features/auth/data/auth_repository.dart';
import 'package:venta_mobile/features/guild_voice/data/guild_voice_api.dart';
import 'package:venta_mobile/features/voice/data/voice_api.dart';

/// The voice surface is deliberately *not* the SFU's.
///
/// It used to be: routes were `cf/tracks/new`, the session was a
/// `cfSessionId`, and a track said `location: "local"|"remote"` - Cloudflare's
/// own vocabulary, describing where media sits rather than what the caller is
/// doing. The server replaced all of it with neutral contracts so the SFU is
/// swappable, and the old shape was deleted rather than kept working.
///
/// These pin the request side of that contract. A silent regression here does
/// not fail loudly - it 404s a route or drops a field the server then reads as
/// null, both of which surface as "voice does not connect" rather than as
/// anything pointing at the rename.
class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockDeviceIdService extends Mock implements DeviceIdService {}

class _CapturingAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode({
        'mediaSessionId': 'media-1',
        'backend': 'cloudflare',
        'sessionDescription': <String, dynamic>{'type': 'answer', 'sdp': ''},
        'tracks': <dynamic>[],
        'roomId': 'chan-1',
        'kind': 'channel',
        'instanceId': 'inst-1',
        'version': 1,
        'participants': <dynamic>[],
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _CapturingAdapter adapter;
  late VoiceApi callApi;
  late GuildVoiceApi guildApi;

  RequestOptions requestFor(String pathFragment) => adapter.requests.firstWhere(
    (r) => r.path.contains(pathFragment),
    orElse: () => throw StateError(
      'no request matching "$pathFragment"; saw '
      '${adapter.requests.map((r) => '${r.method} ${r.path}').toList()}',
    ),
  );

  Map<String, dynamic> bodyOf(String pathFragment) =>
      requestFor(pathFragment).data as Map<String, dynamic>;

  setUp(() {
    final auth = _MockAuthRepository();
    when(() => auth.baseUrl).thenReturn('https://example.test');
    when(() => auth.ensureValidToken()).thenAnswer((_) async => 'token');

    final client = ApiClient(authRepository: auth);
    adapter = _CapturingAdapter();
    client.dio.httpClientAdapter = adapter;

    final deviceIdService = _MockDeviceIdService();
    when(() => deviceIdService.deviceId).thenReturn('device-1');

    callApi = VoiceApi(client: client, deviceIdService: deviceIdService);
    guildApi = GuildVoiceApi(client: client, deviceIdService: deviceIdService);
  });

  group('negotiation body', () {
    test('names the session with mediaSessionId, not cfSessionId', () async {
      await callApi.negotiate(
        callId: 'call-1',
        mediaSessionId: 'media-1',
        sessionDescription: const {'type': 'offer', 'sdp': ''},
        tracks: const [],
      );

      final body = bodyOf('/tracks');
      expect(body['mediaSessionId'], 'media-1');
      expect(body.containsKey('cfSessionId'), isFalse);
    });

    test('direction is spelled the way the server spells it', () {
      // `direction: publish|subscribe` replaced `location: local|remote`, and
      // both values are wire constants. A typo here is silent: the server
      // reads anything that is not "subscribe" as a publish, so a mistyped
      // subscribe is sent to the SFU as an offer to send media nobody has.
      expect(VoiceTrackDirection.publish, 'publish');
      expect(VoiceTrackDirection.subscribe, 'subscribe');
    });

    // The optional declaration is the same field on both bodies, and the call
    // routes carry it as well as the guild ones.
    test('a call renegotiation can restate the picture', () async {
      await callApi.renegotiate(
        callId: 'call-1',
        mediaSessionId: 'media-1',
        sessionDescription: const {},
        video: const {'height': 1080, 'framerate': 60},
      );

      expect(bodyOf('/negotiate')['video'], {'height': 1080, 'framerate': 60});
    });

    test('the microphone track name is still the wire constant', () {
      // Participant announcements key off this exact name, so it survived the
      // rename untouched and must keep doing so.
      expect(TrackNaming.audio, 'audio');
    });
  });

  /// Everything on this body only ever *reduces* what the server sends, and
  /// every field is optional with an omitted one left alone - so the shape has
  /// to be exact in both directions. A pin that never arrives is a fullscreen
  /// tile the subscription set does not include; a `pinned` riding a tile
  /// resize would clear one nobody asked to clear.
  group('subscriber reports', () {
    test('a tile resize carries tile heights and nothing else', () async {
      await guildApi.updateSubscriber(
        guildId: 'g1',
        channelId: 'c1',
        tileHeights: const {'user-4': 180},
      );

      final body = bodyOf('/subscriptions');
      expect(body['tileHeights'], {'user-4': 180});
      expect(body.containsKey('pinned'), isFalse);
      expect(body.containsKey('screenAudioShares'), isFalse);
    });

    test(
      'going fullscreen pins the publisher and asks for its audio',
      () async {
        await callApi.updateSubscriber(
          callId: 'call-1',
          pinned: const ['user-1'],
          screenAudioShares: const ['abc123'],
        );

        final body = bodyOf('/subscriptions');
        expect(body['pinned'], ['user-1']);
        expect(body['screenAudioShares'], ['abc123']);
        expect(body.containsKey('tileHeights'), isFalse);
      },
    );

    // An empty list is not an omission. Leaving fullscreen has to *clear* the
    // pin, and a body that omitted the field would leave it claimed - a
    // subscription held open for a tile nobody is drawing any more.
    test('leaving fullscreen sends empty lists rather than nothing', () async {
      await callApi.updateSubscriber(
        callId: 'call-1',
        pinned: const [],
        screenAudioShares: const [],
      );

      final body = bodyOf('/subscriptions');
      expect(body['pinned'], isEmpty);
      expect(body['screenAudioShares'], isEmpty);
    });
  });

  group('routes', () {
    test('the call media routes are the neutral ones', () async {
      await callApi.createSession('call-1');
      await callApi.negotiate(
        callId: 'call-1',
        mediaSessionId: 'media-1',
        sessionDescription: const {},
        tracks: const [],
      );
      await callApi.renegotiate(
        callId: 'call-1',
        mediaSessionId: 'media-1',
        sessionDescription: const {},
      );
      await callApi.closeTracks(
        callId: 'call-1',
        mediaSessionId: 'media-1',
        trackNames: const ['audio'],
      );

      expect(requestFor('/tracks').method, 'POST');
      expect(requestFor('/negotiate').method, 'PUT');
      // Was a PUT on `cf/tracks/close`; closing is a POST now.
      expect(requestFor('/tracks/close').method, 'POST');
      for (final request in adapter.requests) {
        expect(request.path, isNot(contains('/cf/')));
      }
    });

    test(
      'the guild media routes match the call ones under a guild path',
      () async {
        await guildApi.createSession('g1', 'c1');
        await guildApi.negotiate(
          guildId: 'g1',
          channelId: 'c1',
          mediaSessionId: 'media-1',
          sessionDescription: const {},
          tracks: const [],
        );

        expect(
          requestFor('/tracks').path,
          contains('/guilds/g1/channels/c1/voice/tracks'),
        );
        expect(bodyOf('/tracks')['mediaSessionId'], 'media-1');
      },
    );
  });

  group('session handshake', () {
    test('reads the declared backend alongside the session id', () async {
      final session = await callApi.createSession('call-1');

      expect(session.mediaSessionId, 'media-1');
      expect(session.backend, 'cloudflare');
    });

    test('declares whether it is the primary session', () async {
      await callApi.createSession('call-1');

      expect(requestFor('/session').queryParameters['primary'], isTrue);
    });

    test('join answers with the snapshot itself', () async {
      // It used to answer a shape with no media handles, which is why the
      // client had to read the snapshot separately to find anyone to subscribe
      // to. One response is now enough to render and connect the room.
      final snapshot = await guildApi.join('g1', 'c1');

      expect(snapshot.roomId, 'chan-1');
      expect(snapshot.instanceId, 'inst-1');
      expect(requestFor('/join').method, 'POST');
    });
  });
}
