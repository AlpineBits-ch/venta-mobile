// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ConversationMemberDto _$ConversationMemberDtoFromJson(
  Map<String, dynamic> json,
) => _ConversationMemberDto(
  id: json['id'] as String,
  userId: json['userId'] as String,
  cachedUserName: json['cachedUserName'] as String,
  lastReadMessageId: json['lastReadMessageId'] as String?,
  mentionCount: (json['mentionCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ConversationMemberDtoToJson(
  _ConversationMemberDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'cachedUserName': instance.cachedUserName,
  'lastReadMessageId': instance.lastReadMessageId,
  'mentionCount': instance.mentionCount,
};

_ConversationDto _$ConversationDtoFromJson(Map<String, dynamic> json) =>
    _ConversationDto(
      id: json['id'] as String,
      name: json['name'] as String?,
      members: (json['members'] as List<dynamic>)
          .map((e) => ConversationMemberDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      encryptionState: $enumDecode(
        _$ConversationEncryptionEnumMap,
        json['encryptionState'],
      ),
    );

Map<String, dynamic> _$ConversationDtoToJson(
  _ConversationDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'members': instance.members,
  'encryptionState': _$ConversationEncryptionEnumMap[instance.encryptionState]!,
};

const _$ConversationEncryptionEnumMap = {
  ConversationEncryption.plain: 'Plain',
  ConversationEncryption.encrypted: 'Encrypted',
};
