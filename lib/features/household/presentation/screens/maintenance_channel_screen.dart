import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/format/date_time_format.dart';
import '../../../../core/routing/household_deep_link.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/load_failure_view.dart';
import '../../../guilds/data/models/guild_features.dart';
import '../../data/household_api_wave2.dart';
import '../../data/household_repository.dart';
import '../../data/models/maintenance_dto.dart';
import '../widgets/household_widgets.dart';
import 'household_channel_base.dart';

/// A `Maintenance` channel - the house's machines and what has been done to
/// them.
///
/// Opened rarely and under pressure: standing at a boiler at 22:00 on a Sunday,
/// or in front of a washing machine that has stopped. So this optimises for
/// *finding* rather than for density - few big rows, the two facts that matter
/// (the warranty date and the vendor's number) given real room, and the phone
/// number tappable rather than something to copy out by hand.
///
/// **Reporting a fault is one tap and needs only `LogMaintenance`.** Whoever
/// discovers the machine is dead is whoever tried to use it, and making them
/// find an admin first is how a house ends up with a broken machine nobody has
/// written down.
class MaintenanceChannelScreen extends StatefulWidget {
  const MaintenanceChannelScreen({
    super.key,
    required this.guildId,
    required this.channelId,
    this.focus,
  });

  final String guildId;
  final String channelId;

  /// The asset a `maintenance.*` notification opened this at. Every one of
  /// those kinds names the asset - a service is not a row with a life of its
  /// own, it is something that happened to a machine.
  final HouseholdFocus? focus;

  @override
  State<MaintenanceChannelScreen> createState() =>
      _MaintenanceChannelScreenState();
}

