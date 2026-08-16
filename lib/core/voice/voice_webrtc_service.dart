import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'package:livekit_client/livekit_client.dart';

import '../../features/billing/data/models/entitlement_degradation_dto.dart';
import '../diagnostics/voice_diagnostics.dart';
import '../media/camera_permission.dart';
import '../media/screen_share_service.dart';
import 'tile_heights.dart';
import 'track_naming.dart';
import 'video_layers.dart';
import 'voice_identity.dart';
import 'voice_media_api.dart';
import 'voice_media_dto.dart';
import 'voice_subscription_set.dart';
import 'voice_video_feed.dart';

/// The media half of one voice room - connection, publication and subscription,
/// for a guild voice channel and a direct call alike.
///
/// There is one implementation because there is one server implementation. The
/// two room kinds differ only in the routes their [VoiceMediaApi] talks to;
/// every rule below is identical on both sides, and having written them twice is
/// how they drifted apart before.
///
/// # What this class is, now that there is no negotiation
///
/// The SFU is LiveKit and the SDK owns the peer connection, renegotiation and
/// reconnect. There is no SDP relayed through this backend, no transceiver mid
/// named to anybody, and no server-minted session id that can go stale. What is
/// left here is the part the SDK does not know about:
///
///  * mapping SFU identities back to user ids, so a track can be attributed;
///  * naming published tracks to the convention the roster agrees on;
///  * **declaring** each publish to the backend, which is what makes it visible
///    to everything in the product that is not the media itself;
///  * honouring the subscription set - deciding what to pull and at what layer,
///    which nothing enforces any more.
///
/// Audio plays automatically once its track is subscribed. Video and screen
/// tracks do not render anywhere on their own; the UI attaches a renderer to
/// whatever the track getters here currently return.
class VoiceWebRtcService {
  VoiceWebRtcService({VoiceDiagnostics? diagnostics})
    : _diagnostics = diagnostics ?? VoiceDiagnostics.shared;

  /// Where every failure this class swallows is written down. Injectable so a
  /// test can assert on the trail rather than on a debug print.
  final VoiceDiagnostics _diagnostics;

  final ScreenShareService _screenShareService = ScreenShareService();

  /// Reported to the server rather than acted on locally: which layer this
  /// client is served is the server's decision, and the tile size is the only
  /// input it has for making it. Posts through whatever [VoiceMediaApi] is
  /// current, so a report that arrives before [connectTo] - or after
  /// [disconnect] - is dropped rather than throwing at a UI callback.
  late final VoiceTileHeights _tileHeights = VoiceTileHeights(
    send: (heights) async {
      final set = await _media?.updateSubscriber(tileHeights: heights);
      _adoptSubscriptionSet(set);
    },
  );

  VoiceMediaApi? _media;
  Room? _room;
  VoiceConnectionDto? _connection;

  /// What the server has said this client should be pulling. Null inside means
  /// "everyone who is `Publishing`", which is the ordinary small room.
  final VoiceSubscriptionPlan _plan = VoiceSubscriptionPlan();

  CancelListenFunc? _roomEvents;

  /// The SFU behind this connection, as the server declared it. Read rather
  /// than branched on below: the surface is backend-neutral, and the one
  /// decision it drives - "can this build drive this room at all" - is made
  /// once in [connectTo].
  String? get mediaBackend => _connection?.backend;

  /// What the connection token actually grants, which is not the same question
  /// as what the UI would like to offer. Both default to true before a
  /// connection exists so a control is not disabled while it is being built.
  bool get canPublishAudio => _connection?.canPublishAudio ?? true;
  bool get canPublishVideo => _connection?.canPublishVideo ?? true;

  /// Whether the microphone has been published *and declared*. The roster does
  /// not know about a publish until the declaration lands, so this - not merely
  /// "a track exists" - is what the heartbeat asserts.
  bool _publishedLocalAudio = false;

  LocalAudioTrack? _localAudioTrack;
  LocalVideoTrack? _localVideoTrack;
  LocalVideoTrack? _localScreenTrack;
  String? _activeShareId;

  /// Which way the camera this device publishes from is pointing.
  ///
  /// Held here rather than read back off the track: `getSettings()` does not
  /// report a facing mode on either platform, and the SDK's own copy lives on
  /// `currentOptions`, which is replaced wholesale on every restart. It is also
  /// the answer to a question the UI asks constantly - a front camera is
  /// mirrored in the self-preview and a back one must not be.
  ///
  /// Survives the camera being turned off and on again within a room, so the
  /// side you chose is still the side you get; reset by [disconnect], because
  /// carrying a back camera into the next call is not a choice anybody made.
  CameraPosition _cameraPosition = CameraPosition.front;

  /// Guards [switchCamera] against re-entry. The flip stops the capture and
  /// opens the other camera, and two of those overlapping is how a device ends
  /// up with the picture from one camera and the mirroring of the other.
  bool _switchingCamera = false;

  /// The publications behind the tracks above.
  ///
  /// Held separately because unpublishing is addressed by publication sid, and
  /// a *track's* sid is nullable - it is only assigned once the publication
  /// exists, so reading it back off the track is a null check on every teardown
  /// path for a value that was never in doubt.
  LocalTrackPublication? _localVideoPub;
  LocalTrackPublication? _localScreenPub;
  LocalTrackPublication? _localScreenAudioPub;

  /// Remote tracks by the key they are addressed under. Screen tracks are keyed
  /// by `shareId` rather than by user: one participant can run more than one
  /// share, and the snapshot models them as a list for exactly that reason.
  ///
  /// Audio is held as a bare track because nothing renders it - it plays on
  /// arrival, and the only thing done to it locally is [setDeafened]. Video is
  /// held as a [_RemoteVideo], which keeps the stream the renderer needs and the
  /// health readings that explain a tile that stays black.
  final Map<String, rtc.MediaStreamTrack> _remoteAudioTracks = {};
  final Map<String, _RemoteVideo> _remoteVideo = {};
  final Map<String, _RemoteVideo> _remoteScreens = {};
  final Map<String, rtc.MediaStreamTrack> _remoteScreenAudioTracks = {};
  final Map<String, String> _shareOwners = {};

  /// Everything this client has been asked to pull, whether or not the
  /// publication exists yet.
  ///
  /// The window this covers is narrower than the old publish-before-subscribe
  /// one but has not closed: a cubit starts handling `ParticipantJoined` the
  /// moment its join/accept response lands, while [connectTo] is still awaiting
  /// the connection round trip and the SDK's own handshake. A request that
  /// arrives then has no publication to act on, and dropped it never comes back
  /// - nothing replays it short of a full resync.
  final Map<String, _WantedTrack> _wanted = {};

  /// Called whenever the remote tracks the getters below hand out change - one
  /// arriving, or one being dropped.
  ///
  /// Nothing else announces an arrival, and an arrival is not the same event as
  /// the subscribe that asked for it. `MediaStreamTrack`s cannot live in
  /// `Equatable` cubit state, so the screens re-read them from here and rely on
  /// the cubit emitting to know when to look - which means an arrival nobody is
  /// told about is a tile that keeps the placeholder it was built with.
  void Function()? onTracksChanged;

