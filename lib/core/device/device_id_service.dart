import 'dart:convert';
import 'dart:math';

import '../storage/secure_storage_service.dart';

/// What this installation calls itself everywhere the server records a device:
/// the device registration, the `device_name` sent at the token endpoint, and
/// therefore the sessions list.
///
/// Without it the server falls back to the request's `User-Agent`, which for
/// `dart:io`'s HttpClient is the literal `Dart/<version> (dart:io)` - which is
/// exactly what the sessions screen used to show for this app.
const kDeviceName = 'Venta Mobile';

/// `Desktop` | `Mobile` | `Web`, matching the server's `DeviceType` enum.
const kDeviceType = 'Mobile';

/// The stable per-installation device identifier required by the
/// multi-device calls/guild-voice contract (`X-Device-Id` header, `deviceId`
/// hub query param) and by device registration (`ClientDeviceId`).
/// venta_mobile has no MLS/E2EE yet (deferred - see architecture plan), so
/// there's no existing `ClientDeviceId` to reuse as the spec suggests; this
/// generates and persists its own, under a storage key generic enough to
/// become that same value once E2EE lands.
///
/// Generated once per install and cached in memory - [init] must be awaited
/// before [deviceId] is read (done once at app startup, alongside
/// `AuthRepository.init()`). Deliberately survives sign-out: the id names the
/// installation, not the account, and re-generating it on every login would
/// leave the server holding a device row nothing will ever claim again.
class DeviceIdService {
  DeviceIdService({required this.secureStorage});

  final SecureStorageService secureStorage;
  String? _deviceId;
  String? _identityPublicKey;

  String get deviceId =>
      _deviceId ??
      (throw StateError('DeviceIdService.init() must be awaited before use'));

  /// Same value as [deviceId], but null instead of throwing when [init] hasn't
  /// run yet. For callers that legitimately run before startup completes (the
  /// token endpoint, the request interceptor) and should simply send nothing
  /// rather than fail.
  String? get deviceIdOrNull => _deviceId;

  /// Base64 of this installation's device identity public key, which device
  /// registration requires (`identityPublicKey`, a non-null column server-side).
  ///
  /// It is a placeholder: with no MLS on mobile there is no real identity
  /// keypair to publish, so this is 32 persisted random bytes - stable, unique
  /// per installation, and never used to verify anything. When E2EE lands this
  /// must become the actual MLS identity key, which means deleting the device
  /// registration (`DeviceRegistrationService.forgetThisDevice`) and
  /// re-registering: the server returns the existing row unchanged for an id
  /// it already knows.
  String get identityPublicKey =>
      _identityPublicKey ??
      (throw StateError('DeviceIdService.init() must be awaited before use'));

  Future<void> init() async {
    _deviceId ??= await _loadOrCreate(
      read: secureStorage.readDeviceId,
      write: secureStorage.writeDeviceId,
      create: () => _randomBytes(16).map(_hex).join(),
    );
    _identityPublicKey ??= await _loadOrCreate(
      read: secureStorage.readDeviceIdentityKey,
      write: secureStorage.writeDeviceIdentityKey,
      create: () => base64Encode(_randomBytes(32)),
    );
  }

  Future<String> _loadOrCreate({
    required Future<String?> Function() read,
    required Future<void> Function(String) write,
    required String Function() create,
  }) async {
    final existing = await read();
    if (existing != null && existing.isNotEmpty) return existing;
    final generated = create();
    await write(generated);
    return generated;
  }

  List<int> _randomBytes(int count) {
    final random = Random.secure();
    return List<int>.generate(count, (_) => random.nextInt(256));
  }

  String _hex(int b) => b.toRadixString(16).padLeft(2, '0');
}
