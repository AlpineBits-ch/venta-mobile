import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/di/injector.dart';
import '../../../../../core/theme/widget_styles.dart';
import '../../../../../core/widgets/button_progress_indicator.dart';
import '../../../data/guild_repository.dart';
import '../../../data/models/channel_dto.dart';
import '../../../data/models/guild_dto.dart';

class OverviewSettingsTab extends StatefulWidget {
  const OverviewSettingsTab({super.key, required this.guildId});

  final String guildId;

  @override
  State<OverviewSettingsTab> createState() => _OverviewSettingsTabState();
}

class _OverviewSettingsTabState extends State<OverviewSettingsTab> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();
  GuildDto? _guild;
  String? _systemChannelId;
  VerificationLevel _verificationLevel = VerificationLevel.none;
  bool _saving = false;
  bool _iconFailed = false;

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

  Future<void> _load() async {
    final repository = getIt<GuildRepository>();
    final cached = repository.cachedById(widget.guildId);
    if (cached != null) _applyGuild(cached);
    try {
      final guild = await repository.fetchGuild(widget.guildId);
      if (mounted) _applyGuild(guild);
    } catch (_) {
      // Keep whatever was cached.
    }
  }

  void _applyGuild(GuildDto guild) {
    setState(() {
      _guild = guild;
      _nameController.text = guild.name;
      _descriptionController.text = guild.description ?? '';
      _systemChannelId = guild.systemChannelId;
      _verificationLevel = guild.verificationLevel;
      _iconFailed = false;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await getIt<GuildRepository>().updateGuild(
        widget.guildId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        systemChannelId: _systemChannelId,
        verificationLevel: _verificationLevel,
      );
      if (mounted) {
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

  Future<void> _pickIcon() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    try {
      final updated = await getIt<GuildRepository>().uploadGuildIcon(
        widget.guildId,
        bytes: bytes,
        fileName: file.name,
      );
      if (mounted) _applyGuild(updated);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not upload icon.')));
      }
    }
  }

  Future<void> _removeIcon() async {
    try {
      final updated = await getIt<GuildRepository>().deleteGuildIcon(
        widget.guildId,
      );
      if (mounted) _applyGuild(updated);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not remove icon.')));
      }
    }
  }

  Future<void> _saveAsTemplate() async {
    final nameController = TextEditingController(
      text: '${_guild?.name ?? 'Server'} template',
    );
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save as template'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Template name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(nameController.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty || !mounted) return;
    try {
      final template = await getIt<GuildRepository>().createTemplate(
        widget.guildId,
        name: name.trim(),
      );
      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Template created'),
            content: SelectableText(
              'Share this id so others can create a server from it:\n\n'
              '${template.id}',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not create a template.')),
        );
      }
    }
  }

  Future<void> _confirmDeleteServer() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete server?'),
        content: Text(
          'This permanently deletes "${_guild?.name ?? 'this server'}" and everything in it. '
          'This cannot be undone.',
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
      await getIt<GuildRepository>().deleteGuild(widget.guildId);
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete server.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final guild = _guild;
    if (guild == null) return const Center(child: CircularProgressIndicator());
    final theme = Theme.of(context);
    final textChannels = guild.channels
        .where((c) => c.type == ChannelType.text)
        .toList();
    final iconUrl = getIt<GuildRepository>().guildIconUrl(widget.guildId);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.m),
      children: [
        Center(
          child: Stack(
            children: [
              ClipOval(
                child: Container(
                  width: 88,
                  height: 88,
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  alignment: Alignment.center,
                  child: !_iconFailed
                      ? Image.network(
                          iconUrl,
                          width: 88,
                          height: 88,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) {
                            WidgetsBinding.instance.addPostFrameCallback(
                              (_) => setState(() => _iconFailed = true),
                            );
                            return const SizedBox.shrink();
                          },
                        )
                      : Text(
                          guild.name.isNotEmpty
                              ? guild.name[0].toUpperCase()
                              : '?',
                          style: theme.textTheme.headlineMedium,
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: IconButton.filled(
                  iconSize: 18,
                  onPressed: _pickIcon,
                  icon: const Icon(Icons.edit),
                ),
              ),
            ],
          ),
        ),
        if (!_iconFailed)
          Center(
            child: TextButton(
              onPressed: _removeIcon,
              child: const Text('Remove icon'),
            ),
          ),
        const SizedBox(height: AppSpacing.m),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Server name'),
        ),
        const SizedBox(height: AppSpacing.s),
        TextField(
          controller: _descriptionController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Description'),
        ),
        const SizedBox(height: AppSpacing.s),
        DropdownButtonFormField<String?>(
          initialValue: _systemChannelId,
          decoration: const InputDecoration(labelText: 'System channel'),
          items: [
            const DropdownMenuItem<String?>(child: Text('None')),
            for (final channel in textChannels)
              DropdownMenuItem<String?>(
                value: channel.id,
                child: Text('#${channel.name}'),
              ),
          ],
          onChanged: (value) => setState(() => _systemChannelId = value),
        ),
        const SizedBox(height: AppSpacing.l),
        const Divider(),
        const SizedBox(height: AppSpacing.s),
        Text('Safety', style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.s),
        DropdownButtonFormField<VerificationLevel>(
          initialValue: _verificationLevel,
          decoration: const InputDecoration(labelText: 'Verification level'),
          items: [
            for (final level in VerificationLevel.values)
              DropdownMenuItem(
                value: level,
                child: Text(_verificationLevelLabel(level)),
              ),
          ],
          onChanged: (value) => setState(
            () => _verificationLevel = value ?? VerificationLevel.none,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _verificationLevelDescription(_verificationLevel),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const ButtonProgressIndicator()
              : const Text('Save changes'),
        ),
        const SizedBox(height: AppSpacing.l),
        const Divider(),
        const SizedBox(height: AppSpacing.s),
        OutlinedButton(
          onPressed: _saveAsTemplate,
          child: const Text('Save as template'),
        ),
        const SizedBox(height: AppSpacing.l),
        const Divider(),
        const SizedBox(height: AppSpacing.s),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
          ),
          onPressed: _confirmDeleteServer,
          child: const Text('Delete server'),
        ),
      ],
    );
  }
}

String _verificationLevelLabel(VerificationLevel level) => switch (level) {
  VerificationLevel.none => 'None',
  VerificationLevel.low => 'Low',
  VerificationLevel.medium => 'Medium',
  VerificationLevel.high => 'High',
};

/// Mirrors the backend's join-time requirement for each tier - v1 gates
/// joining only, it doesn't retroactively restrict already-joined members.
String _verificationLevelDescription(VerificationLevel level) => switch (level) {
  VerificationLevel.none => 'Anyone with a valid invite can join.',
  VerificationLevel.low => 'Requires a verified email to join.',
  VerificationLevel.medium =>
    'Requires a verified email and an account registered 5+ minutes ago.',
  VerificationLevel.high =>
    'Requires a verified email and an account registered 10+ minutes ago.',
};
