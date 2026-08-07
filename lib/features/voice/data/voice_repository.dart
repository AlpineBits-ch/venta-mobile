import 'dart:async';

import '../../../core/format/api_date_time.dart';
import '../../../core/realtime/realtime_event.dart';
import '../../../core/realtime/realtime_service.dart';
import '../../../core/realtime/realtime_transport.dart';
import '../../../core/voice/voice_heartbeat.dart';
import '../../../core/voice/voice_room_gate.dart';
import '../../../core/voice/voice_snapshot_dto.dart';
import 'models/call_dto.dart';
import 'models/ongoing_call_dto.dart';
import 'voice_api.dart';

sealed class VoiceRepositoryEvent {
  const VoiceRepositoryEvent();
}

/// The authoritative state of the call. Applied wholesale - never merged.
///
/// Arrives on join, on publish, whenever the server decides this client is out
/// of date, and whenever the version gate here notices a gap and refetches.
class CallSnapshotReceived extends VoiceRepositoryEvent {
  const CallSnapshotReceived(this.snapshot);
  final VoiceRoomSnapshotDto snapshot;
}

/// "Refetch, you are behind." Carries a reason but never a delta.
///
/// [reason] is `roomGone`, `participantLeft` or `peerPublishChanged`. Only
/// `roomGone` needs handling beyond the refetch this repository has already
/// started: the room is gone and rejoining must go through the normal
/// authorised path, because re-admitting on the strength of the client's own
/// claim would let anyone kicked or banned walk back in.
class CallResyncRequested extends VoiceRepositoryEvent {
  const CallResyncRequested({required this.reason, this.userId});
  final String reason;
  final String? userId;

  bool get isRoomGone => reason == 'roomGone';
}

/// Another of the user's own devices accepted this call - dismiss the local
/// ringing UI on this device the same way a local decline would, no "call
/// ended" messaging. No-op if this device isn't currently ringing for the
/// call (e.g. it's the device that itself just accepted).
class CallAcceptedElsewhere extends VoiceRepositoryEvent {
  const CallAcceptedElsewhere(this.callId);
  final String callId;
}

/// A stale decline from *this* device arrived after the user had already
/// connected on another device. Dismiss the local ring UI silently - the
/// call keeps running elsewhere.
class CallDeviceDismissed extends VoiceRepositoryEvent {
  const CallDeviceDismissed(this.callId);
  final String callId;
}

/// This device's connection to the call was just taken over by another of
/// the user's own devices (e.g. accepted on a second device). Must tear down
/// local WebRTC/audio without calling leave - the server already updated
/// state.
class CallDeviceTakeover extends VoiceRepositoryEvent {
  const CallDeviceTakeover(this.callId);
  final String callId;
}

/// A participant left a still-active call via the `leave` endpoint - the call
/// keeps running for everyone else. Distinct from [CallParticipantLeft] (the
/// media-level presence event); both are handled the same way client-side
/// since either may be the one that actually fires for a given leave.
class CallLifecycleParticipantLeft extends VoiceRepositoryEvent {
  const CallLifecycleParticipantLeft(this.userId);
  final String userId;
}

/// The call dropped to exactly one connected participant (this device's
/// user) - a grace period started server-side, ending at [deadline].
class CallAlone extends VoiceRepositoryEvent {
  const CallAlone({required this.callId, required this.deadline});
  final String callId;
  final DateTime deadline;
}

class IncomingCallReceived extends VoiceRepositoryEvent {
  const IncomingCallReceived(this.call);
  final CallDto call;
}

/// This user is now **pullable**: their session and microphone track both
/// exist. Never sent for someone who has merely opened a session, so the
/// subscribe that follows will work.
class CallParticipantJoined extends VoiceRepositoryEvent {
  const CallParticipantJoined({
    required this.userId,
    required this.mediaSessionId,
    required this.audioTrackName,
  });

  final String userId;
  final String mediaSessionId;
  final String audioTrackName;
}

