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
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      imageUrl: json['imageUrl'] as String,
    );

Map<String, dynamic> _$GuildEmojiDtoToJson(_GuildEmojiDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'guildId': instance.guildId,
      'name': instance.name,
      'animated': instance.animated,
      'createdByUserId': instance.createdByUserId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'imageUrl': instance.imageUrl,
    };
