import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/device/device_id_service.dart';
import 'package:venta_mobile/core/mls/conversation_encryption_service.dart';
import 'package:venta_mls/venta_mls.dart';
import 'package:venta_mobile/core/mls/mls_service.dart';
import 'package:venta_mobile/features/conversations/data/conversation_api.dart';
import 'package:venta_mobile/features/conversations/data/models/conversation_dto.dart';
import 'package:venta_mobile/features/mls/data/mls_api.dart';
import 'package:venta_mobile/features/mls/data/models/mls_dtos.dart';

/// What these cover: reachability is a property of a **device**, not of a
/// person, and collapsing the two silently and permanently excludes handsets.
///
/// An MLS group member is a device. A participant with a healthy laptop and a
/// phone that has run out of key packages passed the old per-user check,
/// because the laptop's token proved "this user is reachable" - and the phone
/// was dropped from the group with nothing anywhere saying so. That is the
/// "readable on one device, not the other" report.
///
/// Two things make it permanent rather than temporary. Nothing retro-adds a
/// leaf to an existing group - a device left out at creation is outside it
/// until something explicitly requests admission - and the exclusion was never
/// reported, so nobody knew to ask.
///
/// The creator's own second device is the sharpest case: it was checked by
/// neither side. Mobile looked only at `memberUserIds`, which does not contain
/// the caller, and so did the server until it was fixed - so the one device
/// whose owner would definitely notice was the one nobody looked at.

class _MockMls extends Mock implements MlsService {}

class _MockApi extends Mock implements MlsApi {}

class _MockConversations extends Mock implements ConversationApi {}

class _MockDeviceIds extends Mock implements DeviceIdService {}

const _me = 'user_me';
const _friend = 'user_friend';
const _myDevice = 'device_mine';

const _created = ConversationDto(
  id: 'conv_1',
  members: [],
  encryptionState: ConversationEncryption.encrypted,
);

MlsDeviceTokenDto _token(String userId, String deviceId) => MlsDeviceTokenDto(
  userId: userId,
  deviceId: deviceId,
  token: 'kp_$deviceId',
);

