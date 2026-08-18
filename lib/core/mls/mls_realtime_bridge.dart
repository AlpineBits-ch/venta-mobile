import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/mls/data/mls_api.dart';
import '../../features/mls/data/models/mls_dtos.dart';
import '../realtime/realtime_event.dart';
import '../realtime/realtime_service.dart';
import 'device_admission_service.dart';
import 'mls_service.dart';
import 'mls_sync_service.dart';

/// Turns the server's three MLS pushes into sync work.
///
/// Alpine wires these up inside `main-page.component`, where they live next to
/// the rest of its launch sequence. Mobile has no equivalent always-mounted
/// screen that owns the session, so this is a service started alongside the
/// realtime connection instead - and being a service rather than a widget means
/// a background-to-foreground transition cannot silently drop the
/// subscriptions.
///
/// Every push is a nudge. None of them carries key material, and none of them
/// is applied directly: an MLS client that acts on push-arrival order rather
/// than on the ordered fetch is forked off the group permanently.
class MlsRealtimeBridge {
  MlsRealtimeBridge({
    required this.realtimeService,
    required this.mls,
    required this.sync,
    required this.api,
    required this.admission,
    required this.authRepository,
  });

  final RealtimeService realtimeService;
  final MlsService mls;
  final MlsSyncService sync;
  final MlsApi api;
  final DeviceAdmissionService admission;
  final AuthRepository authRepository;

  StreamSubscription<RealtimeEvent>? _subscription;

