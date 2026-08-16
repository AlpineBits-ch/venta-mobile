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
  Future<VoiceConnectionDto> createConnection({
    bool primary = true,
    String? tag,
  }) => api.createConnection(guildId, channelId, primary: primary, tag: tag);

  @override
  Future<VoicePublishResultDto> declarePublish({
    required List<String> trackNames,
    Map<String, dynamic>? video,
  }) => api.declarePublish(
    guildId: guildId,
    channelId: channelId,
    trackNames: trackNames,
    video: video,
  );

  @override
  Future<void> unpublish({required List<String> trackNames}) => api.unpublish(
    guildId: guildId,
    channelId: channelId,
    trackNames: trackNames,
  );

  @override
  Future<void> declareVideo(Map<String, dynamic> video) =>
      api.declareVideo(guildId: guildId, channelId: channelId, video: video);

  @override
  Future<VoiceSubscriptionSetDto?> updateSubscriber({
    bool? paused,
    Map<String, int>? tileHeights,
    List<String>? pinned,
    List<String>? pausedPublishers,
    List<String>? screenAudioShares,
  }) => api.updateSubscriber(
    guildId: guildId,
    channelId: channelId,
    paused: paused,
    tileHeights: tileHeights,
    pinned: pinned,
    pausedPublishers: pausedPublishers,
    screenAudioShares: screenAudioShares,
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
