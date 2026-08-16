import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/safe_emit.dart';
import '../../../core/diagnostics/voice_diagnostics.dart';
import '../../../core/realtime/realtime_transport.dart';
import '../../../core/sound/sound_service.dart';
import '../../../core/voice/track_naming.dart';
import '../../../core/voice/video_layers.dart';
import '../../../core/voice/voice_app_visibility.dart';
import '../../../core/voice/voice_heartbeat.dart';
import '../../../core/voice/voice_liveness.dart';
import '../../../core/voice/voice_media_api.dart';
import '../../../core/voice/voice_participant_state.dart';
import '../../../core/voice/voice_snapshot_dto.dart';
import '../../../core/voice/voice_speaking_detector.dart';
import '../../../core/voice/voice_video_feed.dart';
import '../../../core/voice/voice_webrtc_service.dart';
import '../../auth/data/auth_repository.dart';
import '../../billing/data/entitlement_reader.dart';
import '../../billing/data/models/entitlement_degradation_dto.dart';
import '../../billing/data/models/entitlement_denial.dart';
import '../data/models/call_dto.dart';
import '../data/models/ongoing_call_dto.dart';
import '../data/voice_repository.dart';
import '../webrtc/call_webrtc_service.dart';

enum CallPhase { idle, incoming, connecting, active }

/// A call participant is a voice-room participant - the two room kinds share
/// one shape because the server runs one implementation for both.
typedef CallParticipantState = VoiceParticipantState;

class CallState extends Equatable {
  const CallState({
    this.phase = CallPhase.idle,
    this.call,
    this.participants = const [],
    this.isMuted = false,
    this.isDeafened = false,
    this.isSpeakerOn = true,
    this.connectedAt,
    this.errorMessage,
    this.disconnectNotice,
    this.aloneDeadline,
    this.videoRevision = 0,
    this.ongoingByConversation = const {},
    this.limits,
    this.videoNotice,
  });

  final CallPhase phase;
  final CallDto? call;

  /// Calls happening in this user's conversations that they are *not* in,
  /// keyed by conversation id - what a "join call in progress" affordance
  /// renders from.
  ///
  /// Kept here rather than per screen because the events that maintain it
  /// (`conversation.CallStateChanged`) reach every member of the conversation
  /// whether or not its screen is open, and there is no other signal: the ring
  /// is addressed to invitees and never replayed.
  final Map<String, OngoingCallDto> ongoingByConversation;
  final List<CallParticipantState> participants;
  final bool isMuted;
  final bool isDeafened;

  /// Whether output is routed to the loud/speakerphone output rather than
  /// the quiet call (earpiece) speaker. Defaults on - with no headset
  /// connected, calls were otherwise landing on the quiet earpiece route
  /// with no way to switch, unlike every other calling app.
  final bool isSpeakerOn;

  /// Set once, the moment the call becomes [CallPhase.active] - drives the
  /// elapsed-time display. Never touched again for the life of the call.
  final DateTime? connectedAt;
  final String? errorMessage;

  /// One-shot, non-error explanation for why the call just ended/was torn
  /// down locally - e.g. "You joined this call on another device." or a
  /// `call.CallEnded` reason translated to copy. `null` means nothing to show.
  final String? disconnectNotice;

  /// Set from `call.CallAlone` while this is the sole connected participant
  /// - the deadline the server will force-end the call at if nobody rejoins.
  /// Cleared once another participant is observed.
  final DateTime? aloneDeadline;

  /// Bumped on every local/remote camera or screen-share track add/remove -
  /// `MediaStreamTrack`s themselves can't live in this `Equatable` state (not
  /// comparable/immutable-safe), so `VideoParticipantTile`/`ScreenShareView`
  /// instead pull the current track imperatively from the webrtc service and
  /// rely on this counter changing to know when to re-pull and rebuild.
  final int videoRevision;

  /// What this call may carry, as of the last snapshot. Null on a server that
  /// does not send limits, which is "nobody said" rather than "no limits".
  ///
  /// A call has no server plan behind it, so the only thing that can reduce one
  /// is an operator ceiling - a self-hoster who has capped what their own box
  /// will carry. That is the one reason no amount of money moves, which is
  /// exactly why the surface below renders a sentence and never a control.
  final VoiceRoomLimitsDto? limits;

  /// One sentence about this device's own video, in the moment. See the
  /// matching field on `GuildVoiceState`.
  final String? videoNotice;

  /// [errorMessage]/[disconnectNotice] are always set as given (including
  /// `null`), never falling back to the current value - every emitting call
  /// site recomputes them, and `null` there means "nothing to show", not
  /// "unchanged". [aloneDeadline] is the opposite: it coalesces like most
  /// other fields so unrelated updates (mute/deafen toggles) don't
  /// accidentally clear an active countdown - pass [clearAloneDeadline] to
  /// clear it explicitly.
  CallState copyWith({
    CallPhase? phase,
    CallDto? call,
    List<CallParticipantState>? participants,
    bool? isMuted,
    bool? isDeafened,
    bool? isSpeakerOn,
    DateTime? connectedAt,
    String? errorMessage,
    String? disconnectNotice,
    DateTime? aloneDeadline,
    bool clearAloneDeadline = false,
    int? videoRevision,
    Map<String, OngoingCallDto>? ongoingByConversation,
    VoiceRoomLimitsDto? limits,
    String? videoNotice,
    bool clearVideoNotice = false,
  }) => CallState(
    ongoingByConversation: ongoingByConversation ?? this.ongoingByConversation,
    phase: phase ?? this.phase,
    call: call ?? this.call,
    participants: participants ?? this.participants,
    isMuted: isMuted ?? this.isMuted,
    isDeafened: isDeafened ?? this.isDeafened,
    isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
    connectedAt: connectedAt ?? this.connectedAt,
    errorMessage: errorMessage,
    disconnectNotice: disconnectNotice,
    aloneDeadline: clearAloneDeadline
        ? null
        : (aloneDeadline ?? this.aloneDeadline),
    videoRevision: videoRevision ?? this.videoRevision,
    limits: limits ?? this.limits,
    // Coalesces like [aloneDeadline] rather than resetting like
    // [errorMessage]: a mute toggle must not wipe the sentence explaining why
    // the camera is off, so clearing it is explicit and only the paths that
    // stop publishing do it.
    videoNotice: clearVideoNotice ? null : (videoNotice ?? this.videoNotice),
  );

  @override
  List<Object?> get props => [
    phase,
    call,
    participants,
    isMuted,
    isDeafened,
    isSpeakerOn,
    connectedAt,
    errorMessage,
    disconnectNotice,
    aloneDeadline,
    videoRevision,
    ongoingByConversation,
    limits,
    videoNotice,
  ];
}

