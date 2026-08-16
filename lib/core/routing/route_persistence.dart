import 'dart:async';

import 'package:hydrated_bloc/hydrated_bloc.dart';

/// Remembers the last *conversation* the user was reading, so relaunching
/// the app after it's been killed (not just backgrounded, which Android
/// already keeps alive) returns them to their last channel/DM instead of
/// always landing on Home - matches Discord's own "reopen where you left
/// off" behavior.
///
/// Piggybacks on `HydratedBloc.storage` (already initialized in `main()`,
/// backed by on-disk Hive storage with an in-memory read cache) rather than
/// pulling in a new persistence dependency for one string.
abstract final class RoutePersistence {
  static const _key = 'last_route_location';

  /// Only a place you *read messages in* is worth reopening: a DM
  /// conversation or a guild channel.
  ///
  /// Everything else is somewhere you went to do one thing and finish -
  /// settings, a profile, the wiki, a member list. Reopening the app onto
  /// Notification Settings because that's where it was last closed reads as
  /// the app being stuck, not as it remembering; those all fall back to Home.
  ///
  /// Sub-screens of a channel (`.../settings`, `.../forum`) are excluded for
  /// the same reason - the channel itself is the destination, not its config.
  static bool isRestorable(String location) {
    final uri = Uri.parse(location);
    return switch (uri.pathSegments) {
      ['home', 'conversation', final id] => id.isNotEmpty,
      ['server', final guildId, 'channel', final channelId] =>
        guildId.isNotEmpty && channelId.isNotEmpty,
      _ => false,
    };
  }

  /// The last restorable location, or null to mean Home.
  ///
  /// Filtered on the way out as well as on the way in, because [save] only
  /// stops *writing* the unrestorable ones - an install that was upgraded
  /// still has whatever the previous version wrote, and someone whose app last
  /// closed on Notification Settings would otherwise keep landing there
  /// forever, since nothing ever overwrites it either.
  static String? get lastLocation {
    final saved = HydratedBloc.storage.read(_key) as String?;
    if (saved == null || !isRestorable(saved)) return null;
    return saved;
  }

  static void save(String location) {
    if (!isRestorable(location)) return;
    // Saved without its query string: the only channel locations that carry
    // one are household deep links (`?focusKind=…&focus=…`), and reopening
    // the app days later scrolled to some long-settled chore - or worse,
    // re-firing its action - is not "where I left off".
    final uri = Uri.parse(location);
    unawaited(HydratedBloc.storage.write(_key, uri.path));
  }

  static void clear() {
    unawaited(HydratedBloc.storage.delete(_key));
  }
}
