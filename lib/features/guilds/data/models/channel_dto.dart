import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';

import 'guild_features.dart';
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

  // Household module channels. These hold structured rows, not messages -
  // there is no message history and no `POST /messages` behind any of them.
  // They arrive from the ordinary channel endpoints alongside Text and Voice,
  // so the sidebar already receives them; the work is knowing not to open a
  // composer on one.
  @JsonValue('List')
  list,
  @JsonValue('Chores')
  chores,
  @JsonValue('Ledger')
  ledger,
  @JsonValue('Pantry')
  pantry,
  @JsonValue('Decisions')
  decisions,
  @JsonValue('Meals')
  meals,

  /// The house's appliances and their service history - `# upkeep` on a
  /// seeded household.
  @JsonValue('Maintenance')
  maintenance,

  /// A type this build has never heard of - a household channel seen by a
  /// client that predates them, or whatever gets appended next.
  ///
  /// Deliberately its own value rather than falling back to [text]: treating
  /// an unrecognised type as Text is precisely the failure that puts a
  /// message composer on a shopping list. Unknown renders inert instead.
  unknown,
}

extension ChannelTypeX on ChannelType {
  /// Forum and Media channels are both post containers driven by the same
  /// `/posts`, `/tags` and `/forum-config` endpoints.
  bool get isForumLike =>
      this == ChannelType.forum || this == ChannelType.media;

  /// Backed by a household module: structured rows, and a `403` on every one
  /// of its endpoints unless the guild has the module.
  bool get isHouseholdModule => const {
    ChannelType.list,
    ChannelType.chores,
    ChannelType.ledger,
    ChannelType.pantry,
    ChannelType.decisions,
    ChannelType.meals,
    ChannelType.maintenance,
  }.contains(this);

  /// Whether this channel has message history and a composer at all.
  ///
  /// False for every household type and for [unknown] - route on this before
  /// rendering anything that can post, mark as read, or mute, because none of
  /// those concepts exist for a shopping list.
  bool get hasMessages => this != ChannelType.unknown && !isHouseholdModule;

  /// The `GuildFeature` flag this channel type belongs to, or null for the
  /// types that aren't gated on a module (Text, Thread).
  String? get requiredFeature => switch (this) {
    ChannelType.voice => GuildFeature.voiceChannels,
    ChannelType.forum || ChannelType.media => GuildFeature.forums,
    ChannelType.announcement => GuildFeature.announcements,
    ChannelType.list => GuildFeature.lists,
    ChannelType.chores => GuildFeature.chores,
    ChannelType.ledger => GuildFeature.ledger,
    ChannelType.pantry => GuildFeature.pantry,
    ChannelType.decisions => GuildFeature.decisions,
    ChannelType.meals => GuildFeature.meals,
    ChannelType.maintenance => GuildFeature.maintenance,
    _ => null,
  };
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
  @ApiDateTimeConverter()
  const factory ChannelDto({
    required String id,
    required String name,
    String? description,
    @JsonKey(unknownEnumValue: ChannelType.unknown) required ChannelType type,
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
