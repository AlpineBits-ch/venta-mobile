import 'dart:async';

import '../../../core/realtime/realtime_event.dart';
import '../../../core/realtime/realtime_service.dart';
import '../../auth/data/auth_repository.dart';
import 'guild_api.dart';
import 'models/audit_log_entry_dto.dart';
import 'models/auto_mod_config_dto.dart';
import 'models/channel_follower_dto.dart';
import 'models/forum_config_dto.dart';
import 'models/forum_post_dto.dart';
import 'models/forum_tag_dto.dart';
import 'models/guild_template_dto.dart';
import 'models/onboarding_dto.dart';
import 'models/scheduled_event_dto.dart';
import 'models/welcome_screen_dto.dart';
import 'models/ban_dto.dart';
import 'models/category_dto.dart';
import 'models/channel_dto.dart';
import 'models/guild_dto.dart';
import 'models/guild_emoji_dto.dart';
import 'models/guild_features.dart';
import 'models/guild_member_dto.dart';
import 'models/guild_permissions.dart';
import 'models/guild_self_permissions.dart';
import 'models/invite_dto.dart';
import 'models/role_dto.dart';

/// REST joined-guilds list merged with realtime structural events
/// (`guild.Guild*`, `guild.Channel*`, `guild.Category*`, `guild.Thread*`,
/// `guild.Member*`, `guild.Bot*`). Same invalidate-and-refetch pattern as
/// `ConversationRepository`/`RelationshipRepository` - these events are
/// infrequent enough that a full refetch per event is simple and correct
/// rather than hand-patching nested categories/channels/roles.
class GuildRepository {
  GuildRepository({
    required this.api,
    required this.authRepository,
    required RealtimeService realtimeService,
  }) {
    _realtimeSub = realtimeService.events
        .where(
          (e) => const {
            'guild.GuildCreated',
            'guild.GuildDeleted',
            'guild.GuildUpdated',
            'guild.ChannelCreated',
            'guild.ChannelDeleted',
            'guild.ChannelUpdated',
            'guild.ChannelReordered',
            'guild.CategoryCreated',
            'guild.CategoryDeleted',
            'guild.CategoryUpdated',
            'guild.ThreadCreated',
            'guild.ThreadUpdated',
            'guild.RolesReordered',
            'guild.MemberJoined',
            'guild.MemberLeft',
            // Nickname changes - the member list and every author name in a
            // channel read from the guild, so this has to invalidate it like
            // any other membership change.
            'guild.MemberUpdated',
            'guild.MemberBanned',
            'guild.MemberKicked',
            'guild.MemberMovedOut',
            'guild.MemberMuted',
            'guild.MemberUnmuted',
            'guild.BotInstalled',
            'guild.BotUninstalled',
            'guild.EmojiCreated',
            'guild.EmojiDeleted',
          }.contains(e.name),
        )
        .listen((event) {
          final guildId = _guildIdFor(event);
          if (event.name == 'guild.EmojiCreated' ||
              event.name == 'guild.EmojiDeleted') {
            if (guildId != null) {
              unawaited(getEmojis(guildId, forceRefresh: true));
            }
            return;
          }
          // Being removed from a guild has no guild left to refetch - drop it
          // from the cache directly. Ban/kick/move-out land here too when
          // they're aimed at us; for anyone else they just restructure the
          // member list, which the refetch below picks up.
          final isSelf = event.stringField('userId') == myUserId;
          if (isSelf &&
              const {
                'guild.MemberLeft',
                'guild.MemberBanned',
                'guild.MemberKicked',
                'guild.MemberMovedOut',
              }.contains(event.name)) {
            _guilds.removeWhere((g) => g.id == guildId);
            _guildsController.add(List.unmodifiable(_guilds));
            return;
          }
          unawaited(_refreshGuild(guildId));
        });
  }

  final GuildApi api;
  final AuthRepository authRepository;
  late final StreamSubscription<RealtimeEvent> _realtimeSub;

