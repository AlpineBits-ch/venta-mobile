// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forum_config_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ForumConfigDto _$ForumConfigDtoFromJson(Map<String, dynamic> json) =>
    _ForumConfigDto(
      channelId: json['channelId'] as String?,
      requireTag: json['requireTag'] as bool? ?? false,
      defaultSortOrder:
          $enumDecodeNullable(
            _$ForumSortOrderEnumMap,
            json['defaultSortOrder'],
          ) ??
          ForumSortOrder.latestActivity,
      defaultLayout:
          $enumDecodeNullable(_$ForumLayoutEnumMap, json['defaultLayout']) ??
          ForumLayout.list,
      defaultReactionEmojiId: json['defaultReactionEmojiId'] as String?,
      defaultReactionEmojiName: json['defaultReactionEmojiName'] as String?,
      defaultThreadSlowModeSeconds:
          (json['defaultThreadSlowModeSeconds'] as num?)?.toInt() ?? 0,
      defaultAutoArchiveMinutes:
          (json['defaultAutoArchiveMinutes'] as num?)?.toInt() ?? 4320,
    );

Map<String, dynamic> _$ForumConfigDtoToJson(_ForumConfigDto instance) =>
    <String, dynamic>{
      'channelId': instance.channelId,
      'requireTag': instance.requireTag,
      'defaultSortOrder': _$ForumSortOrderEnumMap[instance.defaultSortOrder]!,
      'defaultLayout': _$ForumLayoutEnumMap[instance.defaultLayout]!,
      'defaultReactionEmojiId': instance.defaultReactionEmojiId,
      'defaultReactionEmojiName': instance.defaultReactionEmojiName,
      'defaultThreadSlowModeSeconds': instance.defaultThreadSlowModeSeconds,
      'defaultAutoArchiveMinutes': instance.defaultAutoArchiveMinutes,
    };

const _$ForumSortOrderEnumMap = {
  ForumSortOrder.latestActivity: 'LatestActivity',
  ForumSortOrder.creationDate: 'CreationDate',
};

const _$ForumLayoutEnumMap = {
  ForumLayout.list: 'List',
  ForumLayout.gallery: 'Gallery',
};
