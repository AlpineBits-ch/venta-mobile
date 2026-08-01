import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mls/venta_mls.dart';
import 'package:venta_mobile/core/device/device_id_service.dart';
import 'package:venta_mobile/core/mls/mls_service.dart';
import 'package:venta_mobile/core/mls/mls_sync_service.dart';
import 'package:venta_mobile/features/mls/data/mls_api.dart';
import 'package:venta_mobile/features/mls/data/models/mls_dtos.dart';

/// What these cover: the three ordering rules that make MLS survivable, and
/// which are invisible in the type system.
///
/// 1. Commits apply in strict epoch order, fetched from the server. Applying a
///    commit out of order forks a device off the group permanently - there is no
///    recovery, so the client stops rather than guessing.
/// 2. A commit is staged, published, and merged only if the server took it. The
///    server accepts exactly one commit per epoch; merging first means a lost
///    race leaves this device advanced on a commit nobody else has.
/// 3. A Welcome is acknowledged only after its join succeeds. Its init key is
///    single-use, so acking a failed join locks this device out for good.
///
/// Each of those is a silent, permanent data-loss bug when it regresses, which
/// is exactly the kind that needs a test rather than a careful reader.

class _MockMls extends Mock implements MlsService {}

class _MockApi extends Mock implements MlsApi {}

class _MockDeviceId extends Mock implements DeviceIdService {}

const _context = 'conv_1';
const _group = 'Z3JvdXA=';
const _device = 'device-a';

MlsCommitDto _commit(int epoch, {String? bytes}) => MlsCommitDto(
  id: 'mlsc_$epoch',
  contextId: _context,
  conversationId: _context,
  generation: 1,
  epoch: epoch,
  commit: bytes ?? 'commit-$epoch',
  senderUserId: 'user_other',
  senderDeviceId: 'device-b',
);

MlsGroupInfo _groupAt(int epoch) => MlsGroupInfo(
  groupId: _group,
  epoch: epoch,
  ownLeafIndex: 0,
  members: const [],
);

MlsProcessedMessage _appliedCommit(int epoch) => MlsProcessedMessage(
  kind: MlsMessageKind.commit,
  plaintext: null,
  selfRemoved: false,
  addedMembers: const [],
  removedLeafIndices: const [],
  senderIdentity: 'user_other',
  epoch: epoch,
);

