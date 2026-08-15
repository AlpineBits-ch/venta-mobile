import 'package:flutter/material.dart';

import '../../../../../core/theme/widget_styles.dart';
import '../../../../../core/widgets/settings_tiles.dart';
import '../../../../messaging/presentation/widgets/reaction_picker_sheet.dart';
import '../../../data/models/channel_dto.dart';
import '../../../data/models/guild_dto.dart';
import '../../../data/models/onboarding_dto.dart';
import '../../../data/models/role_dto.dart';

/// Permission flags that make a role ineligible for self-assignment.
///
/// Prompt options *are* self-service role assignment - nobody approves the
/// moment a member picks one - so the backend refuses anything carrying
/// admin, management, moderation, audit-log, emoji or wiki-editing rights.
/// Mirrored here so the picker simply doesn't offer them; the server re-checks
/// on save and again when a member answers, so this is convenience, not the
/// guardrail itself.
const _privilegedFlags = <String>[
  'Superadmin',
  'ManageGuild',
  'ManageChannel',
  'ManagePermissions',
  'KickMembers',
  'BanMembers',
  'ModerateMembers',
  'ViewAuditLog',
  'ManageEmojis',
  'EditAnyMessage',
  'DeleteAnyMessage',
  'ManageAnyThread',
  'EditAnyWikiPage',
  'DeleteWikiPages',
  'ManageWikiRevisions',
  'ManageWikiStructure',
  'ModerateWikiComments',
  'PublishWikiPublicly',
];

bool _isAssignable(RoleDto role) {
  if (role.type == RoleType.everyone) return false;
  final permissions = role.permissionsValue;
  return !_privilegedFlags.any(permissions.has);
}

/// Creates or edits one onboarding question. Returns the edited prompt (the
/// caller holds the whole document and `PUT`s it as one), or null if
/// cancelled. Deleting is the caller's job too - see the tab's list.
class OnboardingPromptEditorScreen extends StatefulWidget {
  const OnboardingPromptEditorScreen({
    super.key,
    required this.guild,
    required this.prompt,
  });

  final GuildDto guild;
  final OnboardingPromptDto prompt;

  @override
  State<OnboardingPromptEditorScreen> createState() =>
      _OnboardingPromptEditorScreenState();
}

