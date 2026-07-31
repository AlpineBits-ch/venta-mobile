import 'package:flutter/foundation.dart';

import '../../features/conversations/data/conversation_api.dart';
import '../../features/conversations/data/models/conversation_dto.dart';
import '../../features/mls/data/mls_api.dart';
import '../device/device_id_service.dart';
import 'mls_service.dart';

/// Thrown when a conversation cannot be created encrypted because some
/// invitee's devices have no key packages left.
///
/// The server refuses this case outright rather than creating a conversation
/// that is permanently unreadable for someone in it, and so does this - but it
/// names who, which the server's message does not do in terms the UI can show.
class UnreachableMembersException implements Exception {
  const UnreachableMembersException(this.deviceNames);

  final List<String> deviceNames;

  @override
  String toString() =>
      'UnreachableMembersException(${deviceNames.join(', ')})';
}

/// Creating an end-to-end encrypted DM or group DM. The conversation-side
/// counterpart of [ChannelEncryptionService], mirroring what Alpine's
/// new-conversation dialog does inline.
///
/// There is no enable/disable pair here on purpose: the server has no
/// conversation-level toggle endpoint, only the channel one. A conversation is
/// created encrypted or it is not.
class ConversationEncryptionService {
  ConversationEncryptionService({
    required this.mls,
    required this.api,
    required this.conversationApi,
    required this.deviceIdService,
  });

  final MlsService mls;
  final MlsApi api;
  final ConversationApi conversationApi;
  final DeviceIdService deviceIdService;

  /// Builds an MLS group over every device of [memberUserIds] plus this user's
  /// own other devices, then creates the conversation around it.
  ///
  /// [ownUserId] is included in the token consumption deliberately: this
  /// account's *other* devices have to be in the group too, or the same person
  /// on their phone and their desktop cannot read each other's messages.
  Future<ConversationDto> createEncrypted({
    required String ownUserId,
    required List<String> memberUserIds,
    String? name,
  }) async {
    final ownDeviceId = deviceIdService.deviceId;
    final tokens = await api.consumeTokensForUsers([
      ownUserId,
      ...memberUserIds,
    ]);

    // A member with no reachable device can never read the conversation. Failing
    // before creating anything is the honest outcome - the server rejects it
    // too, and this way no key packages are burned on a group nobody keeps.
    final welcomed = tokens.deviceTokens.map((t) => t.userId).toSet();
    final unreachable = memberUserIds
        .where((id) => !welcomed.contains(id))
        .toList();
    if (unreachable.isNotEmpty) {
      throw UnreachableMembersException(
        tokens.unreachableDevices
            .where((d) => unreachable.contains(d.userId))
            .map((d) => d.deviceName ?? d.deviceId)
            .toList(),
      );
    }

    final invitees = tokens.deviceTokens
        .where((t) => t.deviceId != ownDeviceId)
        .toList();

    final groupIdB64 = mls.newGroupId();
    await mls.createGroup(groupIdB64);

    try {
      var epoch = 0;
      var deviceWelcomes = <Map<String, Object?>>[];
      String? mlsGroupInfo;

      if (invitees.isNotEmpty) {
        final commitOut = await mls.addMembers(
          groupIdB64: groupIdB64,
          keyPackagesB64: invitees.map((t) => t.token).toList(),
        );
        // Merged straight away: this group exists nowhere but here until the
        // create call lands, so there is no other committer to race.
        await mls.mergePendingCommit(groupIdB64);

        epoch = commitOut.epoch;
        deviceWelcomes = invitees
            .map(
              (t) => <String, Object?>{
                'deviceId': t.deviceId,
                'userId': t.userId,
                'welcome': commitOut.welcome,
              },
            )
            .toList();
        mlsGroupInfo = await mls.exportGroupInfo(groupIdB64);
      }

      final conversation = await conversationApi.create(
        name: name,
        memberUserIds: memberUserIds,
        encrypted: true,
        deviceWelcomes: deviceWelcomes,
        mlsGroupId: groupIdB64,
        mlsEpoch: epoch,
        mlsGroupInfo: mlsGroupInfo,
      );

      // The server mints generation 1 for a conversation created encrypted.
      await mls.registerGroup(
        contextId: conversation.id,
        generation: 1,
        mlsGroupId: groupIdB64,
      );

      return conversation;
    } catch (_) {
      // The server did not take the group, so nothing will ever reference it.
      try {
        await mls.deleteGroup(groupIdB64);
      } catch (e) {
        debugPrint('MLS: could not clean up an unpublished group: $e');
      }
      rethrow;
    }
  }
}
