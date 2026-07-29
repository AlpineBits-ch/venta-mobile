import 'package:freezed_annotation/freezed_annotation.dart';

part 'wiki_category_dto.freezed.dart';
part 'wiki_category_dto.g.dart';

@freezed
sealed class WikiCategoryDto with _$WikiCategoryDto {
  const factory WikiCategoryDto({
    required String id,
    required String guildId,
    required String name,
    @Default(0) int position,
    String? parentCategoryId,
  }) = _WikiCategoryDto;

  factory WikiCategoryDto.fromJson(Map<String, dynamic> json) =>
      _$WikiCategoryDtoFromJson(json);
}
