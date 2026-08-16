import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

/// Whether incoming video tiles show what they are actually receiving.
///
/// Off by default and persisted, for the same reason [ViewerOrientationPrefs]
/// is: this is a developer readout drawn over somebody's face, and nobody wants
/// to re-enable it every time they open a stream they are in the middle of
/// diagnosing.
///
/// **Deliberately not gated on `kDebugMode`.** The question this answers - which
/// simulcast layer is this device being served - can only be asked against a
/// real publisher on a real network, which in practice means a release build.
/// A diagnostic that vanishes in the build where the bug lives is not a
/// diagnostic. It is gated by placement instead: the switch lives in the
/// full-screen viewer's app bar, so you have to already be watching a stream to
/// find it.
///
/// A [ValueNotifier] rather than a plain getter because the point is to flip it
/// *while* watching, and see the number appear. A value that only took effect on
/// the next rebuild would have you leaving the room you are trying to measure.
abstract final class VideoDiagnosticsPrefs {
  static const _key = 'video_diagnostics_overlay';

  /// Read once at startup, then authoritative in memory. Every tile listens.
  static final ValueNotifier<bool> enabled = ValueNotifier<bool>(_read());

  static bool _read() {
    final raw = HydratedBloc.storage.read(_key);
    return raw is Map && raw['enabled'] == true;
  }

  /// Wrapped in a map rather than written as a bare bool because every other
  /// pref in this codebase stores a map, and the storage is shared.
  static void set(bool value) {
    enabled.value = value;
    unawaited(HydratedBloc.storage.write(_key, {'enabled': value}));
  }

  static void toggle() => set(!enabled.value);
}