  /// Read live off the current access token, never captured at construction:
  /// this is a lazy app-lifetime singleton, so a value baked in when it was
  /// first resolved would stay the *previous* account's id for the rest of
  /// the process - and every `isSelf` check below would then be wrong.
  String get myUserId => authRepository.currentUserId ?? '';

  final List<GuildDto> _guilds = [];
  final _guildsController = StreamController<List<GuildDto>>.broadcast();

  final Map<String, List<GuildEmojiDto>> _emojiCache = {};
  final _emojiUpdatesController =
      StreamController<
        ({String guildId, List<GuildEmojiDto> emojis})
      >.broadcast();

  Stream<List<GuildDto>> get guildsStream => _guildsController.stream;

  /// Fires whenever a guild's emoji list is (re)fetched - pickers/reaction
  /// renderers listen to keep a newly-created emoji usable without a manual
  /// refresh.
  Stream<({String guildId, List<GuildEmojiDto> emojis})> get emojiUpdates =>
      _emojiUpdatesController.stream;

  List<GuildDto> get cached => List.unmodifiable(_guilds);

  List<GuildEmojiDto>? cachedEmojis(String guildId) => _emojiCache[guildId];

  GuildDto? cachedById(String guildId) {
    for (final guild in _guilds) {
      if (guild.id == guildId) return guild;
    }
    return null;
  }

  /// Drops the joined-guild and emoji caches on a session change - see
  /// `resetSessionScopedCaches()`. Emits so the server rail empties instead
  /// of offering the previous account's guilds, which it can no longer open.
  void clear() {
    _guilds.clear();
    _emojiCache.clear();
    // The next account's list has not been fetched, whatever this one's had.
    _hasFetchedList = false;
    _guildsController.add(List.unmodifiable(_guilds));
  }

  /// Whether [fetch] has ever completed - i.e. whether [cached] is the user's
  /// *whole* guild list rather than the handful of guilds [fetchGuild] happens
  /// to have put there.
  ///
  /// The distinction matters because the cache has two writers. `fetch` fills
  /// it from `GET /guilds`; `fetchGuild` adds one guild at a time and runs
  /// from any screen that opens a guild directly - a restored deep route, an
  /// invite landing. A caller that decides "the cache isn't empty, so the list
  /// must be loaded" gets it wrong exactly then, and shows a rail with one
  /// server on it. See `AppShell`.
  bool get hasFetchedList => _hasFetchedList;
  bool _hasFetchedList = false;

  Future<List<GuildDto>> fetch() async {
    final list = await api.getGuilds();
    _hasFetchedList = true;
    _guilds
      ..clear()
      ..addAll(list);
    _guildsController.add(List.unmodifiable(_guilds));
    return _guilds;
  }

  /// Fetches one guild fresh and updates the cache - used when opening a
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

  /// Works out which guild an event belongs to.
  ///
  /// Most hub payloads carry `guildId` outright. Two don't:
  /// `guild.ChannelReordered`/`guild.RolesReordered` send a bare
  /// `Reorder*Dto` (just positions), and `guild.GuildCreated` sends a whole
  /// `GuildDto` whose id is `id`. Rather than ignore the reorder events, the
  /// owning guild is recovered from the cache via one of the ids they do
  /// carry - see the note in the class doc about the backend gap.
  String? _guildIdFor(RealtimeEvent event) {
    final direct = event.stringField('guildId');
    if (direct != null) return direct;

    if (event.name == 'guild.GuildCreated') return event.stringField('id');

    final referencedIds = switch (event.name) {
      'guild.ChannelReordered' => _idsFrom(
        event.field('channels'),
        'channelId',
      ),
      'guild.RolesReordered' => _idsFrom(event.field('roles'), 'roleId'),
      _ => const <String>[],
    };
    if (referencedIds.isEmpty) return null;

    for (final guild in _guilds) {
      final owns = event.name == 'guild.RolesReordered'
          ? guild.roles.any((r) => referencedIds.contains(r.id))
          : guild.channels.any((c) => referencedIds.contains(c.id));
      if (owns) return guild.id;
    }
    return null;
  }

