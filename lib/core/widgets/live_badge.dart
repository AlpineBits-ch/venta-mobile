import 'package:flutter/material.dart';

import '../theme/widget_styles.dart';

/// Discord's "LIVE" flag - the red pill shown against a voice participant who
/// is screen sharing. Shape and typography deliberately match the "BOT" tag in
/// the member/message rows so the two read as one family of badges; the colour
/// is `error` rather than `primary` because live-ness is the loud state.
///
/// Drawn from theme roles even on the always-dark call chrome: `error`/`onError`
/// are the same red-on-white in both themes, so it needs no dark-only variant.
class LiveBadge extends StatelessWidget {
  const LiveBadge({super.key, this.viewerCount = 0});

  /// Watchers of the share, appended after an eye glyph. Left at zero by
  /// callers with no room for it (the channel-list roster), which then get the
  /// bare word.
  final int viewerCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onError,
      fontWeight: FontWeight.bold,
      fontSize: 9,
      letterSpacing: 0.4,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: theme.colorScheme.error,
        borderRadius: BorderRadius.circular(AppRadii.badge),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('LIVE', style: labelStyle),
          if (viewerCount > 0) ...[
            const SizedBox(width: AppSpacing.xs),
            Icon(Icons.visibility, size: 10, color: theme.colorScheme.onError),
            const SizedBox(width: 2),
            Text('$viewerCount', style: labelStyle),
          ],
        ],
      ),
    );
  }
}
