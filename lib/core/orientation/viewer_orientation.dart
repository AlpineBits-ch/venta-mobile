import 'dart:async';

import 'package:hydrated_bloc/hydrated_bloc.dart';

/// What the full-screen video viewer does with the way the device is held.
enum ViewerOrientationMode {
  /// Follow the tilt. What almost everyone wants and the default.
  auto,

  /// Stay upright however the device is turned - for watching lying down,
  /// where gravity says landscape and the person does not mean it.
  portrait,

  /// Stay sideways however the device is turned. The tilt still picks *which*
  /// side is down, so turning the phone over the other way still works.
  landscape,
}

/// Remembers the choice across sessions.
///
/// Someone who forces landscape is usually working around something permanent
/// about their device or their posture, and re-forcing it on every stream is
/// the kind of small tax that makes a feature feel broken.
///
/// Piggybacks on `HydratedBloc.storage` for the same reason `WikiEditorPrefs`
/// does - it is already initialised in `main()` and this is one key.
abstract final class ViewerOrientationPrefs {
  static const _key = 'viewer_orientation_mode';

  static ViewerOrientationMode get mode {
    final raw = HydratedBloc.storage.read(_key);
    final name = raw is Map ? raw['mode'] as String? : null;
    return ViewerOrientationMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => ViewerOrientationMode.auto,
    );
  }

  static set mode(ViewerOrientationMode value) {
    unawaited(HydratedBloc.storage.write(_key, {'mode': value.name}));
  }
}
