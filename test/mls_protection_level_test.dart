import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mls/venta_mls.dart';
import 'package:venta_mobile/core/crypto/account_identity_service.dart';
import 'package:venta_mobile/core/crypto/master_key_api.dart';
import 'package:venta_mobile/core/crypto/master_key_service.dart';
import 'package:venta_mobile/core/mls/mls_policy_service.dart';
import 'package:venta_mobile/core/mls/protection_level_service.dart';
import 'package:venta_mobile/core/network/api_client.dart';
import 'package:venta_mobile/core/storage/secure_storage_service.dart';

/// What these cover: the two places where "what do we do when we cannot tell?"
/// has opposite right answers, and getting either backwards is a shipped
/// incident.
///
/// * **Certificate enforcement (§I.1) fails to `Observe`.** No device in the
///   field has a device certificate. A client that treated an unreachable or
///   unparsable policy as `Enforce` would start proposing the removal of every
///   other device in every group it is in, including its owner's.
/// * **Protection level (§G.3) fails to `VerifiedDevices`.** If the level were a
///   plain server-side value, a server could silently downgrade a strict account
///   and then auto-admit its own device. So an unverifiable level is rejected
///   rather than defaulted, and the strict interpretation wins.
///
/// One direction costs a rollout; the other destroys groups or admits an
/// attacker. They are not symmetric and the code must not treat them as if they
/// were.

class _MockApiClient extends Mock implements ApiClient {}

class _MockDio extends Mock implements Dio {}

class _MockEngine extends Mock implements VentaMls {}

class _MockIdentity extends Mock implements AccountIdentityService {}

class _MockMasterKeyApi extends Mock implements MasterKeyApi {}

class _MockSecureStorage extends Mock implements SecureStorageService {}

class _MockMasterKeys extends Mock implements MasterKeyService {}

Response<Map<String, dynamic>> _ok(Map<String, dynamic> body) =>
    Response<Map<String, dynamic>>(
      data: body,
      statusCode: 200,
      requestOptions: RequestOptions(path: '/'),
    );

DioException _status(int code) => DioException(
  requestOptions: RequestOptions(path: '/'),
  response: Response<dynamic>(
    statusCode: code,
    requestOptions: RequestOptions(path: '/'),
  ),
);

