// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_reaction_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MessageReactionDto _$MessageReactionDtoFromJson(Map<String, dynamic> json) =>
    _MessageReactionDto(
      messageId: json['messageId'] as String,
      emoji: json['emoji'] as String,
      userId: json['userId'] as String,
      emojiId: json['emojiId'] as String?,
      contextId: json['contextId'] as String?,
      createdAt: _$JsonConverterFromJson<String, DateTime>(
        json['createdAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      conversationId: json['conversationId'] as String?,
      channelId: json['channelId'] as String?,
    );

Map<String, dynamic> _$MessageReactionDtoToJson(_MessageReactionDto instance) =>
    <String, dynamic>{
      'messageId': instance.messageId,
      'emoji': instance.emoji,
      'userId': instance.userId,
      'emojiId': instance.emojiId,
      'contextId': instance.contextId,
      'createdAt': _$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const ApiDateTimeConverter().toJson,
      ),
      'conversationId': instance.conversationId,
      'channelId': instance.channelId,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
