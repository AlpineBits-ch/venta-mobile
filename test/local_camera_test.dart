import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:venta_mobile/core/orientation/device_tilt.dart';
import 'package:venta_mobile/core/widgets/camera_switch_button.dart';
import 'package:venta_mobile/core/widgets/local_camera_tile.dart';
import 'package:venta_mobile/core/widgets/video_participant_tile.dart';
import 'package:venta_mobile/core/widgets/voice_fullscreen_view.dart';

/// The self-preview: the tile that shows this device's own camera, and the
/// control that flips which camera that is.
///
/// The renderer underneath talks to flutter_webrtc over a platform channel that
/// does not exist in the widget-test harness, so both it and the per-texture
/// event channel are stubbed below. Every tile here is built with a null track,
/// which is a state the widget already has to handle - the picture has not
/// arrived yet - and which keeps these tests about the overlay and its wiring
/// rather than about decoding video.
/// Enough of `HydratedBloc.storage` for the viewer's remembered orientation,
/// which it reads while building.
class _MemoryStorage implements Storage {
  final _values = <String, dynamic>{};

  @override
  dynamic read(String key) => _values[key];

  @override
  Future<void> write(String key, dynamic value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<void> clear() async => _values.clear();

  @override
  Future<void> close() async {}
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => HydratedBloc.storage = _MemoryStorage());