/// App-lifetime singleton owning the one call the app can be in at a time.
/// `CallWebRtcService` (a fresh instance per call) owns the WebRTC plumbing;
/// this cubit decides who to subscribe to and keeps the roster.
///
/// The roster is snapshot-driven. Live events adjust it, but the snapshot is
/// what it is rebuilt from on join, on every gap the version gate detects, and
/// on every reconnect - which is the difference between a client that recovers
/// from a dropped event and one that stays wrong until the call ends.
class CallCubit extends Cubit<CallState> with SafeEmit<CallState> {
  CallCubit({
    required this.repository,
    required this.authRepository,
    required this.soundService,
    required CallWebRtcService Function() webRtcServiceFactory,
    this.entitlements,
    VoiceDiagnostics? diagnostics,
  }) : _webRtcServiceFactory = webRtcServiceFactory,
       _diagnostics = diagnostics ?? VoiceDiagnostics.shared,
       super(const CallState()) {
    _sub = repository.events.listen(_handleEvent);
    _connectionSub = repository.connectionStatus.listen(
      _handleConnectionStatus,
    );
    _heartbeat = VoiceHeartbeat(send: _sendHeartbeat);
    _liveness = VoiceLiveness(
      assertAlive: _assertAlive,
      onRoomGone: () => unawaited(_handleRoomGone()),
    );
  }

  final VoiceRepository repository;
  final AuthRepository authRepository;
  final SoundService soundService;

  /// Where the video ladder is read from, so the camera captures at what this
  /// call's rung permits. Optional: without it the camera falls back to
  /// [VideoPublishIntent.conservative], which is what it captured at before the
  /// ladder was on the wire.
  final EntitlementReader? entitlements;

  final CallWebRtcService Function() _webRtcServiceFactory;

  /// Where a failure this cubit swallows is written down, and the source of the
  /// reference appended to every message it shows.
  final VoiceDiagnostics _diagnostics;
  late final StreamSubscription<VoiceRepositoryEvent> _sub;
  late final StreamSubscription<RealtimeConnectionStatus> _connectionSub;
  late final VoiceHeartbeat _heartbeat;

  /// The second, independent liveness channel. Kept as its own timer rather
  /// than folded into [_heartbeat] on purpose: the heartbeat goes over the hub,
  /// and the case this covers is the hub being down.
  late final VoiceLiveness _liveness;
  CallWebRtcService? _webRtc;

  /// Whether the call's screen shares are actually on screen. Viewer claims
  /// and the subscriptions behind them are only held while they are: viewer
  /// counts are cheap, egress is not, and a hidden stream that stays
  /// subscribed is exactly what the watch protocol exists to avoid paying for.
  bool _sharesVisible = false;

  /// Share ids this device currently holds a viewer claim on. Re-posted on the
  /// heartbeat timer, because a claim expires after 90 seconds.
  final Set<String> _watchedShares = {};

  /// Set only for calls *this* device initiated via [startCall] - drives the
  /// outgoing ringback tone, which (unlike incoming calls) has no native
  /// CallKit equivalent to double up with. Cleared as soon as another
  /// participant actually joins, or the call ends/is torn down.
  bool _isRingingOutgoing = false;

  void _stopOutgoingRingback() {
    if (!_isRingingOutgoing) return;
    _isRingingOutgoing = false;
    unawaited(soundService.stopRingOutgoing());
  }

  String get _myUserId => authRepository.currentUserId ?? '';

  /// A state with no call in it. Everything about the call is dropped;
  /// [CallState.ongoingByConversation] is not, because it describes calls in
  /// *other* conversations and is maintained by events that keep arriving
  /// whether or not this device is in a call.
  CallState _cleared({String? errorMessage, String? disconnectNotice}) =>
      CallState(
        errorMessage: errorMessage,
        disconnectNotice: disconnectNotice,
        ongoingByConversation: state.ongoingByConversation,
      );

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  Future<void> startCall({
    required String conversationId,
    required List<String> participantUserIds,
  }) async {
    if (state.phase != CallPhase.idle) return;
    emitIfOpen(state.copyWith(phase: CallPhase.connecting));
    try {
      final call = await repository.createCall(
        conversationId: conversationId,
        participantUserIds: participantUserIds,
      );
      _isRingingOutgoing = true;
      unawaited(soundService.startRingOutgoing());
      await _connect(call);
    } catch (e, s) {
      _stopOutgoingRingback();
      final reference = _diagnostics.record(
        VoiceFaultCodes.join,
        subject: conversationId,
        detail: _describeFailure(e),
        error: e,
        stackTrace: s,
      );
      emitIfOpen(
        _cleared(
          errorMessage: withVoiceTrace('Could not start the call.', reference),
        ),
      );
    }
  }

  Future<void> acceptIncomingCall() async {
    final call = state.call;
    if (state.phase != CallPhase.incoming || call == null) return;
    emitIfOpen(state.copyWith(phase: CallPhase.connecting));
    try {
      final accepted = await repository.acceptCall(call.id);
      await _connect(accepted);
    } catch (e, s) {
      emitIfOpen(_cleared(errorMessage: _joinFailure(call.id, e, s)));
    }
  }

  /// The sentence and the trace reference for a call that could not be joined.
  String _joinFailure(String callId, Object error, StackTrace stackTrace) =>
      withVoiceTrace(
        'Could not join the call.',
        _diagnostics.record(
          VoiceFaultCodes.join,
          subject: callId,
          detail: _describeFailure(error),
          error: error,
          stackTrace: stackTrace,
        ),
      );

  Future<void> declineIncomingCall() async {
    final call = state.call;
    if (state.phase != CallPhase.incoming || call == null) return;
    emitIfOpen(_cleared());
    try {
      await repository.declineCall(call.id);
    } catch (_) {
      // Best-effort - we've already left the incoming-call UI locally.
    }
  }

  /// [acceptIncomingCall]'s counterpart for calls answered from the native
  /// CallKit UI before this app instance ever saw a `call.IncomingCall`
  /// websocket event - e.g. a cold start from a VoIP push, where [state.call]
  /// was never populated. Guards on [CallPhase.idle] rather than
  /// [CallPhase.incoming] for that reason.
  Future<void> acceptIncomingCallById(String callId) async {
    if (state.phase != CallPhase.idle) return;
    emitIfOpen(state.copyWith(phase: CallPhase.connecting));
    try {
      final accepted = await repository.acceptCall(callId);
      await _connect(accepted);
    } catch (e, s) {
      emitIfOpen(_cleared(errorMessage: _joinFailure(callId, e, s)));
    }
  }

  /// [declineIncomingCall]'s by-id counterpart - see [acceptIncomingCallById].
  Future<void> declineIncomingCallById(String callId) async {
    if (state.phase != CallPhase.idle) return;
    try {
      await repository.declineCall(callId);
    } catch (_) {
      // Best-effort - CallKit's UI is already dismissed locally.
    }
  }

  /// Hangs up a call by id regardless of whether it was ever loaded into
  /// [state.call] - the native CallKit "end" action carries only the id.
  Future<void> endCallById(String callId) async {
    if (state.call?.id == callId) {
      await endCall();
      return;
    }
    try {
      await repository.leaveCall(callId);
    } catch (_) {
      // Best-effort - nothing local to tear down for a call we never loaded.
    }
  }

