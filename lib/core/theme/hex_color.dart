import 'package:flutter/material.dart';

/// Parses a `#RRGGBB` string (e.g. a profile's `accentColor`) into an opaque
/// [Color]. Shared by the self and other-user profile screens.
Color parseHexColor(String hex) {
  final cleaned = hex.replaceFirst('#', '');
  return Color(int.parse('FF$cleaned', radix: 16));
}

/// [parseHexColor] for values this client doesn't control the shape of - a
/// bot-set embed accent, say. Returns null rather than throwing out of a
/// `build`, where one malformed colour would take the whole timeline down.
Color? tryParseHexColor(String? hex) {
  if (hex == null) return null;
  final cleaned = hex.replaceFirst('#', '');
  if (cleaned.length != 6) return null;
  final value = int.tryParse(cleaned, radix: 16);
  return value == null ? null : Color(0xFF000000 | value);
}
