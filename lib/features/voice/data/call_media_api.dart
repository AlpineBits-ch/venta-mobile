import '../../../core/voice/voice_media_api.dart';
import '../../../core/voice/voice_media_dto.dart';
import '../../../core/voice/voice_room_key.dart';
import '../../../core/voice/voice_snapshot_dto.dart';
import 'voice_api.dart';

/// Binds [VoiceApi] to one call, so `VoiceWebRtcService` can drive a call
/// through exactly the same code path as a guild voice channel.
class CallMediaApi implements VoiceMediaApi {
  CallMediaApi({required this.api, required this.callId});

  final VoiceApi api;
  final String callId;

  @override
  VoiceRoomKey get roomKey => VoiceRoomKey.call(callId);

  @override
  Future<VoiceRoomSnapshotDto> fetchSnapshot() => api.getSnapshot(callId);

  @override
  Future<VoiceConnectionDto> createConnection({
    bool primary = true,
    String? tag,
  }) => api.createConnection(callId, primary: primary, tag: tag);

  @override
  Future<VoicePublishResultDto> declarePublish({
    required List<String> trackNames,
    Map<String, dynamic>? video,
  }) => api.declarePublish(
    callId: callId,
    trackNames: trackNames,
    video: video,
  );

  @override
  Future<void> unpublish({required List<String> trackNames}) =>
      api.unpublish(callId: callId, trackNames: trackNames);

  @override
  Future<void> declareVideo(Map<String, dynamic> video) =>
      api.declareVideo(callId: callId, video: video);

  @override
  Future<VoiceSubscriptionSetDto?> updateSubscriber({
    bool? paused,
    Map<String, int>? tileHeights,
    List<String>? pinned,
    List<String>? pausedPublishers,
    List<String>? screenAudioShares,
  }) => api.updateSubscriber(
    callId: callId,
    paused: paused,
    tileHeights: tileHeights,
    pinned: pinned,
    pausedPublishers: pausedPublishers,
    screenAudioShares: screenAudioShares,
  );

  @override
  Future<void> watchShare(String shareId) => api.watchShare(callId, shareId);

  @override
  Future<void> unwatchShare(String shareId) =>
      api.unwatchShare(callId, shareId);

  @override
  Future<Map<String, List<String>>> shareViewers() => api.shareViewers(callId);
}
