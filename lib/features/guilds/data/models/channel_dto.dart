import 'package:freezed_annotation/freezed_annotation.dart';

import 'guild_permissions.dart';

part 'channel_dto.freezed.dart';
part 'channel_dto.g.dart';

enum ChannelType {
  @JsonValue('Text')
  text,
  @JsonValue('Voice')
  voice,
  @JsonValue('Thread')
  thread,
  @JsonValue('Announcement')
  announcement,
  @JsonValue('Forum')
  forum,

  /// A forum variant - same tags, same posts, same endpoints; only the
  /// intended rendering differs (gallery-first, media-forward). Everywhere the
  /// forum docs say "forum", read "forum or media channel".
  @JsonValue('Media')
  media,
}

extension ChannelTypeX on ChannelType {
  /// Forum and Media channels are both post containers driven by the same
  /// `/posts`, `/tags` and `/forum-config` endpoints.
  bool get isForumLike =>
      this == ChannelType.forum || this == ChannelType.media;
}

@freezed
sealed class ChannelPermissionDto with _$ChannelPermissionDto {
  const factory ChannelPermissionDto({
    required String id,
    String? channelId,
    String? roleId,
    String? memberId,
    String? categoryId,
    required String allowPermissions,
    required String denyPermissions,
  }) = _ChannelPermissionDto;

  factory ChannelPermissionDto.fromJson(Map<String, dynamic> json) =>
      _$ChannelPermissionDtoFromJson(json);
}

extension ChannelPermissionDtoX on ChannelPermissionDto {
  GuildPermissions get allow => GuildPermissions.parse(allowPermissions);
  GuildPermissions get deny => GuildPermissions.parse(denyPermissions);
}

@freezed
sealed class ChannelDto with _$ChannelDto {
  const factory ChannelDto({
    required String id,
    required String name,
    String? description,
    @JsonKey(unknownEnumValue: ChannelType.text) required ChannelType type,
    required String guildId,
    @Default(false) bool isAgeRestricted,
    @Default(false) bool isPrivate,
    String? categoryId,
    @Default(<ChannelPermissionDto>[]) List<ChannelPermissionDto> permissions,
    @Default(0) int position,
    @Default(0) int slowModeSeconds,
    String? parentChannelId,

    // Forum-parity additions, all only meaningful on a `Thread` (i.e. a forum
    // post - see `ForumPostDto`, which is this same entity as returned by the
    // richer `/posts` endpoint). Additive: a `Thread` from the plain
    // `/threads` list simply leaves them at their defaults.
    @Default(<String>[]) List<String> tagIds,
    @Default(false) bool isPinned,

    /// No new messages, by moderator decision - distinct from archived, and
    /// persisting independently of it.
    @Default(false) bool isLocked,
    @Default(false) bool isArchived,
    DateTime? lastActivityAt,
    @Default(0) int messageCount,
    DateTime? autoArchiveAt,
  }) = _ChannelDto;

  factory ChannelDto.fromJson(Map<String, dynamic> json) =>
      _$ChannelDtoFromJson(json);
}