  /// Called when a publish succeeded with less than it asked for.
  ///
  /// **A success callback, not an error one.** A clamped publish is a `200`
  /// with the whole normal body in it: the track is up, the picture is flowing,
  /// and the only thing that differs is the rung. Nothing here rolls back on it
  /// and the owner must not either - it exists so the room can say "you are
  /// sharing at 720p30" while somebody is looking at the room, which is a
  /// sentence with a short shelf life and no other delivery.
  void Function(List<EntitlementDegradationDto> degradations)? onPublishReduced;

  /// Called when the SFU's audio-level detection changes its mind about whether
  /// this device is talking.
  ///
  /// **Raw, and not fit to send anywhere as it stands.** It is the input to
  /// `VoiceSpeakingDetector`, which is what applies the hysteresis §6.5 puts on
  /// the client: the server admits a speaker the instant it is told, so an
  /// un-debounced report of a cough costs every other client in the room a
  /// resubscription.
  void Function(bool isSpeaking)? onLocalSpeakingChanged;

  /// Called when the SDK has **given up** reconnecting and the media is gone.
  ///
  /// Not a blip: the SDK runs its own reconnect ladder, resuming with the token
  /// and URL it already holds, and that is correct - a room is placed on a node
  /// once and is never moved while it exists, so the cached URL cannot become
  /// the wrong one. This fires only when that ladder is exhausted, which in
  /// practice means the token outlived its TTL while the device was asleep or
  /// in a tunnel.
  ///
  /// The answer is a fresh connection - it is cheap, it does not touch the
  /// roster and only the token is new - followed by republishing. That sequence
  /// belongs to the room's owner, because only it knows what this client was
  /// publishing and what it should re-subscribe to afterwards.
  void Function()? onMediaDisconnected;

  /// Called with a video publication the SFU is advertising that nothing has
  /// asked for - see `_reportUnknownPublications` for the case it exists to
  /// close. The owner decides whether to draw it and subscribes through the
  /// ordinary route; nothing is pulled on the strength of this alone.
  void Function(VoicePublicationDiscovery discovery)? onPublicationDiscovered;

  /// Whether the server is currently managing this client's subscriptions.
  bool get hasManagedSubscriptions => _plan.isManaged;

  /// Who the server ranks as talking, in its order.
  ///
  /// **An ordering hint, not a speaking indicator.** The per-participant
  /// "is talking" badge is driven by the `SpeakingChanged` relay, which is
  /// per-user and immediate; this is a ranked subset that moves at the pace the
  /// server recomputes plans. Writing the badge from this as well makes the two
  /// fight - the coarse set clearing a flag the fine relay had just set - so
  /// nothing here does, and a UI that wants speaker ordering reads this
  /// directly.
  ///
  /// Empty when nothing is ranked, which is every room below the threshold.
  List<String> get activeSpeakers => _plan.activeSpeakers;

  /// Keys of tracks wanted but not yet held. Exposed because the resolution
  /// itself needs a live room, so the queueing half is what unit tests reach.
  @visibleForTesting
  Iterable<String> get pendingSubscribeKeys => _wanted.keys
      .where((k) => !_isHeld(k))
      .toList();

  bool _deafened = false;

  /// Whether this client asked for the teardown, so the SDK's own disconnect
  /// event is not reported as a connection that was lost.
  bool _disconnecting = false;

  /// Which connection attempt is current. Raised by [connectTo] and by
  /// [disconnect], and read at every checkpoint inside [_connectAttempt]: an
  /// attempt whose generation has moved on is one whose room nobody wants.
  int _generation = 0;

  /// The attempt in flight, so [disconnect] can wait for it to abandon itself
  /// rather than racing it to the same room.
  Future<void>? _connecting;

  /// How long the SDK is given to close a room before the local teardown
  /// proceeds without it.
  ///
  /// Shorter than the SDK's own ten seconds on purpose: the ten is its bound for
  /// a pathological socket, and nothing after this point needs the socket to
  /// have closed. Leaving has to feel local, and the server has its own liveness
  /// sweep for a session that goes quiet.
  static const Duration _roomCloseTimeout = Duration(seconds: 3);

  /// The last raw speaking state seen, so [onLocalSpeakingChanged] fires on
  /// transitions rather than on every active-speaker recomputation - which
  /// happens whenever *anybody* in the room starts or stops.
  bool _localSpeaking = false;

  /// This connection's identity, or null while not publishing - the value the
  /// heartbeat asserts. Reported honestly: claiming a session that carries
  /// nothing is what the server's reconcile pass exists to correct.
  String? get mediaSessionId =>
      _publishedLocalAudio ? _connection?.sessionHandle : null;

  /// The microphone track name to assert on the heartbeat, or null when not
  /// publishing.
  String? get publishedAudioTrackName =>
      _publishedLocalAudio ? TrackNaming.audio : null;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// Steps 2-4 of the connection lifecycle: mint a connection, connect the SDK
  /// to it, publish the microphone and declare it. Joining (step 1) already
  /// happened - it is an authorisation decision, not a media one, and the
  /// caller holds the snapshot it produced.
  ///
  /// `autoSubscribe: false` is not a detail. It is what puts §6 in charge of
  /// what this client pulls instead of the room, and without it a large room
  /// quietly subscribes to everybody and pays for it with nobody the wiser.
  ///
  /// **Cancellable, and it has to be.** Every step below is a round trip - the
  /// connection mint, the SFU handshake, the microphone - and a person who taps
  /// a channel and changes their mind is inside one of them. [disconnect] raises
  /// the generation, and every checkpoint here abandons and tears down whatever
  /// it has built so far. Without that the room this call opens is one nothing
  /// holds a reference to: it stays connected, keeps the microphone live, and -
  /// because the SFU keys participants by identity and drops an earlier session
  /// that reappears under the same one - is what kicks the *next* connection off
  /// the air. That is the "could not connect" a fast rejoin produces.
  Future<void> connectTo(VoiceMediaApi media) async {
    final generation = ++_generation;
    _media = media;
    _disconnecting = false;
    final attempt = _connectAttempt(media, generation);
    _connecting = attempt;
    try {
      await attempt;
    } finally {
      if (identical(_connecting, attempt)) _connecting = null;
    }
  }

