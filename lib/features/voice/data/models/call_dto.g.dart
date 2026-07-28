// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CallParticipantDto _$CallParticipantDtoFromJson(Map<String, dynamic> json) =>
    _CallParticipantDto(userId: json['userId'] as String);

Map<String, dynamic> _$CallParticipantDtoToJson(_CallParticipantDto instance) =>
    <String, dynamic>{'userId': instance.userId};

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
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
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
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'tracks': instance.tracks,
  'participants': instance.participants,
};
