import 'dart:async';

import '../../../core/realtime/realtime_event.dart';
import '../../../core/realtime/realtime_service.dart';
import 'guild_api.dart';
import 'models/category_dto.dart';
import 'models/channel_dto.dart';
import 'models/guild_dto.dart';
import 'models/guild_member_dto.dart';
import 'models/invite_dto.dart';

/// REST joined-guilds list merged with realtime structural events
/// (`guild.GuildDeleted/Updated`, `guild.ChannelCreated/Deleted/Updated`,
/// `guild.CategoryCreated/Deleted`, `guild.MemberJoined/Left` for the
/// current user leaving/joining). Same invalidate-and-refetch pattern as
/// `ConversationRepository`/`RelationshipRepository` — these events are
/// infrequent enough that a full refetch per event is simple and correct
/// rather than hand-patching nested categories/channels/roles.
class GuildRepository {
  GuildRepository({required this.api, required RealtimeService realtimeService, required this.myUserId}) {
    _realtimeSub = realtimeService.events
        .where(
          (e) => const {
            'guild.GuildDeleted',
            'guild.GuildUpdated',
            'guild.ChannelCreated',
            'guild.ChannelDeleted',
            'guild.ChannelUpdated',
            'guild.CategoryCreated',
            'guild.CategoryDeleted',
            'guild.MemberJoined',
            'guild.MemberLeft',
          }.contains(e.name),
        )
        .listen((event) {
      if (event.name == 'guild.MemberLeft' && event.objectPayload['userId'] == myUserId) {
        _guilds.removeWhere((g) => g.id == event.objectPayload['guildId']);
        _guildsController.add(List.unmodifiable(_guilds));
        return;
      }
      unawaited(_refreshGuild(event.objectPayload['guildId'] as String?));
    });
  }

  final GuildApi api;
  final String myUserId;
  late final StreamSubscription<RealtimeEvent> _realtimeSub;

  final List<GuildDto> _guilds = [];
  final _guildsController = StreamController<List<GuildDto>>.broadcast();

  Stream<List<GuildDto>> get guildsStream => _guildsController.stream;
  List<GuildDto> get cached => List.unmodifiable(_guilds);

  GuildDto? cachedById(String guildId) {
    for (final guild in _guilds) {
      if (guild.id == guildId) return guild;
    }
    return null;
  }

  Future<List<GuildDto>> fetch() async {
    final list = await api.getGuilds();
    _guilds
      ..clear()
      ..addAll(list);
    _guildsController.add(List.unmodifiable(_guilds));
    return _guilds;
  }

  /// Fetches one guild fresh and updates the cache — used when opening a
  /// guild's channel list, where we want the latest data, not last-known.
  Future<GuildDto> fetchGuild(String guildId) async {
    final updated = await api.getGuild(guildId);
    final index = _guilds.indexWhere((g) => g.id == guildId);
    if (index == -1) {
      _guilds.add(updated);
    } else {
      _guilds[index] = updated;
    }
    _guildsController.add(List.unmodifiable(_guilds));
    return updated;
  }

  Future<void> _refreshGuild(String? guildId) async {
    if (guildId == null) return;
    try {
      final updated = await api.getGuild(guildId);
      final index = _guilds.indexWhere((g) => g.id == guildId);
      if (index == -1) {
        _guilds.add(updated);
      } else {
        _guilds[index] = updated;
      }
      _guildsController.add(List.unmodifiable(_guilds));
    } catch (_) {
      // Guild may have been deleted or we may have been removed — a full
      // fetch() next time the guild list screen opens will reconcile.
    }
  }

  Future<GuildDto> createGuild({required String name, String? description}) async {
    final guild = await api.createGuild(name: name, description: description);
    await fetch();
    return guild;
  }

  Future<void> leaveGuild(String guildId) async {
    await api.leaveGuild(guildId);
    _guilds.removeWhere((g) => g.id == guildId);
    _guildsController.add(List.unmodifiable(_guilds));
  }

  Future<ChannelDto> createChannel({
    required String guildId,
    required String name,
    String? description,
    ChannelType type = ChannelType.text,
    String? categoryId,
  }) async {
    final guild = cachedById(guildId);
    final position = guild?.channels.length ?? 0;
    final channel = await api.createChannel(
      guildId: guildId,
      name: name,
      description: description,
      type: type,
      categoryId: categoryId,
      position: position,
    );
    await _refreshGuild(guildId);
    return channel;
  }

  Future<CategoryDto> createCategory({
    required String guildId,
    required String name,
    String? description,
  }) async {
    final guild = cachedById(guildId);
    final position = guild?.categories.length ?? 0;
    final category = await api.createCategory(
      guildId: guildId,
      name: name,
      description: description,
      position: position,
    );
    await _refreshGuild(guildId);
    return category;
  }

  Future<List<GuildMemberDto>> getMembers(String guildId, {int skip = 0, int take = 50}) =>
      api.getMembers(guildId, skip: skip, take: take);

  Future<InviteDto> createInvite(String guildId, {String? channelId}) =>
      api.createInvite(guildId: guildId, channelId: channelId);

  Future<InviteDto> previewInvite(String code) => api.getInviteByCode(code);

  /// Redeems the invite, then refetches the guild list (which now includes
  /// the newly-joined guild) so callers can navigate straight to it.
  Future<GuildDto> redeemInvite(String code) async {
    final invite = await api.getInviteByCode(code);
    await api.redeemInvite(invite.id);
    await fetch();
    return cachedById(invite.guildId) ?? await api.getGuild(invite.guildId);
  }

  void dispose() {
    _realtimeSub.cancel();
    _guildsController.close();
  }
}
