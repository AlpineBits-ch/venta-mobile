import 'package:freezed_annotation/freezed_annotation.dart';

import 'wiki_category_dto.dart';
import 'wiki_page_summary_dto.dart';

part 'wiki_dto.freezed.dart';
part 'wiki_dto.g.dart';

/// The whole-wiki shape returned by `GET .../guilds/{guildId}/wiki` - every
/// category plus every page *summary* (no content) in one round trip.
@freezed
sealed class WikiDto with _$WikiDto {
  const factory WikiDto({
    required String id,
    required String guildId,
    @Default(<WikiCategoryDto>[]) List<WikiCategoryDto> categories,
    @Default(<WikiPageSummaryDto>[]) List<WikiPageSummaryDto> pages,
  }) = _WikiDto;

  factory WikiDto.fromJson(Map<String, dynamic> json) =>
      _$WikiDtoFromJson(json);
}
