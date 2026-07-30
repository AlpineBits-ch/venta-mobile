import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/settings_tiles.dart';

String _themeLabel(ThemeMode mode) => switch (mode) {
  ThemeMode.system => 'Match system',
  ThemeMode.light => 'Light',
  ThemeMode.dark => 'Dark',
};

String _themeBlurb(ThemeMode mode) => switch (mode) {
  ThemeMode.system => 'Follows your device setting',
  ThemeMode.light => 'Always light',
  ThemeMode.dark => 'Always dark',
};

/// App-wide look: theme mode today. Per-profile accent and font are *profile*
/// data (other people see them), so they live in `EditProfileScreen` instead.
class AppearanceSettingsScreen extends StatelessWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: RoutePaths.settings),
        title: const Text('Appearance'),
      ),
      body: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, mode) => ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.m,
            AppSpacing.m,
            AppSpacing.m,
            AppSpacing.xl,
          ),
          children: [
            SettingsSection(
              label: 'Theme',
              children: [
                for (final option in ThemeMode.values)
                  SettingsRow(
                    icon: switch (option) {
                      ThemeMode.system => Icons.brightness_auto_outlined,
                      ThemeMode.light => Icons.light_mode_outlined,
                      ThemeMode.dark => Icons.dark_mode_outlined,
                    },
                    title: _themeLabel(option),
                    subtitle: _themeBlurb(option),
                    showChevron: false,
                    trailing: option == mode
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () =>
                        context.read<ThemeCubit>().setThemeMode(option),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
