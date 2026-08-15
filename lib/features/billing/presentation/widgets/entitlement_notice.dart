import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/widget_styles.dart';

/// One sentence explaining a limit, at the surface that hit it.
///
/// **There is no action slot, and adding one is not a small change.** Every
/// other notice in this app is a sentence plus a way out; this one is the
/// sentence alone, and the omission is the entire design. The server sends
/// `remedy` and whether this caller could apply it, and neither reaches a
/// screen here - so there is no parameter to pass a button through, no
/// `onTap`, and no trailing affordance for one to be dropped into later.
///
/// What it *is* for is the half a session log cannot do. A reduction rides the
/// response of the request that caused it, and the person who needs it is
/// looking at that surface at that moment. Telling them in Settings some time
/// afterwards answers a question they stopped asking.
///
/// Two renderings, one shape. [onDark] is for the call and channel screens,
/// which are deliberately always-dark whatever the app theme is; the default
/// follows the theme and is what a composer or a settings surface wants.
class EntitlementNotice extends StatelessWidget {
  const EntitlementNotice({
    super.key,
    required this.message,
    this.icon = Icons.trending_down,
    this.onDark = false,
  });

  /// The whole notice. Built by the caller so the copy sits with the surface
  /// that knows what happened - see `EntitlementDegradationDto.notice`,
  /// `OversizedUpload.sentence` and `VoiceRoomLimitsDto`.
  final String message;

  /// [Icons.trending_down] for something that was reduced, which is the common
  /// case and matches the session log. A refusal reads better with
  /// [Icons.info_outline]: nothing was scaled down, it simply did not happen.
  final IconData icon;

  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = onDark
        ? AppColors.darkTextSecondary
        : theme.colorScheme.onSurface.withValues(alpha: 0.7);
    final background = onDark
        ? AppColors.darkBorderSubtle
        : theme.colorScheme.surfaceContainerHighest;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s + 2,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: foreground),
          const SizedBox(width: AppSpacing.s + 2),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: foreground,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
