// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_mod_config_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AutoModConfigDto _$AutoModConfigDtoFromJson(Map<String, dynamic> json) =>
    _AutoModConfigDto(
      enabled: json['enabled'] as bool? ?? false,
      blockedWords:
          (json['blockedWords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      maxMessagesPerInterval: (json['maxMessagesPerInterval'] as num?)?.toInt(),
      intervalSeconds: (json['intervalSeconds'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AutoModConfigDtoToJson(_AutoModConfigDto instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'blockedWords': instance.blockedWords,
      'maxMessagesPerInterval': instance.maxMessagesPerInterval,
      'intervalSeconds': instance.intervalSeconds,
    };
