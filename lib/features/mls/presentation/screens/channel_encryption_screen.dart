import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/mls/channel_encryption_service.dart';
import '../../../../core/mls/mls_join_request_service.dart';
import '../../../../core/mls/mls_service.dart';
import '../../../../core/realtime/realtime_event.dart';
import '../../../../core/realtime/realtime_service.dart';
import '../../../../core/theme/status_colors_extension.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/button_progress_indicator.dart';
import '../../../../core/widgets/profile_resolver.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../guilds/data/guild_repository.dart';
import '../../data/mls_api.dart';
import '../../data/models/mls_dtos.dart';

/// Turning a guild channel's end-to-end encryption on and off.
///
/// Mirrors Alpine's channel-settings encryption page section for section: the
/// status card, the disable confirmation, the devices that could not be
/// included, and the count of past eras. The wording deliberately matches too -
/// this is the one screen in the app where a wrong mental model has permanent
/// consequences for message history.
class ChannelEncryptionScreen extends StatefulWidget {
  const ChannelEncryptionScreen({
    super.key,
    required this.guildId,
    required this.channelId,
  });

  final String guildId;
  final String channelId;

  @override
  State<ChannelEncryptionScreen> createState() =>
      _ChannelEncryptionScreenState();
}

class _ChannelEncryptionScreenState extends State<ChannelEncryptionScreen> {
  final _service = getIt<ChannelEncryptionService>();

  final _joinRequests = getIt<MlsJoinRequestService>();

  MlsContextStateDto? _state;
  bool _loading = true;
  bool _busy = false;
  bool _confirmingDisable = false;
  List<UnreachableDeviceDto> _unreachable = const [];
  int? _retryAfterSeconds;
  String? _error;

  /// People asking to be let in, awaiting review.
  List<MlsJoinRequestDto> _requests = const [];

  /// Set when an approval was refused because the key did not match what was
  /// reviewed. Kept apart from [_error] because it might mean tampering rather
  /// than breakage, and it is shown in those terms.
  String? _verificationError;
  String? _actingOn;
  StreamSubscription<RealtimeEvent>? _requestSub;

  String get _myUserId => getIt<AuthRepository>().currentUserId ?? '';

  @override
  void initState() {
    super.initState();
    _load();

    // Members should see a new request appear without reopening the screen.
    _requestSub = getIt<RealtimeService>().events
        .where(
          (e) =>
              e.name == 'guild.ChannelMlsJoinRequested' &&
              e.objectPayload['channelId'] == widget.channelId,
        )
        .listen((_) => unawaited(_refreshRequests()));
  }

