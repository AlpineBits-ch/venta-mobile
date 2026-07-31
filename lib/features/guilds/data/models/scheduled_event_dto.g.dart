// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scheduled_event_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ScheduledEventDto _$ScheduledEventDtoFromJson(Map<String, dynamic> json) =>
    _ScheduledEventDto(
      id: json['id'] as String,
      guildId: json['guildId'] as String,
      creatorUserId: json['creatorUserId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      startsAt: const ApiDateTimeConverter().fromJson(
        json['startsAt'] as String,
      ),
      endsAt: _$JsonConverterFromJson<String, DateTime>(
        json['endsAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      location: json['location'] as String?,
      voiceChannelId: json['voiceChannelId'] as String?,
      status:
          $enumDecodeNullable(_$EventStatusEnumMap, json['status']) ??
          EventStatus.scheduled,
      interestedCount: (json['interestedCount'] as num?)?.toInt() ?? 0,
      isInterested: json['isInterested'] as bool? ?? false,
    );

Map<String, dynamic> _$ScheduledEventDtoToJson(_ScheduledEventDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'guildId': instance.guildId,
      'creatorUserId': instance.creatorUserId,
      'title': instance.title,
      'description': instance.description,
      'startsAt': const ApiDateTimeConverter().toJson(instance.startsAt),
      'endsAt': _$JsonConverterToJson<String, DateTime>(
        instance.endsAt,
        const ApiDateTimeConverter().toJson,
      ),
      'location': instance.location,
      'voiceChannelId': instance.voiceChannelId,
      'status': _$EventStatusEnumMap[instance.status]!,
      'interestedCount': instance.interestedCount,
      'isInterested': instance.isInterested,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

const _$EventStatusEnumMap = {
  EventStatus.scheduled: 'Scheduled',
  EventStatus.active: 'Active',
  EventStatus.completed: 'Completed',
  EventStatus.cancelled: 'Cancelled',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