  Future<void> _connectAttempt(VoiceMediaApi media, int generation) async {
    // True once the room this attempt is building is no longer the room anybody
    // wants. Read after every await rather than once: the whole of this method
    // is time somebody can spend leaving.
    bool superseded() => generation != _generation || _disconnecting;

    final connection = await media.createConnection(primary: true);
    // The handshake declares its backend so a client picks a media layer from a
    // stated value rather than inferring one. An unrecognised backend means
    // this build cannot drive the room - guessing would drive a transport with
    // different semantics and fail as if the network were at fault.
    if (!supportedVoiceBackends.contains(connection.backend)) {
      _diagnostics.record(
        VoiceFaultCodes.backend,
        subject: media.roomKey.toString(),
        detail: 'server offered "${connection.backend}"',
      );
      throw UnsupportedVoiceBackendException(connection.backend);
    }
    if (superseded()) throw const VoiceConnectSuperseded();
    _connection = connection;

    final room = Room(
      roomOptions: const RoomOptions(
        // Deliberately off, and a departure from the SDK's usual advice.
        // Adaptive stream sizes a subscription from LiveKit's own video
        // widgets, which this app does not use - it renders tracks through
        // `RTCVideoRenderer` directly. With no registered views it concludes
        // every track is invisible and disables it, which is every tile going
        // black. The measurement it would provide is one this client already
        // reports, to the server, as `tileHeights` - and the server answers it
        // with the layer applied in [_applyLayer].
        adaptiveStream: false,
        // Stops publishing layers nobody is subscribed to, which is the
        // publisher-side half of the same saving and needs no view geometry.
        dynacast: true,
      ),
    );
    _room = room;
    _roomEvents = room.events.listen(_handleRoomEvent);

    try {
      await room.connect(
        connection.url,
        connection.token,
        connectOptions: const ConnectOptions(autoSubscribe: false),
      );
    } catch (_) {
      await _abandon(room);
      rethrow;
    }
    if (superseded()) {
      await _abandon(room);
      throw const VoiceConnectSuperseded();
    }

    final track = await LocalAudioTrack.create();
    if (superseded()) {
      await _releaseAudio(track);
      await _abandon(room);
      throw const VoiceConnectSuperseded();
    }
    try {
      await room.localParticipant?.publishAudioTrack(
        track,
        publishOptions: const AudioPublishOptions(name: TrackNaming.audio),
      );
    } catch (_) {
      // The one path where capture succeeded and publication did not. A
      // microphone left open against a publish the SFU refused is a lit
      // indicator over nothing - the same rule [publishLocalVideo] follows for
      // the camera.
      await _releaseAudio(track);
      await _abandon(room);
      rethrow;
    }
    _localAudioTrack = track;
    // Set from the line above rather than from the declaration below, because
    // it is what the *heartbeat* asserts and the heartbeat has to be honest.
    // Media is flowing from here whether or not the declaration lands, and a
    // client that reported `null` because a declaration failed would have the
    // server correct its record in the wrong direction - telling peers to drop
    // somebody who is, in fact, talking.
    _publishedLocalAudio = true;

    // The media is live already; this is what makes it visible to the roster,
    // the viewer counts and everybody else's UI. A failure here is recoverable
    // rather than fatal: the next heartbeat asserts the same state and the
    // server reconciles from it.
    try {
      await _declarePublish([TrackNaming.audio]);
    } catch (e, s) {
      _diagnostics.record(
        VoiceFaultCodes.publish,
        subject: media.roomKey.toString(),
        detail: 'microphone published but not declared; heartbeat will repair',
        error: e,
        stackTrace: s,
      );
    }

    await rtc.Helper.setSpeakerphoneOnButPreferBluetooth();
    _resolveWanted();
  }

  /// Tears down a room this attempt built and nobody wants, without disturbing
  /// whatever has replaced it.
  ///
  /// Guarded on identity throughout: by the time an abandoned attempt gets here
  /// a *newer* connection may already own [_room], and clearing it would take
  /// the live room down with the dead one.
  Future<void> _abandon(Room room) async {
    if (identical(_room, room)) {
      await _roomEvents?.call();
      _roomEvents = null;
      _room = null;
      _connection = null;
    }
    await _closeRoom(room);
  }

  Future<void> _releaseAudio(LocalAudioTrack track) async {
    try {
      await track.stop();
      await track.dispose();
    } catch (e) {
      _diagnostics.record(
        VoiceFaultCodes.connect,
        detail: 'microphone was not released after an abandoned connect',
        error: e,
      );
    }
  }

  /// Closes one room, bounded and never throwing.
  ///
  /// **The SDK's own `disconnect()` can hang for ten seconds and then throw**,
  /// and on the exact path this app hits most: it awaits an
  /// `EngineDisconnectedEvent` that `Engine.disconnect()` has *already emitted*
  /// synchronously whenever the engine was not `connected` - which is every
  /// room torn down before its handshake finished, i.e. every fast leave. The
  /// listener subscribes after the fact, the broadcast controller does not
  /// replay, and `waitFor` times out.
  ///
  /// Unguarded, that `TimeoutException` propagated out of [disconnect] and took
  /// the rest of the teardown with it - the room, the microphone and the media
  /// API were all left set, and the caller's own `POST .../voice/leave` never
  /// ran, so the server still had this device in the channel. The next join then
  /// collided with a membership that should not have existed. Bounding it here
  /// is what makes leaving a local operation again.
  Future<void> _closeRoom(Room room) async {
    try {
      await room.disconnect().timeout(_roomCloseTimeout);
    } catch (e) {
      _diagnostics.record(
        VoiceFaultCodes.superseded,
        detail: 'room disconnect did not complete cleanly',
        error: e,
        // Not an error: the local teardown below is unconditional, and the SFU
        // drops an abandoned session on its own liveness window either way.
        isError: false,
      );
    }
    try {
      await room.dispose();
    } catch (_) {
      // Disposing twice, or disposing a room whose engine is already gone, is
      // not a condition anybody can act on.
    }
  }

  /// Releases the media half of this room. **Never throws, and always completes
  /// the local reset**, because its caller has a `POST .../voice/leave` to send
  /// afterwards and a leave that does not reach the server is a membership
  /// nobody can clear.
  Future<void> disconnect() async {
    // Set before anything closes, so the SDK's own disconnect event is not
    // mistaken for the connection being lost - and so an in-flight [connectTo]
    // abandons at its next checkpoint.
    _disconnecting = true;
    _generation++;

    // Awaited so the room an in-flight attempt is opening is torn down by the
    // attempt itself. Its failure is the abandonment, which is the expected
    // outcome here rather than something to report.
    final pending = _connecting;
    if (pending != null) {
      try {
        await pending;
      } catch (_) {}
    }

    if (_localScreenTrack != null && Platform.isAndroid) {
      try {
        await _screenShareService.stop();
      } catch (e) {
        _diagnostics.record(
          VoiceFaultCodes.connect,
          detail: 'screen capture service did not stop',
          error: e,
        );
      }
    }
    try {
      await _roomEvents?.call();
    } catch (_) {
      // A listener that is already cancelled.
    }
    _roomEvents = null;
    final room = _room;
    _room = null;
    if (room != null) await _closeRoom(room);

    _media = null;
    _connection = null;
    _publishedLocalAudio = false;
    _localAudioTrack = null;
    _localVideoTrack = null;
    _localScreenTrack = null;
    _localVideoPub = null;
    _localScreenPub = null;
    _localScreenAudioPub = null;
    _activeShareId = null;
    _cameraPosition = CameraPosition.front;
    _switchingCamera = false;
    _pinnedUserId = null;
    _audibleShareId = null;
    // Reset with the rest: a rebuilt transport reports its own visibility from
    // the next lifecycle change, and a stale `true` here would suppress the
    // report that turns video back on.
    _paused = false;
    _remoteAudioTracks.clear();
    for (final video in [..._remoteVideo.values, ..._remoteScreens.values]) {
      video.dispose();
    }
    _remoteVideo.clear();
    _remoteScreens.clear();
    _remoteScreenAudioTracks.clear();
    _shareOwners.clear();
    _wanted.clear();
    _plan.reset();
    // Cleared rather than flushed: the connection these sizes described is
    // gone, and the server drops a departed subscriber's entry anyway. A rebuilt
    // transport is reported to from the next layout.
    _tileHeights.clear();
    _deafened = false;
    _localSpeaking = false;
  }

