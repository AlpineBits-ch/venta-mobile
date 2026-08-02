import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mls/venta_mls.dart';
import 'package:venta_mobile/core/crypto/account_identity_service.dart';
import 'package:venta_mobile/core/crypto/master_key_api.dart';
import 'package:venta_mobile/core/crypto/master_key_service.dart';
import 'package:venta_mobile/core/storage/secure_storage_service.dart';

/// What these cover: `AccountIdentityService.ensure`, contract §H.2 and §I.2.
///
/// This is the function that had no production caller, so nothing had ever
/// exercised its decision table against a real server. The decisions matter more
/// than they look:
///
/// * **Minting a second identity key is the worst outcome available here.** Every
///   peer TOFU-pins the first one they see, and a competing key looks exactly
///   like the safety-number change §H.5 exists to warn about - except nobody
///   attacked anything. So every branch that cannot be sure the account has no
///   key refuses to mint.
/// * **Issuing a certificate under a key the account does not publish is the
///   second worst.** It verifies against nothing, and an *invalid* certificate is
///   a security warning at every enforcement phase (§I.1) - unlike a missing one,
///   which `Observe` and `Warn` tolerate by design.

class _MockApi extends Mock implements MasterKeyApi {}

class _MockMasterKeys extends Mock implements MasterKeyService {}

class _MockStorage extends Mock implements SecureStorageService {}

class _MockEngine extends Mock implements VentaMls {}

const _userId = 'user_1';
const _deviceId = 'device_1';
const _masterKey = 'bWFzdGVyLWtleS0zMi1ieXRlcy1sb25nLWs=';
const _ourPublic = 'b3VyLWlkZW50aXR5LXB1YmxpYw==';
const _ourPrivate = 'b3VyLWlkZW50aXR5LXByaXZhdGU=';

