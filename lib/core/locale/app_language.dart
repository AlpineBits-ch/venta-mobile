/// What language this app speaks, chosen by the person using it.
///
/// Device-local and deliberately not synced: a phone and a laptop can sensibly
/// be set to different languages, and a household is not one language either -
/// a flat with a German-speaking and an Italian-speaking flatmate is the normal
/// Swiss case, not the edge one. Syncing this would make one of them wrong on
/// purpose.
///
/// ## Why this exists at all, given nothing is translated yet
///
/// The app's own strings are still English only. This setting is groundwork,
/// and it is worth having before the translations because **it already changes
/// what the server and the model send back**:
///
/// * `Accept-Language` on every request. The product catalog holds a name in
///   de/fr/it/en and picks by that header; with no header the server falls back
///   to German first, so an Italian-speaking flat has been reading German
///   product names with nothing in the app to explain it.
/// * The photo-reading prompt. Swiss packaging carries two or three languages
///   on the same box, so a model told which one to read gives back the words
///   printed on the packet rather than a translation of them.
///
/// Those two have to agree. A model returning German names while the catalog is
/// searched in Italian gives the matcher German text and Italian candidates,
/// and every match abstains. One setting drives both for exactly that reason.
library;

import 'dart:ui';

enum AppLanguage {
  /// Follow the device, falling back to English when the device speaks
  /// something this app does not. The default, and the only option that keeps
  /// working when somebody changes their phone's language.
  system,

  english,
  german,
  italian;

  /// Named in the language itself, which is the convention every OS language
  /// picker follows: somebody who has landed in the wrong language needs to
  /// recognise their own, and "German" is no help to a reader who only reads
  /// German.
  String get label => switch (this) {
    AppLanguage.system => 'Match device',
    AppLanguage.english => 'English',
    AppLanguage.german => 'Deutsch',
    AppLanguage.italian => 'Italiano',
  };

  /// `null` for [system] - there is no fixed code until a device is asked.
  String? get code => switch (this) {
    AppLanguage.system => null,
    AppLanguage.english => 'en',
    AppLanguage.german => 'de',
    AppLanguage.italian => 'it',
  };

  /// The `locale` for `MaterialApp`. Null means "use `supportedLocales` against
  /// the device", which is precisely what [system] wants.
  Locale? get locale {
    final value = code;
    return value == null ? null : Locale(value);
  }

  /// What to call this language *to a model*, in English, because that is the
  /// language the prompt around it is written in.
  ///
  /// Only meaningful once resolved - asking a model to answer in "the device
  /// language" is asking it to guess.
  String get promptName => switch (this) {
    AppLanguage.system => 'English',
    AppLanguage.english => 'English',
    AppLanguage.german => 'German',
    AppLanguage.italian => 'Italian',
  };

  /// Which concrete language [system] means on this device.
  ///
  /// Walks the device's preference list in order rather than looking only at
  /// the first: a phone set to Romansh with German second is a real Swiss
  /// configuration, and it should land on German rather than falling all the
  /// way to English.
  AppLanguage resolve(List<Locale> deviceLocales) {
    if (this != AppLanguage.system) return this;
    for (final locale in deviceLocales) {
      for (final candidate in AppLanguage.values) {
        if (candidate.code != null && candidate.code == locale.languageCode) {
          return candidate;
        }
      }
    }
    return AppLanguage.english;
  }

  static AppLanguage? tryParse(String? raw) {
    for (final language in AppLanguage.values) {
      if (language.name == raw) return language;
    }
    return null;
  }

  /// The locales `MaterialApp` is told it supports.
  ///
  /// French is deliberately absent even though the catalog serves it and
  /// Romandy is a quarter of the country - it was not asked for, and listing a
  /// locale here without the strings behind it would offer French and then
  /// answer in English. Adding it later is this line plus an [AppLanguage]
  /// value; nothing else in the chain hardcodes the set.
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('de'),
    Locale('it'),
  ];
}
