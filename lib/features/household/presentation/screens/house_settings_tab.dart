import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/format/date_time_format.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/settings_tiles.dart';
import '../../../guilds/data/guild_repository.dart';
import '../../../guilds/data/models/guild_dto.dart';
import '../../../guilds/data/models/guild_features.dart';
import '../../../guilds/data/models/guild_member_dto.dart';
import '../../../guilds/data/models/guild_permissions.dart';
import '../../../guilds/data/models/role_dto.dart';
import '../../data/household_api.dart';
import '../../data/models/house_dto.dart';
import '../widgets/household_widgets.dart';

/// The two household modules that belong to the house rather than to a
/// channel: the nightly quiet window, and time-boxed guest access.
class HouseSettingsTab extends StatefulWidget {
  const HouseSettingsTab({super.key, required this.guildId});

  final String guildId;

  @override
  State<HouseSettingsTab> createState() => _HouseSettingsTabState();
}

class _HouseSettingsTabState extends State<HouseSettingsTab> {
  GuildDto? _guild;
  GuildPermissions _permissions = GuildPermissions.none;
  QuietHoursDto? _quietHours;

  /// The unsaved edit. Quiet hours is four coupled values (and `start == end`
  /// is a `400`), so it saves as one action rather than per-toggle.
  QuietHoursDto? _draft;
  bool _savingQuietHours = false;

  List<GuildMemberDto>? _members;
  StreamSubscription<List<GuildDto>>? _guildsSub;

  HouseholdApi get _api => getIt<HouseholdApi>();

  bool get _hasQuietHours =>
      _guild?.hasFeature(GuildFeature.quietHours) ?? false;
  bool get _hasGuestAccess =>
      _guild?.hasFeature(GuildFeature.guestAccess) ?? false;
  bool get _canManageGuests => _permissions.has('ManageGuests');
  bool get _canManageGuild => _permissions.has('ManageGuild');

  @override
  void initState() {
    super.initState();
    _guild = getIt<GuildRepository>().cachedById(widget.guildId);
    _guildsSub = getIt<GuildRepository>().guildsStream.listen((guilds) {
      final updated = guilds.where((g) => g.id == widget.guildId).firstOrNull;
      if (updated == null || !mounted) return;
      final hadGuild = _guild != null;
      setState(() => _guild = updated);
      // Which of these two sections exist depends on the guild's modules, and
      // on a cold open the guild lands *after* this tab builds - without this
      // the sections would stay empty until the tab was reopened.
      if (!hadGuild) unawaited(_load());
    });
    unawaited(_load());
  }

  @override
  void dispose() {
    unawaited(_guildsSub?.cancel());
    super.dispose();
  }