void main() {
  late _MockApi api;
  late _MockMasterKeys masterKeys;
  late _MockStorage storage;
  late _MockEngine engine;
  late AccountIdentityService service;

  /// Whatever `writeAccountIdentity` last stored, so "did it cache a key it
  /// could not publish" is answerable.
  (String, String)? stored;

  setUp(() {
    api = _MockApi();
    masterKeys = _MockMasterKeys();
    storage = _MockStorage();
    engine = _MockEngine();
    stored = null;

    service = AccountIdentityService(
      api: api,
      masterKeys: masterKeys,
      secureStorage: storage,
      engine: engine,
    );

    when(
      () => storage.readAccountIdentity(
        deviceId: any(named: 'deviceId'),
        userId: any(named: 'userId'),
      ),
    ).thenAnswer((_) async => stored);
    when(
      () => storage.writeAccountIdentity(
        deviceId: any(named: 'deviceId'),
        userId: any(named: 'userId'),
        publicKey: any(named: 'publicKey'),
        privateKey: any(named: 'privateKey'),
      ),
    ).thenAnswer((i) async {
      stored = (
        i.namedArguments[#publicKey] as String,
        i.namedArguments[#privateKey] as String,
      );
    });
    when(
      () => masterKeys.peek(
        userId: any(named: 'userId'),
        deviceId: any(named: 'deviceId'),
      ),
    ).thenAnswer((_) async => _masterKey);
    when(() => engine.generateAccountIdentity()).thenAnswer(
      (_) async => MlsAccountIdentity(
        publicKey: _ourPublic,
        privateKey: _ourPrivate,
      ),
    );
    when(
      () => api.uploadIdentityKey(
        identityPublicKey: any(named: 'identityPublicKey'),
        password: any(named: 'password'),
        version: any(named: 'version'),
        deviceId: any(named: 'deviceId'),
        continuitySignature: any(named: 'continuitySignature'),
      ),
    ).thenAnswer((_) async {});
    when(() => api.fetchIdentityKey(any())).thenAnswer((_) async => null);
  });

  Future<bool> ensure({String? password}) => service.ensure(
    userId: _userId,
    deviceId: _deviceId,
    password: password,
  );

  group('a fresh account', () {
    test('mints, publishes and caches an identity key', () async {
      expect(await ensure(password: 'hunter2'), isTrue);

      expect(service.isAvailable, isTrue);
      expect(service.publicKey, _ourPublic);
      expect(service.version, 1);
      verify(
        () => api.uploadIdentityKey(
          identityPublicKey: _ourPublic,
          password: 'hunter2',
          version: 1,
          deviceId: _deviceId,
        ),
      ).called(1);
      expect(stored, (_ourPublic, _ourPrivate));
    });

    test('a failed publish leaves nothing cached', () async {
      // Ordering, deliberately: publish first, cache second. A key in the
      // keychain that the account does not publish is a state the mismatch
      // branch has to clean up after, and not creating it is cheaper.
      when(
        () => api.uploadIdentityKey(
          identityPublicKey: any(named: 'identityPublicKey'),
          password: any(named: 'password'),
          version: any(named: 'version'),
          deviceId: any(named: 'deviceId'),
          continuitySignature: any(named: 'continuitySignature'),
        ),
      ).thenThrow(DioException(requestOptions: RequestOptions(path: '/')));

      await expectLater(ensure(password: 'hunter2'), throwsA(isA<DioException>()));
      expect(stored, isNull);
      expect(service.isAvailable, isFalse);
    });
  });

  group('nothing mints a second identity key', () {
    test('not when the account already publishes one', () async {
      when(() => api.fetchIdentityKey(any())).thenAnswer(
        (_) async => const PublishedIdentityKey(
          publicKey: 'c29tZWJvZHktZWxzZXM=',
          version: 2,
        ),
      );

      expect(await ensure(password: 'hunter2'), isFalse);

      expect(service.isAvailable, isFalse);
      expect(service.publicKey, 'c29tZWJvZHktZWxzZXM=');
      verifyNever(() => engine.generateAccountIdentity());
    });

    test('not when the lookup failed', () async {
      // Fail closed on the *generation* decision. Minting because a GET timed
      // out is a self-inflicted safety-number change on an account that was
      // perfectly healthy.
      when(() => api.fetchIdentityKey(any()))
          .thenThrow(DioException(requestOptions: RequestOptions(path: '/')));

      expect(await ensure(password: 'hunter2'), isFalse);
      verifyNever(() => engine.generateAccountIdentity());
    });

    test('not when there is no password to publish it with', () async {
      // §I.2 says the key appears "when an upgraded client next unlocks". On this
      // platform that has to mean a *credentialed* unlock: the server gates
      // publication on the account password. Minting one we cannot publish would
      // leave this device holding a key no peer has pinned, racing whichever
      // device publishes first.
      expect(await ensure(), isFalse);

      verifyNever(() => engine.generateAccountIdentity());
      expect(stored, isNull);
    });

    test('not when the master key is not unlocked here', () async {
      when(
        () => masterKeys.peek(
          userId: any(named: 'userId'),
          deviceId: any(named: 'deviceId'),
        ),
      ).thenAnswer((_) async => null);

      expect(await ensure(password: 'hunter2'), isFalse);
      verifyNever(() => engine.generateAccountIdentity());
    });

    test('a second ensure adopts the cached key rather than minting again', () async {
      await ensure(password: 'hunter2');
      // The account now publishes what this device holds.
      when(() => api.fetchIdentityKey(any())).thenAnswer(
        (_) async => const PublishedIdentityKey(publicKey: _ourPublic, version: 1),
      );

      expect(await ensure(password: 'hunter2'), isTrue);

      verify(() => engine.generateAccountIdentity()).called(1);
      verify(
        () => api.uploadIdentityKey(
          identityPublicKey: any(named: 'identityPublicKey'),
          password: any(named: 'password'),
          version: any(named: 'version'),
          deviceId: any(named: 'deviceId'),
        ),
      ).called(1);
    });
  });

  group('a cached key that the account does not publish', () {
    setUp(() {
      stored = (_ourPublic, _ourPrivate);
    });

    test('is refused rather than used to sign certificates', () async {
      when(() => api.fetchIdentityKey(any())).thenAnswer(
        (_) async => const PublishedIdentityKey(
          publicKey: 'YW5vdGhlci1kZXZpY2VzLWtleQ==',
          version: 4,
        ),
      );

      expect(await ensure(password: 'hunter2'), isFalse);

      expect(
        service.isAvailable,
        isFalse,
        reason: 'certificates signed by this key would not verify against what '
            'peers pin, and an invalid certificate is a security warning at '
            'every phase - strictly worse than no certificate at all',
      );
      expect(service.publicKey, 'YW5vdGhlci1kZXZpY2VzLWtleQ==');
      expect(service.version, 4);
      expect(await service.issueForThisDevice(
        userId: _userId,
        deviceId: _deviceId,
        deviceSignatureKey: 'a2V5',
      ), isNull);
    });

    test('is published when the account has none and a password is available', () async {
      expect(await ensure(password: 'hunter2'), isTrue);

      expect(service.isAvailable, isTrue);
      verify(
        () => api.uploadIdentityKey(
          identityPublicKey: _ourPublic,
          password: 'hunter2',
          version: 1,
          deviceId: _deviceId,
        ),
      ).called(1);
    });

    test('is still usable on a cold start with no password', () async {
      // The ordinary launch. Nothing can be published, but this device holds the
      // private half, so it can still issue and refresh its own certificate -
      // which is what keeps coverage from decaying between sign-ins.
      expect(await ensure(), isTrue);

      expect(service.isAvailable, isTrue);
      verifyNever(
        () => api.uploadIdentityKey(
          identityPublicKey: any(named: 'identityPublicKey'),
          password: any(named: 'password'),
          version: any(named: 'version'),
          deviceId: any(named: 'deviceId'),
        ),
      );
    });

    test('an unreachable server does not invalidate a cached key', () async {
      when(() => api.fetchIdentityKey(any()))
          .thenThrow(DioException(requestOptions: RequestOptions(path: '/')));

      expect(await ensure(password: 'hunter2'), isTrue);
      expect(
        service.isAvailable,
        isTrue,
        reason: 'offline is not evidence that the account rotated',
      );
    });

    test('a failed publish does not fail the ensure', () async {
      when(
        () => api.uploadIdentityKey(
          identityPublicKey: any(named: 'identityPublicKey'),
          password: any(named: 'password'),
          version: any(named: 'version'),
          deviceId: any(named: 'deviceId'),
          continuitySignature: any(named: 'continuitySignature'),
        ),
      ).thenThrow(DioException(requestOptions: RequestOptions(path: '/')));

      expect(await ensure(password: 'hunter2'), isTrue);
      expect(service.isAvailable, isTrue);
    });
  });

  group('issuing for this device', () {
    test('signs over the leaf\'s own signature key and this device\'s id', () async {
      when(
        () => engine.issueDeviceCertificate(
          accountIdentityPrivateKeyB64: any(named: 'accountIdentityPrivateKeyB64'),
          userId: any(named: 'userId'),
          deviceId: any(named: 'deviceId'),
          deviceSignatureKeyB64: any(named: 'deviceSignatureKeyB64'),
          issuedAt: any(named: 'issuedAt'),
          expiresAt: any(named: 'expiresAt'),
        ),
      ).thenAnswer((_) async => 'c2lnbmF0dXJl');

      await ensure(password: 'hunter2');
      final certificate = await service.issueForThisDevice(
        userId: _userId,
        deviceId: _deviceId,
        deviceSignatureKey: 'bGVhZi1zaWduYXR1cmUta2V5',
      );

      expect(certificate, isNotNull);
      expect(certificate!.deviceId, _deviceId);
      expect(certificate.deviceSignatureKey, 'bGVhZi1zaWduYXR1cmUta2V5');
      // §L.2: the payload includes the user id, because `ClientDeviceId` is
      // unique only per user - a certificate naming only the device would be a
      // valid certificate for every account that happened to have one by that id.
      verify(
        () => engine.issueDeviceCertificate(
          accountIdentityPrivateKeyB64: _ourPrivate,
          userId: _userId,
          deviceId: _deviceId,
          deviceSignatureKeyB64: 'bGVhZi1zaWduYXR1cmUta2V5',
          issuedAt: any(named: 'issuedAt'),
          expiresAt: any(named: 'expiresAt'),
        ),
      ).called(1);

      expect(
        certificate.expiresAt.difference(certificate.issuedAt),
        AccountIdentityService.certificateLifetime,
      );
      expect(certificate.isExpired, isFalse);
    });
  });
}
