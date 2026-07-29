import 'package:freezed_annotation/freezed_annotation.dart';

import 'guild_permissions.dart';

part 'role_dto.freezed.dart';
part 'role_dto.g.dart';

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
