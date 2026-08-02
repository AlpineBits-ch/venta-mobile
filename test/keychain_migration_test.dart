import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/storage/keychain_accessibility_migration.dart';
import 'package:venta_mobile/core/storage/secure_storage_service.dart';

/// What these cover: the root cause of the iOS white screen and the login that
/// failed after the server had already completed it.
///
/// `kSecAttrAccessible` goes into every query the darwin plugin builds
/// (`FlutterSecureStorage.baseQuery`), and it is **not** part of a
/// generic-password item's primary key. So changing the app's accessibility
/// class from the plugin default (`unlocked`) to `first_unlock_this_device`:
///
/// * made every previously-stored item invisible to a read - `errSecItemNotFound`,
///   which the plugin maps to `null`, indistinguishable from "never stored";
/// * made every write to one of those keys fail with `errSecDuplicateItem`
///   (-25299), because `containsKey` missed for the same reason and the plugin
///   therefore called `SecItemAdd` against a primary key that still existed.
///
/// Upgrade installs only. A fresh install has no legacy items, which is why a
/// clean device never reproduced it - and Android has no accessibility class at
/// all, which is why every Android run passed throughout.

class _MockStore extends Mock implements FlutterSecureStorage {}

PlatformException _duplicateItem() => PlatformException(
  code: 'Unexpected security result code',
  message: 'Code: -25299, Message: The item already exists.',
  details: -25299,
);

void main() {
  late _MockStore current;
  late _MockStore legacy;
  late MigratingSecureStore store;

  setUp(() {
    current = _MockStore();
    legacy = _MockStore();
    store = MigratingSecureStore(current: current, legacy: legacy);

    when(() => current.read(key: any(named: 'key'))).thenAnswer((_) async => null);
    when(() => legacy.read(key: any(named: 'key'))).thenAnswer((_) async => null);
    when(
      () => current.write(key: any(named: 'key'), value: any(named: 'value')),
    ).thenAnswer((_) async {});
    when(() => current.delete(key: any(named: 'key'))).thenAnswer((_) async {});
    when(() => legacy.delete(key: any(named: 'key'))).thenAnswer((_) async {});
  });

  group('reads find items stranded under the old accessibility class', () {
    test('a value only the legacy class can see is still returned', () async {
      // The silent half of the bug. This read returned null on every upgraded
      // handset, so the app concluded it had no session and no device id.
      when(() => legacy.read(key: 'venta.auth.refresh_token'))
          .thenAnswer((_) async => 'the-real-refresh-token');

      final value = await store.read(key: 'venta.auth.refresh_token');

      expect(value, 'the-real-refresh-token');
    });

    test('the item is migrated to the current class, once', () async {
      var legacyValue = 'stranded';
      when(() => legacy.read(key: 'k')).thenAnswer((_) async => legacyValue);
      when(() => legacy.delete(key: 'k')).thenAnswer((_) async {
        legacyValue = '';
      });

      await store.read(key: 'k');

      verify(() => legacy.delete(key: 'k')).called(1);
      verify(() => current.write(key: 'k', value: 'stranded')).called(1);
    });

    test('the current class wins and the legacy one is never consulted',
        () async {
      when(() => current.read(key: 'k')).thenAnswer((_) async => 'fresh');

      expect(await store.read(key: 'k'), 'fresh');

      verifyNever(() => legacy.read(key: any(named: 'key')));
    });

    test('genuinely absent is still absent', () async {
      expect(await store.read(key: 'k'), isNull);
      verifyNever(
        () => current.write(key: any(named: 'key'), value: any(named: 'value')),
      );
    });

    test('a throwing legacy read degrades to absent', () async {
      when(() => legacy.read(key: 'k')).thenThrow(_duplicateItem());

      expect(await store.read(key: 'k'), isNull);
    });
  });

  group('writes recover from the duplicate the old item causes', () {
    test('a -25299 clears the legacy item and retries once', () async {
      // The loud half of the bug, and the one that produced both the blank
      // launch and "Something went wrong": `containsKey` misses, the plugin
      // calls `SecItemAdd`, and the primary key is taken.
      var attempts = 0;
      when(
        () => current.write(key: 'k', value: 'v'),
      ).thenAnswer((_) async {
        attempts++;
        if (attempts == 1) throw _duplicateItem();
      });

      await store.write(key: 'k', value: 'v');

      expect(attempts, 2);
      verify(() => legacy.delete(key: 'k')).called(1);
    });

    test('an ordinary write touches the legacy store not at all', () async {
      await store.write(key: 'k', value: 'v');

      verify(() => current.write(key: 'k', value: 'v')).called(1);
      verifyNever(() => legacy.delete(key: any(named: 'key')));
    });

    test('a second failure is the caller\'s problem, not a retry loop',
        () async {
      when(
        () => current.write(key: any(named: 'key'), value: any(named: 'value')),
      ).thenThrow(_duplicateItem());

      await expectLater(
        store.write(key: 'k', value: 'v'),
        throwsA(isA<PlatformException>()),
      );
      verify(
        () => current.write(key: any(named: 'key'), value: any(named: 'value')),
      ).called(2);
    });
  });

  group('deletes clear both classes', () {
    test('so a cleared value cannot reappear on the next read', () async {
      // Without this, signing out would leave the legacy copy behind and the
      // very next read would migrate it straight back in.
      await store.delete(key: 'venta.auth.refresh_token');

      verify(() => current.delete(key: 'venta.auth.refresh_token')).called(1);
      verify(() => legacy.delete(key: 'venta.auth.refresh_token')).called(1);
    });
  });

  group('SecureStorageService wires the migration in', () {
    test('an upgraded install finds its session again', () async {
      final currentStore = _MockStore();
      final legacyStore = _MockStore();
      when(() => currentStore.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);
      when(() => currentStore.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          )).thenAnswer((_) async {});
      when(() => legacyStore.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});
      when(() => legacyStore.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);
      when(() => legacyStore.read(key: 'venta.auth.refresh_token'))
          .thenAnswer((_) async => 'legacy-refresh');
      when(() => legacyStore.read(key: 'venta.device.id'))
          .thenAnswer((_) async => 'a9418a4b7efd50a31d5aed562273ff16');

      final service = SecureStorageService(
        storage: currentStore,
        legacyStorage: legacyStore,
      );

      expect(await service.readRefreshToken(), 'legacy-refresh');
      expect(
        await service.readDeviceId(),
        'a9418a4b7efd50a31d5aed562273ff16',
        reason: 'the device id the server has on file, rather than a fresh one '
            'it has never seen',
      );
    });
  });
}