  Future<void> _load() async {
    final repository = getIt<GuildRepository>();
    try {
      final self = await repository.getOwnMember(widget.guildId);
      final ownerId = _guild?.ownerId;
      if (mounted) {
        setState(
          () => _permissions = ownerId != null
              ? self.effectivePermissions(ownerId)
              : self.permissions,
        );
      }
    } catch (_) {
      // Sections stay read-only; every write is enforced server-side anyway.
    }
    if (_hasQuietHours) {
      try {
        final quietHours = await _api.getQuietHours(widget.guildId);
        if (mounted) setState(() => _quietHours = quietHours);
      } catch (_) {
        // Falls back to the defaults below, which are a sane 22:00-07:00.
      }
    }
    if (_hasGuestAccess) await _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      final members = await getIt<GuildRepository>().getMembers(
        widget.guildId,
        take: 100,
      );
      if (mounted) setState(() => _members = members);
    } catch (_) {
      // The guest list just doesn't render.
    }
  }

  QuietHoursDto get _effective =>
      _draft ?? _quietHours ?? const QuietHoursDto();

  void _edit(QuietHoursDto Function(QuietHoursDto) update) {
    setState(() => _draft = update(_effective));
  }

  bool get _quietHoursDirty =>
      _draft != null && _draft != (_quietHours ?? const QuietHoursDto());

  bool get _quietHoursValid =>
      _effective.startMinuteLocal != _effective.endMinuteLocal;

  Future<void> _pickTime({required bool start}) async {
    final current = start
        ? _effective.startMinuteLocal
        : _effective.endMinuteLocal;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
    );
    if (picked == null) return;
    final minute = picked.hour * 60 + picked.minute;
    _edit(
      (value) => start
          ? value.copyWith(startMinuteLocal: minute)
          : value.copyWith(endMinuteLocal: minute),
    );
  }

  Future<void> _pickTimeZone() async {
    final picked = await showHouseSheet<String>(
      context: context,
      builder: (_) => _TimeZoneSheet(current: _effective.timeZoneId),
    );
    if (picked != null) _edit((value) => value.copyWith(timeZoneId: picked));
  }

  Future<void> _saveQuietHours() async {
    if (!_quietHoursValid) return;
    setState(() => _savingQuietHours = true);
    try {
      final saved = await _api.updateQuietHours(
        widget.guildId,
        enabled: _effective.enabled,
        startMinuteLocal: _effective.startMinuteLocal,
        endMinuteLocal: _effective.endMinuteLocal,
        timeZoneId: _effective.timeZoneId,
      );
      if (mounted) {
        setState(() {
          _quietHours = saved;
          _draft = null;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              householdErrorText(error, 'Could not save quiet hours.'),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _savingQuietHours = false);
    }
  }

  Future<void> _grantGuest() async {
    final granted = await showHouseSheet<bool>(
      context: context,
      builder: (_) => _GuestAccessSheet(
        guildId: widget.guildId,
        members: _members ?? const [],
        roles: _guild?.roles ?? const [],
      ),
    );
    if (granted == true) await _loadMembers();
  }

  Future<void> _revoke(GuildMemberDto member, RoleDto role) async {
    final name = member.nickname ?? member.profile?.userName ?? 'They';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('End this access now?'),
        content: Text(
          '$name loses the ${role.name} role straight away instead of when it '
          'was due to run out.',
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
            child: const Text('End it'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _api.revokeTemporaryRole(
        widget.guildId,
        userId: member.userId,
        roleId: role.id,
      );
      await _loadMembers();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              householdErrorText(error, 'Could not end that access.'),
            ),
          ),
        );
      }
    }
  }

  /// Live guest grants, flattened. A lapsed row is still listed by the server
  /// for about a week, so anything already expired is filtered out here rather
  /// than shown as if it still granted something.
  List<({GuildMemberDto member, RoleDto role, DateTime expiresAt})>
  get _guests => [
    for (final member in _members ?? const <GuildMemberDto>[])
      for (final membership in member.roleMembers)
        if (membership.isTemporary)
          (
            member: member,
            role: membership.role,
            expiresAt: membership.expiresAt!,
          ),
  ]..sort((a, b) => a.expiresAt.compareTo(b.expiresAt));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_guild == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_hasQuietHours && !_hasGuestAccess) {
      return const HouseEmptyState(
        icon: Icons.house_outlined,
        title: 'Nothing to set up here',
        body:
            'Quiet hours and guest access are both switched off for this '
            'server. Turn either on under Modules.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.xl,
      ),
      children: [
        if (_hasQuietHours) ...[
          SettingsSection(
            label: 'Quiet hours',
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Keep the house quiet at night'),
                  subtitle: const Text(
                    'Chore reminders that would land in the window wait until '
                    'it\'s over',
                  ),
                  value: _effective.enabled,
                  onChanged: _canManageGuild
                      ? (value) => _edit((v) => v.copyWith(enabled: value))
                      : null,
                ),
                SettingsRow(
                  title: 'From',
                  icon: Icons.bedtime_outlined,
                  trailing: Text(
                    formatMinuteOfDay(_effective.startMinuteLocal),
                  ),
                  onTap: _canManageGuild ? () => _pickTime(start: true) : null,
                  showChevron: false,
                ),
                SettingsRow(
                  title: 'Until',
                  icon: Icons.wb_twilight_outlined,
                  trailing: Text(formatMinuteOfDay(_effective.endMinuteLocal)),
                  onTap: _canManageGuild ? () => _pickTime(start: false) : null,
                  showChevron: false,
                ),
                SettingsRow(
                  title: 'Time zone',
                  icon: Icons.public_outlined,
                  trailing: Text(_effective.timeZoneId),
                  onTap: _canManageGuild ? _pickTimeZone : null,
                ),
              ],
            ),
          ),
          SettingsFootnote(
            _quietHoursValid
                // Crossing midnight is the normal case, not an edge case -
                // saying so stops it looking like a mistake.
                ? _effective.wrapsMidnight
                      ? 'This window runs overnight, from '
                            '${formatMinuteOfDay(_effective.startMinuteLocal)} '
                            'to '
                            '${formatMinuteOfDay(_effective.endMinuteLocal)} '
                            'the next morning.'
                      : 'This window runs during the day, from '
                            '${formatMinuteOfDay(_effective.startMinuteLocal)} '
                            'to '
                            '${formatMinuteOfDay(_effective.endMinuteLocal)}.'
                : 'Start and end can\'t be the same time.',
          ),
          if (_canManageGuild) ...[
            const SizedBox(height: AppSpacing.s),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed:
                    _quietHoursDirty && _quietHoursValid && !_savingQuietHours
                    ? _saveQuietHours
                    : null,
                child: _savingQuietHours
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save quiet hours'),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.l),
        ],
        if (_hasGuestAccess) ...[
          SettingsSection(
            label: 'Guest access',
            child: Column(
              children: [
                if (_guests.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    child: Text(
                      'Nobody has temporary access right now.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  )
                else
                  for (final guest in _guests)
                    SettingsRow(
                      title:
                          guest.member.nickname ??
                          guest.member.profile?.userName ??
                          'Someone',
                      icon: Icons.hourglass_bottom_outlined,
                      subtitle:
                          '${guest.role.name} · '
                          '${_remaining(guest.expiresAt)}',
                      trailing: _canManageGuests
                          ? TextButton(
                              onPressed: () =>
                                  _revoke(guest.member, guest.role),
                              child: const Text('End'),
                            )
                          : null,
                      showChevron: false,
                    ),
                if (_canManageGuests)
                  SettingsRow(
                    title: 'Give someone temporary access',
                    icon: Icons.person_add_alt,
                    onTap: _grantGuest,
                  ),
              ],
            ),
          ),
          const SettingsFootnote(
            'Temporary roles hand themselves back. The moment one runs out it '
            'stops granting anything - nobody has to remember to revoke the '
            'pet sitter.',
          ),
        ],
      ],
    );
  }

  static String _remaining(DateTime expiresAt) {
    final left = expiresAt.difference(DateTime.now());
    if (left.isNegative) return 'expired';
    if (left.inHours < 1) return '${left.inMinutes} min left';
    if (left.inHours < 48) return '${left.inHours} hours left';
    return '${left.inDays} days left';
  }
}

