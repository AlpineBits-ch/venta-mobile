import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/mls/mls_coverage_service.dart';
import '../../../../core/theme/status_colors_extension.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/profile_resolver.dart';

/// Devices that cannot read this context, on the screen somebody goes looking
/// for it on.
///
/// **Deliberately only here.** Neither of the two situations this renders is one
/// the reader is currently inconvenienced by: another of their devices is
/// stranded but they are not holding it, or somebody else's is and it is not
/// theirs to fix. A badge, a red dot on the conversation list or a push for
/// either is a warning that fires on an inconvenience nobody is having, which is
/// a warning people learn to dismiss - and there is nothing to tap in the moment
/// it would fire. The device in hand being locked out is the case with an
/// action, and that one is inline above the composer instead.
///
/// Refetches on mount rather than reading the session cache: this is the screen
/// where somebody explicitly asked.
class DeviceCoverageSection extends StatefulWidget {
  const DeviceCoverageSection({
    super.key,
    required this.contextId,
    required this.isChannel,
  });

  final String contextId;

  /// Picks the route pair, and the noun. A channel never carries other people's
  /// devices - its roster lives in the Guild service - so only the section's own
  /// devices half can appear there.
  final bool isChannel;

  @override
  State<DeviceCoverageSection> createState() => _DeviceCoverageSectionState();
}

class _DeviceCoverageSectionState extends State<DeviceCoverageSection> {
  final _coverage = getIt<MlsCoverageService>();

  DeviceCoverageView? _view;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() => _busy = true);
    final view = await _coverage.view(
      widget.contextId,
      isChannel: widget.isChannel,
      refresh: true,
    );
    if (!mounted) return;
    setState(() {
      _view = view;
      _busy = false;
    });
  }

  String get _noun => widget.isChannel ? 'channel' : 'conversation';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final view = _view;
    if (view == null || !view.encrypted) return const SizedBox.shrink();

    // Nothing could be looked up, so both lists are empty for a reason that is
    // not "everybody is in". The reader asked, so they get told that much and
    // nothing that reads as an answer.
    if (view.unavailable && !view.hasStrandedDevices) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.l),
        child: _couldNotCheck(theme, 'Couldn\'t check right now.'),
      );
    }

    if (!view.hasStrandedDevices) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DEVICES', style: theme.textTheme.labelSmall),
          const SizedBox(height: AppSpacing.s),

          for (final device in view.otherOwnDevices)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s),
              child: _StrandedDevice(
                title:
                    '${device.deviceName ?? 'One of your devices'} can\'t read '
                    'this $_noun',
                body:
                    'Open Venta on that device and it will ask to be let back '
                    'in.',
              ),
            ),

          for (final device in view.peerDevices)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s),
              child: ProfileResolver(
                userId: device.userId,
                builder: (context, profile) => _StrandedDevice(
                  // "Alex's iPhone", falling back to whichever half is known -
                  // an entry with neither is still worth listing, because the
                  // reader knowing a device is outside is the whole point.
                  title:
                      '${_possessive(profile?.userName ?? device.userId, device.deviceName)} '
                      'can\'t read this $_noun',
                  body:
                      'They\'ll be asked to let it in the next time they open '
                      'Venta on it.',
                ),
              ),
            ),

          // Part of the answer was readable and part was not. The list above
          // stands - nothing here retracts it - and this says only that it may
          // be short.
          if (view.unavailable)
            _couldNotCheck(theme, 'Couldn\'t finish checking right now.'),
        ],
      ),
    );
  }

  Widget _couldNotCheck(ThemeData theme, String message) => Row(
    children: [
      Expanded(
        child: Text(
          message,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
      TextButton(
        onPressed: _busy ? null : _load,
        child: const Text('Try again'),
      ),
    ],
  );

  String _possessive(String owner, String? deviceName) =>
      deviceName == null ? '$owner\'s device' : '$owner\'s $deviceName';
}

/// One device that is outside the group, worded as information rather than as a
/// fault.
///
/// Nothing alarming in the palette on purpose. The context is not less secure
/// for a device being outside it - it is more secure and less useful - and the
/// reader has nothing to do about this one anyway, so an error colour would
/// only teach them to skip the section.
class _StrandedDevice extends StatelessWidget {
  const _StrandedDevice({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s + AppSpacing.xs),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.6),
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              Icons.devices_other,
              size: 18,
              color: context.statusColors.idle,
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
