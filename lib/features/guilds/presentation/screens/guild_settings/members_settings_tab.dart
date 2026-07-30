import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../core/di/injector.dart';
import '../../../../../core/theme/widget_styles.dart';
import '../../../data/guild_repository.dart';
import '../../../data/models/guild_dto.dart';
import '../../../data/models/guild_features.dart';
import '../../../data/models/guild_member_dto.dart';

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

  Future<void> _kick(GuildMemberDto member) async {
    final displayName =
        member.nickname ?? member.profile?.userName ?? member.userId;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kick member?'),
        content: Text('$displayName can rejoin with a new invite.'),
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
    if (confirmed != true) return;
    try {
      await getIt<GuildRepository>().kickMember(widget.guildId, member.id);
      await _load(query: _searchController.text.trim());
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
                    return ListTile(
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
                      // Kicking belongs to the Moderation module - a guild
                      // without it has no kick affordance at all, owner
                      // included.
                      trailing:
                          (getIt<GuildRepository>()
                                  .cachedById(widget.guildId)
                                  ?.hasFeature(GuildFeature.moderation) ??
                              true)
                          ? IconButton(
                              icon: const Icon(Icons.person_remove_outlined),
                              tooltip: 'Kick',
                              onPressed: () => _kick(member),
                            )
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }
}