  /// Hangs up the current call. Calls `leave`, which removes just this user -
  /// it does not end the call for anyone still connected.
  Future<void> endCall() async {
    final call = state.call;
    if (call == null) return;
    _epoch++;
    _stopOutgoingRingback();
    final webRtc = await _teardown();
    emitIfOpen(_cleared());
    // Started before the media teardown rather than after it. `disconnect()` is
    // a round trip to the SFU, and sequencing the hang-up behind it meant a slow
    // teardown - or one that threw, which the SDK's own disconnect does on every
    // room closed before its handshake finished - delayed or skipped the one
    // request that actually removes this device from the call.
    final leaving = repository.leaveCall(call.id);
    await webRtc?.disconnect();
    try {
      await leaving;
    } catch (e, s) {
      _diagnostics.record(
        VoiceFaultCodes.join,
        subject: call.id,
        detail: 'leave was not acknowledged by the server',
        error: e,
        stackTrace: s,
      );
    }
  }

  /// Tears down every local handle on the current call and returns the WebRTC
  /// service so the caller can dispose it after emitting. Releases the viewer
  /// claims first: they outlive this client by 90 seconds otherwise, and a
  /// phantom viewer keeps a publisher's egress alive for nothing.
  Future<CallWebRtcService?> _teardown() async {
    _heartbeat.stop();
    // Before anything that can block. A ping for a call the user has left keeps
    // a ghost participant in everybody else's roster until it stops.
    _liveness.stop();
    _stopSpeakingReports();
    _stopVisibilityReports();
    await _releaseAllShareClaims();
    repository.exitCall();
    final webRtc = _webRtc;
    _webRtc = null;
    return webRtc;
  }

  /// A transport with its callbacks wired. Built here rather than at each call
  /// site so a rebuild cannot come back with fewer of them than the original
  /// had.
  ///
  /// Two callbacks that used to be here are gone with the SDP relay:
  /// `onStaleSubscription` and `onSessionGone`. Neither condition exists any
  /// more - there is no subscribe for this backend to refuse, and no minted
  /// session id to be spent - so the media-rebuild path they drove has gone with
  /// them.
  CallWebRtcService _buildTransport() {
    final webRtc = _webRtcServiceFactory();
    // A track arriving is its own event, later than the subscribe that asked
    // for it and with nothing else attached to it. Without this the screen
    // renders whatever it read before the media existed - see
    // [CallState.videoRevision].
    webRtc.onTracksChanged = _bumpVideoRevision;
    // A reduction is a success. Nothing is torn down here - the sentence is
    // put where the person publishing can read it, and that is all.
    webRtc.onPublishReduced = _noteReduction;
    // Raw, and deliberately not reported from here - it goes through the
    // detector, which is where the hysteresis lives.
    webRtc.onLocalSpeakingChanged = (isSpeaking) =>
        _speaking?.update(isSpeaking: isSpeaking);
    // The SDK gave up reconnecting. A fresh connection is the only recovery -
    // and it is cheap, because minting one touches nothing but the token.
    webRtc.onMediaDisconnected = () => unawaited(_reconnectMedia());
    // A publication the SFU is advertising that nothing asked for - the camera
    // that was already on when this device joined, or one whose `TrackPublished`
    // was missed. See `VoiceWebRtcService._reportUnknownPublications`.
    webRtc.onPublicationDiscovered = _handleDiscoveredPublication;
    return webRtc;
  }

  void _handleDiscoveredPublication(VoicePublicationDiscovery discovery) {
    final callId = state.call?.id;
    if (callId == null || state.phase != CallPhase.active) return;
    _diagnostics.record(
      VoiceFaultCodes.notSubscribed,
      subject: discovery.userId,
      detail:
          'adopted an unannounced publication "${discovery.trackName}" '
          'the SFU was already carrying',
      isError: false,
    );
    _handleTrackPublished(
      userId: discovery.userId,
      // The SFU knows nothing about the backend's session ids and nothing on
      // the subscribe path reads one any more.
      mediaSessionId: '',
      trackName: discovery.trackName,
      kind: discovery.kind,
      shareId: discovery.shareId,
    );
  }

  /// Guards [_reconnectMedia] against a second attempt while one is running.
  bool _reconnectingMedia = false;

  /// Rebuilds the media half after the SDK's own reconnect ladder is exhausted.
  ///
  /// A token is good for minutes rather than hours, so the case this covers is
  /// a device asleep or in a tunnel for longer than that: the resume is refused
  /// and the SDK stops. Asking for another connection is the documented answer,
  /// it does not touch the roster, and it does not re-announce this client to
  /// anybody.
  ///
  /// **The call itself is untouched.** Membership, the roster and the version
  /// tracker all survive; this is not a rejoin, and the user is not hung up on.
  /// The camera and any screen share do not survive - they were publications on
  /// a connection that is gone - so the room is told they stopped rather than
  /// left advertising a picture nobody is receiving.
  Future<void> _reconnectMedia() async {
    final call = state.call;
    if (_reconnectingMedia || call == null) return;
    if (state.phase != CallPhase.active) return;
    _reconnectingMedia = true;
    try {
      final dead = _webRtc;
      _webRtc = null;
      await dead?.disconnect();

      final webRtc = _buildTransport();
      _webRtc = webRtc;
      await webRtc.connect(call.id);
      await webRtc.setMuted(state.isMuted);
      webRtc.setDeafened(state.isDeafened);
      await webRtc.setSpeakerphoneOn(state.isSpeakerOn);

      // The roster is unchanged, but every subscription went with the old
      // connection, so this is what pulls the call back in.
      await repository.refetchSnapshot();
    } catch (_) {
      emitIfOpen(
        state.copyWith(errorMessage: 'Lost the connection to the call.'),
      );
    } finally {
      _reconnectingMedia = false;
    }
  }

  /// Debounces this device's voice activity into `call.SpeakingChanged`.
  ///
  /// Built per call rather than per cubit so its "what the server currently
  /// believes" state cannot survive into a call the belief is not about.
  VoiceSpeakingDetector? _speaking;

  /// Tells the server when this client is backgrounded, so it stops sending
  /// video nobody is looking at. Audio is unaffected - see
  /// [VoiceAppVisibility].
  VoiceAppVisibility? _visibility;

  void _startVisibilityReports() {
    _visibility?.dispose();
    _visibility = VoiceAppVisibility(
      onChanged: (isPaused) => unawaited(
        _webRtc?.setPaused(isPaused) ?? Future.value(),
      ),
    );
  }

  void _stopVisibilityReports() {
    _visibility?.dispose();
    _visibility = null;
  }

  void _startSpeakingReports() {
    _speaking?.dispose();
    _speaking = VoiceSpeakingDetector(
      report: (isSpeaking) async {
        final callId = state.call?.id;
        if (callId == null || state.phase != CallPhase.active) return;
        await repository.invokeSpeakingChanged(
          callId: callId,
          isSpeaking: isSpeaking,
        );
      },
    );
  }

  void _stopSpeakingReports() {
    // Silenced rather than merely disposed: a detector torn down mid-word
    // leaves the server believing this device is still talking, which keeps it
    // ranked - and every other client in the room subscribed to it.
    _speaking?.silenceNow();
    _speaking?.dispose();
    _speaking = null;
  }

  /// Files a clamped publish where the call screen can render it.
  ///
  /// The video ceiling is preferred over any other reduction on the same
  /// publish because it is the one that describes what is now being sent; the
  /// rest still reach the session log through the interceptor.
  void _noteReduction(List<EntitlementDegradationDto> degradations) {
    final video = degradations.firstWhere(
      (d) => d.key == EntitlementKeys.voiceVideoCeiling,
      orElse: () => degradations.first,
    );
    emitIfOpen(state.copyWith(videoNotice: video.notice));
  }

