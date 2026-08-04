import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';

import '../../../../core/format/date_time_format.dart';
import '../../../../core/theme/hex_color.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../data/models/embed_dto.dart';
import 'message_link_launcher.dart';

/// Widest a card is allowed to get, so a preview on a tablet doesn't stretch
/// to the full column the way body text does. Discord caps its embeds at a
/// similar fixed width for the same reason.
const _maxCardWidth = 400.0;

/// Tallest a large image or video poster may be before it is scaled down. A
/// card should never take the whole screen on its own.
const _maxMediaHeight = 260.0;

/// The little square beside the text on a `link` card.
const _thumbnailSize = 76.0;

/// Discord's coloured spine down the left edge of a card.
const _accentBarWidth = 4.0;

/// Renders a message's embeds: bot-authored `rich` cards and server-generated
/// link previews alike, stacked in the order they arrived (author cards first,
/// which is how the server orders them).
///
/// A card is decoration and never a reason to hold a message back - previews
/// are unfurled asynchronously and arrive seconds after the message, so this
/// simply appears when [embeds] becomes non-empty.
///
/// **Everything textual here is attacker-controlled.** `title`,
/// `description`, `author.name`, `provider.name` and `footer.text` come off a
/// third-party page the poster chose, so every one of them is rendered as a
/// plain [Text] - never Markdown, which would let a stranger's page put an
/// image, a link, or a mention into somebody else's channel.
class MessageEmbedsView extends StatelessWidget {
  const MessageEmbedsView({super.key, required this.embeds});

  final List<EmbedDto> embeds;

  @override
  Widget build(BuildContext context) {
    final renderable = embeds.where((e) => !e.isEmpty).toList();
    if (renderable.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final embed in renderable)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: _EmbedCard(embed: embed),
            ),
        ],
      ),
    );
  }
}

class _EmbedCard extends StatelessWidget {
  const _EmbedCard({required this.embed});

  final EmbedDto embed;

  /// The media that gets the full card width. `image` is the author's or the
  /// page's chosen hero; a `video` card's poster frame arrives as `thumbnail`
  /// instead, and is shown large because a play button on a 76px square is
  /// not a play button.
  EmbedMediaDto? get _largeMedia {
    if (embed.image?.displayUrl != null) return embed.image;
    if (embed.video != null && embed.thumbnail?.displayUrl != null) {
      return embed.thumbnail;
    }
    return null;
  }

  /// The small square beside the text - only when the thumbnail isn't already
  /// being shown large.
  EmbedMediaDto? get _sideThumbnail {
    if (_largeMedia == embed.thumbnail) return null;
    return embed.thumbnail?.displayUrl != null ? embed.thumbnail : null;
  }

