// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'absence_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AbsenceDto _$AbsenceDtoFromJson(Map<String, dynamic> json) => _AbsenceDto(
  id: json['id'] as String,
  guildId: json['guildId'] as String? ?? '',
  userId: json['userId'] as String? ?? '',
  startAt: const ApiDateTimeConverter().fromJson(json['startAt'] as String),
  endAt: const ApiDateTimeConverter().fromJson(json['endAt'] as String),
  note: json['note'] as String?,
  createdByUserId: json['createdByUserId'] as String? ?? '',
  createdAt: _$JsonConverterFromJson<String, DateTime>(
    json['createdAt'],
    const ApiDateTimeConverter().fromJson,
  ),
);

Map<String, dynamic> _$AbsenceDtoToJson(_AbsenceDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'guildId': instance.guildId,
      'userId': instance.userId,
      'startAt': const ApiDateTimeConverter().toJson(instance.startAt),
      'endAt': const ApiDateTimeConverter().toJson(instance.endAt),
      'note': instance.note,
      'createdByUserId': instance.createdByUserId,
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

_AbsenceSavedDto _$AbsenceSavedDtoFromJson(Map<String, dynamic> json) =>
    _AbsenceSavedDto(
      absence: AbsenceDto.fromJson(json['absence'] as Map<String, dynamic>),
      choresReassigned: (json['choresReassigned'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$AbsenceSavedDtoToJson(_AbsenceSavedDto instance) =>
    <String, dynamic>{
      'absence': instance.absence,
      'choresReassigned': instance.choresReassigned,
    };
