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
  createdAt: _$JsonConverterFromJson<String, DateTime>(
    json['createdAt'],
    const ApiDateTimeConverter().fromJson,
  ),
);

Map<String, dynamic> _$BanDtoToJson(_BanDto instance) => <String, dynamic>{
  'id': instance.id,
  'guildId': instance.guildId,
  'bannedUserId': instance.bannedUserId,
  'bannedByUserId': instance.bannedByUserId,
  'reason': instance.reason,
  'createdAt': _$JsonConverterToJson<String, DateTime>(
    instance.createdAt,
    const ApiDateTimeConverter().toJson,
  ),
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
