import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_dto.freezed.dart';
part 'profile_dto.g.dart';

enum OnlineStatus {
  @JsonValue('Offline')
  offline,
  @JsonValue('Hidden')
  hidden,
  @JsonValue('Online')
  online,
  @JsonValue('Idle')
  idle,
  @JsonValue('DoNotDisturb')
  doNotDisturb,
}

enum ProfileFont {
  @JsonValue('Default')
  defaultFont,
  @JsonValue('Serif')
  serif,
  @JsonValue('Monospace')
  monospace,
  @JsonValue('Rounded')
  rounded,
  @JsonValue('Display')
  display,
  @JsonValue('Handwritten')
  handwritten,
}

@freezed
sealed class ProfileDto with _$ProfileDto {
  const factory ProfileDto({
    required String id,
    required String userId,
    required String userName,
    String? bio,
    String? avatarUrl,
    String? bannerUrl,
    String? accentColor,
    @Default(ProfileFont.defaultFont) ProfileFont font,
    @Default(OnlineStatus.offline) OnlineStatus onlineStatus,
  }) = _ProfileDto;

  factory ProfileDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileDtoFromJson(json);
}
