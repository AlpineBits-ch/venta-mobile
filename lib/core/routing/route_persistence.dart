import 'dart:async';

import 'package:hydrated_bloc/hydrated_bloc.dart';

/// Remembers the last authenticated route the user was on, so relaunching
/// the app after it's been killed (not just backgrounded, which Android
/// already keeps alive) returns them to their last channel/conversation
/// instead of always landing on Home - matches Discord's own "reopen where
/// you left off" behavior.
///
/// Piggybacks on `HydratedBloc.storage` (already initialized in `main()`,
/// backed by on-disk Hive storage with an in-memory read cache) rather than
/// pulling in a new persistence dependency for one string.
abstract final class RoutePersistence {
  static const _key = 'last_route_location';

  static String? get lastLocation =>
      HydratedBloc.storage.read(_key) as String?;

  static void save(String location) {
    unawaited(HydratedBloc.storage.write(_key, location));
  }

  static void clear() {
    unawaited(HydratedBloc.storage.delete(_key));
  }
}
