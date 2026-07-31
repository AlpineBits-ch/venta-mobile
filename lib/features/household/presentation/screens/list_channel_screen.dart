import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/load_failure_view.dart';
import '../../../../core/widgets/skeleton_list_tile.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../guilds/data/models/guild_features.dart';
import '../../../guilds/data/models/guild_member_dto.dart';
import '../../data/household_repository.dart';
import '../../data/models/list_item_dto.dart';
import '../widgets/household_widgets.dart';
import 'household_channel_base.dart';

/// A `List` channel: the shopping list, the todo list.
///
/// There is no message history and no composer here in the chat sense - the
/// field at the bottom adds a *row*. It's shaped like a composer on purpose,
/// because the defining use case is standing in a shop adding things one after
/// another, and anything that costs a tap between items (a dialog, a FAB, a
/// second screen) makes that materially worse.
///
/// Everything is applied optimistically and reconciled: two people in the same
/// shop with the same list open is the normal case, and a tick has to strike
/// through on the other phone within the second or the milk gets bought twice.
class ListChannelScreen extends StatefulWidget {
  const ListChannelScreen({
    super.key,
    required this.guildId,
    required this.channelId,
  });

  final String guildId;
  final String channelId;

  @override
  State<ListChannelScreen> createState() => _ListChannelScreenState();
}

