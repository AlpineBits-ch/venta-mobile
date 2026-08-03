import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/mls/mls_service.dart';
import 'package:venta_mobile/core/network/api_client.dart';
import 'package:venta_mobile/core/realtime/realtime_event.dart';
import 'package:venta_mobile/core/realtime/realtime_service.dart';
import 'package:venta_mobile/features/auth/data/auth_repository.dart';
import 'package:venta_mobile/features/guilds/data/models/channel_dto.dart';
import 'package:venta_mobile/features/inbox/data/inbox_api.dart';
import 'package:venta_mobile/features/inbox/data/inbox_repository.dart';
import 'package:venta_mobile/features/inbox/data/models/inbox_breadcrumb_dto.dart';
import 'package:venta_mobile/features/inbox/data/models/inbox_mention_dto.dart';
import 'package:venta_mobile/features/inbox/data/models/inbox_summary_dto.dart';

/// The parts of the inbox where being wrong is silent.
///
/// Every one of these is a rule the endpoint documents and the client has to
/// honour without any feedback when it doesn't: an empty page with a cursor
/// behind it reads as an empty inbox, a re-serialised `createdAt` deletes
/// nothing while still answering `204`, and a server-relative icon path renders
/// as a broken image rather than an error.
class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockMlsService extends Mock implements MlsService {}

class _MockRealtimeService extends Mock implements RealtimeService {}

