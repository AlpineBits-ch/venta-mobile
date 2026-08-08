import 'package:flutter_test/flutter_test.dart';
import 'package:venta_mobile/core/format/phone_number.dart';
import 'package:venta_mobile/features/household/data/models/payment_handles_dto.dart';

/// What these cover: the two places a phone number can go wrong before it ever
/// reaches a person.
///
/// The first is the format check, which is a duplicate of
/// `Identity.Application/Services/E164PhoneNumber.Normalize` and is only worth
/// having if it agrees with it exactly - a client that accepts something the
/// server refuses turns a typo into a round trip, and one that refuses
/// something the server accepts locks somebody out of a field with no
/// explanation. So the cases below are the server's own test cases plus the
/// ones the wording has to handle.
///
/// The second is the payment-handle payload, where the thing being asserted is
/// mostly what is *absent*: a member who opted out and a member with no number
/// arrive identically, and the sealed `members` array must be ignored rather
/// than half-parsed.
void main() {
  group('normalizePhoneNumber', () {
    test('keeps a number that is already E.164', () {
      expect(normalizePhoneNumber('+41791234567'), '+41791234567');
    });

    test('takes out the separators people actually type', () {
      expect(normalizePhoneNumber('+41 79 123 45 67'), '+41791234567');
      expect(normalizePhoneNumber('+41-79-123-45-67'), '+41791234567');
      expect(normalizePhoneNumber('+41.79.123.45.67'), '+41791234567');
      expect(normalizePhoneNumber('+41 (79) 123 45 67'), '+41791234567');
    });

    test('takes out a non-breaking space, which contact apps emit', () {
      expect(
        normalizePhoneNumber('+41\u00A079\u00A0123\u00A045\u00A067'),
        '+41791234567',
      );
    });

    test('trims the whitespace a paste brings with it', () {
      expect(normalizePhoneNumber('  +41791234567 \n'), '+41791234567');
    });

    /// The whole reason this file exists. `0041…` is a perfectly good number
    /// in most of Europe and means nothing in North America, so it is refused
    /// rather than rewritten.
    test('refuses a 00 prefix rather than turning it into a +', () {
      expect(normalizePhoneNumber('0041791234567'), isNull);
      expect(normalizePhoneNumber('0041 79 123 45 67'), isNull);
    });

    test('refuses a national number with no country code', () {
      expect(normalizePhoneNumber('0791234567'), isNull);
      expect(normalizePhoneNumber('791234567'), isNull);
    });

    test('refuses a leading zero after the +', () {
      expect(normalizePhoneNumber('+0791234567'), isNull);
    });

    test('refuses anything that is not a digit or a separator', () {
      expect(normalizePhoneNumber('+41 79 CALL ME'), isNull);
      expect(normalizePhoneNumber('+41791234567;ext=9'), isNull);
      expect(normalizePhoneNumber('++41791234567'), isNull);
    });

    test('refuses empty and whitespace', () {
      expect(normalizePhoneNumber(''), isNull);
      expect(normalizePhoneNumber('   '), isNull);
      expect(normalizePhoneNumber('+'), isNull);
    });

    /// Both bounds are the server's, checked at the edges rather than in the
    /// middle - an off-by-one here is a number somebody cannot enter.
    test('holds the 6 and 15 digit bounds exactly', () {
      expect(normalizePhoneNumber('+12345'), isNull);
      expect(normalizePhoneNumber('+123456'), '+123456');
      expect(normalizePhoneNumber('+123456789012345'), '+123456789012345');
      expect(normalizePhoneNumber('+1234567890123456'), isNull);
    });

    test('counts digits, not characters, against those bounds', () {
      // Fifteen digits with separators all through it is still fifteen digits.
      expect(
        normalizePhoneNumber('+1 (234) 567-890.123 45'),
        '+123456789012345',
      );
    });
  });

  group('phoneNumberProblem', () {
    test('says nothing about an empty field', () {
      expect(phoneNumberProblem(''), isNull);
      expect(phoneNumberProblem('   '), isNull);
    });

    test('says nothing about a number that will be accepted', () {
      expect(phoneNumberProblem('+41 79 123 45 67'), isNull);
    });

    test('explains the 00 case as a refusal to guess', () {
      final problem = phoneNumberProblem('0041 79 123 45 67');
      expect(problem, isNotNull);
      expect(problem, contains('00'));
      expect(problem, contains('+'));
    });

    test('asks for the country code when there is no +', () {
      expect(phoneNumberProblem('079 123 45 67'), contains('country code'));
    });

    test('names the leading zero rather than the whole number', () {
      expect(phoneNumberProblem('+079 123 45 67'), contains('Drop the 0'));
    });

    test('names the stray character rather than the length', () {
      expect(phoneNumberProblem('+41 79 CALL ME'), contains('digits only'));
    });

    test('counts the digits when there are too few or too many', () {
      expect(phoneNumberProblem('+1234'), contains('4 digits'));
      expect(phoneNumberProblem('+1234567890123456'), contains('16 digits'));
    });

    /// Nothing checks this number, so nothing may imply that anything did.
    /// This is the one assertion in the file that is about copy rather than
    /// behaviour, and it is here because the words are the feature.
    test('never claims the number has been checked', () {
      const forbidden = ['verif', 'confirm', 'validat', 'authenticat'];
      final messages = [
        phoneNumberProblem('0041791234567'),
        phoneNumberProblem('0791234567'),
        phoneNumberProblem('+0791234567'),
        phoneNumberProblem('+41 79 CALL ME'),
        phoneNumberProblem('+1234'),
        phoneNumberProblem('+1234567890123456'),
        phoneNumberProblem('+'),
      ].whereType<String>();

      expect(messages, isNotEmpty);
      for (final message in messages) {
        for (final word in forbidden) {
          expect(
            message.toLowerCase(),
            isNot(contains(word)),
            reason:
                'nothing in this system checks a phone number, so no '
                'message may hint that something did: "$message"',
          );
        }
      }
    });
  });

  group('isE164PhoneNumber', () {
    test('agrees with normalizePhoneNumber', () {
      expect(isE164PhoneNumber('+41791234567'), isTrue);
      expect(isE164PhoneNumber('0041791234567'), isFalse);
    });
  });

  group('PaymentHandlesDto', () {
    Map<String, dynamic> payload({
      bool sharing = false,
      List<Map<String, dynamic>> phoneNumbers = const [],
    }) => {
      'guildId': 'guild-1',
      'deviceId': 'device-1',
      'memberRosterVersion': 3,
      'members': [
        {
          'userId': 'anna',
          'ciphertext': 'AAECAw==',
          'nonce': 'BAUGBw==',
          'version': 1,
          'memberRosterVersion': 3,
          'updatedAt': '2026-08-07T17:53:53.1234567+00:00',
          'wrappedKey': null,
        },
      ],
      'phoneNumbers': phoneNumbers,
      'sharingPhoneNumber': sharing,
    };

    test('reads the phone half', () {
      final handles = PaymentHandlesDto.fromJson(
        payload(
          sharing: true,
          phoneNumbers: [
            {
              'userId': 'anna',
              'phoneNumber': '+41791234567',
              'updatedAt': '2026-08-07T17:53:53.1234567+00:00',
            },
          ],
        ),
      );

      expect(handles.sharingPhoneNumber, isTrue);
      expect(handles.phoneNumbers, hasLength(1));
      expect(handles.phoneNumbers.single.phoneNumber, '+41791234567');
      expect(handles.phoneNumberFor('anna'), '+41791234567');
    });

    /// The sealed handles need device-scoped crypto this app doesn't have.
    /// Ignoring them has to be free - a payload full of base64 that nothing
    /// can open must not stop the numbers next to it from being read.
    test('ignores the sealed members array entirely', () {
      final handles = PaymentHandlesDto.fromJson(payload());
      expect(handles.phoneNumbers, isEmpty);
      expect(handles.sharingPhoneNumber, isFalse);
    });

    /// The server has a test asserting these two are byte-identical. This is
    /// the client end of that contract: both are simply absent, and there is
    /// no way to tell them apart - which is why nothing renders a sentence.
    test('an opt-out and a missing number are the same absence', () {
      final optedOut = PaymentHandlesDto.fromJson(payload());
      final noNumber = PaymentHandlesDto.fromJson(payload());

      expect(optedOut.phoneNumberFor('anna'), isNull);
      expect(noNumber.phoneNumberFor('anna'), isNull);
      expect(optedOut, noNumber);
    });

    /// A build that predates one of these fields, or a server that stops
    /// sending them, must not crash the ledger.
    test('survives a payload with neither field', () {
      final handles = PaymentHandlesDto.fromJson(const {});
      expect(handles.sharingPhoneNumber, isFalse);
      expect(handles.phoneNumbers, isEmpty);
    });

    /// `updatedAt` is the account's last-updated stamp and the server sends it
    /// with an offset. Nullable here because it is never load-bearing.
    test('reads updatedAt as UTC, and copes without it', () {
      final withStamp = SharedPhoneNumberDto.fromJson(const {
        'userId': 'anna',
        'phoneNumber': '+41791234567',
        'updatedAt': '2026-08-07T19:53:53.1234567+02:00',
      });
      expect(withStamp.updatedAt?.isUtc, isTrue);
      expect(withStamp.updatedAt?.hour, 17);

      final without = SharedPhoneNumberDto.fromJson(const {
        'userId': 'anna',
        'phoneNumber': '+41791234567',
      });
      expect(without.updatedAt, isNull);
    });
  });
}
