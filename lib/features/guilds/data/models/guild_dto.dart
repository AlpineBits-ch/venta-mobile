import 'package:freezed_annotation/freezed_annotation.dart';

import 'category_dto.dart';
import 'channel_dto.dart';
import 'role_dto.dart';

part 'guild_dto.freezed.dart';
part 'guild_dto.g.dart';

/// Gates who may *join* a guild via invite redemption based on how
/// established their account is - mirrors Discord's verification levels.
/// v1 is join-time only: already-joined members are never re-checked, and a
/// level raised after someone joined doesn't retroactively restrict them.
enum VerificationLevel {
  @JsonValue('None')
  none,
  @JsonValue('Low')
  low,
  @JsonValue('Medium')
  medium,
  @JsonValue('High')
  high,
}

@freezed
sealed class GuildDto with _$GuildDto {
  const factory GuildDto({
    required String id,
    required String name,
    String? description,
    required String ownerId,
    @Default(<CategoryDto>[]) List<CategoryDto> categories,
    @Default(<ChannelDto>[]) List<ChannelDto> channels,
    @Default(<RoleDto>[]) List<RoleDto> roles,
    String? bannerUrl,

    /// Not yet sent by the backend - forward-compatible plumbing only, so
    /// the client doesn't need a second change once it starts being sent.
    /// `ServerRailIcon` falls back to the initial-letter circle while null.
    String? iconUrl,
    String? systemChannelId,
    @Default(VerificationLevel.none)
    @JsonKey(unknownEnumValue: VerificationLevel.none)
    VerificationLevel verificationLevel,
  }) = _GuildDto;

  factory GuildDto.fromJson(Map<String, dynamic> json) =>
      _$GuildDtoFromJson(json);
}