class _ListChannelScreenState
    extends HouseholdChannelState<ListChannelScreen> {
  @override
  String get guildId => widget.guildId;
  @override
  String get channelId => widget.channelId;
  @override
  String get requiredFeature => GuildFeature.lists;
  @override
  String get fallbackTitle => 'List';

  List<ListItemDto>? _items;
  bool _loadFailed = false;
  bool _showChecked = true;

  /// Items added on this device that the server hasn't acknowledged yet. They
  /// render immediately (greyed) so typing never stalls on the network, and
  /// they're kept out of the way of every refetch until their id is real.
  final _pending = <ListItemDto>[];
  var _pendingSeq = 0;

  final _composerController = TextEditingController();
  final _composerFocus = FocusNode();
  StreamSubscription<void>? _eventsSub;

  bool get _canAdd => can('AddListItems');
  bool get _canCheck => can('CheckOffListItems');
  bool get _canManage => can('ManageLists');

  /// Editing or deleting: your own line needs `AddListItems`, someone else's
  /// needs `ManageLists`.
  bool _canEdit(ListItemDto item) =>
      _canManage || (_canAdd && MemberName.isSelf(item.addedByUserId));

  @override
  void initState() {
    super.initState();
    _load();
    unawaited(ensureMembers());
    _eventsSub = household
        .channelEvents(widget.channelId, HouseholdEvents.list)
        .listen((_) => _load());
  }

  @override
  void dispose() {
    unawaited(_eventsSub?.cancel());
    _composerController.dispose();
    _composerFocus.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final items = await api.getListItems(widget.channelId);
      if (!mounted) return;
      setState(() {
        _items = items;
        _loadFailed = false;
        // Anything the server now knows about is no longer pending, however
        // it got here - our own POST returning, or the realtime echo.
        _pending.removeWhere(
          (p) => items.any(
            (i) => i.text == p.text && i.addedByUserId == p.addedByUserId,
          ),
        );
      });
    } catch (_) {
      if (mounted && _items == null) setState(() => _loadFailed = true);
    }
  }

  Future<void> _add(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty) return;
    final placeholder = ListItemDto(
      id: 'pending-${_pendingSeq++}',
      channelId: widget.channelId,
      text: text,
      addedByUserId: currentUserId,
      position: 1 << 30,
    );
    setState(() => _pending.add(placeholder));
    _composerController.clear();
    // Keep the keyboard up: the next item is almost always right behind this
    // one.
    _composerFocus.requestFocus();
    try {
      final created = await api.createListItem(widget.channelId, text: text);
      if (!mounted) return;
      setState(() {
        _pending.remove(placeholder);
        final existing = _items ?? const <ListItemDto>[];
        if (!existing.any((i) => i.id == created.id)) {
          _items = [...existing, created];
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _pending.remove(placeholder));
      // Hand the text back rather than losing what they typed.
      _composerController.text = text;
      _composerController.selection = TextSelection.collapsed(
        offset: text.length,
      );
      showError(error, 'Could not add that.');
    }
  }

  Future<void> _setChecked(ListItemDto item, bool checked) async {
    if (!_canCheck) return;
    _patchLocally(
      item.id,
      (i) => i.copyWith(
        isChecked: checked,
        checkedAt: checked ? DateTime.now() : null,
        checkedByUserId: checked ? currentUserId : null,
      ),
    );
    try {
      final updated = await api.setListItemChecked(item.id, checked);
      // A repeat tick is a 200 with the item unchanged and no event - not an
      // error, and nothing to reconcile.
      if (updated != null) _patchLocally(item.id, (_) => updated);
    } catch (error) {
      _patchLocally(item.id, (_) => item);
      showError(error, 'Could not update that item.');
    }
  }

  void _patchLocally(String id, ListItemDto Function(ListItemDto) update) {
    if (!mounted) return;
    setState(() {
      _items = [
        for (final i in _items ?? const <ListItemDto>[])
          if (i.id == id) update(i) else i,
      ];
    });
  }

  Future<void> _openEditor(ListItemDto item) async {
    final result = await showHouseSheet<_ItemEditResult>(
      context: context,
      builder: (_) => _ListItemSheet(
        item: item,
        members: members ?? const [],
        canDelete: _canEdit(item),
      ),
    );
    if (result == null || !mounted) return;
    if (result.delete) {
      final snapshot = _items;
      setState(
        () => _items = [
          for (final i in _items ?? const <ListItemDto>[])
            if (i.id != item.id) i,
        ],
      );
      try {
        await api.deleteListItem(item.id);
      } catch (error) {
        if (mounted) setState(() => _items = snapshot);
        showError(error, 'Could not delete that item.');
      }
      return;
    }
    try {
      final updated = await api.updateListItem(
        item.id,
        text: result.text,
        quantity: result.quantity,
        clearQuantity: result.quantity == null,
        note: result.note,
        clearNote: result.note == null,
        section: result.section,
        clearSection: result.section == null,
        assigneeUserId: result.assigneeUserId,
        clearAssignee: result.assigneeUserId == null,
      );
      _patchLocally(item.id, (_) => updated);
    } catch (error) {
      showError(error, 'Could not save that item.');
    }
  }

  Future<void> _clearDone() async {
    final checked = (_items ?? const <ListItemDto>[])
        .where((i) => i.isChecked)
        .length;
    if (checked == 0) {
      showMessage('Nothing is ticked off yet.');
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear what\'s done?'),
        content: Text(
          '$checked ticked ${checked == 1 ? 'item' : 'items'} will be removed '
          'from the list. Anything the pantry put here can come back next time '
          'it runs low.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await api.clearCheckedListItems(widget.channelId);
      await _load();
    } catch (error) {
      showError(error, 'Could not clear the list.');
    }
  }

  Future<void> _reorder(List<ListItemDto> unchecked, int from, int to) async {
    // `onReorderItem` (unlike the deprecated `onReorder`) already accounts for
    // the dragged item having been lifted out, so `to` is a plain index.
    final reordered = [...unchecked];
    final moved = reordered.removeAt(from);
    reordered.insert(to, moved);
    final order = [for (final item in reordered) item.id];
    setState(() {
      final checked = (_items ?? const <ListItemDto>[])
          .where((i) => i.isChecked)
          .toList();
      _items = [
        for (var i = 0; i < reordered.length; i++)
          reordered[i].copyWith(position: i),
        ...checked,
      ];
    });
    try {
      await api.reorderListItems(widget.channelId, order);
    } catch (error) {
      await _load();
      showError(error, 'Could not reorder the list.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = _items;
    final checkedCount = (items ?? const <ListItemDto>[])
        .where((i) => i.isChecked)
        .length;

    return Scaffold(
      appBar: buildAppBar(
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => switch (value) {
              'toggle' => setState(() => _showChecked = !_showChecked),
              'clear' => unawaited(_clearDone()),
              _ => null,
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle',
                child: Text(
                  _showChecked ? 'Hide ticked items' : 'Show ticked items',
                ),
              ),
              if (_canManage)
                const PopupMenuItem(value: 'clear', child: Text('Clear done')),
            ],
          ),
        ],
      ),
      body: !moduleEnabled
          ? buildModuleOff()
          : _loadFailed
          ? LoadFailureView(
              message: 'Couldn\'t load this list.',
              onRetry: _load,
            )
          : items == null
          ? ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
              children: [for (var i = 0; i < 5; i++) const SkeletonListTile()],
            )
          : Column(
              children: [
                Expanded(child: _buildList(items, checkedCount)),
                if (_canAdd) _buildComposer(theme),
              ],
            ),
    );
  }

  Widget _buildList(List<ListItemDto> items, int checkedCount) {
    final unchecked = [...items.where((i) => !i.isChecked)]
      ..sort((a, b) => a.position.compareTo(b.position));
    final checked = [...items.where((i) => i.isChecked)]
      ..sort((a, b) => (b.checkedAt ?? DateTime(0)).compareTo(
        a.checkedAt ?? DateTime(0),
      ));

    // Nothing *visible* - which is a different state from an empty list when
    // everything has been ticked off and ticked items are hidden.
    if (unchecked.isEmpty &&
        _pending.isEmpty &&
        (checked.isEmpty || !_showChecked)) {
      return HouseEmptyState(
        icon: checked.isEmpty
            ? Icons.checklist_rounded
            : Icons.check_circle_outline_rounded,
        title: checked.isEmpty ? 'Nothing on the list' : 'All done',
        body: checked.isEmpty
            ? _canAdd
                  ? 'Add the first thing below. Everyone in the house sees it '
                        'as you type, and ticking something off strikes it '
                        'through on their phone too.'
                  : 'Whoever does the shopping will fill this in.'
            : 'Everything here has been ticked off. Show ticked items from '
                  'the menu to see them.',
      );
    }

    // Sections are free text, so a list either uses them or it doesn't.
    // Manual drag order and section grouping can't both be true at once, and
    // grouping is the more informative of the two when it's in use.
    final sections = <String?>{
      for (final item in unchecked) _sectionOf(item),
    }.toList()..sort(_sectionOrder);
    final grouped = sections.any((s) => s != null);

    final done = _showChecked && checked.isNotEmpty
        ? _CheckedGroup(
            items: checked,
            count: checkedCount,
            onToggle: _canCheck ? (item) => _setChecked(item, false) : null,
            onOpen: _openEditor,
          )
        : const SizedBox.shrink();

    if (grouped) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.m,
            AppSpacing.s,
            AppSpacing.m,
            AppSpacing.l,
          ),
          children: [
            for (final section in sections) ...[
              HouseSectionHeader(label: section ?? 'Everything else'),
              for (final item in unchecked.where(
                (i) => _sectionOf(i) == section,
              ))
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.s),
                  child: _ListItemRow(
                    item: item,
                    onToggle: _canCheck ? () => _setChecked(item, true) : null,
                    onOpen: () => _openEditor(item),
                  ),
                ),
            ],
            for (final item in _pending)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s),
                child: _ListItemRow(item: item, pending: true),
              ),
            done,
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ReorderableListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.m,
          AppSpacing.s,
          AppSpacing.m,
          AppSpacing.l,
        ),
        itemCount: unchecked.length,
        buildDefaultDragHandles: _canAdd || _canManage,
        onReorderItem: (from, to) => _reorder(unchecked, from, to),
        footer: Column(
          children: [
            for (final item in _pending)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s),
                child: _ListItemRow(item: item, pending: true),
              ),
            done,
          ],
        ),
        itemBuilder: (context, index) {
          final item = unchecked[index];
          return Padding(
            key: ValueKey(item.id),
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: _ListItemRow(
              item: item,
              onToggle: _canCheck ? () => _setChecked(item, true) : null,
              onOpen: () => _openEditor(item),
            ),
          );
        },
      ),
    );
  }

  static String? _sectionOf(ListItemDto item) {
    final section = item.section?.trim();
    return section == null || section.isEmpty ? null : section;
  }

  /// Unsectioned items sort last - a named group is a deliberate act, the
  /// leftovers aren't.
  static int _sectionOrder(String? a, String? b) {
    if (a == null) return 1;
    if (b == null) return -1;
    return a.toLowerCase().compareTo(b.toLowerCase());
  }

  Widget _buildComposer(ThemeData theme) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.m,
          AppSpacing.s,
          AppSpacing.s,
          AppSpacing.s,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _composerController,
                focusNode: _composerFocus,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.sentences,
                maxLength: ListLimits.maxTextLength,
                minLines: 1,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add an item',
                  // The 200-char ceiling matters at 195, not at 4 - the
                  // counter is noise for the entire life of a normal line.
                  counterText: '',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.composerPill),
                    borderSide: BorderSide.none,
                  ),
                  // The theme's focus ring is for forms. A composer is a
                  // permanently-docked bar you type in constantly, and the
                  // message composer already suppresses it for that reason -
                  // the two sat side by side disagreeing.
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.composerPill),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.m,
                    vertical: 10,
                  ),
                ),
                onSubmitted: _add,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            IconButton.filled(
              onPressed: _composerController.text.trim().isEmpty
                  ? null
                  : () => _add(_composerController.text),
              icon: const Icon(Icons.add),
              tooltip: 'Add',
            ),
          ],
        ),
      ),
    );
  }
}

