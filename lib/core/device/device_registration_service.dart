import 'package:flutter/foundation.dart';

import '../mls/mls_service.dart';
import 'device_api.dart';
import 'device_id_service.dart';

/// Keeps this installation registered as a device on the signed-in account.
///
/// Registration is per account, so this has to run once per session rather
/// than once per install: the same `ClientDeviceId` registered by user A means
/// nothing to user B, and B's calls would be rejected with the `400` that
/// [DeviceIdInterceptor] recovers from. [reset] is what makes the next session
/// register again.
class DeviceRegistrationService {
  DeviceRegistrationService({
    required this.api,
    required this.deviceIdService,
    required this.mls,
  });

  final DeviceApi api;
  final DeviceIdService deviceIdService;
  final MlsService mls;

  bool _registered = false;
  Future<void>? _inFlight;

  /// True once this session has registered successfully. Read by the sessions
  /// screen to decide whether "Forget this device" can do anything.
  bool get isRegistered => _registered;

  /// Registers unless this session already has. Cheap enough to call on every
  /// authenticated start-up; the server treats a repeat as a no-op anyway.
  Future<void> ensureRegistered() {
    if (_registered) return Future<void>.value();
    return register();
  }

  /// Concurrent callers share one in-flight request - start-up and the
  /// interceptor's `400` recovery can easily land at the same moment, and two
  /// simultaneous registrations of the same id race each other server-side.
  ///
  /// Failures are swallowed and logged, not thrown: nothing the app does is
  /// worth blocking on this, and leaving [_registered] false means the next
  /// call tries again.
  Future<void> register() {
    final inFlight = _inFlight;
    if (inFlight != null) return inFlight;
    final future = _register();
    _inFlight = future;
    return future.whenComplete(() => _inFlight = null);
  }

  Future<void> _register() async {
    final deviceId = deviceIdService.deviceIdOrNull;
    if (deviceId == null) return;
    try {
      await api.register(
        clientDeviceId: deviceId,
        deviceName: kDeviceName,
        deviceType: kDeviceType,
        identityPublicKey: deviceIdService.identityPublicKey,
      );
      _registered = true;
    } catch (e) {
      debugPrint('DeviceRegistrationService: registration failed: $e');
    }
  }

  /// Unregisters this installation - the "sign out and forget this device"
  /// half of the sessions screen. The caller is expected to sign out straight
  /// afterwards: the server revokes this device's login sessions, so staying
  /// on the current tokens would just be a session waiting to fail its next
  /// refresh.
  Future<void> forgetThisDevice() async {
    final deviceId = deviceIdService.deviceIdOrNull;
    if (deviceId == null) return;
    await api.remove(deviceId);
    // The server has just cascaded away this device's key packages and its
    // right to be handed Welcomes. Keeping the matching MLS identity and group
    // state here would leave a device that believes it is in groups nobody will
    // ever address again, and every encrypted send would fail at the epoch
    // check. This makes the encrypted history on this handset unreadable, which
    // is what "forget this device" means.
    await mls.forgetEverything();
    _registered = false;
  }

  /// Call on sign-out and on sign-in - the next account has to register this
  /// device for itself.
  void reset() => _registered = false;
}