class CallParticipantLeft extends VoiceRepositoryEvent {
  const CallParticipantLeft(this.userId);
  final String userId;
}

class CallMuteChanged extends VoiceRepositoryEvent {
  const CallMuteChanged({
    required this.userId,
    required this.isMuted,
    this.serverForced = false,
  });
  final String userId;
  final bool isMuted;
  final bool serverForced;
}

class CallDeafenChanged extends VoiceRepositoryEvent {
  const CallDeafenChanged({
    required this.userId,
    required this.isDeafened,
    this.serverForced = false,
  });
  final String userId;
  final bool isDeafened;
  final bool serverForced;
}

/// Voice-activity detection, driving the "who's talking" ring. Relay only -
/// high frequency, and never persisted server-side.
class CallSpeakingChanged extends VoiceRepositoryEvent {
  const CallSpeakingChanged({required this.userId, required this.isSpeaking});
  final String userId;
  final bool isSpeaking;
}

class CallCameraChanged extends VoiceRepositoryEvent {
  const CallCameraChanged({required this.userId, required this.isCameraOn});
  final String userId;
  final bool isCameraOn;
}

/// A camera or screen track appeared. [shareId] groups the two halves of one
/// screen share; it is null for a camera.
class CallTrackPublished extends VoiceRepositoryEvent {
  const CallTrackPublished({
    required this.userId,
    required this.mediaSessionId,
    required this.trackName,
    required this.kind,
    this.shareId,
  });
  final String userId;
  final String mediaSessionId;
  final String trackName;
  final String kind;
  final String? shareId;
}

class CallTrackClosed extends VoiceRepositoryEvent {
  const CallTrackClosed({
    required this.userId,
    required this.trackName,
    this.shareId,
  });
  final String userId;
  final String trackName;
  final String? shareId;
}

class CallScreenShareStarted extends VoiceRepositoryEvent {
  const CallScreenShareStarted({required this.userId, required this.shareId});
  final String userId;
  final String shareId;
}

class CallScreenShareStopped extends VoiceRepositoryEvent {
  const CallScreenShareStopped({required this.userId, required this.shareId});
  final String userId;
  final String shareId;
}

/// Who is currently watching one screen share.
class CallShareViewersChanged extends VoiceRepositoryEvent {
  const CallShareViewersChanged({
    required this.shareId,
    required this.viewerCount,
    required this.viewerIds,
  });
  final String shareId;
  final int viewerCount;
  final List<String> viewerIds;
}

/// A call in one of this user's conversations started, changed roster, or
/// ended - sent to *every member of the conversation*, whether or not they are
/// in the call.
///
/// This is what keeps a "join call in progress" affordance live for someone
/// the ring never addressed: a member who declined, who left, or who was never
/// invited. [status] is `Ongoing` or `Ended`.
class ConversationCallStateChanged extends VoiceRepositoryEvent {
  const ConversationCallStateChanged({
    required this.conversationId,
    required this.callId,
    required this.status,
    this.reason,
    this.participantIds = const [],
  });

  final String conversationId;
  final String callId;
  final String status;
  final String? reason;
  final List<String> participantIds;

  bool get hasEnded => status == 'Ended';
}

/// [reason] is the backend's `CallEndedReason` - one of `Declined`,
/// `UserEnded`, `AllParticipantsLeft`, `AloneTimeout` - used to pick UI copy.
class CallEndedRemotely extends VoiceRepositoryEvent {
  const CallEndedRemotely(this.callId, {this.reason});
  final String callId;
  final String? reason;
}

