import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/format/date_time_format.dart';
import '../../../../core/routing/household_deep_link.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/load_failure_view.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../guilds/data/models/guild_features.dart';
import '../../../guilds/data/models/guild_member_dto.dart';
import '../../data/household_repository.dart';
import '../../data/models/household_alert.dart';
import '../../data/models/ledger_dto.dart';
import '../../data/money.dart';
import '../widgets/household_widgets.dart';
import 'bills_view.dart';
import 'household_channel_base.dart';

/// A `Ledger` channel: shared expenses, who owes who, and settling up.
///
/// Money is integer minor units end to end. Nothing in this file computes a
/// split - shares and remainders are the server's, deterministically
/// (1000 across 3 is 334/333/333), because a client that rounds differently
/// produces balances that don't sum to zero and an argument about ten
/// centimes.
class LedgerChannelScreen extends StatefulWidget {
  const LedgerChannelScreen({
    super.key,
    required this.guildId,
    required this.channelId,
    this.focus,
  });

  final String guildId;
  final String channelId;

  /// The row a notification opened this ledger at - an expense, or a bill on
  /// the Bills tab. See [HouseholdChannelState.focus].
  final HouseholdFocus? focus;

  @override
  State<LedgerChannelScreen> createState() => _LedgerChannelScreenState();
}

