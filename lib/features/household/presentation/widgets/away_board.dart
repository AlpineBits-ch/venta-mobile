import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/format/date_time_format.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/load_failure_view.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../guilds/data/guild_repository.dart';
import '../../../guilds/data/models/guild_dto.dart';
import '../../../guilds/data/models/guild_features.dart';
import '../../../guilds/data/models/guild_permissions.dart';
import '../../data/household_api.dart';
import '../../data/household_api_wave2.dart';
import '../../data/household_repository.dart';
import '../../data/models/absence_dto.dart';
import 'household_widgets.dart';

/// "Who's away", under "who's home" and deliberately not folded into it.
///
/// Home status is a **decaying assertion about right now** - somebody who never
/// clears "Out" has to stop claiming to be out by Thursday, which is why it
/// lives with a TTL and is drawn as a row of faces with a status icon. An
/// absence is a **dated plan**: it has a start and an end, the rota reads it to
/// decide whose turn things are, and it is still true while nobody is looking
/// at it.
///
/// So this board is drawn as dates rather than as faces-with-icons. Two
/// indicators that look alike but mean different things make both useless, and
/// the failure here is specific: a fortnight in Lisbon rendered like "back in an
/// hour" is how somebody comes home to a rota nobody moved.
class AwayBoard extends StatefulWidget {
  const AwayBoard({super.key, required this.guild});

  final GuildDto guild;

  /// Presence-gated, like the home-status board. A `403` here means the house
  /// does not do this, not that the viewer is shut out, so the check happens
  /// before anything renders.
  static bool appliesTo(GuildDto guild) =>
      guild.hasFeature(GuildFeature.presence);

  @override
  State<AwayBoard> createState() => _AwayBoardState();
}

class _AwayBoardState extends State<AwayBoard> {
  List<AbsenceDto>? _absences;
  StreamSubscription<void>? _eventsSub;

  String get _myUserId => getIt<AuthRepository>().currentUserId ?? '';

  @override
  void initState() {
    super.initState();
    unawaited(_load());
    _eventsSub = getIt<HouseholdRepository>()
        .guildEvents(widget.guild.id, HouseholdEvents.absences)
        .listen((_) => unawaited(_load()));
  }

