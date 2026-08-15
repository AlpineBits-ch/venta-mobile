import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/format/date_time_format.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/load_failure_view.dart';
import '../../../guilds/data/models/guild_member_dto.dart';
import '../../data/household_api.dart';
import '../../data/household_api_wave2.dart';
import '../../data/household_repository.dart';
import '../../data/models/bill_dto.dart';
import '../../data/models/ledger_dto.dart';
import '../../data/money.dart';
import '../widgets/household_widgets.dart';

/// What the house owes, and when.
///
/// **A bill is an obligation before it is an expense**, and that is the whole
/// reason this is not the ledger's history tab. "Rent is due Friday" and "Anna
/// paid rent, you owe her 850" are different sentences about different moments,
/// and only the second belongs in a list of what has been spent. So nothing
/// here is filed under spending until somebody posts it, and posting is the
/// deliberate act that moves it across.
///
/// The amount shown is the **bill's total**, never a share computed here. Every
/// split in this app is the server's arithmetic, and a share this screen worked
/// out itself would be the one number somebody actually transfers.
class BillsView extends StatefulWidget {
  const BillsView({
    super.key,
    required this.channelId,
    required this.currency,
    required this.currentUserId,
    required this.members,
    required this.canManage,
    required this.canAdd,
    required this.onLedgerChanged,
    this.focusBillId,
  });

  final String channelId;
  final String currency;
  final String currentUserId;
  final List<GuildMemberDto> members;

  /// `ManageLedger` - edit the schedules, skip a period, post anyone's bill.
  final bool canManage;

  /// `AddExpenses` - enough to post a bill you are the payer of.
  final bool canAdd;

  /// Posting a bill writes an expense, so the ledger's other tabs are stale
  /// the moment it succeeds.
  final VoidCallback onLedgerChanged;

  /// The occurrence a notification opened the ledger at, if any.
  final String? focusBillId;

  @override
  State<BillsView> createState() => _BillsViewState();
}

class _BillsViewState extends State<BillsView> {
  List<BillOccurrenceDto>? _bills;
  List<RecurringExpenseDto>? _schedules;
  bool _loadFailed = false;
  StreamSubscription<void>? _eventsSub;

  final _focusKeys = <String, GlobalKey>{};
  bool _focusRevealed = false;

  HouseholdApi get _api => getIt<HouseholdApi>();

  @override
  void initState() {
    super.initState();
    unawaited(_load());
    _eventsSub = getIt<HouseholdRepository>()
        .channelEvents(widget.channelId, HouseholdEvents.bills)
        .listen((_) => unawaited(_load()));
  }

