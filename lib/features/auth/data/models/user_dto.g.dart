// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserDto _$UserDtoFromJson(Map<String, dynamic> json) => _UserDto(
  id: json['id'] as String,
  status: $enumDecode(_$UserStatusEnumMap, json['status']),
  deletionRequestedAt: json['deletionRequestedAt'] == null
      ? null
      : DateTime.parse(json['deletionRequestedAt'] as String),
  purgeScheduledAt: json['purgeScheduledAt'] == null
      ? null
      : DateTime.parse(json['purgeScheduledAt'] as String),
  mfaEnabled: json['mfaEnabled'] as bool? ?? false,
);

Map<String, dynamic> _$UserDtoToJson(_UserDto instance) => <String, dynamic>{
  'id': instance.id,
  'status': _$UserStatusEnumMap[instance.status]!,
  'deletionRequestedAt': instance.deletionRequestedAt?.toIso8601String(),
  'purgeScheduledAt': instance.purgeScheduledAt?.toIso8601String(),
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