  // ── Publishing ────────────────────────────────────────────────────────────

  /// Declares tracks that are already published, handing any reduction to
  /// [onPublishReduced].
  Future<void> _declarePublish(
    List<String> trackNames, {
    VideoPublishIntent? video,
  }) async {
    final media = _media;
    if (media == null) return;
    final result = await media.declarePublish(
      trackNames: trackNames,
      video: video?.toJson(),
    );
    if (result.degradations.isNotEmpty) {
      onPublishReduced?.call(result.degradations);
    }
    if (result.isLayerCapped) {
      // Not an error and not something to roll back: the track is up and
      // flowing, and every viewer is simply held below the top layer. Logged
      // because it is otherwise invisible from this side - the picture looks
      // exactly as it should locally.
      debugPrint(
        '[Voice] publish capped at layer ${result.maxLayer} '
        '(rung ${result.rung ?? 'unstated'}) for $trackNames',
      );
    }
  }

  /// Starts local camera capture and publishes it under [TrackNaming.camera].
  /// The server classifies it as `kind: "video"` from the name alone, so
  /// nothing else is needed. No-ops if the camera is already on.
  ///
  /// [target] is what the room's granted rung permits, resolved from the ladder
  /// the server publishes - see `cameraTargetFor`. It drives three things that
  /// have to agree: the capture constraints, the top rung of the simulcast
  /// ladder, and the size declared on the publish. Null falls back to
  /// [VideoPublishIntent.conservative], which is what this client captured at
  /// before any of it was gated.
  ///
  /// What reaches the wire is read back off the track rather than copied from
  /// [target]. The constraints are `ideal`, so a handset that cannot reach the
  /// target encodes less, and declaring the request instead of the picture
  /// earns a cap that was not needed.
  ///
  /// **Releases the camera if the declaration is refused.** That is the one
  /// path where capture succeeded and publication did not, and a camera left
  /// running against a track the server refused is a lit indicator light over
  /// nothing.
  Future<void> publishLocalVideo({VideoPublishIntent? target}) async {
    final room = _room;
    if (_localVideoTrack != null || room == null) return;
    if (!await ensureCameraPermission()) {
      throw StateError('Camera permission denied');
    }
    final asked = target ?? VideoPublishIntent.conservative;
    final track = await LocalVideoTrack.createCameraTrack(
      CameraCaptureOptions(
        // Whichever side was last chosen, so turning the camera off and on
        // again does not silently walk it back to the front one.
        cameraPosition: _cameraPosition,
        params: VideoParameters(
          dimensions: VideoDimensions(
            VideoLayers.widthFor(asked.height),
            asked.height,
          ),
          encoding: VideoEncoding(
            maxFramerate: asked.framerate,
            maxBitrate: 1200 * 1000,
          ),
        ),
      ),
    );
    _localVideoTrack = track;
    final declared = VideoPublishIntent.fromTrack(
      track.mediaStreamTrack,
      fallback: asked,
    );
    try {
      _localVideoPub = await room.localParticipant?.publishVideoTrack(
        track,
        publishOptions: VideoPublishOptions(
          name: TrackNaming.camera,
          // Named rather than defaulted, and the reasoning - which is about
          // what a handset's H.264 encoder can honestly declare, not about the
          // SFU - is on [publishVideoCodec].
          videoCodec: publishVideoCodec,
          videoSimulcastLayers: VideoLayers.cameraFor(declared.height),
        ),
      );
      await _declarePublish([TrackNaming.camera], video: declared);
    } catch (_) {
      _localVideoTrack = null;
      _localVideoPub = null;
      await track.stop();
      await track.dispose();
      rethrow;
    }
  }

  /// Whether the local camera is currently the front-facing one - the only
  /// thing about it the UI needs, and deliberately not the SDK's enum: the
  /// surface of this class stays backend-neutral so the screens above it never
  /// import a media SDK to render a button.
  bool get isFrontCamera => _cameraPosition == CameraPosition.front;

  /// Flips the local camera between front and back, keeping the publication.
  ///
  /// The capture is restarted and the new track swapped into the existing
  /// sender, so the publication, its name, its declared size and its simulcast
  /// ladder all survive: nothing is unpublished, nothing is re-declared, and
  /// the roster has nothing to notice. Peers keep receiving the same track and
  /// simply see a different picture on it.
  ///
  /// The underlying `MediaStreamTrack` *is* replaced, though, which is why
  /// [onTracksChanged] fires either way - every renderer in the UI is holding
  /// the old one, and a self-preview attached to a stopped track is a frozen
  /// frame rather than an error anybody would see.
  ///
  /// **The stored side only moves if the flip actually happened.** A device
  /// with one camera, or a restart the platform refuses, leaves the original
  /// capture running; recording the other side anyway would mirror a back
  /// camera - the failure would look like the button working and the picture
  /// being wrong.
  Future<void> switchCamera() async {
    final track = _localVideoTrack;
    if (track == null || _switchingCamera) return;
    _switchingCamera = true;
    try {
      final next = _cameraPosition.switched();
      await track.setCameraPosition(next);
      _cameraPosition = next;
    } catch (e) {
      _diagnostics.record(
        VoiceFaultCodes.connect,
        detail: 'camera flip failed; the previous camera is still running',
        error: e,
      );
    } finally {
      _switchingCamera = false;
    }
    onTracksChanged?.call();
  }

  Future<void> stopLocalVideo() async {
    final publication = _localVideoPub;
    if (_localVideoTrack == null) return;
    _localVideoTrack = null;
    _localVideoPub = null;
    // `RoomOptions.stopLocalTrackOnUnpublish` defaults to true, so this stops
    // the capture as well as removing the publication - the camera indicator
    // goes out with the track rather than after it.
    if (publication != null) {
      await _room?.localParticipant?.removePublishedTrack(publication.sid);
    }
    await _unpublish([TrackNaming.camera]);
  }

