import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/mls/conversation_member_service.dart';
import 'package:venta_mobile/core/mls/mls_service.dart';
import 'package:venta_mobile/core/mls/mls_sync_service.dart';
import 'package:venta_mobile/features/conversations/data/conversation_api.dart';
import 'package:venta_mobile/features/conversations/data/models/conversation_dto.dart';
import 'package:venta_mobile/features/mls/data/models/mls_dtos.dart';

/// What these cover: the order in which somebody joins an encrypted group
/// conversation.
///
/// The roster has to come first. A member who is in the conversation but not yet
/// in the MLS group sees an empty conversation - recoverable, and visible to
/// them. The reverse leaves someone holding group keys for a conversation the
/// server does not believe they are in, able to decrypt traffic they are not a
/// member of.
///
/// Nothing in the type system says which call goes first, and both orders
/// "work" in the sense of not throwing, so this is exactly the kind of thing a
/// later refactor would swap without noticing.

class _MockApi extends Mock implements ConversationApi {}

class _MockMls extends Mock implements MlsService {}

class _MockSync extends Mock implements MlsSyncService {}

const _conversation = 'conv_1';
const _invitee = 'user_new';

const _dto = ConversationDto(
  id: _conversation,
  members: [],
  encryptionState: ConversationEncryption.encrypted,
);

void main() {
  late _MockApi api;
  late _MockMls mls;
  late _MockSync sync;
  late ConversationMemberService service;
  late List<String> calls;

  setUp(() {
    api = _MockApi();
    mls = _MockMls();
    sync = _MockSync();
    service = ConversationMemberService(api: api, mls: mls, sync: sync);
    calls = [];

    when(
      () => api.addMember(
        conversationId: any(named: 'conversationId'),
        userId: any(named: 'userId'),
      ),
    ).thenAnswer((_) async {
      calls.add('roster');
      return _dto;
    });
    when(
      () => sync.addMembers(
        contextId: any(named: 'contextId'),
        isChannel: any(named: 'isChannel'),
        userIds: any(named: 'userIds'),
      ),
    ).thenAnswer((_) async {
      calls.add('group');
      return const <UnreachableDeviceDto>[];
    });
  });

  test('adds to the roster before admitting to the group', () async {
    when(() => mls.knownGeneration(_conversation)).thenReturn(1);

    await service.addMember(conversationId: _conversation, userId: _invitee);

    expect(
      calls,
      ['roster', 'group'],
      reason: 'group keys before membership would let them decrypt traffic for '
          'a conversation the server says they are not in',
    );
  });

  test('a plaintext conversation never touches the group', () async {
    when(() => mls.knownGeneration(_conversation)).thenReturn(null);

    final result = await service.addMember(
      conversationId: _conversation,
      userId: _invitee,
    );

    expect(calls, ['roster']);
    expect(result.unreachableDevices, isEmpty);
    verifyNever(
      () => sync.addMembers(
        contextId: any(named: 'contextId'),
        isChannel: any(named: 'isChannel'),
        userIds: any(named: 'userIds'),
      ),
    );
  });

  test('reports devices that could not be admitted rather than dropping them', () async {
    when(() => mls.knownGeneration(_conversation)).thenReturn(1);
    when(
      () => sync.addMembers(
        contextId: any(named: 'contextId'),
        isChannel: any(named: 'isChannel'),
        userIds: any(named: 'userIds'),
      ),
    ).thenAnswer(
      (_) async => const [
        UnreachableDeviceDto(
          userId: _invitee,
          deviceId: 'device-dry',
          deviceName: 'Their phone',
        ),
      ],
    );

    final result = await service.addMember(
      conversationId: _conversation,
      userId: _invitee,
    );

    // They are in the conversation but cannot read it until that device comes
    // back online and uploads new key packages. Saying so beats letting them
    // discover it when the history stays empty.
    expect(result.unreachableDevices.single.deviceName, 'Their phone');
  });
}
