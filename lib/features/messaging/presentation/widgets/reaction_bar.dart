import 'package:flutter/material.dart';

import '../../../../core/theme/widget_styles.dart';
import '../../data/models/message_reaction_dto.dart';

class _ReactionGroup {
  _ReactionGroup(this.emoji);
  final String emoji;
  int count = 0;
  bool hasOwn = false;
}

/// Grouped, counted reaction pills under a message — tapping a pill toggles
/// the caller's own reaction for that emoji; the trailing `+` opens the full
/// picker. Own-reaction pills get a brand-tinted fill so "did I react to
/// this" reads at a glance, matching Alpine's reaction bar.
class MessageReactionBar extends StatelessWidget {
  const MessageReactionBar({
    super.key,
    required this.reactions,
    required this.myUserId,
    required this.onToggle,
    required this.onAddPressed,
  });

  final List<MessageReactionDto> reactions;
  final String myUserId;
  final ValueChanged<String> onToggle;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) return const SizedBox.shrink();

    final groups = <String, _ReactionGroup>{};
    for (final reaction in reactions) {
      final group = groups.putIfAbsent(
        reaction.emoji,
        () => _ReactionGroup(reaction.emoji),
      );
      group.count++;
      if (reaction.userId == myUserId) group.hasOwn = true;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          for (final group in groups.values)
            _ReactionPill(
              emoji: group.emoji,
              count: group.count,
              isOwn: group.hasOwn,
              onTap: () => onToggle(group.emoji),
            ),
          _AddReactionPill(onTap: onAddPressed),
        ],
      ),
    );
  }
}

class _ReactionPill extends StatelessWidget {
  const _ReactionPill({
    required this.emoji,
    required this.count,
    required this.isOwn,
    required this.onTap,
  });

  final String emoji;
  final int count;
  final bool isOwn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: isOwn
          ? theme.colorScheme.primary.withValues(alpha: 0.16)
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppRadii.chip * 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.chip * 2),
        // ConstrainedBox + Center(...Factor: 1) gives a *minimum* 36x36 tap
        // target without the classic Container(alignment: ...) trap, which
        // expands to fill all available cross-axis space inside a Wrap
        // instead of shrink-wrapping — that bug is what stacked these pills
        // into a full-width vertical list instead of a horizontal row.
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 36, minWidth: 36),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.chip * 2),
                border: Border.all(
                  color: isOwn
                      ? theme.colorScheme.primary.withValues(alpha: 0.6)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 15)),
                  const SizedBox(width: 5),
                  Text(
                    '$count',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isOwn ? theme.colorScheme.primary : null,
                      fontWeight: isOwn ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddReactionPill extends StatelessWidget {
  const _AddReactionPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppRadii.chip * 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.chip * 2),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 36, minWidth: 36),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: Icon(
              Icons.add_reaction_outlined,
              size: 17,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}
