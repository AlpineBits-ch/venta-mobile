import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';

part 'embed_dto.freezed.dart';
part 'embed_dto.g.dart';

/// Picks the card layout. Bot-authored cards are [rich]; everything else is
/// a server-generated link preview, unfurled from a URL in the body some
/// seconds *after* the message itself arrives.
enum EmbedType {
  @JsonValue('rich')
  rich,
  @JsonValue('link')
  link,
  @JsonValue('article')
  article,
  @JsonValue('image')
  image,
  @JsonValue('video')
  video,
  @JsonValue('gifv')
  gifv,

  /// A layout this build has never heard of. Falls back to the [link] card,
  /// which degrades to "whatever fields happen to be present" and so renders
  /// something sane for any future type.
  unknown,
}

@freezed
sealed class EmbedDto with _$EmbedDto {
  @ApiDateTimeConverter()
  const factory EmbedDto({
    @Default(EmbedType.link)
    @JsonKey(unknownEnumValue: EmbedType.unknown)
    EmbedType type,
    String? title,
    String? description,
    String? url,

    /// The *content's* own date (a publication date, say) - not when the
    /// preview was generated.
    DateTime? timestamp,

    /// `#rrggbb`, and the card's left accent bar. Null for most generated
    /// previews; bots set it deliberately.
    String? color,
    EmbedProviderDto? provider,
    EmbedAuthorDto? author,

    /// Small, beside the text. Doubles as the poster frame for [video].
    EmbedMediaDto? thumbnail,

    /// Large, full-width below the text.
    EmbedMediaDto? image,

    /// A player-capable provider (YouTube/Vimeo/Twitch/Spotify). [url] here is
    /// an embeddable iframe document, which this client has no sandboxed frame
    /// to put it in - see `MessageEmbedsView`, which degrades to a play badge
    /// that opens the original externally.
    EmbedMediaDto? video,
    @Default(<EmbedFieldDto>[]) List<EmbedFieldDto> fields,
    EmbedFooterDto? footer,

    /// Bitfield. Bit 16 (65536) marks a card the server unfurled from a link
    /// rather than one its author wrote.
    @Default(0) int flags,
  }) = _EmbedDto;

  factory EmbedDto.fromJson(Map<String, dynamic> json) =>
      _$EmbedDtoFromJson(json);
}

@freezed
sealed class EmbedMediaDto with _$EmbedMediaDto {
  const factory EmbedMediaDto({
    /// The origin's own URL. Never rendered directly - see [displayUrl].
    String? url,

    /// Our re-hosted copy: absolute, unauthenticated, immutable. Render this.
    String? proxyUrl,

    /// True measured pixels, used to reserve layout space before the bytes
    /// land so an arriving card doesn't reflow the timeline.
    int? width,
    int? height,
    String? contentType,

    /// BlurHash, shown blurred underneath the image while it loads.
    String? placeholder,

    /// Which encoding [placeholder] uses. `1` is BlurHash, and the only one
    /// this build can decode - see [blurHash].
    int? placeholderVersion,
  }) = _EmbedMediaDto;

  factory EmbedMediaDto.fromJson(Map<String, dynamic> json) =>
      _$EmbedMediaDtoFromJson(json);
}

@freezed
sealed class EmbedFieldDto with _$EmbedFieldDto {
  const factory EmbedFieldDto({
    @Default('') String name,
    @Default('') String value,
    @Default(false) bool inline,
  }) = _EmbedFieldDto;

  factory EmbedFieldDto.fromJson(Map<String, dynamic> json) =>
      _$EmbedFieldDtoFromJson(json);
}

@freezed
sealed class EmbedAuthorDto with _$EmbedAuthorDto {
  const factory EmbedAuthorDto({
    @Default('') String name,
    String? url,
    String? iconUrl,
    String? proxyIconUrl,
  }) = _EmbedAuthorDto;

  factory EmbedAuthorDto.fromJson(Map<String, dynamic> json) =>
      _$EmbedAuthorDtoFromJson(json);
}

@freezed
sealed class EmbedProviderDto with _$EmbedProviderDto {
  const factory EmbedProviderDto({@Default('') String name, String? url}) =
      _EmbedProviderDto;

  factory EmbedProviderDto.fromJson(Map<String, dynamic> json) =>
      _$EmbedProviderDtoFromJson(json);
}

@freezed
sealed class EmbedFooterDto with _$EmbedFooterDto {
  const factory EmbedFooterDto({
    @Default('') String text,
    String? iconUrl,
    String? proxyIconUrl,
  }) = _EmbedFooterDto;

