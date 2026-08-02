import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mls/venta_mls.dart';
import 'package:venta_mobile/core/crypto/master_key_service.dart';
import 'package:venta_mobile/core/device/device_id_service.dart';
import 'package:venta_mobile/core/mls/device_admission_service.dart';
import 'package:venta_mobile/core/mls/mls_join_request_service.dart';
import 'package:venta_mobile/core/mls/mls_service.dart';
import 'package:venta_mobile/core/mls/protection_level_service.dart';
import 'package:venta_mobile/features/mls/data/mls_api.dart';
import 'package:venta_mobile/features/mls/data/models/mls_dtos.dart';

/// What these cover: contract §G's device admission, and specifically the line
/// between "automatic" and "automatic because the server said so".
///
/// The naive version of auto-approval - the server says a device belongs to you,
/// so an existing device adds it - hands the server exactly the power MLS exists
/// to remove. What happens instead is that the joining device proves possession
/// of the **account master key**, which the server holds only in wrapped form,
/// and an existing device verifies that proof locally. A server that adds a
/// device to your account still cannot get it into any group.
///
/// The headline case is the one at the bottom of §G.6: a forged proof - one the
/// server produced without the master key - is rejected at **both** protection
/// levels. If that ever regresses, `TrustedSignIn` silently becomes "trust the
/// server", which is the thing it was carefully built not to be.

class _MockApi extends Mock implements MlsApi {}

class _MockMls extends Mock implements MlsService {}

class _MockJoinRequests extends Mock implements MlsJoinRequestService {}

class _MockMasterKeys extends Mock implements MasterKeyService {}

class _MockProtectionLevels extends Mock implements ProtectionLevelService {}

class _MockDeviceId extends Mock implements DeviceIdService {}

class _MockEngine extends Mock implements VentaMls {}

const _context = 'conv_1';
const _ownDevice = 'device-mine';
const _joiningDevice = 'device-new';
const _fingerprint = 'A1B2C-D3E4F-56789-0ABCD';
const _keyPackage = 'a2V5cGFja2FnZQ==';

MlsJoinRequestDto _request() => const MlsJoinRequestDto(
  id: 'mljr_1',
  contextId: _context,
  conversationId: _context,
  generation: 1,
  requesterUserId: 'user_me',
  requesterDeviceId: _joiningDevice,
  keyPackageHash: 'hash',
  signatureKeyFingerprint: _fingerprint,
  state: MlsJoinRequestState.pending,
  requiredApprovals: 1,
);

MlsAdmissionChallengeDto _challenge({DateTime? expiresAt}) =>
    MlsAdmissionChallengeDto(
      id: 'chal_1',
      requestId: 'mljr_1',
      challenge: 'Y2hhbGxlbmdl',
      issuedByDeviceId: _ownDevice,
      expiresAt: expiresAt ?? DateTime.now().toUtc().add(const Duration(minutes: 15)),
    );

