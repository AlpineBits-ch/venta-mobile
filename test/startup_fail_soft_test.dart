import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/config/app_config.dart';
import 'package:venta_mobile/core/device/device_id_service.dart';
import 'package:venta_mobile/core/startup/app_bootstrap.dart';
import 'package:venta_mobile/core/storage/secure_storage_service.dart';
import 'package:venta_mobile/features/auth/data/auth_api.dart';
import 'package:venta_mobile/features/auth/data/auth_repository.dart';

/// What these cover: the launch path reaching `runApp` no matter what fails.
///
/// The failure this exists for is a **white screen with no diagnostic**. `main`
/// used to be eight bare `await`s with `runApp` nested inside the last of them,
/// so any one throwing left the Flutter engine attached with no root widget:
/// no error text, no stack, nothing to distinguish a refused keychain from a
/// dead network from a crashed plugin. It presented on iOS and not on Android,
/// which is exactly what you would expect - half those calls are platform calls
/// whose iOS behaviour has no Android equivalent - and the structure guaranteed
/// the difference would surface as a blank screen rather than as a message.
///
/// Every test here is "the thing that would have blanked the app now degrades
/// the feature instead".

class _MockSecureStorage extends Mock implements SecureStorageService {}

class _MockAuthApi extends Mock implements AuthApi {}

class _MockDeviceIds extends Mock implements DeviceIdService {}

/// The shape `flutter_secure_storage` throws on iOS when the keychain refuses -
/// a wrong access group, an item under a different accessibility class, or a
/// read before first unlock after a reboot.
PlatformException _keychainRefused() => PlatformException(
  code: 'Unexpected security result code',
  message: 'Code: -34018, Message: A required entitlement is not present.',
);

