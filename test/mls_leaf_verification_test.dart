import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/crypto/account_identity_service.dart';
import 'package:venta_mobile/core/device/device_api.dart';
import 'package:venta_mobile/core/mls/leaf_verification_service.dart';
import 'package:venta_mobile/core/mls/mls_policy_service.dart';
import 'package:venta_mobile/core/network/api_client.dart';

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
      ),
    ).thenAnswer((_) async => verdict);
  }

  Future<LeafVerdict> check() => service.check(
    ownerUserId: 'user_peer',
    deviceId: 'device-peer',
    deviceSignatureKey: 'c2ln',
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
        reason: 'the count is what the decision to advance the phase is made on',
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
      deviceId: 'device-peer',
      deviceSignatureKey: 'c2ln',
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
}
