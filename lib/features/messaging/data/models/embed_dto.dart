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

  /// A link back to this instance, resolved in-process rather than fetched.
  /// Namespaced so it can never collide with a type Discord adds later.
  @JsonValue('venta.invite')
  ventaInvite,
  @JsonValue('venta.wiki_page')
  ventaWikiPage,

  /// "Come and join me in here" - the durable half of a voice ring, written by
  /// the server into the 1:1 conversation between the two people. Everything
  /// the card draws is in this embed's [EmbedDto.venta] block; the message's
  /// own body is a plain-English fallback for a client that has never heard of
  /// `MessageType.voiceChannelInvite`, and is suppressed by the timeline so it
  /// is not shown twice.
  @JsonValue('venta.voice_invite')
  ventaVoiceInvite,

  /// A layout this build has never heard of. Falls back to the [link] card,
  /// which degrades to "whatever fields happen to be present" and so renders
  /// something sane for any future type.
  ///
  /// The one exception is a `venta.*` type we do not recognise - see
  /// [EmbedDtoX.isUnrecognisedVenta]. A future internal-link kind will arrive
  /// before this build is replaced, and a half-drawn card claiming to be
  /// server-vouched is worse than no card.
  unknown,
}

/// Which internal-link card a [EmbedType.ventaInvite] /
/// [EmbedType.ventaWikiPage] / [EmbedType.ventaVoiceInvite] embed is, without
/// the `venta.` prefix, so there is one value to switch on.
enum EmbedVentaKind {
  @JsonValue('invite')
  invite,
  @JsonValue('wiki_page')
  wikiPage,
  @JsonValue('voice_invite')
  voiceInvite,
  unknown,
}

@freezed
sealed class EmbedDto with _$EmbedDto {
  @ApiDateTimeConverter()
  const factory EmbedDto({
    @Default(EmbedType.link)
    @JsonKey(unknownEnumValue: EmbedType.unknown)
    EmbedType type,

    /// `type` again, unparsed.
    ///
    /// Needed because a `venta.*` kind added after this build decodes to
    /// [EmbedType.unknown], which is indistinguishable from any other unknown
    /// type once the enum has swallowed the string - and the two want opposite
    /// treatment: an unknown ordinary type falls back to the link card, an
    /// unknown internal-link type draws nothing at all.
    @JsonKey(name: 'type', includeToJson: false) @Default('') String rawType,
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

    /// The identifiers behind a `venta.*` card.
    ///
    /// **Only trustworthy when [EmbedDtoX.isGenerated].** A bot authors its own
    /// embeds and may put any `venta` block it likes in one; see
    /// [EmbedDtoX.isServerVouchedVenta].
    EmbedVentaDto? venta,

    /// Bitfield. Bit 16 (65536) marks a card the server unfurled from a link
    /// rather than one its author wrote.
    @Default(0) int flags,
  }) = _EmbedDto;

  factory EmbedDto.fromJson(Map<String, dynamic> json) =>
      _$EmbedDtoFromJson(json);
}

/// The multi-word fields on an embed are **snake_case on the wire**, as
/// Discord's own embed object has them, and unlike the camelCase message fields
/// around them - `embedsJson` is an opaque string produced by a different
/// serializer, so `message.editedAt` and `embed.proxy_url` are both correct in
/// the same payload.
///
/// This build read them camel-cased until now, which meant [proxyUrl] was never
/// populated: every card silently hot-linked the third-party origin instead of
/// our proxy, handing that origin the IP address and read time of everyone who
/// scrolled past a link one other person posted. The placeholder and the
/// measured dimensions were lost the same way.
@freezed
sealed class EmbedMediaDto with _$EmbedMediaDto {
  const factory EmbedMediaDto({
    /// The origin's own URL. Never rendered directly - see [displayUrl].
    String? url,

    /// Our re-hosted copy: absolute, unauthenticated, immutable. Render this.
    @JsonKey(name: 'proxy_url') String? proxyUrl,

    /// True measured pixels, used to reserve layout space before the bytes
    /// land so an arriving card doesn't reflow the timeline.
    int? width,
    int? height,
    @JsonKey(name: 'content_type') String? contentType,

    /// BlurHash, shown blurred underneath the image while it loads.
    String? placeholder,

    /// Which encoding [placeholder] uses. `1` is BlurHash, and the only one
    /// this build can decode - see [blurHash].
    @JsonKey(name: 'placeholder_version') int? placeholderVersion,
  }) = _EmbedMediaDto;

  factory EmbedMediaDto.fromJson(Map<String, dynamic> json) =>
      _$EmbedMediaDtoFromJson(json);
}

