import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routing/route_paths.dart';
import 'avatar_image.dart';
import 'profile_resolver.dart';
import 'status_dot.dart';

/// Circular avatar resolved by user id via [ProfileResolver]. Tapping opens
/// that user's profile unless [onTap] is overridden.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.userId,
    this.radius = 20,
    this.onTap,
    this.fallbackLabel,
    this.showStatus = false,
  });

  final String userId;
  final double radius;
  final VoidCallback? onTap;

  /// Shown while no profile/avatar is available. Defaults to `?`.
  final String? fallbackLabel;

  /// Overlays a [StatusDot] driven by the same cached profile - off by
  /// default so avatars in dense rows (voice participant lists, etc.) don't
  /// change size/shape unexpectedly; opt in where presence is meaningful
  /// (DM lists, message authors).
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    return ProfileResolver(
      userId: userId,
      builder: (context, profile) {
        final label = profile?.userName.isNotEmpty ?? false
            ? profile!.userName
            : (fallbackLabel ?? '?');

        final avatar = AvatarImage(
          userId: userId,
          imageUrl: profile?.avatarUrl,
          label: label,
          radius: radius,
        );

        return GestureDetector(
          onTap:
              onTap ?? () => context.push(RoutePaths.userProfilePath(userId)),
          child: showStatus && profile != null
              ? Stack(
                  clipBehavior: Clip.none,
                  children: [
                    avatar,
                    Positioned(
                      right: -1,
                      bottom: -1,
                      child: StatusDot(
                        status: profile.onlineStatus,
                        size: radius * 0.5,
                      ),
                    ),
                  ],
                )
              : avatar,
        );
      },
    );
  }
}