void main() {
  late _MockMls mls;
  late _MockApi api;
  late _MockDeviceId deviceIds;
  late MlsSyncService sync;

  setUpAll(() {
    registerFallbackValue(
      const PublishMlsCommitDto(epoch: 0, commit: '', senderDeviceId: ''),
    );
  });

  setUp(() {
    mls = _MockMls();
    api = _MockApi();
    deviceIds = _MockDeviceId();
    sync = MlsSyncService(mls: mls, api: api, deviceIdService: deviceIds);

    when(() => deviceIds.deviceId).thenReturn(_device);
    when(() => deviceIds.deviceIdOrNull).thenReturn(_device);
    when(() => mls.isUnlocked).thenReturn(true);
    when(() => mls.knownGeneration(_context)).thenReturn(1);
    when(() => mls.groupId(_context, 1)).thenReturn(_group);
    when(() => mls.activeGroupId(_context)).thenReturn(_group);
  });

  group('commit catch-up', () {
    test('applies every commit above the local epoch, in order', () async {
      // Local group sits at 5; server holds 6, 7, 8.
      var localEpoch = 5;
      when(() => mls.getGroupInfo(_group))
          .thenAnswer((_) async => _groupAt(localEpoch));
      when(
        () => api.getCommits(
          contextId: _context,
          isChannel: false,
          sinceEpoch: any(named: 'sinceEpoch'),
          generation: 1,
        ),
      ).thenAnswer((invocation) async {
        final since = invocation.namedArguments[#sinceEpoch] as int;
        return [
          for (var e = since + 1; e <= 8; e++) _commit(e),
        ];
      });

      final applied = <String>[];
      when(
        () => mls.processMessage(
          groupIdB64: _group,
          messageB64: any(named: 'messageB64'),
        ),
      ).thenAnswer((invocation) async {
        final body = invocation.namedArguments[#messageB64] as String;
        applied.add(body);
        localEpoch++;
        return _appliedCommit(localEpoch);
      });

      await sync.syncContext(_context, false);

      expect(applied, ['commit-6', 'commit-7', 'commit-8']);
    });

    test('stops at a gap rather than applying a commit out of order', () async {
      // Server's page starts at 8 while we are on 5 - 6 and 7 are missing.
      // Applying 8 anyway would fork this device off the group for good.
      when(() => mls.getGroupInfo(_group)).thenAnswer((_) async => _groupAt(5));
      when(
        () => api.getCommits(
          contextId: any(named: 'contextId'),
          isChannel: any(named: 'isChannel'),
          sinceEpoch: any(named: 'sinceEpoch'),
          generation: any(named: 'generation'),
        ),
      ).thenAnswer((_) async => [_commit(8), _commit(9)]);

      await sync.syncContext(_context, false);

      verifyNever(
        () => mls.processMessage(
          groupIdB64: any(named: 'groupIdB64'),
          messageB64: any(named: 'messageB64'),
        ),
      );
    });

    test('commits a departing member\'s Remove proposal after catch-up', () async {
      // MLS does not let anyone commit their own removal, so a leave publishes a
      // proposal and someone else has to turn it into a commit. Until they do,
      // the group keeps encrypting to a device that has already thrown its keys
      // away.
      //
      // The commit has to happen *outside* the per-context queue: committing
      // publishes, and publishing takes the same queue catch-up is holding.
      // Doing it inline would deadlock.
      when(() => mls.getGroupInfo(_group)).thenAnswer((_) async => _groupAt(5));
      var page = 0;
      when(
        () => api.getCommits(
          contextId: any(named: 'contextId'),
          isChannel: any(named: 'isChannel'),
          sinceEpoch: any(named: 'sinceEpoch'),
          generation: any(named: 'generation'),
        ),
      ).thenAnswer((_) async => page++ == 0 ? [_commit(6)] : const []);
      when(
        () => mls.processMessage(
          groupIdB64: any(named: 'groupIdB64'),
          messageB64: any(named: 'messageB64'),
        ),
      ).thenAnswer(
        (_) async => MlsProcessedMessage(
          kind: MlsMessageKind.proposal,
          plaintext: null,
          selfRemoved: false,
          addedMembers: const [],
          removedLeafIndices: const [],
          senderIdentity: 'user_leaver',
          epoch: null,
        ),
      );
      when(() => mls.commitPendingProposals(_group)).thenAnswer(
        (_) async => const MlsCommitOut(commit: 'c', welcome: null, epoch: 6),
      );
      when(() => mls.exportGroupInfo(_group)).thenAnswer((_) async => 'gi');
      when(() => mls.mergePendingCommit(_group)).thenAnswer((_) async => 6);
      when(
        () => api.publishCommit(
          contextId: any(named: 'contextId'),
          isChannel: any(named: 'isChannel'),
          dto: any(named: 'dto'),
        ),
      ).thenAnswer(
        (_) async => const MlsCommitPublishedDto(
          contextId: _context,
          generation: 1,
          epoch: 6,
        ),
      );

      // Completing at all is half the assertion - an inline commit would hang
      // here forever waiting on the queue this call already holds.
      await sync.syncContext(_context, false).timeout(const Duration(seconds: 5));

      verify(() => mls.commitPendingProposals(_group)).called(1);
    });

    test('a commit that removes us drops the group and reports it', () async {
      when(() => mls.getGroupInfo(_group)).thenAnswer((_) async => _groupAt(5));
      when(
        () => api.getCommits(
          contextId: any(named: 'contextId'),
          isChannel: any(named: 'isChannel'),
          sinceEpoch: any(named: 'sinceEpoch'),
          generation: any(named: 'generation'),
        ),
      ).thenAnswer((_) async => [_commit(6)]);
      when(
        () => mls.processMessage(
          groupIdB64: any(named: 'groupIdB64'),
          messageB64: any(named: 'messageB64'),
        ),
      ).thenAnswer(
        (_) async => MlsProcessedMessage(
          kind: MlsMessageKind.commit,
          plaintext: null,
          selfRemoved: true,
          addedMembers: const [],
          removedLeafIndices: const [0],
          senderIdentity: 'user_other',
          epoch: 6,
        ),
      );
      when(() => mls.clearActiveGeneration(_context)).thenAnswer((_) async {});
      when(() => mls.deleteGroup(_group)).thenAnswer((_) async {});

      final changes = <MlsContextChanged>[];
      final subscription = sync.contextChanged.listen(changes.add);

      await sync.syncContext(_context, false);
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      verify(() => mls.clearActiveGeneration(_context)).called(1);
      verify(() => mls.deleteGroup(_group)).called(1);
      expect(changes.single.selfRemoved, isTrue);
    });
  });

  group('publishing', () {
    setUp(() {
      when(() => mls.exportGroupInfo(_group)).thenAnswer((_) async => 'gi');
      when(() => mls.mergePendingCommit(_group)).thenAnswer((_) async => 7);
      when(() => mls.clearPendingCommit(_group)).thenAnswer((_) async {});
      when(() => mls.getGroupInfo(_group)).thenAnswer((_) async => _groupAt(6));
    });

    test('merges the staged commit once the server accepts it', () async {
      when(
        () => api.publishCommit(
          contextId: _context,
          isChannel: false,
          dto: any(named: 'dto'),
        ),
      ).thenAnswer(
        (_) async => const MlsCommitPublishedDto(
          contextId: _context,
          generation: 1,
          epoch: 7,
        ),
      );

      final published = await sync.publish(
        contextId: _context,
        isChannel: false,
        produce: () async =>
            const StagedCommit(commit: 'staged', epoch: 7),
      );

      expect(published, isTrue);
      verify(() => mls.mergePendingCommit(_group)).called(1);
      verifyNever(() => mls.clearPendingCommit(_group));
    });

    test('discards and retries once when the server rejects the epoch', () async {
      var attempt = 0;
      when(
        () => api.publishCommit(
          contextId: _context,
          isChannel: false,
          dto: any(named: 'dto'),
        ),
      ).thenAnswer((_) async {
        attempt++;
        if (attempt == 1) {
          throw const MlsEpochConflictException(
            MlsEpochConflictDto(
              currentEpoch: 7,
              rejectedEpoch: 7,
              currentGeneration: 1,
              rejectedGeneration: 1,
              reason: 'Another member already committed this epoch.',
            ),
          );
        }
        return const MlsCommitPublishedDto(
          contextId: _context,
          generation: 1,
          epoch: 8,
        );
      });
      when(
        () => api.getCommits(
          contextId: any(named: 'contextId'),
          isChannel: any(named: 'isChannel'),
          sinceEpoch: any(named: 'sinceEpoch'),
          generation: any(named: 'generation'),
        ),
      ).thenAnswer((_) async => const []);

      final published = await sync.publish(
        contextId: _context,
        isChannel: false,
        produce: () async => const StagedCommit(commit: 'staged', epoch: 7),
      );

      expect(published, isTrue, reason: 'the second attempt should have won');
      // The rejected commit must be thrown away, not merged - a group that
      // advanced on a commit the server refused is forked with no way back.
      verify(() => mls.clearPendingCommit(_group)).called(1);
      verify(() => mls.mergePendingCommit(_group)).called(1);
    });

    test('gives up after a second rejection instead of looping', () async {
      when(
        () => api.publishCommit(
          contextId: _context,
          isChannel: false,
          dto: any(named: 'dto'),
        ),
      ).thenThrow(
        const MlsEpochConflictException(
          MlsEpochConflictDto(
            currentEpoch: 9,
            rejectedEpoch: 7,
            currentGeneration: 1,
            rejectedGeneration: 1,
            reason: 'contended',
          ),
        ),
      );
      when(
        () => api.getCommits(
          contextId: any(named: 'contextId'),
          isChannel: any(named: 'isChannel'),
          sinceEpoch: any(named: 'sinceEpoch'),
          generation: any(named: 'generation'),
        ),
      ).thenAnswer((_) async => const []);

      final published = await sync.publish(
        contextId: _context,
        isChannel: false,
        produce: () async => const StagedCommit(commit: 'staged', epoch: 7),
      );

      expect(published, isFalse);
      verify(() => mls.clearPendingCommit(_group)).called(2);
      verifyNever(() => mls.mergePendingCommit(_group));
    });
  });

  group('pending Welcomes', () {
    PendingWelcomeDto welcome(String id, String contextId) => PendingWelcomeDto(
      id: id,
      contextId: contextId,
      conversationId: contextId,
      userId: 'user_me',
      deviceId: _device,
      welcome: 'welcome-$id',
      generation: 1,
      epoch: 0,
    );

    test('acknowledges only the joins that actually succeeded', () async {
      when(() => api.getPendingWelcomes(_device)).thenAnswer(
        (_) async => [welcome('w1', 'conv_ok'), welcome('w2', 'conv_bad')],
      );
      when(() => mls.groupId(any(), any())).thenReturn(null);
      when(() => mls.knownGeneration(any())).thenReturn(null);
      when(() => mls.joinGroup('welcome-w1'))
          .thenAnswer((_) async => _groupAt(0));
      when(() => mls.joinGroup('welcome-w2'))
          .thenThrow(const MlsException(MlsErrorKind.mlsError, 'bad welcome'));
      when(
        () => mls.registerGroup(
          contextId: any(named: 'contextId'),
          generation: any(named: 'generation'),
          mlsGroupId: any(named: 'mlsGroupId'),
        ),
      ).thenAnswer((_) async {});
      when(() => api.ackWelcomes(any(), deviceId: any(named: 'deviceId')))
          .thenAnswer((_) async => const AckWelcomesResultDto(acknowledged: 1));

      await sync.processPendingWelcomes();

      // w2 stays unacknowledged so the next sweep sees it again. Acking it would
      // consume a single-use init key for a join that never happened, locking
      // this device out of that conversation permanently.
      verify(() => api.ackWelcomes(['w1'], deviceId: _device)).called(1);
    });

    test('acknowledges a Welcome whose group we already joined', () async {
      // A previous run joined but died before acking. Re-joining would fail, and
      // leaving it pending makes every future sweep retry a join that can never
      // succeed.
      when(() => api.getPendingWelcomes(_device))
          .thenAnswer((_) async => [welcome('w1', 'conv_joined')]);
      when(() => mls.groupId('conv_joined', 1)).thenReturn(_group);
      when(() => mls.knownGeneration('conv_joined')).thenReturn(1);
      when(() => mls.getGroupInfo(_group)).thenAnswer((_) async => _groupAt(3));
      when(
        () => api.getCommits(
          contextId: any(named: 'contextId'),
          isChannel: any(named: 'isChannel'),
          sinceEpoch: any(named: 'sinceEpoch'),
          generation: any(named: 'generation'),
        ),
      ).thenAnswer((_) async => const []);
      when(() => api.ackWelcomes(any(), deviceId: any(named: 'deviceId')))
          .thenAnswer((_) async => const AckWelcomesResultDto(acknowledged: 1));

      await sync.processPendingWelcomes();

      verify(() => api.ackWelcomes(['w1'], deviceId: _device)).called(1);
      verifyNever(() => mls.joinGroup(any()));
    });

    test('does nothing at all while the session is locked', () async {
      when(() => mls.isUnlocked).thenReturn(false);

      await sync.processPendingWelcomes();

      verifyNever(() => api.getPendingWelcomes(any()));
    });
  });

  group('encryption state reconciliation', () {
    test('clears the active generation when encryption was turned off', () async {
      when(() => api.getState(contextId: _context, isChannel: false))
          .thenAnswer((_) async => const MlsContextStateDto(contextId: _context));
      when(() => mls.clearActiveGeneration(_context)).thenAnswer((_) async {});

      await sync.refreshState(_context, false);

      verify(() => mls.clearActiveGeneration(_context)).called(1);
    });

    test(
      'fetches Welcomes for a generation this device has never joined',
      () async {
        // Encryption was toggled off and back on while we were away, minting a
        // whole new group. Continuing to encrypt to the old one would produce
        // ciphertext nobody in the context can read.
        when(() => api.getState(contextId: _context, isChannel: false))
            .thenAnswer(
              (_) async => const MlsContextStateDto(
                contextId: _context,
                encrypted: true,
                activeGeneration: 2,
              ),
            );
        when(() => mls.groupId(_context, 2)).thenReturn(null);
        when(() => api.getPendingWelcomes(_device))
            .thenAnswer((_) async => const []);

        await sync.refreshState(_context, false);

        verify(() => api.getPendingWelcomes(_device)).called(1);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // Regressions the audit found (plan §4.1, contract §E2 and §E4)
  // ---------------------------------------------------------------------------

  group('leave-proposal catch-up', () {
    /// The hang. Both clients publish a Remove **proposal** through the *commit*
    /// channel at `serverEpoch + 1`, because that is the only fanout a group
    /// has. The server accepts it - but processing a proposal does not advance
    /// any client's MLS epoch, so `getCommits(sinceEpoch = N)` keeps returning
    /// the same row, `applied` was always >= 1, and `while (true)` never
    /// terminated. It held the per-context queue the whole time, so the drain
    /// that would have resolved it could never run, and it issued an unbounded
    /// stream of HTTP requests while it span.
    ///
    /// The old test suite mocked this into passing by returning `[]` on the
    /// second call, which the real server does not do. This one keeps returning
    /// the proposal, exactly as the server would.
    test('terminates when the server keeps returning the same proposal', () async {
      when(() => mls.getGroupInfo(_group)).thenAnswer((_) async => _groupAt(5));

      var pages = 0;
      when(
        () => api.getCommits(
          contextId: any(named: 'contextId'),
          isChannel: any(named: 'isChannel'),
          sinceEpoch: any(named: 'sinceEpoch'),
          generation: any(named: 'generation'),
        ),
      ).thenAnswer((_) async {
        pages++;
        // The server's honest behaviour: the proposal is still there, and this
        // device's epoch has not moved, so it comes back every time.
        return [_commit(6, bytes: 'proposal')];
      });
      when(
        () => mls.processMessage(
          groupIdB64: any(named: 'groupIdB64'),
          messageB64: any(named: 'messageB64'),
        ),
      ).thenAnswer(
        (_) async => MlsProcessedMessage(
          kind: MlsMessageKind.proposal,
          plaintext: null,
          selfRemoved: false,
          addedMembers: const [],
          removedLeafIndices: const [],
          senderIdentity: 'user_leaver',
          epoch: null,
        ),
      );
      when(() => mls.commitPendingProposals(_group)).thenAnswer(
        (_) async => const MlsCommitOut(commit: 'c', welcome: null, epoch: 6),
      );
      when(() => mls.exportGroupInfo(_group)).thenAnswer((_) async => 'gi');
      when(() => mls.mergePendingCommit(_group)).thenAnswer((_) async => 6);
      when(
        () => api.publishCommit(
          contextId: any(named: 'contextId'),
          isChannel: any(named: 'isChannel'),
          dto: any(named: 'dto'),
        ),
      ).thenAnswer(
        (_) async => const MlsCommitPublishedDto(
          contextId: _context,
          generation: 1,
          epoch: 6,
        ),
      );

      await sync
          .syncContext(_context, false)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => fail(
              'catch-up span on a proposal - a proposal does not advance the '
              'epoch, so it must not count as progress',
            ),
          );

      expect(
        pages,
        1,
        reason: 'a page of nothing but proposals is a terminating page',
      );
    });
  });

  group('a commit whose publish outcome is unknown', () {
    setUp(() {
      when(() => mls.exportGroupInfo(_group)).thenAnswer((_) async => 'gi');
      when(() => mls.clearPendingCommit(_group)).thenAnswer((_) async {});
    });

    /// The stranding bug. `_attemptPublish` discarded the staged commit on *any*
    /// exception, including a timeout that arrived after the server had already
    /// committed. The next catch-up then handed this device its own commit,
    /// `processMessage` refused it, and the device was forked off the group with
    /// no way back.
    test('is merged, not reprocessed, when it turns up in the next page', () async {
      when(
        () => api.publishCommit(
          contextId: any(named: 'contextId'),
          isChannel: any(named: 'isChannel'),
          dto: any(named: 'dto'),
        ),
      ).thenThrow(_TimedOut());

      await expectLater(
        sync.publish(
          contextId: _context,
          isChannel: false,
          produce: () async => const StagedCommit(commit: 'staged', epoch: 7),
        ),
        throwsA(isA<_TimedOut>()),
      );

      verifyNever(
        () => mls.clearPendingCommit(_group),
      );

      // The server did take it. It comes back in the next page, attributed to
      // this device.
      when(() => mls.getGroupInfo(_group)).thenAnswer((_) async => _groupAt(6));
      var page = 0;
      when(
        () => api.getCommits(
          contextId: any(named: 'contextId'),
          isChannel: any(named: 'isChannel'),
          sinceEpoch: any(named: 'sinceEpoch'),
          generation: any(named: 'generation'),
        ),
      ).thenAnswer(
        (_) async => page++ == 0
            ? [
                MlsCommitDto(
                  id: 'mlsc_own',
                  contextId: _context,
                  conversationId: _context,
                  generation: 1,
                  epoch: 7,
                  commit: 'staged',
                  senderUserId: 'user_me',
                  senderDeviceId: _device,
                ),
              ]
            : const [],
      );
      when(() => mls.mergePendingCommit(_group)).thenAnswer((_) async => 7);

      await sync.syncContext(_context, false);

      verify(() => mls.mergePendingCommit(_group)).called(1);
      verifyNever(
        () => mls.processMessage(
          groupIdB64: any(named: 'groupIdB64'),
          messageB64: any(named: 'messageB64'),
        ),
      );
    });

    test('is discarded when somebody else won that epoch instead', () async {
      when(
        () => api.publishCommit(
          contextId: any(named: 'contextId'),
          isChannel: any(named: 'isChannel'),
          dto: any(named: 'dto'),
        ),
      ).thenThrow(_TimedOut());

      await expectLater(
        sync.publish(
          contextId: _context,
          isChannel: false,
          produce: () async => const StagedCommit(commit: 'staged', epoch: 7),
        ),
        throwsA(isA<_TimedOut>()),
      );

      // A different device's commit occupies epoch 7. Ours was never taken, so
      // it must be dropped before theirs is applied - a group holding a staged
      // commit cannot merge somebody else's.
      when(() => mls.getGroupInfo(_group)).thenAnswer((_) async => _groupAt(6));
      var page = 0;
      when(
        () => api.getCommits(
          contextId: any(named: 'contextId'),
          isChannel: any(named: 'isChannel'),
          sinceEpoch: any(named: 'sinceEpoch'),
          generation: any(named: 'generation'),
        ),
      ).thenAnswer((_) async => page++ == 0 ? [_commit(7)] : const []);
      when(
        () => mls.processMessage(
          groupIdB64: any(named: 'groupIdB64'),
          messageB64: any(named: 'messageB64'),
        ),
      ).thenAnswer((_) async => _appliedCommit(7));

      await sync.syncContext(_context, false);

      verify(() => mls.clearPendingCommit(_group)).called(1);
      verify(
        () => mls.processMessage(
          groupIdB64: _group,
          messageB64: 'commit-7',
        ),
      ).called(1);
    });

    test('a rejected epoch is still discarded immediately', () async {
      // The definite "no" - somebody else took the epoch, so the commit was
      // never applied anywhere and holding it would block every later one.
      when(
        () => api.publishCommit(
          contextId: any(named: 'contextId'),
          isChannel: any(named: 'isChannel'),
          dto: any(named: 'dto'),
        ),
      ).thenThrow(
        const MlsEpochConflictException(
          MlsEpochConflictDto(currentEpoch: 7, rejectedEpoch: 7),
        ),
      );
      when(() => mls.getGroupInfo(_group)).thenAnswer((_) async => _groupAt(7));
      when(
        () => api.getCommits(
          contextId: any(named: 'contextId'),
          isChannel: any(named: 'isChannel'),
          sinceEpoch: any(named: 'sinceEpoch'),
          generation: any(named: 'generation'),
        ),
      ).thenAnswer((_) async => const []);

      final published = await sync.publish(
        contextId: _context,
        isChannel: false,
        produce: () async => const StagedCommit(commit: 'staged', epoch: 7),
      );

      expect(published, isFalse);
      verify(() => mls.clearPendingCommit(_group)).called(2);
    });
  });

  group('welcome retries', () {
    test('are bounded, so a broken Welcome is not retried forever', () async {
      // A structurally broken Welcome will not become valid. Retrying it on
      // every launch, every push and every state refresh is an unbounded loop
      // against a single-use key that can never work.
      when(() => mls.groupId(_context, 1)).thenReturn(null);
      when(() => api.getPendingWelcomes(_device)).thenAnswer(
        (_) async => const [
          PendingWelcomeDto(
            id: 'pw_1',
            contextId: _context,
            conversationId: _context,
            userId: 'user_me',
            deviceId: _device,
            welcome: 'garbage',
            generation: 1,
            epoch: 0,
          ),
        ],
      );
      when(() => mls.joinGroup(any())).thenThrow(
        const MlsException(MlsErrorKind.validationError, 'not a Welcome'),
      );

      for (var i = 0; i < 6; i++) {
        await sync.processPendingWelcomes();
      }

      // Three attempts, then it stops trying. Deliberately still not acked: the
      // ack is what destroys the server's copy, and a fixed client should get
      // another go at it.
      verify(() => mls.joinGroup('garbage')).called(3);
      verifyNever(() => api.ackWelcomes(any(), deviceId: any(named: 'deviceId')));
    });
  });
}

/// Stands in for a dropped connection - anything that leaves the publish outcome
/// genuinely unknown, as distinct from a server that said no.
class _TimedOut implements Exception {
  @override
  String toString() => 'the connection went away';
}
