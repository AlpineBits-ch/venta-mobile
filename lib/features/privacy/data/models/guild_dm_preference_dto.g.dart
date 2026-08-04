// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guild_dm_preference_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GuildDmPreferenceDto _$GuildDmPreferenceDtoFromJson(
  Map<String, dynamic> json,
) => _GuildDmPreferenceDto(
  guildId: json['guildId'] as String,
  allowDirectMessages: json['allowDirectMessages'] as bool,
  isOverride: json['isOverride'] as bool? ?? true,
  updatedAt: _$JsonConverterFromJson<String, DateTime>(
    json['updatedAt'],
    const ApiDateTimeConverter().fromJson,
  ),
);

Map<String, dynamic> _$GuildDmPreferenceDtoToJson(
  _GuildDmPreferenceDto instance,
) => <String, dynamic>{
  'guildId': instance.guildId,
  'allowDirectMessages': instance.allowDirectMessages,
  'isOverride': instance.isOverride,
  'updatedAt': _$JsonConverterToJson<String, DateTime>(
    instance.updatedAt,
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
