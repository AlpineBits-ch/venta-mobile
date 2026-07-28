import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../profile/data/models/profile_dto.dart';
import 'guild_permissions.dart';
import 'role_dto.dart';

part 'guild_member_dto.freezed.dart';
part 'guild_member_dto.g.dart';

enum MemberType {
  @JsonValue('Default')
  standard,
  @JsonValue('Bot')
  bot,
}

@freezed
sealed class RoleMembershipDto with _$RoleMembershipDto {
  const factory RoleMembershipDto({required RoleDto role}) = _RoleMembershipDto;

  factory RoleMembershipDto.fromJson(Map<String, dynamic> json) =>
      _$RoleMembershipDtoFromJson(json);
}

@freezed
sealed class GuildMemberDto with _$GuildMemberDto {
  const factory GuildMemberDto({
    required String id,
    required String guildId,
    required String userId,
    // Backend contract change (2026-07-27): member permissions are now
    // computed from `roleMembers` rather than sent as a precomputed string —
    // this can legitimately be null/absent now.
    @Default('') String permissions,
    @Default(OnlineStatus.offline) OnlineStatus status,
    @Default(MemberType.standard) MemberType type,
    String? nickname,
    ProfileDto? profile,
    @Default(<RoleMembershipDto>[]) List<RoleMembershipDto> roleMembers,
  }) = _GuildMemberDto;

  factory GuildMemberDto.fromJson(Map<String, dynamic> json) => _$GuildMemberDtoFromJson(json);
}

extension GuildMemberEffectivePermissions on GuildMemberDto {
  /// Union of every non-`@everyone` role's permission bits, plus an
  /// automatic Superadmin bypass for the guild owner — mirrors the
  /// server's own aggregation (`GuildPermissionService`) closely enough for
  /// gating client-side UI (the server is still the source of truth on
  /// every write).
  GuildPermissions effectivePermissions(String guildOwnerId) {
    var result = GuildPermissions.none;
    for (final membership in roleMembers) {
      result = result | membership.role.permissionsValue;
    }
    if (userId == guildOwnerId) result = result | GuildPermissions.superadmin;
    return result;
  }
}
