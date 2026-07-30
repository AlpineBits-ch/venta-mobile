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
      error: AppColors.statusOffline,
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
      error: AppColors.statusOffline,
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
      splashFactory: InkRipple.splashFactory,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
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
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.onSurface.withValues(alpha: 0.6),
        selectedTileColor: statusColors.hover,
      ),
      dividerTheme: DividerThemeData(color: dividerColor, thickness: 1),
      extensions: [statusColors],
    );
  }
}