  /// Starts screen capture and publishes it as `screen-{shareId}`, plus
  /// `screen-audio-{shareId}` when the platform actually handed us the shared
  /// application's audio.
  ///
  /// Both halves are declared in the *same* call, which is what lets a
  /// receiving client group them into one tile from the two `TrackPublished`
  /// events that follow. A share may legitimately be video-only - on iOS
  /// ReplayKit and on Android below API 29 there is no app audio to capture -
  /// so the audio half is conditional, never assumed.
  Future<void> startScreenShare(String shareId) async {
    final room = _room;
    if (_localScreenTrack != null || room == null) return;
    if (Platform.isAndroid) await _screenShareService.start();

    final List<LocalTrack> tracks;
    try {
      tracks = await LocalVideoTrack.createScreenShareTracksWithAudio(
        const ScreenShareCaptureOptions(captureScreenAudio: true),
      );
    } catch (e) {
      if (Platform.isAndroid) await _screenShareService.stop();
      rethrow;
    }

    final videoTrack = tracks.whereType<LocalVideoTrack>().firstOrNull;
    final audioTrack = tracks.whereType<LocalAudioTrack>().firstOrNull;
    if (videoTrack == null) {
      for (final track in tracks) {
        await track.stop();
      }
      if (Platform.isAndroid) await _screenShareService.stop();
      throw StateError('Screen capture produced no video track');
    }

    _localScreenTrack = videoTrack;
    _activeShareId = shareId;

    // A share's size is not chosen before capture, but it is knowable after it:
    // the track carries what the platform actually opened. An undeclared share
    // is an uncapped one, and a share is the expensive half of the room - a 4K
    // display fanned out at its top layer to every viewer is the bill this
    // declaration exists to bound.
    final declared = _screenIntent(videoTrack.mediaStreamTrack);

    try {
      _localScreenPub = await room.localParticipant?.publishVideoTrack(
        videoTrack,
        publishOptions: VideoPublishOptions(
          name: TrackNaming.screenTrack(shareId),
          // Same codec as the camera, and for the same reason: a share is the
          // publish most worth spending H.264 High on, and the platform this
          // runs on is the one that cannot declare it. See [publishVideoCodec].
          videoCodec: publishVideoCodec,
          screenShareSimulcastLayers: VideoLayers.screenFor(
            declared?.height ?? VideoPublishIntent.conservative.height,
          ),
        ),
      );
      if (audioTrack != null) {
        _localScreenAudioPub = await room.localParticipant?.publishAudioTrack(
          audioTrack,
          publishOptions: AudioPublishOptions(
            name: TrackNaming.screenAudioTrack(shareId),
          ),
        );
      }
      await _declarePublish([
        TrackNaming.screenTrack(shareId),
        if (audioTrack != null) TrackNaming.screenAudioTrack(shareId),
      ], video: declared);
    } catch (_) {
      _localScreenTrack = null;
      _localScreenPub = null;
      _localScreenAudioPub = null;
      _activeShareId = null;
      await videoTrack.stop();
      await audioTrack?.stop();
      if (Platform.isAndroid) await _screenShareService.stop();
      rethrow;
    }
  }

  /// What a share declares, from what the platform reports it captured.
  ///
  /// Three sources, in falling order of authority: the track's own settings,
  /// this device's display size, and nothing. The middle one is not a guess - a
  /// mobile share captures the display it runs on, so it is the same number
  /// from the other side - and it exists because some platforms hand back a
  /// track with no settings on it at all. When even that is unavailable the
  /// field is omitted, because a number invented to fill it would be a false
  /// statement rather than a missing one.
  VideoPublishIntent? _screenIntent(rtc.MediaStreamTrack track) {
    final declared = VideoPublishIntent.fromTrack(
      track,
      fallback: displayCaptureIntent() ?? VideoPublishIntent.unstated,
    );
    return declared.isStated ? declared : null;
  }

  /// Stops the local share and unpublishes its tracks.
  ///
  /// This is only half of stopping: the caller also announces
  /// `ScreenShareStopped` over the hub. Both are needed. The hub event tells
  /// people; this releases the media and the egress behind it.
  Future<void> stopScreenShare() async {
    final videoTrack = _localScreenTrack;
    final shareId = _activeShareId;
    if (videoTrack == null || shareId == null) return;
    _localScreenTrack = null;
    _activeShareId = null;

    final local = _room?.localParticipant;
    final videoPub = _localScreenPub;
    final audioPub = _localScreenAudioPub;
    _localScreenPub = null;
    _localScreenAudioPub = null;
    if (videoPub != null) await local?.removePublishedTrack(videoPub.sid);
    if (audioPub != null) await local?.removePublishedTrack(audioPub.sid);
    // Both halves are declared closed unconditionally: closing a track that was
    // never published is a no-op server-side, and leaving a live screen-audio
    // track behind a stopped video one is a share nobody can see but everyone
    // hears.
    await _unpublish([
      TrackNaming.screenTrack(shareId),
      TrackNaming.screenAudioTrack(shareId),
    ]);
    if (Platform.isAndroid) await _screenShareService.stop();
  }

  Future<void> _unpublish(List<String> trackNames) async {
    try {
      await _media?.unpublish(trackNames: trackNames);
    } catch (_) {
      // Best-effort - the local track is already stopped either way.
    }
  }

  /// Declares a resolution change made without republishing.
  ///
  /// A ceiling computed once at publish time is one a later resolution change
  /// walks straight past, which on a share that switched from a document to a
  /// video is the difference the whole declaration exists to catch.
  Future<void> declareVideoChange(VideoPublishIntent video) async {
    if (!video.isStated) return;
    try {
      await _media?.declareVideo(video.toJson());
    } catch (e) {
      debugPrint('[Voice] resolution change was not declared: $e');
    }
  }

  // ── Subscribing ───────────────────────────────────────────────────────────

