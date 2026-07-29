import 'package:freezed_annotation/freezed_annotation.dart';

part 'wiki_page_summary_dto.freezed.dart';
part 'wiki_page_summary_dto.g.dart';

/// Wire values are PascalCase (`Public`/`Private`) — matching every other
/// enum in this API (`OnlineStatus`, `ChannelType`, etc.) despite Alpine's
/// own TypeScript type alias (`'public' | 'private'`) suggesting lowercase;
/// verified against a live `GET .../wiki` response.
enum WikiVisibility {
  @JsonValue('Public')
  public,
  @JsonValue('Private')
  private,
}

/// The list-view shape returned by `GET .../wiki` — every page except its
/// `content` (fetched lazily per-page, see `WikiPageDto`). Mirrors Alpine's
/// `WikiPageSummaryDto`.
@freezed
sealed class WikiPageSummaryDto with _$WikiPageSummaryDto {
  const factory WikiPageSummaryDto({
    required String id,
    required String guildId,
    required String title,
    required String slug,
    required String authorId,
    String? lastEditorId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? parentPageId,
    String? categoryId,
    @Default(WikiVisibility.private) WikiVisibility visibility,
    @Default(<String>[]) List<String> tags,
    @Default(false) bool isPinned,
    @Default(0) int revisionCount,
  }) = _WikiPageSummaryDto;

  factory WikiPageSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$WikiPageSummaryDtoFromJson(json);
}
