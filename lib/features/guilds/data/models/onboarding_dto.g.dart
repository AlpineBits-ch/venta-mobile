// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OnboardingPromptOptionDto _$OnboardingPromptOptionDtoFromJson(
  Map<String, dynamic> json,
) => _OnboardingPromptOptionDto(
  id: json['id'] as String?,
  title: json['title'] as String? ?? '',
  description: json['description'] as String?,
  emoji: json['emoji'] as String?,
  roleIds:
      (json['roleIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  channelIds:
      (json['channelIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  position: (json['position'] as num?)?.toInt() ?? 0,
  selected: json['selected'] as bool? ?? false,
);

Map<String, dynamic> _$OnboardingPromptOptionDtoToJson(
  _OnboardingPromptOptionDto instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'title': instance.title,
  'description': instance.description,
  'emoji': instance.emoji,
  'roleIds': instance.roleIds,
  'channelIds': instance.channelIds,
  'position': instance.position,
};

_OnboardingPromptDto _$OnboardingPromptDtoFromJson(Map<String, dynamic> json) =>
    _OnboardingPromptDto(
      id: json['id'] as String?,
      title: json['title'] as String? ?? '',
      type:
          $enumDecodeNullable(_$OnboardingPromptTypeEnumMap, json['type']) ??
          OnboardingPromptType.multipleChoice,
      singleSelect: json['singleSelect'] as bool? ?? false,
      isRequired: json['required'] as bool? ?? false,
      inOnboarding: json['inOnboarding'] as bool? ?? true,
      position: (json['position'] as num?)?.toInt() ?? 0,
      options:
          (json['options'] as List<dynamic>?)
              ?.map(
                (e) => OnboardingPromptOptionDto.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const <OnboardingPromptOptionDto>[],
    );

Map<String, dynamic> _$OnboardingPromptDtoToJson(
  _OnboardingPromptDto instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'title': instance.title,
  'type': _$OnboardingPromptTypeEnumMap[instance.type]!,
  'singleSelect': instance.singleSelect,
  'required': instance.isRequired,
  'inOnboarding': instance.inOnboarding,
  'position': instance.position,
  'options': instance.options,
};

const _$OnboardingPromptTypeEnumMap = {
  OnboardingPromptType.multipleChoice: 'MultipleChoice',
  OnboardingPromptType.dropdown: 'Dropdown',
};

_OnboardingConfigDto _$OnboardingConfigDtoFromJson(Map<String, dynamic> json) =>
    _OnboardingConfigDto(
      enabled: json['enabled'] as bool? ?? false,
      mode:
          $enumDecodeNullable(_$OnboardingModeEnumMap, json['mode']) ??
          OnboardingMode.standard,
      rulesText: json['rulesText'] as String?,
      defaultChannelIds:
          (json['defaultChannelIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      prompts:
          (json['prompts'] as List<dynamic>?)
              ?.map(
                (e) => OnboardingPromptDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <OnboardingPromptDto>[],
    );

Map<String, dynamic> _$OnboardingConfigDtoToJson(
  _OnboardingConfigDto instance,
) => <String, dynamic>{
  'enabled': instance.enabled,
  'mode': _$OnboardingModeEnumMap[instance.mode]!,
  'rulesText': instance.rulesText,
  'defaultChannelIds': instance.defaultChannelIds,
  'prompts': instance.prompts,
};

const _$OnboardingModeEnumMap = {
  OnboardingMode.standard: 'Default',
  OnboardingMode.advanced: 'Advanced',
};

_OnboardingStatusDto _$OnboardingStatusDtoFromJson(Map<String, dynamic> json) =>
    _OnboardingStatusDto(
      enabled: json['enabled'] as bool? ?? false,
      completed: json['completed'] as bool? ?? true,
      rulesText: json['rulesText'] as String?,
      defaultChannelIds:
          (json['defaultChannelIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      prompts:
          (json['prompts'] as List<dynamic>?)
              ?.map(
                (e) => OnboardingPromptDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <OnboardingPromptDto>[],
    );

Map<String, dynamic> _$OnboardingStatusDtoToJson(
  _OnboardingStatusDto instance,
) => <String, dynamic>{
  'enabled': instance.enabled,
  'completed': instance.completed,
  'rulesText': instance.rulesText,
  'defaultChannelIds': instance.defaultChannelIds,
  'prompts': instance.prompts,
};

_OnboardingResponseDto _$OnboardingResponseDtoFromJson(
  Map<String, dynamic> json,
) => _OnboardingResponseDto(
  promptId: json['promptId'] as String,
  optionIds:
      (json['optionIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
);

Map<String, dynamic> _$OnboardingResponseDtoToJson(
  _OnboardingResponseDto instance,
) => <String, dynamic>{
  'promptId': instance.promptId,
  'optionIds': instance.optionIds,
};

_PendingMemberDto _$PendingMemberDtoFromJson(Map<String, dynamic> json) =>
    _PendingMemberDto(
      memberId: json['memberId'] as String,
      userId: json['userId'] as String,
      nickname: json['nickname'] as String?,
      joinedAt: _$JsonConverterFromJson<String, DateTime>(
        json['joinedAt'],
        const ApiDateTimeConverter().fromJson,
      ),
    );

Map<String, dynamic> _$PendingMemberDtoToJson(_PendingMemberDto instance) =>
    <String, dynamic>{
      'memberId': instance.memberId,
      'userId': instance.userId,
      'nickname': instance.nickname,
      'joinedAt': _$JsonConverterToJson<String, DateTime>(
        instance.joinedAt,
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
