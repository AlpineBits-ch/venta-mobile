// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wiki_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WikiDto _$WikiDtoFromJson(Map<String, dynamic> json) => _WikiDto(
  id: json['id'] as String,
  guildId: json['guildId'] as String,
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => WikiCategoryDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <WikiCategoryDto>[],
  pages:
      (json['pages'] as List<dynamic>?)
          ?.map((e) => WikiPageSummaryDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <WikiPageSummaryDto>[],
);

Map<String, dynamic> _$WikiDtoToJson(_WikiDto instance) => <String, dynamic>{
  'id': instance.id,
  'guildId': instance.guildId,
  'categories': instance.categories,
  'pages': instance.pages,
};
