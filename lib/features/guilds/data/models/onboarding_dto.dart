import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_dto.freezed.dart';
part 'onboarding_dto.g.dart';

/// Admin-configured "read and accept the rules" gate - `PUT` fully replaces
/// this, same non-partial convention as [AutoModConfigDto]'s guide entry.
@freezed
sealed class OnboardingConfigDto with _$OnboardingConfigDto {
  const factory OnboardingConfigDto({
    @Default(false) bool enabled,
    String? rulesText,
    @Default([]) List<String> defaultChannelIds,
  }) = _OnboardingConfigDto;

  factory OnboardingConfigDto.fromJson(Map<String, dynamic> json) =>
      _$OnboardingConfigDtoFromJson(json);
}

/// The calling member's own onboarding state (`.../onboarding/me`) - once
/// [completed] flips `true` there's no "re-accept" flow, so this is only
/// ever checked, never cached long-term.
@freezed
sealed class OnboardingStatusDto with _$OnboardingStatusDto {
  const factory OnboardingStatusDto({
    @Default(true) bool completed,
    String? rulesText,
    @Default([]) List<String> defaultChannelIds,
  }) = _OnboardingStatusDto;

  factory OnboardingStatusDto.fromJson(Map<String, dynamic> json) =>
      _$OnboardingStatusDtoFromJson(json);
}
