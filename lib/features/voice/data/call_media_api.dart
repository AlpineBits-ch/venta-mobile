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
  Future<VoiceSessionDto> createSession({bool primary = true}) =>
      api.createSession(callId, primary: primary);

  @override
  Future<VoiceNegotiateResponseDto> negotiate({
    required String mediaSessionId,
    required Map<String, dynamic> sessionDescription,
    required List<Map<String, dynamic>> tracks,
    Map<String, dynamic>? video,
  }) => api.negotiate(
    callId: callId,
    mediaSessionId: mediaSessionId,
    sessionDescription: sessionDescription,
    tracks: tracks,
    video: video,
  );

  @override
  Future<VoiceRenegotiateResponseDto> renegotiate({
    required String mediaSessionId,
    required Map<String, dynamic> sessionDescription,
    Map<String, dynamic>? video,
  }) => api.renegotiate(
    callId: callId,
    mediaSessionId: mediaSessionId,
    sessionDescription: sessionDescription,
    video: video,
  );

  @override
  Future<void> closeTracks({
    required String mediaSessionId,
    required List<String> trackNames,
  }) => api.closeTracks(
    callId: callId,
    mediaSessionId: mediaSessionId,
    trackNames: trackNames,
  );

  @override
  Future<void> updateSubscriber({
    Map<String, int>? tileHeights,
    List<String>? pinned,
    List<String>? screenAudioShares,
  }) => api.updateSubscriber(
    callId: callId,
    tileHeights: tileHeights,
    pinned: pinned,
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
