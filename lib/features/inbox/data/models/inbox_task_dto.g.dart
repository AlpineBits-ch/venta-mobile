// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_task_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InboxTaskDto _$InboxTaskDtoFromJson(Map<String, dynamic> json) =>
    _InboxTaskDto(
      kind:
          $enumDecodeNullable(
            _$InboxTaskKindEnumMap,
            json['kind'],
            unknownValue: InboxTaskKind.unknown,
          ) ??
          InboxTaskKind.unknown,
      targetId: json['targetId'] as String? ?? '',
      breadcrumb: json['breadcrumb'] == null
          ? const InboxBreadcrumbDto()
          : InboxBreadcrumbDto.fromJson(
              json['breadcrumb'] as Map<String, dynamic>,
            ),
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      dueAt: _$JsonConverterFromJson<String, DateTime>(
        json['dueAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      isOverdue: json['isOverdue'] as bool? ?? false,
    );

Map<String, dynamic> _$InboxTaskDtoToJson(_InboxTaskDto instance) =>
    <String, dynamic>{
      'kind': _$InboxTaskKindEnumMap[instance.kind]!,
      'targetId': instance.targetId,
      'breadcrumb': instance.breadcrumb,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'dueAt': _$JsonConverterToJson<String, DateTime>(
        instance.dueAt,
        const ApiDateTimeConverter().toJson,
      ),
      'isOverdue': instance.isOverdue,
    };

const _$InboxTaskKindEnumMap = {
  InboxTaskKind.choreDue: 'ChoreDue',
  InboxTaskKind.decisionVote: 'DecisionVote',
  InboxTaskKind.listAssignment: 'ListAssignment',
  InboxTaskKind.billDue: 'BillDue',
  InboxTaskKind.cookingToday: 'CookingToday',
  InboxTaskKind.maintenanceDue: 'MaintenanceDue',
  InboxTaskKind.unknown: 'unknown',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_InboxTaskPageDto _$InboxTaskPageDtoFromJson(Map<String, dynamic> json) =>
    _InboxTaskPageDto(
      tasks:
          (json['tasks'] as List<dynamic>?)
              ?.map((e) => InboxTaskDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <InboxTaskDto>[],
      truncated: json['truncated'] as bool? ?? false,
    );

Map<String, dynamic> _$InboxTaskPageDtoToJson(_InboxTaskPageDto instance) =>
    <String, dynamic>{'tasks': instance.tasks, 'truncated': instance.truncated};