  /// Subscribes to a participant's microphone. The only thing that makes them
  /// audible, and only ever called for someone the snapshot reports as
  /// `Publishing`.
  Future<void> subscribeToParticipant({
    required String userId,
    required String mediaSessionId,
    required String trackName,
  }) async => _want(
    userId: userId,
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
  }) async => _want(
    userId: userId,
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
      _want(
        userId: userId,
        trackName: trackName,
        kind: descriptor.kind,
        shareId: descriptor.shareId ?? shareId,
      );
    }
    _resolveWanted();
  }

  /// One subscription key. Shares carry their id so a participant running two
  /// of them does not collide with themselves; microphone and camera have no
  /// share and keep the plain `userId|trackName` form.
  static String _subscriptionKey(
    String userId,
    String trackName,
    String? shareId,
  ) => shareId == null
      ? '$userId|$trackName'
      : '$userId|$trackName|$shareId';

  /// Records that this client wants a track, and pulls it if it can.
  void _want({
    required String userId,
    required String trackName,
    required TrackKind kind,
    String? shareId,
  }) {
    final key = _subscriptionKey(userId, trackName, shareId);
    _wanted[key] = _WantedTrack(
      userId: userId,
      trackName: trackName,
      kind: kind,
      shareId: shareId,
    );
    if (shareId != null) _shareOwners[shareId] = userId;
    _resolveWanted();
  }

  /// Brings the SDK's subscriptions in line with what is wanted *and* allowed.
  ///
  /// Two filters, and they are different questions. [_wanted] is what this
  /// client's UI has asked for; the subscription plan is what the server says
  /// it may have. A track has to pass both - and since the plan only ever
  /// removes, applying it can never break a subscription that was valid.
  ///
  /// Idempotent and cheap to call: it diffs against what is already subscribed
  /// rather than tearing down and rebuilding, because a set change usually
  /// moves one or two entries and a rebuild turns that into a reconnect.
  void _resolveWanted() {
    final room = _room;
    if (room == null) return;

    for (final participant in room.remoteParticipants.values) {
      final userId = VoiceIdentity.userIdOf(participant.identity);
      for (final publication in participant.trackPublications.values) {
        final name = publication.name;
        if (name.isEmpty) continue;
        final descriptor = TrackNaming.describe(name);
        final key = _subscriptionKey(userId, name, descriptor.shareId);
        final wanted = _wanted.containsKey(key);
        final allowed = _plan.allows(
          userId: userId,
          trackName: name,
          shareId: descriptor.shareId,
        );

        if (wanted && allowed) {
          if (!publication.subscribed) unawaited(publication.subscribe());
          _applyLayer(publication, userId: userId, trackName: name);
        } else if (publication.subscribed) {
          unawaited(publication.unsubscribe());
        }
      }
    }
  }

  /// Applies the layer the server chose for one video publication.
  ///
  /// This used to ride the subscribe the backend made on this client's behalf,
  /// so it bound whether the client cooperated or not. It does not any more: a
  /// tile reported as 120 pixels tall is served the top layer until something
  /// asks for less, and this is the only thing that asks.
  void _applyLayer(
    RemoteTrackPublication publication, {
    required String userId,
    required String trackName,
  }) {
    if (publication.kind != TrackType.VIDEO) return;
    if (!publication.subscribed) return;
    final layer = _plan.layerFor(userId: userId, trackName: trackName);
    unawaited(publication.setVideoQuality(videoQualityForLayer(layer)));
  }

  bool _isHeld(String key) {
    final wanted = _wanted[key];
    if (wanted == null) return false;
    return switch (wanted.kind) {
      TrackKind.audio => _remoteAudioTracks.containsKey(wanted.userId),
      TrackKind.video => _remoteVideo.containsKey(wanted.userId),
      TrackKind.screen => _remoteScreens.containsKey(wanted.shareId),
      TrackKind.screenAudio => _remoteScreenAudioTracks.containsKey(
        wanted.shareId,
      ),
    };
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
        _remoteVideo.remove(userId)?.dispose();
      case TrackKind.screen:
        if (shareId != null) _remoteScreens.remove(shareId)?.dispose();
      case TrackKind.screenAudio:
        if (shareId != null) _remoteScreenAudioTracks.remove(shareId);
    }
    _wanted.removeWhere(
      (key, wanted) =>
          wanted.userId == userId &&
          wanted.kind == kind &&
          wanted.shareId == shareId,
    );
    _resolveWanted();
    onTracksChanged?.call();
  }

  /// Drops both halves of one screen share. Called when the share stops, and
  /// when the viewer stops watching - egress is not free, and an unwatched
  /// stream that stays subscribed is exactly what the viewer protocol exists to
  /// avoid paying for.
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

  // ── Subscription sets ─────────────────────────────────────────────────────

  /// Adopts a subscription set from a snapshot, a `SubscriptionsChanged` or the
  /// reply to a report, and reconciles what is being pulled against it.
  ///
  /// Safe to call with the same set repeatedly - most calls are exactly that,
  /// since every snapshot carries the current set whether or not it moved.
  ///
  /// Nothing is emitted to the owner from here. A set change that adds or drops
  /// a track produces the SDK's own subscribe/unsubscribe events, and those
  /// already reach the UI through [onTracksChanged]; the roster itself does not
  /// move, because everyone stays rendered whatever the set says.
  void applySubscriptionSet(VoiceSubscriptionSetDto? set) {
    if (!_plan.adopt(set)) return;
    _resolveWanted();
  }

  /// Adopts the set that came back from a report this client just made.
  ///
  /// Null here means the *reply carried no set object at all* - an empty body,
  /// or one that did not parse - which is a server that did not answer rather
  /// than one revoking anything, so it is left alone. That is a different thing
  /// from a reply whose `tracks` is null, which **is** a revocation and reaches
  /// [applySubscriptionSet] intact.
  void _adoptSubscriptionSet(VoiceSubscriptionSetDto? set) {
    if (set == null) return;
    applySubscriptionSet(set);
  }

  // ── What this client is drawing ───────────────────────────────────────────

  /// Reports the rendered height of one tile, in device pixels, so the server
  /// can serve that publisher's video at a layer the tile can actually use.
  ///
  /// Safe to call on every layout: [VoiceTileHeights] debounces and only posts
  /// when the resulting map changes. [tileId] identifies the tile rather than
  /// the publisher - see there for why that distinction matters.
  void reportTileHeight({
    required String tileId,
    required String userId,
    required int devicePixels,
  }) => _tileHeights.set(
    tileId: tileId,
    userId: userId,
    devicePixels: devicePixels,
  );

  /// The tile is gone from the layout - the participant left the grid, or the
  /// screen it was on was closed.
  void forgetTile(String tileId) => _tileHeights.remove(tileId);

  String? _pinnedUserId;
  String? _audibleShareId;
  bool _paused = false;

  /// This client is backgrounded or hidden.
  ///
  /// **Drops video, never audio.** A backgrounded client is still in the
  /// conversation, and a phone in a pocket that stopped hearing the room would
  /// be a bug rather than a saving.
  Future<void> setPaused(bool paused) async {
    if (_paused == paused) return;
    _paused = paused;
    try {
      _adoptSubscriptionSet(await _media?.updateSubscriber(paused: paused));
    } catch (e) {
      debugPrint('[Voice] pause state was not recorded: $e');
    }
  }

  /// One publisher this client is looking at to the exclusion of the rest, and
  /// optionally the share whose audio it wants with them. Both null is "back to
  /// the grid".
  ///
  /// Two separate things ride on one call because they turn on and off at the
  /// same moment, and sending them separately would post the same body twice.
  ///
  ///  * **The pin** keeps a publisher subscribed whatever the ranking says, so
  ///    opening somebody who happens not to be talking still shows a picture.
  ///    Capped server-side, and a pin over the cap is dropped silently.
  ///  * **The share audio** is off by default for everybody, because most
  ///    shares carry none and distributing it doubles the stream count of the
  ///    most expensive thing in a room. Opening one full-screen is the clearest
  ///    statement a viewer can make that they want it.
  Future<void> setFocus({String? userId, String? shareId}) async {
    if (_pinnedUserId == userId && _audibleShareId == shareId) return;
    _pinnedUserId = userId;
    _audibleShareId = shareId;
    final media = _media;
    if (media == null) return;
    try {
      _adoptSubscriptionSet(
        await media.updateSubscriber(
          pinned: [?userId],
          screenAudioShares: [?shareId],
        ),
      );
    } catch (e) {
      debugPrint('[Voice] focus on ${userId ?? 'nobody'} was not recorded: $e');
    }
  }

  /// Publishers whose tile this client has collapsed. Video only - a collapsed
  /// tile stops paying for pixels, not for sound.
  Future<void> setPausedPublishers(List<String> userIds) async {
    try {
      _adoptSubscriptionSet(
        await _media?.updateSubscriber(pausedPublishers: userIds),
      );
    } catch (e) {
      debugPrint('[Voice] collapsed tiles were not recorded: $e');
    }
  }

  // ── Local controls ────────────────────────────────────────────────────────

  /// Mutes at the track, which is what stops the SFU receiving anything -
  /// rather than merely disabling the local track, which keeps the encoder
  /// running and the uplink paid for.
  Future<void> setMuted(bool isMuted) async {
    final track = _localAudioTrack;
    if (track == null) return;
    await (isMuted ? track.mute() : track.unmute());
  }

  Future<void> setSpeakerphoneOn(bool enable) =>
      rtc.Helper.setSpeakerphoneOn(enable);

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

  /// This device's own camera, as a feed.
  ///
  /// Carries the stream the SDK opened rather than one built here. The
  /// distinction is the difference between a preview that survives a camera flip
  /// and one that does not: `restartTrack` stops the old track and disposes its
  /// stream before opening the replacement, so anything the UI built around the
  /// old track is already invalid by the time it is used.
  ///
  /// No health, because nobody subscribes to their own picture and there are no
  /// receiver statistics to read.
  VoiceVideoFeed? get localVideoFeed => _feedOf(_localVideoTrack);
  VoiceVideoFeed? get localScreenFeed => _feedOf(_localScreenTrack);

  VoiceVideoFeed? remoteVideoFeedFor(String userId) =>
      _remoteVideo[userId]?.feed;

  VoiceVideoFeed? remoteScreenFeedForShare(String shareId) =>
      _remoteScreens[shareId]?.feed;

  /// The first share this participant is running. Kept for the single-share
  /// rendering the call and channel screens do today; a multi-share UI should
  /// address shares by id via [remoteScreenFeedForShare].
  VoiceVideoFeed? remoteScreenFeedFor(String userId) {
    for (final shareId in _sharesOf(userId)) {
      final feed = _remoteScreens[shareId]?.feed;
      if (feed != null) return feed;
    }
    return null;
  }

  static VoiceVideoFeed? _feedOf(LocalVideoTrack? track) => track == null
      ? null
      : VoiceVideoFeed(
          stream: track.mediaStream,
          track: track.mediaStreamTrack,
        );

  // ── Room events ───────────────────────────────────────────────────────────

  void _handleRoomEvent(RoomEvent event) {
    switch (event) {
      case TrackSubscribedEvent(:final participant, :final publication):
        _routeTrack(
          identity: participant.identity,
          publication: publication,
          track: publication.track,
        );
        // The layer the server chose is applied on a *subscribed* publication,
        // and it was not one when the subscribe was issued - `subscribed` means
        // the media has landed, which is this moment and not the earlier one. Up
        // to here nothing had asked for a layer since the subscribe, so every
        // tile was served the top rung until an unrelated resolve happened by.
        _resolveWanted();
      case TrackUnsubscribedEvent(:final participant, :final publication):
        _dropTrack(
          identity: participant.identity,
          trackName: publication.name,
        );
      case TrackMutedEvent(:final participant, :final publication):
        _setSenderMuted(participant.identity, publication.name, true);
      case TrackUnmutedEvent(:final participant, :final publication):
        _setSenderMuted(participant.identity, publication.name, false);
      case TrackSubscriptionExceptionEvent(:final participant, :final reason):
        // The one subscribe failure the SDK reports as an event rather than as
        // a rejected future. Without this it is a tile that never fills and no
        // record anywhere of having been refused.
        _diagnostics.record(
          VoiceFaultCodes.notSubscribed,
          subject: participant == null
              ? null
              : VoiceIdentity.userIdOf(participant.identity),
          detail: 'the SFU refused a subscribe: ${reason.name}',
        );
      case TrackPublishedEvent():
      case ParticipantConnectedEvent():
      case RoomConnectedEvent():
        // A publication this client may already be waiting for. The roster
        // event that names it arrives over the hub separately; this is the
        // moment the SDK can actually act on a want recorded earlier.
        _resolveWanted();
        _reportUnknownPublications();
      case ParticipantDisconnectedEvent(:final participant):
        _dropParticipant(VoiceIdentity.userIdOf(participant.identity));
      case ActiveSpeakersChangedEvent(:final speakers):
        // The SFU's own audio-level observer, which is a far better voice
        // detector than anything worth writing here - and the only one that
        // does not need a second audio tap on the local track.
        final identity = _room?.localParticipant?.identity;
        final speaking =
            identity != null && speakers.any((s) => s.identity == identity);
        if (speaking != _localSpeaking) {
          _localSpeaking = speaking;
          onLocalSpeakingChanged?.call(speaking);
        }
      case RoomReconnectedEvent():
        // The SDK resumed on its own. Subscriptions do not always survive a
        // full reconnect, so what this client wants is asserted again rather
        // than assumed - it is a diff, so a session that kept them does no
        // work.
        _resolveWanted();
        _reportUnknownPublications();
      case RoomDisconnectedEvent():
        // Only ever after the SDK's own ladder is exhausted. A teardown this
        // client asked for is excluded by the flag, because reporting that as
        // a lost connection would have the owner rebuild media for a room it
        // has just deliberately left.
        if (_disconnecting) break;
        onMediaDisconnected?.call();
      default:
        break;
    }
  }

  void _routeTrack({
    required String identity,
    required RemoteTrackPublication publication,
    required Track? track,
  }) {
    final trackName = publication.name;
    final mediaTrack = track?.mediaStreamTrack;
    if (track == null || mediaTrack == null || trackName.isEmpty) return;
    final userId = VoiceIdentity.userIdOf(identity);
    final descriptor = _describeChecked(trackName, publication, userId);

    switch (descriptor.kind) {
      case TrackKind.audio:
        mediaTrack.enabled = !_deafened;
        _remoteAudioTracks[userId] = mediaTrack;
      case TrackKind.video:
        _remoteVideo[userId]?.dispose();
        _remoteVideo[userId] = _watch(track, publication, subject: userId);
      case TrackKind.screen:
        final shareId = descriptor.shareId;
        if (shareId == null) return;
        _remoteScreens[shareId]?.dispose();
        _remoteScreens[shareId] = _watch(
          track,
          publication,
          subject: 'share:$shareId',
        );
        _shareOwners[shareId] = userId;
      case TrackKind.screenAudio:
        final shareId = descriptor.shareId;
        if (shareId == null) return;
        mediaTrack.enabled = !_deafened;
        _remoteScreenAudioTracks[shareId] = mediaTrack;
        _shareOwners[shareId] = userId;
    }
    // The media exists now, which is a different moment from the subscribe that
    // asked for it - and the only moment a viewer can render it.
    onTracksChanged?.call();
  }

  /// The descriptor for [trackName], checked against what the SDK says the
  /// track actually is.
  ///
  /// [TrackNaming.describe] classifies from the name alone and falls back to
  /// *camera* for anything it does not recognise, which is the right default
  /// while every publisher agrees on the convention and a silent disaster the
  /// moment one does not: a publisher whose microphone is published under the
  /// SDK's own default name would have its audio routed into the camera map and
  /// rendered as a black tile, with nothing refused anywhere.
  ///
  /// The SFU's own `kind` cannot disagree about audio versus video, so it is
  /// the tie-breaker - and the disagreement itself is worth recording, because
  /// it means two clients have drifted on the naming convention.
  TrackDescriptor _describeChecked(
    String trackName,
    RemoteTrackPublication publication,
    String userId,
  ) {
    final descriptor = TrackNaming.describe(trackName);
    final isAudioByName =
        descriptor.kind == TrackKind.audio ||
        descriptor.kind == TrackKind.screenAudio;
    final isAudioByKind = publication.kind == TrackType.AUDIO;
    if (isAudioByName == isAudioByKind) return descriptor;

    _diagnostics.record(
      VoiceFaultCodes.noDecode,
      subject: userId,
      detail:
          'track "$trackName" reads as ${descriptor.kind.name} by name and '
          '${publication.kind.name} by kind; trusting the SFU',
    );
    return TrackDescriptor(
      trackName: trackName,
      kind: isAudioByKind ? TrackKind.audio : TrackKind.video,
    );
  }

  /// Starts holding one incoming video track, with its health.
  _RemoteVideo _watch(
    Track track,
    RemoteTrackPublication publication, {
    required String subject,
  }) {
    final video = _RemoteVideo(
      stream: track.mediaStream,
      track: track.mediaStreamTrack,
      publication: publication,
    );
    video.listenTo(track);
    return video;
  }

  void _setSenderMuted(String identity, String trackName, bool muted) {
    if (trackName.isEmpty) return;
    final userId = VoiceIdentity.userIdOf(identity);
    final descriptor = TrackNaming.describe(trackName);
    final video = switch (descriptor.kind) {
      TrackKind.video => _remoteVideo[userId],
      TrackKind.screen => _remoteScreens[descriptor.shareId],
      _ => null,
    };
    video?.setSenderMuted(muted);
  }

  /// Reports publications the SFU is advertising that nothing has asked for.
  ///
  /// **The camera that was already on when you arrived.** A snapshot names an
  /// audio track and any shares; it does not name a camera, so the only thing
  /// that ever subscribed one was the `TrackPublished` relay - an event that is
  /// never replayed. Join a room where somebody is already on camera, or rebuild
  /// media after the SDK gave up, and their picture is one nothing in this
  /// client will ever ask for: no tile, or a tile that stays black for as long
  /// as they do not toggle the camera off and on again.
  ///
  /// Reported rather than subscribed here, because whether a picture should be
  /// drawn is the roster's question and the roster lives above this class. What
  /// comes back down is an ordinary [subscribeToTrack].
  void _reportUnknownPublications() {
    final report = onPublicationDiscovered;
    final room = _room;
    if (report == null || room == null) return;
    for (final participant in room.remoteParticipants.values) {
      final userId = VoiceIdentity.userIdOf(participant.identity);
      for (final publication in participant.trackPublications.values) {
        final name = publication.name;
        if (name.isEmpty || publication.kind == TrackType.AUDIO) continue;
        final descriptor = TrackNaming.describe(name);
        final key = _subscriptionKey(userId, name, descriptor.shareId);
        if (_wanted.containsKey(key)) continue;
        report(
          VoicePublicationDiscovery(
            userId: userId,
            trackName: name,
            kind: descriptor.kind,
            shareId: descriptor.shareId,
          ),
        );
      }
    }
  }

  void _dropTrack({required String identity, required String trackName}) {
    if (trackName.isEmpty) return;
    final userId = VoiceIdentity.userIdOf(identity);
    final descriptor = TrackNaming.describe(trackName);
    switch (descriptor.kind) {
      case TrackKind.audio:
        _remoteAudioTracks.remove(userId);
      case TrackKind.video:
        _remoteVideo.remove(userId)?.dispose();
      case TrackKind.screen:
        _remoteScreens.remove(descriptor.shareId)?.dispose();
      case TrackKind.screenAudio:
        _remoteScreenAudioTracks.remove(descriptor.shareId);
    }
    onTracksChanged?.call();
  }

  void _dropParticipant(String userId) {
    _remoteAudioTracks.remove(userId);
    _remoteVideo.remove(userId)?.dispose();
    for (final shareId in _sharesOf(userId)) {
      _remoteScreens.remove(shareId)?.dispose();
      _remoteScreenAudioTracks.remove(shareId);
      _shareOwners.remove(shareId);
    }
    onTracksChanged?.call();
  }
}

