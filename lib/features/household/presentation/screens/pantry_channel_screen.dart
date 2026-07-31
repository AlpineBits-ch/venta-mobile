import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/format/date_time_format.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/load_failure_view.dart';
import '../../../guilds/data/guild_repository.dart';
import '../../../guilds/data/models/channel_dto.dart';
import '../../../guilds/data/models/guild_features.dart';
import '../../data/household_repository.dart';
import '../../data/models/pantry_dto.dart';
import '../widgets/household_widgets.dart';
import 'household_channel_base.dart';

/// A `Pantry` channel - one location: the fridge, the freezer, the cellar.
///
/// The restock loop is the thing worth designing for: when something drops to
/// its threshold the server appends it to the configured shopping list and
/// stamps the item, so it can't be added twice while it's already on the list.
/// Buying it (ticking it off, or clearing done) re-arms the loop. None of that
/// is obvious from the outside, so the UI says which items are on the list and
/// says plainly when no list is configured at all - a threshold that silently
/// does nothing is worse than no threshold.
class PantryChannelScreen extends StatefulWidget {
  const PantryChannelScreen({
    super.key,
    required this.guildId,
    required this.channelId,
  });

  final String guildId;
  final String channelId;

  @override
  State<PantryChannelScreen> createState() => _PantryChannelScreenState();
}