/// The identifiers behind a `venta.*` card - what the link points at, so a
/// client can act on it without parsing the URL.
///
/// **Identifiers only, never a URL to call.** The obvious shape was a `refresh`
/// field carrying the endpoint to hit; it is deliberately absent, because a bot
/// authors its own embeds and a client that fetched a server-supplied URL with
/// the user's credentials would hand any bot author a credential harvester.
/// Compose the request from [RoutePaths]-style route tables of our own, and
/// only for an embed carrying the server-generated flag.
@freezed
sealed class EmbedVentaDto with _$EmbedVentaDto {
  @ApiDateTimeConverter()
  const factory EmbedVentaDto({
    @JsonKey(unknownEnumValue: EmbedVentaKind.unknown)
    @Default(EmbedVentaKind.unknown)
    EmbedVentaKind kind,

    /// Whether the server filled the human-readable fields in from the real
    /// record, or deliberately left them out. False means the card is a stub -
    /// see the wiki card, where a title is refused by design.
    @Default(false) bool resolved,
    @JsonKey(name: 'guild_id') String? guildId,

    /// The invite's short shareable code, not its id. Always the canonical
    /// generated code even when the pasted link was a vanity URL, so it
    /// survives a vanity rename.
    @JsonKey(name: 'invite_code') String? inviteCode,

    /// Invite: the channel a joiner lands on, when the invite names one. Voice
    /// invite: the channel being asked into. An id, never a name - except on a
    /// voice invite, which also carries [channelName].
    @JsonKey(name: 'channel_id') String? channelId,
    @JsonKey(name: 'page_id') String? pageId,

    /// Absent for an invite that never expires, and for a voice invitation that
    /// was sent as a plain message rather than as a ring - see the standing
    /// case in `_VentaVoiceInviteCard`, which is why "no expiry" must never be
    /// read as "expired". On a ring it is always present and is about a minute
    /// after the message was sent, which is what decides whether [ringId] still
    /// means anything.
    ///
    /// Safe to freeze into the card: an absolute instant does not go stale the
    /// way a stored "expired" boolean does.
    @JsonKey(name: 'expires_at') DateTime? expiresAt,

    /// Absent for unlimited. The running *use* count is deliberately not
    /// carried - re-resolve if you want to show it.
    @JsonKey(name: 'max_uses') int? maxUses,

    /// Voice invite only: the ring this card was written for.
    ///
    /// Live only until [expiresAt]. Past that, treat it as absent rather than
    /// as something to call - the ring no longer exists and accepting it
    /// answers `409`. The honest affordance there is the ordinary join, which
    /// accepts nothing.
    @JsonKey(name: 'ring_id') String? ringId,

    /// Voice invite only: who did the asking.
    ///
    /// The same person as the message's author today; carried so the card keeps
    /// meaning what it says if it is ever quoted. It is also what tells the
    /// *inviter* they are reading their own invitation, so the card can drop
    /// the Join button for the channel they are already sitting in.
    @JsonKey(name: 'inviter_id') String? inviterId,

    /// Voice invite only: the channel's name when the invitation was sent.
    ///
    /// The one place a `venta.*` card carries a name rather than only an id.
    /// The invite kind can leave it out because a client re-resolves it from
    /// the code, and the wiki kind *must* leave it out because the audience for
    /// a title is narrower than the audience for the message. Neither applies
    /// here: the recipient was checked for `ViewChannel` before the ring was
    /// allowed at all, and there is no later lookup that would let them fill it
    /// in. Render it; do not go and fetch a fresher one.
    @JsonKey(name: 'channel_name') String? channelName,
  }) = _EmbedVentaDto;

  factory EmbedVentaDto.fromJson(Map<String, dynamic> json) =>
      _$EmbedVentaDtoFromJson(json);
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
    @JsonKey(name: 'icon_url') String? iconUrl,
    @JsonKey(name: 'proxy_icon_url') String? proxyIconUrl,
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
    @JsonKey(name: 'icon_url') String? iconUrl,
    @JsonKey(name: 'proxy_icon_url') String? proxyIconUrl,
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

  /// Whether this claims to be an internal-link card at all, recognised or not.
  /// Read off [rawType] rather than [type] so a kind added after this build
  /// still counts as one.
  bool get isVentaType => rawType.startsWith(_ventaTypePrefix);

  /// An internal-link kind this build has a layout for.
  bool get isKnownVentaKind =>
      type == EmbedType.ventaInvite ||
      type == EmbedType.ventaWikiPage ||
      type == EmbedType.ventaVoiceInvite;

  /// An internal-link card this build may actually draw as one.
  ///
  /// The flag check is the whole of it. Without it the embed was written by
  /// whoever posted the message, and a bot can author one carrying any `venta`
  /// block it likes. It buys an attacker nothing - every action a card offers
  /// runs through an authenticated, permission-checked endpoint, so a
  /// fabricated `page_id` fails exactly as a real one the viewer cannot see
  /// does - but a card that *looks* server-vouched when it is not is a phishing
  /// surface, and this is a one-line check.
  bool get isServerVouchedVenta =>
      isKnownVentaKind && isGenerated && venta != null;

  /// A `venta.*` card whose kind this build does not know.
  ///
  /// Drawn as nothing rather than falling through to the link layout. A future
  /// internal-link kind will arrive before this build is replaced, and a
  /// half-rendered card is worse than no card.
  bool get isUnrecognisedVenta => isVentaType && !isKnownVentaKind;

  /// A card with nothing to draw. The server shouldn't send one, but every
  /// field on an embed comes from a third-party page that may have supplied
  /// nothing at all, so an empty shell is reachable.
  ///
  /// A server-vouched wiki stub is deliberately exempt: it carries no title and
  /// no description by design, and is still a card worth drawing.
  bool get isEmpty =>
      !isServerVouchedVenta &&
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
  static const _ventaTypePrefix = 'venta.';
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
