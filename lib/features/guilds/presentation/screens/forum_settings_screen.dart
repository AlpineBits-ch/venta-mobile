import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/adaptive_progress_indicator.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/settings_tiles.dart';
import '../../../messaging/presentation/widgets/reaction_picker_sheet.dart';
import '../../data/guild_api.dart';
import '../../data/guild_repository.dart';
import '../../data/models/forum_config_dto.dart';
import '../../data/models/forum_tag_dto.dart';
import '../../data/models/guild_emoji_dto.dart';
import '../widgets/forum_tag_chip.dart';

/// A moderator's tag editor plus per-forum posting config, reached from a
/// forum channel's overflow menu. `ManageChannel` throughout - the same bit
/// that already gates channel settings, so nothing new needs granting.
class ForumSettingsScreen extends StatefulWidget {
  const ForumSettingsScreen({
    super.key,
    required this.guildId,
    required this.channelId,
  });

  final String guildId;
  final String channelId;

  @override
  State<ForumSettingsScreen> createState() => _ForumSettingsScreenState();
}

class _ForumSettingsScreenState extends State<ForumSettingsScreen> {
  List<ForumTagDto> _tags = const [];
  List<GuildEmojiDto>? _guildEmojis;
  ForumConfigDto _config = const ForumConfigDto();
  bool _loading = true;
  bool _savingConfig = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final repository = getIt<GuildRepository>();
    try {
      final tags = await repository.getForumTags(widget.channelId);
      final config = await repository.getForumConfig(widget.channelId);
      if (!mounted) return;
      setState(() {
        _tags = tags;
        _config = config;
        _loading = false;
      });
      final emojis = await repository.getEmojis(widget.guildId);
      if (mounted) setState(() => _guildEmojis = emojis);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _patchConfig(
    ForumConfigDto Function(ForumConfigDto) mutate,
  ) async {
    final previous = _config;
    final next = mutate(previous);
    setState(() {
      _config = next;
      _savingConfig = true;
    });
    try {
      final saved = await getIt<GuildRepository>().updateForumConfig(
        widget.channelId,
        requireTag: next.requireTag,
        defaultSortOrder: next.defaultSortOrder,
        defaultLayout: next.defaultLayout,
        defaultThreadSlowModeSeconds: next.defaultThreadSlowModeSeconds,
        defaultAutoArchiveMinutes: next.defaultAutoArchiveMinutes,
        defaultReactionEmojiId: next.defaultReactionEmojiId,
        defaultReactionEmojiName: next.defaultReactionEmojiName,
      );
      if (mounted) setState(() => _config = saved);
    } catch (_) {
      if (mounted) {
        setState(() => _config = previous);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save that setting.')),
        );
      }
    } finally {
      if (mounted) setState(() => _savingConfig = false);
    }
  }

