// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_session_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LoginSessionDto _$LoginSessionDtoFromJson(Map<String, dynamic> json) =>
    _LoginSessionDto(
      id: json['id'] as String,
      deviceName: json['deviceName'] as String?,
      deviceType: json['deviceType'] as String?,
      ipAddress: json['ipAddress'] as String?,
      createdAt: _$JsonConverterFromJson<String, DateTime>(
        json['createdAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      lastUsedAt: _$JsonConverterFromJson<String, DateTime>(
        json['lastUsedAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      clientDeviceId: json['clientDeviceId'] as String?,
      isCurrent: json['isCurrent'] as bool? ?? false,
    );

Map<String, dynamic> _$LoginSessionDtoToJson(_LoginSessionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deviceName': instance.deviceName,
      'deviceType': instance.deviceType,
      'ipAddress': instance.ipAddress,
      'createdAt': _$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const ApiDateTimeConverter().toJson,
      ),
      'lastUsedAt': _$JsonConverterToJson<String, DateTime>(
        instance.lastUsedAt,
        const ApiDateTimeConverter().toJson,
      ),
      'clientDeviceId': instance.clientDeviceId,
      'isCurrent': instance.isCurrent,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
