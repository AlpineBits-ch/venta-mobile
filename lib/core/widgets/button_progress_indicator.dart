import 'package:flutter/material.dart';

import 'adaptive_progress_indicator.dart';

/// The spinner that replaces a button's label while its action is in flight.
///
/// Exists because the obvious inline spelling is wrong in two different ways.
/// A bare `CircularProgressIndicator` defaults to `colorScheme.primary`, which
/// on a filled primary button is brand-on-brand and effectively invisible; the
/// workaround that grew up alongside it was a hardcoded `Colors.white`, which
/// is only accidentally right (light mode's `onPrimary`) and ignores the
/// theme. Reading the owning button's own foreground colour handles both, and
/// keeps the sizing consistent instead of drifting between 16 and 20px per
/// call site.
class ButtonProgressIndicator extends StatelessWidget {
  const ButtonProgressIndicator({super.key, this.onColor});

  /// Foreground to draw on. Defaults to `onPrimary`, matching the filled
  /// buttons this sits inside most often; pass `onSurface` (or similar) when
  /// hosting it in an outlined or text button.
  final Color? onColor;

  @override
  Widget build(BuildContext context) {
    return AdaptiveProgressIndicator(
      size: 18,
      strokeWidth: 2,
      color: onColor ?? Theme.of(context).colorScheme.onPrimary,
    );
  }
}
