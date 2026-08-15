import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../../core/di/injector.dart';
import '../../../../../core/format/date_time_format.dart';
import '../../../../../core/theme/widget_styles.dart';
import '../../../../../core/widgets/load_failure_view.dart';
import '../../../../../core/widgets/profile_resolver.dart';
import '../../../data/guild_repository.dart';
import '../../../data/models/audit_log_entry_dto.dart';

/// What `targetId` points at for a given action, so the row can resolve the
/// id into a name instead of leaving "banned a member" with no member.
enum _TargetKind { user, role, channel, category, none }

_TargetKind _targetKind(AuditActionType type) => switch (type) {
  AuditActionType.memberBanned ||
  AuditActionType.memberUnbanned ||
  AuditActionType.memberKicked ||
  AuditActionType.memberMuted ||
  AuditActionType.memberUnmuted ||
  AuditActionType.botInstalled ||
  AuditActionType.botUninstalled => _TargetKind.user,
  AuditActionType.roleCreated ||
  AuditActionType.roleUpdated ||
  AuditActionType.roleDeleted => _TargetKind.role,
  AuditActionType.channelCreated ||
  AuditActionType.channelDeleted ||
  AuditActionType.channelUpdated ||
  AuditActionType.channelPermissionChanged ||
  // Server logs the channel the blocked message was sent in as the target.
  AuditActionType.autoModMessageBlocked => _TargetKind.channel,
  // Categories live in `GuildDto.categories`, not `channels`, and take no
  // `#` prefix.
  AuditActionType.categoryCreated ||
  AuditActionType.categoryDeleted ||
  AuditActionType.categoryUpdated => _TargetKind.category,
  // Everything else targets an opaque id (emoji, event, template, follow,
  // message) whose human-readable name the server puts in `metadata`, which
  // the subtitle already renders - so there's nothing to resolve here.
  _ => _TargetKind.none,
};

/// Verb phrase for known actions. Deliberately leaves the object out when
/// [_targetKind] can name it, so the row reads "banned Dominic" rather than
/// "banned a member".
String _describeKnown(AuditActionType type, bool hasTarget) => switch (type) {
  AuditActionType.memberBanned => hasTarget ? 'banned' : 'banned a member',
  AuditActionType.memberUnbanned =>
    hasTarget ? 'unbanned' : 'unbanned a member',
  AuditActionType.memberKicked => hasTarget ? 'kicked' : 'kicked a member',
  AuditActionType.memberMuted => hasTarget ? 'muted' : 'muted a member',
  AuditActionType.memberUnmuted => hasTarget ? 'unmuted' : 'unmuted a member',
  AuditActionType.memberLeft => 'left the server',
  AuditActionType.roleCreated => hasTarget ? 'created role' : 'created a role',
  AuditActionType.roleUpdated => hasTarget ? 'updated role' : 'updated a role',
  AuditActionType.roleDeleted => hasTarget ? 'deleted role' : 'deleted a role',
  AuditActionType.rolePositionsChanged => 'reordered roles',
  AuditActionType.channelCreated =>
    hasTarget ? 'created channel' : 'created a channel',
  AuditActionType.channelDeleted =>
    hasTarget ? 'deleted channel' : 'deleted a channel',
  AuditActionType.channelUpdated =>
    hasTarget ? 'updated channel' : 'updated a channel',
  AuditActionType.channelPermissionChanged =>
    hasTarget ? 'changed permissions on' : 'changed channel permissions',
  AuditActionType.categoryCreated =>
    hasTarget ? 'created category' : 'created a category',
  AuditActionType.categoryDeleted =>
    hasTarget ? 'deleted category' : 'deleted a category',
  AuditActionType.categoryUpdated =>
    hasTarget ? 'updated category' : 'updated a category',
  AuditActionType.guildUpdated => 'updated server settings',
  AuditActionType.guildDeleted => 'deleted the server',
  AuditActionType.inviteCreated => 'created an invite',
  AuditActionType.inviteDeleted => 'deleted an invite',
  AuditActionType.botInstalled =>
    hasTarget ? 'installed bot' : 'installed a bot',
  AuditActionType.botUninstalled =>
    hasTarget ? 'uninstalled bot' : 'uninstalled a bot',
  AuditActionType.guildImportedFromDiscord =>
    'imported this server from Discord',
  AuditActionType.guildSyncedFromDiscord => 'synced this server from Discord',
  AuditActionType.messagePinned => 'pinned a message',
  AuditActionType.messageUnpinned => 'unpinned a message',
  AuditActionType.emojiCreated => 'added an emoji',
  AuditActionType.emojiDeleted => 'deleted an emoji',
  AuditActionType.autoModConfigUpdated => 'updated auto-moderation',
  // Note the actor here is the member who tripped auto-mod, not a moderator -
  // phrased passively so the row doesn't read as if they moderated someone.
  AuditActionType.autoModMessageBlocked =>
    hasTarget
        ? 'had a message blocked in'
        : 'had a message blocked by auto-mod',
  AuditActionType.onboardingConfigUpdated => 'updated onboarding',
  AuditActionType.scheduledEventCreated => 'created an event',
  AuditActionType.scheduledEventUpdated => 'updated an event',
  AuditActionType.scheduledEventCancelled => 'cancelled an event',
  AuditActionType.scheduledEventDeleted => 'deleted an event',
  AuditActionType.templateCreated => 'created a server template',
  AuditActionType.guildCreatedFromTemplate =>
    'created this server from a template',
  AuditActionType.channelFollowCreated => 'followed a channel',
  AuditActionType.channelFollowRemoved => 'unfollowed a channel',
  AuditActionType.unknown => '',
};

