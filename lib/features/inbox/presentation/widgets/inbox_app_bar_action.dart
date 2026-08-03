import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/routing/route_paths.dart';
import '../../data/inbox_repository.dart';
import '../../data/models/inbox_summary_dto.dart';

/// The inbox button, with its unread/mention badge - Discord's tray icon, in
/// the app bar of the two surfaces it belongs on (Home and a guild).
///
/// Reads `InboxRepository.summary` directly rather than through a bloc: the
/// badge outlives every screen that shows it, is kept current from the hub
/// between fetches, and has exactly one piece of state.
class InboxAppBarAction extends StatefulWidget {
  const InboxAppBarAction({super.key, this.guildId});

  /// Passed through so the Mentions tab can offer to scope itself to the
  /// guild the inbox was opened from.
  final String? guildId;

  @override
  State<InboxAppBarAction> createState() => _InboxAppBarActionState();
}

class _InboxAppBarActionState extends State<InboxAppBarAction> {
  @override
  void initState() {
    super.initState();
    // Cheap, but not free - fetched when a surface carrying the badge mounts,
    // and kept current from `inbox.MentionAdded`/`inbox.ReadStateChanged`
    // after that rather than polled.
    getIt<InboxRepository>().refreshSummary().catchError((
      Object e,
      StackTrace st,
    ) {
      debugPrint('inbox summary fetch failed: $e\n$st');
      return getIt<InboxRepository>().summary.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<InboxSummaryDto>(
      valueListenable: getIt<InboxRepository>().summary,
      builder: (context, summary, child) {
        final button = IconButton(
          icon: Icon(
            // Filled once there's something in it, so the state reads without
            // needing the badge to be legible at a glance.
            summary.hasAnything ? Icons.inbox : Icons.inbox_outlined,
            // A channel that is merely unread doesn't get the dot - only a
            // mention does, matching how the rest of the app treats the two.
            color: summary.hasAnything ? theme.colorScheme.primary : null,
          ),
          tooltip: 'Inbox',
          onPressed: () =>
              context.push(RoutePaths.inboxPath(guildId: widget.guildId)),
        );
        if (!summary.hasMentions) return button;
        return Badge(
          label: Text(summary.badgeLabel),
          backgroundColor: theme.colorScheme.error,
          textColor: theme.colorScheme.onError,
          child: button,
        );
      },
    );
  }
}
