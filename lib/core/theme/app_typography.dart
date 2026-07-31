import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Discord-like type scale, set in Inter (Alpine's `--font-sans`).
abstract final class AppTypography {
  /// Inter has no emoji coverage at all, and `google_fonts` hands Flutter a
  /// family with no fallback list - so every emoji in the app is relying on
  /// the engine's implicit walk of the platform font chain, which is where
  /// tofu boxes come from when it doesn't find one. Naming the platform emoji
  /// families explicitly puts them ahead of that guess on both platforms.
  ///
  /// Note this can only help for codepoints some installed font actually has:
  /// an emoji newer than the device's emoji font still has nothing to fall
  /// back *to*, and only bundling a font would fix that.
  static const _emojiFallback = <String>[
    'Noto Color Emoji', // Android
    'Noto Emoji',
    'Apple Color Emoji', // iOS/macOS
    'Segoe UI Emoji', // Windows
  ];

  static TextTheme textTheme(Color primary, Color secondary, Color muted) {
    final base = GoogleFonts.interTextTheme().apply(
      fontFamilyFallback: _emojiFallback,
    );
    return base.copyWith(
      // Dialog titles (AlertDialog's Material 3 default reads headlineSmall)
      // and any other display/headline text - left uncolored here before,
      // these stayed at Google Fonts' default near-black regardless of
      // theme brightness, rendering as black-on-black in dialogs like
      // "Create a server"/"Create a channel" on the dark theme.
      displayLarge: base.displayLarge?.copyWith(color: primary),
      displayMedium: base.displayMedium?.copyWith(color: primary),
      displaySmall: base.displaySmall?.copyWith(color: primary),
      headlineLarge: base.headlineLarge?.copyWith(color: primary),
      headlineMedium: base.headlineMedium?.copyWith(color: primary),
      headlineSmall: base.headlineSmall?.copyWith(color: primary),
      // Channel / server names, screen titles
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: primary,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: primary,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: secondary,
      ),
      // Message body text
      bodyLarge: base.bodyLarge?.copyWith(fontSize: 16, color: primary),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: 15, color: primary),
      bodySmall: base.bodySmall?.copyWith(fontSize: 13, color: secondary),
      // Timestamps, meta text
      labelMedium: base.labelMedium?.copyWith(fontSize: 13, color: secondary),
      labelSmall: base.labelSmall?.copyWith(fontSize: 12, color: muted),
    );
  }
}
