import 'package:flutter/material.dart';

import '../data/bot_modal_api.dart';
import '../data/bot_modal_service.dart';
import '../data/models/bot_modal_dtos.dart';
import 'widgets/bot_modal_dialog.dart';

/// Puts whatever is in [BotModalService.request] on screen, over whatever the
/// user happens to be looking at.
///
/// A bot answers a slash command on its own schedule, so the modal has to be
/// able to arrive at any moment and from any screen - including a screen
/// outside `AppShell`. This is therefore the same mechanism the invite deep
/// link uses and not a second one: the router's own navigator context plus
/// `showDialog`, which raises the route on the *root* navigator and so sits
/// above the shell, above a pushed call screen, and above anything else that is
/// up at the time.
///
/// Deliberately not a widget. A widget mounted in `MaterialApp.builder` sits
/// *above* the navigator and has no `Navigator` to raise a dialog from; one
/// mounted inside `AppShell` would not exist on the screens outside it. Holding
/// the navigator's context in a plain listener is what lets one object cover
/// both.
class BotModalPresenter {
  BotModalPresenter({
    required this.service,
    required this.api,
    required this.navigatorContext,
  });

  final BotModalService service;
  final BotModalApi api;

  /// Resolves the router's navigator context, or null before the first frame.
  /// A callback rather than the context itself because the navigator is built
  /// after this is constructed, and the one that is live changes across a hot
  /// restart.
  final BuildContext? Function() navigatorContext;

  /// Whether the dialog route is currently up. The route itself is the source
  /// of truth for this - see the `whenComplete` below - so the barrier, the
  /// system back button, Cancel and a successful submit all clear it by the
  /// same path.
  bool _dialogOpen = false;

  void start() {
    service.request.addListener(_present);
    // A modal that landed before this was wired up - realistically only during
    // a hot restart, since the service is resolved at launch - would otherwise
    // sit in the notifier with nothing watching it.
    _present();
  }

  void stop() => service.request.removeListener(_present);

  /// [attempt] exists for the same reason the invite dialog's does: the
  /// navigator's context is null until the first frame, and dropping the
  /// request there would silently discard the whole point of the push. Gives up
  /// after twenty frames rather than spinning forever if no navigator ever
  /// appears.
  void _present({int attempt = 0}) {
    final request = service.request.value;
    // Not a mistake that this does nothing while a dialog is already up: the
    // dialog reads the notifier itself and re-seeds in place, which is what
    // "last one wins" has to mean when the route is already on screen.
    if (request == null || _dialogOpen) return;

    final context = navigatorContext();
    if (context == null) {
      if (attempt >= 20) return;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _present(attempt: attempt + 1),
      );
      return;
    }

    _dialogOpen = true;
    showDialog<void>(
      context: context,
      builder: (_) => BotModalDialog(service: service, api: api),
    ).whenComplete(() => _onDialogClosed(request));
  }

  /// [shown] is the payload the route that has just gone away was showing.
  ///
  /// The identity check is what stops a modal that arrived *during* the pop
  /// animation from being thrown away by the closing dialog's own cleanup - and
  /// the re-entrant [_present] is what then puts it up, since the notifier
  /// fired while `_dialogOpen` was still true and nothing else will ask again.
  void _onDialogClosed(BotModalOpenDto shown) {
    _dialogOpen = false;
    if (identical(service.request.value, shown)) {
      service.close();
      return;
    }
    _present();
  }
}