  /// Which call cycle is current, so media work that outlives the call it was
  /// started for can tell that it has been superseded rather than writing into
  /// the next one. See `GuildVoiceCubit._epoch` - the same race, the same fix.
  int _epoch = 0;

  Future<void> _connect(CallDto call) async {
    final epoch = ++_epoch;
    final webRtc = _buildTransport();
    _webRtc = webRtc;
    repository.enterCall(call.id);

    emitIfOpen(
      state.copyWith(
        phase: CallPhase.active,
        call: call,
        participants: [
          for (final p in call.participants)
            CallParticipantState(userId: p.userId),
        ],
        connectedAt: DateTime.now(),
      ),
    );

    try {
      await webRtc.connect(call.id);
      await webRtc.setMuted(state.isMuted);
      webRtc.setDeafened(state.isDeafened);
      await webRtc.setSpeakerphoneOn(state.isSpeakerOn);
      _startSpeakingReports();
      _startVisibilityReports();
    } on VoiceConnectSuperseded {
      // The call was hung up while this was connecting. Not a failure, and
      // reporting it would tell somebody who deliberately ended a call that it
      // could not be joined.
      return;
    } on VoiceMediaException catch (e, s) {
      if (epoch != _epoch) return;
      final reference = _diagnostics.record(
        VoiceFaultCodes.connect,
        subject: call.id,
        detail: _describeFailure(e),
        error: e,
        stackTrace: s,
      );
      // A self-hosted instance with no SFU configured is a supported state, not
      // a fault - and there is no capability read to ask up front, so this is
      // where it is discovered. Saying "could not connect" for it would send
      // somebody looking for a network problem that does not exist.
      emitIfOpen(
        state.copyWith(
          errorMessage: withVoiceTrace(
            e.isVoiceNotConfigured
                ? 'Voice is not available on this server.'
                : 'Could not connect audio.',
            reference,
          ),
        ),
      );
    } catch (e, s) {
      if (epoch != _epoch) return;
      final reference = _diagnostics.record(
        VoiceFaultCodes.connect,
        subject: call.id,
        detail: _describeFailure(e),
        error: e,
        stackTrace: s,
      );
      emitIfOpen(
        state.copyWith(
          errorMessage: withVoiceTrace('Could not connect audio.', reference),
        ),
      );
    }

    // Everything below belongs to a call this device is still in. Left
    // unguarded, a hang-up during the connect above was followed by a refetch
    // for the call just left and by two timers restarted after the teardown had
    // stopped them.
    if (epoch != _epoch) return;

    // The snapshot is the roster, and it is read after connecting so it can be
    // acted on immediately. The accept/create response cannot serve here: it is
    // serialized before the other side publishes, so it names nobody to
    // subscribe to.
    await repository.refetchSnapshot();
    if (epoch != _epoch) return;
    _heartbeat.start();
    _liveness.start();
  }

  /// A short, safe description of a failure for the fault log. See
  /// `GuildVoiceCubit._describeFailure`.
  String _describeFailure(Object error) => switch (error) {
    VoiceMediaException(:final statusCode, :final operation, :final error) =>
      '$operation failed: $statusCode ${error ?? ''}'.trimRight(),
    UnsupportedVoiceBackendException(:final backend) =>
      'unsupported media backend "$backend"',
    _ => error.runtimeType.toString(),
  };

  // ── Snapshot ──────────────────────────────────────────────────────────────

  /// Adopts an authoritative snapshot wholesale and reconciles the transport
  /// with it: unsubscribe from whoever is gone or has stopped publishing,
  /// subscribe to whoever is publishing and not yet subscribed.
  ///
  /// Camera and speaking state are carried forward rather than taken from the
  /// snapshot, because the server does not store them - they are relay-only
  /// events, and a snapshot that dropped them would blank every camera badge
  /// on every resync.
  void _applySnapshot(VoiceRoomSnapshotDto snapshot) {
    if (state.phase != CallPhase.active) return;
    if (state.call?.id != snapshot.roomId) return;
    final webRtc = _webRtc;

    final previous = {for (final p in state.participants) p.userId: p};
    final participants = [
      for (final p in snapshot.participants)
        VoiceParticipantState.fromSnapshot(
          p,
          hasCamera: previous[p.userId]?.hasCamera ?? false,
          isSpeaking: previous[p.userId]?.isSpeaking ?? false,
        ),
    ];

    final present = participants.map((p) => p.userId).toSet();
    for (final gone in previous.keys.where((id) => !present.contains(id))) {
      webRtc?.unsubscribeParticipant(gone);
    }

    emitIfOpen(
      state.copyWith(
        participants: participants,
        clearAloneDeadline: participants.length > 1,
        videoRevision: state.videoRevision + 1,
        // Absent limits leave the last known set alone rather than blanking
        // it: a room that stops reporting has not stopped having ceilings, and
        // a control that re-enables itself because a field went missing is the
        // one direction this must not fail in.
        limits: snapshot.limits,
      ),
    );

    if (webRtc == null) return;

    // Taken wholesale, exactly like the roster. Applied *before* the subscribes
    // below so they are filtered by it on the way through rather than issued
    // and then withdrawn - and a snapshot with no `subscriptions` clears any
    // set that was in force, which is the ordinary small room saying "pull
    // everyone who is publishing".
    webRtc.applySubscriptionSet(snapshot.subscriptions);

    for (final p in snapshot.publishersExcept(_myUserId)) {
      unawaited(
        webRtc.subscribeToParticipant(
          userId: p.userId,
          mediaSessionId: p.mediaSessionId!,
          trackName: p.audioTrackName!,
        ),
      );
    }
    unawaited(_reconcileShares(snapshot));
  }

  /// Brings viewer claims and share subscriptions in line with the snapshot
  /// and with whether the shares are on screen at all.
  Future<void> _reconcileShares(VoiceRoomSnapshotDto snapshot) async {
    final webRtc = _webRtc;
    final callId = state.call?.id;
    if (webRtc == null || callId == null) return;

    final live = <String, VoiceParticipantSnapshotDto>{};
    for (final p in snapshot.participants) {
      if (p.userId == _myUserId) continue;
      for (final share in p.shares) {
        live[share.shareId] = p;
      }
    }

    // Shares that ended, or that we should no longer be watching.
    for (final shareId in _watchedShares.toList()) {
      if (live.containsKey(shareId) && _sharesVisible) continue;
      final owner = live[shareId]?.userId;
      await _stopWatching(callId, shareId, ownerUserId: owner);
    }

    if (!_sharesVisible) return;

    for (final entry in live.entries) {
      final publisher = entry.value;
      if (!publisher.isPublishing) continue;
      final share = publisher.shares.firstWhere((s) => s.shareId == entry.key);
      if (_watchedShares.add(entry.key)) {
        unawaited(_claimShare(callId, entry.key));
      }
      await webRtc.subscribeToShare(
        userId: publisher.userId,
        // The share's own session, not the publisher's microphone one - they
        // are the same session only by coincidence. See [VoiceShareDto].
        mediaSessionId: share.mediaSessionId ?? publisher.mediaSessionId!,
        shareId: share.shareId,
        trackNames: share.trackNames,
      );
    }
  }

