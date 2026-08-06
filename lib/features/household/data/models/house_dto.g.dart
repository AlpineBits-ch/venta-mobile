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
      expiresAt: _$JsonConverterFromJson<String, DateTime>(
        json['expiresAt'],
        const ApiDateTimeConverter().fromJson,
      ),
    );

Map<String, dynamic> _$HomeStatusDtoToJson(_HomeStatusDto instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'kind': _$HomeStatusKindEnumMap[instance.kind]!,
      'note': instance.note,
      'expiresAt': _$JsonConverterToJson<String, DateTime>(
        instance.expiresAt,
        const ApiDateTimeConverter().toJson,
      ),
    };

const _$HomeStatusKindEnumMap = {
  HomeStatusKind.home: 'Home',
  HomeStatusKind.out: 'Out',
  HomeStatusKind.asleep: 'Asleep',
  HomeStatusKind.doNotDisturb: 'DoNotDisturb',
  HomeStatusKind.onMyWay: 'OnMyWay',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

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

_OutstandingBalanceDto _$OutstandingBalanceDtoFromJson(
  Map<String, dynamic> json,
) => _OutstandingBalanceDto(
  channelId: json['channelId'] as String? ?? '',
  currency: json['currency'] as String? ?? 'CHF',
  netMinor: (json['netMinor'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$OutstandingBalanceDtoToJson(
  _OutstandingBalanceDto instance,
) => <String, dynamic>{
  'channelId': instance.channelId,
  'currency': instance.currency,
  'netMinor': instance.netMinor,
};

_MoveOutSummaryDto _$MoveOutSummaryDtoFromJson(Map<String, dynamic> json) =>
    _MoveOutSummaryDto(
      userId: json['userId'] as String? ?? '',
      choresReassigned: (json['choresReassigned'] as num?)?.toInt() ?? 0,
      choresDropped: (json['choresDropped'] as num?)?.toInt() ?? 0,
      choresPaused: (json['choresPaused'] as num?)?.toInt() ?? 0,
      listItemsUnassigned: (json['listItemsUnassigned'] as num?)?.toInt() ?? 0,
      balancesWrittenOff:
          (json['balancesWrittenOff'] as List<dynamic>?)
              ?.map(
                (e) =>
                    TransferSuggestionDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <TransferSuggestionDto>[],
    );

Map<String, dynamic> _$MoveOutSummaryDtoToJson(_MoveOutSummaryDto instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'choresReassigned': instance.choresReassigned,
      'choresDropped': instance.choresDropped,
      'choresPaused': instance.choresPaused,
      'listItemsUnassigned': instance.listItemsUnassigned,
      'balancesWrittenOff': instance.balancesWrittenOff,
    };
