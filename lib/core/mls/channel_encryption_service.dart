import 'package:flutter/foundation.dart';

import '../../features/mls/data/mls_api.dart';
import '../../features/mls/data/models/mls_dtos.dart';
import '../device/device_id_service.dart';
import 'mls_service.dart';
import 'mls_sync_service.dart';

class EnableChannelEncryptionResult {
  const EnableChannelEncryptionResult({
    required this.generation,
    required this.unreachableDevices,
  });

  final int generation;

  /// Devices that had no key package left and were therefore not added. They
  /// cannot read anything sent from now on, so the caller has to say so rather
  /// than reporting a clean success.
  final List<UnreachableDeviceDto> unreachableDevices;
}

class DisableChannelEncryptionResult {
  const DisableChannelEncryptionResult({
    required this.terminatedGeneration,
    required this.alreadyPlain,
  });

  /// Messages sent under this generation stay ciphertext. Nothing is decrypted
  /// or rewritten, so anyone without that group's keys - including future
  /// members - cannot read that stretch.
  final int? terminatedGeneration;
  final bool alreadyPlain;
}

/// Turning a guild channel's end-to-end encryption on and off. Port of Alpine's
/// `ChannelEncryptionService`.
///
/// Enabling builds a fresh MLS group over whoever can currently see the channel.
/// Disabling terminates it. Doing both repeatedly is expected and safe - each
/// enable mints a new generation rather than resuming the last one, because
/// resuming would hand the old traffic to whoever joined while it was off.
class ChannelEncryptionService {
  ChannelEncryptionService({
    required this.mls,
    required this.sync,
    required this.api,
    required this.deviceIdService,
  });

  final MlsService mls;
  final MlsSyncService sync;
  final MlsApi api;
  final DeviceIdService deviceIdService;

  /// Turns encryption on, adding every device of [memberUserIds] to the new
  /// group.
  ///
  /// Plaintext already in the channel is untouched and stays readable - this
  /// marks a boundary in the channel's timeline, it does not convert anything.
  Future<EnableChannelEncryptionResult> enable({
    required String channelId,
    required List<String> memberUserIds,
  }) async {
    final ownDeviceId = deviceIdService.deviceId;
    final tokens = await api.consumeTokensForUsers(memberUserIds);
    final invitees = tokens.deviceTokens
        .where((t) => t.deviceId != ownDeviceId)
        .toList();

    final groupIdB64 = mls.newGroupId();
    await mls.createGroup(groupIdB64);

    try {
      var epoch = 0;
      var welcomes = <DeviceWelcomeDto>[];
      String? groupInfo;

      if (invitees.isNotEmpty) {
        final commitOut = await mls.addMembers(
          groupIdB64: groupIdB64,
          keyPackagesB64: invitees.map((t) => t.token).toList(),
        );
        // Merged straight away: this group exists nowhere but here until the
        // enable call lands, so there is no other committer to lose an epoch
        // race against.
        await mls.mergePendingCommit(groupIdB64);

        epoch = commitOut.epoch;
        welcomes = invitees
            .map(
              (t) => DeviceWelcomeDto(
                deviceId: t.deviceId,
                userId: t.userId,
                welcome: commitOut.welcome!,
              ),
            )
            .toList();
        groupInfo = await mls.exportGroupInfo(groupIdB64);
      }

      final result = await api.enableChannelEncryption(
        channelId: channelId,
        dto: EnableMlsDto(
          mlsGroupId: groupIdB64,
          epoch: epoch,
          mlsGroupInfo: groupInfo,
          welcomes: welcomes,
        ),
      );

      final generation = result.generation!;
      await mls.registerGroup(
        contextId: channelId,
        generation: generation,
        mlsGroupId: groupIdB64,
      );

      return EnableChannelEncryptionResult(
        generation: generation,
        unreachableDevices: tokens.unreachableDevices,
      );
    } catch (_) {
      // The server did not take the group, so nothing else will ever reference
      // it. Leaving it behind would have this device holding keys for an era
      // that never existed, and the next attempt would build a second group for
      // the same channel.
      try {
        await mls.deleteGroup(groupIdB64);
      } catch (e) {
        debugPrint('MLS: could not clean up an unpublished group: $e');
      }
      rethrow;
    }
  }

  /// Turns encryption off.
  ///
  /// The local group is deliberately *not* deleted: the messages it encrypted
  /// are still in the channel, and this device is one of the few that can still
  /// read them. Only the "this context is currently encrypted" marker is
  /// cleared.
  Future<DisableChannelEncryptionResult> disable(String channelId) async {
    final result = await api.disableChannelEncryption(channelId);
    await mls.clearActiveGeneration(channelId);
    return DisableChannelEncryptionResult(
      terminatedGeneration: result.terminatedGeneration,
      alreadyPlain: result.alreadyInRequestedState,
    );
  }

  /// Whether this channel is encrypted right now, and under which generation.
  Future<MlsContextStateDto> state(String channelId) =>
      sync.refreshState(channelId, true);
}
