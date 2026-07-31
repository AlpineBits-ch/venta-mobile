// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chore_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChoreDto _$ChoreDtoFromJson(Map<String, dynamic> json) => _ChoreDto(
  id: json['id'] as String,
  channelId: json['channelId'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  intervalDays: (json['intervalDays'] as num?)?.toInt() ?? 7,
  anchorAt: _$JsonConverterFromJson<String, DateTime>(
    json['anchorAt'],
    const ApiDateTimeConverter().fromJson,
  ),
  effortMinutes: (json['effortMinutes'] as num?)?.toInt() ?? 15,
  rotationRoleId: json['rotationRoleId'] as String?,
  fixedAssigneeUserId: json['fixedAssigneeUserId'] as String?,
  graceHours: (json['graceHours'] as num?)?.toInt() ?? 0,
  isPaused: json['isPaused'] as bool? ?? false,
  nextDueAt: _$JsonConverterFromJson<String, DateTime>(
    json['nextDueAt'],
    const ApiDateTimeConverter().fromJson,
  ),
);

Map<String, dynamic> _$ChoreDtoToJson(_ChoreDto instance) => <String, dynamic>{
  'id': instance.id,
  'channelId': instance.channelId,
  'title': instance.title,
  'description': instance.description,
  'intervalDays': instance.intervalDays,
  'anchorAt': _$JsonConverterToJson<String, DateTime>(
    instance.anchorAt,
    const ApiDateTimeConverter().toJson,
  ),
  'effortMinutes': instance.effortMinutes,
  'rotationRoleId': instance.rotationRoleId,
  'fixedAssigneeUserId': instance.fixedAssigneeUserId,
  'graceHours': instance.graceHours,
  'isPaused': instance.isPaused,
  'nextDueAt': _$JsonConverterToJson<String, DateTime>(
    instance.nextDueAt,
    const ApiDateTimeConverter().toJson,
  ),
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_ChoreOccurrenceDto _$ChoreOccurrenceDtoFromJson(Map<String, dynamic> json) =>
    _ChoreOccurrenceDto(
      id: json['id'] as String,
      choreId: json['choreId'] as String,
      channelId: json['channelId'] as String,
      title: json['title'] as String? ?? '',
      dueAt: const ApiDateTimeConverter().fromJson(json['dueAt'] as String),
      assignedUserId: json['assignedUserId'] as String? ?? '',
      effortMinutes: (json['effortMinutes'] as num?)?.toInt() ?? 0,
      completedAt: _$JsonConverterFromJson<String, DateTime>(
        json['completedAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      completedByUserId: json['completedByUserId'] as String?,
      skippedAt: _$JsonConverterFromJson<String, DateTime>(
        json['skippedAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      isOverdue: json['isOverdue'] as bool? ?? false,
    );

Map<String, dynamic> _$ChoreOccurrenceDtoToJson(_ChoreOccurrenceDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'choreId': instance.choreId,
      'channelId': instance.channelId,
      'title': instance.title,
      'dueAt': const ApiDateTimeConverter().toJson(instance.dueAt),
      'assignedUserId': instance.assignedUserId,
      'effortMinutes': instance.effortMinutes,
      'completedAt': _$JsonConverterToJson<String, DateTime>(
        instance.completedAt,
        const ApiDateTimeConverter().toJson,
      ),
      'completedByUserId': instance.completedByUserId,
      'skippedAt': _$JsonConverterToJson<String, DateTime>(
        instance.skippedAt,
        const ApiDateTimeConverter().toJson,
      ),
      'isOverdue': instance.isOverdue,
    };

_ChoreBalanceEntryDto _$ChoreBalanceEntryDtoFromJson(
  Map<String, dynamic> json,
) => _ChoreBalanceEntryDto(
  userId: json['userId'] as String? ?? '',
  completedMinutes: (json['completedMinutes'] as num?)?.toInt() ?? 0,
  completedCount: (json['completedCount'] as num?)?.toInt() ?? 0,
  balanceMinutes: (json['balanceMinutes'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ChoreBalanceEntryDtoToJson(
  _ChoreBalanceEntryDto instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'completedMinutes': instance.completedMinutes,
  'completedCount': instance.completedCount,
  'balanceMinutes': instance.balanceMinutes,
};
