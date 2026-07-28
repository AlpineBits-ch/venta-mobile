import 'package:flutter/material.dart';

/// Raw design tokens ported from the Venta desktop client's palette
/// (`Alpine/src/styles.css`, theme id `alpine-dark`).
///
/// This is the single place hex values live — features must never hardcode
/// a `Color(0x...)` literal, they should go through [AppTheme]/[VentaStatusColors].
abstract final class AppColors {
  // Brand
  static const brand = Color(0xFF7C72FF);
  static const brandHover = Color(0xFF695DF2);
  static const brandDim = Color(0xFF9A84FF);
  static const brandDark = Color(0xFF584AD9);

  // Dark-mode surfaces (Alpine's only theme)
  static const darkLoginBg = Color(0xFF06090F);
  static const darkAppBg = Color(0xFF0D1117);
  static const darkSidebar = Color(0xFF111520);
  static const darkCard = Color(0xFF161B27);
  static const darkHover = Color(0xFF1D2333);
  static const darkBorder = Color(0xFF252E42);
  static const darkBorderSubtle = Color(0x1AFFFFFF); // rgba(255,255,255,.10)
  static const darkBorderDefault = Color(0x29FFFFFF); // rgba(255,255,255,.16)
  static const darkTextPrimary = Color(0xD9FFFFFF); // rgba(255,255,255,.85)
  static const darkTextSecondary = Color(0x99FFFFFF); // rgba(255,255,255,.60)
  static const darkTextMuted = Color(0x66FFFFFF); // rgba(255,255,255,.40)

  // Light-mode surfaces — manually mapped for the mobile client, since
  // Alpine desktop ships dark-only but Discord mobile supports both.
  static const lightAppBg = Color(0xFFFFFFFF);
  static const lightSidebar = Color(0xFFF2F3F7);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightHover = Color(0xFFE9EAF2);
  static const lightBorder = Color(0xFFE1E3EC);
  static const lightBorderSubtle = Color(0x14060714); // rgba(6,7,20,.08)
  static const lightBorderDefault = Color(0x29060714); // rgba(6,7,20,.16)
  static const lightTextPrimary = Color(0xE0060714); // rgba(6,7,20,.88)
  static const lightTextSecondary = Color(0xA3060714); // rgba(6,7,20,.64)
  static const lightTextMuted = Color(0x73060714); // rgba(6,7,20,.45)

  // Presence / status — same across both themes
  static const statusOnline = Color(0xFF34D399);
  static const statusIdle = Color(0xFFFBBF24);
  static const statusOffline = Color(0xFFF43F5E);
  static const statusDnd = Color(0xFFF43F5E);
}
