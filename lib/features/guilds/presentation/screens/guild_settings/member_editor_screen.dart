import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../core/di/injector.dart';
import '../../../../../core/network/api_error.dart';
import '../../../../../core/format/date_time_format.dart';
import '../../../../../core/theme/hex_color.dart';
import '../../../../../core/theme/widget_styles.dart';
import '../../../../../core/widgets/user_avatar.dart';
import '../../../../household/data/household_api.dart';
import '../../../../household/data/models/house_dto.dart';
import '../../../../household/data/money.dart';
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

  /// The *viewer's* permissions, not the edited member's. Only move-out needs
  /// them: it's the household's stand-in for a kick, and a flatmate who can't
  /// perform it shouldn't be offered it.
  GuildPermissions _myPermissions = GuildPermissions.none;

  @override
  void initState() {
    super.initState();
    _guild = getIt<GuildRepository>().cachedById(widget.guildId);
    if (_guild == null) _loadGuild();
    unawaited(_loadOwnPermissions());
  }

  Future<void> _loadOwnPermissions() async {
    try {
      final self = await getIt<GuildRepository>().getOwnMember(widget.guildId);
      final ownerId = _guild?.ownerId;
      if (!mounted) return;
      setState(
        () => _myPermissions = ownerId != null
            ? self.effectivePermissions(ownerId)
            : self.permissions,
      );
    } catch (_) {
      // Leaves move-out hidden. Every write here is enforced server-side, so
      // the cost of guessing wrong is a button that isn't offered.
    }
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

  /// A house, rather than a server: either it says so, or it has one of the
  /// household modules switched on. A Community guild keeps the kick it
  /// already had and gets no move-out, which would mean nothing there.
  bool get _isHousehold =>
      _guild?.kind == GuildKind.household ||
      GuildFeature.householdModules.any(
        (module) => _guild?.hasFeature(module) ?? false,
      );

  bool get _canMoveOut => _isHousehold && _myPermissions.has('ManageGuild');

  /// The role that means "lives here". A household is seeded with it holding
  /// the owner, it carries the four household manage bits, and its membership
  /// is the default chore rotation pool - so putting somebody in it is the
  /// deliberate act that separates a flatmate from a guest who joined by
  /// invite and is therefore never assigned the bins.
  static const _flatmatesRoleName = 'flatmates';

  bool _isFlatmatesRole(RoleDto role) =>
      _isHousehold &&
      role.type != RoleType.everyone &&
      role.name.toLowerCase() == _flatmatesRoleName;

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

  /// Moving somebody out - a household's only way of removing a member.
  ///
  /// The `Household` preset leaves Moderation off, which strips `KickMembers`
  /// for everybody including the owner, so without this a flatmate who moved
  /// out and stopped answering their phone stayed in the house forever. It is
  /// also not a kick with a nicer name: the person was carrying half the flat,
  /// and the server hands their unfinished chores on, takes their name off list
  /// items and refuses entirely while they still owe money.
  Future<void> _moveOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('$_displayName has moved out?'),
        content: const Text(
          'Their unfinished chores go to whoever\'s done the least, their name '
          'comes off anything on the lists, and chores that named them '
          'personally are paused for the house to pick up. What they already '
          'did stays counted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Move them out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _performMoveOut(writeOffBalances: false);
  }

  Future<void> _performMoveOut({required bool writeOffBalances}) async {
    try {
      final summary = await getIt<HouseholdApi>().moveOut(
        widget.guildId,
        userId: widget.member.userId,
        writeOffBalances: writeOffBalances,
      );
      if (!mounted) return;
      await _showMoveOutSummary(summary);
      if (mounted) Navigator.of(context).pop(true);
    } on MoveOutBlocked catch (blocked) {
      if (mounted) await _offerWriteOff(blocked);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              // The owner can't be moved out, and the role hierarchy applies
              // the same way it does to every other action against a member.
              apiErrorMessage(error) ?? 'Could not move that member out.',
            ),
          ),
        );
      }
    }
  }

  /// The `409`. Rendered as a decision rather than a failure: the house either
  /// chases the money or agrees to stop counting it, and this is the one moment
  /// it is made to choose.
  Future<void> _offerWriteOff(MoveOutBlocked blocked) async {
    final theme = Theme.of(context);
    final writeOff = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('$_displayName isn\'t settled up'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final balance in blocked.outstanding)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  balance.netMinor < 0
                      ? '$_displayName owes '
                            '${formatMinor(-balance.netMinor, balance.currency)}'
                      : 'The house owes $_displayName '
                            '${formatMinor(balance.netMinor, balance.currency)}',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Settle up on the ledger first, or write it off. A write-off '
              'doesn\'t pretend the money moved - it\'s the house agreeing to '
              'stop counting it, and it goes in the audit log as that.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Settle up first'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Write it off'),
          ),
        ],
      ),
    );
    if (writeOff != true || !mounted) return;
    await _performMoveOut(writeOffBalances: true);
  }

  /// Paused chores are the part that needs a person, so this is a dialog rather
  /// than a snackbar: a chore that named the leaver personally is now nobody's
  /// until the house decides.
  Future<void> _showMoveOutSummary(MoveOutSummaryDto summary) async {
    final lines = <String>[
      if (summary.choresReassigned > 0)
        '${summary.choresReassigned} '
            '${summary.choresReassigned == 1 ? 'chore' : 'chores'} handed to '
            'whoever\'s done the least',
      if (summary.choresDropped > 0)
        '${summary.choresDropped} dropped - the rota had nobody left for them',
      if (summary.choresPaused > 0)
        '${summary.choresPaused} paused because they were '
            '$_displayName\'s alone - somebody needs to pick them up',
      if (summary.listItemsUnassigned > 0)
        '${summary.listItemsUnassigned} list '
            '${summary.listItemsUnassigned == 1 ? 'item' : 'items'} unassigned',
      if (summary.balancesWrittenOff.isNotEmpty)
        '${summary.balancesWrittenOff.length} '
            '${summary.balancesWrittenOff.length == 1 ? 'balance' : 'balances'} '
            'written off',
    ];
    if (lines.isEmpty) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('$_displayName has moved out'),
        content: Text(lines.join('\n')),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
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
                  secondary: _isFlatmatesRole(role)
                      ? Icon(
                          Icons.home_rounded,
                          size: 18,
                          color: role.color != null && role.color!.isNotEmpty
                              ? parseHexColor(role.color!)
                              : theme.colorScheme.primary,
                        )
                      : CircleAvatar(
                          radius: 8,
                          backgroundColor:
                              role.color != null && role.color!.isNotEmpty
                              ? parseHexColor(role.color!)
                              : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.3,
                                ),
                        ),
                  title: Text(
                    _isFlatmatesRole(role)
                        ? '${role.name} - lives here'
                        : role.name,
                  ),
                  subtitle: _expiresAt.containsKey(role.id)
                      ? Text(
                          'Guest access, expires '
                          '${formatShortDateTime(_expiresAt[role.id]!.toLocal())}',
                        )
                      // Not decoration: this role is the default chore
                      // rotation pool, so switching it on is what puts
                      // somebody on the rota and hands them the manage bits.
                      : _isFlatmatesRole(role)
                      ? const Text(
                          'Takes a turn at the chores, and can manage the '
                          'lists, rota, ledger and guests',
                        )
                      : null,
                  isThreeLine: _isFlatmatesRole(role),
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
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
            // A house doesn't kick people, it says goodbye to them - and the
            // saying goodbye has to deal with the rota and the ledger they
            // were part of. `ManageGuild`, never feature-gated, so this shows
            // for a household whether or not Moderation happens to be on.
            if (_canMoveOut && !isOwner) ...[
              const SizedBox(height: AppSpacing.s),
              OutlinedButton.icon(
                onPressed: _moveOut,
                icon: const Icon(Icons.luggage_outlined),
                label: const Text('Moved out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Removes them from the house and hands on what they were '
                'carrying - chores, list items, and whatever they owe.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
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
