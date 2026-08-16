import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/realtime/realtime_event.dart';
import '../../../core/realtime/realtime_service.dart';
import 'models/bot_modal_dtos.dart';

/// Holds the modal a bot has asked this client to show.
///
/// One app-lifetime singleton with one [ValueNotifier], and a presenter that
/// puts whatever is in it on screen - the same shape as `StatusRepository` and
/// its banner, and the same shape Alpine's `BotModalDialogService` has. A
/// service rather than a cubit for the reason `MlsRealtimeBridge` is one: this
/// has to survive every screen the user is on, including no screen at all
/// while the app is being rebuilt, and a subscription owned by a widget can be
/// dropped by a background-to-foreground transition.
///
/// **Last one wins.** A bot can only have one modal on screen at a time, and
/// queueing them would leave a stale form standing over an interaction the user
/// has already moved on from - the bot's first question having been answered by
/// the very submit that produced the second.
class BotModalService {
  BotModalService({required RealtimeService realtimeService}) {
    _subscription = realtimeService.events
        .where((e) => e.name == _eventName)
        .listen(_handle);
  }

  /// Server->client only. The answer leaves over REST, not the hub - see
  /// `BotModalApi.submitModal`.
  static const _eventName = 'guild.ModalOpen';

  final ValueNotifier<BotModalOpenDto?> request =
      ValueNotifier<BotModalOpenDto?>(null);

  StreamSubscription<RealtimeEvent>? _subscription;

  void _handle(RealtimeEvent event) {
    final payload = event.objectPayload;
    if (payload.isEmpty) return;
    try {
      request.value = BotModalOpenDto.fromJson(payload);
    } catch (e) {
      // A malformed push is one bot's form not opening, not a reason to take
      // the realtime stream down with an unhandled decode error. Every field
      // the DTO reads is defaulted or nullable, so reaching here means the
      // argument was not an object at all.
      debugPrint('guild.ModalOpen: could not read the payload: $e');
    }
  }

  /// Takes the current modal off screen. Called when the user dismisses it,
  /// when a submit is accepted, and whenever the dialog route goes away for any
  /// other reason - see `BotModalPresenter`, which treats the route
  /// disappearing as the single source of truth for "this is closed".
  void close() => request.value = null;

  /// Sign-out. A form a bot asked the *previous* account to fill in must not be
  /// standing over the next one's first screen: it is addressed to a user id
  /// that is no longer signed in, and the submit behind it would be made with
  /// the new account's credentials against the old account's interaction.
  void clear() => request.value = null;

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    request.dispose();
  }
}