/// One incoming video track this client is holding, with the readings that
/// explain a tile that is not showing it.
///
/// The health is a [ValueNotifier] rather than part of cubit state because it
/// moves on the SDK's own statistics timer - once a second, per track - and
/// putting that through a cubit would rebuild an entire voice screen at that
/// rate to update one badge.
class _RemoteVideo {
  _RemoteVideo({
    required this.stream,
    required this.track,
    required RemoteTrackPublication publication,
  }) : health = ValueNotifier(
         VoiceTrackHealth(
           subscribed: true,
           senderMuted: publication.muted,
           trackName: publication.name,
           subscribedAt: DateTime.now(),
         ),
       );

  final rtc.MediaStream stream;
  final rtc.MediaStreamTrack track;
  final ValueNotifier<VoiceTrackHealth> health;

  CancelListenFunc? _events;

  VoiceVideoFeed get feed =>
      VoiceVideoFeed(stream: stream, track: track, health: health);

  /// The SDK monitors a started track on its own timer, so this only has to
  /// listen - there is no polling to arrange and no second `getStats` call to
  /// pay for.
  void listenTo(Track source) {
    _events = source.events.listen((event) {
      if (event is! VideoReceiverStatsEvent) return;
      final stats = event.stats;
      final decoded = stats.framesDecoded?.toInt() ?? 0;
      final previous = health.value;
      health.value = previous.copyWith(
        bytesReceived: stats.bytesReceived?.toInt() ?? previous.bytesReceived,
        packetsReceived:
            stats.packetsReceived?.toInt() ?? previous.packetsReceived,
        framesDecoded: decoded,
        framesReceived: stats.framesReceived?.toInt() ?? previous.framesReceived,
        frameWidth: stats.frameWidth?.toInt() ?? previous.frameWidth,
        frameHeight: stats.frameHeight?.toInt() ?? previous.frameHeight,
        mimeType: stats.mimeType ?? previous.mimeType,
        decoder: stats.decoderImplementation ?? previous.decoder,
        updatedAt: DateTime.now(),
        // Only moved when the count did, so "when did a frame last arrive" is
        // answerable rather than being overwritten by every tick that brought
        // none.
        lastFrameAt: decoded > previous.framesDecoded
            ? DateTime.now()
            : previous.lastFrameAt,
      );
    });
  }