/// App-lifetime singleton (like `ConversationRepository`) - the single hub
/// connection's `call.*` events need to reach the incoming-call banner even
/// when no call screen is on-screen yet, so this can't be scoped to one call.
///
/// It also owns the version gate for whichever call this client is in. Every
/// `call.*` event carries `instanceId` and `version`; anything out of order is
/// dropped here and a gap triggers a snapshot refetch, so a cubit downstream
/// only ever sees events it can safely apply. See [VoiceRoomGate].
class VoiceRepository {
  VoiceRepository({required this.api, required RealtimeService realtimeService})
    : _realtimeService = realtimeService {
    _gate = VoiceRoomGate(
      fetchSnapshot: api.getSnapshot,
      onSnapshot: (snapshot) =>
          _eventsController.add(CallSnapshotReceived(snapshot)),
    );
    _realtimeSub = realtimeService.events
        .where(
          (e) =>
              e.name.startsWith('call.') ||
              // Conversation-scoped, not room-scoped: it reaches members who
              // are not in the call at all, which is the whole point of it.
              e.name == _conversationCallStateChanged,
        )
        .listen(_handleRealtimeEvent);
  }

  static const _conversationCallStateChanged = 'conversation.CallStateChanged';

  final VoiceApi api;
  final RealtimeService _realtimeService;
  late final StreamSubscription<RealtimeEvent> _realtimeSub;
  late final VoiceRoomGate _gate;

  final _eventsController = StreamController<VoiceRepositoryEvent>.broadcast();
  Stream<VoiceRepositoryEvent> get events => _eventsController.stream;

  /// Drives the cubit's reconcile-on-reconnect - a transition back to
  /// [RealtimeConnectionStatus.connected] is the signal that any `call.*`
  /// events broadcast during the gap were silently dropped.
  Stream<RealtimeConnectionStatus> get connectionStatus =>
      _realtimeService.connectionStatus;

  /// The instance/version this client currently holds, for the heartbeat.
  String? get knownInstanceId => _gate.instanceId;
  int get knownVersion => _gate.version;

  /// Starts version-tracking [callId]. Until a snapshot is adopted the first
  /// event forces a refetch, which is correct - there is no baseline to apply
  /// a delta to.
  void enterCall(String callId) => _gate.enterRoom(callId);

  /// Stops version-tracking the current call. The counterpart to [enterCall];
  /// named apart from [leaveCall] because that one hangs up server-side and
  /// this one only forgets local bookkeeping.
  void exitCall() => _gate.leaveRoom();

  void adoptSnapshot(VoiceRoomSnapshotDto snapshot) => _gate.adopt(snapshot);

  /// Fetches and adopts the authoritative state, emitting it as a
  /// [CallSnapshotReceived]. The recovery path for a reconnect gap.
  Future<void> refetchSnapshot() => _gate.refetch();

  Future<VoiceRoomSnapshotDto> getSnapshot(String callId) =>
      api.getSnapshot(callId);