class _LedgerChannelScreenState
    extends HouseholdChannelState<LedgerChannelScreen>
    with SingleTickerProviderStateMixin {
  @override
  String get guildId => widget.guildId;
  @override
  String get channelId => widget.channelId;
  @override
  String get requiredFeature => GuildFeature.ledger;
  @override
  String get fallbackTitle => 'Ledger';

  late final TabController _tabs = TabController(length: 3, vsync: this);

  /// Which tab index the Bills board sits on.
  static const _billsTab = 1;

  List<ExpenseDto>? _expenses;
  List<LedgerBalanceDto>? _balances;
  List<TransferSuggestionDto>? _suggestions;
  LedgerConfigDto? _config;
  bool _loadFailed = false;
  StreamSubscription<void>? _eventsSub;

  /// Keyset cursor for the next (older) page, or null once the ledger has been
  /// read to its end. A house that has been running for years has more than a
  /// screenful, and the history is the part people scroll back through when
  /// they disagree about something.
  String? _nextCursor;
  bool _loadingMore = false;

  /// The server's own default page size, mirrored so a refresh can ask for the
  /// depth already on screen instead of one page.
  static const _pageSize = 50;

  String get _currency => _config?.currency ?? 'CHF';
  bool get _canAdd => can('AddExpenses');
  bool get _canManage => can('ManageLedger');

  /// Editing someone else's expense, or recording a payment you weren't part
  /// of, is `ManageLedger`. Your own is `AddExpenses`.
  bool _canEdit(ExpenseDto expense) =>
      _canManage ||
      (_canAdd &&
          (MemberName.isSelf(expense.payerUserId) ||
              MemberName.isSelf(expense.createdByUserId)));

  @override
  void initState() {
    focus = widget.focus;
    super.initState();
    // A `ledger.bill_due` notification names a bill, which lives on a
    // different tab from the expense a `ledger.expense` one names. Landing on
    // the wrong tab and leaving somebody to find the right one is the deep
    // link only half arriving.
    if (isFocused(HouseholdFocusKind.bill, focus?.id)) {
      _tabs.index = _billsTab;
    }
    _load();
    unawaited(ensureMembers());
    _eventsSub = household
        .channelEvents(widget.channelId, HouseholdEvents.ledger)
        // Every one of these moves the balances, so nothing here is
        // incremental - refetch the lot.
        .listen((_) => _load());
  }

  @override
  void onHouseholdAlert(HouseholdAlert alert) {
    super.onHouseholdAlert(alert);
    if (isFocused(HouseholdFocusKind.bill, focus?.id)) {
      _tabs.index = _billsTab;
    }
    unawaited(_load());
  }

  @override
  void dispose() {
    unawaited(_eventsSub?.cancel());
    _tabs.dispose();
    super.dispose();
  }

  /// Re-reads the ledger from the top, as deep as it's currently scrolled.
  ///
  /// Every ledger event moves the balances, so nothing here is patched in
  /// place - but re-reading only the first page would throw away pages
  /// somebody had just paged in, which is what they were reading when the
  /// event arrived. Capped at the server's own page maximum.
  Future<void> _load() async {
    final loaded = _expenses?.length ?? 0;
    try {
      final results = await Future.wait([
        api.getExpenses(
          widget.channelId,
          limit: loaded > _pageSize ? (loaded > 200 ? 200 : loaded) : null,
        ),
        api.getLedgerBalances(widget.channelId),
        api.getSettleSuggestion(widget.channelId),
        api.getLedgerConfig(widget.channelId),
      ]);
      if (!mounted) return;
      final page = results[0] as ExpensePageDto;
      setState(() {
        _expenses = page.items;
        _nextCursor = page.nextCursor;
        _balances = results[1] as List<LedgerBalanceDto>;
        _suggestions = results[2] as List<TransferSuggestionDto>;
        _config = results[3] as LedgerConfigDto;
        _loadFailed = false;
      });
    } catch (_) {
      if (mounted && _expenses == null) setState(() => _loadFailed = true);
    }
  }

  Future<void> _loadMore() async {
    final cursor = _nextCursor;
    if (cursor == null || _loadingMore) return;
    setState(() => _loadingMore = true);
    try {
      final page = await api.getExpenses(widget.channelId, cursor: cursor);
      if (!mounted) return;
      setState(() {
        _expenses = [...?_expenses, ...page.items];
        _nextCursor = page.nextCursor;
      });
    } catch (error) {
      showError(error, 'Could not load any more of the ledger.');
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  /// What the house owes me, or I owe it. Members at zero are omitted from
  /// the response, so "not in the list" means square.
  int get _myNetMinor =>
      (_balances ?? const <LedgerBalanceDto>[])
          .where((b) => b.userId == currentUserId)
          .firstOrNull
          ?.netMinor ??
      0;

  Future<void> _openExpenseEditor([ExpenseDto? existing]) async {
    final saved = await showHouseSheet<bool>(
      context: context,
      builder: (_) => _ExpenseSheet(
        channelId: widget.channelId,
        existing: existing,
        currency: _currency,
        members: members ?? const [],
        myUserId: currentUserId,
        canRecordForOthers: _canManage,
      ),
    );
    if (saved == true) await _load();
  }

  Future<void> _deleteExpense(ExpenseDto expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this expense?'),
        content: Text(
          '"${expense.description}" comes off the ledger and everyone\'s '
          'balance moves accordingly.',
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
      await api.deleteExpense(expense.id);
      await _load();
    } catch (error) {
      showError(error, 'Could not delete that expense.');
    }
  }

  /// Records that somebody paid somebody. It does not move money and never
  /// will, which is also where the payments work attaches.
  ///
  /// **Seam for encrypted payment handles and the Swiss QR bill.** When that
  /// lands, this dialog is where "how do I actually pay Anna" belongs: the
  /// creditor's IBAN decrypted on *this* device, a QR generated locally from
  /// it, and a launch button for whichever wallet the payer picked once in
  /// settings. Nothing about the flow below changes - it stays the explicit
  /// "mark as paid" that every one of those paths has to end in, because no
  /// payment app returns a result and a settlement is therefore a claim rather
  /// than a fact. The copy here already says so and must keep saying so.
  ///
  /// Deliberately not started here: the crypto and the QR payload are being
  /// built web-first, TWINT cannot be deep-linked or prefilled at all, and the
  /// phone-number half lives in Identity behind a per-household opt-in that is
  /// still cross-service work. If a number ever surfaces on this screen it must
  /// never be labelled verified - nothing SMS-verifies it.
  Future<void> _recordSettlement(TransferSuggestionDto transfer) async {
    final isMine = transfer.fromUserId == currentUserId;
    if (!isMine && !_canManage) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Record this payment?'),
        content: Text(
          'This records that the ${formatMinor(transfer.amountMinor, _currency)} '
          'has been handed over - it doesn\'t move any money itself.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Not yet'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Record it'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await api.recordSettlement(
        widget.channelId,
        fromUserId: transfer.fromUserId,
        toUserId: transfer.toUserId,
        amountMinor: transfer.amountMinor,
      );
      await _load();
    } catch (error) {
      showError(error, 'Could not record that payment.');
    }
  }

  Future<void> _changeCurrency() async {
    final picked = await showHouseSheet<String>(
      context: context,
      builder: (_) => _CurrencySheet(current: _currency),
    );
    if (picked == null || picked == _currency || !mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Switch to $picked?'),
        content: Text(
          'Everything already on the ledger gets relabelled as $picked. '
          'Nothing is converted - a 20.00 stays 20.00.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Switch'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final config = await api.updateLedgerConfig(
        widget.channelId,
        currency: picked,
      );
      if (mounted) setState(() => _config = config);
    } catch (error) {
      showError(error, 'Could not change the currency.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        subtitle: _config == null ? null : _currency,
        actions: [
          if (_canManage)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'currency') unawaited(_changeCurrency());
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'currency', child: Text('Currency')),
              ],
            ),
        ],
        bottom: moduleEnabled
            ? TabBar(
                controller: _tabs,
                tabs: const [
                  Tab(text: 'Expenses'),
                  // Not "Expenses" with a filter on it: what is owed and what
                  // has been spent are different questions, and folding the
                  // first into the second is exactly what the ledger could not
                  // say before.
                  Tab(text: 'Due'),
                  Tab(text: 'Who owes who'),
                ],
              )
            : null,
      ),
      body: !moduleEnabled
          ? buildModuleOff()
          : _loadFailed
          ? LoadFailureView(
              message: 'Couldn\'t load the ledger.',
              onRetry: _load,
            )
          : _expenses == null
          ? const HouseCardSkeleton(lines: 3)
          : TabBarView(
              controller: _tabs,
              children: [
                _buildExpenses(),
                BillsView(
                  channelId: widget.channelId,
                  currency: _currency,
                  currentUserId: currentUserId,
                  members: members ?? const [],
                  canManage: _canManage,
                  canAdd: _canAdd,
                  onLedgerChanged: () => unawaited(_load()),
                  focusBillId: isFocused(HouseholdFocusKind.bill, _focusId)
                      ? _focusId
                      : null,
                ),
                _buildBalances(),
              ],
            ),
      floatingActionButton: moduleEnabled && _canAdd
          ? AnimatedBuilder(
              animation: _tabs,
              // The Bills tab has its own actions on each row, and a "+ Expense"
              // button floating over a list of obligations invites exactly the
              // confusion this tab exists to remove.
              builder: (context, _) => _tabs.index == 0
                  ? FloatingActionButton.extended(
                      onPressed: () => _openExpenseEditor(),
                      icon: const Icon(Icons.add),
                      label: const Text('Expense'),
                    )
                  : const SizedBox.shrink(),
            )
          : null,
    );
  }

  String? get _focusId => focus?.id;

  Widget _buildExpenses() {
    final expenses = [..._expenses ?? const <ExpenseDto>[]]
      ..sort(
        (a, b) => (b.occurredAt ?? DateTime(0)).compareTo(
          a.occurredAt ?? DateTime(0),
        ),
      );
    if (expenses.isEmpty) {
      return HouseEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Nothing on the ledger',
        body: _canAdd
            ? 'Add what you\'ve paid for and the house works out who owes '
                  'who. Rent, the big shop, the internet bill.'
            : 'Nobody has added an expense yet.',
        action: _canAdd
            ? FilledButton(
                onPressed: () => _openExpenseEditor(),
                child: const Text('Add an expense'),
              )
            : null,
      );
    }

    String? lastHeading;
    final rows = <Widget>[
      _MyPositionCard(netMinor: _myNetMinor, currency: _currency),
    ];
    for (final expense in expenses) {
      final heading = _monthHeading(expense.occurredAt);
      if (heading != lastHeading) {
        rows.add(HouseSectionHeader(label: heading));
        lastHeading = heading;
      }
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s),
          // A `ledger.bill_posted` alert names the **expense** the bill became,
          // not the occurrence it came from - the one trap in the alert table,
          // and why this lands here rather than on the Due tab.
          child: focusRow(
            HouseholdFocusKind.expense,
            expense.id,
            label: 'The expense you were told about',
            _ExpenseCard(
              expense: expense,
              currency: _currency,
              myUserId: currentUserId,
              onTap: _canEdit(expense)
                  ? () => _openExpenseEditor(expense)
                  : null,
              onDelete: _canEdit(expense)
                  ? () => _deleteExpense(expense)
                  : null,
            ),
          ),
        ),
      );
    }

    if (_nextCursor != null) {
      rows.add(
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.s),
          child: Center(
            child: _loadingMore
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : TextButton(
                    onPressed: _loadMore,
                    child: const Text('Older expenses'),
                  ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.m,
          AppSpacing.m,
          AppSpacing.m,
          80,
        ),
        children: rows,
      ),
    );
  }

  static String _monthHeading(DateTime? when) {
    if (when == null) return 'Undated';
    final local = when.toLocal();
    final now = DateTime.now();
    if (local.year == now.year && local.month == now.month) return 'This month';
    // formatShortDateTime gives "Jul 30, 3:45 PM"; the month is its head.
    return formatShortDateTime(local).split(' ').first +
        (local.year == now.year ? '' : ' ${local.year}');
  }

  Widget _buildBalances() {
    final theme = Theme.of(context);
    final balances = [..._balances ?? const <LedgerBalanceDto>[]]
      ..sort((a, b) => b.netMinor.compareTo(a.netMinor));
    final suggestions = _suggestions ?? const <TransferSuggestionDto>[];

    if (balances.isEmpty) {
      return const HouseEmptyState(
        icon: Icons.handshake_outlined,
        title: 'All square',
        body:
            'Nobody owes anybody anything. Balances always add up to zero, so '
            'when this is empty the house really is settled.',
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.m,
          AppSpacing.m,
          AppSpacing.m,
          80,
        ),
        children: [
          _MyPositionCard(netMinor: _myNetMinor, currency: _currency),
          const HouseSectionHeader(label: 'Everyone'),
          for (final balance in balances)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s),
              child: _BalanceCard(balance: balance, currency: _currency),
            ),
          if (suggestions.isNotEmpty) ...[
            HouseSectionHeader(
              label: 'Settling up',
              trailing: Text(
                '${suggestions.length} '
                '${suggestions.length == 1 ? 'payment' : 'payments'}',
              ),
            ),
            for (final transfer in suggestions)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s),
                child: _SettleCard(
                  transfer: transfer,
                  currency: _currency,
                  canRecord: transfer.fromUserId == currentUserId || _canManage,
                  onRecord: () => _recordSettlement(transfer),
                ),
              ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'That\'s the fewest payments that settle everyone - four people '
              'square up with two transfers, not six. Recording one doesn\'t '
              'move any money; it notes that it happened.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Where the viewer stands, in one line, at the top of both tabs. It's the
/// only number most people open this screen for.
class _MyPositionCard extends StatelessWidget {
  const _MyPositionCard({required this.netMinor, required this.currency});

  final int netMinor;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settled = netMinor == 0;
    final owed = netMinor > 0;
    final color = settled
        ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
        : owed
        ? theme.colorScheme.primary
        : theme.colorScheme.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: HouseCard(
        tint: settled ? null : color,
        child: Row(
          children: [
            Icon(
              settled
                  ? Icons.check_circle_outline_rounded
                  : owed
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              color: color,
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    settled
                        ? 'You\'re square'
                        : owed
                        ? 'You\'re owed'
                        : 'You owe',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    settled
                        ? 'Nothing outstanding'
                        : formatMinor(netMinor.abs(), currency),
                    style: theme.textTheme.titleMedium?.copyWith(color: color),
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

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({
    required this.expense,
    required this.currency,
    required this.myUserId,
    this.onTap,
    this.onDelete,
  });

  final ExpenseDto expense;
  final String currency;
  final String myUserId;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final myShare = expense.shares
        .where((s) => s.userId == myUserId)
        .firstOrNull
        ?.amountMinor;
    final iPaid = expense.payerUserId == myUserId;

    return HouseCard(
      onTap: onTap,
      onLongPress: onDelete,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (expense.category != ExpenseCategory.uncategorized) ...[
                Icon(expense.category.icon, size: 16, color: muted),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  expense.description,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              // Tabular figures so a month of these lines up as a column
              // rather than wobbling with the digits.
              HouseAmount(
                amountMinor: expense.amountMinor,
                currency: currency,
                style: theme.textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              UserAvatar(userId: expense.payerUserId, radius: 8),
              const SizedBox(width: 6),
              Flexible(
                child: MemberName(
                  userId: expense.payerUserId,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ),
              Text(
                ' paid',
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
              if (expense.occurredAt != null)
                Expanded(
                  child: Text(
                    ' · ${formatShortDateTime(expense.occurredAt!).split(',').first}',
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          // Who typed it in isn't the same as who paid, and on a shared
          // ledger that distinction is worth a line.
          if (expense.createdByUserId.isNotEmpty &&
              expense.createdByUserId != expense.payerUserId) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.edit_note_rounded, size: 12, color: muted),
                const SizedBox(width: 4),
                Text(
                  'entered by ',
                  style: theme.textTheme.labelSmall?.copyWith(color: muted),
                ),
                Flexible(
                  child: MemberName(
                    userId: expense.createdByUserId,
                    style: theme.textTheme.labelSmall?.copyWith(color: muted),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.s),
          Row(
            children: [
              HousePill(
                label: switch (expense.splitKind) {
                  // A one-person "split" isn't one - it's somebody covering
                  // their own coffee, and the pill says so rather than
                  // reading "Split equally, 1 ways".
                  SplitKind.equal =>
                    expense.shares.isEmpty
                        ? 'Split with everyone'
                        : expense.shares.length == 1
                        ? 'Not split'
                        : 'Split equally, ${expense.shares.length} ways',
                  SplitKind.shares => 'Split by shares',
                  SplitKind.exact => 'Exact amounts',
                },
              ),
              const Spacer(),
              if (myShare != null && myShare != 0)
                Text(
                  iPaid
                      ? 'your share ${formatMinor(myShare, currency)}'
                      : 'you owe ${formatMinor(myShare, currency)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: iPaid ? muted : theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance, required this.currency});

  final LedgerBalanceDto balance;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final owed = balance.netMinor > 0;
    final color = owed ? theme.colorScheme.primary : theme.colorScheme.error;
    return HouseCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: 10,
      ),
      child: Row(
        children: [
          UserAvatar(userId: balance.userId, radius: 14),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MemberName(
                  userId: balance.userId,
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  owed ? 'is owed' : 'owes the house',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatMinor(balance.netMinor.abs(), currency),
            style: theme.textTheme.titleSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _SettleCard extends StatelessWidget {
  const _SettleCard({
    required this.transfer,
    required this.currency,
    required this.canRecord,
    required this.onRecord,
  });

  final TransferSuggestionDto transfer;
  final String currency;
  final bool canRecord;
  final VoidCallback onRecord;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return HouseCard(
      child: Row(
        children: [
          UserAvatar(userId: transfer.fromUserId, radius: 12),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: MemberName(
                        userId: transfer.fromUserId,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Icon(
                      Icons.arrow_right_alt_rounded,
                      size: 18,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    Flexible(
                      child: MemberName(
                        userId: transfer.toUserId,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                Text(
                  formatMinor(transfer.amountMinor, currency),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          if (canRecord)
            TextButton(onPressed: onRecord, child: const Text('Paid')),
        ],
      ),
    );
  }
}

/// Add or edit an expense.
class _ExpenseSheet extends StatefulWidget {
  const _ExpenseSheet({
    required this.channelId,
    required this.existing,
    required this.currency,
    required this.members,
    required this.myUserId,
    required this.canRecordForOthers,
  });

  final String channelId;
  final ExpenseDto? existing;
  final String currency;
  final List<GuildMemberDto> members;
  final String myUserId;

  /// `ManageLedger` - only then can an expense be recorded as somebody else's.
  final bool canRecordForOthers;

  @override
  State<_ExpenseSheet> createState() => _ExpenseSheetState();
}

class _ExpenseSheetState extends State<_ExpenseSheet> {
  late final _descriptionController = TextEditingController(
    text: widget.existing?.description ?? '',
  );
  late final _amountController = TextEditingController(
    text: widget.existing == null
        ? ''
        : editableAmount(widget.existing!.amountMinor, widget.currency),
  );
  late String _payerUserId = widget.existing?.payerUserId ?? widget.myUserId;
  late DateTime _occurredAt = widget.existing?.occurredAt ?? DateTime.now();
  late SplitKind _splitKind = widget.existing?.splitKind ?? SplitKind.equal;

  /// Coarse on purpose - see [ExpenseCategory]. Anything from before the field
  /// existed arrives as `Uncategorized`, which is a real bucket rather than a
  /// polite word for "Other".
  late ExpenseCategory _category =
      widget.existing?.category ?? ExpenseCategory.uncategorized;

  /// Empty means "everyone in the guild" for an equal split - the common case,
  /// and the server's own default.
  late Set<String> _included = {
    for (final share in widget.existing?.shares ?? const <ExpenseShareDto>[])
      share.userId,
  };

  /// Weight (Shares) or exact minor amount (Exact), keyed by user id.
  late final Map<String, TextEditingController> _shareControllers = {
    for (final member in widget.members)
      member.userId: TextEditingController(
        text: _initialShareText(member.userId),
      ),
  };

  bool _saving = false;

  String _initialShareText(String userId) {
    final existing = widget.existing;
    if (existing == null) return '';
    final share = existing.shares.where((s) => s.userId == userId).firstOrNull;
    if (share == null) return '';
    return switch (existing.splitKind) {
      SplitKind.shares => '${share.shareValue}',
      SplitKind.exact => editableAmount(share.amountMinor, widget.currency),
      SplitKind.equal => '',
    };
  }

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(() => setState(() {}));
    _amountController.addListener(() => setState(() {}));
    for (final controller in _shareControllers.values) {
      controller.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    for (final controller in _shareControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  int? get _amountMinor =>
      parseAmountToMinor(_amountController.text, widget.currency);

  /// For [SplitKind.exact]: what the typed amounts add up to, so the sheet can
  /// show the gap live instead of letting the server reject it.
  int get _exactTotalMinor {
    var total = 0;
    for (final entry in _shareControllers.entries) {
      if (!_included.contains(entry.key)) continue;
      total += parseAmountToMinor(entry.value.text, widget.currency) ?? 0;
    }
    return total;
  }

  int get _sharesTotal {
    var total = 0;
    for (final entry in _shareControllers.entries) {
      if (!_included.contains(entry.key)) continue;
      total += int.tryParse(entry.value.text.trim()) ?? 0;
    }
    return total;
  }

  bool get _valid {
    final amount = _amountMinor;
    if (_descriptionController.text.trim().isEmpty) return false;
    if (amount == null || amount <= 0) return false;
    return switch (_splitKind) {
      SplitKind.equal => true,
      SplitKind.shares => _included.isNotEmpty && _sharesTotal > 0,
      // Exact shares must sum to the total. Checked here so the mismatch is
      // visible while typing rather than arriving as a 400.
      SplitKind.exact => _included.isNotEmpty && _exactTotalMinor == amount,
    };
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(now.year - 3),
      lastDate: now.add(const Duration(days: 1)),
    );
    if (date != null && mounted) {
      setState(
        () => _occurredAt = DateTime(
          date.year,
          date.month,
          date.day,
          _occurredAt.hour,
          _occurredAt.minute,
        ),
      );
    }
  }

  List<({String userId, int shareValue})> _buildShares() {
    return switch (_splitKind) {
      // Empty = everyone in the guild. Sending the full member list instead
      // would be the same thing today and wrong the moment somebody joins.
      SplitKind.equal => [
        if (_included.isNotEmpty)
          for (final userId in _included) (userId: userId, shareValue: 0),
      ],
      SplitKind.shares => [
        for (final userId in _included)
          (
            userId: userId,
            shareValue:
                int.tryParse(_shareControllers[userId]?.text.trim() ?? '') ?? 0,
          ),
      ],
      SplitKind.exact => [
        for (final userId in _included)
          (
            userId: userId,
            shareValue:
                parseAmountToMinor(
                  _shareControllers[userId]?.text ?? '',
                  widget.currency,
                ) ??
                0,
          ),
      ],
    };
  }

  Future<void> _save() async {
    if (!_valid) return;
    setState(() => _saving = true);
    try {
      if (widget.existing == null) {
        await householdApi.createExpense(
          widget.channelId,
          description: _descriptionController.text.trim(),
          amountMinor: _amountMinor!,
          payerUserId: _payerUserId,
          occurredAt: _occurredAt,
          splitKind: _splitKind,
          category: _category,
          shares: _buildShares(),
        );
      } else {
        await householdApi.updateExpense(
          widget.existing!.id,
          description: _descriptionController.text.trim(),
          amountMinor: _amountMinor,
          // Only when it actually moved. Reassigning the payer needs
          // `ManageLedger` on the patch path too (create always required it,
          // so create-then-patch used to walk around the check), and sending
          // the payer it already has would turn every edit of your own expense
          // into a 403.
          payerUserId: _payerUserId == widget.existing!.payerUserId
              ? null
              : _payerUserId,
          occurredAt: _occurredAt,
          splitKind: _splitKind,
          category: _category,
          shares: _buildShares(),
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            householdErrorText(error, 'Could not save that expense.'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amount = _amountMinor;
    return HouseSheet(
      title: widget.existing == null ? 'New expense' : 'Edit expense',
      actionLabel: 'Save',
      busy: _saving,
      onAction: _valid ? _save : null,
      children: [
        SheetField(
          label: 'What for',
          child: TextField(
            controller: _descriptionController,
            autofocus: widget.existing == null,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'The big shop'),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'How much',
          child: TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: InputDecoration(
              prefixText: '${widget.currency} ',
              hintText: '0.00',
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Row(
          children: [
            Expanded(
              child: SheetField(
                label: 'Who paid',
                child: widget.canRecordForOthers && widget.members.isNotEmpty
                    ? DropdownButtonFormField<String>(
                        initialValue: _payerUserId,
                        isExpanded: true,
                        items: [
                          for (final member in widget.members)
                            DropdownMenuItem(
                              value: member.userId,
                              child: Text(
                                member.userId == widget.myUserId
                                    ? 'You'
                                    : member.nickname ??
                                          member.profile?.userName ??
                                          'Someone',
                              ),
                            ),
                        ],
                        onChanged: (value) =>
                            setState(() => _payerUserId = value!),
                      )
                    // Without `ManageLedger` you can only record what you paid
                    // yourself, so a picker would be a dead control.
                    : InputDecorator(
                        decoration: const InputDecoration(isDense: true),
                        child: const Text('You'),
                      ),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: SheetField(
                label: 'When',
                child: OutlinedButton(
                  onPressed: _pickDate,
                  child: Text(
                    formatShortDateTime(_occurredAt).split(',').first,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'Split',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SegmentedButton<SplitKind>(
                segments: [
                  for (final kind in SplitKind.values)
                    ButtonSegment(value: kind, label: Text(kind.label)),
                ],
                selected: {_splitKind},
                onSelectionChanged: (value) =>
                    setState(() => _splitKind = value.first),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _splitKind.description,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
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
        _buildSplitEditor(theme, amount),
      ],
    );
  }

  Widget _buildSplitEditor(ThemeData theme, int? amount) {
    if (widget.members.isEmpty) {
      return Text(
        'Split equally between everyone in the house.',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      );
    }

    final everyone = _splitKind == SplitKind.equal && _included.isEmpty;
    final remaining = (amount ?? 0) - _exactTotalMinor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_splitKind == SplitKind.equal)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Everyone in the house'),
            subtitle: const Text(
              'Including anyone who joins later - rent, internet, the usual',
            ),
            value: everyone,
            onChanged: (value) => setState(() {
              _included = value
                  ? {}
                  : {for (final m in widget.members) m.userId};
            }),
          ),
        if (!everyone) ...[
          for (final member in widget.members)
            _SplitRow(
              member: member,
              isMe: member.userId == widget.myUserId,
              included: _included.contains(member.userId),
              onIncludedChanged: (value) => setState(() {
                if (value) {
                  _included.add(member.userId);
                } else {
                  _included.remove(member.userId);
                }
              }),
              controller: _shareControllers[member.userId]!,
              kind: _splitKind,
              currency: widget.currency,
            ),
          if (_splitKind == SplitKind.exact) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              remaining == 0
                  ? 'The amounts add up.'
                  : remaining > 0
                  ? '${formatMinor(remaining, widget.currency)} still to '
                        'account for'
                  : '${formatMinor(-remaining, widget.currency)} over the '
                        'total',
              style: theme.textTheme.labelSmall?.copyWith(
                color: remaining == 0
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (_splitKind == SplitKind.shares) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Weights, not amounts - a 2 next to a 1 means twice as much of '
              'the bill.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _SplitRow extends StatelessWidget {
  const _SplitRow({
    required this.member,
    required this.isMe,
    required this.included,
    required this.onIncludedChanged,
    required this.controller,
    required this.kind,
    required this.currency,
  });

  final GuildMemberDto member;
  final bool isMe;
  final bool included;
  final ValueChanged<bool> onIncludedChanged;
  final TextEditingController controller;
  final SplitKind kind;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final name = isMe
        ? 'You'
        : member.nickname ?? member.profile?.userName ?? 'Someone';
    return Row(
      children: [
        Checkbox(
          value: included,
          onChanged: (value) => onIncludedChanged(value ?? false),
        ),
        Expanded(child: Text(name, overflow: TextOverflow.ellipsis)),
        if (included && kind != SplitKind.equal)
          SizedBox(
            width: 96,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.end,
              keyboardType: TextInputType.numberWithOptions(
                decimal: kind == SplitKind.exact,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  kind == SplitKind.exact
                      ? RegExp(r'[0-9.,]')
                      : RegExp(r'[0-9]'),
                ),
              ],
              decoration: InputDecoration(
                isDense: true,
                hintText: kind == SplitKind.exact ? '0.00' : '1',
                prefixText: kind == SplitKind.exact ? '$currency ' : null,
              ),
            ),
          ),
      ],
    );
  }
}

/// One currency per ledger channel, so this is a pick-one list rather than a
/// free text field - a typo'd ISO code is a relabelled ledger.
class _CurrencySheet extends StatelessWidget {
  const _CurrencySheet({required this.current});

  final String current;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.s,
              AppSpacing.l,
              AppSpacing.s,
            ),
            child: Text(
              'Currency',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          RadioGroup<String>(
            groupValue: current,
            onChanged: (value) => Navigator.of(context).pop(value),
            child: Column(
              children: [
                for (final code in commonCurrencyCodes)
                  RadioListTile<String>(value: code, title: Text(code)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
