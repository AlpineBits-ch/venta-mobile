import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/mls/device_admission_service.dart';
import '../../../../core/mls/mls_join_request_service.dart';
import '../../../../core/mls/mls_service.dart';
import '../../../../core/realtime/realtime_event.dart';
import '../../../../core/realtime/realtime_service.dart';
import '../../../../core/theme/status_colors_extension.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/profile_resolver.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/data/auth_repository.dart';
import '../../data/models/mls_dtos.dart';

/// The review queue for an encrypted context, shown inside the context itself.
///
/// Until this existed the only place a join request could be approved was
/// `ChannelEncryptionScreen`, which lives behind guild channel settings. A DM
/// has no such screen, so a request against a **conversation** - the case
/// contract §B was written for, and the one a second handset actually hits -
/// reached the server, sat at `Pending`, and was never shown to a single human.
/// The reporter's words were "neither mobile or anything else shows a prompt
/// that allows me to set it", and this widget is that prompt.
///
/// Mounted for channels too. The settings screen is reachable only by members
/// who can open channel settings, while any member may vouch, so a queue that
/// only appears there is invisible to most of the people entitled to act on it.
///
/// Sits next to `ChannelAccessBanner` and deliberately mirrors it: that one is
/// this device asking, this one is this device being asked. Same fingerprint
/// emphasis, same wording register, same place on the screen.
class MlsJoinRequestReview extends StatefulWidget {
  const MlsJoinRequestReview({
    super.key,
    required this.contextId,
    required this.isChannel,
  });

  final String contextId;

  /// Picks the route pair. Conversations and channels differ only in
  /// authorization server-side.
  final bool isChannel;

  @override
  State<MlsJoinRequestReview> createState() => _MlsJoinRequestReviewState();
}

class _MlsJoinRequestReviewState extends State<MlsJoinRequestReview> {
  final _joinRequests = getIt<MlsJoinRequestService>();
  final _admission = getIt<DeviceAdmissionService>();

  List<MlsJoinRequestDto> _requests = const [];
  String? _actingOn;

  /// Kept apart from [_error] because a mismatch between the bytes on offer and
  /// the bytes that were reviewed cannot happen by accident. It is rendered as a
  /// security warning, not as "something went wrong".
  String? _verificationError;
  String? _error;

  StreamSubscription<RealtimeEvent>? _pushSub;

  String get _myUserId => getIt<AuthRepository>().currentUserId ?? '';

  String? get _myDeviceId => getIt<MlsService>().deviceIdService.deviceIdOrNull;

  @override
  void initState() {
    super.initState();
    unawaited(_refresh());

    // A request raised while the thread is open has to appear without the user
    // reopening it - a review prompt nobody is looking at is the state this
    // whole widget exists to end.
    _pushSub = getIt<RealtimeService>().events
        .where(_concernsThisContext)
        .listen((_) => unawaited(_refresh()));
  }

  @override
  void dispose() {
    _pushSub?.cancel();
    super.dispose();
  }

  /// Conversations and channels announce the same event under different names,
  /// and the channel one keys on `channelId` rather than `contextId`.
  bool _concernsThisContext(RealtimeEvent event) {
    final payload = event.objectPayload;
    if (event.name == 'conversation.MlsJoinRequest') {
      return payload['contextId'] == widget.contextId;
    }
    if (event.name == 'guild.ChannelMlsJoinRequested') {
      return payload['channelId'] == widget.contextId;
    }
    return false;
  }

  Future<void> _refresh() async {
    try {
      final requests = await _joinRequests.list(
        widget.contextId,
        isChannel: widget.isChannel,
      );
      if (!mounted) return;
      setState(() => _requests = requests.where(_isReviewable).toList());
    } catch (e) {
      // A queue that cannot be read must not blank the conversation behind it.
      debugPrint('MlsJoinRequestReview: could not list join requests: $e');
      if (mounted) setState(() => _requests = const []);
    }
  }

  /// Requests this device may usefully be shown.
  ///
  /// Excludes this device's own request. The server refuses a device approving
  /// itself, and `ChannelAccessBanner` already renders that case as "waiting to
  /// be let in" - showing it here as well would offer an Approve button whose
  /// only possible outcome is a 400.
  bool _isReviewable(MlsJoinRequestDto request) =>
      request.state == MlsJoinRequestState.pending &&
      request.requesterDeviceId != _myDeviceId;

