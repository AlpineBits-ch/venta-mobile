import 'dart:async';

import '../../../core/realtime/realtime_event.dart';
import '../../../core/realtime/realtime_service.dart';
import '../../../core/realtime/realtime_transport.dart';
import '../../../core/voice/voice_heartbeat.dart';
import '../../../core/voice/voice_room_gate.dart';
import '../../../core/voice/voice_snapshot_dto.dart';
import 'guild_voice_api.dart';
import 'models/guild_voice_activity_dto.dart';

sealed class GuildVoiceEvent {
  const GuildVoiceEvent();
}

/// The authoritative state of one channel. Applied wholesale - never merged.
class VoiceSnapshotReceived extends GuildVoiceEvent {
  const VoiceSnapshotReceived(this.snapshot);
  final VoiceRoomSnapshotDto snapshot;

  String get channelId => snapshot.roomId;
}

/// "Refetch, you are behind." [reason] is `roomGone`, `participantLeft` or
/// `peerPublishChanged`. Only `roomGone` needs handling beyond the refetch the
/// repository has already started - the room is gone, and rejoining has to go
/// back through the authorised join path rather than being re-asserted by the
/// client.
class VoiceResyncRequested extends GuildVoiceEvent {
  const VoiceResyncRequested({
    required this.channelId,
    required this.reason,
    this.userId,
  });
  final String channelId;
  final String reason;
  final String? userId;

  bool get isRoomGone => reason == 'roomGone';
}

/// Guild-wide presence: someone entered/left a channel's roster. Sent to every
/// member of the guild, not just the room, so the channel list can show who is
/// in voice. Deliberately *not* room state - it carries no media handles and
/// is not version-gated.
class UserJoinedVoiceChannel extends GuildVoiceEvent {
  const UserJoinedVoiceChannel({
    required this.userId,
    required this.channelId,
    required this.guildId,
  });
  final String userId;
  final String channelId;
  final String guildId;
}

class UserLeftVoiceChannel extends GuildVoiceEvent {
  const UserLeftVoiceChannel({
    required this.userId,
    required this.channelId,
    required this.guildId,
  });
  final String userId;
  final String channelId;
  final String guildId;
}

/// This user is now **pullable** - their session and microphone track both
/// exist. Never sent for someone who has merely opened a session.
class VoiceParticipantJoined extends GuildVoiceEvent {
  const VoiceParticipantJoined({
    required this.userId,
    required this.channelId,
    required this.mediaSessionId,
    required this.audioTrackName,
  });
  final String userId;
  final String channelId;
  final String mediaSessionId;
  final String audioTrackName;
}

/// A camera or screen track appeared. [shareId] groups the two halves of one
/// screen share and is null for a camera.
class VoiceTrackPublished extends GuildVoiceEvent {
  const VoiceTrackPublished({
    required this.userId,
    required this.channelId,
    required this.mediaSessionId,
    required this.trackName,
    required this.kind,
    this.shareId,
  });
  final String userId;
  final String channelId;
  final String mediaSessionId;
  final String trackName;
  final String kind;
  final String? shareId;
}

class VoiceTrackClosed extends GuildVoiceEvent {
  const VoiceTrackClosed({
    required this.userId,
    required this.channelId,
    required this.trackName,
    this.shareId,
  });
  final String userId;
  final String channelId;
  final String trackName;
  final String? shareId;
}

class VoiceMuteChanged extends GuildVoiceEvent {
  const VoiceMuteChanged({
    required this.userId,
    required this.channelId,
    required this.isMuted,
    required this.serverForced,
  });
  final String userId;
  final String channelId;
  final bool isMuted;

  /// True when a moderator did it, rather than the participant themselves.
  final bool serverForced;
}

/// Deafen implies mute one-way: a `true` deafen should force the participant's
/// muted badge on too, but `false` does not auto-unmute.
class VoiceDeafenChanged extends GuildVoiceEvent {
  const VoiceDeafenChanged({
    required this.userId,
    required this.channelId,
    required this.isDeafened,
    required this.serverForced,
  });
  final String userId;
  final String channelId;
  final bool isDeafened;
  final bool serverForced;
}

class VoiceCameraChanged extends GuildVoiceEvent {
  const VoiceCameraChanged({
    required this.userId,
    required this.channelId,
    required this.isCameraOn,
  });
  final String userId;
  final String channelId;
  final bool isCameraOn;
}

/// Relay only, high frequency - render it, never persist it.
class VoiceSpeakingChanged extends GuildVoiceEvent {
  const VoiceSpeakingChanged({
    required this.userId,
    required this.channelId,
    required this.isSpeaking,
  });
  final String userId;
  final String channelId;
  final bool isSpeaking;
}

