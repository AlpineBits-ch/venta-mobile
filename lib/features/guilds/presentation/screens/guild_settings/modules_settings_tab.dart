import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../core/di/injector.dart';
import '../../../../../core/network/api_error.dart';
import '../../../../../core/theme/widget_styles.dart';
import '../../../../../core/widgets/settings_tiles.dart';
import '../../../data/guild_repository.dart';
import '../../../data/models/guild_dto.dart';
import '../../../data/models/guild_features.dart';

/// What the guild *is* (its kind) and what it *has* (its modules).
///
/// Every toggle saves on the spot - there's no Save button, because each
/// module is independently meaningful and a half-applied set isn't a state
/// worth being able to hold.
class ModulesSettingsTab extends StatefulWidget {
  const ModulesSettingsTab({super.key, required this.guildId});

  final String guildId;

  @override
  State<ModulesSettingsTab> createState() => _ModulesSettingsTabState();
}

class _ModulesSettingsTabState extends State<ModulesSettingsTab> {
  GuildDto? _guild;
  bool _saving = false;
  String? _error;
  StreamSubscription<List<GuildDto>>? _guildsSub;

  @override
  void initState() {
    super.initState();
    _guild = getIt<GuildRepository>().cachedById(widget.guildId);
    _guildsSub = getIt<GuildRepository>().guildsStream.listen((guilds) {
      if (!mounted) return;
      final updated = guilds.where((g) => g.id == widget.guildId).firstOrNull;
      if (updated != null) setState(() => _guild = updated);
    });
  }

  @override
  void dispose() {
    unawaited(_guildsSub?.cancel());
    super.dispose();
  }

  Future<void> _save({GuildKind? kind, GuildFeatures? features}) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await getIt<GuildRepository>().updateGuild(
        widget.guildId,
        kind: kind,
        features: features,
      );
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = apiErrorMessage(error) ?? 'Could not save that.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _changeKind(GuildKind kind) async {
    final guild = _guild;
    if (guild == null || kind == guild.kind) return;
    // Sending `kind` on its own re-seeds the module set from that kind's
    // preset, which silently discards whatever the owner has customised. Ask
    // first, and offer the other option: relabel while keeping the modules,
    // which means sending both fields.
    final choice = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Make this a ${kind.label.toLowerCase()}?'),
        content: Text(
          'Switching to ${kind.label} can replace this '
          '${guild.kind.noun.toLowerCase()}\'s modules with '
          'that preset. Nothing is deleted either way - modules only hide '
          'things, and turning one back on brings it back intact.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop('keep'),
            child: const Text('Keep my modules'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop('reset'),
            child: const Text('Use the preset'),
          ),
        ],
      ),
    );
    if (choice == null || !mounted) return;
    await _save(
      kind: kind,
      // Sending the current set alongside the kind is what stops the server
      // re-seeding it.
      features: choice == 'keep' ? guild.featureSet : null,
    );
  }

  Future<void> _toggle(String feature, bool enabled) async {
    final guild = _guild;
    if (guild == null) return;
    await _save(features: guild.featureSet.withFlag(feature, enabled));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final guild = _guild;
    if (guild == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    final features = guild.featureSet;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.xl,
      ),
      children: [
        SettingsSection(
          label: 'This server is a',
          child: RadioGroup<GuildKind>(
            groupValue: guild.kind,
            onChanged: (value) {
              if (value != null && !_saving) unawaited(_changeKind(value));
            },
            child: Column(
              children: [
                for (final kind in GuildKind.values)
                  RadioListTile<GuildKind>.adaptive(
                    value: kind,
                    title: Text(kind.label),
                    subtitle: Text(
                      kind.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SettingsFootnote(
          'This only changes wording and which settings you see. What the '
          'server can actually do is the module list below.',
        ),
        const SizedBox(height: AppSpacing.l),
        SettingsSection(
          label: 'Modules',
          child: Column(
            children: [
              for (final module in GuildFeature.communityModules)
                SwitchListTile.adaptive(
                  title: Text(GuildFeature.labels[module] ?? module),
                  subtitle: GuildFeature.descriptions[module] == null
                      ? null
                      : Text(GuildFeature.descriptions[module]!),
                  value: features.has(module),
                  onChanged: _saving ? null : (value) => _toggle(module, value),
                ),
            ],
          ),
        ),
        const SettingsFootnote(
          'Turning a module off hides it and takes away its permissions - it '
          'never deletes anything. Channels of a type you switch off stay '
          'where they are; you just can\'t make new ones.',
        ),
        const SizedBox(height: AppSpacing.l),
        SettingsSection(
          label: 'Household',
          child: Column(
            children: [
              for (final module in GuildFeature.householdModules)
                SwitchListTile.adaptive(
                  title: Text(GuildFeature.labels[module] ?? module),
                  subtitle: GuildFeature.descriptions[module] == null
                      ? null
                      : Text(GuildFeature.descriptions[module]!),
                  value: features.has(module),
                  onChanged: _saving ? null : (value) => _toggle(module, value),
                ),
            ],
          ),
        ),
        SettingsFootnote(
          'The first five each add a kind of channel. The last three are about '
          'the whole house rather than one channel, and show up on the '
          '${(_guild?.kind.noun ?? 'server').toLowerCase()} itself.',
        ),
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.m),
          Text(
            _error!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}
