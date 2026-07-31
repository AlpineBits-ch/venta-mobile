import 'package:flutter/material.dart';

import '../../../../../core/di/injector.dart';
import '../../../../../core/format/date_time_format.dart';
import '../../../../../core/theme/hex_color.dart';
import '../../../../../core/theme/widget_styles.dart';
import '../../../../../core/widgets/user_avatar.dart';
import '../../../data/guild_repository.dart';
import '../../../data/models/guild_dto.dart';
import '../../../data/models/guild_features.dart';
import '../../../data/models/guild_member_dto.dart';
import '../../../data/models/guild_permissions.dart';
import '../../../data/models/role_dto.dart';

/// One member's roles - the other half of role management. The roles tab
/// answers "who has this role"; this answers "what does this person have",
/// which is how you actually think about it when someone asks for permission
/// to do one specific thing.
///
/// A member's permissions are never edited directly: they're the union of
/// their roles' bits (see [GuildMemberEffectivePermissions]), so the only
/// thing there is to change here is which roles they hold. The resulting
/// permission set is shown read-only underneath so the effect of a toggle is
/// visible without leaving the screen.
///
/// Pops `true` when anything was changed, so the members list knows to reload.
class MemberEditorScreen extends StatefulWidget {
  const MemberEditorScreen({
    super.key,
    required this.guildId,
    required this.member,
  });

  final String guildId;
  final GuildMemberDto member;

  @override
  State<MemberEditorScreen> createState() => _MemberEditorScreenState();
}

class _MemberEditorScreenState extends State<MemberEditorScreen> {
  /// Role ids the member holds, mirrored locally so a toggle lands
  /// immediately - there's no "get one member" endpoint to re-read after a
  /// write, and re-listing the whole guild per switch would be worse.
  late final Set<String> _assigned = {
    for (final membership in widget.member.roleMembers)
      if (!membership.hasLapsed) membership.role.id,
  };

  /// Expiry per role, for the guest-access grants that carry one. Kept
  /// alongside [_assigned] rather than derived from it so the countdown
  /// survives a toggle round-trip.
  late final Map<String, DateTime> _expiresAt = {
    for (final membership in widget.member.roleMembers)
      if (membership.isTemporary) membership.role.id: membership.expiresAt!,
  };

  /// Roles with a write in flight, so their switch can't be double-tapped.
  final _pending = <String>{};

  bool _changed = false;

  /// The guild is normally already cached by the time settings is open, but
  /// the role list is the whole screen - a cold cache would render "no roles
  /// yet" at a member who has some, so it's fetched rather than assumed.
  GuildDto? _guild;

  @override
  void initState() {
    super.initState();
    _guild = getIt<GuildRepository>().cachedById(widget.guildId);
    if (_guild == null) _loadGuild();
  }

  Future<void> _loadGuild() async {
    try {
      final guild = await getIt<GuildRepository>().fetchGuild(widget.guildId);
      if (mounted) setState(() => _guild = guild);
    } catch (_) {
      // Leaves the empty-roles copy in place; nothing here is destructive.
    }
  }

  String get _displayName =>
      widget.member.nickname ??
      widget.member.profile?.userName ??
      widget.member.userId;

