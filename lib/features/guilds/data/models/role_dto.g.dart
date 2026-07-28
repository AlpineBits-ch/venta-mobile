// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RoleDto _$RoleDtoFromJson(Map<String, dynamic> json) => _RoleDto(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  color: json['color'] as String?,
  guildId: json['guildId'] as String,
  permissions: json['permissions'] as String,
  type: $enumDecodeNullable(_$RoleTypeEnumMap, json['type']) ?? RoleType.none,
  position: (json['position'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$RoleDtoToJson(_RoleDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'color': instance.color,
  'guildId': instance.guildId,
  'permissions': instance.permissions,
  'type': _$RoleTypeEnumMap[instance.type]!,
  'position': instance.position,
};

const _$RoleTypeEnumMap = {
  RoleType.none: 'None',
  RoleType.everyone: 'Everyone',
};
