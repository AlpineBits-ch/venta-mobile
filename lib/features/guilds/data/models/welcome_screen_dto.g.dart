// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'welcome_screen_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WelcomeChannelDto _$WelcomeChannelDtoFromJson(Map<String, dynamic> json) =>
    _WelcomeChannelDto(
      channelId: json['channelId'] as String,
      description: json['description'] as String? ?? '',
      emoji: json['emoji'] as String?,
      position: (json['position'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$WelcomeChannelDtoToJson(_WelcomeChannelDto instance) =>
    <String, dynamic>{
      'channelId': instance.channelId,
      'description': instance.description,
      'emoji': instance.emoji,
      'position': instance.position,
    };

_WelcomeScreenDto _$WelcomeScreenDtoFromJson(Map<String, dynamic> json) =>
    _WelcomeScreenDto(
      enabled: json['enabled'] as bool? ?? false,
      description: json['description'] as String?,
      channels:
          (json['channels'] as List<dynamic>?)
              ?.map(
                (e) => WelcomeChannelDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <WelcomeChannelDto>[],
    );

Map<String, dynamic> _$WelcomeScreenDtoToJson(_WelcomeScreenDto instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'description': instance.description,
      'channels': instance.channels,
    };
