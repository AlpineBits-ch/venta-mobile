// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_catalogue_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BillingPlanDto _$BillingPlanDtoFromJson(Map<String, dynamic> json) =>
    _BillingPlanDto(
      name: json['name'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      versionNumber: (json['versionNumber'] as num?)?.toInt() ?? 0,
      subjectKind: json['subjectKind'] as String? ?? '',
      entitlements:
          (json['entitlements'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
              k,
              EntitlementValueDto.fromJson(e as Map<String, dynamic>),
            ),
          ) ??
          const <String, EntitlementValueDto>{},
    );

Map<String, dynamic> _$BillingPlanDtoToJson(_BillingPlanDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'displayName': instance.displayName,
      'versionNumber': instance.versionNumber,
      'subjectKind': instance.subjectKind,
      'entitlements': instance.entitlements,
    };

_BillingCatalogueDto _$BillingCatalogueDtoFromJson(Map<String, dynamic> json) =>
    _BillingCatalogueDto(
      plans:
          (json['plans'] as List<dynamic>?)
              ?.map((e) => BillingPlanDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <BillingPlanDto>[],
    );

Map<String, dynamic> _$BillingCatalogueDtoToJson(
  _BillingCatalogueDto instance,
) => <String, dynamic>{'plans': instance.plans};
