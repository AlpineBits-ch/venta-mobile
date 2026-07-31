// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'decision_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DecisionOptionDto _$DecisionOptionDtoFromJson(Map<String, dynamic> json) =>
    _DecisionOptionDto(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      position: (json['position'] as num?)?.toInt() ?? 0,
      supportCount: (json['supportCount'] as num?)?.toInt() ?? 0,
      isBlocked: json['isBlocked'] as bool? ?? false,
    );

Map<String, dynamic> _$DecisionOptionDtoToJson(_DecisionOptionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'position': instance.position,
      'supportCount': instance.supportCount,
      'isBlocked': instance.isBlocked,
    };

_DecisionBlockDto _$DecisionBlockDtoFromJson(Map<String, dynamic> json) =>
    _DecisionBlockDto(
      userId: json['userId'] as String? ?? '',
      optionId: json['optionId'] as String?,
      reason: json['reason'] as String? ?? '',
    );

Map<String, dynamic> _$DecisionBlockDtoToJson(_DecisionBlockDto instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'optionId': instance.optionId,
      'reason': instance.reason,
    };

_DecisionDto _$DecisionDtoFromJson(Map<String, dynamic> json) => _DecisionDto(
  id: json['id'] as String,
  channelId: json['channelId'] as String,
  title: json['title'] as String? ?? '',
  description: json['description'] as String?,
  createdByUserId: json['createdByUserId'] as String? ?? '',
  closesAt: _$JsonConverterFromJson<String, DateTime>(
    json['closesAt'],
    const ApiDateTimeConverter().fromJson,
  ),
  quorum: (json['quorum'] as num?)?.toInt(),
  status:
      $enumDecodeNullable(
        _$DecisionStatusEnumMap,
        json['status'],
        unknownValue: DecisionStatus.open,
      ) ??
      DecisionStatus.open,
  outcomeOptionId: json['outcomeOptionId'] as String?,
  options:
      (json['options'] as List<dynamic>?)
          ?.map((e) => DecisionOptionDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <DecisionOptionDto>[],
  blocks:
      (json['blocks'] as List<dynamic>?)
          ?.map((e) => DecisionBlockDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <DecisionBlockDto>[],
  myVoteOptionId: json['myVoteOptionId'] as String?,
  myVoteKind: $enumDecodeNullable(
    _$VoteKindEnumMap,
    json['myVoteKind'],
    unknownValue: JsonKey.nullForUndefinedEnumValue,
  ),
);

Map<String, dynamic> _$DecisionDtoToJson(_DecisionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'channelId': instance.channelId,
      'title': instance.title,
      'description': instance.description,
      'createdByUserId': instance.createdByUserId,
      'closesAt': _$JsonConverterToJson<String, DateTime>(
        instance.closesAt,
        const ApiDateTimeConverter().toJson,
      ),
      'quorum': instance.quorum,
      'status': _$DecisionStatusEnumMap[instance.status]!,
      'outcomeOptionId': instance.outcomeOptionId,
      'options': instance.options,
      'blocks': instance.blocks,
      'myVoteOptionId': instance.myVoteOptionId,
      'myVoteKind': _$VoteKindEnumMap[instance.myVoteKind],
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

const _$DecisionStatusEnumMap = {
  DecisionStatus.open: 'Open',
  DecisionStatus.decided: 'Decided',
  DecisionStatus.blocked: 'Blocked',
  DecisionStatus.cancelled: 'Cancelled',
  DecisionStatus.expired: 'Expired',
};

const _$VoteKindEnumMap = {
  VoteKind.support: 'Support',
  VoteKind.abstain: 'Abstain',
  VoteKind.block: 'Block',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