class VoiceScreenShareStarted extends GuildVoiceEvent {
  const VoiceScreenShareStarted({
    required this.userId,
    required this.channelId,
    required this.shareId,
  });
  final String userId;
  final String channelId;
  final String shareId;
}

class VoiceScreenShareStopped extends GuildVoiceEvent {
  const VoiceScreenShareStopped({
    required this.userId,
    required this.channelId,
    required this.shareId,
  });
  final String userId;
  final String channelId;
  final String shareId;
}

/// Who is currently watching one screen share.
class VoiceShareViewersChanged extends GuildVoiceEvent {
  const VoiceShareViewersChanged({
    required this.channelId,
    required this.shareId,
    required this.viewerCount,
    required this.viewerIds,
  });
  final String channelId;
  final String shareId;
  final int viewerCount;
  final List<String> viewerIds;
}

/// A moderator moved the local user to a different channel.
class VoiceMovedToChannel extends GuildVoiceEvent {
  const VoiceMovedToChannel({
    required this.channelId,
    required this.guildId,
    required this.movedBy,
  });
  final String channelId;
  final String guildId;
  final String movedBy;
}

/// This device's session in [channelId] was just taken over by another of the
/// user's own devices joining the same channel. Must tear down local
/// WebRTC/audio without calling leave - the server already removed it.
class VoiceKickedByOtherDevice extends GuildVoiceEvent {
  const VoiceKickedByOtherDevice({
    required this.channelId,
    required this.guildId,
  });
  final String channelId;
  final String guildId;
}

/// App-lifetime singleton - voice rosters for every voice channel in every
/// guild the user can see need to stay live even when no voice screen is
/// on-screen, so this can't be scoped to one joined channel.
///
/// It also owns the version gate for the channel this client has joined. Every
/// room-state event carries `instanceId` and `version`; out-of-order events are
/// dropped here and a gap triggers a snapshot refetch, so the cubit only ever
/// sees events it can safely apply. Guild-wide presence
/// (`UserJoinedVoice`/`UserLeftVoice`) is not room state and passes through
/// ungated - it is about channels this client is not in.
class GuildVoiceRepository {
  GuildVoiceRepository({
    required this.api,
    required RealtimeService realtimeService,
  }) : _realtimeService = realtimeService {
    _gate = VoiceRoomGate(
      fetchSnapshot: (channelId) {
        final guildId = _activeGuildId;
        if (guildId == null) {
          throw StateError('No active guild voice channel to snapshot.');
        }
        return api.getSnapshot(guildId, channelId);
      },
      onSnapshot: (snapshot) =>
          _eventsController.add(VoiceSnapshotReceived(snapshot)),
    );
    _realtimeSub = realtimeService.events
        .where((e) => e.name.startsWith('guild.voice.'))
        .listen(_handleRealtimeEvent);
  }

  final GuildVoiceApi api;
  final RealtimeService _realtimeService;
  late final StreamSubscription<RealtimeEvent> _realtimeSub;
  late final VoiceRoomGate _gate;
  String? _activeGuildId;

  final _eventsController = StreamController<GuildVoiceEvent>.broadcast();
  Stream<GuildVoiceEvent> get events => _eventsController.stream;

  /// A reconnect is the signal that events broadcast during the gap were
  /// dropped - SignalR does not queue undelivered messages.
  Stream<RealtimeConnectionStatus> get connectionStatus =>
      _realtimeService.connectionStatus;

  String? get knownInstanceId => _gate.instanceId;
  int get knownVersion => _gate.version;

  void enterChannel({required String guildId, required String channelId}) {
    _activeGuildId = guildId;
    _gate.enterRoom(channelId);
  }

  void exitChannel() {
    _activeGuildId = null;
    _gate.leaveRoom();
  }

  void adoptSnapshot(VoiceRoomSnapshotDto snapshot) => _gate.adopt(snapshot);

  Future<void> refetchSnapshot() => _gate.refetch();

