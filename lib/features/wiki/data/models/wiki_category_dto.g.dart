// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wiki_category_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WikiCategoryDto _$WikiCategoryDtoFromJson(Map<String, dynamic> json) =>
    _WikiCategoryDto(
      id: json['id'] as String,
      guildId: json['guildId'] as String,
      name: json['name'] as String,
      position: (json['position'] as num?)?.toInt() ?? 0,
      parentCategoryId: json['parentCategoryId'] as String?,
    );

Map<String, dynamic> _$WikiCategoryDtoToJson(_WikiCategoryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'guildId': instance.guildId,
      'name': instance.name,
      'position': instance.position,
      'parentCategoryId': instance.parentCategoryId,
    };
