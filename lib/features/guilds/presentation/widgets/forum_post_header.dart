import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../data/guild_repository.dart';
import '../../data/models/channel_dto.dart';
import '../../data/models/forum_tag_dto.dart';
import '../../data/models/guild_emoji_dto.dart';
import 'forum_tag_chip.dart';

/// The strip under a forum post's app bar: its applied tags, plus an archived
/// note when it has one.
///
/// A post's tags live on the post, but their names, colours and emoji live on
/// the *forum*, so this resolves them against the parent channel's tag list.
/// Renders nothing at all for an untagged, unarchived post rather than leaving
/// an empty band above the messages.
class ForumPostHeader extends StatefulWidget {
  const ForumPostHeader({super.key, required this.guildId, required this.post});

  final String guildId;

  /// The post itself - a `Thread` channel parented to a Forum/Media channel.
  final ChannelDto post;

  @override
  State<ForumPostHeader> createState() => _ForumPostHeaderState();
}

class _ForumPostHeaderState extends State<ForumPostHeader> {
  List<ForumTagDto> _tags = const [];
  List<GuildEmojiDto>? _guildEmojis;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void didUpdateWidget(covariant ForumPostHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.parentChannelId != widget.post.parentChannelId) {
      unawaited(_load());
    }
  }

  Future<void> _load() async {
    final forumId = widget.post.parentChannelId;
    if (forumId == null || widget.post.tagIds.isEmpty) return;
    try {
      final repository = getIt<GuildRepository>();
      final tags = await repository.getForumTags(forumId);
      if (!mounted) return;
      setState(() => _tags = tags);
      if (tags.any((t) => t.emojiId != null)) {
        final emojis = await repository.getEmojis(widget.guildId);
        if (mounted) setState(() => _guildEmojis = emojis);
      }
    } catch (_) {
      // Without the tag list the chips just stay out; the post reads fine.
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final applied = [
      for (final id in widget.post.tagIds) ..._tags.where((t) => t.id == id),
    ];
    if (applied.isEmpty && !widget.post.isArchived) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.s,
        AppSpacing.m,
        AppSpacing.s,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (widget.post.isArchived)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.archive_outlined,
                  size: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  'Archived - posting here brings it back',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          for (final tag in applied)
            ForumTagChip(
              tag: tag,
              emojiImageUrl: forumTagEmojiUrl(tag, _guildEmojis),
              dense: true,
            ),
        ],
      ),
    );
  }
}