  void _handleRealtimeEvent(RealtimeEvent event) {
    final payload = event.objectPayload;
    final channelId = payload['channelId'] as String?;

    // Guild-wide presence describes channels this client is not in, so it is
    // never version-gated - the gate would have no baseline for those rooms
    // and would refetch a snapshot per event.
    //
    // `Snapshot` and `Resync` are exempt for a different reason: they are the
    // recovery channel rather than deltas on it. `Resync(roomGone)` is
    // deliberately sent with a blank instance and version 0, which every
    // branch of the gate reads as "you are out of date" - so gating it would
    // swallow the one event that says the room no longer exists, and answer it
    // with a refetch of a room that is gone.
    const ungated = {
      'guild.voice.UserJoinedVoice',
      'guild.voice.UserLeftVoice',
      'guild.voice.Snapshot',
      'guild.voice.Resync',
    };
    // Relays carry the current version without being a change to it - the
    // server neither stores them nor bumps the version for them. Letting one
    // advance the baseline would have it stand in for a state change that was
    // actually missed, and the next real event would look contiguous.
    const relays = {'guild.voice.SpeakingChanged', 'guild.voice.CameraChanged'};

    if (!ungated.contains(event.name) &&
        !_gate.admit(
          channelId,
          payload,
          isRelay: relays.contains(event.name),
        )) {
      return;
    }

    switch (event.name) {
      case 'guild.voice.Snapshot':
        final snapshot = VoiceRoomSnapshotDto.fromJson(payload);
        _gate.adopt(snapshot);
        _eventsController.add(VoiceSnapshotReceived(snapshot));
      case 'guild.voice.Resync':
        final reason = payload['reason'] as String? ?? '';
        _eventsController.add(
          VoiceResyncRequested(
            channelId: channelId ?? '',
            reason: reason,
            userId: payload['userId'] as String?,
          ),
        );
        if (reason != 'roomGone') unawaited(_gate.refetch());
      case 'guild.voice.UserJoinedVoice':
        _eventsController.add(
          UserJoinedVoiceChannel(
            userId: payload['userId'] as String,
            channelId: payload['channelId'] as String,
            guildId: payload['guildId'] as String,
          ),
        );
      case 'guild.voice.UserLeftVoice':
        _eventsController.add(
          UserLeftVoiceChannel(
            userId: payload['userId'] as String,
            channelId: payload['channelId'] as String,
            guildId: payload['guildId'] as String,
          ),
        );
      case 'guild.voice.ParticipantJoined':
        _eventsController.add(
          VoiceParticipantJoined(
            userId: payload['userId'] as String,
            channelId: payload['channelId'] as String,
            mediaSessionId: payload['mediaSessionId'] as String,
            audioTrackName: payload['audioTrackName'] as String,
          ),
        );
      case 'guild.voice.TrackPublished':
        _eventsController.add(
          VoiceTrackPublished(
            userId: payload['userId'] as String,
            channelId: payload['channelId'] as String,
            mediaSessionId: payload['mediaSessionId'] as String,
            trackName: payload['trackName'] as String,
            kind: payload['kind'] as String,
            shareId: payload['shareId'] as String?,
          ),
        );
      case 'guild.voice.TrackClosed':
        _eventsController.add(
          VoiceTrackClosed(
            userId: payload['userId'] as String,
            channelId: payload['channelId'] as String,
            trackName: payload['trackName'] as String,
            shareId: payload['shareId'] as String?,
          ),
        );
      case 'guild.voice.MuteChanged':
        _eventsController.add(
          VoiceMuteChanged(
            userId: payload['userId'] as String,
            channelId: payload['channelId'] as String,
            isMuted: payload['isMuted'] as bool,
            serverForced: payload['serverForced'] as bool? ?? false,
          ),
        );
      case 'guild.voice.DeafenChanged':
        _eventsController.add(
          VoiceDeafenChanged(
            userId: payload['userId'] as String,
            channelId: payload['channelId'] as String,
            isDeafened: payload['isDeafened'] as bool,
            serverForced: payload['serverForced'] as bool? ?? false,
          ),
        );
      case 'guild.voice.CameraChanged':
        _eventsController.add(
          VoiceCameraChanged(
            userId: payload['userId'] as String,
            channelId: payload['channelId'] as String,
            isCameraOn: payload['isCameraOn'] as bool,
          ),
        );
      case 'guild.voice.SpeakingChanged':
        _eventsController.add(
          VoiceSpeakingChanged(
            userId: payload['userId'] as String,
            channelId: payload['channelId'] as String,
            isSpeaking: payload['isSpeaking'] as bool? ?? false,
          ),
        );
      case 'guild.voice.ScreenShareStarted':
        _eventsController.add(
          VoiceScreenShareStarted(
            userId: payload['userId'] as String,
            channelId: payload['channelId'] as String,
            shareId: payload['shareId'] as String,
          ),
        );
      case 'guild.voice.ScreenShareStopped':
        _eventsController.add(
          VoiceScreenShareStopped(
            userId: payload['userId'] as String,
            channelId: payload['channelId'] as String,
            shareId: payload['shareId'] as String,
          ),
        );
      case 'guild.voice.ShareViewersChanged':
        _eventsController.add(
          VoiceShareViewersChanged(
            channelId: channelId ?? '',
            shareId: payload['shareId'] as String,
            viewerCount: (payload['viewerCount'] as num?)?.toInt() ?? 0,
            viewerIds: (payload['viewerIds'] as List? ?? const [])
                .cast<String>(),
          ),
        );
      case 'guild.voice.MovedToChannel':
        _eventsController.add(
          VoiceMovedToChannel(
            channelId: payload['channelId'] as String,
            guildId: payload['guildId'] as String,
            movedBy: payload['movedBy'] as String,
          ),
        );
      case 'guild.voice.KickedByOtherDevice':
        _eventsController.add(
          VoiceKickedByOtherDevice(
            channelId: payload['channelId'] as String,
            guildId: payload['guildId'] as String,
          ),
        );
    }
  }

