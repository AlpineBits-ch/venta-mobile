// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChannelPermissionDto _$ChannelPermissionDtoFromJson(
  Map<String, dynamic> json,
) => _ChannelPermissionDto(
  id: json['id'] as String,
  channelId: json['channelId'] as String?,
  roleId: json['roleId'] as String?,
  memberId: json['memberId'] as String?,
  categoryId: json['categoryId'] as String?,
  allowPermissions: json['allowPermissions'] as String,
  denyPermissions: json['denyPermissions'] as String,
);

Map<String, dynamic> _$ChannelPermissionDtoToJson(
  _ChannelPermissionDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'channelId': instance.channelId,
  'roleId': instance.roleId,
  'memberId': instance.memberId,
  'categoryId': instance.categoryId,
  'allowPermissions': instance.allowPermissions,
  'denyPermissions': instance.denyPermissions,
};

_ChannelDto _$ChannelDtoFromJson(Map<String, dynamic> json) => _ChannelDto(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  type: $enumDecode(
    _$ChannelTypeEnumMap,
    json['type'],
    unknownValue: ChannelType.unknown,
  ),
  guildId: json['guildId'] as String,
  isAgeRestricted: json['isAgeRestricted'] as bool? ?? false,
  isPrivate: json['isPrivate'] as bool? ?? false,
  categoryId: json['categoryId'] as String?,
  permissions:
      (json['permissions'] as List<dynamic>?)
          ?.map((e) => ChannelPermissionDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ChannelPermissionDto>[],
  position: (json['position'] as num?)?.toInt() ?? 0,
  slowModeSeconds: (json['slowModeSeconds'] as num?)?.toInt() ?? 0,
  parentChannelId: json['parentChannelId'] as String?,
  tagIds:
      (json['tagIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  isPinned: json['isPinned'] as bool? ?? false,
  isLocked: json['isLocked'] as bool? ?? false,
  isArchived: json['isArchived'] as bool? ?? false,
  lastActivityAt: _$JsonConverterFromJson<String, DateTime>(
    json['lastActivityAt'],
    const ApiDateTimeConverter().fromJson,
  ),
  messageCount: (json['messageCount'] as num?)?.toInt() ?? 0,
  autoArchiveAt: _$JsonConverterFromJson<String, DateTime>(
    json['autoArchiveAt'],
    const ApiDateTimeConverter().fromJson,
  ),
);

Map<String, dynamic> _$ChannelDtoToJson(_ChannelDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': _$ChannelTypeEnumMap[instance.type]!,
      'guildId': instance.guildId,
      'isAgeRestricted': instance.isAgeRestricted,
      'isPrivate': instance.isPrivate,
      'categoryId': instance.categoryId,
      'permissions': instance.permissions,
      'position': instance.position,
      'slowModeSeconds': instance.slowModeSeconds,
      'parentChannelId': instance.parentChannelId,
      'tagIds': instance.tagIds,
      'isPinned': instance.isPinned,
      'isLocked': instance.isLocked,
      'isArchived': instance.isArchived,
      'lastActivityAt': _$JsonConverterToJson<String, DateTime>(
        instance.lastActivityAt,
        const ApiDateTimeConverter().toJson,
      ),
      'messageCount': instance.messageCount,
      'autoArchiveAt': _$JsonConverterToJson<String, DateTime>(
        instance.autoArchiveAt,
        const ApiDateTimeConverter().toJson,
      ),
    };

const _$ChannelTypeEnumMap = {
  ChannelType.text: 'Text',
  ChannelType.voice: 'Voice',
  ChannelType.thread: 'Thread',
  ChannelType.announcement: 'Announcement',
  ChannelType.forum: 'Forum',
  ChannelType.media: 'Media',
  ChannelType.list: 'List',
  ChannelType.chores: 'Chores',
  ChannelType.ledger: 'Ledger',
  ChannelType.pantry: 'Pantry',
  ChannelType.decisions: 'Decisions',
  ChannelType.unknown: 'unknown',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
