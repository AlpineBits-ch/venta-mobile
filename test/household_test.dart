import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venta_mobile/core/push/household_push_payload.dart';
import 'package:venta_mobile/core/realtime/realtime_event.dart';
import 'package:venta_mobile/core/realtime/realtime_service.dart';
import 'package:venta_mobile/features/household/data/household_api.dart';
import 'package:venta_mobile/features/household/data/household_repository.dart';
import 'package:venta_mobile/features/household/data/models/digest_dto.dart';
import 'package:venta_mobile/features/household/data/models/house_dto.dart';
import 'package:venta_mobile/features/household/data/models/household_alert.dart';
import 'package:venta_mobile/features/household/data/models/ledger_dto.dart';
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
      expect(
        overnight.copyWith(enabled: false).containsMinute(23 * 60),
        isFalse,
      );
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
      expect(
        formatListQuantity('a bunch of the small ones'),
        'a bunch of the '
        'small ones',
      );
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

  /// `GET /expenses` stopped answering with a bare array. A client that still
  /// reads one gets nothing at all, which is why the paged shape is parsed
  /// here and the old one is only tolerated.
  group('expense paging', () {
    test('reads the paged shape', () {
      final page = ExpensePageDto.fromJson({
        'items': [
          {'id': 'e1', 'channelId': 'c1', 'amountMinor': 1234},
        ],
        'nextCursor': '2026-08-01T00:00:00.0000000+00:00|e1',
      });
      expect(page.items.single.amountMinor, 1234);
      expect(page.nextCursor, isNotNull);
    });

    test('treats a missing cursor as the end of the ledger', () {
      final page = ExpensePageDto.fromJson({'items': <dynamic>[]});
      expect(page.items, isEmpty);
      expect(page.nextCursor, isNull);
    });
  });

  group('move-out', () {
    test('reads the summary', () {
      final summary = MoveOutSummaryDto.fromJson({
        'userId': 'ben',
        'choresReassigned': 2,
        'choresPaused': 1,
        'listItemsUnassigned': 3,
        'balancesWrittenOff': [
          {'fromUserId': 'ben', 'toUserId': 'anna', 'amountMinor': 24000},
        ],
      });
      expect(summary.choresReassigned, 2);
      // Dropped is absent from the payload when it's zero.
      expect(summary.choresDropped, 0);
      expect(summary.balancesWrittenOff.single.amountMinor, 24000);
    });

    /// The `409` is a decision to put in front of the house, so its balances
    /// have to survive the trip out of Dio - a bare "request failed" is the one
    /// rendering that can't be acted on.
    test('unpacks the not-settled-up refusal', () {
      final blocked = MoveOutBlocked.tryParse(
        DioException(
          requestOptions: RequestOptions(path: '/move-out'),
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: '/move-out'),
            statusCode: 409,
            data: {
              'error': 'This member is not settled up',
              'outstanding': [
                {'channelId': 'c1', 'currency': 'CHF', 'netMinor': -24000},
              ],
            },
          ),
        ),
      );
      expect(blocked, isNotNull);
      expect(blocked!.outstanding.single.netMinor, -24000);
      expect(blocked.outstanding.single.currency, 'CHF');
    });

    test('leaves other failures alone', () {
      expect(
        MoveOutBlocked.tryParse(
          DioException(
            requestOptions: RequestOptions(path: '/move-out'),
            response: Response<dynamic>(
              requestOptions: RequestOptions(path: '/move-out'),
              statusCode: 403,
            ),
          ),
        ),
        isNull,
      );
    });
  });

  group('household push', () {
    test('routes a chore reminder at the board it came from', () {
      final payload = HouseholdPushPayload.tryParse({
        'type': 'household',
        'kind': 'chore.due',
        'guildId': 'g1',
        'channelId': 'c1',
        'targetId': 'o1',
        'title': 'Bins',
        'body': 'Your turn, and it\'s due now.',
      });
      expect(payload, isNotNull);
      expect(payload!.route, '/server/g1/channel/c1');
      expect(payload.targetId, 'o1');
    });

    test('falls back to the house when the module has no channel', () {
      final payload = HouseholdPushPayload.tryParse({
        'type': 'household',
        'kind': 'something.new',
        'guildId': 'g1',
        'title': 'Home',
      });
      expect(payload!.route, '/server/g1');
    });

    test('ignores a message push', () {
      expect(
        HouseholdPushPayload.tryParse({'type': 'message', 'messageId': 'm1'}),
        isNull,
      );
    });
  });

  group('household alert', () {
    // One event name carries every kind on purpose: kinds keep being added,
    // and a client that had to subscribe to `guild.SomethingNewAlert` would
    // silently stop being told about whatever shipped next.
    test('parses the unified envelope, whatever the kind', () {
      final alert = HouseholdAlert.tryParse(
        const RealtimeEvent('guild.HouseholdAlert', [
          {
            'guildId': 'g1',
            'channelId': 'c1',
            'kind': 'pantry.expiring',
            'targetId': 'c1',
            'title': 'Going off soon',
            'body': 'Milk, Yoghurt and 2 more are about to go off',
            'data': {
              'items': ['Milk', 'Yoghurt'],
            },
          },
        ]),
      );

      expect(alert, isNotNull);
      expect(alert!.kind, HouseholdAlert.pantryExpiring);
      expect(alert.targetId, 'c1');
      expect(alert.route, '/server/g1/channel/c1');
      expect(alert.data['items'], ['Milk', 'Yoghurt']);
      // The server writes the copy so no client needs per-kind wording.
      expect(alert.message, 'Milk, Yoghurt and 2 more are about to go off');
    });

    test('a kind this build has never seen still lands somewhere', () {
      final alert = HouseholdAlert.tryParse(
        const RealtimeEvent('guild.HouseholdAlert', [
          {'guildId': 'g1', 'kind': 'something.new', 'title': 'Home'},
        ]),
      );

      expect(alert!.route, '/server/g1');
      expect(alert.message, 'Home');
    });

    test('drops an alert with nowhere to go', () {
      expect(
        HouseholdAlert.tryParse(
          const RealtimeEvent('guild.HouseholdAlert', [
            {'kind': 'chore.due'},
          ]),
        ),
        isNull,
      );
    });
  });

  group('home digest', () {
    // A null section means "render nothing" - it covers both "the module is
    // off" and "you can see no channel of that type", and the two are
    // deliberately indistinguishable. Neither is an empty frame worth drawing.
    test('a house with nothing outstanding draws no card', () {
      expect(const HouseholdDigestDto(guildId: 'g1').isEmpty, isTrue);
      expect(
        const HouseholdDigestDto(
          guildId: 'g1',
          lists: [HouseholdListDigestDto(channelId: 'c1', openCount: 0)],
          ledger: [HouseholdLedgerDigestDto(channelId: 'c2')],
          decisions: HouseholdDecisionsDigestDto(),
        ).isEmpty,
        isTrue,
      );
    });

    test('anything outstanding draws it', () {
      expect(
        const HouseholdDigestDto(
          guildId: 'g1',
          lists: [HouseholdListDigestDto(channelId: 'c1', openCount: 3)],
        ).isEmpty,
        isFalse,
      );
      // Your own position in a ledger counts even when nothing else does -
      // negative means you owe the house.
      expect(
        const HouseholdDigestDto(
          guildId: 'g1',
          ledger: [
            HouseholdLedgerDigestDto(channelId: 'c2', myNetMinor: -2400),
          ],
        ).isEmpty,
        isFalse,
      );
    });
  });

  /// A hub method the transport never registered is dropped before any
  /// repository sees it, so a household event missing from the watch list turns
  /// its board silently back into pull-to-refresh.
  test('every household event is watched by the realtime transport', () {
    expect(
      HouseholdEvents.all.difference(RealtimeService.watchedEvents.toSet()),
      isEmpty,
    );
  });
}
