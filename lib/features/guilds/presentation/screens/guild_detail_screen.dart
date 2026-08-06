import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/realtime/realtime_event.dart';
import '../../../../core/realtime/realtime_service.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/profile_resolver.dart';
import '../../../../core/widgets/skeleton_list_tile.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../guild_voice/bloc/guild_voice_cubit.dart';
import '../../../guild_voice/presentation/screens/guild_voice_screen.dart';
import '../../../household/presentation/widgets/home_digest_card.dart';
import '../../../household/presentation/widgets/home_status_board.dart';
import '../../../inbox/data/inbox_repository.dart';
import '../../../inbox/presentation/widgets/inbox_app_bar_action.dart';
import '../../../support/data/models/report_dto.dart';
import '../../../support/presentation/widgets/report_sheet.dart';
import '../../data/forum_visits.dart';
import '../../data/guild_repository.dart';
import '../../data/models/category_dto.dart';
import '../../data/models/channel_dto.dart';
import '../../data/models/guild_dto.dart';
import '../../data/models/guild_features.dart';
import '../../data/models/guild_permissions.dart';
import '../../data/models/onboarding_dto.dart';
import '../widgets/channel_type_icon.dart';
import 'onboarding_wizard_screen.dart';

/// Per-channel read state tracked locally in [_GuildDetailScreenState] -
/// [isUnread] drives the bold channel-name styling, [mentionCount] the red
/// badge, mirroring Alpine's `GuildReadStateService`/`ChannelReadState`.
///
/// Seeded from the inbox rather than from `GET /guilds/{id}/me`: the
/// `readState[].mentionCount` this used to read has been zeroed permanently
/// (see `GuildSelfPermissions`), and kept live from `guild.MessageCreated`
/// after that.
typedef _ChannelReadState = ({bool isUnread, int mentionCount});

/// Content pane shown inside `AppShell` when a server is selected from the
/// rail - categories/channels for that guild. Tapping a channel pushes the
/// full-screen `ChannelScreen` (outside the shell); the rail stays visible
/// here the whole time, matching Discord mobile.
class GuildDetailScreen extends StatefulWidget {
  const GuildDetailScreen({super.key, required this.guildId});

  final String guildId;

  @override
  State<GuildDetailScreen> createState() => _GuildDetailScreenState();
}

class _GuildDetailScreenState extends State<GuildDetailScreen> {
  GuildDto? _guild;
  GuildPermissions _permissions = GuildPermissions.none;
  Map<String, _ChannelReadState> _unread = {};
  late final StreamSubscription<RealtimeEvent> _messageSub;

  /// This member's onboarding state, when the guild has onboarding at all.
  OnboardingStatusDto? _onboarding;

  /// The wizard opens itself once per visit to this screen; after that the
  /// banner is the way back in, so re-entering a channel doesn't relaunch it.
  bool _onboardingShown = false;

  /// Whether the guild has any onboarding prompts - the Channels & Roles entry
  /// only makes sense when there's something to pick.
  bool _hasSelfServePrompts = false;

  bool get _onboardingPending =>
      (_onboarding?.enabled ?? false) && !(_onboarding?.completed ?? true);

  @override
  void initState() {
    super.initState();
    _load();
    // Opening a post happens on a screen pushed over this one, so the nested
    // post rows have to update from underneath rather than on the next build.
    ForumVisits.revision.addListener(_onVisitsChanged);
    final myUserId = getIt<AuthRepository>().currentUserId;
    _messageSub = getIt<RealtimeService>().events
        .where((e) => e.name == 'guild.MessageCreated')
        .listen((event) {
          final payload = event.objectPayload;
          final channelId = payload['channelId'] as String?;
          if (channelId == null || payload['authorId'] == myUserId) return;
          if (!(_guild?.channels.any((c) => c.id == channelId) ?? false)) {
            return;
          }
          final mentioned =
              (payload['mentions'] as List?)?.contains(myUserId) ?? false;
          setState(() {
            final current = _unread[channelId];
            _unread = {
              ..._unread,
              channelId: (
                isUnread: true,
                mentionCount:
                    (current?.mentionCount ?? 0) + (mentioned ? 1 : 0),
              ),
            };
          });
        });
  }

  /// Whether a response that was requested for [guildId] should still be
  /// allowed to touch this screen's state.
  ///
  /// This `State` is reused when the rail switches guilds (see
  /// [didUpdateWidget]), so a slow fetch for the guild you just left resolves
  /// *after* the fast one for the guild you're now on and would otherwise
  /// overwrite it - you tap a big server, tap back to a small one, and a
  /// second later the big server's channels reappear under the small one's
  /// rail selection. Every `await` below has to re-check this, not just
  /// [mounted].
  bool _isStale(String guildId) => !mounted || widget.guildId != guildId;

