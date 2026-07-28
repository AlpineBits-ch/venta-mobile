// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bot_command_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BotCommandOptionDto _$BotCommandOptionDtoFromJson(Map<String, dynamic> json) =>
    _BotCommandOptionDto(
      name: json['name'] as String,
      description: json['description'] as String?,
      type:
          $enumDecodeNullable(_$BotCommandOptionTypeEnumMap, json['type']) ??
          BotCommandOptionType.string,
      required: json['required'] as bool? ?? false,
    );

Map<String, dynamic> _$BotCommandOptionDtoToJson(
  _BotCommandOptionDto instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'type': _$BotCommandOptionTypeEnumMap[instance.type]!,
  'required': instance.required,
};

const _$BotCommandOptionTypeEnumMap = {
  BotCommandOptionType.string: 3,
  BotCommandOptionType.integer: 4,
  BotCommandOptionType.boolean: 5,
  BotCommandOptionType.user: 6,
  BotCommandOptionType.channel: 7,
  BotCommandOptionType.role: 8,
  BotCommandOptionType.mentionable: 9,
  BotCommandOptionType.number: 10,
};

_BotCommandDto _$BotCommandDtoFromJson(Map<String, dynamic> json) =>
    _BotCommandDto(
      botUserId: json['botUserId'] as String,
      botName: json['botName'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      options:
          (json['options'] as List<dynamic>?)
              ?.map(
                (e) => BotCommandOptionDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <BotCommandOptionDto>[],
      scope: json['scope'] as String?,
    );

Map<String, dynamic> _$BotCommandDtoToJson(_BotCommandDto instance) =>
    <String, dynamic>{
      'botUserId': instance.botUserId,
      'botName': instance.botName,
      'name': instance.name,
      'description': instance.description,
      'options': instance.options,
      'scope': instance.scope,
    };
