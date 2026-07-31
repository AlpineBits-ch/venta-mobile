import 'package:flutter/material.dart';

import '../../../../core/theme/status_colors_extension.dart';
import '../../../../core/theme/widget_styles.dart';

/// The "this is end-to-end encrypted" marker, mirroring Alpine's.
///
/// Alpine draws a circled check rather than the padlock the settings screen
/// uses, and the two are not interchangeable: the padlock answers "can this be
/// turned on", the check answers "was this particular message sealed". Using one
/// glyph for both would make an encrypted message look like a control.
///
/// The colour is [VentaStatusColors.online] - the same emerald Alpine uses, and
/// already a theme token here rather than a new one invented for this.
class EncryptedBadge extends StatelessWidget {
  const EncryptedBadge({super.key, this.showLabel = false, this.size = 12});

  /// Adds the "E2E" wordmark. Alpine shows it in the conversation header, where
  /// there is room to explain the icon, and omits it on each message, where
  /// repeating it on every row would be noise.
  final bool showLabel;

  final double size;

  @override
  Widget build(BuildContext context) {
    final color = context.statusColors.online.withValues(alpha: 0.7);

    return Tooltip(
      message: 'End-to-end encrypted',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, size: size, color: color),
          if (showLabel) ...[
            const SizedBox(width: AppSpacing.xs),
            Text(
              'E2E',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shown in place of a message this device holds no keys for.
///
/// MLS ratchets forward and never backward, so history that predates this
/// install - or a generation it was never admitted to - can never be read here.
/// Alpine flags these in its store and then renders the raw base64 anyway;
/// saying so plainly is the whole reason the flag exists.
class UndecryptableMessageBody extends StatelessWidget {
  const UndecryptableMessageBody({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurface.withValues(alpha: 0.45);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.lock_outline, size: 14, color: color),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            'This message can\'t be decrypted on this device.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}
