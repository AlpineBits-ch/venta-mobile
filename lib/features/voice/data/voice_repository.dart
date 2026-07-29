import 'dart:async';

import '../../../core/device/device_id_service.dart';
import '../../../core/realtime/realtime_event.dart';
import '../../../core/realtime/realtime_service.dart';
import '../../../core/realtime/realtime_transport.dart';
import 'models/call_dto.dart';
import 'voice_api.dart';

sealed class VoiceRepositoryEvent {
  const VoiceRepositoryEvent();
}

/// Another of the user's own devices accepted this call — dismiss the local
/// ringing UI on this device the same way a local decline would, no "call
/// ended" messaging. No-op if this device isn't currently ringing for the
/// call (e.g. it's the device that itself just accepted).
class CallAcceptedElsewhere extends VoiceRepositoryEvent {
  const CallAcceptedElsewhere(this.callId);
  final String callId;
}

/// A stale decline from *this* device arrived after the user had already
/// connected on another device. Dismiss the local ring UI silently — the
/// call keeps running elsewhere.
class CallDeviceDismissed extends VoiceRepositoryEvent {
  const CallDeviceDismissed(this.callId);
  final String callId;
}

/// This device's connection to the call was just taken over by another of
/// the user's own devices (e.g. accepted on a second device). Must tear down
/// local WebRTC/audio without calling leave — the server already updated
/// state.
class CallDeviceTakeover extends VoiceRepositoryEvent {
  const CallDeviceTakeover(this.callId);
  final String callId;
}

/// A participant left a still-active call via the new `leave` endpoint — the
/// call keeps running for everyone else. Distinct from [CallParticipantLeft]
/// (the CF-Calls-track-level presence event); both are handled the same way
/// client-side (remove from roster, unsubscribe audio) since either may be
/// the one that actually fires for a given `leave`.
class CallLifecycleParticipantLeft extends VoiceRepositoryEvent {
  const CallLifecycleParticipantLeft(this.userId);
  final String userId;
}

/// The call dropped to exactly one connected participant (this device's
/// user) — a 5-minute grace period started server-side, ending at [deadline].
class CallAlone extends VoiceRepositoryEvent {
  const CallAlone({required this.callId, required this.deadline});
  final String callId;
  final DateTime deadline;
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

/// [reason] is the backend's `CallEndedReason` — one of `Declined`,
/// `UserEnded`, `AllParticipantsLeft`, `AloneTimeout` — used to pick UI copy.
/// May be `null` for events from before this field existed.
class CallEndedRemotely extends VoiceRepositoryEvent {
  const CallEndedRemotely(this.callId, {this.reason});
  final String callId;
  final String? reason;
}

/// App-lifetime singleton (like `ConversationRepository`) — the single hub
/// connection's `call.*` events need to reach the incoming-call banner even
/// when no call screen is on-screen yet, so this can't be scoped to one call.
class VoiceRepository {
  VoiceRepository({
    required this.api,
    required RealtimeService realtimeService,
    required DeviceIdService deviceIdService,
  })  : _realtimeService = realtimeService,
        _deviceIdService = deviceIdService {
    _realtimeSub =
        realtimeService.events.where((e) => e.name.startsWith('call.')).listen(_handleRealtimeEvent);
  }

  final VoiceApi api;
  final RealtimeService _realtimeService;
  final DeviceIdService _deviceIdService;
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
        _eventsController.add(
          CallEndedRemotely(payload['callId'] as String, reason: payload['reason'] as String?),
        );
      case 'call.CallAccepted':
        _eventsController.add(CallAcceptedElsewhere(payload['callId'] as String));
      case 'call.CallDeviceDismissed':
        _eventsController.add(CallDeviceDismissed(payload['callId'] as String));
      case 'call.CallDeviceTakeover':
        _eventsController.add(CallDeviceTakeover(payload['callId'] as String));
      case 'call.CallParticipantLeft':
        _eventsController.add(CallLifecycleParticipantLeft(payload['userId'] as String));
      case 'call.CallAlone':
        _eventsController.add(
          CallAlone(
            callId: payload['callId'] as String,
            deadline: DateTime.parse(payload['deadline'] as String),
          ),
        );
    }
  }

  Future<CallDto> createCall({required String conversationId, required List<String> participantUserIds}) =>
      api.createCall(
        conversationId: conversationId,
        participantUserIds: participantUserIds,
        deviceId: _deviceIdService.deviceId,
      );

  Future<CallDto> acceptCall(String callId) => api.acceptCall(callId, deviceId: _deviceIdService.deviceId);

  Future<CallDto> declineCall(String callId) => api.declineCall(callId, deviceId: _deviceIdService.deviceId);

  /// Removes the local user from the call without ending it for anyone else
  /// still connected — see [VoiceApi.leaveCall].
  Future<CallDto> leaveCall(String callId) => api.leaveCall(callId, deviceId: _deviceIdService.deviceId);

  Future<CallDto> endCall(String callId) => api.endCall(callId, deviceId: _deviceIdService.deviceId);

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
