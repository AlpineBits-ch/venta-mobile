// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forum_tag_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ForumTagDto _$ForumTagDtoFromJson(Map<String, dynamic> json) => _ForumTagDto(
  id: json['id'] as String,
  channelId: json['channelId'] as String,
  guildId: json['guildId'] as String,
  name: json['name'] as String,
  emojiId: json['emojiId'] as String?,
  emojiName: json['emojiName'] as String?,
  color: json['color'] as String? ?? '#000000',
  position: (json['position'] as num?)?.toInt() ?? 0,
  moderated: json['moderated'] as bool? ?? false,
  postCount: (json['postCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ForumTagDtoToJson(_ForumTagDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'channelId': instance.channelId,
      'guildId': instance.guildId,
      'name': instance.name,
      'emojiId': instance.emojiId,
      'emojiName': instance.emojiName,
      'color': instance.color,
      'position': instance.position,
      'moderated': instance.moderated,
      'postCount': instance.postCount,
    };
