// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_mention_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InboxMentionDto _$InboxMentionDtoFromJson(Map<String, dynamic> json) =>
    _InboxMentionDto(
      messageId: json['messageId'] as String? ?? '',
      createdAtRaw: json['createdAt'] as String? ?? '',
      kind:
          $enumDecodeNullable(
            _$InboxMentionKindEnumMap,
            json['kind'],
            unknownValue: InboxMentionKind.direct,
          ) ??
          InboxMentionKind.direct,
      roleId: json['roleId'] as String?,
      roleName: json['roleName'] as String?,
      authorId: json['authorId'] as String? ?? '',
      breadcrumb: json['breadcrumb'] == null
          ? null
          : InboxBreadcrumbDto.fromJson(
              json['breadcrumb'] as Map<String, dynamic>,
            ),
      conversationId: json['conversationId'] as String?,
      message: json['message'] == null
          ? null
          : InboxMessageDto.fromJson(json['message'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$InboxMentionDtoToJson(_InboxMentionDto instance) =>
    <String, dynamic>{
      'messageId': instance.messageId,
      'createdAt': instance.createdAtRaw,
      'kind': _$InboxMentionKindEnumMap[instance.kind]!,
      'roleId': instance.roleId,
      'roleName': instance.roleName,
      'authorId': instance.authorId,
      'breadcrumb': instance.breadcrumb,
      'conversationId': instance.conversationId,
      'message': instance.message,
    };

const _$InboxMentionKindEnumMap = {
  InboxMentionKind.direct: 'Direct',
  InboxMentionKind.here: 'Here',
  InboxMentionKind.everyone: 'Everyone',
  InboxMentionKind.role: 'Role',
};

_InboxMentionPageDto _$InboxMentionPageDtoFromJson(Map<String, dynamic> json) =>
    _InboxMentionPageDto(
      mentions:
          (json['mentions'] as List<dynamic>?)
              ?.map((e) => InboxMentionDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <InboxMentionDto>[],
      nextCursor: json['nextCursor'] as String?,
    );

Map<String, dynamic> _$InboxMentionPageDtoToJson(
  _InboxMentionPageDto instance,
) => <String, dynamic>{
  'mentions': instance.mentions,
  'nextCursor': instance.nextCursor,
};