  Future<void> _editTag({ForumTagDto? existing}) async {
    final result = await showDialog<_TagEditResult>(
      context: context,
      builder: (dialogContext) => _TagEditorDialog(
        existing: existing,
        guildEmojis: _guildEmojis,
        guildId: widget.guildId,
        takenNames: {
          for (final tag in _tags)
            if (tag.id != existing?.id) tag.name.toLowerCase(),
        },
      ),
    );
    if (result == null || !mounted) return;

    try {
      if (result.delete && existing != null) {
        await getIt<GuildRepository>().deleteForumTag(existing.id);
      } else if (existing == null) {
        await getIt<GuildRepository>().createForumTag(
          widget.channelId,
          name: result.name,
          emojiId: result.emojiId,
          emojiName: result.emojiName,
          color: result.color,
          moderated: result.moderated,
        );
      } else {
        await getIt<GuildRepository>().updateForumTag(
          existing.id,
          name: result.name,
          // Empty string is this API's "clear it" - null means "unchanged" -
          // so both emoji fields are always sent, one of them blank.
          emojiId: result.emojiId ?? '',
          emojiName: result.emojiName ?? '',
          color: result.color,
          moderated: result.moderated,
        );
      }
      await _load();
    } on ForumTagNameTakenException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('A tag called "${result.name}" already exists.'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save the tag.')),
        );
      }
    }
  }

  Future<void> _reorder(int oldIndex, int newIndex) async {
    final reordered = [..._tags];
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, moved);
    setState(() => _tags = reordered);
    try {
      // The endpoint takes the forum's *complete* ordered id list; positions
      // come from the array index and a partial list is a `400`.
      await getIt<GuildRepository>().reorderForumTags(widget.channelId, [
        for (final tag in reordered) tag.id,
      ]);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save the new order.')),
        );
        await _load();
      }
    }
  }

  /// One value-picking row's choices, shown as a sheet rather than an inline
  /// dropdown so the settings list stays a list of rows with their values on
  /// the right - the shape used by every other settings screen here.
  Future<void> _pickValue<T>({
    required String title,
    required T current,
    required List<({T value, String label, String? description})> options,
    required void Function(T value) onPicked,
  }) async {
    final picked = await showModalBottomSheet<T>(
      context: context,
      useRootNavigator: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                AppSpacing.l,
                AppSpacing.l,
                AppSpacing.s,
              ),
              child: Text(
                title,
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
            ),
            for (final option in options)
              ListTile(
                title: Text(option.label),
                subtitle: option.description == null
                    ? null
                    : Text(option.description!),
                trailing: option.value == current
                    ? Icon(
                        Icons.check,
                        color: Theme.of(sheetContext).colorScheme.primary,
                      )
                    : null,
                onTap: () => Navigator.pop(sheetContext, option.value),
              ),
            const SizedBox(height: AppSpacing.s),
          ],
        ),
      ),
    );
    if (picked != null && picked != current) onPicked(picked);
  }

  String get _autoArchiveLabel => switch (_config.defaultAutoArchiveMinutes) {
    60 => '1 hour',
    1440 => '24 hours',
    10080 => '1 week',
    _ => '3 days',
  };

  String get _slowModeLabel => switch (_config.defaultThreadSlowModeSeconds) {
    0 => 'Off',
    final s when s < 60 => '$s seconds',
    final s when s < 3600 => '${s ~/ 60} min',
    final s => '${s ~/ 3600} hour',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atTagCap = _tags.length >= ForumTagLimits.tagsPerForum;

    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(
          fallbackLocation: RoutePaths.serverChannelPath(
            widget.guildId,
            widget.channelId,
          ),
        ),
        title: const Text('Tags & settings'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.m,
                AppSpacing.m,
                AppSpacing.m,
                AppSpacing.xl,
              ),
              children: [
                SettingsSection(
                  label:
                      'Tags  ·  ${_tags.length}/'
                      '${ForumTagLimits.tagsPerForum}',
                  child: Column(
                    children: [
                      if (_tags.isEmpty)
                        const _EmptyRow(
                          text:
                              'No tags yet. Members will just see a plain '
                              'list of posts.',
                        )
                      else
                        ReorderableListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          buildDefaultDragHandles: false,
                          onReorderItem: (oldIndex, newIndex) =>
                              unawaited(_reorder(oldIndex, newIndex)),
                          children: [
                            for (var i = 0; i < _tags.length; i++)
                              _TagRow(
                                key: ValueKey(_tags[i].id),
                                index: i,
                                tag: _tags[i],
                                emojiImageUrl: forumTagEmojiUrl(
                                  _tags[i],
                                  _guildEmojis,
                                ),
                                onTap: () => _editTag(existing: _tags[i]),
                              ),
                          ],
                        ),
                      ListTile(
                        leading: Icon(
                          Icons.add,
                          color: atTagCap
                              ? theme.colorScheme.onSurface.withValues(
                                  alpha: 0.4,
                                )
                              : theme.colorScheme.primary,
                        ),
                        title: Text(
                          atTagCap ? 'Tag limit reached' : 'Create tag',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: atTagCap
                                ? theme.colorScheme.onSurface.withValues(
                                    alpha: 0.4,
                                  )
                                : theme.colorScheme.primary,
                          ),
                        ),
                        onTap: atTagCap ? null : () => _editTag(),
                      ),
                    ],
                  ),
                ),
                SettingsFootnote(
                  'Members pick tags when they post and filter the forum by '
                  'them.${_tags.length > 1 ? ' Drag to reorder.' : ''}',
                ),
                const SizedBox(height: AppSpacing.l),
                SettingsSection(
                  label: 'Posting',
                  child: Column(
                    children: [
                      SwitchListTile.adaptive(
                        title: const Text('Require a tag'),
                        // Greyed out with no tags to require - saying why
                        // beats letting it read as broken.
                        subtitle: Text(
                          _tags.isEmpty
                              ? 'Create a tag first'
                              : 'New posts must carry at least one',
                        ),
                        value: _config.requireTag,
                        onChanged: _tags.isEmpty
                            ? null
                            : (value) => _patchConfig(
                                (c) => c.copyWith(requireTag: value),
                              ),
                      ),
                      SettingsRow(
                        title: 'Slow mode in new posts',
                        trailing: Text(_slowModeLabel),
                        onTap: () => _pickValue<int>(
                          title: 'Slow mode in new posts',
                          current: _config.defaultThreadSlowModeSeconds,
                          options: const [
                            (value: 0, label: 'Off', description: null),
                            (value: 5, label: '5 seconds', description: null),
                            (value: 30, label: '30 seconds', description: null),
                            (value: 60, label: '1 minute', description: null),
                            (value: 300, label: '5 minutes', description: null),
                            (
                              value: 900,
                              label: '15 minutes',
                              description: null,
                            ),
                            (value: 3600, label: '1 hour', description: null),
                          ],
                          onPicked: (value) => _patchConfig(
                            (c) =>
                                c.copyWith(defaultThreadSlowModeSeconds: value),
                          ),
                        ),
                      ),
                      SettingsRow(
                        title: 'Auto-archive posts after',
                        trailing: Text(_autoArchiveLabel),
                        onTap: () => _pickValue<int>(
                          title: 'Auto-archive posts after',
                          current: _config.defaultAutoArchiveMinutes,
                          options: const [
                            (value: 60, label: '1 hour', description: null),
                            (value: 1440, label: '24 hours', description: null),
                            (value: 4320, label: '3 days', description: null),
                            (value: 10080, label: '1 week', description: null),
                          ],
                          onPicked: (value) => _patchConfig(
                            (c) => c.copyWith(defaultAutoArchiveMinutes: value),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SettingsFootnote(
                  'Slow mode and the archive window are copied onto each new '
                  'post - changing them leaves existing posts alone.',
                ),
                const SizedBox(height: AppSpacing.l),
                SettingsSection(
                  label: 'How members see it',
                  child: Column(
                    children: [
                      SettingsRow(
                        title: 'Sort posts by',
                        trailing: Text(_config.defaultSortOrder.label),
                        onTap: () => _pickValue<ForumSortOrder>(
                          title: 'Sort posts by',
                          current: _config.defaultSortOrder,
                          options: [
                            for (final order in ForumSortOrder.values)
                              (
                                value: order,
                                label: order.label,
                                description: null,
                              ),
                          ],
                          onPicked: (value) => _patchConfig(
                            (c) => c.copyWith(defaultSortOrder: value),
                          ),
                        ),
                      ),
                      SettingsRow(
                        title: 'Layout',
                        trailing: Text(
                          _config.defaultLayout == ForumLayout.gallery
                              ? 'Gallery'
                              : 'List',
                        ),
                        onTap: () => _pickValue<ForumLayout>(
                          title: 'Layout',
                          current: _config.defaultLayout,
                          options: const [
                            (
                              value: ForumLayout.list,
                              label: 'List',
                              description: 'One post per row',
                            ),
                            (
                              value: ForumLayout.gallery,
                              label: 'Gallery',
                              description: 'A grid of cards, media-forward',
                            ),
                          ],
                          onPicked: (value) => _patchConfig(
                            (c) => c.copyWith(defaultLayout: value),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SettingsFootnote(
                  'A starting point only - anyone can switch sort and layout '
                  'for themselves, and their choice sticks.',
                ),
                if (_savingConfig) ...[
                  const SizedBox(height: AppSpacing.m),
                  const Center(
                    child: AdaptiveProgressIndicator(size: 16, strokeWidth: 2),
                  ),
                ],
              ],
            ),
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

/// One tag inside the tags card: the chip as it actually renders, its post
/// count, and a drag handle.
class _TagRow extends StatelessWidget {
  const _TagRow({
    super.key,
    required this.index,
    required this.tag,
    required this.emojiImageUrl,
    required this.onTap,
  });

  final int index;
  final ForumTagDto tag;
  final String? emojiImageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      title: Align(
        alignment: Alignment.centerLeft,
        child: ForumTagChip(tag: tag, emojiImageUrl: emojiImageUrl),
      ),
      subtitle: Text(
        '${tag.postCount} post${tag.postCount == 1 ? '' : 's'}'
        '${tag.moderated ? '  ·  moderators only' : ''}',
        style: theme.textTheme.labelSmall,
      ),
      trailing: ReorderableDragStartListener(
        index: index,
        child: Icon(
          Icons.drag_handle,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
      onTap: onTap,
    );
  }
}

/// What [_TagEditorDialog] resolves to - an edited tag, or a delete request.
class _TagEditResult {
  const _TagEditResult({
    required this.name,
    this.emojiId,
    this.emojiName,
    required this.color,
    required this.moderated,
    this.delete = false,
  });

  final String name;
  final String? emojiId;
  final String? emojiName;
  final String color;
  final bool moderated;
  final bool delete;
}

/// Name, emoji, colour and the moderators-only flag.
///
/// The colour palette here is tag *data*, not app chrome - it's what members
/// see on the chips - so it's a fixed set of swatches rather than anything
/// pulled from the theme.
class _TagEditorDialog extends StatefulWidget {
  const _TagEditorDialog({
    required this.existing,
    required this.guildEmojis,
    required this.guildId,
    required this.takenNames,
  });

  final ForumTagDto? existing;
  final List<GuildEmojiDto>? guildEmojis;
  final String guildId;

  /// Lower-cased names already used in this forum - names are unique per
  /// forum, case-insensitively, and a collision is the one error people hit
  /// routinely, so it's flagged inline instead of after a round trip.
  final Set<String> takenNames;

  @override
  State<_TagEditorDialog> createState() => _TagEditorDialogState();
}

class _TagEditorDialogState extends State<_TagEditorDialog> {
  static const _swatches = <String>[
    '#000000',
    '#e74c3c',
    '#e67e22',
    '#f1c40f',
    '#2ecc71',
    '#1abc9c',
    '#3498db',
    '#9b59b6',
    '#e91e63',
    '#95a5a6',
  ];

  late final _nameController = TextEditingController(
    text: widget.existing?.name ?? '',
  );
  late String _color = widget.existing?.color ?? '#000000';
  late bool _moderated = widget.existing?.moderated ?? false;
  late String? _emojiId = widget.existing?.emojiId;
  late String? _emojiName = widget.existing?.emojiName;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String? get _nameError {
    final name = _nameController.text.trim();
    if (name.isEmpty) return null;
    if (name.length > ForumTagLimits.nameLength) {
      return 'Up to ${ForumTagLimits.nameLength} characters.';
    }
    if (widget.takenNames.contains(name.toLowerCase())) {
      return 'A tag with that name already exists.';
    }
    return null;
  }

  Future<void> _pickEmoji() async {
    final picked = await showReactionPickerSheet(
      context,
      guildId: widget.guildId,
    );
    if (picked == null) return;
    setState(() {
      // Exactly one of the two is ever set - a guild emoji id or a glyph.
      _emojiId = picked.emojiId;
      _emojiName = picked.emojiId == null ? picked.emoji : null;
    });
  }

  Widget _emojiPreview() {
    if (_emojiId != null) {
      final match = widget.guildEmojis
          ?.where((e) => e.id == _emojiId)
          .firstOrNull;
      return match == null
          ? const Icon(Icons.emoji_emotions_outlined)
          : Image.network(
              match.imageUrl,
              width: 22,
              height: 22,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.emoji_emotions_outlined),
            );
    }
    if (_emojiName != null && _emojiName!.isNotEmpty) {
      return Text(_emojiName!, style: const TextStyle(fontSize: 20));
    }
    return const Icon(Icons.emoji_emotions_outlined);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = _nameController.text.trim();
    final canSave = name.isNotEmpty && _nameError == null;

    return AlertDialog(
      title: Text(widget.existing == null ? 'Create tag' : 'Edit tag'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: _pickEmoji,
                  tooltip: 'Tag emoji',
                  icon: _emojiPreview(),
                ),
                if (_emojiId != null || _emojiName != null)
                  IconButton(
                    tooltip: 'Remove emoji',
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() {
                      _emojiId = null;
                      _emojiName = null;
                    }),
                  ),
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    autofocus: true,
                    maxLength: ForumTagLimits.nameLength,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      errorText: _nameError,
                      counterText: '',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            Text('COLOUR', style: theme.textTheme.labelSmall),
            const SizedBox(height: AppSpacing.s),
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              children: [
                for (final swatch in _swatches)
                  GestureDetector(
                    onTap: () => setState(() => _color = swatch),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color:
                            parseForumTagColor(swatch) ??
                            theme.colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _color.toLowerCase() == swatch
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant.withValues(
                                  alpha: 0.5,
                                ),
                          width: _color.toLowerCase() == swatch ? 2 : 1,
                        ),
                      ),
                      child: parseForumTagColor(swatch) == null
                          ? Icon(
                              Icons.block,
                              size: 14,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            )
                          : null,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Moderators only'),
              subtitle: const Text(
                'Only moderators can add or remove this tag',
              ),
              value: _moderated,
              onChanged: (value) => setState(() => _moderated = value),
            ),
          ],
        ),
      ),
      actions: [
        if (widget.existing != null)
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(
              _TagEditResult(
                name: widget.existing!.name,
                color: widget.existing!.color,
                moderated: widget.existing!.moderated,
                delete: true,
              ),
            ),
            child: const Text('Delete'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: canSave
              ? () => Navigator.of(context).pop(
                  _TagEditResult(
                    name: name,
                    emojiId: _emojiId,
                    emojiName: _emojiName,
                    color: _color,
                    moderated: _moderated,
                  ),
                )
              : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
