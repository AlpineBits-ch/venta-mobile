import 'package:flutter/material.dart';

import '../theme/widget_styles.dart';

/// Centred "couldn't load this" state with a retry action.
///
/// Screens that fetch a list on open tended to collapse failure into one of
/// the two states they already had: either the null-means-loading spinner
/// (which then span forever, with no way to retry short of backing out) or
/// the empty state, so a dropped connection read as "No posts yet - be the
/// first!". Failure is a third state and needs to say so.
class LoadFailureView extends StatelessWidget {
  const LoadFailureView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 40,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.m),
              OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}