  @override
  void dispose() {
    _requestSub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final state = await _service.state(widget.channelId);
      if (!mounted) return;
      setState(() {
        _state = state;
        _loading = false;
      });
      await _refreshRequests();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not read this channel\'s encryption state.';
        _loading = false;
      });
      debugPrint('ChannelEncryptionScreen: $e');
    }
  }

  Future<void> _refreshRequests() async {
    if (!(_state?.encrypted ?? false)) {
      if (mounted) setState(() => _requests = const []);
      return;
    }
    try {
      final requests = await _joinRequests.list(widget.channelId);
      if (mounted) setState(() => _requests = requests);
    } catch (e) {
      // A failed queue read must not blank out the toggle above it.
      debugPrint('ChannelEncryptionScreen: could not list join requests: $e');
      if (mounted) setState(() => _requests = const []);
    }
  }

  /// True once this member has vouched - so the button reads as done rather than
  /// inviting a re-click.
  bool _hasApproved(MlsJoinRequestDto request) =>
      request.approverUserIds.contains(_myUserId);

  /// Vouching for yourself is not review, and the server refuses it anyway.
  bool _canApprove(MlsJoinRequestDto request) =>
      _myUserId.isNotEmpty &&
      request.requesterUserId != _myUserId &&
      !_hasApproved(request);

  Future<void> _approve(MlsJoinRequestDto request) async {
    if (_actingOn != null) return;
    setState(() {
      _actingOn = request.id;
      _verificationError = null;
    });
    try {
      await _joinRequests.approve(
        channelId: widget.channelId,
        request: request,
      );
      await _refreshRequests();
    } on JoinRequestVerificationException catch (e) {
      // The bytes did not match what was reviewed. Said plainly, because it is
      // the one failure here that might mean someone is tampering rather than
      // something being broken.
      if (mounted) setState(() => _verificationError = e.message);
    } catch (e) {
      debugPrint('ChannelEncryptionScreen: approve failed: $e');
      if (mounted) setState(() => _error = 'Could not approve that request.');
    } finally {
      if (mounted) setState(() => _actingOn = null);
    }
  }

  Future<void> _deny(MlsJoinRequestDto request) async {
    if (_actingOn != null) return;
    setState(() => _actingOn = request.id);
    try {
      await _joinRequests.deny(
        channelId: widget.channelId,
        requestId: request.id,
      );
      await _refreshRequests();
    } catch (e) {
      debugPrint('ChannelEncryptionScreen: deny failed: $e');
      if (mounted) setState(() => _error = 'Could not deny that request.');
    } finally {
      if (mounted) setState(() => _actingOn = null);
    }
  }

  Future<void> _enable() async {
    setState(() {
      _busy = true;
      _error = null;
      _retryAfterSeconds = null;
      _unreachable = const [];
    });

    try {
      // Exactly who can see the channel, resolved server-side against the same
      // permission logic that gates reads.
      //
      // Deliberately not the guild's member list: on a channel with restrictive
      // overwrites that hands group keys to people who cannot open the channel
      // at all, which makes the traffic readable to a wider audience than the
      // channel itself. Fetched fresh rather than cached - anyone missing from
      // this roster stays locked out until somebody approves their join request.
      final viewers = await getIt<GuildRepository>().getChannelViewers(
        widget.channelId,
      );

      final result = await _service.enable(
        channelId: widget.channelId,
        memberUserIds: viewers,
      );

      if (!mounted) return;
      setState(() => _unreachable = result.unreachableDevices);
      await _load();
    } on MlsToggleConflictException catch (e) {
      if (!mounted) return;
      setState(() {
        _retryAfterSeconds = e.conflict.retryAfterSeconds;
        _error = e.conflict.reason;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Could not turn on encryption. $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _disable() async {
    setState(() {
      _busy = true;
      _error = null;
      _retryAfterSeconds = null;
      _confirmingDisable = false;
    });

    try {
      await _service.disable(widget.channelId);
      await _load();
    } on MlsToggleConflictException catch (e) {
      if (!mounted) return;
      setState(() {
        _retryAfterSeconds = e.conflict.retryAfterSeconds;
        _error = e.conflict.reason;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Could not turn off encryption. $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = _state;
    final encrypted = state?.encrypted ?? false;
    final locked = !getIt<MlsService>().isUnlocked;

    return Scaffold(
      // Pushed with a MaterialPageRoute from channel settings, so the framework's
      // own back button is correct here - unlike the go_router-addressable
      // screens, which need AppBackButton's deep-link fallback.
      appBar: AppBar(title: const Text('Encryption')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.m),
              children: [
                Text(
                  'End-to-end encryption',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Messages sent while this is on can only be read by the '
                  'devices in the channel at the time. The server stores them '
                  'as ciphertext and cannot read or search them.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: AppSpacing.m),

                _StatusCard(
                  encrypted: encrypted,
                  generation: state?.activeGeneration,
                  busy: _busy || locked,
                  onEnable: _enable,
                  onDisable: () => setState(() => _confirmingDisable = true),
                ),

                if (locked) ...[
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    'Encryption keys for this device aren\'t set up yet, so it '
                    'can\'t start or join an encrypted channel.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],

                // Turning it off is not reversible for the messages already
                // sent, so this is a confirmation and not a toggle.
                if (_confirmingDisable) ...[
                  const SizedBox(height: AppSpacing.m),
                  _WarningPanel(
                    color: theme.colorScheme.error,
                    title: 'Turn off encryption?',
                    body:
                        'New messages will be readable by the server again. '
                        'Everything already sent stays encrypted - it is not '
                        'decrypted or rewritten, so only devices that are in '
                        'the group today will ever be able to read that '
                        'stretch of history.',
                    actions: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _busy
                              ? null
                              : () =>
                                    setState(() => _confirmingDisable = false),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: AppSpacing.s),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.error,
                          ),
                          onPressed: _busy ? null : _disable,
                          child: _busy
                              ? const ButtonProgressIndicator()
                              : const Text('Turn off'),
                        ),
                      ],
                    ),
                  ),
                ],

                // Access requests awaiting review.
                if (_requests.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.l),
                  Text('ACCESS REQUESTS', style: theme.textTheme.labelSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Only someone already in the channel can let anyone else '
                    'in - the server holds no keys. Check the fingerprint with '
                    'them directly before you approve.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  for (final request in _requests)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.s),
                      child: _JoinRequestCard(
                        request: request,
                        busy: _actingOn != null,
                        approved: _hasApproved(request),
                        canApprove: _canApprove(request),
                        onApprove: () => _approve(request),
                        onDeny: () => _deny(request),
                      ),
                    ),
                  if (_verificationError case final message?)
                    _WarningPanel(
                      color: theme.colorScheme.error,
                      title: 'That key did not match',
                      body: message,
                      actions: const SizedBox.shrink(),
                    ),
                ],

                // Devices we could not include. Silently short-changing them
                // would leave people staring at a channel they cannot read with
                // no explanation.
                if (_unreachable.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.m),
                  _WarningPanel(
                    color: context.statusColors.idle,
                    title: 'Some devices could not be included',
                    body:
                        'These devices had no encryption keys available, so '
                        'they were not added to the group and cannot read '
                        'anything sent from now on. They will be able to join '
                        'once they come online and upload new keys.',
                    actions: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final device in _unreachable)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.xs),
                            child: Text(
                              '• ${device.deviceName ?? device.deviceId}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],

                if ((state?.terminatedGenerationCount ?? 0) > 0) ...[
                  const SizedBox(height: AppSpacing.m),
                  Text(
                    'This channel has ${state!.terminatedGenerationCount} '
                    'earlier encrypted ${state.terminatedGenerationCount == 1 ? 'period' : 'periods'}. '
                    'Messages from those are still here but can only be read '
                    'by devices that were in the group at the time.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],

                if (_retryAfterSeconds case final seconds?) ...[
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    'Encryption was changed too recently. Try again in '
                    '$seconds ${seconds == 1 ? 'second' : 'seconds'}.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: context.statusColors.idle,
                    ),
                  ),
                ] else if (_error case final message?) ...[
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.encrypted,
    required this.generation,
    required this.busy,
    required this.onEnable,
    required this.onDisable,
  });

  final bool encrypted;
  final int? generation;
  final bool busy;
  final VoidCallback onEnable;
  final VoidCallback onDisable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = encrypted
        ? context.statusColors.online
        : theme.colorScheme.onSurface.withValues(alpha: 0.45);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s + AppSpacing.xs),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              encrypted ? Icons.lock_outline : Icons.lock_open_outlined,
              size: 20,
              color: accent,
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  encrypted
                      ? 'This channel is end-to-end encrypted'
                      : 'This channel is not encrypted',
                  style: theme.textTheme.bodyMedium,
                ),
                if (encrypted && generation != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Encryption period $generation',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          if (encrypted)
            TextButton(
              onPressed: busy ? null : onDisable,
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              child: const Text('Turn off'),
            )
          else
            FilledButton(
              onPressed: busy ? null : onEnable,
              child: busy
                  ? const ButtonProgressIndicator()
                  : const Text('Turn on'),
            ),
        ],
      ),
    );
  }
}

