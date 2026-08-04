import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mls/venta_mls.dart';
import 'package:venta_mobile/core/device/device_id_service.dart';
import 'package:venta_mobile/core/mls/mls_join_request_service.dart';
import 'package:venta_mobile/core/mls/mls_service.dart';
import 'package:venta_mobile/core/mls/mls_sync_service.dart';
import 'package:venta_mobile/features/mls/data/mls_api.dart';
import 'package:venta_mobile/features/mls/data/models/mls_dtos.dart';

/// What these cover: the verification an approver performs before adding
/// somebody to an encrypted channel.
///
/// The server cannot admit anyone - it holds no group keys - so admission is a
/// request that members review and the threshold-completing approval mints the
/// Welcome. That review is only worth something if the bytes finally added are
/// the bytes that were reviewed. A server that substituted its own key package
/// between approval and add would otherwise have its key silently welcomed into
/// the group, and every message from then on readable by it.
///
/// So the approving client re-derives all three - hash, fingerprint, claimed
/// identity - from what the server handed back, and refuses on any mismatch.
/// These tests exist because that check is easy to quietly drop and impossible
/// to notice missing.

class _MockMls extends Mock implements MlsService {}

class _MockApi extends Mock implements MlsApi {}

class _MockSync extends Mock implements MlsSyncService {}

class _MockDeviceId extends Mock implements DeviceIdService {}

const _channel = 'chan_1';
const _group = 'Z3JvdXA=';
const _device = 'device-req';
const _requester = 'user_requester';
const _keyPackage = 'a2V5cGFja2FnZQ==';
const _hash = 'abc123';
const _fingerprint = 'A1B2C-D3E4F-56789-0ABCD';

MlsJoinRequestDto _request() => const MlsJoinRequestDto(
  id: 'mljr_1',
  contextId: _channel,
  channelId: _channel,
  generation: 1,
  requesterUserId: _requester,
  requesterDeviceId: _device,
  keyPackageHash: _hash,
  signatureKeyFingerprint: _fingerprint,
  state: MlsJoinRequestState.pending,
  requiredApprovals: 2,
  approverUserIds: ['user_other'],
);

MlsKeyPackageInfo _info({
  String identity = _requester,
  String hash = _hash,
  String fingerprint = _fingerprint,
}) => MlsKeyPackageInfo(
  identity: identity,
  signaturePublicKey: 'sig',
  signatureKeyFingerprint: fingerprint,
  keyPackageHash: hash,
);

