import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mls/venta_mls.dart';
import 'package:venta_mobile/core/crypto/account_identity_service.dart';
import 'package:venta_mobile/core/crypto/master_key_api.dart';
import 'package:venta_mobile/core/crypto/master_key_service.dart';
import 'package:venta_mobile/core/device/device_api.dart';
import 'package:venta_mobile/core/mls/leaf_verification_service.dart';
import 'package:venta_mobile/core/mls/mls_policy_service.dart';
import 'package:venta_mobile/core/network/api_client.dart';
import 'package:venta_mobile/core/storage/secure_storage_service.dart';

/// What these cover: contract §I.1, which exists because §H.4 as written is
/// catastrophic to ship.
///
/// §H.4 says a leaf whose device certificate is missing or invalid is proposed
/// for removal. **No device in the field has a certificate.** A client that
/// shipped that rule flat would begin proposing the removal of every other
/// device in every group it is in - including its owner's - the moment it
/// launched.
///
/// So enforcement is three-state, server-driven, and defaults to `Observe`
/// whenever anything is unclear. The asymmetry is the point: an over-lenient
/// guess costs a longer rollout, an over-strict one destroys groups.
///
/// The one case that never gets the benefit of the doubt is an *invalid*
/// certificate, as opposed to an absent one - that cannot arise by accident.

class _MockIdentity extends Mock implements AccountIdentityService {}

class _MockDeviceApi extends Mock implements DeviceApi {}

class _MockApiClient extends Mock implements ApiClient {}

class _MockEngine extends Mock implements VentaMls {}

class _MockSecureStorage extends Mock implements SecureStorageService {}

class _MockMasterKeyApi extends Mock implements MasterKeyApi {}

class _MockMasterKeys extends Mock implements MasterKeyService {}