class _OnboardingPromptEditorScreenState
    extends State<OnboardingPromptEditorScreen> {
  late final _titleController = TextEditingController(
    text: widget.prompt.title,
  );
  late bool _singleSelect = widget.prompt.singleSelect;
  late bool _isRequired = widget.prompt.isRequired;
  late bool _inOnboarding = widget.prompt.inOnboarding;

  /// Round-tripped, never edited: `MultipleChoice` vs `Dropdown` is a desktop
  /// rendering distinction, and both render as the same list of tappable rows
  /// on a phone - so exposing a control for it would be a setting that
  /// visibly does nothing here.
  late final OnboardingPromptType _type = widget.prompt.type;
  late List<OnboardingPromptOptionDto> _options = [...widget.prompt.options]
    ..sort((a, b) => a.position.compareTo(b.position));

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  /// Every option must grant *something* - one that hands out neither a role
  /// nor a channel does nothing at all, and the backend rejects it.
  bool get _optionsValid =>
      _options.isNotEmpty &&
      _options.every(
        (o) =>
            o.title.trim().isNotEmpty &&
            (o.roleIds.isNotEmpty || o.channelIds.isNotEmpty),
      );

  bool get _canSave => _titleController.text.trim().isNotEmpty && _optionsValid;

  Future<void> _editOption(int? index) async {
    final existing = index == null ? null : _options[index];
    final result = await Navigator.of(context).push<_OptionEditResult>(
      MaterialPageRoute(
        builder: (_) => _OptionEditorScreen(
          guild: widget.guild,
          option:
              existing ?? OnboardingPromptOptionDto(position: _options.length),
        ),
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      if (result.delete && index != null) {
        _options = [..._options]..removeAt(index);
      } else if (index == null) {
        _options = [..._options, result.option];
      } else {
        _options = [..._options];
        _options[index] = result.option;
      }
      _options = [
        for (var i = 0; i < _options.length; i++)
          _options[i].copyWith(position: i),
      ];
    });
  }

  void _save() {
    Navigator.of(context).pop(
      widget.prompt.copyWith(
        title: _titleController.text.trim(),
        type: _type,
        singleSelect: _singleSelect,
        isRequired: _isRequired,
        inOnboarding: _inOnboarding,
        options: _options,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atOptionCap =
        _options.length >= OnboardingConfigDto.maxOptionsPerPrompt;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.prompt.id == null ? 'New question' : 'Edit question',
        ),
        actions: [
          TextButton(
            onPressed: _canSave ? _save : null,
            child: const Text('Done'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.m,
          AppSpacing.m,
          AppSpacing.m,
          AppSpacing.xl,
        ),
        children: [
          SettingsSection(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: TextField(
                controller: _titleController,
                autofocus: widget.prompt.id == null,
                maxLength: OnboardingConfigDto.maxTitleLength,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  hintText: 'What are you here for?',
                  counterText: '',
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          SettingsSection(
            label:
                'Answers  ·  ${_options.length}/'
                '${OnboardingConfigDto.maxOptionsPerPrompt}',
            child: Column(
              children: [
                if (_options.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.m,
                      AppSpacing.m,
                      AppSpacing.m,
                      AppSpacing.s,
                    ),
                    child: Text(
                      'No answers yet.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  )
                else
                  for (var i = 0; i < _options.length; i++)
                    _OptionSummaryTile(
                      option: _options[i],
                      guild: widget.guild,
                      onTap: () => _editOption(i),
                    ),
                ListTile(
                  leading: Icon(
                    Icons.add,
                    color: atOptionCap
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                        : theme.colorScheme.primary,
                  ),
                  title: Text(
                    atOptionCap ? 'Answer limit reached' : 'Add answer',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: atOptionCap
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                          : theme.colorScheme.primary,
                    ),
                  ),
                  onTap: atOptionCap ? null : () => _editOption(null),
                ),
              ],
            ),
          ),
          SettingsFootnote(
            'Every answer has to grant at least one role or channel - '
            'that\'s the whole point of it.',
          ),
          const SizedBox(height: AppSpacing.l),
          SettingsSection(
            label: 'How it\'s asked',
            child: Column(
              children: [
                ListTile(
                  title: const Text('Answers allowed'),
                  trailing: SegmentedButton<bool>(
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                    segments: const [
                      ButtonSegment(value: true, label: Text('One')),
                      ButtonSegment(value: false, label: Text('Many')),
                    ],
                    selected: {_singleSelect},
                    showSelectedIcon: false,
                    onSelectionChanged: (value) =>
                        setState(() => _singleSelect = value.first),
                  ),
                ),
                SwitchListTile.adaptive(
                  title: const Text('Ask when someone joins'),
                  subtitle: const Text('Off: only offered in Channels & Roles'),
                  value: _inOnboarding,
                  onChanged: (value) => setState(() {
                    _inOnboarding = value;
                    // "Required" only means anything inside the join flow.
                    if (!value) _isRequired = false;
                  }),
                ),
                SwitchListTile.adaptive(
                  title: const Text('Required'),
                  subtitle: const Text('Must be answered to finish onboarding'),
                  value: _isRequired,
                  onChanged: _inOnboarding
                      ? (value) => setState(() => _isRequired = value)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionSummaryTile extends StatelessWidget {
  const _OptionSummaryTile({
    required this.option,
    required this.guild,
    required this.onTap,
  });

  final OnboardingPromptOptionDto option;
  final GuildDto guild;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grants = [
      for (final id in option.channelIds)
        ...guild.channels.where((c) => c.id == id).map((c) => '#${c.name}'),
      for (final id in option.roleIds)
        ...guild.roles.where((r) => r.id == id).map((r) => r.name),
    ];
    final incomplete = option.title.trim().isEmpty || grants.isEmpty;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: option.emoji != null && option.emoji!.isNotEmpty
          ? Text(option.emoji!, style: const TextStyle(fontSize: 20))
          : const Icon(Icons.radio_button_unchecked),
      title: Text(
        option.title.trim().isEmpty ? 'Untitled answer' : option.title,
      ),
      subtitle: Text(
        grants.isEmpty ? 'Grants nothing yet' : grants.join(', '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: incomplete
              ? theme.colorScheme.error
              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _OptionEditResult {
  const _OptionEditResult({required this.option, this.delete = false});
  final OnboardingPromptOptionDto option;
  final bool delete;
}

class _OptionEditorScreen extends StatefulWidget {
  const _OptionEditorScreen({required this.guild, required this.option});

  final GuildDto guild;
  final OnboardingPromptOptionDto option;

  @override
  State<_OptionEditorScreen> createState() => _OptionEditorScreenState();
}

class _OptionEditorScreenState extends State<_OptionEditorScreen> {
  late final _titleController = TextEditingController(
    text: widget.option.title,
  );
  late final _descriptionController = TextEditingController(
    text: widget.option.description ?? '',
  );
  late String? _emoji = widget.option.emoji;
  late Set<String> _roleIds = widget.option.roleIds.toSet();
  late Set<String> _channelIds = widget.option.channelIds.toSet();

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _titleController.text.trim().isNotEmpty &&
      (_roleIds.isNotEmpty || _channelIds.isNotEmpty);

  Future<void> _pickEmoji() async {
    final picked = await showReactionPickerSheet(context);
    if (picked == null) return;
    setState(() => _emoji = picked.emoji);
  }

  void _save() {
    Navigator.of(context).pop(
      _OptionEditResult(
        option: widget.option.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          emoji: _emoji,
          roleIds: _roleIds.toList(),
          channelIds: _channelIds.toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final assignableRoles = widget.guild.roles.where(_isAssignable).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final channels =
        widget.guild.channels
            .where((c) => c.type != ChannelType.thread)
            .toList()
          ..sort((a, b) => a.position.compareTo(b.position));
    final hiddenRoleCount = widget.guild.roles.length - assignableRoles.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Answer'),
        actions: [
          TextButton(
            onPressed: _canSave ? _save : null,
            child: const Text('Done'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.m,
          AppSpacing.m,
          AppSpacing.m,
          AppSpacing.xl,
        ),
        children: [
          SettingsSection(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: _pickEmoji,
                        tooltip: 'Emoji',
                        icon: _emoji != null && _emoji!.isNotEmpty
                            ? Text(
                                _emoji!,
                                style: const TextStyle(fontSize: 20),
                              )
                            : const Icon(Icons.emoji_emotions_outlined),
                      ),
                      if (_emoji != null && _emoji!.isNotEmpty)
                        IconButton(
                          tooltip: 'Remove emoji',
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => setState(() => _emoji = null),
                        ),
                      Expanded(
                        child: TextField(
                          controller: _titleController,
                          autofocus: widget.option.id == null,
                          maxLength: OnboardingConfigDto.maxTitleLength,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            labelText: 'Answer',
                            counterText: '',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s),
                  TextField(
                    controller: _descriptionController,
                    maxLength: 100,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      counterText: '',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          SettingsSection(
            label: 'Gives these roles',
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: assignableRoles.isEmpty
                  ? Text(
                      'No self-assignable roles in this server yet.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    )
                  : Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        for (final role in assignableRoles)
                          FilterChip(
                            label: Text(role.name),
                            selected: _roleIds.contains(role.id),
                            onSelected: (selected) => setState(() {
                              _roleIds = {..._roleIds};
                              if (selected) {
                                if (_roleIds.length <
                                    OnboardingConfigDto.maxGrantsPerOption) {
                                  _roleIds.add(role.id);
                                }
                              } else {
                                _roleIds.remove(role.id);
                              }
                            }),
                          ),
                      ],
                    ),
            ),
          ),
          if (hiddenRoleCount > 0)
            const SettingsFootnote(
              'Roles carrying moderation or management permissions can\'t be '
              'self-assigned, so they aren\'t listed.',
            ),
          const SizedBox(height: AppSpacing.l),
          SettingsSection(
            label: 'Unlocks these channels',
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final channel in channels)
                    FilterChip(
                      label: Text('#${channel.name}'),
                      selected: _channelIds.contains(channel.id),
                      onSelected: (selected) => setState(() {
                        _channelIds = {..._channelIds};
                        if (selected) {
                          if (_channelIds.length <
                              OnboardingConfigDto.maxGrantsPerOption) {
                            _channelIds.add(channel.id);
                          }
                        } else {
                          _channelIds.remove(channel.id);
                        }
                      }),
                    ),
                ],
              ),
            ),
          ),
          const SettingsFootnote(
            'This grants real access, unlike the suggested channels on the '
            'onboarding screen, which only point them out.',
          ),
          if (widget.option.id != null) ...[
            const SizedBox(height: AppSpacing.l),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              onPressed: () => Navigator.of(
                context,
              ).pop(_OptionEditResult(option: widget.option, delete: true)),
              child: const Text('Remove answer'),
            ),
            const SettingsFootnote(
              'Removing an answer doesn\'t take back roles or channels it '
              'already granted - members keep those until they unpick it '
              'themselves.',
            ),
          ],
        ],
      ),
    );
  }
}
