import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/settings_tiles.dart';
import '../../../guilds/data/guild_repository.dart';
import '../../../guilds/data/models/guild_dto.dart';
import '../../data/models/guild_dm_preference_dto.dart';
import '../../data/models/privacy_settings_dto.dart';
import '../../data/privacy_repository.dart';

/// One switch per server: whether members of *that* server may DM you.
///
/// Only bites while the account's global DM policy is "Friends and server
/// members" - that is the one branch that consults shared servers at all. Under
/// the other three, nothing here can change any outcome, and the screen says so
/// at the top rather than presenting switches that quietly do nothing.
class GuildDmPrivacyScreen extends StatefulWidget {
  const GuildDmPrivacyScreen({super.key});

  @override
  State<GuildDmPrivacyScreen> createState() => _GuildDmPrivacyScreenState();
}

class _GuildDmPrivacyScreenState extends State<GuildDmPrivacyScreen> {
  List<GuildDto>? _guilds;
  PrivacySettingsDto? _settings;

  /// Guild id → the override, for guilds that have one. A guild missing here
  /// has no override and follows the global policy.
  final Map<String, bool> _overrides = {};

  final Set<String> _busy = {};
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    try {
      final privacy = getIt<PrivacyRepository>();
      final guildRepository = getIt<GuildRepository>();
      // `cached` is only the whole list once `fetch` has run - the cache has a
      // second writer that fills it a guild at a time, so "non-empty" is not
      // "loaded". This page can be reached cold, so it fetches.
      final guilds = guildRepository.hasFetchedList
          ? guildRepository.cached
          : await guildRepository.fetch();
      final settings = await privacy.ensureLoaded();
      final preferences = await privacy.getGuildDmPreferences();
      if (!mounted) return;
      setState(() {
        _guilds = guilds;
        _settings = settings;
        _overrides
          ..clear()
          ..addEntries(
            preferences.map((p) => MapEntry(p.guildId, p.allowDirectMessages)),
          );
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _set(GuildDto guild, bool allow) async {
    final previous = _overrides[guild.id];
    setState(() {
      _overrides[guild.id] = allow;
      _busy.add(guild.id);
    });
    try {
      await getIt<PrivacyRepository>().setGuildDmPreference(
        guildId: guild.id,
        allowDirectMessages: allow,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        if (previous == null) {
          _overrides.remove(guild.id);
        } else {
          _overrides[guild.id] = previous;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is GuildMembershipGoneException
                ? 'You are no longer in ${guild.name}.'
                : 'Could not update ${guild.name}.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy.remove(guild.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final guilds = _guilds;
    final settings = _settings;
    final applies =
        settings?.directMessagePolicy ==
        DirectMessagePolicy.friendsAndServerMembers;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: RoutePaths.privacy),
        title: const Text('Server message privacy'),
      ),
      body: switch ((_failed, guilds, settings)) {
        (true, _, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Could not load your servers.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.m),
                FilledButton(onPressed: _load, child: const Text('Try again')),
              ],
            ),
          ),
        ),
        (_, null, _) || (_, _, null) => const Center(
          child: CircularProgressIndicator(),
        ),
        (_, final List<GuildDto> list, final PrivacySettingsDto s) => ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.m,
            AppSpacing.m,
            AppSpacing.m,
            AppSpacing.xl,
          ),
          children: [
            if (!applies) ...[
              _NotAppliedBanner(policy: s.directMessagePolicy),
              const SizedBox(height: AppSpacing.l),
            ],
            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Center(
                  child: Text(
                    'You aren\'t in any servers.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                ),
              )
            else
              SettingsSection(
                label: 'Allow direct messages from',
                child: Column(
                  children: [
                    for (final guild in list)
                      SwitchListTile(
                        title: Text(guild.name),
                        // Absent means "no override", which follows the global
                        // policy - and under this policy that is "allowed".
                        value: _overrides[guild.id] ?? true,
                        onChanged: !applies || _busy.contains(guild.id)
                            ? null
                            : (v) => _set(guild, v),
                      ),
                  ],
                ),
              ),
            const SettingsFootnote(
              'Turning a server off stops people you only know through it from '
              'starting a conversation. Friends can always message you, and '
              'conversations you are already in keep working.',
            ),
          ],
        ),
      },
    );
  }
}

class _NotAppliedBanner extends StatelessWidget {
  const _NotAppliedBanner({required this.policy});

  final DirectMessagePolicy policy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = theme.colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: tint.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: tint.withValues(alpha: 0.7),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              'Your direct messages are set to "${policy.label}", so these '
              'per-server switches don\'t change anything right now. Set '
              'direct messages to "Friends and server members" on the Privacy '
              'page to use them.',
              style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
