import 'dart:async';
import 'dart:io';

import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/voice/bloc/call_cubit.dart';
import '../../features/voice/data/models/call_dto.dart';
import '../storage/secure_storage_service.dart';
import 'push_token_api.dart';

/// Marks a push as call-signaling — see `PushNotificationService`'s matching
/// constant and `docs/native-call-push-backend-spec.md`.
const _callPushType = 'call';

/// Called from `firebaseMessagingBackgroundHandler` (Android only — iOS call
/// pushes arrive via PushKit straight into native Swift, never through FCM)
/// when a data-only call push wakes the app. Must stay a static/top-level
/// function reachable from the background isolate.
///
/// `callSubtype: "end"` cancels a ring already shown on this device — sent
/// when the call was answered/declined/timed out on another device or by
/// the caller. Without this a phantom ring sits there indefinitely (Android
/// has no CallKit-style auto-timeout for a custom incoming-call UI). See
/// docs/native-call-push-backend-spec.md.
Future<void> showCallKitFromPushData(Map<String, dynamic> data) async {
  if (data['type'] != _callPushType) return;
  final callId = data['callId'] as String;
  if (data['callSubtype'] == 'end') {
    await FlutterCallkitIncoming.endCall(callId);
    return;
  }
  await FlutterCallkitIncoming.showCallkitIncoming(
    CallKitParams(
      id: callId,
      nameCaller: data['callerName'] as String? ?? 'Unknown',
      avatar: data['callerAvatarUrl'] as String?,
      type: 0,
      extra: {'conversationId': data['conversationId'] as String? ?? ''},
      android: const AndroidParams(isCustomNotification: true),
    ),
  );
}

/// Android only (see [CallKitService.start]) — must be a top-level function
/// for the same reason as [firebaseMessagingBackgroundHandler]: the plugin
/// relaunches a separate, throwaway background isolate to run it whenever an
/// accept/decline/timeout fires natively with no live [FlutterCallkitIncoming.onEvent]
/// listener attached (i.e. the app process was killed). That's the normal
/// resting state of a phone, and without this the tap is silently dropped —
/// the plugin's own event dispatch only reaches a listener or a registered
/// background handler, never both, and never queues for later.
///
/// This can't reach [CallCubit] or make the authenticated accept/decline API
/// call itself (no [getIt], no running app) — it only records which call was
/// acted on so [CallKitService.start] can finish the job once the real app
/// engine boots moments later via the plugin's own relaunch of `MainActivity`.
@pragma('vm:entry-point')
Future<void> callKitBackgroundMessageHandler(CallEvent event) async {
  final (callId, action) = switch (event) {
    CallEventActionCallAccept(:final callKitParams) => (callKitParams.id, 'accept'),
    CallEventActionCallDecline(:final callKitParams) => (callKitParams.id, 'decline'),
    CallEventActionCallTimeout(:final id) => (id, 'decline'),
    _ => (null, null),
  };
  if (callId == null || action == null) return;
  await SecureStorageService().writePendingCallAction(callId: callId, action: action);
}

/// Bridges the native CallKit/Android-incoming-call UI (`flutter_callkit_incoming`)
/// to [CallCubit] — the single source of truth for actual call state. This
/// service never decides call state itself; it only forwards native UI
/// actions into the cubit and mirrors the cubit's own transitions back out
/// to the native UI, picking whichever of [CallCubit]'s "normal" or "by id"
/// methods applies depending on whether this app instance already knows
/// about the call (foreground/live-socket path) or is hearing about it for
/// the first time via CallKit itself (cold start from a VoIP push).
class CallKitService {
  CallKitService({
    required this.callCubit,
    required this.authRepository,
    required this.profileRepository,
    required this.pushTokenApi,
    required this.secureStorage,
  });

  final CallCubit callCubit;
  final AuthRepository authRepository;
  final ProfileRepository profileRepository;
  final PushTokenApi pushTokenApi;
  final SecureStorageService secureStorage;

  StreamSubscription<CallEvent?>? _eventSub;
  StreamSubscription<CallState>? _callCubitSub;
  String? _shownForCallId;
  String? _connectedForCallId;

  Future<void> start() async {
    _eventSub = FlutterCallkitIncoming.onEvent.listen(_handleEvent);
    _callCubitSub = callCubit.stream.listen(_handleCallCubitState);
    if (Platform.isIOS) {
      await _registerVoipToken();
    } else {
      // iOS's PushKit contract forces the Dart engine to boot (and this
      // listener to attach) before the system CallKit UI can even be shown
      // — see AppDelegate.swift — so only Android needs the background
      // hand-off registered/consumed. See callKitBackgroundMessageHandler.
      await FlutterCallkitIncoming.onBackgroundMessage(callKitBackgroundMessageHandler);
      await _resumePendingCallAction();
    }
  }

