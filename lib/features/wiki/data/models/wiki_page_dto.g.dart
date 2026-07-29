// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wiki_page_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WikiPageDto _$WikiPageDtoFromJson(Map<String, dynamic> json) => _WikiPageDto(
  id: json['id'] as String,
  guildId: json['guildId'] as String,
  title: json['title'] as String,
  slug: json['slug'] as String,
  authorId: json['authorId'] as String,
  lastEditorId: json['lastEditorId'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  parentPageId: json['parentPageId'] as String?,
  categoryId: json['categoryId'] as String?,
  visibility:
      $enumDecodeNullable(_$WikiVisibilityEnumMap, json['visibility']) ??
      WikiVisibility.private,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  isPinned: json['isPinned'] as bool? ?? false,
  revisionCount: (json['revisionCount'] as num?)?.toInt() ?? 0,
  content: json['content'] as String? ?? '',
);

Map<String, dynamic> _$WikiPageDtoToJson(_WikiPageDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'guildId': instance.guildId,
      'title': instance.title,
      'slug': instance.slug,
      'authorId': instance.authorId,
      'lastEditorId': instance.lastEditorId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'parentPageId': instance.parentPageId,
      'categoryId': instance.categoryId,
      'visibility': _$WikiVisibilityEnumMap[instance.visibility]!,
      'tags': instance.tags,
      'isPinned': instance.isPinned,
      'revisionCount': instance.revisionCount,
      'content': instance.content,
    };

const _$WikiVisibilityEnumMap = {
  WikiVisibility.public: 'Public',
  WikiVisibility.private: 'Private',
};