/// One line of the list.
class _ListItemRow extends StatelessWidget {
  const _ListItemRow({
    required this.item,
    this.onToggle,
    this.onOpen,
    this.pending = false,
  });

  final ListItemDto item;
  final VoidCallback? onToggle;
  final VoidCallback? onOpen;

  /// Added on this device, not yet acknowledged.
  final bool pending;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final quantity = formatListQuantity(item.quantity ?? '');
    final note = item.note?.trim();

    return Opacity(
      opacity: pending ? 0.5 : 1,
      child: HouseCard(
        padding: const EdgeInsets.fromLTRB(AppSpacing.s, 10, AppSpacing.m, 10),
        onTap: onOpen,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Deliberately generous: this is the tap target used one-handed,
            // in a shop, holding a basket.
            IconButton(
              onPressed: onToggle,
              visualDensity: VisualDensity.compact,
              icon: Icon(
                item.isChecked
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                color: item.isChecked ? theme.colorScheme.primary : muted,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.text,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            decoration: item.isChecked
                                ? TextDecoration.lineThrough
                                : null,
                            color: item.isChecked ? muted : null,
                          ),
                        ),
                      ),
                      // Free text, so it can be as long as "a bunch of the
                      // small ones" - it gets to shrink before the item name
                      // does, and ellipsizes rather than overflowing.
                      if (quantity.isNotEmpty) ...[
                        const SizedBox(width: AppSpacing.s),
                        Flexible(child: HousePill(label: quantity)),
                      ],
                    ],
                  ),
                  if (note != null && note.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      note,
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (item.sourcePantryItemId != null) ...[
                    const SizedBox(height: 4),
                    HousePill(
                      label: 'Added by the pantry',
                      icon: Icons.kitchen_outlined,
                      color: theme.colorScheme.tertiary,
                    ),
                  ],
                ],
              ),
            ),
            if (item.assigneeUserId != null) ...[
              const SizedBox(width: AppSpacing.s),
              UserAvatar(userId: item.assigneeUserId!, radius: 12),
            ],
          ],
        ),
      ),
    );
  }
}

