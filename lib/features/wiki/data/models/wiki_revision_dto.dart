import 'package:freezed_annotation/freezed_annotation.dart';

part 'wiki_revision_dto.freezed.dart';
part 'wiki_revision_dto.g.dart';

@freezed
sealed class WikiRevisionDto with _$WikiRevisionDto {
  const factory WikiRevisionDto({
    required String id,
    required String pageId,
    required String content,
    required String editorId,
    DateTime? createdAt,
    @Default(0) int revisionNumber,
    String? summary,
  }) = _WikiRevisionDto;

  factory WikiRevisionDto.fromJson(Map<String, dynamic> json) =>
      _$WikiRevisionDtoFromJson(json);
}
