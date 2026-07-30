import 'dart:convert';

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Deterministic per-user accent color for avatar placeholders (no avatar
/// image yet). Same [userId] always maps to the same color, so a member/DM
/// list doesn't read as one flat wash of grey circles.
abstract final class AvatarPalette {
  static const _palette = <Color>[
    AppColors.brand,
    AppColors.avatarAccentBlue,
    AppColors.avatarAccentCyan,
    AppColors.avatarAccentPink,
    AppColors.avatarAccentMagenta,
    AppColors.avatarAccentCoral,
    AppColors.brandDim,
  ];

  static Color colorForUserId(String userId) {
    return _palette[_fnv1a(userId) % _palette.length];
  }

  /// FNV-1a over UTF-8 bytes - stable across Dart versions/isolates, unlike
  /// [Object.hashCode] which carries no such guarantee.
  static int _fnv1a(String input) {
    const prime = 0x01000193;
    var hash = 0x811c9dc5;
    for (final byte in utf8.encode(input)) {
      hash ^= byte;
      hash = (hash * prime) & 0xFFFFFFFF;
    }
    return hash;
  }
}
