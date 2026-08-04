import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/crypto/account_encryption_service.dart';
import 'package:venta_mobile/core/crypto/account_identity_service.dart';
import 'package:venta_mobile/core/crypto/master_key_service.dart';
import 'package:venta_mobile/core/device/device_api.dart';
import 'package:venta_mobile/core/device/device_id_service.dart';
import 'package:venta_mobile/core/mls/mls_policy_service.dart';
import 'package:venta_mobile/core/mls/mls_service.dart';
import 'package:venta_mobile/core/network/api_client.dart';
import 'package:venta_mobile/core/storage/secure_storage_service.dart';
import 'package:venta_mobile/features/auth/data/auth_repository.dart';

/// What these cover: contract §I.2 and §I.4 - the *generation* side of §G/§H,
/// and the reason it had to be wired before anything else could be.
///
/// `MasterKeyService`, `AccountIdentityService` and the certificate path were
/// all built and unit-tested with **zero production callers**. So no real
/// account ever acquired a master key, no account identity key was ever
/// published, and no device certificate was ever issued - which pins certificate
/// coverage at exactly 0%, which is what `certificateEnforcement` has to climb
/// past before it can leave `Observe`, which is what §H.4's external-commit
/// defence waits on. The whole chain was blocked on nobody calling `ensure`.
///
/// The constraint that shapes every test here: **existing clients must not be
/// degraded.** Every account in the field has no master key, no identity key and
/// no certificate. A bootstrap that failed loudly, blocked a launch, or removed
/// anything would meet the entire install base on the launch after an update.

class _MockMasterKeys extends Mock implements MasterKeyService {}

class _MockIdentity extends Mock implements AccountIdentityService {}

class _MockMls extends Mock implements MlsService {}

class _MockDeviceApi extends Mock implements DeviceApi {}

class _MockDeviceIds extends Mock implements DeviceIdService {}

class _MockAuth extends Mock implements AuthRepository {}

class _MockStorage extends Mock implements SecureStorageService {}

/// Never reached: the point of the enforcement assertion is that establishing
/// credentials does not consult, and cannot move, the phase.
class _MockApiClient extends Mock implements ApiClient {}

const _userId = 'user_1';
const _deviceId = 'device_1';
const _signatureKey = 'c2lnbmF0dXJlLXB1YmxpYy1rZXktYnl0ZXMtMzI=';
const _masterKey = 'bWFzdGVyLWtleS0zMi1ieXRlcy1sb25nLWs=';

DeviceCertificate _certificate({
  String deviceId = _deviceId,
  String signatureKey = _signatureKey,
  Duration remaining = const Duration(days: 180),
}) {
  final now = DateTime.now().toUtc();
  return DeviceCertificate(
    deviceId: deviceId,
    deviceSignatureKey: signatureKey,
    issuedAt: now,
    expiresAt: now.add(remaining),
    certificate: 'Y2VydGlmaWNhdGUtc2lnbmF0dXJl',
  );
}