  Future<void> _loadOwnPermissions(String guildId, String ownerId) async {
    try {
      final self = await getIt<GuildRepository>().getOwnMember(guildId);
      if (_isStale(guildId)) return;
      setState(() => _permissions = self.effectivePermissions(ownerId));
    } catch (_) {
      // Leave permission-gated entries hidden - they're still enforced
      // server-side on every write regardless.
    }
  }

  /// Seeds the channel-list badges from the inbox.
  ///
  /// Separate from [_loadOwnPermissions], which is where this used to live: the
  /// two now come from different services, and a `/me` that 500s must not also
  /// take the badges down with it (nor the reverse). Failure here leaves the
  /// list unbadged rather than blocking it - the live
  /// `guild.MessageCreated` handler still fills it in from this point on.
  Future<void> _loadUnread(String guildId) async {
    try {
      final counts = await getIt<InboxRepository>().unreadByChannel(
        guildId: guildId,
      );
      if (_isStale(guildId)) return;
      setState(() {
        _unread = {
          for (final entry in counts.entries)
            entry.key: (isUnread: true, mentionCount: entry.value.mentionCount),
        };
      });
    } catch (_) {
      // No badges beats wrong badges, and this is not worth a visible error.
    }
  }

  /// Clears the badge here and acks the channel server-side.
  ///
  /// The ack is new: `POST /inbox/channels/{id}/read` is a real endpoint now,
  /// where this used to be local-only and the badge came back on the next
  /// launch. Fire-and-forget on purpose - the row is already gone from a map
  /// that is rebuilt from the server on every open, so a failed write costs a
  /// badge reappearing rather than anything the caller needs to hear about.
  void _markChannelRead(String channelId) {
    final mentionCount = _unread[channelId]?.mentionCount ?? 0;
    setState(() => _unread = {..._unread}..remove(channelId));
    unawaited(
      getIt<InboxRepository>()
          .markChannelRead(channelId, mentionCount: mentionCount)
          .catchError((Object e, StackTrace st) {
            debugPrint('mark channel read failed: $e\n$st');
          }),
    );
  }

