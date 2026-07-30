import 'dart:async';

import '../../../core/device/device_id_service.dart';
import '../../../core/realtime/realtime_event.dart';
import '../../../core/realtime/realtime_service.dart';
import 'guild_voice_api.dart';
import 'models/guild_voice_dto.dart';

sealed class GuildVoiceEvent {
  const GuildVoiceEvent();
}

/// Presence-only: someone entered/left a channel's roster. Drives the
/// inline participant list shown under every voice channel in the sidebar,
/// including channels the local user hasn't joined.
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

/// CF-Calls-specific: a participant now has a [cfSessionId]/[audioTrackName]
/// to subscribe to.
class VoiceParticipantJoined extends GuildVoiceEvent {
  const VoiceParticipantJoined({
    required this.userId,
    required this.channelId,
    required this.cfSessionId,
    required this.audioTrackName,
  });
  final String userId;
  final String channelId;
  final String cfSessionId;
  final String audioTrackName;
}

/// A remote participant published a new track. `kind` is video/screen/
/// screenAudio - not acted on in this audio-only v1, but still surfaced so
/// callers can show a badge (e.g. "streaming") without subscribing to it.
class VoiceTrackPublished extends GuildVoiceEvent {
  const VoiceTrackPublished({
    required this.userId,
    required this.channelId,
    required this.cfSessionId,
    required this.trackName,
    required this.kind,
    this.shareId,
  });
  final String userId;
  final String channelId;
  final String cfSessionId;
  final String trackName;
  final String kind;
  final String? shareId;
}

class VoiceTrackClosed extends GuildVoiceEvent {
  const VoiceTrackClosed({
    required this.userId,
    required this.channelId,
    required this.trackName,
  });
  final String userId;
  final String channelId;
  final String trackName;
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
  final bool serverForced;
}

/// Deafen implies mute one-way: a `true` deafen event should force the
/// participant's muted badge on too, but `false` does not auto-unmute -
/// mirrors Alpine's `onDeafenChanged` handling.
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

class VoiceScreenShareStarted extends GuildVoiceEvent {
  const VoiceScreenShareStarted({
    required this.userId,
    required this.channelId,
    required this.shareId,
    required this.trackName,
  });
  final String userId;
  final String channelId;
  final String shareId;
  final String trackName;
}

/// Client-side is a no-op beyond clearing the streaming badge - the actual
/// track teardown rides on [VoiceTrackClosed], same as Alpine.
class VoiceScreenShareStopped extends GuildVoiceEvent {
  const VoiceScreenShareStopped({
    required this.channelId,
    required this.shareId,
  });
  final String channelId;
  final String shareId;
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

/// This device's session in [channelId] was just taken over by another of
/// the user's own devices joining the same channel. Must tear down local
/// WebRTC/audio without calling leave - the server already removed it.
class VoiceKickedByOtherDevice extends GuildVoiceEvent {
  const VoiceKickedByOtherDevice({
    required this.channelId,
    required this.guildId,
  });
  final String channelId;
  final String guildId;
}

/// App-lifetime singleton (like `GuildRepository`/`VoiceRepository`) - voice
/// rosters for every voice channel in every guild the user can see need to
/// stay live even when no voice screen is on-screen, so this can't be scoped
/// to one joined channel.
class GuildVoiceRepository {
  GuildVoiceRepository({
    required this.api,
    required RealtimeService realtimeService,
    required DeviceIdService deviceIdService,
  }) : _realtimeService = realtimeService,
       _deviceIdService = deviceIdService {
    _realtimeSub = realtimeService.events
        .where((e) => e.name.startsWith('guild.voice.'))
        .listen(_handleRealtimeEvent);
  }

  final GuildVoiceApi api;
  final RealtimeService _realtimeService;
  final DeviceIdService _deviceIdService;
  late final StreamSubscription<RealtimeEvent> _realtimeSub;

  final _eventsController = StreamController<GuildVoiceEvent>.broadcast();
  Stream<GuildVoiceEvent> get events => _eventsController.stream;

  void _handleRealtimeEvent(RealtimeEvent event) {
    final payload = event.objectPayload;
    switch (event.name) {
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
            cfSessionId: payload['cfSessionId'] as String,
            audioTrackName: payload['audioTrackName'] as String,
          ),
        );
      case 'guild.voice.TrackPublished':
        _eventsController.add(
          VoiceTrackPublished(
            userId: payload['userId'] as String,
            channelId: payload['channelId'] as String,
            cfSessionId: payload['cfSessionId'] as String,
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
      case 'guild.voice.ScreenShareStarted':
        _eventsController.add(
          VoiceScreenShareStarted(
            userId: payload['userId'] as String,
            channelId: payload['channelId'] as String,
            shareId: payload['shareId'] as String,
            trackName: payload['trackName'] as String,
          ),
        );
      case 'guild.voice.ScreenShareStopped':
        _eventsController.add(
          VoiceScreenShareStopped(
            channelId: payload['channelId'] as String,
            shareId: payload['shareId'] as String,
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

  Future<VoiceStateDto> join(String guildId, String channelId) =>
      api.join(guildId, channelId, deviceId: _deviceIdService.deviceId);

  Future<void> leave(String guildId, String channelId) =>
      api.leave(guildId, channelId, deviceId: _deviceIdService.deviceId);

  Future<VoiceStateDto> getState(String guildId, String channelId) =>
      api.getState(guildId, channelId);

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

  Future<void> invokeScreenShareStarted({
    required String channelId,
    required String shareId,
    required String trackName,
  }) => _realtimeService.invoke(
    'guild.voice.ScreenShareStarted',
    args: [
      {'channelId': channelId, 'shareId': shareId, 'trackName': trackName},
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

  Future<void> invokeHeartbeat() =>
      _realtimeService.invoke('guild.voice.Heartbeat');

  void dispose() {
    _realtimeSub.cancel();
    _eventsController.close();
  }
}
