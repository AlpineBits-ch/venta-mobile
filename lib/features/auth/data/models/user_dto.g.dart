// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserDto _$UserDtoFromJson(Map<String, dynamic> json) => _UserDto(
  id: json['id'] as String,
  status: $enumDecode(_$UserStatusEnumMap, json['status']),
  deletionRequestedAt: _$JsonConverterFromJson<String, DateTime>(
    json['deletionRequestedAt'],
    const ApiDateTimeConverter().fromJson,
  ),
  purgeScheduledAt: _$JsonConverterFromJson<String, DateTime>(
    json['purgeScheduledAt'],
    const ApiDateTimeConverter().fromJson,
  ),
  mfaEnabled: json['mfaEnabled'] as bool? ?? false,
);

Map<String, dynamic> _$UserDtoToJson(_UserDto instance) => <String, dynamic>{
  'id': instance.id,
  'status': _$UserStatusEnumMap[instance.status]!,
  'deletionRequestedAt': _$JsonConverterToJson<String, DateTime>(
    instance.deletionRequestedAt,
    const ApiDateTimeConverter().toJson,
  ),
  'purgeScheduledAt': _$JsonConverterToJson<String, DateTime>(
    instance.purgeScheduledAt,
    const ApiDateTimeConverter().toJson,
  ),
  'mfaEnabled': instance.mfaEnabled,
};

const _$UserStatusEnumMap = {
  UserStatus.active: 'Active',
  UserStatus.pendingDeletion: 'PendingDeletion',
  UserStatus.purgeInProgress: 'PurgeInProgress',
  UserStatus.deleted: 'Deleted',
  UserStatus.inactive: 'Inactive',
  UserStatus.banned: 'Banned',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
