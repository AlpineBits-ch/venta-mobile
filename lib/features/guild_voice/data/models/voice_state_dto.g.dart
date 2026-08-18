// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_state_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VoiceStateDto _$VoiceStateDtoFromJson(Map<String, dynamic> json) =>
    _VoiceStateDto(
      guildId: json['guildId'] as String,
      channelId: json['channelId'] as String,
      channelName: json['channelName'] as String?,
      deviceId: json['deviceId'] as String?,
      joinedAt: _$JsonConverterFromJson<String, DateTime>(
        json['joinedAt'],
        const ApiDateTimeConverter().fromJson,
      ),
    );

Map<String, dynamic> _$VoiceStateDtoToJson(_VoiceStateDto instance) =>
    <String, dynamic>{
      'guildId': instance.guildId,
      'channelId': instance.channelId,
      'channelName': instance.channelName,
      'deviceId': instance.deviceId,
      'joinedAt': _$JsonConverterToJson<String, DateTime>(
        instance.joinedAt,
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
