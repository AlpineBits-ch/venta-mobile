import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/widget_styles.dart';

/// One-tap quick reactions plus a "more" row that expands into the full
/// emoji keyboard — matches Alpine's hover-toolbar quick reactions
/// (`quickReactions = ['👍','❤️','😂']`), extended slightly for a touch
/// target that has no hover state to lean on.
const _quickReactions = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

Future<String?> showReactionPickerSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _ReactionPickerSheet(),
  );
}

class _ReactionPickerSheet extends StatefulWidget {
  const _ReactionPickerSheet();

  @override
  State<_ReactionPickerSheet> createState() => _ReactionPickerSheetState();
}

class _ReactionPickerSheetState extends State<_ReactionPickerSheet> {
  bool _showFullPicker = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: _showFullPicker
            ? SizedBox(
                height: 340,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) =>
                      Navigator.of(context).pop(emoji.emoji),
                  config: Config(
                    emojiViewConfig: EmojiViewConfig(
                      backgroundColor: theme.colorScheme.surface,
                    ),
                    bottomActionBarConfig: BottomActionBarConfig(
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
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
              )
            : Padding(
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
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.2,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (final emoji in _quickReactions)
                          _QuickReactionButton(
                            emoji: emoji,
                            onTap: () => Navigator.of(context).pop(emoji),
                          ),
                        _QuickReactionButton(
                          icon: Icons.add,
                          onTap: () => setState(() => _showFullPicker = true),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
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
