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
            // Filled once there's something in it, so the state still reads at
            // a glance on a narrow app bar where the badge is small.
            summary.hasAnything ? Icons.inbox : Icons.inbox_outlined,
            color: summary.hasAnything ? theme.colorScheme.primary : null,
          ),
          tooltip: summary.badgeBreakdown,
          onPressed: () =>
              context.push(RoutePaths.inboxPath(guildId: widget.guildId)),
        );
        // Badged for anything at all, not just mentions: "is there anything in
        // there" is the question this button exists to answer, and an unread
        // channel is an answer of yes.
        if (!summary.hasAnything) return button;
        return Badge(
          label: Text(summary.badgeLabel),
          // Red keeps meaning "somebody wants you". Unread-only stays on the
          // brand colour so a busy server doesn't cry wolf and leave the real
          // mention badge indistinguishable from noise.
          backgroundColor: summary.hasMentions
              ? theme.colorScheme.error
              : theme.colorScheme.primary,
          textColor: summary.hasMentions
              ? theme.colorScheme.onError
              : theme.colorScheme.onPrimary,
          child: button,
        );
      },
    );
  }
}
