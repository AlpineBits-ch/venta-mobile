// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OnboardingConfigDto _$OnboardingConfigDtoFromJson(Map<String, dynamic> json) =>
    _OnboardingConfigDto(
      enabled: json['enabled'] as bool? ?? false,
      rulesText: json['rulesText'] as String?,
      defaultChannelIds:
          (json['defaultChannelIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$OnboardingConfigDtoToJson(
  _OnboardingConfigDto instance,
) => <String, dynamic>{
  'enabled': instance.enabled,
  'rulesText': instance.rulesText,
  'defaultChannelIds': instance.defaultChannelIds,
};

_OnboardingStatusDto _$OnboardingStatusDtoFromJson(Map<String, dynamic> json) =>
    _OnboardingStatusDto(
      completed: json['completed'] as bool? ?? true,
      rulesText: json['rulesText'] as String?,
      defaultChannelIds:
          (json['defaultChannelIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$OnboardingStatusDtoToJson(
  _OnboardingStatusDto instance,
) => <String, dynamic>{
  'completed': instance.completed,
  'rulesText': instance.rulesText,
  'defaultChannelIds': instance.defaultChannelIds,
};
