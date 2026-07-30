import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../guilds/data/guild_repository.dart';
import '../../../guilds/data/models/guild_emoji_dto.dart';

/// One-tap quick reactions plus a "more" row that expands into the full
/// emoji keyboard - matches Alpine's hover-toolbar quick reactions
/// (`quickReactions = ['👍','❤️','😂']`), extended slightly for a touch
/// target that has no hover state to lean on.
const _quickReactions = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

/// What the sheet resolves to - [emoji] is always the display text (a
/// Unicode glyph, or a custom emoji's name), [emojiId] is set only when a
/// custom guild emoji was picked.
typedef ReactionPick = ({String emoji, String? emojiId});

/// [guildId] enables a "server emoji" tab - omit it (e.g. for the composer's
/// inline-insert use, which has no rendering story for custom emoji yet) to
/// keep the sheet Unicode-only.
Future<ReactionPick?> showReactionPickerSheet(
  BuildContext context, {
  String? guildId,
}) {
  return showModalBottomSheet<ReactionPick>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _ReactionPickerSheet(guildId: guildId),
  );
}

enum _PickerView { compact, unicode, server }

class _ReactionPickerSheet extends StatefulWidget {
  const _ReactionPickerSheet({this.guildId});

  final String? guildId;

  @override
  State<_ReactionPickerSheet> createState() => _ReactionPickerSheetState();
}

class _ReactionPickerSheetState extends State<_ReactionPickerSheet> {
  _PickerView _view = _PickerView.compact;
  List<GuildEmojiDto>? _serverEmoji;
  bool _loadingServerEmoji = false;

  Future<void> _loadServerEmoji() async {
    final guildId = widget.guildId;
    if (guildId == null) return;
    setState(() => _loadingServerEmoji = true);
    try {
      final emojis = await getIt<GuildRepository>().getEmojis(guildId);
      if (mounted) setState(() => _serverEmoji = emojis);
    } catch (_) {
      if (mounted) setState(() => _serverEmoji = const []);
    } finally {
      if (mounted) setState(() => _loadingServerEmoji = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: switch (_view) {
          _PickerView.unicode => SizedBox(
            height: 340,
            child: EmojiPicker(
              onEmojiSelected: (category, emoji) => Navigator.of(
                context,
              ).pop((emoji: emoji.emoji, emojiId: null)),
              config: Config(
                emojiViewConfig: EmojiViewConfig(
                  backgroundColor: theme.colorScheme.surface,
                ),
                bottomActionBarConfig: BottomActionBarConfig(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  buttonColor: theme.colorScheme.surfaceContainerHighest,
                  buttonIconColor: theme.colorScheme.onSurface,
                ),
                categoryViewConfig: CategoryViewConfig(
                  backgroundColor: theme.colorScheme.surface,
                  iconColorSelected: theme.colorScheme.primary,
                  indicatorColor: theme.colorScheme.primary,
                ),
                searchViewConfig: SearchViewConfig(
                  backgroundColor: theme.colorScheme.surface,
                ),
              ),
            ),
          ),
          _PickerView.server => SizedBox(
            height: 340,
            child: _ServerEmojiGrid(
              emojis: _serverEmoji,
              loading: _loadingServerEmoji,
            ),
          ),
          _PickerView.compact => Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.m,
              AppSpacing.s,
              AppSpacing.m,
              AppSpacing.l,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppSpacing.m),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final emoji in _quickReactions) ...[
                        _QuickReactionButton(
                          emoji: emoji,
                          onTap: () => Navigator.of(
                            context,
                          ).pop((emoji: emoji, emojiId: null)),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                      if (widget.guildId != null) ...[
                        _QuickReactionButton(
                          icon: Icons.tag_faces_outlined,
                          onTap: () {
                            setState(() => _view = _PickerView.server);
                            _loadServerEmoji();
                          },
                        ),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                      _QuickReactionButton(
                        icon: Icons.add,
                        onTap: () =>
                            setState(() => _view = _PickerView.unicode),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        },
      ),
    );
  }
}

class _ServerEmojiGrid extends StatelessWidget {
  const _ServerEmojiGrid({required this.emojis, required this.loading});

  final List<GuildEmojiDto>? emojis;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (loading) return const Center(child: CircularProgressIndicator());
    final list = emojis ?? const [];
    if (list.isEmpty) {
      return Center(
        child: Text(
          'No custom emoji yet',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.m),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: AppSpacing.s,
        crossAxisSpacing: AppSpacing.s,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final emoji = list[index];
        return InkWell(
          borderRadius: BorderRadius.circular(AppRadii.chip),
          onTap: () =>
              Navigator.of(context).pop((emoji: emoji.name, emojiId: emoji.id)),
          child: Tooltip(
            message: emoji.name,
            child: Image.network(
              emoji.imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stack) =>
                  const Icon(Icons.broken_image_outlined, size: 20),
            ),
          ),
        );
      },
    );
  }
}

class _QuickReactionButton extends StatelessWidget {
  const _QuickReactionButton({this.emoji, this.icon, required this.onTap});

  final String? emoji;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: emoji != null
                ? Text(emoji!, style: const TextStyle(fontSize: 22))
                : Icon(
                    icon,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
          ),
        ),
      ),
    );
  }
}
