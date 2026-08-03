import '../../../../core/format/api_date_time.dart';
import 'guild_permissions.dart';

/// Result of `GET /guilds/{id}/me` - deliberately NOT parsed through
/// [GuildMemberDto]/[RoleDto]. That endpoint serializes via the backend's
/// `SelfMemberDto`/`FlatRoleDto` (see `Guild.Application/Dtos/Response/
/// MemberDto.cs` and `RoleMemberDto.cs`), whose nested role objects only
/// carry `id`/`createdAt`/`updatedAt`/`permissions` - no `name` or
/// `guildId`, both `required` on [RoleDto] - so decoding through the normal
/// model throws. Only `permissions` is actually needed here, so this hand-
/// parses just that instead of widening [RoleDto] to accommodate a shape
/// used nowhere else.
///
/// This response still carries a `readState` array, and it is deliberately not
/// read for mention counts any more: `readState[].mentionCount` is always `0`
/// as of the 2026-08-03 inbox release. It used to be a stored counter bumped
/// per mention, which stopped being possible once an `@everyone` became one row
/// rather than one per member - and it was never idempotent anyway (a retried
/// message doubled it, a deleted one left it high). Counts are computed on read
/// now and live on the inbox endpoints: `GET /inbox/summary` for the total,
/// `GET /inbox/unread` for per-channel. See `InboxRepository.unreadByChannel`,
/// which is what seeds the channel-list badges.
///
/// The field is still in the JSON and still an int, so nothing failed to
/// deserialise - it just quietly stopped being a number. Parsing it here would
/// compile, run, and silently show every channel as having no mentions.
class GuildSelfPermissions {
  const GuildSelfPermissions({required this.userId, required this.permissions});

  final String userId;
  final GuildPermissions permissions;

  factory GuildSelfPermissions.fromJson(Map<String, dynamic> json) {
    var permissions = GuildPermissions.none;
    for (final raw in (json['roleMembers'] as List?) ?? const []) {
      final membership = raw as Map<String, dynamic>;
      // A guest grant is still listed for about a week after it lapses, but
      // stopped granting anything the instant it expired - so a UI built from
      // this would otherwise keep offering the pet sitter buttons that now
      // 403.
      final expiresAt = tryParseApiDateTime(membership['expiresAt']);
      if (expiresAt != null && expiresAt.isBefore(DateTime.now().toUtc())) {
        continue;
      }
      final role = membership['role'] as Map<String, dynamic>?;
      final wire = role?['permissions'] as String?;
      if (wire != null)
        permissions = permissions | GuildPermissions.parse(wire);
    }
    return GuildSelfPermissions(
      userId: json['userId'] as String,
      permissions: permissions,
    );
  }

  /// [permissions] plus an automatic Superadmin bypass when this is the
  /// guild owner - mirrors [GuildMemberEffectivePermissions.effectivePermissions].
  GuildPermissions effectivePermissions(String guildOwnerId) =>
      userId == guildOwnerId
      ? permissions | GuildPermissions.superadmin
      : permissions;
}
