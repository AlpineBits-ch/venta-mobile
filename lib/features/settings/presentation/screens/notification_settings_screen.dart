import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/settings_tiles.dart';
import '../../../auth/data/account_repository.dart';
import '../../../auth/data/models/notification_settings_dto.dart';

/// Push/sound preferences. Saves on every toggle - there's no Save button
/// because each switch is independently meaningful, and
/// `AccountRepository.updateNotificationSettings` merges into the server's
/// settings blob rather than overwriting keys other clients own.
///
/// The server's preferences are only half the story: nothing is delivered if
/// the OS permission is missing, and on Android a permanently-denied
/// `POST_NOTIFICATIONS` can never be re-prompted from inside the app. A screen
/// showing four switches turned on above a silent phone is the app claiming
/// something it can't do, so the OS state is read here too and shown before
/// the preferences it overrides.
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen>
    with WidgetsBindingObserver {
  static const _cooldownOptions = [5, 10, 15, 30, 60, 120, 300];

  NotificationSettingsDto _settings = const NotificationSettingsDto();
  bool _saving = false;
  bool _loading = true;

  /// Null until the first check comes back.
  PermissionStatus? _osPermission;

  /// Set once a request has come back without a grant.
  ///
  /// Android's `USER_FIXED` flag - the state a twice-denied permission ends up
  /// in, where the system dialog will never appear again - is not visible to
  /// `permission_handler`: it reports plain `denied`, the same as
  /// never-asked, and `isPermanentlyDenied` stays false. Asking and getting
  /// nothing back *is* the signal, and without it the banner offers an
  /// "Allow notifications" button that can be pressed forever with no dialog
  /// and no change.
  bool _requestWentUnanswered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
    _refreshPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// The only way back from a permanently-denied permission is the system
  /// settings app, so the answer changes while this screen is backgrounded.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshPermission();
  }

  Future<void> _refreshPermission() async {
    final status = await Permission.notification.status;
    if (!mounted) return;
    setState(() {
      _osPermission = status;
      // Coming back granted clears the "asking doesn't work" state - they
      // fixed it in system settings.
      if (status.isGranted) _requestWentUnanswered = false;
    });
  }

  Future<void> _load() async {
    try {
      final settings = await getIt<AccountRepository>()
          .getNotificationSettings();
      if (mounted) {
        setState(() {
          _settings = settings;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _apply(NotificationSettingsDto settings) async {
    setState(() {
      _settings = settings;
      _saving = true;
    });
    try {
      await getIt<AccountRepository>().updateNotificationSettings(settings);
    } catch (error) {
      if (mounted) {
        // `413` is the settings blob being over its size cap. This screen only
        // ever adds the `notifications` key, and re-fetches and merges before
        // saving, so the bulk came from somewhere else - retrying the same
        // toggle will meet the same wall, and the generic wording would have
        // the user do exactly that.
        final tooLarge =
            error is DioException && error.response?.statusCode == 413;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tooLarge
                  ? 'Your saved settings are too large for the server to '
                        'store. Try again from the app that added them.'
                  : 'Could not save notification settings.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Turning the master switch on is the moment the user has said they want
  /// notifications, so it's also the moment to ask the OS for them - the
  /// session-start request in `PushNotificationService` is easy to miss and
  /// only ever fires once per install.
  Future<void> _setEnabled(bool enabled) async {
    if (enabled && !(_osPermission?.isGranted ?? false)) {
      await _requestPermission();
    }
    await _apply(_settings.copyWith(enabled: enabled));
  }

  Future<void> _requestPermission() async {
    final status = await Permission.notification.request();
    if (!mounted) return;
    setState(() {
      _osPermission = status;
      _requestWentUnanswered = !status.isGranted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final permission = _osPermission;
    // `null` while the first check is in flight - saying nothing beats
    // flashing a warning that resolves itself half a frame later.
    final blocked = permission != null && !permission.isGranted;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: RoutePaths.settings),
        title: const Text('Notifications'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.m,
                AppSpacing.m,
                AppSpacing.m,
                AppSpacing.xl,
              ),
              children: [
                if (blocked) ...[
                  _BlockedBanner(
                    // A denial Android will re-prompt for is a different
                    // problem from one it won't, and they need different
                    // buttons.
                    permanent:
                        permission.isPermanentlyDenied ||
                        _requestWentUnanswered,
                    onRequest: _requestPermission,
                    onOpenSettings: () => unawaited(openAppSettings()),
                  ),
                  const SizedBox(height: AppSpacing.l),
                ],
                SettingsSection(
                  label: 'Deliver',
                  child: Column(
                    children: [
                      SwitchListTile.adaptive(
                        title: const Text('Notifications enabled'),
                        value: _settings.enabled,
                        onChanged: _saving ? null : _setEnabled,
                      ),
                      // Switched off rather than merely ignored when the
                      // master is off: three live-looking switches under a
                      // dead master is the screen telling you two contrary
                      // things at once.
                      SwitchListTile.adaptive(
                        title: const Text('Direct messages'),
                        value: _settings.dm,
                        onChanged: _saving || !_settings.enabled
                            ? null
                            : (v) => _apply(_settings.copyWith(dm: v)),
                      ),
                      SwitchListTile.adaptive(
                        title: const Text('Mentions'),
                        value: _settings.mentions,
                        onChanged: _saving || !_settings.enabled
                            ? null
                            : (v) => _apply(_settings.copyWith(mentions: v)),
                      ),
                      SwitchListTile.adaptive(
                        title: const Text('Sounds'),
                        value: _settings.sounds,
                        onChanged: _saving || !_settings.enabled
                            ? null
                            : (v) => _apply(_settings.copyWith(sounds: v)),
                      ),
                    ],
                  ),
                ),
                if (!_settings.enabled)
                  const SettingsFootnote(
                    'Direct messages, mentions and sounds apply once '
                    'notifications are on.',
                  ),
                const SizedBox(height: AppSpacing.l),
                SettingsSection(
                  label: 'Cooldown',
                  child: Column(
                    children: [
                      SwitchListTile.adaptive(
                        title: const Text('Notification cooldown'),
                        subtitle: const Text(
                          'Limit how often notifications can repeat',
                        ),
                        value: _settings.cooldownEnabled,
                        onChanged: _saving || !_settings.enabled
                            ? null
                            : (v) => _apply(
                                _settings.copyWith(cooldownEnabled: v),
                              ),
                      ),
                      if (_settings.cooldownEnabled)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.m,
                            0,
                            AppSpacing.m,
                            AppSpacing.m,
                          ),
                          child: DropdownButtonFormField<int>(
                            initialValue:
                                _cooldownOptions.contains(
                                  _settings.cooldownSeconds,
                                )
                                ? _settings.cooldownSeconds
                                : _cooldownOptions.first,
                            decoration: const InputDecoration(
                              labelText: 'Cooldown length',
                            ),
                            items: [
                              for (final seconds in _cooldownOptions)
                                DropdownMenuItem(
                                  value: seconds,
                                  child: Text(
                                    seconds < 60
                                        ? '$seconds seconds'
                                        : '${seconds ~/ 60} minute(s)',
                                  ),
                                ),
                            ],
                            onChanged: _saving || !_settings.enabled
                                ? null
                                : (value) => _apply(
                                    _settings.copyWith(
                                      cooldownSeconds:
                                          value ?? _settings.cooldownSeconds,
                                    ),
                                  ),
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

/// Shown above the preferences, not below them: whatever these switches say,
/// nothing arrives until this is dealt with.
class _BlockedBanner extends StatelessWidget {
  const _BlockedBanner({
    required this.permanent,
    required this.onRequest,
    required this.onOpenSettings,
  });

  final bool permanent;
  final VoidCallback onRequest;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = theme.colorScheme.error;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: tint.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_off_outlined, size: 20, color: tint),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  'Your phone is blocking notifications',
                  style: theme.textTheme.titleSmall?.copyWith(color: tint),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            permanent
                ? 'Notifications are turned off for Venta in your system '
                      'settings, so nothing below can be delivered. Android '
                      'won\'t ask again from inside the app - turn them back '
                      'on there and come back.'
                : 'Venta hasn\'t been allowed to send notifications yet, so '
                      'nothing below can be delivered.',
            style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
          ),
          const SizedBox(height: AppSpacing.s),
          Row(
            children: [
              FilledButton(
                onPressed: permanent ? onOpenSettings : onRequest,
                child: Text(
                  permanent ? 'Open system settings' : 'Allow notifications',
                ),
              ),
              // Kept alongside the prompt, not only after it fails: the OS
              // dialog is one of two ways this gets fixed and the other one
              // shouldn't need a wrong guess first.
              if (!permanent)
                TextButton(
                  onPressed: onOpenSettings,
                  child: const Text('System settings'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