void main() {
  late _MockIdentity identity;
  late _MockDeviceApi deviceApi;
  late MlsPolicyService policy;
  late LeafVerificationService service;

  setUp(() {
    identity = _MockIdentity();
    deviceApi = _MockDeviceApi();
    policy = MlsPolicyService(client: _MockApiClient());
    service = LeafVerificationService(
      identity: identity,
      deviceApi: deviceApi,
      policy: policy,
    );

    when(
      () => deviceApi.fetchDeviceCertificate(
        userId: any(named: 'userId'),
        clientDeviceId: any(named: 'clientDeviceId'),
      ),
    ).thenAnswer((_) async => null);
  });

  void verdictIs(CertificateVerdict verdict) {
    when(
      () => identity.verify(
        ownerUserId: any(named: 'ownerUserId'),
        certificate: any(named: 'certificate'),
        leafDeviceId: any(named: 'leafDeviceId'),
        leafSignatureKey: any(named: 'leafSignatureKey'),
      ),
    ).thenAnswer((_) async => verdict);
  }

  Future<LeafVerdict> check({Set<String> knownIdentities = const {}}) =>
      service.check(
        ownerUserId: 'user_peer',
        leafDeviceId: 'device-peer',
        leafSignatureKey: 'c2ln',
        knownIdentities: knownIdentities,
      );

  group('a leaf with no certificate', () {
    setUp(() => verdictIs(CertificateVerdict.missing));

    test('is allowed and counted under Observe', () async {
      policy.seed(CertificateEnforcement.observe);

      final verdict = await check();

      expect(verdict.action, LeafAction.allow);
      expect(verdict.warning, isNull, reason: 'Observe shows no UI at all');
      expect(
        service.uncertifiedLeavesSeen,
        1,
        reason:
            'the count is what the decision to advance the phase is made on',
      );
    });

    test('is allowed but flagged under Warn', () async {
      policy.seed(CertificateEnforcement.warn);

      final verdict = await check();

      expect(verdict.action, LeafAction.flag);
      expect(verdict.warning, isNotNull);
    });

    test('is proposed for removal only under Enforce', () async {
      policy.seed(CertificateEnforcement.enforce);

      expect((await check()).action, LeafAction.propose);
    });
  });

  test('an unreachable policy leaves a missing certificate alone', () async {
    // The scenario that would have taken every group down: nothing has a
    // certificate, and the client cannot reach the endpoint that would say so.
    verdictIs(CertificateVerdict.missing);
    final unreachable = MlsPolicyService(client: _MockApiClient());
    final guarded = LeafVerificationService(
      identity: identity,
      deviceApi: deviceApi,
      policy: unreachable,
    );

    final verdict = await guarded.check(
      ownerUserId: 'user_peer',
      leafDeviceId: 'device-peer',
      leafSignatureKey: 'c2ln',
    );

    expect(verdict.action, LeafAction.allow);
  });

  group('an invalid certificate', () {
    setUp(() => verdictIs(CertificateVerdict.invalid));

    test('warns even under Observe - it cannot happen by accident', () async {
      policy.seed(CertificateEnforcement.observe);

      final verdict = await check();

      expect(verdict.action, LeafAction.flag);
      expect(verdict.warning, contains('does not check out'));
    });

    test('is proposed for removal under Enforce', () async {
      policy.seed(CertificateEnforcement.enforce);

      expect((await check()).action, LeafAction.propose);
    });
  });

  test('a changed account identity key is a safety-number warning', () async {
    // §H.5: never auto-accepted, the same way Signal never quietly accepts a
    // changed safety number. Either the account rotated its key, or someone is
    // impersonating it, and only a human can tell the two apart.
    verdictIs(CertificateVerdict.identityChanged);
    policy.seed(CertificateEnforcement.warn);

    final verdict = await check();

    expect(verdict.action, LeafAction.flag);
    expect(verdict.warning, contains('security code has changed'));
  });

  test('a valid certificate is allowed at every phase', () async {
    verdictIs(CertificateVerdict.valid);
    for (final phase in CertificateEnforcement.values) {
      policy.seed(phase);
      final verdict = await check();
      expect(verdict.action, LeafAction.allow, reason: '$phase');
      expect(verdict.warning, isNull);
    }
  });

  // C4 / §L.2. `check` took `deviceId` and `deviceSignatureKey` and read
  // neither: it verified the certificate against the certificate's own
  // self-reported fields. Certificates are public, so a server fetches a genuine
  // one for the account, presents it beside a leaf it injected, and verification
  // passes - at full enforcement, at 100% coverage.
  group('binding the certificate to the leaf', () {
    test(
      'passes the leaf\'s own values to the verifier, not the certificate\'s',
      () async {
        verdictIs(CertificateVerdict.valid);
        when(
          () => deviceApi.fetchDeviceCertificate(
            userId: any(named: 'userId'),
            clientDeviceId: any(named: 'clientDeviceId'),
          ),
        ).thenAnswer(
          (_) async => {
            // A real certificate, for a different device of the same account.
            'deviceId': 'device-elsewhere',
            'deviceSignatureKey': 'c29tZW9uZS1lbHNl',
            'issuedAt': 1,
            'expiresAt': 1 << 40,
            'certificate': 'c2lnbmF0dXJl',
          },
        );

        await service.check(
          ownerUserId: 'user_peer',
          leafDeviceId: 'device-under-examination',
          leafSignatureKey: 'dGhpcy1sZWFm',
        );

        final captured = verify(
          () => identity.verify(
            ownerUserId: any(named: 'ownerUserId'),
            certificate: any(named: 'certificate'),
            leafDeviceId: captureAny(named: 'leafDeviceId'),
            leafSignatureKey: captureAny(named: 'leafSignatureKey'),
          ),
        ).captured;

        expect(
          captured,
          ['device-under-examination', 'dGhpcy1sZWFm'],
          reason:
              'verifying against the certificate\'s own fields asks "did '
              'somebody sign this", not "does this vouch for the leaf in front '
              'of me" - and a replayed genuine certificate answers the first '
              'every time',
        );
      },
    );

    test(
      'a genuine certificate for another leaf is never merely tolerated',
      () async {
        verdictIs(CertificateVerdict.wrongLeaf);

        for (final phase in CertificateEnforcement.values) {
          policy.seed(phase);
          final verdict = await check();

          expect(
            verdict.action,
            phase == CertificateEnforcement.enforce
                ? LeafAction.propose
                : LeafAction.flag,
            reason:
                '$phase - this cannot happen by accident, so Observe may '
                'suppress removal but never the warning',
          );
          expect(verdict.warning, contains('for a different device'));
        }
      },
    );
  });

  // §L.5. `Observe` suppresses removal, never detection.
  group('detection that survives Observe', () {
    test(
      'a device that certified before and now does not is an attack',
      () async {
        policy.seed(CertificateEnforcement.observe);
        service.rememberCertified(userId: 'user_peer', deviceId: 'device-peer');
        verdictIs(CertificateVerdict.missing);

        final verdict = await check();

        expect(
          verdict.action,
          LeafAction.flag,
          reason:
              'absence after presence is suppression, not a pending upgrade',
        );
        expect(verdict.warning, contains('stopped presenting'));
      },
    );

    test(
      'an identity nobody in the group knows is surfaced under Observe',
      () async {
        policy.seed(CertificateEnforcement.observe);
        verdictIs(CertificateVerdict.missing);

        final verdict = await check(
          knownIdentities: {'user_me', 'user_friend'},
        );

        expect(
          verdict.action,
          LeafAction.allow,
          reason: 'Observe still must not remove anything',
        );
        expect(
          verdict.warning,
          contains('nobody here added'),
          reason:
              'an unknown credential identity turning up in a group is the '
              'external-commit injection signature, and it has to reach the '
              'user at every phase',
        );
        expect(service.unknownIdentitiesSeen, contains('user_peer'));
      },
    );

    test(
      'a known member with no certificate stays silent under Observe',
      () async {
        policy.seed(CertificateEnforcement.observe);
        verdictIs(CertificateVerdict.missing);

        final verdict = await check(knownIdentities: {'user_me', 'user_peer'});

        expect(verdict.action, LeafAction.allow);
        expect(
          verdict.warning,
          isNull,
          reason:
              'no device in the field has a certificate; warning about all '
              'of them is how a rollout gets switched off',
        );
      },
    );
  });

  // The comparison itself, one layer down, with the engine mocked so the
  // question is only "what does this service check before it asks the engine".
  group('AccountIdentityService.verify', () {
    late _MockEngine engine;
    late _MockSecureStorage storage;
    late _MockMasterKeyApi api;
    late AccountIdentityService identityService;

    const pinnedKey = 'cGlubmVk';

    DeviceCertificate certificateFor({
      String deviceId = 'device-peer',
      String signatureKey = 'c2ln',
    }) => DeviceCertificate(
      deviceId: deviceId,
      deviceSignatureKey: signatureKey,
      issuedAt: DateTime.utc(2026),
      expiresAt: DateTime.utc(2099),
      certificate: 'YSBnZW51aW5lIHNpZ25hdHVyZQ==',
    );

    setUp(() {
      engine = _MockEngine();
      storage = _MockSecureStorage();
      api = _MockMasterKeyApi();
      identityService = AccountIdentityService(
        api: api,
        masterKeys: _MockMasterKeys(),
        secureStorage: storage,
        engine: engine,
      );

      when(
        () => storage.readPinnedIdentityKey(any()),
      ).thenAnswer((_) async => pinnedKey);
      when(
        () => engine.verifyDeviceCertificate(
          accountIdentityPublicKeyB64: any(
            named: 'accountIdentityPublicKeyB64',
          ),
          userId: any(named: 'userId'),
          deviceId: any(named: 'deviceId'),
          deviceSignatureKeyB64: any(named: 'deviceSignatureKeyB64'),
          issuedAt: any(named: 'issuedAt'),
          expiresAt: any(named: 'expiresAt'),
          certificateB64: any(named: 'certificateB64'),
        ),
      ).thenAnswer((_) async => true);
    });

    test(
      'refuses a genuine certificate replayed against another leaf',
      () async {
        final verdict = await identityService.verify(
          ownerUserId: 'user_peer',
          certificate: certificateFor(deviceId: 'device-elsewhere'),
          leafDeviceId: 'device-injected',
          leafSignatureKey: 'c2ln',
        );

        expect(verdict, CertificateVerdict.wrongLeaf);
        verifyNever(
          () => engine.verifyDeviceCertificate(
            accountIdentityPublicKeyB64: any(
              named: 'accountIdentityPublicKeyB64',
            ),
            userId: any(named: 'userId'),
            deviceId: any(named: 'deviceId'),
            deviceSignatureKeyB64: any(named: 'deviceSignatureKeyB64'),
            issuedAt: any(named: 'issuedAt'),
            expiresAt: any(named: 'expiresAt'),
            certificateB64: any(named: 'certificateB64'),
          ),
        );
      },
    );

    test('refuses one whose signature key is not the leaf\'s', () async {
      final verdict = await identityService.verify(
        ownerUserId: 'user_peer',
        certificate: certificateFor(signatureKey: 'b3RoZXI='),
        leafDeviceId: 'device-peer',
        leafSignatureKey: 'c2ln',
      );

      expect(verdict, CertificateVerdict.wrongLeaf);
    });

    test(
      'accepts one that does bind, and verifies the leaf\'s values',
      () async {
        final verdict = await identityService.verify(
          ownerUserId: 'user_peer',
          certificate: certificateFor(),
          leafDeviceId: 'device-peer',
          leafSignatureKey: 'c2ln',
        );

        expect(verdict, CertificateVerdict.valid);
        verify(
          () => engine.verifyDeviceCertificate(
            accountIdentityPublicKeyB64: pinnedKey,
            userId: 'user_peer',
            deviceId: 'device-peer',
            deviceSignatureKeyB64: 'c2ln',
            issuedAt: any(named: 'issuedAt'),
            expiresAt: any(named: 'expiresAt'),
            certificateB64: any(named: 'certificateB64'),
          ),
        ).called(1);
      },
    );

    test('the same key encoded differently is the same key', () async {
      // `c2ln` and `c2ln=` decode identically. A comparison that failed on
      // padding is a comparison somebody relaxes the first time it misfires.
      final verdict = await identityService.verify(
        ownerUserId: 'user_peer',
        certificate: certificateFor(signatureKey: 'c2ln'),
        leafDeviceId: 'device-peer',
        leafSignatureKey: 'c2ln',
      );

      expect(verdict, CertificateVerdict.valid);
    });
  });
}
