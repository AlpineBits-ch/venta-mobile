import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:venta_mobile/core/push/voice_ring_push_payload.dart';
import 'package:venta_mobile/core/push/voice_strings.dart';

/// What these cover: the fact that one table of voice-ring notification copy
/// exists in three places and has to stay one table.
///
/// A ring push carries a real notification block whose `body_loc_key` /
/// `loc-key` the OS resolves against the app bundle - `res/values*/strings.xml`
/// on Android, `*.lproj/Localizable.strings` on iOS - because that is the only
/// mechanism that still draws a notification when the app is dead. The Dart
/// table exists for the one case the OS skips: a push arriving while the app is
/// in the foreground is handed to `onMessage` and displayed by nobody, so the
/// app draws it, and it must produce the same sentence.
///
/// The other half of the contract lives server-side in `VoiceLocKeys.All`.
///
/// A key the bundle does not contain does **not** fall back to the literal text
/// the same payload carries: Android drops the text, iOS shows the key name. So
/// the resources and the `push.loc.v1` capability ship in one build, and neither
/// is removed without the other.
///
/// Deliberately separate from `household_strings_test.dart` rather than folded
/// into it. The two features ship on different releases, and a build that
/// carries one table and not the other must be able to say so - which it can
/// only do if the two are asserted independently.
void main() {
  final androidPlaceholder = RegExp(r'%(\d+)\$s');
  final iosPlaceholder = RegExp(r'%(\d+)\$@');

  /// Both platform files carry the household copy too. Scoping by prefix is
  /// what keeps this test and the household one from failing each other every
  /// time either feature gains a key.
  bool isVoice(String key) => key.startsWith('voice_ring_');

  Map<String, String> onlyVoice(Map<String, String> table) => {
    for (final entry in table.entries)
      if (isVoice(entry.key)) entry.key: entry.value,
  };

  Map<String, String> parseAndroid(String path) {
    final xml = File(path).readAsStringSync();
    final entries = RegExp(
      r'<string name="([^"]+)">(.*?)</string>',
      dotAll: true,
    ).allMatches(xml);

    return onlyVoice({
      for (final m in entries)
        m.group(1)!: m
            .group(2)!
            // Android escapes an apostrophe inside a string resource; the same
            // character is bare in Dart and iOS.
            .replaceAll(r"\'", "'")
            .replaceAll('&amp;', '&')
            .replaceAll('&lt;', '<')
            .replaceAll('&gt;', '>'),
    });
  }

  final iosEntry = RegExp(r'"([^"]+)"\s*=\s*"((?:[^"\\]|\\.)*)"\s*;');

  Map<String, String> parseIos(String path) {
    final text = File(path).readAsStringSync();
    final body = text.replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '');

    return onlyVoice({
      for (final m in iosEntry.allMatches(body))
        m.group(1)!: m.group(2)!.replaceAll(r'\"', '"'),
    });
  }

  final android = {
    'en': parseAndroid('android/app/src/main/res/values/strings.xml'),
    'de': parseAndroid('android/app/src/main/res/values-de/strings.xml'),
  };

  final ios = {
    'en': parseIos('ios/Runner/en.lproj/Localizable.strings'),
    'de': parseIos('ios/Runner/de.lproj/Localizable.strings'),
  };

  group('every language carries every key', () {
    test('the Dart table agrees with itself across languages', () {
      for (final entry in VoiceStrings.byLanguage.entries) {
        expect(
          entry.value.keys.toSet(),
          VoiceStrings.keys,
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
          VoiceStrings.keys,
          reason:
              'values${entry.key == 'en' ? '' : '-${entry.key}'}/strings.xml',
        );
      }
    });

    test('iOS carries exactly the Dart keys', () {
      for (final entry in ios.entries) {
        expect(
          entry.value.keys.toSet(),
          VoiceStrings.keys,
          reason: 'ios/Runner/${entry.key}.lproj/Localizable.strings',
        );
      }
    });

    test('Android and iOS ship the same languages as Dart', () {
      expect(android.keys.toSet(), VoiceStrings.byLanguage.keys.toSet());
      expect(ios.keys.toSet(), VoiceStrings.byLanguage.keys.toSet());
    });

    /// The exact three the server is allowed to send, named here so adding one
    /// to `VoiceLocKeys.cs` without adding it to any bundle fails on this side
    /// too.
    test('the set is exactly the three keys the contract names', () {
      expect(VoiceStrings.keys, {
        'voice_ring_invite_body',
        'voice_ring_hidden_title',
        'voice_ring_hidden_body',
      });
    });
  });

  group('the three tables say the same thing', () {
    test('Dart and Android are character-for-character identical', () {
      for (final language in VoiceStrings.byLanguage.keys) {
        final dart = VoiceStrings.byLanguage[language]!;
        for (final key in VoiceStrings.keys) {
          expect(
            android[language]![key],
            dart[key],
            reason: '$language/$key differs between strings.xml and Dart',
          );
        }
      }
    });

    test('iOS matches once %1\$@ is read as %1\$s', () {
      for (final language in VoiceStrings.byLanguage.keys) {
        final dart = VoiceStrings.byLanguage[language]!;
        for (final key in VoiceStrings.keys) {
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

    /// A translation that drops an argument leaves the channel name nowhere,
    /// and one that invents an index renders a literal `%2$s` on a lock screen.
    test('every language uses the same argument indices for a key', () {
      Set<String> indices(String template, RegExp pattern) =>
          pattern.allMatches(template).map((m) => m.group(1)!).toSet();

      for (final key in VoiceStrings.keys) {
        final expected = indices(
          VoiceStrings.byLanguage['en']![key]!,
          androidPlaceholder,
        );

        for (final language in VoiceStrings.byLanguage.keys) {
          expect(
            indices(VoiceStrings.byLanguage[language]![key]!, androidPlaceholder),
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

    /// The argument order is part of the contract: the server supplies only the
    /// ordered values, so the body key taking exactly one - the channel name -
    /// is what makes `bodyLocArgs: ["General"]` mean anything.
    test('the invite body takes exactly one argument, the channel name', () {
      expect(
        androidPlaceholder
            .allMatches(VoiceStrings.byLanguage['en']!['voice_ring_invite_body']!)
            .map((m) => m.group(1))
            .toSet(),
        {'1'},
      );
    });

    /// Hiding push content is not satisfied by hiding only the half of the
    /// notification that happens to be a sentence. Neither hidden string may
    /// take an argument at all, because there is nothing it would be allowed to
    /// carry.
    test('the hidden pair name nobody and nothing', () {
      for (final key in const [
        'voice_ring_hidden_title',
        'voice_ring_hidden_body',
      ]) {
        for (final language in VoiceStrings.byLanguage.keys) {
          expect(
            androidPlaceholder.hasMatch(VoiceStrings.byLanguage[language]![key]!),
            isFalse,
            reason: '$language/$key must take no arguments',
          );
        }
      }
    });
  });

  group('resolve', () {
    test('substitutes the channel name', () {
      expect(
        VoiceStrings.resolve('voice_ring_invite_body', [
          'General',
        ], language: 'en'),
        'Asked you to join General.',
      );
    });

    test('uses the reader language when it has one', () {
      expect(
        VoiceStrings.resolve(
          'voice_ring_hidden_title',
          const [],
          language: 'de',
        ),
        'Sprach-Einladung',
      );
    });

    test('falls back to English for an untranslated language', () {
      expect(
        VoiceStrings.resolve(
          'voice_ring_hidden_title',
          const [],
          language: 'fr',
        ),
        'Voice invite',
      );
    });

    /// The normal state of a mobile release train: the server ships a key
    /// before this build knows it. Null is what makes the caller use the
    /// server's English rather than showing nothing.
    test('returns null for a key this build has never heard of', () {
      expect(VoiceStrings.resolve('voice_ring_something_new', const []), isNull);
    });

    test('returns null when there is no key', () {
      expect(VoiceStrings.resolve(null, const []), isNull);
      expect(VoiceStrings.resolve('', const []), isNull);
    });

    /// A visible `%1$s` is a bug report; a sentence with a silent gap in it is
    /// a mystery.
    test('leaves a placeholder with no argument behind it alone', () {
      expect(
        VoiceStrings.resolve('voice_ring_invite_body', const [], language: 'en'),
        r'Asked you to join %1$s.',
      );
    });
  });

  group('payload', () {
    Map<String, dynamic> invite({
      String? bodyLocKey,
      String? bodyLocArgs,
      String expiresInSeconds = '60',
      String hidden = '0',
    }) => <String, dynamic>{
      'type': 'voice_ring',
      'ringSubtype': 'invite',
      'ringId': 'ring_9f2c',
      'guildId': 'guild_1',
      'channelId': 'chan_1',
      'inviterId': 'user_them',
      'recipientUserId': 'user_me',
      'hidden': hidden,
      'expiresInSeconds': expiresInSeconds,
      'title': 'Ada',
      'body': 'Asked you to join General.',
      if (bodyLocKey != null) 'bodyLocKey': bodyLocKey,
      if (bodyLocArgs != null) 'bodyLocArgs': bodyLocArgs,
    };

    test('parses an invite with its localization key', () {
      final payload = VoiceRingPushPayload.tryParse(
        invite(
          bodyLocKey: 'voice_ring_invite_body',
          bodyLocArgs: '["General"]',
        ),
      )!;

      expect(payload.ringId, 'ring_9f2c');
      expect(payload.isCancel, isFalse);
      expect(payload.bodyLocArgs, ['General']);
      expect(payload.expiresInSeconds, 60);
      expect(payload.notificationTag, 'voiceRing:ring_9f2c');
    });

    /// An older server, or a build that never declared `push.loc.v1` and so is
    /// sent no keys at all. Neither may lose the notification.
    test('a payload with no keys still renders the English', () {
      final payload = VoiceRingPushPayload.tryParse(invite())!;

      expect(payload.bodyLocKey, isNull);
      expect(payload.localizedBody, 'Asked you to join General.');
      expect(payload.localizedTitle, 'Ada');
    });

    /// This runs in a background isolate where a throw is a notification that
    /// silently never arrives.
    test('unparseable arguments cost the translation and nothing else', () {
      final payload = VoiceRingPushPayload.tryParse(
        invite(bodyLocKey: 'voice_ring_invite_body', bodyLocArgs: 'not json'),
      )!;

      expect(payload.bodyLocArgs, isEmpty);
      expect(payload.localizedBody, contains('Asked you to join'));
    });

    test('hidden content is carried as a flag, not re-derived', () {
      final payload = VoiceRingPushPayload.tryParse(invite(hidden: '1'))!;
      expect(payload.hidden, isTrue);
    });

    /// `expiresInSeconds` is as of publication. A push that sat in a queue
    /// longer than the ring's whole life must be dropped rather than drawn -
    /// the invitation is already over and its resolution has already gone out.
    test('a push that outlived its ring is stale', () {
      expect(
        VoiceRingPushPayload.tryParse(invite(expiresInSeconds: '0'))!.isStale,
        isTrue,
      );
      expect(
        VoiceRingPushPayload.tryParse(invite(expiresInSeconds: '60'))!.isStale,
        isFalse,
      );
    });

    test('a cancel is never stale - taking a card down is always worth it', () {
      final cancel = VoiceRingPushPayload.tryParse({
        'type': 'voice_ring',
        'ringSubtype': 'cancel',
        'ringId': 'ring_9f2c',
        'cancelReason': 'Accepted',
        'excludeDeviceId': 'device_abc',
      })!;

      expect(cancel.isCancel, isTrue);
      expect(cancel.isStale, isFalse);
    });

    /// The device that answered already knows. The server addresses it anyway,
    /// because a push token only knows which device it belongs to if it was
    /// registered after the device-identity consolidation - and filtering
    /// server-side spared whole accounts.
    test('a cancel naming this device is ignored by this device', () {
      final cancel = VoiceRingPushPayload.tryParse({
        'type': 'voice_ring',
        'ringSubtype': 'cancel',
        'ringId': 'ring_9f2c',
        'excludeDeviceId': 'device_abc',
      })!;

      expect(cancel.isSelfCancel('device_abc'), isTrue);
      expect(cancel.isSelfCancel('device_other'), isFalse);
    });

    /// `excludeDeviceId` may be empty, and a device with no id of its own must
    /// not match that by accident - it would swallow every cancel it got.
    test('an empty exclusion matches nobody', () {
      final cancel = VoiceRingPushPayload.tryParse({
        'type': 'voice_ring',
        'ringSubtype': 'cancel',
        'ringId': 'ring_9f2c',
        'excludeDeviceId': '',
      })!;

      expect(cancel.isSelfCancel(''), isFalse);
      expect(cancel.isSelfCancel(null), isFalse);
      expect(cancel.isSelfCancel('device_abc'), isFalse);
    });

    test('a call push is not a ring, and a ring is not a call push', () {
      expect(
        VoiceRingPushPayload.tryParse({'type': 'call', 'callId': 'c1'}),
        isNull,
      );
      expect(
        VoiceRingPushPayload.tryParse({'type': 'household', 'kind': 'x'}),
        isNull,
      );
    });

    test('a ring with no id is not a ring', () {
      expect(
        VoiceRingPushPayload.tryParse({'type': 'voice_ring'}),
        isNull,
      );
    });
  });
}
