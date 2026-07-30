import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../guilds/data/guild_repository.dart';
import '../../data/models/message_reaction_dto.dart';

class _ReactionGroup {
  _ReactionGroup(this.emoji, this.emojiId);
  final String emoji;
  final String? emojiId;
  int count = 0;
  bool hasOwn = false;
}

/// Grouped, counted reaction pills under a message - tapping a pill toggles
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
    this.guildId,
  });

  final List<MessageReactionDto> reactions;
  final String myUserId;
  final void Function(String emoji, String? emojiId) onToggle;
  final VoidCallback onAddPressed;

  /// Set for guild channels - resolves `emojiId` against the guild's
  /// cached custom emoji list to render the actual image.
  final String? guildId;

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) return const SizedBox.shrink();

    final groups = <String, _ReactionGroup>{};
    for (final reaction in reactions) {
      final key = reaction.emojiId ?? reaction.emoji;
      final group = groups.putIfAbsent(
        key,
        () => _ReactionGroup(reaction.emoji, reaction.emojiId),
      );
      group.count++;
      if (reaction.userId == myUserId) group.hasOwn = true;
    }

    final customEmoji = guildId != null
        ? getIt<GuildRepository>().cachedEmojis(guildId!)
        : null;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          for (final group in groups.values)
            _ReactionPill(
              emoji: group.emoji,
              imageUrl: group.emojiId != null
                  ? customEmoji
                        ?.where((e) => e.id == group.emojiId)
                        .firstOrNull
                        ?.imageUrl
                  : null,
              count: group.count,
              isOwn: group.hasOwn,
              onTap: () => onToggle(group.emoji, group.emojiId),
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
    this.imageUrl,
  });

  final String emoji;
  final String? imageUrl;
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
        // instead of shrink-wrapping - that bug is what stacked these pills
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
                  imageUrl != null
                      ? Image.network(
                          imageUrl!,
                          width: 15,
                          height: 15,
                          errorBuilder: (context, error, stack) => Text(
                            ':$emoji:',
                            style: const TextStyle(fontSize: 11),
                          ),
                        )
                      : Text(emoji, style: const TextStyle(fontSize: 15)),
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
