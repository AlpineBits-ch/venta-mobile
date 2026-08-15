import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';
import 'status_colors_extension.dart';
import 'widget_styles.dart';

/// Builds explicit [ThemeData] for both brightness modes.
///
/// Deliberately does NOT use [ColorScheme.fromSeed] - that algorithmically
/// derives tones and would drift from Venta's exact brand hex values. Every
/// role below is mapped by hand from Alpine's `--color-*` tokens.
abstract final class AppTheme {
  /// Whether to build the Cupertino-leaning variant of the theme.
  ///
  /// Reads [defaultTargetPlatform] rather than taking a parameter because
  /// that is also what `ThemeData.platform` defaults to, and therefore what
  /// every `.adaptive` widget constructor in the framework switches on - so
  /// the theme and the widgets can never disagree about which platform this
  /// is. `debugDefaultTargetPlatformOverride` moves both together, which is
  /// what makes the iOS widget tests possible on a Windows machine.
  static bool get _isApple =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  static ThemeData get dark {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.brand,
      onPrimary: Colors.white,
      secondary: AppColors.brandDim,
      onSecondary: Colors.white,
      surface: AppColors.darkCard,
      onSurface: AppColors.darkTextPrimary,
      surfaceContainerHighest: AppColors.darkSidebar,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.darkBorderDefault,
      outlineVariant: AppColors.darkBorderSubtle,
    );

    return _build(
      colorScheme: colorScheme,
      scaffoldBg: AppColors.darkAppBg,
      cardColor: AppColors.darkCard,
      dividerColor: AppColors.darkBorder,
      textTheme: AppTypography.textTheme(
        AppColors.darkTextPrimary,
        AppColors.darkTextSecondary,
        AppColors.darkTextMuted,
      ),
      statusColors: VentaStatusColors.dark,
    );
  }

  static ThemeData get light {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.brandDark,
      onPrimary: Colors.white,
      secondary: AppColors.brand,
      onSecondary: Colors.white,
      surface: AppColors.lightCard,
      onSurface: AppColors.lightTextPrimary,
      surfaceContainerHighest: AppColors.lightSidebar,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.lightBorderDefault,
      outlineVariant: AppColors.lightBorderSubtle,
    );

    return _build(
      colorScheme: colorScheme,
      scaffoldBg: AppColors.lightAppBg,
      cardColor: AppColors.lightCard,
      dividerColor: AppColors.lightBorder,
      textTheme: AppTypography.textTheme(
        AppColors.lightTextPrimary,
        AppColors.lightTextSecondary,
        AppColors.lightTextMuted,
      ),
      statusColors: VentaStatusColors.light,
    );
  }

  static ThemeData _build({
    required ColorScheme colorScheme,
    required Color scaffoldBg,
    required Color cardColor,
    required Color dividerColor,
    required TextTheme textTheme,
    required VentaStatusColors statusColors,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,
      canvasColor: scaffoldBg,
      cardColor: cardColor,
      dividerColor: dividerColor,
      // The single loudest "this is an Android app" signal on iOS, where a tap
      // fades rather than spreading a ripple from the touch point. `NoSplash`
      // still leaves the highlight overlay, which is the closer analogue of
      // iOS's pressed state - it's the *travelling* ink that reads as foreign.
      splashFactory: _isApple
          ? NoSplash.splashFactory
          : InkRipple.splashFactory,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        // Null rather than a value on iOS: unset is how `AppBar` is told to
        // fall back to its own per-platform default, which centres the title
        // on iOS/macOS and left-aligns everywhere else. Spelling `false` here
        // was the one place the theme actively undid an adaptation Flutter
        // would otherwise have made for free. The handful of screens whose
        // title is a custom `Row`/`Column` rather than `Text` pin
        // `centerTitle: false` on their own `AppBar`, since those don't
        // survive being squeezed into the centre slot.
        centerTitle: _isApple ? null : false,
        titleTextStyle: textTheme.titleMedium,
      ),
      drawerTheme: DrawerThemeData(backgroundColor: statusColors.sidebar),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: BorderSide(color: dividerColor),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: statusColors.hover,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.input),
          ),
          textStyle: textTheme.titleSmall?.copyWith(
            color: colorScheme.onPrimary,
          ),
        ),
      ),
      // `FilledButton` is the primary action across most of the app, but
      // Material 3 defaults it to a stadium (pill) shape - which sat next to
      // the `AppRadii.input`-cornered `ElevatedButton` on the login/register
      // screens as two different-looking primary buttons. Mirror the elevated
      // style so "primary button" reads the same everywhere.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.4),
          disabledForegroundColor: colorScheme.onPrimary.withValues(alpha: 0.7),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.input),
          ),
          textStyle: textTheme.titleSmall?.copyWith(
            color: colorScheme.onPrimary,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: dividerColor),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.input),
          ),
          textStyle: textTheme.titleSmall,
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.onSurface.withValues(alpha: 0.6),
        selectedTileColor: statusColors.hover,
      ),
      dividerTheme: DividerThemeData(color: dividerColor, thickness: 1),
      extensions: [statusColors],
    );
  }
}
