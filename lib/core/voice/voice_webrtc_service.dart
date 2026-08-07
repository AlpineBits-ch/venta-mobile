import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../media/camera_permission.dart';
import '../media/screen_share_service.dart';
import 'track_naming.dart';
import 'voice_media_api.dart';
import 'voice_media_dto.dart';

/// Owner of one negotiated mid, so a single `ontrack` callback can route an
/// inbound track to the right participant and the right bucket. [shareId] is
/// set for the two halves of a screen share and null otherwise.
typedef _TrackOwner = ({String userId, TrackKind kind, String? shareId});

/// A subscribe request deferred until the local publish has completed.
typedef _PendingSubscribe = ({
  String userId,
  String mediaSessionId,
  String trackName,
  TrackKind kind,
  String? shareId,
});

/// The WebRTC half of one voice room - mids, tracks and SDP, for a guild voice
/// channel and a direct call alike.
///
/// There is one implementation because there is one server implementation.
/// The two room kinds differ only in the routes their [VoiceMediaApi] talks to;
/// every rule below - publish before you pull, roll the dedupe guard back on
/// failure, group a screen share's two tracks by `shareId` - is identical on
/// both sides, and having written them twice is how they drifted apart before.
///
/// Audio plays automatically once its track is part of a live
/// `RTCPeerConnection` (flutter_webrtc routes it to the device's call/media
/// output natively). Video and screen tracks do not render anywhere on their
/// own; the UI attaches an `RTCVideoRenderer` to whatever the track getters
/// here currently return.
///
/// The SFU is publicly routable, so no STUN/TURN configuration is needed for
/// the leg between this device and it.
class VoiceWebRtcService {
  VoiceWebRtcService();

  final ScreenShareService _screenShareService = ScreenShareService();

  VoiceMediaApi? _media;
  RTCPeerConnection? _pc;
  String? _mediaSessionId;

  String? _backend;

  /// The SFU behind this session, as the server declared it. Read rather than
  /// branched on anywhere below: the negotiation is backend-neutral, and the
  /// one decision it drives - "can this build drive this room at all" - is
  /// made once in [connectTo].
  String? get mediaBackend => _backend;

  /// Whether the local microphone track has actually been published.
  ///
  /// The SFU rejects a pull on a session that has not completed its own
  /// negotiation, so this - not merely "a session exists" - is what releases
  /// the deferred subscribes. See [_pendingSubscribes].
  bool _publishedLocalAudio = false;

  MediaStreamTrack? _localAudioTrack;
  MediaStream? _localStream;
  MediaStreamTrack? _localVideoTrack;
  MediaStream? _localVideoStream;
  MediaStreamTrack? _localScreenTrack;
  MediaStream? _localScreenStream;
  String? _activeShareId;

  final Map<String, _TrackOwner> _midOwners = {};

  /// Subscription keys already claimed - see [_subscriptionKey]. Makes
  /// subscribing safe to call more than once for the same target (a live
  /// `TrackPublished` racing a snapshot backfill).
  final Set<String> _subscribedKeys = {};

  final Map<String, MediaStreamTrack> _remoteAudioTracks = {};
  final Map<String, MediaStreamTrack> _remoteVideoTracks = {};

  /// Screen tracks are keyed by `shareId`, not by user: one participant can
  /// run more than one share, and the snapshot models them as a list for
  /// exactly that reason.
  final Map<String, MediaStreamTrack> _remoteScreenTracks = {};
  final Map<String, MediaStreamTrack> _remoteScreenAudioTracks = {};
  final Map<String, String> _shareOwners = {};

  final List<RTCTrackEvent> _pendingTracks = [];

  /// Subscribe requests that arrived before the local publish completed.
  ///
  /// This window is much wider than it looks and is hit constantly. A cubit
  /// goes active and starts handling `ParticipantJoined` the moment its
  /// join/accept response lands, while [connectTo] is still awaiting
  /// `getUserMedia` - which blocks for seconds behind the OS microphone prompt
  /// on a cold start. The other party publishes in exactly that window (they
  /// are not waiting on us), so their announcement is routinely the event that
  /// lands first. Dropped, it never comes back: nothing replays it short of a
  /// full resync.
  final Map<String, _PendingSubscribe> _pendingSubscribes = {};

