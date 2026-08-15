import '../../../core/voice/voice_media_api.dart';
import '../../../core/voice/voice_media_dto.dart';
import '../../../core/voice/voice_room_key.dart';
import '../../../core/voice/voice_snapshot_dto.dart';
import 'guild_voice_api.dart';

/// Binds [GuildVoiceApi] to one channel, so `VoiceWebRtcService` drives a
/// guild voice channel through the same code path as a 1:1 call.
class GuildVoiceMediaApi implements VoiceMediaApi {
  GuildVoiceMediaApi({
    required this.api,
    required this.guildId,
    required this.channelId,
  });

  final GuildVoiceApi api;
  final String guildId;
  final String channelId;

  @override
  VoiceRoomKey get roomKey => VoiceRoomKey.channel(channelId);

  @override
  Future<VoiceRoomSnapshotDto> fetchSnapshot() =>
      api.getSnapshot(guildId, channelId);

  @override
  Future<VoiceSessionDto> createSession({bool primary = true}) =>
      api.createSession(guildId, channelId, primary: primary);

  @override
  Future<VoiceNegotiateResponseDto> negotiate({
    required String mediaSessionId,
    required Map<String, dynamic> sessionDescription,
    required List<Map<String, dynamic>> tracks,
    Map<String, dynamic>? video,
  }) => api.negotiate(
    guildId: guildId,
    channelId: channelId,
    mediaSessionId: mediaSessionId,
    sessionDescription: sessionDescription,
    tracks: tracks,
    video: video,
  );

  @override
  Future<VoiceRenegotiateResponseDto> renegotiate({
    required String mediaSessionId,
    required Map<String, dynamic> sessionDescription,
  }) => api.renegotiate(
    guildId: guildId,
    channelId: channelId,
    mediaSessionId: mediaSessionId,
    sessionDescription: sessionDescription,
  );

  @override
  Future<void> closeTracks({
    required String mediaSessionId,
    required List<String> trackNames,
  }) => api.closeTracks(
    guildId: guildId,
    channelId: channelId,
    mediaSessionId: mediaSessionId,
    trackNames: trackNames,
  );

  @override
  Future<void> updateSubscriber({Map<String, int>? tileHeights}) =>
      api.updateSubscriber(
        guildId: guildId,
        channelId: channelId,
        tileHeights: tileHeights,
      );

  @override
  Future<void> watchShare(String shareId) =>
      api.watchShare(guildId, channelId, shareId);

  @override
  Future<void> unwatchShare(String shareId) =>
      api.unwatchShare(guildId, channelId, shareId);

  @override
  Future<Map<String, List<String>>> shareViewers() =>
      api.shareViewers(guildId, channelId);
}
