// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_breadcrumb_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InboxBreadcrumbDto _$InboxBreadcrumbDtoFromJson(Map<String, dynamic> json) =>
    _InboxBreadcrumbDto(
      guildId: json['guildId'] as String? ?? '',
      guildName: json['guildName'] as String? ?? '',
      guildIconUrl: json['guildIconUrl'] as String?,
      guildIconThumbnailUrl: json['guildIconThumbnailUrl'] as String?,
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      channelId: json['channelId'] as String? ?? '',
      channelName: json['channelName'] as String? ?? '',
      channelType: (json['channelType'] as num?)?.toInt() ?? 0,
      parentChannelId: json['parentChannelId'] as String?,
      parentChannelName: json['parentChannelName'] as String?,
    );

Map<String, dynamic> _$InboxBreadcrumbDtoToJson(_InboxBreadcrumbDto instance) =>
    <String, dynamic>{
      'guildId': instance.guildId,
      'guildName': instance.guildName,
      'guildIconUrl': instance.guildIconUrl,
      'guildIconThumbnailUrl': instance.guildIconThumbnailUrl,
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'channelId': instance.channelId,
      'channelName': instance.channelName,
      'channelType': instance.channelType,
      'parentChannelId': instance.parentChannelId,
      'parentChannelName': instance.parentChannelName,
    };
