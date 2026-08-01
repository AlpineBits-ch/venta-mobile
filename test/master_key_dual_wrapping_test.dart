import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mls/venta_mls.dart';
import 'package:venta_mobile/core/crypto/master_key_api.dart';
import 'package:venta_mobile/core/crypto/master_key_service.dart';
import 'package:venta_mobile/core/storage/secure_storage_service.dart';

/// What these cover: contract §C.1.1, the reason the master key is wrapped
/// twice.
///
/// `ResetPassword` never touched `EncryptedMasterKey`, so the envelope stayed
/// sealed under a password the user had — by definition of a reset — forgotten.
/// Every backup blob and the account identity key became permanently unopenable,
/// silently, at exactly the moment someone was trying to recover their account.
///
/// The recovery code is the only credential that survives that, which is why an
/// account without one must be *told* rather than left to discover it, and why
/// `VerifiedDevices` — whose only recovery credential is the code — must refuse
/// to engage without it.

class _MockApi extends Mock implements MasterKeyApi {}

class _MockEngine extends Mock implements VentaMls {}

class _MockSecureStorage extends Mock implements SecureStorageService {}

const _userId = 'user_1';
const _deviceId = 'device_1';
const _masterKey = 'bWFzdGVyLWtleS0zMi1ieXRlcy1sb25nLWs=';

EncryptedMasterKeyDto _wrapping(String label) => EncryptedMasterKeyDto(
  cipherText: 'ct-$label',
  salt: 'salt-$label',
  iv: 'iv-$label',
  argon2Iterations: 3,
  argon2Memory: 65536,
  argon2Parallelism: 1,
  version: 2,
);

RecoveryKeyStateDto _state({
  EncryptedMasterKeyDto? password,
  EncryptedMasterKeyDto? recoveryCode,
  DateTime? invalidatedAt,
  bool recoverable = true,
}) => RecoveryKeyStateDto(
  version: 2,
  passwordWrapping: password,
  recoveryCodeWrapping: recoveryCode,
  passwordWrappingInvalidatedAt: invalidatedAt,
  encryptedHistoryRecoverable: recoverable,
);

