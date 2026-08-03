import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/avatar_palette.dart';
import '../../../../core/theme/widget_styles.dart';

/// A guild's icon at inbox-row size, with the name initial underneath.
///
/// Same layering as `AvatarImage`, for the same reason: `guildIconUrl` is a
/// fixed path rather than a stored value, so it exists for every guild and
/// `404`s for the ones with no icon uploaded. Branching on "is the URL null"
/// would therefore draw a bare coloured square for most guilds; drawing the
/// initial as the *base* layer and letting the image cover it only when it
/// really loads means a 404, a timeout and an offline device all degrade to
/// the same readable placeholder.
///
/// Rounded square rather than the rail's circle - at 36px a circle crops a
/// square icon hard enough to lose the artwork it was chosen for.
class InboxGuildIcon extends StatelessWidget {
  const InboxGuildIcon({
    super.key,
    required this.guildId,
    required this.name,
    this.imageUrl,
    this.size = 36,
  });

  final String guildId;
  final String name;

  /// Prefer the thumbnail variant - it is what this size is sized for.
  final String? imageUrl;

  final double size;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.chip),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: AvatarPalette.colorForUserId(guildId),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.4,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ),
            ),
            if (url != null)
              CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                width: size,
                height: size,
                // Both fall through to the initial underneath - a spinner or a
                // broken-image glyph at this size reads as breakage.
                placeholder: (_, _) => const SizedBox.shrink(),
                errorWidget: (_, _, _) => const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );
  }
}
