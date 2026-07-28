import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../data/guild_voice_api.dart';

/// Manages the WebRTC plumbing for one guild voice channel session — mirrors
/// `CallWebRtcService` (1:1 calling) almost exactly, since a guild voice
/// channel is really just "one more `cfSessionId`-bearing peer connection
/// scoped to a guild+channel pair, with N participants instead of 2." One
/// instance is created per joined channel by `GuildVoiceCubit`.
///
/// Audio-only v1: no `<audio>`-element wiring needed — flutter_webrtc's
/// native engine plays a received audio track through the device's call/
/// media output as soon as it's part of a live `RTCPeerConnection`.
class GuildVoiceWebRtcService {
  GuildVoiceWebRtcService({required this.api});

  final GuildVoiceApi api;

  RTCPeerConnection? _pc;
  String? _guildId;
  String? _channelId;
  String? _cfSessionId;
  MediaStreamTrack? _localAudioTrack;
  MediaStream? _localStream;

  // MID -> userId, so ontrack can route inbound audio to the right participant.
  final Map<String, String> _midToUserId = {};
  final Map<String, MediaStreamTrack> _remoteAudioTracks = {};
  final List<RTCTrackEvent> _pendingTracks = [];

  // RTCPeerConnection only allows one offer/answer exchange at a time —
  // chaining through this serializes publish/subscribe calls that would
  // otherwise race on setLocalDescription/setRemoteDescription.
  Future<void> _negotiationChain = Future.value();

  bool _deafened = false;

  Future<void> connect(String guildId, String channelId) async {
    _guildId = guildId;
    _channelId = channelId;
    _pc = await createPeerConnection({
      'sdpSemantics': 'unified-plan',
      'bundlePolicy': 'max-bundle',
    });
    _pc!.onTrack = _handleRemoteTrack;

    _cfSessionId = await api.cfCreateSession(guildId, channelId);

    final stream = await navigator.mediaDevices.getUserMedia({'audio': true, 'video': false});
    final track = stream.getAudioTracks().first;
    _localStream = stream;
    _localAudioTrack = track;

    final transceiver = await _pc!.addTransceiver(
      track: track,
      init: RTCRtpTransceiverInit(direction: TransceiverDirection.SendOnly),
    );

    await _offerAnswerCycle(() => [
          {'location': 'local', 'mid': transceiver.mid, 'trackName': 'audio'},
        ]);

    await Helper.setSpeakerphoneOnButPreferBluetooth();
  }

  Future<void> subscribeToParticipant({
    required String userId,
    required String cfSessionId,
    required String trackName,
  }) async {
    final pc = _pc;
    if (pc == null) return;

    final transceiver = await pc.addTransceiver(
      kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
      init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
    );

    final results = await _offerAnswerCycle(() => [
          {'location': 'remote', 'sessionId': cfSessionId, 'trackName': trackName},
        ]);

    final mid = results.firstWhere(
          (r) => r['trackName'] == trackName,
          orElse: () => const {},
        )['mid'] as String? ??
        transceiver.mid;
    _midToUserId[mid] = userId;
    _processPendingTracks();
  }

  void unsubscribeParticipant(String userId) {
    _remoteAudioTracks.remove(userId);
    _midToUserId.removeWhere((mid, id) => id == userId);
  }

  void setMuted(bool isMuted) {
    _localAudioTrack?.enabled = !isMuted;
  }

  void setDeafened(bool isDeafened) {
    _deafened = isDeafened;
    for (final track in _remoteAudioTracks.values) {
      track.enabled = !isDeafened;
    }
  }

  Future<void> disconnect() async {
    _localAudioTrack?.stop();
    await _localStream?.dispose();
    await _pc?.close();
    _pc = null;
    _guildId = null;
    _channelId = null;
    _cfSessionId = null;
    _localAudioTrack = null;
    _localStream = null;
    _midToUserId.clear();
    _remoteAudioTracks.clear();
    _pendingTracks.clear();
    _deafened = false;
    _negotiationChain = Future.value();
  }

  // ── SDP offer/answer cycle ────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> _offerAnswerCycle(
    List<Map<String, dynamic>> Function() buildTracks,
  ) {
    final next = _negotiationChain.catchError((_) {}).then((_) => _doOfferAnswer(buildTracks));
    _negotiationChain = next.catchError((_) => const <Map<String, dynamic>>[]);
    return next;
  }

  Future<List<Map<String, dynamic>>> _doOfferAnswer(
    List<Map<String, dynamic>> Function() buildTracks,
  ) async {
    final pc = _pc;
    final guildId = _guildId;
    final channelId = _channelId;
    final cfSessionId = _cfSessionId;
    if (pc == null || guildId == null || channelId == null || cfSessionId == null) return const [];

    final offer = await pc.createOffer();
    await pc.setLocalDescription(offer);

    final response = await api.cfTracksNew(
      guildId: guildId,
      channelId: channelId,
      cfSessionId: cfSessionId,
      sessionDescription: {'type': offer.type, 'sdp': offer.sdp},
      tracks: buildTracks(),
    );

    await pc.setRemoteDescription(_toSessionDescription(response.sessionDescription));

    if (response.requiresImmediateRenegotiation) {
      final reOffer = await pc.createOffer();
      await pc.setLocalDescription(reOffer);
      final reneg = await api.cfRenegotiate(
        guildId: guildId,
        channelId: channelId,
        cfSessionId: cfSessionId,
        sessionDescription: {'type': reOffer.type, 'sdp': reOffer.sdp},
      );
      await pc.setRemoteDescription(_toSessionDescription(reneg.sessionDescription));
    }

    return response.tracks.map((t) => <String, dynamic>{'mid': t.mid, 'trackName': t.trackName}).toList();
  }

  RTCSessionDescription _toSessionDescription(Map<String, dynamic> map) =>
      RTCSessionDescription(map['sdp'] as String, map['type'] as String);

  // ── Remote track routing ──────────────────────────────────────────────────

  void _processPendingTracks() {
    final remaining = <RTCTrackEvent>[];
    for (final event in _pendingTracks) {
      final mid = event.transceiver?.mid;
      if (mid != null && _midToUserId.containsKey(mid)) {
        _routeTrack(mid, event);
      } else {
        remaining.add(event);
      }
    }
    _pendingTracks
      ..clear()
      ..addAll(remaining);
  }

  void _handleRemoteTrack(RTCTrackEvent event) {
    final mid = event.transceiver?.mid;
    if (mid == null || !_midToUserId.containsKey(mid)) {
      _pendingTracks.add(event);
      return;
    }
    _routeTrack(mid, event);
  }

  void _routeTrack(String mid, RTCTrackEvent event) {
    final userId = _midToUserId[mid]!;
    final track = event.track;
    track.enabled = !_deafened;
    _remoteAudioTracks[userId] = track;
  }
}
