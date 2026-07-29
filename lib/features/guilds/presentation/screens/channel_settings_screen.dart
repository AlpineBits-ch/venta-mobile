import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../data/guild_repository.dart';
import '../../data/models/channel_dto.dart';

/// Rename/describe/slowmode/delete for a single channel — mirrors desktop's
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
      appBar: AppBar(title: const Text('Channel Settings')),
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
                const SizedBox(height: AppSpacing.m),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save changes'),
                ),
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
