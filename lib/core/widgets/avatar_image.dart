import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/avatar_palette.dart';

/// A circular avatar that always has something to show.
///
/// The coloured disc with an initial in it is the *base* layer here, not an
/// `else` branch, and that distinction is the whole point: the backend hands
/// out an `avatarUrl` for every profile whether or not one was ever uploaded
/// (it 302s to object storage, which then 404s for anyone without a picture).
/// So `avatarUrl != null` is always true and says nothing about whether an
/// image exists - code that branches on it draws a bare coloured disc with no
/// initial in it, which is what a default avatar used to look like.
///
/// Drawing the initial underneath and letting the image cover it when (and
/// only when) it actually loads means a 404, a timeout and an offline device
/// all degrade to the same readable placeholder.
class AvatarImage extends StatelessWidget {
  const AvatarImage({
    super.key,
    required this.userId,
    required this.imageUrl,
    required this.label,
    required this.radius,
  });

  /// Picks the placeholder tint, so the same person is always the same colour.
  final String userId;

  final String? imageUrl;

  /// Usually the display name - only its first character is drawn.
  final String label;

  final double radius;

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final url = imageUrl;
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            _Initial(userId: userId, label: label, radius: radius),
            if (url != null)
              CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                width: size,
                height: size,
                // Both fall through to the initial underneath rather than
                // painting anything of their own - a spinner or broken-image
                // glyph at 20px reads as breakage, not as loading.
                placeholder: (_, _) => const SizedBox.shrink(),
                errorWidget: (_, _, _) => const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );
  }
}

class _Initial extends StatelessWidget {
  const _Initial({
    required this.userId,
    required this.label,
    required this.radius,
  });

  final String userId;
  final String label;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AvatarPalette.colorForUserId(userId),
      child: Center(
        child: Text(
          label.isNotEmpty ? label[0].toUpperCase() : '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: radius * 0.8,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
      ),
    );
  }
}
