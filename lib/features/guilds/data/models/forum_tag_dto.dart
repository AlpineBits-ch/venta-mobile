import 'package:freezed_annotation/freezed_annotation.dart';

part 'forum_tag_dto.freezed.dart';
part 'forum_tag_dto.g.dart';

/// A label defined *on one forum channel* - tags never span forums, and a tag
/// id is meaningless outside the forum that owns it. Posts carry a subset of
/// their forum's tags (max 5, see [ForumTagLimits]).
@freezed
sealed class ForumTagDto with _$ForumTagDto {
  const factory ForumTagDto({
    required String id,
    required String channelId,
    required String guildId,
    required String name,

    /// A guild custom emoji id (`emoj_...`) - mutually exclusive with
    /// [emojiName]. May outlive the emoji itself: if the guild emoji was
    /// deleted this still resolves to nothing, so render the tag bare rather
    /// than showing a broken image.
    String? emojiId,

    /// A unicode emoji glyph, e.g. `🐛`.
    String? emojiName,
    @Default('#000000') String color,
    @Default(0) int position,

    /// Only moderators may apply/remove this tag. Flipping it on doesn't
    /// strip the tag from posts that already carry it.
    @Default(false) bool moderated,

    /// Non-archived posts currently carrying this tag, computed per request -
    /// fine for a filter-bar badge, not something to cache.
    @Default(0) int postCount,
  }) = _ForumTagDto;

  factory ForumTagDto.fromJson(Map<String, dynamic> json) =>
      _$ForumTagDtoFromJson(json);
}

/// Server-enforced caps worth mirroring client-side so the UI blocks rather
/// than round-trips into a `400`.
abstract final class ForumTagLimits {
  static const tagsPerForum = 20;
  static const appliedTagsPerPost = 5;
  static const nameLength = 20;
}