  Future<void> _claimShare(String callId, String shareId) async {
    try {
      await repository.watchShare(callId, shareId);
    } catch (_) {
      // A lost claim only understates a viewer count; the next heartbeat
      // re-posts it.
    }
  }

  Future<void> _stopWatching(
    String callId,
    String shareId, {
    String? ownerUserId,
  }) async {
    _watchedShares.remove(shareId);
    if (ownerUserId != null) {
      _webRtc?.unsubscribeShare(userId: ownerUserId, shareId: shareId);
    }
    try {
      await repository.unwatchShare(callId, shareId);
    } catch (_) {
      // Best-effort - the claim expires on its own within 90 seconds.
    }
  }

  Future<void> _releaseAllShareClaims() async {
    final callId = state.call?.id;
    final shareIds = _watchedShares.toList();
    _watchedShares.clear();
    if (callId == null) return;
    for (final shareId in shareIds) {
      try {
        await repository.unwatchShare(callId, shareId);
      } catch (_) {
        // Best-effort.
      }
    }
  }

  /// Called by the call screen as it appears and disappears. Watching is
  /// announced explicitly because a subscribe is not a reliable signal - it
  /// has no teardown a client is obliged to send.
  void setSharesVisible(bool visible) {
    if (_sharesVisible == visible) return;
    _sharesVisible = visible;
    unawaited(repository.refetchSnapshot());
  }

  // ── Heartbeat ─────────────────────────────────────────────────────────────

  /// Asserts this device's real state every ~30s, and re-posts viewer claims
  /// on the same timer because they expire on the same clock.
  Future<void> _sendHeartbeat() async {
    final callId = state.call?.id;
    if (callId == null || state.phase != CallPhase.active) return;
    final webRtc = _webRtc;
    await repository.invokeHeartbeat(
      callId: callId,
      state: VoiceHeartbeatState(
        knownInstanceId: repository.knownInstanceId,
        knownVersion: repository.knownVersion,
        mediaSessionId: webRtc?.mediaSessionId,
        audioTrackName: webRtc?.publishedAudioTrackName,
      ),
    );
    for (final shareId in _watchedShares) {
      unawaited(_claimShare(callId, shareId));
    }
  }

  /// One tick of the HTTP liveness loop - see [VoiceLiveness].
  ///
  /// Null when there is no active call to assert. The timer is started after
  /// the phase goes active and stopped in [_teardown], so that only happens to
  /// a tick that raced a hang-up - and a hang-up is not the server evicting us,
  /// which is the one thing a non-null answer here would be read as.
  Future<VoiceLivenessOutcome?> _assertAlive() async {
    final callId = state.call?.id;
    if (callId == null || state.phase != CallPhase.active) return null;
    return repository.assertAlive(callId);
  }

  // ── Local controls ────────────────────────────────────────────────────────

  Future<void> toggleMute() async {
    if (state.phase != CallPhase.active) return;
    final isMuted = !state.isMuted;
    emitIfOpen(
      state.copyWith(
        isMuted: isMuted,
        participants: _updateSelf((p) => p.copyWith(isMuted: isMuted)),
      ),
    );
    await _webRtc?.setMuted(isMuted);
    // Muting is not a pause in speech and must not be debounced like one: held
    // through the release delay, this device stays ranked as talking with its
    // microphone off, and every other client in the room stays subscribed to
    // the silence.
    if (isMuted) _speaking?.silenceNow();
    final callId = state.call?.id;
    if (callId != null) {
      await repository.invokeMuteChanged(callId: callId, isMuted: isMuted);
    }
  }

  void toggleDeafen() {
    if (state.phase != CallPhase.active) return;
    final isDeafened = !state.isDeafened;
    emitIfOpen(
      state.copyWith(
        isDeafened: isDeafened,
        participants: _updateSelf((p) => p.copyWith(isDeafened: isDeafened)),
      ),
    );
    _webRtc?.setDeafened(isDeafened);
  }

  Future<void> toggleSpeaker() async {
    if (state.phase != CallPhase.active) return;
    final isSpeakerOn = !state.isSpeakerOn;
    emitIfOpen(state.copyWith(isSpeakerOn: isSpeakerOn));
    await _webRtc?.setSpeakerphoneOn(isSpeakerOn);
  }

  /// Current local camera state - read from [state.participants] rather than
  /// a separate field, since the self-entry there is already the source of
  /// truth other participants' badges read from.
  bool get isCameraOn => _self?.hasCamera ?? false;

  /// Whether asking to publish video here would only be refused.
  ///
  /// Two independent sources, and both have to permit it. The room's limits
  /// describe what this room allows; the **connection token** describes what
  /// this client was actually granted, which is the more authoritative of the
  /// two - a member whose plan carries no video connects and hears everyone,
  /// and cannot turn a camera on however the client is patched. Rendering the
  /// control from a locally computed permission instead is how a button that
  /// cannot work stays enabled.
  ///
  /// False when neither has been reported: a control disabled on the strength
  /// of a field nobody sent is worse than one that is pressed and answered.
  bool get isVideoBlocked =>
      !(state.limits?.canPublishVideo ?? true) ||
      !(_webRtc?.canPublishVideo ?? true);

  Future<void> toggleCamera() async {
    if (state.phase != CallPhase.active) return;
    final webRtc = _webRtc;
    final callId = state.call?.id;
    if (webRtc == null || callId == null) return;
    final turningOn = !isCameraOn;

    // Pre-empted rather than attempted. The control is already disabled where
    // this is true, so reaching here means the room changed under the button.
    final blocked = turningOn ? state.limits?.videoBlockedSentence : null;
    if (blocked != null) {
      emitIfOpen(state.copyWith(videoNotice: blocked));
      return;
    }

    try {
      if (turningOn) {
        await webRtc.publishLocalVideo(target: await _cameraTarget());
      } else {
        await webRtc.stopLocalVideo();
      }
    } on EntitlementDenialException catch (e) {
      // Explained, and not retried: an entitlement refusal answered by asking
      // again is one refusal turned into three.
      emitIfOpen(state.copyWith(videoNotice: e.denial.sentence));
      return;
    } catch (_) {
      return; // Capture failed (denied permission, no camera, etc.) - bail.
    }
    emitIfOpen(
      state.copyWith(
        participants: _updateSelf((p) => p.copyWith(hasCamera: turningOn)),
        videoRevision: state.videoRevision + 1,
      ),
    );
    if (!turningOn) _clearVideoNoticeIfIdle();
    await repository.invokeCameraChanged(callId: callId, isCameraOn: turningOn);
  }

  /// Which way the local camera points, for the self-preview's mirroring and
  /// the flip control's icon. Front while nothing is publishing, which is the
  /// side the next publish will open.
  bool get isFrontCamera => _webRtc?.isFrontCamera ?? true;

  /// Flips the local camera. Nothing is published or declared again, so the
  /// roster does not move and no event goes out - see
  /// `VoiceWebRtcService.switchCamera`. The service bumps the video revision
  /// through `onTracksChanged`, which is what re-attaches the renderers.
  /// Awaited rather than forwarded, so the control that called this stays busy
  /// until the other camera is actually live.
  Future<void> switchCamera() async {
    await _webRtc?.switchCamera();
  }

