import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mls/venta_mls.dart';
import 'package:venta_mobile/core/device/device_id_service.dart';
import 'package:venta_mobile/core/mls/device_admission_service.dart';
import 'package:venta_mobile/core/mls/mls_join_request_service.dart';
import 'package:venta_mobile/core/mls/mls_realtime_bridge.dart';
import 'package:venta_mobile/core/mls/mls_service.dart';
import 'package:venta_mobile/core/mls/mls_store.dart';
import 'package:venta_mobile/core/mls/mls_sync_service.dart';
import 'package:venta_mobile/core/realtime/realtime_event.dart';
import 'package:venta_mobile/core/realtime/realtime_service.dart';
import 'package:venta_mobile/features/auth/data/auth_repository.dart';
import 'package:venta_mobile/features/mls/data/mls_api.dart';
import 'package:venta_mobile/features/mls/data/models/mls_dtos.dart';

import 'fake_state_cipher.dart';

/// What these cover: the three reasons a device that asked to join an encrypted
/// DM was never let in, all of which were live at the same time and each of
/// which alone was sufficient to strand it.
///
/// 1. **The key package never reached the admitting device.** `MlsJoinRequestDto`
///    carried `keyPackageHash` and not `keyPackage`, so the bridge handed
///    `inspectKeyPackage` an empty string. The §G ceremony could complete
///    perfectly and still fail at the last step, on a field.
/// 2. **Nobody ever answered the challenge.** The push goes to the requester's
///    own account as well (§L.3), and both devices ran the *admitting* branch -
///    so the joining device challenged its own request, which the server
///    refuses, and never signed anything. The verifier sat on `awaitingProof`
///    for the full 14-day life of the request.
/// 3. **Nothing swept at launch.** `requestAccessWhereMissing` had no caller, so
///    a handset locked out of a conversation never asked at all unless its owner
///    happened to open that conversation and read a banner.

class _MockApi extends Mock implements MlsApi {}

class _MockMls extends Mock implements MlsService {}

class _MockSync extends Mock implements MlsSyncService {}

class _MockAdmission extends Mock implements DeviceAdmissionService {}

class _MockAuth extends Mock implements AuthRepository {}

class _MockDeviceIds extends Mock implements DeviceIdService {}

class _MockRealtime extends Mock implements RealtimeService {}

const _context = 'conv_3HMTDT0HIZHFYC8OWHIHUVMIIRR';
const _userId = 'user_3GlfdMDyQ7OrfrMmGtwt9BzwNTJ';
const _thisDevice = 'device-this';
const _otherDevice = '0d6a8285-c128-4863-9d3a-19eabce5911e';
const _fingerprint = '517F4-D75A0-AD0A2-6BBCF';
const _keyPackage = 'a2V5LXBhY2thZ2UtYnl0ZXM=';

MlsJoinRequestDto _request({
  String requesterDeviceId = _otherDevice,
  String requesterUserId = _userId,
  String? keyPackage = _keyPackage,
}) => MlsJoinRequestDto(
  id: 'mljr_3HMTLECQ5LI0YOSXPWBYILJKER9',
  contextId: _context,
  conversationId: _context,
  generation: 1,
  requesterUserId: requesterUserId,
  requesterDeviceId: requesterDeviceId,
  keyPackageHash: 'hash',
  keyPackage: keyPackage,
  signatureKeyFingerprint: _fingerprint,
  state: MlsJoinRequestState.pending,
  requiredApprovals: 1,
);

RealtimeEvent _push({String requesterUserId = _userId}) =>
    RealtimeEvent('conversation.MlsJoinRequest', [
      {
        'contextId': _context,
        'conversationId': _context,
        'requestId': 'mljr_3HMTLECQ5LI0YOSXPWBYILJKER9',
        'requesterUserId': requesterUserId,
        // Deliberately absent, exactly as the wire has it for the field the
        // bridge must not branch on: the server does send it, but the bytes it
        // does *not* send - the key package - force the fetch anyway, and one
        // authoritative read beats two sources that can disagree.
        'generation': 1,
        'signatureKeyFingerprint': _fingerprint,
        'requiresManualApproval': false,
      },
    ]);

