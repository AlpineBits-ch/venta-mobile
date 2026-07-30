import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/network/api_error.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/button_progress_indicator.dart';
import '../../data/guild_repository.dart';
import '../../data/models/guild_dto.dart';
import '../../data/models/guild_emoji_dto.dart';
import '../../data/models/onboarding_dto.dart';
import '../widgets/onboarding_prompt_view.dart';

/// The join flow: rules, then one question per screen, then a short "you're
/// in" summary pointing at the guild's suggested channels.
///
/// Shown while `enabled && !completed`. It's dismissible on purpose - a
/// pending member can still read everything, they just can't post, and the
/// guild screen keeps a banner up to bring them back here (the composer's own
/// `403` is the backstop). Accepting lifts the restriction immediately.
class OnboardingWizardScreen extends StatefulWidget {
  const OnboardingWizardScreen({
    super.key,
    required this.guildId,
    required this.status,
  });

  final String guildId;
  final OnboardingStatusDto status;

  @override
  State<OnboardingWizardScreen> createState() => _OnboardingWizardScreenState();
}

class _OnboardingWizardScreenState extends State<OnboardingWizardScreen> {
  late final List<OnboardingPromptDto> _prompts = [...widget.status.prompts]
    ..sort((a, b) => a.position.compareTo(b.position));

  /// promptId -> chosen optionIds.
  final Map<String, Set<String>> _answers = {};

  int _index = 0;
  bool _submitting = false;
  bool _done = false;
  String? _error;
  List<GuildEmojiDto>? _guildEmojis;

  bool get _hasRules => (widget.status.rulesText ?? '').trim().isNotEmpty;

  /// The rules screen, when there is one, followed by one screen per prompt.
  int get _stepCount => (_hasRules ? 1 : 0) + _prompts.length;

  OnboardingPromptDto? get _currentPrompt {
    final promptIndex = _hasRules ? _index - 1 : _index;
    if (promptIndex < 0 || promptIndex >= _prompts.length) return null;
    return _prompts[promptIndex];
  }

  GuildDto? get _guild => getIt<GuildRepository>().cachedById(widget.guildId);

  @override
  void initState() {
    super.initState();
    unawaited(_loadEmojis());
  }

  Future<void> _loadEmojis() async {
    try {
      final emojis = await getIt<GuildRepository>().getEmojis(widget.guildId);
      if (mounted) setState(() => _guildEmojis = emojis);
    } catch (_) {
      // Options fall back to no emoji.
    }
  }

  /// A `required` prompt with nothing picked blocks the step, matching the
  /// server's own rule so the member never gets a `400` for it.
  bool get _canAdvance {
    final prompt = _currentPrompt;
    if (prompt == null || !prompt.isRequired) return true;
    return (_answers[prompt.id ?? '']?.isNotEmpty ?? false);
  }

  Future<void> _next() async {
    if (_index < _stepCount - 1) {
      setState(() {
        _index++;
        _error = null;
      });
      return;
    }
    await _submit();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await getIt<GuildRepository>().acceptOnboarding(
        widget.guildId,
        responses: [
          for (final entry in _answers.entries)
            if (entry.value.isNotEmpty)
              OnboardingResponseDto(
                promptId: entry.key,
                optionIds: entry.value.toList(),
              ),
        ],
      );
      if (mounted) setState(() => _done = true);
    } catch (error) {
      if (mounted) {
        setState(() => _error = _readableError(error));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  /// The server names the offending prompt by id; swapping in its title makes
  /// the message mean something to the person reading it.
  String _readableError(Object error) {
    final raw = apiErrorMessage(error);
    if (raw == null) return 'Could not finish - please try again.';
    var message = raw;
    for (final prompt in _prompts) {
      final id = prompt.id;
      if (id != null && message.contains(id)) {
        message = message.replaceAll(id, '"${prompt.title}"');
      }
    }
    return message;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_guild?.name ?? 'Welcome'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Not now',
          onPressed: _submitting
              ? null
              : () => Navigator.of(context).pop(_done),
        ),
        bottom: _done || _stepCount <= 1
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: LinearProgressIndicator(
                  value: (_index + 1) / _stepCount,
                  minHeight: 4,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
      ),
      body: SafeArea(child: _done ? _buildDone(theme) : _buildStep(theme)),
    );
  }

  Widget _buildStep(ThemeData theme) {
    final prompt = _currentPrompt;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: prompt != null
                ? OnboardingPromptView(
                    prompt: prompt,
                    guild: _guild,
                    guildEmojis: _guildEmojis,
                    selectedOptionIds: _answers[prompt.id ?? ''] ?? const {},
                    onChanged: (selection) => setState(() {
                      final id = prompt.id;
                      if (id != null) _answers[id] = selection;
                    }),
                  )
                : _buildRules(theme),
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
            child: Text(
              _error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Row(
            children: [
              if (_index > 0)
                TextButton(
                  onPressed: _submitting
                      ? null
                      : () => setState(() => _index--),
                  child: const Text('Back'),
                ),
              const Spacer(),
              FilledButton(
                onPressed: _submitting || !_canAdvance ? null : _next,
                child: _submitting
                    ? const ButtonProgressIndicator()
                    : Text(
                        _index < _stepCount - 1
                            ? 'Continue'
                            : _hasRules && _prompts.isEmpty
                            ? 'I understand and agree'
                            : 'Finish',
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRules(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.waving_hand_outlined, color: theme.colorScheme.primary),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Text(
                'Read the rules to get started',
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.l),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
          // Rules are plain text: whitespace and line breaks are the author's,
          // and nothing in them is markdown.
          child: Text(
            widget.status.rulesText ?? '',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildDone(ThemeData theme) {
    final guild = _guild;
    final suggested = [
      for (final id in widget.status.defaultChannelIds)
        ...?guild?.channels.where((c) => c.id == id),
    ];
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.l),
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.m),
              Text(
                'You\'re all set',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                suggested.isEmpty
                    ? 'You can post, react and join voice now.'
                    : 'Here\'s where to start.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              // Suggested channels are advisory only - they don't grant
              // visibility, that's what a prompt option's channels do.
              for (final channel in suggested)
                ListTile(
                  leading: const Icon(Icons.tag),
                  title: Text(channel.name),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).pop(true);
                    context.push(
                      RoutePaths.serverChannelPath(widget.guildId, channel.id),
                    );
                  },
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Done'),
            ),
          ),
        ),
      ],
    );
  }
}