  /// What to open the camera at here: this call's granted rung, resolved
  /// against the ladder the server publishes.
  ///
  /// A call has no guild plan behind it, so anything on its limits came from an
  /// operator ceiling. The rung is still read off the room rather than the
  /// account, because the room's copy is the one the server enforces against and
  /// the one that can change mid-call.
  ///
  /// **A rung that changes mid-call does not move an already-published camera.**
  /// Nothing in this client can change an encoding without republishing, and
  /// tearing a live picture down to re-open it smaller is a worse answer than
  /// letting the server cap the layer - which it does, and says so in the
  /// notice. The next publish picks the new rung up.
  Future<VideoPublishIntent?> _cameraTarget() async {
    final rung = state.limits?.videoRung;
    if (rung == null) return null;
    return cameraTargetFor(
      rung: rung,
      ladder: await entitlements?.videoQualityLadder(),
    );
  }

  /// Drops the video notice once nothing is being published.
  ///
  /// It describes the picture this device is sending, so it has to survive one
  /// of the two publications ending while the other runs - which is why this
  /// asks about both rather than clearing on either.
  void _clearVideoNoticeIfIdle() {
    if (isCameraOn || isScreenSharing) return;
    if (state.videoNotice == null) return;
    emitIfOpen(state.copyWith(clearVideoNotice: true));
  }

  /// Whether this device is live - screen sharing.
  bool get isScreenSharing => _self?.isStreaming ?? false;

  String? _myShareId;

  Future<void> toggleScreenShare() async {
    if (state.phase != CallPhase.active) return;
    final webRtc = _webRtc;
    final callId = state.call?.id;
    if (webRtc == null || callId == null) return;

    if (isScreenSharing) {
      final shareId = _myShareId;
      _myShareId = null;
      try {
        await webRtc.stopScreenShare();
      } catch (_) {
        // Best-effort - fall through to update local state regardless.
      }
      emitIfOpen(
        state.copyWith(
          participants: shareId == null
              ? state.participants
              : _updateSelf((p) => p.withoutShare(shareId)),
          videoRevision: state.videoRevision + 1,
        ),
      );
      _clearVideoNoticeIfIdle();
      if (shareId != null) {
        await repository.invokeScreenShareStopped(
          callId: callId,
          shareId: shareId,
        );
      }
      return;
    }

    final blocked = state.limits?.videoBlockedSentence;
    if (blocked != null) {
      emitIfOpen(state.copyWith(videoNotice: blocked));
      return;
    }

    final shareId =
        '${DateTime.now().microsecondsSinceEpoch}-${identityHashCode(this)}';
    try {
      await webRtc.startScreenShare(shareId);
    } on EntitlementDenialException catch (e) {
      emitIfOpen(state.copyWith(videoNotice: e.denial.sentence));
      return;
    } catch (_) {
      return; // Permission denied/cancelled the system picker - bail.
    }
    _myShareId = shareId;
    emitIfOpen(
      state.copyWith(
        participants: _updateSelf(
          (p) =>
              p.withShare(shareId, trackName: TrackNaming.screenTrack(shareId)),
        ),
        videoRevision: state.videoRevision + 1,
      ),
    );
    await repository.invokeScreenShareStarted(callId: callId, shareId: shareId);
  }

  void _bumpVideoRevision() =>
      emitIfOpen(state.copyWith(videoRevision: state.videoRevision + 1));

  /// Track getters for the UI - read imperatively, see
  /// [CallState.videoRevision] for why `MediaStreamTrack`s can't live in
  /// cubit state itself.
  VoiceVideoFeed? get localVideoFeed => _webRtc?.localVideoFeed;
  VoiceVideoFeed? get localScreenFeed => _webRtc?.localScreenFeed;
  VoiceVideoFeed? remoteVideoFeedFor(String userId) =>
      _webRtc?.remoteVideoFeedFor(userId);
  VoiceVideoFeed? remoteScreenFeedFor(String userId) =>
      _webRtc?.remoteScreenFeedFor(userId);
  VoiceVideoFeed? remoteScreenFeedForShare(String shareId) =>
      _webRtc?.remoteScreenFeedForShare(shareId);

  /// How large this client is drawing [userId], which is what the server picks
  /// their simulcast layer from. Reported by the tiles themselves; safe to call
  /// on every layout, and a no-op before the transport exists.
  void reportTileHeight({
    required String tileId,
    required String userId,
    required int devicePixels,
  }) => _webRtc?.reportTileHeight(
    tileId: tileId,
    userId: userId,
    devicePixels: devicePixels,
  );

  void forgetTile(String tileId) => _webRtc?.forgetTile(tileId);

  /// One publisher this client is looking at full-screen, and optionally the
  /// share whose audio it wants with them. Both null returns to the grid. See
  /// `VoiceWebRtcService.setFocus`.
  Future<void> setFocus({String? userId, String? shareId}) async =>
      _webRtc?.setFocus(userId: userId, shareId: shareId);

  // ── Catch-up ──────────────────────────────────────────────────────────────

  /// Asks the server whether a call is ringing for this user that this client
  /// was never told about.
  ///
  /// `call.IncomingCall` is broadcast once and never replayed. Every path that
  /// misses it ends the same way - the phone is ringing somewhere and the app
  /// shows nothing: the app was opened after the call started, the socket was
  /// down when the call was placed, or the push never arrived.
  ///
  /// Called on every realtime connect, and once explicitly at startup - the
  /// socket connects before this cubit is constructed on a cold start, so the
  /// connect event alone would miss exactly the case this exists for.
  Future<void> catchUpOnPendingCall() async {
    final CallDto? pending;
    try {
      pending = await repository.getPendingCall();
    } catch (_) {
      return; // Best-effort. A later reconnect tries again.
    }
    if (pending == null) return;
    // Re-checked after the await: an in-app "call" tapped while this was in
    // flight, or the real `call.IncomingCall` finally landing, both leave a
    // state this must not overwrite.
    if (state.phase != CallPhase.idle) return;
    emitIfOpen(CallState(phase: CallPhase.incoming, call: pending));
  }

  /// A reconnect is when to assert this client's state, not when to rebuild it.
  ///
  /// A dropped socket is not leaving the call: the server shortens this client's liveness window
  /// rather than evicting it, and reconnecting restores it - so nothing here touches the SFU
  /// connection. The hub and the media are entirely independent transports, the SDK has its own
  /// reconnect for its own socket, and rebuilding media on a hub blip drops audio for a fault that
  /// was never on the media path.
  ///
  /// What the gap does cost is events, which SignalR does not queue. The heartbeat goes first and
  /// immediately rather than at the next 30-second tick: it restores the liveness window and brings
  /// back a snapshot if this client fell behind. The lifecycle read then answers "is this call still
  /// running and am I still in it", which no snapshot covers.
  Future<void> _handleConnectionStatus(RealtimeConnectionStatus status) async {
    if (status != RealtimeConnectionStatus.connected) return;
    if (state.phase == CallPhase.idle) {
      await catchUpOnPendingCall();
      return;
    }
    if (state.phase != CallPhase.active) return;
    final call = state.call;
    if (call == null) return;

    unawaited(_sendHeartbeat());

    CallDto fresh;
    try {
      fresh = await repository.getCall(call.id);
    } catch (_) {
      return; // Best-effort - a later reconnect or live event will catch up.
    }
    if (state.phase != CallPhase.active || state.call?.id != call.id) return;

    if (fresh.status == 'Completed' ||
        fresh.status == 'Rejected' ||
        !fresh.participants.any((p) => p.userId == _myUserId)) {
      final webRtc = await _teardown();
      emitIfOpen(_cleared());
      unawaited(webRtc?.disconnect());
      return;
    }

    emitIfOpen(state.copyWith(call: fresh));
    await repository.refetchSnapshot();
  }

