import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mls/venta_mls.dart';
import 'package:venta_mobile/core/device/device_api.dart';
import 'package:venta_mobile/core/device/device_id_service.dart';
import 'package:venta_mobile/core/mls/mls_service.dart';
import 'package:venta_mobile/core/mls/mls_session_manager.dart';
import 'package:venta_mobile/core/mls/mls_sync_service.dart';
import 'package:venta_mobile/core/storage/secure_storage_service.dart';
import 'package:venta_mobile/features/auth/data/auth_repository.dart';
import 'package:venta_mobile/features/mls/data/models/mls_dtos.dart';

/// What these cover: key package supply, which fails silently and asymmetrically.
///
/// Every group this device is added to consumes one single-use package. Run out
/// and the server has nothing to hand callers, so this device is quietly left
/// out of new conversations - readable by everyone except the person holding it.
/// The last-resort package is the floor that prevents that, and it is reusable
/// precisely because it is the fallback.
///
/// The server decides the count, not the client: it is the one that knows what
/// has been consumed, expired or swept.

class _MockMls extends Mock implements MlsService {}

class _MockDeviceApi extends Mock implements DeviceApi {}

class _MockDeviceId extends Mock implements DeviceIdService {}

class _MockSync extends Mock implements MlsSyncService {}

class _MockAuth extends Mock implements AuthRepository {}

class _MockStorage extends Mock implements SecureStorageService {}

const _device = 'device-a';

KeyPackageResult _package(String id) =>
    KeyPackageResult(keyPackage: 'kp-$id', initPrivateKey: 'init-$id');

void main() {
  late _MockMls mls;
  late _MockDeviceApi deviceApi;
  late _MockDeviceId deviceIds;
  late MlsSessionManager manager;

  setUpAll(() {
    registerFallbackValue(const <KeyPackageUpload>[]);
  });

  setUp(() {
    mls = _MockMls();
    deviceApi = _MockDeviceApi();
    deviceIds = _MockDeviceId();
    manager = MlsSessionManager(
      mls: mls,
      sync_: _MockSync(),
      deviceApi: deviceApi,
      deviceIdService: deviceIds,
      authRepository: _MockAuth(),
      secureStorage: _MockStorage(),
    );

    when(() => deviceIds.deviceIdOrNull).thenReturn(_device);
    when(() => mls.isUnlocked).thenReturn(true);
    when(
      () => deviceApi.uploadKeyPackages(
        clientDeviceId: any(named: 'clientDeviceId'),
        keyPackages: any(named: 'keyPackages'),
      ),
    ).thenAnswer((_) async => 0);
  });

  test('uploads exactly the count the server asked for', () async {
    when(() => deviceApi.keyPackagesToGenerate(_device)).thenAnswer(
      (_) async => const GenerateKeyPackagesDto(count: 40),
    );
    when(() => mls.generateKeyPackages(40))
        .thenAnswer((_) async => [for (var i = 0; i < 40; i++) _package('$i')]);

    await manager.replenishKeyPackages();

    final captured = verify(
      () => deviceApi.uploadKeyPackages(
        clientDeviceId: _device,
        keyPackages: captureAny(named: 'keyPackages'),
      ),
    ).captured.single as List<KeyPackageUpload>;

    expect(captured, hasLength(40));
    expect(captured.every((p) => !p.isLastResort), isTrue);
  });

  test('adds a last-resort package when the server holds none', () async {
    when(() => deviceApi.keyPackagesToGenerate(_device)).thenAnswer(
      (_) async =>
          const GenerateKeyPackagesDto(count: 2, needsLastResort: true),
    );
    when(() => mls.generateKeyPackages(2))
        .thenAnswer((_) async => [_package('a'), _package('b')]);
    when(() => mls.generateKeyPackages(1))
        .thenAnswer((_) async => [_package('lr')]);

    await manager.replenishKeyPackages();

    final captured = verify(
      () => deviceApi.uploadKeyPackages(
        clientDeviceId: _device,
        keyPackages: captureAny(named: 'keyPackages'),
      ),
    ).captured.single as List<KeyPackageUpload>;

    expect(captured, hasLength(3));
    expect(
      captured.where((p) => p.isLastResort).map((p) => p.keyPackage),
      ['kp-lr'],
      reason: 'exactly one package may be marked reusable',
    );
  });

  test('a fully stocked device uploads nothing at all', () async {
    when(() => deviceApi.keyPackagesToGenerate(_device))
        .thenAnswer((_) async => const GenerateKeyPackagesDto());

    await manager.replenishKeyPackages();

    verifyNever(
      () => deviceApi.uploadKeyPackages(
        clientDeviceId: any(named: 'clientDeviceId'),
        keyPackages: any(named: 'keyPackages'),
      ),
    );
    verifyNever(() => mls.generateKeyPackages(any()));
  });

  test('does nothing while the MLS session is locked', () async {
    when(() => mls.isUnlocked).thenReturn(false);

    await manager.replenishKeyPackages();

    verifyNever(() => deviceApi.keyPackagesToGenerate(any()));
  });

  group('resume trigger', () {
    test('checks once, then holds off until the interval elapses', () async {
      when(() => deviceApi.keyPackagesToGenerate(_device))
          .thenAnswer((_) async => const GenerateKeyPackagesDto());

      await manager.replenishIfStale();
      await manager.replenishIfStale();
      await manager.replenishIfStale();

      verify(() => deviceApi.keyPackagesToGenerate(_device)).called(1);
    });

    test('a failed check still holds off rather than retrying every resume', () async {
      when(() => deviceApi.keyPackagesToGenerate(_device))
          .thenThrow(Exception('offline'));

      // Must not throw - this runs detached from any UI.
      await manager.replenishIfStale();
      await manager.replenishIfStale();

      verify(() => deviceApi.keyPackagesToGenerate(_device)).called(1);
    });
  });
}
