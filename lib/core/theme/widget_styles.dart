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

  /// Small role badges (e.g. "BOT" tags) - replaces the mix of 3/4px
  /// literals that used to be scattered across message/member rows.
  static const badge = 4.0;

  /// Fully-rounded pill shape for the chat composer's input container.
  static const composerPill = 24.0;

  /// Text field / date-picker-style input control corners - matches
  /// `AppTheme`'s `InputDecorationTheme`/`ElevatedButtonThemeData`.
  static const input = 10.0;

  /// Modal/dialog shape and the larger rounded-square containers within it
  /// (icon badges, guild-icon placeholders).
  static const dialog = 16.0;
}
