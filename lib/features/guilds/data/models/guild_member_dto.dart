import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../profile/data/models/profile_dto.dart';
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