/// The ticked-off items, collapsed under one header at the bottom. Kept
/// visible (rather than deleted on tick) because "did someone already grab
/// milk?" is a question people ask the list five minutes later.
class _CheckedGroup extends StatelessWidget {
  const _CheckedGroup({
    required this.items,
    required this.count,
    this.onToggle,
    required this.onOpen,
  });

  final List<ListItemDto> items;
  final int count;
  final void Function(ListItemDto item)? onToggle;
  final void Function(ListItemDto item) onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HouseSectionHeader(label: 'Done', trailing: Text('$count')),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: _ListItemRow(
              item: item,
              onToggle: onToggle == null ? null : () => onToggle!(item),
              onOpen: () => onOpen(item),
            ),
          ),
      ],
    );
  }
}

/// What [_ListItemSheet] resolves to. Nulls are meaningful - they mean
/// "cleared", which is why this isn't just a patched [ListItemDto].
class _ItemEditResult {
  const _ItemEditResult({
    this.text = '',
    this.quantity,
    this.note,
    this.section,
    this.assigneeUserId,
    this.delete = false,
  });

  final String text;
  final String? quantity;
  final String? note;
  final String? section;
  final String? assigneeUserId;
  final bool delete;
}

class _ListItemSheet extends StatefulWidget {
  const _ListItemSheet({
    required this.item,
    required this.members,
    required this.canDelete,
  });

