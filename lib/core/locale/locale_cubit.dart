import 'dart:ui';

import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../bloc/safe_emit.dart';
import 'app_language.dart';

/// Holds the chosen language and remembers it across launches.
///
/// A [HydratedCubit] for the same reason `ThemeCubit` is one: this is a
/// device-local preference with no server behind it, and hydrated storage is
/// already wired up at startup. Nothing about it is account-scoped, so it
/// deliberately survives sign-out - somebody who set the app to Italian and
/// then switched accounts did not thereby start reading German.
class LocaleCubit extends HydratedCubit<AppLanguage> with SafeEmit<AppLanguage> {
  LocaleCubit() : super(AppLanguage.system);

  void setLanguage(AppLanguage language) => emitIfOpen(language);

  /// The concrete language in force right now, with [AppLanguage.system]
  /// already resolved against the device.
  ///
  /// Everything that has to *name* a language - the `Accept-Language` header,
  /// the prompt telling a model which text to read off a packet - needs this
  /// rather than the raw state, because "match device" is not an answer either
  /// of them can use.
  AppLanguage get effective =>
      state.resolve(PlatformDispatcher.instance.locales);

  @override
  AppLanguage? fromJson(Map<String, dynamic> json) =>
      AppLanguage.tryParse(json['language'] as String?);

  /// Stored by name rather than by index: an enum reordered in a later refactor
  /// would silently reinterpret every stored value, and the value here is one
  /// somebody chose by hand and would have to find again.
  @override
  Map<String, dynamic>? toJson(AppLanguage state) => {'language': state.name};
}