  Future<void> _showChannelActions(ChannelDto channel) async {
    // Everything in this sheet is either about messages or about managing the
    // channel - for a household channel you can't manage, there's nothing in
    // it, and an empty sheet sliding up is worse than nothing happening.
    if (!channel.type.hasMessages && !_permissions.has('ManageChannel')) return;
    final action = await showModalBottomSheet<String>(
      context: context,
      // The shell's nav rail lives in a sibling of this screen's own
      // Navigator (see `AppShell`) - without this the sheet is clipped to
      // just the content pane instead of covering the whole device width.
      useRootNavigator: true,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            // Read state, muting and notification settings are all about
            // messages, and a List/Chores/Ledger/Pantry/Decisions channel
            // doesn't have any.
            if (channel.type.hasMessages) ...[
              ListTile(
                leading: const Icon(Icons.done_all),
                title: const Text('Mark as read'),
                onTap: () => Navigator.pop(context, 'read'),
              ),
              ListTile(
                leading: const Icon(Icons.notifications_off_outlined),
                title: const Text('Mute'),
                onTap: () => Navigator.pop(context, 'mute'),
              ),
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('Notification settings'),
                onTap: () => Navigator.pop(context, 'notifications'),
              ),
            ],
            if (_permissions.has('ManageChannel'))
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Edit channel'),
                onTap: () => Navigator.pop(context, 'edit'),
              ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case 'read':
        _markChannelRead(channel.id);
      case 'mute':
      case 'notifications':
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Not available yet.')));
      case 'edit':
        context.push(
          RoutePaths.serverChannelSettingsPath(widget.guildId, channel.id),
        );
    }
  }

  /// Reports the server itself.
  ///
  /// The account being reported is the owner - the server has no account of its
  /// own, and `targetUserId` is required on every report. No snapshot goes with
  /// it: there is no one conversation a server report is about, and attaching
  /// an arbitrary channel's last ten messages would upload something the
  /// reporter never chose. Blocking isn't offered afterwards either - blocking
  /// whoever happens to own a server is not what someone reporting it is asking
  /// for, and it wouldn't get them out of the server.
  Future<void> _reportGuild(GuildDto guild) async {
    await showReportSheet(
      context,
      ReportTarget(
        targetUserId: guild.ownerId,
        subjectKind: ReportSubjectKind.guild,
        subjectId: guild.id,
        title: 'Report ${guild.name}',
        offerBlock: false,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant GuildDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.guildId == widget.guildId) return;
    // Every field below describes the guild we just left. Dropping them now
    // means the switch shows this guild's own skeleton rather than the
    // previous one's channels and badges, and lets the new guild's onboarding
    // wizard open even if the last one's already had.
    //
    // No flicker when the new guild is cached: `_load` writes the cached guild
    // synchronously before its first `await`, so both `setState`s land in the
    // same frame.
    setState(() {
      _guild = null;
      _permissions = GuildPermissions.none;
      _unread = {};
      _onboarding = null;
      _hasSelfServePrompts = false;
      _onboardingShown = false;
    });
    _load();
  }

  @override
  void dispose() {
    _messageSub.cancel();
    ForumVisits.revision.removeListener(_onVisitsChanged);
    super.dispose();
  }

  void _onVisitsChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    // Captured once: `widget.guildId` can change under this method while the
    // fetch below is in flight, and every write here belongs to the guild the
    // load was started for.
    final guildId = widget.guildId;
    final repository = getIt<GuildRepository>();
    final cached = repository.cachedById(guildId);
    // Painting the cache first is only worth doing when there is something to
    // paint. A cached guild carrying no channels *and* no categories renders
    // as a blank sidebar that is indistinguishable from "this server is
    // empty" - which is a worse thing to show for the second it takes the
    // fetch below to answer than the skeleton is, and it is exactly what a
    // guild you have just joined looks like if it reached the cache before
    // its contents did.
    final cacheIsPaintable =
        cached != null &&
        (cached.channels.isNotEmpty || cached.categories.isNotEmpty);
    if (cached != null && cacheIsPaintable && !_isStale(guildId)) {
      setState(() => _guild = cached);
      _hydrateVoiceRosters(cached);
      unawaited(_loadOwnPermissions(guildId, cached.ownerId));
    }
    try {
      final guild = await repository.fetchGuild(guildId);
      if (_isStale(guildId)) return;
      setState(() => _guild = guild);
      _hydrateVoiceRosters(guild);
      unawaited(_loadOwnPermissions(guildId, guild.ownerId));
    } catch (_) {
      // Keep whatever was cached; the realtime-driven refetch will retry.
    }
    if (_isStale(guildId)) return;
    unawaited(_checkOnboarding(guildId));
    // Detached and last: badges are the least of what this screen is for, and
    // nothing above waits on them.
    unawaited(_loadUnread(guildId));
  }

  /// Cheap enough to call on every guild-open per the backend guide.
  ///
  /// Gated on `enabled` as well as `completed`: a member who joined while
  /// onboarding was on and had it switched off underneath them reads as
  /// `completed: false` forever, and is not actually restricted - showing them
  /// a rules screen they can't get rid of was exactly the bug `enabled` was
  /// added to fix.
  Future<void> _checkOnboarding(String guildId) async {
    final repository = getIt<GuildRepository>();
    // Onboarding is a module: with it off there is no rules gate, no prompts
    // and no Channels & Roles, so neither request is worth making.
    if (!(_guild?.hasFeature(GuildFeature.onboarding) ?? true)) {
      if (!_isStale(guildId) && (_onboarding != null || _hasSelfServePrompts)) {
        setState(() {
          _onboarding = null;
          _hasSelfServePrompts = false;
        });
      }
      return;
    }
    try {
      final status = await repository.getOwnOnboardingStatus(guildId);
      if (_isStale(guildId)) return;
      setState(() => _onboarding = status);
      if (status.enabled && !status.completed && !_onboardingShown) {
        _onboardingShown = true;
        await _openOnboarding();
      }
    } catch (_) {
      // No onboarding configured for this guild, or the check failed -
      // either way, don't block on it.
    }
    try {
      // Channels & Roles covers every prompt, including the ones that never
      // appear in the join flow - so its entry point can't be inferred from
      // the join-flow status above.
      final prompts = await repository.getOnboardingPrompts(guildId);
      if (_isStale(guildId)) return;
      setState(() => _hasSelfServePrompts = prompts.isNotEmpty);
    } catch (_) {
      // Leave the Channels & Roles row hidden.
    }
  }

  Future<void> _openOnboarding() async {
    final status = _onboarding;
    if (status == null) return;
    final completed = await Navigator.of(context, rootNavigator: true)
        .push<bool>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) =>
                OnboardingWizardScreen(guildId: widget.guildId, status: status),
          ),
        );
    if (completed == true && mounted) {
      // Accepting can add roles and channel overwrites, so both the guild and
      // this member's own permissions may have changed.
      setState(() => _onboarding = status.copyWith(completed: true));
      await _load();
    }
  }

  void _hydrateVoiceRosters(GuildDto guild) {
    final cubit = getIt<GuildVoiceCubit>();
    for (final channel in guild.channels) {
      if (channel.type == ChannelType.voice) {
        unawaited(cubit.hydrateChannelRoster(guild.id, channel.id));
      }
    }
  }

  Future<void> _showCreateSheet() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.tag),
              title: const Text('Create channel'),
              onTap: () => Navigator.pop(context, 'channel'),
            ),
            ListTile(
              leading: const Icon(Icons.create_new_folder_outlined),
              title: const Text('Create category'),
              onTap: () => Navigator.pop(context, 'category'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || choice == null) return;
    switch (choice) {
      case 'channel':
        await _createChannel();
      case 'category':
        await _createCategory();
    }
  }

  Future<void> _createChannel() async {
    final guild = _guild;
    if (guild == null) return;
    final input = await showDialog<_NewChannelInput>(
      context: context,
      builder: (context) => _CreateChannelDialog(
        categories: guild.categories,
        features: guild.featureSet,
      ),
    );
    if (input == null || input.name.trim().isEmpty) return;
    try {
      await getIt<GuildRepository>().createChannel(
        guildId: widget.guildId,
        name: input.name.trim(),
        type: input.type,
        categoryId: input.categoryId,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not create that channel.')),
        );
      }
    }
  }

  Future<void> _createCategory() async {
    final name = await _promptForText(
      title: 'Create a category',
      hint: 'Category name',
    );
    if (name == null || name.trim().isEmpty) return;
    try {
      await getIt<GuildRepository>().createCategory(
        guildId: widget.guildId,
        name: name.trim(),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not create that category.')),
        );
      }
    }
  }

  Future<void> _editCategory(CategoryDto category) async {
    final input = await showDialog<_CategoryEditInput>(
      context: context,
      builder: (context) => _EditCategoryDialog(category: category),
    );
    if (input == null) return;
    if (input.delete) {
      try {
        await getIt<GuildRepository>().deleteCategory(
          widget.guildId,
          category.id,
        );
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not delete that category.')),
          );
        }
      }
      return;
    }
    if (input.name.trim().isEmpty) return;
    try {
      await getIt<GuildRepository>().updateCategory(
        widget.guildId,
        category.id,
        name: input.name.trim(),
        description: input.description.trim(),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save that category.')),
        );
      }
    }
  }

  Future<String?> _promptForText({
    required String title,
    required String hint,
  }) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  /// One channel row - plus, for a forum, the posts in it this member has
  /// already opened, nested underneath it like Discord's sidebar.
  ///
  /// The nested rows are the only way back into a post without going through
  /// the forum's post list first, which is the point: a forum you're following
  /// two conversations in otherwise costs two taps to reach either of them.
  Widget _channelEntry(GuildDto guild, ChannelDto channel, bool canManage) {
    final tile = _ChannelTile(
      guildId: guild.id,
      guildName: guild.name,
      channel: channel,
      canManage: canManage,
      unread: _unread[channel.id],
      onLongPress: () => _showChannelActions(channel),
    );
    if (!channel.type.isForumLike) return tile;
    final visits = [
      for (final visit in ForumVisits.forForum(channel.id))
        // An archived post leaves the sidebar the way it leaves the forum's
        // active post list - it's still there to open, it's just not something
        // anybody is following anymore.
        if (!(guild.channels
                .where((c) => c.id == visit.postId)
                .firstOrNull
                ?.isArchived ??
            false))
          visit,
    ];
    if (visits.isEmpty) return tile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        tile,
        for (var i = 0; i < visits.length; i++)
          _ForumPostTile(
            // A post can be renamed after it was last opened, so the cached
            // channel wins when the guild still has it; the remembered title
            // is the fallback for a post the cache doesn't carry.
            name:
                guild.channels
                    .where((c) => c.id == visits[i].postId)
                    .firstOrNull
                    ?.name ??
                visits[i].name,
            unread: _unread[visits[i].postId],
            isLast: i == visits.length - 1,
            onTap: () {
              _markChannelRead(visits[i].postId);
              context.push(
                RoutePaths.serverChannelPath(guild.id, visits[i].postId),
              );
            },
            onForget: () => ForumVisits.forget(channel.id, visits[i].postId),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final guild = _guild;
    if (guild == null) {
      return Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: ListView(
            key: const ValueKey('loading'),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
            children: [for (var i = 0; i < 6; i++) const SkeletonListTile()],
          ),
        ),
      );
    }

    final byCategory = <String?, List<ChannelDto>>{};
    for (final channel in guild.channels) {
      // Forum posts are Thread-typed channels parented to their Forum (see
      // ForumChannelScreen) - they browse under that forum's own post list,
      // never as top-level sidebar entries.
      if (channel.type == ChannelType.thread) continue;
      (byCategory[channel.categoryId] ??= []).add(channel);
    }
    for (final list in byCategory.values) {
      list.sort((a, b) => a.position.compareTo(b.position));
    }
    final sortedCategories = [...guild.categories]
      ..sort((a, b) => a.position.compareTo(b.position));
    final uncategorized = byCategory[null] ?? const <ChannelDto>[];
    final canManageChannels = _permissions.has('ManageChannel');

    return Scaffold(
      appBar: AppBar(
        title: Text(guild.name),
        actions: [
          InboxAppBarAction(guildId: guild.id),
          // Modules are hidden, never greyed out - a household should not see
          // a wiki button it can't press. The owner is not exempt either:
          // a disabled module is a product state, not a permission level.
          if (guild.hasFeature(GuildFeature.wiki) &&
              _permissions.has('ViewWiki'))
            IconButton(
              icon: const Icon(Icons.menu_book_outlined),
              tooltip: 'Wiki',
              onPressed: () =>
                  context.push(RoutePaths.serverWikiPath(guild.id)),
            ),
          if (guild.hasFeature(GuildFeature.events))
            IconButton(
              icon: const Icon(Icons.event_outlined),
              tooltip: 'Events',
              onPressed: () =>
                  context.push(RoutePaths.serverEventsPath(guild.id)),
            ),
          IconButton(
            icon: const Icon(Icons.people_outline),
            onPressed: () =>
                context.push(RoutePaths.serverMembersPath(guild.id)),
          ),
          if (_permissions.has('ManageGuild'))
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () =>
                  context.push(RoutePaths.serverSettingsPath(guild.id)),
            ),
          // Reporting the server lives here rather than in Server Settings.
          // Settings is gated on `ManageGuild`, so putting it there would hide
          // it from every member except the people running the server - which
          // is exactly backwards from who needs to report one.
          PopupMenuButton<String>(
            tooltip: 'More',
            onSelected: (value) {
              if (value == 'report') _reportGuild(guild);
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'report',
                child: Text('Report this server'),
              ),
            ],
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: ListView(
          key: const ValueKey('loaded'),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
          children: [
            // A pending member can read everything but can't post, react or
            // join voice - so the way back into the wizard has to stay in
            // front of them rather than being a modal they dismissed once.
            if (_onboardingPending) _OnboardingBanner(onTap: _openOnboarding),
            // Who's actually in the flat, above the channels - it's the thing
            // a household opens the app to check, and it belongs to the house
            // rather than to any one channel.
            if (guild.hasFeature(GuildFeature.presence))
              HomeStatusBoard(guild: guild),
            // Under the board rather than above it: "who's home" is what a
            // household opens the app to check, and this is a summary of the
            // channels immediately below it. Draws nothing at all when there
            // is nothing outstanding.
            if (HomeDigestCard.appliesTo(guild)) HomeDigestCard(guild: guild),
            if (_hasSelfServePrompts)
              ListTile(
                dense: true,
                leading: const Icon(Icons.checklist_outlined),
                title: Text(
                  'Channels & Roles',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () =>
                    context.push(RoutePaths.serverChannelsRolesPath(guild.id)),
              ),
            for (final channel in uncategorized)
              _channelEntry(guild, channel, canManageChannels),
            for (final category in sortedCategories) ...[
              _CategoryHeader(
                category: category,
                canManage: canManageChannels,
                onEdit: () => _editCategory(category),
              ),
              for (final channel in byCategory[category.id] ?? const [])
                _channelEntry(guild, channel, canManageChannels),
            ],
          ],
        ),
      ),
      floatingActionButton: _permissions.has('ManageChannel')
          ? FloatingActionButton(
              onPressed: _showCreateSheet,
              tooltip: 'Create channel or category',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

/// Result of [_CreateChannelDialog] - carries the chosen type/category
/// alongside the name so [_GuildDetailScreenState._createChannel] doesn't
/// need a second round-trip through the dialog's internal state.
class _NewChannelInput {
  const _NewChannelInput({
    required this.name,
    required this.type,
    this.categoryId,
  });
  final String name;
  final ChannelType type;
  final String? categoryId;
}

/// The standing "you haven't finished onboarding" prompt at the top of a
/// pending member's channel list. Deliberately a banner rather than a blocking
/// modal: they can look around, they just can't participate yet.
class _OnboardingBanner extends StatelessWidget {
  const _OnboardingBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.xs,
        AppSpacing.m,
        AppSpacing.s,
      ),
      child: Material(
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.card),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Row(
              children: [
                Icon(
                  Icons.waving_hand_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Finish getting set up',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'You can look around, but you can\'t post yet.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: theme.colorScheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({
    required this.category,
    this.canManage = false,
    this.onEdit,
  });
  final CategoryDto category;
  final bool canManage;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: canManage ? onEdit : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, AppSpacing.m, 8, AppSpacing.xs),
        child: Text(
          category.name.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
    );
  }
}

class _ChannelTile extends StatelessWidget {
  const _ChannelTile({
    required this.guildId,
    required this.guildName,
    required this.channel,
    this.canManage = false,
    this.unread,
    this.onLongPress,
  });
  final String guildId;
  final String guildName;
  final ChannelDto channel;
  final bool canManage;
  final _ChannelReadState? unread;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    if (channel.type == ChannelType.voice) {
      return _VoiceChannelTile(
        guildId: guildId,
        guildName: guildName,
        channel: channel,
        canManage: canManage,
        onLongPress: onLongPress,
      );
    }
    final theme = Theme.of(context);
    final isUnread = unread?.isUnread ?? false;
    final mentionCount = unread?.mentionCount ?? 0;
    return ListTile(
      dense: true,
      leading: Icon(channelTypeIcon(channel.type)),
      title: Text(
        channel.name,
        style: isUnread
            ? theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)
            : theme.textTheme.bodyMedium,
      ),
      trailing: mentionCount > 0
          ? CircleAvatar(
              radius: 10,
              backgroundColor: theme.colorScheme.error,
              child: Text(
                '$mentionCount',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onError,
                ),
              ),
            )
          : null,
      onTap: () =>
          context.push(RoutePaths.serverChannelPath(guildId, channel.id)),
      onLongPress: onLongPress,
    );
  }
}

