import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// How the device is being held, expressed as the clockwise quarter turns the
/// *content* has to make to look level to whoever is holding it.
///
/// This exists because the platform will not tell us. The app is portrait
/// locked (see `main()`), so the window never rotates; and even an app that is
/// not locked gets nothing from a device whose rotation lock is on - which is
/// exactly the person who most needs a way to watch a stream sideways. Reading
/// gravity ourselves answers both cases with one mechanism, and the answer is
/// the same either way, which is worth more than matching the platform's own
/// rotation would be.
///
/// Only 0, 1 and 3 are produced. Upside down reads as 0, the same thing a phone
/// with reverse portrait disabled does, rather than a 2 that would leave the
/// picture standing on its head.
///
/// The accelerometer is a shared, refcounted subscription: nothing listens
/// until somebody [claim]s it, and it stops again when the last claim is
/// released. A sensor left running behind a closed viewer is a battery cost
/// with nobody to spend it on.
class DeviceTilt {
  DeviceTilt._();

  static final DeviceTilt instance = DeviceTilt._();

  /// Where the readings come from. Overridable so tests can drive tilt without
  /// a plugin, and so a platform with no accelerometer can be stood in for.
  @visibleForTesting
  static Stream<AccelerometerEvent> Function() streamFactory = () =>
      accelerometerEventStream(samplingPeriod: SensorInterval.uiInterval);

  /// The current answer. Starts upright and only ever moves to a pose the
  /// device has actually been held in.
  final ValueNotifier<int> quarterTurns = ValueNotifier<int>(0);

  /// Below this, the device is flat enough on its back that the screen-plane
  /// component of gravity is noise rather than an opinion, and the last pose
  /// stands. (Full gravity is ~9.81.)
  static const double _flatThreshold = 4.0;

  /// Exponential smoothing on the raw readings. Gravity does not jump, so the
  /// difference between one sample and the next is mostly hand tremor and
  /// whatever the person walking with the phone is doing with their arm.
  static const double _smoothing = 0.2;

  StreamSubscription<AccelerometerEvent>? _subscription;
  int _claims = 0;
  double? _x;
  double? _y;

  /// Starts, or joins, the sensor subscription. The returned callback releases
  /// this caller's claim and is safe to call more than once.
  VoidCallback claim() {
    if (_claims++ == 0) _start();
    var released = false;
    return () {
      if (released) return;
      released = true;
      if (--_claims == 0) _stop();
    };
  }

  void _start() {
    try {
      _subscription = streamFactory().listen(
        _onReading,
        // A sensor that fails mid-stream leaves the last pose in place and the
        // manual override still works. Nothing here is worth an error dialog
        // over a video that is playing fine.
        onError: (Object _) {},
      );
    } catch (_) {
      // No accelerometer at all (desktop, a bare emulator image). The picture
      // stays upright and the toggle is the only way to turn it - which is a
      // large part of why there is a toggle.
    }
  }

  void _stop() {
    unawaited(_subscription?.cancel());
    _subscription = null;
    _x = null;
    _y = null;
  }

  void _onReading(AccelerometerEvent event) {
    // The reading is the world's "up" expressed in device axes: +y out of the
    // top edge, +x out of the right edge, both platforms (sensors_plus flips
    // iOS to match Android).
    _x = _x == null ? event.x : _x! + _smoothing * (event.x - _x!);
    _y = _y == null ? event.y : _y! + _smoothing * (event.y - _y!);
    final x = _x!;
    final y = _y!;

    if (math.sqrt(x * x + y * y) < _flatThreshold) return;

    // 0 upright, +90 when the top edge points to the holder's left.
    final degrees = math.atan2(x, y) * 180 / math.pi;
    final turns = quarterTurnsForAngle(degrees);
    if (turns != null) quarterTurns.value = turns;
  }

  /// The pose for a tilt of [degrees] from upright, or null while the device is
  /// between two poses.
  ///
  /// The gaps between the bands are the whole point: without them a phone held
  /// at 45 degrees flickers between portrait and landscape on every tremor, and
  /// each flip is a relayout of a live video surface.
  @visibleForTesting
  static int? quarterTurnsForAngle(double degrees) {
    final tilt = degrees.abs();
    if (tilt <= 35) return 0;
    if (tilt >= 145) return 0; // Upside down: level enough to leave alone.
    if (tilt >= 55 && tilt <= 125) return degrees > 0 ? 1 : 3;
    return null;
  }
}
