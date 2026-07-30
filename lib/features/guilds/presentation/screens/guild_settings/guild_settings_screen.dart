import 'package:flutter/material.dart';

import '../../../../../core/routing/route_paths.dart';
import '../../../../../core/widgets/app_back_button.dart';
import 'audit_log_settings_tab.dart';
import 'auto_mod_settings_tab.dart';
import 'bans_settings_tab.dart';
import 'emoji_settings_tab.dart';
import 'invites_settings_tab.dart';
import 'members_settings_tab.dart';
import 'onboarding_settings_tab.dart';
import 'overview_settings_tab.dart';
import 'roles_settings_tab.dart';

/// Discord-style server settings - tabbed, matching desktop's
/// `GuildSettingsModalComponent` nav (Overview/Roles/Members/Bans/Audit
/// Log/Invites/Emoji; desktop's separate "Community" group with Discord
/// Sync is out of scope here). Reachable only from a `ManageGuild`-gated
/// entry point on `GuildDetailScreen`.
class GuildSettingsScreen extends StatelessWidget {
  const GuildSettingsScreen({super.key, required this.guildId});

  final String guildId;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 9,
      child: Scaffold(
        appBar: AppBar(
          leading: AppBackButton(
            fallbackLocation: RoutePaths.serverPath(guildId),
          ),
          title: const Text('Server Settings'),
          // The tab strip doesn't fit on a phone width, so it's scrollable -
          // this fade hints that without it, "Audit Log"/"Invites" just look
          // like they're cut off at the edge with no way to reach them.
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kTextTabBarHeight),
            child: ShaderMask(
              shaderCallback: (rect) => const LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black,
                  Colors.black,
                  Colors.transparent,
                ],
                stops: [0.0, 0.04, 0.92, 1.0],
              ).createShader(rect),
              blendMode: BlendMode.dstIn,
              child: const TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: 'Overview'),
                  Tab(text: 'Roles'),
                  Tab(text: 'Members'),
                  Tab(text: 'Bans'),
                  Tab(text: 'Audit Log'),
                  Tab(text: 'Invites'),
                  Tab(text: 'Emoji'),
                  Tab(text: 'Auto-Mod'),
                  Tab(text: 'Onboarding'),
                ],
              ),
            ),
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
            EmojiSettingsTab(guildId: guildId),
            AutoModSettingsTab(guildId: guildId),
            OnboardingSettingsTab(guildId: guildId),
          ],
        ),
      ),
    );
  }
}
