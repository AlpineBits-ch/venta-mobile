import 'dart:async';

import '../../../core/realtime/realtime_event.dart';
import '../../../core/realtime/realtime_service.dart';
import '../../../core/realtime/realtime_transport.dart';
import 'models/call_dto.dart';
import 'voice_api.dart';

sealed class VoiceRepositoryEvent {
  const VoiceRepositoryEvent();
}

class IncomingCallReceived extends VoiceRepositoryEvent {
  const IncomingCallReceived(this.call);
  final CallDto call;
}

/// Someone joined the call. [cfSessionId]/[audioTrackName] are their CF
/// Calls session + published audio track name — needed to subscribe to it.
class CallParticipantJoined extends VoiceRepositoryEvent {
  const CallParticipantJoined({
    required this.userId,
    required this.cfSessionId,
    required this.audioTrackName,
  });

  final String userId;
  final String cfSessionId;
  final String audioTrackName;
}

class CallParticipantLeft extends VoiceRepositoryEvent {
  const CallParticipantLeft(this.userId);
  final String userId;
}

class CallMuteChanged extends VoiceRepositoryEvent {
  const CallMuteChanged({required this.userId, required this.isMuted});
  final String userId;
  final bool isMuted;
}

class CallEndedRemotely extends VoiceRepositoryEvent {
  const CallEndedRemotely(this.callId);
  final String callId;
}

/// App-lifetime singleton (like `ConversationRepository`) — the single hub
/// connection's `call.*` events need to reach the incoming-call banner even
/// when no call screen is on-screen yet, so this can't be scoped to one call.
class VoiceRepository {
  VoiceRepository({required this.api, required RealtimeService realtimeService})
      : _realtimeService = realtimeService {
    _realtimeSub =
        realtimeService.events.where((e) => e.name.startsWith('call.')).listen(_handleRealtimeEvent);
  }

  final VoiceApi api;
  final RealtimeService _realtimeService;
  late final StreamSubscription<RealtimeEvent> _realtimeSub;

  final _eventsController = StreamController<VoiceRepositoryEvent>.broadcast();
  Stream<VoiceRepositoryEvent> get events => _eventsController.stream;

  /// Drives [CallCubit]'s reconcile-on-reconnect — a transition back to
  /// [RealtimeConnectionStatus.connected] is the signal that any `call.*`
  /// events broadcast during the gap were silently dropped.
  Stream<RealtimeConnectionStatus> get connectionStatus => _realtimeService.connectionStatus;

  void _handleRealtimeEvent(RealtimeEvent event) {
    final payload = event.objectPayload;
    switch (event.name) {
      case 'call.IncomingCall':
        _eventsController.add(IncomingCallReceived(CallDto.fromJson(payload)));
      case 'call.ParticipantJoined':
        _eventsController.add(
          CallParticipantJoined(
            userId: payload['userId'] as String,
            cfSessionId: payload['cfSessionId'] as String,
            audioTrackName: payload['audioTrackName'] as String,
          ),
        );
      case 'call.ParticipantLeft':
        _eventsController.add(CallParticipantLeft(payload['userId'] as String));
      case 'call.MuteChanged':
        _eventsController.add(
          CallMuteChanged(userId: payload['userId'] as String, isMuted: payload['isMuted'] as bool),
        );
      case 'call.CallEnded':
        _eventsController.add(CallEndedRemotely(payload['callId'] as String));
    }
  }

  Future<CallDto> createCall({required String conversationId, required List<String> participantUserIds}) =>
      api.createCall(conversationId: conversationId, participantUserIds: participantUserIds);

  Future<CallDto> acceptCall(String callId) => api.acceptCall(callId);

  Future<CallDto> declineCall(String callId) => api.declineCall(callId);

  Future<CallDto> endCall(String callId) => api.endCall(callId);

  Future<CallDto> getCall(String callId) => api.getCall(callId);

  Future<void> invokeMuteChanged({required String callId, required bool isMuted}) => _realtimeService.invoke(
        'call.MuteChanged',
        args: [
          {'callId': callId, 'isMuted': isMuted},
        ],
      );

  void dispose() {
    _realtimeSub.cancel();
    _eventsController.close();
  }
}
