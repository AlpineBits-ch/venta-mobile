// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MessageDto _$MessageDtoFromJson(Map<String, dynamic> json) => _MessageDto(
  id: json['id'] as String,
  content: json['content'] as String,
  conversationId: json['conversationId'] as String?,
  channelId: json['channelId'] as String?,
  authorId: json['authorId'] as String,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  isPending: json['isPending'] as bool? ?? false,
  isFailed: json['isFailed'] as bool? ?? false,
  inReplyTo: json['inReplyTo'] as String?,
  mentions:
      (json['mentions'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  encryptionState:
      $enumDecodeNullable(
        _$MessageEncryptionStateEnumMap,
        json['encryptionState'],
      ) ??
      MessageEncryptionState.plain,
  type:
      $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
      MessageType.message,
);

Map<String, dynamic> _$MessageDtoToJson(
  _MessageDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'content': instance.content,
  'conversationId': instance.conversationId,
  'channelId': instance.channelId,
  'authorId': instance.authorId,
  'createdAt': instance.createdAt?.toIso8601String(),
  'isPending': instance.isPending,
  'isFailed': instance.isFailed,
  'inReplyTo': instance.inReplyTo,
  'mentions': instance.mentions,
  'encryptionState': _$MessageEncryptionStateEnumMap[instance.encryptionState]!,
  'type': _$MessageTypeEnumMap[instance.type]!,
};

const _$MessageEncryptionStateEnumMap = {
  MessageEncryptionState.plain: 'Plain',
  MessageEncryptionState.encrypted: 'Encrypted',
};

const _$MessageTypeEnumMap = {
  MessageType.message: 'Message',
  MessageType.system: 'System',
  MessageType.invite: 'Invite',
  MessageType.guildMemberJoin: 'GuildMemberJoin',
  MessageType.guildMemberLeave: 'GuildMemberLeave',
};