void main() {
  setUpAll(() => registerFallbackValue(_request()));

  group('the DTO', () {
    test('carries the key package the server returns for our own request', () {
      // `GET .../mls/join-requests` includes it when the request belongs to the
      // calling account (Echo `MlsJoinRequestService.cs:217`). With no field to
      // decode into, the only bytes that can admit an own device were dropped on
      // the floor at parse time and the ceremony had no way to finish.
      final parsed = MlsJoinRequestDto.fromJson(const {
        'id': 'mljr_1',
        'contextId': _context,
        'conversationId': _context,
        'generation': 1,
        'requesterUserId': _userId,
        'requesterDeviceId': _otherDevice,
        'keyPackageHash': 'hash',
        'keyPackage': _keyPackage,
        'signatureKeyFingerprint': _fingerprint,
        'state': 'Pending',
      });

      expect(parsed.keyPackage, _keyPackage);
    });

    test('a peer\'s request simply has none, which is not a failure', () {
      // Withheld by design - a peer has no use for the bytes until the threshold
      // is met. Null has to parse cleanly, or every peer request in the review
      // queue throws.
      final parsed = MlsJoinRequestDto.fromJson(const {
        'id': 'mljr_2',
        'contextId': _context,
        'generation': 1,
        'requesterUserId': 'user_someone_else',
        'requesterDeviceId': 'device-theirs',
        'keyPackageHash': 'hash',
        'signatureKeyFingerprint': _fingerprint,
        'state': 'Pending',
      });

      expect(parsed.keyPackage, isNull);
    });
  });

  group('the realtime bridge, on a join request from our own account', () {
    late _MockApi api;
    late _MockMls mls;
    late _MockAdmission admission;
    late _MockAuth auth;
    late _MockDeviceIds deviceIds;
    late StreamController<RealtimeEvent> events;
    late MlsRealtimeBridge bridge;

    setUp(() {
      api = _MockApi();
      mls = _MockMls();
      admission = _MockAdmission();
      auth = _MockAuth();
      deviceIds = _MockDeviceIds();
      events = StreamController<RealtimeEvent>.broadcast();

      final realtime = _MockRealtime();
      when(() => realtime.events).thenAnswer((_) => events.stream);
      when(() => auth.currentUserId).thenReturn(_userId);
      when(() => mls.isUnlocked).thenReturn(true);
      when(() => mls.deviceIdService).thenReturn(deviceIds);
      when(() => deviceIds.deviceIdOrNull).thenReturn(_thisDevice);
      when(
        () => admission.challenge(
          contextId: any(named: 'contextId'),
          isChannel: any(named: 'isChannel'),
          request: any(named: 'request'),
          userId: any(named: 'userId'),
        ),
      ).thenAnswer((_) async => null);
      when(
        () => admission.tryAdmit(
          contextId: any(named: 'contextId'),
          isChannel: any(named: 'isChannel'),
          request: any(named: 'request'),
          userId: any(named: 'userId'),
          keyPackage: any(named: 'keyPackage'),
        ),
      ).thenAnswer((_) async => AdmissionOutcome.awaitingProof);
      when(
        () => admission.answerChallenge(
          contextId: any(named: 'contextId'),
          isChannel: any(named: 'isChannel'),
          requestId: any(named: 'requestId'),
          userId: any(named: 'userId'),
          signatureKeyFingerprint: any(named: 'signatureKeyFingerprint'),
        ),
      ).thenAnswer((_) async => true);

      bridge = MlsRealtimeBridge(
        realtimeService: realtime,
        mls: mls,
        sync: _MockSync(),
        api: api,
        admission: admission,
        authRepository: auth,
      );
      bridge.start();
    });

    tearDown(() async {
      await bridge.stop();
      await events.close();
    });

    void serverReturns(MlsJoinRequestDto request) {
      when(
        () => api.listJoinRequests(
          contextId: any(named: 'contextId'),
          isChannel: any(named: 'isChannel'),
        ),
      ).thenAnswer((_) async => [request]);
    }

    /// The handler runs detached from the stream, so let its futures settle.
    Future<void> settle() async {
      for (var i = 0; i < 8; i++) {
        await Future<void>.delayed(Duration.zero);
      }
    }

    test('answers the challenge when the asking device is this one', () async {
      // The same push reaches both devices. The requesting one must sign, not
      // challenge: the server refuses a device challenging its own request, so
      // the old unconditional admitting branch 400'd here and then produced no
      // proof for the device that was waiting on one.
      serverReturns(_request(requesterDeviceId: _thisDevice));

      events.add(_push());
      await settle();

      verify(
        () => admission.answerChallenge(
          contextId: _context,
          isChannel: false,
          requestId: 'mljr_3HMTLECQ5LI0YOSXPWBYILJKER9',
          userId: _userId,
          signatureKeyFingerprint: _fingerprint,
        ),
      ).called(1);
      verifyNever(
        () => admission.challenge(
          contextId: any(named: 'contextId'),
          isChannel: any(named: 'isChannel'),
          request: any(named: 'request'),
          userId: any(named: 'userId'),
        ),
      );
    });

    test('challenges and admits when it is another of our devices', () async {
      serverReturns(_request());

      events.add(_push());
      await settle();

      verify(
        () => admission.challenge(
          contextId: _context,
          isChannel: false,
          request: any(named: 'request'),
          userId: _userId,
        ),
      ).called(1);
      verifyNever(
        () => admission.answerChallenge(
          contextId: any(named: 'contextId'),
          isChannel: any(named: 'isChannel'),
          requestId: any(named: 'requestId'),
          userId: any(named: 'userId'),
          signatureKeyFingerprint: any(named: 'signatureKeyFingerprint'),
        ),
      );
    });

    test('hands the admitting side the real key package', () async {
      // The whole point of the DTO field. It used to pass '', which reaches
      // `inspectKeyPackage` and cannot parse, so a verified proof still admitted
      // nobody.
      serverReturns(_request());

      events.add(_push());
      await settle();

      final captured = verify(
        () => admission.tryAdmit(
          contextId: _context,
          isChannel: false,
          request: any(named: 'request'),
          userId: _userId,
          keyPackage: captureAny(named: 'keyPackage'),
        ),
      ).captured.single;

      expect(captured, _keyPackage);
    });

    test('leaves a peer\'s request to the review queue', () async {
      // §G.4: our protection level governs our devices and nobody else's. A
      // peer cannot verify a master-key HMAC and must never be asked to.
      serverReturns(_request(requesterUserId: 'user_someone_else'));

      events.add(_push(requesterUserId: 'user_someone_else'));
      await settle();

      verifyNever(
        () => api.listJoinRequests(
          contextId: any(named: 'contextId'),
          isChannel: any(named: 'isChannel'),
        ),
      );
    });
  });

  /// Contract §E9, and the regression the sweep would otherwise have shipped.
  ///
  /// Before this work nothing on mobile listened for
  /// `conversation.MlsDeviceRemoved` and nothing swept, so a deliberate removal
  /// was simply inert here. With a launch sweep and a conversation-level review
  /// prompt both live, a removed device would ask again on every launch and the
  /// person who performed the removal would be prompted afresh every time -
  /// wearing down by repetition a decision that was made once, which is exactly
  /// what §E9 exists to prevent.
  group('a device removal', () {
    late _MockMls mls;
    late _MockSync sync;
    late _MockDeviceIds deviceIds;
    late StreamController<RealtimeEvent> events;
    late MlsRealtimeBridge bridge;

    setUp(() {
      mls = _MockMls();
      sync = _MockSync();
      deviceIds = _MockDeviceIds();
      events = StreamController<RealtimeEvent>.broadcast();

      final auth = _MockAuth();
      final realtime = _MockRealtime();
      when(() => realtime.events).thenAnswer((_) => events.stream);
      when(() => auth.currentUserId).thenReturn(_userId);
      when(() => mls.isUnlocked).thenReturn(true);
      when(() => mls.deviceIdService).thenReturn(deviceIds);
      when(() => deviceIds.deviceIdOrNull).thenReturn(_thisDevice);
      when(() => mls.recordRemovedHere(any())).thenAnswer((_) async {});
      when(() => sync.syncContext(any(), any())).thenAnswer((_) async {});

      bridge = MlsRealtimeBridge(
        realtimeService: realtime,
        mls: mls,
        sync: sync,
        api: _MockApi(),
        admission: _MockAdmission(),
        authRepository: auth,
      );
      bridge.start();
    });

    tearDown(() async {
      await bridge.stop();
      await events.close();
    });

    /// The shape `DeviceRemovedHandler.cs:132` publishes - one push per affected
    /// context, naming the device that was removed as `deviceId` rather than the
    /// `senderDeviceId` the other MLS pushes carry.
    RealtimeEvent removal({
      String userId = _userId,
      String deviceId = _thisDevice,
      String contextId = _context,
    }) => RealtimeEvent('conversation.MlsDeviceRemoved', [
      {
        'contextId': contextId,
        'conversationId': contextId,
        'channelId': null,
        'generation': 1,
        'epoch': 7,
        'userId': userId,
        'deviceId': deviceId,
      },
    ]);

    Future<void> settle() async {
      for (var i = 0; i < 8; i++) {
        await Future<void>.delayed(Duration.zero);
      }
    }

    test('is recorded when it names this device', () async {
      events.add(removal());
      await settle();

      verify(() => mls.recordRemovedHere(_context)).called(1);
      // This device is out. Fetching commits it holds no keys for buys a round
      // trip and a failure count and nothing else.
      verifyNever(() => sync.syncContext(any(), any()));
    });

    test('another device of ours is caught up, not recorded', () async {
      // Our laptop being removed says nothing about whether this handset should
      // ask - and somebody has to mint the Remove commit, which only a member's
      // client can do and nothing on this one ever did.
      events.add(removal(deviceId: _otherDevice));
      await settle();

      verifyNever(() => mls.recordRemovedHere(any()));
      verify(() => sync.syncContext(_context, false)).called(1);
    });

    test('a peer\'s removal is caught up, not recorded', () async {
      events.add(removal(userId: 'user_peer', deviceId: 'device-theirs'));
      await settle();

      verifyNever(() => mls.recordRemovedHere(any()));
      verify(() => sync.syncContext(_context, false)).called(1);
    });

    test('a matching device id under another account records nothing', () async {
      // `ClientDeviceId` is chosen by the client and unique only per account, so
      // a co-member can register a device under an id equal to ours. Matching on
      // the bare id would hand them a way to suppress our sweep for a
      // conversation nobody removed us from. Echo scopes every query in this
      // handler by user for the same reason; this is the client half.
      events.add(removal(userId: 'user_impostor', deviceId: _thisDevice));
      await settle();

      verifyNever(() => mls.recordRemovedHere(any()));
    });

    test('is recorded even while this device is locked', () async {
      // Removal revokes the device's sessions and its keys may already be gone,
      // so the device a removal push is about is the one most likely to be
      // locked. Dropping the record for that reason loses it in the only case it
      // exists for.
      when(() => mls.isUnlocked).thenReturn(false);

      events.add(removal());
      await settle();

      verify(() => mls.recordRemovedHere(_context)).called(1);
    });
  });

  group('the launch sweep', () {
    late _MockApi api;
    late _MockMls mls;
    late _MockDeviceIds deviceIds;
    late MlsJoinRequestService service;

    setUp(() {
      api = _MockApi();
      mls = _MockMls();
      deviceIds = _MockDeviceIds();
      service = MlsJoinRequestService(
        mls: mls,
        sync: _MockSync(),
        api: api,
        deviceIdService: deviceIds,
      );

      when(() => mls.isUnlocked).thenReturn(true);
      when(() => mls.activeGroupId(any())).thenReturn(null);
      when(() => mls.hasEverHeldGroup(any())).thenReturn(false);
      when(() => mls.wasRemovedHere(any())).thenReturn(false);
      when(() => deviceIds.deviceId).thenReturn(_thisDevice);
      when(() => mls.generateKeyPackages(1)).thenAnswer(
        (_) async => const [
          KeyPackageResult(keyPackage: _keyPackage, initPrivateKey: 'init'),
        ],
      );
      when(() => mls.inspectKeyPackage(any())).thenAnswer(
        (_) async => const MlsKeyPackageInfo(
          identity: _userId,
          signaturePublicKey: 'pub',
          signatureKeyFingerprint: _fingerprint,
          keyPackageHash: 'hash',
        ),
      );
      when(
        () => api.requestAccess(
          contextId: any(named: 'contextId'),
          isChannel: any(named: 'isChannel'),
          keyPackage: any(named: 'keyPackage'),
          deviceId: any(named: 'deviceId'),
          signatureKeyFingerprint: any(named: 'signatureKeyFingerprint'),
        ),
      ).thenAnswer((invocation) async {
        return _request(
          requesterDeviceId: _thisDevice,
        ).copyWith(contextId: invocation.namedArguments[#contextId] as String);
      });
    });

    MlsAdmissionCandidate candidate(
      String id, {
      bool serverSaysEncrypted = true,
    }) => (
      contextId: id,
      isChannel: false,
      serverSaysEncrypted: serverSaysEncrypted,
    );

    test('costs a healthy device nothing at all', () async {
      // Every filter reads local state, so the common case - in every group it
      // should be in - completes without a single request. The old shape called
      // `getState` per context before it could tell, which put one round trip on
      // every conversation of every launch.
      when(() => mls.activeGroupId(any())).thenReturn('group-id');

      final requested = await service.requestAccessWhereMissing([
        candidate('conv_a'),
        candidate('conv_b'),
      ]);

      expect(requested, isEmpty);
      verifyNever(
        () => api.getState(
          contextId: any(named: 'contextId'),
          isChannel: any(named: 'isChannel'),
        ),
      );
      verifyNever(() => mls.generateKeyPackages(any()));
    });

    test('asks for the contexts it holds no group for', () async {
      final requested = await service.requestAccessWhereMissing([
        candidate('conv_a'),
      ]);

      expect(requested, ['conv_a']);
    });

    test('ignores a context nobody says is encrypted', () async {
      final requested = await service.requestAccessWhereMissing([
        candidate('conv_a', serverSaysEncrypted: false),
      ]);

      expect(requested, isEmpty);
    });

    test('disbelieves the server about a context it has encrypted', () async {
      // The local floor outranks the wire. "This conversation is plaintext" is
      // exactly what a server would say to keep a device it excluded from asking
      // to come back, and the registry is the evidence that contradicts it.
      when(() => mls.hasEverHeldGroup('conv_a')).thenReturn(true);

      final requested = await service.requestAccessWhereMissing([
        candidate('conv_a', serverSaysEncrypted: false),
      ]);

      expect(requested, ['conv_a']);
    });

    test('never re-asks after a deliberate removal', () async {
      // The wear-down. One removal must not become an approval prompt on every
      // launch for the person who performed it.
      when(() => mls.wasRemovedHere('conv_a')).thenReturn(true);

      final requested = await service.requestAccessWhereMissing([
        candidate('conv_a'),
      ]);

      expect(requested, isEmpty);
      verifyNever(() => mls.generateKeyPackages(any()));
    });

    test('the local floor does not override a removal', () async {
      // A removed device *has* held a group here, so the floor is satisfied and
      // would keep it a candidate forever. The removal check has to come first
      // or the suppression is worth nothing on exactly the devices it is for.
      when(() => mls.wasRemovedHere('conv_a')).thenReturn(true);
      when(() => mls.hasEverHeldGroup('conv_a')).thenReturn(true);

      expect(
        await service.requestAccessWhereMissing([candidate('conv_a')]),
        isEmpty,
      );
    });

    test('a removal from one conversation does not silence another', () async {
      when(() => mls.wasRemovedHere('conv_a')).thenReturn(true);

      final requested = await service.requestAccessWhereMissing([
        candidate('conv_a'),
        candidate('conv_b'),
      ]);

      expect(requested, ['conv_b']);
    });

    test('caps one launch rather than firing a burst', () async {
      // A device that just lost its keys is locked out of everything, and an
      // uncapped sweep turns one bad launch into the exact shape the server's
      // rate limits exist to refuse.
      final requested = await service.requestAccessWhereMissing([
        for (var i = 0; i < 25; i++) candidate('conv_$i'),
      ]);

      expect(requested, hasLength(MlsJoinRequestService.maxContextsPerSweep));
    });

    test('one context refusing does not stop the rest', () async {
      when(
        () => api.requestAccess(
          contextId: 'conv_a',
          isChannel: any(named: 'isChannel'),
          keyPackage: any(named: 'keyPackage'),
          deviceId: any(named: 'deviceId'),
          signatureKeyFingerprint: any(named: 'signatureKeyFingerprint'),
        ),
      ).thenThrow(Exception('rate limited'));

      final requested = await service.requestAccessWhereMissing([
        candidate('conv_a'),
        candidate('conv_b'),
      ]);

      expect(requested, ['conv_b']);
    });

    test('a locked session asks for nothing', () async {
      when(() => mls.isUnlocked).thenReturn(false);

      expect(
        await service.requestAccessWhereMissing([candidate('conv_a')]),
        isEmpty,
      );
    });
  });

  group('the local encryption floor', () {
    late Directory root;
    late MlsStore store;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('venta_mls_floor_test');
      store = MlsStore(
        directory: () async => root,
        stateKey: (userId) async => 'key-for-$userId',
        cipher: FakeStateCipher.new,
      );
      await store.init(_userId);
    });

    tearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });

    test('a context never encrypted here is not on the floor', () {
      expect(store.hasEverHeldGroup(_context), isFalse);
    });

    test('survives encryption being switched off', () async {
      // The whole point. `clearActiveGeneration` drops the live pointer and
      // keeps the per-generation mapping, because the messages from that era
      // still need those keys - and that mapping is the evidence that says the
      // server's later "this is plaintext" is not the whole story.
      await store.registerGroup(
        contextId: _context,
        generation: 1,
        mlsGroupId: 'group-1',
      );
      await store.clearActiveGeneration(_context);

      expect(store.activeGroupId(_context), isNull);
      expect(store.hasEverHeldGroup(_context), isTrue);
    });

    test('a removal marker is not a group and not a floor', () async {
      // It shares the registry map, so it must be impossible to mistake for
      // either of the things that live there. Stored as a bool for exactly this
      // reason: `groupCount` counts String values and `hasEverHeldGroup`
      // requires one.
      await store.recordRemovedHere(_context);

      expect(store.wasRemovedHere(_context), isTrue);
      expect(store.hasEverHeldGroup(_context), isFalse);
      expect(store.activeGroupId(_context), isNull);
      expect(store.groupCount, 0);
    });

    test('a removal survives a relaunch', () async {
      // The whole requirement. The sweep it suppresses runs *at launch*, so a
      // signal that reset on restart would suppress precisely nothing.
      await store.recordRemovedHere(_context);

      final reopened = MlsStore(
        directory: () async => root,
        stateKey: (userId) async => 'key-for-$userId',
        cipher: FakeStateCipher.new,
      );
      await reopened.init(_userId);

      expect(reopened.wasRemovedHere(_context), isTrue);
    });

    test('being re-added clears the removal, and only that does', () async {
      // The recovery path. Without it the suppression is permanent and a device
      // that was removed, then legitimately re-added, would never sweep for this
      // context again - so being dropped from a later generation would strand it
      // silently and for good.
      //
      // Unabusable, because getting here means already holding a leaf: every
      // caller reaches `registerGroup` after a Welcome a current member minted,
      // an external commit, or creating the generation. A device that is merely
      // *asking* never arrives, and one that is already in has nothing to ask
      // for - there is no prompt left to wear down.
      await store.recordRemovedHere(_context);

      await store.registerGroup(
        contextId: _context,
        generation: 2,
        mlsGroupId: 'group-2',
      );

      expect(store.wasRemovedHere(_context), isFalse);
    });

    test('encryption being switched off does not clear a removal', () async {
      // `clearActiveGeneration` drops the live pointer without anybody deciding
      // anything about this device, so treating it as re-admission would let a
      // re-key silently undo the removal.
      await store.registerGroup(
        contextId: _context,
        generation: 1,
        mlsGroupId: 'group-1',
      );
      await store.recordRemovedHere(_context);
      await store.clearActiveGeneration(_context);

      expect(store.wasRemovedHere(_context), isTrue);
    });

    test('a removal never travels in a backup', () async {
      // It is a statement about this installation, not about the account's group
      // memberships. Restored onto a new handset it would suppress that device's
      // sweep for a removal it was never the subject of - and going and asking
      // is the restore path's entire job (§D).
      await store.registerGroup(
        contextId: _context,
        generation: 1,
        mlsGroupId: 'group-1',
      );
      await store.recordRemovedHere(_context);

      expect(store.snapshot.keys, contains('$_context#1'));
      expect(store.snapshot.keys, isNot(contains('$_context#removed')));
    });

    test('does not spill between contexts sharing a prefix', () async {
      // Keys are `<contextId>#<generation>`, so a prefix match that omitted the
      // separator would let `conv_1` claim `conv_12`'s history and go asking to
      // rejoin a conversation it has never been in.
      await store.registerGroup(
        contextId: 'conv_12',
        generation: 1,
        mlsGroupId: 'group-12',
      );

      expect(store.hasEverHeldGroup('conv_12'), isTrue);
      expect(store.hasEverHeldGroup('conv_1'), isFalse);
    });
  });
}