void main() {
  group('AppBootstrap', () {
    test('a failing step is recorded, not thrown', () async {
      final bootstrap = AppBootstrap();

      final ok = await bootstrap.step(
        'boom',
        () async => throw StateError('no'),
      );

      expect(ok, isFalse);
      expect(bootstrap.isClean, isFalse);
      expect(bootstrap.failures.single.step, 'boom');
      expect(bootstrap.summary, contains('boom'));
    });

    test('every step failing still leaves a usable report', () async {
      // The whole point: the caller runs to completion and calls `runApp`.
      final bootstrap = AppBootstrap();

      for (final name in ['a', 'b', 'c']) {
        await bootstrap.step(name, () async => throw Exception(name));
      }

      expect(bootstrap.failures, hasLength(3));
      expect(bootstrap.summary.split('\n'), hasLength(3));
    });

    test('catches Errors, not just Exceptions', () async {
      // A `MissingPluginException`, a `StateError` from an unregistered
      // dependency and an assertion failure are not one type, and none of them
      // may reach the caller.
      final bootstrap = AppBootstrap();

      await bootstrap.step('platform', () async => throw _keychainRefused());
      await bootstrap.step(
        'state',
        () async => throw StateError('unregistered'),
      );
      await bootstrap.step('assert', () async => throw AssertionError('nope'));

      expect(bootstrap.failures, hasLength(3));
    });

    test('a clean run reports clean and calls nothing back', () async {
      final reported = <StartupFailure>[];
      final bootstrap = AppBootstrap(onFailure: reported.add);

      final ok = await bootstrap.step('fine', () async {});

      expect(ok, isTrue);
      expect(bootstrap.isClean, isTrue);
      expect(reported, isEmpty);
      expect(bootstrap.summary, 'startup clean');
    });

    test('failures are reported as they happen', () async {
      // So a crash reporter that did come up still learns about the steps that
      // did not, rather than everything being lost with the launch.
      final reported = <StartupFailure>[];
      final bootstrap = AppBootstrap(onFailure: reported.add);

      await bootstrap.step('one', () async => throw Exception('1'));

      expect(reported.single.step, 'one');
    });
  });

  group('InMemoryHydratedStorage', () {
    // `HydratedBloc.storage` is a `late` static read during the first frame by
    // `ThemeCubit`'s construction and by `RoutePersistence`. Leaving it
    // unassigned after a disk failure turns that failure into a widget-tree
    // failure a beat after `runApp` succeeded - the same blank screen, one frame
    // later.
    test(
      'reads back what it wrote and never throws on a missing key',
      () async {
        final storage = InMemoryHydratedStorage();

        expect(storage.read('absent'), isNull);
        await storage.write('theme', 'dark');
        expect(storage.read('theme'), 'dark');
        await storage.delete('theme');
        expect(storage.read('theme'), isNull);
        await storage.clear();
        await storage.close();
      },
    );

    test('satisfies the Storage contract HydratedBloc reads', () {
      // Assigning it is the fallback `main` installs; if the interface ever
      // drifts, this is where it is noticed rather than at launch on a device.
      HydratedBloc.storage = InMemoryHydratedStorage();
      expect(HydratedBloc.storage.read('anything'), isNull);
    });
  });

  group('DeviceIdService survives a refused keychain', () {
    late _MockSecureStorage storage;
    late DeviceIdService service;

    setUp(() {
      storage = _MockSecureStorage();
      service = DeviceIdService(secureStorage: storage);
    });

    test(
      'a read that throws yields an ephemeral id rather than killing launch',
      () async {
        when(() => storage.readDeviceId()).thenThrow(_keychainRefused());
        when(
          () => storage.readDeviceIdentityKey(),
        ).thenThrow(_keychainRefused());

        await service.init();

        expect(service.deviceIdOrNull, isNotNull);
        expect(service.deviceIdOrNull, isNotEmpty);
        expect(service.identityPublicKey, isNotEmpty);
        expect(service.isEphemeral, isTrue);
      },
    );

    test('a failed read never writes over what may still be there', () async {
      // A read that failed is no evidence that nothing is stored. Writing on
      // that assumption turns a transient keychain fault into a permanent
      // identity change - this id names the installation's MLS leaf, and a new
      // one means every group it is in stops addressing it.
      when(() => storage.readDeviceId()).thenThrow(_keychainRefused());
      when(() => storage.readDeviceIdentityKey()).thenThrow(_keychainRefused());

      await service.init();

      verifyNever(() => storage.writeDeviceId(any()));
      verifyNever(() => storage.writeDeviceIdentityKey(any()));
    });

    test('a refused write still yields a usable id for this process', () async {
      when(() => storage.readDeviceId()).thenAnswer((_) async => null);
      when(() => storage.readDeviceIdentityKey()).thenAnswer((_) async => null);
      when(() => storage.writeDeviceId(any())).thenThrow(_keychainRefused());
      when(
        () => storage.writeDeviceIdentityKey(any()),
      ).thenThrow(_keychainRefused());

      await service.init();

      expect(service.deviceIdOrNull, isNotEmpty);
      expect(service.isEphemeral, isTrue);
    });

    test('the ordinary path is unchanged and not ephemeral', () async {
      when(() => storage.readDeviceId()).thenAnswer((_) async => 'stored-id');
      when(
        () => storage.readDeviceIdentityKey(),
      ).thenAnswer((_) async => 'stored-key');

      await service.init();

      expect(service.deviceIdOrNull, 'stored-id');
      expect(service.identityPublicKey, 'stored-key');
      expect(service.isEphemeral, isFalse);
      verifyNever(() => storage.writeDeviceId(any()));
    });
  });

  group('AuthRepository.init never throws', () {
    late _MockSecureStorage storage;
    late _MockAuthApi api;
    late AuthRepository repository;

    setUp(() {
      storage = _MockSecureStorage();
      api = _MockAuthApi();
      final deviceIds = _MockDeviceIds();
      when(() => deviceIds.deviceIdOrNull).thenReturn('device-1');
      repository = AuthRepository(
        api: api,
        secureStorage: storage,
        deviceIdService: deviceIds,
      );

      when(() => storage.readServerUrl()).thenAnswer((_) async => null);
      when(() => storage.readRefreshToken()).thenAnswer((_) async => null);
      when(() => storage.readAccessToken()).thenAnswer((_) async => null);
      when(() => storage.clearSession()).thenAnswer((_) async {});
    });

    test('a refused server-url read falls back to the default', () async {
      when(() => storage.readServerUrl()).thenThrow(_keychainRefused());

      await repository.init();

      expect(repository.baseUrl, AppConfig.defaultApiUrl);
      expect(repository.isAuthenticated, isFalse);
    });

    test('a refused session read leaves the launch unauthenticated', () async {
      when(() => storage.readRefreshToken()).thenThrow(_keychainRefused());

      await repository.init();

      expect(repository.isAuthenticated, isFalse);
    });

    test('a refused session read clears nothing', () async {
      // "Could not read" and "signed out" are different facts. Acting on the
      // second when only the first is true costs the user their login over a
      // transient fault.
      when(() => storage.readRefreshToken()).thenThrow(_keychainRefused());

      await repository.init();

      verifyNever(() => storage.clearSession());
    });

    // The one that maps directly onto the reported symptom: the refresh fails
    // because of something the server did, the handler calls `logout`, and
    // `logout` writes to the same keychain that is refusing. Unguarded, that
    // turned a refused token refresh into a dead app.
    test('a failed refresh whose logout also fails still returns', () async {
      when(() => storage.readRefreshToken()).thenAnswer((_) async => 'refresh');
      when(() => storage.readAccessToken()).thenAnswer((_) async => 'access');
      when(
        () => api.refreshGrant(
          baseUrl: any(named: 'baseUrl'),
          refreshToken: any(named: 'refreshToken'),
        ),
      ).thenThrow(Exception('the server rejected the refresh'));
      when(() => storage.clearSession()).thenThrow(_keychainRefused());

      await expectLater(repository.init(), completes);
      expect(repository.isAuthenticated, isFalse);
    });

    test('a refused access-token read still attempts the refresh', () async {
      when(() => storage.readRefreshToken()).thenAnswer((_) async => 'refresh');
      when(() => storage.readAccessToken()).thenThrow(_keychainRefused());
      when(
        () => api.refreshGrant(
          baseUrl: any(named: 'baseUrl'),
          refreshToken: any(named: 'refreshToken'),
        ),
      ).thenThrow(Exception('offline'));

      await expectLater(repository.init(), completes);
      verify(
        () => api.refreshGrant(
          baseUrl: any(named: 'baseUrl'),
          refreshToken: 'refresh',
        ),
      ).called(1);
    });
  });

  group('the last-resort error surface', () {
    testWidgets('names the failure instead of rendering nothing', (
      tester,
    ) async {
      // The release default for a build failure is a bare grey rectangle with no
      // text, which is indistinguishable from the blank screen. This is what
      // makes the next one self-reporting.
      await tester.pumpWidget(
        const StartupErrorSurface(
          title: 'Something broke',
          detail: 'PlatformException(-34018, entitlement missing)',
        ),
      );

      expect(find.text('Something broke'), findsOneWidget);
      expect(find.textContaining('-34018'), findsOneWidget);
    });

    testWidgets('renders with no MaterialApp, Directionality or theme above it', (
      tester,
    ) async {
      // It has to draw in exactly the situation where those are what failed, so
      // it may not depend on any of them.
      await tester.pumpWidget(
        const StartupErrorSurface(title: 't', detail: 'd'),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('d'), findsOneWidget);
    });
  });
}
