import 'package:flutter/material.dart';

/// Icon for a `deviceType` string as the identity API reports it (`Desktop`,
/// `Mobile`, `Web`). Shared by the QR approval prompt and the logged-in
/// devices list so the same device doesn't get two different icons depending
/// on which screen you're looking at.
///
/// Matched case-insensitively, with a neutral fallback: the value is recorded
/// from whatever a client sent at login, and an unknown one should still
/// render a row rather than nothing.
IconData deviceTypeIcon(String? deviceType) =>
    switch (deviceType?.toLowerCase()) {
      'web' => Icons.language,
      'desktop' => Icons.desktop_windows_outlined,
      'mobile' => Icons.smartphone,
      _ => Icons.devices_other,
    };
