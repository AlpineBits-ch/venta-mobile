// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'house_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HomeStatusDto _$HomeStatusDtoFromJson(Map<String, dynamic> json) =>
    _HomeStatusDto(
      userId: json['userId'] as String? ?? '',
      kind:
          $enumDecodeNullable(
            _$HomeStatusKindEnumMap,
            json['kind'],
            unknownValue: HomeStatusKind.home,
          ) ??
          HomeStatusKind.home,
      note: json['note'] as String?,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$HomeStatusDtoToJson(_HomeStatusDto instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'kind': _$HomeStatusKindEnumMap[instance.kind]!,
      'note': instance.note,
      'expiresAt': instance.expiresAt?.toIso8601String(),
    };

const _$HomeStatusKindEnumMap = {
  HomeStatusKind.home: 'Home',
  HomeStatusKind.out: 'Out',
  HomeStatusKind.asleep: 'Asleep',
  HomeStatusKind.doNotDisturb: 'DoNotDisturb',
  HomeStatusKind.onMyWay: 'OnMyWay',
};

_QuietHoursDto _$QuietHoursDtoFromJson(Map<String, dynamic> json) =>
    _QuietHoursDto(
      enabled: json['enabled'] as bool? ?? false,
      startMinuteLocal: (json['startMinuteLocal'] as num?)?.toInt() ?? 1320,
      endMinuteLocal: (json['endMinuteLocal'] as num?)?.toInt() ?? 420,
      timeZoneId: json['timeZoneId'] as String? ?? 'Europe/Zurich',
    );

Map<String, dynamic> _$QuietHoursDtoToJson(_QuietHoursDto instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'startMinuteLocal': instance.startMinuteLocal,
      'endMinuteLocal': instance.endMinuteLocal,
      'timeZoneId': instance.timeZoneId,
    };
