import 'package:freezed_annotation/freezed_annotation.dart';

part 'forum_config_dto.freezed.dart';
part 'forum_config_dto.g.dart';

/// Which order a forum's post list defaults to. The list endpoint's own
/// `sort` query param uses shorter wire values (`activity`/`created`) - see
/// [ForumSortOrderX.querySortValue].
enum ForumSortOrder {
  @JsonValue('LatestActivity')
  latestActivity,
  @JsonValue('CreationDate')
  creationDate,
}

extension ForumSortOrderX on ForumSortOrder {
  String get querySortValue =>
      this == ForumSortOrder.latestActivity ? 'activity' : 'created';

  String get label =>
      this == ForumSortOrder.latestActivity ? 'Latest activity' : 'Date posted';
}

enum ForumLayout {
  @JsonValue('List')
  list,
  @JsonValue('Gallery')
  gallery,
}

/// Per-forum posting settings. Every forum has one - the backend creates it
/// with defaults on first read, so `GET` never 404s on a real forum.
///
/// [defaultLayout] and `defaultReactionEmoji*` are presentation hints the
/// backend only stores and echoes: they exist so a moderator's house style
/// syncs across devices. Nothing server-side acts on them.
@freezed
sealed class ForumConfigDto with _$ForumConfigDto {
  const factory ForumConfigDto({
    String? channelId,

    /// Posts must carry at least one tag. Enforced at write time only - it's
    /// never applied retroactively to posts that predate it.
    @Default(false) bool requireTag,
    @Default(ForumSortOrder.latestActivity) ForumSortOrder defaultSortOrder,
    @Default(ForumLayout.list) ForumLayout defaultLayout,
    String? defaultReactionEmojiId,
    String? defaultReactionEmojiName,

    /// Copied onto each new post at creation; changing it leaves existing
    /// posts alone.
    @Default(0) int defaultThreadSlowModeSeconds,

    /// One of [autoArchiveChoices] - 3 days by default.
    @Default(4320) int defaultAutoArchiveMinutes,
  }) = _ForumConfigDto;

  factory ForumConfigDto.fromJson(Map<String, dynamic> json) =>
      _$ForumConfigDtoFromJson(json);

  /// The only values the backend accepts for `defaultAutoArchiveMinutes`.
  static const autoArchiveChoices = <int>[60, 1440, 4320, 10080];
}
