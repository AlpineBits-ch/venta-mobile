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
  anchorAt: json['anchorAt'] == null
      ? null
      : DateTime.parse(json['anchorAt'] as String),
  effortMinutes: (json['effortMinutes'] as num?)?.toInt() ?? 15,
  rotationRoleId: json['rotationRoleId'] as String?,
  fixedAssigneeUserId: json['fixedAssigneeUserId'] as String?,
  graceHours: (json['graceHours'] as num?)?.toInt() ?? 0,
  isPaused: json['isPaused'] as bool? ?? false,
  nextDueAt: json['nextDueAt'] == null
      ? null
      : DateTime.parse(json['nextDueAt'] as String),
);

Map<String, dynamic> _$ChoreDtoToJson(_ChoreDto instance) => <String, dynamic>{
  'id': instance.id,
  'channelId': instance.channelId,
  'title': instance.title,
  'description': instance.description,
  'intervalDays': instance.intervalDays,
  'anchorAt': instance.anchorAt?.toIso8601String(),
  'effortMinutes': instance.effortMinutes,
  'rotationRoleId': instance.rotationRoleId,
  'fixedAssigneeUserId': instance.fixedAssigneeUserId,
  'graceHours': instance.graceHours,
  'isPaused': instance.isPaused,
  'nextDueAt': instance.nextDueAt?.toIso8601String(),
};

_ChoreOccurrenceDto _$ChoreOccurrenceDtoFromJson(Map<String, dynamic> json) =>
    _ChoreOccurrenceDto(
      id: json['id'] as String,
      choreId: json['choreId'] as String,
      channelId: json['channelId'] as String,
      title: json['title'] as String? ?? '',
      dueAt: DateTime.parse(json['dueAt'] as String),
      assignedUserId: json['assignedUserId'] as String? ?? '',
      effortMinutes: (json['effortMinutes'] as num?)?.toInt() ?? 0,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      completedByUserId: json['completedByUserId'] as String?,
      skippedAt: json['skippedAt'] == null
          ? null
          : DateTime.parse(json['skippedAt'] as String),
      isOverdue: json['isOverdue'] as bool? ?? false,
    );

Map<String, dynamic> _$ChoreOccurrenceDtoToJson(_ChoreOccurrenceDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'choreId': instance.choreId,
      'channelId': instance.channelId,
      'title': instance.title,
      'dueAt': instance.dueAt.toIso8601String(),
      'assignedUserId': instance.assignedUserId,
      'effortMinutes': instance.effortMinutes,
      'completedAt': instance.completedAt?.toIso8601String(),
      'completedByUserId': instance.completedByUserId,
      'skippedAt': instance.skippedAt?.toIso8601String(),
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
