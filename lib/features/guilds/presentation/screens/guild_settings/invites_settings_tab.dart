import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/di/injector.dart';
import '../../../../../core/theme/widget_styles.dart';
import '../../../data/guild_repository.dart';
import '../../../data/models/invite_dto.dart';

class InvitesSettingsTab extends StatefulWidget {
  const InvitesSettingsTab({super.key, required this.guildId});

  final String guildId;

  @override
  State<InvitesSettingsTab> createState() => _InvitesSettingsTabState();
}

class _InvitesSettingsTabState extends State<InvitesSettingsTab> {
  List<InviteDto>? _invites;
  String? _error;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final invites = await getIt<GuildRepository>().getInvites(widget.guildId);
      if (mounted) setState(() => _invites = invites);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not load invites.');
    }
  }

  Future<void> _revoke(InviteDto invite) async {
    try {
      await getIt<GuildRepository>().deleteInvite(invite.id);
      await _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not revoke that invite.')),
        );
      }
    }
  }

  void _copy(InviteDto invite) {
    Clipboard.setData(
      ClipboardData(text: 'https://venta.gg/invite/${invite.code}'),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Link copied.')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_error != null) return Center(child: Text(_error!));
    final invites = _invites;
    if (invites == null)
      return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _creating
                      ? null
                      : () => _createTyped(InviteType.permanent),
                  child: const Text('Create permanent'),
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: OutlinedButton(
                  onPressed: _creating
                      ? null
                      : () => _createTyped(InviteType.oneTime),
                  child: const Text('Create one-time'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: invites.isEmpty
              ? const Center(child: Text('No active invites.'))
              : ListView.builder(
                  itemCount: invites.length,
                  itemBuilder: (context, index) {
                    final invite = invites[index];
                    final expired = invite.state == InviteState.expired;
                    return ListTile(
                      title: Text(
                        invite.code,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                      subtitle: Text(
                        [
                          invite.type == InviteType.permanent
                              ? 'Permanent'
                              : 'One-time',
                          '${invite.useCount} use${invite.useCount == 1 ? '' : 's'}',
                          if (expired) 'Expired',
                        ].join(' · '),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: expired ? theme.colorScheme.error : null,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.copy_outlined),
                            onPressed: () => _copy(invite),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _revoke(invite),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _createTyped(InviteType type) async {
    setState(() => _creating = true);
    try {
      await getIt<GuildRepository>().createInvite(widget.guildId, type: type);
      await _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not create an invite.')),
        );
      }
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }
}
