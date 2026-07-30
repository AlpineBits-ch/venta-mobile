import 'package:flutter/material.dart';

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
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  static const _cooldownOptions = [5, 10, 15, 30, 60, 120, 300];

  NotificationSettingsDto _settings = const NotificationSettingsDto();
  bool _saving = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
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
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save notification settings.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: RoutePaths.settings),
        title: const Text('Notifications'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.m,
                AppSpacing.m,
                AppSpacing.m,
                AppSpacing.xl,
              ),
              children: [
                SettingsSection(
                  label: 'Deliver',
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Notifications enabled'),
                        value: _settings.enabled,
                        onChanged: _saving
                            ? null
                            : (v) => _apply(_settings.copyWith(enabled: v)),
                      ),
                      SwitchListTile(
                        title: const Text('Direct messages'),
                        value: _settings.dm,
                        onChanged: _saving
                            ? null
                            : (v) => _apply(_settings.copyWith(dm: v)),
                      ),
                      SwitchListTile(
                        title: const Text('Mentions'),
                        value: _settings.mentions,
                        onChanged: _saving
                            ? null
                            : (v) => _apply(_settings.copyWith(mentions: v)),
                      ),
                      SwitchListTile(
                        title: const Text('Sounds'),
                        value: _settings.sounds,
                        onChanged: _saving
                            ? null
                            : (v) => _apply(_settings.copyWith(sounds: v)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                SettingsSection(
                  label: 'Cooldown',
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Notification cooldown'),
                        subtitle: const Text(
                          'Limit how often notifications can repeat',
                        ),
                        value: _settings.cooldownEnabled,
                        onChanged: _saving
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
                            onChanged: _saving
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