  setUp(() {
    // The full-screen viewer turns its own content, which means it subscribes
    // to the accelerometer the moment it is built.
    DeviceTilt.streamFactory = () => const Stream<AccelerometerEvent>.empty();
    DeviceTilt.instance.quarterTurns.value = 0;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('FlutterWebRTC.Method'),
      (call) async => switch (call.method) {
        'createVideoRenderer' => {'textureId': 1},
        _ => null,
      },
    );
    // An `EventChannel` subscribes over a `MethodChannel` of the same name, and
    // a failure to subscribe is reported through `FlutterError` - which a
    // widget test fails on. Absorbed rather than left to throw.
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('FlutterWebRTC/Texture1'),
      (call) async => null,
    );
  });

  tearDown(() {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('FlutterWebRTC.Method'),
      null,
    );
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('FlutterWebRTC/Texture1'),
      null,
    );
  });

  group('CameraSwitchButton', () {
    testWidgets('a tap while the flip is still in flight is dropped', (
      tester,
    ) async {
      var flips = 0;
      final held = Completer<void>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CameraSwitchButton(
              onSwitch: () {
                flips++;
                return held.future;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CameraSwitchButton));
      await tester.pump();
      await tester.tap(find.byType(CameraSwitchButton));
      await tester.pump();
      expect(
        flips,
        1,
        reason: 'flipping twice at once is how the picture and the mirroring '
            'end up describing different cameras',
      );

      held.complete();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CameraSwitchButton));
      await tester.pump();
      expect(flips, 2, reason: 'the control has to come back afterwards');
    });

    testWidgets('a flip that fails still releases the control', (tester) async {
      var flips = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CameraSwitchButton(
              onSwitch: () {
                flips++;
                return Future<void>.error(StateError('no second camera'));
              },
            ),
          ),
        ),
      );

      // A device with one camera simply keeps the picture it had, and that is
      // the whole of it: no error out into the gesture callback, and above all
      // no button left stuck busy, which would be the one failure the user
      // would actually be holding.
      await tester.tap(find.byType(CameraSwitchButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CameraSwitchButton));
      await tester.pumpAndSettle();
      expect(flips, 2);
    });
  });

  group('LocalCameraTile', () {
    Future<void> pumpTile(
      WidgetTester tester, {
      required bool isFrontCamera,
      VoidCallback? onTap,
      Future<void> Function()? onSwitchCamera,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: LocalCameraTile(
                track: null,
                isFrontCamera: isFrontCamera,
                onSwitchCamera: onSwitchCamera ?? () async {},
                onTap: onTap ?? () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('the front camera is mirrored and the back one is not', (
      tester,
    ) async {
      await pumpTile(tester, isFrontCamera: true);
      expect(
        tester.widget<VideoParticipantTile>(find.byType(VideoParticipantTile))
            .mirror,
        isTrue,
      );

      await pumpTile(tester, isFrontCamera: false);
      expect(
        tester.widget<VideoParticipantTile>(find.byType(VideoParticipantTile))
            .mirror,
        isFalse,
        reason: 'a mirrored back camera reads the world backwards',
      );
    });

    testWidgets('tapping the picture opens it full-screen', (tester) async {
      var opened = 0;
      await pumpTile(tester, isFrontCamera: true, onTap: () => opened++);
      // By position rather than by finder: what actually takes the tap is the
      // ink well laid over the picture, which is the point.
      await tester.tapAt(tester.getCenter(find.byType(VideoParticipantTile)));
      await tester.pump();
      expect(opened, 1);
    });

    testWidgets('tapping the flip control does not also open full-screen', (
      tester,
    ) async {
      var opened = 0;
      var flips = 0;
      await pumpTile(
        tester,
        isFrontCamera: true,
        onTap: () => opened++,
        onSwitchCamera: () async => flips++,
      );

      await tester.tap(find.byType(CameraSwitchButton));
      // Pumped by hand rather than settled: with no track yet the tile draws a
      // progress indicator, and an indeterminate one never settles.
      await tester.pump(const Duration(milliseconds: 400));
      expect(flips, 1);
      expect(
        opened,
        0,
        reason: 'the control sits on top of the tile that opens full-screen, '
            'so a tap on it must not be a tap on both',
      );
    });
  });

  group('VoiceFullscreenView', () {
    Future<void> pumpViewer(
      WidgetTester tester, {
      Future<void> Function()? onSwitchCamera,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: VoiceFullscreenView(
            title: 'Your camera',
            updates: const Stream<Object?>.empty(),
            track: () => null,
            isLive: () => true,
            isMirrored: () => true,
            onSwitchCamera: onSwitchCamera,
          ),
        ),
      );
      await tester.pump();
    }

    /// How faded the controls currently are. They are always in the tree - what
    /// changes is whether they are drawn and whether they take taps. Found
    /// under the slide, which is the chrome's alone: the picture carries a fade
    /// of its own for the camera flip.
    /// The outermost one under the slide: the flip control fades itself too
    /// while it is working, and that one is nested inside this.
    double chromeOpacity(WidgetTester tester) => tester
        .widgetList<AnimatedOpacity>(
          find.descendant(
            of: find.byType(AnimatedSlide),
            matching: find.byType(AnimatedOpacity),
          ),
        )
        .first
        .opacity;

    testWidgets('the controls withdraw on their own and come back on a tap', (
      tester,
    ) async {
      await pumpViewer(tester);
      expect(chromeOpacity(tester), 1, reason: 'a screen that opens bare has '
          'no way out that anybody can see');

      await tester.pump(const Duration(seconds: 4));
      expect(chromeOpacity(tester), 0);

      // Anywhere on the picture - the gesture every full-screen viewer taught.
      await tester.tapAt(tester.getCenter(find.byType(VideoParticipantTile)));
      await tester.pump();
      expect(chromeOpacity(tester), 1);
    });

    testWidgets('the flip control is offered only for our own camera', (
      tester,
    ) async {
      await pumpViewer(tester);
      expect(find.byType(CameraSwitchButton), findsNothing);

      await pumpViewer(tester, onSwitchCamera: () async {});
      expect(find.byType(CameraSwitchButton), findsOneWidget);
    });

    testWidgets('using a control keeps the controls up', (tester) async {
      final held = Completer<void>();
      await pumpViewer(tester, onSwitchCamera: () => held.future);

      await tester.pump(const Duration(milliseconds: 2500));
      await tester.tap(find.byType(CameraSwitchButton));
      await tester.pump(const Duration(seconds: 2));
      expect(
        chromeOpacity(tester),
        1,
        reason: 'the bar must not withdraw out from under a thumb that is '
            'still using it',
      );

      held.complete();
      await tester.pump();
      await tester.pump(const Duration(seconds: 4));
      expect(chromeOpacity(tester), 0);
    });
  });
}