class _MaintenanceChannelScreenState
    extends HouseholdChannelState<MaintenanceChannelScreen> {
  @override
  String get guildId => widget.guildId;
  @override
  String get channelId => widget.channelId;
  @override
  String get requiredFeature => GuildFeature.maintenance;
  @override
  String get fallbackTitle => 'Upkeep';

  List<MaintenanceAssetDto>? _assets;
  bool _loadFailed = false;
  StreamSubscription<void>? _eventsSub;

  bool get _canLog => can('LogMaintenance');
  bool get _canManage => can('ManageMaintenance');

  @override
  void initState() {
    focus = widget.focus;
    super.initState();
    unawaited(_load());
    _eventsSub = household
        .channelEvents(widget.channelId, HouseholdEvents.maintenance)
        .listen((_) => unawaited(_load()));
  }

  @override
  void dispose() {
    unawaited(_eventsSub?.cancel());
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final assets = await api.getMaintenanceAssets(widget.channelId);
      if (mounted) {
        setState(() {
          _assets = assets;
          _loadFailed = false;
        });
      }
    } catch (_) {
      if (mounted && _assets == null) setState(() => _loadFailed = true);
    }
  }

  Future<void> _openAsset(MaintenanceAssetDto asset) async {
    final changed = await Navigator.of(context, rootNavigator: true).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => MaintenanceAssetScreen(
          asset: asset,
          canLog: _canLog,
          canManage: _canManage,
        ),
      ),
    );
    if (changed == true) await _load();
  }

  Future<void> _openEditor([MaintenanceAssetDto? existing]) async {
    final saved = await showHouseSheet<bool>(
      context: context,
      builder: (_) =>
          _AssetSheet(channelId: widget.channelId, existing: existing),
    );
    if (saved == true) await _load();
  }

  /// The one-tap fault report, from the board without opening anything.
  Future<void> _markBroken(MaintenanceAssetDto asset) async {
    if (!_canLog) return;
    houseHapticHeavy();
    setState(() {
      _assets = [
        for (final a in _assets ?? const <MaintenanceAssetDto>[])
          if (a.id == asset.id) a.copyWith(status: AssetStatus.broken) else a,
      ];
    });
    try {
      final updated = await api.setAssetStatus(
        asset.id,
        status: AssetStatus.broken,
      );
      if (!mounted) return;
      setState(() {
        _assets = [
          for (final a in _assets ?? const <MaintenanceAssetDto>[])
            if (a.id == asset.id) updated else a,
        ];
      });
      showMessage('${asset.name} is marked broken. The house has been told.');
    } catch (error) {
      await _load();
      showError(error, 'Could not report that.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final assets = _assets;
    return Scaffold(
      appBar: buildAppBar(),
      body: !moduleEnabled
          ? buildModuleOff()
          : _loadFailed
          ? LoadFailureView(
              message: 'Couldn\'t load the appliances.',
              onRetry: _load,
            )
          : assets == null
          ? const HouseCardSkeleton(lines: 3)
          : assets.isEmpty
          ? HouseEmptyState(
              icon: Icons.handyman_outlined,
              title: 'Nothing listed',
              body: _canManage
                  ? 'The boiler, the washing machine, the dishwasher. Add one '
                        'with its warranty date and the plumber\'s number, and '
                        'the two things nobody can find at 22:00 on a Sunday '
                        'are already here.'
                  : 'Nobody has listed an appliance yet.',
              action: _canManage
                  ? FilledButton.icon(
                      onPressed: () => unawaited(_openEditor()),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add an appliance'),
                    )
                  : null,
            )
          : _buildList(assets),
      bottomNavigationBar:
          moduleEnabled && _canManage && (assets?.isNotEmpty ?? false)
          ? HouseActionBar(
              child: HousePrimaryButton(
                label: 'Add an appliance',
                icon: Icons.add_rounded,
                onPressed: () => unawaited(_openEditor()),
              ),
            )
          : null,
    );
  }

  Widget _buildList(List<MaintenanceAssetDto> assets) {
    // Everything that wants a human first, in the order somebody would deal
    // with it. Broken is urgent; out of use is a decision the house already
    // took and is not.
    final attention = assets.where((a) => a.needsSomebody).toList()
      ..sort((a, b) => _urgency(b).compareTo(_urgency(a)));
    final rest = assets.where((a) => !a.needsSomebody).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return RefreshIndicator.adaptive(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.m,
          AppSpacing.s,
          AppSpacing.m,
          AppSpacing.xl,
        ),
        children: [
          ..._group('Needs somebody', attention, tint: true),
          ..._group('Everything else', rest),
        ],
      ),
    );
  }

  static int _urgency(MaintenanceAssetDto asset) => switch (asset) {
    _ when asset.status == AssetStatus.broken => 4,
    _ when asset.isServiceOverdue => 3,
    _ when asset.status == AssetStatus.needsAttention => 2,
    _ when asset.isWarrantyExpiring => 1,
    _ => 0,
  };

  List<Widget> _group(
    String label,
    List<MaintenanceAssetDto> assets, {
    bool tint = false,
  }) {
    if (assets.isEmpty) return const [];
    final theme = Theme.of(context);
    return [
      HouseSectionHeader(
        label: label,
        color: tint ? theme.colorScheme.error : null,
        trailing: Text('${assets.length}'),
      ),
      for (final asset in assets)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s),
          child: focusRow(
            HouseholdFocusKind.maintenanceAsset,
            asset.id,
            label: 'The appliance you were told about',
            AssetCard(
              asset: asset,
              onTap: () => unawaited(_openAsset(asset)),
              onMarkBroken: _canLog && asset.status != AssetStatus.broken
                  ? () => unawaited(_markBroken(asset))
                  : null,
            ),
          ),
        ),
    ];
  }
}

/// One machine, as it appears on a board.
class AssetCard extends StatelessWidget {
  const AssetCard({
    super.key,
    required this.asset,
    required this.onTap,
    this.onMarkBroken,
  });

  final MaintenanceAssetDto asset;
  final VoidCallback onTap;

  /// One tap, from wherever the asset appears. `LogMaintenance`, not
  /// `ManageMaintenance`.
  final VoidCallback? onMarkBroken;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final broken = asset.status == AssetStatus.broken;