void main() {
  late _MockApiClient client;
  late _MockDio dio;

  setUp(() {
    client = _MockApiClient();
    dio = _MockDio();
    when(() => client.dio).thenReturn(dio);
    when(() => client.url(any())).thenAnswer(
      (i) => 'https://example.test${i.positionalArguments.first}',
    );
  });

  group('certificate enforcement (§I.1)', () {
    test('is Observe before anything has been fetched', () {
      expect(
        MlsPolicyService(client: client).current,
        CertificateEnforcement.observe,
      );
    });

    test('reads the three phases the server can name', () async {
      for (final (wire, expected) in [
        ('Observe', CertificateEnforcement.observe),
        ('Warn', CertificateEnforcement.warn),
        ('Enforce', CertificateEnforcement.enforce),
      ]) {
        when(
          () => dio.get<Map<String, dynamic>>(any()),
        ).thenAnswer((_) async => _ok({'certificateEnforcement': wire}));

        final policy = MlsPolicyService(client: client);
        expect(await policy.resolve(), expected, reason: wire);
      }
    });

    test('an unreachable server yields Observe, never Enforce', () async {
      when(() => dio.get<Map<String, dynamic>>(any())).thenThrow(_status(503));

      final policy = MlsPolicyService(client: client);

      expect(await policy.resolve(), CertificateEnforcement.observe);
    });

    test('a malformed or unknown phase yields Observe', () async {
      // Including a value a *later* server might introduce. Treating an
      // unrecognised string as the strictest option would make adding one a
      // group-destroying change.
      for (final body in <Map<String, dynamic>>[
        {},
        {'certificateEnforcement': null},
        {'certificateEnforcement': 42},
        {'certificateEnforcement': 'EnforceHarder'},
      ]) {
        when(
          () => dio.get<Map<String, dynamic>>(any()),
        ).thenAnswer((_) async => _ok(body));

        final policy = MlsPolicyService(client: client);
        expect(
          await policy.resolve(),
          CertificateEnforcement.observe,
          reason: '$body',
        );
      }
    });
  });

  group('protection level (§G.3)', () {
    late _MockEngine engine;
    late _MockIdentity identity;
    late _MockMasterKeyApi masterKeyApi;
    late _MockSecureStorage storage;
    late _MockMasterKeys masterKeys;
    late ValueNotifier<MasterKeyStatus> masterKeyStatus;
    late ProtectionLevelService service;

    setUp(() {
      engine = _MockEngine();
      identity = _MockIdentity();
      masterKeyApi = _MockMasterKeyApi();
      storage = _MockSecureStorage();
      masterKeys = _MockMasterKeys();
      masterKeyStatus = ValueNotifier<MasterKeyStatus>(MasterKeyStatus.ready);
      service = ProtectionLevelService(
        client: client,
        identity: identity,
        masterKeyApi: masterKeyApi,
        masterKeys: masterKeys,
        secureStorage: storage,
        engine: engine,
      );

      when(() => identity.publicKey).thenReturn('account-pub');
      when(() => identity.isAvailable).thenReturn(true);
      when(() => masterKeys.status).thenReturn(masterKeyStatus);
      when(
        () => storage.readProtectionLevel(
          deviceId: any(named: 'deviceId'),
          userId: any(named: 'userId'),
        ),
      ).thenAnswer((_) async => null);
      when(
        () => storage.writeProtectionLevel(
          deviceId: any(named: 'deviceId'),
          userId: any(named: 'userId'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});
    });

    test('starts strict, before anything has been verified', () {
      expect(service.effectiveLevel, ProtectionLevel.verifiedDevices);
    });

    test('accepts a level whose assertion verifies', () async {
      when(() => dio.get<Map<String, dynamic>>(any())).thenAnswer(
        (_) async => _ok({
          'level': 'TrustedSignIn',
          'version': 4,
          'updatedAt': '2026-08-01T00:00:00Z',
          'signedAssertion': 'sig',
        }),
      );
      when(
        () => engine.verifyProtectionLevel(
          accountIdentityPublicKeyB64: any(named: 'accountIdentityPublicKeyB64'),
          userId: any(named: 'userId'),
          level: any(named: 'level'),
          version: any(named: 'version'),
          updatedAt: any(named: 'updatedAt'),
          assertionB64: any(named: 'assertionB64'),
        ),
      ).thenAnswer((_) async => true);

      await service.refresh(userId: 'user_a', deviceId: 'device-a');

      expect(service.effectiveLevel, ProtectionLevel.trustedSignIn);
      expect(service.warning.value, isNull);
    });

    test('rejects an unsigned level and falls closed to strict', () async {
      // §G.3: rejected, not defaulted. An unsigned level is exactly what a
      // server would send if it wanted to relax an account it cannot sign for.
      when(() => dio.get<Map<String, dynamic>>(any())).thenAnswer(
        (_) async => _ok({
          'level': 'TrustedSignIn',
          'version': 4,
          'updatedAt': '2026-08-01T00:00:00Z',
          'signedAssertion': '',
        }),
      );

      await service.refresh(userId: 'user_a', deviceId: 'device-a');

      expect(service.effectiveLevel, ProtectionLevel.verifiedDevices);
      expect(service.warning.value, isNotNull);
      verifyNever(
        () => storage.writeProtectionLevel(
          deviceId: any(named: 'deviceId'),
          userId: any(named: 'userId'),
          value: any(named: 'value'),
        ),
      );
    });

    test('rejects a level whose signature does not check out', () async {
      when(() => dio.get<Map<String, dynamic>>(any())).thenAnswer(
        (_) async => _ok({
          'level': 'TrustedSignIn',
          'version': 4,
          'updatedAt': '2026-08-01T00:00:00Z',
          'signedAssertion': 'forged',
        }),
      );
      when(
        () => engine.verifyProtectionLevel(
          accountIdentityPublicKeyB64: any(named: 'accountIdentityPublicKeyB64'),
          userId: any(named: 'userId'),
          level: any(named: 'level'),
          version: any(named: 'version'),
          updatedAt: any(named: 'updatedAt'),
          assertionB64: any(named: 'assertionB64'),
        ),
      ).thenAnswer((_) async => false);

      await service.refresh(userId: 'user_a', deviceId: 'device-a');

      expect(service.effectiveLevel, ProtectionLevel.verifiedDevices);
      expect(service.warning.value, contains('could not be verified'));
    });

    test('an account that never set a level is TrustedSignIn, not strict', () async {
      // 404 is "nothing asserted", which is not a failure to verify - there is
      // nothing that could have been tampered with. §G.5 starts every account
      // here, and treating it as strict would demand an approval nobody was told
      // to expect.
      when(() => dio.get<Map<String, dynamic>>(any())).thenThrow(_status(404));

      await service.refresh(userId: 'user_a', deviceId: 'device-a');

      expect(service.effectiveLevel, ProtectionLevel.trustedSignIn);
    });

    test('an unreachable endpoint does not relax an account, it tightens it', () async {
      when(() => dio.get<Map<String, dynamic>>(any())).thenThrow(_status(503));

      await service.refresh(userId: 'user_a', deviceId: 'device-a');

      expect(
        service.effectiveLevel,
        ProtectionLevel.verifiedDevices,
        reason: 'taking the endpoint away must not be a downgrade',
      );
    });

    test('warns loudly about a downgrade this device did not make', () async {
      when(
        () => storage.readProtectionLevel(
          deviceId: any(named: 'deviceId'),
          userId: any(named: 'userId'),
        ),
      ).thenAnswer(
        (_) async =>
            '{"level":"VerifiedDevices","version":3,"updatedAt":"2026-07-01T00:00:00Z"}',
      );
      when(() => dio.get<Map<String, dynamic>>(any())).thenAnswer(
        (_) async => _ok({
          'level': 'TrustedSignIn',
          'version': 4,
          'updatedAt': '2026-08-01T00:00:00Z',
          'signedAssertion': 'sig',
        }),
      );
      when(
        () => engine.verifyProtectionLevel(
          accountIdentityPublicKeyB64: any(named: 'accountIdentityPublicKeyB64'),
          userId: any(named: 'userId'),
          level: any(named: 'level'),
          version: any(named: 'version'),
          updatedAt: any(named: 'updatedAt'),
          assertionB64: any(named: 'assertionB64'),
        ),
      ).thenAnswer((_) async => true);

      await service.refresh(userId: 'user_a', deviceId: 'device-a');

      expect(service.warning.value, contains('lowered'));
    });

    // H6 / §L.6. "Every client enforces the last validly-signed level it has
    // seen" is unimplementable without a version floor, and there was none - so
    // a genuinely-signed *older* assertion verified perfectly and lowered the
    // stored level. The server keeps every assertion it has ever been given.
    group('the version floor', () {
      void remembered(String json) => when(
        () => storage.readProtectionLevel(
          deviceId: any(named: 'deviceId'),
          userId: any(named: 'userId'),
        ),
      ).thenAnswer((_) async => json);

      void serves(Map<String, dynamic> body) =>
          when(() => dio.get<Map<String, dynamic>>(any()))
              .thenAnswer((_) async => _ok(body));

      void signatureIs(bool valid) => when(
        () => engine.verifyProtectionLevel(
          accountIdentityPublicKeyB64: any(named: 'accountIdentityPublicKeyB64'),
          userId: any(named: 'userId'),
          level: any(named: 'level'),
          version: any(named: 'version'),
          updatedAt: any(named: 'updatedAt'),
          assertionB64: any(named: 'assertionB64'),
        ),
      ).thenAnswer((_) async => valid);

      test('refuses a genuinely signed but older assertion', () async {
        remembered(
          '{"level":"VerifiedDevices","version":7,"updatedAt":"2026-07-01T00:00:00Z"}',
        );
        // The assertion the account signed before it upgraded. Replayed, it
        // verifies - that is the whole attack.
        serves({
          'level': 'TrustedSignIn',
          'version': 3,
          'updatedAt': '2026-06-01T00:00:00Z',
          'signedAssertion': 'genuinely-signed-but-old',
        });
        signatureIs(true);

        final resolved = await service.refresh(
          userId: 'user_a',
          deviceId: 'device-a',
        );

        expect(resolved.version, 7);
        expect(service.effectiveLevel, ProtectionLevel.verifiedDevices);
        expect(service.warning.value, contains('older one'));
        verifyNever(
          () => storage.writeProtectionLevel(
            deviceId: any(named: 'deviceId'),
            userId: any(named: 'userId'),
            value: any(named: 'value'),
          ),
        );
      });

      test('accepts a signed assertion at or above the floor', () async {
        remembered(
          '{"level":"VerifiedDevices","version":7,"updatedAt":"2026-07-01T00:00:00Z"}',
        );
        serves({
          'level': 'TrustedSignIn',
          'version': 8,
          'updatedAt': '2026-08-01T00:00:00Z',
          'signedAssertion': 'sig',
        });
        signatureIs(true);

        final resolved = await service.refresh(
          userId: 'user_a',
          deviceId: 'device-a',
        );

        expect(resolved.version, 8);
        expect(service.effectiveLevel, ProtectionLevel.trustedSignIn);
        expect(
          service.warning.value,
          contains('lowered'),
          reason: 'a legitimate downgrade is permitted and still announced',
        );
      });

      test('a 200 with no assertion does not become TrustedSignIn', () async {
        // The concrete hole: `body == null` left `reachable` true, so the
        // fallback was built with `verified: true` on the relaxed tier. `200 {}`
        // was a complete downgrade.
        serves(<String, dynamic>{});

        final resolved = await service.refresh(
          userId: 'user_a',
          deviceId: 'device-a',
        );

        expect(resolved.verified, isFalse);
        expect(service.effectiveLevel, ProtectionLevel.verifiedDevices);
      });

      test('a 404 does not erase a level this device has already seen signed', () async {
        remembered(
          '{"level":"VerifiedDevices","version":7,"updatedAt":"2026-07-01T00:00:00Z"}',
        );
        when(() => dio.get<Map<String, dynamic>>(any())).thenThrow(_status(404));

        await service.refresh(userId: 'user_a', deviceId: 'device-a');

        expect(
          service.effectiveLevel,
          ProtectionLevel.verifiedDevices,
          reason: '"this account has no level" contradicts something this '
              'device verified, so the floor wins',
        );
        expect(service.warning.value, contains('older one'));
      });

      test('setting a level signs above the floor, not above nothing', () async {
        remembered(
          '{"level":"TrustedSignIn","version":9,"updatedAt":"2026-07-01T00:00:00Z"}',
        );
        when(
          () => storage.readAccountIdentity(
            deviceId: any(named: 'deviceId'),
            userId: any(named: 'userId'),
          ),
        ).thenAnswer((_) async => ('account-pub', 'account-priv'));
        when(
          () => engine.signProtectionLevel(
            accountIdentityPrivateKeyB64: any(named: 'accountIdentityPrivateKeyB64'),
            userId: any(named: 'userId'),
            level: any(named: 'level'),
            version: any(named: 'version'),
            updatedAt: any(named: 'updatedAt'),
          ),
        ).thenAnswer((_) async => 'sig');
        when(() => dio.put<void>(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response<void>(
            statusCode: 200,
            requestOptions: RequestOptions(path: '/'),
          ),
        );

        await service.setLevel(
          userId: 'user_a',
          deviceId: 'device-a',
          level: ProtectionLevel.verifiedDevices,
        );

        final sent = verify(
          () => dio.put<void>(any(), data: captureAny(named: 'data')),
        ).captured.single as Map<String, dynamic>;
        expect(
          sent['version'],
          10,
          reason: 'a device that has not refreshed this session would otherwise '
              'sign version 1, which its own floor then refuses',
        );
      });
    });

    test('cannot be set without an account identity key to sign with', () async {
      // §I.2: an account with no identity key cannot enter VerifiedDevices, and
      // the UI has to explain that rather than failing opaquely.
      when(() => identity.isAvailable).thenReturn(false);

      final set = await service.setLevel(
        userId: 'user_a',
        deviceId: 'device-a',
        level: ProtectionLevel.verifiedDevices,
      );

      expect(set, isFalse);
      verifyNever(() => dio.put<void>(any(), data: any(named: 'data')));
    });

    test('refuses VerifiedDevices without a recovery-code wrapping', () async {
      // §H.7 with §C.1.1. The strict tier names the recovery code as the *only*
      // recovery credential - a server-assisted password reset explicitly
      // cannot restore E2EE. Entering it without one promises a recovery path
      // that does not exist, and the first password reset would be silent,
      // total loss.
      masterKeyStatus.value = MasterKeyStatus.needsRecoveryCode;

      final set = await service.setLevel(
        userId: 'user_a',
        deviceId: 'device-a',
        level: ProtectionLevel.verifiedDevices,
      );

      expect(set, isFalse);
      verifyNever(() => dio.put<void>(any(), data: any(named: 'data')));
    });

    test('still allows the relaxed tier without a recovery code', () async {
      // TrustedSignIn's recovery credential is the password, which the account
      // has. Blocking it too would leave an account unable to set any level.
      masterKeyStatus.value = MasterKeyStatus.needsRecoveryCode;
      when(
        () => engine.signProtectionLevel(
          accountIdentityPrivateKeyB64: any(named: 'accountIdentityPrivateKeyB64'),
          userId: any(named: 'userId'),
          level: any(named: 'level'),
          version: any(named: 'version'),
          updatedAt: any(named: 'updatedAt'),
        ),
      ).thenAnswer((_) async => 'sig');
      when(
        () => storage.readAccountIdentity(
          deviceId: any(named: 'deviceId'),
          userId: any(named: 'userId'),
        ),
      ).thenAnswer((_) async => ('account-pub', 'account-priv'));
      when(
        () => dio.put<void>(any(), data: any(named: 'data')),
      ).thenAnswer(
        (_) async => Response<void>(
          statusCode: 200,
          requestOptions: RequestOptions(path: '/'),
        ),
      );

      final set = await service.setLevel(
        userId: 'user_a',
        deviceId: 'device-a',
        level: ProtectionLevel.trustedSignIn,
      );

      expect(set, isTrue);
    });
  });
}