  @override
  void dispose() {
    unawaited(_eventsSub?.cancel());
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        // Pending only: a posted bill is an expense now and lives on the other
        // tab, and a skipped one is a decision already taken. Neither is
        // something owed.
        _api.getBills(widget.channelId, status: BillStatus.pending),
        _api.getRecurringExpenses(widget.channelId),
      ]);
      if (!mounted) return;
      setState(() {
        _bills = results[0] as List<BillOccurrenceDto>;
        _schedules = results[1] as List<RecurringExpenseDto>;
        _loadFailed = false;
      });
    } catch (_) {
      if (mounted && _bills == null) setState(() => _loadFailed = true);
    }
  }

  bool _canPost(BillOccurrenceDto bill) {
    if (widget.canManage) return true;
    // "Or `AddExpenses` if you are the payer" - the person fronting the money
    // is the one who knows it has gone out.
    final schedule = _scheduleFor(bill);
    return widget.canAdd && schedule?.payerUserId == widget.currentUserId;
  }

  RecurringExpenseDto? _scheduleFor(BillOccurrenceDto bill) =>
      (_schedules ?? const <RecurringExpenseDto>[])
          .where((s) => s.id == bill.recurringExpenseId)
          .firstOrNull;

  Future<void> _openBill(BillOccurrenceDto bill) async {
    final changed = await showHouseSheet<bool>(
      context: context,
      builder: (_) => _BillSheet(
        bill: bill,
        schedule: _scheduleFor(bill),
        currency: widget.currency,
        canPost: _canPost(bill),
        canSkip: widget.canManage,
      ),
    );
    if (changed != true) return;
    await _load();
    widget.onLedgerChanged();
  }

  Future<void> _openSchedules() async {
    await Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => BillSchedulesScreen(
          channelId: widget.channelId,
          currency: widget.currency,
          members: widget.members,
          currentUserId: widget.currentUserId,
          canManage: widget.canManage,
        ),
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final bills = _bills;
    if (_loadFailed) {
      return LoadFailureView(
        message: 'Couldn\'t load what\'s due.',
        onRetry: _load,
      );
    }
    if (bills == null) return const HouseCardSkeleton(lines: 3);
    if (bills.isEmpty) return _empty();

    final now = DateTime.now();
    final overdue = bills.where((b) => b.isOverdue).toList()
      ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
    final soon =
        bills
            .where(
              (b) =>
                  !b.isOverdue &&
                  b.dueAt.toLocal().isBefore(now.add(const Duration(days: 14))),
            )
            .toList()
          ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
    final later =
        bills
            .where(
              (b) =>
                  !b.isOverdue &&
                  !b.dueAt.toLocal().isBefore(
                    now.add(const Duration(days: 14)),
                  ),
            )
            .toList()
          ..sort((a, b) => a.dueAt.compareTo(b.dueAt));

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
          ..._group('Late', overdue, tint: true),
          ..._group('Coming up', soon),
          ..._group('Later', later),
          const SizedBox(height: AppSpacing.m),
          _SchedulesLink(count: _schedules?.length ?? 0, onTap: _openSchedules),
        ],
      ),
    );
  }

  Widget _empty() {
    return HouseEmptyState(
      icon: Icons.receipt_long_outlined,
      title: 'Nothing owed',
      // The pitch, at the moment it is relevant: an empty bills board is
      // exactly where somebody decides whether this module is worth using.
      body: widget.canManage
          ? 'Rent, internet, the electricity bill - set one up once and every '
                'period shows up here on its own, split the way you agreed, '
                'before it is money anyone has spent.'
          : 'When the house has a bill coming, it will be here with the date '
                'it is due.',
      action: widget.canManage
          ? FilledButton.icon(
              onPressed: _openSchedules,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Set up a bill'),
            )
          : null,
    );
  }

  List<Widget> _group(
    String label,
    List<BillOccurrenceDto> bills, {
    bool tint = false,
  }) {
    if (bills.isEmpty) return const [];
    final theme = Theme.of(context);
    return [
      HouseSectionHeader(
        label: label,
        color: tint ? theme.colorScheme.error : null,
        trailing: Text('${bills.length}'),
      ),
      for (final bill in bills)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s),
          child: _focusWrap(
            bill,
            _BillCard(
              bill: bill,
              schedule: _scheduleFor(bill),
              onTap: () => unawaited(_openBill(bill)),
            ),
          ),
        ),
    ];
  }

  Widget _focusWrap(BillOccurrenceDto bill, Widget child) {
    if (widget.focusBillId != bill.id) return child;
    final key = _focusKeys.putIfAbsent(bill.id, GlobalKey.new);
    if (!_focusRevealed) {
      _focusRevealed = true;
      revealHouseholdRow(key);
    }
    return HouseFocusMark(
      key: key,
      focused: true,
      label: 'The bill you were told about',
      child: child,
    );
  }
}

/// One obligation.
///
/// Three things in one glance, in the order somebody reads them: what it is,
/// how much, and by when. The amount is in tabular figures so a column of them
/// lines up, and a bill nobody has put a figure to says so rather than showing
/// a zero.
class _BillCard extends StatelessWidget {
  const _BillCard({
    required this.bill,
    required this.schedule,
    required this.onTap,
  });

  final BillOccurrenceDto bill;
  final RecurringExpenseDto? schedule;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final amount = bill.amountMinor;

