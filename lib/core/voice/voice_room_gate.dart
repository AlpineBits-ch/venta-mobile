import 'dart:async';

import 'package:flutter/foundation.dart';

import 'voice_room_version.dart';
import 'voice_snapshot_dto.dart';

/// The version gate for one client's active voice room.
///
/// Every voice event carries `instanceId` and `version`. A client that ignores
/// them will eventually show a stale roster forever, because a dropped event
/// is otherwise indistinguishable from no event and nothing ever repeats it.
/// This is the single place that decides, for both room kinds, whether an
/// event may be applied - and refetches the snapshot when it may not.
///
/// It sits in the repository rather than in a cubit deliberately: the
/// repository is the one component that sees every raw payload, so a cubit
/// cannot forget to check, and the refetch-and-adopt path is written once.
class VoiceRoomGate {
  VoiceRoomGate({required this.fetchSnapshot, required this.onSnapshot});

  /// Fetches the authoritative state of the room the gate is currently on.
  final Future<VoiceRoomSnapshotDto> Function(String roomId) fetchSnapshot;

  /// Delivers a snapshot the gate fetched on its own initiative. Callers apply
  /// it wholesale - snapshots are never merged.
  final void Function(VoiceRoomSnapshotDto snapshot) onSnapshot;

  final VoiceRoomVersionTracker _tracker = VoiceRoomVersionTracker();
  String? _roomId;

  /// Guards against a burst of gapped events each firing its own refetch.
  bool _refetchInFlight = false;

  String? get roomId => _roomId;
  String? get instanceId => _tracker.instanceId;
  int get version => _tracker.version;

  /// Starts tracking [roomId] with no baseline, so the first event forces a
  /// snapshot fetch unless a snapshot arrives first.
  void enterRoom(String roomId) {
    _roomId = roomId;
    _tracker.reset();
  }

  void leaveRoom() {
    _roomId = null;
    _tracker.reset();
  }

  /// Adopts an authoritative snapshot. An empty `instanceId` means the server
  /// answered for a room it does not actually have, and must not become a
  /// baseline - a client that stored it would believe it was in sync with a
  /// room that is gone.
  void adopt(VoiceRoomSnapshotDto snapshot) {
    if (snapshot.instanceId.isEmpty) return;
    if (_roomId != null && snapshot.roomId != _roomId) return;
    _tracker.adoptSnapshot(
      instanceId: snapshot.instanceId,
      version: snapshot.version,
    );
  }

  /// Whether an event for [roomId] carrying this envelope may be applied.
  ///
  /// Returns false for an event that is strictly older than what is held and
  /// for a gap - the latter also schedules a snapshot refetch, so one dropped
  /// event costs one round trip rather than the rest of the session.
  ///
  /// [isRelay] marks the two events the server does not store and does not
  /// bump the version for. They are applied without advancing the baseline;
  /// see [VoiceRoomVersionTracker].
  bool admit(
    String? roomId,
    Map<String, dynamic> payload, {
    bool isRelay = false,
  }) {
    // Events about a room this client is not in are guild-wide presence, not
    // room state, and are not versioned against anything here.
    if (_roomId == null || roomId != _roomId) return true;

    final verdict = _tracker.evaluate(
      instanceId: payload['instanceId'] as String?,
      version: (payload['version'] as num?)?.toInt(),
      isRelay: isRelay,
    );

    switch (verdict) {
      case VoiceEventVerdict.apply:
        return true;
      case VoiceEventVerdict.ignore:
        return false;
      case VoiceEventVerdict.refetch:
        unawaited(refetch());
        return false;
    }
  }

  /// Fetches and adopts the snapshot for the current room, handing it to
  /// [onSnapshot]. Safe to call from anywhere - concurrent calls collapse into
  /// the one already running.
  Future<void> refetch() async {
    final roomId = _roomId;
    if (roomId == null || _refetchInFlight) return;
    _refetchInFlight = true;
    try {
      final snapshot = await fetchSnapshot(roomId);
      // The room may have changed under us while the request was in flight.
      if (_roomId != roomId) return;
      adopt(snapshot);
      onSnapshot(snapshot);
    } catch (e) {
      debugPrint('[Voice] snapshot refetch failed for $roomId: $e');
    } finally {
      _refetchInFlight = false;
    }
  }
}
