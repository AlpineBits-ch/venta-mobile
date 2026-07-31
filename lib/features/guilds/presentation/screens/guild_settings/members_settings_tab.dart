import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../core/di/injector.dart';
import '../../../../../core/theme/widget_styles.dart';
import '../../../../../core/widgets/user_avatar.dart';
import '../../../data/guild_repository.dart';
import '../../../data/models/guild_member_dto.dart';
import '../../../data/models/role_dto.dart';
import 'member_editor_screen.dart';

class MembersSettingsTab extends StatefulWidget {
  const MembersSettingsTab({super.key, required this.guildId});

  final String guildId;

  @override
  State<MembersSettingsTab> createState() => _MembersSettingsTabState();
}

class _MembersSettingsTabState extends State<MembersSettingsTab> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<GuildMemberDto>? _members;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load({String query = ''}) async {
    try {
      final members = query.isEmpty
          ? await getIt<GuildRepository>().getMembers(widget.guildId)
          : await getIt<GuildRepository>().searchMembers(widget.guildId, query);
      if (mounted) setState(() => _members = members);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not load members.');
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => _load(query: value.trim()),
    );
  }

  Future<void> _openMember(GuildMemberDto member) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            MemberEditorScreen(guildId: widget.guildId, member: member),
      ),
    );
    // The roles a member holds are only in the list payload, so a change made
    // in there is only reflected by re-listing.
    if (changed == true && mounted) {
      await _load(query: _searchController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: const InputDecoration(
              hintText: 'Search members',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: _error != null
              ? Center(child: Text(_error!))
              : _members == null
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _members!.length,
                  itemBuilder: (context, index) {
                    final member = _members![index];
                    final isBot = member.type == MemberType.bot;
                    final displayName =
                        member.nickname ??
                        member.profile?.userName ??
                        'Unknown';
                    final roleNames = [
                      for (final membership in member.roleMembers)
                        if (!membership.hasLapsed &&
                            membership.role.type != RoleType.everyone)
                          membership.role.name,
                    ];
                    return ListTile(
                      onTap: () => _openMember(member),
                      // `nickname` is guild-local and the avatar is not, so
                      // the fallback initial has to come from the profile -
                      // otherwise a nicknamed member's disc and their disc
                      // everywhere else show different letters.
                      leading: UserAvatar(
                        userId: member.userId,
                        fallbackLabel: member.profile?.userName ?? displayName,
                        // Without this the avatar swallows the tap and opens
                        // the public profile instead of the row's own action.
                        onTap: () => _openMember(member),
                      ),
                      subtitle: Text(
                        roleNames.isEmpty ? 'No roles' : roleNames.join(', '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              displayName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isBot) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppRadii.badge,
                                ),
                              ),
                              child: Text(
                                'BOT',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      // Kick used to live here as the row's only action,
                      // which left a guild without the Moderation module
                      // showing rows with nothing on them at all. It moved
                      // into MemberEditorScreen alongside the roles, and the
                      // row just says "there's more in here".
                      trailing: const Icon(Icons.chevron_right),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
