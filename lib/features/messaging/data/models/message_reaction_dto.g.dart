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
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
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
      'createdAt': instance.createdAt?.toIso8601String(),
      'conversationId': instance.conversationId,
      'channelId': instance.channelId,
    };
