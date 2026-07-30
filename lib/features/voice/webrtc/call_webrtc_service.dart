import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../core/media/camera_permission.dart';
import '../../../core/media/screen_share_service.dart';
import '../../../core/webrtc/track_kind.dart';
import '../data/voice_api.dart';

/// Owner (userId + [TrackKind]) of one negotiated mid - lets a single
/// `ontrack` callback route audio, camera, and screen-share tracks to the
/// right per-kind bucket instead of assuming everything is audio.
typedef _TrackOwner = ({String userId, TrackKind kind});

/// Manages the WebRTC plumbing for one Cloudflare Calls SFU session - the
/// mobile counterpart to Alpine desktop's `CallWebRtcService`. One instance
/// is created per active call by `CallCubit`, which owns the participant
/// list; this service only knows about mids, tracks, and SDP.
///
/// Audio plays automatically once its track is part of a live
/// `RTCPeerConnection` (flutter_webrtc routes it to the device's call/media
/// output natively) - video/screen tracks don't auto-render anywhere; the UI
/// attaches an `RTCVideoRenderer` to whatever [remoteVideoTrackFor]/
/// [remoteScreenTrackFor]/[localVideoTrack] currently return.
///
/// CF Calls' SFU has a publicly routable server, so no STUN/TURN
/// configuration is needed (mirrors Alpine's `call-webrtc.service.ts`).
class CallWebRtcService {
  CallWebRtcService({required this.api});

  final VoiceApi api;
  final ScreenShareService _screenShareService = ScreenShareService();

  RTCPeerConnection? _pc;
  String? _callId;
  String? _cfSessionId;
  MediaStreamTrack? _localAudioTrack;
  MediaStream? _localStream;
  MediaStreamTrack? _localVideoTrack;
  MediaStream? _localVideoStream;
  MediaStreamTrack? _localScreenTrack;
  MediaStream? _localScreenStream;
  String? _activeShareId;

  // MID -> (userId, kind), so ontrack can route an inbound track to the
  // right participant and the right per-kind bucket below.
  final Map<String, _TrackOwner> _midOwners = {};
  // "userId|kind" keys already subscribed - makes subscribing safe to call
  // more than once for the same user+kind (e.g. both the live
  // `ParticipantJoined`/`TrackPublished` event and a reconcile-on-reconnect
  // backfill racing).
  final Set<String> _subscribedKeys = {};
  final Map<String, MediaStreamTrack> _remoteAudioTracks = {};
  final Map<String, MediaStreamTrack> _remoteVideoTracks = {};
  final Map<String, MediaStreamTrack> _remoteScreenTracks = {};
  final List<RTCTrackEvent> _pendingTracks = [];

  // RTCPeerConnection only allows one offer/answer exchange at a time -
  // chaining through this serializes publish/subscribe calls that would
  // otherwise race on setLocalDescription/setRemoteDescription.
  Future<void> _negotiationChain = Future.value();

  bool _deafened = false;

  // TEMPORARY diagnostic - see venta_mobile's "no audio in/out on mobile"
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