  factory EmbedFooterDto.fromJson(Map<String, dynamic> json) =>
      _$EmbedFooterDtoFromJson(json);
}

extension EmbedMediaDtoX on EmbedMediaDto {
  /// What to actually put in an `<img>`.
  ///
  /// [proxyUrl] wins whenever it exists, and not as a nicety: loading [url]
  /// hands a third-party origin the IP address, rough location and read time
  /// of everyone who scrolls past a link *one other person* posted. Keep [url]
  /// for an "open original" affordance and nothing else.
  String? get displayUrl {
    final proxy = proxyUrl;
    if (proxy != null && proxy.isNotEmpty) return proxy;
    final origin = url;
    return (origin != null && origin.isNotEmpty) ? origin : null;
  }

  /// The BlurHash to blur underneath the image while it loads, or null when
  /// there isn't one this build can decode.
  ///
  /// The version check is the point: a future encoding would be a string of
  /// the right shape and entirely the wrong meaning, and feeding it to a
  /// BlurHash decoder produces noise rather than an error.
  String? get blurHash {
    final hash = placeholder;
    if (hash == null || hash.isEmpty) return null;
    if (placeholderVersion != _blurHashVersion) return null;
    return hash;
  }

  /// Aspect ratio to reserve, or null when the server measured neither side.
  double? get aspectRatio {
    final w = width;
    final h = height;
    if (w == null || h == null || w <= 0 || h <= 0) return null;
    return w / h;
  }

  static const _blurHashVersion = 1;
}

extension EmbedAuthorDtoX on EmbedAuthorDto {
  /// The proxied avatar, falling back to the origin's - same
  /// leak-nothing-by-default rule as [EmbedMediaDtoX.displayUrl].
  String? get displayIconUrl => _firstNonEmpty(proxyIconUrl, iconUrl);
}

extension EmbedFooterDtoX on EmbedFooterDto {
  String? get displayIconUrl => _firstNonEmpty(proxyIconUrl, iconUrl);
}

String? _firstNonEmpty(String? preferred, String? fallback) {
  if (preferred != null && preferred.isNotEmpty) return preferred;
  return (fallback != null && fallback.isNotEmpty) ? fallback : null;
}

extension EmbedDtoX on EmbedDto {
  /// Server-unfurled from a link in the body, as opposed to written by the
  /// message's author. Drives nothing visual today - Discord doesn't
  /// distinguish them either - but it is what separates "this card belongs to
  /// the bot that posted it" from "this card is a preview of somebody's link".
  bool get isGenerated => (flags & _generatedFromContent) != 0;

  /// A card with nothing to draw. The server shouldn't send one, but every
  /// field on an embed comes from a third-party page that may have supplied
  /// nothing at all, so an empty shell is reachable.
  bool get isEmpty =>
      (title?.isEmpty ?? true) &&
      (description?.isEmpty ?? true) &&
      (provider?.name.isEmpty ?? true) &&
      (author?.name.isEmpty ?? true) &&
      (footer?.text.isEmpty ?? true) &&
      fields.isEmpty &&
      thumbnail?.displayUrl == null &&
      image?.displayUrl == null &&
      video == null;

  static const _generatedFromContent = 1 << 16;
}

/// Decodes `MessageDto.embedsJson`, which is a JSON-encoded **string** rather
/// than a nested object.
///
/// Never throws: a card is decoration, and a message whose embeds fail to
/// parse still has to render its text. Results are memoised because the
/// timeline rebuilds this for every visible row on every frame of a scroll,
/// and re-parsing a 4KB document per row per frame is not free.
List<EmbedDto> parseEmbedsJson(String? embedsJson) {
  if (embedsJson == null || embedsJson.isEmpty) return const [];

  final cached = _embedCache[embedsJson];
  if (cached != null) return cached;

  var parsed = const <EmbedDto>[];
  try {
    final decoded = jsonDecode(embedsJson);
    if (decoded is List) {
      parsed = [
        for (final entry in decoded)
          if (entry is Map) EmbedDto.fromJson(entry.cast<String, dynamic>()),
      ];
    }
  } catch (e) {
    debugPrint('parseEmbedsJson: could not read embeds: $e');
  }

  // Crude but sufficient: the cache only has to span a scroll session, and
  // dropping it wholesale costs one re-parse of whatever is on screen.
  if (_embedCache.length >= _embedCacheLimit) _embedCache.clear();
  _embedCache[embedsJson] = parsed;
  return parsed;
}

final _embedCache = <String, List<EmbedDto>>{};
const _embedCacheLimit = 256;
