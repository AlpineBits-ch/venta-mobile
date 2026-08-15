import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:venta_mobile/core/orientation/device_tilt.dart';
import 'package:venta_mobile/core/orientation/viewer_orientation.dart';
import 'package:venta_mobile/core/widgets/tilt_rotation.dart';

/// Watching a stream sideways.
///
/// The app is portrait locked and a rotation-locked device would not turn for
/// us anyway, so the full-screen viewer turns its own content. That makes the
/// mapping from "how the phone is held" to "how far the picture is turned"
/// something this codebase owns rather than something the platform gets right
/// - and getting it wrong by one quarter turn is a picture on its side, which
/// no test above this level would notice.
void main() {
  group('tilt angle to quarter turns', () {
    // The reading is the world's up in device axes, so +x means the device's
    // right edge points at the sky, which means the top edge points at the
    // holder's left, which means the content turns one quarter clockwise.
    test('upright is unrotated', () {
      expect(DeviceTilt.quarterTurnsForAngle(0), 0);
      expect(DeviceTilt.quarterTurnsForAngle(20), 0);
      expect(DeviceTilt.quarterTurnsForAngle(-20), 0);
    });

    test('the two landscapes turn opposite ways', () {
      expect(DeviceTilt.quarterTurnsForAngle(90), 1);
      expect(DeviceTilt.quarterTurnsForAngle(-90), 3);
    });

    test('upside down stays upright rather than standing on its head', () {
      // The same thing a phone with reverse portrait disabled does.
      expect(DeviceTilt.quarterTurnsForAngle(180), 0);
      expect(DeviceTilt.quarterTurnsForAngle(-170), 0);
    });

    test('the diagonals decide nothing', () {
      // Without this gap a phone held at 45 degrees flips on every tremor, and
      // each flip relays out a live video surface.
      expect(DeviceTilt.quarterTurnsForAngle(45), isNull);
      expect(DeviceTilt.quarterTurnsForAngle(-45), isNull);
      expect(DeviceTilt.quarterTurnsForAngle(135), isNull);
    });
  });

  group('device tilt', () {
    late StreamController<AccelerometerEvent> readings;

    setUp(() {
      readings = StreamController<AccelerometerEvent>.broadcast();
      DeviceTilt.streamFactory = () => readings.stream;
      DeviceTilt.instance.quarterTurns.value = 0;
    });

    tearDown(() async {
      await readings.close();
    });

    /// Gravity has to be pushed for a while: the readings are smoothed, so one
    /// sample never carries all the way to a new pose. Which is the point -
    /// a single jolt is not a person turning their phone over.
    Future<void> hold(double x, double y) async {
      for (var i = 0; i < 40; i++) {
        readings.add(AccelerometerEvent(x, y, 0, DateTime(2026)));
        await Future<void>.delayed(Duration.zero);
      }
    }

    test(
      'follows the phone and stops when the last claim is released',
      () async {
        final release = DeviceTilt.instance.claim();
        addTearDown(release);

        await hold(9.8, 0);
        expect(DeviceTilt.instance.quarterTurns.value, 1);

        await hold(-9.8, 0);
        expect(DeviceTilt.instance.quarterTurns.value, 3);

        await hold(0, 9.8);
        expect(DeviceTilt.instance.quarterTurns.value, 0);

        release();
        expect(readings.hasListener, isFalse);
      },
    );

    test('a phone lying flat keeps the pose it was last held in', () async {
      addTearDown(DeviceTilt.instance.claim());

      await hold(9.8, 0);
      expect(DeviceTilt.instance.quarterTurns.value, 1);

      // Face up on a table: the screen-plane component of gravity is noise, and
      // noise must not be allowed to spin the picture.
      await hold(0.1, -0.2);
      expect(DeviceTilt.instance.quarterTurns.value, 1);
    });

    test('two claims share one subscription', () {
      final first = DeviceTilt.instance.claim();
      final second = DeviceTilt.instance.claim();
      first();
      expect(readings.hasListener, isTrue);
      second();
      expect(readings.hasListener, isFalse);
    });
  });

  group('TiltRotation', () {
    setUp(() {
      DeviceTilt.streamFactory = () => const Stream<AccelerometerEvent>.empty();
      DeviceTilt.instance.quarterTurns.value = 0;
    });

    Future<int> turnsUnder(
      WidgetTester tester,
      ViewerOrientationMode mode,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TiltRotation(mode: mode, child: const SizedBox()),
        ),
      );
      await tester.pump();
      return tester.widget<RotatedBox>(find.byType(RotatedBox)).quarterTurns;
    }

    testWidgets('auto follows the device', (tester) async {
      DeviceTilt.instance.quarterTurns.value = 3;
      expect(await turnsUnder(tester, ViewerOrientationMode.auto), 3);
    });

    testWidgets('forced upright ignores the device', (tester) async {
      DeviceTilt.instance.quarterTurns.value = 1;
      expect(await turnsUnder(tester, ViewerOrientationMode.portrait), 0);
    });

    testWidgets('forced sideways ignores the device standing up', (
      tester,
    ) async {
      expect(await turnsUnder(tester, ViewerOrientationMode.landscape), 1);
    });

    testWidgets('forced sideways still picks the side being held', (
      tester,
    ) async {
      // The lock is about not going back to portrait. Turning the phone the
      // other way round is still a thing the person meant.
      DeviceTilt.instance.quarterTurns.value = 3;
      expect(await turnsUnder(tester, ViewerOrientationMode.landscape), 3);

      DeviceTilt.instance.quarterTurns.value = 0;
      await tester.pump();
      expect(
        tester.widget<RotatedBox>(find.byType(RotatedBox)).quarterTurns,
        3,
        reason: 'standing the phone up keeps the side it was last held on',
      );
    });
  });
}