void main() {
  late _MockApi api;
  late _MockEngine engine;
  late _MockSecureStorage storage;
  late MasterKeyService service;

  setUpAll(() => registerFallbackValue(_wrapping('fallback')));

  setUp(() {
    api = _MockApi();
    engine = _MockEngine();
    storage = _MockSecureStorage();
    service = MasterKeyService(
      api: api,
      secureStorage: storage,
      engine: engine,
    );

    when(
      () => storage.readMasterKey(
        deviceId: any(named: 'deviceId'),
        userId: any(named: 'userId'),
      ),
    ).thenAnswer((_) async => null);
    when(
      () => storage.writeMasterKey(
        deviceId: any(named: 'deviceId'),
        userId: any(named: 'userId'),
        masterKey: any(named: 'masterKey'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => engine.normalizeRecoveryCode(any()),
    ).thenAnswer((i) async => (i.positionalArguments.first as String)
        .replaceAll('-', '')
        .toUpperCase());
    when(
      () => api.putRecoveryKey(
        version: any(named: 'version'),
        passwordWrapping: any(named: 'passwordWrapping'),
        recoveryCodeWrapping: any(named: 'recoveryCodeWrapping'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => api.rewrapPassword(
        version: any(named: 'version'),
        passwordWrapping: any(named: 'passwordWrapping'),
      ),
    ).thenAnswer((_) async {});
  });

  group('status', () {
    test('an account with no recovery code is flagged, not left to find out', () async {
      // Every account created before §C.1.1 is here, and each one is a single
      // password reset away from losing every backup blob and the account
      // identity key.
      when(() => api.fetchRecoveryKey())
          .thenAnswer((_) async => _state(password: _wrapping('p')));

      await service.refreshStatus();

      expect(service.status.value, MasterKeyStatus.needsRecoveryCode);
    });

    test('a completed loss is reported as a loss, not a warning', () async {
      // A reset invalidated the password wrapping and there was no recovery-code
      // wrapping. This is not "you might lose your history" - it is gone.
      when(() => api.fetchRecoveryKey()).thenAnswer(
        (_) async => _state(
          invalidatedAt: DateTime.utc(2026, 8, 1),
          recoverable: false,
        ),
      );

      await service.refreshStatus();

      expect(service.status.value, MasterKeyStatus.historyLost);
    });

    test('a reset with a recovery code to fall back on is recoverable', () async {
      when(() => api.fetchRecoveryKey()).thenAnswer(
        (_) async => _state(
          recoveryCode: _wrapping('r'),
          invalidatedAt: DateTime.utc(2026, 8, 1),
        ),
      );

      await service.refreshStatus();

      expect(service.status.value, MasterKeyStatus.needsPasswordRewrap);
    });

    test('both wrappings present is ready', () async {
      when(() => api.fetchRecoveryKey()).thenAnswer(
        (_) async => _state(
          password: _wrapping('p'),
          recoveryCode: _wrapping('r'),
        ),
      );

      await service.refreshStatus();

      expect(service.status.value, MasterKeyStatus.ready);
    });
  });

  group('setup', () {
    test('writes both wrappings under one version and returns the code', () async {
      when(
        () => engine.setupMasterKey(any(), recoveryCode: any(named: 'recoveryCode')),
      ).thenAnswer(
        (_) async => {
          'passwordWrapping': _wrapping('p').toJson(),
          'recoveryCodeWrapping': _wrapping('r').toJson(),
          'recoveryCode': 'ABCD-EFGH-2345-6789',
          'masterKey': _masterKey,
        },
      );

      final result = await service.setUp(
        userId: _userId,
        deviceId: _deviceId,
        password: 'hunter2',
      );

      expect(result.recoveryCode, 'ABCD-EFGH-2345-6789');
      expect(result.masterKey, _masterKey);
      expect(service.status.value, MasterKeyStatus.ready);

      final captured = verify(
        () => api.putRecoveryKey(
          version: captureAny(named: 'version'),
          passwordWrapping: captureAny(named: 'passwordWrapping'),
          recoveryCodeWrapping: captureAny(named: 'recoveryCodeWrapping'),
        ),
      ).captured;
      expect(
        captured[0],
        2,
        reason: 'both wrappings seal the same bytes, so they share a version',
      );
      expect((captured[1] as EncryptedMasterKeyDto).cipherText, 'ct-p');
      expect((captured[2] as EncryptedMasterKeyDto).cipherText, 'ct-r');
    });
  });

  group('unlock after a password reset', () {
    setUp(() {
      // The password wrapping is gone; only the recovery code is left.
      when(() => api.fetchRecoveryKey()).thenAnswer(
        (_) async => _state(
          recoveryCode: _wrapping('r'),
          invalidatedAt: DateTime.utc(2026, 8, 1),
        ),
      );
      when(
        () => engine.decryptMasterKey(
          encryptedMasterKey: any(named: 'encryptedMasterKey'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((i) async {
        // Only the normalised recovery code opens it.
        if (i.namedArguments[#password] == 'ABCDEFGH23456789') return _masterKey;
        throw Exception('wrong secret');
      });
      when(
        () => engine.wrapMasterKeyUnder(
          masterKeyB64: any(named: 'masterKeyB64'),
          secret: any(named: 'secret'),
        ),
      ).thenAnswer((_) async => _wrapping('p2').toJson());
    });

    test('opens with the recovery code and re-wraps under the new password', () async {
      final key = await service.unlock(
        userId: _userId,
        deviceId: _deviceId,
        password: 'the-new-one',
        recoveryCode: 'abcd-efgh-2345-6789',
      );

      expect(key, _masterKey);

      // Re-wrapped so the *next* unlock is ordinary again. Doing it here rather
      // than as a separate step is what stops it being forgotten.
      verify(
        () => engine.wrapMasterKeyUnder(
          masterKeyB64: _masterKey,
          secret: 'the-new-one',
        ),
      ).called(1);
      verify(
        () => api.rewrapPassword(
          version: 2,
          passwordWrapping: any(named: 'passwordWrapping'),
        ),
      ).called(1);
      expect(service.status.value, MasterKeyStatus.ready);
    });

    test('re-wraps the same master key rather than minting a new one', () async {
      // Every backup blob and every admission proof is bound to the existing
      // key. Replacing it would orphan all of them, and nobody would notice
      // until the first restore.
      await service.unlock(
        userId: _userId,
        deviceId: _deviceId,
        password: 'the-new-one',
        recoveryCode: 'abcd-efgh-2345-6789',
      );

      verifyNever(
        () => engine.setupMasterKey(any(), recoveryCode: any(named: 'recoveryCode')),
      );
      verify(
        () => storage.writeMasterKey(
          deviceId: _deviceId,
          userId: _userId,
          masterKey: _masterKey,
        ),
      ).called(1);
    });

    test('a wrong recovery code unlocks nothing and re-wraps nothing', () async {
      final key = await service.unlock(
        userId: _userId,
        deviceId: _deviceId,
        password: 'the-new-one',
        recoveryCode: '2222-2222-2222-2222',
      );

      expect(key, isNull);
      verifyNever(
        () => api.rewrapPassword(
          version: any(named: 'version'),
          passwordWrapping: any(named: 'passwordWrapping'),
        ),
      );
    });

    test('the key still unlocks even if the re-wrap upload fails', () async {
      // A failed re-wrap costs the user one more use of the code. Failing the
      // whole unlock over it would be strictly worse.
      when(
        () => api.rewrapPassword(
          version: any(named: 'version'),
          passwordWrapping: any(named: 'passwordWrapping'),
        ),
      ).thenThrow(DioException(requestOptions: RequestOptions(path: '/')));

      final key = await service.unlock(
        userId: _userId,
        deviceId: _deviceId,
        password: 'the-new-one',
        recoveryCode: 'abcd-efgh-2345-6789',
      );

      expect(key, _masterKey);
    });
  });

  test('no password wrapping and no code offered is a loss, not a bad password', () async {
    when(() => api.fetchRecoveryKey()).thenAnswer(
      (_) async => _state(invalidatedAt: DateTime.utc(2026, 8, 1)),
    );

    final key = await service.unlock(
      userId: _userId,
      deviceId: _deviceId,
      password: 'anything',
    );

    expect(key, isNull);
    expect(
      service.status.value,
      MasterKeyStatus.historyLost,
      reason: 'there is no door left, so this must not read as a typo',
    );
  });

  group('retrofitting a recovery code', () {
    const generated = 'WXYZ-2345-6789-ABCD-JKMN-PQRS-TVWX-YZ23';
    const normalized = 'WXYZ23456789ABCDJKMNPQRSTVWXYZ23';

    setUp(() {
      when(
        () => storage.readMasterKey(
          deviceId: any(named: 'deviceId'),
          userId: any(named: 'userId'),
        ),
      ).thenAnswer((_) async => _masterKey);
      when(() => engine.generateRecoveryCode())
          .thenAnswer((_) async => generated);
      when(
        () => engine.wrapMasterKeyUnder(
          masterKeyB64: any(named: 'masterKeyB64'),
          secret: any(named: 'secret'),
        ),
      ).thenAnswer((_) async => _wrapping('r').toJson());
    });

    test('adds it to an account that never had one', () async {
      var reads = 0;
      when(() => api.fetchRecoveryKey()).thenAnswer((_) async {
        // First read: password wrapping only. After the write: both — which is
        // what the verification inside `addRecoveryCode` looks for.
        reads++;
        return reads == 1
            ? _state(password: _wrapping('p'))
            : _state(password: _wrapping('p'), recoveryCode: _wrapping('r'));
      });

      final code = await service.addRecoveryCode(
        userId: _userId,
        deviceId: _deviceId,
      );

      expect(code, generated);
      // Wrapped under the normalised form, or the code as displayed would not
      // open it.
      verify(
        () => engine.wrapMasterKeyUnder(
          masterKeyB64: _masterKey,
          secret: normalized,
        ),
      ).called(1);
      expect(service.status.value, MasterKeyStatus.ready);
    });

    test('sends the stored password wrapping back byte-identical', () async {
      // The server refuses a differing `cipherText` at an unchanged version, and
      // has to: different bytes under the same version is either a re-wrap under
      // a new password (a different route) or a different master key claiming to
      // be the same one, which would leave every blob at that version unopenable
      // while asserting nothing had changed.
      //
      // So this must never re-encrypt the password side — that produces
      // different ciphertext from a fresh IV and now earns a 400. Pinned because
      // "freshen the other wrapping while we're here" is an obvious-looking
      // change that would silently break every retrofit.
      final stored = _wrapping('p');
      var reads = 0;
      when(() => api.fetchRecoveryKey()).thenAnswer((_) async {
        reads++;
        return reads == 1
            ? _state(password: stored)
            : _state(password: stored, recoveryCode: _wrapping('r'));
      });

      await service.addRecoveryCode(userId: _userId, deviceId: _deviceId);

      final captured = verify(
        () => api.putRecoveryKey(
          version: captureAny(named: 'version'),
          passwordWrapping: captureAny(named: 'passwordWrapping'),
          recoveryCodeWrapping: captureAny(named: 'recoveryCodeWrapping'),
        ),
      ).captured;

      expect(captured[0], 2, reason: 'same version — additive, nothing rotated');
      expect(
        captured[1],
        same(stored),
        reason: 'the exact object the GET returned, not a re-encryption of it',
      );
      // Only the recovery side is freshly wrapped.
      verify(
        () => engine.wrapMasterKeyUnder(
          masterKeyB64: any(named: 'masterKeyB64'),
          secret: normalized,
        ),
      ).called(1);
    });

    test('refuses to show a code the server did not store', () async {
      // The server has a path that answers 200 to a same-version write and
      // persists nothing. Believing it would leave someone convinced they have a
      // recovery code when they do not — found out mid-recovery, with no second
      // copy. Failing visibly is the best a client can do about that.
      when(() => api.fetchRecoveryKey())
          .thenAnswer((_) async => _state(password: _wrapping('p')));

      await expectLater(
        service.addRecoveryCode(userId: _userId, deviceId: _deviceId),
        throwsA(isA<RecoveryCodeNotStoredException>()),
      );
      expect(
        service.status.value,
        isNot(MasterKeyStatus.ready),
        reason: 'the account is still unprotected and must not read as ready',
      );
    });
  });

  test('a password reset result is applied to the status', () {
    service.applyPasswordResetResult(
      masterKeyRewrapRequired: true,
      encryptedHistoryRecoverable: true,
    );
    expect(service.status.value, MasterKeyStatus.needsPasswordRewrap);

    service.applyPasswordResetResult(
      masterKeyRewrapRequired: true,
      encryptedHistoryRecoverable: false,
    );
    expect(service.status.value, MasterKeyStatus.historyLost);
  });
}
