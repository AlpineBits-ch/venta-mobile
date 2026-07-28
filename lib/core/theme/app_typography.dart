import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Discord-like type scale, set in Inter (Alpine's `--font-sans`).
abstract final class AppTypography {
  static TextTheme textTheme(Color primary, Color secondary, Color muted) {
    final base = GoogleFonts.interTextTheme();
    return base.copyWith(
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
