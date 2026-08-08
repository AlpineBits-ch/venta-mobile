import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../features/mls/data/mls_api.dart';
import '../../features/mls/data/models/mls_dtos.dart';
import 'mls_service.dart';
import 'mls_sync_service.dart';

/// What a coverage answer means for the screen, with the local cross-check
/// already applied.
///
/// Built here rather than in the widgets so the three situations stay apart.
/// Collapsing them into one warning is the main way this feature can be made
/// worse than the silence it replaces: only [lockedOutHere] has an action, only
/// the device in hand can ask, and the other two are reference material for
/// somebody who went looking.
@immutable
class DeviceCoverageView {
  const DeviceCoverageView({
    required this.encrypted,
    required this.unavailable,
    required this.lockedOutHere,
    required this.otherOwnDevices,
    required this.peerDevices,
  });

  static const nothing = DeviceCoverageView(
    encrypted: false,
    unavailable: false,
    lockedOutHere: false,
    otherOwnDevices: <MlsDeviceCoverageDto>[],
    peerDevices: <UnreachableDeviceDto>[],
  );

  /// False renders nothing at all. There is no live group, so there is nothing
  /// to be outside of.
  final bool encrypted;

  /// The lists could not be read. They are empty because nothing could be
  /// looked up, so nothing here may be shown as an all-clear and nothing
  /// already displayed may be cleared on the strength of it.
  final bool unavailable;

  /// The device in hand cannot read this context, confirmed against local group
  /// state. The only case with a primary action, because it is the only device
  /// that can ask.
  final bool lockedOutHere;

  /// Other devices of this account that hold no leaf. Nothing here is
  /// actionable from this device - the stranded one has to ask for itself.
  final List<MlsDeviceCoverageDto> otherOwnDevices;

  /// Other people's devices that hold no leaf. Always empty for a channel.
  final List<UnreachableDeviceDto> peerDevices;

  /// Whether there is any device to name. False keeps the security screen quiet
  /// rather than showing an empty heading.
  bool get hasStrandedDevices =>
      encrypted && (otherOwnDevices.isNotEmpty || peerDevices.isNotEmpty);
}

/// Asks the server which devices can read a context, and turns the answer into
/// something a screen can render without misreading it.
///
/// **Not polled.** The answer only changes when the group does, so this is read
/// on the four moments in the client guide - opening an encrypted context, a
/// Welcome or commit landing locally, opening the security screen, and a join
/// request being decided - and cached in between.
///
/// The cache is per `(contextId, generation)`: a device covered in generation 2
/// is not covered in generation 3, so an answer that names a generation this
/// device no longer believes in is not a stale answer but a wrong one.
class MlsCoverageService {
  MlsCoverageService({
    required this.api,
    required this.mls,
    Stream<MlsContextChanged>? contextChanged,
  }) {
    // A Welcome applied or a commit published here changes the answer, and the
    // device that just joined is exactly the one whose notice has to come down
    // without waiting for the next launch.
    _changes = contextChanged?.listen((e) => invalidate(e.contextId));
  }

  final MlsApi api;
  final MlsService mls;

  StreamSubscription<MlsContextChanged>? _changes;

  final _cache = <String, MlsCoverageDto>{};

  /// Coverage for [contextId], from the cache unless [refresh].
  ///
  /// Never throws. A request that fails answers "cannot tell right now" -
  /// whatever was last known, marked [DeviceCoverageView.unavailable] - because
  /// an offline read that cleared a warning would be the silence this exists to
  /// break, dressed up as good news.
  Future<DeviceCoverageView> view(
    String contextId, {
    required bool isChannel,
    bool refresh = false,
  }) async {
    if (!refresh && _cache.containsKey(contextId)) {
      return _viewOf(_cache[contextId]!);
    }

    try {
      final fresh = await api.getCoverage(
        contextId: contextId,
        isChannel: isChannel,
      );
      return _remember(contextId, fresh);
    } catch (e) {
      debugPrint('MLS: could not read device coverage for $contextId: $e');
      final last = _cache[contextId];
      return last == null ? _cannotTell : _viewOf(last, unavailable: true);
    }
  }

