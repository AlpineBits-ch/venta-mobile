import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/format/date_time_format.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/load_failure_view.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../guilds/data/models/guild_features.dart';
import '../../../guilds/data/models/guild_member_dto.dart';
import '../../../guilds/data/models/role_dto.dart';
import '../../data/household_repository.dart';
import '../../data/models/chore_dto.dart';
import '../widgets/household_widgets.dart';
import 'household_channel_base.dart';

/// `90` -> `1h 30m`. Chore effort is minutes on the wire and almost always
/// reads better as hours once a week's worth is added up.
String formatEffort(int minutes) {
  final absolute = minutes.abs();
  final hours = absolute ~/ 60;
  final rest = absolute % 60;
  final text = hours == 0
      ? '${rest}m'
      : rest == 0
      ? '${hours}h'
      : '${hours}h ${rest}m';
  return minutes < 0 ? '-$text' : text;
}

/// A `Chores` channel: the rota, its generated turns, and the fairness ledger
/// behind it.
///
/// The rotation is deliberately **not** round-robin, and the UI says so
/// out loud, because it's the behaviour people notice: the next turn goes to
/// whoever has completed the fewest weighted minutes lately. A plain rota
/// rewards skipping (your turn comes round again regardless), and weighting by
/// effort stops "take the bins out" counting the same as "clean the bathroom".
class ChoresChannelScreen extends StatefulWidget {
  const ChoresChannelScreen({
    super.key,
    required this.guildId,
    required this.channelId,
  });

  final String guildId;
  final String channelId;

  @override
  State<ChoresChannelScreen> createState() => _ChoresChannelScreenState();
}

