import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/network/api_client.dart';
import 'package:venta_mobile/core/realtime/realtime_event.dart';
import 'package:venta_mobile/core/realtime/realtime_service.dart';
import 'package:venta_mobile/features/auth/data/auth_repository.dart';
import 'package:venta_mobile/features/guilds/data/guild_api.dart';
import 'package:venta_mobile/features/guilds/data/guild_repository.dart';

/// What happens between "the invite says you joined" and "the server you landed
/// on is usable".
///
/// The join itself is one call and it either works or it doesn't. Landing on the
/// guild afterwards is a *second* read of state the join has only just created,
/// and that read can answer as though the join hadn't happened - which is how
/// accepting an invite dropped the user on a server with no name, no icon and no
/// channels while the join had in fact succeeded. These pin the retry that
/// absorbs it, and the shape of the answers it has to survive.
class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockRealtimeService extends Mock implements RealtimeService {}

/// Answers each request from [handler], recording what was asked for.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.handler);

  final List<RequestOptions> requests = [];

  /// Returns `(status, body)` for one request. A null body sends no content.
  final (int, Object?) Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final (status, body) = handler(options);
    return ResponseBody.fromString(
      body == null ? '' : jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}

  /// Paths of every request made, in order - the assertion subject for "did it
  /// try again", which is otherwise invisible from the return value alone.
  List<String> get paths => requests.map((r) => r.uri.path).toList();

  int countOf(String path) => paths.where((p) => p == path).length;
}

const _base = 'https://example.test';
const _guildId = 'gild_1';
const _code = 'abc123';

Map<String, dynamic> _invite() => {
  'id': 'invi_1',
  'type': 'Permanent',
  'state': 'Active',
  'guildId': _guildId,
  'code': _code,
  'useCount': 0,
};

/// A guild as the read side answers once the join is visible to it.
Map<String, dynamic> _fullGuild() => {
  'id': _guildId,
  'name': 'Echo',
  'ownerId': 'user_owner',
  'channels': [
    {
      'id': 'chan_1',
      'guildId': _guildId,
      'name': 'general',
      'type': 'Text',
      'position': 0,
    },
  ],
  'categories': [],
  'roles': [],
};

/// The same guild before the join is visible: the row exists, its contents do
/// not come back with it. Indistinguishable from "empty server" on screen, which
/// is exactly why it can't be taken as final.
Map<String, dynamic> _contentlessGuild() => {
  'id': _guildId,
  'name': '',
  'ownerId': 'user_owner',
  'channels': [],
  'categories': [],
  'roles': [],
};

void main() {
  late _ScriptedAdapter adapter;
  late GuildRepository repository;
  late StreamController<RealtimeEvent> events;
  var built = false;

  void build((int, Object?) Function(RequestOptions options) handler) {
    built = true;
    final auth = _MockAuthRepository();
    when(() => auth.baseUrl).thenReturn(_base);
    when(() => auth.ensureValidToken()).thenAnswer((_) async => 'token');
    when(() => auth.currentUserId).thenReturn('user_me');

    final client = ApiClient(authRepository: auth);
    adapter = _ScriptedAdapter(handler);
    client.dio.httpClientAdapter = adapter;

    events = StreamController<RealtimeEvent>.broadcast();
    final realtime = _MockRealtimeService();
    when(() => realtime.events).thenAnswer((_) => events.stream);

    repository = GuildRepository(
      api: GuildApi(client: client),
      authRepository: auth,
      realtimeService: realtime,
    );
  }

  tearDown(() {
    if (!built) return;
    built = false;
    repository.dispose();
    unawaited(events.close());
  });

  const guildPath = '/api/v1/guild/guilds/$_guildId';
  const listPath = '/api/v1/guild/guilds';

  test('a join whose guild read 403s at first still lands on the guild', () async {
    var guildReads = 0;
    build((options) {
      final path = options.uri.path;
      if (path == '/api/v1/guild/invites/code/$_code') return (200, _invite());
      if (path == '/api/v1/guild/invites/invi_1/redeem') return (202, null);
      if (path == listPath) return (200, [_fullGuild()]);
      if (path == guildPath) {
        guildReads++;
        // The membership is committed but the permission check behind this read
        // has not caught up with it yet.
        if (guildReads == 1) return (403, {'error': 'forbidden'});
        return (200, _fullGuild());
      }
      return (404, null);
    });

    final guild = await repository.redeemInvite(_code);

    expect(guild.id, _guildId);
    expect(guild.name, 'Echo');
    expect(guild.channels, hasLength(1), reason: 'landed with its channels');
    expect(guildReads, 2, reason: 'the failed read was retried, not accepted');
    // And the guild the rail and the guild screen read is the full one.
    expect(repository.cachedById(_guildId)?.channels, hasLength(1));
  });

  test('a guild that comes back with no contents is read again', () async {
    var guildReads = 0;
    build((options) {
      final path = options.uri.path;
      if (path == '/api/v1/guild/invites/code/$_code') return (200, _invite());
      if (path == '/api/v1/guild/invites/invi_1/redeem') return (202, null);
      if (path == listPath) return (200, [_contentlessGuild()]);
      if (path == guildPath) {
        guildReads++;
        return (200, guildReads == 1 ? _contentlessGuild() : _fullGuild());
      }
      return (404, null);
    });

    final guild = await repository.redeemInvite(_code);

    expect(guild.name, 'Echo', reason: 'a 200 is not the same as an answer');
    expect(guild.channels, hasLength(1));
    expect(guildReads, 2);
  });

  test('a guild that is really empty settles rather than retrying forever', () async {
    var guildReads = 0;
    build((options) {
      final path = options.uri.path;
      if (path == '/api/v1/guild/invites/code/$_code') return (200, _invite());
      if (path == '/api/v1/guild/invites/invi_1/redeem') return (202, null);
      if (path == listPath) return (200, [_contentlessGuild()]);
      if (path == guildPath) {
        guildReads++;
        return (200, _contentlessGuild());
      }
      return (404, null);
    });

    final guild = await repository.redeemInvite(_code);

    expect(guild.id, _guildId, reason: 'the join succeeded, so this must not throw');
    expect(guildReads, 4, reason: 'bounded: three retries behind the first read');
  });

  test('a read that never succeeds surfaces as a failure, not as a blank guild', () async {
    build((options) {
      final path = options.uri.path;
      if (path == '/api/v1/guild/invites/code/$_code') return (200, _invite());
      if (path == '/api/v1/guild/invites/invi_1/redeem') return (202, null);
      if (path == listPath) return (200, <Object>[]);
      return (500, {'error': 'nope'});
    });

    await expectLater(repository.redeemInvite(_code), throwsA(isA<Object>()));
    expect(
      adapter.countOf(guildPath),
      4,
      reason: 'every attempt was spent before giving up',
    );
  });

  test('the icon url is built from the id, since the guild payload omits it', () {
    build((options) => (200, _fullGuild()));

    expect(repository.iconUrl(_guildId), '$_base$guildPath/icon');
    // The field the rail used to rely on is still absent from the payload -
    // which is why the url has to be derived rather than read.
    expect(_fullGuild().containsKey('iconUrl'), isFalse);
  });
}
