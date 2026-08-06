import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/realtime/realtime_event.dart';
import '../../../../core/realtime/realtime_service.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/hex_color.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/avatar_image.dart';
import '../../../../core/widgets/skeleton_list_tile.dart';
import '../../../../core/widgets/status_dot.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../friends/data/relationship_repository.dart';
import '../../../profile/data/models/profile_dto.dart';
import '../../../support/data/models/report_dto.dart';
import '../../../support/presentation/widgets/report_sheet.dart';
import '../../data/guild_repository.dart';
import '../../data/models/guild_member_dto.dart';
import '../../data/models/role_dto.dart';

/// Member sidebar - grouped by highest colored role (Discord convention),
/// then an Online/Offline fallback for members with no significant role.
/// Bots are flagged with a badge and treated as always-active for grouping.
/// Full member management (kick/ban/mute/role assignment) lives in the
/// server settings screen.
class GuildMembersScreen extends StatefulWidget {
  const GuildMembersScreen({super.key, required this.guildId});

  final String guildId;

  @override
  State<GuildMembersScreen> createState() => _GuildMembersScreenState();
}

class _GuildMembersScreenState extends State<GuildMembersScreen> {
  List<GuildMemberDto>? _members;
  String? _error;
  late final StreamSubscription<RealtimeEvent> _presenceSub;
  late final StreamSubscription<RealtimeEvent> _rosterSub;

  @override
  void initState() {
    super.initState();
    _load();
    _presenceSub = getIt<RealtimeService>().events
        .where((e) => e.name == 'guild.PresenceChanged')
        .listen(_onPresenceChanged);
    // Presence alone kept the dots live but left the roster stale - someone
    // joining, leaving, or being banned/kicked didn't show up until the
    // screen was reopened.
    _rosterSub = getIt<RealtimeService>().events
        .where(
          (e) =>
              const {
                'guild.MemberJoined',
                'guild.MemberLeft',
                'guild.MemberBanned',
                'guild.MemberKicked',
                'guild.MemberMovedOut',
                'guild.MemberMuted',
                'guild.MemberUnmuted',
              }.contains(e.name) &&
              e.stringField('guildId') == widget.guildId,
        )
        .listen((_) => _load());
  }

  @override
  void dispose() {
    unawaited(_presenceSub.cancel());
    unawaited(_rosterSub.cancel());
    super.dispose();
  }

  void _onPresenceChanged(RealtimeEvent event) {
    if (event.stringField('guildId') != widget.guildId) return;
    final userId = event.stringField('userId');
    final statusName = event.stringField('status');
    final members = _members;
    if (userId == null || statusName == null || members == null) return;
    final status = _parseOnlineStatus(statusName);
    setState(() {
      _members = [
        for (final member in members)
          if (member.userId == userId)
            member.copyWith(status: status)
          else
            member,
      ];
    });
  }

  static OnlineStatus _parseOnlineStatus(String wire) => switch (wire) {
    'Online' => OnlineStatus.online,
    'Idle' => OnlineStatus.idle,
    'DoNotDisturb' => OnlineStatus.doNotDisturb,
    'Hidden' => OnlineStatus.hidden,
    _ => OnlineStatus.offline,
  };

  Future<void> _load() async {
    try {
      final members = await getIt<GuildRepository>().getMembers(widget.guildId);
      if (mounted) setState(() => _members = members);
    } catch (e, st) {
      debugPrint('guild members load failed: $e\n$st');
      if (mounted) setState(() => _error = 'Could not load members.');
    }
  }

  /// Tapping a member: their profile, blocking them, and reporting them.
  ///
  /// The tile did nothing on tap before this, so the sheet is also what makes
  /// the roster useful - but the ordering inside it is the part that matters.
  /// Block is above Report and is the destructive-coloured one: it works
  /// immediately and needs nobody, where a report is a queue. A menu that only
  /// offers the queue leaves someone waiting on us while they are still being
  /// messaged.
  Future<void> _showMemberActions(GuildMemberDto member) async {
    final displayName =
        member.nickname ?? member.profile?.userName ?? 'this member';
    // Reporting or blocking yourself is not a thing; the server refuses the
    // first and the second is nonsense.
    final isSelf = member.userId == getIt<AuthRepository>().currentUserId;
    final isBlocked = isSelf
        ? false
        : await getIt<RelationshipRepository>()
              .isBlocked(member.userId)
              .catchError((_) => false);
    if (!mounted) return;

    final action = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('View profile'),
              onTap: () => Navigator.pop(context, 'profile'),
            ),
            if (!isSelf) ...[
              ListTile(
                leading: Icon(
                  Icons.block,
                  color: isBlocked ? null : Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  isBlocked ? 'Unblock' : 'Block',
                  style: isBlocked
                      ? null
                      : TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () => Navigator.pop(context, 'block'),
              ),
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: const Text('Report member'),
                onTap: () => Navigator.pop(context, 'report'),
              ),
            ],
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;

