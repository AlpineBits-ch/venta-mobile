import 'package:flutter/material.dart';

import '../theme/widget_styles.dart';

/// A caption above a list whose rows do nothing when tapped.
///
/// `ListTile` rows read as pressable whether or not they have an `onTap` -
/// nothing about a row announces its own inertness, so a read-only list looks
/// like a broken one. Both lists that need this (message search, pinned
/// messages) are read-only for the same reason: `ThreadView` has no
/// scroll-to-index infrastructure to jump to, so say that rather than let
/// people keep testing it.
class ReadOnlyNotice extends StatelessWidget {
  const ReadOnlyNotice(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.55);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.s,
        AppSpacing.m,
        AppSpacing.s,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 14, color: muted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.labelSmall?.copyWith(
                color: muted,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
