// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InviteDto _$InviteDtoFromJson(Map<String, dynamic> json) => _InviteDto(
  id: json['id'] as String,
  type: $enumDecode(_$InviteTypeEnumMap, json['type']),
  state: $enumDecode(_$InviteStateEnumMap, json['state']),
  guildId: json['guildId'] as String,
  guild: json['guild'] == null
      ? null
      : GuildDto.fromJson(json['guild'] as Map<String, dynamic>),
  code: json['code'] as String,
  expiresAt: json['expiresAt'] as String?,
  maxUses: (json['maxUses'] as num?)?.toInt(),
  useCount: (json['useCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$InviteDtoToJson(_InviteDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$InviteTypeEnumMap[instance.type]!,
      'state': _$InviteStateEnumMap[instance.state]!,
      'guildId': instance.guildId,
      'guild': instance.guild,
      'code': instance.code,
      'expiresAt': instance.expiresAt,
      'maxUses': instance.maxUses,
      'useCount': instance.useCount,
    };

const _$InviteTypeEnumMap = {
  InviteType.oneTime: 'OneTime',
  InviteType.permanent: 'Permanent',
};

const _$InviteStateEnumMap = {
  InviteState.active: 'Active',
  InviteState.expired: 'Expired',
};
