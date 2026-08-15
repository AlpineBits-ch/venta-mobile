// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlement_snapshot_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EntitlementSubjectDto _$EntitlementSubjectDtoFromJson(
  Map<String, dynamic> json,
) => _EntitlementSubjectDto(
  kind: json['kind'] as String? ?? '',
  id: json['id'] as String? ?? '',
);

Map<String, dynamic> _$EntitlementSubjectDtoToJson(
  _EntitlementSubjectDto instance,
) => <String, dynamic>{'kind': instance.kind, 'id': instance.id};

_EntitlementPlanDto _$EntitlementPlanDtoFromJson(Map<String, dynamic> json) =>
    _EntitlementPlanDto(
      name: json['name'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      version: (json['version'] as num?)?.toInt(),
      currentVersion: (json['currentVersion'] as num?)?.toInt(),
    );

Map<String, dynamic> _$EntitlementPlanDtoToJson(_EntitlementPlanDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'displayName': instance.displayName,
      'version': instance.version,
      'currentVersion': instance.currentVersion,
    };

_EntitlementSnapshotDto _$EntitlementSnapshotDtoFromJson(
  Map<String, dynamic> json,
) => _EntitlementSnapshotDto(
  subject: json['subject'] == null
      ? const EntitlementSubjectDto()
      : EntitlementSubjectDto.fromJson(json['subject'] as Map<String, dynamic>),
  plan: json['plan'] == null
      ? null
      : EntitlementPlanDto.fromJson(json['plan'] as Map<String, dynamic>),
  entitlements:
      (json['entitlements'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          EntitlementValueDto.fromJson(e as Map<String, dynamic>),
        ),
      ) ??
      const <String, EntitlementValueDto>{},
);

Map<String, dynamic> _$EntitlementSnapshotDtoToJson(
  _EntitlementSnapshotDto instance,
) => <String, dynamic>{
  'subject': instance.subject,
  'plan': instance.plan,
  'entitlements': instance.entitlements,
};