  @override
  Widget build(BuildContext context) {
    // "Just the image, no chrome" - a link straight to an image file, or a GIF
    // the origin serves as a video. Wrapping either in a titled card would be
    // all frame and no picture.
    if (embed.type == EmbedType.image || embed.type == EmbedType.gifv) {
      return _BareMediaEmbed(embed: embed);
    }

    final theme = Theme.of(context);
    final accent =
        tryParseHexColor(embed.color) ?? theme.colorScheme.outlineVariant;

    const inset = AppSpacing.s + 2;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxCardWidth),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: ColoredBox(
          color: theme.colorScheme.surfaceContainerHighest,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  _accentBarWidth + inset,
                  inset,
                  inset,
                  inset,
                ),
                child: _cardBody(context, theme),
              ),
              // Discord's colour bar, running the card's full height.
              //
              // A stretched Row child would need an IntrinsicHeight around it,
              // and intrinsics are exactly what the LayoutBuilder in
              // `_EmbedFields` cannot answer - a `rich` card with fields would
              // throw. Positioning it against the body's own height sidesteps
              // the measurement entirely.
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                width: _accentBarWidth,
                child: ColoredBox(color: accent),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardBody(BuildContext context, ThemeData theme) {
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final thumbnail = _sideThumbnail;
    final large = _largeMedia;

    final textColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (embed.provider?.name.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              embed.provider!.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(color: muted),
            ),
          ),
        if (embed.author?.name.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _AuthorRow(author: embed.author!, theme: theme),
          ),
        if (embed.title?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: GestureDetector(
              onTap: embed.url == null
                  ? null
                  : () => openMessageLink(context, embed.url),
              child: Text(
                embed.title!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: embed.url == null
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        if (embed.description?.isNotEmpty ?? false)
          Text(
            embed.description!,
            // A description may be 4096 characters. Discord shows the lot on
            // desktop; on a phone that is several screens of somebody else's
            // page inside a chat, so it gets a ceiling.
            maxLines: 10,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
            ),
          ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (thumbnail != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: textColumn),
              const SizedBox(width: AppSpacing.s),
              _EmbedMedia(
                media: thumbnail,
                maxWidth: _thumbnailSize,
                maxHeight: _thumbnailSize,
                fit: BoxFit.cover,
                onTap: () => openMessageLink(context, embed.url),
              ),
            ],
          )
        else
          textColumn,
        if (embed.fields.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.s),
            child: _EmbedFields(fields: embed.fields, theme: theme),
          ),
        if (large != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.s),
            child: _EmbedMedia(
              media: large,
              maxWidth: _maxCardWidth,
              maxHeight: _maxMediaHeight,
              // A player-capable provider. There is no sandboxed frame to put
              // a third-party iframe in here, so the poster gets a play badge
              // and the tap leaves for the provider's own app - the degraded
              // card the backend guide asks for in place of an unsandboxed
              // embed.
              showPlayBadge: embed.video != null,
              onTap: () => openMessageLink(context, embed.url),
            ),
          ),
        if ((embed.footer?.text.isNotEmpty ?? false) || embed.timestamp != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.s),
            child: _FooterRow(
              footer: embed.footer,
              timestamp: embed.timestamp,
              theme: theme,
            ),
          ),
      ],
    );
  }
}

/// An `image`/`gifv` embed: the picture and nothing else, matching the
/// chrome-less way Discord renders a bare image link.
class _BareMediaEmbed extends StatelessWidget {
  const _BareMediaEmbed({required this.embed});

  final EmbedDto embed;

  @override
  Widget build(BuildContext context) {
    final media = embed.image?.displayUrl != null
        ? embed.image!
        : embed.thumbnail;
    if (media?.displayUrl == null) return const SizedBox.shrink();

    return _EmbedMedia(
      media: media!,
      maxWidth: _maxCardWidth,
      maxHeight: _maxMediaHeight,
      // A `gifv` is an animated GIF the origin re-serves as a video, which
      // this client has no player for. Labelled rather than silently shown as
      // a still, so a frozen first frame reads as "tap me" instead of "broken".
      badgeLabel: embed.type == EmbedType.gifv ? 'GIF' : null,
      onTap: () => openMessageLink(context, embed.url ?? media.url),
    );
  }
}

/// One image, sized from the server's measured dimensions so the timeline
/// doesn't reflow when the bytes land, and blurred from its BlurHash until
/// they do.
class _EmbedMedia extends StatelessWidget {
  const _EmbedMedia({
    required this.media,
    required this.maxWidth,
    required this.maxHeight,
    this.fit = BoxFit.cover,
    this.showPlayBadge = false,
    this.badgeLabel,
    this.onTap,
  });

  final EmbedMediaDto media;
  final double maxWidth;
  final double maxHeight;
  final BoxFit fit;
  final bool showPlayBadge;
  final String? badgeLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final url = media.displayUrl;
    if (url == null) return const SizedBox.shrink();
    final theme = Theme.of(context);