/// One already-visited forum post, nested under its forum in the channel
/// list, joined to it by the branch line [_ForumBranchPainter] draws.
///
/// Not a `ListTile`: this row is deliberately tighter than a channel row, and
/// it gives its left inset over to the branch, so a forum with a few posts
/// under it reads as one entry in the list rather than as five channels.
class _ForumPostTile extends StatelessWidget {
  const _ForumPostTile({
    required this.name,
    required this.isLast,
    required this.onTap,
    required this.onForget,
    this.unread,
  });

  /// Row height. Fixed rather than intrinsic because the branch is painted
  /// against it - the elbow has to land on the text's centre line, and the
  /// title is a single ellipsised line, so there's nothing to measure.
  static const _height = 36.0;

  final String name;
  final _ChannelReadState? unread;

  /// The last post under this forum ends the trunk at its own elbow instead
  /// of running the line on into the next channel.
  final bool isLast;
  final VoidCallback onTap;
  final VoidCallback onForget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = unread?.isUnread ?? false;
    final mentionCount = unread?.mentionCount ?? 0;
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: _height,
        child: Row(
          children: [
            CustomPaint(
              size: const Size(_ForumBranchPainter.width, _height),
              painter: _ForumBranchPainter(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.22),
                isLast: isLast,
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isUnread ? theme.colorScheme.onSurface : muted,
                  fontWeight: isUnread ? FontWeight.w600 : null,
                ),
              ),
            ),
            if (mentionCount > 0) ...[
              const SizedBox(width: AppSpacing.s),
              CircleAvatar(
                radius: 9,
                backgroundColor: theme.colorScheme.error,
                child: Text(
                  '$mentionCount',
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.onError,
                  ),
                ),
              ),
            ],
            // Only stops the post being listed here - it isn't leaving the
            // post, and opening it again brings the row back.
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              color: muted,
              tooltip: 'Remove from list',
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.all(AppSpacing.xs),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onPressed: onForget,
            ),
          ],
        ),
      ),
    );
  }
}

