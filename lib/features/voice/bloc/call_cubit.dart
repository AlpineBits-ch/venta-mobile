import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' show MediaStreamTrack;

import '../../../core/bloc/safe_emit.dart';
import '../../../core/realtime/realtime_transport.dart';
import '../../../core/sound/sound_service.dart';
import '../../../core/webrtc/track_kind.dart';
import '../../auth/data/auth_repository.dart';
import '../data/models/call_dto.dart';
import '../data/voice_repository.dart';
import '../webrtc/call_webrtc_service.dart';

enum CallPhase { idle, incoming, connecting, active }

class CallParticipantState extends Equatable {
  const CallParticipantState({
    required this.userId,
    this.isMuted = false,
    this.isStreaming = false,
    this.hasCamera = false,
    this.isSpeaking = false,
  });

  final String userId;
  final bool isMuted;

  /// Screen sharing.
  final bool isStreaming;
  final bool hasCamera;

  /// Server-side voice-activity detection - drives the ring around a talking
  /// participant's avatar.
  final bool isSpeaking;

  CallParticipantState copyWith({
    bool? isMuted,
    bool? isStreaming,
    bool? hasCamera,
    bool? isSpeaking,
  }) => CallParticipantState(
    userId: userId,
    isMuted: isMuted ?? this.isMuted,
    isStreaming: isStreaming ?? this.isStreaming,
    hasCamera: hasCamera ?? this.hasCamera,
    isSpeaking: isSpeaking ?? this.isSpeaking,
  );

  @override
  List<Object?> get props => [
    userId,
    isMuted,
    isStreaming,
    hasCamera,
    isSpeaking,
  ];
}

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
  });

  final CallPhase phase;
  final CallDto? call;
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
  /// - the deadline (~5 min out) the server will force-end the call at if
  /// nobody rejoins. Cleared once another participant is observed.
  final DateTime? aloneDeadline;

  /// Bumped on every local/remote camera or screen-share track add/remove -
  /// `MediaStreamTrack`s themselves can't live in this `Equatable` state (not
  /// comparable/immutable-safe), so `VideoParticipantTile`/`ScreenShareView`
  /// instead pull the current track imperatively from the webrtc service and
  /// rely on this counter changing to know when to re-pull and rebuild.
  final int videoRevision;

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
  }) => CallState(
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
  ];
}

/// App-lifetime singleton owning the one call the app can be in at a time -
/// the domain/UI-state counterpart to Alpine desktop's `CallSessionService`.
/// `CallWebRtcService` (a fresh instance per call) owns the actual WebRTC
/// plumbing; this cubit just tells it which participants to subscribe to.
class CallCubit extends Cubit<CallState> with SafeEmit<CallState> {
  CallCubit({
    required this.repository,
    required this.authRepository,
    required this.soundService,
    required CallWebRtcService Function() webRtcServiceFactory,
  }) : _webRtcServiceFactory = webRtcServiceFactory,
       super(const CallState()) {
    _sub = repository.events.listen(_handleEvent);
    _connectionSub = repository.connectionStatus.listen(
      _handleConnectionStatus,
    );
  }