    final image = CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (context, _) => _placeholder(theme),
      errorWidget: (context, _, _) => ColoredBox(
        color: theme.colorScheme.surfaceContainerHigh,
        child: Icon(
          Icons.broken_image_outlined,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.chip),
        child: _sized(
          Stack(
            fit: StackFit.passthrough,
            children: [
              image,
              if (showPlayBadge) const _PlayBadge(),
              if (badgeLabel != null)
                Positioned(
                  left: AppSpacing.xs,
                  bottom: AppSpacing.xs,
                  child: _CornerLabel(text: badgeLabel!),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Reserves the exact box the image will occupy whenever the server measured
  /// it. Without this a card grows the moment its image decodes, which shoves
  /// the whole message list under the reader's thumb.
  Widget _sized(Widget child) {
    final ratio = media.aspectRatio;
    if (ratio == null) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: child,
      );
    }

    // Never upscale past the true pixel size - a 40px favicon blown up to the
    // full card width is worse than a small favicon.
    var width = math.min(maxWidth, media.width!.toDouble());
    var height = width / ratio;
    if (height > maxHeight) {
      height = maxHeight;
      width = height * ratio;
    }
    return SizedBox(width: width, height: height, child: child);
  }

  Widget _placeholder(ThemeData theme) {
    final neutral = ColoredBox(color: theme.colorScheme.surfaceContainerHigh);
    final hash = media.blurHash;
    if (hash == null) return neutral;
    return Image(
      image: BlurHashImage(hash),
      fit: BoxFit.cover,
      // A hash of the right shape and the wrong contents decodes to noise or
      // throws; either way the neutral block is the better answer.
      errorBuilder: (context, _, _) => neutral,
    );
  }
}

class _PlayBadge extends StatelessWidget {
  const _PlayBadge();

  @override
  Widget build(BuildContext context) {
    // Deliberately not themed: this sits on top of an arbitrary third-party
    // thumbnail, where a surface-coloured control can land on a
    // surface-coloured photograph and vanish.
    return const Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0x8C000000),
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.s),
          child: Icon(Icons.play_arrow_rounded, size: 32, color: Colors.white),
        ),
      ),
    );
  }
}

class _CornerLabel extends StatelessWidget {
  const _CornerLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: const Color(0x8C000000),
        borderRadius: BorderRadius.circular(AppRadii.badge),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 9,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _AuthorRow extends StatelessWidget {
  const _AuthorRow({required this.author, required this.theme});

  final EmbedAuthorDto author;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final icon = author.displayIconUrl;
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: icon,
              width: 20,
              height: 20,
              fit: BoxFit.cover,
              errorWidget: (context, _, _) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            author.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );

    if (author.url == null) return row;
    return GestureDetector(
      onTap: () => openMessageLink(context, author.url),
      child: row,
    );
  }
}

class _FooterRow extends StatelessWidget {
  const _FooterRow({
    required this.footer,
    required this.timestamp,
    required this.theme,
  });

  final EmbedFooterDto? footer;
  final DateTime? timestamp;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final icon = footer?.displayIconUrl;
    final parts = [
      if (footer?.text.isNotEmpty ?? false) footer!.text,
      if (timestamp != null) formatShortDateTime(timestamp!),
    ];

    return Row(
      children: [
        if (icon != null) ...[
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: icon,
              width: 16,
              height: 16,
              fit: BoxFit.cover,
              errorWidget: (context, _, _) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            parts.join(' • '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }
}

/// Bot-only in practice - a generated link preview never populates fields.
/// Inline fields share a row two-up rather than Discord's three, which is one
/// column too many at phone widths.
class _EmbedFields extends StatelessWidget {
  const _EmbedFields({required this.fields, required this.theme});

  final List<EmbedFieldDto> fields;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final full = constraints.maxWidth;
        final half = (full - AppSpacing.s) / 2;
        return Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.s,
          children: [
            for (final field in fields)
              SizedBox(
                width: field.inline ? half : full,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      field.name,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      field.value,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.85,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
