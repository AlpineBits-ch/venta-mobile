import 'package:flutter/foundation.dart';

import '../../features/conversations/data/conversation_api.dart';
import '../../features/conversations/data/models/conversation_dto.dart';
import '../../features/mls/data/mls_api.dart';
import '../../features/mls/data/models/mls_dtos.dart';
import '../device/device_id_service.dart';
import 'mls_service.dart';

/// Thrown when a conversation cannot be created encrypted because some
/// participant's devices have no key packages left.
///
/// The server refuses this case outright rather than creating a conversation
/// that is permanently unreadable on someone's handset, and so does this - but
/// it names which devices, which the server's message does not do in terms the
/// UI can show.
class UnreachableMembersException implements Exception {
  const UnreachableMembersException(this.devices);

  /// Per **device**, not per person. A participant with a working laptop and a
  /// dry phone is in here, because the phone is the part that will never read
  /// the conversation.
  final List<UnreachableDeviceDto> devices;

  List<String> get deviceNames =>
      devices.map((d) => d.deviceName ?? d.deviceId).toList();

  @override
  String toString() => 'UnreachableMembersException(${deviceNames.join(', ')})';
}

/// Asks the human whether to create the conversation anyway, given the devices
/// that will never be able to read it.
///
/// Returning true is what puts `?allowPartialDeviceCoverage=true` on the create
/// call. A callback rather than a "retry with a flag" exception because the key
/// packages have already been consumed by the time this is known: throwing and
/// re-entering would spend a second package on every reachable device, which is
/// the waste the server-side comment on `/consume-tokens` calls out by name.
typedef PartialCoverageDecision =
    Future<bool> Function(List<UnreachableDeviceDto> devices);

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
    PartialCoverageDecision? onPartialCoverage,
  }) async {
    final ownDeviceId = deviceIdService.deviceId;
    final tokens = await api.consumeTokensForUsers([
      ownUserId,
      ...memberUserIds,
    ]);

    // **Per device, not per user.** An MLS group member is a device, so a
    // participant whose laptop got a Welcome and whose phone did not is someone
    // who reads this conversation on one machine and sees undecryptable noise
    // on the other.
    //
    // This used to ask only whether each *user id* appeared among the tokens at
    // all, which the laptop's token answered yes to - so the phone was dropped
    // in silence. And it asked it of `memberUserIds`, which does not contain
    // the caller, so this account's own second device was checked by nobody:
    // the server's resolver had the identical blind spot until it was fixed,
    // and that pair is the "readable on my phone, not on my desktop" report.
    //
    // Silence is what makes it permanent. Nothing retro-adds a leaf to an
    // existing group, so a device left out here is outside the conversation
    // until it explicitly requests admission - which it cannot do if nobody
    // ever said it was left out.
    final unreachable = tokens.unreachableDevices;
    if (unreachable.isNotEmpty) {
      // The decision happens *before* any group is built, so declining costs
      // nothing beyond the packages already consumed and leaves no orphaned
      // group to clean up.
      final proceed = await onPartialCoverage?.call(unreachable) ?? false;
      if (!proceed) throw UnreachableMembersException(unreachable);
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
        // Reaching here with devices left out means the human was shown them
        // and said yes. Without the flag the server refuses the create once
        // `MlsPolicy.RejectUnreachableDevicesOnCreate` is on, so accepting in
        // the UI and not saying so on the wire is just a create that fails.
        allowPartialDeviceCoverage: unreachable.isNotEmpty,
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
