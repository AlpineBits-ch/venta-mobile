import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../guilds/data/models/guild_dto.dart';
import '../../../guilds/data/models/guild_features.dart';
import '../../data/household_api.dart';
import '../../data/household_repository.dart';
import '../../data/models/house_dto.dart';
import 'household_widgets.dart';

/// "Who's home", at the top of a household's channel list.
///
/// Deliberately not styled like the online/offline presence dot that already
/// exists elsewhere in this app. That one means "their app is connected";
/// this means "they're in the flat". Two indicators that look alike but mean
/// different things make both useless, so this one is icon-and-word based and
/// never uses a status dot.
///
/// Statuses decay - the server never returns an expired one, and somebody with
/// nothing live is simply absent rather than shown as unknown. A board that
/// still claims someone is asleep three days later is worse than no board.
class HomeStatusBoard extends StatefulWidget {
  const HomeStatusBoard({super.key, required this.guild});

  final GuildDto guild;

  @override
  State<HomeStatusBoard> createState() => _HomeStatusBoardState();
}

class _HomeStatusBoardState extends State<HomeStatusBoard> {
  List<HomeStatusDto>? _statuses;
  QuietHoursDto? _quietHours;
  StreamSubscription<void>? _eventsSub;

  String get _myUserId => getIt<AuthRepository>().currentUserId ?? '';

  HomeStatusDto? get _mine =>
      _statuses?.where((s) => s.userId == _myUserId).firstOrNull;

  @override
  void initState() {
    super.initState();
    _load();
    _eventsSub = getIt<HouseholdRepository>()
        .guildEvents(widget.guild.id, HouseholdEvents.homeStatus)
        .listen((_) => _load());
  }

