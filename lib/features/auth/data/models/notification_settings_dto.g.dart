// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationSettingsDto _$NotificationSettingsDtoFromJson(
  Map<String, dynamic> json,
) => _NotificationSettingsDto(
  enabled: json['enabled'] as bool? ?? true,
  dm: json['dm'] as bool? ?? true,
  mentions: json['mentions'] as bool? ?? true,
  sounds: json['sounds'] as bool? ?? true,
  cooldownEnabled: json['cooldownEnabled'] as bool? ?? true,
  cooldownSeconds: (json['cooldownSeconds'] as num?)?.toInt() ?? 10,
);

Map<String, dynamic> _$NotificationSettingsDtoToJson(
  _NotificationSettingsDto instance,
) => <String, dynamic>{
  'enabled': instance.enabled,
  'dm': instance.dm,
  'mentions': instance.mentions,
  'sounds': instance.sounds,
  'cooldownEnabled': instance.cooldownEnabled,
  'cooldownSeconds': instance.cooldownSeconds,
};
