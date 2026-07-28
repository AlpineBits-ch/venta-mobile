import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/status_colors_extension.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../data/guild_repository.dart';
import '../../data/models/guild_member_dto.dart';
import '../../data/models/role_dto.dart';

/// Read-only member list — nickname/username, roles, presence. Full member
/// management (kick/ban/mute/role assignment) is a fast-follow; this pass
/// covers browsing who's in the server.
class GuildMembersScreen extends StatefulWidget {
  const GuildMembersScreen({super.key, required this.guildId});

  final String guildId;

  @override
  State<GuildMembersScreen> createState() => _GuildMembersScreenState();
}

class _GuildMembersScreenState extends State<GuildMembersScreen> {
  List<GuildMemberDto>? _members;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final members = await getIt<GuildRepository>().getMembers(widget.guildId);
      if (mounted) setState(() => _members = members);
    } catch (e, st) {
      debugPrint('guild members load failed: $e\n$st');
      if (mounted) setState(() => _error = 'Could not load members.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final members = _members;
    return Scaffold(
      appBar: AppBar(title: const Text('Members')),
      body: _error != null
          ? Center(child: Text(_error!))
          : members == null
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    final displayName = member.nickname ?? member.profile?.userName ?? 'Unknown';
                    final roleNames = member.roleMembers
                        .map((rm) => rm.role)
                        .where((role) => role.type != RoleType.everyone)
                        .map((role) => role.name)
                        .join(', ');
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: context.statusColors.hover,
                        backgroundImage: member.profile?.avatarUrl != null
                            ? NetworkImage(member.profile!.avatarUrl!)
                            : null,
                        child: member.profile?.avatarUrl == null
                            ? Text(displayName.isNotEmpty ? displayName[0].toUpperCase() : '?')
                            : null,
                      ),
                      title: Text(displayName),
                      subtitle: roleNames.isNotEmpty
                          ? Text(roleNames, style: theme.textTheme.labelSmall)
                          : null,
                    );
                  },
                ),
    );
  }
}
