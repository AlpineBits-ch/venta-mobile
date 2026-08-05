import 'dart:async';

import 'package:hydrated_bloc/hydrated_bloc.dart';

/// Which editing surface the wiki editor opens with.
enum WikiEditorMode { rich, markdown }

/// Remembers the editor a person actually likes.
///
/// Most people want the rich editor and never think about markdown again;
/// the ones who write markdown want it every time and are the loudest about
/// being handed a WYSIWYG surface instead. Neither group should have to flip
/// the switch on every page, so the choice sticks.
///
/// Piggybacks on `HydratedBloc.storage` for the same reason `RoutePersistence`
/// does - it is already initialised in `main()` and this is one key.
abstract final class WikiEditorPrefs {
  static const _key = 'wiki_editor_mode';

  static WikiEditorMode get mode {
    final raw = HydratedBloc.storage.read(_key);
    final name = raw is Map ? raw['mode'] as String? : null;
    return WikiEditorMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => WikiEditorMode.rich,
    );
  }

  static set mode(WikiEditorMode value) {
    unawaited(HydratedBloc.storage.write(_key, {'mode': value.name}));
  }
}
