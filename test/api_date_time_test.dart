import 'package:flutter_test/flutter_test.dart';
import 'package:venta_mobile/core/format/api_date_time.dart';
import 'package:venta_mobile/features/messaging/data/models/message_dto.dart';

/// The bug this covers: `pinnedAt` arrives without a time-zone designator,
/// `DateTime.parse` reads that as local, and every `.toLocal()` downstream
/// becomes a no-op - so a message pinned at 09:09 in Berlin rendered as
/// `7:09 AM`. Anything the API sends now goes through [parseApiDateTime].
void main() {
  group('parseApiDateTime', () {
    test('reads a designator-less timestamp as UTC, not local', () {
      final parsed = parseApiDateTime('2026-07-31T07:09:12.481');
      expect(parsed.isUtc, isTrue);
      expect(parsed.toUtc().hour, 7);
      expect(
        parsed.millisecondsSinceEpoch,
        DateTime.utc(2026, 7, 31, 7, 9, 12, 481).millisecondsSinceEpoch,
      );
    });

    test('leaves an explicit Z alone', () {
      expect(
        parseApiDateTime('2026-07-31T07:09:12.481Z').millisecondsSinceEpoch,
        DateTime.utc(2026, 7, 31, 7, 9, 12, 481).millisecondsSinceEpoch,
      );
    });

    test('honours a numeric offset', () {
      expect(
        parseApiDateTime('2026-07-31T09:09:12+02:00').millisecondsSinceEpoch,
        DateTime.utc(2026, 7, 31, 7, 9, 12).millisecondsSinceEpoch,
      );
    });

    test('both spellings of the same instant agree', () {
      expect(
        parseApiDateTime('2026-07-31T07:09:12.481'),
        parseApiDateTime('2026-07-31T07:09:12.481Z'),
      );
    });

    test('tryParse tolerates null, empty and rubbish', () {
      expect(tryParseApiDateTime(null), isNull);
      expect(tryParseApiDateTime(''), isNull);
      expect(tryParseApiDateTime(42), isNull);
      expect(tryParseApiDateTime('not a date'), isNull);
      expect(tryParseApiDateTime('2026-07-31T07:09:12')?.isUtc, isTrue);
    });
  });

  group('DTO wiring', () {
    test('MessageDto routes both timestamps through the converter', () {
      final message = MessageDto.fromJson({
        'id': 'm1',
        'content': '',
        'authorId': 'u1',
        // Exactly the mix the API sends: one field with a designator, one
        // without. Before the converter these two decoded two hours apart.
        'createdAt': '2026-07-31T07:09:12.481Z',
        'pinnedAt': '2026-07-31T07:09:12.481',
      });
      expect(message.createdAt, message.pinnedAt);
      expect(message.pinnedAt!.isUtc, isTrue);
    });

    test('a null timestamp still decodes to null', () {
      final message = MessageDto.fromJson({
        'id': 'm1',
        'content': '',
        'authorId': 'u1',
      });
      expect(message.createdAt, isNull);
      expect(message.pinnedAt, isNull);
    });
  });
}
