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
      iconUpdatedAt: _$JsonConverterFromJson<String, DateTime>(
        json['iconUpdatedAt'],
        const ApiDateTimeConverter().fromJson,
      ),
    );

Map<String, dynamic> _$ConversationDtoToJson(
  _ConversationDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'members': instance.members,
  'encryptionState': _$ConversationEncryptionEnumMap[instance.encryptionState]!,
  'iconUpdatedAt': _$JsonConverterToJson<String, DateTime>(
    instance.iconUpdatedAt,
    const ApiDateTimeConverter().toJson,
  ),
};

const _$ConversationEncryptionEnumMap = {
  ConversationEncryption.plain: 'Plain',
  ConversationEncryption.encrypted: 'Encrypted',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