void main() {
  late _MockMls mls;
  late _MockApi api;
  late _MockSync sync;
  late MlsJoinRequestService service;

  setUp(() {
    mls = _MockMls();
    api = _MockApi();
    sync = _MockSync();
    final deviceIds = _MockDeviceId();
    service = MlsJoinRequestService(
      mls: mls,
      sync: sync,
      api: api,
      deviceIdService: deviceIds,
    );

    when(() => deviceIds.deviceId).thenReturn('device-approver');
    when(() => mls.isUnlocked).thenReturn(true);
    when(() => mls.activeGroupId(_channel)).thenReturn(_group);
    when(
      () => api.approveJoinRequest(
        contextId: any(named: 'contextId'),
        isChannel: any(named: 'isChannel'),
        requestId: any(named: 'requestId'),
      ),
    ).thenAnswer(
      (_) async => const MlsJoinRequestApprovalResultDto(
        requestId: 'mljr_1',
        approvals: 2,
        requiredApprovals: 2,
        thresholdMet: true,
        keyPackage: _keyPackage,
        keyPackageHash: _hash,
        generation: 1,
      ),
    );
    when(
      () => sync.publish(
        contextId: any(named: 'contextId'),
        isChannel: any(named: 'isChannel'),
        produce: any(named: 'produce'),
      ),
    ).thenAnswer((_) async => true);
  });

  group('approving', () {
    test('adds the device once the threshold is met', () async {
      when(
        () => mls.inspectKeyPackage(_keyPackage),
      ).thenAnswer((_) async => _info());

      final admitted = await service.approve(
        contextId: _channel,
        request: _request(),
      );

      expect(admitted, isTrue);
      verify(
        () => sync.publish(
          contextId: _channel,
          isChannel: true,
          produce: any(named: 'produce'),
        ),
      ).called(1);
    });

    test('does not add anything before the threshold is met', () async {
      when(
        () => api.approveJoinRequest(
          contextId: any(named: 'contextId'),
          isChannel: any(named: 'isChannel'),
          requestId: any(named: 'requestId'),
        ),
      ).thenAnswer(
        (_) async => const MlsJoinRequestApprovalResultDto(
          requestId: 'mljr_1',
          approvals: 1,
          requiredApprovals: 2,
          keyPackageHash: _hash,
        ),
      );

      final admitted = await service.approve(
        contextId: _channel,
        request: _request(),
      );

      expect(admitted, isFalse);
      verifyNever(
        () => sync.publish(
          contextId: any(named: 'contextId'),
          isChannel: any(named: 'isChannel'),
          produce: any(named: 'produce'),
        ),
      );
    });

    test(
      'refuses a key package whose bytes differ from the reviewed ones',
      () async {
        // The substitution attack the whole review exists to prevent.
        when(
          () => mls.inspectKeyPackage(_keyPackage),
        ).thenAnswer((_) async => _info(hash: 'a-different-hash'));

        await expectLater(
          service.approve(contextId: _channel, request: _request()),
          throwsA(isA<JoinRequestVerificationException>()),
        );

        verifyNever(
          () => sync.publish(
            contextId: any(named: 'contextId'),
            isChannel: any(named: 'isChannel'),
            produce: any(named: 'produce'),
          ),
        );
      },
    );

    test('refuses a key package under a different identity key', () async {
      when(
        () => mls.inspectKeyPackage(_keyPackage),
      ).thenAnswer((_) async => _info(fingerprint: 'FFFFF-FFFFF'));

      await expectLater(
        service.approve(contextId: _channel, request: _request()),
        throwsA(isA<JoinRequestVerificationException>()),
      );
    });

    test('refuses a key package claiming a different user', () async {
      when(
        () => mls.inspectKeyPackage(_keyPackage),
      ).thenAnswer((_) async => _info(identity: 'user_someone_else'));

      await expectLater(
        service.approve(contextId: _channel, request: _request()),
        throwsA(isA<JoinRequestVerificationException>()),
      );
    });

    test(
      'refuses when the server claims a threshold but sends no bytes',
      () async {
        when(
          () => api.approveJoinRequest(
            contextId: any(named: 'contextId'),
            isChannel: any(named: 'isChannel'),
            requestId: any(named: 'requestId'),
          ),
        ).thenAnswer(
          (_) async => const MlsJoinRequestApprovalResultDto(
            requestId: 'mljr_1',
            approvals: 2,
            requiredApprovals: 2,
            thresholdMet: true,
            keyPackageHash: _hash,
          ),
        );

        await expectLater(
          service.approve(contextId: _channel, request: _request()),
          throwsA(isA<JoinRequestVerificationException>()),
        );
      },
    );
  });

  group('own fingerprint', () {
    test('never mints a key package', () async {
      // Generating one writes ~2.5KB of init key material into the engine's
      // store that nothing will ever consume, permanently - and the store is
      // rewritten in full on every save, so the cost lands on every later
      // encrypt and decrypt. A UI that showed this per rebuild would degrade the
      // device indefinitely. The value is a hash of the signing key we already
      // hold, so there is nothing to mint.
      when(() => mls.ownFingerprint()).thenAnswer((_) async => _fingerprint);

      final fingerprint = await service.ownFingerprint();

      expect(fingerprint, _fingerprint);
      verifyNever(() => mls.generateKeyPackages(any()));
      verifyNever(() => mls.inspectKeyPackage(any()));
    });

    test('is null while the session is locked', () async {
      when(() => mls.ownFingerprint()).thenAnswer((_) async => null);

      expect(await service.ownFingerprint(), isNull);
    });
  });

  group('requesting', () {
    test('submits freshly minted bytes, not one from the pool', () async {
      when(() => mls.generateKeyPackages(1)).thenAnswer(
        (_) async => [
          const KeyPackageResult(
            keyPackage: _keyPackage,
            initPrivateKey: 'init',
          ),
        ],
      );
      when(
        () => mls.inspectKeyPackage(_keyPackage),
      ).thenAnswer((_) async => _info());
      when(
        () => api.requestAccess(
          contextId: any(named: 'contextId'),
          isChannel: any(named: 'isChannel'),
          keyPackage: any(named: 'keyPackage'),
          deviceId: any(named: 'deviceId'),
          signatureKeyFingerprint: any(named: 'signatureKeyFingerprint'),
        ),
      ).thenAnswer((_) async => _request());

      await service.requestAccess(_channel);

      // Minted for this request specifically: reviewers approve exact bytes, and
      // bytes nobody else can hand out cannot be swapped between approval and
      // add.
      verify(() => mls.generateKeyPackages(1)).called(1);
      verify(
        () => api.requestAccess(
          contextId: _channel,
          isChannel: true,
          keyPackage: _keyPackage,
          deviceId: 'device-approver',
          signatureKeyFingerprint: _fingerprint,
        ),
      ).called(1);
    });
  });
}
