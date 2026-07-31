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
      createdAt: _$JsonConverterFromJson<String, DateTime>(
        json['createdAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      updatedAt: _$JsonConverterFromJson<String, DateTime>(
        json['updatedAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      createdByUserId: json['createdByUserId'] as String?,
      tagIds:
          (json['tagIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      isPinned: json['isPinned'] as bool? ?? false,
      isLocked: json['isLocked'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
      autoArchiveAt: _$JsonConverterFromJson<String, DateTime>(
        json['autoArchiveAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      autoArchiveMinutes: (json['autoArchiveMinutes'] as num?)?.toInt(),
      lastActivityAt: _$JsonConverterFromJson<String, DateTime>(
        json['lastActivityAt'],
        const ApiDateTimeConverter().fromJson,
      ),
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
      'createdAt': _$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const ApiDateTimeConverter().toJson,
      ),
      'updatedAt': _$JsonConverterToJson<String, DateTime>(
        instance.updatedAt,
        const ApiDateTimeConverter().toJson,
      ),
      'createdByUserId': instance.createdByUserId,
      'tagIds': instance.tagIds,
      'isPinned': instance.isPinned,
      'isLocked': instance.isLocked,
      'isArchived': instance.isArchived,
      'autoArchiveAt': _$JsonConverterToJson<String, DateTime>(
        instance.autoArchiveAt,
        const ApiDateTimeConverter().toJson,
      ),
      'autoArchiveMinutes': instance.autoArchiveMinutes,
      'lastActivityAt': _$JsonConverterToJson<String, DateTime>(
        instance.lastActivityAt,
        const ApiDateTimeConverter().toJson,
      ),
      'messageCount': instance.messageCount,
      'isAgeRestricted': instance.isAgeRestricted,
      'isPrivate': instance.isPrivate,
      'slowModeSeconds': instance.slowModeSeconds,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

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
