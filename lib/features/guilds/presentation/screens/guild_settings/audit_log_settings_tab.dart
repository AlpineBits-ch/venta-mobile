import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../../core/di/injector.dart';
import '../../../../../core/theme/widget_styles.dart';
import '../../../../../core/widgets/profile_resolver.dart';
import '../../../data/guild_repository.dart';
import '../../../data/models/audit_log_entry_dto.dart';

String _describe(AuditActionType type) => switch (type) {
      AuditActionType.memberBanned => 'banned a member',
      AuditActionType.memberUnbanned => 'unbanned a member',
      AuditActionType.memberKicked => 'kicked a member',
      AuditActionType.memberMuted => 'muted a member',
      AuditActionType.memberUnmuted => 'unmuted a member',
      AuditActionType.memberLeft => 'left the server',
      AuditActionType.roleCreated => 'created a role',
      AuditActionType.roleUpdated => 'updated a role',
      AuditActionType.roleDeleted => 'deleted a role',
      AuditActionType.rolePositionsChanged => 'reordered roles',
      AuditActionType.channelCreated => 'created a channel',
      AuditActionType.channelDeleted => 'deleted a channel',
      AuditActionType.channelUpdated => 'updated a channel',
      AuditActionType.channelPermissionChanged => 'changed channel permissions',
      AuditActionType.categoryCreated => 'created a category',
      AuditActionType.categoryDeleted => 'deleted a category',
      AuditActionType.guildUpdated => 'updated server settings',
      AuditActionType.guildDeleted => 'deleted the server',
      AuditActionType.inviteCreated => 'created an invite',
      AuditActionType.inviteDeleted => 'deleted an invite',
      AuditActionType.botInstalled => 'installed a bot',
      AuditActionType.botUninstalled => 'uninstalled a bot',
      AuditActionType.guildImportedFromDiscord => 'imported this server from Discord',
      AuditActionType.guildSyncedFromDiscord => 'synced this server from Discord',
      AuditActionType.unknown => 'did something',
    };

String? _metadataSummary(String? metadata) {
  if (metadata == null || metadata.isEmpty) return null;
  try {
    final decoded = jsonDecode(metadata);
    if (decoded is! Map) return null;
    return decoded.entries.map((e) => '${e.key}: ${e.value}').join(' · ');
  } catch (_) {
    return null;
  }
}

class AuditLogSettingsTab extends StatefulWidget {
  const AuditLogSettingsTab({super.key, required this.guildId});

  final String guildId;

  @override
  State<AuditLogSettingsTab> createState() => _AuditLogSettingsTabState();
}

class _AuditLogSettingsTabState extends State<AuditLogSettingsTab> {
  List<AuditLogEntryDto>? _entries;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final entries = await getIt<GuildRepository>().getAuditLog(widget.guildId);
      if (mounted) setState(() => _entries = entries);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not load the audit log.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_error != null) return Center(child: Text(_error!));
    final entries = _entries;
    if (entries == null) return const Center(child: CircularProgressIndicator());
    if (entries.isEmpty) return const Center(child: Text('No activity yet.'));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final summary = _metadataSummary(entry.metadata);
        return ListTile(
          title: ProfileResolver(
            userId: entry.actorUserId,
            builder: (context, profile) => Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: profile?.userName ?? entry.actorUserId,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' ${_describe(entry.actionType)}'),
                ],
              ),
            ),
          ),
          subtitle: summary != null
              ? Text(summary, style: theme.textTheme.labelSmall)
              : null,
        );
      },
    );
  }
}
