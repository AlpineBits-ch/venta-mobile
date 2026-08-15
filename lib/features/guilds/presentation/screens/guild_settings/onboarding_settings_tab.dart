import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../core/di/injector.dart';
import '../../../../../core/format/date_time_format.dart';
import '../../../../../core/network/api_error.dart';
import '../../../../../core/theme/widget_styles.dart';
import '../../../../../core/widgets/button_progress_indicator.dart';
import '../../../../../core/widgets/profile_resolver.dart';
import '../../../../../core/widgets/settings_tiles.dart';
import '../../../../../core/widgets/user_avatar.dart';
import '../../../data/guild_repository.dart';
import '../../../data/models/channel_dto.dart';
import '../../../data/models/onboarding_dto.dart';
import 'onboarding_prompt_editor_screen.dart';
import 'welcome_screen_settings_screen.dart';

/// Server Settings → Onboarding: the rules gate, the questions that
/// self-assign roles and channels, the welcome screen, and who hasn't
/// finished yet.
///
/// The config is one document with no per-prompt endpoints: `PUT` replaces it
/// wholesale, and anything missing from the payload is deleted server-side.
/// So this holds the entire config in state, edits it locally, and saves it in
/// one call - dropping an id would silently delete that prompt and every
/// member's answer to it.
class OnboardingSettingsTab extends StatefulWidget {
  const OnboardingSettingsTab({super.key, required this.guildId});

  final String guildId;

  @override
  State<OnboardingSettingsTab> createState() => _OnboardingSettingsTabState();
}

class _OnboardingSettingsTabState extends State<OnboardingSettingsTab> {
  final _rulesController = TextEditingController();
  OnboardingConfigDto _config = const OnboardingConfigDto();
  Set<String> _defaultChannelIds = {};
  List<OnboardingPromptDto> _prompts = const [];
  List<PendingMemberDto> _pending = const [];
  bool _saving = false;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _rulesController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repository = getIt<GuildRepository>();
    try {
      final config = await repository.getOnboarding(widget.guildId);
      if (mounted) _applyConfig(config);
    } catch (_) {
      // Keep the defaults already held in state.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
    try {
      final pending = await repository.getPendingMembers(widget.guildId);
      if (mounted) setState(() => _pending = pending);
    } catch (_) {
      // Moderator-only endpoint - just leave the section out.
    }
  }

  void _applyConfig(OnboardingConfigDto config) {
    setState(() {
      _config = config;
      _rulesController.text = config.rulesText ?? '';
      _defaultChannelIds = config.defaultChannelIds.toSet();
      _prompts = [...config.prompts]
        ..sort((a, b) => a.position.compareTo(b.position));
    });
  }

  bool get _hasRules => _rulesController.text.trim().isNotEmpty;

  bool get _hasJoinFlowPrompt => _prompts.any((p) => p.inOnboarding);

