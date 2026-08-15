// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlement_degradation_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EntitlementDegradationDto _$EntitlementDegradationDtoFromJson(
  Map<String, dynamic> json,
) => _EntitlementDegradationDto(
  key: json['key'] as String? ?? '',
  requested: json['requested'] == null
      ? null
      : EntitlementValueDto.fromJson(json['requested'] as Map<String, dynamic>),
  granted: json['granted'] == null
      ? null
      : EntitlementValueDto.fromJson(json['granted'] as Map<String, dynamic>),
  reason:
      $enumDecodeNullable(
        _$DegradationReasonEnumMap,
        json['reason'],
        unknownValue: DegradationReason.unknown,
      ) ??
      DegradationReason.unknown,
  boundBy: $enumDecodeNullable(
    _$DegradationBoundByEnumMap,
    json['boundBy'],
    unknownValue: DegradationBoundBy.unknown,
  ),
  subject: json['subject'] == null
      ? const EntitlementSubjectDto()
      : EntitlementSubjectDto.fromJson(json['subject'] as Map<String, dynamic>),
);

Map<String, dynamic> _$EntitlementDegradationDtoToJson(
  _EntitlementDegradationDto instance,
) => <String, dynamic>{
  'key': instance.key,
  'requested': instance.requested,
  'granted': instance.granted,
  'reason': _$DegradationReasonEnumMap[instance.reason]!,
  'boundBy': _$DegradationBoundByEnumMap[instance.boundBy],
  'subject': instance.subject,
};

const _$DegradationReasonEnumMap = {
  DegradationReason.guildPlanLimit: 'guild_plan_limit',
  DegradationReason.userPlanLimit: 'user_plan_limit',
  DegradationReason.pairedCeiling: 'paired_ceiling',
  DegradationReason.operatorCeiling: 'operator_ceiling',
  DegradationReason.unknown: 'unknown',
};

const _$DegradationBoundByEnumMap = {
  DegradationBoundBy.guild: 'guild',
  DegradationBoundBy.user: 'user',
  DegradationBoundBy.unknown: 'unknown',
};