void main() {
  setUpAll(() => registerFallbackValue(_request()));

  late _MockApi api;
  late _MockMls mls;
  late _MockJoinRequests joinRequests;
  late _MockMasterKeys masterKeys;
  late _MockProtectionLevels protectionLevels;
  late _MockDeviceId deviceIds;
  late _MockEngine engine;
  late DeviceAdmissionService service;

  setUp(() {
    api = _MockApi();
    mls = _MockMls();
    joinRequests = _MockJoinRequests();
    masterKeys = _MockMasterKeys();
    protectionLevels = _MockProtectionLevels();
    deviceIds = _MockDeviceId();
    engine = _MockEngine();
    service = DeviceAdmissionService(
      api: api,
      mls: mls,
      joinRequests: joinRequests,
      masterKeys: masterKeys,
      protectionLevels: protectionLevels,
      deviceIdService: deviceIds,
      engine: engine,
    );

    when(() => deviceIds.deviceId).thenReturn(_ownDevice);
    when(() => deviceIds.deviceIdOrNull).thenReturn(_ownDevice);
    when(
      () => masterKeys.peek(
        userId: any(named: 'userId'),
        deviceId: any(named: 'deviceId'),
      ),
    ).thenAnswer((_) async => 'bWFzdGVyLWtleQ==');
    when(
      () => protectionLevels.effectiveLevel,
    ).thenReturn(ProtectionLevel.trustedSignIn);
    when(
      () => api.fetchChallenge(
        contextId: any(named: 'contextId'),
        isChannel: any(named: 'isChannel'),
        requestId: any(named: 'requestId'),
      ),
    ).thenAnswer((_) async => _challenge());
    when(
      () => api.fetchProof(
        contextId: any(named: 'contextId'),
        isChannel: any(named: 'isChannel'),
        requestId: any(named: 'requestId'),
      ),
    ).thenAnswer(
      (_) async => const MlsAdmissionProofDto(
        challengeId: 'chal_1',
        requestId: 'mljr_1',
        proof: 'cHJvb2Y=',
      ),
    );
    when(
      () => joinRequests.admit(
        contextId: any(named: 'contextId'),
        request: any(named: 'request'),
        keyPackage: any(named: 'keyPackage'),
        isChannel: any(named: 'isChannel'),
      ),
    ).thenAnswer((_) async => true);
  });

  void proofVerifiesAs(bool valid) {
    when(
      () => engine.verifyAdmissionProof(
        masterKeyB64: any(named: 'masterKeyB64'),
        challengeB64: any(named: 'challengeB64'),
        deviceId: any(named: 'deviceId'),
        signatureKeyFingerprint: any(named: 'signatureKeyFingerprint'),
        proofB64: any(named: 'proofB64'),
      ),
    ).thenAnswer((_) async => valid);
  }

  Future<AdmissionOutcome> attempt() => service.tryAdmit(
    contextId: _context,
    isChannel: false,
    request: _request(),
    userId: 'user_me',
    keyPackage: _keyPackage,
  );

  group('a forged proof', () {
    test('is rejected under TrustedSignIn', () async {
      // The server can relay a challenge and a proof, but it holds no master key
      // and nothing derived from one, so whatever it puts in that field cannot
      // verify. This is what stops "automatic" from meaning "the server decides".
      proofVerifiesAs(false);

      expect(await attempt(), AdmissionOutcome.rejected);
      verifyNever(
        () => joinRequests.admit(
          contextId: any(named: 'contextId'),
          request: any(named: 'request'),
          keyPackage: any(named: 'keyPackage'),
          isChannel: any(named: 'isChannel'),
        ),
      );
    });

    test('is rejected under VerifiedDevices too', () async {
      // Not "rejected because a human has not approved yet" - rejected outright.
      // A valid proof is necessary at both levels; the strict tier only adds a
      // requirement on top of it.
      when(
        () => protectionLevels.effectiveLevel,
      ).thenReturn(ProtectionLevel.verifiedDevices);
      proofVerifiesAs(false);

      expect(await attempt(), AdmissionOutcome.rejected);
    });
  });

  group('a valid proof', () {
    setUp(() => proofVerifiesAs(true));

    test('auto-admits under TrustedSignIn', () async {
      expect(await attempt(), AdmissionOutcome.admitted);
      verify(
        () => joinRequests.admit(
          contextId: _context,
          request: any(named: 'request'),
          keyPackage: _keyPackage,
          isChannel: false,
        ),
      ).called(1);
    });

    test('does not auto-admit under VerifiedDevices', () async {
      when(
        () => protectionLevels.effectiveLevel,
      ).thenReturn(ProtectionLevel.verifiedDevices);

      expect(await attempt(), AdmissionOutcome.awaitingApproval);
      verifyNever(
        () => joinRequests.admit(
          contextId: any(named: 'contextId'),
          request: any(named: 'request'),
          keyPackage: any(named: 'keyPackage'),
          isChannel: any(named: 'isChannel'),
        ),
      );
    });

    test('is announced, because silent admission is not silent notification', () async {
      // §G.2, item 1. An admission nobody is told about is an admission nobody
      // can dispute, so the fingerprint goes on record for comparison exactly as
      // it would for a manual approval.
      await attempt();

      final admitted = service.recentlyAdmitted.value.single;
      expect(admitted.deviceId, _joiningDevice);
      expect(admitted.fingerprint, _fingerprint);
      expect(admitted.contextId, _context);
    });

    test('falls back to manual after one auto-admission in 24h', () async {
      // §G.2, item 3. A burst of admissions is the signature of a compromise, so
      // the second one is made expensive - and asked about, rather than failed,
      // so nobody is locked out by it.
      expect(await attempt(), AdmissionOutcome.admitted);
      expect(await attempt(), AdmissionOutcome.awaitingApproval);
      verify(
        () => joinRequests.admit(
          contextId: any(named: 'contextId'),
          request: any(named: 'request'),
          keyPackage: any(named: 'keyPackage'),
          isChannel: any(named: 'isChannel'),
        ),
      ).called(1);
    });
  });

  group('replay and expiry', () {
    setUp(() => proofVerifiesAs(true));

    test('an expired challenge admits nothing', () async {
      // §G.2, item 5: valid for 15 minutes from issue. Checked here as well as
      // server-side, because a client that accepts an expired proof can be
      // replayed against regardless of what the server does.
      when(
        () => api.fetchChallenge(
          contextId: any(named: 'contextId'),
          isChannel: any(named: 'isChannel'),
          requestId: any(named: 'requestId'),
        ),
      ).thenAnswer(
        (_) async => _challenge(
          expiresAt: DateTime.now().toUtc().subtract(const Duration(minutes: 1)),
        ),
      );

      expect(await attempt(), AdmissionOutcome.awaitingProof);
    });

    test('a proof for a different challenge is rejected', () async {
      // Splicing an old answer onto a new question is exactly what a relaying
      // server is positioned to try.
      when(
        () => api.fetchProof(
          contextId: any(named: 'contextId'),
          isChannel: any(named: 'isChannel'),
          requestId: any(named: 'requestId'),
        ),
      ).thenAnswer(
        (_) async => const MlsAdmissionProofDto(
          challengeId: 'chal_stale',
          requestId: 'mljr_1',
          proof: 'cHJvb2Y=',
        ),
      );

      expect(await attempt(), AdmissionOutcome.rejected);
    });

    test('no proof yet is not a rejection', () async {
      when(
        () => api.fetchProof(
          contextId: any(named: 'contextId'),
          isChannel: any(named: 'isChannel'),
          requestId: any(named: 'requestId'),
        ),
      ).thenAnswer((_) async => null);

      expect(await attempt(), AdmissionOutcome.awaitingProof);
    });
  });

  test('a request with no key package admits nothing, and says so', () async {
    // The bridge used to pass `''` here, because the DTO had no field to carry
    // the bytes. That reached `inspectKeyPackage`, which cannot parse an empty
    // string, so a perfectly good proof failed four layers away with an error
    // about key package deserialization. Reported as its own outcome instead:
    // nothing is wrong with the proof, there is simply nothing to commit.
    proofVerifiesAs(true);

    final outcome = await service.tryAdmit(
      contextId: _context,
      isChannel: false,
      request: _request(),
      userId: 'user_me',
      keyPackage: null,
    );

    expect(outcome, AdmissionOutcome.keyPackageMissing);
    verifyNever(
      () => joinRequests.admit(
        contextId: any(named: 'contextId'),
        request: any(named: 'request'),
        keyPackage: any(named: 'keyPackage'),
        isChannel: any(named: 'isChannel'),
      ),
    );
    // Not even a round trip: there is no proof worth fetching for a call that
    // could not act on it.
    verifyNever(
      () => api.fetchChallenge(
        contextId: any(named: 'contextId'),
        isChannel: any(named: 'isChannel'),
        requestId: any(named: 'requestId'),
      ),
    );
  });

  test('a device with no master key defers rather than guessing', () async {
    // It can verify nothing, so it must not decide anything. Another device of
    // the account handles it, or a human does.
    when(
      () => masterKeys.peek(
        userId: any(named: 'userId'),
        deviceId: any(named: 'deviceId'),
      ),
    ).thenAnswer((_) async => null);

    expect(await attempt(), AdmissionOutcome.cannotVerify);
  });

  group('the joining side', () {
    test('binds its proof to this device and this signing key', () async {
      // A proof lifted off the wire must not admit a *different* device, so the
      // device id and the fingerprint go into the MAC alongside the challenge.
      when(
        () => engine.signAdmissionProof(
          masterKeyB64: any(named: 'masterKeyB64'),
          challengeB64: any(named: 'challengeB64'),
          deviceId: any(named: 'deviceId'),
          signatureKeyFingerprint: any(named: 'signatureKeyFingerprint'),
        ),
      ).thenAnswer((_) async => 'cHJvb2Y=');
      when(
        () => api.submitProof(
          contextId: any(named: 'contextId'),
          isChannel: any(named: 'isChannel'),
          requestId: any(named: 'requestId'),
          challengeId: any(named: 'challengeId'),
          proof: any(named: 'proof'),
        ),
      ).thenAnswer((_) async {});

      final answered = await service.answerChallenge(
        contextId: _context,
        isChannel: false,
        requestId: 'mljr_1',
        userId: 'user_me',
        signatureKeyFingerprint: _fingerprint,
      );

      expect(answered, isTrue);
      verify(
        () => engine.signAdmissionProof(
          masterKeyB64: 'bWFzdGVyLWtleQ==',
          challengeB64: 'Y2hhbGxlbmdl',
          deviceId: _ownDevice,
          signatureKeyFingerprint: _fingerprint,
        ),
      ).called(1);
    });

    test('cannot answer without the master key', () async {
      when(
        () => masterKeys.peek(
          userId: any(named: 'userId'),
          deviceId: any(named: 'deviceId'),
        ),
      ).thenAnswer((_) async => null);

      expect(
        await service.answerChallenge(
          contextId: _context,
          isChannel: false,
          requestId: 'mljr_1',
          userId: 'user_me',
          signatureKeyFingerprint: _fingerprint,
        ),
        isFalse,
      );
    });
  });
}
