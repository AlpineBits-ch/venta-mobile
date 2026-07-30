import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/button_progress_indicator.dart';
import '../../data/guild_repository.dart';
import '../../data/models/channel_dto.dart';
import '../../data/models/channel_follower_dto.dart';

/// Rename/describe/slowmode/delete for a single channel - mirrors desktop's
/// `ChannelOverviewComponent`. Permission override editing (per-role/
/// per-member allow/deny) isn't built here; that's the same scope cut as
/// the guild role editor (display/edit of the simple fields only).
class ChannelSettingsScreen extends StatefulWidget {
  const ChannelSettingsScreen({
    super.key,
    required this.guildId,
    required this.channelId,
  });

  final String guildId;
  final String channelId;

  @override
  State<ChannelSettingsScreen> createState() => _ChannelSettingsScreenState();
}

class _ChannelSettingsScreenState extends State<ChannelSettingsScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  ChannelDto? _channel;
  bool _isPrivate = false;
  bool _isAgeRestricted = false;
  int _slowModeSeconds = 0;
  bool _saving = false;
  List<ChannelFollowerDto>? _followers;
  bool _followersLoaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _applyChannel(ChannelDto channel) {
    setState(() {
      _channel = channel;
      _nameController.text = channel.name;
      _descriptionController.text = channel.description ?? '';
      _isPrivate = channel.isPrivate;
      _isAgeRestricted = channel.isAgeRestricted;
      _slowModeSeconds = channel.slowModeSeconds;
    });
    if (channel.type == ChannelType.announcement && !_followersLoaded) {
      _followersLoaded = true;
      _loadFollowers();
    }
  }

  Future<void> _loadFollowers() async {
    try {
      final followers = await getIt<GuildRepository>().getFollowers(
        widget.channelId,
      );
      if (mounted) setState(() => _followers = followers);
    } catch (_) {
      // Section just stays empty if this fails.
    }
  }

  Future<void> _unfollow(ChannelFollowerDto follower) async {
    try {
      await getIt<GuildRepository>().unfollowChannel(
        sourceChannelId: widget.channelId,
        followId: follower.id,
      );
      if (mounted) {
        setState(
          () => _followers = _followers
              ?.where((f) => f.id != follower.id)
              .toList(),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not remove that follower.')),
        );
      }
    }
  }

  Future<void> _load() async {
    final repository = getIt<GuildRepository>();
    final guild = repository.cachedById(widget.guildId);
    final cached = guild?.channels
        .where((c) => c.id == widget.channelId)
        .firstOrNull;
    if (cached != null) _applyChannel(cached);
    try {
      final fresh = await repository.fetchGuild(widget.guildId);
      final channel = fresh.channels
          .where((c) => c.id == widget.channelId)
          .firstOrNull;
      if (mounted && channel != null) _applyChannel(channel);
    } catch (_) {
      // Keep whatever was cached.
    }
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      final updated = await getIt<GuildRepository>().updateChannel(
        widget.guildId,
        widget.channelId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        isPrivate: _isPrivate,
        isAgeRestricted: _isAgeRestricted,
        slowModeSeconds: _slowModeSeconds,
      );
      if (mounted) {
        _applyChannel(updated);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Saved.')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save changes.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete channel?'),
        content: Text(
          'This permanently deletes "#${_channel?.name ?? 'this channel'}" '
          'and its message history. This cannot be undone.',
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
    if (confirmed != true || !mounted) return;
    try {
      await getIt<GuildRepository>().deleteChannel(
        widget.guildId,
        widget.channelId,
      );
      if (mounted) {
        Navigator.of(context)
          ..pop()
          ..pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete that channel.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final channel = _channel;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(
          fallbackLocation: RoutePaths.serverChannelPath(
            widget.guildId,
            widget.channelId,
          ),
        ),
        title: const Text('Channel Settings'),
      ),
      body: channel == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.m),
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Channel name'),
                ),
                const SizedBox(height: AppSpacing.s),
                TextField(
                  controller: _descriptionController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description (topic)',
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Private channel'),
                  subtitle: const Text(
                    'Only members with an explicit override can view it',
                  ),
                  value: _isPrivate,
                  onChanged: (value) => setState(() => _isPrivate = value),
                ),
                // Age gating and slow mode are both about *posting*, and a
                // household channel holds rows rather than messages - there's
                // nothing for either of them to act on.
                if (channel.type.hasMessages) ...[
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Age-restricted'),
                    value: _isAgeRestricted,
                    onChanged: (value) =>
                        setState(() => _isAgeRestricted = value),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  DropdownButtonFormField<int>(
                    initialValue: _slowModeSeconds,
                    decoration: const InputDecoration(labelText: 'Slow mode'),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Off')),
                      DropdownMenuItem(value: 5, child: Text('5 seconds')),
                      DropdownMenuItem(value: 10, child: Text('10 seconds')),
                      DropdownMenuItem(value: 30, child: Text('30 seconds')),
                      DropdownMenuItem(value: 60, child: Text('1 minute')),
                      DropdownMenuItem(value: 300, child: Text('5 minutes')),
                      DropdownMenuItem(value: 900, child: Text('15 minutes')),
                      DropdownMenuItem(value: 3600, child: Text('1 hour')),
                    ],
                    onChanged: (value) =>
                        setState(() => _slowModeSeconds = value ?? 0),
                  ),
                ],
                const SizedBox(height: AppSpacing.m),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const ButtonProgressIndicator()
                      : const Text('Save changes'),
                ),
                if (channel.type.isForumLike) ...[
                  const SizedBox(height: AppSpacing.l),
                  const Divider(),
                  const SizedBox(height: AppSpacing.s),
                  Text('FORUM', style: theme.textTheme.labelSmall),
                  const SizedBox(height: AppSpacing.xs),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.sell_outlined),
                    title: const Text('Tags & posting settings'),
                    subtitle: const Text(
                      'Post tags, required tagging, default sort and layout',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(
                      RoutePaths.serverChannelForumSettingsPath(
                        widget.guildId,
                        widget.channelId,
                      ),
                    ),
                  ),
                ],
                if (channel.type == ChannelType.announcement) ...[
                  const SizedBox(height: AppSpacing.l),
                  const Divider(),
                  const SizedBox(height: AppSpacing.s),
                  Text('FOLLOWERS', style: theme.textTheme.labelSmall),
                  const SizedBox(height: 4),
                  Text(
                    'Channels (in other servers) that receive published '
                    'posts from here.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  if (_followers == null)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.s),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_followers!.isEmpty)
                    Text(
                      'No channels follow this one yet.',
                      style: theme.textTheme.bodyMedium,
                    )
                  else
                    for (final follower in _followers!)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.rss_feed),
                        title: Text(follower.targetChannelId),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: 'Remove follower',
                          onPressed: () => _unfollow(follower),
                        ),
                      ),
                ],
                const SizedBox(height: AppSpacing.l),
                const Divider(),
                const SizedBox(height: AppSpacing.s),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                  onPressed: _confirmDelete,
                  child: const Text('Delete channel'),
                ),
              ],
            ),
    );
  }
}