    return HouseCard(
      onTap: onTap,
      tint: broken ? theme.colorScheme.error : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (asset.location?.trim().isNotEmpty ?? false) ...[
                  const SizedBox(height: 2),
                  Text(
                    asset.location!,
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                ],
                const SizedBox(height: AppSpacing.s),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    if (asset.status != AssetStatus.ok)
                      HousePill(
                        label: asset.status.label,
                        icon: asset.status.icon,
                        color: broken
                            ? theme.colorScheme.error
                            // Out of use is a decision, not an emergency, so
                            // it never borrows the alarm colour.
                            : asset.status == AssetStatus.outOfService
                            ? null
                            : theme.colorScheme.tertiary,
                      ),
                    if (asset.isServiceOverdue)
                      HousePill(
                        label: 'Service overdue',
                        icon: Icons.build_outlined,
                        color: theme.colorScheme.tertiary,
                      ),
                    if (asset.isWarrantyExpiring && asset.warrantyUntil != null)
                      HousePill(
                        label:
                            'Warranty to '
                            '${formatShortDateTime(asset.warrantyUntil!).split(',').first}',
                        icon: Icons.verified_outlined,
                        color: theme.colorScheme.tertiary,
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (onMarkBroken != null)
            IconButton(
              onPressed: onMarkBroken,
              visualDensity: VisualDensity.compact,
              tooltip: 'Report ${asset.name} as broken',
              icon: Icon(
                Icons.report_gmailerrorred_rounded,
                size: 22,
                color: theme.colorScheme.error,
              ),
            ),
        ],
      ),
    );
  }
}

/// One machine, in full, plus its service log.
class MaintenanceAssetScreen extends StatefulWidget {
  const MaintenanceAssetScreen({
    super.key,
    required this.asset,
    required this.canLog,
    required this.canManage,
  });

  final MaintenanceAssetDto asset;
  final bool canLog;
  final bool canManage;

  @override
  State<MaintenanceAssetScreen> createState() => _MaintenanceAssetScreenState();
}

class _MaintenanceAssetScreenState extends State<MaintenanceAssetScreen> {
  late MaintenanceAssetDto _asset = widget.asset;
  List<MaintenanceRecordDto>? _records;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadRecords());
  }

  Future<void> _loadRecords() async {
    try {
      final page = await householdApi.getMaintenanceRecords(
        _asset.channelId,
        assetId: _asset.id,
      );
      if (mounted) setState(() => _records = page.items);
    } catch (_) {
      if (mounted) setState(() => _records = const []);
    }
  }

  Future<void> _setStatus(AssetStatus status) async {
    houseHapticHeavy();
    try {
      final updated = await householdApi.setAssetStatus(
        _asset.id,
        status: status,
      );
      if (!mounted) return;
      setState(() {
        _asset = updated;
        _changed = true;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(householdErrorText(error, 'Could not change that.')),
          ),
        );
      }
    }
  }

  Future<void> _recordService() async {
    final saved = await showHouseSheet<bool>(
      context: context,
      builder: (_) => _ServiceSheet(asset: _asset),
    );
    if (saved != true) return;
    _changed = true;
    await _loadRecords();
    try {
      final assets = await householdApi.getMaintenanceAssets(_asset.channelId);
      final refreshed = assets.where((a) => a.id == _asset.id).firstOrNull;
      if (refreshed != null && mounted) setState(() => _asset = refreshed);
    } catch (_) {
      // The log is the part that just changed; the header catches up on the
      // next open.
    }
  }

  Future<void> _call(String number) async {
    final uri = Uri(scheme: 'tel', path: number.replaceAll(' ', ''));
    if (!await launchUrl(uri) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No app on this phone can dial that.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final records = _records;
    final phone = _asset.vendorPhone?.trim();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_changed);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_asset.name)),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.m,
            AppSpacing.m,
            AppSpacing.m,
            HouseActionBar.reservedHeight,
          ),
          children: [
            // The two facts somebody is standing there needing, first and
            // biggest: is it still under warranty, and who do I ring.
            _WarrantyCard(asset: _asset),
            if (phone != null && phone.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s),
              _VendorCard(
                name: _asset.vendorName,
                phone: phone,
                onCall: () => unawaited(_call(phone)),
              ),
            ],
            const SizedBox(height: AppSpacing.m),
            _DetailRows(asset: _asset),
            const SizedBox(height: AppSpacing.m),
            const HouseSectionHeader(label: 'State'),
            _StatusPicker(
              status: _asset.status,
              note: _asset.statusNote,
              enabled: widget.canLog,
              onChanged: _setStatus,
            ),
            const SizedBox(height: AppSpacing.m),
            HouseSectionHeader(
              label: 'Service log',
              trailing: Text('${records?.length ?? 0}'),
            ),
            if (records == null)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.m),
                child: Center(child: CircularProgressIndicator.adaptive()),
              )
            else if (records.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
                child: Text(
                  'Nothing logged yet. A service records when it was actually '
                  'done and schedules the next one from there.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: muted,
                    height: 1.4,
                  ),
                ),
              )
            else
              for (final record in records)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.s),
                  child: _RecordCard(record: record),
                ),
          ],
        ),
        bottomNavigationBar: widget.canLog
            ? HouseActionBar(
                child: HousePrimaryButton(
                  label: 'Log a service',
                  icon: Icons.build_outlined,
                  onPressed: _recordService,
                ),
              )
            : null,
      ),
    );
  }
}

