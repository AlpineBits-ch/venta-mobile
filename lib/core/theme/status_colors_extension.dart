import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Presence/status colors have no natural Material [ColorScheme] role, so
/// they're exposed as a [ThemeExtension] instead. Retrieve with:
/// `Theme.of(context).extension<VentaStatusColors>()!`
@immutable
class VentaStatusColors extends ThemeExtension<VentaStatusColors> {
  const VentaStatusColors({
    required this.online,
    required this.idle,
    required this.doNotDisturb,
    required this.offline,
    required this.sidebar,
    required this.hover,
    required this.warning,
  });

  final Color online;
  final Color idle;
  final Color doNotDisturb;
  final Color offline;

  /// Distinct from [ColorScheme.surface] - the server-rail/channel-drawer
  /// background, one tone darker/lighter than cards.
  final Color sidebar;

  /// Hover/pressed background for list rows (channel list, member list, DM list).
  final Color hover;

  /// "Something is degraded, but not broken" - the amber between
  /// [ColorScheme.primary] and [ColorScheme.error], for which Material's scheme
  /// has no role. Read by the platform-status banner and component dots.
  ///
  /// Shares [AppColors.statusIdle]'s hex rather than introducing a second
  /// amber, but is its own token: presence-idle and a degraded service are
  /// different facts, and the day one of them wants a different shade the other
  /// must not move with it.
  final Color warning;

  static const dark = VentaStatusColors(
    online: AppColors.statusOnline,
    idle: AppColors.statusIdle,
    doNotDisturb: AppColors.statusDnd,
    offline: AppColors.statusOffline,
    sidebar: AppColors.darkSidebar,
    hover: AppColors.darkHover,
    warning: AppColors.statusIdle,
  );

  static const light = VentaStatusColors(
    online: AppColors.statusOnline,
    idle: AppColors.statusIdle,
    doNotDisturb: AppColors.statusDnd,
    offline: AppColors.statusOffline,
    sidebar: AppColors.lightSidebar,
    hover: AppColors.lightHover,
    warning: AppColors.statusIdle,
  );

  @override
  VentaStatusColors copyWith({
    Color? online,
    Color? idle,
    Color? doNotDisturb,
    Color? offline,
    Color? sidebar,
    Color? hover,
    Color? warning,
  }) {
    return VentaStatusColors(
      online: online ?? this.online,
      idle: idle ?? this.idle,
      doNotDisturb: doNotDisturb ?? this.doNotDisturb,
      offline: offline ?? this.offline,
      sidebar: sidebar ?? this.sidebar,
      hover: hover ?? this.hover,
      warning: warning ?? this.warning,
    );
  }

  @override
  VentaStatusColors lerp(ThemeExtension<VentaStatusColors>? other, double t) {
    if (other is! VentaStatusColors) return this;
    return VentaStatusColors(
      online: Color.lerp(online, other.online, t)!,
      idle: Color.lerp(idle, other.idle, t)!,
      doNotDisturb: Color.lerp(doNotDisturb, other.doNotDisturb, t)!,
      offline: Color.lerp(offline, other.offline, t)!,
      sidebar: Color.lerp(sidebar, other.sidebar, t)!,
      hover: Color.lerp(hover, other.hover, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}

extension VentaStatusColorsX on BuildContext {
  VentaStatusColors get statusColors =>
      Theme.of(this).extension<VentaStatusColors>()!;
}