void main() {
  late _MockMasterKeys masterKeys;
  late _MockIdentity identity;
  late _MockMls mls;
  late _MockDeviceApi deviceApi;
  late _MockDeviceIds deviceIds;
  late _MockAuth auth;
  late _MockStorage storage;
  late AccountEncryptionService service;

  /// The keychain, as a map, so "was the certificate cached" and "does a second
  /// run see it" are the same fact rather than two mock expectations.
  late Map<String, String> keychain;

  late ValueNotifier<MasterKeyStatus> status;

  setUp(() {
    masterKeys = _MockMasterKeys();
    identity = _MockIdentity();
    mls = _MockMls();
    deviceApi = _MockDeviceApi();
    deviceIds = _MockDeviceIds();
    auth = _MockAuth();
    storage = _MockStorage();
    keychain = {};
    status = ValueNotifier(MasterKeyStatus.ready);

    service = AccountEncryptionService(
      masterKeys: masterKeys,
      identity: identity,
      mls: mls,
      deviceApi: deviceApi,
      deviceIdService: deviceIds,
      authRepository: auth,
      secureStorage: storage,
    );

    when(() => auth.currentUserId).thenReturn(_userId);
    when(() => deviceIds.deviceIdOrNull).thenReturn(_deviceId);
    when(() => mls.signaturePublicKey).thenReturn(_signatureKey);
    when(() => masterKeys.status).thenReturn(status);

    when(
      () => masterKeys.peek(
        userId: any(named: 'userId'),
        deviceId: any(named: 'deviceId'),
      ),
    ).thenAnswer((_) async => _masterKey);
    when(
      () => masterKeys.readStatus(),
    ).thenAnswer((_) async => const RecoveryKeyStatus.read(null));
    when(
      () => masterKeys.unlock(
        userId: any(named: 'userId'),
        deviceId: any(named: 'deviceId'),
        password: any(named: 'password'),
        recoveryCode: any(named: 'recoveryCode'),
      ),
    ).thenAnswer((_) async => _masterKey);

    when(
      () => identity.ensure(
        userId: any(named: 'userId'),
        deviceId: any(named: 'deviceId'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => true);
    when(() => identity.version).thenReturn(1);
    when(
      () => identity.issueForThisDevice(
        userId: any(named: 'userId'),
        deviceId: any(named: 'deviceId'),
        deviceSignatureKey: any(named: 'deviceSignatureKey'),
      ),
    ).thenAnswer((_) async => _certificate());

    when(
      () => deviceApi.uploadDeviceCertificate(
        clientDeviceId: any(named: 'clientDeviceId'),
        certificate: any(named: 'certificate'),
        issuedAt: any(named: 'issuedAt'),
        expiresAt: any(named: 'expiresAt'),
        identityKeyVersion: any(named: 'identityKeyVersion'),
      ),
    ).thenAnswer((_) async {});

    when(
      () => storage.readDeviceCertificate(
        deviceId: any(named: 'deviceId'),
        userId: any(named: 'userId'),
      ),
    ).thenAnswer((i) async => keychain[i.namedArguments[#deviceId] as String]);
    when(
      () => storage.writeDeviceCertificate(
        deviceId: any(named: 'deviceId'),
        userId: any(named: 'userId'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((i) async {
      keychain[i.namedArguments[#deviceId] as String] =
          i.namedArguments[#value] as String;
    });
    when(
      () => storage.readRecoveryCodeAcknowledged(any()),
    ).thenAnswer((_) async => false);
    when(
      () => storage.writeRecoveryCodeAcknowledged(any()),
    ).thenAnswer((_) async {});
  });

  group('a fresh account, signing in with a password', () {
    test('gets an identity key and a published device certificate', () async {
      final result = await service.establish(password: 'hunter2');

      expect(result.masterKeyReady, isTrue);
      expect(result.identityKeyReady, isTrue);
      expect(result.certificateIssued, isTrue);
      expect(result.certificateCurrent, isTrue);

      // The password reaches `ensure`. It has to: the server gates
      // `PUT users/identity-key` on it for a *first* publication as well as a
      // rotation, because whoever publishes first is who every peer TOFU-pins.
      verify(
        () => identity.ensure(
          userId: _userId,
          deviceId: _deviceId,
          password: 'hunter2',
        ),
      ).called(1);

      // The certificate binds *this* leaf: the signature key the MLS session is
      // actually using, not a freshly minted one. A certificate for a different
      // key is `CertificateVerdict.wrongLeaf`, which §L.2 says is always an
      // attack and never a rollout artefact.
      verify(
        () => identity.issueForThisDevice(
          userId: _userId,
          deviceId: _deviceId,
          deviceSignatureKey: _signatureKey,
        ),
      ).called(1);
      verify(
        () => deviceApi.uploadDeviceCertificate(
          clientDeviceId: _deviceId,
          certificate: any(named: 'certificate'),
          issuedAt: any(named: 'issuedAt'),
          expiresAt: any(named: 'expiresAt'),
          identityKeyVersion: 1,
        ),
      ).called(1);
    });

    test('unlocks the master key when the keychain has none yet', () async {
      when(
        () => masterKeys.peek(
          userId: any(named: 'userId'),
          deviceId: any(named: 'deviceId'),
        ),
      ).thenAnswer((_) async => null);

      final result = await service.establish(password: 'hunter2');

      expect(result.masterKeyReady, isTrue);
      verify(
        () => masterKeys.unlock(
          userId: _userId,
          deviceId: _deviceId,
          password: 'hunter2',
        ),
      ).called(1);
    });
  });

  group('an existing account with neither key', () {
    // §I.2's long tail. Every account in the field is here, and the only thing
    // that must be true of them is that nothing breaks.
    test('is retrofitted rather than blocked, and loses nothing', () async {
      when(
        () => masterKeys.peek(
          userId: any(named: 'userId'),
          deviceId: any(named: 'deviceId'),
        ),
      ).thenAnswer((_) async => null);
      status.value = MasterKeyStatus.needsRecoveryCode;

      final result = await service.establish(password: 'hunter2');

      expect(result.masterKeyReady, isTrue);
      expect(result.identityKeyReady, isTrue);
      expect(result.certificateIssued, isTrue);

      // Nothing is deleted on the way. The MLS identity, the group registry and
      // the message cache are untouched by this path - it only adds.
      verifyNever(() => mls.forgetEverything());
      verifyNever(
        () => storage.clearMlsIdentity(
          deviceId: any(named: 'deviceId'),
          userId: any(named: 'userId'),
        ),
      );
      verifyNever(
        () => storage.clearMasterKey(
          deviceId: any(named: 'deviceId'),
          userId: any(named: 'userId'),
        ),
      );
    });

    test(
      'a cold start with no password still refreshes the certificate',
      () async {
        // The overwhelming majority of launches. There is no password, so nothing
        // that establishes credentials can run - but the certificate route needs
        // none, and refreshing it is what keeps coverage from decaying as
        // certificates age out.
        final result = await service.establish();

        expect(result.certificateIssued, isTrue);
        verify(
          () => identity.ensure(
            userId: _userId,
            deviceId: _deviceId,
            password: null,
          ),
        ).called(1);
      },
    );

    test('a cold start with no master key defers instead of failing', () async {
      when(
        () => masterKeys.peek(
          userId: any(named: 'userId'),
          deviceId: any(named: 'deviceId'),
        ),
      ).thenAnswer((_) async => null);

      final result = await service.establish();

      expect(result.masterKeyReady, isFalse);
      expect(result.identityKeyReady, isFalse);
      expect(result.certificateIssued, isFalse);
      // Critically: it did not mint anything it could not publish, and it did
      // not unlock with a password it does not have.
      verifyNever(
        () => masterKeys.unlock(
          userId: any(named: 'userId'),
          deviceId: any(named: 'deviceId'),
          password: any(named: 'password'),
          recoveryCode: any(named: 'recoveryCode'),
        ),
      );
      verifyNever(
        () => identity.ensure(
          userId: any(named: 'userId'),
          deviceId: any(named: 'deviceId'),
          password: any(named: 'password'),
        ),
      );
    });

    test('an unreadable recovery-key state never mints a master key', () async {
      // The failure that used to write a fresh random master key over the real
      // one: a timeout arrived as the same answer an account with no envelope
      // does, orphaning every backup blob and the account identity key while
      // reporting success.
      when(
        () => masterKeys.peek(
          userId: any(named: 'userId'),
          deviceId: any(named: 'deviceId'),
        ),
      ).thenAnswer((_) async => null);
      when(
        () => masterKeys.readStatus(),
      ).thenAnswer((_) async => const RecoveryKeyStatus.unavailable());

      final result = await service.establish(password: 'hunter2');

      expect(result.masterKeyReady, isFalse);
      verifyNever(
        () => masterKeys.unlock(
          userId: any(named: 'userId'),
          deviceId: any(named: 'deviceId'),
          password: any(named: 'password'),
          recoveryCode: any(named: 'recoveryCode'),
        ),
      );
    });
  });

  group('idempotency', () {
    test(
      'two launches do not mint two identity keys or two certificates',
      () async {
        await service.establish(password: 'hunter2');
        await service.establish(password: 'hunter2');

        // `ensure` runs both times - it is the thing that *loads* the key, and it
        // is idempotent by construction - but the certificate is signed and
        // uploaded once. Reissuing on every launch would churn the value peers are
        // verifying against for no reason.
        verify(
          () => identity.issueForThisDevice(
            userId: any(named: 'userId'),
            deviceId: any(named: 'deviceId'),
            deviceSignatureKey: any(named: 'deviceSignatureKey'),
          ),
        ).called(1);
        verify(
          () => deviceApi.uploadDeviceCertificate(
            clientDeviceId: any(named: 'clientDeviceId'),
            certificate: any(named: 'certificate'),
            issuedAt: any(named: 'issuedAt'),
            expiresAt: any(named: 'expiresAt'),
            identityKeyVersion: any(named: 'identityKeyVersion'),
          ),
        ).called(1);
      },
    );

    test('concurrent triggers share one run', () async {
      // A sign-in and `startAuthenticatedServices` land within milliseconds of
      // each other. Two concurrent runs on an account with no identity key would
      // both see "none published" and both mint one; the loser then holds a
      // private half no peer has pinned - the §H.5 safety-number case, self
      // inflicted.
      await Future.wait([
        service.establish(password: 'hunter2'),
        service.establish(password: 'hunter2'),
      ]);

      verify(
        () => identity.ensure(
          userId: any(named: 'userId'),
          deviceId: any(named: 'deviceId'),
          password: any(named: 'password'),
        ),
      ).called(1);
    });

    test('a certificate close to expiry is reissued', () async {
      keychain[_deviceId] = jsonEncode(
        _certificate(remaining: const Duration(days: 3)).toJson(),
      );

      final result = await service.establish(password: 'hunter2');

      expect(result.certificateIssued, isTrue);
    });

    test('a certificate for a different signing key is reissued', () async {
      // A re-linked device mints a fresh signing keypair. The old certificate
      // names the old key, so it vouches for a leaf that no longer exists.
      keychain[_deviceId] = jsonEncode(
        _certificate(signatureKey: 'b3RoZXIta2V5').toJson(),
      );

      final result = await service.establish(password: 'hunter2');

      expect(result.certificateIssued, isTrue);
    });
  });

  group('failure degrades gracefully', () {
    test(
      'an offline certificate upload still lets the user into the app',
      () async {
        when(
          () => deviceApi.uploadDeviceCertificate(
            clientDeviceId: any(named: 'clientDeviceId'),
            certificate: any(named: 'certificate'),
            issuedAt: any(named: 'issuedAt'),
            expiresAt: any(named: 'expiresAt'),
            identityKeyVersion: any(named: 'identityKeyVersion'),
          ),
        ).thenThrow(DioException(requestOptions: RequestOptions(path: '/')));

        final result = await service.establish(password: 'hunter2');

        expect(result.identityKeyReady, isTrue);
        expect(result.certificateIssued, isFalse);
        expect(result.certificateCurrent, isFalse);
        // And nothing was cached, so the next launch retries rather than believing
        // it already published one.
        expect(keychain, isEmpty);
      },
    );

    test('a 500 from the identity-key publish does not stop the run', () async {
      when(
        () => identity.ensure(
          userId: any(named: 'userId'),
          deviceId: any(named: 'deviceId'),
          password: any(named: 'password'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/'),
          response: Response<void>(
            requestOptions: RequestOptions(path: '/'),
            statusCode: 500,
          ),
        ),
      );

      final result = await service.establish(password: 'hunter2');

      expect(result.masterKeyReady, isTrue);
      expect(result.identityKeyReady, isFalse);
      expect(result.certificateIssued, isFalse);
    });

    test('a thrown master-key read is swallowed, not propagated', () async {
      when(
        () => masterKeys.readStatus(),
      ).thenThrow(StateError('the platform channel is not available'));

      // No throw. A launch that fell over here would take the whole app with it
      // for an account that has nothing to encrypt yet.
      final result = await service.establish(password: 'hunter2');
      expect(result.masterKeyReady, isFalse);
    });

    test('no signed-in user is a no-op rather than an error', () async {
      when(() => auth.currentUserId).thenReturn(null);

      final result = await service.establish(password: 'hunter2');

      expect(result.identityKeyReady, isFalse);
      verifyNever(
        () => identity.ensure(
          userId: any(named: 'userId'),
          deviceId: any(named: 'deviceId'),
          password: any(named: 'password'),
        ),
      );
    });

    test(
      'a device with no MLS identity issues no certificate and does not throw',
      () async {
        when(() => mls.signaturePublicKey).thenReturn(null);

        final result = await service.establish(password: 'hunter2');

        expect(result.identityKeyReady, isTrue);
        expect(result.certificateIssued, isFalse);
        verifyNever(
          () => identity.issueForThisDevice(
            userId: any(named: 'userId'),
            deviceId: any(named: 'deviceId'),
            deviceSignatureKey: any(named: 'deviceSignatureKey'),
          ),
        );
      },
    );
  });

  group('the recovery-code prompt', () {
    test(
      'is raised for an account that has no recovery-code wrapping',
      () async {
        status.value = MasterKeyStatus.needsRecoveryCode;

        final result = await service.establish(password: 'hunter2');

        expect(result.needsRecoveryCode, isTrue);
        expect(service.recoveryCodeOwed.value, isTrue);
      },
    );

    test('is not raised for a user who already has one', () async {
      // Whichever device wrote the wrapping. Offering a fresh code here would
      // replace it and silently invalidate the copy they wrote down - the
      // retrofit turning into the loss it exists to prevent.
      status.value = MasterKeyStatus.ready;

      final result = await service.establish(password: 'hunter2');

      expect(result.needsRecoveryCode, isFalse);
      expect(service.recoveryCodeOwed.value, isFalse);
    });

    test(
      'is not raised again once a code has been confirmed on this device',
      () async {
        status.value = MasterKeyStatus.needsRecoveryCode;
        when(
          () => storage.readRecoveryCodeAcknowledged(any()),
        ).thenAnswer((_) async => true);

        final result = await service.establish(password: 'hunter2');

        expect(result.needsRecoveryCode, isFalse);
      },
    );

    test(
      'marking it saved records the acknowledgement and lowers the flag',
      () async {
        status.value = MasterKeyStatus.needsRecoveryCode;
        await service.establish(password: 'hunter2');
        expect(service.recoveryCodeOwed.value, isTrue);

        await service.markRecoveryCodeSaved(_userId);

        expect(service.recoveryCodeOwed.value, isFalse);
        verify(() => storage.writeRecoveryCodeAcknowledged(_userId)).called(1);
      },
    );

    test('a completed loss is not offered a retrofit', () async {
      // `historyLost` means the password wrapping was invalidated by a reset and
      // there was no recovery-code wrapping. There is no master key to wrap, so
      // offering a code would produce one that opens nothing.
      status.value = MasterKeyStatus.historyLost;

      final result = await service.establish(password: 'hunter2');

      expect(result.needsRecoveryCode, isFalse);
    });

    // Found on a real handset against the live backend, not in a test. The
    // account's *status* is the server's answer, but the code has to be wrapped
    // around a master key **this device holds** - and an account whose envelope
    // another device wrote satisfies the status check on a handset that has
    // never unlocked it. The banner appeared, the flow ran, and the write failed
    // at the last step with "your master key is not unlocked on this device".
    test(
      'is not raised when this device does not hold the master key',
      () async {
        when(
          () => masterKeys.peek(
            userId: any(named: 'userId'),
            deviceId: any(named: 'deviceId'),
          ),
        ).thenAnswer((_) async => null);
        status.value = MasterKeyStatus.needsRecoveryCode;

        // No password either, so nothing can unlock it this launch.
        final result = await service.establish();

        expect(result.masterKeyReady, isFalse);
        expect(
          result.needsRecoveryCode,
          isFalse,
          reason:
              'offering something that cannot work is worse than not offering',
        );
        expect(service.recoveryCodeOwed.value, isFalse);
      },
    );
  });

  group('generation enforces nothing', () {
    test('nothing on this path removes a device or a leaf', () async {
      await service.establish(password: 'hunter2');

      verifyNever(() => mls.forgetEverything());
      verifyNever(() => deviceApi.remove(any()));
      verifyNever(() => deviceApi.resetKeyPackages(any()));
    });

    test(
      'certificate enforcement is untouched and defaults to Observe',
      () async {
        // §I.1: the phase is server-supplied and defaults to Observe. Wiring
        // generation must not move it - a client that inferred a stricter phase
        // from its own capabilities would start proposing removals against an
        // install base with 0% coverage, including its owner's other devices.
        final policy = MlsPolicyService(client: _MockApiClient());

        expect(policy.current, CertificateEnforcement.observe);
        await service.establish(password: 'hunter2');
        expect(
          policy.current,
          CertificateEnforcement.observe,
          reason: 'the phase is the server\'s to move, on coverage data',
        );
      },
    );
  });
}
