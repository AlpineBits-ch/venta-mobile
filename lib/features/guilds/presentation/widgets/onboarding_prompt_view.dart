import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/widget_styles.dart';
import '../../data/models/guild_dto.dart';
import '../../data/models/guild_emoji_dto.dart';
import '../../data/models/onboarding_dto.dart';

/// One onboarding question and its options, shared by the join wizard and the
/// post-join Channels & Roles screen so both stay identical as the prompt
/// model grows.
///
/// `singleSelect` renders radio semantics, otherwise checkboxes - the only
/// difference between Discord's two prompt shapes on a phone, where the
/// `Dropdown` type isn't worth a different control.
class OnboardingPromptView extends StatelessWidget {
  const OnboardingPromptView({
    super.key,
    required this.prompt,
    required this.selectedOptionIds,
    required this.onChanged,
    this.guild,
    this.guildEmojis,
    this.showTitle = true,
  });

  final OnboardingPromptDto prompt;
  final Set<String> selectedOptionIds;
  final ValueChanged<Set<String>> onChanged;

  /// Used to name the channels and roles an option grants - purely
  /// explanatory, and silently skipped for ids the cache doesn't know.
  final GuildDto? guild;
  final List<GuildEmojiDto>? guildEmojis;
  final bool showTitle;

  void _toggle(String optionId) {
    if (prompt.singleSelect) {
      onChanged(selectedOptionIds.contains(optionId) ? {} : {optionId});
      return;
    }
    final next = {...selectedOptionIds};
    if (!next.remove(optionId)) next.add(optionId);
    onChanged(next);
  }

  /// "#general, #memes · Gamer" - what picking this option actually unlocks.
  String? _grantsLabel(OnboardingPromptOptionDto option) {
    final channels = <String>[];
    final roles = <String>[];
    final currentGuild = guild;
    if (currentGuild != null) {
      for (final id in option.channelIds) {
        final match = currentGuild.channels
            .where((c) => c.id == id)
            .firstOrNull;
        if (match != null) channels.add('#${match.name}');
      }
      for (final id in option.roleIds) {
        final match = currentGuild.roles.where((r) => r.id == id).firstOrNull;
        if (match != null) roles.add(match.name);
      }
    }
    final parts = [
      if (channels.isNotEmpty) channels.join(', '),
      if (roles.isNotEmpty) roles.join(', '),
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = [...prompt.options]
      ..sort((a, b) => a.position.compareTo(b.position));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(prompt.title, style: theme.textTheme.titleMedium),
              ),
              if (prompt.isRequired)
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.s, top: 2),
                  child: Text(
                    'Required',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            prompt.singleSelect ? 'Pick one' : 'Pick as many as you like',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
        ],
        for (final option in options) ...[
          _OptionRow(
            option: option,
            selected: selectedOptionIds.contains(option.id),
            singleSelect: prompt.singleSelect,
            grants: _grantsLabel(option),
            guildEmojis: guildEmojis,
            onTap: option.id == null ? null : () => _toggle(option.id!),
          ),
          const SizedBox(height: AppSpacing.s),
        ],
      ],
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.option,
    required this.selected,
    required this.singleSelect,
    required this.grants,
    required this.guildEmojis,
    required this.onTap,
  });

  final OnboardingPromptOptionDto option;
  final bool selected;
  final bool singleSelect;
  final String? grants;
  final List<GuildEmojiDto>? guildEmojis;
  final VoidCallback? onTap;

  /// An option's `emoji` is either a unicode glyph or a guild emoji id, with
  /// no marker distinguishing them - the id prefix is the only tell.
  Widget? _emoji() {
    final emoji = option.emoji;
    if (emoji == null || emoji.isEmpty) return null;
    if (emoji.startsWith('emoj_')) {
      final match = guildEmojis?.where((e) => e.id == emoji).firstOrNull;
      if (match == null) return null;
      return CachedNetworkImage(
        imageUrl: match.imageUrl,
        width: 22,
        height: 22,
        errorWidget: (_, _, _) => const SizedBox.shrink(),
      );
    }
    return Text(emoji, style: const TextStyle(fontSize: 20));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final emoji = _emoji();
    return Material(
      color: selected
          ? theme.colorScheme.primary.withValues(alpha: 0.12)
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.s + 4,
          ),
          child: Row(
            children: [
              if (emoji != null) ...[
                emoji,
                const SizedBox(width: AppSpacing.m),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (option.description != null &&
                        option.description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        option.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                    if (grants != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        grants!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Icon(
                singleSelect
                    ? (selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked)
                    : (selected
                          ? Icons.check_box
                          : Icons.check_box_outline_blank),
                size: 20,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
