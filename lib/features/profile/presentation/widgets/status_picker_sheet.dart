import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../data/models/profile_dto.dart';
import '../../data/profile_repository.dart';
import 'status_label.dart';

const _pickableStatuses = [
  OnlineStatus.online,
  OnlineStatus.idle,
  OnlineStatus.doNotDisturb,
  OnlineStatus.hidden,
];

String _statusBlurb(OnlineStatus status) => switch (status) {
  OnlineStatus.doNotDisturb => 'You will not receive any notifications',
  OnlineStatus.hidden => 'You will not appear online, but have full access',
  _ => '',
};

/// The presence menu behind the chevron in the persistent user banner. Writes
/// straight to [ProfileRepository] instead of taking a cubit, so it can be
/// opened from the app shell (which has no profile bloc in scope) as well as
/// from the profile screens - everyone listening on `selfStream` updates.
Future<void> showStatusPickerSheet(BuildContext context) async {
  final repository = getIt<ProfileRepository>();
  final current = repository.cachedSelf?.onlineStatus;

  final picked = await showModalBottomSheet<OnlineStatus>(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    builder: (context) => _StatusPickerSheet(current: current),
  );
  if (picked == null || picked == current) return;

  try {
    await repository.setSelfStatus(picked);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update your status.')),
      );
    }
  }
}

class _StatusPickerSheet extends StatelessWidget {
  const _StatusPickerSheet({required this.current});

  final OnlineStatus? current;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.m,
              0,
              AppSpacing.m,
              AppSpacing.s,
            ),
            child: Text('Set Status', style: theme.textTheme.titleMedium),
          ),
          for (final status in _pickableStatuses)
            ListTile(
              leading: Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor(context, status),
                ),
              ),
              title: Text(statusLabel(status)),
              subtitle: _statusBlurb(status).isEmpty
                  ? null
                  : Text(_statusBlurb(status)),
              trailing: status == current
                  ? Icon(Icons.check, color: theme.colorScheme.primary)
                  : null,
              onTap: () => Navigator.of(context).pop(status),
            ),
        ],
      ),
    );
  }
}
