// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forum_post_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ForumPostDto _$ForumPostDtoFromJson(Map<String, dynamic> json) =>
    _ForumPostDto(
      id: json['id'] as String,
      guildId: json['guildId'] as String,
      parentChannelId: json['parentChannelId'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      createdByUserId: json['createdByUserId'] as String?,
      tagIds:
          (json['tagIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      isPinned: json['isPinned'] as bool? ?? false,
      isLocked: json['isLocked'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
      autoArchiveAt: json['autoArchiveAt'] == null
          ? null
          : DateTime.parse(json['autoArchiveAt'] as String),
      autoArchiveMinutes: (json['autoArchiveMinutes'] as num?)?.toInt(),
      lastActivityAt: json['lastActivityAt'] == null
          ? null
          : DateTime.parse(json['lastActivityAt'] as String),
      messageCount: (json['messageCount'] as num?)?.toInt() ?? 0,
      isAgeRestricted: json['isAgeRestricted'] as bool? ?? false,
      isPrivate: json['isPrivate'] as bool? ?? false,
      slowModeSeconds: (json['slowModeSeconds'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ForumPostDtoToJson(_ForumPostDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'guildId': instance.guildId,
      'parentChannelId': instance.parentChannelId,
      'name': instance.name,
      'description': instance.description,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'createdByUserId': instance.createdByUserId,
      'tagIds': instance.tagIds,
      'isPinned': instance.isPinned,
      'isLocked': instance.isLocked,
      'isArchived': instance.isArchived,
      'autoArchiveAt': instance.autoArchiveAt?.toIso8601String(),
      'autoArchiveMinutes': instance.autoArchiveMinutes,
      'lastActivityAt': instance.lastActivityAt?.toIso8601String(),
      'messageCount': instance.messageCount,
      'isAgeRestricted': instance.isAgeRestricted,
      'isPrivate': instance.isPrivate,
      'slowModeSeconds': instance.slowModeSeconds,
    };

_ForumPostPageDto _$ForumPostPageDtoFromJson(Map<String, dynamic> json) =>
    _ForumPostPageDto(
      posts:
          (json['posts'] as List<dynamic>?)
              ?.map((e) => ForumPostDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ForumPostDto>[],
      nextCursor: json['nextCursor'] as String?,
    );

Map<String, dynamic> _$ForumPostPageDtoToJson(_ForumPostPageDto instance) =>
    <String, dynamic>{
      'posts': instance.posts,
      'nextCursor': instance.nextCursor,
    };
