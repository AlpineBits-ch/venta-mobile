import 'package:flutter_test/flutter_test.dart';
import 'package:venta_mobile/core/voice/tile_heights.dart';
import 'package:venta_mobile/core/voice/video_layers.dart';

/// The client half of simulcast layer selection: the rid names it publishes
/// under, and the tile sizes it reports for the server to choose from.
///
/// Neither half fails loudly when it is wrong. A bad rid order costs quality
/// only under congestion; a report that never arrives costs money only on the
/// bill. So both are asserted rather than left to be noticed.
void main() {
  group('video layers', () {
    test('rid names sort alphabetically in descending quality', () {
      // The SFU's only ordering vocabulary is `asciibetical` - a-z, "a most
      // desirable, z least" - and it is never told what these names mean, so
      // the alphabet *is* the ranking. The WebRTC convention q/h/f sorts
      // backwards and would ask the SFU to degrade a congested viewer up to
      // full resolution. Must match the server's `VoiceVideoLayers`.
      expect(VideoLayers.high.compareTo(VideoLayers.medium), isNegative);
      expect(VideoLayers.medium.compareTo(VideoLayers.low), isNegative);
    });

    test('the camera ladder is three layers, largest first', () {
      final rids = VideoLayers.camera.map((e) => e.rid).toList();
      final scales = VideoLayers.camera
          .map((e) => e.scaleResolutionDownBy)
          .toList();

      expect(rids, [VideoLayers.high, VideoLayers.medium, VideoLayers.low]);
      expect(scales, [1, 2, 4]);
    });

    test('the screen ladder omits the quarter layer', () {
      // Text at quarter resolution is not a cheaper picture but an unreadable
      // one. A viewer the server sends to `low` has no such layer to pull,
      // which the subscribe already handles by falling back to one that exists.
      expect(VideoLayers.screen.map((e) => e.rid), [
        VideoLayers.high,
        VideoLayers.medium,
      ]);
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
