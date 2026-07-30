import 'package:flutter/material.dart';

import '../theme/widget_styles.dart';

/// A grouped card of settings rows under an optional small-caps label - the
/// iOS/Discord "inset grouped list" shape. Rows inside get hairline dividers
/// indented past the icon column; the card clips them so the corners stay
/// round.
class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key, this.label, this.child, this.children})
    : assert(
        (child == null) != (children == null),
        'Pass exactly one of child or children.',
      );

  final String? label;

  /// Arbitrary card content (a paragraph, a form) instead of [children].
  final Widget? child;

  /// Rows to separate with dividers - typically [SettingsRow]s.
  final List<Widget>? children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = children;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xs,
              bottom: AppSpacing.s,
            ),
            child: Text(
              label!.toUpperCase(),
              style: theme.textTheme.labelSmall,
            ),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.card),
            child:
                child ??
                Column(
                  children: [
                    for (var i = 0; i < rows!.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          thickness: 1,
                          indent: 56,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.08,
                          ),
                        ),
                      rows[i],
                    ],
                  ],
                ),
          ),
        ),
      ],
    );
  }
}

/// The explanatory line under a [SettingsSection] - deliberately outside the
/// card, so the card stays a clean list of rows and the prose doesn't read as
/// one of them.
class SettingsFootnote extends StatelessWidget {
  const SettingsFootnote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.s,
        AppSpacing.xs,
        0,
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

/// One tappable row inside a [SettingsSection]. Kept separate from [ListTile]
/// so the icon column, chevron and destructive variant stay identical across
/// every settings page.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.destructive = false,
    this.showChevron,
  });

  final String title;
  final IconData? icon;
  final String? subtitle;

  /// Sits before the chevron - a value, a badge, a stack of avatars. Laid out
  /// flexibly, so a long value ellipsizes instead of crushing [title] down to
  /// one-letter-per-line and overflowing anyway.
  final Widget? trailing;

  final VoidCallback? onTap;

  /// Renders in the error color - log out, delete account.
  final bool destructive;

  /// Defaults to "yes if tappable". Set `false` for rows that act in place
  /// rather than pushing a page.
  final bool? showChevron;

  /// Ceiling for [trailing] - see the comment at its layout site.
  static const _maxTrailingWidth = 160.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = destructive
        ? theme.colorScheme.error
        : theme.colorScheme.onSurface;
    final chevron = showChevron ?? (onTap != null);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: 14,
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 22, color: color),
              const SizedBox(width: AppSpacing.m),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(color: color),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.s),
              // Capped rather than made flexible: `Flexible` here would take a
              // fixed share of the free space and start ellipsizing long
              // *titles* even next to a two-letter value. A hard ceiling leaves
              // short values tight and forces long ones to ellipsize.
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _maxTrailingWidth),
                child: DefaultTextStyle.merge(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  child: trailing!,
                ),
              ),
            ],
            if (chevron)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.xs),
                child: Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