  void _handleRealtimeEvent(RealtimeEvent event) {
    final payload = event.objectPayload;

    // Three exemptions, and each one is load-bearing.
    //
    // `IncomingCall` describes a call this client is not in yet, so it is not
    // versioned against anything - gating it would drop the event that makes
    // the phone ring. `Snapshot` and `Resync` are the recovery channel rather
    // than deltas on it: `Resync(roomGone)` in particular is deliberately sent
    // with a blank instance and version 0, which every branch of the gate
    // reads as "you are out of date" - so gating it would swallow the one
    // event that says the room no longer exists, and answer it with a refetch
    // of a room that is gone.
    const ungated = {'call.IncomingCall', 'call.Snapshot', 'call.Resync'};

    // Relays carry the current version without being a change to it - the
    // server neither stores them nor bumps the version for them. Letting one
    // advance the baseline would have it stand in for a state change that was
    // actually missed, and the next real event would look contiguous.
    const relays = {'call.SpeakingChanged', 'call.CameraChanged'};

    if (!ungated.contains(event.name) &&
        !_gate.admit(
          payload['callId'] as String?,
          payload,
          isRelay: relays.contains(event.name),
        )) {
      return;
    }

    switch (event.name) {
      case _conversationCallStateChanged:
        _eventsController.add(
          ConversationCallStateChanged(
            conversationId: payload['conversationId'] as String,
            callId: payload['callId'] as String,
            status: payload['status'] as String? ?? '',
            reason: payload['reason'] as String?,
            participantIds: (payload['participantIds'] as List? ?? const [])
                .cast<String>(),
          ),
        );
      case 'call.Snapshot':
        final snapshot = VoiceRoomSnapshotDto.fromJson(payload);
        _gate.adopt(snapshot);
        _eventsController.add(CallSnapshotReceived(snapshot));
      case 'call.Resync':
        final reason = payload['reason'] as String? ?? '';
        _eventsController.add(
          CallResyncRequested(
            reason: reason,
            userId: payload['userId'] as String?,
          ),
        );
        // Every reason but roomGone is answered by refetching; roomGone means
        // there is nothing to fetch and the cubit has to rejoin.
        if (reason != 'roomGone') unawaited(_gate.refetch());
      case 'call.IncomingCall':
        _eventsController.add(IncomingCallReceived(CallDto.fromJson(payload)));
      case 'call.ParticipantJoined':
        _eventsController.add(
          CallParticipantJoined(
            userId: payload['userId'] as String,
            mediaSessionId: payload['mediaSessionId'] as String,
            audioTrackName: payload['audioTrackName'] as String,
          ),
        );
      case 'call.ParticipantLeft':
        _eventsController.add(CallParticipantLeft(payload['userId'] as String));
      case 'call.MuteChanged':
        _eventsController.add(
          CallMuteChanged(
            userId: payload['userId'] as String,
            isMuted: payload['isMuted'] as bool,
            serverForced: payload['serverForced'] as bool? ?? false,
          ),
        );
      case 'call.DeafenChanged':
        _eventsController.add(
          CallDeafenChanged(
            userId: payload['userId'] as String,
            isDeafened: payload['isDeafened'] as bool,
            serverForced: payload['serverForced'] as bool? ?? false,
          ),
        );
      case 'call.SpeakingChanged':
        _eventsController.add(
          CallSpeakingChanged(
            userId: payload['userId'] as String,
            isSpeaking: payload['isSpeaking'] as bool? ?? false,
          ),
        );
      case 'call.CallEnded':
        _eventsController.add(
          CallEndedRemotely(
            payload['callId'] as String,
            reason: payload['reason'] as String?,
          ),
        );
      case 'call.CallAccepted':
        _eventsController.add(
          CallAcceptedElsewhere(payload['callId'] as String),
        );
      case 'call.CallDeviceDismissed':
        _eventsController.add(CallDeviceDismissed(payload['callId'] as String));
      case 'call.CallDeviceTakeover':
        _eventsController.add(CallDeviceTakeover(payload['callId'] as String));
      case 'call.CallParticipantLeft':
        _eventsController.add(
          CallLifecycleParticipantLeft(payload['userId'] as String),
        );
      case 'call.CallAlone':
        _eventsController.add(
          CallAlone(
            callId: payload['callId'] as String,
            deadline: parseApiDateTime(payload['deadline'] as String),
          ),
        );
      case 'call.CameraChanged':
        _eventsController.add(
          CallCameraChanged(
            userId: payload['userId'] as String,
            isCameraOn: payload['isCameraOn'] as bool,
          ),
        );
      case 'call.TrackPublished':
        _eventsController.add(
          CallTrackPublished(
            userId: payload['userId'] as String,
            mediaSessionId: payload['mediaSessionId'] as String,
            trackName: payload['trackName'] as String,
            kind: payload['kind'] as String,
            shareId: payload['shareId'] as String?,
          ),
        );
      case 'call.TrackClosed':
        _eventsController.add(
          CallTrackClosed(
            userId: payload['userId'] as String,
            trackName: payload['trackName'] as String,
            shareId: payload['shareId'] as String?,
          ),
        );
      case 'call.ScreenShareStarted':
        _eventsController.add(
          CallScreenShareStarted(
            userId: payload['userId'] as String,
            shareId: payload['shareId'] as String,
          ),
        );
      case 'call.ScreenShareStopped':
        _eventsController.add(
          CallScreenShareStopped(
            userId: payload['userId'] as String,
            shareId: payload['shareId'] as String,
          ),
        );
      case 'call.ShareViewersChanged':
        _eventsController.add(
          CallShareViewersChanged(
            shareId: payload['shareId'] as String,
            viewerCount: (payload['viewerCount'] as num?)?.toInt() ?? 0,
            viewerIds: (payload['viewerIds'] as List? ?? const [])
                .cast<String>(),
          ),
        );
    }
  }

