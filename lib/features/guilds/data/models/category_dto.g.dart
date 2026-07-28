// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CategoryDto _$CategoryDtoFromJson(Map<String, dynamic> json) => _CategoryDto(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  permissions:
      (json['permissions'] as List<dynamic>?)
          ?.map((e) => ChannelPermissionDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ChannelPermissionDto>[],
  position: (json['position'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$CategoryDtoToJson(_CategoryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'permissions': instance.permissions,
      'position': instance.position,
    };