  void setSenderMuted(bool muted) {
    if (health.value.senderMuted == muted) return;
    health.value = health.value.copyWith(senderMuted: muted);
  }

  void dispose() {
    unawaited(_events?.call() ?? Future<void>.value());
    _events = null;
    // The stream and the track belong to the SDK, which stops them with the
    // subscription. Disposing either from here is what takes a *second*
    // renderer on the same track down with it - on darwin `streamDispose`
    // clears whichever renderer it finds holding that track id first, which is
    // not necessarily the one being closed.
    health.dispose();
  }
}

/// A publication the SFU is advertising that nothing in this client has asked
/// for. See `VoiceWebRtcService._reportUnknownPublications`.
@immutable
class VoicePublicationDiscovery {
  const VoicePublicationDiscovery({
    required this.userId,
    required this.trackName,
    required this.kind,
    this.shareId,
  });

  final String userId;
  final String trackName;
  final TrackKind kind;
  final String? shareId;
}

/// A connection attempt abandoned because the room was left underneath it.
///
/// Its own type because it is the *correct* outcome of a race and must not be
/// shown to anybody: a person who tapped away from a channel has not
/// experienced a failure to connect to it, and telling them so is how a
/// deliberate cancellation reads as a broken feature.
class VoiceConnectSuperseded implements Exception {
  const VoiceConnectSuperseded();

  @override
  String toString() =>
      'VoiceConnectSuperseded: the room was left while it was being connected.';
}

/// One track this client has asked to pull.
class _WantedTrack {
  const _WantedTrack({
    required this.userId,
    required this.trackName,
    required this.kind,
    this.shareId,
  });

  final String userId;
  final String trackName;
  final TrackKind kind;
  final String? shareId;
}
