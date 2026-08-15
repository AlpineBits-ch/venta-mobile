import 'package:flutter/foundation.dart';

import 'models/entitlement_degradation_dto.dart';

/// One reduction, with when it happened and what the app was doing.
@immutable
class ObservedDegradation {
  const ObservedDegradation({
    required this.degradation,
    required this.observedAt,
    this.surface,
  });

  final EntitlementDegradationDto degradation;

  /// Local time. Rendered relatively - "a plan limit applied 20 minutes ago" is
  /// a fact somebody can place; an ISO timestamp is not.
  final DateTime observedAt;

  /// What the user was doing, in their words, or null when this build has no
  /// name for the request that carried it. See [surfaceForPath].
  final String? surface;
}

/// Which part of the app a request path belongs to.
///
/// Deliberately a short table of the paths that can actually reduce today,
/// matched longest-intent-first: a guild voice join is `/guilds/.../voice/join`
/// and matches both the voice rule and the server rule, and it is voice.
///
/// Null for anything unrecognised, which the screen renders as no "where" at
/// all rather than as a guess. A wrong "where" is worse than none: it sends
/// somebody looking at the wrong feature for a limit they hit somewhere else.
String? surfaceForPath(String path) {
  final lower = path.toLowerCase();
  if (lower.contains('/voice/') || lower.endsWith('/voice')) return 'Voice';
  if (lower.contains('/attachments') || lower.contains('/upload')) {
    return 'Uploads';
  }
  if (lower.contains('/emojis')) return 'Custom emoji';
  if (lower.contains('/bots')) return 'Bots';
  if (lower.contains('/audit-log')) return 'Audit log';
  if (lower.contains('/guilds/')) return 'Server settings';
  return null;
}

/// Every reduction this session has seen, newest first.
///
/// **This exists because a degradation cannot be fetched.** It rides the `200`
/// of the request that caused it and nothing else, so there is no endpoint the
/// plan screen could ask "what has been capped lately". Without somewhere to
/// put them, the most useful read-only sentence on that screen - "your video
/// was capped at 720p" - could only ever be shown by the voice UI, in the
/// moment, to somebody who was looking at the right corner of the screen.
///
/// **In memory, and only in memory.** The same rule the entitlements guide
/// applies to snapshots applies here for a sharper reason: a reduction is a
/// statement about one request at one moment, and one read off disk at cold
/// start would be an app claiming a limit applied to something that has not
/// happened yet. A relaunch starting empty is correct.
///
/// Session-scoped, so it is cleared when the account changes: a reduction
/// belongs to whoever made the request, and carrying one across a sign-in would
/// tell the next person about somebody else's plan.
class DegradationLog {
  /// Enough to see a pattern, few enough that a chatty session cannot grow
  /// unboundedly. A voice room that reduces on every publish would otherwise
  /// hold one entry per camera toggle for as long as the app is open.
  static const maxEntries = 20;

  final _entries = ValueNotifier<List<ObservedDegradation>>(
    const <ObservedDegradation>[],
  );

  ValueListenable<List<ObservedDegradation>> get entries => _entries;

  /// Records one, collapsing a repeat of the same limit into the newest.
  ///
  /// Keyed on the entitlement key plus the subject rather than on the whole
  /// object: publishing video four times in one call is one fact about one
  /// plan, and four identical rows would bury the second and third *different*
  /// limits somebody actually wants to see.
  void record(
    EntitlementDegradationDto degradation, {
    String? surface,
    DateTime? at,
  }) {
    final observation = ObservedDegradation(
      degradation: degradation,
      observedAt: at ?? DateTime.now(),
      surface: surface,
    );

    final kept = [
      observation,
      for (final existing in _entries.value)
        if (!_sameLimit(existing.degradation, degradation)) existing,
    ];

    _entries.value = List.unmodifiable(
      kept.length <= maxEntries ? kept : kept.sublist(0, maxEntries),
    );
  }

  /// Drops everything. Called when the signed-in account changes.
  void clear() {
    if (_entries.value.isEmpty) return;
    _entries.value = const <ObservedDegradation>[];
  }

  static bool _sameLimit(
    EntitlementDegradationDto a,
    EntitlementDegradationDto b,
  ) =>
      a.key == b.key &&
      a.subject.kind == b.subject.kind &&
      a.subject.id == b.subject.id;
}
