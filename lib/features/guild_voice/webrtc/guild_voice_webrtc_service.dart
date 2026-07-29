import 'dart:async';

import 'package:flutter/foundation.dart';
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

  // TEMPORARY diagnostic — see venta_mobile's "no audio in/out on mobile"
  // investigation. Polls getStats() to see whether real RTP bytes are
  // actually flowing (as opposed to the connection merely reaching
  // `connected` with silent tracks). Remove once the root cause is found.
  Timer? _statsTimer;

  void _startStatsLogging() {
    debugPrint('[AudioStats] _startStatsLogging called, arming timer');
    _statsTimer?.cancel();
    _statsTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      debugPrint('[AudioStats] timer fired, _pc=$_pc');
      final pc = _pc;
      if (pc == null) return;
      try {
        final reports = await pc.getStats();
        debugPrint('[AudioStats] === tick: ${reports.length} reports ===');
        for (final r in reports) {
          if (r.type != 'outbound-rtp' &&
              r.type != 'inbound-rtp' &&
              r.type != 'media-source' &&
              r.type != 'track') {
            continue;
          }
          debugPrint('[AudioStats] type=${r.type} values=${r.values}');
        }
      } catch (e, st) {
        debugPrint('[AudioStats] getStats threw: $e\n$st');
      }
    });
  }

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

    await _offerAnswerCycle((pc) async {
      final mid = await _resolveMid(pc, transceiver);
      return [
        {'location': 'local', 'mid': mid, 'trackName': 'audio'},
      ];
    });

    await Helper.setSpeakerphoneOnButPreferBluetooth();
    _startStatsLogging();
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

    final results = await _offerAnswerCycle((pc) async => [
          {'location': 'remote', 'sessionId': cfSessionId, 'trackName': trackName},
        ]);

    final mid = results.firstWhere(
          (r) => r['trackName'] == trackName,
          orElse: () => const {},
        )['mid'] as String? ??
        await _resolveMid(pc, transceiver) ??
        '';
    _midToUserId[mid] = userId;
    _processPendingTracks();
  }

  // flutter_webrtc's RTCRtpTransceiver.mid is a snapshot taken when
  // addTransceiver() returns — before the SDP that actually assigns mids
  // exists — and is never refreshed after setLocalDescription() the way a
  // browser's live `mid` property is (see Alpine's identical-looking
  // `transceiver.mid` usage, which works there for exactly that reason: a
  // browser DOES keep it live). Reading it straight off `transceiver` here
  // always sends an empty mid, which Cloudflare Calls rejects outright
  // ("Missing mid in track") — see venta_mobile's "no audio in/out"
  // investigation. getTransceivers() makes a fresh native call and returns
  // the real, current mid.
  //
  // transceiverId can't be used to find the same transceiver again — on
  // Android (PeerConnectionObserver.java) it's *derived from* mid itself
  // (`transceiver.getMid() ?? randomUUID()`), so it's a fresh random value
  // every time it's read before mid is assigned, and a *different* value
  // (the real mid) once mid becomes available. The "same" transceiver
  // therefore never compares equal to itself across this before/after gap.
  // The sender's local track id is what's actually stable.
  Future<String?> _resolveMid(RTCPeerConnection pc, RTCRtpTransceiver original) async {
    final trackId = original.sender.track?.id;
    final transceivers = await pc.getTransceivers();
    if (trackId != null) {
      for (final t in transceivers) {
        if (t.sender.track?.id == trackId) return t.mid;
      }
    }
    return original.mid;
  }

  void unsubscribeParticipant(String userId) {
    _remoteAudioTracks.remove(userId);
    _midToUserId.removeWhere((mid, id) => id == userId);
  }

  void setMuted(bool isMuted) {
    _localAudioTrack?.enabled = !isMuted;
  }

  Future<void> setSpeakerphoneOn(bool enable) => Helper.setSpeakerphoneOn(enable);

  void setDeafened(bool isDeafened) {
    _deafened = isDeafened;
    for (final track in _remoteAudioTracks.values) {
      track.enabled = !isDeafened;
    }
  }

  Future<void> disconnect() async {
    _statsTimer?.cancel();
    _statsTimer = null;
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
    Future<List<Map<String, dynamic>>> Function(RTCPeerConnection pc) buildTracks,
  ) {
    final next = _negotiationChain.catchError((_) {}).then((_) => _doOfferAnswer(buildTracks));
    _negotiationChain = next.catchError((_) => const <Map<String, dynamic>>[]);
    return next;
  }

  Future<List<Map<String, dynamic>>> _doOfferAnswer(
    Future<List<Map<String, dynamic>>> Function(RTCPeerConnection pc) buildTracks,
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
      tracks: await buildTracks(pc),
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
