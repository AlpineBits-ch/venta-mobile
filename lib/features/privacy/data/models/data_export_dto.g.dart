// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_export_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DataExportDto _$DataExportDtoFromJson(Map<String, dynamic> json) =>
    _DataExportDto(
      exportId: json['exportId'] as String,
      status: $enumDecode(
        _$DataExportStatusEnumMap,
        json['status'],
        unknownValue: DataExportStatus.pending,
      ),
      requestedAt: _$JsonConverterFromJson<String, DateTime>(
        json['requestedAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      completedAt: _$JsonConverterFromJson<String, DateTime>(
        json['completedAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      expiresAt: _$JsonConverterFromJson<String, DateTime>(
        json['expiresAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      failureReason: json['failureReason'] as String?,
      missingServices:
          (json['missingServices'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$DataExportDtoToJson(_DataExportDto instance) =>
    <String, dynamic>{
      'exportId': instance.exportId,
      'status': _$DataExportStatusEnumMap[instance.status]!,
      'requestedAt': _$JsonConverterToJson<String, DateTime>(
        instance.requestedAt,
        const ApiDateTimeConverter().toJson,
      ),
      'completedAt': _$JsonConverterToJson<String, DateTime>(
        instance.completedAt,
        const ApiDateTimeConverter().toJson,
      ),
      'expiresAt': _$JsonConverterToJson<String, DateTime>(
        instance.expiresAt,
        const ApiDateTimeConverter().toJson,
      ),
      'failureReason': instance.failureReason,
      'missingServices': instance.missingServices,
    };

const _$DataExportStatusEnumMap = {
  DataExportStatus.pending: 'Pending',
  DataExportStatus.running: 'Running',
  DataExportStatus.ready: 'Ready',
  DataExportStatus.partial: 'Partial',
  DataExportStatus.failed: 'Failed',
  DataExportStatus.expired: 'Expired',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
