import 'package:freezed_annotation/freezed_annotation.dart';

import 'profile_extras.dart';

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

    // ── Visibility-gated (see `profile_extras.dart`) ──────────────────────
    //
    // Null means the key was absent, which is what the server sends when the
    // subject's setting doesn't admit this viewer. That is *not* the same as an
    // empty list, and the profile screen renders the two differently: an empty
    // list is "no servers in common", a missing one is a section that isn't
    // there at all.
    List<MutualEntry>? mutualFriends,
    List<MutualEntry>? mutualServers,
    List<ProfileConnection>? connections,

    /// A date, sent without a time. Kept as the raw string: it is displayed and
    /// never compared, and parsing a date-only value into a `DateTime` would
    /// shift it a day either way depending on the device's timezone.
    String? birthday,
    ProfileActivity? activity,
  }) = _ProfileDto;

  factory ProfileDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileDtoFromJson(json);
}