/// One person asking to be let in.
///
/// The fingerprint is the point of the whole screen, so it gets the emphasis: a
/// reviewer is meant to read it back to the requester over some channel the
/// server does not control. Approving without doing that makes the review
/// ceremonial.
class _JoinRequestCard extends StatelessWidget {
  const _JoinRequestCard({
    required this.request,
    required this.busy,
    required this.approved,
    required this.canApprove,
    required this.onApprove,
    required this.onDeny,
  });

  final MlsJoinRequestDto request;
  final bool busy;
  final bool approved;
  final bool canApprove;
  final VoidCallback onApprove;
  final VoidCallback onDeny;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s + AppSpacing.xs),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(userId: request.requesterUserId, radius: 14),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: ProfileResolver(
                  userId: request.requesterUserId,
                  builder: (context, profile) => Text(
                    profile?.userName ?? request.requesterUserId,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
              Text(
                '${request.approverUserIds.length} of '
                '${request.requiredApprovals} approvals',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Their identity fingerprint',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 2),
          SelectableText(
            request.signatureKeyFingerprint,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Ask them to read this out. If it differs, do not approve.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: busy ? null : onDeny,
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
                child: const Text('Deny'),
              ),
              const SizedBox(width: AppSpacing.s),
              if (approved)
                Text(
                  'You approved',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.statusColors.online,
                  ),
                )
              else
                FilledButton(
                  onPressed: busy || !canApprove ? null : onApprove,
                  child: const Text('Approve'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WarningPanel extends StatelessWidget {
  const _WarningPanel({
    required this.color,
    required this.title,
    required this.body,
    required this.actions,
  });

  final Color color;
  final String title;
  final String body;
  final Widget actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s + AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            body,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          actions,
        ],
      ),
    );
  }
}
