// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ongoing_call_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OngoingCallDto _$OngoingCallDtoFromJson(Map<String, dynamic> json) =>
    _OngoingCallDto(
      callId: json['callId'] as String,
      conversationId: json['conversationId'] as String,
      status: json['status'] as String? ?? '',
      creatorId: json['creatorId'] as String?,
      startedAt: _$JsonConverterFromJson<String, DateTime>(
        json['startedAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      connectedUserIds:
          (json['connectedUserIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$OngoingCallDtoToJson(_OngoingCallDto instance) =>
    <String, dynamic>{
      'callId': instance.callId,
      'conversationId': instance.conversationId,
      'status': instance.status,
      'creatorId': instance.creatorId,
      'startedAt': _$JsonConverterToJson<String, DateTime>(
        instance.startedAt,
        const ApiDateTimeConverter().toJson,
      ),
      'connectedUserIds': instance.connectedUserIds,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