  final VoiceRepository repository;
  final AuthRepository authRepository;
  final SoundService soundService;
  final CallWebRtcService Function() _webRtcServiceFactory;
  late final StreamSubscription<VoiceRepositoryEvent> _sub;
  late final StreamSubscription<RealtimeConnectionStatus> _connectionSub;
  CallWebRtcService? _webRtc;

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
    } catch (_) {
      _stopOutgoingRingback();
      emitIfOpen(const CallState(errorMessage: 'Could not start the call.'));
    }
  }

  Future<void> acceptIncomingCall() async {
    final call = state.call;
    if (state.phase != CallPhase.incoming || call == null) return;
    emitIfOpen(state.copyWith(phase: CallPhase.connecting));
    try {
      final accepted = await repository.acceptCall(call.id);
      await _connect(accepted);
    } catch (_) {
      emitIfOpen(const CallState(errorMessage: 'Could not join the call.'));
    }
  }

  Future<void> declineIncomingCall() async {
    final call = state.call;
    if (state.phase != CallPhase.incoming || call == null) return;
    emitIfOpen(const CallState());
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
  /// [CallPhase.incoming] for that reason; `CallKitService` picks whichever
  /// of this or [acceptIncomingCall] applies based on current state.
  Future<void> acceptIncomingCallById(String callId) async {
    if (state.phase != CallPhase.idle) return;
    emitIfOpen(state.copyWith(phase: CallPhase.connecting));
    try {
      final accepted = await repository.acceptCall(callId);
      await _connect(accepted);
    } catch (_) {
      emitIfOpen(const CallState(errorMessage: 'Could not join the call.'));
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
  /// This is a local hang-up (removes just this user), not a force-end for
  /// everyone - see [endCall].
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

  /// Hangs up the current call. Calls the `leave` endpoint - this removes
  /// just the local user, it does not end the call for anyone still
  /// connected (a 1:1 call still ends almost immediately in practice once
  /// the other side also leaves/was never connected, but the mechanism is
  /// the same as a group call). There's no "end call for everyone" action in
  /// this UI, so that's the only teardown path this cubit exposes.
  Future<void> endCall() async {
    final call = state.call;
    if (call == null) return;
    _stopOutgoingRingback();
    final webRtc = _webRtc;
    _webRtc = null;
    emitIfOpen(const CallState());
    await webRtc?.disconnect();
    try {
      await repository.leaveCall(call.id);
    } catch (_) {
      // Best-effort - we've already torn down locally.
    }
  }

  Future<void> toggleMute() async {
    if (state.phase != CallPhase.active) return;
    final isMuted = !state.isMuted;
    emitIfOpen(state.copyWith(isMuted: isMuted));
    _webRtc?.setMuted(isMuted);
    final callId = state.call?.id;
    if (callId != null) {
      await repository.invokeMuteChanged(callId: callId, isMuted: isMuted);
    }
  }

  void toggleDeafen() {
    if (state.phase != CallPhase.active) return;
    final isDeafened = !state.isDeafened;
    emitIfOpen(state.copyWith(isDeafened: isDeafened));
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
  bool get isCameraOn =>
      state.participants
          .where((p) => p.userId == _myUserId)
          .firstOrNull
          ?.hasCamera ??
      false;

  Future<void> toggleCamera() async {
    if (state.phase != CallPhase.active) return;
    final webRtc = _webRtc;
    final callId = state.call?.id;
    if (webRtc == null || callId == null) return;
    final turningOn = !isCameraOn;
    try {
      if (turningOn) {
        await webRtc.publishLocalVideo();
      } else {
        await webRtc.stopLocalVideo();
      }
    } catch (_) {
      return; // Capture failed (denied permission, no camera, etc.) - bail.
    }
    emitIfOpen(
      state.copyWith(
        participants: [
          for (final p in state.participants)
            p.userId == _myUserId ? p.copyWith(hasCamera: turningOn) : p,
        ],
      ),
    );
    _bumpVideoRevision();
    await repository.invokeCameraChanged(callId: callId, isCameraOn: turningOn);
  }

  /// Mirrors [isCameraOn] for screen sharing - Android only (see
  /// `toggleScreenShare` callers, which gate the button by platform).
  bool get isScreenSharing =>
      state.participants
          .where((p) => p.userId == _myUserId)
          .firstOrNull
          ?.isStreaming ??
      false;

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
          participants: [
            for (final p in state.participants)
              p.userId == _myUserId ? p.copyWith(isStreaming: false) : p,
          ],
        ),
      );
      _bumpVideoRevision();
      if (shareId != null) {
        await repository.invokeScreenShareStopped(
          callId: callId,
          shareId: shareId,
        );
      }
    } else {
      final shareId =
          '${DateTime.now().microsecondsSinceEpoch}-${identityHashCode(this)}';
      try {
        await webRtc.startScreenShare(shareId);
      } catch (_) {
        return; // Permission denied/cancelled the system picker - bail.
      }
      _myShareId = shareId;
      emitIfOpen(
        state.copyWith(
          participants: [
            for (final p in state.participants)
              p.userId == _myUserId ? p.copyWith(isStreaming: true) : p,
          ],
        ),
      );
      _bumpVideoRevision();
      await repository.invokeScreenShareStarted(
        callId: callId,
        shareId: shareId,
        trackName: 'screen-$shareId',
      );
    }
  }

  void _bumpVideoRevision() =>
      emitIfOpen(state.copyWith(videoRevision: state.videoRevision + 1));

  /// Track getters for the UI - read imperatively, see [CallState.videoRevision]
  /// doc comment for why `MediaStreamTrack`s can't live in cubit state itself.
  MediaStreamTrack? get localVideoTrack => _webRtc?.localVideoTrack;
  MediaStreamTrack? get localScreenTrack => _webRtc?.localScreenTrack;
  MediaStreamTrack? remoteVideoTrackFor(String userId) =>
      _webRtc?.remoteVideoTrackFor(userId);
  MediaStreamTrack? remoteScreenTrackFor(String userId) =>
      _webRtc?.remoteScreenTrackFor(userId);

  Future<void> _connect(CallDto call) async {
    final webRtc = _webRtcServiceFactory();
    _webRtc = webRtc;
    final participants = call.participants
        .map((p) => CallParticipantState(userId: p.userId))
        .toList();
    emitIfOpen(
      state.copyWith(
        phase: CallPhase.active,
        call: call,
        participants: participants,
        connectedAt: DateTime.now(),
      ),
    );
    try {
      await webRtc.connect(call.id);
      webRtc.setMuted(state.isMuted);
      webRtc.setDeafened(state.isDeafened);
      await webRtc.setSpeakerphoneOn(state.isSpeakerOn);
      // Backfill-subscribe to anyone already publishing audio, rather than
      // relying solely on the live `call.ParticipantJoined` event - that
      // event can be missed (e.g. joining a group call already in progress,
      // or a SignalR gap right around connect). Mirrors GuildVoiceCubit.
      for (final p in call.participants) {
        final cfSessionId = p.cfSessionId;
        final trackName = p.audioTrackName;
        if (p.userId != _myUserId && cfSessionId != null && trackName != null) {
          unawaited(
            webRtc.subscribeToParticipant(
              userId: p.userId,
              cfSessionId: cfSessionId,
              trackName: trackName,
            ),
          );
        }
      }
    } catch (_) {
      emitIfOpen(state.copyWith(errorMessage: 'Could not connect audio.'));
    }
  }

  /// Asks the server whether a call is ringing for this user that this client
  /// was never told about.
  ///
  /// `call.IncomingCall` is broadcast once and never replayed. Every path that
  /// misses it ends the same way - the phone is ringing somewhere and the app
  /// shows nothing:
  ///
  ///  * the app was opened after the call started (the common one - the socket
  ///    connects, and the event it needed went out seconds earlier);
  ///  * the socket was down when the call was placed and reconnected after;
  ///  * the call push never arrived, which is best-effort by construction.
  ///
  /// Called on every realtime connect, and once explicitly at startup
  /// (`startAuthenticatedServices`) - the socket connects before this cubit is
  /// constructed on a cold start, so the connect event alone would miss exactly
  /// the case this exists for. Cheap: `204` with no body is the answer
  /// essentially always, and the phase guard means it never runs mid-call.
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

  /// A reconnect is the signal that any `call.*` events broadcast during the
  /// gap were dropped - SignalR doesn't queue undelivered messages. Re-fetches
  /// authoritative state and reconciles: subscribes to participants we never
  /// heard about, unsubscribes from ones who left, and hangs up locally if the
  /// call ended (or we were removed) while disconnected.
  Future<void> _handleConnectionStatus(RealtimeConnectionStatus status) async {
    if (status != RealtimeConnectionStatus.connected) return;
    if (state.phase == CallPhase.idle) {
      await catchUpOnPendingCall();
      return;
    }
    if (state.phase != CallPhase.active) return;
    final call = state.call;
    final webRtc = _webRtc;
    if (call == null || webRtc == null) return;

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
      _webRtc = null;
      emitIfOpen(const CallState());
      unawaited(webRtc.disconnect());
      return;
    }

    final freshIds = fresh.participants.map((p) => p.userId).toSet();
    for (final gone in state.participants.where(
      (p) => !freshIds.contains(p.userId),
    )) {
      webRtc.unsubscribeParticipant(gone.userId);
    }
    final remaining = state.participants
        .where((p) => freshIds.contains(p.userId))
        .toList();
    final knownIds = remaining.map((p) => p.userId).toSet();

    final newParticipants = <CallParticipantState>[];
    for (final p in fresh.participants) {
      if (p.userId == _myUserId || knownIds.contains(p.userId)) continue;
      newParticipants.add(CallParticipantState(userId: p.userId));
      final cfSessionId = p.cfSessionId;
      final trackName = p.audioTrackName;
      if (cfSessionId != null && trackName != null) {
        unawaited(
          webRtc.subscribeToParticipant(
            userId: p.userId,
            cfSessionId: cfSessionId,
            trackName: trackName,
          ),
        );
      }
    }

    emitIfOpen(
      state.copyWith(
        call: fresh,
        participants: [...remaining, ...newParticipants],
      ),
    );
  }

  void _handleEvent(VoiceRepositoryEvent event) {
    switch (event) {
      case IncomingCallReceived(:final call):
        final isForMe = call.participants.any((p) => p.userId == _myUserId);
        if (state.phase == CallPhase.idle && isForMe) {
          emitIfOpen(CallState(phase: CallPhase.incoming, call: call));
        }

      case CallParticipantJoined(
        :final userId,
        :final cfSessionId,
        :final audioTrackName,
      ):
        if (userId == _myUserId || state.phase != CallPhase.active) return;
        _stopOutgoingRingback();
        if (!state.participants.any((p) => p.userId == userId)) {
          emitIfOpen(
            state.copyWith(
              participants: [
                ...state.participants,
                CallParticipantState(userId: userId),
              ],
              clearAloneDeadline: true,
            ),
          );
        }
        unawaited(
          _webRtc?.subscribeToParticipant(
            userId: userId,
            cfSessionId: cfSessionId,
            trackName: audioTrackName,
          ),
        );

      case CallParticipantLeft(:final userId):
        emitIfOpen(
          state.copyWith(
            participants: state.participants
                .where((p) => p.userId != userId)
                .toList(),
          ),
        );
        _webRtc?.unsubscribeParticipant(userId);

      case CallLifecycleParticipantLeft(:final userId):
        // Roster-level counterpart to CallParticipantLeft above - handled
        // identically (idempotent either way, whichever actually fires).
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
            participants: [
              for (final p in state.participants)
                p.userId == userId ? p.copyWith(isMuted: isMuted) : p,
            ],
          ),
        );

      case CallSpeakingChanged(:final userId, :final isSpeaking):
        emitIfOpen(
          state.copyWith(
            participants: [
              for (final p in state.participants)
                p.userId == userId ? p.copyWith(isSpeaking: isSpeaking) : p,
            ],
          ),
        );

      case CallCameraChanged(:final userId, :final isCameraOn):
        if (userId == _myUserId) return;
        emitIfOpen(
          state.copyWith(
            participants: [
              for (final p in state.participants)
                p.userId == userId ? p.copyWith(hasCamera: isCameraOn) : p,
            ],
          ),
        );

      case CallTrackPublished(
        :final userId,
        :final cfSessionId,
        :final trackName,
        :final kind,
      ):
        if (userId == _myUserId) return;
        final trackKind = trackKindFromWire(kind);
        if (trackKind == null) return; // screenAudio or unknown - ignored
        unawaited(
          _webRtc?.subscribeToTrack(
            userId: userId,
            cfSessionId: cfSessionId,
            trackName: trackName,
            kind: trackKind,
          ),
        );
        emitIfOpen(
          state.copyWith(
            participants: [
              for (final p in state.participants)
                if (p.userId == userId)
                  trackKind == TrackKind.screen
                      ? p.copyWith(isStreaming: true)
                      : p.copyWith(hasCamera: true)
                else
                  p,
            ],
            videoRevision: state.videoRevision + 1,
          ),
        );

      case CallTrackClosed(:final userId, :final trackName):
        final trackKind = trackName == 'camera'
            ? TrackKind.video
            : trackName.startsWith('screen-')
            ? TrackKind.screen
            : null;
        if (trackKind == null) return;
        _webRtc?.unsubscribeTrack(userId: userId, kind: trackKind);
        emitIfOpen(
          state.copyWith(
            participants: [
              for (final p in state.participants)
                if (p.userId == userId)
                  trackKind == TrackKind.screen
                      ? p.copyWith(isStreaming: false)
                      : p.copyWith(hasCamera: false)
                else
                  p,
            ],
            videoRevision: state.videoRevision + 1,
          ),
        );

      case CallScreenShareStarted(:final userId):
        emitIfOpen(
          state.copyWith(
            participants: [
              for (final p in state.participants)
                p.userId == userId ? p.copyWith(isStreaming: true) : p,
            ],
          ),
        );

      case CallScreenShareStopped():
        break; // Teardown rides on CallTrackClosed, same as guild voice.

      case CallAcceptedElsewhere(:final callId):
      case CallDeviceDismissed(:final callId):
        // Another device resolved the ring (accepted, or this device's own
        // decline raced a takeover) - dismiss silently, no "ended" messaging.
        if (state.phase == CallPhase.incoming && state.call?.id == callId) {
          emitIfOpen(const CallState());
        } else if (state.call?.id == callId) {
          _stopOutgoingRingback();
        }

      case CallDeviceTakeover(:final callId):
        if (state.call?.id == callId) {
          _stopOutgoingRingback();
          final webRtc = _webRtc;
          _webRtc = null;
          emitIfOpen(
            const CallState(
              disconnectNotice: 'You joined this call on another device.',
            ),
          );
          unawaited(webRtc?.disconnect());
        }

      case CallAlone(:final callId, :final deadline):
        if (state.call?.id == callId && state.phase == CallPhase.active) {
          emitIfOpen(state.copyWith(aloneDeadline: deadline));
        }

      case CallEndedRemotely(:final callId, :final reason):
        if (state.call?.id == callId) {
          _stopOutgoingRingback();
          final webRtc = _webRtc;
          _webRtc = null;
          emitIfOpen(CallState(disconnectNotice: _endedNoticeFor(reason)));
          unawaited(webRtc?.disconnect());
        }
    }
  }

  String? _endedNoticeFor(String? reason) => switch (reason) {
    'Declined' => 'Call declined.',
    'AloneTimeout' => 'Call ended - nobody rejoined in time.',
    _ => null,
  };

  @override
  Future<void> close() {
    unawaited(_sub.cancel());
    unawaited(_connectionSub.cancel());
    return super.close();
  }
}
