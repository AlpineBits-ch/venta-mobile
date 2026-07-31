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
      createdAt: _$JsonConverterFromJson<String, DateTime>(
        json['createdAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      revisionNumber: (json['revisionNumber'] as num?)?.toInt() ?? 0,
      summary: json['summary'] as String?,
    );

Map<String, dynamic> _$WikiRevisionDtoToJson(_WikiRevisionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pageId': instance.pageId,
      'content': instance.content,
      'editorId': instance.editorId,
      'createdAt': _$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const ApiDateTimeConverter().toJson,
      ),
      'revisionNumber': instance.revisionNumber,
      'summary': instance.summary,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
