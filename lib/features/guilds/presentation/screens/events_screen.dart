import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/format/date_time_format.dart';
import '../../../../core/realtime/realtime_event.dart';
import '../../../../core/realtime/realtime_service.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/button_progress_indicator.dart';
import '../../../../core/widgets/load_failure_view.dart';
import '../../../guild_voice/bloc/guild_voice_cubit.dart';
import '../../../guild_voice/presentation/screens/guild_voice_screen.dart';
import '../../data/guild_repository.dart';
import '../../data/models/channel_dto.dart';
import '../../data/models/guild_permissions.dart';
import '../../data/models/scheduled_event_dto.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key, required this.guildId});

  final String guildId;

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<ScheduledEventDto>? _events;
  bool _loadFailed = false;
  GuildPermissions _permissions = GuildPermissions.none;
  late final StreamSubscription<RealtimeEvent> _eventsSub;

  @override
  void initState() {
    super.initState();
    _load();
    unawaited(_loadPermissions());
    _eventsSub = getIt<RealtimeService>().events
        .where(
          (e) =>
              (e.name == 'guild.EventCreated' ||
                  e.name == 'guild.EventUpdated' ||
                  e.name == 'guild.EventCancelled') &&
              e.stringField('guildId') == widget.guildId,
        )
        .listen((_) => _load());
  }

  @override
  void dispose() {
    unawaited(_eventsSub.cancel());
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final events = await getIt<GuildRepository>().getEvents(widget.guildId);
      if (mounted) {
        setState(() {
          _events = events;
          _loadFailed = false;
        });
      }
    } catch (_) {
      // Keep whatever was already loaded - but if that's nothing, the screen
      // would otherwise sit on its spinner forever with no way to retry.
      if (mounted && _events == null) setState(() => _loadFailed = true);
    }
  }

  Future<void> _loadPermissions() async {
    try {
      final repository = getIt<GuildRepository>();
      final self = await repository.getOwnMember(widget.guildId);
      final ownerId = repository.cachedById(widget.guildId)?.ownerId;
      final effective = ownerId != null
          ? self.effectivePermissions(ownerId)
          : self.permissions;
      if (mounted) {
        setState(() => _permissions = effective);
      }
    } catch (_) {
      // Leave "create event" hidden - still enforced server-side.
    }
  }

  Future<void> _toggleInterest(ScheduledEventDto event) async {
    setState(() {
      _events = [
        for (final e in _events ?? const <ScheduledEventDto>[])
          if (e.id == event.id)
            e.copyWith(
              isInterested: !e.isInterested,
              interestedCount: e.interestedCount + (e.isInterested ? -1 : 1),
            )
          else
            e,
      ];
    });
    try {
      if (event.isInterested) {
        await getIt<GuildRepository>().removeEventInterest(event.id);
      } else {
        await getIt<GuildRepository>().markEventInterested(event.id);
      }
    } catch (_) {
      if (mounted) _load();
    }
  }

  Future<void> _joinVoice(String channelId) async {
    final guild = getIt<GuildRepository>().cachedById(widget.guildId);
    final channel = guild?.channels.where((c) => c.id == channelId).firstOrNull;
    if (guild == null || channel == null) return;
    await getIt<GuildVoiceCubit>().join(
      guildId: widget.guildId,
      channelId: channelId,
      channelName: channel.name,
      guildName: guild.name,
    );
    if (mounted) {
      Navigator.of(
        context,
        rootNavigator: true,
      ).push(MaterialPageRoute(builder: (_) => const GuildVoiceScreen()));
    }
  }

  Future<void> _openEditor([ScheduledEventDto? existing]) async {
    final voiceChannels =
        getIt<GuildRepository>()
            .cachedById(widget.guildId)
            ?.channels
            .where((c) => c.type == ChannelType.voice)
            .toList() ??
        const [];
    final saved = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _EventEditorSheet(
        guildId: widget.guildId,
        existing: existing,
        voiceChannels: voiceChannels,
      ),
    );
    if (saved == true) _load();
  }

  Future<void> _confirmCancel(ScheduledEventDto event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel this event?'),
        content: Text('"${event.title}" will be marked cancelled.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep it'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cancel event'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await getIt<GuildRepository>().cancelEvent(event.id);
      _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not cancel that event.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final events = _events;
    final canManage = _permissions.has('ManageEvents');
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(
          fallbackLocation: RoutePaths.serverPath(widget.guildId),
        ),
        title: const Text('Events'),
      ),
      body: _loadFailed
          ? LoadFailureView(message: 'Couldn\'t load events.', onRetry: _load)
          : events == null
          ? const Center(child: CircularProgressIndicator())
          : events.isEmpty
          ? Center(
              child: Text(
                'No upcoming events.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.m),
                itemCount: events.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.s),
                itemBuilder: (context, index) => _EventCard(
                  event: events[index],
                  canManage: canManage,
                  onToggleInterest: () => _toggleInterest(events[index]),
                  onJoinVoice: events[index].voiceChannelId != null
                      ? () => _joinVoice(events[index].voiceChannelId!)
                      : null,
                  onEdit: canManage ? () => _openEditor(events[index]) : null,
                  onCancel: canManage
                      ? () => _confirmCancel(events[index])
                      : null,
                ),
              ),
            ),
      floatingActionButton: canManage
          ? FloatingActionButton(
              onPressed: () => _openEditor(),
              tooltip: 'New event',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.canManage,
    required this.onToggleInterest,
    this.onJoinVoice,
    this.onEdit,
    this.onCancel,
  });

  final ScheduledEventDto event;
  final bool canManage;
  final VoidCallback onToggleInterest;
  final VoidCallback? onJoinVoice;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cancelled = event.status == EventStatus.cancelled;
    return Opacity(
      // Cancelled events stay in the list (the backend keeps them), so they
      // need to read as inactive rather than sitting there looking bookable.
      opacity: cancelled ? 0.6 : 1,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      decoration: cancelled ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                if (canManage && !cancelled)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) => switch (value) {
                      'edit' => onEdit?.call(),
                      'cancel' => onCancel?.call(),
                      _ => null,
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                        value: 'cancel',
                        child: Text('Cancel event'),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                if (cancelled) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs + 2,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadii.badge),
                    ),
                    child: Text(
                      'CANCELLED',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                ],
                Text(
                  formatShortDateTime(event.startsAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            if (event.location != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(event.location!, style: theme.textTheme.bodySmall),
            ],
            if (event.description != null) ...[
              const SizedBox(height: AppSpacing.s),
              Text(event.description!, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: AppSpacing.s),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: cancelled ? null : onToggleInterest,
                  icon: Icon(
                    event.isInterested ? Icons.favorite : Icons.favorite_border,
                    size: 18,
                  ),
                  label: Text('${event.interestedCount}'),
                ),
                if (onJoinVoice != null && !cancelled) ...[
                  const SizedBox(width: AppSpacing.s),
                  OutlinedButton.icon(
                    onPressed: onJoinVoice,
                    icon: const Icon(Icons.call, size: 18),
                    label: const Text('Join voice'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EventEditorSheet extends StatefulWidget {
  const _EventEditorSheet({
    required this.guildId,
    this.existing,
    required this.voiceChannels,
  });

  final String guildId;
  final ScheduledEventDto? existing;
  final List<ChannelDto> voiceChannels;

  @override
  State<_EventEditorSheet> createState() => _EventEditorSheetState();
}

class _EventEditorSheetState extends State<_EventEditorSheet> {
  late final _titleController = TextEditingController(
    text: widget.existing?.title ?? '',
  );
  late final _descriptionController = TextEditingController(
    text: widget.existing?.description ?? '',
  );
  late final _locationController = TextEditingController(
    text: widget.existing?.location ?? '',
  );
  late DateTime _startsAt =
      widget.existing?.startsAt ?? DateTime.now().add(const Duration(hours: 1));
  String? _voiceChannelId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _voiceChannelId = widget.existing?.voiceChannelId;
    // Save is gated on a non-empty title; re-evaluate as the user types.
    _titleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickStartsAt() async {
    // An event that already started is still editable, and `showDatePicker`
    // asserts `initialDate >= firstDate` - so anchor the range at whichever of
    // "now" and the existing start is earlier rather than crashing on it.
    final now = DateTime.now();
    final firstDate = _startsAt.isBefore(now) ? _startsAt : now;
    final date = await showDatePicker(
      context: context,
      initialDate: _startsAt,
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startsAt),
    );
    if (time == null) return;
    setState(() {
      _startsAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    setState(() => _saving = true);
    try {
      final repository = getIt<GuildRepository>();
      final existing = widget.existing;
      if (existing == null) {
        await repository.createEvent(
          widget.guildId,
          title: title,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          startsAt: _startsAt,
          location: _locationController.text.trim().isEmpty
              ? null
              : _locationController.text.trim(),
          voiceChannelId: _voiceChannelId,
        );
      } else {
        await repository.updateEvent(
          existing.id,
          title: title,
          description: _descriptionController.text.trim(),
          startsAt: _startsAt,
          location: _locationController.text.trim(),
          voiceChannelId: _voiceChannelId,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save that event.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );
    final divider = Divider(
      height: 1,
      thickness: 1,
      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
    );
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.l,
        right: AppSpacing.l,
        top: AppSpacing.l,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.l,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.existing == null ? 'New event' : 'Edit event',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.l),
            Text('TITLE', style: labelStyle),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              autofocus: widget.existing == null,
              decoration: const InputDecoration(hintText: 'Game night'),
            ),
            const SizedBox(height: AppSpacing.l),
            Text('DETAILS', style: labelStyle),
            const SizedBox(height: 6),
            TextField(
              controller: _descriptionController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Description (optional)',
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                hintText: 'Location (optional)',
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Text('SCHEDULE', style: labelStyle),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.card),
              child: ColoredBox(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Column(
                  children: [
                    InkWell(
                      onTap: _pickStartsAt,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.m,
                          vertical: AppSpacing.s + 2,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.m),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Starts at', style: labelStyle),
                                  const SizedBox(height: 2),
                                  Text(formatShortDateTime(_startsAt)),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (widget.voiceChannels.isNotEmpty) ...[
                      divider,
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.m,
                          vertical: AppSpacing.s,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.volume_up_outlined,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.m),
                            Expanded(
                              child: DropdownButtonFormField<String?>(
                                initialValue: _voiceChannelId,
                                isExpanded: true,
                                // Zero content padding: the theme's default
                                // (16h) would indent this label past the
                                // "Starts at" label in the row above, which
                                // shares the same icon gutter.
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  labelText: 'Voice channel (optional)',
                                ),
                                items: [
                                  const DropdownMenuItem<String?>(
                                    child: Text('None'),
                                  ),
                                  for (final channel in widget.voiceChannels)
                                    DropdownMenuItem<String?>(
                                      value: channel.id,
                                      child: Text(channel.name),
                                    ),
                                ],
                                onChanged: (value) =>
                                    setState(() => _voiceChannelId = value),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving || _titleController.text.trim().isEmpty
                    ? null
                    : _save,
                child: _saving
                    ? const ButtonProgressIndicator()
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
