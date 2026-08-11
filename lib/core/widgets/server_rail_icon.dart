import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/status_colors_extension.dart';
import '../theme/widget_styles.dart';

/// One circular icon in the Discord-style server rail (shown in the app's
/// `startDrawer`). `selected` draws the short pill indicator on the left
/// edge, exactly like Discord mobile's server list.
class ServerRailIcon extends StatelessWidget {
  const ServerRailIcon({
    super.key,
    required this.onTap,
    this.selected = false,
    this.icon,
    this.label,
    this.backgroundColor,
    this.imageUrl,
    this.child,
    this.voiceParticipantCount = 0,
    this.voiceHasStream = false,
  });

  final VoidCallback onTap;
  final bool selected;
  final IconData? icon;
  final String? label;
  final Color? backgroundColor;

  /// How many people are in voice anywhere in this server right now. Zero
  /// draws nothing - the badge is the whole signal, so an empty one would say
  /// "something is happening here" when nothing is.
  final int voiceParticipantCount;

  /// Whether any of them is screen sharing, which reads as "live" rather than
  /// merely "occupied" and gets the louder colour.
  final bool voiceHasStream;

  /// The server's icon image. Falls back to [icon]/[label] both while null and
  /// when the fetch fails, which is the normal case rather than an error path:
  /// the icon route answers a `404` for a guild that has never had one
  /// uploaded, so "no icon" arrives as a failed image load, not as a null URL.
  final String? imageUrl;

  /// An arbitrary glyph for rails whose chip isn't a Material icon, a letter
  /// or a fetched image - the home button, which draws the brand mark. Wins
  /// over [icon] and [label]; [imageUrl] still wins over it.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fallback =
        child ??
        (icon != null
            ? Icon(icon, color: theme.colorScheme.onSurface, size: 24)
            : Text(label ?? '', style: theme.textTheme.titleSmall));
    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 4,
            height: selected ? 32 : 0,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface,
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(4),
              ),
            ),
          ),
          Center(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(selected ? 16 : 24),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    clipBehavior: imageUrl != null ? Clip.antiAlias : Clip.none,
                    decoration: BoxDecoration(
                      color: backgroundColor ?? context.statusColors.hover,
                      borderRadius: BorderRadius.circular(selected ? 16 : 24),
                    ),
                    child: imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: imageUrl!,
                            fit: BoxFit.cover,
                            width: 48,
                            height: 48,
                            fadeInDuration: const Duration(milliseconds: 200),
                            // The letter, not a broken-image glyph: a guild with
                            // no icon uploaded is the common case, and it
                            // reaches this widget as a 404.
                            errorWidget: (context, url, error) =>
                                Center(child: fallback),
                            // Same reason the placeholder isn't a spinner - a
                            // rail of 48px spinners on every cold start is
                            // noisier than the letters they replace.
                            placeholder: (context, url) =>
                                Center(child: fallback),
                          )
                        : fallback,
                  ),
                  if (voiceParticipantCount > 0)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: _VoiceActivityBadge(
                        count: voiceParticipantCount,
                        hasStream: voiceHasStream,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Somebody is in voice in this server" - the rail's counterpart to the
/// per-channel roster inside a guild.
///
/// It shows a count rather than a bare dot because occupancy is the useful
/// fact from outside the server: a rail full of identical dots says only that
/// several servers are busy. The louder colour is reserved for a live screen
/// share, which is the thing worth switching servers for.
class _VoiceActivityBadge extends StatelessWidget {
  const _VoiceActivityBadge({required this.count, required this.hasStream});

  final int count;
  final bool hasStream;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = hasStream
        ? theme.colorScheme.error
        : context.statusColors.online;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      constraints: const BoxConstraints(minWidth: 18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.badge + 5),
        // Punched out of the rail rather than laid on top of it, so the badge
        // reads as attached to the chip at any icon colour.
        border: Border.all(color: context.statusColors.sidebar, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasStream ? Icons.screen_share : Icons.volume_up,
            size: 10,
            color: theme.colorScheme.onError,
          ),
          const SizedBox(width: 2),
          Text(
            '$count',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onError,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