  // ── Events ────────────────────────────────────────────────────────────────

  void _handleEvent(VoiceRepositoryEvent event) {
    switch (event) {
      case ConversationCallStateChanged():
        _applyConversationCallState(event);

      case CallSnapshotReceived(:final snapshot):
        _applySnapshot(snapshot);

      case CallSubscriptionsChanged(:final subscriptions):
        // Nobody did anything - the conversation moved. The transport diffs
        // this against what it is currently pulling and adjusts; nothing here
        // tears anything down, and everyone stays rendered.
        if (state.phase != CallPhase.active) return;
        _webRtc?.applySubscriptionSet(subscriptions);

      case CallResyncRequested():
        // Everything but roomGone was already answered by a refetch in the
        // repository. roomGone means the room is gone: rejoining has to go
        // through the authorised path, so this device hangs up locally rather
        // than re-asserting itself.
        if (event.isRoomGone && state.phase == CallPhase.active) {
          unawaited(_handleRoomGone());
        }

      case IncomingCallReceived(:final call):
        final isForMe = call.participants.any((p) => p.userId == _myUserId);
        if (state.phase == CallPhase.idle && isForMe) {
          emitIfOpen(CallState(phase: CallPhase.incoming, call: call));
        }

      case CallParticipantJoined(
        :final userId,
        :final mediaSessionId,
        :final audioTrackName,
      ):
        if (userId == _myUserId || state.phase != CallPhase.active) return;
        _stopOutgoingRingback();
        emitIfOpen(
          state.copyWith(
            participants: _upsert(
              userId,
              (p) => p.copyWith(isPublishing: true),
              () => CallParticipantState(userId: userId, isPublishing: true),
            ),
            clearAloneDeadline: true,
          ),
        );
        unawaited(
          _webRtc?.subscribeToParticipant(
            userId: userId,
            mediaSessionId: mediaSessionId,
            trackName: audioTrackName,
          ),
        );

      case CallLifecycleParticipantLeft(:final userId):
        emitIfOpen(
          state.copyWith(
            participants: state.participants
                .where((p) => p.userId != userId)
                .toList(),
          ),
        );
        _webRtc?.unsubscribeParticipant(userId);

      case CallMuteChanged(:final userId, :final isMuted):
        emitIfOpen(
          state.copyWith(
            participants: _update(userId, (p) => p.copyWith(isMuted: isMuted)),
          ),
        );

      case CallDeafenChanged(:final userId, :final isDeafened):
        // Deafen implies mute one-way for the badge: false doesn't auto-unmute.
        emitIfOpen(
          state.copyWith(
            participants: _update(
              userId,
              (p) => p.copyWith(
                isDeafened: isDeafened,
                isMuted: isDeafened ? true : p.isMuted,
              ),
            ),
          ),
        );

      case CallSpeakingChanged(:final userId, :final isSpeaking):
        emitIfOpen(
          state.copyWith(
            participants: _update(
              userId,
              (p) => p.copyWith(isSpeaking: isSpeaking),
            ),
          ),
        );

      case CallCameraChanged(:final userId, :final isCameraOn):
        if (userId == _myUserId) return;
        emitIfOpen(
          state.copyWith(
            participants: _update(
              userId,
              (p) => p.copyWith(hasCamera: isCameraOn),
            ),
          ),
        );

      case CallTrackPublished(
        :final userId,
        :final mediaSessionId,
        :final trackName,
        :final kind,
        :final shareId,
      ):
        if (userId == _myUserId) return;
        _handleTrackPublished(
          userId: userId,
          mediaSessionId: mediaSessionId,
          trackName: trackName,
          kind: trackKindFromWire(kind),
          shareId: shareId,
        );

      case CallTrackClosed(:final userId, :final trackName, :final shareId):
        _handleTrackClosed(
          userId: userId,
          trackName: trackName,
          shareId: shareId,
        );

      case CallScreenShareStarted(:final userId, :final shareId):
        if (userId == _myUserId) return;
        emitIfOpen(
          state.copyWith(
            participants: _upsert(
              userId,
              (p) => p.withShare(shareId),
              () => CallParticipantState(
                userId: userId,
                shares: [VoiceShareState(shareId: shareId)],
              ),
            ),
          ),
        );
      // The tracks themselves arrive as TrackPublished; a refetch here would
      // race them for nothing.

      case CallScreenShareStopped(:final userId, :final shareId):
        emitIfOpen(
          state.copyWith(
            participants: _update(userId, (p) => p.withoutShare(shareId)),
            videoRevision: state.videoRevision + 1,
          ),
        );
        _webRtc?.unsubscribeShare(userId: userId, shareId: shareId);
        if (_watchedShares.remove(shareId)) {
          final callId = state.call?.id;
          if (callId != null) {
            unawaited(repository.unwatchShare(callId, shareId));
          }
        }

      case CallShareViewersChanged(:final shareId, :final viewerIds):
        emitIfOpen(
          state.copyWith(
            participants: [
              for (final p in state.participants)
                p.shareById(shareId) == null
                    ? p
                    : p.withShareViewers(shareId, viewerIds),
            ],
          ),
        );

      case CallAcceptedElsewhere(:final callId):
      case CallDeviceDismissed(:final callId):
        // Another device resolved the ring (accepted, or this device's own
        // decline raced a takeover) - dismiss silently, no "ended" messaging.
        if (state.phase == CallPhase.incoming && state.call?.id == callId) {
          emitIfOpen(_cleared());
        } else if (state.call?.id == callId) {
          _stopOutgoingRingback();
        }

      case CallDeviceTakeover(:final callId):
        if (state.call?.id == callId) {
          _stopOutgoingRingback();
          unawaited(() async {
            final webRtc = await _teardown();
            emitIfOpen(
              _cleared(
                disconnectNotice: 'You joined this call on another device.',
              ),
            );
            await webRtc?.disconnect();
          }());
        }

      case CallAlone(:final callId, :final deadline):
        if (state.call?.id == callId && state.phase == CallPhase.active) {
          emitIfOpen(state.copyWith(aloneDeadline: deadline));
        }

      case CallEndedRemotely(:final callId, :final reason):
        if (state.call?.id == callId) {
          _stopOutgoingRingback();
          unawaited(() async {
            final webRtc = await _teardown();
            emitIfOpen(_cleared(disconnectNotice: _endedNoticeFor(reason)));
            await webRtc?.disconnect();
          }());
        }
    }
  }