  Future<void> connect(String callId) async {
    _callId = callId;
    _pc = await createPeerConnection({
      'sdpSemantics': 'unified-plan',
      'bundlePolicy': 'max-bundle',
    });
    _pc!.onTrack = _handleRemoteTrack;

    _cfSessionId = await api.cfCreateSession(callId);

    final stream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': false,
    });
    final track = stream.getAudioTracks().first;
    _localStream = stream;
    _localAudioTrack = track;

    await _publishTrack(track: track, trackName: 'audio');

    await Helper.setSpeakerphoneOnButPreferBluetooth();
    _startStatsLogging();
  }

  /// Starts local camera capture and publishes it as a `"camera"` track -
  /// the backend classifies any non-`"audio"`, non-`screen-`-prefixed track
  /// name as `kind: "video"` purely from the name, so nothing else is needed
  /// server-side. No-ops if the camera is already on.
  Future<void> publishLocalVideo() async {
    if (_localVideoTrack != null) return;
    if (!await ensureCameraPermission()) {
      throw StateError('Camera permission denied');
    }
    final stream = await navigator.mediaDevices.getUserMedia({
      'audio': false,
      'video': true,
    });
    final track = stream.getVideoTracks().first;
    _localVideoStream = stream;
    _localVideoTrack = track;
    await _publishTrack(track: track, trackName: 'camera');
  }

  Future<void> stopLocalVideo() async {
    final track = _localVideoTrack;
    if (track == null) return;
    _localVideoTrack = null;
    track.stop();
    await _localVideoStream?.dispose();
    _localVideoStream = null;
    await _closeTrack('camera');
  }

  /// Starts screen capture and publishes it as `"screen-$shareId"` - the
  /// `screen-` prefix is what makes the backend classify it as `kind:
  /// "screen"` (vs. `"video"` for the camera) and broadcast it as a screen
  /// share rather than a regular video track. [shareId] is a caller-generated
  /// id also passed to `invokeScreenShareStarted`.
  Future<void> startScreenShare(String shareId) async {
    if (_localScreenTrack != null) return;
    if (Platform.isAndroid) await _screenShareService.start();
    final MediaStream stream;
    try {
      stream = await navigator.mediaDevices.getDisplayMedia({
        'video': true,
        'audio': false,
      });
    } catch (e) {
      if (Platform.isAndroid) await _screenShareService.stop();
      rethrow;
    }
    final track = stream.getVideoTracks().first;
    _localScreenStream = stream;
    _localScreenTrack = track;
    _activeShareId = shareId;
    await _publishTrack(track: track, trackName: 'screen-$shareId');
  }

  Future<void> stopScreenShare() async {
    final track = _localScreenTrack;
    final shareId = _activeShareId;
    if (track == null || shareId == null) return;
    _localScreenTrack = null;
    _activeShareId = null;
    track.stop();
    await _localScreenStream?.dispose();
    _localScreenStream = null;
    await _closeTrack('screen-$shareId');
    if (Platform.isAndroid) await _screenShareService.stop();
  }

  Future<void> _closeTrack(String trackName) async {
    final callId = _callId;
    final cfSessionId = _cfSessionId;
    if (callId == null || cfSessionId == null) return;
    try {
      await api.cfCloseTracks(
        callId: callId,
        cfSessionId: cfSessionId,
        trackNames: [trackName],
      );
    } catch (_) {
      // Best-effort - the local track is already stopped either way.
    }
  }

  /// Publishes one already-captured local track under [trackName] - shared
  /// by [connect] (audio), [publishLocalVideo] (camera), and
  /// [startScreenShare] (screen).
  Future<void> _publishTrack({
    required MediaStreamTrack track,
    required String trackName,
  }) async {
    final pc = _pc;
    if (pc == null) return;
    final transceiver = await pc.addTransceiver(
      track: track,
      init: RTCRtpTransceiverInit(direction: TransceiverDirection.SendOnly),
    );
    await _offerAnswerCycle((pc) async {
      final mid = await _resolveMid(pc, transceiver);
      return [
        {'location': 'local', 'mid': mid, 'trackName': trackName},
      ];
    });
  }

  Future<void> subscribeToParticipant({
    required String userId,
    required String cfSessionId,
    required String trackName,
  }) => _subscribeTrack(
    userId: userId,
    cfSessionId: cfSessionId,
    trackName: trackName,
    kind: TrackKind.audio,
    mediaType: RTCRtpMediaType.RTCRtpMediaTypeAudio,
  );

  /// Subscribes to a remote participant's camera/screen track once a
  /// `TrackPublished(kind: "video"|"screen")` event names it.
  Future<void> subscribeToTrack({
    required String userId,
    required String cfSessionId,
    required String trackName,
    required TrackKind kind,
  }) => _subscribeTrack(
    userId: userId,
    cfSessionId: cfSessionId,
    trackName: trackName,
    kind: kind,
    mediaType: RTCRtpMediaType.RTCRtpMediaTypeVideo,
  );

  Future<void> _subscribeTrack({
    required String userId,
    required String cfSessionId,
    required String trackName,
    required TrackKind kind,
    required RTCRtpMediaType mediaType,
  }) async {
    final pc = _pc;
    final key = '$userId|${kind.name}';
    if (pc == null || !_subscribedKeys.add(key)) return;

    final transceiver = await pc.addTransceiver(
      kind: mediaType,
      init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
    );

    final results = await _offerAnswerCycle(
      (pc) async => [
        {
          'location': 'remote',
          'sessionId': cfSessionId,
          'trackName': trackName,
        },
      ],
    );

    final mid =
        results.firstWhere(
              (r) => r['trackName'] == trackName,
              orElse: () => const {},
            )['mid']
            as String? ??
        await _resolveMid(pc, transceiver) ??
        '';
    _midOwners[mid] = (userId: userId, kind: kind);
    _processPendingTracks();
  }

  // flutter_webrtc's RTCRtpTransceiver.mid is a snapshot taken when
  // addTransceiver() returns - before the SDP that actually assigns mids
  // exists - and is never refreshed after setLocalDescription() the way a
  // browser's live `mid` property is (see Alpine's identical-looking
  // `transceiver.mid` usage, which works there for exactly that reason: a
  // browser DOES keep it live). Reading it straight off `transceiver` here
  // always sends an empty mid, which Cloudflare Calls rejects outright
  // ("Missing mid in track") - see venta_mobile's "no audio in/out"
  // investigation. getTransceivers() makes a fresh native call and returns
  // the real, current mid.
  //
  // transceiverId can't be used to find the same transceiver again - on
  // Android (PeerConnectionObserver.java) it's *derived from* mid itself
  // (`transceiver.getMid() ?? randomUUID()`), so it's a fresh random value
  // every time it's read before mid is assigned, and a *different* value
  // (the real mid) once mid becomes available. The "same" transceiver
  // therefore never compares equal to itself across this before/after gap.
  // The sender's local track id is what's actually stable.
  Future<String?> _resolveMid(
    RTCPeerConnection pc,
    RTCRtpTransceiver original,
  ) async {
    final trackId = original.sender.track?.id;
    final transceivers = await pc.getTransceivers();
    if (trackId != null) {
      for (final t in transceivers) {
        if (t.sender.track?.id == trackId) return t.mid;
      }
    }
    return original.mid;
  }

  void unsubscribeParticipant(String userId) =>
      unsubscribeTrack(userId: userId, kind: TrackKind.audio);

  void unsubscribeTrack({required String userId, required TrackKind kind}) {
    switch (kind) {
      case TrackKind.audio:
        _remoteAudioTracks.remove(userId);
      case TrackKind.video:
        _remoteVideoTracks.remove(userId);
      case TrackKind.screen:
        _remoteScreenTracks.remove(userId);
    }
    _subscribedKeys.remove('$userId|${kind.name}');
    _midOwners.removeWhere(
      (mid, owner) => owner.userId == userId && owner.kind == kind,
    );
  }

  void setMuted(bool isMuted) {
    _localAudioTrack?.enabled = !isMuted;
  }

  Future<void> setSpeakerphoneOn(bool enable) =>
      Helper.setSpeakerphoneOn(enable);

  void setDeafened(bool isDeafened) {
    _deafened = isDeafened;
    for (final track in _remoteAudioTracks.values) {
      track.enabled = !isDeafened;
    }
  }

  MediaStreamTrack? get localVideoTrack => _localVideoTrack;
  MediaStreamTrack? get localScreenTrack => _localScreenTrack;
  MediaStreamTrack? remoteVideoTrackFor(String userId) =>
      _remoteVideoTracks[userId];
  MediaStreamTrack? remoteScreenTrackFor(String userId) =>
      _remoteScreenTracks[userId];

  Future<void> disconnect() async {
    _statsTimer?.cancel();
    _statsTimer = null;
    if (_localScreenTrack != null && Platform.isAndroid) {
      await _screenShareService.stop();
    }
    _localAudioTrack?.stop();
    _localVideoTrack?.stop();
    _localScreenTrack?.stop();
    await _localStream?.dispose();
    await _localVideoStream?.dispose();
    await _localScreenStream?.dispose();
    await _pc?.close();
    _pc = null;
    _callId = null;
    _cfSessionId = null;
    _localAudioTrack = null;
    _localStream = null;
    _localVideoTrack = null;
    _localVideoStream = null;
    _localScreenTrack = null;
    _localScreenStream = null;
    _activeShareId = null;
    _midOwners.clear();
    _remoteAudioTracks.clear();
    _remoteVideoTracks.clear();
    _remoteScreenTracks.clear();
    _pendingTracks.clear();
    _subscribedKeys.clear();
    _deafened = false;
    _negotiationChain = Future.value();
  }

  // ── SDP offer/answer cycle ────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> _offerAnswerCycle(
    Future<List<Map<String, dynamic>>> Function(RTCPeerConnection pc)
    buildTracks,
  ) {
    final next = _negotiationChain
        .catchError((_) {})
        .then((_) => _doOfferAnswer(buildTracks));
    _negotiationChain = next.catchError((_) => const <Map<String, dynamic>>[]);
    return next;
  }

  Future<List<Map<String, dynamic>>> _doOfferAnswer(
    Future<List<Map<String, dynamic>>> Function(RTCPeerConnection pc)
    buildTracks,
  ) async {
    final pc = _pc;
    final callId = _callId;
    final cfSessionId = _cfSessionId;
    if (pc == null || callId == null || cfSessionId == null) return const [];

    final offer = await pc.createOffer();
    await pc.setLocalDescription(offer);

    final response = await api.cfTracksNew(
      callId: callId,
      cfSessionId: cfSessionId,
      sessionDescription: {'type': offer.type, 'sdp': offer.sdp},
      tracks: await buildTracks(pc),
    );

    await pc.setRemoteDescription(
      _toSessionDescription(response.sessionDescription),
    );

    if (response.requiresImmediateRenegotiation) {
      final reOffer = await pc.createOffer();
      await pc.setLocalDescription(reOffer);
      final reneg = await api.cfRenegotiate(
        callId: callId,
        cfSessionId: cfSessionId,
        sessionDescription: {'type': reOffer.type, 'sdp': reOffer.sdp},
      );
      await pc.setRemoteDescription(
        _toSessionDescription(reneg.sessionDescription),
      );
    }

    return response.tracks
        .map((t) => <String, dynamic>{'mid': t.mid, 'trackName': t.trackName})
        .toList();
  }

  RTCSessionDescription _toSessionDescription(Map<String, dynamic> map) =>
      RTCSessionDescription(map['sdp'] as String, map['type'] as String);

  // ── Remote track routing ──────────────────────────────────────────────────

  void _processPendingTracks() {
    final remaining = <RTCTrackEvent>[];
    for (final event in _pendingTracks) {
      final mid = event.transceiver?.mid;
      if (mid != null && _midOwners.containsKey(mid)) {
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
    if (mid == null || !_midOwners.containsKey(mid)) {
      _pendingTracks.add(event);
      return;
    }
    _routeTrack(mid, event);
  }

  void _routeTrack(String mid, RTCTrackEvent event) {
    final owner = _midOwners[mid]!;
    final track = event.track;
    switch (owner.kind) {
      case TrackKind.audio:
        track.enabled = !_deafened;
        _remoteAudioTracks[owner.userId] = track;
      case TrackKind.video:
        _remoteVideoTracks[owner.userId] = track;
      case TrackKind.screen:
        _remoteScreenTracks[owner.userId] = track;
    }
  }
}
