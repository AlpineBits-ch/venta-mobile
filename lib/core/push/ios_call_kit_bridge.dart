import 'dart:async';

import 'package:flutter/services.dart';

/// Mirrors just the event shapes [CallKitService] needs from the native
/// CXProvider owned directly by `AppDelegate.swift` - see that file for why
/// iOS stopped going through `flutter_callkit_incoming` (still used as-is
/// on Android).
sealed class IosCallKitEvent {
  const IosCallKitEvent();
}

class IosCallAccepted extends IosCallKitEvent {
  const IosCallAccepted(this.callId);
  final String callId;
}

class IosCallDeclined extends IosCallKitEvent {
  const IosCallDeclined(this.callId);
  final String callId;
}

class IosCallEndedNatively extends IosCallKitEvent {
  const IosCallEndedNatively(this.callId);
  final String callId;
}

class IosVoipTokenUpdated extends IosCallKitEvent {
  const IosVoipTokenUpdated(this.token);
  final String token;
}

/// A VoIP push put a call on screen before any Dart code was running. Carries
/// what the push knew about the caller so [CallKitService] can fill in what it
/// didn't - see [IosCallKitBridge.updateCall].
class IosCallReported extends IosCallKitEvent {
  const IosCallReported({
    required this.callId,
    required this.callerId,
    required this.callerName,
  });

  final String callId;

  /// Empty when the push predates the backend sending it.
  final String callerId;

  /// Empty when the push carried no name - the case the native side shows a
  /// placeholder for, and the one worth correcting.
  final String callerName;
}

/// Thin wrapper around the `gg.venta.mobile/callkit` [MethodChannel] that
/// `AppDelegate.swift` sets up on whichever Flutter engine ends up live
/// (the normal UIScene-driven one, or its own lazily-booted fallback for a
/// backgrounded decline/end - see `ensureEngineForActionRelay` there).
///
/// Native buffers every event rather than pushing it the instant a channel
/// exists, since that could still race Dart's [setMethodCallHandler] call
/// below - [_drainPendingEvents] here (called once up front, and again on
/// every "wake" ping) is what actually guarantees delivery.
class IosCallKitBridge {
  IosCallKitBridge() {
    _channel.setMethodCallHandler(_handleMethodCall);
    unawaited(_drainPendingEvents());
  }

  static const _channel = MethodChannel('gg.venta.mobile/callkit');

  final _eventsController = StreamController<IosCallKitEvent>.broadcast();
  Stream<IosCallKitEvent> get events => _eventsController.stream;

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'wake') {
      await _drainPendingEvents();
    }
  }

  Future<void> _drainPendingEvents() async {
    final raw = await _channel.invokeMethod<List<Object?>>(
      'drainPendingEvents',
    );
    for (final entry in raw ?? const []) {
      final event = _toEvent((entry as Map).cast<String, dynamic>());
      if (event != null) _eventsController.add(event);
    }
  }

  IosCallKitEvent? _toEvent(Map<String, dynamic> args) {
    final callId = args['callId'] as String?;
    return switch (args['type']) {
      'accept' when callId != null => IosCallAccepted(callId),
      'decline' when callId != null => IosCallDeclined(callId),
      'end' when callId != null => IosCallEndedNatively(callId),
      'voipTokenUpdated' when args['token'] is String => IosVoipTokenUpdated(
        args['token'] as String,
      ),
      'reported' when callId != null => IosCallReported(
        callId: callId,
        callerId: args['callerId'] as String? ?? '',
        callerName: args['callerName'] as String? ?? '',
      ),
      _ => null,
    };
  }

  Future<String?> getVoipToken() =>
      _channel.invokeMethod<String>('getVoipToken');

  /// Mirrors this installation's `X-Device-Id` into native, which needs it to
  /// recognise its own "stop ringing" push (see `AppDelegate.localDeviceId`)
  /// while no Flutter engine is running. Persisted natively, so it only has to
  /// be sent once per launch.
  Future<void> setDeviceId(String deviceId) =>
      _channel.invokeMethod<void>('setDeviceId', deviceId);

  /// Foreground/live-socket path - mirrors the old `showCallkitIncoming`
  /// call for a call [CallKitService] already learned about over SignalR.
  Future<bool> reportIncomingCall({
    required String callId,
    required String callerName,
  }) async {
    final ok = await _channel.invokeMethod<bool>('reportIncomingCall', {
      'callId': callId,
      'callerName': callerName,
    });
    return ok ?? false;
  }

  /// Re-labels a ring already on screen. The native side reports the call from
  /// the push payload alone - it has no network access and no session - so this
  /// is how a name resolved afterwards (or one the push never carried) reaches
  /// the CallKit UI. No-op for a call CallKit no longer knows about.
  Future<void> updateCall({
    required String callId,
    required String callerName,
  }) => _channel.invokeMethod<void>('updateCall', {
    'callId': callId,
    'callerName': callerName,
  });

  Future<void> setCallConnected(String callId) =>
      _channel.invokeMethod<void>('setCallConnected', {'callId': callId});

  Future<void> endCall(String callId) =>
      _channel.invokeMethod<void>('endCall', {'callId': callId});

  Future<void> dispose() => _eventsController.close();
}