/// Grant a role that expires by itself.
class _GuestAccessSheet extends StatefulWidget {
  const _GuestAccessSheet({
    required this.guildId,
    required this.members,
    required this.roles,
  });

  final String guildId;
  final List<GuildMemberDto> members;
  final List<RoleDto> roles;

  @override
  State<_GuestAccessSheet> createState() => _GuestAccessSheetState();
}

class _GuestAccessSheetState extends State<_GuestAccessSheet> {
  String? _userId;
  String? _roleId;
  int _days = 3;
  bool _saving = false;

  static const _durations = <int, String>{
    1: 'A day',
    3: '3 days',
    7: 'A week',
    14: 'Two weeks',
    30: 'A month',
  };

  List<RoleDto> get _assignableRoles => [
    // `@everyone` is held by everyone already - offering it as a temporary
    // grant would be offering nothing.
    for (final role in widget.roles)
      if (role.type != RoleType.everyone) role,
  ];

  Future<void> _save() async {
    if (_userId == null || _roleId == null) return;
    setState(() => _saving = true);
    try {
      await getIt<HouseholdApi>().grantTemporaryRole(
        widget.guildId,
        userId: _userId!,
        roleId: _roleId!,
        expiresAt: DateTime.now().add(Duration(days: _days)),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            // Most likely cause is the role hierarchy rule: you can only hand
            // out roles you could assign by hand.
            householdErrorText(error, 'Could not grant that role.'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return HouseSheet(
      title: 'Temporary access',
      actionLabel: 'Give access',
      busy: _saving,
      onAction: _userId != null && _roleId != null ? _save : null,
      children: [
        SheetField(
          label: 'Who',
          child: DropdownButtonFormField<String>(
            initialValue: _userId,
            isExpanded: true,
            hint: const Text('Pick someone'),
            items: [
              for (final member in widget.members)
                DropdownMenuItem(
                  value: member.userId,
                  child: Text(
                    member.nickname ?? member.profile?.userName ?? 'Someone',
                  ),
                ),
            ],
            onChanged: (value) => setState(() => _userId = value),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'What they get',
          child: DropdownButtonFormField<String>(
            initialValue: _roleId,
            isExpanded: true,
            hint: const Text('Pick a role'),
            items: [
              for (final role in _assignableRoles)
                DropdownMenuItem(value: role.id, child: Text(role.name)),
            ],
            onChanged: (value) => setState(() => _roleId = value),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        SheetField(
          label: 'For how long',
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
                      selected: _days == entry.key,
                      onSelected: (_) => setState(() => _days = entry.key),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Ends on its own at '
                '${formatShortDateTime(DateTime.now().add(Duration(days: _days)))}. '
                'You can end it sooner, but you don\'t have to do anything to '
                'let it lapse.',
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

/// A searchable pick-list of IANA zones. The server validates the id, so a
/// free text field would just be a way to get a `400`.
class _TimeZoneSheet extends StatefulWidget {
  const _TimeZoneSheet({required this.current});

  final String current;

  @override
  State<_TimeZoneSheet> createState() => _TimeZoneSheetState();
}

class _TimeZoneSheetState extends State<_TimeZoneSheet> {
  final _searchController = TextEditingController();

  /// Not exhaustive - the common ones, plus whatever the guild is already set
  /// to so an unlisted zone is never silently replaced.
  static const _zones = <String>[
    'Europe/Zurich',
    'Europe/London',
    'Europe/Dublin',
    'Europe/Lisbon',
    'Europe/Madrid',
    'Europe/Paris',
    'Europe/Brussels',
    'Europe/Amsterdam',
    'Europe/Berlin',
    'Europe/Vienna',
    'Europe/Prague',
    'Europe/Warsaw',
    'Europe/Rome',
    'Europe/Copenhagen',
    'Europe/Oslo',
    'Europe/Stockholm',
    'Europe/Helsinki',
    'Europe/Athens',
    'Europe/Bucharest',
    'Europe/Istanbul',
    'Europe/Kyiv',
    'Europe/Moscow',
    'Atlantic/Reykjavik',
    'America/New_York',
    'America/Toronto',
    'America/Chicago',
    'America/Denver',
    'America/Los_Angeles',
    'America/Vancouver',
    'America/Mexico_City',
    'America/Bogota',
    'America/Sao_Paulo',
    'America/Buenos_Aires',
    'Africa/Casablanca',
    'Africa/Lagos',
    'Africa/Cairo',
    'Africa/Nairobi',
    'Africa/Johannesburg',
    'Asia/Jerusalem',
    'Asia/Dubai',
    'Asia/Karachi',
    'Asia/Kolkata',
    'Asia/Dhaka',
    'Asia/Bangkok',
    'Asia/Jakarta',
    'Asia/Singapore',
    'Asia/Hong_Kong',
    'Asia/Shanghai',
    'Asia/Taipei',
    'Asia/Seoul',
    'Asia/Tokyo',
    'Australia/Perth',
    'Australia/Adelaide',
    'Australia/Brisbane',
    'Australia/Sydney',
    'Pacific/Auckland',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final zones = <String>{
      widget.current,
      ..._zones,
    }.where((z) => z.toLowerCase().contains(query)).toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.l,
          right: AppSpacing.l,
          top: AppSpacing.l,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time zone', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: zones.length,
                itemBuilder: (context, index) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(zones[index].replaceAll('_', ' ')),
                  trailing: zones[index] == widget.current
                      ? const Icon(Icons.check, size: 18)
                      : null,
                  onTap: () => Navigator.of(context).pop(zones[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
