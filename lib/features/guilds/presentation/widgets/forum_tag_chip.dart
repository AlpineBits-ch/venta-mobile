import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/hex_color.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../data/models/forum_tag_dto.dart';
import '../../data/models/guild_emoji_dto.dart';

/// A forum tag's `color`, or null when it's the `#000000` default.
///
/// Unlike [parseHexColor] this is deliberately nullable and treats the default
/// as "no colour": rendering `#000000` literally paints a black pill that
/// reads as broken in the dark theme and as a hole in the light one. Unset
/// tags fall back to the normal chip surface instead.
Color? parseForumTagColor(String? hex) {
  if (hex == null) return null;
  final value = hex.trim().replaceFirst('#', '');
  if (value.length != 6 || int.tryParse(value, radix: 16) == null) return null;
  final color = parseHexColor(value);
  return color == const Color(0xFF000000) ? null : color;
}

/// The presigned image URL for a tag's custom guild emoji, or null when the
/// tag has none - or when it points at an emoji that has since been deleted
/// from the guild, in which case the tag renders bare rather than showing a
/// broken image.
String? forumTagEmojiUrl(ForumTagDto tag, List<GuildEmojiDto>? guildEmojis) {
  final emojiId = tag.emojiId;
  if (emojiId == null || emojiId.isEmpty || guildEmojis == null) return null;
  for (final emoji in guildEmojis) {
    if (emoji.id == emojiId) return emoji.imageUrl;
  }
  return null;
}

/// One forum tag rendered as a pill - used for the filter bar (tappable,
/// selectable, with a post-count badge), for a post card's applied tags
/// (dense, static) and for the tag picker.
class ForumTagChip extends StatelessWidget {
  const ForumTagChip({
    super.key,
    required this.tag,
    this.emojiImageUrl,
    this.selected = false,
    this.dense = false,
    this.showCount = false,
    this.onTap,
    this.trailing,
  });

  final ForumTagDto tag;
  final String? emojiImageUrl;
  final bool selected;

  /// The smaller variant used on post cards, where several tags share a row
  /// with the title.
  final bool dense;

  /// Appends the tag's `postCount` - only meaningful in the filter bar, and
  /// only as a live-ish hint (the backend recomputes it per request).
  final bool showCount;

  final VoidCallback? onTap;

  /// A remove affordance for the picker/editor, laid out after the label.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tagColor = parseForumTagColor(tag.color);
    final accent = tagColor ?? theme.colorScheme.primary;
    final background = selected
        ? accent.withValues(alpha: 0.22)
        : theme.colorScheme.surfaceContainerHighest;
    final foreground = selected
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurface.withValues(alpha: 0.8);
    final glyphSize = dense ? 11.0 : 13.0;

    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.chip),
        side: selected
            ? BorderSide(color: accent)
            : BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.chip),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: dense ? 6 : AppSpacing.s,
            vertical: dense ? 2 : 5,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (emojiImageUrl != null) ...[
                CachedNetworkImage(
                  imageUrl: emojiImageUrl!,
                  width: glyphSize + 2,
                  height: glyphSize + 2,
                  errorWidget: (_, _, _) => const SizedBox.shrink(),
                ),
                const SizedBox(width: 4),
              ] else if (tag.emojiName != null &&
                  tag.emojiName!.isNotEmpty) ...[
                Text(tag.emojiName!, style: TextStyle(fontSize: glyphSize + 1)),
                const SizedBox(width: 4),
              ] else if (tagColor != null) ...[
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: tagColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
              ],
              if (tag.moderated) ...[
                Icon(
                  Icons.shield_outlined,
                  size: glyphSize,
                  color: foreground.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 3),
              ],
              Flexible(
                child: Text(
                  showCount ? '${tag.name} ${tag.postCount}' : tag.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      (dense
                              ? theme.textTheme.labelSmall
                              : theme.textTheme.labelMedium)
                          ?.copyWith(color: foreground),
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 4), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}