  // ── REST ──────────────────────────────────────────────────────────────────

  Future<VoiceRoomSnapshotDto> join(String guildId, String channelId) =>
      api.join(guildId, channelId);

  Future<void> leave(String guildId, String channelId) =>
      api.leave(guildId, channelId);

  /// Roster read for a channel the user has not joined - the same snapshot,
  /// which is safe because it withholds media handles for anyone not actually
  /// publishing.
  Future<VoiceRoomSnapshotDto> getSnapshot(String guildId, String channelId) =>
      api.getSnapshot(guildId, channelId);

  /// Voice occupancy across every guild this user is a member of - see
  /// [GuildVoiceApi.getVoiceActivity].
  Future<List<GuildVoiceActivityDto>> getVoiceActivity() =>
      api.getVoiceActivity();

  Future<void> watchShare({
    required String guildId,
    required String channelId,
    required String shareId,
  }) => api.watchShare(guildId, channelId, shareId);

  Future<void> unwatchShare({
    required String guildId,
    required String channelId,
    required String shareId,
  }) => api.unwatchShare(guildId, channelId, shareId);

  // ── Hub invocations ───────────────────────────────────────────────────────

  /// The state-asserting heartbeat, the same call a 1:1 call makes with
  /// `roomKind: "call"`. Not just a keepalive - see [VoiceHeartbeat].
  Future<void> invokeHeartbeat({
    required String channelId,
    required VoiceHeartbeatState state,
  }) => _realtimeService.invoke(
    'voice.Heartbeat',
    args: [VoiceRoomKind.channel, channelId, state.toJson()],
  );

  Future<void> invokeMuteChanged({
    required String channelId,
    required bool isMuted,
  }) => _realtimeService.invoke(
    'guild.voice.MuteChanged',
    args: [
      {'channelId': channelId, 'isMuted': isMuted},
    ],
  );

  Future<void> invokeDeafenChanged({
    required String channelId,
    required bool isDeafened,
  }) => _realtimeService.invoke(
    'guild.voice.DeafenChanged',
    args: [
      {'channelId': channelId, 'isDeafened': isDeafened},
    ],
  );

  Future<void> invokeCameraChanged({
    required String channelId,
    required bool isCameraOn,
  }) => _realtimeService.invoke(
    'guild.voice.CameraChanged',
    args: [
      {'channelId': channelId, 'isCameraOn': isCameraOn},
    ],
  );

  /// Announces the share. The track name is not sent: the server derives both
  /// halves from the `shareId` and the naming convention, and a client-supplied
  /// name could disagree with what was actually published.
  Future<void> invokeScreenShareStarted({
    required String channelId,
    required String shareId,
  }) => _realtimeService.invoke(
    'guild.voice.ScreenShareStarted',
    args: [
      {'channelId': channelId, 'shareId': shareId},
    ],
  );

  Future<void> invokeScreenShareStopped({
    required String channelId,
    required String shareId,
  }) => _realtimeService.invoke(
    'guild.voice.ScreenShareStopped',
    args: [
      {'channelId': channelId, 'shareId': shareId},
    ],
  );

  /// Moderation. The server checks the permission and overwrites the acting
  /// user from the connection, so these can only ever name a *target*.
  Future<void> invokeServerMute({
    required String channelId,
    required String targetUserId,
    required bool isMuted,
  }) => _realtimeService.invoke(
    'guild.voice.ServerMute',
    args: [
      {
        'channelId': channelId,
        'targetUserId': targetUserId,
        'isMuted': isMuted,
      },
    ],
  );

  Future<void> invokeServerDeafen({
    required String channelId,
    required String targetUserId,
    required bool isDeafened,
  }) => _realtimeService.invoke(
    'guild.voice.ServerDeafen',
    args: [
      {
        'channelId': channelId,
        'targetUserId': targetUserId,
        'isDeafened': isDeafened,
      },
    ],
  );

  Future<void> invokeMoveUser({
    required String channelId,
    required String targetUserId,
    required String targetChannelId,
  }) => _realtimeService.invoke(
    'guild.voice.MoveUser',
    args: [
      {
        'channelId': channelId,
        'targetUserId': targetUserId,
        'targetChannelId': targetChannelId,
      },
    ],
  );

  void dispose() {
    _realtimeSub.cancel();
    _eventsController.close();
  }
}
