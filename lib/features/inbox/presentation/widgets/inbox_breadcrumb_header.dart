import 'package:flutter/material.dart';

import '../../../../core/theme/widget_styles.dart';
import '../../../guilds/presentation/widgets/channel_type_icon.dart';
import '../../data/models/inbox_breadcrumb_dto.dart';
import 'inbox_guild_icon.dart';

/// The "where did this come from" line every inbox row starts with: the guild
/// icon, the channel it happened in, and the guild/category above it.
///
/// The inbox spans every guild the caller is in, so this is doing more work
/// than a channel list's own header - two rows from different servers can name
/// the same `#general`, and the second line is what tells them apart.
class InboxBreadcrumbHeader extends StatelessWidget {
  const InboxBreadcrumbHeader({
    super.key,
    required this.breadcrumb,
    this.trailing,
    this.iconSize = 36,
  });

  final InboxBreadcrumbDto breadcrumb;
  final Widget? trailing;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InboxGuildIcon(
          guildId: breadcrumb.guildId,
          name: breadcrumb.guildName,
          imageUrl: breadcrumb.guildIconThumbnailUrl ?? breadcrumb.guildIconUrl,
          size: iconSize,
        ),
        const SizedBox(width: AppSpacing.s + AppSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    channelTypeIcon(breadcrumb.channelKind),
                    size: 15,
                    color: muted,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      breadcrumb.channelName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                _contextLine(breadcrumb),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(color: muted),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.s),
          trailing!,
        ],
      ],
    );
  }

  /// Guild › category, or guild › forum for a post - the parent channel is
  /// more useful than the category there, since a post's category is its
  /// forum's and says nothing about the post.
  static String _contextLine(InboxBreadcrumbDto breadcrumb) {
    final parent = breadcrumb.parentChannelName;
    if (parent != null && parent.isNotEmpty) {
      return '${breadcrumb.guildName} › $parent';
    }
    return breadcrumb.contextLabel;
  }
}
