// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CallParticipantDto _$CallParticipantDtoFromJson(Map<String, dynamic> json) =>
    _CallParticipantDto(
      userId: json['userId'] as String,
      cfSessionId: json['cfSessionId'] as String?,
      audioTrackName: json['audioTrackName'] as String?,
    );

Map<String, dynamic> _$CallParticipantDtoToJson(_CallParticipantDto instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'cfSessionId': instance.cfSessionId,
      'audioTrackName': instance.audioTrackName,
    };

_CallTrackDto _$CallTrackDtoFromJson(Map<String, dynamic> json) =>
    _CallTrackDto(
      trackId: json['trackId'] as String,
      userId: json['userId'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$CallTrackDtoToJson(_CallTrackDto instance) =>
    <String, dynamic>{
      'trackId': instance.trackId,
      'userId': instance.userId,
      'status': instance.status,
    };

_CallDto _$CallDtoFromJson(Map<String, dynamic> json) => _CallDto(
  id: json['id'] as String,
  conversationId: json['conversationId'] as String,
  creatorId: json['creatorId'] as String?,
  status: json['status'] as String?,
  createdAt: _$JsonConverterFromJson<String, DateTime>(
    json['createdAt'],
    const ApiDateTimeConverter().fromJson,
  ),
  updatedAt: _$JsonConverterFromJson<String, DateTime>(
    json['updatedAt'],
    const ApiDateTimeConverter().fromJson,
  ),
  tracks:
      (json['tracks'] as List<dynamic>?)
          ?.map((e) => CallTrackDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CallTrackDto>[],
  participants:
      (json['participants'] as List<dynamic>?)
          ?.map((e) => CallParticipantDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CallParticipantDto>[],
);

Map<String, dynamic> _$CallDtoToJson(_CallDto instance) => <String, dynamic>{
  'id': instance.id,
  'conversationId': instance.conversationId,
  'creatorId': instance.creatorId,
  'status': instance.status,
  'createdAt': _$JsonConverterToJson<String, DateTime>(
    instance.createdAt,
    const ApiDateTimeConverter().toJson,
  ),
  'updatedAt': _$JsonConverterToJson<String, DateTime>(
    instance.updatedAt,
    const ApiDateTimeConverter().toJson,
  ),
  'tracks': instance.tracks,
  'participants': instance.participants,
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