  /// Finishes handling an accept/decline that [callKitBackgroundMessageHandler]
  /// caught while this engine wasn't running yet.
  Future<void> _resumePendingCallAction() async {
    final pending = await secureStorage.readPendingCallAction();
    if (pending == null) return;
    await secureStorage.clearPendingCallAction();
    final (callId, action) = pending;
    if (action == 'accept') {
      _accept(callId);
    } else {
      _decline(callId);
    }
  }

  Future<void> _registerVoipToken() async {
    final token = await FlutterCallkitIncoming.getDevicePushTokenVoIP();
    if (token == null || token.isEmpty) return;
    await pushTokenApi.registerVoipToken(token);
  }

  /// Foreground/live-socket path: [CallCubit] already learned about the call
  /// over the websocket, so this is the one place that shows the native UI
  /// for it (the push-driven cold-start path shows it natively before any
  /// Dart code runs at all — see [showCallKitFromPushData] and the iOS
  /// PushKit delegate in `AppDelegate.swift`).
  Future<void> _handleCallCubitState(CallState state) async {
    if (state.phase == CallPhase.incoming && state.call != null && _shownForCallId != state.call!.id) {
      _shownForCallId = state.call!.id;
      await _showForIncoming(state.call!);
    } else if (state.phase == CallPhase.active &&
        state.call != null &&
        _shownForCallId == state.call!.id &&
        _connectedForCallId != state.call!.id) {
      // Answering from this app's own in-call UI (as opposed to the native
      // CallKit banner/lock-screen button) never performs a `CXAnswerCallAction`
      // — nothing tells CallKit the call was picked up, so its session stays
      // "ringing" forever and iOS never grants the audio route, leaving
      // WebRTC signaling fully connected but silent in both directions (see
      // AppDelegate.swift's didActivateAudioSession for the other half of
      // this). setCallConnected drives a real CXAnswerCallAction through
      // CallManager.connectedCall, which is what actually triggers
      // provider(_:didActivate:). Harmless no-op if the native button
      // already answered it.
      _connectedForCallId = state.call!.id;
      await FlutterCallkitIncoming.setCallConnected(state.call!.id);
    } else if (state.phase == CallPhase.idle && _shownForCallId != null) {
      final id = _shownForCallId!;
      _shownForCallId = null;
      _connectedForCallId = null;
      await FlutterCallkitIncoming.endCall(id);
    }
  }

  Future<void> _showForIncoming(CallDto call) async {
    final myUserId = authRepository.currentUserId;
    final callerUserId = call.participants
        .map((p) => p.userId)
        .firstWhere((id) => id != myUserId, orElse: () => '');
    String? callerName;
    String? callerAvatarUrl;
    if (callerUserId.isNotEmpty) {
      try {
        final profile = await profileRepository.getByUserId(callerUserId);
        callerName = profile.userName;
        callerAvatarUrl = profile.avatarUrl;
      } catch (_) {
        // Fall through with no name/avatar — still worth ringing.
      }
    }
    await FlutterCallkitIncoming.showCallkitIncoming(
      CallKitParams(
        id: call.id,
        nameCaller: callerName ?? 'Unknown',
        avatar: callerAvatarUrl,
        type: 0,
        extra: {'conversationId': call.conversationId},
      ),
    );
  }

  void _handleEvent(CallEvent? event) {
    switch (event) {
      case CallEventActionCallAccept(:final callKitParams):
        _accept(callKitParams.id);
      case CallEventActionCallDecline(:final callKitParams):
        _decline(callKitParams.id);
      case CallEventActionCallEnded(:final callKitParams):
        callCubit.endCallById(callKitParams.id);
      case CallEventActionCallTimeout(:final id):
        _decline(id);
      case CallEventActionDidUpdateDevicePushTokenVoip():
        _registerVoipToken();
      default:
        break;
    }
  }

  void _accept(String callId) {
    final state = callCubit.state;
    if (state.phase == CallPhase.incoming && state.call?.id == callId) {
      callCubit.acceptIncomingCall();
    } else {
      callCubit.acceptIncomingCallById(callId);
    }
  }

  void _decline(String callId) {
    final state = callCubit.state;
    if (state.phase == CallPhase.incoming && state.call?.id == callId) {
      callCubit.declineIncomingCall();
    } else {
      callCubit.declineIncomingCallById(callId);
    }
  }

  Future<void> dispose() async {
    await _eventSub?.cancel();
    await _callCubitSub?.cancel();
  }
}