class _PantryChannelScreenState
    extends HouseholdChannelState<PantryChannelScreen> {
  @override
  String get guildId => widget.guildId;
  @override
  String get channelId => widget.channelId;
  @override
  String get requiredFeature => GuildFeature.pantry;
  @override
  String get fallbackTitle => 'Pantry';

  List<PantryItemDto>? _items;
  PantryConfigDto? _config;
  bool _loadFailed = false;
  StreamSubscription<void>? _eventsSub;

  /// Tapping "+" four times is one intent, not four requests - the last value
  /// wins after a short pause.
  final _quantityDebounce = <String, Timer>{};

  /// What each debounced timer is going to send. Kept separately so leaving
  /// the screen mid-pause flushes the change instead of dropping it - taking
  /// the last of the milk and immediately backing out is a completely normal
  /// way to use this screen.
  final _pendingQuantity = <String, double>{};

  bool get _canManage => can('ManagePantry');

  @override
  void initState() {
    super.initState();
    _load();
    _eventsSub = household
        .channelEvents(widget.channelId, HouseholdEvents.pantry)
        .listen((_) => _load());
  }

  @override
  void dispose() {
    for (final timer in _quantityDebounce.values) {
      timer.cancel();
    }
    for (final entry in _pendingQuantity.entries) {
      // Fire and forget: there's no state left to reconcile against, and the
      // realtime event will correct anyone still looking at this pantry.
      householdApi
          .updatePantryItem(entry.key, quantity: entry.value)
          .then((_) {}, onError: (Object _) {});
    }
    unawaited(_eventsSub?.cancel());
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        api.getPantryItems(widget.channelId),
        api.getPantryConfig(widget.channelId),
      ]);
      if (!mounted) return;
      setState(() {
        _items = results[0] as List<PantryItemDto>;
        _config = results[1] as PantryConfigDto;
        _loadFailed = false;
      });
    } catch (_) {
      if (mounted && _items == null) setState(() => _loadFailed = true);
    }
  }

  void _adjustQuantity(PantryItemDto item, double delta) {
    if (!_canManage) return;
    final next = (item.quantity + delta).clamp(0.0, 999999.0).toDouble();
    if (next == item.quantity) return;
    setState(() {
      _items = [
        for (final i in _items ?? const <PantryItemDto>[])
          if (i.id == item.id)
            i.copyWith(
              quantity: next,
              // Predicted locally so the "Low" pill appears on the tap that
              // caused it; the server's own answer replaces this in a moment.
              isLow: i.lowThreshold != null && next <= i.lowThreshold!,
            )
          else
            i,
      ];
    });
    _quantityDebounce[item.id]?.cancel();
    _pendingQuantity[item.id] = next;
    _quantityDebounce[item.id] = Timer(
      const Duration(milliseconds: 600),
      () => unawaited(_commitQuantity(item.id, next)),
    );
  }

  Future<void> _commitQuantity(String itemId, double quantity) async {
    _pendingQuantity.remove(itemId);
    try {
      final updated = await api.updatePantryItem(itemId, quantity: quantity);
      if (!mounted) return;
      setState(() {
        _items = [
          for (final i in _items ?? const <PantryItemDto>[])
            if (i.id == itemId) updated else i,
        ];
      });
    } catch (error) {
      await _load();
      showError(error, 'Could not update that item.');
    }
  }

  Future<void> _openItemEditor([PantryItemDto? existing]) async {
    final saved = await showHouseSheet<bool>(
      context: context,
      builder: (_) =>
          _PantryItemSheet(channelId: widget.channelId, existing: existing),
    );
    if (saved == true) await _load();
  }

  Future<void> _openConfig() async {
    final lists =
        guild?.channels.where((c) => c.type == ChannelType.list).toList() ??
        const <ChannelDto>[];
    final saved = await showHouseSheet<bool>(
      context: context,
      builder: (_) => _PantryConfigSheet(
        channelId: widget.channelId,
        config: _config ?? const PantryConfigDto(),
        lists: lists,
      ),
    );
    if (saved == true) await _load();
  }

  Future<void> _openExpiring() async {
    await showHouseSheet<void>(
      context: context,
      builder: (_) => _ExpiringSheet(
        guildId: widget.guildId,
        days: _config?.expiryWarningDays ?? 3,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final warningDays = _config?.expiryWarningDays ?? 3;

    return Scaffold(
      appBar: buildAppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.schedule_outlined),
            tooltip: 'What needs eating',
            onPressed: _openExpiring,
          ),
          if (_canManage)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'config') unawaited(_openConfig());
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'config',
                  child: Text('Restock settings'),
                ),
              ],
            ),
        ],
      ),
      body: !moduleEnabled
          ? buildModuleOff()
          : _loadFailed
          ? LoadFailureView(
              message: 'Couldn\'t load the pantry.',
              onRetry: _load,
            )
          : items == null
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? HouseEmptyState(
              icon: Icons.kitchen_outlined,
              title: 'Nothing in here yet',
              body: _canManage
                  ? 'Add what you keep stocked. Give something a "running '
                        'low" level and it puts itself on the shopping list '
                        'when it gets there.'
                  : 'Nobody has added anything to this pantry yet.',
              action: _canManage
                  ? FilledButton(
                      onPressed: () => _openItemEditor(),
                      child: const Text('Add something'),
                    )
                  : null,
            )
          : _buildList(items, warningDays),
      floatingActionButton: moduleEnabled && _canManage && (items?.isNotEmpty ?? false)
          ? FloatingActionButton(
              onPressed: () => _openItemEditor(),
              tooltip: 'Add to the pantry',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildList(List<PantryItemDto> items, int warningDays) {
    final theme = Theme.of(context);
    final low = items.where((i) => i.isLow).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final expiring =
        items
            .where((i) => !i.isLow && i.isExpiringWithin(warningDays))
            .toList()
          ..sort(
            (a, b) => (a.expiresAt ?? DateTime(9999)).compareTo(
              b.expiresAt ?? DateTime(9999),
            ),
          );
    final rest =
        items
            .where((i) => !i.isLow && !i.isExpiringWithin(warningDays))
            .toList()
          ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );

    final restockOff = _config?.restockListChannelId == null;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.m,
          AppSpacing.s,
          AppSpacing.m,
          80,
        ),
        children: [
          if (low.isNotEmpty && restockOff)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s),
              child: HouseCard(
                tint: theme.colorScheme.tertiary,
                onTap: _canManage ? _openConfig : null,
                child: Row(
                  children: [
                    Icon(
                      Icons.playlist_add_check_circle_outlined,
                      color: theme.colorScheme.tertiary,
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Text(
                        _canManage
                            ? 'Nothing is being added to a shopping list. '
                                  'Pick a list in restock settings and low '
                                  'items go there on their own.'
                            : 'This pantry isn\'t linked to a shopping list, '
                                  'so low items stay here.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ..._group('Running low', low, theme.colorScheme.error, warningDays),
          ..._group(
            'Eat these first',
            expiring,
            theme.colorScheme.tertiary,
            warningDays,
          ),
          ..._group('In stock', rest, null, warningDays),
        ],
      ),
    );
  }

  List<Widget> _group(
    String label,
    List<PantryItemDto> items,
    Color? color,
    int warningDays,
  ) {
    if (items.isEmpty) return const [];
    return [
      HouseSectionHeader(
        label: label,
        color: color,
        trailing: Text('${items.length}'),
      ),
      for (final item in items)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s),
          child: _PantryRow(
            item: item,
            warningDays: warningDays,
            canManage: _canManage,
            onAdjust: (delta) => _adjustQuantity(item, delta),
            onOpen: _canManage ? () => _openItemEditor(item) : null,
          ),
        ),
    ];
  }
}

