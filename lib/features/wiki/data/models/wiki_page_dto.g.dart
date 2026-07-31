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
  createdAt: _$JsonConverterFromJson<String, DateTime>(
    json['createdAt'],
    const ApiDateTimeConverter().fromJson,
  ),
  updatedAt: _$JsonConverterFromJson<String, DateTime>(
    json['updatedAt'],
    const ApiDateTimeConverter().fromJson,
  ),
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
      'createdAt': _$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const ApiDateTimeConverter().toJson,
      ),
      'updatedAt': _$JsonConverterToJson<String, DateTime>(
        instance.updatedAt,
        const ApiDateTimeConverter().toJson,
      ),
      'parentPageId': instance.parentPageId,
      'categoryId': instance.categoryId,
      'visibility': _$WikiVisibilityEnumMap[instance.visibility]!,
      'tags': instance.tags,
      'isPinned': instance.isPinned,
      'revisionCount': instance.revisionCount,
      'content': instance.content,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

const _$WikiVisibilityEnumMap = {
  WikiVisibility.public: 'Public',
  WikiVisibility.private: 'Private',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