  /// The `X-Device-Id` header these all depend on is applied inside [VoiceApi]
  /// itself rather than threaded through here - it has to be on the Cloudflare
  /// session/track endpoints too, which this repository never touches (they're
  /// driven from the WebRTC service). See the class comment on [VoiceApi].
  Future<CallDto> createCall({
    required String conversationId,
    required List<String> participantUserIds,
  }) => api.createCall(
    conversationId: conversationId,
    participantUserIds: participantUserIds,
  );

  Future<CallDto> acceptCall(String callId) => api.acceptCall(callId);

  Future<CallDto> declineCall(String callId) => api.declineCall(callId);

  /// Removes the local user from the call without ending it for anyone else
  /// still connected - see [VoiceApi.leaveCall].
  Future<CallDto> leaveCall(String callId) => api.leaveCall(callId);

  Future<CallDto> endCall(String callId) => api.endCall(callId);

  Future<CallDto> getCall(String callId) => api.getCall(callId);

  /// See [VoiceApi.getPendingCall] - the catch-up read for a ring this client
  /// was never told about.
  Future<CallDto?> getPendingCall() => api.getPendingCall();

  /// The call already happening in this conversation, or null. See
  /// [VoiceApi.getConversationCall].
  Future<OngoingCallDto?> getConversationCall(String conversationId) =>
      api.getConversationCall(conversationId);

  Future<void> watchShare(String callId, String shareId) =>
      api.watchShare(callId, shareId);

  Future<void> unwatchShare(String callId, String shareId) =>
      api.unwatchShare(callId, shareId);

  // ── Hub invocations ───────────────────────────────────────────────────────

  /// The state-asserting heartbeat. See [VoiceHeartbeat] for why this is a
  /// repair channel and not merely a keepalive.
  Future<void> invokeHeartbeat({
    required String callId,
    required VoiceHeartbeatState state,
  }) => _realtimeService.invoke(
    'voice.Heartbeat',
    args: [VoiceRoomKind.call, callId, state.toJson()],
  );

  Future<void> invokeMuteChanged({
    required String callId,
    required bool isMuted,
  }) => _realtimeService.invoke(
    'call.MuteChanged',
    args: [
      {'callId': callId, 'isMuted': isMuted},
    ],
  );

  Future<void> invokeCameraChanged({
    required String callId,
    required bool isCameraOn,
  }) => _realtimeService.invoke(
    'call.CameraChanged',
    args: [
      {'callId': callId, 'isCameraOn': isCameraOn},
    ],
  );

  Future<void> invokeSpeakingChanged({
    required String callId,
    required bool isSpeaking,
  }) => _realtimeService.invoke(
    'call.SpeakingChanged',
    args: [
      {'callId': callId, 'isSpeaking': isSpeaking},
    ],
  );

  /// Announces the share. The track name is not sent: the server derives both
  /// halves from the `shareId` and the naming convention, and a client-supplied
  /// name could disagree with what was actually published.
  Future<void> invokeScreenShareStarted({
    required String callId,
    required String shareId,
  }) => _realtimeService.invoke(
    'call.ScreenShareStarted',
    args: [
      {'callId': callId, 'shareId': shareId},
    ],
  );

  Future<void> invokeScreenShareStopped({
    required String callId,
    required String shareId,
  }) => _realtimeService.invoke(
    'call.ScreenShareStopped',
    args: [
      {'callId': callId, 'shareId': shareId},
    ],
  );

  void dispose() {
    _realtimeSub.cancel();
    _eventsController.close();
  }
}