  /// The server's own rules, mirrored so problems show up inline instead of
  /// as a `400` after a save.
  String? get _validationError {
    if (_config.enabled && !_hasRules && !_hasJoinFlowPrompt) {
      return 'Turning onboarding on needs either rules text or at least one '
          'question asked when someone joins.';
    }
    if (_rulesController.text.trim().length >
        OnboardingConfigDto.maxRulesLength) {
      return 'Rules can be at most '
          '${OnboardingConfigDto.maxRulesLength} characters.';
    }
    for (final prompt in _prompts) {
      if (prompt.options.isEmpty) {
        return '"${prompt.title}" needs at least one answer.';
      }
      for (final option in prompt.options) {
        if (option.roleIds.isEmpty && option.channelIds.isEmpty) {
          return '"${option.title}" in "${prompt.title}" doesn\'t grant a '
              'role or a channel, so it wouldn\'t do anything.';
        }
      }
    }
    return null;
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final updated = await getIt<GuildRepository>().updateOnboarding(
        widget.guildId,
        _config.copyWith(
          rulesText: _rulesController.text.trim(),
          defaultChannelIds: _defaultChannelIds.toList(),
          prompts: [
            for (var i = 0; i < _prompts.length; i++)
              _prompts[i].copyWith(position: i),
          ],
        ),
      );
      if (mounted) {
        _applyConfig(updated);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Saved.')));
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = apiErrorMessage(error) ?? 'Could not save changes.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _editPrompt(int? index) async {
    final guild = getIt<GuildRepository>().cachedById(widget.guildId);
    if (guild == null) return;
    final edited = await Navigator.of(context).push<OnboardingPromptDto>(
      MaterialPageRoute(
        builder: (_) => OnboardingPromptEditorScreen(
          guild: guild,
          prompt: (index == null
              ? OnboardingPromptDto(position: _prompts.length)
              : _prompts[index]),
        ),
      ),
    );
    if (edited == null || !mounted) return;
    setState(() {
      final next = [..._prompts];
      if (index == null) {
        next.add(edited);
      } else {
        next[index] = edited;
      }
      _prompts = next;
    });
  }

  Future<void> _confirmDeletePrompt(int index) async {
    final prompt = _prompts[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete question?'),
        content: Text(
          'This removes "${prompt.title}" and every member\'s answer to it. '
          'Roles and channels they already got stay with them.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _prompts = [..._prompts]..removeAt(index));
  }

  void _reorderPrompt(int oldIndex, int newIndex) {
    setState(() {
      final next = [..._prompts];
      next.insert(newIndex, next.removeAt(oldIndex));
      _prompts = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    final theme = Theme.of(context);
    final channels =
        getIt<GuildRepository>()
            .cachedById(widget.guildId)
            ?.channels
            .where((c) => c.type != ChannelType.thread)
            .toList() ??
        const [];
    final validationError = _validationError;
    final atPromptCap = _prompts.length >= OnboardingConfigDto.maxPrompts;
    final enabled = _config.enabled;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.xl,
      ),
      children: [
        SettingsSection(
          child: SwitchListTile.adaptive(
            title: const Text('Onboarding'),
            subtitle: const Text('Set up new members before they can chat'),
            value: enabled,
            onChanged: (value) =>
                setState(() => _config = _config.copyWith(enabled: value)),
          ),
        ),
        const SettingsFootnote(
          'While onboarding is on, someone who joins can read along but '
          'can\'t post, react or join voice until they finish it.',
        ),
        if (_pending.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.l),
          _PendingMembersCard(pending: _pending),
        ],
        const SizedBox(height: AppSpacing.l),
        SettingsSection(
          label: 'Rules',
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: TextField(
              controller: _rulesController,
              minLines: 4,
              maxLines: 10,
              maxLength: OnboardingConfigDto.maxRulesLength,
              // Inert while the master switch is off, so it reads as disabled
              // rather than as unsaved changes.
              enabled: enabled,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: '1. Be nice\n2. ...',
                counterText: '',
              ),
            ),
          ),
        ),
        const SettingsFootnote(
          'Shown as plain text, exactly as you type it. Leave it empty if '
          'your questions are the whole flow.',
        ),
        const SizedBox(height: AppSpacing.l),
        SettingsSection(
          label:
              'Questions  ·  ${_prompts.length}/'
              '${OnboardingConfigDto.maxPrompts}',
          child: Column(
            children: [
              if (_prompts.isEmpty)
                const _EmptyRow(
                  text:
                      'No questions yet. New members will only see the '
                      'rules.',
                )
              else
                ReorderableListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: false,
                  onReorderItem: _reorderPrompt,
                  children: [
                    for (var i = 0; i < _prompts.length; i++)
                      _PromptTile(
                        key: ValueKey(_prompts[i].id ?? 'new-$i'),
                        index: i,
                        prompt: _prompts[i],
                        onTap: () => _editPrompt(i),
                        onDelete: () => _confirmDeletePrompt(i),
                      ),
                  ],
                ),
              ListTile(
                leading: Icon(
                  Icons.add,
                  color: atPromptCap
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                      : theme.colorScheme.primary,
                ),
                title: Text(
                  atPromptCap ? 'Question limit reached' : 'Add a question',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: atPromptCap
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                        : theme.colorScheme.primary,
                  ),
                ),
                onTap: atPromptCap ? null : () => _editPrompt(null),
              ),
            ],
          ),
        ),
        SettingsFootnote(
          'Answers hand out roles and open up channels - this is what '
          'actually changes what a new member can see.'
          '${_prompts.length > 1 ? ' Drag to reorder.' : ''}',
        ),
        if (channels.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.l),
          SettingsSection(
            label:
                'Suggested channels  ·  ${_defaultChannelIds.length}/'
                '${OnboardingConfigDto.maxDefaultChannels}',
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final channel in channels)
                    FilterChip(
                      label: Text('#${channel.name}'),
                      selected: _defaultChannelIds.contains(channel.id),
                      onSelected: enabled
                          ? (selected) => setState(() {
                              final next = {..._defaultChannelIds};
                              if (selected) {
                                if (next.length <
                                    OnboardingConfigDto.maxDefaultChannels) {
                                  next.add(channel.id);
                                }
                              } else {
                                next.remove(channel.id);
                              }
                              _defaultChannelIds = next;
                            })
                          : null,
                    ),
                ],
              ),
            ),
          ),
          const SettingsFootnote(
            'Pointed out to new members once they\'re done. This does not '
            'change who can see them - only a question\'s answer does that.',
          ),
        ],
        const SizedBox(height: AppSpacing.l),
        SettingsSection(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.waving_hand_outlined),
                title: const Text('Welcome screen'),
                subtitle: const Text('Shown on an invite, before joining'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) =>
                        WelcomeScreenSettingsScreen(guildId: widget.guildId),
                  ),
                ),
              ),
              // Advisory only: the backend stores `mode` and echoes it but
              // enforces no minimum-channel rule the way Discord's Community
              // program does. It's here so a server set up elsewhere reads
              // the same on both clients.
              ListTile(
                leading: const Icon(Icons.tune),
                title: const Text('Onboarding mode'),
                subtitle: Text(
                  _config.mode == OnboardingMode.advanced
                      ? 'Advanced - channels behind questions count as visible'
                      : 'Default',
                ),
                trailing: Switch.adaptive(
                  value: _config.mode == OnboardingMode.advanced,
                  onChanged: (value) => setState(
                    () => _config = _config.copyWith(
                      mode: value
                          ? OnboardingMode.advanced
                          : OnboardingMode.standard,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        if (validationError != null || _error != null) ...[
          Text(
            validationError ?? _error!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
        ],
        FilledButton(
          onPressed: _saving || validationError != null ? null : _save,
          child: _saving
              ? const ButtonProgressIndicator()
              : const Text('Save changes'),
        ),
      ],
    );
  }
}

class _EmptyRow extends StatelessWidget {
  const _EmptyRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.s,
      ),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

class _PromptTile extends StatelessWidget {
  const _PromptTile({
    super.key,
    required this.index,
    required this.prompt,
    required this.onTap,
    required this.onDelete,
  });

  final int index;
  final OnboardingPromptDto prompt;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badges = [
      '${prompt.options.length} answer'
          '${prompt.options.length == 1 ? '' : 's'}',
      if (prompt.isRequired) 'required',
      if (!prompt.inOnboarding) 'Channels & Roles only',
      prompt.singleSelect ? 'pick one' : 'pick many',
    ];

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        prompt.title.trim().isEmpty ? 'Untitled question' : prompt.title,
      ),
      subtitle: Text(badges.join(' · '), style: theme.textTheme.labelSmall),
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            tooltip: 'Delete question',
            onPressed: onDelete,
          ),
          ReorderableDragStartListener(
            index: index,
            child: Icon(
              Icons.drag_handle,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// "3 members haven't accepted the rules" - the moderator nudge. Pending
/// members can still be kicked and banned normally, so this is a report, not
/// a queue to action here.
class _PendingMembersCard extends StatelessWidget {
  const _PendingMembersCard({required this.pending});

  final List<PendingMemberDto> pending;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${pending.length} member${pending.length == 1 ? '' : 's'} '
            'haven\'t finished onboarding',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          for (final member in pending.take(5))
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  UserAvatar(
                    userId: member.userId,
                    radius: AppRadii.avatarSmall / 2,
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: ProfileResolver(
                      userId: member.userId,
                      builder: (context, profile) => Text(
                        member.nickname ?? profile?.userName ?? '…',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ),
                  if (member.joinedAt != null)
                    Text(
                      'joined ${formatCompactAgo(member.joinedAt!)} ago',
                      style: theme.textTheme.labelSmall,
                    ),
                ],
              ),
            ),
          if (pending.length > 5)
            Text(
              'and ${pending.length - 5} more',
              style: theme.textTheme.labelSmall,
            ),
        ],
      ),
    );
  }
}