  /// True once this member has vouched, so the button reads as done rather than
  /// inviting a second click that changes nothing.
  bool _hasApproved(MlsJoinRequestDto request) =>
      request.approverUserIds.contains(_myUserId);

  /// Whether an Approve button should be live.
  ///
  /// Holding the group is the hard requirement, not a nicety: approving is what
  /// makes *this* client mint the Add commit, and a device with no leaf cannot
  /// produce one. Offering the action anyway would fail at the last step with
  /// the request already marked approved server-side, which reads to everyone
  /// else as though somebody vouched and the join simply broke.
  bool get _holdsGroup =>
      getIt<MlsService>().activeGroupId(widget.contextId) != null;

  bool _canApprove(MlsJoinRequestDto request) =>
      _myUserId.isNotEmpty && _holdsGroup && !_hasApproved(request);

  Future<void> _approve(MlsJoinRequestDto request) async {
    if (_actingOn != null) return;
    setState(() {
      _actingOn = request.id;
      _verificationError = null;
      _error = null;
    });
    try {
      await _joinRequests.approve(
        contextId: widget.contextId,
        request: request,
        isChannel: widget.isChannel,
      );
      await _refresh();
    } on JoinRequestVerificationException catch (e) {
      // The bytes did not match what was reviewed. Said plainly and loudly,
      // because it is the one failure here that may mean somebody is tampering
      // rather than something being broken - a server that substitutes a key
      // package between approval and add is exactly what the check catches.
      if (mounted) setState(() => _verificationError = e.message);
    } catch (e) {
      debugPrint('MlsJoinRequestReview: approve failed: $e');
      if (mounted) setState(() => _error = 'Could not approve that request.');
    } finally {
      if (mounted) setState(() => _actingOn = null);
    }
  }