class _PantryRow extends StatelessWidget {
  const _PantryRow({
    required this.item,
    required this.warningDays,
    required this.canManage,
    required this.onAdjust,
    this.onOpen,
  });

  final PantryItemDto item;
  final int warningDays;
  final bool canManage;
  final ValueChanged<double> onAdjust;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final unit = item.unit?.trim();

    return HouseCard(
      padding: const EdgeInsets.fromLTRB(AppSpacing.m, 10, AppSpacing.s, 10),
      onTap: onOpen,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(item.name, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 3),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (item.isLow)
                      HousePill(
                        label: 'Running low',
                        icon: Icons.trending_down_rounded,
                        color: theme.colorScheme.error,
                      ),
                    // The whole point of the loop is that people know why milk
                    // showed up on the list - and that it won't be added twice.
                    if (item.isAwaitingRestock)
                      HousePill(
                        label: 'On the shopping list',
                        icon: Icons.check_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    if (item.expiresAt != null)
                      HousePill(
                        label: _expiryLabel(item.expiresAt!),
                        icon: Icons.schedule_outlined,
                        color: item.isExpired()
                            ? theme.colorScheme.error
                            : item.isExpiringWithin(warningDays)
                            ? theme.colorScheme.tertiary
                            : null,
                        filled: item.isExpiringWithin(warningDays),
                      ),
                    if (item.lowThreshold != null && !item.isLow)
                      Text(
                        'low at ${formatQuantity(item.lowThreshold!)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: muted,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          if (canManage)
            _QuantityStepper(
              quantity: item.quantity,
              unit: unit,
              onAdjust: onAdjust,
            )
          else
            Text(
              unit == null || unit.isEmpty
                  ? formatQuantity(item.quantity)
                  : '${formatQuantity(item.quantity)} $unit',
              style: theme.textTheme.titleSmall,
            ),
        ],
      ),
    );
  }

  static String _expiryLabel(DateTime expiresAt) {
    final now = DateTime.now();
    final local = expiresAt.toLocal();
    final days = DateTime(local.year, local.month, local.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    return switch (days) {
      < 0 => 'went off',
      0 => 'today',
      1 => 'tomorrow',
      < 14 => 'in $days days',
      _ => formatShortDateTime(local).split(',').first,
    };
  }
}

/// Taking the last of the milk should be one tap, from the list, without
/// opening anything.
class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.unit,
    required this.onAdjust,
  });

  final double quantity;
  final String? unit;
  final ValueChanged<double> onAdjust;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: quantity <= 0 ? null : () => onAdjust(-1),
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.remove_circle_outline, size: 20),
          tooltip: 'One less',
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 34),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatQuantity(quantity),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall,
              ),
              if (unit != null && unit!.isNotEmpty)
                Text(
                  unit!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => onAdjust(1),
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.add_circle_outline, size: 20),
          tooltip: 'One more',
        ),
      ],
    );
  }
}

