import 'dart:async';
import 'dart:io';

import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/voice/bloc/call_cubit.dart';
import '../../features/voice/data/models/call_dto.dart';
import '../device/device_id_service.dart';
import '../storage/secure_storage_service.dart';
import 'ios_call_kit_bridge.dart';
import 'push_token_api.dart';

/// Marks a push as call-signaling - see `PushNotificationService`'s matching
/// constant and `docs/native-call-push-backend-spec.md`.
const _callPushType = 'call';

/// Called from `firebaseMessagingBackgroundHandler` (Android only - iOS call
/// pushes arrive via PushKit straight into native Swift, never through FCM)
/// when a data-only call push wakes the app. Must stay a static/top-level
/// function reachable from the background isolate.
///
/// `callSubtype: "end"` cancels a ring already shown on this device - sent
/// when the call was answered/declined/timed out on another device or by
/// the caller. Without this a phantom ring sits there indefinitely (Android
/// has no CallKit-style auto-timeout for a custom incoming-call UI). See
/// docs/native-call-push-backend-spec.md.
///
/// A cancel is never applied to a call this device is *in*. The server leaves
/// the accepting device out of the fan-out, but only when that device sent a
/// registered `X-Device-Id` on accept - and since the device-identity
/// consolidation the user's *other* devices are deliberately included, where
/// the whole user used to be skipped. That makes a stray cancel reaching the
/// answering device a live possibility (an unregistered id, a token still
/// unattached from before the migration), and acting on it hangs up a
/// connected call. The active call id is read from secure storage because
/// this runs in a background isolate with no access to [CallCubit].
Future<void> showCallKitFromPushData(Map<String, dynamic> data) async {
  if (data['type'] != _callPushType) return;
  // Android only. iOS drives its CallKit UI exclusively through `AppDelegate`'s
  // native CXProvider - via PushKit for backgrounded/killed calls and via
  // SignalR -> CallKitService for foreground ones. Routing an FCM call push
  // through the plugin here on iOS puts a *second*, competing CallKit call on
  // screen: its Accept goes to the plugin, whose iOS events nothing listens to
  // (see CallKitService.start - the plugin's onEvent is wired on Android only),
  // so the tap is silently dropped, while our own provider never learns of the
  // call and every answer/end on it fails with UnknownCallUUID. FCM call pushes
  // on iOS are redundant with PushKit regardless, so just ignore them.
  if (Platform.isIOS) return;
  final callId = data['callId'] as String;
  if (data['callSubtype'] == 'end') {
    if (await SecureStorageService().readActiveCallId() == callId) return;
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

/// Android only (see [CallKitService.start]) - must be a top-level function
/// for the same reason as [firebaseMessagingBackgroundHandler]: the plugin
/// relaunches a separate, throwaway background isolate to run it whenever an
/// accept/decline/timeout fires natively with no live [FlutterCallkitIncoming.onEvent]
/// listener attached (i.e. the app process was killed). That's the normal
/// resting state of a phone, and without this the tap is silently dropped -
/// the plugin's own event dispatch only reaches a listener or a registered
/// background handler, never both, and never queues for later.
///
/// This can't reach [CallCubit] or make the authenticated accept/decline API
/// call itself (no [getIt], no running app) - it only records which call was
/// acted on so [CallKitService.start] can finish the job once the real app
/// engine boots moments later via the plugin's own relaunch of `MainActivity`.
@pragma('vm:entry-point')
Future<void> callKitBackgroundMessageHandler(CallEvent event) async {
  final (callId, action) = switch (event) {
    CallEventActionCallAccept(:final callKitParams) => (
      callKitParams.id,
      'accept',
    ),
    CallEventActionCallDecline(:final callKitParams) => (
      callKitParams.id,
      'decline',
    ),
    CallEventActionCallTimeout(:final id) => (id, 'decline'),
    _ => (null, null),
  };
  if (callId == null || action == null) return;
  await SecureStorageService().writePendingCallAction(
    callId: callId,
    action: action,
  );
}

/// Bridges the native CallKit/Android-incoming-call UI to [CallCubit] - the
/// single source of truth for actual call state. This service never decides
/// call state itself; it only forwards native UI actions into the cubit and
/// mirrors the cubit's own transitions back out to the native UI, picking
/// whichever of [CallCubit]'s "normal" or "by id" methods applies depending
/// on whether this app instance already knows about the call
/// (foreground/live-socket path) or is hearing about it for the first time
/// via CallKit itself (cold start from a VoIP push).
///
/// iOS and Android take genuinely different native paths: iOS owns a
/// `CXProvider` directly in `AppDelegate.swift` (see [IosCallKitBridge] for
/// why - in short, going through a plugin that needs a live Flutter engine
/// was the root cause of a PushKit crash), Android still goes through
/// `flutter_callkit_incoming`.
class CallKitService {
  CallKitService({
    required this.callCubit,
    required this.authRepository,
    required this.profileRepository,
    required this.pushTokenApi,
    required this.secureStorage,
    required this.deviceIdService,
  });

  final CallCubit callCubit;
  final AuthRepository authRepository;
  final ProfileRepository profileRepository;
  final PushTokenApi pushTokenApi;
  final SecureStorageService secureStorage;
  final DeviceIdService deviceIdService;

  final IosCallKitBridge? _iosBridge = Platform.isIOS
      ? IosCallKitBridge()
      : null;
  StreamSubscription<CallEvent?>? _androidEventSub;
  StreamSubscription<IosCallKitEvent>? _iosEventSub;
  StreamSubscription<CallState>? _callCubitSub;
  String? _shownForCallId;
  String? _connectedForCallId;
  String? _registeredVoipToken;

  Future<void> start() async {
    _callCubitSub = callCubit.stream.listen(_handleCallCubitState);
    final iosBridge = _iosBridge;
    if (iosBridge != null) {
      _iosEventSub = iosBridge.events.listen(_handleIosEvent);
      await _registerVoipToken();
    } else {
      _androidEventSub = FlutterCallkitIncoming.onEvent.listen(
        _handleAndroidEvent,
      );
      // iOS's own CXProvider relays accept/decline/end natively regardless
      // of whether any Dart engine was already running (AppDelegate.swift
      // eagerly boots one if not) - only Android needs this background
      // hand-off registered/consumed. See callKitBackgroundMessageHandler.
      await FlutterCallkitIncoming.onBackgroundMessage(
        callKitBackgroundMessageHandler,
      );
      await _resumePendingCallAction();
    }
  }

  /// Finishes handling an accept/decline that [callKitBackgroundMessageHandler]
  /// caught while this engine wasn't running yet. Android only - see [start].
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
    final token = await _currentVoipToken();
    if (token == null || token.isEmpty) return;
    _registeredVoipToken = token;
    await pushTokenApi.registerToken(
      token: token,
      kind: PushTokenKind.apnsVoip,
      deviceId: deviceIdService.deviceIdOrNull,
    );
  }

  /// Deregisters this installation's VoIP token. Must run while the session is
  /// still valid (it's an authenticated call) - otherwise a signed-out handset
  /// keeps ringing for the account it left.
  Future<void> unregisterVoipToken() async {
    final token = _registeredVoipToken ?? await _currentVoipToken();
    if (token == null || token.isEmpty) return;
    _registeredVoipToken = null;
    await pushTokenApi.deleteToken(
      token: token,
      kind: PushTokenKind.apnsVoip,
    );
  }

  Future<String?> _currentVoipToken() async {
    final iosBridge = _iosBridge;
    return iosBridge != null
        ? await iosBridge.getVoipToken()
        : await FlutterCallkitIncoming.getDevicePushTokenVoIP();
  }

  /// Foreground/live-socket path: [CallCubit] already learned about the call
  /// over the websocket, so this is the one place that shows the native UI
  /// for it (the push-driven cold-start path shows it natively before any
  /// Dart code runs at all - see [showCallKitFromPushData] on Android, and
  /// the PushKit delegate in `AppDelegate.swift` on iOS).
  Future<void> _handleCallCubitState(CallState state) async {
    if (state.phase == CallPhase.incoming &&
        state.call != null &&
        _shownForCallId != state.call!.id) {
      _shownForCallId = state.call!.id;
      await _showForIncoming(state.call!);
    } else if (state.phase == CallPhase.active &&
        state.call != null &&
        _connectedForCallId != state.call!.id) {
      // Answering from this app's own in-call UI (as opposed to the native
      // CallKit banner/lock-screen button) never performs a `CXAnswerCallAction`
      // on iOS - nothing tells CallKit the call was picked up, so its session
      // stays "ringing" forever and iOS never grants the audio route, leaving
      // WebRTC signaling fully connected but silent in both directions (see
      // AppDelegate.swift's didActivate handoff for the other half of this).
      // setCallConnected there drives a real CXAnswerCallAction, which is
      // what actually triggers it. Harmless no-op if the native button
      // already answered it (both platforms).
      //
      // Deliberately NOT gated on `_shownForCallId == state.call!.id` - that's
      // only ever set by this Dart instance's own _showForIncoming, but most
      // real calls arrive while backgrounded/killed, where the native side
      // shows the incoming-call UI directly and this field never gets set
      // for that call at all. Gating on it here silently skipped the
      // fallback for the majority of real calls.
      _shownForCallId = state.call!.id;
      _connectedForCallId = state.call!.id;
      // Persisted, not just held in memory: the FCM background isolate that
      // handles a cancel push has no CallCubit to ask, and needs to know this
      // device is the one that answered. See showCallKitFromPushData.
      await secureStorage.writeActiveCallId(state.call!.id);
      final iosBridge = _iosBridge;
      if (iosBridge != null) {
        await iosBridge.setCallConnected(state.call!.id);
      } else {
        await FlutterCallkitIncoming.setCallConnected(state.call!.id);
      }
    } else if (state.phase == CallPhase.idle && _shownForCallId != null) {
      final id = _shownForCallId!;
      _shownForCallId = null;
      _connectedForCallId = null;
      await secureStorage.writeActiveCallId(null);
      final iosBridge = _iosBridge;
      if (iosBridge != null) {
        await iosBridge.endCall(id);
      } else {
        await FlutterCallkitIncoming.endCall(id);
      }
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
        // Fall through with no name/avatar - still worth ringing.
      }
    }
    final iosBridge = _iosBridge;
    if (iosBridge != null) {
      await iosBridge.reportIncomingCall(
        callId: call.id,
        callerName: callerName ?? 'Unknown',
      );
      return;
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

  void _handleIosEvent(IosCallKitEvent event) {
    switch (event) {
      case IosCallAccepted(:final callId):
        _accept(callId);
      case IosCallDeclined(:final callId):
        _decline(callId);
      case IosCallEndedNatively(:final callId):
        callCubit.endCallById(callId);
      case IosVoipTokenUpdated():
        _registerVoipToken();
    }
  }

  void _handleAndroidEvent(CallEvent? event) {
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
    await _androidEventSub?.cancel();
    await _iosEventSub?.cancel();
    await _iosBridge?.dispose();
    await _callCubitSub?.cancel();
  }
}
