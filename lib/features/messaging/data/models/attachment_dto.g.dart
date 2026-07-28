// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AttachmentDto _$AttachmentDtoFromJson(Map<String, dynamic> json) =>
    _AttachmentDto(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      contentType: json['contentType'] as String,
      state:
          $enumDecodeNullable(_$AttachmentStateEnumMap, json['state']) ??
          AttachmentState.complete,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
      url: json['url'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );

Map<String, dynamic> _$AttachmentDtoToJson(_AttachmentDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fileName': instance.fileName,
      'contentType': instance.contentType,
      'state': _$AttachmentStateEnumMap[instance.state]!,
      'sizeBytes': instance.sizeBytes,
      'url': instance.url,
      'thumbnailUrl': instance.thumbnailUrl,
    };

const _$AttachmentStateEnumMap = {
  AttachmentState.pending: 'Pending',
  AttachmentState.complete: 'Complete',
};
