import 'package:flutter/material.dart';

import '../../../../core/format/date_time_format.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../data/models/inbox_mention_dto.dart';
import 'inbox_breadcrumb_header.dart';
import 'inbox_message_line.dart';

/// One row in the Mentions tab.
///
/// The ✕ is only drawn for a mention that can actually be dismissed: an
/// `@everyone` or `@role` ping isn't a per-user row, so the server accepts the
/// delete and removes nothing. Showing the affordance anyway would be a button
/// that appears to work and doesn't.
class InboxMentionTile extends StatelessWidget {
  const InboxMentionTile({
    super.key,
    required this.mention,
    required this.onOpen,
    required this.onDismiss,
    this.dismissing = false,
  });

  final InboxMentionDto mention;
  final VoidCallback onOpen;
  final VoidCallback onDismiss;
  final bool dismissing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final breadcrumb = mention.breadcrumb;
    final createdAt = mention.createdAt;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.xs,
        AppSpacing.m,
        AppSpacing.xs,
      ),
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(AppRadii.card),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (breadcrumb != null)
                  InboxBreadcrumbHeader(
                    breadcrumb: breadcrumb,
                    iconSize: 28,
                    trailing: _trailing(context, createdAt),
                  )
                else
                  _DirectMessageHeader(trailing: _trailing(context, createdAt)),
                const SizedBox(height: AppSpacing.s),
                Row(
                  children: [
                    _KindChip(mention: mention),
                    if (mention.kind == InboxMentionKind.here) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          'you were online',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: muted,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (mention.message != null) ...[
                  const SizedBox(height: AppSpacing.s),
                  InboxMessageLine(message: mention.message!, maxLines: 3),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _trailing(BuildContext context, DateTime? createdAt) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (createdAt != null)
          Text(
            formatCompactAgo(createdAt),
            style: theme.textTheme.labelSmall?.copyWith(color: muted),
          ),
        if (mention.kind.isDismissible)
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            visualDensity: VisualDensity.compact,
            tooltip: 'Dismiss',
            color: muted,
            onPressed: dismissing ? null : onDismiss,
          ),
      ],
    );
  }
}

/// A DM mention has no guild, category or channel to name - and no icon to
/// fetch, since a conversation isn't a guild.
class _DirectMessageHeader extends StatelessWidget {
  const _DirectMessageHeader({required this.trailing});

  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadii.chip),
          ),
          child: Icon(
            Icons.alternate_email,
            size: 16,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.s + AppSpacing.xs),
        Expanded(
          child: Text(
            'Direct message',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        trailing,
      ],
    );
  }
}

/// Which way the caller was reached. Named rather than assumed: being pinged
/// by name and being caught by an `@everyone` are different enough that the
/// row should say which happened.
class _KindChip extends StatelessWidget {
  const _KindChip({required this.mention});

  final InboxMentionDto mention;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final direct = mention.kind == InboxMentionKind.direct;
    final color = direct
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.6);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.chip),
      ),
      child: Text(
        mention.kindLabel,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
