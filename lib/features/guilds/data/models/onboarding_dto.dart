import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';

part 'onboarding_dto.freezed.dart';
part 'onboarding_dto.g.dart';

/// Mirrors Discord's flag for whether channels reachable through prompt
/// options count toward "what a newcomer can see". Purely advisory here - the
/// backend enforces no minimum-channel requirement - so it's stored and shown
/// for parity, nothing more.
enum OnboardingMode {
  @JsonValue('Default')
  standard,
  @JsonValue('Advanced')
  advanced,
}

enum OnboardingPromptType {
  @JsonValue('MultipleChoice')
  multipleChoice,
  @JsonValue('Dropdown')
  dropdown,
}

/// One answer to an [OnboardingPromptDto]. Picking it grants [roleIds] and
/// makes [channelIds] visible through a real per-member permission overwrite -
/// which is what actually changes visibility. (A guild's
/// `defaultChannelIds` are only a UI hint and grant nothing.)
@freezed
sealed class OnboardingPromptOptionDto with _$OnboardingPromptOptionDto {
  const factory OnboardingPromptOptionDto({
    /// Omitted to create; round-trip the server-assigned `onbo_...` to update
    /// in place. Dropping an id you were given deletes the option.
    @JsonKey(includeIfNull: false) String? id,
    @Default('') String title,
    String? description,

    /// A unicode emoji, or a guild emoji id.
    String? emoji,
    @Default(<String>[]) List<String> roleIds,
    @Default(<String>[]) List<String> channelIds,
    @Default(0) int position,

    /// Whether the calling member currently has this option picked - present
    /// only on `.../onboarding/prompts`, never sent back on a write.
    @JsonKey(includeToJson: false) @Default(false) bool selected,
  }) = _OnboardingPromptOptionDto;

  factory OnboardingPromptOptionDto.fromJson(Map<String, dynamic> json) =>
      _$OnboardingPromptOptionDtoFromJson(json);
}

/// A question shown during onboarding and/or in Channels & Roles, whose
/// answers self-assign roles and channels.
@freezed
sealed class OnboardingPromptDto with _$OnboardingPromptDto {
  const factory OnboardingPromptDto({
    /// Omitted to create; round-trip the server-assigned `onbp_...` to update
    /// in place. Dropping an id you were given deletes the prompt *and every
    /// member's answer to it*.
    @JsonKey(includeIfNull: false) String? id,
    @Default('') String title,
    @Default(OnboardingPromptType.multipleChoice) OnboardingPromptType type,

    /// `true` = radio buttons, `false` = checkboxes.
    @Default(false) bool singleSelect,

    /// Must be answered before onboarding can be finished. `required` is a
    /// Dart modifier keyword, hence the renamed field.
    @JsonKey(name: 'required') @Default(false) bool isRequired,

    /// `false` = only offered in Channels & Roles, never in the join flow.
    @Default(true) bool inOnboarding,
    @Default(0) int position,
    @Default(<OnboardingPromptOptionDto>[])
    List<OnboardingPromptOptionDto> options,
  }) = _OnboardingPromptDto;

  factory OnboardingPromptDto.fromJson(Map<String, dynamic> json) =>
      _$OnboardingPromptDtoFromJson(json);
}

/// Admin-configured onboarding: the rules gate, the prompts, and the
/// suggested channels. `PUT` **replaces the whole document** - a prompt or
/// option missing from the payload is deleted, so the edit loop must be
/// `GET` → mutate → `PUT` with every id round-tripped.
///
/// Deleting an option does *not* take back what it already granted; members
/// keep the role and channel access until they deselect it themselves.
@freezed
sealed class OnboardingConfigDto with _$OnboardingConfigDto {
  const factory OnboardingConfigDto({
    @Default(false) bool enabled,
    @Default(OnboardingMode.standard) OnboardingMode mode,
    String? rulesText,
    @Default(<String>[]) List<String> defaultChannelIds,
    @Default(<OnboardingPromptDto>[]) List<OnboardingPromptDto> prompts,
  }) = _OnboardingConfigDto;

  factory OnboardingConfigDto.fromJson(Map<String, dynamic> json) =>
      _$OnboardingConfigDtoFromJson(json);

  /// Server-enforced caps, mirrored so the settings screen can flag problems
  /// inline instead of round-tripping into a `400`.
  static const maxRulesLength = 4000;
  static const maxDefaultChannels = 25;
  static const maxPrompts = 10;
  static const maxOptionsPerPrompt = 25;
  static const maxGrantsPerOption = 10;
  static const maxTitleLength = 100;
}

/// The calling member's own onboarding state (`.../onboarding/me`).
///
/// Show the onboarding flow only while `enabled && !completed`. When
/// [enabled] is `false` there is nothing to show even if [completed] is
/// `false` - that's a member who joined while onboarding was on and had it
/// switched off underneath them, and they are *not* restricted.
@freezed
sealed class OnboardingStatusDto with _$OnboardingStatusDto {
  const factory OnboardingStatusDto({
    @Default(false) bool enabled,
    @Default(true) bool completed,
    String? rulesText,
    @Default(<String>[]) List<String> defaultChannelIds,

    /// Only prompts with `inOnboarding: true`.
    @Default(<OnboardingPromptDto>[]) List<OnboardingPromptDto> prompts,
  }) = _OnboardingStatusDto;

  factory OnboardingStatusDto.fromJson(Map<String, dynamic> json) =>
      _$OnboardingStatusDtoFromJson(json);
}

/// One prompt's answer, sent on accept and on every Channels & Roles save.
@freezed
sealed class OnboardingResponseDto with _$OnboardingResponseDto {
  const factory OnboardingResponseDto({
    required String promptId,
    @Default(<String>[]) List<String> optionIds,
  }) = _OnboardingResponseDto;

  factory OnboardingResponseDto.fromJson(Map<String, dynamic> json) =>
      _$OnboardingResponseDtoFromJson(json);
}

/// A member still sitting on the onboarding screen - the moderator-side
/// report behind a "3 members haven't accepted the rules" nudge.
@freezed
sealed class PendingMemberDto with _$PendingMemberDto {
  @ApiDateTimeConverter()
  const factory PendingMemberDto({
    required String memberId,
    required String userId,
    String? nickname,
    DateTime? joinedAt,
  }) = _PendingMemberDto;

  factory PendingMemberDto.fromJson(Map<String, dynamic> json) =>
      _$PendingMemberDtoFromJson(json);
}