class _PantryItemSheet extends StatefulWidget {
  const _PantryItemSheet({required this.channelId, this.existing});

  final String channelId;
  final PantryItemDto? existing;

  @override
  State<_PantryItemSheet> createState() => _PantryItemSheetState();
}

class _PantryItemSheetState extends State<_PantryItemSheet> {
  late final _nameController = TextEditingController(
    text: widget.existing?.name ?? '',
  );
  late final _quantityController = TextEditingController(
    text: widget.existing == null
        ? '1'
        : formatQuantity(widget.existing!.quantity),
  );
  late final _unitController = TextEditingController(
    text: widget.existing?.unit ?? '',
  );
  late final _thresholdController = TextEditingController(
    text: widget.existing?.lowThreshold == null
        ? ''
        : formatQuantity(widget.existing!.lowThreshold!),
  );
  late DateTime? _expiresAt = widget.existing?.expiresAt;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  double? _parse(TextEditingController controller) =>
      double.tryParse(controller.text.trim().replaceAll(',', '.'));

  Future<void> _pickExpiry() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? now.add(const Duration(days: 7)),
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (date != null && mounted) setState(() => _expiresAt = date);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    final quantity = _parse(_quantityController) ?? 0;
    final threshold = _parse(_thresholdController);
    final unit = _unitController.text.trim();
    try {
      if (widget.existing == null) {
        await householdApi.createPantryItem(
          widget.channelId,
          name: name,
          quantity: quantity,
          unit: unit.isEmpty ? null : unit,
          lowThreshold: threshold,
          expiresAt: _expiresAt,
        );
      } else {
        await householdApi.updatePantryItem(
          widget.existing!.id,
          name: name,
          quantity: quantity,
          unit: unit,
          clearUnit: unit.isEmpty,
          lowThreshold: threshold,
          clearLowThreshold: threshold == null,
          expiresAt: _expiresAt,
          clearExpiresAt: _expiresAt == null,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(householdErrorText(error, 'Could not save that.')),
        ),
      );
    }
  }

  Future<void> _delete() async {
    final existing = widget.existing;
    if (existing == null) return;
    try {
      await householdApi.deletePantryItem(existing.id);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(householdErrorText(error, 'Could not delete that.')),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return HouseSheet(
      title: widget.existing == null ? 'Add to the pantry' : 'Edit item',
      actionLabel: 'Save',
      busy: _saving,
      onAction: _nameController.text.trim().isEmpty ? null : _save,
      leadingAction: widget.existing == null
          ? null
          : TextButton(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              onPressed: _delete,
              child: const Text('Delete'),
            ),
      children: [
        SheetField(
          label: 'What',
          child: TextField(
            controller: _nameController,
            autofocus: widget.existing == null,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'Milk'),
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
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: SheetField(
                label: 'Unit',
                child: TextField(
                  controller: _unitController,
                  decoration: const InputDecoration(hintText: 'l'),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'Put it on the list at',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _thresholdController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: const InputDecoration(
                  hintText: 'Leave empty to never track this',
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'When it drops to this, it adds itself to the shopping list - '
                'once, until it\'s bought.',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'Goes off',
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickExpiry,
                  icon: const Icon(Icons.event_outlined, size: 18),
                  label: Text(
                    _expiresAt == null
                        ? 'No date'
                        : formatShortDateTime(_expiresAt!).split(',').first,
                  ),
                ),
              ),
              if (_expiresAt != null)
                IconButton(
                  onPressed: () => setState(() => _expiresAt = null),
                  icon: const Icon(Icons.close),
                  tooltip: 'Clear',
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PantryConfigSheet extends StatefulWidget {
  const _PantryConfigSheet({
    required this.channelId,
    required this.config,
    required this.lists,
  });

  final String channelId;
  final PantryConfigDto config;
  final List<ChannelDto> lists;

  @override
  State<_PantryConfigSheet> createState() => _PantryConfigSheetState();
}

class _PantryConfigSheetState extends State<_PantryConfigSheet> {
  late String? _restockListChannelId = widget.config.restockListChannelId;
  late int _expiryWarningDays = widget.config.expiryWarningDays;
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await householdApi.updatePantryConfig(
        widget.channelId,
        restockListChannelId: _restockListChannelId,
        expiryWarningDays: _expiryWarningDays,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            householdErrorText(error, 'Could not save those settings.'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return HouseSheet(
      title: 'Restock settings',
      actionLabel: 'Save',
      busy: _saving,
      onAction: _save,
      children: [
        SheetField(
          label: 'Add low items to',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.lists.isEmpty)
                Text(
                  'This house has no list channel yet. Make one and it can '
                  'catch everything that runs out.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                )
              else
                DropdownButtonFormField<String?>(
                  initialValue: _restockListChannelId,
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem<String?>(
                      child: Text('Nowhere - don\'t add automatically'),
                    ),
                    for (final list in widget.lists)
                      DropdownMenuItem<String?>(
                        value: list.id,
                        child: Text('#${list.name}'),
                      ),
                  ],
                  onChanged: (value) =>
                      setState(() => _restockListChannelId = value),
                ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _restockListChannelId == null
                    ? 'With nothing chosen, the whole restock loop is off - '
                          'individual "running low" levels won\'t do anything.'
                    : 'Anything that hits its "running low" level is added '
                          'here, once, and marked so you know where it came '
                          'from.',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'Warn about expiry',
          child: Wrap(
            spacing: AppSpacing.xs,
            children: [
              for (final days in const [1, 2, 3, 5, 7, 14])
                ChoiceChip(
                  label: Text(days == 1 ? '1 day' : '$days days'),
                  selected: _expiryWarningDays == days,
                  onSelected: (_) =>
                      setState(() => _expiryWarningDays = days),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// What needs eating, across **every** pantry in the house - the question is
/// about the house, not one fridge. The server filters by `ViewChannel`, so a
/// guest with access to one pantry can't use this to enumerate a private one.
class _ExpiringSheet extends StatefulWidget {
  const _ExpiringSheet({required this.guildId, required this.days});

  final String guildId;
  final int days;

  @override
  State<_ExpiringSheet> createState() => _ExpiringSheetState();
}

class _ExpiringSheetState extends State<_ExpiringSheet> {
  List<PantryItemDto>? _items;
  bool _failed = false;
  late int _days = widget.days;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await householdApi.getExpiringPantryItems(
        widget.guildId,
        days: _days,
      );
      if (mounted) {
        setState(() {
          _items = items;
          _failed = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  String _channelName(String channelId) {
    final channel = getIt<GuildRepository>()
        .cachedById(widget.guildId)
        ?.channels
        .where((c) => c.id == channelId)
        .firstOrNull;
    return channel == null ? 'Pantry' : '#${channel.name}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = _items;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.l,
          AppSpacing.l,
          AppSpacing.l,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What needs eating', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s),
            Wrap(
              spacing: AppSpacing.xs,
              children: [
                for (final days in const [3, 7, 14, 30])
                  ChoiceChip(
                    label: Text('$days days'),
                    selected: _days == days,
                    onSelected: (_) {
                      setState(() {
                        _days = days;
                        _items = null;
                      });
                      unawaited(_load());
                    },
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: _failed
                  ? LoadFailureView(
                      message: 'Couldn\'t check the pantries.',
                      onRetry: _load,
                    )
                  : items == null
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.l),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : items.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.l,
                      ),
                      child: Text(
                        'Nothing is going off in the next $_days days.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    )
                  : ListView(
                      shrinkWrap: true,
                      children: [
                        for (final item
                            in [..._items!]..sort(
                              (a, b) => (a.expiresAt ?? DateTime(9999))
                                  .compareTo(b.expiresAt ?? DateTime(9999)),
                            ))
                          ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(item.name),
                            subtitle: Text(_channelName(item.channelId)),
                            trailing: Text(
                              item.expiresAt == null
                                  ? ''
                                  : _PantryRow._expiryLabel(item.expiresAt!),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: item.isExpired()
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.tertiary,
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
