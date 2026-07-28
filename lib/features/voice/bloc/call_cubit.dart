import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/data/auth_repository.dart';
import '../data/models/call_dto.dart';
import '../data/voice_repository.dart';
import '../webrtc/call_webrtc_service.dart';

enum CallPhase { idle, incoming, connecting, active }

class CallParticipantState extends Equatable {
  const CallParticipantState({required this.userId, this.isMuted = false});

  final String userId;
  final bool isMuted;

  CallParticipantState copyWith({bool? isMuted}) =>
      CallParticipantState(userId: userId, isMuted: isMuted ?? this.isMuted);

  @override
  List<Object?> get props => [userId, isMuted];
}

class CallState extends Equatable {
  const CallState({
    this.phase = CallPhase.idle,
    this.call,
    this.participants = const [],
    this.isMuted = false,
    this.isDeafened = false,
    this.errorMessage,
  });

  final CallPhase phase;
  final CallDto? call;
  final List<CallParticipantState> participants;
  final bool isMuted;
  final bool isDeafened;
  final String? errorMessage;

  /// [errorMessage] is always set as given (including `null`), never
  /// falling back to the current value — every emitting call site
  /// recomputes it, and `null` there means "no error", not "unchanged".
  CallState copyWith({
    CallPhase? phase,
    CallDto? call,
    List<CallParticipantState>? participants,
    bool? isMuted,
    bool? isDeafened,
    String? errorMessage,
  }) =>
      CallState(
        phase: phase ?? this.phase,
        call: call ?? this.call,
        participants: participants ?? this.participants,
        isMuted: isMuted ?? this.isMuted,
        isDeafened: isDeafened ?? this.isDeafened,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [phase, call, participants, isMuted, isDeafened, errorMessage];
}

/// App-lifetime singleton owning the one call the app can be in at a time —
/// the domain/UI-state counterpart to Alpine desktop's `CallSessionService`.
/// `CallWebRtcService` (a fresh instance per call) owns the actual WebRTC
/// plumbing; this cubit just tells it which participants to subscribe to.
class CallCubit extends Cubit<CallState> {
  CallCubit({
    required this.repository,
    required this.authRepository,
    required CallWebRtcService Function() webRtcServiceFactory,
  })  : _webRtcServiceFactory = webRtcServiceFactory,
        super(const CallState()) {
    _sub = repository.events.listen(_handleEvent);
  }

  final VoiceRepository repository;
  final AuthRepository authRepository;
  final CallWebRtcService Function() _webRtcServiceFactory;
  late final StreamSubscription<VoiceRepositoryEvent> _sub;
  CallWebRtcService? _webRtc;

  String get _myUserId => authRepository.currentUserId ?? '';

  Future<void> startCall({
    required String conversationId,
    required List<String> participantUserIds,
  }) async {
    if (state.phase != CallPhase.idle) return;
    emit(state.copyWith(phase: CallPhase.connecting));
    try {
      final call = await repository.createCall(
        conversationId: conversationId,
        participantUserIds: participantUserIds,
      );
      await _connect(call);
    } catch (_) {
      emit(const CallState(errorMessage: 'Could not start the call.'));
    }
  }

  Future<void> acceptIncomingCall() async {
    final call = state.call;
    if (state.phase != CallPhase.incoming || call == null) return;
    emit(state.copyWith(phase: CallPhase.connecting));
    try {
      final accepted = await repository.acceptCall(call.id);
      await _connect(accepted);
    } catch (_) {
      emit(const CallState(errorMessage: 'Could not join the call.'));
    }
  }

  Future<void> declineIncomingCall() async {
    final call = state.call;
    if (state.phase != CallPhase.incoming || call == null) return;
    emit(const CallState());
    try {
      await repository.declineCall(call.id);
    } catch (_) {
      // Best-effort — we've already left the incoming-call UI locally.
    }
  }

  Future<void> endCall() async {
    final call = state.call;
    if (call == null) return;
    final webRtc = _webRtc;
    _webRtc = null;
    emit(const CallState());
    await webRtc?.disconnect();
    try {
      await repository.endCall(call.id);
    } catch (_) {
      // Best-effort — we've already torn down locally.
    }
  }

  Future<void> toggleMute() async {
    if (state.phase != CallPhase.active) return;
    final isMuted = !state.isMuted;
    emit(state.copyWith(isMuted: isMuted));
    _webRtc?.setMuted(isMuted);
    final callId = state.call?.id;
    if (callId != null) {
      await repository.invokeMuteChanged(callId: callId, isMuted: isMuted);
    }
  }

  void toggleDeafen() {
    if (state.phase != CallPhase.active) return;
    final isDeafened = !state.isDeafened;
    emit(state.copyWith(isDeafened: isDeafened));
    _webRtc?.setDeafened(isDeafened);
  }

  Future<void> _connect(CallDto call) async {
    final webRtc = _webRtcServiceFactory();
    _webRtc = webRtc;
    final participants = call.participants.map((p) => CallParticipantState(userId: p.userId)).toList();
    emit(state.copyWith(phase: CallPhase.active, call: call, participants: participants));
    try {
      await webRtc.connect(call.id);
      webRtc.setMuted(state.isMuted);
      webRtc.setDeafened(state.isDeafened);
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Could not connect audio.'));
    }
  }

  void _handleEvent(VoiceRepositoryEvent event) {
    switch (event) {
      case IncomingCallReceived(:final call):
        final isForMe = call.participants.any((p) => p.userId == _myUserId);
        if (state.phase == CallPhase.idle && isForMe) {
          emit(CallState(phase: CallPhase.incoming, call: call));
        }

      case CallParticipantJoined(:final userId, :final cfSessionId, :final audioTrackName):
        if (userId == _myUserId || state.phase != CallPhase.active) return;
        if (!state.participants.any((p) => p.userId == userId)) {
          emit(state.copyWith(participants: [...state.participants, CallParticipantState(userId: userId)]));
        }
        unawaited(
          _webRtc?.subscribeToParticipant(
            userId: userId,
            cfSessionId: cfSessionId,
            trackName: audioTrackName,
          ),
        );

      case CallParticipantLeft(:final userId):
        emit(state.copyWith(participants: state.participants.where((p) => p.userId != userId).toList()));
        _webRtc?.unsubscribeParticipant(userId);

      case CallMuteChanged(:final userId, :final isMuted):
        emit(
          state.copyWith(
            participants: [
              for (final p in state.participants) p.userId == userId ? p.copyWith(isMuted: isMuted) : p,
            ],
          ),
        );

      case CallEndedRemotely(:final callId):
        if (state.call?.id == callId) {
          final webRtc = _webRtc;
          _webRtc = null;
          emit(const CallState());
          unawaited(webRtc?.disconnect());
        }
    }
  }

  @override
  Future<void> close() {
    unawaited(_sub.cancel());
    return super.close();
  }
}
