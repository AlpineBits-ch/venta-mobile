import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mls/venta_mls.dart';
import 'package:venta_mobile/core/device/device_id_service.dart';
import 'package:venta_mobile/core/mls/mls_service.dart';
import 'package:venta_mobile/core/mls/mls_store.dart';
import 'package:venta_mobile/core/storage/secure_storage_service.dart';

/// What these cover: two failures that are confidentiality bugs rather than
/// corruption ones, and one that quietly destroys a device's ability to talk to
/// anyone.
///
/// * **Account isolation.** `MlsStore.stateDirectory` cached its directory
///   ignoring the user id, so a push notification for account B - which resolves
///   its own store - was handed account A's directory. Account B would then read
///   account A's group registry and its decrypted message history, and the
///   engine underneath would read A's private keys.
/// * **Silent identity re-mint.** A keychain miss on a device that holds groups
///   is not a first run; it is lost keys. Minting a fresh Ed25519 pair over live
///   group state leaves the device holding leaves it can neither sign for nor
///   decrypt, while `isUnlocked` reads true and the composer offers to send.
///   Every message it sends is refused and none it receives can be read, and
///   nothing says so.

class _MockEngine extends Mock implements VentaMls {}

class _MockSecureStorage extends Mock implements SecureStorageService {}

class _MockDeviceId extends Mock implements DeviceIdService {}

void main() {
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('venta_mls_store_test');
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  MlsStore storeIn(Directory dir) => MlsStore(directory: () async => dir);

  group('MlsStore account scoping', () {
    test('resolves a different directory per account', () async {
      final store = storeIn(root);

      final a = await store.stateDirectory('user_a');
      final b = await store.stateDirectory('user_b');

      expect(
        a.path,
        isNot(b.path),
        reason: 'the cache used to ignore the user id entirely, so a push for '
            'account B read account A\'s state directory',
      );
      expect(a.path, contains('user_a'));
      expect(b.path, contains('user_b'));
    });

    test('re-initialising for another account does not serve the first\'s state', () async {
      final store = storeIn(root);

      await store.init('user_a');
      await store.registerGroup(
        contextId: 'conv_1',
        generation: 1,
        mlsGroupId: 'Z3JvdXBB',
      );
      store.cacheMessage('msg_1', base64Encode(utf8.encode('a secret')));
      await store.flush();

      // The FCM background isolate initialises whichever account a notification
      // names. `init` used to return early on `_ready`, handing it the loaded
      // account's registry and plaintext cache.
      await store.init('user_b');

      expect(store.groupId('conv_1', 1), isNull);
      expect(store.cachedMessage('msg_1'), isNull);
      expect(store.loadedUserId, 'user_b');

      // And account A's own state is intact, not wiped - switching back has to
      // find its history.
      await store.init('user_a');
      expect(store.groupId('conv_1', 1), 'Z3JvdXBB');
      expect(store.cachedMessage('msg_1'), isNotNull);

      store.dispose();
    });

    test('counts groups but not the active-generation pointers', () async {
      final store = storeIn(root);
      await store.init('user_a');

      expect(store.groupCount, 0);
      await store.registerGroup(
        contextId: 'conv_1',
        generation: 1,
        mlsGroupId: 'Z3JvdXBB',
      );
      await store.registerGroup(
        contextId: 'conv_2',
        generation: 3,
        mlsGroupId: 'Z3JvdXBC',
      );

      // Two groups, plus two `#active` pointers that share the map and are
      // bookkeeping rather than membership.
      expect(store.groupCount, 2);
      store.dispose();
    });
  });

  group('identity re-mint guard', () {
    late _MockEngine engine;
    late _MockSecureStorage storage;
    late _MockDeviceId deviceIds;
    late MlsStore store;
    late MlsService mls;

    setUp(() async {
      engine = _MockEngine();
      storage = _MockSecureStorage();
      deviceIds = _MockDeviceId();
      store = storeIn(root);
      mls = MlsService(
        store: store,
        secureStorage: storage,
        deviceIdService: deviceIds,
        engine: engine,
      );

      when(() => deviceIds.deviceId).thenReturn('device-a');
      when(() => engine.initStorage(any())).thenAnswer((_) async => true);
      when(() => engine.clearStorage()).thenAnswer((_) async {});
      when(
        () => storage.readMlsIdentity(
          deviceId: any(named: 'deviceId'),
          userId: any(named: 'userId'),
        ),
      ).thenAnswer((_) async => null);
      when(
        () => storage.writeMlsIdentity(
          deviceId: any(named: 'deviceId'),
          userId: any(named: 'userId'),
          publicKey: any(named: 'publicKey'),
          privateKey: any(named: 'privateKey'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => engine.generateKeyPackages(
          identity: any(named: 'identity'),
          count: any(named: 'count'),
        ),
      ).thenAnswer(
        (_) async => const MlsKeyPackageBatch(
          signingPublicKey: 'pub',
          signingPrivateKey: 'priv',
          keyPackages: [],
          keyHandle: 'handle',
        ),
      );
    });

    tearDown(() => store.dispose());

    test('refuses to mint over restored groups', () async {
      await mls.init('user_a');
      await store.registerGroup(
        contextId: 'conv_1',
        generation: 1,
        mlsGroupId: 'Z3JvdXBB',
      );

      // The keychain has nothing. On a device with no groups that is a first
      // run; on this one it is lost keys.
      expect(await mls.unlock(), isFalse);
      expect(mls.identityStatus.value, MlsIdentityStatus.keysMissing);

      await expectLater(
        mls.createIdentity(),
        throwsA(isA<MlsIdentityConflictException>()),
      );
      verifyNever(
        () => engine.generateKeyPackages(
          identity: any(named: 'identity'),
          count: any(named: 'count'),
        ),
      );
      expect(
        mls.isUnlocked,
        isFalse,
        reason: 'the composer must not be offered while the keys are gone',
      );
    });

    test('mints freely on a genuine first run', () async {
      await mls.init('user_a');

      expect(await mls.unlock(), isFalse);
      expect(mls.identityStatus.value, MlsIdentityStatus.needsSetup);

      await mls.createIdentity();

      expect(mls.isUnlocked, isTrue);
      expect(mls.identityStatus.value, MlsIdentityStatus.unlocked);
    });

    test('mints no key packages at identity creation', () async {
      // The ten this used to mint were never uploaded and never freed. They sat
      // in the engine's store, which is re-serialized in full on every send,
      // receive and commit - so they made every later operation slower forever
      // in exchange for nothing. Replenish mints exactly what the server asks
      // for, moments later, and that is the only batch anyone can consume.
      await mls.init('user_a');
      await mls.createIdentity();

      verify(
        () => engine.generateKeyPackages(identity: 'user_a', count: 0),
      ).called(1);
    });

    test('recovery is explicit, and wipes before it mints', () async {
      await mls.init('user_a');
      await store.registerGroup(
        contextId: 'conv_1',
        generation: 1,
        mlsGroupId: 'Z3JvdXBB',
      );
      await mls.unlock();

      // The user-initiated "re-link this device" path. Every encrypted message
      // this account holds on this handset becomes unreadable, which is why it
      // is not a fallback inside `createIdentity`.
      await mls.recoverWithFreshIdentity();

      verify(() => engine.clearStorage()).called(1);
      expect(store.groupCount, 0);
      expect(mls.isUnlocked, isTrue);
    });
  });
}
