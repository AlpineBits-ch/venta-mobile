import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:venta_mobile/core/push/household_push_payload.dart';
import 'package:venta_mobile/core/push/household_strings.dart';

/// What these cover: the fact that one table of notification copy exists in
/// three places and has to stay one table.
///
/// A household push carries a real notification block whose `title_loc_key` /
/// `loc-key` the OS resolves against the app bundle - `res/values*/strings.xml`
/// on Android, `*.lproj/Localizable.strings` on iOS - because that is the only
/// mechanism that still draws a notification when the app is dead. The Dart
/// table exists for the one case the OS skips: a push that arrives while the app
/// is in the foreground is handed to `onMessage` and displayed by nobody, so the
/// app draws it, and it must produce the same sentence.
///
/// None of the three can see the others, and none of the mismatches has a
/// symptom short of "the notification reads differently depending on whether the
/// app happened to be open". So they are compared here.
///
/// The other half of the contract lives server-side in `HouseholdLocKeys.All`,
/// which is asserted against the keys actually sent. Between the two, a key can
/// go missing at neither end without a test failing.
void main() {
  // The declared placeholder dialects. Android and Dart share `%1$s` so their
  // tables can be compared as text; iOS spells the same argument `%1$@`.
  final androidPlaceholder = RegExp(r'%(\d+)\$s');
  final iosPlaceholder = RegExp(r'%(\d+)\$@');

  Map<String, String> parseAndroid(String path) {
    final xml = File(path).readAsStringSync();
    final entries = RegExp(
      r'<string name="([^"]+)">(.*?)</string>',
      dotAll: true,
    ).allMatches(xml);

    return {
      for (final m in entries)
        m.group(1)!: m
            .group(2)!
            // Android escapes an apostrophe inside a string resource; the same
            // character is bare in Dart and iOS.
            .replaceAll(r"\'", "'")
            .replaceAll('&amp;', '&')
            .replaceAll('&lt;', '<')
            .replaceAll('&gt;', '>'),
    };
  }

  final iosEntry = RegExp(r'"([^"]+)"\s*=\s*"((?:[^"\\]|\\.)*)"\s*;');

  /// Whatever is left of a `.strings` file once its comments and its entries
  /// are removed. Anything but whitespace means the file is not a valid
  /// property list - see the test below.
  String iosResidue(String path) {
    final text = File(path).readAsStringSync();
    // Non-greedy, so this stops at the *first* `*/` exactly as the plist parser
    // does. That is the point: a comment closed early leaves its remaining prose
    // here rather than being quietly swallowed.
    final body = text.replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '');
    return body.replaceAll(iosEntry, '');
  }

  Map<String, String> parseIos(String path) {
    final text = File(path).readAsStringSync();
    final body = text.replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '');

    return {
      for (final m in iosEntry.allMatches(body))
        m.group(1)!: m.group(2)!.replaceAll(r'\"', '"'),
    };
  }

  final android = {
    'en': parseAndroid('android/app/src/main/res/values/strings.xml'),
    'de': parseAndroid('android/app/src/main/res/values-de/strings.xml'),
  };

  final ios = {
    'en': parseIos('ios/Runner/en.lproj/Localizable.strings'),
    'de': parseIos('ios/Runner/de.lproj/Localizable.strings'),
  };

  /// A `.strings` file is parsed as a property list, and it does not degrade:
  /// anything the parser cannot account for fails the whole file, and the iOS
  /// build fails during archive with "Couldn't parse property list because the
  /// input data was in an invalid format" - a message that names the file and
  /// says nothing about which line.
  ///
  /// The way to produce one is to write `*/` inside a comment. `res/values*/`
  /// closes the comment three lines early, and every sentence after it becomes
  /// body. Nothing in the file looks wrong, and the previous version of this
  /// test passed straight through it: it stripped comments, matched the entries
  /// it recognised, and never asked what was left over.
  ///
  /// So it asks now.
  group('the iOS files are valid property lists', () {
    for (final language in const ['en', 'de']) {
      test('$language.lproj has nothing outside a comment or an entry', () {
        final residue = iosResidue(
          'ios/Runner/$language.lproj/Localizable.strings',
        );

        expect(
          residue.trim(),
          isEmpty,
          reason:
              'left over after removing comments and entries, which means the '
              'plist parser will choke on it. The usual cause is a `*/` inside '
              'a comment closing it early.',
        );
      });
    }
  });

  group('every language carries every key', () {
    test('the Dart table agrees with itself across languages', () {
      for (final entry in HouseholdStrings.byLanguage.entries) {
        expect(
          entry.value.keys.toSet(),
          HouseholdStrings.keys,
          reason:
              '${entry.key} is missing keys, or has ones English does not - a '
              'key translated into one language and not declared in English is '
              'unreachable',
        );
      }
    });

    test('Android carries exactly the Dart keys', () {
      for (final entry in android.entries) {
        expect(
          entry.value.keys.toSet(),
          HouseholdStrings.keys,
          reason:
              'values${entry.key == 'en' ? '' : '-${entry.key}'}/strings.xml',
        );
      }
    });

    test('iOS carries exactly the Dart keys', () {
      for (final entry in ios.entries) {
        expect(
          entry.value.keys.toSet(),
          HouseholdStrings.keys,
          reason: 'ios/Runner/${entry.key}.lproj/Localizable.strings',
        );
      }
    });

    test('Android and Dart ship the same languages', () {
      expect(android.keys.toSet(), HouseholdStrings.byLanguage.keys.toSet());
      expect(ios.keys.toSet(), HouseholdStrings.byLanguage.keys.toSet());
    });
  });

  group('the three tables say the same thing', () {
    test('Dart and Android are character-for-character identical', () {
      for (final language in HouseholdStrings.byLanguage.keys) {
        final dart = HouseholdStrings.byLanguage[language]!;
        for (final key in HouseholdStrings.keys) {
          expect(
            android[language]![key],
            dart[key],
            reason: '$language/$key differs between strings.xml and Dart',
          );
        }
      }
    });

    /// iOS differs only in the placeholder spelling, so normalising that is
    /// enough to compare the sentences.
    test('iOS matches once %1\$@ is read as %1\$s', () {
      for (final language in HouseholdStrings.byLanguage.keys) {
        final dart = HouseholdStrings.byLanguage[language]!;
        for (final key in HouseholdStrings.keys) {
          final normalized = ios[language]![key]!.replaceAllMapped(
            iosPlaceholder,
            (m) => '%${m.group(1)}\$s',
          );

          expect(
            normalized,
            dart[key],
            reason:
                '$language/$key differs between Localizable.strings and Dart',
          );
        }
      }
    });

    /// A translation that drops an argument leaves the server's value nowhere,
    /// and one that invents an index renders a literal `%3$s` on a lock screen.
    test('every language uses the same argument indices for a key', () {
      Set<String> indices(String template, RegExp pattern) =>
          pattern.allMatches(template).map((m) => m.group(1)!).toSet();

      for (final key in HouseholdStrings.keys) {
        final expected = indices(
          HouseholdStrings.byLanguage['en']![key]!,
          androidPlaceholder,
        );

        for (final language in HouseholdStrings.byLanguage.keys) {
          expect(
            indices(
              HouseholdStrings.byLanguage[language]![key]!,
              androidPlaceholder,
            ),
            expected,
            reason: 'Dart $language/$key',
          );
          expect(
            indices(android[language]![key]!, androidPlaceholder),
            expected,
            reason: 'Android $language/$key',
          );
          expect(
            indices(ios[language]![key]!, iosPlaceholder),
            expected,
            reason: 'iOS $language/$key',
          );
        }
      }
    });
  });

  group('resolve', () {
    test('substitutes positional arguments', () {
      expect(
        HouseholdStrings.resolve('household_pantry_low_listed_body', [
          'Shopping',
        ], language: 'en'),
        "Running low, so it's gone on Shopping.",
      );
    });

    test('uses the reader language when it has one', () {
      expect(
        HouseholdStrings.resolve(
          'household_pantry_low_body',
          const [],
          language: 'de',
        ),
        'Zu Hause geht es zur Neige.',
      );
    });

    test('falls back to English for an untranslated language', () {
      expect(
        HouseholdStrings.resolve(
          'household_pantry_low_body',
          const [],
          language: 'fr',
        ),
        'Running low at home.',
      );
    });

    /// The normal state of a mobile release train: the server ships a new alert
    /// kind before this build knows the key. Null is what makes the caller use
    /// the server's English rather than showing nothing.
    test('returns null for a key this build has never heard of', () {
      expect(
        HouseholdStrings.resolve('household_something_new', const []),
        isNull,
      );
    });

    test('returns null when there is no key, which is user content', () {
      expect(HouseholdStrings.resolve(null, const []), isNull);
      expect(HouseholdStrings.resolve('', const []), isNull);
    });

    /// A visible `%2$s` is a bug report; a sentence with a silent gap in it is a
    /// mystery.
    test('leaves a placeholder with no argument behind it alone', () {
      expect(
        HouseholdStrings.format(r'%1$s and %2$s', ['Milk']),
        r'Milk and %2$s',
      );
    });

    test('substitutes out of order when the translation reorders', () {
      expect(HouseholdStrings.format(r'%2$s vor %1$s', ['a', 'b']), 'b vor a');
    });
  });

  group('payload', () {
    Map<String, dynamic> data({
      String? bodyLocKey,
      String? bodyLocArgs,
      String body = 'Running low, so it\'s gone on Shopping.',
    }) => {
      'type': 'household',
      'kind': 'pantry.low',
      'guildId': 'guild-1',
      'channelId': 'chan-pantry',
      'targetId': 'pitm-1',
      'title': 'Milk',
      'body': body,
      ?'bodyLocKey': bodyLocKey,
      ?'bodyLocArgs': bodyLocArgs,
    };

    test('parses a JSON argument list', () {
      final payload = HouseholdPushPayload.tryParse(
        data(
          bodyLocKey: 'household_pantry_low_listed_body',
          bodyLocArgs: '["Shopping"]',
        ),
      )!;

      expect(payload.bodyLocKey, 'household_pantry_low_listed_body');
      expect(payload.bodyLocArgs, ['Shopping']);
    });

    /// An older server, or a build that never declared `push.loc.v1` and so is
    /// sent no keys at all. Neither may lose the notification.
    test('a payload with no keys still renders the English', () {
      final payload = HouseholdPushPayload.tryParse(data())!;

      expect(payload.bodyLocKey, isNull);
      expect(payload.bodyLocArgs, isEmpty);
      expect(payload.localizedBody, "Running low, so it's gone on Shopping.");
      expect(payload.localizedTitle, 'Milk');
    });

    /// This runs in a background isolate where a throw is a notification that
    /// silently never arrives, so a malformed list costs the translation and
    /// nothing else.
    test(
      'unparseable arguments fall back to the English rather than throwing',
      () {
        final payload = HouseholdPushPayload.tryParse(
          data(
            bodyLocKey: 'household_pantry_low_listed_body',
            bodyLocArgs: 'not json',
          ),
        )!;

        expect(payload.bodyLocArgs, isEmpty);
        // The key still resolves; its placeholder is simply left visible rather
        // than being filled with a value nobody sent.
        expect(payload.localizedBody, contains('Running low'));
      },
    );

    test('a title with no key is left as the user typed it', () {
      final payload = HouseholdPushPayload.tryParse(data())!;
      expect(payload.titleLocKey, isNull);
      expect(payload.localizedTitle, 'Milk');
    });
  });
}
