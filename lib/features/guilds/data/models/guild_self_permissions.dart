import 'guild_permissions.dart';

/// Result of `GET /guilds/{id}/me` — deliberately NOT parsed through
/// [GuildMemberDto]/[RoleDto]. That endpoint serializes via the backend's
/// `SelfMemberDto`/`FlatRoleDto` (see `Guild.Application/Dtos/Response/
/// MemberDto.cs` and `RoleMemberDto.cs`), whose nested role objects only
/// carry `id`/`createdAt`/`updatedAt`/`permissions` — no `name` or
/// `guildId`, both `required` on [RoleDto] — so decoding through the normal
/// model throws. Only `permissions` is actually needed here, so this hand-
/// parses just that instead of widening [RoleDto] to accommodate a shape
/// used nowhere else.
class GuildSelfPermissions {
  const GuildSelfPermissions({required this.userId, required this.permissions});

  final String userId;
  final GuildPermissions permissions;

  factory GuildSelfPermissions.fromJson(Map<String, dynamic> json) {
    var permissions = GuildPermissions.none;
    for (final raw in (json['roleMembers'] as List?) ?? const []) {
      final role = (raw as Map<String, dynamic>)['role'] as Map<String, dynamic>?;
      final wire = role?['permissions'] as String?;
      if (wire != null) permissions = permissions | GuildPermissions.parse(wire);
    }
    return GuildSelfPermissions(userId: json['userId'] as String, permissions: permissions);
  }

  /// [permissions] plus an automatic Superadmin bypass when this is the
  /// guild owner — mirrors [GuildMemberEffectivePermissions.effectivePermissions].
  GuildPermissions effectivePermissions(String guildOwnerId) =>
      userId == guildOwnerId ? permissions | GuildPermissions.superadmin : permissions;
}
