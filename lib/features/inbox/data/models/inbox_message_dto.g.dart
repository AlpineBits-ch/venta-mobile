// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_message_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InboxMessageDto _$InboxMessageDtoFromJson(Map<String, dynamic> json) =>
    _InboxMessageDto(
      id: json['id'] as String,
      createdAt: _$JsonConverterFromJson<String, DateTime>(
        json['createdAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      authorId: json['authorId'] as String? ?? '',
      authorDisplayName: json['authorDisplayName'] as String?,
      authorAvatarUrl: json['authorAvatarUrl'] as String?,
      content: json['content'] as String? ?? '',
      isEncrypted: json['isEncrypted'] as bool? ?? false,
      mlsGeneration: (json['mlsGeneration'] as num?)?.toInt(),
      type:
          $enumDecodeNullable(
            _$InboxMessageTypeEnumMap,
            json['type'],
            unknownValue: InboxMessageType.unknown,
          ) ??
          InboxMessageType.message,
      systemMessageVariant: (json['systemMessageVariant'] as num?)?.toInt(),
      embedsJson: json['embedsJson'] as String?,
    );

Map<String, dynamic> _$InboxMessageDtoToJson(_InboxMessageDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': _$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const ApiDateTimeConverter().toJson,
      ),
      'authorId': instance.authorId,
      'authorDisplayName': instance.authorDisplayName,
      'authorAvatarUrl': instance.authorAvatarUrl,
      'content': instance.content,
      'isEncrypted': instance.isEncrypted,
      'mlsGeneration': instance.mlsGeneration,
      'type': _$InboxMessageTypeEnumMap[instance.type]!,
      'systemMessageVariant': instance.systemMessageVariant,
      'embedsJson': instance.embedsJson,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

const _$InboxMessageTypeEnumMap = {
  InboxMessageType.message: 0,
  InboxMessageType.invite: 1,
  InboxMessageType.guildMemberJoin: 2,
  InboxMessageType.guildMemberLeave: 3,
  InboxMessageType.unknown: 'unknown',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
