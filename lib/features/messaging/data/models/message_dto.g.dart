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
  createdAt: _$JsonConverterFromJson<String, DateTime>(
    json['createdAt'],
    const ApiDateTimeConverter().fromJson,
  ),
  isPending: json['isPending'] as bool? ?? false,
  isFailed: json['isFailed'] as bool? ?? false,
  inReplyTo: json['inReplyTo'] as String?,
  mentions:
      (json['mentions'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  roleMentions:
      (json['roleMentions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  mentionsEveryone: json['mentionsEveryone'] as bool? ?? false,
  mentionsHere: json['mentionsHere'] as bool? ?? false,
  attachments:
      (json['attachments'] as List<dynamic>?)
          ?.map((e) => AttachmentDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <AttachmentDto>[],
  reactions:
      (json['reactions'] as List<dynamic>?)
          ?.map((e) => MessageReactionDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <MessageReactionDto>[],
  encryptionState:
      $enumDecodeNullable(
        _$MessageEncryptionStateEnumMap,
        json['encryptionState'],
      ) ??
      MessageEncryptionState.plain,
  type:
      $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
      MessageType.message,
  authorIdType:
      $enumDecodeNullable(
        _$MessageAuthorTypeEnumMap,
        json['authorIdType'],
        unknownValue: MessageAuthorType.standard,
      ) ??
      MessageAuthorType.standard,
  isPinned: json['isPinned'] as bool? ?? false,
  pinnedAt: _$JsonConverterFromJson<String, DateTime>(
    json['pinnedAt'],
    const ApiDateTimeConverter().fromJson,
  ),
  pinnedById: json['pinnedById'] as String?,
  embedsJson: json['embedsJson'] as String?,
  flags: (json['flags'] as num?)?.toInt() ?? 0,
  editedAt: _$JsonConverterFromJson<String, DateTime>(
    json['editedAt'],
    const ApiDateTimeConverter().fromJson,
  ),
  updatedAt: _$JsonConverterFromJson<String, DateTime>(
    json['updatedAt'],
    const ApiDateTimeConverter().fromJson,
  ),
  systemMessageVariant: (json['systemMessageVariant'] as num?)?.toInt(),
  mlsGeneration: (json['mlsGeneration'] as num?)?.toInt(),
  mlsEpoch: (json['mlsEpoch'] as num?)?.toInt(),
  senderDeviceId: json['senderDeviceId'] as String?,
);

Map<String, dynamic> _$MessageDtoToJson(
  _MessageDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'content': instance.content,
  'conversationId': instance.conversationId,
  'channelId': instance.channelId,
  'authorId': instance.authorId,
  'createdAt': _$JsonConverterToJson<String, DateTime>(
    instance.createdAt,
    const ApiDateTimeConverter().toJson,
  ),
  'isPending': instance.isPending,
  'isFailed': instance.isFailed,
  'inReplyTo': instance.inReplyTo,
  'mentions': instance.mentions,
  'roleMentions': instance.roleMentions,
  'mentionsEveryone': instance.mentionsEveryone,
  'mentionsHere': instance.mentionsHere,
  'attachments': instance.attachments,
  'reactions': instance.reactions,
  'encryptionState': _$MessageEncryptionStateEnumMap[instance.encryptionState]!,
  'type': _$MessageTypeEnumMap[instance.type]!,
  'authorIdType': _$MessageAuthorTypeEnumMap[instance.authorIdType]!,
  'isPinned': instance.isPinned,
  'pinnedAt': _$JsonConverterToJson<String, DateTime>(
    instance.pinnedAt,
    const ApiDateTimeConverter().toJson,
  ),
  'pinnedById': instance.pinnedById,
  'embedsJson': instance.embedsJson,
  'flags': instance.flags,
  'editedAt': _$JsonConverterToJson<String, DateTime>(
    instance.editedAt,
    const ApiDateTimeConverter().toJson,
  ),
  'updatedAt': _$JsonConverterToJson<String, DateTime>(
    instance.updatedAt,
    const ApiDateTimeConverter().toJson,
  ),
  'systemMessageVariant': instance.systemMessageVariant,
  'mlsGeneration': instance.mlsGeneration,
  'mlsEpoch': instance.mlsEpoch,
  'senderDeviceId': instance.senderDeviceId,
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

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

const _$MessageAuthorTypeEnumMap = {
  MessageAuthorType.standard: 'Default',
  MessageAuthorType.bot: 'Bot',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
