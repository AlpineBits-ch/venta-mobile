// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guild_emoji_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GuildEmojiDto _$GuildEmojiDtoFromJson(Map<String, dynamic> json) =>
    _GuildEmojiDto(
      id: json['id'] as String,
      guildId: json['guildId'] as String,
      name: json['name'] as String,
      animated: json['animated'] as bool? ?? false,
      createdByUserId: json['createdByUserId'] as String,
      createdAt: _$JsonConverterFromJson<String, DateTime>(
        json['createdAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      imageUrl: json['imageUrl'] as String,
    );

Map<String, dynamic> _$GuildEmojiDtoToJson(_GuildEmojiDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'guildId': instance.guildId,
      'name': instance.name,
      'animated': instance.animated,
      'createdByUserId': instance.createdByUserId,
      'createdAt': _$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const ApiDateTimeConverter().toJson,
      ),
      'imageUrl': instance.imageUrl,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
