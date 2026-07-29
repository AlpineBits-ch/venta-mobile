import 'dart:math';

import '../storage/secure_storage_service.dart';

/// The stable per-installation device identifier required by the
/// multi-device calls/guild-voice contract (`X-Device-Id` header, `deviceId`
/// hub query param). venta_mobile has no MLS/E2EE yet (deferred — see
/// architecture plan), so there's no existing `ClientDeviceId` to reuse as
/// the spec suggests; this generates and persists its own, under a storage
/// key generic enough to become that same value once E2EE lands.
///
/// Generated once per install and cached in memory — [init] must be awaited
/// before [deviceId] is read (done once at app startup, alongside
/// `AuthRepository.init()`).
class DeviceIdService {
  DeviceIdService({required this.secureStorage});

  final SecureStorageService secureStorage;
  String? _deviceId;

  String get deviceId =>
      _deviceId ?? (throw StateError('DeviceIdService.init() must be awaited before use'));

  Future<void> init() async {
    if (_deviceId != null) return;
    final existing = await secureStorage.readDeviceId();
    if (existing != null) {
      _deviceId = existing;
      return;
    }
    final generated = _generate();
    await secureStorage.writeDeviceId(generated);
    _deviceId = generated;
  }

  String _generate() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
