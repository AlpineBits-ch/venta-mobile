// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guild_template_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GuildTemplateDto _$GuildTemplateDtoFromJson(Map<String, dynamic> json) =>
    _GuildTemplateDto(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: const ApiDateTimeConverter().fromJson(
        json['createdAt'] as String,
      ),
    );

Map<String, dynamic> _$GuildTemplateDtoToJson(_GuildTemplateDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'createdAt': const ApiDateTimeConverter().toJson(instance.createdAt),
    };

_TemplateChannelDto _$TemplateChannelDtoFromJson(Map<String, dynamic> json) =>
    _TemplateChannelDto(
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
      position: (json['position'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$TemplateChannelDtoToJson(_TemplateChannelDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'description': instance.description,
      'position': instance.position,
    };

_TemplateCategoryDto _$TemplateCategoryDtoFromJson(Map<String, dynamic> json) =>
    _TemplateCategoryDto(
      name: json['name'] as String,
      position: (json['position'] as num?)?.toInt() ?? 0,
      channels:
          (json['channels'] as List<dynamic>?)
              ?.map(
                (e) => TemplateChannelDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TemplateCategoryDtoToJson(
  _TemplateCategoryDto instance,
) => <String, dynamic>{
  'name': instance.name,
  'position': instance.position,
  'channels': instance.channels,
};

_TemplateRoleDto _$TemplateRoleDtoFromJson(Map<String, dynamic> json) =>
    _TemplateRoleDto(
      name: json['name'] as String,
      color: json['color'] as String,
      position: (json['position'] as num?)?.toInt() ?? 0,
      permissions: (json['permissions'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$TemplateRoleDtoToJson(_TemplateRoleDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'color': instance.color,
      'position': instance.position,
      'permissions': instance.permissions,
    };

_TemplateSnapshotDto _$TemplateSnapshotDtoFromJson(
  Map<String, dynamic> json,
) => _TemplateSnapshotDto(
  roles:
      (json['roles'] as List<dynamic>?)
          ?.map((e) => TemplateRoleDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => TemplateCategoryDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  uncategorizedChannels:
      (json['uncategorizedChannels'] as List<dynamic>?)
          ?.map((e) => TemplateChannelDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$TemplateSnapshotDtoToJson(
  _TemplateSnapshotDto instance,
) => <String, dynamic>{
  'roles': instance.roles,
  'categories': instance.categories,
  'uncategorizedChannels': instance.uncategorizedChannels,
};

_GuildTemplateDetailDto _$GuildTemplateDetailDtoFromJson(
  Map<String, dynamic> json,
) => _GuildTemplateDetailDto(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  creatorUserId: json['creatorUserId'] as String,
  createdAt: const ApiDateTimeConverter().fromJson(json['createdAt'] as String),
  usageCount: (json['usageCount'] as num?)?.toInt() ?? 0,
  snapshot: TemplateSnapshotDto.fromJson(
    json['snapshot'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$GuildTemplateDetailDtoToJson(
  _GuildTemplateDetailDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'creatorUserId': instance.creatorUserId,
  'createdAt': const ApiDateTimeConverter().toJson(instance.createdAt),
  'usageCount': instance.usageCount,
  'snapshot': instance.snapshot,
};
