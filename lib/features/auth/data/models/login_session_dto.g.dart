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
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      lastUsedAt: json['lastUsedAt'] == null
          ? null
          : DateTime.parse(json['lastUsedAt'] as String),
      isCurrent: json['isCurrent'] as bool? ?? false,
    );

Map<String, dynamic> _$LoginSessionDtoToJson(_LoginSessionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deviceName': instance.deviceName,
      'deviceType': instance.deviceType,
      'ipAddress': instance.ipAddress,
      'createdAt': instance.createdAt?.toIso8601String(),
      'lastUsedAt': instance.lastUsedAt?.toIso8601String(),
      'isCurrent': instance.isCurrent,
    };
