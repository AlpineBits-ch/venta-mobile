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
  });

  final Color online;
  final Color idle;
  final Color doNotDisturb;
  final Color offline;

  /// Distinct from [ColorScheme.surface] — the server-rail/channel-drawer
  /// background, one tone darker/lighter than cards.
  final Color sidebar;

  /// Hover/pressed background for list rows (channel list, member list, DM list).
  final Color hover;

  static const dark = VentaStatusColors(
    online: AppColors.statusOnline,
    idle: AppColors.statusIdle,
    doNotDisturb: AppColors.statusDnd,
    offline: AppColors.statusOffline,
    sidebar: AppColors.darkSidebar,
    hover: AppColors.darkHover,
  );

  static const light = VentaStatusColors(
    online: AppColors.statusOnline,
    idle: AppColors.statusIdle,
    doNotDisturb: AppColors.statusDnd,
    offline: AppColors.statusOffline,
    sidebar: AppColors.lightSidebar,
    hover: AppColors.lightHover,
  );

  @override
  VentaStatusColors copyWith({
    Color? online,
    Color? idle,
    Color? doNotDisturb,
    Color? offline,
    Color? sidebar,
    Color? hover,
  }) {
    return VentaStatusColors(
      online: online ?? this.online,
      idle: idle ?? this.idle,
      doNotDisturb: doNotDisturb ?? this.doNotDisturb,
      offline: offline ?? this.offline,
      sidebar: sidebar ?? this.sidebar,
      hover: hover ?? this.hover,
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
    );
  }
}

extension VentaStatusColorsX on BuildContext {
  VentaStatusColors get statusColors =>
      Theme.of(this).extension<VentaStatusColors>()!;
}
