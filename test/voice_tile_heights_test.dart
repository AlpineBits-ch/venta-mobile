import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' show MediaStreamTrack;
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/voice/tile_heights.dart';
import 'package:venta_mobile/core/voice/video_layers.dart';

/// A track that reports whatever the platform would have. Only `getSettings`
/// is reached, so nothing else is stubbed.
class _FakeTrack extends Mock implements MediaStreamTrack {
  _FakeTrack(this._settings);

  final Map<String, dynamic> _settings;

  @override
  Map<String, dynamic> getSettings() => _settings;
}

/// The client half of simulcast layer selection: the ladder it publishes, and
/// the tile sizes it reports for the server to choose from.
///
/// Neither half fails loudly when it is wrong. A mis-shaped ladder costs
/// quality only under congestion; a report that never arrives costs money only
/// on the bill. So both are asserted rather than left to be noticed.
void main() {
  group('video layers', () {
    test('the camera ladder is three layers, largest first', () {
      // Rid *names* no longer matter and used to: the layer string was once a
      // `preferredRid` that went on the wire, and the previous SFU ranked rids
      // alphabetically. The server never sees a rid now, so the SDK names the
      // encodings and only the shape of the ladder is this client's business.
      final ladder = VideoLayers.cameraFor(720);

      expect(ladder, hasLength(3));
      expect(ladder.map((e) => e.dimensions.height), [720, 360, 180]);
    });

    // The server's layer ceiling arithmetic assumes exactly this relationship,
    // so the ladder has to hold its shape at whatever the top encode became.
    // A 1080 capture published through a ladder written down against 720 would
    // have the server serving viewers a layer it had mis-measured.
    test('the 1:2:4 relationship survives a taller capture', () {
      for (final height in [480, 720, 1080]) {
        final heights = VideoLayers.cameraFor(
          height,
        ).map((e) => e.dimensions.height).toList();

        expect(
          heights,
          [height, height ~/ 2, height ~/ 4],
          reason: 'ladder for ${height}p',
        );
      }
    });

    test('the bitrate budget follows the capture size', () {
      // Anchored at 720 and scaled by pixel area, so raising the capture does
      // not push 1080 lines through a budget tuned for 720. `maxBitrate` is a
      // ceiling rather than a target, so congestion control still settles below
      // it on a link that cannot carry it.
      final at720 = VideoLayers.cameraFor(720).first.encoding!.maxBitrate;
      final at1080 = VideoLayers.cameraFor(1080).first.encoding!.maxBitrate;
      final at480 = VideoLayers.cameraFor(480).first.encoding!.maxBitrate;

      expect(at1080, greaterThan(at720));
      expect(at480, lessThan(at720));
      expect(at1080 / at720, closeTo(2.25, 0.01));
    });

    test('the screen ladder omits the quarter layer', () {
      // Text at quarter resolution is not a cheaper picture but an unreadable
      // one. A viewer the server sends to the bottom layer has no such layer to
      // pull, which the SDK already handles by falling back to one the
      // publisher actually sends.
      expect(VideoLayers.screenFor(1080), hasLength(2));
      expect(
        VideoLayers.screenFor(1080).map((e) => e.dimensions.height),
        [1080, 540],
      );
    });

    test('a screen layer carries more bits than a camera one', () {
      // Same scale, different content: a shared screen is mostly text, and
      // text is where a camera-tuned budget produces an unreadable picture
      // rather than a cheaper one.
      final screen = VideoLayers.screenFor(720).first.encoding!.maxBitrate;
      final camera = VideoLayers.cameraFor(720).first.encoding!.maxBitrate;

      expect(screen, greaterThan(camera));
    });
  });

  /// What reaches the wire is what was captured, not what was asked for.
  ///
  /// The one direction it is safe to be wrong in is upward: a declaration above
  /// what is really encoded earns a cap that was not needed, while one below it
  /// leaves the publisher uncapped at the simulcast layer - and on a screen
  /// share, uncapped means a 4K display fanned out at its top layer to every
  /// viewer in the room.
  group('what a capture declares', () {
    test('the track is believed over the request', () {
      final track = _FakeTrack({'width': 640, 'height': 480, 'frameRate': 24});

      // A handset that could not reach 1080 encodes 480. Declaring the request
      // would ask the server to cap a picture that is already small.
      expect(
        VideoPublishIntent.fromTrack(
          track,
          fallback: const VideoPublishIntent(height: 1080, framerate: 60),
        ),
        const VideoPublishIntent(height: 480, framerate: 24),
      );
    });

    test('a platform that reports nothing falls back to the request', () {
      expect(
        VideoPublishIntent.fromTrack(
          _FakeTrack(const {}),
          fallback: VideoPublishIntent.conservative,
        ),
        VideoPublishIntent.conservative,
      );
    });

    test('one readable axis is used and the other falls back', () {
      // A non-positive number reads as "unstated" on the wire, so a zero here
      // would silently drop that axis of the declaration rather than state it.
      expect(
        VideoPublishIntent.fromTrack(
          _FakeTrack(const {'height': 1080}),
          fallback: const VideoPublishIntent(height: 720, framerate: 30),
        ),
        const VideoPublishIntent(height: 1080, framerate: 30),
      );
    });

    test('sizes arriving as strings or doubles are still numbers', () {
      expect(
        VideoPublishIntent.fromTrack(
          _FakeTrack(const {'height': '1080', 'frameRate': 29.97}),
          fallback: VideoPublishIntent.conservative,
        ),
        const VideoPublishIntent(height: 1080, framerate: 30),
      );
    });

    test('nonsense in the settings map is not a declaration', () {
      expect(
        VideoPublishIntent.fromTrack(
          _FakeTrack(const {'height': 'tall', 'frameRate': -1}),
          fallback: VideoPublishIntent.conservative,
        ),
        VideoPublishIntent.conservative,
      );
    });

    test('an intent stating neither axis is not worth sending', () {
      expect(VideoPublishIntent.unstated.isStated, isFalse);
      expect(
        const VideoPublishIntent(height: 1080, framerate: 0).isStated,
        isTrue,
      );
    });
  });

  group('tile heights', () {
    late List<Map<String, int>> sent;
    late VoiceTileHeights heights;

    const debounce = Duration(milliseconds: 10);

    setUp(() {
      sent = [];
      heights = VoiceTileHeights(
        debounce: debounce,
        send: (map) async => sent.add(Map.of(map)),
      );
    });

    tearDown(() => heights.dispose());

    Future<void> settle() => Future<void>.delayed(debounce * 3);

    test('a burst of reports posts once', () async {
      for (var i = 0; i < 10; i++) {
        heights.set(tileId: 'camera:u1', userId: 'u1', devicePixels: 100 + i);
      }
      await settle();

      // A resize is not free server-side - it recomputes a plan and can move a
      // subscription - so a settling layout must not become ten of them.
      expect(sent, [
        {'u1': 109},
      ]);
    });

    test('the largest tile wins for a publisher on screen twice', () async {
      heights.set(tileId: 'camera:u1', userId: 'u1', devicePixels: 240);
      heights.set(tileId: 'share:u1', userId: 'u1', devicePixels: 1080);
      await settle();

      // One height per publisher, and the share is the one that has to be
      // legible. Keying on the publisher instead of the tile is what made the
      // thumbnail overwrite it.
      expect(sent.single, {'u1': 1080});
    });

    test('a removed tile leaves the map without it', () async {
      heights.set(tileId: 'camera:u1', userId: 'u1', devicePixels: 240);
      heights.set(tileId: 'camera:u2', userId: 'u2', devicePixels: 240);
      await settle();
      heights.remove('camera:u2');
      await settle();

      // The endpoint replaces the stored dictionary, so a publisher absent
      // from the map is one this client is no longer drawing. A delta would
      // leave a departed tile claiming full quality forever.
      expect(sent, [
        {'u1': 240, 'u2': 240},
        {'u1': 240},
      ]);
    });

    test('an unchanged map is not reposted', () async {
      heights.set(tileId: 'camera:u1', userId: 'u1', devicePixels: 240);
      await settle();
      heights.set(tileId: 'camera:u1', userId: 'u1', devicePixels: 240);
      await settle();

      expect(sent, hasLength(1));
    });

    test(
      'a failed post is retried by the next report rather than lost',
      () async {
        var attempts = 0;
        final flaky = VoiceTileHeights(
          debounce: debounce,
          send: (map) async {
            attempts++;
            if (attempts == 1) throw Exception('offline');
            sent.add(Map.of(map));
          },
        );
        addTearDown(flaky.dispose);

        flaky.set(tileId: 'camera:u1', userId: 'u1', devicePixels: 240);
        await settle();
        // The same value again: recorded as sent, it would be suppressed as
        // unchanged and the server would never learn this size at all.
        flaky.set(tileId: 'camera:u1', userId: 'u1', devicePixels: 241);
        await settle();

        expect(attempts, 2);
        expect(sent.single, {'u1': 241});
      },
    );

    test('clearing forgets without posting', () async {
      heights.set(tileId: 'camera:u1', userId: 'u1', devicePixels: 240);
      heights.clear();
      await settle();

      expect(sent, isEmpty);
    });
  });
}
