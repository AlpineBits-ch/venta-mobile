import 'package:freezed_annotation/freezed_annotation.dart';

part 'welcome_screen_dto.freezed.dart';
part 'welcome_screen_dto.g.dart';

/// One highlighted channel on a guild's welcome screen.
@freezed
sealed class WelcomeChannelDto with _$WelcomeChannelDto {
  const factory WelcomeChannelDto({
    required String channelId,

    /// Max 50 chars, server-enforced.
    @Default('') String description,
    String? emoji,
    @Default(0) int position,
  }) = _WelcomeChannelDto;

  factory WelcomeChannelDto.fromJson(Map<String, dynamic> json) =>
      _$WelcomeChannelDtoFromJson(json);
}

/// The splash shown to someone looking at an invite, *before* they join.
///
/// Members read/write it at `.../guilds/{id}/welcome-screen`; the pre-join
/// case can't (a non-member has no access), so the invite preview
/// (`GET .../invites/code/{code}`) carries it inline instead, on
/// `InviteDto.welcomeScreen`.
@freezed
sealed class WelcomeScreenDto with _$WelcomeScreenDto {
  const factory WelcomeScreenDto({
    @Default(false) bool enabled,

    /// Max 140 chars, server-enforced.
    String? description,
    @Default(<WelcomeChannelDto>[]) List<WelcomeChannelDto> channels,
  }) = _WelcomeScreenDto;

  factory WelcomeScreenDto.fromJson(Map<String, dynamic> json) =>
      _$WelcomeScreenDtoFromJson(json);

  static const maxChannels = 5;
  static const maxDescriptionLength = 140;
  static const maxChannelDescriptionLength = 50;
}
