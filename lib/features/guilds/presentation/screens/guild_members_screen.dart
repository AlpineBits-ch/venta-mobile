import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/realtime/realtime_event.dart';
import '../../../../core/realtime/realtime_service.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/avatar_palette.dart';
import '../../../../core/theme/hex_color.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/skeleton_list_tile.dart';
import '../../../../core/widgets/status_dot.dart';
import '../../../profile/data/models/profile_dto.dart';
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
                _MemberTile(member: member, dimmed: section.dimmed),
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
  const _MemberTile({required this.member, required this.dimmed});

  final GuildMemberDto member;
  final bool dimmed;

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
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            backgroundColor: AvatarPalette.colorForUserId(member.userId),
            backgroundImage: member.profile?.avatarUrl != null
                ? CachedNetworkImageProvider(member.profile!.avatarUrl!)
                : null,
            child: member.profile?.avatarUrl == null
                ? Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white),
                  )
                : null,
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
