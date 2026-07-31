import 'package:flutter_test/flutter_test.dart';
import 'package:venta_mobile/features/household/data/models/house_dto.dart';
import 'package:venta_mobile/features/household/data/money.dart';
import 'package:venta_mobile/features/household/presentation/widgets/household_widgets.dart';

/// The two pieces of household logic that live on the client rather than the
/// server, and where being wrong is expensive: money (a mis-parsed amount is a
/// wrong ledger) and the quiet-hours window (which wraps midnight in the
/// normal case, not the edge case).
void main() {
  group('money', () {
    test('formats two-decimal currencies from minor units', () {
      expect(formatMinor(1234, 'CHF'), 'CHF 12.34');
      expect(formatMinor(5, 'EUR'), 'EUR 0.05');
      expect(formatMinor(100000, 'GBP'), 'GBP 1\u202f000.00');
    });

    test('respects currencies without a minor unit', () {
      expect(formatMinor(1234, 'JPY'), 'JPY 1\u202f234');
      expect(currencyExponent('KWD'), 3);
      expect(formatMinor(1234, 'KWD'), 'KWD 1.234');
    });

    test('signs balances only when asked', () {
      expect(formatMinor(-1234, 'CHF'), '-CHF 12.34');
      expect(formatMinor(1234, 'CHF', signed: true), 'CHF +12.34');
      expect(formatMinor(1234, 'CHF', showCurrency: false), '12.34');
    });

    test('parses what people actually type', () {
      expect(parseAmountToMinor('12.34', 'CHF'), 1234);
      expect(parseAmountToMinor('12,34', 'CHF'), 1234);
      expect(parseAmountToMinor('12', 'CHF'), 1200);
      expect(parseAmountToMinor('12.5', 'CHF'), 1250);
      expect(parseAmountToMinor('.5', 'CHF'), 50);
      expect(parseAmountToMinor(' 7 ', 'CHF'), 700);
    });

    test('truncates extra decimals rather than rejecting them', () {
      expect(parseAmountToMinor('12.349', 'CHF'), 1234);
      expect(parseAmountToMinor('12.9', 'JPY'), 12);
    });

    test('refuses anything that is not a plain amount', () {
      expect(parseAmountToMinor('', 'CHF'), isNull);
      expect(parseAmountToMinor('abc', 'CHF'), isNull);
      expect(parseAmountToMinor('1.2.3', 'CHF'), isNull);
      expect(parseAmountToMinor('-5', 'CHF'), isNull);
    });

    test('round-trips through the editable form', () {
      for (final minor in [0, 5, 99, 100, 123456]) {
        expect(
          parseAmountToMinor(editableAmount(minor, 'CHF'), 'CHF'),
          minor,
          reason: 'editing $minor should not change it',
        );
      }
    });
  });

  group('quiet hours', () {
    const overnight = QuietHoursDto(
      enabled: true,
      startMinuteLocal: 22 * 60,
      endMinuteLocal: 7 * 60,
    );

    test('wraps midnight when start is after end', () {
      expect(overnight.wrapsMidnight, isTrue);
      expect(overnight.containsMinute(23 * 60), isTrue);
      expect(overnight.containsMinute(2 * 60), isTrue);
      expect(overnight.containsMinute(22 * 60), isTrue);
      expect(overnight.containsMinute(7 * 60), isFalse);
      expect(overnight.containsMinute(12 * 60), isFalse);
    });

    test('handles a daytime window without wrapping', () {
      const daytime = QuietHoursDto(
        enabled: true,
        startMinuteLocal: 13 * 60,
        endMinuteLocal: 15 * 60,
      );
      expect(daytime.wrapsMidnight, isFalse);
      expect(daytime.containsMinute(14 * 60), isTrue);
      expect(daytime.containsMinute(16 * 60), isFalse);
      expect(daytime.containsMinute(2 * 60), isFalse);
    });

    test('is never active while disabled', () {
      expect(overnight.copyWith(enabled: false).containsMinute(23 * 60),
          isFalse);
    });

    test('formats minutes past midnight as a 24-hour clock', () {
      expect(formatMinuteOfDay(0), '00:00');
      expect(formatMinuteOfDay(7 * 60), '07:00');
      expect(formatMinuteOfDay(22 * 60 + 30), '22:30');
      expect(formatMinuteOfDay(23 * 60 + 59), '23:59');
    });
  });

  /// A list item's quantity is a server-supplied string and the pantry's is a
  /// local `double`, so the pantry restock that writes `5.0 Tab` onto the
  /// shopping list put `5.0 Tab` and `5` on screen for the same stock.
  group('formatListQuantity', () {
    test('respells a leading decimal the way the pantry does', () {
      expect(formatListQuantity('5.0 Tab'), '5 Tab');
      expect(formatListQuantity('5.50 kg'), '5.5 kg');
      expect(formatListQuantity('2.0'), '2');
    });

    test('leaves free text alone', () {
      expect(formatListQuantity('a bunch of the small ones'), 'a bunch of the '
          'small ones');
      expect(formatListQuantity('2x6 pack'), '2x6 pack');
      expect(formatListQuantity('half a kilo'), 'half a kilo');
      expect(formatListQuantity(''), '');
      expect(formatListQuantity('   '), '');
    });

    test('keeps a quantity that was already tidy', () {
      expect(formatListQuantity('5 Tab'), '5 Tab');
      expect(formatListQuantity('1.5 l'), '1.5 l');
    });
  });
}
