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
      startsAt: DateTime.parse(json['startsAt'] as String),
      endsAt: json['endsAt'] == null
          ? null
          : DateTime.parse(json['endsAt'] as String),
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
      'startsAt': instance.startsAt.toIso8601String(),
      'endsAt': instance.endsAt?.toIso8601String(),
      'location': instance.location,
      'voiceChannelId': instance.voiceChannelId,
      'status': _$EventStatusEnumMap[instance.status]!,
      'interestedCount': instance.interestedCount,
      'isInterested': instance.isInterested,
    };

const _$EventStatusEnumMap = {
  EventStatus.scheduled: 'Scheduled',
  EventStatus.active: 'Active',
  EventStatus.completed: 'Completed',
  EventStatus.cancelled: 'Cancelled',
};