  /// The answer this device last got, without asking again. Null when nothing
  /// has been read for the context yet.
  DeviceCoverageView? cached(String contextId) {
    final held = _cache[contextId];
    return held == null ? null : _viewOf(held);
  }

  /// Drops the cached answer. Call it after a join request of this device's is
  /// approved or denied - the verdict that changes is exactly the one cached.
  void invalidate(String contextId) => _cache.remove(contextId);

  /// Drops the cached answer when the live generation has moved on.
  ///
  /// Called wherever the caller already holds a fresh `MlsContextStateDto`, so
  /// the re-key that made every previous verdict wrong costs no extra request
  /// to notice.
  void noteGeneration(String contextId, int? generation) {
    final held = _cache[contextId];
    if (held != null && held.generation != generation) _cache.remove(contextId);
  }

  void dispose() {
    _changes?.cancel();
    _changes = null;
  }

  /// Keeps a fresh answer, unless it is the "could not look anything up" one.
  ///
  /// An unavailable answer carries two empty lists, and storing them over a
  /// known answer would silently retract a warning nobody retracted. It is only
  /// allowed to replace an answer about a *different* generation, which is
  /// wrong rather than merely older.
  DeviceCoverageView _remember(String contextId, MlsCoverageDto fresh) {
    final last = _cache[contextId];
    if (fresh.coverageUnavailable &&
        last != null &&
        last.generation == fresh.generation) {
      return _viewOf(last, unavailable: true);
    }
    _cache[contextId] = fresh;
    return _viewOf(fresh);
  }

  static const _cannotTell = DeviceCoverageView(
    encrypted: false,
    unavailable: true,
    lockedOutHere: false,
    otherOwnDevices: <MlsDeviceCoverageDto>[],
    peerDevices: <UnreachableDeviceDto>[],
  );

  DeviceCoverageView _viewOf(MlsCoverageDto dto, {bool unavailable = false}) {
    final cannotTell = unavailable || dto.coverageUnavailable;
    if (!dto.encrypted) {
      return cannotTell ? _cannotTell : DeviceCoverageView.nothing;
    }

    final here = mls.deviceIdService.deviceIdOrNull;

    return DeviceCoverageView(
      encrypted: true,
      unavailable: cannotTell,
      lockedOutHere: !cannotTell && _lockedOutHere(dto, here),
      // `== false`, never `!covered`: an entry the server did not fill in has
      // no verdict on it, and reading absence as uncovered would name a working
      // device on a screen that exists to be believed.
      otherOwnDevices: dto.ownDevices
          .where((d) => d.covered == false && d.deviceId != here)
          .toList(),
      peerDevices: dto.unreachableDevices,
    );
  }

  /// Whether the device in hand should be offered the repair.
  ///
  /// **Both halves, always.** `covered: false` is evidence and not proof: the
  /// server computes it from a Welcome addressed to the device, a commit
  /// published from it, or the record that it built the group, and a device that
  /// walked back in by external commit left none of those three traces while
  /// decrypting everything perfectly. Telling that device it cannot read the
  /// conversation it is currently reading is worse than saying nothing.
  ///
  /// The local half is the registry, asked about the generation the server
  /// computed against rather than about the context in general - a device that
  /// held generation 1 and was left out of generation 2 genuinely cannot read
  /// what is being sent now, and `hasEverHeldGroup` would wave that through.
  bool _lockedOutHere(MlsCoverageDto dto, String? here) {
    if (here == null) return false;

    // Absent claims nothing, and neither does an entry with no verdict on it.
    // Only an explicit false is evidence worth crossing against local state.
    final entry = dto.ownDevices.where((d) => d.deviceId == here).firstOrNull;
    if (entry?.covered != false) return false;

    // The generation-specific lookup is the whole point, and it does **not**
    // fall back to the active group when it misses. Letting the keys this
    // device holds for generation 1 vouch for generation 2 is exactly the false
    // negative that ruled out `hasEverHeldGroup`: a device left out of the
    // re-key genuinely cannot read what is being sent now. `activeGroupId` is
    // only reachable when the answer names no generation at all, which is the
    // case where there is no era to ask about.
    final generation = dto.generation;
    final held = generation == null
        ? mls.activeGroupId(dto.contextId)
        : mls.groupId(dto.contextId, generation);
    return held == null;
  }
}