  @override
  void didUpdateWidget(covariant AwayBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.guild.id != widget.guild.id) unawaited(_load());
  }

  @override
  void dispose() {
    unawaited(_eventsSub?.cancel());
    super.dispose();
  }

  Future<void> _load() async {
    final now = DateTime.now();
    try {
      final absences = await getIt<HouseholdApi>().getAbsences(
        widget.guild.id,
        from: now,
        to: now.add(const Duration(days: 120)),
      );
      if (mounted) setState(() => _absences = absences);
    } catch (_) {
      // Ambient information: it simply does not appear. An error banner above
      // the channel list would be more intrusive than the thing it reports on.
      if (mounted) setState(() => _absences = const []);
    }
  }

  Future<void> _open() async {
    await Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(builder: (_) => AwayScreen(guild: widget.guild)),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final absences = _absences;
    // Nothing to say and nothing planned draws nothing at all - the home
    // status board above it is already asking the ambient question.
    if (absences == null || absences.isEmpty) return const SizedBox.shrink();

    final now = DateTime.now();
    final ordered = [...absences]
      ..sort((a, b) => a.startAt.compareTo(b.startAt));

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.xs,
        AppSpacing.m,
        AppSpacing.xs,
      ),
      child: HouseCard(
        onTap: _open,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.m,
          AppSpacing.s + 2,
          AppSpacing.s,
          AppSpacing.s + 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'AWAY',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            for (final absence in ordered.take(3))
              _AwayLine(
                absence: absence,
                isMe: absence.userId == _myUserId,
                now: now,
              ),
            if (ordered.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  '${ordered.length - 3} more planned',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// One person, one span. A date range rather than a status word, because the
/// dates are the whole difference from home status.
class _AwayLine extends StatelessWidget {
  const _AwayLine({
    required this.absence,
    required this.isMe,
    required this.now,
  });

  final AbsenceDto absence;
  final bool isMe;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final live = absence.isLive(now: now);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          UserAvatar(userId: absence.userId, radius: 10),
          const SizedBox(width: AppSpacing.s),
          Flexible(
            child: MemberName(
              userId: absence.userId,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            flex: 2,
            child: Text(
              formatAbsenceRange(absence),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: theme.textTheme.labelSmall?.copyWith(
                color: live ? theme.colorScheme.tertiary : muted,
                fontWeight: live ? FontWeight.w600 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// `12 - 19 Aug`, or `Away until Friday` while it is happening.
String formatAbsenceRange(AbsenceDto absence, {DateTime? now}) {
  final at = now ?? DateTime.now();
  final start = formatShortDateTime(absence.startAt).split(',').first;
  final end = formatShortDateTime(absence.endAt).split(',').first;
  if (absence.isLive(now: at)) return 'back $end';
  return '$start - $end';
}

/// The whole board: who is away, when, and the editor for your own.
class AwayScreen extends StatefulWidget {
  const AwayScreen({super.key, required this.guild});

  final GuildDto guild;

  @override
  State<AwayScreen> createState() => _AwayScreenState();
}

class _AwayScreenState extends State<AwayScreen> {
  List<AbsenceDto>? _absences;
  bool _loadFailed = false;
  GuildPermissions _permissions = GuildPermissions.none;

  String get _myUserId => getIt<AuthRepository>().currentUserId ?? '';

  @override
  void initState() {
    super.initState();
    unawaited(_load());
    unawaited(_loadPermissions());
  }

  Future<void> _loadPermissions() async {
    try {
      final self = await getIt<GuildRepository>().getOwnMember(widget.guild.id);
      if (mounted) {
        setState(
          () => _permissions = self.effectivePermissions(widget.guild.ownerId),
        );
      }
    } catch (_) {
      // Leaves everyone able to edit only their own, which is the safe
      // default and still enforced server-side.
    }
  }

  Future<void> _load() async {
    final now = DateTime.now();
    try {
      final absences = await getIt<HouseholdApi>().getAbsences(
        widget.guild.id,
        from: now.subtract(const Duration(days: 30)),
        to: now.add(const Duration(days: 365)),
      );
      if (mounted) {
        setState(() {
          _absences = absences;
          _loadFailed = false;
        });
      }
    } catch (_) {
      if (mounted && _absences == null) setState(() => _loadFailed = true);
    }
  }

  /// Your own, or `ManageGuild` for somebody else's.
  ///
  /// `ManageGuild` can amend and delete but **cannot create** - inventing an
  /// absence for somebody would move their chores off them without their
  /// knowing, so there is no "add for" affordance anywhere on this screen.
  bool _canEdit(AbsenceDto absence) =>
      absence.userId == _myUserId || _permissions.has('ManageGuild');

  Future<void> _openEditor([AbsenceDto? existing]) async {
    final saved = await showHouseSheet<bool>(
      context: context,
      builder: (_) =>
          _AbsenceSheet(guildId: widget.guild.id, existing: existing),
    );
    if (saved == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final absences = _absences;
    final now = DateTime.now();
    final live = [...?absences?.where((a) => a.isLive(now: now))]
      ..sort((a, b) => a.endAt.compareTo(b.endAt));
    final upcoming = [
      ...?absences?.where((a) => !a.isLive(now: now) && !a.isPast(now: now)),
    ]..sort((a, b) => a.startAt.compareTo(b.startAt));
    final past = [...?absences?.where((a) => a.isPast(now: now))]
      ..sort((a, b) => b.endAt.compareTo(a.endAt));

    return Scaffold(
      appBar: AppBar(title: const Text('Away')),
      body: _loadFailed
          ? LoadFailureView(
              message: 'Couldn\'t load who\'s away.',
              onRetry: _load,
            )
          : absences == null
          ? const HouseCardSkeleton(lines: 2)
          : absences.isEmpty
          ? const HouseEmptyState(
              icon: Icons.luggage_outlined,
              title: 'Nobody has anything planned',
              body:
                  'Say when you are away and your chores in that window go to '
                  'whoever is actually here. It also stops the fairness board '
                  'reading a fortnight abroad as being behind.',
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.m,
                  AppSpacing.s,
                  AppSpacing.m,
                  HouseActionBar.reservedHeight,
                ),
                children: [
                  ..._group('Away now', live, now, highlight: true),
                  ..._group('Planned', upcoming, now),
                  ..._group('Been and gone', past, now),
                ],
              ),
            ),
      bottomNavigationBar: HouseActionBar(
        child: HousePrimaryButton(
          label: 'I\'m away',
          icon: Icons.luggage_outlined,
          onPressed: () => unawaited(_openEditor()),
        ),
      ),
    );
  }

  List<Widget> _group(
    String label,
    List<AbsenceDto> absences,
    DateTime now, {
    bool highlight = false,
  }) {
    if (absences.isEmpty) return const [];
    final theme = Theme.of(context);
    return [
      HouseSectionHeader(
        label: label,
        color: highlight ? theme.colorScheme.tertiary : null,
        trailing: Text('${absences.length}'),
      ),
      for (final absence in absences)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s),
          child: _AbsenceCard(
            absence: absence,
            now: now,
            onTap: _canEdit(absence)
                ? () => unawaited(_openEditor(absence))
                : null,
          ),
        ),
    ];
  }
}

class _AbsenceCard extends StatelessWidget {
  const _AbsenceCard({required this.absence, required this.now, this.onTap});

  final AbsenceDto absence;
  final DateTime now;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final live = absence.isLive(now: now);
    final note = absence.note?.trim();

    return HouseCard(
      onTap: onTap,
      tint: live ? theme.colorScheme.tertiary : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(userId: absence.userId, radius: 14),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: MemberName(
                        userId: absence.userId,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (live) ...[
                      const SizedBox(width: AppSpacing.s),
                      HousePill(
                        label: 'Away now',
                        color: theme.colorScheme.tertiary,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${formatAbsenceRange(absence, now: now)} · '
                  '${absence.days} day${absence.days == 1 ? '' : 's'}',
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
                if (note != null && note.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    note,
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Declaring, amending or dropping a span away.
class _AbsenceSheet extends StatefulWidget {
  const _AbsenceSheet({required this.guildId, this.existing});

  final String guildId;
  final AbsenceDto? existing;

  @override
  State<_AbsenceSheet> createState() => _AbsenceSheetState();
}

class _AbsenceSheetState extends State<_AbsenceSheet> {
  late DateTime _startAt = widget.existing?.startAt.toLocal() ?? DateTime.now();
  late DateTime _endAt =
      widget.existing?.endAt.toLocal() ??
      DateTime.now().add(const Duration(days: 7));
  late final _noteController = TextEditingController(
    text: widget.existing?.note ?? '',
  );
  bool _saving = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  bool get _valid => _endAt.isAfter(_startAt);

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startAt, end: _endAt),
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      helpText: 'When are you away?',
    );
    if (picked != null && mounted) {
      setState(() {
        _startAt = picked.start;
        // End of the last day rather than its midnight: somebody away "until
        // the 19th" is away on the 19th, and a rota that hands their bins back
        // that morning has misread them.
        _endAt = DateTime(
          picked.end.year,
          picked.end.month,
          picked.end.day,
          23,
          59,
        );
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final note = _noteController.text.trim();
    try {
      final saved = widget.existing == null
          ? await householdApi.createAbsence(
              widget.guildId,
              startAt: _startAt,
              endAt: _endAt,
              note: note,
            )
          : await householdApi.updateAbsence(
              widget.existing!.id,
              startAt: _startAt,
              endAt: _endAt,
              note: note,
              clearNote: note.isEmpty,
            );
      if (!mounted) return;
      Navigator.of(context).pop(true);
      final moved = saved.choresReassigned;
      if (moved > 0) {
        // The write has a visible effect on other people's boards, and saying
        // so is what turns a silent consequence into something checkable
        // before somebody gets on a plane.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              moved == 1
                  ? 'One chore in that window went to somebody who is here.'
                  : '$moved chores in that window went to whoever is here.',
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      // The server names the collision when two spans overlap, and that
      // wording is far more useful than anything generic.
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
        title: const Text('Drop this?'),
        // People expect otherwise, every time, so it is said plainly.
        content: const Text(
          'Chores that were handed over when this was declared stay with '
          'whoever picked them up. Removing it does not take them back.',
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
            child: const Text('Drop it'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await householdApi.deleteAbsence(existing.id);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(householdErrorText(error, 'Could not drop that.')),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final days =
        DateTime(_endAt.year, _endAt.month, _endAt.day)
            .difference(DateTime(_startAt.year, _startAt.month, _startAt.day))
            .inDays +
        1;

    return HouseSheet(
      title: widget.existing == null ? 'I\'m away' : 'Change this',
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
              child: const Text('Drop'),
            ),
      children: [
        SheetField(
          label: 'When',
          child: OutlinedButton.icon(
            onPressed: _pickRange,
            icon: const Icon(Icons.date_range_outlined, size: 18),
            label: Text(
              '${formatShortDateTime(_startAt).split(',').first} - '
              '${formatShortDateTime(_endAt).split(',').first}'
              '${days > 0 ? '  ·  $days day${days == 1 ? '' : 's'}' : ''}',
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'Where, roughly',
          child: TextField(
            controller: _noteController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'At my parents\' (optional)',
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Text(
          'Your unfinished chores in this window go to whoever in the house is '
          'carrying the least. The fairness board also weights by how much of '
          'the month you were actually here, so being away stops reading as '
          'being behind.',
          style: theme.textTheme.bodySmall?.copyWith(color: muted, height: 1.4),
        ),
      ],
    );
  }
}