  final ListItemDto item;
  final List<GuildMemberDto> members;
  final bool canDelete;

  @override
  State<_ListItemSheet> createState() => _ListItemSheetState();
}

class _ListItemSheetState extends State<_ListItemSheet> {
  late final _textController = TextEditingController(text: widget.item.text);
  late final _quantityController = TextEditingController(
    text: widget.item.quantity ?? '',
  );
  late final _noteController = TextEditingController(
    text: widget.item.note ?? '',
  );
  late final _sectionController = TextEditingController(
    text: widget.item.section ?? '',
  );
  late String? _assigneeUserId = widget.item.assigneeUserId;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _textController.dispose();
    _quantityController.dispose();
    _noteController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  String? _trimmedOrNull(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return HouseSheet(
      title: 'Edit item',
      actionLabel: 'Save',
      onAction: _textController.text.trim().isEmpty
          ? null
          : () => Navigator.of(context).pop(
              _ItemEditResult(
                text: _textController.text.trim(),
                quantity: _trimmedOrNull(_quantityController),
                note: _trimmedOrNull(_noteController),
                section: _trimmedOrNull(_sectionController),
                assigneeUserId: _assigneeUserId,
              ),
            ),
      leadingAction: widget.canDelete
          ? TextButton(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              onPressed: () =>
                  Navigator.of(context).pop(const _ItemEditResult(delete: true)),
              child: const Text('Delete'),
            )
          : null,
      children: [
        SheetField(
          label: 'Item',
          child: TextField(
            controller: _textController,
            autofocus: true,
            maxLength: ListLimits.maxTextLength,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(counterText: ''),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SheetField(
                label: 'How much',
                child: TextField(
                  controller: _quantityController,
                  // Free text on purpose: "2 packs" and "a bunch" are how
                  // people write a shopping list, and nothing computes on it.
                  decoration: const InputDecoration(hintText: '2 packs'),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: SheetField(
                label: 'Group',
                child: TextField(
                  controller: _sectionController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(hintText: 'Dairy'),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'Note',
          child: TextField(
            controller: _noteController,
            minLines: 1,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'The oat one, not the soy one',
            ),
          ),
        ),
        if (widget.members.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.m),
          SheetField(
            label: 'Whose job',
            child: DropdownButtonFormField<String?>(
              initialValue: _assigneeUserId,
              isExpanded: true,
              items: [
                const DropdownMenuItem<String?>(child: Text('Anyone')),
                for (final member in widget.members)
                  DropdownMenuItem<String?>(
                    value: member.userId,
                    child: Text(
                      member.nickname ?? member.profile?.userName ?? 'Someone',
                    ),
                  ),
              ],
              onChanged: (value) => setState(() => _assigneeUserId = value),
            ),
          ),
        ],
      ],
    );
  }
}
