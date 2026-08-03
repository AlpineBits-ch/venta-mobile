import 'package:flutter/material.dart';

import '../../../../core/format/date_time_format.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../data/models/inbox_unread_dto.dart';
import 'inbox_breadcrumb_header.dart';
import 'inbox_message_line.dart';

/// One unread channel, with as much of what was said in it as the server sent.
///
/// The two counts are drawn differently on purpose. [InboxUnreadGroupDto.
/// mentionCount] is exact and gets the red badge people act on;
/// [InboxUnreadGroupDto.unreadCount] is derived from denormalised counters that
/// drift under message loss, so it is a muted "N new" pill that reads as a
/// rough sense of volume rather than a number worth trusting.
class InboxUnreadCard extends StatelessWidget {
  const InboxUnreadCard({
    super.key,
    required this.group,
    required this.onOpen,
    required this.onMarkRead,
    this.previewsUnavailable = false,
    this.markingRead = false,
  });

  final InboxUnreadGroupDto group;
  final VoidCallback onOpen;
  final VoidCallback onMarkRead;

  /// The message service was unreachable, so [InboxUnreadGroupDto.previews] is
  /// empty for a reason that has nothing to do with this channel.
  final bool previewsUnavailable;

  final bool markingRead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final lastActivityAt = group.lastActivityAt;

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
                InboxBreadcrumbHeader(
                  breadcrumb: group.breadcrumb,
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (lastActivityAt != null)
                        Text(
                          formatCompactAgo(lastActivityAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: muted,
                          ),
                        ),
                      if (group.mentionCount > 0) ...[
                        const SizedBox(height: AppSpacing.xs),
                        _MentionBadge(count: group.mentionCount),
                      ],
                    ],
                  ),
                ),
                if (group.previews.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.s + AppSpacing.xs),
                  if (group.previewsTruncated)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Text(
                        'Earlier messages above',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: muted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  for (final preview in group.previews)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: InboxMessageLine(message: preview),
                    ),
                ] else if (previewsUnavailable) ...[
                  const SizedBox(height: AppSpacing.s),
                  Row(
                    children: [
                      Icon(Icons.sync_problem_outlined, size: 14, color: muted),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          'Messages are still loading',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    if (group.unreadCount > 0)
                      Text(
                        '${group.unreadCount} new',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: muted,
                        ),
                      ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: markingRead ? null : onMarkRead,
                      icon: const Icon(Icons.done_all, size: 16),
                      label: const Text('Mark as read'),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The exact-count badge. Same shape as the DM list's, so a number means the
/// same thing wherever it appears.
class _MentionBadge extends StatelessWidget {
  const _MentionBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: theme.colorScheme.error,
        borderRadius: BorderRadius.circular(AppRadii.chip),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onError,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
