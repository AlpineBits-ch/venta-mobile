import 'dart:async';

import 'package:flutter/foundation.dart';

import '../realtime/realtime_event.dart';
import '../realtime/realtime_service.dart';
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
  });

  final RealtimeService realtimeService;
  final MlsService mls;
  final MlsSyncService sync;

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
  };

  void _handle(RealtimeEvent event) {
    // Nothing here can do anything useful while locked, and several of these
    // would otherwise fetch a page of commits only to discard it.
    if (!mls.isUnlocked) return;

    switch (event.name) {
      // The push names a context but carries nothing else: the fetch behind it
      // is device-scoped, and the Welcome is acknowledged only once its join has
      // actually worked.
      case 'conversation.Welcome':
        _guard(
          'process pending Welcomes',
          () => sync.processPendingWelcomes(),
        );

      // A commit landed. Group state advances by fetching commits above our own
      // epoch and applying them in order, never in push-arrival order.
      case 'conversation.MlsCommit':
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
    }
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