    switch (action) {
      case 'profile':
        context.push(RoutePaths.userProfilePath(member.userId));
      case 'block':
        await _toggleBlock(member.userId, displayName, isBlocked: isBlocked);
      case 'report':
        await showReportSheet(
          context,
          ReportTarget(
            targetUserId: member.userId,
            // A member report is a report on the account, not on the
            // membership - there is no per-guild subject for it.
            subjectKind: ReportSubjectKind.user,
            title: 'Report $displayName',
            displayName: displayName,
          ),
        );
    }
  }

  Future<void> _toggleBlock(
    String userId,
    String displayName, {
    required bool isBlocked,
  }) async {
    final relationships = getIt<RelationshipRepository>();
    if (isBlocked) {
      try {
        await relationships.unblock(userId);
        if (mounted) _toast('$displayName is unblocked.');
      } catch (_) {
        if (mounted) _toast('Could not unblock them.');
      }
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Block $displayName?'),
        content: const Text(
          'They won\'t be able to message you, call you, add you as a friend '
          'or mention you, and you won\'t see them either. They are not told.'
          '\n\nIf you are friends, that ends - unblocking later does not bring '
          'it back.',
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
            child: const Text('Block'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await relationships.block(userId);
      if (mounted) _toast('$displayName is blocked.');
    } catch (_) {
      if (mounted) _toast('Could not block them.');
    }
  }

  void _toast(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  static bool _isBot(GuildMemberDto member) => member.type == MemberType.bot;

  static bool _isActive(GuildMemberDto member) =>
      _isBot(member) ||
      (member.status != OnlineStatus.offline &&
          member.status != OnlineStatus.hidden);

  static RoleDto? _highestRole(GuildMemberDto member) {
    RoleDto? highest;
    for (final membership in member.roleMembers) {
      final role = membership.role;
      if (role.type == RoleType.everyone) continue;
      if (highest == null || role.position > highest.position) highest = role;
    }
    return highest;
  }

  static Color? _nameColor(GuildMemberDto member) {
    final accent = member.profile?.accentColor;
    if (accent != null && accent.isNotEmpty) return parseHexColor(accent);
    final roleColor = _highestRole(member)?.color;
    if (roleColor != null && roleColor.isNotEmpty)
      return parseHexColor(roleColor);
    return null;
  }

  List<_MemberSection> _buildSections(List<GuildMemberDto> members) {
    final roleGroups = <String, (RoleDto, List<GuildMemberDto>)>{};
    final onlineNoRole = <GuildMemberDto>[];
    final offlineNoRole = <GuildMemberDto>[];

    for (final member in members) {
      final role = _highestRole(member);
      if (role != null) {
        final entry = roleGroups.putIfAbsent(
          role.id,
          () => (role, <GuildMemberDto>[]),
        );
        entry.$2.add(member);
      } else if (_isActive(member)) {
        onlineNoRole.add(member);
      } else {
        offlineNoRole.add(member);
      }
    }

    int activeFirst(GuildMemberDto a, GuildMemberDto b) =>
        (_isActive(b) ? 1 : 0) - (_isActive(a) ? 1 : 0);

    final groups = roleGroups.values.toList()
      ..sort((a, b) => b.$1.position.compareTo(a.$1.position));

    final sections = <_MemberSection>[];
    for (final (role, roleMembers) in groups) {
      roleMembers.sort(activeFirst);
      sections.add(
        _MemberSection('${role.name} - ${roleMembers.length}', roleMembers),
      );
    }
    if (onlineNoRole.isNotEmpty) {
      sections.add(
        _MemberSection('Online - ${onlineNoRole.length}', onlineNoRole),
      );
    }
    if (offlineNoRole.isNotEmpty) {
      sections.add(
        _MemberSection(
          'Offline - ${offlineNoRole.length}',
          offlineNoRole,
          dimmed: true,
        ),
      );
    }
    return sections;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final members = _members;
    Widget body;
    if (_error != null) {
      body = Center(child: Text(_error!));
    } else if (members == null) {
      body = ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
        children: [for (var i = 0; i < 6; i++) const SkeletonListTile()],
      );
    } else {
      final sections = _buildSections(members);
      body = ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
        itemCount: sections.length,
        itemBuilder: (context, sectionIndex) {
          final section = sections[sectionIndex];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.m,
                  AppSpacing.m,
                  AppSpacing.m,
                  4,
                ),
                child: Text(
                  section.title.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              for (final member in section.members)
                _MemberTile(
                  member: member,
                  dimmed: section.dimmed,
                  onTap: () => _showMemberActions(member),
                ),
            ],
          );
        },
      );
    }
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(
          fallbackLocation: RoutePaths.serverPath(widget.guildId),
        ),
        title: const Text('Members'),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: KeyedSubtree(key: ValueKey(members == null), child: body),
      ),
    );
  }
}

class _MemberSection {
  _MemberSection(this.title, this.members, {this.dimmed = false});

  final String title;
  final List<GuildMemberDto> members;
  final bool dimmed;
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member, required this.dimmed, this.onTap});

  final GuildMemberDto member;
  final bool dimmed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBot = member.type == MemberType.bot;
    final displayName =
        member.nickname ?? member.profile?.userName ?? 'Unknown';
    final nameColor = _GuildMembersScreenState._nameColor(member);
    final baseColor = dimmed
        ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
        : null;

    return ListTile(
      onTap: onTap,
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          AvatarImage(
            userId: member.userId,
            imageUrl: member.profile?.avatarUrl,
            label: displayName,
            radius: AppRadii.avatarMedium,
          ),
          if (!isBot)
            Positioned(
              right: -2,
              bottom: -2,
              child: StatusDot(status: member.status),
            ),
        ],
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              displayName,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: nameColor ?? baseColor,
              ),
            ),
          ),
          if (isBot) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadii.badge),
              ),
              child: Text(
                'BOT',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 9,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
