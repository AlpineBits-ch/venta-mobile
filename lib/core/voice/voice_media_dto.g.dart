// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_media_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VoiceConnectionDto _$VoiceConnectionDtoFromJson(Map<String, dynamic> json) =>
    _VoiceConnectionDto(
      backend: json['backend'] as String? ?? '',
      url: json['url'] as String,
      token: json['token'] as String,
      room: json['room'] as String? ?? '',
      identity: json['identity'] as String,
      mediaSessionId: json['mediaSessionId'] as String?,
      expiresAt: _$JsonConverterFromJson<String, DateTime>(
        json['expiresAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      canPublishAudio: json['canPublishAudio'] as bool? ?? true,
      canPublishVideo: json['canPublishVideo'] as bool? ?? true,
    );

Map<String, dynamic> _$VoiceConnectionDtoToJson(_VoiceConnectionDto instance) =>
    <String, dynamic>{
      'backend': instance.backend,
      'url': instance.url,
      'token': instance.token,
      'room': instance.room,
      'identity': instance.identity,
      'mediaSessionId': instance.mediaSessionId,
      'expiresAt': _$JsonConverterToJson<String, DateTime>(
        instance.expiresAt,
        const ApiDateTimeConverter().toJson,
      ),
      'canPublishAudio': instance.canPublishAudio,
      'canPublishVideo': instance.canPublishVideo,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_VoicePublishResultDto _$VoicePublishResultDtoFromJson(
  Map<String, dynamic> json,
) => _VoicePublishResultDto(
  identity: json['identity'] as String? ?? '',
  rung: json['rung'] as String?,
  height: (json['height'] as num?)?.toInt(),
  framerate: (json['framerate'] as num?)?.toInt(),
  maxLayer: json['maxLayer'] as String?,
  degradations:
      (json['degradations'] as List<dynamic>?)
          ?.map(
            (e) =>
                EntitlementDegradationDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <EntitlementDegradationDto>[],
);

Map<String, dynamic> _$VoicePublishResultDtoToJson(
  _VoicePublishResultDto instance,
) => <String, dynamic>{
  'identity': instance.identity,
  'rung': instance.rung,
  'height': instance.height,
  'framerate': instance.framerate,
  'maxLayer': instance.maxLayer,
  'degradations': instance.degradations,
};
