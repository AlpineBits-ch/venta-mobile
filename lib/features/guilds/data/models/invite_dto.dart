import 'package:freezed_annotation/freezed_annotation.dart';

import 'guild_dto.dart';
import 'welcome_screen_dto.dart';

part 'invite_dto.freezed.dart';
part 'invite_dto.g.dart';

enum InviteType {
  @JsonValue('OneTime')
  oneTime,
  @JsonValue('Permanent')
  permanent,
}

enum InviteState {
  @JsonValue('Active')
  active,
  @JsonValue('Expired')
  expired,
}

@freezed
sealed class InviteDto with _$InviteDto {
  const factory InviteDto({
    required String id,
    required InviteType type,
    required InviteState state,
    required String guildId,
    GuildDto? guild,
    required String code,
    String? expiresAt,
    int? maxUses,
    @Default(0) int useCount,

    /// The guild's welcome splash, present only when it has one and it's
    /// enabled. Carried inline here because the dedicated welcome-screen
    /// endpoint is members-only and whoever is looking at an invite isn't one
    /// yet.
    WelcomeScreenDto? welcomeScreen,
  }) = _InviteDto;

  factory InviteDto.fromJson(Map<String, dynamic> json) =>
      _$InviteDtoFromJson(json);
}
