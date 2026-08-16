// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bot_modal_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BotComponentDto _$BotComponentDtoFromJson(Map<String, dynamic> json) =>
    _BotComponentDto(
      type: (readBotPayloadKey(json, 'type') as num?)?.toInt() ?? 0,
      components:
          (readBotPayloadKey(json, 'components') as List<dynamic>?)
              ?.map((e) => BotComponentDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <BotComponentDto>[],
      customId: readBotPayloadKey(json, 'custom_id') as String?,
      label: readBotPayloadKey(json, 'label') as String?,
      style: (readBotPayloadKey(json, 'style') as num?)?.toInt(),
      placeholder: readBotPayloadKey(json, 'placeholder') as String?,
      value: readBotPayloadKey(json, 'value') as String?,
      isRequired: readBotPayloadKey(json, 'required') as bool? ?? false,
      minLength: (readBotPayloadKey(json, 'min_length') as num?)?.toInt(),
      maxLength: (readBotPayloadKey(json, 'max_length') as num?)?.toInt(),
    );

Map<String, dynamic> _$BotComponentDtoToJson(_BotComponentDto instance) =>
    <String, dynamic>{
      'type': instance.type,
      'components': instance.components,
      'custom_id': instance.customId,
      'label': instance.label,
      'style': instance.style,
      'placeholder': instance.placeholder,
      'value': instance.value,
      'required': instance.isRequired,
      'min_length': instance.minLength,
      'max_length': instance.maxLength,
    };

_BotModalOpenDto _$BotModalOpenDtoFromJson(Map<String, dynamic> json) =>
    _BotModalOpenDto(
      guildId: readBotPayloadKey(json, 'guildId') as String?,
      channelId: readBotPayloadKey(json, 'channelId') as String? ?? '',
      botUserId: readBotPayloadKey(json, 'botUserId') as String? ?? '',
      customId: readBotPayloadKey(json, 'customId') as String?,
      title: readBotPayloadKey(json, 'title') as String?,
      components:
          (readBotPayloadKey(json, 'components') as List<dynamic>?)
              ?.map((e) => BotComponentDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <BotComponentDto>[],
    );

Map<String, dynamic> _$BotModalOpenDtoToJson(_BotModalOpenDto instance) =>
    <String, dynamic>{
      'guildId': instance.guildId,
      'channelId': instance.channelId,
      'botUserId': instance.botUserId,
      'customId': instance.customId,
      'title': instance.title,
      'components': instance.components,
    };
