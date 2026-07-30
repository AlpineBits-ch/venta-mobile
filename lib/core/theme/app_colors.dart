import 'package:flutter/material.dart';

/// Raw design tokens ported from the Venta desktop client's palette
/// (`Alpine/src/styles.css`'s `@theme` block, which is required to stay
/// byte-identical to `DEFAULT_THEME` in `Alpine/src/app/models/theme.model.ts`
/// - same two-source-of-truth constraint applies here, so re-check both
/// when Alpine's palette changes again).
///
/// This is the single place hex values live - features must never hardcode
/// a `Color(0x...)` literal, they should go through [AppTheme]/[VentaStatusColors].
abstract final class AppColors {
  // Brand
  static const brand = Color(0xFF4B5BC4);
  static const brandHover = Color(0xFF3E4EAE);
  static const brandDim = Color(0xFF7E8AE0);
  static const brandDark = Color(0xFF333F8C);

  // Dark-mode surfaces (Alpine's only theme)
  static const darkLoginBg = Color(0xFF06090F);
  static const darkAppBg = Color(0xFF0D1117);
  static const darkSidebar = Color(0xFF111520);
  static const darkCard = Color(0xFF161B27);
  static const darkHover = Color(0xFF1D2333);
  static const darkBorder = Color(0xFF252E42);
  static const darkBorderSubtle = Color(0x1AFFFFFF); // rgba(255,255,255,.10)
  static const darkBorderDefault = Color(0x29FFFFFF); // rgba(255,255,255,.16)
  static const darkTextPrimary = Color(0xE0FFFFFF); // rgba(255,255,255,.88)
  static const darkTextSecondary = Color(0x9EFFFFFF); // rgba(255,255,255,.62)
  static const darkTextMuted = Color(0x6BFFFFFF); // rgba(255,255,255,.42)
  static const darkTextFaint = Color(0x3DFFFFFF); // rgba(255,255,255,.24)

  // Light-mode surfaces - manually mapped for the mobile client, since
  // Alpine desktop ships dark-only but Discord mobile supports both.
  static const lightAppBg = Color(0xFFFFFFFF);
  static const lightSidebar = Color(0xFFF2F3F7);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightHover = Color(0xFFE9EAF2);
  static const lightBorder = Color(0xFFE1E3EC);
  static const lightBorderSubtle = Color(0x1F060714); // rgba(6,7,20,.12)
  static const lightBorderDefault = Color(0x38060714); // rgba(6,7,20,.22)
  static const lightTextPrimary = Color(0xE0060714); // rgba(6,7,20,.88)
  static const lightTextSecondary = Color(0xA3060714); // rgba(6,7,20,.64)
  static const lightTextMuted = Color(0x73060714); // rgba(6,7,20,.45)

  // Presence / status - same across both themes
  static const statusOnline = Color(0xFF34D399);
  static const statusIdle = Color(0xFFFBBF24);
  static const statusOffline = Color(0xFFF43F5E);
  static const statusDnd = Color(0xFFF43F5E);

  // Avatar-placeholder accent palette - deterministic per-user fallback fill
  // (see AvatarPalette.colorForUserId), kept hue-distinct from the presence
  // colors above so a placeholder is never mistaken for a status dot.
  static const avatarAccentBlue = Color(0xFF4C8DFF);
  static const avatarAccentCyan = Color(0xFF2BB8C4);
  static const avatarAccentPink = Color(0xFFEA5FA3);
  static const avatarAccentMagenta = Color(0xFFC768E0);
  static const avatarAccentCoral = Color(0xFFF2784B);
}