/// The warranty date, given the room it deserves.
///
/// It is the one date in a flat nobody tracks and the one that is expensive to
/// have missed, so it is the first thing on the page and it is written out in
/// full rather than folded into a row of metadata.
class _WarrantyCard extends StatelessWidget {
  const _WarrantyCard({required this.asset});

  final MaintenanceAssetDto asset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final until = asset.warrantyUntil;
    final lapsed = asset.warrantyLapsed();

    final color = until == null
        ? muted
        : lapsed
        ? muted
        : asset.isWarrantyExpiring
        ? theme.colorScheme.tertiary
        : theme.colorScheme.primary;

    return HouseCard(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_outlined, size: 18, color: color),
              const SizedBox(width: AppSpacing.s),
              Text(
                'WARRANTY',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            until == null
                ? 'Not recorded'
                : formatShortDateTime(until).split(',').first,
            style: theme.textTheme.headlineSmall?.copyWith(color: color),
          ),
          const SizedBox(height: 2),
          Text(
            until == null
                ? 'Worth digging the receipt out once - it is the date nobody '
                      'can find when something breaks.'
                : lapsed
                ? 'Ran out. A repair is the house\'s to pay for now.'
                : asset.isWarrantyExpiring
                ? 'Running out soon. If anything is wrong with it, now is when '
                      'to say so.'
                : 'Still covered.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: muted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _VendorCard extends StatelessWidget {
  const _VendorCard({
    required this.name,
    required this.phone,
    required this.onCall,
  });

  final String? name;
  final String phone;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    return HouseCard(
      onTap: onCall,
      child: Row(
        children: [
          Icon(Icons.call_outlined, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name?.trim().isNotEmpty ?? false ? name! : 'Whoever fixes it',
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
                Text(phone, style: theme.textTheme.titleSmall),
              ],
            ),
          ),
          Text(
            'Call',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRows extends StatelessWidget {
  const _DetailRows({required this.asset});

  final MaintenanceAssetDto asset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final rows = <(String, String)>[
      if (asset.brand?.trim().isNotEmpty ?? false) ('Make', asset.brand!),
      if (asset.model?.trim().isNotEmpty ?? false) ('Model', asset.model!),
      if (asset.serialNumber?.trim().isNotEmpty ?? false)
        ('Serial', asset.serialNumber!),
      if (asset.purchasedAt != null)
        ('Bought', formatShortDateTime(asset.purchasedAt!).split(',').first),
      if (asset.lastServicedAt != null)
        (
          'Last serviced',
          formatShortDateTime(asset.lastServicedAt!).split(',').first,
        ),
      if (asset.nextServiceAt != null)
        (
          'Next service',
          formatShortDateTime(asset.nextServiceAt!).split(',').first,
        ),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();

    return HouseCard(
      child: Column(
        children: [
          for (final (label, value) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 108,
                    child: Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ),
                  Expanded(
                    child: SelectableText(
                      value,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Broken and out of use are not the same thing, and the picker says so
/// out loud rather than leaving somebody to guess from two similar words.
class _StatusPicker extends StatelessWidget {
  const _StatusPicker({
    required this.status,
    required this.note,
    required this.enabled,
    required this.onChanged,
  });

  final AssetStatus status;
  final String? note;
  final bool enabled;
  final ValueChanged<AssetStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final value in AssetStatus.values)
          // A list of tappable rows rather than a radio group: the whole row is
          // the target, which matters when this is being tapped one-handed in
          // front of a machine that has just stopped.
          Semantics(
            selected: value == status,
            button: enabled,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              enabled: enabled,
              onTap: enabled ? () => onChanged(value) : null,
              leading: Icon(
                value == status
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: value == status
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              title: Text(value.label),
              subtitle: Text(
                value.description,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: muted,
                  height: 1.3,
                ),
              ),
            ),
          ),
        if (note?.trim().isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              note!,
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
          ),
      ],
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record});

  final MaintenanceRecordDto record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final cost = record.costMinor;
    return HouseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(record.title, style: theme.textTheme.titleSmall),
              ),
              if (cost != null)
                HouseAmount(
                  amountMinor: cost,
                  currency: record.currency ?? 'CHF',
                  style: theme.textTheme.bodyMedium,
                ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            [
              formatShortDateTime(record.performedAt).split(',').first,
              if (record.vendorName?.trim().isNotEmpty ?? false)
                record.vendorName!,
            ].join(' · '),
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
          if (record.description?.trim().isNotEmpty ?? false) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              record.description!,
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
          ],
        ],
      ),
    );
  }
}

class _ServiceSheet extends StatefulWidget {
  const _ServiceSheet({required this.asset});

