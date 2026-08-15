import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/network/api_error.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/button_progress_indicator.dart';
import '../../../../core/widgets/load_failure_view.dart';
import '../../data/guild_repository.dart';
import '../../data/models/guild_emoji_dto.dart';
import '../../data/models/onboarding_dto.dart';
import '../widgets/onboarding_prompt_view.dart';

/// Discord's "Channels & Roles" - where a member changes the onboarding
/// answers that gave them roles and channel access, at any time after joining.
///
/// Covers *every* prompt, including those with `inOnboarding: false`, which
/// exist only here and never appear in the join flow.
class ChannelsAndRolesScreen extends StatefulWidget {
  const ChannelsAndRolesScreen({super.key, required this.guildId});

  final String guildId;

  @override
  State<ChannelsAndRolesScreen> createState() => _ChannelsAndRolesScreenState();
}

class _ChannelsAndRolesScreenState extends State<ChannelsAndRolesScreen> {
  List<OnboardingPromptDto>? _prompts;
  List<GuildEmojiDto>? _guildEmojis;
  final Map<String, Set<String>> _answers = {};
  Map<String, Set<String>> _saved = {};
  bool _loadFailed = false;
  bool _saving = false;
  String? _error;

  /// Nothing to save until a pick actually differs from what the server has.
  bool get _dirty {
    if (_prompts == null) return false;
    for (final entry in _answers.entries) {
      final before = _saved[entry.key] ?? const <String>{};
      if (before.length != entry.value.length ||
          !before.containsAll(entry.value)) {
        return true;
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() => _loadFailed = false);
    try {
      final prompts = await getIt<GuildRepository>().getOnboardingPrompts(
        widget.guildId,
      );
      if (!mounted) return;
      final selections = {
        for (final prompt in prompts)
          if (prompt.id != null)
            prompt.id!: {
              for (final option in prompt.options)
                if (option.selected && option.id != null) option.id!,
            },
      };
      setState(() {
        _prompts = [...prompts]
          ..sort((a, b) => a.position.compareTo(b.position));
        _saved = selections;
        _answers
          ..clear()
          ..addAll({
            for (final entry in selections.entries) entry.key: {...entry.value},
          });
      });
      final emojis = await getIt<GuildRepository>().getEmojis(widget.guildId);
      if (mounted) setState(() => _guildEmojis = emojis);
    } catch (_) {
      if (mounted) setState(() => _loadFailed = _prompts == null);
    }
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      // Full replace across all prompts: a prompt left out counts as "nothing
      // selected" and has its grants revoked, so every prompt is sent, even
      // the empty ones.
      await getIt<GuildRepository>().updateOwnOnboardingResponses(
        widget.guildId,
        [
          for (final prompt in _prompts ?? const <OnboardingPromptDto>[])
            if (prompt.id != null)
              OnboardingResponseDto(
                promptId: prompt.id!,
                optionIds: (_answers[prompt.id!] ?? const <String>{}).toList(),
              ),
        ],
      );
      if (!mounted) return;
      setState(
        () => _saved = {
          for (final entry in _answers.entries) entry.key: {...entry.value},
        },
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saved.')));
    } catch (error) {
      if (mounted) {
        setState(
          () => _error =
              apiErrorMessage(error) ?? 'Could not save those changes.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prompts = _prompts;
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(
          fallbackLocation: RoutePaths.serverPath(widget.guildId),
        ),
        title: const Text('Channels & Roles'),
      ),
      body: _loadFailed
          ? LoadFailureView(
              message: 'Couldn\'t load these options.',
              onRetry: _load,
            )
          : prompts == null
          ? const Center(child: CircularProgressIndicator.adaptive())
          : prompts.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Text(
                  'This server doesn\'t offer any self-assignable roles or '
                  'channels.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.m,
                      AppSpacing.m,
                      AppSpacing.m,
                      AppSpacing.xl,
                    ),
                    children: [
                      Text(
                        'Pick what you\'re into - your choices add roles and '
                        'open up channels. Unpicking one takes that access '
                        'away again.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.l),
                      for (final prompt in prompts) ...[
                        OnboardingPromptView(
                          prompt: prompt,
                          guild: getIt<GuildRepository>().cachedById(
                            widget.guildId,
                          ),
                          guildEmojis: _guildEmojis,
                          selectedOptionIds:
                              _answers[prompt.id ?? ''] ?? const {},
                          onChanged: (selection) => setState(() {
                            final id = prompt.id;
                            if (id != null) _answers[id] = selection;
                          }),
                        ),
                        const SizedBox(height: AppSpacing.l),
                      ],
                    ],
                  ),
                ),
                // Sticky rather than parked at the end of the list: with
                // several questions the save action would otherwise sit below
                // the fold exactly when someone has just changed something.
                if (_dirty || _error != null)
                  Material(
                    elevation: 8,
                    color: theme.colorScheme.surface,
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.m),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_error != null) ...[
                              Text(
                                _error!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.s),
                            ],
                            FilledButton(
                              onPressed: !_dirty || _saving ? null : _save,
                              child: _saving
                                  ? const ButtonProgressIndicator()
                                  : const Text('Save changes'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
