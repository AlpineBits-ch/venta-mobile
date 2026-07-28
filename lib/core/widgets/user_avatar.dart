import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routing/route_paths.dart';
import '../theme/status_colors_extension.dart';
import 'profile_resolver.dart';

/// Circular avatar resolved by user id via [ProfileResolver]. Tapping opens
/// that user's profile unless [onTap] is overridden.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.userId,
    this.radius = 20,
    this.onTap,
    this.fallbackLabel,
  });

  final String userId;
  final double radius;
  final VoidCallback? onTap;

  /// Shown while no profile/avatar is available. Defaults to `?`.
  final String? fallbackLabel;

  @override
  Widget build(BuildContext context) {
    return ProfileResolver(
      userId: userId,
      builder: (context, profile) {
        final label = profile?.userName.isNotEmpty ?? false
            ? profile!.userName[0].toUpperCase()
            : (fallbackLabel ?? '?');

        return GestureDetector(
          onTap: onTap ?? () => context.push(RoutePaths.userProfilePath(userId)),
          child: CircleAvatar(
            radius: radius,
            backgroundColor: context.statusColors.hover,
            backgroundImage: profile?.avatarUrl != null ? NetworkImage(profile!.avatarUrl!) : null,
            child: profile?.avatarUrl == null
                ? Text(label, style: TextStyle(fontSize: radius * 0.7))
                : null,
          ),
        );
      },
    );
  }
}