  Future<void> _toggleRole(RoleDto role, bool value) async {
    setState(() {
      _pending.add(role.id);
      if (value) {
        _assigned.add(role.id);
      } else {
        _assigned.remove(role.id);
      }
    });
    try {
      final repository = getIt<GuildRepository>();
      if (value) {
        await repository.addRoleMember(role.id, widget.member.id);
      } else {
        await repository.removeRoleMember(role.id, widget.member.id);
      }
      _changed = true;
      if (mounted) {
        setState(() {
          _pending.remove(role.id);
          // A grant that's been revoked and re-granted is a plain one again.
          if (!value) _expiresAt.remove(role.id);
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _pending.remove(role.id);
        if (value) {
          _assigned.remove(role.id);
        } else {
          _assigned.add(role.id);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                // The server refuses a role at or above the actor's own
                // highest, which is the usual reason a toggle bounces back.
                ? 'Could not give $_displayName the ${role.name} role.'
                : 'Could not take the ${role.name} role away.',
          ),
        ),
      );
    }
  }

  Future<void> _kick() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kick member?'),
        content: Text('$_displayName can rejoin with a new invite.'),
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
            child: const Text('Kick'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await getIt<GuildRepository>().kickMember(
        widget.guildId,
        widget.member.id,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not kick that member.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final guild = _guild;
    final roles =
        (guild?.roles ?? const <RoleDto>[])
            .where((r) => r.type != RoleType.everyone)
            .toList()
          ..sort((a, b) => b.position.compareTo(a.position));
    final isOwner = guild?.ownerId == widget.member.userId;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_changed);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_displayName)),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.m),
          children: [
            Row(
              children: [
                UserAvatar(
                  userId: widget.member.userId,
                  radius: 28,
                  fallbackLabel:
                      widget.member.profile?.userName ?? _displayName,
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_displayName, style: theme.textTheme.titleMedium),
                      // Only when the nickname actually differs - a nickname
                      // set to the username renders the same name twice.
                      if (widget.member.profile != null &&
                          widget.member.profile!.userName != _displayName)
                        Text(
                          widget.member.profile!.userName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      if (isOwner)
                        Text(
                          'Owner',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.l),
            Text('Roles', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            if (roles.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
                child: Text(
                  'This server has no roles yet. Create one on the Roles tab '
                  'first.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              )
            else
              for (final role in roles)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  secondary: CircleAvatar(
                    radius: 8,
                    backgroundColor: role.color != null && role.color!.isNotEmpty
                        ? parseHexColor(role.color!)
                        : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  title: Text(role.name),
                  subtitle: _expiresAt.containsKey(role.id)
                      ? Text(
                          'Guest access, expires '
                          '${formatShortDateTime(_expiresAt[role.id]!.toLocal())}',
                        )
                      : null,
                  value: _assigned.contains(role.id),
                  onChanged: _pending.contains(role.id)
                      ? null
                      : (value) => _toggleRole(role, value),
                ),
            const SizedBox(height: AppSpacing.l),
            Text('What this adds up to', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _permissionSummary(roles),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            if (!isOwner) ...[
              const SizedBox(height: AppSpacing.s),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  // Recomputed from the switches above rather than read from
                  // the member's `permissions` string, so the effect of a
                  // toggle is visible without a round-trip. Read-only: a
                  // member's permissions are the union of their roles' and
                  // there is nothing per-member to set.
                  for (final flag in _effectiveFlags(roles))
                    Chip(
                      label: Text(GuildPermissions.labelFor(flag)),
                      labelStyle: theme.textTheme.labelSmall,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.l),
            // Kicking belongs to the Moderation module - a guild without it
            // has no kick affordance at all, owner included. The owner also
            // can't be kicked out of their own server.
            if ((guild?.hasFeature(GuildFeature.moderation) ?? true) &&
                !isOwner)
              OutlinedButton.icon(
                onPressed: _kick,
                icon: const Icon(Icons.person_remove_outlined),
                label: const Text('Kick from server'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _permissionSummary(List<RoleDto> roles) {
    if (_guild?.ownerId == widget.member.userId) {
      return 'Owner - holds every permission regardless of roles, and can\'t '
          'be kicked or have it taken away.';
    }
    final held = roles.where((r) => _assigned.contains(r.id)).toList();
    if (held.isEmpty) {
      return 'No roles beyond @everyone, so this member has only the '
          'baseline permissions.';
    }
    return '@everyone plus ${held.map((r) => r.name).join(', ')}:';
  }

  /// The member's permissions as the server will compute them: the union of
  /// `@everyone` and every role they hold. Filtered to the guild's modules,
  /// because a permission belonging to a disabled module is refused before
  /// roles are consulted and listing it here would be a lie.
  List<String> _effectiveFlags(List<RoleDto> roles) {
    var permissions = GuildPermissions.none;
    for (final role in _guild?.roles ?? const <RoleDto>[]) {
      if (role.type == RoleType.everyone || _assigned.contains(role.id)) {
        permissions = permissions | role.permissionsValue;
      }
    }
    final features = _guild?.featureSet ?? GuildFeatures.communityPreset;
    return [
      for (final flag in GuildPermissions.grantableFlagNamesFor(features))
        if (permissions.has(flag)) flag,
    ];
  }
}