  @override
  void didUpdateWidget(covariant HomeStatusBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.guild.id != widget.guild.id) _load();
  }

  @override
  void dispose() {
    unawaited(_eventsSub?.cancel());
    super.dispose();
  }

  Future<void> _load() async {
    final api = getIt<HouseholdApi>();
    try {
      final statuses = await api.getHomeStatuses(widget.guild.id);
      if (mounted) setState(() => _statuses = statuses);
    } catch (_) {
      // The board just doesn't appear - it's ambient information, and an
      // error banner above the channel list would be far more intrusive than
      // the thing it's reporting on.
      if (mounted) setState(() => _statuses = const []);
    }
    if (widget.guild.hasFeature(GuildFeature.quietHours)) {
      try {
        final quietHours = await api.getQuietHours(widget.guild.id);
        if (mounted) setState(() => _quietHours = quietHours);
      } catch (_) {
        // Same reasoning.
      }
    }
  }

  Future<void> _setMine() async {
    final changed = await showHouseSheet<bool>(
      context: context,
      builder: (_) => _HomeStatusSheet(
        guildId: widget.guild.id,
        current: _mine,
      ),
    );
    if (changed == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statuses = _statuses;
    if (statuses == null) return const SizedBox.shrink();

    final quiet = _quietHours;
    final quietNow = quiet?.isActiveNow() ?? false;
    // Yourself first: the row is read as "am I set, and who else is in".
    final ordered = [
      ...statuses.where((s) => s.userId == _myUserId),
      ...statuses.where((s) => s.userId != _myUserId),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.s,
        AppSpacing.m,
        AppSpacing.xs,
      ),
      child: HouseCard(
        onTap: _setMine,
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
                  'IN THE FLAT',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                const Spacer(),
                if (quietNow)
                  HousePill(
                    label: 'quiet until ${formatMinuteOfDay(
                      quiet!.endMinuteLocal,
                    )}',
                    icon: Icons.bedtime_outlined,
                    color: theme.colorScheme.tertiary,
                  ),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            if (ordered.isEmpty)
              Text(
                'Nobody has said where they are. Tap to set yours.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              )
            else
              SizedBox(
                height: 62,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: ordered.length + 1,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.m),
                  itemBuilder: (context, index) {
                    if (index == ordered.length) {
                      return _AddMineTile(
                        hasStatus: _mine != null,
                        onTap: _setMine,
                      );
                    }
                    final status = ordered[index];
                    return _StatusTile(
                      status: status,
                      isMe: status.userId == _myUserId,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({required this.status, required this.isMe});

  final HomeStatusDto status;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (status.kind) {
      HomeStatusKind.home => theme.colorScheme.primary,
      HomeStatusKind.onMyWay => theme.colorScheme.tertiary,
      HomeStatusKind.doNotDisturb => theme.colorScheme.error,
      HomeStatusKind.asleep ||
      HomeStatusKind.out => theme.colorScheme.onSurface.withValues(alpha: 0.55),
    };
    final note = status.note?.trim();

    return Tooltip(
      message: note == null || note.isEmpty ? status.kind.label : note,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                UserAvatar(userId: status.userId, radius: 16),
                Positioned(
                  right: -3,
                  bottom: -3,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(status.kind.icon, size: 13, color: color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              isMe ? 'You' : status.kind.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddMineTile extends StatelessWidget {
  const _AddMineTile({required this.hasStatus, required this.onTap});

  final bool hasStatus;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.55);
    return SizedBox(
      width: 64,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.chip),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.onSurface.withValues(
                alpha: 0.08,
              ),
              child: Icon(
                hasStatus ? Icons.edit_outlined : Icons.add,
                size: 16,
                color: muted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              hasStatus ? 'Change' : 'Set yours',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(color: muted),
            ),
          ],
        ),
      ),
    );
  }
}

/// Setting **your own** status. There is no permission for this and no way to
/// set anyone else's - "Anna is asleep" is only Anna's to assert.
class _HomeStatusSheet extends StatefulWidget {
  const _HomeStatusSheet({required this.guildId, required this.current});

  final String guildId;
  final HomeStatusDto? current;

  @override
  State<_HomeStatusSheet> createState() => _HomeStatusSheetState();
}

class _HomeStatusSheetState extends State<_HomeStatusSheet> {
  late HomeStatusKind _kind = widget.current?.kind ?? HomeStatusKind.home;
  late final _noteController = TextEditingController(
    text: widget.current?.note ?? '',
  );

  /// Server default is 12 hours, capped at a week.
  int? _expiresInMinutes = 12 * 60;
  bool _saving = false;

  static const _durations = <int, String>{
    60: '1 hour',
    4 * 60: '4 hours',
    12 * 60: '12 hours',
    24 * 60: 'A day',
    3 * 24 * 60: '3 days',
  };

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final note = _noteController.text.trim();
    try {
      await getIt<HouseholdApi>().setHomeStatus(
        widget.guildId,
        kind: _kind,
        note: note.isEmpty ? null : note,
        expiresInMinutes: _expiresInMinutes,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(householdErrorText(error, 'Could not set that.')),
        ),
      );
    }
  }

  Future<void> _clear() async {
    try {
      await getIt<HouseholdApi>().clearHomeStatus(widget.guildId);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(householdErrorText(error, 'Could not clear that.')),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return HouseSheet(
      title: 'Where are you?',
      actionLabel: 'Set it',
      busy: _saving,
      onAction: _save,
      leadingAction: widget.current == null
          ? null
          : TextButton(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              onPressed: _clear,
              child: const Text('Clear'),
            ),
      children: [
        for (final kind in HomeStatusKind.values)
          InkWell(
            onTap: () => setState(() => _kind = kind),
            borderRadius: BorderRadius.circular(AppRadii.chip),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    kind.icon,
                    color: _kind == kind
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Text(
                      kind.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: _kind == kind
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                  Icon(
                    _kind == kind
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 20,
                    color: _kind == kind
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'Anything to add',
          child: TextField(
            controller: _noteController,
            maxLength: 100,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Back around eight',
              counterText: '',
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'Until',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final entry in _durations.entries)
                    ChoiceChip(
                      label: Text(entry.value),
                      selected: _expiresInMinutes == entry.key,
                      onSelected: (_) =>
                          setState(() => _expiresInMinutes = entry.key),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'It clears itself afterwards. Nobody has to remember to take '
                'it down, and the board never claims you\'re asleep on Tuesday.',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