/// Turns a raw server action name into something readable - `EmojiCreated`
/// becomes `Emoji Created`. Used for action types this client has no label
/// for, so a new server-side action shows up as itself rather than as an
/// anonymous "did something".
String _titleCaseAction(String raw) => raw
    .replaceAllMapped(
      RegExp(r'(?<=[a-z0-9])([A-Z])'),
      (match) => ' ${match[1]}',
    )
    .trim();

/// `{"targetUserId": "...", "reason": "spam"}` renders as `Reason: spam`
/// rather than dumping raw camelCase JSON keys at the moderator. Ids are
/// dropped - they're opaque and the row already resolves the target.
String? _metadataSummary(String? metadata) {
  if (metadata == null || metadata.isEmpty) return null;
  try {
    final decoded = jsonDecode(metadata);
    if (decoded is! Map) return null;
    final parts = <String>[];
    for (final entry in decoded.entries) {
      final key = entry.key.toString();
      final value = entry.value;
      if (value == null) continue;
      if (key.toLowerCase().endsWith('id')) continue;
      final label = _titleCaseAction(
        key.isEmpty ? key : key[0].toUpperCase() + key.substring(1),
      );
      parts.add('$label: $value');
    }
    return parts.isEmpty ? null : parts.join(' · ');
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
    if (mounted) setState(() => _error = null);
    try {
      final entries = await getIt<GuildRepository>().getAuditLog(
        widget.guildId,
      );
      if (mounted) setState(() => _entries = entries);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not load the audit log.');
    }
  }

  /// Resolves [targetId] to a display name from the cached guild. Returns
  /// null when the role/channel is gone - deleted targets are exactly what an
  /// audit log is full of, so the row falls back to its generic phrasing.
  String? _cachedTargetName(_TargetKind kind, String targetId) {
    final guild = getIt<GuildRepository>().cachedById(widget.guildId);
    if (guild == null) return null;
    return switch (kind) {
      _TargetKind.role =>
        guild.roles.where((r) => r.id == targetId).firstOrNull?.name,
      _TargetKind.channel =>
        guild.channels.where((c) => c.id == targetId).firstOrNull?.name,
      _TargetKind.category =>
        guild.categories.where((c) => c.id == targetId).firstOrNull?.name,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return LoadFailureView(message: _error!, onRetry: _load);
    }
    final entries = _entries;
    if (entries == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (entries.isEmpty) {
      return const Center(child: Text('No activity yet.'));
    }

    return RefreshIndicator.adaptive(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
        itemCount: entries.length,
        itemBuilder: (context, index) => _AuditRow(
          entry: entries[index],
          cachedTargetName: _cachedTargetName,
        ),
      ),
    );
  }
}

class _AuditRow extends StatelessWidget {
  const _AuditRow({required this.entry, required this.cachedTargetName});

  final AuditLogEntryDto entry;
  final String? Function(_TargetKind kind, String targetId) cachedTargetName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = _metadataSummary(entry.metadata);
    final kind = _targetKind(entry.actionType);
    final targetId = entry.targetId;

    final resolvedName =
        targetId == null || kind == _TargetKind.none || kind == _TargetKind.user
        ? null
        : cachedTargetName(kind, targetId);

    // User targets resolve asynchronously, so the phrase is built knowing a
    // name is coming even before it arrives.
    final hasTarget =
        targetId != null && (kind == _TargetKind.user || resolvedName != null);

    return ListTile(
      isThreeLine: summary != null,
      title: ProfileResolver(
        userId: entry.actorUserId,
        builder: (context, actor) => Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: actor?.userName ?? entry.actorUserId,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._actionSpans(context, hasTarget, resolvedName, kind, targetId),
            ],
          ),
        ),
      ),
      subtitle: summary != null
          ? Text(
              summary,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            )
          : null,
      trailing: entry.createdAt != null
          ? Text(
              formatRelativeDateTime(entry.createdAt!),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            )
          : null,
    );
  }

  List<InlineSpan> _actionSpans(
    BuildContext context,
    bool hasTarget,
    String? resolvedName,
    _TargetKind kind,
    String? targetId,
  ) {
    final theme = Theme.of(context);

    if (entry.actionType == AuditActionType.unknown) {
      // No friendly label for this action - show the server's own name for it
      // instead of the old catch-all "did something", which made every
      // unrecognised action look identical.
      final raw = _titleCaseAction(entry.rawActionType);
      if (raw.isEmpty) return const [TextSpan(text: ' did something')];
      return [
        const TextSpan(text: ' performed '),
        TextSpan(
          text: raw,
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
          ),
        ),
      ];
    }

    final phrase = _describeKnown(entry.actionType, hasTarget);
    if (!hasTarget) return [TextSpan(text: ' $phrase')];

    return [
      TextSpan(text: ' $phrase '),
      if (kind == _TargetKind.user)
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: ProfileResolver(
            userId: targetId!,
            builder: (context, target) => Text(
              target?.userName ?? 'a member',
              style: DefaultTextStyle.of(
                context,
              ).style.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        )
      else
        TextSpan(
          text: kind == _TargetKind.channel
              ? '#$resolvedName'
              : resolvedName ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
    ];
  }
}