/// The elbow joining a nested forum post to its forum: a trunk dropping from
/// the forum's icon, turning right into each post's title.
///
/// This is what makes a run of posts read as belonging to the channel above
/// them rather than as an unexplained indent - the trunk is continuous down
/// the run and stops at the last elbow, so the group has a visible end.
class _ForumBranchPainter extends CustomPainter {
  const _ForumBranchPainter({required this.color, required this.isLast});

  /// Sized so the trunk lands under the centre of a `ListTile`'s leading icon
  /// (16 content padding + half of a 24 icon), and the run out of the elbow is
  /// long enough to carry the title clear of the channel names above it -
  /// nesting you can see at a glance rather than a four-pixel indent.
  static const width = 56.0;
  static const _trunkX = 28.0;
  static const _radius = 10.0;

  final Color color;
  final bool isLast;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final centerY = size.height / 2;
    canvas.drawPath(
      Path()
        ..moveTo(_trunkX, 0)
        ..lineTo(_trunkX, isLast ? centerY - _radius : size.height)
        ..moveTo(_trunkX, centerY - _radius)
        ..quadraticBezierTo(_trunkX, centerY, _trunkX + _radius, centerY)
        ..lineTo(size.width, centerY),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ForumBranchPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isLast != isLast;
}

/// Inline, Discord-style: the channel row plus one participant row per
/// connected user, embedded directly in the channel list (not a separate
/// screen). Tapping the row joins the channel without forcing any
/// navigation; tapping it again while already joined opens the full
/// `GuildVoiceScreen`.
class _VoiceChannelTile extends StatelessWidget {
  const _VoiceChannelTile({
    required this.guildId,
    required this.guildName,
    required this.channel,
    this.canManage = false,
    this.onLongPress,
  });
  final String guildId;
  final String guildName;
  final ChannelDto channel;
  final bool canManage;
  final VoidCallback? onLongPress;

