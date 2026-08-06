// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InboxSummaryDto _$InboxSummaryDtoFromJson(Map<String, dynamic> json) =>
    _InboxSummaryDto(
      unreadChannelCount: (json['unreadChannelCount'] as num?)?.toInt() ?? 0,
      mentionCount: (json['mentionCount'] as num?)?.toInt() ?? 0,
      taskCount: (json['taskCount'] as num?)?.toInt() ?? 0,
      capped: json['capped'] as bool? ?? false,
    );

Map<String, dynamic> _$InboxSummaryDtoToJson(_InboxSummaryDto instance) =>
    <String, dynamic>{
      'unreadChannelCount': instance.unreadChannelCount,
      'mentionCount': instance.mentionCount,
      'taskCount': instance.taskCount,
      'capped': instance.capped,
    };
