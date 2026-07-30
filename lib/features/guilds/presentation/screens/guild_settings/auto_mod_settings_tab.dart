import 'package:flutter/material.dart';

import '../../../../../core/di/injector.dart';
import '../../../../../core/theme/widget_styles.dart';
import '../../../../../core/widgets/button_progress_indicator.dart';
import '../../../data/guild_repository.dart';
import '../../../data/models/auto_mod_config_dto.dart';

const _rateLimitOptions = <(int messages, int seconds)>[
  (5, 5),
  (10, 10),
  (5, 60),
  (10, 60),
];

class AutoModSettingsTab extends StatefulWidget {
  const AutoModSettingsTab({super.key, required this.guildId});

  final String guildId;

  @override
  State<AutoModSettingsTab> createState() => _AutoModSettingsTabState();
}

class _AutoModSettingsTabState extends State<AutoModSettingsTab> {
  final _wordController = TextEditingController();
  AutoModConfigDto? _config;
  bool _rateLimited = false;
  (int messages, int seconds) _rateLimit = _rateLimitOptions.first;
  bool _saving = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _wordController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final config = await getIt<GuildRepository>().getAutoMod(
        widget.guildId,
      );
      if (mounted) _applyConfig(config);
    } catch (_) {
      // Falls back to the defaults already held in state.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyConfig(AutoModConfigDto config) {
    final messages = config.maxMessagesPerInterval;
    final seconds = config.intervalSeconds;
    setState(() {
      _config = config;
      _rateLimited = messages != null && seconds != null;
      if (messages != null && seconds != null) {
        final match = _rateLimitOptions.firstWhere(
          (o) => o.$1 == messages && o.$2 == seconds,
          orElse: () => (messages, seconds),
        );
        _rateLimit = match;
      }
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final updated = await getIt<GuildRepository>().updateAutoMod(
        widget.guildId,
        AutoModConfigDto(
          enabled: _config?.enabled ?? false,
          blockedWords: _config?.blockedWords ?? const [],
          maxMessagesPerInterval: _rateLimited ? _rateLimit.$1 : null,
          intervalSeconds: _rateLimited ? _rateLimit.$2 : null,
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

  void _addWord() {
    final word = _wordController.text.trim();
    final config = _config;
    if (word.isEmpty || config == null) return;
    if (config.blockedWords.any((w) => w.toLowerCase() == word.toLowerCase())) {
      _wordController.clear();
      return;
    }
    setState(() {
      _config = config.copyWith(blockedWords: [...config.blockedWords, word]);
      _wordController.clear();
    });
  }

  void _removeWord(String word) {
    final config = _config;
    if (config == null) return;
    setState(() {
      _config = config.copyWith(
        blockedWords: config.blockedWords.where((w) => w != word).toList(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final theme = Theme.of(context);
    final config = _config ?? const AutoModConfigDto();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.m),
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Auto-moderation'),
          subtitle: const Text(
            'Block messages containing disallowed words or sent too quickly',
          ),
          value: config.enabled,
          onChanged: (value) =>
              setState(() => _config = config.copyWith(enabled: value)),
        ),
        const SizedBox(height: AppSpacing.l),
        Text('BLOCKED WORDS', style: theme.textTheme.labelSmall),
        const SizedBox(height: AppSpacing.s),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _wordController,
                autocorrect: false,
                enabled: config.enabled,
                onSubmitted: (_) => _addWord(),
                decoration: const InputDecoration(hintText: 'Add a word'),
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            IconButton.filled(
              onPressed: config.enabled ? _addWord : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        if (config.blockedWords.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final word in config.blockedWords)
                Chip(
                  label: Text(word),
                  onDeleted: config.enabled ? () => _removeWord(word) : null,
                ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.l),
        const Divider(),
        const SizedBox(height: AppSpacing.s),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Rate limit'),
          subtitle: const Text(
            'Cap how many messages a member can send at once',
          ),
          value: _rateLimited,
          // Both sections below the master switch stay visible but go inert
          // when auto-mod is off - editing them implied they'd take effect.
          onChanged: config.enabled
              ? (value) => setState(() => _rateLimited = value)
              : null,
        ),
        if (_rateLimited) ...[
          const SizedBox(height: AppSpacing.s),
          DropdownButtonFormField<(int, int)>(
            initialValue: _rateLimit,
            decoration: const InputDecoration(labelText: 'Limit'),
            items: [
              for (final option in _rateLimitOptions)
                DropdownMenuItem(
                  value: option,
                  child: Text('${option.$1} messages / ${option.$2}s'),
                ),
            ],
            onChanged: config.enabled
                ? (value) => setState(
                    () => _rateLimit = value ?? _rateLimitOptions.first,
                  )
                : null,
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