  /// The room is gone, or this device is not in it. Reached two ways, and the
  /// second is the one that matters during an outage: `Resync(roomGone)` over
  /// the hub, and a `404`/`409` from the HTTP liveness ping. A client the sweep
  /// evicted is announced to the roster it has just been removed from, so it is
  /// the one participant the hub event does not reach - the ping is the only
  /// channel that can tell it.
  Future<void> _handleRoomGone() async {
    final webRtc = await _teardown();
    emitIfOpen(_cleared());
    await webRtc?.disconnect();
  }

  void _handleTrackPublished({
    required String userId,
    required String mediaSessionId,
    required String trackName,
    required TrackKind kind,
    required String? shareId,
  }) {
    final webRtc = _webRtc;
    switch (kind) {
      case TrackKind.audio:
        // The microphone is subscribed via ParticipantJoined, which is the
        // event that guarantees the track exists.
        break;
      case TrackKind.video:
        unawaited(
          webRtc?.subscribeToTrack(
            userId: userId,
            mediaSessionId: mediaSessionId,
            trackName: trackName,
            kind: kind,
          ),
        );
        emitIfOpen(
          state.copyWith(
            participants: _update(userId, (p) => p.copyWith(hasCamera: true)),
            videoRevision: state.videoRevision + 1,
          ),
        );
      case TrackKind.screen:
      case TrackKind.screenAudio:
        if (shareId == null) return;
        emitIfOpen(
          state.copyWith(
            participants: _upsert(
              userId,
              (p) => p.withShare(shareId, trackName: trackName),
              () => CallParticipantState(
                userId: userId,
                shares: [
                  VoiceShareState(shareId: shareId, trackNames: [trackName]),
                ],
              ),
            ),
            videoRevision: state.videoRevision + 1,
          ),
        );
        // Only pull a share that is actually on screen - see [_sharesVisible].
        if (!_sharesVisible) return;
        final callId = state.call?.id;
        if (callId != null && _watchedShares.add(shareId)) {
          unawaited(_claimShare(callId, shareId));
        }
        unawaited(
          webRtc?.subscribeToTrack(
            userId: userId,
            mediaSessionId: mediaSessionId,
            trackName: trackName,
            kind: kind,
            shareId: shareId,
          ),
        );
    }
  }

  void _handleTrackClosed({
    required String userId,
    required String trackName,
    required String? shareId,
  }) {
    final descriptor = TrackNaming.describe(trackName);
    final resolvedShareId = shareId ?? descriptor.shareId;
    switch (descriptor.kind) {
      case TrackKind.audio:
        _webRtc?.unsubscribeTrack(userId: userId, kind: TrackKind.audio);
        emitIfOpen(
          state.copyWith(
            participants: _update(
              userId,
              (p) => p.copyWith(isPublishing: false),
            ),
          ),
        );
      case TrackKind.video:
        _webRtc?.unsubscribeTrack(userId: userId, kind: TrackKind.video);
        emitIfOpen(
          state.copyWith(
            participants: _update(userId, (p) => p.copyWith(hasCamera: false)),
            videoRevision: state.videoRevision + 1,
          ),
        );
      case TrackKind.screen:
      case TrackKind.screenAudio:
        if (resolvedShareId == null) return;
        _webRtc?.unsubscribeTrack(
          userId: userId,
          kind: descriptor.kind,
          shareId: resolvedShareId,
        );
        // Only the video half ending retires the share; a share can lose its
        // audio track and keep running.
        if (descriptor.kind != TrackKind.screen) return;
        emitIfOpen(
          state.copyWith(
            participants: _update(
              userId,
              (p) => p.withoutShare(resolvedShareId),
            ),
            videoRevision: state.videoRevision + 1,
          ),
        );
    }
  }

  // ── Calls in progress elsewhere ───────────────────────────────────────────

  /// Reads whether a call is already happening in [conversationId] - the
  /// catch-up for a conversation opened after the call started, which no event
  /// covers: the ring is addressed to invitees and never replayed.
  Future<void> refreshConversationCall(String conversationId) async {
    final OngoingCallDto? ongoing;
    try {
      ongoing = await repository.getConversationCall(conversationId);
    } catch (_) {
      return; // Best-effort: this is an affordance, not a blocker.
    }
    final ongoingByConversation = Map<String, OngoingCallDto>.from(
      state.ongoingByConversation,
    );
    if (ongoing == null) {
      ongoingByConversation.remove(conversationId);
    } else {
      ongoingByConversation[conversationId] = ongoing;
    }
    emitIfOpen(state.copyWith(ongoingByConversation: ongoingByConversation));
  }

  /// The call in progress in [conversationId] that this user is not in, or
  /// null. Never reports the call this device is already on.
  OngoingCallDto? ongoingCallIn(String conversationId) {
    final ongoing = state.ongoingByConversation[conversationId];
    if (ongoing == null) return null;
    if (state.call?.id == ongoing.callId) return null;
    return ongoing;
  }

  /// Joins a call already running in this conversation. Goes through `accept`
  /// like any other join, so the server applies the same device-takeover and
  /// permission handling rather than this being a second way in.
  Future<void> joinConversationCall(String conversationId) async {
    final ongoing = ongoingCallIn(conversationId);
    if (ongoing == null || state.phase != CallPhase.idle) return;
    await acceptIncomingCallById(ongoing.callId);
  }

  void _applyConversationCallState(ConversationCallStateChanged event) {
    final ongoingByConversation = Map<String, OngoingCallDto>.from(
      state.ongoingByConversation,
    );
    if (event.hasEnded) {
      ongoingByConversation.remove(event.conversationId);
    } else {
      // The event carries everything the read does except the start time,
      // which only matters for a duration this affordance does not show.
      ongoingByConversation[event.conversationId] = OngoingCallDto(
        callId: event.callId,
        conversationId: event.conversationId,
        status: 'Connected',
        connectedUserIds: event.participantIds,
      );
    }
    emitIfOpen(state.copyWith(ongoingByConversation: ongoingByConversation));
  }

  String? _endedNoticeFor(String? reason) => switch (reason) {
    'Declined' => 'Call declined.',
    'AloneTimeout' => 'Call ended - nobody rejoined in time.',
    _ => null,
  };

  // ── Roster helpers ────────────────────────────────────────────────────────

  CallParticipantState? get _self =>
      state.participants.where((p) => p.userId == _myUserId).firstOrNull;

  List<CallParticipantState> _update(
    String userId,
    CallParticipantState Function(CallParticipantState) update,
  ) => [for (final p in state.participants) p.userId == userId ? update(p) : p];

  List<CallParticipantState> _updateSelf(
    CallParticipantState Function(CallParticipantState) update,
  ) => _update(_myUserId, update);

  /// Updates a participant, or adds one built by [create] when the roster has
  /// not heard of them yet - a live event can name someone the last snapshot
  /// did not.
  List<CallParticipantState> _upsert(
    String userId,
    CallParticipantState Function(CallParticipantState) update,
    CallParticipantState Function() create,
  ) => state.participants.any((p) => p.userId == userId)
      ? _update(userId, update)
      : [...state.participants, create()];

  @override
  Future<void> close() {
    _heartbeat.stop();
    _liveness.stop();
    unawaited(_sub.cancel());
    unawaited(_connectionSub.cancel());
    return super.close();
  }
}
