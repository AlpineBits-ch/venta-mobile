import 'package:flutter/material.dart';

import '../../../../../core/di/injector.dart';
import '../../../../../core/theme/widget_styles.dart';
import '../../../../../core/widgets/button_progress_indicator.dart';
import '../../../data/guild_repository.dart';
import '../../../data/models/channel_dto.dart';
import '../../../data/models/onboarding_dto.dart';

class OnboardingSettingsTab extends StatefulWidget {
  const OnboardingSettingsTab({super.key, required this.guildId});

  final String guildId;

  @override
  State<OnboardingSettingsTab> createState() => _OnboardingSettingsTabState();
}

class _OnboardingSettingsTabState extends State<OnboardingSettingsTab> {
  final _rulesController = TextEditingController();
  OnboardingConfigDto? _config;
  Set<String> _defaultChannelIds = {};
  bool _saving = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _rulesController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final config = await getIt<GuildRepository>().getOnboarding(
        widget.guildId,
      );
      if (mounted) _applyConfig(config);
    } catch (_) {
      // Keep the defaults already held in state.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyConfig(OnboardingConfigDto config) {
    setState(() {
      _config = config;
      _rulesController.text = config.rulesText ?? '';
      _defaultChannelIds = config.defaultChannelIds.toSet();
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final updated = await getIt<GuildRepository>().updateOnboarding(
        widget.guildId,
        OnboardingConfigDto(
          enabled: _config?.enabled ?? false,
          rulesText: _rulesController.text.trim(),
          defaultChannelIds: _defaultChannelIds.toList(),
        ),
      );
      if (mounted) {
        _applyConfig(updated);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Saved.')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save changes.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final theme = Theme.of(context);
    final config = _config ?? const OnboardingConfigDto();
    final channels =
        getIt<GuildRepository>()
            .cachedById(widget.guildId)
            ?.channels
            .where((c) => c.type != ChannelType.thread)
            .toList() ??
        const [];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.m),
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Onboarding'),
          subtitle: const Text(
            'New members must accept the rules before they can chat',
          ),
          value: config.enabled,
          onChanged: (value) =>
              setState(() => _config = config.copyWith(enabled: value)),
        ),
        const SizedBox(height: AppSpacing.l),
        Text('RULES', style: theme.textTheme.labelSmall),
        const SizedBox(height: AppSpacing.s),
        TextField(
          controller: _rulesController,
          minLines: 4,
          maxLines: 10,
          // Inert while onboarding is off - the rules and suggested channels
          // only apply once the master switch is on.
          enabled: config.enabled,
          decoration: const InputDecoration(
            hintText: '1. Be nice\n2. ...',
          ),
        ),
        if (channels.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.l),
          Text('SUGGESTED CHANNELS', style: theme.textTheme.labelSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Highlighted for new members - doesn\'t change who can see them.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final channel in channels)
                FilterChip(
                  label: Text('#${channel.name}'),
                  selected: _defaultChannelIds.contains(channel.id),
                  onSelected: config.enabled
                      ? (selected) => setState(() {
                          _defaultChannelIds = {..._defaultChannelIds};
                          if (selected) {
                            _defaultChannelIds.add(channel.id);
                          } else {
                            _defaultChannelIds.remove(channel.id);
                          }
                        })
                      : null,
                ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.l),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const ButtonProgressIndicator()
              : const Text('Save changes'),
        ),
      ],
    );
  }
}