/// Answers each request from [handler], recording what was asked for.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.handler);

  final List<RequestOptions> requests = [];

  /// Returns the JSON body for one request, or null for an empty `204`.
  final Object? Function(RequestOptions options, int callIndex) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final index = requests.length;
    requests.add(options);
    final body = handler(options, index);
    return ResponseBody.fromString(
      body == null ? '' : jsonEncode(body),
      body == null ? 204 : 200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const _base = 'https://example.test';

Map<String, dynamic> _breadcrumb({String channelId = 'chan_1'}) => {
  'guildId': 'gild_1',
  'guildName': 'Echo',
  'guildIconUrl': '/api/v1/guild/guilds/gild_1/icon',
  'guildIconThumbnailUrl': '/api/v1/guild/guilds/gild_1/icon/thumbnail',
  'categoryId': 'cate_1',
  'categoryName': 'General',
  'channelId': channelId,
  'channelName': 'announcements',
  'channelType': 0,
  'parentChannelId': null,
  'parentChannelName': null,
};

Map<String, dynamic> _group({String channelId = 'chan_1'}) => {
  'breadcrumb': _breadcrumb(channelId: channelId),
  'lastActivityAt': '2026-08-03T10:14:22.115Z',
  'unreadCount': 8,
  'mentionCount': 2,
  'previews': [
    {
      'id': 'mesg_1',
      'createdAt': '2026-08-03T10:14:22.115Z',
      'authorId': 'user_1',
      'authorDisplayName': null,
      'authorAvatarUrl': null,
      'content': 'aGVsbG8=',
      'isEncrypted': false,
      'mlsGeneration': null,
      'type': 0,
      'systemMessageVariant': null,
      'embedsJson': null,
    },
  ],
  'previewsTruncated': true,
};

void main() {
  late _ScriptedAdapter adapter;
  late InboxApi api;
  late StreamController<RealtimeEvent> events;
  late InboxRepository repository;

  /// Not every test here needs a repository - the pure mapping ones don't -
  /// and tearing one down twice trips `ValueNotifier`'s dispose assertion.
  var built = false;

  void build(Object? Function(RequestOptions options, int callIndex) handler) {
    built = true;
    final auth = _MockAuthRepository();
    when(() => auth.baseUrl).thenReturn(_base);
    when(() => auth.ensureValidToken()).thenAnswer((_) async => 'token');

    final client = ApiClient(authRepository: auth);
    adapter = _ScriptedAdapter(handler);
    client.dio.httpClientAdapter = adapter;

    api = InboxApi(client: client);
    events = StreamController<RealtimeEvent>.broadcast();
    final realtime = _MockRealtimeService();
    when(() => realtime.events).thenAnswer((_) => events.stream);
    repository = InboxRepository(
      api: api,
      realtimeService: realtime,
      mls: _MockMlsService(),
    );
  }

  tearDown(() {
    if (!built) return;
    built = false;
    repository.dispose();
    unawaited(events.close());
  });

  group('paging', () {
    // Muting and permission filtering are applied *after* a page is taken, so
    // a page can be empty while more results exist. Stopping there is the
    // single easiest thing to get wrong here, and it looks exactly like an
    // empty inbox.
    test('follows the cursor through empty pages', () async {
      build((options, index) {
        if (index < 2)
          return {'groups': <Object>[], 'nextCursor': 'cur_$index'};
        return {
          'groups': [_group()],
          'nextCursor': null,
        };
      });

      final result = await repository.loadUnread();

      expect(adapter.requests, hasLength(3));
      expect(result.groups, hasLength(1));
      expect(result.nextCursor, isNull);
      // The cursor from the previous page is what the next request carries.
      expect(adapter.requests[1].queryParameters['cursor'], 'cur_0');
      expect(adapter.requests[2].queryParameters['cursor'], 'cur_1');
    });

    test('stops as soon as a page produces something', () async {
      build(
        (options, index) => {
          'groups': [_group()],
          'nextCursor': 'cur_more',
        },
      );

      final result = await repository.loadUnread();

      expect(adapter.requests, hasLength(1));
      expect(result.nextCursor, 'cur_more');
    });

    // Following forever would let one pull-to-refresh walk the whole account.
    // The cursor is handed back instead, so the UI can offer to keep looking
    // rather than claim an empty inbox.
    test('gives up bounded, keeping the cursor', () async {
      build((options, index) => {'groups': <Object>[], 'nextCursor': 'cur'});

      final result = await repository.loadUnread();

      expect(result.groups, isEmpty);
      expect(result.nextCursor, isNotNull);
      expect(adapter.requests.length, lessThan(20));
    });

    test('stops on a null cursor even with nothing found', () async {
      build((options, index) => {'groups': <Object>[], 'nextCursor': null});

      final result = await repository.loadUnread();

      expect(adapter.requests, hasLength(1));
      expect(result.nextCursor, isNull);
    });

    // Deleted messages are skipped server-side, so the same rule applies to
    // the mentions list for a different reason.
    test('follows empty mention pages too', () async {
      build((options, index) {
        if (index == 0) {
          return {'mentions': <Object>[], 'nextCursor': 'cur_0'};
        }
        return {
          'mentions': [
            {
              'messageId': 'mesg_1',
              'createdAt': '2026-08-03T09:41:02.884Z',
              'kind': 'Direct',
              'authorId': 'user_1',
              'breadcrumb': _breadcrumb(),
            },
          ],
          'nextCursor': null,
        };
      });

      final result = await repository.loadMentions();

      expect(adapter.requests, hasLength(2));
      expect(result.mentions, hasLength(1));
    });
  });

  group('dismiss', () {
    // The index is keyed on the exact string. A `DateTime` round-trip that
    // drops a millisecond or adds a `Z` matches no row, and the delete is a
    // `204` that removed nothing - there is no error to notice.
    test('sends createdAt back verbatim', () async {
      build((options, index) => null);
      const raw = '2026-08-03T09:41:02.8840000';

      await repository.dismissMention(
        const InboxMentionDto(messageId: 'mesg_1', createdAtRaw: raw),
      );

      final request = adapter.requests.single;
      expect(request.method, 'DELETE');
      expect(request.path, contains('/inbox/mentions/mesg_1'));
      expect(request.queryParameters['createdAt'], raw);
    });

    test('an empty 204 body is not treated as a failure', () async {
      build((options, index) => null);

      await expectLater(repository.markChannelRead('chan_1'), completes);
      await expectLater(repository.markAllRead(), completes);
    });
  });

  group('breadcrumb', () {
    test('absolutises server-relative guild icon paths', () async {
      build(
        (options, index) => {
          'groups': [_group()],
          'nextCursor': null,
        },
      );

      final result = await repository.loadUnread();
      final breadcrumb = result.groups.single.breadcrumb;

      expect(
        breadcrumb.guildIconThumbnailUrl,
        '$_base/api/v1/guild/guilds/gild_1/icon/thumbnail',
      );
      expect(breadcrumb.guildIconUrl, '$_base/api/v1/guild/guilds/gild_1/icon');
    });

    test('maps the int channel type onto ChannelType', () {
      expect(
        const InboxBreadcrumbDto(channelType: 0).channelKind,
        ChannelType.text,
      );
      expect(
        const InboxBreadcrumbDto(channelType: 4).channelKind,
        ChannelType.forum,
      );
      // Past the server's own range. Renders inert rather than being read as
      // Text, which is what would put a composer on a shopping list.
      expect(
        const InboxBreadcrumbDto(channelType: 99).channelKind,
        ChannelType.unknown,
      );
      expect(
        const InboxBreadcrumbDto(channelType: -1).channelKind,
        ChannelType.unknown,
      );
    });
  });

  group('badge label', () {
    // The whole point of the header badge is answering "is there anything in
    // there". A badge that counted only mentions showed nothing at all for an
    // inbox full of unread channels, which is the same as no badge.
    test('counts unread channels as well as mentions', () {
      expect(
        const InboxSummaryDto(
          unreadChannelCount: 4,
          mentionCount: 0,
        ).badgeLabel,
        '4',
      );
      expect(
        const InboxSummaryDto(
          unreadChannelCount: 4,
          mentionCount: 12,
        ).badgeLabel,
        '16',
      );
    });

    test('caps at 99, from either side', () {
      expect(
        const InboxSummaryDto(
          unreadChannelCount: 90,
          mentionCount: 20,
        ).badgeLabel,
        '99+',
      );
      // The server saying it stopped counting caps it regardless of the
      // numbers it did report.
      expect(
        const InboxSummaryDto(
          unreadChannelCount: 1,
          mentionCount: 1,
          capped: true,
        ).badgeLabel,
        '99+',
      );
    });

    test('the tooltip keeps the two counts apart', () {
      expect(
        const InboxSummaryDto(
          unreadChannelCount: 1,
          mentionCount: 1,
        ).badgeBreakdown,
        'Inbox - 1 mention, 1 unread channel',
      );
      expect(
        const InboxSummaryDto(unreadChannelCount: 4).badgeBreakdown,
        'Inbox - 4 unread channels',
      );
      expect(const InboxSummaryDto().badgeBreakdown, 'Inbox');
    });
  });

  group('summary badge', () {
    test('a read-all from another device clears every count', () async {
      build(
        (options, index) => {
          'unreadChannelCount': 4,
          'mentionCount': 12,
          'capped': false,
        },
      );
      await repository.refreshSummary();
      expect(repository.summary.value.mentionCount, 12);

      // Read-all sends `{ all: true }` and no channel id at all - looking for
      // one and finding null would drop the event and leave the badge lit.
      events.add(
        const RealtimeEvent('inbox.ReadStateChanged', [
          {'all': true},
        ]),
      );
      await Future<void>.delayed(Duration.zero);

      expect(repository.summary.value.unreadChannelCount, 0);
      expect(repository.summary.value.mentionCount, 0);
    });

    test('a mention moves the badge before the refetch lands', () async {
      build(
        (options, index) => {
          'unreadChannelCount': 1,
          'mentionCount': 1,
          'capped': false,
        },
      );
      await repository.refreshSummary();

      events.add(
        const RealtimeEvent('inbox.MentionAdded', [
          {
            'messageId': 'mesg_1',
            'channelId': 'chan_1',
            'guildId': 'gild_1',
            'authorId': 'user_2',
            'kind': 'Direct',
            'createdAt': '2026-08-03T09:41:02.884Z',
          },
        ]),
      );
      await Future<void>.delayed(Duration.zero);

      expect(repository.summary.value.mentionCount, 2);
    });

    test('marking a channel read takes its mentions with it', () async {
      build(
        (options, index) => index == 0
            ? {'unreadChannelCount': 3, 'mentionCount': 5, 'capped': false}
            : null,
      );
      await repository.refreshSummary();

      await repository.markChannelRead('chan_1', mentionCount: 2);

      expect(repository.summary.value.unreadChannelCount, 2);
      expect(repository.summary.value.mentionCount, 3);
    });

    test('counts never go negative', () async {
      build(
        (options, index) => index == 0
            ? {'unreadChannelCount': 0, 'mentionCount': 0, 'capped': false}
            : null,
      );
      await repository.refreshSummary();

      await repository.markChannelRead('chan_1', mentionCount: 4);

      expect(repository.summary.value.unreadChannelCount, 0);
      expect(repository.summary.value.mentionCount, 0);
    });
  });
}
