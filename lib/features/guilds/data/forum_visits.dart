import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

/// One forum post this member has opened, as remembered locally.
///
/// [name] is the post title as it read when it was last opened - the sidebar
/// prefers the live channel name when the guild cache still has the post, and
/// falls back to this so a remembered row never renders blank.
typedef ForumVisit = ({String postId, String name, DateTime visitedAt});

/// The forum posts this member has opened, per forum channel, so the guild
/// sidebar can nest them under their forum the way Discord does.
///
/// Purely local. The server has no "recently viewed post" concept, and a
/// post's own membership (`/threads`) isn't the same thing - this is a
/// navigation shortcut, so it's built from what this member actually opened
/// on this device. Piggybacks on `HydratedBloc.storage` for the same reason
/// `RoutePersistence` and the forum's own view prefs do.
///
/// Static rather than injected because it's read from `build` on a screen
/// that isn't bloc-backed; [revision] is what makes those reads reactive.
abstract final class ForumVisits {
  /// Deliberately short. This is a shortcut back to what you're currently
  /// following, not a history - a forum with thirty remembered posts under it
  /// buries every other channel in the sidebar, which is the whole thing the
  /// nesting is meant to avoid.
  static const maxPerForum = 5;

  /// Bumped on every change, so widgets built off [forForum] can rebuild
  /// without any of this having to be a bloc. Listeners fire while a post is
  /// open, which is exactly when the sidebar underneath needs to change.
  static final ValueNotifier<int> revision = ValueNotifier(0);

  static String _key(String forumChannelId) => 'forum_visits_$forumChannelId';

  /// Most recently opened first.
  static List<ForumVisit> forForum(String forumChannelId) {
    final raw = HydratedBloc.storage.read(_key(forumChannelId));
    final entries = raw is Map ? raw['posts'] : null;
    if (entries is! List) return const [];
    final visits = <ForumVisit>[];
    for (final entry in entries) {
      if (entry is! Map) continue;
      final id = entry['id'];
      final name = entry['name'];
      final timestamp = entry['ts'];
      if (id is! String || name is! String || timestamp is! int) continue;
      visits.add((
        postId: id,
        name: name,
        visitedAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
      ));
    }
    visits.sort((a, b) => b.visitedAt.compareTo(a.visitedAt));
    return visits;
  }

  /// Records an open (or re-open) of [postId], moving it to the top.
  ///
  /// Cheap to call from anywhere a post gets opened - re-opening the post
  /// that's already at the top under its current title writes nothing, so the
  /// sidebar doesn't churn on every rebuild of the screen calling this.
  static void record({
    required String forumChannelId,
    required String postId,
    required String name,
  }) {
    final existing = forForum(forumChannelId);
    final first = existing.firstOrNull;
    if (first != null && first.postId == postId && first.name == name) return;
    final kept = [
      for (final visit in existing)
        if (visit.postId != postId) visit,
    ];
    _write(forumChannelId, [
      (postId: postId, name: name, visitedAt: DateTime.now()),
      ...kept.take(maxPerForum - 1),
    ]);
  }

  /// Drops one post from the list - the `x` on the row. Only forgets that it
  /// was visited; the post itself is untouched, and opening it again brings
  /// the row back.
  static void forget(String forumChannelId, String postId) {
    final remaining = [
      for (final visit in forForum(forumChannelId))
        if (visit.postId != postId) visit,
    ];
    _write(forumChannelId, remaining);
  }

  static void _write(String forumChannelId, List<ForumVisit> visits) {
    unawaited(
      HydratedBloc.storage.write(_key(forumChannelId), {
        'posts': [
          for (final visit in visits)
            {
              'id': visit.postId,
              'name': visit.name,
              'ts': visit.visitedAt.millisecondsSinceEpoch,
            },
        ],
      }),
    );
    // Deferred: the post screen records its visit from `initState`, which runs
    // inside the frame that builds the pushed route - notifying synchronously
    // there marks the sidebar underneath dirty mid-build. A microtask runs
    // once the frame's synchronous work is done, which is late enough.
    scheduleMicrotask(() => revision.value++);
  }
}