  final MaintenanceAssetDto asset;

  @override
  State<_ServiceSheet> createState() => _ServiceSheetState();
}

class _ServiceSheetState extends State<_ServiceSheet> {
  final _titleController = TextEditingController();
  final _vendorController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _performedAt = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _vendorController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _performedAt,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
    );
    if (date != null && mounted) setState(() => _performedAt = date);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await householdApi.recordService(
        widget.asset.id,
        performedAt: _performedAt,
        title: _titleController.text.trim(),
        notes: _notesController.text.trim(),
        vendorName: _vendorController.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(householdErrorText(error, 'Could not log that.')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    return HouseSheet(
      title: 'Log a service',
      actionLabel: 'Log it',
      busy: _saving,
      onAction: _save,
      children: [
        SheetField(
          label: 'When it was actually done',
          child: OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.event_outlined, size: 18),
            label: Text(formatShortDateTime(_performedAt).split(',').first),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          // Not from the date it was due: a service six weeks late does not
          // pull the next one six weeks forward.
          'The next service is scheduled from this date, not from the one it '
          'was supposed to happen on.',
          style: theme.textTheme.labelSmall?.copyWith(
            color: muted,
            height: 1.3,
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'What was done',
          child: TextField(
            controller: _titleController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'Annual service'),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'Who did it',
          child: TextField(
            controller: _vendorController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'Optional'),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'Notes',
          child: TextField(
            controller: _notesController,
            minLines: 2,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          'A visit is not proof it works, so logging a service does not clear '
          'a broken machine. Set it back to working yourself once it is.',
          style: theme.textTheme.labelSmall?.copyWith(
            color: muted,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _AssetSheet extends StatefulWidget {
  const _AssetSheet({required this.channelId, this.existing});

  final String channelId;
  final MaintenanceAssetDto? existing;

  @override
  State<_AssetSheet> createState() => _AssetSheetState();
}

class _AssetSheetState extends State<_AssetSheet> {
  late final _nameController = TextEditingController(
    text: widget.existing?.name ?? '',
  );
  late final _locationController = TextEditingController(
    text: widget.existing?.location ?? '',
  );
  late final _brandController = TextEditingController(
    text: widget.existing?.brand ?? '',
  );
  late final _serialController = TextEditingController(
    text: widget.existing?.serialNumber ?? '',
  );
  late final _vendorNameController = TextEditingController(
    text: widget.existing?.vendorName ?? '',
  );
  late final _vendorPhoneController = TextEditingController(
    text: widget.existing?.vendorPhone ?? '',
  );
  late DateTime? _warrantyUntil = widget.existing?.warrantyUntil;
  late int? _serviceIntervalDays = widget.existing?.serviceIntervalDays;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _brandController.dispose();
    _serialController.dispose();
    _vendorNameController.dispose();
    _vendorPhoneController.dispose();
    super.dispose();
  }

  String? _text(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _pickWarranty() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _warrantyUntil ?? now.add(const Duration(days: 365 * 2)),
      firstDate: DateTime(now.year - 20),
      lastDate: DateTime(now.year + 20),
      helpText: 'Warranty runs until',
    );
    if (date != null && mounted) setState(() => _warrantyUntil = date);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      if (widget.existing == null) {
        await householdApi.createMaintenanceAsset(
          widget.channelId,
          name: _nameController.text.trim(),
          location: _text(_locationController),
          brand: _text(_brandController),
          serialNumber: _text(_serialController),
          warrantyUntil: _warrantyUntil,
          vendorName: _text(_vendorNameController),
          vendorPhone: _text(_vendorPhoneController),
          serviceIntervalDays: _serviceIntervalDays,
        );
      } else {
        await householdApi.updateMaintenanceAsset(
          widget.existing!.id,
          name: _nameController.text.trim(),
          location: _text(_locationController),
          brand: _text(_brandController),
          serialNumber: _text(_serialController),
          warrantyUntil: _warrantyUntil,
          clearWarrantyUntil: _warrantyUntil == null,
          vendorName: _text(_vendorNameController),
          vendorPhone: _text(_vendorPhoneController),
          serviceIntervalDays: _serviceIntervalDays,
          clearServiceInterval: _serviceIntervalDays == null,
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
      await householdApi.deleteMaintenanceAsset(existing.id);
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
      title: widget.existing == null ? 'Add an appliance' : 'Edit appliance',
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
            decoration: const InputDecoration(hintText: 'Washing machine'),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'Where',
          child: TextField(
            controller: _locationController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'Bathroom'),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        // First-class rather than buried with make and model: it is the date
        // that costs money to have missed.
        SheetField(
          label: 'Warranty runs until',
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickWarranty,
                  icon: const Icon(Icons.verified_outlined, size: 18),
                  label: Text(
                    _warrantyUntil == null
                        ? 'Not recorded'
                        : formatShortDateTime(_warrantyUntil!).split(',').first,
                  ),
                ),
              ),
              if (_warrantyUntil != null)
                IconButton(
                  onPressed: () => setState(() => _warrantyUntil = null),
                  tooltip: 'Clear',
                  icon: const Icon(Icons.close_rounded),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'Who fixes it',
          child: Column(
            children: [
              TextField(
                controller: _vendorNameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'Plumber, shop…'),
              ),
              const SizedBox(height: AppSpacing.s),
              TextField(
                controller: _vendorPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(hintText: 'Phone number'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'Serviced every',
          child: Wrap(
            spacing: AppSpacing.xs,
            children: [
              for (final days in const <int?>[null, 180, 365, 730])
                ChoiceChip(
                  label: Text(
                    days == null
                        ? 'Never'
                        : days == 365
                        ? 'Year'
                        : days == 730
                        ? '2 years'
                        : '6 months',
                  ),
                  selected: _serviceIntervalDays == days,
                  onSelected: (_) =>
                      setState(() => _serviceIntervalDays = days),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'Make and serial',
          child: Column(
            children: [
              TextField(
                controller: _brandController,
                decoration: const InputDecoration(hintText: 'Make'),
              ),
              const SizedBox(height: AppSpacing.s),
              TextField(
                controller: _serialController,
                decoration: const InputDecoration(hintText: 'Serial number'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
