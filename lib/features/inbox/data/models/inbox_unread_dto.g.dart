// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_unread_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InboxUnreadGroupDto _$InboxUnreadGroupDtoFromJson(Map<String, dynamic> json) =>
    _InboxUnreadGroupDto(
      breadcrumb: json['breadcrumb'] == null
          ? const InboxBreadcrumbDto()
          : InboxBreadcrumbDto.fromJson(
              json['breadcrumb'] as Map<String, dynamic>,
            ),
      lastActivityAt: _$JsonConverterFromJson<String, DateTime>(
        json['lastActivityAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      mentionCount: (json['mentionCount'] as num?)?.toInt() ?? 0,
      previews:
          (json['previews'] as List<dynamic>?)
              ?.map((e) => InboxMessageDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <InboxMessageDto>[],
      previewsTruncated: json['previewsTruncated'] as bool? ?? false,
    );

Map<String, dynamic> _$InboxUnreadGroupDtoToJson(
  _InboxUnreadGroupDto instance,
) => <String, dynamic>{
  'breadcrumb': instance.breadcrumb,
  'lastActivityAt': _$JsonConverterToJson<String, DateTime>(
    instance.lastActivityAt,
    const ApiDateTimeConverter().toJson,
  ),
  'unreadCount': instance.unreadCount,
  'mentionCount': instance.mentionCount,
  'previews': instance.previews,
  'previewsTruncated': instance.previewsTruncated,
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_InboxUnreadPageDto _$InboxUnreadPageDtoFromJson(Map<String, dynamic> json) =>
    _InboxUnreadPageDto(
      groups:
          (json['groups'] as List<dynamic>?)
              ?.map(
                (e) => InboxUnreadGroupDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <InboxUnreadGroupDto>[],
      nextCursor: json['nextCursor'] as String?,
      previewsUnavailable: json['previewsUnavailable'] as bool? ?? false,
    );

Map<String, dynamic> _$InboxUnreadPageDtoToJson(_InboxUnreadPageDto instance) =>
    <String, dynamic>{
      'groups': instance.groups,
      'nextCursor': instance.nextCursor,
      'previewsUnavailable': instance.previewsUnavailable,
    };
