import 'package:flutter/material.dart';

import '../../features/profile/data/models/profile_dto.dart';
import '../theme/status_colors_extension.dart';

/// A small presence indicator meant to sit at an avatar's bottom-right
/// corner (wrap the avatar in a [Stack] and [Positioned] this over it).
/// `offline`/`hidden` render nothing - an absent dot is presence
/// information too, and avoids cluttering member lists with a grey dot on
/// every inactive row.
class StatusDot extends StatelessWidget {
  const StatusDot({
    super.key,
    required this.status,
    this.size = 12,
    this.borderWidth = 2,
  });

  final OnlineStatus status;
  final double size;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.statusColors;
    final color = switch (status) {
      OnlineStatus.online => colors.online,
      OnlineStatus.idle => colors.idle,
      OnlineStatus.doNotDisturb => colors.doNotDisturb,
      OnlineStatus.offline || OnlineStatus.hidden => null,
    };
    if (color == null) return const SizedBox.shrink();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
          width: borderWidth,
        ),
      ),
    );
  }
}
