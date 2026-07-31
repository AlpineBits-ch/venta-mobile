import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../core/di/injector.dart';
import '../../../../../core/network/api_error.dart';
import '../../../../../core/theme/widget_styles.dart';
import '../../../../../core/widgets/button_progress_indicator.dart';
import '../../../../../core/widgets/load_failure_view.dart';
import '../../../../messaging/presentation/widgets/reaction_picker_sheet.dart';
import '../../../data/guild_repository.dart';
import '../../../data/models/channel_dto.dart';
import '../../../data/models/welcome_screen_dto.dart';

/// The splash someone sees on an invite, before they join - description plus
/// up to five highlighted channels.
///
/// Non-members can't call the welcome-screen endpoint, so the invite preview
/// carries this inline; that's what `InviteDialog` renders.
class WelcomeScreenSettingsScreen extends StatefulWidget {
  const WelcomeScreenSettingsScreen({super.key, required this.guildId});

  final String guildId;

  @override
  State<WelcomeScreenSettingsScreen> createState() =>
      _WelcomeScreenSettingsScreenState();
}

class _WelcomeScreenSettingsScreenState
    extends State<WelcomeScreenSettingsScreen> {
  final _descriptionController = TextEditingController();
  bool _enabled = false;
  List<WelcomeChannelDto> _channels = const [];
  bool _loading = true;
  bool _loadFailed = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loadFailed = false;
      _loading = true;
    });
    try {
      final screen = await getIt<GuildRepository>().getWelcomeScreen(
        widget.guildId,
      );
      if (!mounted) return;
      setState(() {
        _enabled = screen.enabled;
        _descriptionController.text = screen.description ?? '';
        _channels = [...screen.channels]
          ..sort((a, b) => a.position.compareTo(b.position));
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadFailed = true;
        });
      }
    }
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final saved = await getIt<GuildRepository>().updateWelcomeScreen(
        widget.guildId,
        WelcomeScreenDto(
          enabled: _enabled,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          channels: [
            for (var i = 0; i < _channels.length; i++)
              _channels[i].copyWith(position: i),
          ],
        ),
      );
      if (!mounted) return;
      setState(() {
        _enabled = saved.enabled;
        _channels = [...saved.channels]
          ..sort((a, b) => a.position.compareTo(b.position));
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saved.')));
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = apiErrorMessage(error) ?? 'Could not save changes.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _addChannel() async {
    final guild = getIt<GuildRepository>().cachedById(widget.guildId);
    final available = [
      for (final channel in guild?.channels ?? const <ChannelDto>[])
        if (channel.type != ChannelType.thread &&
            !_channels.any((c) => c.channelId == channel.id))
          channel,
    ]..sort((a, b) => a.position.compareTo(b.position));
    if (available.isEmpty) return;

    final picked = await showModalBottomSheet<ChannelDto>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final channel in available)
              ListTile(
                leading: const Icon(Icons.tag),
                title: Text(channel.name),
                onTap: () => Navigator.pop(sheetContext, channel),
              ),
          ],
        ),
      ),
    );
    if (picked == null || !mounted) return;
    setState(
      () => _channels = [
        ..._channels,
        WelcomeChannelDto(channelId: picked.id, position: _channels.length),
      ],
    );
  }

  Future<void> _editChannel(int index) async {
    final entry = _channels[index];
    final result = await showDialog<_WelcomeChannelEdit>(
      context: context,
      builder: (dialogContext) => _WelcomeChannelDialog(entry: entry),
    );
    if (result == null || !mounted) return;
    setState(() {
      final next = [..._channels];
      if (result.delete) {
        next.removeAt(index);
      } else {
        next[index] = entry.copyWith(
          description: result.description,
          emoji: result.emoji,
        );
      }
      _channels = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final guild = getIt<GuildRepository>().cachedById(widget.guildId);
    final atChannelCap = _channels.length >= WelcomeScreenDto.maxChannels;

    return Scaffold(
      appBar: AppBar(title: const Text('Welcome screen')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadFailed
          ? LoadFailureView(
              message: 'Couldn\'t load the welcome screen.',
              onRetry: _load,
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.m),
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Show a welcome screen'),
                  subtitle: const Text(
                    'Shown on the invite, before someone joins',
                  ),
                  value: _enabled,
                  onChanged: (value) => setState(() => _enabled = value),
                ),
                const SizedBox(height: AppSpacing.s),
                TextField(
                  controller: _descriptionController,
                  enabled: _enabled,
                  minLines: 2,
                  maxLines: 3,
                  maxLength: WelcomeScreenDto.maxDescriptionLength,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'What is this server about?',
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Row(
                  children: [
                    Text('CHANNELS', style: theme.textTheme.labelSmall),
                    const Spacer(),
                    Text(
                      '${_channels.length}/${WelcomeScreenDto.maxChannels}',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                for (var i = 0; i < _channels.length; i++)
                  Builder(
                    builder: (context) {
                      final entry = _channels[i];
                      final channel = guild?.channels
                          .where((c) => c.id == entry.channelId)
                          .firstOrNull;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: entry.emoji != null && entry.emoji!.isNotEmpty
                            ? Text(
                                entry.emoji!,
                                style: const TextStyle(fontSize: 20),
                              )
                            : const Icon(Icons.tag),
                        title: Text('#${channel?.name ?? entry.channelId}'),
                        subtitle: Text(
                          entry.description.isEmpty
                              ? 'No description yet'
                              : entry.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: entry.description.isEmpty
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _enabled ? () => _editChannel(i) : null,
                      );
                    },
                  ),
                const SizedBox(height: AppSpacing.xs),
                OutlinedButton.icon(
                  onPressed: !_enabled || atChannelCap ? null : _addChannel,
                  icon: const Icon(Icons.add),
                  label: Text(
                    atChannelCap ? 'Up to 5 channels' : 'Add a channel',
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    _error!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.l),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const ButtonProgressIndicator()
                      : const Text('Save changes'),
                ),
              ],
            ),
    );
  }
}

class _WelcomeChannelEdit {
  const _WelcomeChannelEdit({
    this.description = '',
    this.emoji,
    this.delete = false,
  });
  final String description;
  final String? emoji;
  final bool delete;
}

class _WelcomeChannelDialog extends StatefulWidget {
  const _WelcomeChannelDialog({required this.entry});

  final WelcomeChannelDto entry;

  @override
  State<_WelcomeChannelDialog> createState() => _WelcomeChannelDialogState();
}

class _WelcomeChannelDialogState extends State<_WelcomeChannelDialog> {
  late final _controller = TextEditingController(
    text: widget.entry.description,
  );
  late String? _emoji = widget.entry.emoji;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Channel highlight'),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            tooltip: 'Emoji',
            onPressed: () async {
              final picked = await showReactionPickerSheet(context);
              if (picked != null) setState(() => _emoji = picked.emoji);
            },
            icon: _emoji != null && _emoji!.isNotEmpty
                ? Text(_emoji!, style: const TextStyle(fontSize: 20))
                : const Icon(Icons.emoji_emotions_outlined),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              maxLength: WelcomeScreenDto.maxChannelDescriptionLength,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Say hi here',
                counterText: '',
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => Navigator.of(
            context,
          ).pop(const _WelcomeChannelEdit(delete: true)),
          child: const Text('Remove'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            _WelcomeChannelEdit(
              description: _controller.text.trim(),
              emoji: _emoji,
            ),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
