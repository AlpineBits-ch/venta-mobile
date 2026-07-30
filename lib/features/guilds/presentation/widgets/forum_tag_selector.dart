import 'package:flutter/material.dart';

import '../../../../core/theme/widget_styles.dart';
import '../../data/models/forum_tag_dto.dart';
import '../../data/models/guild_emoji_dto.dart';
import 'forum_tag_chip.dart';

/// The wrap of selectable tag chips shared by "new post" and "edit tags".
///
/// `moderated` tags are filtered out entirely for members who can't apply
/// them - showing-then-rejecting would fail the *whole* write with a `403`,
/// not silently drop the tag - and the 5-per-post cap is enforced here rather
/// than round-tripping into a `400`.
class ForumTagSelector extends StatelessWidget {
  const ForumTagSelector({
    super.key,
    required this.tags,
    required this.selectedTagIds,
    required this.onChanged,
    this.guildEmojis,
    this.canApplyModerated = false,
  });

  final List<ForumTagDto> tags;
  final Set<String> selectedTagIds;
  final ValueChanged<Set<String>> onChanged;
  final List<GuildEmojiDto>? guildEmojis;
  final bool canApplyModerated;

  /// Tags a post carries that the caller may not toggle - a moderator's
  /// `confirmed-bug` stays visible to its author, just not removable.
  bool _isLocked(ForumTagDto tag) => tag.moderated && !canApplyModerated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visible = [
      for (final tag in tags)
        if (!_isLocked(tag) || selectedTagIds.contains(tag.id)) tag,
    ];
    if (visible.isEmpty) {
      return Text(
        'This forum has no tags yet.',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      );
    }
    final atCap = selectedTagIds.length >= ForumTagLimits.appliedTagsPerPost;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final tag in visible)
              Opacity(
                opacity:
                    (atCap && !selectedTagIds.contains(tag.id)) ||
                        _isLocked(tag)
                    ? 0.45
                    : 1,
                child: ForumTagChip(
                  tag: tag,
                  emojiImageUrl: forumTagEmojiUrl(tag, guildEmojis),
                  selected: selectedTagIds.contains(tag.id),
                  onTap: _isLocked(tag)
                      ? null
                      : () {
                          final next = {...selectedTagIds};
                          if (!next.remove(tag.id)) {
                            if (atCap) return;
                            next.add(tag.id);
                          }
                          onChanged(next);
                        },
                ),
              ),
          ],
        ),
        if (atCap) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Up to ${ForumTagLimits.appliedTagsPerPost} tags per post.',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ],
    );
  }
}

/// Standalone "edit this post's tags" sheet. Resolves to the complete desired
/// set (the tags endpoint has replace semantics), or null if dismissed.
Future<Set<String>?> showForumTagPickerSheet(
  BuildContext context, {
  required List<ForumTagDto> tags,
  required Set<String> initialSelection,
  List<GuildEmojiDto>? guildEmojis,
  bool canApplyModerated = false,
  bool requireTag = false,
}) {
  return showModalBottomSheet<Set<String>>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (sheetContext) => _TagPickerSheet(
      tags: tags,
      initialSelection: initialSelection,
      guildEmojis: guildEmojis,
      canApplyModerated: canApplyModerated,
      requireTag: requireTag,
    ),
  );
}

class _TagPickerSheet extends StatefulWidget {
  const _TagPickerSheet({
    required this.tags,
    required this.initialSelection,
    required this.guildEmojis,
    required this.canApplyModerated,
    required this.requireTag,
  });

  final List<ForumTagDto> tags;
  final Set<String> initialSelection;
  final List<GuildEmojiDto>? guildEmojis;
  final bool canApplyModerated;
  final bool requireTag;

  @override
  State<_TagPickerSheet> createState() => _TagPickerSheetState();
}

class _TagPickerSheetState extends State<_TagPickerSheet> {
  late Set<String> _selected = {...widget.initialSelection};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final blocked = widget.requireTag && _selected.isEmpty;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Tags', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.m),
            Flexible(
              child: SingleChildScrollView(
                child: ForumTagSelector(
                  tags: widget.tags,
                  selectedTagIds: _selected,
                  guildEmojis: widget.guildEmojis,
                  canApplyModerated: widget.canApplyModerated,
                  onChanged: (next) => setState(() => _selected = next),
                ),
              ),
            ),
            if (blocked) ...[
              const SizedBox(height: AppSpacing.s),
              Text(
                'This forum requires at least one tag.',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.l),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: AppSpacing.s),
                FilledButton(
                  onPressed: blocked
                      ? null
                      : () => Navigator.of(context).pop(_selected),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
