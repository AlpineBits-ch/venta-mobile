import 'package:flutter/material.dart';

import '../../../../core/theme/status_colors_extension.dart';
import '../../data/models/profile_dto.dart';

/// Display name for a presence value. `hidden` reads as "Invisible" - the
/// thing the user deliberately chose - while `offline` is the involuntary
/// state nobody picks.
String statusLabel(OnlineStatus status) => switch (status) {
  OnlineStatus.online => 'Online',
  OnlineStatus.idle => 'Idle',
  OnlineStatus.doNotDisturb => 'Do Not Disturb',
  OnlineStatus.hidden => 'Invisible',
  OnlineStatus.offline => 'Offline',
};

/// Solid presence color. Unlike `StatusDot` this always resolves to a color
/// (grey for invisible/offline) - use it where the dot sits next to a written
/// label, so an absent dot doesn't read as a rendering bug.
Color statusColor(BuildContext context, OnlineStatus status) =>
    switch (status) {
      OnlineStatus.online => context.statusColors.online,
      OnlineStatus.idle => context.statusColors.idle,
      OnlineStatus.doNotDisturb => context.statusColors.doNotDisturb,
      OnlineStatus.hidden ||
      OnlineStatus.offline => context.statusColors.offline,
    };