  Future<void> _deny(MlsJoinRequestDto request) async {
    if (_actingOn != null) return;
    setState(() {
      _actingOn = request.id;
      _error = null;
    });
    try {
      await _joinRequests.deny(
        contextId: widget.contextId,
        requestId: request.id,
        isChannel: widget.isChannel,
      );
      await _refresh();
    } catch (e) {
      debugPrint('MlsJoinRequestReview: deny failed: $e');
      if (mounted) setState(() => _error = 'Could not deny that request.');
    } finally {
      if (mounted) setState(() => _actingOn = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<AdmittedDevice>>(
      valueListenable: _admission.recentlyAdmitted,
      builder: (context, admitted, _) {
        final here = admitted
            .where((d) => d.contextId == widget.contextId)
            .toList();
        if (_requests.isEmpty && here.isEmpty && _verificationError == null) {
          return const SizedBox.shrink();
        }
        return _panel(context, here);
      },
    );
  }

  Widget _panel(BuildContext context, List<AdmittedDevice> admitted) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s + AppSpacing.xs),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // §G.2, item 1: admission may be silent, notification may not. An
          // admission nobody is told about is an admission nobody can dispute,
          // so it carries the same fingerprint a manual approval would show.
          for (final device in admitted)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s),
              child: _AdmittedNotice(
                device: device,
                onAcknowledge: () => _admission.acknowledge(device.deviceId),
              ),
            ),

          if (_requests.isNotEmpty) ...[
            Text('ACCESS REQUESTS', style: theme.textTheme.labelSmall),
            const SizedBox(height: AppSpacing.xs),
            for (final request in _requests)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.s),
                child: _RequestCard(
                  request: request,
                  isOwnAccount: request.requesterUserId == _myUserId,
                  busy: _actingOn != null,
                  approved: _hasApproved(request),
                  canApprove: _canApprove(request),
                  holdsGroup: _holdsGroup,
                  onApprove: () => _approve(request),
                  onDeny: () => _deny(request),
                ),
              ),
          ],

          if (_verificationError case final message?) ...[
            const SizedBox(height: AppSpacing.s),
            _VerificationWarning(message: message),
          ],

          if (_error case final message?) ...[
            const SizedBox(height: AppSpacing.xs),
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

/// One device asking to be let in.
///
/// The fingerprint is the point of the card, so it gets the emphasis: it is the
/// long-lived identity value a human compares out of band, and it is stable
/// across every key package that device will ever mint. The key-package hash is
/// deliberately absent - it changes on every request and nobody can read it
/// aloud, so presenting it as the thing to check would look like verification
/// while verifying nothing.
class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.isOwnAccount,
    required this.busy,
    required this.approved,
    required this.canApprove,
    required this.holdsGroup,
    required this.onApprove,
    required this.onDeny,
  });

  final MlsJoinRequestDto request;

  /// Whether the asking device belongs to the reviewer's own account. Two very
  /// different trust questions - "is this really my laptop" versus "is this
  /// really my correspondent's new phone" - and answering the wrong one is how a
  /// reviewer approves without checking anything.
  final bool isOwnAccount;

  final bool busy;
  final bool approved;
  final bool canApprove;
  final bool holdsGroup;
  final VoidCallback onApprove;
  final VoidCallback onDeny;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtle = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final name = request.requesterDeviceName;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s + AppSpacing.xs),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.6),
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isOwnAccount)
                Icon(
                  Icons.devices_other,
                  size: 24,
                  color: context.statusColors.idle,
                )
              else
                UserAvatar(userId: request.requesterUserId, radius: 14),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: isOwnAccount
                    ? Text(
                        name == null
                            ? 'Another of your devices wants in'
                            : '"$name" wants in',
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      )
                    : ProfileResolver(
                        userId: request.requesterUserId,
                        builder: (context, profile) => Text(
                          '${profile?.userName ?? request.requesterUserId} '
                          'added a device',
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
              ),
              Text(
                '${request.approverUserIds.length} of '
                '${request.requiredApprovals}',
                style: theme.textTheme.bodySmall?.copyWith(color: subtle),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            isOwnAccount
                ? 'A device signed in to your account is asking to read this '
                      'conversation. Nobody but a device already in the group '
                      'can let it in - not even the server, which holds no '
                      'keys.'
                : 'Their new device holds none of this conversation\'s keys '
                      'yet. Only somebody already in the group can add it.',
            style: theme.textTheme.bodySmall?.copyWith(color: subtle),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            isOwnAccount
                ? 'That device\'s identity fingerprint'
                : 'Their identity fingerprint',
            style: theme.textTheme.labelSmall?.copyWith(color: subtle),
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
            isOwnAccount
                ? 'Check this against what that device is showing you. If it '
                      'differs, the device asking is not yours.'
                : 'Ask them to read this out over a call. If it differs, do '
                      'not approve.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),

          // Said rather than left as a disabled button with no explanation. A
          // locked-out device cannot mint an Add commit for anybody, and a
          // reviewer staring at a greyed-out Approve has no way to know why.
          if (!holdsGroup) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'This device isn\'t in the group either, so it can\'t let anyone '
              'in. Approve from a device that can read this conversation.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: context.statusColors.idle,
              ),
            ),
          ],

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

/// A device that was let in without anyone tapping anything (contract §G.2).
///
/// Automatic admission is silent *admission*, never silent *notification*: the
/// owner has to be able to notice a device they do not recognise, which means
/// naming it and showing the fingerprint they would have compared had they been
/// asked.
class _AdmittedNotice extends StatelessWidget {
  const _AdmittedNotice({required this.device, required this.onAcknowledge});

  final AdmittedDevice device;
  final VoidCallback onAcknowledge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = context.statusColors.online;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s + AppSpacing.xs),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A device of yours joined this conversation',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'It proved it holds your account key, so it was let in without '
            'asking you. If you did not just set up a device, remove it from '
            'your account settings now.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          SelectableText(
            device.fingerprint,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              letterSpacing: 1,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onAcknowledge,
              child: const Text('Got it'),
            ),
          ),
        ],
      ),
    );
  }
}

/// The key package on offer was not the one that was reviewed.
///
/// Rendered as its own panel rather than folded into the generic error line
/// because the two mean opposite things. A failed request is a failed request;
/// this one means the bytes changed between the review and the add, which is
/// precisely the substitution the review exists to catch and cannot happen by
/// accident.
class _VerificationWarning extends StatelessWidget {
  const _VerificationWarning({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final error = theme.colorScheme.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s + AppSpacing.xs),
      decoration: BoxDecoration(
        color: error.withValues(alpha: 0.06),
        border: Border.all(color: error.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.gpp_maybe_outlined, size: 18, color: error),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  'That key did not match',
                  style: theme.textTheme.bodyMedium?.copyWith(color: error),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(message, style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Nothing was added. This is not a normal failure - the key offered '
            'was not the key that was reviewed. Check the fingerprint with '
            'them again before trying anything else.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
