import '../../../core/di/injector.dart';
import '../../guilds/data/guild_repository.dart';
import '../../guilds/data/models/guild_permissions.dart';

/// Loads the caller's effective wiki (and other) permissions for a guild —
/// shared by every wiki screen so each one gates its own actions
/// consistently, mirroring `GuildDetailScreen._loadOwnPermissions`.
Future<GuildPermissions> loadGuildPermissions(String guildId) async {
  final repository = getIt<GuildRepository>();
  final guild =
      repository.cachedById(guildId) ?? await repository.fetchGuild(guildId);
  final self = await repository.getOwnMember(guildId);
  return self.effectivePermissions(guild.ownerId);
}
