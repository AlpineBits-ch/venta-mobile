import 'package:flutter/material.dart';

import 'audit_log_settings_tab.dart';
import 'bans_settings_tab.dart';
import 'invites_settings_tab.dart';
import 'members_settings_tab.dart';
import 'overview_settings_tab.dart';
import 'roles_settings_tab.dart';

/// Discord-style server settings — tabbed, matching desktop's
/// `GuildSettingsModalComponent` nav (Overview/Roles/Members/Bans/Audit
/// Log/Invites; desktop's separate "Community" group with Discord Sync is
/// out of scope here). Reachable only from a `ManageGuild`-gated entry
/// point on `GuildDetailScreen`.
class GuildSettingsScreen extends StatelessWidget {
  const GuildSettingsScreen({super.key, required this.guildId});

  final String guildId;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Server Settings'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Roles'),
              Tab(text: 'Members'),
              Tab(text: 'Bans'),
              Tab(text: 'Audit Log'),
              Tab(text: 'Invites'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            OverviewSettingsTab(guildId: guildId),
            RolesSettingsTab(guildId: guildId),
            MembersSettingsTab(guildId: guildId),
            BansSettingsTab(guildId: guildId),
            AuditLogSettingsTab(guildId: guildId),
            InvitesSettingsTab(guildId: guildId),
          ],
        ),
      ),
    );
  }
}
