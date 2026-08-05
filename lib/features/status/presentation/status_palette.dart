import 'package:flutter/material.dart';

import '../../../core/theme/status_colors_extension.dart';
import '../data/models/platform_status_dto.dart';

/// How status severity maps onto the app's palette, in one place so the banner
/// and the Platform status screen can never disagree about what amber means.
///
/// Every `unknown` here resolves to the least alarming thing available - a
/// muted grey, never red. That is the spec's rule for unrecognised enum values
/// and it is the whole reason these are functions rather than a `switch` copied
/// into two widgets.
extension StatusPalette on BuildContext {
  /// §4: "`info` -> neutral or blue, `warning` -> amber, `critical` -> red."
  Color severityColor(StatusSeverity severity) => switch (severity) {
    StatusSeverity.info => Theme.of(this).colorScheme.primary,
    StatusSeverity.warning => statusColors.warning,
    StatusSeverity.critical => Theme.of(this).colorScheme.error,
    StatusSeverity.unknown => Theme.of(this).colorScheme.primary,
  };

  /// The dot beside a component name.
  Color componentColor(ComponentStatus status) => switch (status) {
    ComponentStatus.operational => statusColors.online,
    ComponentStatus.degradedPerformance => statusColors.warning,
    ComponentStatus.partialOutage => statusColors.warning,
    ComponentStatus.majorOutage => Theme.of(this).colorScheme.error,
    ComponentStatus.underMaintenance => Theme.of(this).colorScheme.primary,
    // Grey, and honest about it: a status this build has never heard of says
    // nothing about whether the component works.
    ComponentStatus.unknown => statusColors.offline,
  };

  /// The dot beside the overall roll-up on the Platform status screen.
  Color indicatorColor(StatusIndicator indicator) => switch (indicator) {
    StatusIndicator.operational => statusColors.online,
    StatusIndicator.degraded => statusColors.warning,
    StatusIndicator.partialOutage => statusColors.warning,
    StatusIndicator.majorOutage => Theme.of(this).colorScheme.error,
    StatusIndicator.maintenance => Theme.of(this).colorScheme.primary,
    StatusIndicator.unknown => statusColors.offline,
  };

  /// Text/icon colour that stays legible on [background].
  ///
  /// Computed rather than paired with each severity because the warning amber
  /// is a fixed token shared by both themes: `onPrimary` and `onError` follow
  /// the scheme, but nothing in the scheme knows what sits well on that amber,
  /// and hardcoding white there is unreadable.
  Color onStatusColor(Color background) =>
      ThemeData.estimateBrightnessForColor(background) == Brightness.dark
      ? Colors.white
      : Colors.black87;
}
