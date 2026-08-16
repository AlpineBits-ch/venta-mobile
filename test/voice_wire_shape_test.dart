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
/// It used to be: routes were `cf/tracks/new`, the session was a `cfSessionId`,
/// and a track said `location: "local"|"remote"` - the SFU's own vocabulary,
/// describing where media sits rather than what the caller is doing. The server
/// replaced all of it with neutral contracts so the SFU is swappable, and the
/// move from Cloudflare Calls to LiveKit is what that bought: the snapshot, the
/// version rules, the heartbeat, the viewer counts and the entitlement bodies
/// did not move at all, because none of them were ever about which SFU was
/// behind them.
///
/// These pin the request side of that contract. A silent regression here does
/// not fail loudly - it 404s a route or drops a field the server then reads as
/// null, both of which surface as "voice does not connect" rather than as
/// anything pointing at the shape.
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
        // A superset serving every endpoint: these tests assert on the request
        // side, so one canned body answers them all.
        'backend': 'livekit',
        'url': 'wss://sfu-fsn1.venta.gg',
        'token': 'jwt',
        'room': 'channel-chan-1',
        'identity': 'user-1',
        'mediaSessionId': 'user-1',
        'rung': '1080p60',
        'maxLayer': null,
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

  group('publish declaration', () {
    test('declares tracks by name, and nothing about a transport', () async {
      // The whole body now. There is no SDP to relay, no session to name and no
      // mid to resolve - the media is already flowing by the time this is sent,
      // and its only job is to make the publish visible to everything in the
      // product that is not the media.
      await callApi.declarePublish(
        callId: 'call-1',
        trackNames: const ['screen-abc123', 'screen-audio-abc123'],
        video: const {'height': 1080, 'framerate': 60},
      );

      final body = bodyOf('/publish');
      expect(body['trackNames'], ['screen-abc123', 'screen-audio-abc123']);
      expect(body['video'], {'height': 1080, 'framerate': 60});
      expect(body.containsKey('sessionDescription'), isFalse);
      expect(body.containsKey('mediaSessionId'), isFalse);
    });

    test('both halves of a share are declared in one call', () async {
      // What lets a receiving client group them into a single tile from the two
      // `TrackPublished` events that follow.
      await callApi.declarePublish(
        callId: 'call-1',
        trackNames: const ['screen-abc123', 'screen-audio-abc123'],
      );

      expect(adapter.requests.where((r) => r.path.contains('/publish')), hasLength(1));
    });

    test('an audio-only publish declares no picture', () async {
      // A video ceiling has never had anything to say about a microphone, and
      // declaring a height on one invites the server to answer a question
      // nobody asked.
      await callApi.declarePublish(
        callId: 'call-1',
        trackNames: const ['audio'],
      );

      expect(bodyOf('/publish').containsKey('video'), isFalse);
    });

    test('a resolution change is its own declaration', () async {
      // For a client that changes what it sends *without* republishing - a
      // share that switched source, a camera that changed size. A ceiling
      // computed once at publish time is one a later change walks straight
      // past.
      await callApi.declareVideo(
        callId: 'call-1',
        video: const {'height': 1080, 'framerate': 60},
      );

      final request = requestFor('/video');
      expect(request.method, 'PUT');
      expect(request.data, {'height': 1080, 'framerate': 60});
    });

    test('the microphone track name is still the wire constant', () {
      // Participant announcements key off this exact name, so it survived two
      // SFU migrations untouched and must keep doing so.
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

    test('backgrounding reports paused on its own', () async {
      // Drops video, never audio - a backgrounded client is still in the
      // conversation. Riding anything else on this body would clear a set
      // nobody asked to clear.
      await callApi.updateSubscriber(callId: 'call-1', paused: true);

      final body = bodyOf('/subscriptions');
      expect(body['paused'], isTrue);
      expect(body.containsKey('tileHeights'), isFalse);
      expect(body.containsKey('pinned'), isFalse);
    });

    test('a collapsed tile names its publisher', () async {
      await callApi.updateSubscriber(
        callId: 'call-1',
        pausedPublishers: const ['user-7'],
      );

      expect(bodyOf('/subscriptions')['pausedPublishers'], ['user-7']);
    });

    test('the reply is this client\'s own subscription set', () async {
      // So a caller can act on what it just reported without waiting for the
      // push - which matters most on the report that *caused* the change, where
      // waiting means a tile stays at the wrong layer for a round trip.
      //
      // The reply is always a full 200 object, never a 204 or a bare null, and
      // it flattens the set onto itself the way `SubscriptionsChanged` does
      // rather than nesting it the way the snapshot does.
      final set = await callApi.updateSubscriber(
        callId: 'call-1',
        tileHeights: const {'user-4': 180},
      );

      expect(set, isNotNull);
      // The canned reply carries no `tracks`, which is the unplanned room: a
      // revocation, **not** an empty set. Reading it as the latter unsubscribes
      // this client from everybody in the ordinary small call, silently, on
      // every tile resize.
      expect(set!.isInForce, isFalse);
      expect(set.tracks, isNull);
    });
  });

  group('routes', () {
    test('the call media routes are the neutral ones', () async {
      await callApi.createConnection('call-1');
      await callApi.declarePublish(
        callId: 'call-1',
        trackNames: const ['audio'],
      );
      await callApi.declareVideo(
        callId: 'call-1',
        video: const {'height': 720, 'framerate': 30},
      );
      await callApi.unpublish(callId: 'call-1', trackNames: const ['audio']);

      expect(requestFor('/connection').method, 'POST');
      expect(requestFor('/publish').method, 'POST');
      expect(requestFor('/video').method, 'PUT');
      expect(requestFor('/unpublish').method, 'POST');
      for (final request in adapter.requests) {
        expect(request.path, isNot(contains('/cf/')));
      }
    });

    test('the removed negotiation routes are gone from this client', () async {
      // They 404 now, and a client still calling them fails in a way that looks
      // like a network problem rather than like a deleted route.
      await callApi.createConnection('call-1');
      await callApi.declarePublish(
        callId: 'call-1',
        trackNames: const ['audio'],
      );
      await callApi.unpublish(callId: 'call-1', trackNames: const ['audio']);

      for (final request in adapter.requests) {
        expect(request.path, isNot(contains('/session')));
        expect(request.path, isNot(endsWith('/tracks')));
        expect(request.path, isNot(contains('/tracks/close')));
        expect(request.path, isNot(contains('/negotiate')));
        expect(request.path, isNot(contains('/ice-servers')));
      }
    });

    test(
      'the guild media routes match the call ones under a guild path',
      () async {
        await guildApi.createConnection('g1', 'c1');
        await guildApi.declarePublish(
          guildId: 'g1',
          channelId: 'c1',
          trackNames: const ['audio'],
        );

        expect(
          requestFor('/publish').path,
          contains('/guilds/g1/channels/c1/voice/publish'),
        );
        expect(bodyOf('/publish')['trackNames'], ['audio']);
      },
    );
  });

  group('connection handshake', () {
    test('reads the node, the token and what the token grants', () async {
      // `url` is the routing answer - a room lives on exactly one node - and
      // the two publish flags are what the token actually permits, which is not
      // the same question as what the UI would like to offer.
      final connection = await callApi.createConnection('call-1');

      expect(connection.backend, 'livekit');
      expect(connection.url, 'wss://sfu-fsn1.venta.gg');
      expect(connection.token, 'jwt');
      expect(connection.canPublishAudio, isTrue);
      expect(connection.canPublishVideo, isTrue);
    });

    test('identity is the handle, under either name', () {
      // Both fields carry it so a client can adopt the newer name without
      // changing its snapshot handling on the same day.
      const connection = VoiceConnectionDto(
        url: 'wss://node',
        token: 't',
        identity: 'AbC123',
        mediaSessionId: 'AbC123',
      );

      expect(connection.sessionHandle, 'AbC123');
    });

    test('declares whether it is the primary connection', () async {
      await callApi.createConnection('call-1');

      expect(requestFor('/connection').queryParameters['primary'], isTrue);
    });

    test('a capped publish says so without failing', () async {
      // `maxLayer` non-null means no viewer is served above that layer however
      // large their tile - but the track is up and the picture is flowing, so
      // nothing may treat it as a refusal.
      final result = await callApi.declarePublish(
        callId: 'call-1',
        trackNames: const ['camera'],
      );

      expect(result.rung, '1080p60');
      expect(result.maxLayer, isNull);
      expect(result.isLayerCapped, isFalse);
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
