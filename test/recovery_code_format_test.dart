import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// What these cover: contract §C.1.2, the recovery-code format, from the Dart
/// side.
///
/// The alphabet is **wire format** — a code generated on one client has to open
/// the wrapping on the other — and the two clients diverged on it without
/// anything noticing. Mobile appended `*` as a 32nd symbol purely so a 5-bit mask
/// would be uniform; sound reasoning about bias, wrong trade. `*` was not in the
/// desktop client's alphabet, so its validator rejected every code containing one
/// and fell back to the **unnormalised raw input**, deriving a different key
/// silently, during the one operation the code exists for. Roughly one character
/// in 32 was a `*`, so most codes were affected.
///
/// Nothing server-side could have caught it: the server only ever sees the
/// wrapping, never the code.
///
/// The engine enforces this in Rust and is tested there. These pin the two places
/// the rules are restated on the Dart side — the confirmation screen's validator
/// and the checked-in cross-client fixture — because a copy of a rule is exactly
/// the thing that drifts.

/// Mirrors `RECOVERY_CODE_ALPHABET` in `packages/venta_mls/rust/src/mls.rs` and
/// `_alphabet` in `RecoveryCodeScreen`.
const _alphabet = '23456789ABCDEFGHJKMNPQRSTUVWXYZ';

/// The confirmation screen's normalisation, restated. Kept in step with
/// `RecoveryCodeScreen._normalize`.
String _normalize(String value) =>
    value.replaceAll(RegExp(r'[\s-]'), '').toUpperCase();

void main() {
  group('the shared alphabet', () {
    test('is exactly 31 symbols and holds no ambiguous glyph', () {
      expect(_alphabet.length, 31);
      expect(_alphabet.split('').toSet().length, 31, reason: 'no duplicates');

      // The pairs people transcribe wrongly off paper.
      for (final ambiguous in ['I', 'L', 'O', '0', '1']) {
        expect(
          _alphabet.contains(ambiguous),
          isFalse,
          reason: '$ambiguous is misread for another character',
        );
      }
    });

    test('holds no punctuation, and specifically no asterisk', () {
      // The regression guard. `*` is punctuation in a string a human copies off
      // paper under stress, and it is not in the other client's alphabet.
      expect(_alphabet.contains('*'), isFalse);
      expect(
        RegExp(r'^[0-9A-Z]+$').hasMatch(_alphabet),
        isTrue,
        reason: 'alphanumeric only — anything else is a transcription hazard',
      );
    });
  });

  group('the checked-in cross-client fixture', () {
    late Map<String, dynamic> fixture;

    setUpAll(() {
      final file = File('testdata/mls-golden/v1/recovery-code.json');
      expect(
        file.existsSync(),
        isTrue,
        reason: 'the fixture the desktop client consumes must be checked in',
      );
      fixture = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    });

    test('declares the shared alphabet', () {
      expect(fixture['alphabet'], _alphabet);
      expect(fixture['producedBy'], 'venta-mobile');
    });

    test('is a code the other client would accept', () {
      final code = fixture['recoveryCode'] as String;
      final normalized = fixture['normalized'] as String;

      expect(normalized.length, 32);
      expect(_normalize(code), normalized);

      for (final c in normalized.split('')) {
        expect(
          _alphabet.contains(c),
          isTrue,
          reason:
              '"$c" would be rejected by the other client, which then '
              'silently derives a different key',
        );
      }

      // Eight groups of four, dash-separated.
      final groups = code.split('-');
      expect(groups.length, 8);
      expect(groups.every((g) => g.length == 4), isTrue);
    });

    test('carries the wrapping and the key it opens to', () {
      // Without both halves the fixture proves nothing — the whole point is that
      // the other client can derive from the code and land on this key.
      expect(fixture['masterKey'], isA<String>());
      final wrapping = fixture['recoveryCodeWrapping'] as Map<String, dynamic>;
      expect(wrapping['cipherText'], isA<String>());
      expect(wrapping['salt'], isA<String>());
      expect(wrapping['iv'], isA<String>());

      // Master-key parameters, not the backup envelope's. p is 1 here and 4
      // there; they must not be aligned.
      expect(wrapping['argon2Memory'], 65536);
      expect(wrapping['argon2Iterations'], 3);
      expect(wrapping['argon2Parallelism'], 1);
    });
  });

  group('the confirmation screen validator', () {
    test('accepts a correct code however it was typed', () {
      const shown = 'PVK8-XHXZ-TXTE-ZJ9V-CTQK-QQAN-R7RX-AGJD';
      const expected = 'PVK8XHXZTXTEZJ9VCTQKQQANR7RXAGJD';

      for (final variant in [
        shown,
        shown.toLowerCase(),
        shown.replaceAll('-', ''),
        shown.replaceAll('-', ' '),
        '  ${shown.toLowerCase()}  ',
      ]) {
        expect(_normalize(variant), expected, reason: variant);
      }
    });

    test(
      'surfaces the specific stray character rather than "does not match"',
      () {
        // Naming the character is the difference between a fixable typo and giving
        // up. `0` for `O` and `1` for `I` are the ones people actually hit.
        const typed = 'PVK8-XHXZ-TXTE-ZJ9V-CTQK-QQAN-R7RX-AGJ0';
        final stray = _normalize(
          typed,
        ).split('').where((c) => !_alphabet.contains(c)).toSet();

        expect(stray, {'0'});
      },
    );
  });
}
