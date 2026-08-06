import 'package:flutter/material.dart';

import '../../../../core/format/date_time_format.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../data/models/inbox_task_dto.dart';
import 'inbox_breadcrumb_header.dart';

/// One household row waiting on the caller: a chore due, a decision unvoted, a
/// list item with their name on it.
///
/// Everything rendered here comes off the row - [InboxTaskDto.title] and
/// [InboxTaskDto.subtitle] are written server-side - so a kind this build has
/// never heard of still reads correctly and still lands somewhere. That is the
/// point of the design: more kinds are coming, and the only per-kind decision
/// made here is which icon to draw.
class InboxTaskTile extends StatelessWidget {
  const InboxTaskTile({super.key, required this.task, required this.onOpen});

  final InboxTaskDto task;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final dueAt = task.dueAt;

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
                InboxBreadcrumbHeader(breadcrumb: task.breadcrumb),
                const SizedBox(height: AppSpacing.s + AppSpacing.xs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      task.kind.icon,
                      size: 18,
                      color: task.isOverdue
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (task.subtitle.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              task.subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: muted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (dueAt != null || task.isOverdue) ...[
                  const SizedBox(height: AppSpacing.s),
                  Row(
                    children: [
                      // The server's flag, never re-derived from `dueAt`: a
                      // chore two hours late inside a 24-hour grace period is
                      // not overdue, and only the server knows the grace.
                      if (task.isOverdue)
                        _OverduePill(theme: theme)
                      else if (dueAt != null)
                        Text(
                          formatDueLabel(dueAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: muted,
                          ),
                        ),
                      if (task.isOverdue && dueAt != null) ...[
                        const SizedBox(width: AppSpacing.s),
                        Text(
                          formatDueLabel(dueAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: muted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OverduePill extends StatelessWidget {
  const _OverduePill({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: theme.colorScheme.error,
        borderRadius: BorderRadius.circular(AppRadii.chip),
      ),
      child: Text(
        'Overdue',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onError,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
