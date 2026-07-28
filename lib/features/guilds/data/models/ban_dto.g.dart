// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ban_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BanDto _$BanDtoFromJson(Map<String, dynamic> json) => _BanDto(
  id: json['id'] as String,
  guildId: json['guildId'] as String,
  bannedUserId: json['bannedUserId'] as String,
  bannedByUserId: json['bannedByUserId'] as String?,
  reason: json['reason'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$BanDtoToJson(_BanDto instance) => <String, dynamic>{
  'id': instance.id,
  'guildId': instance.guildId,
  'bannedUserId': instance.bannedUserId,
  'bannedByUserId': instance.bannedByUserId,
  'reason': instance.reason,
  'createdAt': instance.createdAt?.toIso8601String(),
};