  /// Called when the server refuses a subscribe because this client's view of
  /// the room is stale - it asked to pull a track nobody is publishing.
  ///
  /// The owner answers by refetching the snapshot and reconciling against it.
  /// There is nothing useful this service can do on its own: it knows the pull
  /// was refused, but only the room's owner knows what should be pulled
  /// instead.
  void Function()? onStaleSubscription;

  /// Keys of subscribe requests currently deferred. Exposed because the flush
  /// itself can only run against a live peer connection (platform channels),
  /// so the queueing half is what unit tests can reach.
  @visibleForTesting
  Iterable<String> get pendingSubscribeKeys => _pendingSubscribes.keys;

  // RTCPeerConnection only allows one offer/answer exchange at a time -
  // chaining through this serializes publish/subscribe calls that would
  // otherwise race on setLocalDescription/setRemoteDescription.
  Future<void> _negotiationChain = Future.value();

  bool _deafened = false;

  /// This session's media id, or null while not publishing - the value
  /// the heartbeat asserts. Reported honestly: claiming a session that carries
  /// nothing is what the server's reconcile pass exists to correct.
  String? get mediaSessionId => _publishedLocalAudio ? _mediaSessionId : null;

  /// The microphone track name to assert on the heartbeat, or null when not
  /// publishing.
  String? get publishedAudioTrackName =>
      _publishedLocalAudio ? TrackNaming.audio : null;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// Steps 2-3 of the connection lifecycle: open a media session, then publish
  /// the microphone. Joining (step 1) already happened - it is an
  /// authorisation decision, not a media one, and the caller holds the
  /// snapshot it produced.
  ///
  /// The microphone is acquired *before* the session is opened. `POST
  /// /session` records this participant's session id, and until the audio
  /// track exists there is a window where the roster holds a session carrying
  /// nothing. The server no longer announces participants in that state, but
  /// `getUserMedia` can block for seconds on the OS permission prompt - by far
  /// the widest such window in the stack - so opening the session last shrinks
  /// it to the round trip it has to be.
  Future<void> connectTo(VoiceMediaApi media) async {
    _media = media;

    final stream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': false,
    });
    final track = stream.getAudioTracks().first;
    _localStream = stream;
    _localAudioTrack = track;

    _pc = await createPeerConnection({
      'sdpSemantics': 'unified-plan',
      'bundlePolicy': 'max-bundle',
    });
    _pc!.onTrack = _handleRemoteTrack;

    final session = await media.createSession(primary: true);
    // The handshake declares its backend so a client picks a media layer from
    // a stated value rather than inferring one. An unrecognised backend means
    // this build cannot drive the room - guessing would negotiate against
    // different semantics and fail as if the network were at fault.
    if (!supportedVoiceBackends.contains(session.backend)) {
      throw UnsupportedVoiceBackendException(session.backend);
    }
    _mediaSessionId = session.mediaSessionId;
    _backend = session.backend;

    await _publishTrack(track: track, trackName: TrackNaming.audio);
    _publishedLocalAudio = true;

    await Helper.setSpeakerphoneOnButPreferBluetooth();
    await _flushPendingSubscribes();
  }

  Future<void> disconnect() async {
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
    _media = null;
    _mediaSessionId = null;
    _backend = null;
    _publishedLocalAudio = false;
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
    _remoteScreenAudioTracks.clear();
    _shareOwners.clear();
    _pendingTracks.clear();
    _pendingSubscribes.clear();
    _subscribedKeys.clear();
    _deafened = false;
    _negotiationChain = Future.value();
  }

  // ── Publishing ────────────────────────────────────────────────────────────

  /// Starts local camera capture and publishes it under [TrackNaming.camera].
  /// The server classifies it as `kind: "video"` from the name alone, so
  /// nothing else is needed. No-ops if the camera is already on.
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
    await _publishTrack(track: track, trackName: TrackNaming.camera);
  }

  Future<void> stopLocalVideo() async {
    final track = _localVideoTrack;
    if (track == null) return;
    _localVideoTrack = null;
    track.stop();
    await _localVideoStream?.dispose();
    _localVideoStream = null;
    await _closeTracks([TrackNaming.camera]);
  }

  /// Starts screen capture and publishes it as `screen-{shareId}`, plus
  /// `screen-audio-{shareId}` when the platform actually handed us the shared
  /// application's audio.
  ///
  /// Both halves go out in the *same* `tracks/new` call, which is what lets a
  /// receiving client group them into one tile from the two `TrackPublished`
  /// events that follow. A share may legitimately be video-only - on iOS
  /// ReplayKit and on Android below API 29 there is no app audio to capture -
  /// so the audio half is conditional, never assumed.
  Future<void> startScreenShare(String shareId) async {
    if (_localScreenTrack != null) return;
    if (Platform.isAndroid) await _screenShareService.start();
    final MediaStream stream;
    try {
      stream = await navigator.mediaDevices.getDisplayMedia({
        'video': true,
        'audio': true,
      });
    } catch (e) {
      if (Platform.isAndroid) await _screenShareService.stop();
      rethrow;
    }
    final videoTrack = stream.getVideoTracks().first;
    final audioTrack = stream.getAudioTracks().firstOrNull;
    _localScreenStream = stream;
    _localScreenTrack = videoTrack;
    _activeShareId = shareId;

    await _publishTracks([
      (track: videoTrack, trackName: TrackNaming.screenTrack(shareId)),
      if (audioTrack != null)
        (track: audioTrack, trackName: TrackNaming.screenAudioTrack(shareId)),
    ]);
  }

  /// Stops the local share and closes its tracks on the SFU.
  ///
  /// This is only half of stopping: the caller also announces
  /// `ScreenShareStopped` over the hub. Both are needed. The hub event tells
  /// people; this tells the SFU and releases the media. The server now cleans
  /// its roster up if only the announcement arrives, so skipping this is no
  /// longer a correctness bug - but it leaves the track live on the SFU until
  /// the whole session is torn down, which is egress paid for a picture nobody
  /// is receiving.
  Future<void> stopScreenShare() async {
    final track = _localScreenTrack;
    final shareId = _activeShareId;
    if (track == null || shareId == null) return;
    _localScreenTrack = null;
    _activeShareId = null;
    track.stop();
    for (final audio in _localScreenStream?.getAudioTracks() ?? const []) {
      audio.stop();
    }
    await _localScreenStream?.dispose();
    _localScreenStream = null;
    // Both halves are closed unconditionally: closing a track that was never
    // published is a no-op server-side, and leaving a live screen-audio track
    // behind a stopped video one is a share nobody can see but everyone hears.
    await _closeTracks([
      TrackNaming.screenTrack(shareId),
      TrackNaming.screenAudioTrack(shareId),
    ]);
    if (Platform.isAndroid) await _screenShareService.stop();
  }

  Future<void> _closeTracks(List<String> trackNames) async {
    final media = _media;
    final mediaSessionId = _mediaSessionId;
    if (media == null || mediaSessionId == null) return;
    try {
      await media.closeTracks(
        mediaSessionId: mediaSessionId,
        trackNames: trackNames,
      );
    } catch (_) {
      // Best-effort - the local track is already stopped either way.
    }
  }

  Future<void> _publishTrack({
    required MediaStreamTrack track,
    required String trackName,
  }) => _publishTracks([(track: track, trackName: trackName)]);

  /// Publishes one or more already-captured local tracks in a single
  /// negotiation.
  Future<void> _publishTracks(
    List<({MediaStreamTrack track, String trackName})> tracks,
  ) async {
    final pc = _pc;
    if (pc == null || tracks.isEmpty) return;

    final transceivers = <String, RTCRtpTransceiver>{};
    for (final t in tracks) {
      transceivers[t.trackName] = await pc.addTransceiver(
        track: t.track,
        init: RTCRtpTransceiverInit(direction: TransceiverDirection.SendOnly),
      );
    }

    await _offerAnswerCycle((pc) async {
      final payload = <Map<String, dynamic>>[];
      for (final entry in transceivers.entries) {
        payload.add({
          'direction': VoiceTrackDirection.publish,
          'mid': await _resolveMid(pc, entry.value),
          'trackName': entry.key,
        });
      }
      return payload;
    });
  }

  // ── Subscribing ───────────────────────────────────────────────────────────

  /// Subscribes to a participant's microphone. The only thing that makes them
  /// audible, and only ever called for someone the snapshot reports as
  /// `Publishing`.
  Future<void> subscribeToParticipant({
    required String userId,
    required String mediaSessionId,
    required String trackName,
  }) => _subscribeTrack(
    userId: userId,
    mediaSessionId: mediaSessionId,
    trackName: trackName,
    kind: TrackKind.audio,
  );

  /// Subscribes to a camera or either half of a screen share, once a
  /// `TrackPublished` or a snapshot names it.
  Future<void> subscribeToTrack({
    required String userId,
    required String mediaSessionId,
    required String trackName,
    required TrackKind kind,
    String? shareId,
  }) => _subscribeTrack(
    userId: userId,
    mediaSessionId: mediaSessionId,
    trackName: trackName,
    kind: kind,
    shareId: shareId,
  );

  /// Subscribes to every track of one screen share that actually exists.
  Future<void> subscribeToShare({
    required String userId,
    required String mediaSessionId,
    required String shareId,
    required List<String> trackNames,
  }) async {
    for (final trackName in trackNames) {
      final descriptor = TrackNaming.describe(trackName);
      await _subscribeTrack(
        userId: userId,
        mediaSessionId: mediaSessionId,
        trackName: trackName,
        kind: descriptor.kind,
        shareId: descriptor.shareId ?? shareId,
      );
    }
  }

  /// One subscription key. Shares carry their id so a participant running two
  /// of them does not collide with themselves; microphone and camera have no
  /// share and keep the plain `userId|kind` form.
  static String _subscriptionKey(
    String userId,
    TrackKind kind,
    String? shareId,
  ) => shareId == null
      ? '$userId|${kind.name}'
      : '$userId|${kind.name}|$shareId';

  /// Subscribes to one remote track, rolling the [_subscribedKeys] guard back
  /// on any failure.
  ///
  /// That rollback is the whole point. Every path that could retry this
  /// subscription is gated behind the same guard, so a guard consumed by a
  /// failed attempt and never released is how one transient error becomes
  /// permanent silence for that participant.
  ///
  /// Retries are per status, and the differences matter:
  ///
  ///  * **409 stale** - never retried. The track is gone rather than late, so
  ///    the identical body fails identically; [onStaleSubscription] asks for a
  ///    fresh snapshot and the reconcile that follows decides what to pull.
  ///  * **502** - backed off exponentially from a second. Retrying faster than
  ///    the snapshot being retried against can change just turns one bad moment
  ///    into a burst; that is what took voice to the status page in
  ///    VNT-GE21R3P7.
  ///  * **503** - contended, so the change was simply not applied. Retried
  ///    quickly, because nothing about the request was wrong.
  ///  * **403/404** - not retried at all.
  Future<void> _subscribeTrack({
    required String userId,
    required String mediaSessionId,
    required String trackName,
    required TrackKind kind,
    String? shareId,
  }) async {
    final key = _subscriptionKey(userId, kind, shareId);
    final pc = _pc;

    if (pc == null || _mediaSessionId == null || !_publishedLocalAudio) {
      // Not publishing yet - hold the request rather than dropping it, and
      // leave [_subscribedKeys] alone so the flush is what claims the key.
      _pendingSubscribes[key] = (
        userId: userId,
        mediaSessionId: mediaSessionId,
        trackName: trackName,
        kind: kind,
        shareId: shareId,
      );
      return;
    }
    _pendingSubscribes.remove(key);
    if (!_subscribedKeys.add(key)) return;

    const attempts = 3;
    for (var attempt = 1; attempt <= attempts; attempt++) {
      try {
        await pc.addTransceiver(
          kind: kind == TrackKind.audio || kind == TrackKind.screenAudio
              ? RTCRtpMediaType.RTCRtpMediaTypeAudio
              : RTCRtpMediaType.RTCRtpMediaTypeVideo,
          init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
        );

        final results = await _offerAnswerCycle(
          (pc) async => [
            {
              'direction': VoiceTrackDirection.subscribe,
              'mediaSessionId': mediaSessionId,
              'trackName': trackName,
            },
          ],
        );

        // Only the mid the server answered with can route this track. A locally
        // resolved one would name a transceiver the SFU never attached anything to.
        final mid =
            results.firstWhere(
                  (r) => r['trackName'] == trackName,
                  orElse: () => const {},
                )['mid']
                as String?;
        if (mid == null || mid.isEmpty) {
          throw StateError(
            'No mid returned for ${kind.name} track "$trackName" '
            'on session $mediaSessionId',
          );
        }

        _midOwners[mid] = (userId: userId, kind: kind, shareId: shareId);
        if (shareId != null) _shareOwners[shareId] = userId;
        _processPendingTracks();
        return;
      } on VoiceMediaException catch (e) {
        if (e.isStale) {
          _subscribedKeys.remove(key);
          debugPrint(
            '[Voice] stale subscribe for $userId ("$trackName") - '
            'refetching the snapshot: $e',
          );
          onStaleSubscription?.call();
          return;
        }

        final backoff = voiceRetryDelay(e, attempt);
        if (backoff == null || attempt == attempts) {
          // Released so another announcement or a fresh snapshot can try
          // again - a guard left set is how one failure becomes permanent
          // silence for this participant.
          _subscribedKeys.remove(key);
          debugPrint('[Voice] subscribe failed for $userId ("$trackName"): $e');
          return;
        }

        // The guard stays claimed across the wait: this attempt is still the
        // live one, and a duplicate announcement arriving now should still
        // dedupe against it.
        await Future<void>.delayed(backoff);

        // Unless something cleared it meanwhile. `unsubscribeTrack` and
        // `disconnect` both drop the key, and either means retrying would
        // subscribe to a participant who has already gone.
        if (!_subscribedKeys.contains(key)) return;
      } catch (e) {
        _subscribedKeys.remove(key);
        debugPrint('[Voice] subscribe failed for $userId ("$trackName"): $e');
        return;
      }
    }
  }

  /// Issues any subscribe requests that arrived while the local publish was
  /// still in flight. Draining a snapshot (rather than iterating the live map)
  /// keeps this safe against [_subscribeTrack] re-adding a failed entry
  /// mid-flush.
  Future<void> _flushPendingSubscribes() async {
    if (_pendingSubscribes.isEmpty) return;
    final pending = _pendingSubscribes.values.toList();
    _pendingSubscribes.clear();
    for (final p in pending) {
      await _subscribeTrack(
        userId: p.userId,
        mediaSessionId: p.mediaSessionId,
        trackName: p.trackName,
        kind: p.kind,
        shareId: p.shareId,
      );
    }
  }

  void unsubscribeParticipant(String userId) {
    unsubscribeTrack(userId: userId, kind: TrackKind.audio);
    unsubscribeTrack(userId: userId, kind: TrackKind.video);
    for (final shareId in _sharesOf(userId)) {
      unsubscribeShare(userId: userId, shareId: shareId);
    }
  }

  void unsubscribeTrack({
    required String userId,
    required TrackKind kind,
    String? shareId,
  }) {
    switch (kind) {
      case TrackKind.audio:
        _remoteAudioTracks.remove(userId);
      case TrackKind.video:
        _remoteVideoTracks.remove(userId);
      case TrackKind.screen:
        if (shareId != null) _remoteScreenTracks.remove(shareId);
      case TrackKind.screenAudio:
        if (shareId != null) _remoteScreenAudioTracks.remove(shareId);
    }
    final key = _subscriptionKey(userId, kind, shareId);
    _subscribedKeys.remove(key);
    // Also drop a request still waiting on the publish - a participant who
    // left during that window must not be subscribed to by the flush.
    _pendingSubscribes.remove(key);
    _midOwners.removeWhere(
      (mid, owner) =>
          owner.userId == userId &&
          owner.kind == kind &&
          owner.shareId == shareId,
    );
  }

  /// Drops both halves of one screen share. Called when the share stops, and
  /// when the viewer stops watching - egress is not free, and an unwatched
  /// stream that stays subscribed is exactly what the viewer protocol exists
  /// to avoid paying for.
  void unsubscribeShare({required String userId, required String shareId}) {
    unsubscribeTrack(userId: userId, kind: TrackKind.screen, shareId: shareId);
    unsubscribeTrack(
      userId: userId,
      kind: TrackKind.screenAudio,
      shareId: shareId,
    );
    _shareOwners.remove(shareId);
  }

  Iterable<String> _sharesOf(String userId) => _shareOwners.entries
      .where((e) => e.value == userId)
      .map((e) => e.key)
      .toList();

  // ── Local controls ────────────────────────────────────────────────────────

  void setMuted(bool isMuted) {
    _localAudioTrack?.enabled = !isMuted;
  }

  Future<void> setSpeakerphoneOn(bool enable) =>
      Helper.setSpeakerphoneOn(enable);

  /// Deafening silences peers' microphones *and* any screen audio - a shared
  /// tab's sound is remote audio like any other, and leaving it playing is not
  /// what "deafened" means to the person who pressed it.
  void setDeafened(bool isDeafened) {
    _deafened = isDeafened;
    for (final track in [
      ..._remoteAudioTracks.values,
      ..._remoteScreenAudioTracks.values,
    ]) {
      track.enabled = !isDeafened;
    }
  }

  // ── Track getters for the UI ──────────────────────────────────────────────

  MediaStreamTrack? get localVideoTrack => _localVideoTrack;
  MediaStreamTrack? get localScreenTrack => _localScreenTrack;

  MediaStreamTrack? remoteVideoTrackFor(String userId) =>
      _remoteVideoTracks[userId];

  MediaStreamTrack? remoteScreenTrackForShare(String shareId) =>
      _remoteScreenTracks[shareId];

  /// The first share this participant is running. Kept for the single-share
  /// rendering the call and channel screens do today; a multi-share UI should
  /// address shares by id via [remoteScreenTrackForShare].
  MediaStreamTrack? remoteScreenTrackFor(String userId) {
    for (final shareId in _sharesOf(userId)) {
      final track = _remoteScreenTracks[shareId];
      if (track != null) return track;
    }
    return null;
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
    final media = _media;
    final mediaSessionId = _mediaSessionId;
    if (pc == null || media == null || mediaSessionId == null) return const [];

    final offer = await pc.createOffer();
    await pc.setLocalDescription(offer);

    final response = await media.negotiate(
      mediaSessionId: mediaSessionId,
      sessionDescription: {'type': offer.type, 'sdp': offer.sdp},
      tracks: await buildTracks(pc),
    );

    await pc.setRemoteDescription(
      _toSessionDescription(response.sessionDescription),
    );

    if (response.requiresImmediateRenegotiation) {
      final reOffer = await pc.createOffer();
      await pc.setLocalDescription(reOffer);
      final reneg = await media.renegotiate(
        mediaSessionId: mediaSessionId,
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

  // flutter_webrtc's RTCRtpTransceiver.mid is a snapshot taken when
  // addTransceiver() returns - before the SDP that actually assigns mids
  // exists - and is never refreshed after setLocalDescription() the way a
  // browser's live `mid` property is. Reading it straight off `transceiver`
  // here always sends an empty mid, which the SFU rejects outright
  // ("Missing mid in track"). getTransceivers() makes a fresh native call and
  // returns the real, current mid.
  //
  // transceiverId can't be used to find the same transceiver again - on
  // Android (PeerConnectionObserver.java) it's *derived from* mid itself
  // (`transceiver.getMid() ?? randomUUID()`), so it's a fresh random value
  // every time it's read before mid is assigned, and a *different* value (the
  // real mid) once mid becomes available. The "same" transceiver therefore
  // never compares equal to itself across that gap. The sender's local track
  // id is what's actually stable.
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
        if (owner.shareId != null) {
          _remoteScreenTracks[owner.shareId!] = track;
        }
      case TrackKind.screenAudio:
        track.enabled = !_deafened;
        if (owner.shareId != null) {
          _remoteScreenAudioTracks[owner.shareId!] = track;
        }
    }
  }
}
