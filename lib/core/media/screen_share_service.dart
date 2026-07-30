import 'package:flutter/services.dart';

/// Bridges to the small native Android foreground service
/// (`ScreenCaptureService`) that must already be running before
/// `getDisplayMedia` starts `MediaProjection` capture - Android 10+ requires
/// an active foreground service (Android 14 strictly enforces
/// `foregroundServiceType="mediaProjection"`), and flutter_webrtc doesn't
/// start one itself. iOS has no screenshare support yet (deferred - needs a
/// ReplayKit Broadcast Upload Extension), so this is Android-only; callers
/// are expected not to invoke it on iOS.
class ScreenShareService {
  static const _channel = MethodChannel('venta/screen_share');

  Future<void> start() => _channel.invokeMethod('start');
  Future<void> stop() => _channel.invokeMethod('stop');
}
