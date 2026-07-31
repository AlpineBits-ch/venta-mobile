import 'package:flutter/material.dart';

import '../../../../../core/di/injector.dart';
import '../../../../../core/routing/route_paths.dart';
import '../../../../../core/widgets/app_back_button.dart';
import '../../../../household/presentation/screens/house_settings_tab.dart';
import '../../../data/guild_repository.dart';
import '../../../data/models/guild_dto.dart';
import '../../../data/models/guild_features.dart';
import 'audit_log_settings_tab.dart';
import 'auto_mod_settings_tab.dart';
import 'bans_settings_tab.dart';
import 'emoji_settings_tab.dart';
import 'invites_settings_tab.dart';
import 'members_settings_tab.dart';
import 'modules_settings_tab.dart';
import 'onboarding_settings_tab.dart';
import 'overview_settings_tab.dart';
import 'roles_settings_tab.dart';

/// Discord-style server settings - tabbed, matching desktop's
/// `GuildSettingsModalComponent` nav. Reachable only from a
/// `ManageGuild`-gated entry point on `GuildDetailScreen`.
///
/// Which tabs exist depends on the guild's modules: a household has no Bans,
/// Audit Log, Auto-Mod or Onboarding tab at all. Hidden rather than disabled -
/// a tab you can't press is worse than one that isn't there. Overview,
/// Roles, Members, Invites and Modules are always present, because
/// `ManageGuild` is never gated: it's how a module gets switched back on.
class GuildSettingsScreen extends StatefulWidget {
  const GuildSettingsScreen({super.key, required this.guildId});

  final String guildId;

  @override
  State<GuildSettingsScreen> createState() => _GuildSettingsScreenState();
}

class _GuildSettingsScreenState extends State<GuildSettingsScreen> {
  GuildDto? _guild;

  @override
  void initState() {
    super.initState();
    _guild = getIt<GuildRepository>().cachedById(widget.guildId);
    // Toggling a module rebuilds this tab set, so the screen tracks the guild
    // rather than reading the cache once.
    getIt<GuildRepository>().guildsStream.listen((guilds) {
      if (!mounted) return;
      final updated = guilds.where((g) => g.id == widget.guildId).firstOrNull;
      if (updated != null) setState(() => _guild = updated);
    });
  }

  @override
  Widget build(BuildContext context) {
    final guild = _guild;
    final features = guild?.featureSet ?? GuildFeatures.communityPreset;

    final tabs = <({String label, Widget view})>[
      (label: 'Overview', view: OverviewSettingsTab(guildId: widget.guildId)),
      (label: 'Roles', view: RolesSettingsTab(guildId: widget.guildId)),
      (label: 'Members', view: MembersSettingsTab(guildId: widget.guildId)),
      if (features.has(GuildFeature.moderation)) ...[
        (label: 'Bans', view: BansSettingsTab(guildId: widget.guildId)),
        (
          label: 'Audit Log',
          view: AuditLogSettingsTab(guildId: widget.guildId),
        ),
      ],
      (label: 'Invites', view: InvitesSettingsTab(guildId: widget.guildId)),
      if (features.has(GuildFeature.emojis))
        (label: 'Emoji', view: EmojiSettingsTab(guildId: widget.guildId)),
      if (features.has(GuildFeature.autoMod))
        (label: 'Auto-Mod', view: AutoModSettingsTab(guildId: widget.guildId)),
      if (features.has(GuildFeature.onboarding))
        (
          label: 'Onboarding',
          view: OnboardingSettingsTab(guildId: widget.guildId),
        ),
      // The two household modules that aren't channels have to live
      // somewhere, and "the house itself" is the same shape of thing as
      // Overview - quiet hours and who's allowed in for the weekend.
      if (features.has(GuildFeature.quietHours) ||
          features.has(GuildFeature.guestAccess))
        (label: 'House', view: HouseSettingsTab(guildId: widget.guildId)),
      (label: 'Modules', view: ModulesSettingsTab(guildId: widget.guildId)),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          leading: AppBackButton(
            fallbackLocation: RoutePaths.serverPath(widget.guildId),
          ),
          // "Server Settings" on a household reads as a different product to
          // the one every other screen in it is describing - `GuildKind` has
          // carried the right noun for each kind since it was introduced.
          title: Text('${guild?.kind.noun ?? 'Server'} Settings'),
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
              child: TabBar(
                isScrollable: true,
                tabs: [for (final tab in tabs) Tab(text: tab.label)],
              ),
            ),
          ),
        ),
        body: TabBarView(children: [for (final tab in tabs) tab.view]),
      ),
    );
  }
}
