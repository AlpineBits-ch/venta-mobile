import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/mls/mls_join_request_service.dart';
import '../../../../core/mls/mls_service.dart';
import '../../../../core/theme/status_colors_extension.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/button_progress_indicator.dart';
import '../../../auth/data/auth_repository.dart';
import '../../data/models/mls_dtos.dart';

/// Shown at the top of an encrypted channel this device cannot read.
///
/// Somebody who joins a guild after a channel was encrypted holds no group keys,
/// and nobody can mint them a Welcome unprompted - the server has no keys either,
/// so only a current member can produce an Add commit. Without a way to ask, the
/// channel is simply a wall of unreadable messages with no explanation and no
/// recourse.
///
/// Alpine has the service for this but no UI on the requester's side; this is
/// the other half of that loop.
class ChannelAccessBanner extends StatefulWidget {
  const ChannelAccessBanner({super.key, required this.channelId});

  final String channelId;

  @override
  State<ChannelAccessBanner> createState() => _ChannelAccessBannerState();
}

class _ChannelAccessBannerState extends State<ChannelAccessBanner> {
  final _joinRequests = getIt<MlsJoinRequestService>();

  MlsJoinRequestDto? _pending;
  String? _fingerprint;
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final requests = await _joinRequests.list(widget.channelId);
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
      final request = await _joinRequests.requestAccess(widget.channelId);
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

  Future<void> _withdraw() async {
    final pending = _pending;
    if (pending == null) return;
    setState(() => _busy = true);
    try {
      await _joinRequests.cancel(
        channelId: widget.channelId,
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
    final locked = !getIt<MlsService>().isUnlocked;

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
                      pending == null
                          ? 'You can\'t read this channel'
                          : 'Waiting to be let in',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _describe(pending, locked),
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
                        : const Text('Request access'),
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

  String _describe(MlsJoinRequestDto? pending, bool locked) {
    if (locked) {
      return 'Encryption keys aren\'t set up on this device yet, so it can\'t '
          'ask to join.';
    }
    if (pending == null) {
      return 'It\'s end-to-end encrypted and this device isn\'t in the group. '
          'Ask the members to let you in - the server can\'t do it, because it '
          'holds no keys.';
    }
    return '${pending.approverUserIds.length} of ${pending.requiredApprovals} '
        'members have approved. Read your fingerprint out to one of them so '
        'they can check it before approving.';
  }
}