    return HouseCard(
      onTap: onTap,
      tint: bill.isOverdue ? theme.colorScheme.error : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  bill.description,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              if (amount == null)
                const HouseAmountPending(label: 'Needs a figure')
              else
                HouseAmount(
                  amountMinor: amount,
                  currency: bill.currency,
                  style: theme.textTheme.titleMedium,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Row(
            children: [
              Icon(
                bill.isOverdue
                    ? Icons.error_outline_rounded
                    : Icons.event_outlined,
                size: 14,
                color: bill.isOverdue ? theme.colorScheme.error : muted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  bill.isOverdue
                      ? 'Was due ${formatShortDateTime(bill.dueAt).split(',').first}'
                      : 'Due ${formatShortDateTime(bill.dueAt).split(',').first}',
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: bill.isOverdue ? theme.colorScheme.error : muted,
                  ),
                ),
              ),
              if (schedule != null) ...[
                const SizedBox(width: AppSpacing.s),
                // The total, and how it divides - never a share worked out
                // here. See the class doc on [BillsView].
                Text(
                  schedule!.splitKind.label.toLowerCase(),
                  style: theme.textTheme.labelSmall?.copyWith(color: muted),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SchedulesLink extends StatelessWidget {
  const _SchedulesLink({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    return HouseCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(Icons.repeat_rounded, size: 18, color: muted),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Text(
              count == 0
                  ? 'Set up a recurring bill'
                  : count == 1
                  ? '1 bill set up'
                  : '$count bills set up',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: muted),
        ],
      ),
    );
  }
}

/// One bill, and the two things anybody does with it.
class _BillSheet extends StatefulWidget {
  const _BillSheet({
    required this.bill,
    required this.schedule,
    required this.currency,
    required this.canPost,
    required this.canSkip,
  });

  final BillOccurrenceDto bill;
  final RecurringExpenseDto? schedule;
  final String currency;
  final bool canPost;
  final bool canSkip;

  @override
  State<_BillSheet> createState() => _BillSheetState();
}

class _BillSheetState extends State<_BillSheet> {
  late final _amountController = TextEditingController(
    text: widget.bill.amountMinor == null
        ? ''
        : editableAmount(widget.bill.amountMinor!, widget.currency),
  );
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  int? get _amountMinor =>
      parseAmountToMinor(_amountController.text, widget.currency);

  Future<void> _post() async {
    final amount = _amountMinor;
    // A variable bill cannot be posted without a figure - the server refuses,
    // and offering the button anyway just buys a `400`.
    if (amount == null) return;
    setState(() => _busy = true);
    try {
      await householdApi.postBill(widget.bill.id, amountMinor: amount);
      houseHapticHeavy();
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            householdErrorText(error, 'Could not add that to the ledger.'),
          ),
        ),
      );
    }
  }