class _ChoresChannelScreenState
    extends HouseholdChannelState<ChoresChannelScreen>
    with SingleTickerProviderStateMixin {
  @override
  String get guildId => widget.guildId;
  @override
  String get channelId => widget.channelId;
  @override
  String get requiredFeature => GuildFeature.chores;
  @override
  String get fallbackTitle => 'Chores';

  late final TabController _tabs = TabController(length: 3, vsync: this);

  List<ChoreOccurrenceDto>? _occurrences;
  List<ChoreDto>? _chores;
  List<ChoreBalanceEntryDto>? _balance;
  bool _loadFailed = false;
  StreamSubscription<void>? _eventsSub;

  bool get _canComplete => can('CompleteChores');
  bool get _canManage => can('ManageChores');

  @override
  void initState() {
    super.initState();
    _load();
    unawaited(ensureMembers());
    _eventsSub = household
        .channelEvents(widget.channelId, HouseholdEvents.chores)
        .listen((_) => _load());
  }

  @override
  void dispose() {
    unawaited(_eventsSub?.cancel());
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final now = DateTime.now();
    try {
      // Backwards far enough to still see what was done this week, forwards
      // far enough that "later this month" isn't an empty screen.
      final results = await Future.wait([
        api.getChoreOccurrences(
          widget.channelId,
          from: now.subtract(const Duration(days: 14)),
          to: now.add(const Duration(days: 28)),
        ),
        api.getChores(widget.channelId),
        api.getChoreBalance(widget.channelId),
      ]);
      if (!mounted) return;
      setState(() {
        _occurrences = results[0] as List<ChoreOccurrenceDto>;
        _chores = results[1] as List<ChoreDto>;
        _balance = results[2] as List<ChoreBalanceEntryDto>;
        _loadFailed = false;
      });
    } catch (_) {
      if (mounted && _occurrences == null) setState(() => _loadFailed = true);
    }
  }

  void _patchOccurrence(String id, ChoreOccurrenceDto updated) {
    if (!mounted) return;
    setState(() {
      _occurrences = [
        for (final o in _occurrences ?? const <ChoreOccurrenceDto>[])
          if (o.id == id) updated else o,
      ];
    });
  }

  Future<void> _setCompleted(ChoreOccurrenceDto occurrence, bool done) async {
    if (!_canComplete) return;
    _patchOccurrence(
      occurrence.id,
      occurrence.copyWith(
        completedAt: done ? DateTime.now() : null,
        completedByUserId: done ? currentUserId : null,
        // Completing something you'd skipped un-skips it - otherwise the row
        // would claim both at once.
        skippedAt: done ? null : occurrence.skippedAt,
      ),
    );
    try {
      final updated = await api.setOccurrenceCompleted(occurrence.id, done);
      if (updated != null) _patchOccurrence(occurrence.id, updated);
      // The balance moves on every completion, and it's the whole point of
      // the feature - refetch rather than let it drift.
      unawaited(_refreshBalance());
    } catch (error) {
      _patchOccurrence(occurrence.id, occurrence);
      showError(error, 'Could not update that chore.');
    }
  }

  Future<void> _refreshBalance() async {
    try {
      final balance = await api.getChoreBalance(widget.channelId);
      if (mounted) setState(() => _balance = balance);
    } catch (_) {
      // The board is still correct; the bars just lag until the next load.
    }
  }

  Future<void> _skip(ChoreOccurrenceDto occurrence) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Skip this one?'),
        content: const Text(
          'A skipped chore still counts as unpaid work - it doesn\'t credit '
          'anyone\'s share, which is what makes the rota come back around to '
          'the same person.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Skip'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final updated = await api.skipOccurrence(occurrence.id);
      if (updated != null) {
        _patchOccurrence(occurrence.id, updated);
      } else {
        await _load();
      }
    } catch (error) {
      showError(error, 'Could not skip that chore.');
    }
  }

  Future<void> _swap(ChoreOccurrenceDto occurrence) async {
    try {
      final updated = await api.swapOccurrence(occurrence.id);
      if (updated != null) {
        _patchOccurrence(occurrence.id, updated);
      } else {
        await _load();
      }
      if (mounted) showMessage('Passed on to whoever\'s got the lightest load.');
    } catch (error) {
      // The server's own wording is better than anything generic here -
      // "nobody else is in the rotation" is exactly what you need to know.
      showError(error, 'There\'s nobody else in this rotation.');
    }
  }

  Future<void> _openChoreEditor([ChoreDto? existing]) async {
    final saved = await showHouseSheet<bool>(
      context: context,
      builder: (_) => _ChoreSheet(
        channelId: widget.channelId,
        existing: existing,
        roles: guild?.roles ?? const [],
        members: members ?? const [],
      ),
    );
    if (saved == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        bottom: moduleEnabled
            ? TabBar(
                controller: _tabs,
                tabs: const [
                  Tab(text: 'Board'),
                  Tab(text: 'Rota'),
                  Tab(text: 'Fairness'),
                ],
              )
            : null,
      ),
      body: !moduleEnabled
          ? buildModuleOff()
          : _loadFailed
          ? LoadFailureView(
              message: 'Couldn\'t load the chores.',
              onRetry: _load,
            )
          : _occurrences == null
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabs,
              children: [_buildBoard(), _buildRota(), _buildFairness()],
            ),
      floatingActionButton: moduleEnabled && _canManage
          ? AnimatedBuilder(
              animation: _tabs,
              // Only offered on the tab it belongs to: a "+" on the fairness
              // chart would be a puzzle.
              builder: (context, _) => _tabs.index == 2
                  ? const SizedBox.shrink()
                  : FloatingActionButton(
                      onPressed: () => _openChoreEditor(),
                      tooltip: 'New chore',
                      child: const Icon(Icons.add),
                    ),
            )
          : null,
    );
  }

  // ---------------------------------------------------------------- board

  Widget _buildBoard() {
    final now = DateTime.now();
    final all = _occurrences ?? const <ChoreOccurrenceDto>[];
    final open = [...all.where((o) => o.isOpen)]
      ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
    final settled = [...all.where((o) => !o.isOpen)]..sort(
      (a, b) => (b.completedAt ?? b.skippedAt ?? b.dueAt).compareTo(
        a.completedAt ?? a.skippedAt ?? a.dueAt,
      ),
    );

    if (all.isEmpty) {
      return HouseEmptyState(
        icon: Icons.cleaning_services_outlined,
        title: 'No chores yet',
        body: _canManage
            ? 'Add a chore and the house starts taking turns at it. Turns go '
                  'to whoever\'s done the least lately, not round-robin.'
            : 'Nobody has set up the rota yet.',
        action: _canManage
            ? FilledButton(
                onPressed: () => _openChoreEditor(),
                child: const Text('Add a chore'),
              )
            : null,
      );
    }

    final overdue = open.where((o) => o.isOverdue).toList();
    final today = open
        .where((o) => !o.isOverdue && _isSameDay(o.dueAt.toLocal(), now))
        .toList();
    final soon = open
        .where(
          (o) =>
              !o.isOverdue &&
              !_isSameDay(o.dueAt.toLocal(), now) &&
              o.dueAt.toLocal().isBefore(now.add(const Duration(days: 7))),
        )
        .toList();
    final later = open
        .where(
          (o) =>
              !o.isOverdue &&
              !o.dueAt.toLocal().isBefore(now.add(const Duration(days: 7))),
        )
        .toList();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.m,
          AppSpacing.s,
          AppSpacing.m,
          AppSpacing.xl,
        ),
        children: [
          ..._group(context, 'Overdue', overdue, tint: true),
          ..._group(context, 'Today', today),
          ..._group(context, 'This week', soon),
          ..._group(context, 'Later', later),
          // Not "Done": this group holds skipped turns too, and a skipped
          // chore is unpaid work that credits nobody. Filing it under "done"
          // would be the UI quietly disagreeing with the fairness ledger.
          ..._group(context, 'Recently', settled),
        ],
      ),
    );
  }

  List<Widget> _group(
    BuildContext context,
    String label,
    List<ChoreOccurrenceDto> occurrences, {
    bool tint = false,
  }) {
    if (occurrences.isEmpty) return const [];
    final theme = Theme.of(context);
    return [
      HouseSectionHeader(
        label: label,
        color: tint ? theme.colorScheme.error : null,
        trailing: Text('${occurrences.length}'),
      ),
      for (final occurrence in occurrences)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s),
          child: _OccurrenceCard(
            occurrence: occurrence,
            canComplete: _canComplete,
            onToggle: () =>
                _setCompleted(occurrence, !occurrence.isCompleted),
            onSkip: () => _skip(occurrence),
            onSwap: () => _swap(occurrence),
          ),
        ),
    ];
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ----------------------------------------------------------------- rota

  Widget _buildRota() {
    final chores = _chores ?? const <ChoreDto>[];
    if (chores.isEmpty) {
      return const HouseEmptyState(
        icon: Icons.repeat_rounded,
        title: 'Nothing on the rota',
        body: 'Chores you add here generate turns automatically.',
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.m,
          AppSpacing.m,
          AppSpacing.m,
          AppSpacing.xl,
        ),
        children: [
          for (final chore in chores)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s),
              child: _ChoreCard(
                chore: chore,
                roleName: chore.rotationRoleId == null
                    ? null
                    : _roleName(chore.rotationRoleId!),
                onTap: _canManage ? () => _openChoreEditor(chore) : null,
              ),
            ),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Turns don\'t rotate in order. The next one goes to whoever in the '
            'pool has done the fewest weighted minutes over the last 30 days, '
            'so an hour of bathroom counts for more than two minutes of bins.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _roleName(String roleId) {
    final role = guild?.roles.where((r) => r.id == roleId).firstOrNull;
    if (role == null) return 'a role';
    return role.type == RoleType.everyone ? 'everyone' : role.name;
  }

  // ------------------------------------------------------------- fairness

  Widget _buildFairness() {
    final theme = Theme.of(context);
    final entries = [..._balance ?? const <ChoreBalanceEntryDto>[]]
      ..sort((a, b) => b.balanceMinutes.compareTo(a.balanceMinutes));
    if (entries.isEmpty) {
      return const HouseEmptyState(
        icon: Icons.balance_rounded,
        title: 'Nothing done yet',
        body:
            'Once chores start getting completed, this shows who\'s ahead of '
            'their share and who\'s behind.',
      );
    }
    final maxMinutes = entries
        .map((e) => e.completedMinutes)
        .fold<int>(1, (a, b) => a > b ? a : b);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.m,
          AppSpacing.m,
          AppSpacing.m,
          AppSpacing.xl,
        ),
        children: [
          for (final entry in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.m),
              child: _BalanceRow(entry: entry, maxMinutes: maxMinutes),
            ),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Measured against the house average over the last 30 days, not as '
            'a running total - so "behind" means behind your share, not behind '
            'everyone. Skipped chores credit nothing, and a chore done for '
            'someone else credits the person whose turn it was.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _OccurrenceCard extends StatelessWidget {
  const _OccurrenceCard({
    required this.occurrence,
    required this.canComplete,
    required this.onToggle,
    required this.onSkip,
    required this.onSwap,
  });

  final ChoreOccurrenceDto occurrence;
  final bool canComplete;
  final VoidCallback onToggle;
  final VoidCallback onSkip;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final done = occurrence.isCompleted;
    final skipped = occurrence.isSkipped;

    return HouseCard(
      padding: const EdgeInsets.fromLTRB(AppSpacing.s, 10, AppSpacing.xs, 10),
      tint: occurrence.isOverdue && occurrence.isOpen
          ? theme.colorScheme.error
          : null,
      child: Row(
        children: [
          IconButton(
            onPressed: canComplete ? onToggle : null,
            visualDensity: VisualDensity.compact,
            tooltip: done ? 'Mark as not done' : 'Mark as done',
            icon: Icon(
              done
                  ? Icons.check_circle_rounded
                  : skipped
                  ? Icons.remove_circle_outline_rounded
                  : Icons.circle_outlined,
              color: done
                  ? theme.colorScheme.primary
                  : skipped
                  ? muted
                  : occurrence.isOverdue
                  ? theme.colorScheme.error
                  : muted,
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
                        occurrence.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          decoration: done ? TextDecoration.lineThrough : null,
                          color: done || skipped ? muted : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    HousePill(label: formatEffort(occurrence.effortMinutes)),
                  ],
                ),
                const SizedBox(height: 3),
                DefaultTextStyle.merge(
                  style: theme.textTheme.bodySmall!.copyWith(color: muted),
                  child: Row(
                    children: [
                      UserAvatar(userId: occurrence.assignedUserId, radius: 8),
                      const SizedBox(width: 6),
                      Flexible(
                        child: MemberName(
                          userId: occurrence.assignedUserId,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: muted,
                          ),
                        ),
                      ),
                      // Both halves ellipsize: a long nickname next to "was
                      // due 3 days ago" overflows a narrow phone otherwise.
                      Flexible(
                        child: Text(
                          ' · ${_dueLabel(occurrence.dueAt)}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // Crediting the doer would let one flatmate farm the ledger by
                // doing everyone's easy chores, so the balance credits the
                // assignee - which only makes sense if both names are shown.
                if (occurrence.wasDoneBySomeoneElse) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.volunteer_activism_outlined,
                          size: 12, color: muted),
                      const SizedBox(width: 4),
                      Flexible(
                        child: MemberName(
                          userId: occurrence.completedByUserId!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: muted,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          ' covered this one',
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (skipped) ...[
                  const SizedBox(height: 4),
                  HousePill(
                    label: 'Skipped - still unpaid work',
                    icon: Icons.redo_rounded,
                    color: theme.colorScheme.tertiary,
                  ),
                ],
              ],
            ),
          ),
          if (occurrence.isOpen && canComplete)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, size: 20, color: muted),
              onSelected: (value) => switch (value) {
                'swap' => onSwap(),
                'skip' => onSkip(),
                _ => null,
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'swap',
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text('Pass it on'),
                    subtitle: Text('To whoever\'s done the least'),
                  ),
                ),
                PopupMenuItem(
                  value: 'skip',
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text('Skip'),
                    subtitle: Text('Nobody gets credit'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// "today 18:00" / "tomorrow" / "Aug 5, 6:00 PM" - a chore board is read at
  /// a glance and an absolute date for tonight's bins is needless work.
  static String _dueLabel(DateTime dueAt) {
    final now = DateTime.now();
    final local = dueAt.toLocal();
    final days = DateTime(
      local.year,
      local.month,
      local.day,
    ).difference(DateTime(now.year, now.month, now.day)).inDays;
    return switch (days) {
      0 => 'due today, ${formatTimeOfDay(local)}',
      1 => 'due tomorrow',
      -1 => 'was due yesterday',
      < 0 => 'was due ${-days} days ago',
      < 7 => 'due in $days days',
      _ => 'due ${formatShortDateTime(local)}',
    };
  }
}

class _ChoreCard extends StatelessWidget {
  const _ChoreCard({required this.chore, required this.roleName, this.onTap});

  final ChoreDto chore;
  final String? roleName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    return HouseCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(chore.title, style: theme.textTheme.titleSmall),
              ),
              if (chore.isPaused)
                const HousePill(label: 'Paused', icon: Icons.pause_rounded)
              else
                HousePill(label: formatEffort(chore.effortMinutes)),
            ],
          ),
          if (chore.description?.trim().isNotEmpty ?? false) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              chore.description!,
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
          ],
          const SizedBox(height: AppSpacing.s),
          Row(
            children: [
              Icon(Icons.repeat_rounded, size: 14, color: muted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _cadence(chore),
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Icon(
                roleName != null ? Icons.groups_outlined : Icons.person_outline,
                size: 14,
                color: muted,
              ),
              const SizedBox(width: 6),
              if (roleName != null)
                Text(
                  'Rotates between $roleName',
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                )
              else if (chore.fixedAssigneeUserId != null) ...[
                Text(
                  'Always ',
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
                MemberName(
                  userId: chore.fixedAssigneeUserId!,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ] else
                Text(
                  'Nobody assigned',
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static String _cadence(ChoreDto chore) {
    final label = switch (chore.intervalDays) {
      1 => 'Every day',
      7 => 'Every week',
      14 => 'Every two weeks',
      30 || 31 => 'Every month',
      final n => 'Every $n days',
    };
    final next = chore.nextDueAt;
    if (next == null || chore.isPaused) return label;
    return '$label · next ${formatShortDateTime(next)}';
  }
}

class _BalanceRow extends StatelessWidget {
  const _BalanceRow({required this.entry, required this.maxMinutes});

  final ChoreBalanceEntryDto entry;
  final int maxMinutes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final behind = entry.balanceMinutes < 0;
    final level = entry.balanceMinutes.abs() < 15
        // Within a quarter of an hour of your share is level, not "behind" -
        // a board that flags everyone as failing teaches people to ignore it.
        ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
        : behind
        ? theme.colorScheme.error
        : theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            UserAvatar(userId: entry.userId, radius: 11),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: MemberName(
                userId: entry.userId,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            HousePill(
              label: entry.balanceMinutes.abs() < 15
                  ? 'level'
                  : behind
                  ? '${formatEffort(entry.balanceMinutes)} behind'
                  : '+${formatEffort(entry.balanceMinutes)} ahead',
              color: level,
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.badge),
          child: LinearProgressIndicator(
            value: (entry.completedMinutes / maxMinutes).clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: theme.colorScheme.onSurface.withValues(
              alpha: 0.08,
            ),
            valueColor: AlwaysStoppedAnimation(level),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${formatEffort(entry.completedMinutes)} done · '
          '${entry.completedCount} '
          '${entry.completedCount == 1 ? 'chore' : 'chores'}',
          style: theme.textTheme.labelSmall?.copyWith(color: muted),
        ),
      ],
    );
  }
}

/// Create/edit a chore definition.
class _ChoreSheet extends StatefulWidget {
  const _ChoreSheet({
    required this.channelId,
    required this.existing,
    required this.roles,
    required this.members,
  });

  final String channelId;
  final ChoreDto? existing;
  final List<RoleDto> roles;
  final List<GuildMemberDto> members;

  @override
  State<_ChoreSheet> createState() => _ChoreSheetState();
}

class _ChoreSheetState extends State<_ChoreSheet> {
  late final _titleController = TextEditingController(
    text: widget.existing?.title ?? '',
  );
  late final _descriptionController = TextEditingController(
    text: widget.existing?.description ?? '',
  );
  late int _intervalDays = widget.existing?.intervalDays ?? 7;
  late int _effortMinutes = widget.existing?.effortMinutes ?? 15;
  late DateTime _anchorAt =
      widget.existing?.anchorAt ??
      DateTime.now().add(const Duration(hours: 12));
  late bool _rotates =
      widget.existing == null || widget.existing!.rotationRoleId != null;
  late String? _rotationRoleId = widget.existing?.rotationRoleId;
  late String? _fixedAssigneeUserId = widget.existing?.fixedAssigneeUserId;
  late int _graceHours = widget.existing?.graceHours ?? 0;
  late bool _isPaused = widget.existing?.isPaused ?? false;
  bool _saving = false;

  static const _intervalPresets = <int, String>{
    1: 'Daily',
    2: 'Every 2 days',
    7: 'Weekly',
    14: 'Fortnightly',
    30: 'Monthly',
  };

  static const _effortPresets = <int>[5, 10, 15, 30, 45, 60, 90];

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() => setState(() {}));
    // Default the pool to the widest role available, which for a household is
    // "everyone" - the answer nine times out of ten.
    _rotationRoleId ??= widget.roles
        .where((r) => r.type == RoleType.everyone)
        .firstOrNull
        ?.id;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _valid =>
      _titleController.text.trim().isNotEmpty &&
      (_rotates ? _rotationRoleId != null : _fixedAssigneeUserId != null);

  Future<void> _pickAnchor() async {
    final now = DateTime.now();
    final first = _anchorAt.isBefore(now) ? _anchorAt : now;
    final date = await showDatePicker(
      context: context,
      initialDate: _anchorAt,
      firstDate: first,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_anchorAt),
    );
    if (time == null) return;
    setState(
      () => _anchorAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ),
    );
  }

  Future<void> _save() async {
    if (!_valid) return;
    setState(() => _saving = true);
    try {
      final description = _descriptionController.text.trim();
      if (widget.existing == null) {
        await householdApi.createChore(
          widget.channelId,
          title: _titleController.text.trim(),
          description: description.isEmpty ? null : description,
          intervalDays: _intervalDays,
          anchorAt: _anchorAt,
          effortMinutes: _effortMinutes,
          rotationRoleId: _rotates ? _rotationRoleId : null,
          fixedAssigneeUserId: _rotates ? null : _fixedAssigneeUserId,
          graceHours: _graceHours,
        );
      } else {
        await householdApi.updateChore(
          widget.existing!.id,
          title: _titleController.text.trim(),
          description: description,
          clearDescription: description.isEmpty,
          intervalDays: _intervalDays,
          anchorAt: _anchorAt,
          effortMinutes: _effortMinutes,
          rotationRoleId: _rotates ? _rotationRoleId : null,
          fixedAssigneeUserId: _rotates ? null : _fixedAssigneeUserId,
          graceHours: _graceHours,
          isPaused: _isPaused,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(householdErrorText(error, 'Could not save that chore.')),
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
        title: Text('Delete "${existing.title}"?'),
        content: const Text(
          'Its upcoming turns go too. What\'s already been done stays counted.',
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
    try {
      await householdApi.deleteChore(existing.id);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              householdErrorText(error, 'Could not delete that chore.'),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return HouseSheet(
      title: widget.existing == null ? 'New chore' : 'Edit chore',
      actionLabel: 'Save',
      busy: _saving,
      onAction: _valid ? _save : null,
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
          label: 'Chore',
          child: TextField(
            controller: _titleController,
            autofocus: widget.existing == null,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'Clean the bathroom'),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'Details',
          child: TextField(
            controller: _descriptionController,
            minLines: 1,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'Optional'),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'How often',
          child: Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final entry in _intervalPresets.entries)
                ChoiceChip(
                  label: Text(entry.value),
                  selected: _intervalDays == entry.key,
                  onSelected: (_) =>
                      setState(() => _intervalDays = entry.key),
                ),
              if (!_intervalPresets.containsKey(_intervalDays))
                ChoiceChip(
                  label: Text('Every $_intervalDays days'),
                  selected: true,
                  onSelected: (_) {},
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'How much work',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final minutes in _effortPresets)
                    ChoiceChip(
                      label: Text(formatEffort(minutes)),
                      selected: _effortMinutes == minutes,
                      onSelected: (_) =>
                          setState(() => _effortMinutes = minutes),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'This is the fairness weight - it\'s what stops the bins '
                'counting the same as the bathroom.',
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
          label: 'First one due',
          child: OutlinedButton.icon(
            onPressed: _pickAnchor,
            icon: const Icon(Icons.schedule, size: 18),
            label: Text(formatShortDateTime(_anchorAt)),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'Whose turn',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Take turns')),
                  ButtonSegment(value: false, label: Text('One person')),
                ],
                selected: {_rotates},
                onSelectionChanged: (value) =>
                    setState(() => _rotates = value.first),
              ),
              const SizedBox(height: AppSpacing.s),
              if (_rotates)
                DropdownButtonFormField<String?>(
                  initialValue: _rotationRoleId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Who\'s in the rotation',
                  ),
                  items: [
                    for (final role in widget.roles)
                      DropdownMenuItem<String?>(
                        value: role.id,
                        child: Text(
                          role.type == RoleType.everyone
                              ? 'Everyone in the house'
                              : role.name,
                        ),
                      ),
                  ],
                  onChanged: (value) =>
                      setState(() => _rotationRoleId = value),
                )
              else
                DropdownButtonFormField<String?>(
                  initialValue: _fixedAssigneeUserId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Always'),
                  items: [
                    for (final member in widget.members)
                      DropdownMenuItem<String?>(
                        value: member.userId,
                        child: Text(
                          member.nickname ??
                              member.profile?.userName ??
                              'Someone',
                        ),
                      ),
                  ],
                  onChanged: (value) =>
                      setState(() => _fixedAssigneeUserId = value),
                ),
              if (_rotates) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Adding someone to the rota means giving them this role.',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'Grace period',
          child: Wrap(
            spacing: AppSpacing.xs,
            children: [
              for (final hours in const [0, 6, 12, 24, 48])
                ChoiceChip(
                  label: Text(hours == 0 ? 'None' : '${hours}h'),
                  selected: _graceHours == hours,
                  onSelected: (_) => setState(() => _graceHours = hours),
                ),
            ],
          ),
        ),
        if (widget.existing != null) ...[
          const SizedBox(height: AppSpacing.s),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Paused'),
            subtitle: const Text('Stops generating new turns'),
            value: _isPaused,
            onChanged: (value) => setState(() => _isPaused = value),
          ),
        ],
      ],
    );
  }
}
