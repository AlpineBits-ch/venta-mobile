import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/di/injector.dart';
import '../../../../../core/theme/widget_styles.dart';
import '../../../../household/presentation/widgets/household_widgets.dart';
import '../../../data/guild_repository.dart';
import '../../../data/models/guild_permissions.dart';
import '../../../data/models/invite_dto.dart';

/// The guild's join links.
///
/// **Gated on `ManageGuild`.** The list endpoint used to take `ManageChannel`,
/// which was the wrong grant twice over: channel-scoped where the list is
/// guild-scoped, and held by moderators who are not trusted with the guild's
/// entire set of live join credentials. A channel moderator who could open this
/// screen yesterday gets a `403` today, so the screen says so rather than
/// showing them a wall.
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
  bool _includeRevoked = false;

  /// Null until the read lands. Everything gated on it stays hidden meanwhile,
  /// which is the right way round: the server enforces all of this on every
  /// write regardless, so a briefly-missing button costs a moment and a
  /// briefly-present one costs a `403` the user did not ask for.
  GuildPermissions? _permissions;

  bool get _canManageGuild => _permissions?.has('ManageGuild') ?? false;

  bool get _canManageChannels => _permissions?.has('ManageChannel') ?? false;

  bool get _canCreateInvite => _permissions?.has('CreateInvite') ?? false;

  /// `ManageGuild` anywhere in the guild, **or** `ManageChannel` on the channel
  /// this invite lands on - which is how a channel moderator withdraws a link
  /// into their own channel without being handed the guild.
  ///
  /// An invite naming no channel has no channel to hold `ManageChannel` on, so
  /// only `ManageGuild` will do. Rendering the button anyway would put a `403`
  /// behind it.
  ///
  /// Note this client only ever resolves guild-level effective permissions -
  /// per-channel overwrites are modelled but never applied - so the
  /// `ManageChannel` half is checked guild-wide here. That is a superset of what
  /// the server will accept for a channel the caller holds nothing on, which is
  /// why the failure path below still has to say something useful.
  bool _canRevoke(InviteDto invite) =>
      _canManageGuild ||
      (invite.isRevocableByChannelModerator && _canManageChannels);

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    try {
      final repository = getIt<GuildRepository>();
      final guild = repository.cachedById(widget.guildId);
      final self = await repository.getOwnMember(widget.guildId);
      if (!mounted) return;
      setState(
        () => _permissions = self.effectivePermissions(guild?.ownerId ?? ''),
      );
      if (_canManageGuild) await _load();
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not check your permissions here.');
      }
    }
  }

  Future<void> _load() async {
    try {
      final invites = await getIt<GuildRepository>().getInvites(
        widget.guildId,
        includeRevoked: _includeRevoked,
      );
      if (mounted) {
        setState(() {
          _invites = invites;
          _error = null;
        });
      }
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

    if (_permissions == null && _error == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    // Said plainly rather than shown as a failed load. A moderator who lost
    // this screen deserves to know why, not to watch it fail.
    if (!_canManageGuild && _error == null) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Center(
          child: Text(
            'You need Manage Server to see this server\'s invites.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      );
    }

    if (_error != null) return Center(child: Text(_error!));
    final invites = _invites;
    if (invites == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    return Column(
      children: [
        if (_canCreateInvite)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _creating ? null : _openCreateSheet,
                icon: const Icon(Icons.add_link),
                label: const Text('Create invite'),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Show revoked',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              Switch.adaptive(
                value: _includeRevoked,
                onChanged: (value) {
                  setState(() {
                    _includeRevoked = value;
                    _invites = null;
                  });
                  _load();
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: invites.isEmpty
              ? const Center(child: Text('No active invites.'))
              : ListView.builder(
                  itemCount: invites.length,
                  itemBuilder: (context, index) =>
                      _inviteTile(theme, invites[index]),
                ),
        ),
      ],
    );
  }

  Widget _inviteTile(ThemeData theme, InviteDto invite) {
    // Rendered from the server's verdict and nothing else. Every read path
    // derives it now - revoked, expired by clock, expired by use count, or a
    // consumed one-time invite, which is the case no client could ever have got
    // right on its own because there is no `maxUses` to compare against.
    final badge = invite.state.badgeLabel;
    final revoked = invite.state == InviteState.revoked;

    return ListTile(
      title: Text(
        invite.code,
        style: TextStyle(
          fontFamily: 'monospace',
          decoration: revoked ? TextDecoration.lineThrough : null,
          color: badge == null
              ? null
              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            [
              switch (invite.type) {
                InviteType.permanent => 'Permanent',
                InviteType.oneTime => 'One-time',
                InviteType.unknown => 'Invite',
              },
              if (invite.maxUses != null)
                '${invite.useCount}/${invite.maxUses} uses'
              else
                '${invite.useCount} use${invite.useCount == 1 ? '' : 's'}',
              if (invite.temporary) 'Temporary',
              if (invite.targetType == InviteTargetType.voiceChannel) 'Voice',
              if (badge != null) badge,
            ].join(' · '),
            style: theme.textTheme.labelSmall?.copyWith(
              color: badge == null ? null : theme.colorScheme.error,
            ),
          ),
          // A user id, not a profile - Guild owns neither usernames nor
          // avatars, so this hydrates through the same cache message authors
          // do. Null for every invite minted before attribution existed and for
          // anything a system path created, which is why the row simply has no
          // second line rather than saying "unknown".
          if (invite.inviterId != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Created by ', style: theme.textTheme.labelSmall),
                MemberName(
                  userId: invite.inviterId!,
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.copy_outlined),
            onPressed: () => _copy(invite),
          ),
          // A revoked invite has nothing left to revoke, and the route is
          // idempotent rather than an error - but offering the button again
          // says the row is live when it is not.
          if (!revoked && _canRevoke(invite))
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _revoke(invite),
            ),
        ],
      ),
    );
  }

  Future<void> _openCreateSheet() async {
    final options = await showModalBottomSheet<_CreateInviteOptions>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _CreateInviteSheet(),
    );
    if (options == null || !mounted) return;
    await _create(options);
  }

  Future<void> _create(_CreateInviteOptions options) async {
    setState(() => _creating = true);
    try {
      await getIt<GuildRepository>().createInvite(
        widget.guildId,
        type: options.type,
        expiresAt: options.expiresAt,
        maxUses: options.maxUses,
      );
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

/// What the create sheet collected.
class _CreateInviteOptions {
  const _CreateInviteOptions({
    required this.type,
    this.expiresAt,
    this.maxUses,
  });

  final InviteType type;

  /// Null means never.
  final DateTime? expiresAt;

  /// Null means unlimited. Never zero - the server refuses it with a `400`,
  /// because an invite that is exhausted the moment it exists is a link
  /// somebody is about to share.
  final int? maxUses;
}

/// Discord's two dropdowns: how long the link lasts, and how many people it
/// admits. Both were accepted by the endpoint long before anything sent them.
class _CreateInviteSheet extends StatefulWidget {
  const _CreateInviteSheet();

  @override
  State<_CreateInviteSheet> createState() => _CreateInviteSheetState();
}

class _CreateInviteSheetState extends State<_CreateInviteSheet> {
  /// Null is "never", and is the entry Discord makes you choose deliberately.
  Duration? _expiresIn = const Duration(days: 7);

  /// Null is "no limit". `0` is not an option and never will be.
  int? _maxUses;

  bool _oneTime = false;

  static const _durations = <({String label, Duration? value})>[
    (label: '30 minutes', value: Duration(minutes: 30)),
    (label: '1 hour', value: Duration(hours: 1)),
    (label: '6 hours', value: Duration(hours: 6)),
    (label: '12 hours', value: Duration(hours: 12)),
    (label: '1 day', value: Duration(days: 1)),
    (label: '7 days', value: Duration(days: 7)),
    (label: '30 days', value: Duration(days: 30)),
    (label: 'Never', value: null),
  ];

  static const _useLimits = <({String label, int? value})>[
    (label: 'No limit', value: null),
    (label: '1 use', value: 1),
    (label: '5 uses', value: 5),
    (label: '10 uses', value: 10),
    (label: '25 uses', value: 25),
    (label: '50 uses', value: 50),
    (label: '100 uses', value: 100),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.l,
        right: AppSpacing.l,
        top: AppSpacing.l,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.l,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Create invite', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.l),
          DropdownButtonFormField<Duration?>(
            initialValue: _expiresIn,
            decoration: const InputDecoration(labelText: 'Expire after'),
            items: [
              for (final option in _durations)
                DropdownMenuItem(
                  value: option.value,
                  child: Text(option.label),
                ),
            ],
            onChanged: (value) => setState(() => _expiresIn = value),
          ),
          const SizedBox(height: AppSpacing.m),
          DropdownButtonFormField<int?>(
            initialValue: _maxUses,
            decoration: const InputDecoration(
              labelText: 'Max number of uses',
            ),
            items: [
              for (final option in _useLimits)
                DropdownMenuItem(
                  value: option.value,
                  child: Text(option.label),
                ),
            ],
            onChanged: (value) => setState(() => _maxUses = value),
          ),
          const SizedBox(height: AppSpacing.s),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('One-time link'),
            subtitle: const Text('Stops working after the first person joins.'),
            value: _oneTime,
            onChanged: (value) => setState(() => _oneTime = value),
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: AppSpacing.s),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(
                  _CreateInviteOptions(
                    type: _oneTime ? InviteType.oneTime : InviteType.permanent,
                    // Sent as an absolute instant, resolved here rather than on
                    // the server, so "7 days" means seven days from the moment
                    // the button was pressed.
                    expiresAt: _expiresIn == null
                        ? null
                        : DateTime.now().toUtc().add(_expiresIn!),
                    maxUses: _maxUses,
                  ),
                ),
                child: const Text('Create'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