void main() {
  late _MockMls mls;
  late _MockApi api;
  late _MockConversations conversations;
  late _MockDeviceIds deviceIds;
  late ConversationEncryptionService service;

  setUp(() {
    mls = _MockMls();
    api = _MockApi();
    conversations = _MockConversations();
    deviceIds = _MockDeviceIds();
    service = ConversationEncryptionService(
      mls: mls,
      api: api,
      conversationApi: conversations,
      deviceIdService: deviceIds,
    );

    when(() => deviceIds.deviceId).thenReturn(_myDevice);
    when(() => mls.newGroupId()).thenReturn('group_1');
    when(() => mls.createGroup(any())).thenAnswer(
      (_) async => const MlsGroupInfo(
        groupId: 'group_1',
        epoch: 0,
        ownLeafIndex: 0,
        members: [],
      ),
    );
    when(() => mls.deleteGroup(any())).thenAnswer((_) async {});
    when(() => mls.mergePendingCommit(any())).thenAnswer((_) async => 1);
    when(() => mls.exportGroupInfo(any())).thenAnswer((_) async => 'info');
    when(
      () => mls.addMembers(
        groupIdB64: any(named: 'groupIdB64'),
        keyPackagesB64: any(named: 'keyPackagesB64'),
      ),
    ).thenAnswer(
      (_) async => const MlsCommitOut(commit: 'c', welcome: 'w', epoch: 1),
    );
    when(
      () => mls.registerGroup(
        contextId: any(named: 'contextId'),
        generation: any(named: 'generation'),
        mlsGroupId: any(named: 'mlsGroupId'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => conversations.create(
        name: any(named: 'name'),
        memberUserIds: any(named: 'memberUserIds'),
        encrypted: any(named: 'encrypted'),
        deviceWelcomes: any(named: 'deviceWelcomes'),
        mlsGroupId: any(named: 'mlsGroupId'),
        mlsEpoch: any(named: 'mlsEpoch'),
        mlsGroupInfo: any(named: 'mlsGroupInfo'),
        allowPartialDeviceCoverage: any(named: 'allowPartialDeviceCoverage'),
      ),
    ).thenAnswer((_) async => _created);
  });

  void tokensAre(ConsumeTokensResultDto result) {
    when(
      () => api.consumeTokensForUsers(any()),
    ).thenAnswer((_) async => result);
  }

  test('every participant is asked about, including the caller', () async {
    tokensAre(
      ConsumeTokensResultDto(
        deviceTokens: [_token(_friend, 'device_friend')],
        unreachableDevices: const [],
      ),
    );

    await service.createEncrypted(
      ownUserId: _me,
      memberUserIds: const [_friend],
    );

    // The caller's *other* devices have to be in the group or the same person
    // cannot read their own messages across handsets.
    final asked =
        verify(() => api.consumeTokensForUsers(captureAny())).captured.single
            as List<String>;
    expect(asked, containsAll(<String>[_me, _friend]));
  });

  test(
    'a participant with one good and one dry device does not silently create',
    () async {
      tokensAre(
        ConsumeTokensResultDto(
          deviceTokens: [_token(_friend, 'device_laptop')],
          unreachableDevices: const [
            UnreachableDeviceDto(
              userId: _friend,
              deviceId: 'device_phone',
              deviceName: 'Their phone',
            ),
          ],
        ),
      );

      // The old check asked "did this user appear at all", and the laptop's
      // token said yes - so the phone was dropped and nothing was raised.
      await expectLater(
        service.createEncrypted(ownUserId: _me, memberUserIds: const [_friend]),
        throwsA(isA<UnreachableMembersException>()),
      );

      verifyNever(
        () => conversations.create(
          name: any(named: 'name'),
          memberUserIds: any(named: 'memberUserIds'),
          encrypted: any(named: 'encrypted'),
          deviceWelcomes: any(named: 'deviceWelcomes'),
          mlsGroupId: any(named: 'mlsGroupId'),
          mlsEpoch: any(named: 'mlsEpoch'),
          mlsGroupInfo: any(named: 'mlsGroupInfo'),
          allowPartialDeviceCoverage: any(named: 'allowPartialDeviceCoverage'),
        ),
      );
    },
  );

  test('the caller\'s own dry second device is caught', () async {
    tokensAre(
      ConsumeTokensResultDto(
        deviceTokens: [_token(_friend, 'device_friend')],
        unreachableDevices: const [
          UnreachableDeviceDto(
            userId: _me,
            deviceId: 'device_my_desktop',
            deviceName: 'My desktop',
          ),
        ],
      ),
    );

    // Neither side looked here: mobile checked `memberUserIds`, which never
    // contains the caller, and the server's resolver had the same blind spot.
    // It is also the reported symptom - a message the phone can read and the
    // desktop cannot.
    await expectLater(
      service.createEncrypted(ownUserId: _me, memberUserIds: const [_friend]),
      throwsA(
        isA<UnreachableMembersException>().having(
          (e) => e.deviceNames,
          'deviceNames',
          contains('My desktop'),
        ),
      ),
    );
  });

  test(
    'the human can accept partial coverage, and the server is told',
    () async {
      tokensAre(
        ConsumeTokensResultDto(
          deviceTokens: [_token(_friend, 'device_laptop')],
          unreachableDevices: const [
            UnreachableDeviceDto(userId: _friend, deviceId: 'device_phone'),
          ],
        ),
      );

      List<UnreachableDeviceDto>? offered;
      final conversation = await service.createEncrypted(
        ownUserId: _me,
        memberUserIds: const [_friend],
        onPartialCoverage: (devices) async {
          offered = devices;
          return true;
        },
      );

      expect(conversation.id, _created.id);
      expect(offered, hasLength(1));
      // Without the flag the server refuses outright once
      // MlsPolicy.RejectUnreachableDevicesOnCreate is on, so accepting in the UI
      // and not saying so on the wire is a create that simply fails.
      verify(
        () => conversations.create(
          name: any(named: 'name'),
          memberUserIds: any(named: 'memberUserIds'),
          encrypted: any(named: 'encrypted'),
          deviceWelcomes: any(named: 'deviceWelcomes'),
          mlsGroupId: any(named: 'mlsGroupId'),
          mlsEpoch: any(named: 'mlsEpoch'),
          mlsGroupInfo: any(named: 'mlsGroupInfo'),
          allowPartialDeviceCoverage: true,
        ),
      ).called(1);
    },
  );

  test('declining leaves no group behind', () async {
    tokensAre(
      ConsumeTokensResultDto(
        deviceTokens: [_token(_friend, 'device_laptop')],
        unreachableDevices: const [
          UnreachableDeviceDto(userId: _friend, deviceId: 'device_phone'),
        ],
      ),
    );

    await expectLater(
      service.createEncrypted(
        ownUserId: _me,
        memberUserIds: const [_friend],
        onPartialCoverage: (_) async => false,
      ),
      throwsA(isA<UnreachableMembersException>()),
    );

    // The decision happens before any group is built, so there is nothing to
    // clean up and no key packages spent on a group nobody keeps.
    verifyNever(() => mls.createGroup(any()));
  });

  test('full coverage never asks', () async {
    tokensAre(
      ConsumeTokensResultDto(
        deviceTokens: [_token(_friend, 'device_friend')],
        unreachableDevices: const [],
      ),
    );

    var asked = false;
    await service.createEncrypted(
      ownUserId: _me,
      memberUserIds: const [_friend],
      onPartialCoverage: (_) async {
        asked = true;
        return true;
      },
    );

    expect(asked, isFalse);
    verify(
      () => conversations.create(
        name: any(named: 'name'),
        memberUserIds: any(named: 'memberUserIds'),
        encrypted: any(named: 'encrypted'),
        deviceWelcomes: any(named: 'deviceWelcomes'),
        mlsGroupId: any(named: 'mlsGroupId'),
        mlsEpoch: any(named: 'mlsEpoch'),
        mlsGroupInfo: any(named: 'mlsGroupInfo'),
        allowPartialDeviceCoverage: false,
      ),
    ).called(1);
  });
}
