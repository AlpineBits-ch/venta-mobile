import 'package:flutter_test/flutter_test.dart';
import 'package:venta_mobile/core/format/day_heading.dart';

void main() {
  group('isSameLocalDay', () {
    test('two instants in the same local day match', () {
      expect(
        isSameLocalDay(
          DateTime(2026, 8, 18, 0, 0, 1),
          DateTime(2026, 8, 18, 23, 59, 59),
        ),
        isTrue,
      );
    });

    test('a minute either side of local midnight does not', () {
      expect(
        isSameLocalDay(
          DateTime(2026, 8, 18, 23, 59),
          DateTime(2026, 8, 19, 0, 1),
        ),
        isFalse,
      );
    });

    /// The whole reason this compares local time. A UTC instant late in the
    /// evening is already tomorrow at Greenwich for anyone east of it, and a
    /// divider placed on the UTC date would land hours from the boundary the
    /// reader actually lived.
    test('a UTC stamp is compared after conversion to local time', () {
      final utc = DateTime.utc(2026, 8, 18, 22, 30);
      expect(isSameLocalDay(utc, utc.toLocal()), isTrue);
    });

    test('the same day in a different year does not match', () {
      expect(
        isSameLocalDay(DateTime(2025, 8, 18), DateTime(2026, 8, 18)),
        isFalse,
      );
    });
  });

  group('formatDayHeading', () {
    final now = DateTime(2026, 8, 18, 14, 30);

    test('today is named rather than dated', () {
      expect(formatDayHeading(DateTime(2026, 8, 18, 9), now), 'Today');
    });

    test('the first moment of today is still today', () {
      expect(formatDayHeading(DateTime(2026, 8, 18), now), 'Today');
    });

    test('yesterday is named rather than dated', () {
      expect(formatDayHeading(DateTime(2026, 8, 17, 23, 59), now), 'Yesterday');
    });

    /// Both directions of the boundary, since an off-by-one here reads as the
    /// timeline losing a day.
    test('the day before yesterday is dated', () {
      expect(formatDayHeading(DateTime(2026, 8, 16, 12), now), '16 August');
    });

    test('a date earlier this year omits the year', () {
      expect(formatDayHeading(DateTime(2026, 1, 3, 8), now), '3 January');
    });

    test('a date in another year carries it', () {
      expect(
        formatDayHeading(DateTime(2025, 12, 31, 23), now),
        '31 December 2025',
      );
    });

    /// A month-end crossing is where an implementation that subtracts a day
    /// from the date number rather than from the date goes wrong.
    test('yesterday across a month boundary is still yesterday', () {
      expect(
        formatDayHeading(DateTime(2026, 7, 31, 20), DateTime(2026, 8, 1, 6)),
        'Yesterday',
      );
    });

    test('yesterday across a year boundary is still yesterday', () {
      expect(
        formatDayHeading(DateTime(2025, 12, 31, 20), DateTime(2026, 1, 1, 6)),
        'Yesterday',
      );
    });

    /// February 29th exists in 2028 and not in 2027, so a "same date last
    /// month/year" shortcut would produce an invalid date here.
    test('a leap day is dated normally', () {
      expect(
        formatDayHeading(DateTime(2028, 2, 29, 10), DateTime(2028, 3, 5)),
        '29 February',
      );
    });

    test('every month name is reachable and correct', () {
      final reference = DateTime(2026, 6, 15);
      final names = [
        for (var month = 1; month <= 12; month++)
          formatDayHeading(DateTime(2025, month, 10), reference),
      ];
      expect(names, [
        '10 January 2025',
        '10 February 2025',
        '10 March 2025',
        '10 April 2025',
        '10 May 2025',
        '10 June 2025',
        '10 July 2025',
        '10 August 2025',
        '10 September 2025',
        '10 October 2025',
        '10 November 2025',
        '10 December 2025',
      ]);
    });
  });

  group('startsNewDay', () {
    /// Null covers two cases the caller collapses into one - no older message
    /// is loaded, and the older message has no timestamp. Either way this row
    /// heads its day: a window that opens mid-conversation should say which
    /// day it opens on rather than silently joining an unknown one.
    test('a row with no dated older neighbour heads a day', () {
      expect(startsNewDay(null, DateTime(2026, 8, 18, 9)), isTrue);
    });

    test('a message on the same day as the one before it does not', () {
      expect(
        startsNewDay(DateTime(2026, 8, 18, 9), DateTime(2026, 8, 18, 23)),
        isFalse,
      );
    });

    test('the first message after local midnight does', () {
      expect(
        startsNewDay(
          DateTime(2026, 8, 18, 23, 59),
          DateTime(2026, 8, 19, 0, 1),
        ),
        isTrue,
      );
    });

    /// No date to head it with, so it heads nothing - the caller still breaks
    /// the grouping run above it.
    test('a message with no timestamp heads nothing', () {
      expect(startsNewDay(DateTime(2026, 8, 18), null), isFalse);
      expect(startsNewDay(null, null), isFalse);
    });
  });
}
