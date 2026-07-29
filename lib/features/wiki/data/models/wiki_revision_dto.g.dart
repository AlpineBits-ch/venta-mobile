// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wiki_revision_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WikiRevisionDto _$WikiRevisionDtoFromJson(Map<String, dynamic> json) =>
    _WikiRevisionDto(
      id: json['id'] as String,
      pageId: json['pageId'] as String,
      content: json['content'] as String,
      editorId: json['editorId'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      revisionNumber: (json['revisionNumber'] as num?)?.toInt() ?? 0,
      summary: json['summary'] as String?,
    );

Map<String, dynamic> _$WikiRevisionDtoToJson(_WikiRevisionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pageId': instance.pageId,
      'content': instance.content,
      'editorId': instance.editorId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'revisionNumber': instance.revisionNumber,
      'summary': instance.summary,
    };
