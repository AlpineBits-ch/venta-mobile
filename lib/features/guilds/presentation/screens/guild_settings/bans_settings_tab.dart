import 'package:flutter/material.dart';

import '../../../../../core/di/injector.dart';
import '../../../../../core/theme/widget_styles.dart';
import '../../../data/guild_repository.dart';
import '../../../data/models/ban_dto.dart';

class BansSettingsTab extends StatefulWidget {
  const BansSettingsTab({super.key, required this.guildId});

  final String guildId;

  @override
  State<BansSettingsTab> createState() => _BansSettingsTabState();
}

class _BansSettingsTabState extends State<BansSettingsTab> {
  List<BanDto>? _bans;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final bans = await getIt<GuildRepository>().getBans(widget.guildId);
      if (mounted) setState(() => _bans = bans);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not load bans.');
    }
  }

  Future<void> _unban(BanDto ban) async {
    try {
      await getIt<GuildRepository>().deleteBan(
        widget.guildId,
        ban.bannedUserId,
      );
      await _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not unban.')));
      }
    }
  }

  Future<void> _createBan() async {
    final userIdController = TextEditingController();
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ban user'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: userIdController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'User ID'),
            ),
            const SizedBox(height: AppSpacing.s),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Reason (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Ban'),
          ),
        ],
      ),
    );
    if (confirmed != true || userIdController.text.trim().isEmpty) return;
    try {
      await getIt<GuildRepository>().createBan(
        widget.guildId,
        userId: userIdController.text.trim(),
        reason: reasonController.text.trim().isEmpty
            ? null
            : reasonController.text.trim(),
      );
      await _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not ban that user.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: _error != null
          ? Center(child: Text(_error!))
          : _bans == null
          ? const Center(child: CircularProgressIndicator.adaptive())
          : _bans!.isEmpty
          ? const Center(child: Text('No bans.'))
          : ListView.builder(
              itemCount: _bans!.length,
              itemBuilder: (context, index) {
                final ban = _bans![index];
                return ListTile(
                  title: Text(ban.bannedUserId),
                  subtitle: ban.reason != null && ban.reason!.isNotEmpty
                      ? Text(ban.reason!, style: theme.textTheme.bodySmall)
                      : null,
                  trailing: TextButton(
                    onPressed: () => _unban(ban),
                    child: const Text('Unban'),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createBan,
        tooltip: 'Ban user',
        child: const Icon(Icons.block),
      ),
    );
  }
}
