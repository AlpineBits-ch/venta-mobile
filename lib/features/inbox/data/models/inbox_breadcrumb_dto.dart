import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../guilds/data/models/channel_dto.dart';

part 'inbox_breadcrumb_dto.freezed.dart';
part 'inbox_breadcrumb_dto.g.dart';

/// Where an inbox row came from: guild › category › channel, plus the parent
/// channel when the row is a thread or a forum post.
///
/// Everything here is denormalised onto the row on purpose - the inbox spans
/// every guild the caller is in, so resolving names from `GuildRepository`
/// would mean either fetching guilds the user hasn't opened this session or
/// rendering half the list without labels.
@freezed
sealed class InboxBreadcrumbDto with _$InboxBreadcrumbDto {
  const factory InboxBreadcrumbDto({
    @Default('') String guildId,
    @Default('') String guildName,

    /// A fixed path that *redirects* to a presigned URL, not a stored value -
    /// and a `404` when the guild has no icon, which is the ordinary case.
    /// `InboxGuildIcon` draws the name initial underneath and lets the image
    /// cover it only when it really loads, so a 404 degrades to the fallback
    /// instead of a blank square. Absolutised against the current server by
    /// `InboxApi` - the wire value is server-relative.
    String? guildIconUrl,

    /// The small variant, which is what the inbox is sized for.
    String? guildIconThumbnailUrl,

    /// Null when the channel is uncategorised.
    String? categoryId,
    String? categoryName,
    @Default('') String channelId,
    @Default('') String channelName,

    /// Int on this endpoint, where `ChannelDto.type` is a string - see
    /// [InboxBreadcrumbDtoX.channelKind] for the mapping.
    @Default(0) int channelType,

    /// Set for threads and forum posts; [channelName] is then the post's own
    /// title and this names the forum it lives in.
    String? parentChannelId,
    String? parentChannelName,
  }) = _InboxBreadcrumbDto;

  factory InboxBreadcrumbDto.fromJson(Map<String, dynamic> json) =>
      _$InboxBreadcrumbDtoFromJson(json);
}

extension InboxBreadcrumbDtoX on InboxBreadcrumbDto {
  /// [InboxBreadcrumbDto.channelType] as the [ChannelType] the rest of the app
  /// speaks.
  ///
  /// The int is the server enum's ordinal, which is the order [ChannelType]
  /// already declares its members in. [ChannelType.unknown] is this client's
  /// own sentinel and has no server counterpart, so it sits past the end of
  /// that range and is what an unrecognised ordinal falls back to - an
  /// out-of-range value renders inert rather than being read as Text, for the
  /// same reason spelled out on [ChannelType.unknown] itself.
  ChannelType get channelKind {
    final serverValues = ChannelType.values.length - 1;
    if (channelType < 0 || channelType >= serverValues) {
      return ChannelType.unknown;
    }
    return ChannelType.values[channelType];
  }

  /// `#channel`, or `forum › post` for a thread/forum post.
  String get channelLabel => parentChannelName == null
      ? channelName
      : '$parentChannelName › $channelName';

  /// The middle line of the breadcrumb: the guild, then the category when
  /// there is one.
  String get contextLabel =>
      categoryName == null ? guildName : '$guildName › $categoryName';
}
