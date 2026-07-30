import 'package:freezed_annotation/freezed_annotation.dart';

part 'forum_post_dto.freezed.dart';
part 'forum_post_dto.g.dart';

/// One post in a Forum (or Media) channel. Physically it's the same
/// `Thread`-typed channel a text channel's threads use - this is that channel
/// plus the forum-specific fields the `/posts` endpoint layers on, which the
/// plain `/threads` list doesn't carry.
///
/// **Locked is not archived.** Archived means "off the default list, still
/// readable, revived by posting". Locked means "no new messages, by moderator
/// decision" and persists independently - a post can be either, both, or
/// neither, so they render differently (lock icon + dead composer vs a muted
/// card).
@freezed
sealed class ForumPostDto with _$ForumPostDto {
  const factory ForumPostDto({
    required String id,
    required String guildId,

    /// The forum channel this post belongs to.
    String? parentChannelId,

    /// The post title.
    required String name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdByUserId,

    /// Applied tags, already ordered by each tag's own `position` - render in
    /// array order rather than re-sorting.
    @Default(<String>[]) List<String> tagIds,
    @Default(false) bool isPinned,
    @Default(false) bool isLocked,
    @Default(false) bool isArchived,

    /// When this post auto-archives absent further activity. Honoured by a
    /// periodic sweep, so it can lag a few minutes - don't render a live
    /// countdown that hits zero and stalls.
    DateTime? autoArchiveAt,

    /// This post's own archive window, snapshotted from the forum's config at
    /// creation - so changing the forum default later leaves it alone.
    int? autoArchiveMinutes,

    /// Last message timestamp; null for a post nobody has replied in (and for
    /// every post created before the backend started tracking it).
    DateTime? lastActivityAt,
    @Default(0) int messageCount,
    @Default(false) bool isAgeRestricted,
    @Default(false) bool isPrivate,
    @Default(0) int slowModeSeconds,
  }) = _ForumPostDto;

  factory ForumPostDto.fromJson(Map<String, dynamic> json) =>
      _$ForumPostDtoFromJson(json);
}

/// One keyset-paginated page of [ForumPostDto]s. [nextCursor] is an opaque
/// base64 blob tied to the sort/filter params it was issued under - pass it
/// back verbatim, never parse or persist it, and start from page one whenever
/// a filter changes.
@freezed
sealed class ForumPostPageDto with _$ForumPostPageDto {
  const factory ForumPostPageDto({
    @Default(<ForumPostDto>[]) List<ForumPostDto> posts,
    String? nextCursor,
  }) = _ForumPostPageDto;

  factory ForumPostPageDto.fromJson(Map<String, dynamic> json) =>
      _$ForumPostPageDtoFromJson(json);
}

/// `archived` query-param values for the post list.
enum ForumArchiveFilter {
  active('false'),
  archived('true'),
  all('all');

  const ForumArchiveFilter(this.wireValue);
  final String wireValue;
}
