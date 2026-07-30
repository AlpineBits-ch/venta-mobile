import 'package:freezed_annotation/freezed_annotation.dart';

import 'wiki_page_summary_dto.dart';

part 'wiki_page_dto.freezed.dart';
part 'wiki_page_dto.g.dart';

/// The full page shape returned by `GET .../wiki/pages/{id}` and by
/// create/update - a [WikiPageSummaryDto] plus `content` (markdown text on
/// the wire, per Alpine's `renderWikiMarkdown`/TipTap-markdown-export
/// pipeline). Kept as a flat class rather than extending the summary since
/// freezed doesn't support class inheritance.
@freezed
sealed class WikiPageDto with _$WikiPageDto {
  const factory WikiPageDto({
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
    @Default('') String content,
  }) = _WikiPageDto;

  factory WikiPageDto.fromJson(Map<String, dynamic> json) =>
      _$WikiPageDtoFromJson(json);
}

extension WikiPageDtoX on WikiPageDto {
  WikiPageSummaryDto toSummary() => WikiPageSummaryDto(
    id: id,
    guildId: guildId,
    title: title,
    slug: slug,
    authorId: authorId,
    lastEditorId: lastEditorId,
    createdAt: createdAt,
    updatedAt: updatedAt,
    parentPageId: parentPageId,
    categoryId: categoryId,
    visibility: visibility,
    tags: tags,
    isPinned: isPinned,
    revisionCount: revisionCount,
  );
}
