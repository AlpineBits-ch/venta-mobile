/// Shared spacing/radius scale consumed by `core/widgets/` and feature UI,
/// so layout tweaks happen in one place instead of scattered magic numbers.
abstract final class AppSpacing {
  static const xs = 4.0;
  static const s = 8.0;
  static const m = 16.0;
  static const l = 24.0;
  static const xl = 32.0;
}

abstract final class AppRadii {
  static const card = 12.0;
  static const chip = 8.0;
  static const bubble = 14.0;
  static const avatarSmall = 16.0; // circular, radius = size / 2
  static const avatarMedium = 20.0;
  static const avatarLarge = 40.0;
}
