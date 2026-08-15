import 'dart:async';

import 'package:flutter/foundation.dart';

import 'entitlement_api.dart';
import 'models/entitlement_snapshot_dto.dart';
import 'models/entitlement_value.dart';

/// The catalogue keys this reader is asked for by name, so a caller does not
/// spell one and get a silent null for the rest of the release.
abstract final class EntitlementKeys {
  /// The largest single upload into a server. **Paired**: the effective ceiling
  /// is the lower of the server's and the member's own.
  static const guildUploadMaxBytes = 'storage.upload_max_bytes';

  /// The largest upload where no server is involved.
  static const userUploadMaxBytes = 'user.upload_max_bytes';

  /// Camera and screenshare publish quality. **Paired**, and the one key a
  /// voice room reads off its own snapshot rather than from here - see
  /// `VoiceRoomLimitsDto` for why the room's copy is the one that can change
  /// mid-call.
  static const voiceVideoCeiling = 'voice.video_ceiling';
}

/// One subject's ceilings, held for as long as the server said they may be.
///
/// **In memory only, and never to disk.** A ceiling read at cold start off
/// yesterday's disk would render limits nobody currently has, and "your server
/// was downgraded" is not a sentence to show by accident.
///
/// Session-scoped: cleared when the account changes, because a ceiling belongs
/// to whoever it was resolved for and the cache key alone would not save you
/// from the case where two accounts hold the same guild id.
class EntitlementReader {
  EntitlementReader({required this.api});

  final EntitlementApi api;

  final _entries = <String, _CachedSnapshot>{};

  /// Reads in flight, so a screen that asks three times while the first request
  /// is still out pays for one. Keyed the same way the cache is.
  final _inFlight = <String, Future<EntitlementSnapshotDto?>>{};

  /// This account's own ceilings, or null when they could not be read.
  ///
  /// **Never throws.** Every caller is doing something else and asking this on
  /// the way past: a pre-flight that cannot read a ceiling has to let the
  /// request through and let the server answer, because the alternative is an
  /// app that refuses uploads whenever a lookup fails.
  Future<EntitlementSnapshotDto?> mine() =>
      _read(SubjectKinds.user, '', () => api.getMine());

  /// One server's ceilings, or null. A server the caller is not in answers
  /// `404`, which lands here as null like any other failure - there is nothing
  /// useful a client can do differently with it.
  Future<EntitlementSnapshotDto?> forGuild(String guildId) =>
      _read(SubjectKinds.guild, guildId, () => api.getForGuild(guildId));

  /// The ceiling on one upload, for the place it is going.
  ///
  /// Inside a server the key is paired, so both sides carry it and the
  /// effective ceiling is the lower - which is why this reads both and takes
  /// the minimum rather than trusting the server's copy alone. Outside one
  /// there is only the account's.
  ///
  /// This is a **courtesy, not the enforcement**. The ceiling can move between
  /// this read and the transfer, and the read can fail outright; the server
  /// refuses either way and that refusal is what the call site must still
  /// handle. What this buys is not correctness - it is not spending a 90 MB
  /// upload to be told no.
  Future<EntitlementValueDto?> uploadCeiling({String? guildId}) async {
    if (guildId == null || guildId.isEmpty) {
      final mine = await this.mine();
      return mine?.entitlements[EntitlementKeys.userUploadMaxBytes];
    }

    final results = await Future.wait([mine(), forGuild(guildId)]);
    return _lower(
      results[0]?.entitlements[EntitlementKeys.guildUploadMaxBytes],
      results[1]?.entitlements[EntitlementKeys.guildUploadMaxBytes],
    );
  }

  /// Drops everything. Called when the signed-in account changes.
  void clear() {
    _entries.clear();
    _inFlight.clear();
  }

  Future<EntitlementSnapshotDto?> _read(
    String subjectKind,
    String subjectId,
    Future<EntitlementSnapshotDto> Function() fetch,
  ) {
    final cacheKey = '$subjectKind:$subjectId';
    final held = _entries[cacheKey];
    if (held != null && !held.isStale) return Future.value(held.snapshot);

    final running = _inFlight[cacheKey];
    if (running != null) return running;

    final read = _fetch(cacheKey, subjectKind, subjectId, fetch);
    _inFlight[cacheKey] = read;
    return read.whenComplete(() => _inFlight.remove(cacheKey));
  }

  Future<EntitlementSnapshotDto?> _fetch(
    String cacheKey,
    String subjectKind,
    String subjectId,
    Future<EntitlementSnapshotDto> Function() fetch,
  ) async {
    final EntitlementSnapshotDto snapshot;
    try {
      snapshot = await fetch();
    } catch (e) {
      debugPrint('entitlements for $cacheKey could not be read: $e');
      return null;
    }

    // The subject is checked on arrival rather than assumed from the route. A
    // response that outlived the screen that asked for it gets filed against
    // whatever the app has since switched to otherwise, which is one account's
    // limits shown to another.
    if (!sameSubjectKind(snapshot.subject.kind, subjectKind) ||
        (subjectId.isNotEmpty && snapshot.subject.id != subjectId)) {
      return null;
    }

    // And against what is already held: delivery is not ordered, so a slow
    // response can arrive after a newer one and would otherwise overwrite it.
    final held = _entries[cacheKey];
    if (held != null && snapshot.version < held.snapshot.version) {
      return held.snapshot;
    }

    _entries[cacheKey] = _CachedSnapshot(snapshot: snapshot, at: DateTime.now());
    return snapshot;
  }

  /// The lower of two ceilings, treating "no ceiling" as the larger and an
  /// absent or unreadable one as no answer at all.
  ///
  /// Unlimited is not infinity dressed as a number here - it is a value with no
  /// number in it - so it can only win by being the only side present. That is
  /// the right way round: a paired key where one side is unlimited resolves to
  /// the other side's number.
  static EntitlementValueDto? _lower(
    EntitlementValueDto? left,
    EntitlementValueDto? right,
  ) {
    final a = _bytesOf(left);
    final b = _bytesOf(right);
    if (a == null) return b == null ? (left ?? right) : right;
    if (b == null) return left;
    return a <= b ? left : right;
  }

  /// The number on a numeric ceiling, or null for unlimited, unreadable, or a
  /// kind that is not a number.
  static int? _bytesOf(EntitlementValueDto? value) {
    if (value == null) return null;
    if (value.kind != EntitlementValueKind.numeric) return null;
    if (value.unlimited) return null;
    return value.value;
  }
}

class _CachedSnapshot {
  _CachedSnapshot({required this.snapshot, required this.at});

  final EntitlementSnapshotDto snapshot;
  final DateTime at;

  bool get isStale =>
      DateTime.now().difference(at) >= Duration(seconds: snapshot.ttlSeconds);
}
