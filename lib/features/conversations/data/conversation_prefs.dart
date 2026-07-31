import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

/// The per-conversation preferences the DM long-press sheet offers that the
/// server has no concept of: pinning a DM to the top of Home, muting it, and
/// clearing its unread badge by hand.
///
/// Purely local, and necessarily so - `ConversationDto` carries no
/// `pinned`/`muted` field and there is no per-conversation read-ack endpoint
/// (Alpine marks channels read client-side too; see `GuildDetailScreen`'s
/// `_markChannelRead`). Piggybacks on `HydratedBloc.storage` for the same
/// reason `RoutePersistence` and `ForumVisits` do.
///
/// Static rather than injected because the DM list reads all of this from
/// `build` and isn't bloc-backed for any of it; [revision] is what makes
/// those reads reactive.
abstract final class ConversationPrefs {
  /// Bumped on every change, so widgets built off these reads can rebuild
  /// without any of this having to be a bloc.
  static final ValueNotifier<int> revision = ValueNotifier(0);

  static const _pinnedKey = 'conversation_pinned';
  static const _mutedKey = 'conversation_muted';
  static const _dismissedKey = 'conversation_dismissed_mentions';

  static bool isPinned(String conversationId) =>
      _ids(_pinnedKey).contains(conversationId);

  static bool isMuted(String conversationId) =>
      _ids(_mutedKey).contains(conversationId);

  static void togglePinned(String conversationId) =>
      _toggleId(_pinnedKey, conversationId);

  static void toggleMuted(String conversationId) =>
      _toggleId(_mutedKey, conversationId);

  /// The unread badge the DM list should actually draw, given the server's
  /// [mentionCount].
  ///
  /// "Mark as read" records the count it dismissed rather than a bare flag, so
  /// the *next* mention still comes through instead of the conversation going
  /// quiet forever.
  static int visibleMentionCount(String conversationId, int mentionCount) {
    final dismissed = _dismissed()[conversationId] ?? 0;
    return mentionCount > dismissed ? mentionCount : 0;
  }

  static void markRead(String conversationId, int mentionCount) {
    if (mentionCount <= 0) return;
    _writeDismissed({..._dismissed(), conversationId: mentionCount});
  }

  /// Drops dismissal records the server has since moved past - the DM was read
  /// on another device (count back to 0), or new mentions pushed it above what
  /// was dismissed here. Without this, a conversation read elsewhere would keep
  /// swallowing badges up to the count last dismissed on this device.
  ///
  /// Takes conversation id -> the server's mention count for this user. Call it
  /// from a listener, never from `build` - it writes.
  static void reconcile(Map<String, int> serverMentionCounts) {
    final dismissed = _dismissed();
    final kept = {
      for (final entry in dismissed.entries)
        if (serverMentionCounts[entry.key] == entry.value)
          entry.key: entry.value,
    };
    // `kept` is a subset, so equal length means nothing was dropped - bail out
    // rather than write (and bump [revision]) on every list refresh.
    if (kept.length == dismissed.length) return;
    _writeDismissed(kept);
  }

  /// Forgets everything remembered about a conversation that no longer exists,
  /// so a closed DM doesn't leave a pinned/muted entry behind for an id that
  /// can never come back.
  static void forget(String conversationId) {
    _removeId(_pinnedKey, conversationId);
    _removeId(_mutedKey, conversationId);
    final dismissed = _dismissed();
    if (dismissed.containsKey(conversationId)) {
      _writeDismissed({...dismissed}..remove(conversationId));
    }
  }

  static Set<String> _ids(String key) {
    final raw = HydratedBloc.storage.read(key);
    final ids = raw is Map ? raw['ids'] : null;
    if (ids is! List) return const {};
    return {
      for (final id in ids)
        if (id is String) id,
    };
  }

  static void _toggleId(String key, String conversationId) {
    final ids = {..._ids(key)};
    if (!ids.remove(conversationId)) ids.add(conversationId);
    _write(key, {'ids': ids.toList()});
  }

  static void _removeId(String key, String conversationId) {
    final ids = {..._ids(key)};
    if (!ids.remove(conversationId)) return;
    _write(key, {'ids': ids.toList()});
  }

  static Map<String, int> _dismissed() {
    final raw = HydratedBloc.storage.read(_dismissedKey);
    final counts = raw is Map ? raw['counts'] : null;
    if (counts is! Map) return const {};
    return {
      for (final entry in counts.entries)
        if (entry.key is String && entry.value is int)
          entry.key as String: entry.value as int,
    };
  }

  static void _writeDismissed(Map<String, int> counts) =>
      _write(_dismissedKey, {'counts': counts});

  static void _write(String key, Map<String, Object?> value) {
    unawaited(HydratedBloc.storage.write(key, value));
    // Deferred for the same reason `ForumVisits` defers: [reconcile] runs from
    // a bloc listener, and notifying synchronously there marks the list that is
    // still mid-frame dirty.
    scheduleMicrotask(() => revision.value++);
  }
}
