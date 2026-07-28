import 'package:flutter/material.dart';

/// Parses a `#RRGGBB` string (e.g. a profile's `accentColor`) into an opaque
/// [Color]. Shared by the self and other-user profile screens.
Color parseHexColor(String hex) {
  final cleaned = hex.replaceFirst('#', '');
  return Color(int.parse('FF$cleaned', radix: 16));
}
