import 'package:freezed_annotation/freezed_annotation.dart';

import 'guild_permissions.dart';

part 'role_dto.freezed.dart';
part 'role_dto.g.dart';

/// What a role with no colour of its own is written as on the wire.
///
/// `color` is **not** nullable server-side: both role request DTOs type it as
/// a plain `string` and the column is `NOT NULL`, so sending `null` gets as
/// far as the save and fails there - a 500 that reads to the user as "could
/// not create role". Every write goes through this default instead. The value
/// is the neutral grey a role carries until someone picks a colour, which
/// stays legible on both themes (unlike the server-side `#000000` default).
const defaultRoleColor = '#99AAB5';

enum RoleType {
  @JsonValue('None')
  none,
  @JsonValue('Everyone')
  everyone,
}

@freezed
sealed class RoleDto with _$RoleDto {
  const factory RoleDto({
    required String id,
    required String name,
    String? description,
    String? color,
    required String guildId,
    required String permissions,
    @Default(RoleType.none) RoleType type,
    @Default(0) int position,
  }) = _RoleDto;

  factory RoleDto.fromJson(Map<String, dynamic> json) =>
      _$RoleDtoFromJson(json);
}

extension RoleDtoX on RoleDto {
  GuildPermissions get permissionsValue => GuildPermissions.parse(permissions);
}
