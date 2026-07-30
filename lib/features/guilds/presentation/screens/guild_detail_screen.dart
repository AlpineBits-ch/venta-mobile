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
import '../../data/guild_repository.dart';
import '../../data/models/category_dto.dart';
import '../../data/models/channel_dto.dart';
import '../../data/models/guild_dto.dart';
import '../../data/models/guild_permissions.dart';
import '../../data/models/onboarding_dto.dart';

/// Per-channel read state tracked locally in [_GuildDetailScreenState] -
/// [isUnread] drives the bold channel-name styling, [mentionCount] the red
/// badge, mirroring Alpine's `GuildReadStateService`/`ChannelReadState`.
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

  @override
  void initState() {
    super.initState();
    _load();
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

  Future<void> _loadOwnPermissions(String ownerId) async {
    try {
      final self = await getIt<GuildRepository>().getOwnMember(widget.guildId);
      if (!mounted) return;
      setState(() {
        _permissions = self.effectivePermissions(ownerId);
        _unread = {
          for (final entry in self.unreadMentionCounts.entries)
            entry.key: (isUnread: true, mentionCount: entry.value),
        };
      });
    } catch (_) {
      // Leave permission-gated entries hidden - they're still enforced
      // server-side on every write regardless.
    }
  }

  /// Local-only, like Alpine's own `markChannelRead` - there's no per-
  /// channel "mark read" endpoint, just the same `readState` rows the
  /// server updates when messages are actually viewed in-channel.
  void _markChannelRead(String channelId) {
    setState(() => _unread = {..._unread}..remove(channelId));
  }

  Future<void> _showChannelActions(ChannelDto channel) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      // The shell's nav rail lives in a sibling of this screen's own
      // Navigator (see `AppShell`) - without this the sheet is clipped to
      // just the content pane instead of covering the whole device width.
      useRootNavigator: true,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
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

  @override
  void didUpdateWidget(covariant GuildDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.guildId != widget.guildId) _load();
  }

  @override
  void dispose() {
    _messageSub.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final repository = getIt<GuildRepository>();
    final cached = repository.cachedById(widget.guildId);
    if (cached != null && mounted) setState(() => _guild = cached);
    if (cached != null) {
      _hydrateVoiceRosters(cached);
      unawaited(_loadOwnPermissions(cached.ownerId));
    }
    try {
      final guild = await repository.fetchGuild(widget.guildId);
      if (mounted) setState(() => _guild = guild);
      _hydrateVoiceRosters(guild);
      unawaited(_loadOwnPermissions(guild.ownerId));
    } catch (_) {
      // Keep whatever was cached; the realtime-driven refetch will retry.
    }
    unawaited(_checkOnboarding());
  }

  /// Cheap enough to call on every guild-open per the backend guide - shows
  /// the rules gate once per membership (never again once `completed`).
  Future<void> _checkOnboarding() async {
    try {
      final status = await getIt<GuildRepository>().getOwnOnboardingStatus(
        widget.guildId,
      );
      if (!status.completed && mounted) await _showOnboardingSheet(status);
    } catch (_) {
      // No onboarding configured for this guild, or the check failed -
      // either way, don't block on it.
    }
  }

  Future<void> _showOnboardingSheet(OnboardingStatusDto status) async {
    final theme = Theme.of(context);
    var accepting = false;
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Welcome! Read the rules to get started', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.m),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: SingleChildScrollView(
                    child: Text(
                      status.rulesText ?? '',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                FilledButton(
                  onPressed: accepting
                      ? null
                      : () async {
                          setSheetState(() => accepting = true);
                          try {
                            await getIt<GuildRepository>().acceptOnboarding(
                              widget.guildId,
                            );
                            if (sheetContext.mounted) {
                              Navigator.of(sheetContext).pop();
                            }
                          } catch (_) {
                            setSheetState(() => accepting = false);
                            if (sheetContext.mounted) {
                              ScaffoldMessenger.of(sheetContext).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Could not accept - please try again.',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                  child: accepting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('I understand and agree'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
      builder: (context) => _CreateChannelDialog(categories: guild.categories),
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
          if (_permissions.has('ViewWiki'))
            IconButton(
              icon: const Icon(Icons.menu_book_outlined),
              tooltip: 'Wiki',
              onPressed: () =>
                  context.push(RoutePaths.serverWikiPath(guild.id)),
            ),
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
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: ListView(
          key: const ValueKey('loaded'),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
          children: [
            for (final channel in uncategorized)
              _ChannelTile(
                guildId: guild.id,
                guildName: guild.name,
                channel: channel,
                canManage: canManageChannels,
                unread: _unread[channel.id],
                onLongPress: () => _showChannelActions(channel),
              ),
            for (final category in sortedCategories) ...[
              _CategoryHeader(
                category: category,
                canManage: canManageChannels,
                onEdit: () => _editCategory(category),
              ),
              for (final channel in byCategory[category.id] ?? const [])
                _ChannelTile(
                  guildId: guild.id,
                  guildName: guild.name,
                  channel: channel,
                  canManage: canManageChannels,
                  unread: _unread[channel.id],
                  onLongPress: () => _showChannelActions(channel),
                ),
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
      leading: Icon(
        channel.type == ChannelType.forum ? Icons.forum_outlined : Icons.tag,
      ),
      title: Text(
        channel.name,
        style: isUnread
            ? theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              )
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

/// Name + type (Text/Voice/Forum - matches desktop's own create-channel
/// modal, which likewise doesn't offer Announcement/Thread as user-creatable
/// types) + optional category, mirroring `CreateChannelModalComponent`.
class _CreateChannelDialog extends StatefulWidget {
  const _CreateChannelDialog({required this.categories});

  final List<CategoryDto> categories;

  @override
  State<_CreateChannelDialog> createState() => _CreateChannelDialogState();
}

class _CreateChannelDialogState extends State<_CreateChannelDialog> {
  final _nameController = TextEditingController();
  ChannelType _type = ChannelType.text;
  String? _categoryId;

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
                    divider,
                    _ChannelTypeOption(
                      icon: Icons.volume_up_outlined,
                      title: 'Voice',
                      subtitle: 'Hang out together with voice chat',
                      selected: _type == ChannelType.voice,
                      onTap: () => setState(() => _type = ChannelType.voice),
                    ),
                    divider,
                    _ChannelTypeOption(
                      icon: Icons.forum_outlined,
                      title: 'Forum',
                      subtitle: 'Organize discussion into posts',
                      selected: _type == ChannelType.forum,
                      onTap: () => setState(() => _type = ChannelType.forum),
                    ),
                  ],
                ),
              ),
            ),
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