  List<String> _idsFrom(Object? list, String key) {
    if (list is! List) return const [];
    return [
      for (final item in list)
        if (item is Map) ...[
          for (final entry in item.entries)
            if (entry.key.toString().toLowerCase() == key.toLowerCase() &&
                entry.value is String)
              entry.value as String,
        ],
    ];
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
      // Guild may have been deleted or we may have been removed - a full
      // fetch() next time the guild list screen opens will reconcile.
    }
  }

  Future<GuildDto> createGuild({
    required String name,
    String? description,
    GuildKind? kind,
  }) async {
    final guild = await api.createGuild(
      name: name,
      description: description,
      kind: kind,
    );
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

  Future<ChannelDto> updateChannel(
    String guildId,
    String channelId, {
    required String name,
    String? description,
    required bool isPrivate,
    required bool isAgeRestricted,
    required int slowModeSeconds,
  }) async {
    final channel = await api.updateChannel(
      channelId,
      name: name,
      description: description,
      isPrivate: isPrivate,
      isAgeRestricted: isAgeRestricted,
      slowModeSeconds: slowModeSeconds,
    );
    await _refreshGuild(guildId);
    return channel;
  }

  Future<void> deleteChannel(String guildId, String channelId) async {
    await api.deleteChannel(channelId);
    await _refreshGuild(guildId);
  }

  Future<CategoryDto> updateCategory(
    String guildId,
    String categoryId, {
    required String name,
    String? description,
  }) async {
    final category = await api.updateCategory(
      categoryId,
      name: name,
      description: description,
    );
    await _refreshGuild(guildId);
    return category;
  }

  Future<void> deleteCategory(String guildId, String categoryId) async {
    await api.deleteCategory(categoryId);
    await _refreshGuild(guildId);
  }

  Future<List<GuildMemberDto>> getMembers(
    String guildId, {
    int skip = 0,
    int take = 50,
  }) => api.getMembers(guildId, skip: skip, take: take);

  /// Exactly who can see a channel, resolved server-side against the same
  /// permission logic that gates reads. See [GuildApi.getChannelViewers] - this
  /// is the roster end-to-end encryption needs, not the guild's member list.
  Future<List<String>> getChannelViewers(String channelId) =>
      api.getChannelViewers(channelId);

  Future<GuildSelfPermissions> getOwnMember(String guildId) =>
      api.getOwnMember(guildId);

  Future<List<GuildMemberDto>> searchMembers(String guildId, String search) =>
      api.searchMembers(guildId, search);

  Future<void> kickMember(String guildId, String memberId) =>
      api.kickMember(guildId, memberId);

  /// Changing modules can add or remove whole channel types, so this refetches
  /// the guild rather than trusting the PATCH response's channel list.
  Future<GuildDto> updateGuild(
    String guildId, {
    String? name,
    String? description,
    String? systemChannelId,
    VerificationLevel? verificationLevel,
    GuildKind? kind,
    GuildFeatures? features,
  }) async {
    final updated = await api.updateGuild(
      guildId,
      name: name,
      description: description,
      systemChannelId: systemChannelId,
      verificationLevel: verificationLevel,
      kind: kind,
      features: features,
    );
    _replaceCached(updated);
    if (kind != null || features != null) await _refreshGuild(guildId);
    return updated;
  }

  /// Cache-then-fetch, like [cachedById]/[fetchGuild] - pass
  /// [forceRefresh] after a mutating call (upload/delete) or on a
  /// `guild.EmojiCreated`/`guild.EmojiDeleted` realtime event, since emoji
  /// aren't part of [GuildDto] and so don't ride along with guild refreshes.
  Future<List<GuildEmojiDto>> getEmojis(
    String guildId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _emojiCache.containsKey(guildId)) {
      return _emojiCache[guildId]!;
    }
    final emojis = await api.getEmojis(guildId);
    _emojiCache[guildId] = emojis;
    _emojiUpdatesController.add((guildId: guildId, emojis: emojis));
    return emojis;
  }

  Future<GuildEmojiDto> uploadEmoji(
    String guildId, {
    required String name,
    required bool animated,
    required List<int> bytes,
    required String fileName,
  }) async {
    final emoji = await api.uploadEmoji(
      guildId,
      name: name,
      animated: animated,
      bytes: bytes,
      fileName: fileName,
    );
    await getEmojis(guildId, forceRefresh: true);
    return emoji;
  }

  Future<void> deleteEmoji(String guildId, String emojiId) async {
    await api.deleteEmoji(guildId, emojiId);
    await getEmojis(guildId, forceRefresh: true);
  }

  Future<ChannelDto> createThread(
    String channelId, {
    required String name,
    String? content,
    List<String> tagIds = const [],
  }) =>
      api.createThread(channelId, name: name, content: content, tagIds: tagIds);

  Future<List<ChannelDto>> getThreads(String channelId) =>
      api.getThreads(channelId);

  Future<void> archiveThread(String threadId) => api.archiveThread(threadId);

  Future<List<ForumTagDto>> getForumTags(String forumChannelId) =>
      api.getForumTags(forumChannelId);

  Future<ForumTagDto> createForumTag(
    String forumChannelId, {
    required String name,
    String? emojiId,
    String? emojiName,
    String? color,
    bool moderated = false,
  }) => api.createForumTag(
    forumChannelId,
    name: name,
    emojiId: emojiId,
    emojiName: emojiName,
    color: color,
    moderated: moderated,
  );

  Future<ForumTagDto> updateForumTag(
    String tagId, {
    String? name,
    String? emojiId,
    String? emojiName,
    String? color,
    bool? moderated,
  }) => api.updateForumTag(
    tagId,
    name: name,
    emojiId: emojiId,
    emojiName: emojiName,
    color: color,
    moderated: moderated,
  );

  Future<void> deleteForumTag(String tagId) => api.deleteForumTag(tagId);

  Future<void> reorderForumTags(String forumChannelId, List<String> tagIds) =>
      api.reorderForumTags(forumChannelId, tagIds);

  Future<ForumConfigDto> getForumConfig(String forumChannelId) =>
      api.getForumConfig(forumChannelId);

  Future<ForumConfigDto> updateForumConfig(
    String forumChannelId, {
    bool? requireTag,
    ForumSortOrder? defaultSortOrder,
    ForumLayout? defaultLayout,
    String? defaultReactionEmojiId,
    String? defaultReactionEmojiName,
    int? defaultThreadSlowModeSeconds,
    int? defaultAutoArchiveMinutes,
  }) => api.updateForumConfig(
    forumChannelId,
    requireTag: requireTag,
    defaultSortOrder: defaultSortOrder,
    defaultLayout: defaultLayout,
    defaultReactionEmojiId: defaultReactionEmojiId,
    defaultReactionEmojiName: defaultReactionEmojiName,
    defaultThreadSlowModeSeconds: defaultThreadSlowModeSeconds,
    defaultAutoArchiveMinutes: defaultAutoArchiveMinutes,
  );

  Future<ForumPostPageDto> getForumPosts(
    String forumChannelId, {
    List<String> tagIds = const [],
    bool matchAll = false,
    ForumSortOrder? sort,
    ForumArchiveFilter archived = ForumArchiveFilter.active,
    int limit = 25,
    String? cursor,
  }) => api.getForumPosts(
    forumChannelId,
    tagIds: tagIds,
    matchAll: matchAll,
    sort: sort,
    archived: archived,
    limit: limit,
    cursor: cursor,
  );

  Future<ForumPostDto> setPostTags(String threadId, List<String> tagIds) =>
      api.setPostTags(threadId, tagIds);

  Future<void> setPostPinned(String threadId, bool pinned) =>
      api.setPostPinned(threadId, pinned);

  Future<void> setPostLocked(String threadId, bool locked) =>
      api.setPostLocked(threadId, locked);

  Future<GuildDto> uploadGuildIcon(
    String guildId, {
    required List<int> bytes,
    required String fileName,
  }) async {
    final updated = await api.uploadGuildIcon(
      guildId,
      bytes: bytes,
      fileName: fileName,
    );
    _replaceCached(updated);
    return updated;
  }

  Future<GuildDto> deleteGuildIcon(String guildId) async {
    final updated = await api.deleteGuildIcon(guildId);
    _replaceCached(updated);
    return updated;
  }

  Future<void> deleteGuild(String guildId) async {
    await api.deleteGuild(guildId);
    _guilds.removeWhere((g) => g.id == guildId);
    _guildsController.add(List.unmodifiable(_guilds));
  }

  String guildIconUrl(String guildId) => api.guildIconUrl(guildId);

  Future<RoleDto> createRole({
    required String guildId,
    required String name,
    String? description,
    String? color,
    GuildPermissions? permissions,
  }) async {
    final role = await api.createRole(
      guildId: guildId,
      name: name,
      description: description,
      color: color,
      permissions: permissions,
    );
    await _refreshGuild(guildId);
    return role;
  }

  /// Answers with the saved role as the guild now reports it - the PATCH itself
  /// returns no body, so the refresh below is the only place the new values can
  /// come from. Null only if the role vanished between the two calls.
  Future<RoleDto?> updateRole({
    required String guildId,
    required String roleId,
    required String name,
    String? description,
    String? color,
    required GuildPermissions permissions,
  }) async {
    await api.updateRole(
      roleId: roleId,
      name: name,
      description: description,
      color: color,
      permissions: permissions,
    );
    await _refreshGuild(guildId);
    for (final role in cachedById(guildId)?.roles ?? const <RoleDto>[]) {
      if (role.id == roleId) return role;
    }
    return null;
  }

  Future<void> deleteRole(String guildId, String roleId) async {
    await api.deleteRole(roleId);
    await _refreshGuild(guildId);
  }

  Future<void> reorderRoles(
    String guildId,
    List<({String roleId, int position})> positions,
  ) async {
    await api.reorderRoles(guildId, positions);
    await _refreshGuild(guildId);
  }

  Future<void> reorderChannels(
    String guildId, {
    List<({String channelId, int position, String? categoryId})> channels =
        const [],
    List<({String categoryId, int position})> categories = const [],
  }) async {
    await api.reorderChannels(
      guildId,
      channels: channels,
      categories: categories,
    );
    await _refreshGuild(guildId);
  }

  /// Resolves the join rows [GuildApi.getRoleMembers] returns to the members
  /// themselves. A row the server didn't project a `member` onto is matched
  /// against the guild's member list rather than dropped, so the caller never
  /// quietly under-reports who holds a role.
  Future<List<GuildMemberDto>> getRoleMembers(
    String guildId,
    String roleId, {
    int skip = 0,
    int take = 30,
  }) async {
    final rows = await api.getRoleMembers(roleId, skip: skip, take: take);
    if (rows.every((row) => row.member != null)) {
      return [for (final row in rows) row.member!];
    }
    final members = await api.getMembers(guildId, take: 200);
    final byId = {for (final member in members) member.id: member};
    return [for (final row in rows) ?(row.member ?? byId[row.memberId])];
  }

  Future<void> addRoleMember(String roleId, String memberId) =>
      api.addRoleMember(roleId, memberId);

  Future<void> removeRoleMember(String roleId, String memberId) =>
      api.removeRoleMember(roleId, memberId);

  Future<List<BanDto>> getBans(String guildId) => api.getBans(guildId);

  Future<void> createBan(
    String guildId, {
    required String userId,
    String? reason,
  }) => api.createBan(guildId, userId: userId, reason: reason);

  Future<void> deleteBan(String guildId, String bannedUserId) =>
      api.deleteBan(guildId, bannedUserId);

  Future<AutoModConfigDto> getAutoMod(String guildId) =>
      api.getAutoMod(guildId);

  Future<AutoModConfigDto> updateAutoMod(
    String guildId,
    AutoModConfigDto config,
  ) => api.updateAutoMod(guildId, config);

  Future<void> followChannel({
    required String sourceChannelId,
    required String targetChannelId,
  }) => api.followChannel(
    sourceChannelId: sourceChannelId,
    targetChannelId: targetChannelId,
  );

  Future<List<ChannelFollowerDto>> getFollowers(String sourceChannelId) =>
      api.getFollowers(sourceChannelId);

  Future<void> unfollowChannel({
    required String sourceChannelId,
    required String followId,
  }) =>
      api.unfollowChannel(sourceChannelId: sourceChannelId, followId: followId);

  Future<List<ScheduledEventDto>> getEvents(String guildId) =>
      api.getEvents(guildId);

  Future<ScheduledEventDto> createEvent(
    String guildId, {
    required String title,
    String? description,
    required DateTime startsAt,
    DateTime? endsAt,
    String? location,
    String? voiceChannelId,
  }) => api.createEvent(
    guildId,
    title: title,
    description: description,
    startsAt: startsAt,
    endsAt: endsAt,
    location: location,
    voiceChannelId: voiceChannelId,
  );

  Future<ScheduledEventDto> updateEvent(
    String eventId, {
    String? title,
    String? description,
    DateTime? startsAt,
    DateTime? endsAt,
    String? location,
    String? voiceChannelId,
  }) => api.updateEvent(
    eventId,
    title: title,
    description: description,
    startsAt: startsAt,
    endsAt: endsAt,
    location: location,
    voiceChannelId: voiceChannelId,
  );

  Future<void> cancelEvent(String eventId) => api.cancelEvent(eventId);

  Future<void> markEventInterested(String eventId) =>
      api.markEventInterested(eventId);

  Future<void> removeEventInterest(String eventId) =>
      api.removeEventInterest(eventId);

  Future<GuildTemplateDto> createTemplate(
    String guildId, {
    required String name,
    String? description,
  }) => api.createTemplate(guildId, name: name, description: description);

  Future<GuildTemplateDetailDto> getTemplate(String templateId) =>
      api.getTemplate(templateId);

  Future<GuildDto> useTemplate(
    String templateId, {
    required String name,
    String? description,
  }) => api.useTemplate(templateId, name: name, description: description);

  Future<OnboardingConfigDto> getOnboarding(String guildId) =>
      api.getOnboarding(guildId);

  Future<OnboardingConfigDto> updateOnboarding(
    String guildId,
    OnboardingConfigDto config,
  ) => api.updateOnboarding(guildId, config);

  Future<OnboardingStatusDto> getOwnOnboardingStatus(String guildId) =>
      api.getOwnOnboardingStatus(guildId);

  /// Accepting grants roles and channel overwrites, so the guild is refetched
  /// afterwards - the member may now see channels that weren't in the cached
  /// copy at all.
  Future<void> acceptOnboarding(
    String guildId, {
    List<OnboardingResponseDto> responses = const [],
  }) async {
    await api.acceptOnboarding(guildId, responses: responses);
    await _refreshGuild(guildId);
  }

  Future<List<OnboardingPromptDto>> getOnboardingPrompts(String guildId) =>
      api.getOnboardingPrompts(guildId);

  /// Same visibility consequences as [acceptOnboarding], in both directions:
  /// deselecting an option revokes the channels it granted.
  Future<void> updateOwnOnboardingResponses(
    String guildId,
    List<OnboardingResponseDto> responses,
  ) async {
    await api.updateOwnOnboardingResponses(guildId, responses);
    await _refreshGuild(guildId);
  }

  Future<WelcomeScreenDto> getWelcomeScreen(String guildId) =>
      api.getWelcomeScreen(guildId);

  Future<WelcomeScreenDto> updateWelcomeScreen(
    String guildId,
    WelcomeScreenDto screen,
  ) => api.updateWelcomeScreen(guildId, screen);

  Future<List<PendingMemberDto>> getPendingMembers(
    String guildId, {
    int limit = 100,
    int offset = 0,
  }) => api.getPendingMembers(guildId, limit: limit, offset: offset);

  Future<List<AuditLogEntryDto>> getAuditLog(
    String guildId, {
    int skip = 0,
    int take = 50,
  }) => api.getAuditLog(guildId, skip: skip, take: take);

  Future<List<InviteDto>> getInvites(String guildId) => api.getInvites(guildId);

  Future<void> deleteInvite(String inviteId) => api.deleteInvite(inviteId);

  void _replaceCached(GuildDto updated) {
    final index = _guilds.indexWhere((g) => g.id == updated.id);
    if (index == -1) {
      _guilds.add(updated);
    } else {
      _guilds[index] = updated;
    }
    _guildsController.add(List.unmodifiable(_guilds));
  }

  Future<InviteDto> createInvite(
    String guildId, {
    String? channelId,
    InviteType type = InviteType.permanent,
  }) => api.createInvite(guildId: guildId, channelId: channelId, type: type);

  Future<InviteDto> previewInvite(String code) => api.getInviteByCode(code);

  /// Where the guild's icon image lives - see [GuildApi.iconUrl] for why this
  /// is built from the id rather than read off `GuildDto.iconUrl`.
  String iconUrl(String guildId) => api.iconUrl(guildId);

  /// Redeems the invite, then refetches the guild list so callers can
  /// navigate straight to the guild they just joined.
  ///
  /// The list refetch alone is not enough to land on. Whether it comes back
  /// carrying the new guild depends on the join being visible to the query
  /// that serves it, and a caller that navigates on the assumption it is gets
  /// a guild the rail doesn't list and the cache doesn't hold. So the guild is
  /// fetched by id afterwards regardless, through [fetchGuild] rather than the
  /// api directly - that is what puts it in the cache and emits it, which is
  /// what the rail and the guild screen are both reading.
  ///
  /// That read is retried, because the join being *done* and the join being
  /// *readable* are not the same instant: the membership row is what
  /// `GET /guilds/{id}` authorizes against, and for the first moments after
  /// redeeming, that check can still answer as though this account had never
  /// joined (a `403`) or hand back the guild without its channels. One attempt
  /// therefore decided the whole landing: a caller that got the early answer
  /// either reported a join that had actually succeeded as a failure, or
  /// navigated to a server with no name and no channels in it. Retried here
  /// rather than at the screen so every entry point - the invite popup, the
  /// rail's Join sheet - gets the same behaviour.
  Future<GuildDto> redeemInvite(String code) async {
    final invite = await api.getInviteByCode(code);
    await api.redeemInvite(invite.id);
    await fetch();
    return fetchJoinedGuild(invite.guildId);
  }

  /// [fetchGuild] with the just-joined guild's read-visibility lag absorbed:
  /// retries while the read fails outright, and while it answers with a guild
  /// that carries neither channels nor categories, which is what a membership
  /// the read side can't see yet looks like when it doesn't 403.
  ///
  /// Settles for whatever the last attempt produced rather than throwing on a
  /// guild that really is empty - a server whose channels have all been deleted
  /// is a real, if unusual, state, and the join itself has already succeeded by
  /// the time this runs.
  Future<GuildDto> fetchJoinedGuild(String guildId) async {
    const delays = [
      Duration(milliseconds: 250),
      Duration(milliseconds: 600),
      Duration(milliseconds: 1200),
    ];
    Object? lastError;
    for (var attempt = 0; attempt <= delays.length; attempt++) {
      if (attempt > 0) await Future<void>.delayed(delays[attempt - 1]);
      try {
        final guild = await fetchGuild(guildId);
        if (guild.channels.isNotEmpty || guild.categories.isNotEmpty) {
          return guild;
        }
        lastError = null;
        if (attempt == delays.length) return guild;
      } catch (e) {
        lastError = e;
      }
    }
    // Every attempt failed. The join stands, but nothing readable came back -
    // let the caller decide what to say about it.
    throw lastError ??
        StateError('Could not read guild $guildId after joining');
  }

  void dispose() {
    _realtimeSub.cancel();
    _guildsController.close();
    _emojiUpdatesController.close();
  }
}
