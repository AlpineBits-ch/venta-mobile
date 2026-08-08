import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/locale/app_language.dart';
import '../../../../core/locale/locale_cubit.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/settings_tiles.dart';

/// The second line on a row, in English, because every row's *title* is already
/// in the language it names.
///
/// "Deutsch" tells a German speaker which row is theirs; it tells nobody else
/// anything, and this page is currently read by people whose app is otherwise
/// in English. The pair is how OS pickers do it and it costs a line.
String _languageBlurb(AppLanguage language) => switch (language) {
  AppLanguage.system => 'Follows your device setting',
  AppLanguage.english => 'English',
  AppLanguage.german => 'German',
  AppLanguage.italian => 'Italian',
};

/// Which language this app asks the world for.
///
/// A sibling of `AppearanceSettingsScreen` in every sense - a device-local
/// preference, one section of radio-ish rows, no server call, no save button -
/// and deliberately built to look like one, because they sit next to each other
/// in the settings index and a picker that behaves differently from the one
/// above it reads as a different kind of decision than it is.
///
/// ## The footnote is the point of the page
///
/// This setting does not translate the app, and it will not until the strings
/// are done. A language picker that visibly does nothing is a bug report
/// waiting to be filed - so the footnote says plainly what it does change
/// today, which is not nothing: the `Accept-Language` header that decides which
/// of a product's four catalog names comes back, the prompt that tells a model
/// which language to read off a packet, and Flutter's own dialogs. Take that
/// paragraph out and the page starts costing support time.
class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: RoutePaths.settings),
        title: const Text('Language'),
      ),
      body: BlocBuilder<LocaleCubit, AppLanguage>(
        builder: (context, selected) {
          // "Match device" is the default and, spelled on its own, says nothing
          // about what the app is actually doing. Resolving it here means the
          // row a user has never touched can still answer the question they
          // came to this page with.
          final resolved = context.read<LocaleCubit>().effective;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.m,
              AppSpacing.m,
              AppSpacing.m,
              AppSpacing.xl,
            ),
            children: [
              SettingsSection(
                label: 'Language',
                children: [
                  for (final option in AppLanguage.values)
                    SettingsRow(
                      icon: option == AppLanguage.system
                          ? Icons.smartphone_outlined
                          : Icons.translate,
                      // Only on the row that is in force: on an unselected
                      // "Match device" the resolved name would read as a
                      // second option rather than as what is happening.
                      title: option == AppLanguage.system && option == selected
                          ? '${option.label} · ${resolved.label}'
                          : option.label,
                      subtitle: _languageBlurb(option),
                      showChevron: false,
                      trailing: option == selected
                          ? Icon(
                              Icons.check,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      onTap: () =>
                          context.read<LocaleCubit>().setLanguage(option),
                    ),
                ],
              ),
              const SettingsFootnote(
                'The app\'s own text is English for now, and changing this will '
                'not translate it. What it does change is the language things '
                'arrive in: product names from the catalogue, the names read '
                'off a photographed packet, and the dialogs the system draws '
                'for us - date pickers, the text selection menu. When our own '
                'screens are translated, this is the setting they will follow.',
              ),
            ],
          );
        },
      ),
    );
  }
}