  Future<void> _skip() async {
    final reason = await showDialog<String?>(
      context: context,
      builder: (_) => const _SkipReasonDialog(),
    );
    if (reason == null || !mounted) return;
    setState(() => _busy = true);
    try {
      await householdApi.skipBill(widget.bill.id, reason: reason);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(householdErrorText(error, 'Could not skip that.')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final schedule = widget.schedule;

    return HouseSheet(
      title: widget.bill.description,
      actionLabel: 'Add to the ledger',
      busy: _busy,
      onAction: widget.canPost && _amountMinor != null ? _post : null,
      leadingAction: widget.canSkip
          ? TextButton(
              onPressed: _busy ? null : _skip,
              child: const Text('Skip'),
            )
          : null,
      children: [
        Row(
          children: [
            Icon(
              widget.bill.isOverdue
                  ? Icons.error_outline_rounded
                  : Icons.event_outlined,
              size: 16,
              color: widget.bill.isOverdue ? theme.colorScheme.error : muted,
            ),
            const SizedBox(width: 6),
            Text(
              widget.bill.isOverdue
                  ? 'Was due ${formatShortDateTime(widget.bill.dueAt).split(',').first}'
                  : 'Due ${formatShortDateTime(widget.bill.dueAt).split(',').first}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: widget.bill.isOverdue ? theme.colorScheme.error : muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.l),
        SheetField(
          label: 'Amount',
          child: TextField(
            controller: _amountController,
            enabled: widget.canPost,
            autofocus: widget.bill.needsAmount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: InputDecoration(
              prefixText: '${widget.currency.toUpperCase()} ',
              hintText: '0.00',
            ),
          ),
        ),
        if (widget.bill.needsAmount) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            'This one varies, so nobody has said what it came to yet. Type '
            'what the letter says.',
            style: theme.textTheme.labelSmall?.copyWith(
              color: muted,
              height: 1.3,
            ),
          ),
        ],
        if (schedule != null) ...[
          const SizedBox(height: AppSpacing.l),
          Text(
            'Adding it records an expense paid by the payer on this schedule '
            'and splits it ${schedule.splitKind.label.toLowerCase()}. Skipping '
            'leaves the schedule alone, so next period still arrives.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: muted,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

class _SkipReasonDialog extends StatefulWidget {
  const _SkipReasonDialog();

  @override
  State<_SkipReasonDialog> createState() => _SkipReasonDialogState();
}

class _SkipReasonDialogState extends State<_SkipReasonDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Skip this period?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nothing goes on the ledger for this one. The schedule carries on, '
            'so the next period still turns up.',
          ),
          const SizedBox(height: AppSpacing.m),
          TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Why (optional)',
              hintText: 'Flat was empty in August',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: const Text('Skip it'),
        ),
      ],
    );
  }
}

/// The schedules behind the bills: what recurs, how often, split how.
///
/// A page rather than a sheet because it is the rarely-visited half - set up
/// once when the house moves in and looked at again when the rent changes.
class BillSchedulesScreen extends StatefulWidget {
  const BillSchedulesScreen({
    super.key,
    required this.channelId,
    required this.currency,
    required this.members,
    required this.currentUserId,
    required this.canManage,
  });

  final String channelId;
  final String currency;
  final List<GuildMemberDto> members;
  final String currentUserId;
  final bool canManage;

  @override
  State<BillSchedulesScreen> createState() => _BillSchedulesScreenState();
}

class _BillSchedulesScreenState extends State<BillSchedulesScreen> {
  List<RecurringExpenseDto>? _schedules;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final schedules = await getIt<HouseholdApi>().getRecurringExpenses(
        widget.channelId,
      );
      if (mounted) {
        setState(() {
          _schedules = schedules;
          _loadFailed = false;
        });
      }
    } catch (_) {
      if (mounted && _schedules == null) setState(() => _loadFailed = true);
    }
  }

  Future<void> _openEditor([RecurringExpenseDto? existing]) async {
    final saved = await showHouseSheet<bool>(
      context: context,
      builder: (_) => _ScheduleSheet(
        channelId: widget.channelId,
        currency: widget.currency,
        members: widget.members,
        currentUserId: widget.currentUserId,
        existing: existing,
      ),
    );
    if (saved == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final schedules = _schedules;
    return Scaffold(
      appBar: AppBar(title: const Text('Recurring bills')),
      body: _loadFailed
          ? LoadFailureView(
              message: 'Couldn\'t load the schedules.',
              onRetry: _load,
            )
          : schedules == null
          ? const HouseCardSkeleton(lines: 3)
          : schedules.isEmpty
          ? HouseEmptyState(
              icon: Icons.repeat_rounded,
              title: 'No recurring bills',
              body: widget.canManage
                  ? 'Rent, internet, electricity - add them once and every '
                        'period turns up on its own, already split.'
                  : 'Nobody has set up a recurring bill yet.',
              action: widget.canManage
                  ? FilledButton(
                      onPressed: () => _openEditor(),
                      child: const Text('Add one'),
                    )
                  : null,
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.m,
                AppSpacing.m,
                AppSpacing.m,
                HouseActionBar.reservedHeight,
              ),
              children: [
                for (final schedule in schedules)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.s),
                    child: _ScheduleCard(
                      schedule: schedule,
                      onTap: widget.canManage
                          ? () => unawaited(_openEditor(schedule))
                          : null,
                    ),
                  ),
              ],
            ),
      bottomNavigationBar: widget.canManage && (schedules?.isNotEmpty ?? false)
          ? HouseActionBar(
              child: HousePrimaryButton(
                label: 'Add a bill',
                icon: Icons.add_rounded,
                onPressed: () => unawaited(_openEditor()),
              ),
            )
          : null,
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.schedule, this.onTap});

  final RecurringExpenseDto schedule;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final amount = schedule.amountMinor;

    return HouseCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  schedule.description,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              if (amount == null)
                const HouseAmountPending(label: 'Varies')
              else
                HouseAmount(
                  amountMinor: amount,
                  currency: schedule.currency,
                  style: theme.textTheme.titleMedium,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              HousePill(
                label: schedule.cadenceLabel,
                icon: Icons.repeat_rounded,
              ),
              HousePill(
                label: schedule.category.label,
                icon: schedule.category.icon,
              ),
              if (schedule.autoPost)
                HousePill(
                  label: 'Posts itself',
                  icon: Icons.bolt_rounded,
                  color: theme.colorScheme.primary,
                ),
              if (schedule.isPaused)
                const HousePill(label: 'Paused', icon: Icons.pause_rounded),
            ],
          ),
          if (schedule.nextDueAt != null && !schedule.isPaused) ...[
            const SizedBox(height: AppSpacing.s),
            Row(
              children: [
                Icon(Icons.event_outlined, size: 14, color: muted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Next '
                    '${formatShortDateTime(schedule.nextDueAt!).split(',').first}',
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                ),
                Icon(Icons.person_outline, size: 14, color: muted),
                const SizedBox(width: 4),
                MemberName(
                  userId: schedule.payerUserId,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ScheduleSheet extends StatefulWidget {
  const _ScheduleSheet({
    required this.channelId,
    required this.currency,
    required this.members,
    required this.currentUserId,
    this.existing,
  });

  final String channelId;
  final String currency;
  final List<GuildMemberDto> members;
  final String currentUserId;
  final RecurringExpenseDto? existing;

  @override
  State<_ScheduleSheet> createState() => _ScheduleSheetState();
}

class _ScheduleSheetState extends State<_ScheduleSheet> {
  late final _descriptionController = TextEditingController(
    text: widget.existing?.description ?? '',
  );
  late final _amountController = TextEditingController(
    text: widget.existing?.amountMinor == null
        ? ''
        : editableAmount(widget.existing!.amountMinor!, widget.currency),
  );

  /// A bill whose amount changes every period - the electricity, the phone.
  /// Kept as its own switch rather than inferred from an empty field, because
  /// "I haven't typed it yet" and "it is different every time" want different
  /// behaviour for the rest of this form.
  late bool _varies = widget.existing?.isVariable ?? false;

  late RecurrenceUnit _unit =
      widget.existing?.recurrenceUnit ?? RecurrenceUnit.month;

  /// Kept from whatever the schedule already had. There is no "every 2 months"
  /// control on this form because nothing in a flat recurs that way often
  /// enough to earn a picker - but editing a schedule that has one must not
  /// quietly reset it to 1.
  late final int _interval = widget.existing?.recurrenceInterval ?? 1;
  late ExpenseCategory _category =
      widget.existing?.category ?? ExpenseCategory.uncategorized;
  late String _payerUserId = widget.existing?.payerUserId.isNotEmpty == true
      ? widget.existing!.payerUserId
      : widget.currentUserId;
  late DateTime _anchorAt =
      widget.existing?.anchorAt?.toLocal() ?? DateTime.now();
  late int _leadDays = widget.existing?.leadDays ?? 3;
  late bool _autoPost = widget.existing?.autoPost ?? false;
  late bool _isPaused = widget.existing?.isPaused ?? false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(() => setState(() {}));
    _amountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  int? get _amountMinor => _varies
      ? null
      : parseAmountToMinor(_amountController.text, widget.currency);

  bool get _canSave {
    if (_descriptionController.text.trim().isEmpty) return false;
    return _varies || _amountMinor != null;
  }

  Future<void> _pickAnchor() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _anchorAt,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
    );
    if (date != null && mounted) setState(() => _anchorAt = date);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      if (widget.existing == null) {
        await householdApi.createRecurringExpense(
          widget.channelId,
          description: _descriptionController.text.trim(),
          amountMinor: _amountMinor,
          payerUserId: _payerUserId,
          category: _category,
          recurrenceUnit: _unit,
          recurrenceInterval: _interval,
          anchorAt: _anchorAt,
          leadDays: _leadDays,
          autoPost: _autoPost && !_varies,
        );
      } else {
        await householdApi.updateRecurringExpense(
          widget.existing!.id,
          description: _descriptionController.text.trim(),
          amountMinor: _amountMinor,
          clearAmount: _varies,
          payerUserId: _payerUserId,
          category: _category,
          recurrenceUnit: _unit,
          recurrenceInterval: _interval,
          anchorAt: _anchorAt,
          leadDays: _leadDays,
          autoPost: _autoPost && !_varies,
          isPaused: _isPaused,
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this bill?'),
        content: const Text(
          'Future periods stop being generated. Anything already posted to the '
          'ledger stays exactly where it is.',
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
    if (confirmed != true) return;
    try {
      await householdApi.deleteRecurringExpense(existing.id);
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
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return HouseSheet(
      title: widget.existing == null ? 'New recurring bill' : 'Edit bill',
      actionLabel: 'Save',
      busy: _saving,
      onAction: _canSave ? _save : null,
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
            controller: _descriptionController,
            autofocus: widget.existing == null,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'Rent'),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'Amount',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _amountController,
                enabled: !_varies,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: InputDecoration(
                  prefixText: '${widget.currency.toUpperCase()} ',
                  hintText: _varies ? 'Entered each period' : '0.00',
                ),
              ),
              SwitchListTile.adaptive(
                value: _varies,
                contentPadding: EdgeInsets.zero,
                title: const Text('It is different every time'),
                subtitle: Text(
                  'Each period waits for somebody to read the figure off the '
                  'bill before it can go on the ledger.',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: muted,
                    height: 1.3,
                  ),
                ),
                onChanged: (value) => setState(() {
                  _varies = value;
                  // Only a fixed amount can post itself - the server refuses
                  // the combination, and leaving the switch on would make this
                  // form disagree with what actually saves.
                  if (value) _autoPost = false;
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'How often',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.xs,
                children: [
                  for (final unit in RecurrenceUnit.values)
                    ChoiceChip(
                      label: Text(switch (unit) {
                        RecurrenceUnit.day => 'Daily',
                        RecurrenceUnit.week => 'Weekly',
                        RecurrenceUnit.month => 'Monthly',
                        RecurrenceUnit.year => 'Yearly',
                      }),
                      selected: _unit == unit,
                      onSelected: (_) => setState(() => _unit = unit),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                // Why months rather than a day count: rent is due on the first,
                // not every thirty days.
                _unit == RecurrenceUnit.month
                    ? 'Anchored to the day of the month, so it never drifts.'
                    : 'Steps from the first due date below.',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: muted,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'First due',
          child: OutlinedButton.icon(
            onPressed: _pickAnchor,
            icon: const Icon(Icons.event_outlined, size: 18),
            label: Text(formatShortDateTime(_anchorAt).split(',').first),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'Who pays it',
          child: DropdownButtonFormField<String>(
            initialValue: _payerUserId,
            isExpanded: true,
            items: [
              for (final member in widget.members)
                DropdownMenuItem(
                  value: member.userId,
                  child: Text(
                    member.userId == widget.currentUserId
                        ? 'You'
                        : member.nickname ??
                              member.profile?.userName ??
                              'Someone',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (value) =>
                setState(() => _payerUserId = value ?? _payerUserId),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'What kind of thing',
          child: Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final category in ExpenseCategory.values)
                ChoiceChip(
                  avatar: Icon(category.icon, size: 16),
                  label: Text(category.label),
                  selected: _category == category,
                  onSelected: (_) => setState(() => _category = category),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'Tell the house',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.xs,
                children: [
                  for (final days in const [0, 1, 3, 7, 14])
                    ChoiceChip(
                      label: Text(
                        days == 0
                            ? 'On the day'
                            : days == 1
                            ? '1 day before'
                            : '$days days before',
                      ),
                      selected: _leadDays == days,
                      onSelected: (_) => setState(() => _leadDays = days),
                    ),
                ],
              ),
              if (!_varies) ...[
                SwitchListTile.adaptive(
                  value: _autoPost,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Put it on the ledger automatically'),
                  subtitle: Text(
                    'Only for a fixed amount. Nobody has to press anything on '
                    'the day.',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: muted,
                      height: 1.3,
                    ),
                  ),
                  onChanged: (value) => setState(() => _autoPost = value),
                ),
              ],
              if (widget.existing != null)
                SwitchListTile.adaptive(
                  value: _isPaused,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Paused'),
                  subtitle: Text(
                    'Stops generating periods without losing the setup.',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: muted,
                      height: 1.3,
                    ),
                  ),
                  onChanged: (value) => setState(() => _isPaused = value),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          'Changing the date moves the periods that have not been posted yet '
          'rather than regenerating them, so an amount somebody typed off a '
          'paper bill is not lost.',
          style: theme.textTheme.labelSmall?.copyWith(
            color: muted,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