  void _onTap(BuildContext context, GuildVoiceState state) {
    final alreadyJoined = state.channelId == channel.id && state.isInVoice;
    if (alreadyJoined) {
      Navigator.of(
        context,
        rootNavigator: true,
      ).push(MaterialPageRoute(builder: (_) => const GuildVoiceScreen()));
    } else {
      getIt<GuildVoiceCubit>().join(
        guildId: guildId,
        channelId: channel.id,
        channelName: channel.name,
        guildName: guildName,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<GuildVoiceCubit, GuildVoiceState>(
      bloc: getIt<GuildVoiceCubit>(),
      builder: (context, state) {
        final participants = state.rosterFor(channel.id);
        final joined = state.channelId == channel.id && state.isInVoice;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              dense: true,
              leading: Icon(
                Icons.volume_up_outlined,
                color: joined ? theme.colorScheme.primary : null,
              ),
              title: Text(channel.name, style: theme.textTheme.bodyMedium),
              trailing: participants.isNotEmpty
                  ? Text(
                      '${participants.length}',
                      style: theme.textTheme.labelSmall,
                    )
                  : null,
              onTap: () => _onTap(context, state),
              onLongPress: onLongPress,
            ),
            for (final participant in participants)
              Padding(
                padding: const EdgeInsets.only(left: 56, bottom: AppSpacing.xs),
                child: Row(
                  children: [
                    UserAvatar(
                      userId: participant.userId,
                      radius: AppRadii.avatarSmall / 2,
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(
                      child: ProfileResolver(
                        userId: participant.userId,
                        builder: (context, profile) => Text(
                          profile?.userName ?? '…',
                          style: theme.textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (participant.isMuted)
                      Icon(
                        Icons.mic_off,
                        size: 14,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Name + type (Text/Voice/Forum/Media - matches desktop's own create-channel
/// modal, which likewise doesn't offer Announcement/Thread as user-creatable
/// types) + optional category, mirroring `CreateChannelModalComponent`.
class _CreateChannelDialog extends StatefulWidget {
  const _CreateChannelDialog({
    required this.categories,
    required this.features,
  });

  final List<CategoryDto> categories;

  /// Channel types belonging to a disabled module aren't offered at all -
  /// creating one would be refused with a `400` anyway.
  final GuildFeatures features;

  @override
  State<_CreateChannelDialog> createState() => _CreateChannelDialogState();
}

/// One row of the create-channel picker, for the household types - which are
/// data-driven because there are five of them and they're all gated
/// individually on their own module.
typedef _ChannelTypeChoice = ({
  ChannelType type,
  IconData icon,
  String title,
  String subtitle,
});

class _CreateChannelDialogState extends State<_CreateChannelDialog> {
  final _nameController = TextEditingController();
  ChannelType _type = ChannelType.text;
  String? _categoryId;

  static const _allHouseholdTypes = <_ChannelTypeChoice>[
    (
      type: ChannelType.list,
      icon: Icons.checklist_rounded,
      title: 'List',
      subtitle: 'A shopping or todo list everyone ticks off together',
    ),
    (
      type: ChannelType.chores,
      icon: Icons.cleaning_services_outlined,
      title: 'Chores',
      subtitle: 'A rota that shares out the work by effort, not by turn',
    ),
    (
      type: ChannelType.ledger,
      icon: Icons.account_balance_wallet_outlined,
      title: 'Ledger',
      subtitle: 'Shared expenses and who owes who',
    ),
    (
      type: ChannelType.pantry,
      icon: Icons.kitchen_outlined,
      title: 'Pantry',
      subtitle: 'Stock for one place - the fridge, the freezer, the cellar',
    ),
    (
      type: ChannelType.decisions,
      icon: Icons.how_to_vote_outlined,
      title: 'Decisions',
      subtitle: 'House questions anyone can stop with a reason',
    ),
  ];

  /// A type whose module is off isn't offered - creating one is a `400`.
  List<_ChannelTypeChoice> get _householdTypes => [
    for (final choice in _allHouseholdTypes)
      if (choice.type.requiredFeature != null &&
          widget.features.has(choice.type.requiredFeature!))
        choice,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );
    final divider = Divider(
      height: 1,
      thickness: 1,
      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
    );
    return AlertDialog(
      title: const Text('Create a channel'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CHANNEL NAME', style: labelStyle),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'new-channel'),
            ),
            const SizedBox(height: AppSpacing.l),
            Text('CHANNEL TYPE', style: labelStyle),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.card),
              child: ColoredBox(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Column(
                  children: [
                    _ChannelTypeOption(
                      icon: Icons.tag,
                      title: 'Text',
                      subtitle: 'Send messages, images, GIFs, and more',
                      selected: _type == ChannelType.text,
                      onTap: () => setState(() => _type = ChannelType.text),
                    ),
                    if (widget.features.has(GuildFeature.voiceChannels)) ...[
                      divider,
                      _ChannelTypeOption(
                        icon: Icons.volume_up_outlined,
                        title: 'Voice',
                        subtitle: 'Hang out together with voice chat',
                        selected: _type == ChannelType.voice,
                        onTap: () => setState(() => _type = ChannelType.voice),
                      ),
                    ],
                    // One flag covers Forum *and* Media.
                    if (widget.features.has(GuildFeature.forums)) ...[
                      divider,
                      _ChannelTypeOption(
                        icon: Icons.forum_outlined,
                        title: 'Forum',
                        subtitle: 'Organize discussion into posts',
                        selected: _type == ChannelType.forum,
                        onTap: () => setState(() => _type = ChannelType.forum),
                      ),
                      divider,
                      _ChannelTypeOption(
                        icon: Icons.perm_media_outlined,
                        title: 'Media',
                        subtitle:
                            'A forum for images and clips, shown as a grid',
                        selected: _type == ChannelType.media,
                        onTap: () => setState(() => _type = ChannelType.media),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // The household types sit in their own group rather than at the
            // end of the same list: they hold rows instead of messages, which
            // is a bigger difference than Text vs Voice, and the heading is
            // what says so before somebody picks one.
            if (_householdTypes.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.l),
              Text('FOR THE HOUSE', style: labelStyle),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.card),
                child: ColoredBox(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Column(
                    children: [
                      for (var i = 0; i < _householdTypes.length; i++) ...[
                        if (i > 0) divider,
                        _ChannelTypeOption(
                          icon: _householdTypes[i].icon,
                          title: _householdTypes[i].title,
                          subtitle: _householdTypes[i].subtitle,
                          selected: _type == _householdTypes[i].type,
                          onTap: () =>
                              setState(() => _type = _householdTypes[i].type),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
            if (widget.categories.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.l),
              Text('CATEGORY', style: labelStyle),
              const SizedBox(height: 6),
              DropdownButtonFormField<String?>(
                initialValue: _categoryId,
                items: [
                  const DropdownMenuItem<String?>(child: Text('None')),
                  for (final category in widget.categories)
                    DropdownMenuItem<String?>(
                      value: category.id,
                      child: Text(category.name),
                    ),
                ],
                onChanged: (value) => setState(() => _categoryId = value),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            _NewChannelInput(
              name: _nameController.text,
              type: _type,
              categoryId: _categoryId,
            ),
          ),
          child: const Text('Create'),
        ),
      ],
    );
  }
}

/// One selectable channel-type row in [_CreateChannelDialog] - three of
/// these sit inside one shared bordered/rounded group (see the `ClipRRect`
/// in the dialog's `build`) separated by hairline dividers, rather than each
/// being its own bordered box. Only the selected row gets a tinted
/// background, so the group reads as one cohesive picker instead of three
/// disconnected buttons.
class _ChannelTypeOption extends StatelessWidget {
  const _ChannelTypeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? theme.colorScheme.primary.withValues(alpha: 0.12)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.s + 2,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 20,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// What [_EditCategoryDialog] resolves to - either an edited name/
/// description, or a delete request (kept as one result type so the
/// caller only has to `await` one dialog for both actions).
class _CategoryEditInput {
  const _CategoryEditInput({
    this.name = '',
    this.description = '',
    this.delete = false,
  });
  final String name;
  final String description;
  final bool delete;
}

class _EditCategoryDialog extends StatefulWidget {
  const _EditCategoryDialog({required this.category});

  final CategoryDto category;

  @override
  State<_EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<_EditCategoryDialog> {
  late final _nameController = TextEditingController(
    text: widget.category.name,
  );
  late final _descriptionController = TextEditingController(
    text: widget.category.description ?? '',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text(
          'Channels in "${widget.category.name}" are not deleted - they just '
          "won't be grouped under it anymore.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      Navigator.of(context).pop(const _CategoryEditInput(delete: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit category'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Category name'),
          ),
          const SizedBox(height: AppSpacing.s),
          TextField(
            controller: _descriptionController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
        ],
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: _confirmDelete,
          child: const Text('Delete'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            _CategoryEditInput(
              name: _nameController.text,
              description: _descriptionController.text,
            ),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
