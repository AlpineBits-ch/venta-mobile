import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/status_colors_extension.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/profile_resolver.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../guild_voice/bloc/guild_voice_cubit.dart';
import '../../../guild_voice/presentation/screens/guild_voice_screen.dart';
import '../../data/guild_repository.dart';
import '../../data/models/category_dto.dart';
import '../../data/models/channel_dto.dart';
import '../../data/models/guild_dto.dart';

/// Content pane shown inside `AppShell` when a server is selected from the
/// rail — categories/channels for that guild. Tapping a channel pushes the
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
  bool _canManageGuild = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _loadOwnPermissions(String ownerId) async {
    try {
      final self = await getIt<GuildRepository>().getOwnMember(widget.guildId);
      if (!mounted) return;
      setState(() => _canManageGuild = self.effectivePermissions(ownerId).has('ManageGuild'));
    } catch (_) {
      // Leave the settings entry hidden — the tab itself is still
      // permission-checked server-side on every write regardless.
    }
  }

  @override
  void didUpdateWidget(covariant GuildDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.guildId != widget.guildId) _load();
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
  }

  void _hydrateVoiceRosters(GuildDto guild) {
    final cubit = getIt<GuildVoiceCubit>();
    for (final channel in guild.channels) {
      if (channel.type == ChannelType.voice) {
        unawaited(cubit.hydrateChannelRoster(guild.id, channel.id));
      }
    }
  }

  Future<void> _createChannel() async {
    final name = await _promptForText(title: 'Create a channel', hint: 'channel-name');
    if (name == null || name.trim().isEmpty) return;
    try {
      await getIt<GuildRepository>().createChannel(guildId: widget.guildId, name: name.trim());
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not create that channel.')),
        );
      }
    }
  }

  Future<String?> _promptForText({required String title, required String hint}) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(controller: controller, autofocus: true, decoration: InputDecoration(hintText: hint)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final byCategory = <String?, List<ChannelDto>>{};
    for (final channel in guild.channels) {
      (byCategory[channel.categoryId] ??= []).add(channel);
    }
    for (final list in byCategory.values) {
      list.sort((a, b) => a.position.compareTo(b.position));
    }
    final sortedCategories = [...guild.categories]..sort((a, b) => a.position.compareTo(b.position));
    final uncategorized = byCategory[null] ?? const <ChannelDto>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(guild.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline),
            onPressed: () => context.push(RoutePaths.serverMembersPath(guild.id)),
          ),
          if (_canManageGuild)
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => context.push(RoutePaths.serverSettingsPath(guild.id)),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
        children: [
          for (final channel in uncategorized)
            _ChannelTile(guildId: guild.id, guildName: guild.name, channel: channel),
          for (final category in sortedCategories)
            if ((byCategory[category.id] ?? const <ChannelDto>[]).isNotEmpty) ...[
              _CategoryHeader(category: category),
              for (final channel in byCategory[category.id]!)
                _ChannelTile(guildId: guild.id, guildName: guild.name, channel: channel),
            ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createChannel,
        tooltip: 'Create channel',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.category});
  final CategoryDto category;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, AppSpacing.m, 16, AppSpacing.xs),
      child: Text(
        category.name.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

class _ChannelTile extends StatelessWidget {
  const _ChannelTile({required this.guildId, required this.guildName, required this.channel});
  final String guildId;
  final String guildName;
  final ChannelDto channel;

  @override
  Widget build(BuildContext context) {
    if (channel.type == ChannelType.voice) {
      return _VoiceChannelTile(guildId: guildId, guildName: guildName, channel: channel);
    }
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(Icons.tag, color: context.statusColors.hover.withValues(alpha: 1)),
      title: Text(channel.name, style: theme.textTheme.bodyMedium),
      onTap: () => context.push(RoutePaths.serverChannelPath(guildId, channel.id)),
    );
  }
}

/// Inline, Discord-style: the channel row plus one participant row per
/// connected user, embedded directly in the channel list (not a separate
/// screen). Tapping the row joins the channel without forcing any
/// navigation; tapping it again while already joined opens the full
/// `GuildVoiceScreen`.
class _VoiceChannelTile extends StatelessWidget {
  const _VoiceChannelTile({required this.guildId, required this.guildName, required this.channel});
  final String guildId;
  final String guildName;
  final ChannelDto channel;

  void _onTap(BuildContext context, GuildVoiceState state) {
    final alreadyJoined = state.channelId == channel.id && state.isInVoice;
    if (alreadyJoined) {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (_) => const GuildVoiceScreen()),
      );
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
              leading: Icon(
                Icons.volume_up_outlined,
                color: joined ? theme.colorScheme.primary : context.statusColors.hover.withValues(alpha: 1),
              ),
              title: Text(channel.name, style: theme.textTheme.bodyMedium),
              trailing: participants.isEmpty
                  ? null
                  : Text('${participants.length}', style: theme.textTheme.labelSmall),
              onTap: () => _onTap(context, state),
            ),
            for (final participant in participants)
              Padding(
                padding: const EdgeInsets.only(left: 56, bottom: AppSpacing.xs),
                child: Row(
                  children: [
                    UserAvatar(userId: participant.userId, radius: AppRadii.avatarSmall / 2),
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
                      Icon(Icons.mic_off, size: 14, color: context.statusColors.hover),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
