import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/mls/mls_failure_log.dart';
import '../../../../core/mls/mls_join_request_service.dart';
import '../../../../core/mls/mls_service.dart';
import '../../../../core/theme/status_colors_extension.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/button_progress_indicator.dart';
import '../../../auth/data/auth_repository.dart';
import '../../data/models/mls_dtos.dart';

/// Shown at the top of an encrypted context this device cannot read.
///
/// Two situations reach here, and they used to be indistinguishable to the user
/// because both render as a wall of unreadable messages with no explanation:
///
/// * **Never admitted.** Somebody who joined a guild after a channel was
///   encrypted holds no group keys - and, far more commonly, a *device*
///   registered after an encrypted DM already existed was never welcomed to it.
///   A group member is a device, not a user, so a second handset is as much an
///   outsider as a stranger. Nobody can mint them a Welcome unprompted, since
///   the server holds no keys either; only a current member can produce an Add
///   commit.
/// * **Admitted but broken.** The keys were here and are not any more - a wiped
///   store, a lost keychain entry, a device removed by someone else. Counted by
///   [MlsFailureLog], which is the only reason this case is visible at all:
///   every failure on the read path used to be swallowed.
///
/// Contract §B extends the join-request routes to conversations, which is what
/// makes this useful outside guild channels.
class ChannelAccessBanner extends StatefulWidget {
  const ChannelAccessBanner({
    super.key,
    required this.contextId,
    this.isChannel = true,
  });

  final String contextId;

  /// Picks the route pair. Conversations and channels differ only in
  /// authorization server-side.
  final bool isChannel;

  @override
  State<ChannelAccessBanner> createState() => _ChannelAccessBannerState();
}

class _ChannelAccessBannerState extends State<ChannelAccessBanner> {
  final _joinRequests = getIt<MlsJoinRequestService>();
  final _failures = getIt<MlsFailureLog>();

  MlsJoinRequestDto? _pending;
  String? _fingerprint;
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _failures.addListener(_onFailuresChanged);
    unawaited(_load());
  }

  @override
  void dispose() {
    _failures.removeListener(_onFailuresChanged);
    super.dispose();
  }

  void _onFailuresChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    try {
      final requests = await _joinRequests.list(
        widget.contextId,
        isChannel: widget.isChannel,
      );
      final myUserId = getIt<AuthRepository>().currentUserId;
      final myDeviceId = getIt<MlsService>().deviceIdService.deviceIdOrNull;

      // Admission is per device, so another of this user's devices having asked
      // does nothing for this one.
      final mine = requests
          .where(
            (r) =>
                r.requesterUserId == myUserId &&
                r.requesterDeviceId == myDeviceId &&
                r.state == MlsJoinRequestState.pending,
          )
          .firstOrNull;

      final fingerprint = mine == null
          ? null
          : await _joinRequests.ownFingerprint();

      if (!mounted) return;
      setState(() {
        _pending = mine;
        _fingerprint = fingerprint;
        _loading = false;
      });
    } catch (e) {
      debugPrint('ChannelAccessBanner: could not read the request queue: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _request() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      // External commit first. When the server still holds a GroupInfo for the
      // live generation this device can walk back in on its own, with no
      // approval and no round trip through another person - which is the whole
      // point of the recovery path openmls gives us and which nothing has ever
      // called.
      if (await _tryRejoin()) return;

      final request = await _joinRequests.requestAccess(
        widget.contextId,
        isChannel: widget.isChannel,
      );
      final fingerprint = await _joinRequests.ownFingerprint();
      if (!mounted) return;
      setState(() {
        _pending = request;
        _fingerprint = fingerprint;
      });
    } catch (e) {
      debugPrint('ChannelAccessBanner: request failed: $e');
      if (mounted) {
        setState(() => _error = 'Could not send that request. Try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Best effort by design: an external commit only works when the group's
  /// public GroupInfo is available, so a failure here is the normal path back
  /// to asking, not an error worth showing.
  Future<bool> _tryRejoin() async {
    try {
      return await _joinRequests.rejoin(
        widget.contextId,
        isChannel: widget.isChannel,
      );
    } catch (e) {
      debugPrint('ChannelAccessBanner: external-commit rejoin failed: $e');
      return false;
    }
  }

  Future<void> _withdraw() async {
    final pending = _pending;
    if (pending == null) return;
    setState(() => _busy = true);
    try {
      await _joinRequests.cancel(
        contextId: widget.contextId,
        isChannel: widget.isChannel,
        requestId: pending.id,
      );
      if (mounted) setState(() => _pending = null);
    } catch (e) {
      debugPrint('ChannelAccessBanner: withdraw failed: $e');
      if (mounted) setState(() => _error = 'Could not withdraw that request.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) return const SizedBox.shrink();

    final pending = _pending;
    final mls = getIt<MlsService>();
    final locked = !mls.isUnlocked;
    final keysGone = mls.identityStatus.value == MlsIdentityStatus.keysMissing;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s + AppSpacing.xs),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: context.statusColors.idle,
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title(pending, keysGone),
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _describe(pending, locked, keysGone),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.65,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // The requester's half of the out-of-band check: read this to someone
          // who is already in, so they can confirm it against what they see.
          if (pending != null && _fingerprint != null) ...[
            const SizedBox(height: AppSpacing.s),
            Text(
              'Your identity fingerprint',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 2),
            SelectableText(
              _fingerprint!,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                letterSpacing: 1,
              ),
            ),
          ],

          // Whatever the engine actually said. Free-form on purpose: it is the
          // one detail that makes a report about this actionable, and
          // paraphrasing it would lose exactly that.
          if (_failures.lastReason(widget.contextId) case final reason?) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              reason,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
              ),
            ),
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

          const SizedBox(height: AppSpacing.s),
          Align(
            alignment: Alignment.centerRight,
            child: pending == null
                ? FilledButton(
                    onPressed: _busy || locked ? null : _request,
                    child: _busy
                        ? const ButtonProgressIndicator()
                        : Text(keysGone ? 'Re-link this device' : 'Request access'),
                  )
                : TextButton(
                    onPressed: _busy ? null : _withdraw,
                    child: const Text('Withdraw request'),
                  ),
          ),
        ],
      ),
    );
  }

  String _title(MlsJoinRequestDto? pending, bool keysGone) {
    if (pending != null) return 'Waiting to be let in';
    if (keysGone) return 'This device can\'t read this conversation';
    return widget.isChannel
        ? 'You can\'t read this channel'
        : 'This device can\'t read this conversation';
  }

  String _describe(MlsJoinRequestDto? pending, bool locked, bool keysGone) {
    if (locked) {
      return 'Encryption keys aren\'t set up on this device yet, so it can\'t '
          'ask to join.';
    }
    if (pending != null) {
      return '${pending.approverUserIds.length} of ${pending.requiredApprovals} '
          'members have approved. Read your fingerprint out to one of them so '
          'they can check it before approving.';
    }
    if (keysGone) {
      return 'Its encryption keys are gone, so the messages here can\'t be '
          'opened. Re-linking gets it back into the group - anything sent '
          'before that stays unreadable on this device.';
    }
    return 'It\'s end-to-end encrypted and this device isn\'t in the group. '
        'Ask to be let in - the server can\'t do it for you, because it holds '
        'no keys.';
  }
}