  void start() {
    _subscription ??= realtimeService.events
        .where((e) => _handled.contains(e.name))
        .listen(_handle);
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  static const _handled = {
    'conversation.Welcome',
    'conversation.MlsCommit',
    'conversation.MlsStateChanged',
    'guild.ChannelMlsStateChanged',
    // Contract §B. Somebody - possibly this account, on a new handset - is
    // asking to be let into an encrypted context.
    'conversation.MlsJoinRequest',
    // Contract §E9. A device was removed from an account and has to be
    // committed out of every group it holds a leaf in - and when it is *this*
    // device, it has to stop asking to be let back in.
    'conversation.MlsDeviceRemoved',
    // Somebody's device was let into a group we are in. A prompt
    // only - the membership change itself arrives as a commit through the
    // ordered fetch, which is why it is answered exactly like `MlsCommit`.
    'conversation.MlsDeviceAdmitted',
  };

  void _handle(RealtimeEvent event) {
    // Taken above the unlock guard, deliberately. The device this one push is
    // *about* is the device most likely to be locked - removal revokes its
    // sessions, and its keys may already be gone - so dropping the record for
    // that reason would lose it in precisely the case it exists for. Recording
    // it writes the registry file and needs no signing key.
    if (event.name == 'conversation.MlsDeviceRemoved') {
      _handleDeviceRemoved(event);
      return;
    }

    // Nothing here can do anything useful while locked, and several of these
    // would otherwise fetch a page of commits only to discard it.
    if (!mls.isUnlocked) return;

    switch (event.name) {
      // The push names a context but carries nothing else: the fetch behind it
      // is device-scoped, and the Welcome is acknowledged only once its join has
      // actually worked.
      case 'conversation.Welcome':
        _guard('process pending Welcomes', () => sync.processPendingWelcomes());

      // A commit landed. Group state advances by fetching commits above our own
      // epoch and applying them in order, never in push-arrival order.
      case 'conversation.MlsCommit' || 'conversation.MlsDeviceAdmitted':
        final payload = event.objectPayload;
        final contextId = payload['contextId'] as String?;
        if (contextId == null) return;
        // The publisher already merged locally; re-fetching would find nothing
        // and cost a round-trip on every message this device itself caused.
        if (payload['senderDeviceId'] == mls.deviceIdService.deviceIdOrNull) {
          return;
        }
        final isChannel = payload['channelId'] != null;
        _guard(
          'apply MLS commits for $contextId',
          () => sync.syncContext(contextId, isChannel),
        );

      // Encryption was switched on or off. Re-reading the state is what stops
      // this client encrypting to a group that has been replaced, or sending
      // plaintext into one that has not.
      case 'conversation.MlsStateChanged':
        final contextId = event.objectPayload['contextId'] as String?;
        if (contextId == null) return;
        final isChannel = event.objectPayload['channelId'] != null;
        _guard(
          'refresh MLS state for $contextId',
          () => sync.refreshState(contextId, isChannel),
        );

      case 'guild.ChannelMlsStateChanged':
        final channelId = event.objectPayload['channelId'] as String?;
        if (channelId == null) return;
        _guard(
          'refresh MLS state for channel $channelId',
          () => sync.refreshState(channelId, true),
        );

      // A device wants in. Only *our own* devices are handled automatically -
      // a peer's new device is their business, and §G.4 is explicit that our
      // protection level governs our devices and nobody else's. A peer's
      // request still reaches the review queue in the UI.
      case 'conversation.MlsJoinRequest':
        final payload = event.objectPayload;
        final contextId = payload['contextId'] as String?;
        final requestId = payload['requestId'] as String?;
        final requesterUserId = payload['requesterUserId'] as String?;
        if (contextId == null || requestId == null) return;

        final ownUserId = authRepository.currentUserId;
        if (ownUserId == null || requesterUserId != ownUserId) return;

        final isChannel = payload['channelId'] != null;
        _guard(
          'handle a join request for $contextId',
          () => _handleOwnAccountRequest(
            contextId: contextId,
            isChannel: isChannel,
            requestId: requestId,
            userId: ownUserId,
          ),
        );
    }
  }

  /// Contract §E9, from both sides of a removal.
  ///
  /// The payload is one push per affected context
  /// (`DeviceRemovedHandler.cs:132`): `contextId`, `conversationId`,
  /// `channelId`, `generation`, `epoch`, and the `userId`/`deviceId` of the
  /// device that was **removed**. Note the field is `deviceId`, not the
  /// `senderDeviceId` the other MLS pushes carry.
  ///
  /// Two entirely different jobs depending on who was removed:
  ///
  /// * **This device.** Record it, per context, so the launch sweep stops asking
  ///   to be let back in. Nothing else - this device is out, and syncing would
  ///   fetch commits it cannot apply.
  /// * **Anyone else.** Catch up, which is what discovers the removal and
  ///   produces the Remove commit for it. The server cannot mint one; only a
  ///   member's client can, and nothing on this client did.
  ///
  /// The `userId` check is not redundant with the `deviceId` one.
  /// `ClientDeviceId` is chosen by the client and unique only per account, so a
  /// co-member can register a device under an id that matches ours - and the
  /// bare id alone would let them suppress our sweep for a conversation nobody
  /// removed us from. Echo scopes every query in this handler by user for the
  /// same reason; this is the client half of it.
  void _handleDeviceRemoved(RealtimeEvent event) {
    final payload = event.objectPayload;
    final contextId = payload['contextId'] as String?;
    if (contextId == null) return;

    final removedUserId = payload['userId'] as String?;
    final removedDeviceId = payload['deviceId'] as String?;
    final ownUserId = authRepository.currentUserId;
    final ownDeviceId = mls.deviceIdService.deviceIdOrNull;

    final wasThisDevice =
        removedUserId != null &&
        removedDeviceId != null &&
        removedUserId == ownUserId &&
        removedDeviceId == ownDeviceId;

    if (wasThisDevice) {
      _guard(
        'record this device\'s removal from $contextId',
        () => mls.recordRemovedHere(contextId),
      );
      return;
    }

    if (!mls.isUnlocked) return;
    final isChannel = payload['channelId'] != null;
    _guard(
      'catch up after a device removal in $contextId',
      () => sync.syncContext(contextId, isChannel),
    );
  }

  /// Contract §G.1, from whichever side of the ceremony this device is on.
  ///
  /// The push goes to **every** member of the conversation including the
  /// requester's own account (Echo `MlsEndpoints.cs:451-462`, per §L.3), because
  /// the requester's *other* devices are the only party holding the account
  /// master key and therefore the only party that can verify the proof. So this
  /// handler receives the same event on both devices and the two have opposite
  /// jobs: one answers the challenge, the other issues it.
  ///
  /// It used to assume it was always the admitting device. The joining device
  /// therefore challenged its own request - which the server refuses outright -
  /// and never signed anything, so the admitting side sat on `awaitingProof`
  /// forever and no own-device admission ever completed.
  ///
  /// The branch is taken on `requesterDeviceId` from the *listed* request rather
  /// than from the push, because the fetch is needed anyway - it is the only
  /// route to the key package (§L.3) - and one authoritative read beats two
  /// sources that can disagree.
  Future<void> _handleOwnAccountRequest({
    required String contextId,
    required bool isChannel,
    required String requestId,
    required String userId,
  }) async {
    final requests = await api.listJoinRequests(
      contextId: contextId,
      isChannel: isChannel,
    );
    final request = requests.where((r) => r.id == requestId).firstOrNull;
    if (request == null) return;

    final ownDeviceId = mls.deviceIdService.deviceIdOrNull;
    if (ownDeviceId == null) return;

    if (request.requesterDeviceId == ownDeviceId) {
      await _answerOwnChallenge(
        contextId: contextId,
        isChannel: isChannel,
        request: request,
        userId: userId,
      );
      return;
    }

    await _admitOwnDevice(
      contextId: contextId,
      isChannel: isChannel,
      request: request,
      userId: userId,
    );
  }

  /// The joining side: contract §G.1 step 3.
  ///
  /// Reached on the handset that asked to be let in. Nothing here can admit
  /// anything - it holds no group - so the whole job is to sign the nonce
  /// another of our devices chose, which is what unblocks that device.
  ///
  /// Runs on the same push that started the other side, so on the first pass
  /// there is usually no challenge yet and this is a no-op. The re-nudge is the
  /// admitting device's challenge landing, which the server relays as another
  /// `conversation.MlsJoinRequest` for the same request.
  Future<void> _answerOwnChallenge({
    required String contextId,
    required bool isChannel,
    required MlsJoinRequestDto request,
    required String userId,
  }) async {
    final answered = await admission.answerChallenge(
      contextId: contextId,
      isChannel: isChannel,
      requestId: request.id,
      userId: userId,
      // The fingerprint the verifier will check against is the one on the
      // request record, so that is what has to go into the MAC. A server that
      // altered it gains nothing: `MlsJoinRequestService.admit` re-derives the
      // fingerprint from the key package bytes before adding anything, so a
      // record that disagrees with its own key package fails there instead.
      signatureKeyFingerprint: request.signatureKeyFingerprint,
    );
    debugPrint(
      answered
          ? 'MLS: answered the admission challenge for ${request.id}'
          : 'MLS: no admission challenge to answer for ${request.id} yet',
    );
  }

  /// The admitting side: contract §G.1, steps 2 and 4.
  ///
  /// Issue a challenge, wait for the joining device to MAC it under the account
  /// master key, verify that locally, and only then mint the Add commit. The
  /// server relays and can forge nothing, because it never holds the master key
  /// - which is the whole reason automatic admission is not "trust the server".
  Future<void> _admitOwnDevice({
    required String contextId,
    required bool isChannel,
    required MlsJoinRequestDto request,
    required String userId,
  }) async {
    // Idempotent server-side, so a second nudge for the same request costs a
    // round trip rather than invalidating the challenge already in flight.
    await admission.challenge(
      contextId: contextId,
      isChannel: isChannel,
      request: request,
      userId: userId,
    );

    // The proof will not be there yet - the joining device has to be told about
    // the challenge first. `tryAdmit` returns `awaitingProof` and the next nudge,
    // or the review screen, picks it up. Deliberately not polled: a device that
    // never answers is a device that should need a human.
    final outcome = await admission.tryAdmit(
      contextId: contextId,
      isChannel: isChannel,
      request: request,
      userId: userId,
      // The server hands these back only for the calling account's own requests,
      // which is exactly this branch. Passing the empty string here instead -
      // which is what happened while the DTO had no field to carry them - made
      // `inspectKeyPackage` fail on every single automatic admission.
      keyPackage: request.keyPackage,
    );
    debugPrint(
      'MLS: admission for ${request.id} in $contextId: ${outcome.name}',
    );
  }

  /// These run detached from any UI. A failure means one context is temporarily
  /// unreadable and the next nudge or launch retries - it must never surface as
  /// an unhandled async error.
  void _guard(String what, Future<void> Function() work) {
    unawaited(
      work().catchError((Object e) {
        debugPrint('MLS: failed to $what: $e');
      }),
    );
  }
}
