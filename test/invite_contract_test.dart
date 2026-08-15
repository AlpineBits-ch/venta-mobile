import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/network/api_client.dart';
import 'package:venta_mobile/features/auth/data/auth_repository.dart';
import 'package:venta_mobile/features/guilds/data/guild_api.dart';
import 'package:venta_mobile/features/guilds/data/models/invite_dto.dart';

/// The invite round's six breaking changes, and the one that bites silently.
///
/// `state` gained `Revoked` - **a new value on an existing field** - and this
/// client decodes it with `$enumDecode`, which throws rather than degrades. One
/// unrecognised value on one row therefore failed `InviteDto.fromJson`, which
/// failed the whole list, which rendered as "Could not load invites." with
/// nothing to say why. That is the case the first group exists for, and it is
/// written against a value nobody has invented yet as well as against `Revoked`,
/// because the next one will arrive the same way.
///
/// The rest: the permission move to `ManageGuild`, `DELETE` becoming a revoke
/// rather than a delete, `maxUses`/`expiresAt` finally being sendable, the
/// preview routes' own `429`, and the `202` that now carries a body.
class _MockAuthRepository extends Mock implements AuthRepository {}

class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.handler);

  final List<RequestOptions> requests = [];
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

  RequestOptions requestFor(String fragment) => requests.firstWhere(
    (r) => r.uri.path.contains(fragment),
    orElse: () => throw StateError(
      'no request matched "$fragment"; saw ${requests.map((r) => r.uri).toList()}',
    ),
  );

  Map<String, dynamic> bodyOf(String fragment) =>
      (requestFor(fragment).data as Map).cast<String, dynamic>();
}

const _base = 'https://example.test';
const _guildId = 'gild_1';

Map<String, dynamic> _invite({
  String state = 'Active',
  String type = 'Permanent',
  Object? channelId,
  Object? maxUses,
  bool temporary = false,
  String targetType = 'None',
}) => <String, dynamic>{
  'id': 'invi_1',
  'type': type,
  'state': state,
  'guildId': _guildId,
  'code': 'ABC23456',
  'useCount': 0,
  'channelId': channelId,
  'maxUses': maxUses,
  'temporary': temporary,
  'targetType': targetType,
};

void main() {
  late _ScriptedAdapter adapter;
  late GuildApi api;

  void build((int, Object?) Function(RequestOptions options) handler) {
    final auth = _MockAuthRepository();
    when(() => auth.baseUrl).thenReturn(_base);
    when(() => auth.ensureValidToken()).thenAnswer((_) async => 'token');

    final client = ApiClient(authRepository: auth);
    adapter = _ScriptedAdapter(handler);
    client.dio.httpClientAdapter = adapter;
    api = GuildApi(client: client);
  }

  group('InviteState decoding', () {
    test('reads the states that existed before this round', () {
      expect(
        InviteDto.fromJson(_invite(state: 'Active')).state,
        InviteState.active,
      );
      expect(
        InviteDto.fromJson(_invite(state: 'Expired')).state,
        InviteState.expired,
      );
    });

    test('Revoked is a state, not a crash', () {
      final invite = InviteDto.fromJson(_invite(state: 'Revoked'));
      expect(invite.state, InviteState.revoked);
    });

    /// The whole point of the fallback. A value invented after this build shipped
    /// must cost one unlabelled row, never the screen - and it must not be
    /// silently folded into `Active`, which would offer a Join button for a link
    /// whose disposition nobody here can read.
    test('a state this build has never heard of does not throw', () {
      expect(
        () => InviteDto.fromJson(_invite(state: 'Quarantined')),
        returnsNormally,
      );
      final invite = InviteDto.fromJson(_invite(state: 'Quarantined'));
      expect(invite.state, InviteState.unknown);
      expect(invite.state.isUsable, isFalse);
      expect(invite.state.badgeLabel, isNotNull);
    });

    test('an unknown type does not throw either', () {
      final invite = InviteDto.fromJson(_invite(type: 'Ephemeral'));
      expect(invite.type, InviteType.unknown);
    });

    test('an unknown target type does not throw either', () {
      final invite = InviteDto.fromJson(_invite(targetType: 'Stage'));
      expect(invite.targetType, InviteTargetType.unknown);
    });

    /// A whole list must survive one bad row's worth of new vocabulary, because
    /// the audit view is exactly where a mixed list turns up.
    test('a mixed list decodes end to end', () async {
      build(
        (_) => (200, [
          _invite(),
          _invite(state: 'Revoked'),
          _invite(state: 'Expired'),
          _invite(state: 'SomethingNew'),
        ]),
      );

      final invites = await api.getInvites(_guildId, includeRevoked: true);

      expect(invites, hasLength(4));
      expect(invites.map((i) => i.state), [
        InviteState.active,
        InviteState.revoked,
        InviteState.expired,
        InviteState.unknown,
      ]);
    });

    /// Revoked and expired are different words on purpose: one is a link that
    /// ran its course, the other is a link somebody took away, and an owner
    /// looking at an audit list wants to know which.
    test('revoked and expired do not read the same', () {
      expect(InviteState.active.badgeLabel, isNull);
      expect(InviteState.expired.badgeLabel, 'Expired');
      expect(InviteState.revoked.badgeLabel, 'Revoked');
      expect(
        InviteState.revoked.badgeLabel,
        isNot(InviteState.expired.badgeLabel),
      );
    });
  });

  group('the new fields', () {
    test('attribution, temporariness and target come off the wire', () {
      final invite = InviteDto.fromJson({
        ..._invite(channelId: 'chan_1', maxUses: 25, temporary: true),
        'inviterId': 'user_1',
        'targetType': 'VoiceChannel',
        'targetUserId': 'user_2',
        'revokedAt': '2026-08-15T12:00:00Z',
        'expiresAt': '2026-09-01T00:00:00Z',
      });

      expect(invite.inviterId, 'user_1');
      expect(invite.temporary, isTrue);
      expect(invite.targetType, InviteTargetType.voiceChannel);
      expect(invite.targetUserId, 'user_2');
      expect(invite.maxUses, 25);
      expect(invite.revokedAt, isNotNull);
      expect(invite.expiresAt, DateTime.utc(2026, 9, 1));
    });

    /// Every one of them is absent on an invite minted before this round, and a
    /// missing field is not a parse failure.
    test('an invite from before this round still decodes', () {
      final invite = InviteDto.fromJson({
        'id': 'invi_old',
        'type': 'Permanent',
        'state': 'Active',
        'guildId': _guildId,
        'code': 'OLD12345',
        'useCount': 3,
      });

      expect(invite.inviterId, isNull);
      expect(invite.temporary, isFalse);
      expect(invite.targetType, InviteTargetType.none);
      expect(invite.revokedAt, isNull);
    });

    /// `DELETE` needs `ManageGuild`, **or** `ManageChannel` on the invite's own
    /// channel - so an invite naming no channel has no channel to hold the
    /// second grant on, and only `ManageGuild` will do.
    test('an unchannelled invite is not revocable by a channel moderator', () {
      expect(
        InviteDto.fromJson(_invite(channelId: 'chan_1'))
            .isRevocableByChannelModerator,
        isTrue,
      );
      expect(
        InviteDto.fromJson(_invite()).isRevocableByChannelModerator,
        isFalse,
      );
      expect(
        InviteDto.fromJson(_invite(channelId: ''))
            .isRevocableByChannelModerator,
        isFalse,
      );
    });
  });

  group('creating', () {
    test('sends all four controls, not just the type', () async {
      build((_) => (200, _invite()));

      await api.createInvite(
        guildId: _guildId,
        type: InviteType.oneTime,
        channelId: 'chan_1',
        expiresAt: DateTime.utc(2026, 9, 1),
        maxUses: 25,
      );

      final body = adapter.bodyOf('/guilds/$_guildId/invite');
      expect(body['type'], 'OneTime');
      expect(body['channelId'], 'chan_1');
      expect(body['expiresAt'], '2026-09-01T00:00:00.000Z');
      expect(body['maxUses'], 25);
    });

    /// Null is the wire's "unlimited" and "never". Zero is refused with a `400`,
    /// because an invite exhausted the moment it exists is a link somebody is
    /// about to share - so the client must never send it, and the picker has no
    /// entry for it.
    test('unlimited and never are null, never zero', () async {
      build((_) => (200, _invite()));

      await api.createInvite(guildId: _guildId);

      final body = adapter.bodyOf('/guilds/$_guildId/invite');
      expect(body['maxUses'], isNull);
      expect(body['expiresAt'], isNull);
      expect(body['maxUses'], isNot(0));
    });

    test('a voice target names its channel', () async {
      build((_) => (200, _invite(channelId: 'chan_1')));

      await api.createInvite(
        guildId: _guildId,
        channelId: 'chan_1',
        targetType: InviteTargetType.voiceChannel,
        temporary: true,
      );

      final body = adapter.bodyOf('/guilds/$_guildId/invite');
      expect(body['targetType'], 'VoiceChannel');
      expect(body['temporary'], isTrue);
    });

    /// The server refuses `maxUses: 0` outright. The client's job is to surface
    /// it rather than swallow it into "could not create an invite" - which it
    /// does by letting the DioException through.
    test('a rejected maxUses reaches the caller', () async {
      build(
        (_) => (400, 'maxUses must be at least 1, or omitted for unlimited.'),
      );

      await expectLater(
        api.createInvite(guildId: _guildId, maxUses: 0),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('listing and revoking', () {
    test('revoked rows are excluded unless asked for', () async {
      build((_) => (200, [_invite()]));

      await api.getInvites(_guildId);
      expect(adapter.requestFor('/invites').uri.queryParameters, isEmpty);

      await api.getInvites(_guildId, includeRevoked: true);
      expect(
        adapter.requests.last.uri.queryParameters['includeRevoked'],
        'true',
      );
    });

    /// `DELETE` answers the invite now, moved to `Revoked` with a `revokedAt` -
    /// the row survives because `guildMember.inviteId` points at it, and
    /// deleting it once took every member who had joined through it.
    test('a delete answers the revoked invite rather than nothing', () async {
      build(
        (_) => (200, {
          ..._invite(state: 'Revoked'),
          'revokedAt': '2026-08-15T12:00:00Z',
        }),
      );

      final invite = await api.deleteInvite('invi_1');

      expect(invite, isNotNull);
      expect(invite!.state, InviteState.revoked);
      expect(invite.revokedAt, isNotNull);
    });

    /// The route is idempotent, and a body this client cannot read must not turn
    /// a successful revoke into a thrown error - the row is revoked either way.
    test('an unreadable delete body is not a failed revoke', () async {
      build((_) => (200, null));
      await expectLater(api.deleteInvite('invi_1'), completion(isNull));

      build((_) => (200, {'unexpected': true}));
      await expectLater(api.deleteInvite('invi_1'), completion(isNull));
    });
  });

  group('previewing', () {
    test('a code that resolves comes back as an invite', () async {
      build((_) => (200, _invite()));
      expect((await api.getInviteByCode('ABC23456')).code, 'ABC23456');
    });

    /// The preview routes are the only unauthenticated surface that will say
    /// whether a code exists, so they carry their own budget - and **a miss
    /// spends a token too**, because a miss is the request worth pricing.
    ///
    /// Told apart from a `404` because the two want opposite copy: one is final,
    /// the other clears itself in seconds. Rendering this as "this invite is
    /// invalid" tells somebody holding a perfectly good link that it is broken.
    test('a 429 is a distinct, retryable condition', () async {
      build(
        (_) => (429, {
          'error': 'rate_limited',
          'message': 'Too many invite lookups; try again shortly.',
        }),
      );

      await expectLater(
        api.getInviteByCode('ABC23456'),
        throwsA(
          isA<InvitePreviewRateLimitedException>().having(
            (e) => e.message,
            'message',
            contains('try again shortly'),
          ),
        ),
      );
    });

    test('a 404 stays a plain failure, not a rate limit', () async {
      build((_) => (404, null));

      await expectLater(
        api.getInviteByCode('NOPE'),
        throwsA(isA<DioException>()),
      );
    });

    /// A revoked invite answers `404`, exactly as a deleted one used to: to
    /// whoever is holding the code it has to be indistinguishable from a code
    /// that was never real.
    test('a revoked code is a 404 like any other miss', () async {
      build((_) => (404, null));
      await expectLater(
        api.getInviteByCode('REVOKED1'),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            404,
          ),
        ),
      );
    });
  });

  group('redeeming', () {
    test('the 202 body is read', () async {
      build(
        (_) => (202, {
          'guildId': _guildId,
          'channelId': 'chan_voice',
          'targetType': 'VoiceChannel',
          'targetUserId': null,
          'joinVoice': true,
          'onboardingRequired': true,
          'temporaryMembership': true,
        }),
      );

      final result = (await api.redeemInvite('invi_1'))!;

      expect(result.joinVoice, isTrue);
      expect(result.onboardingRequired, isTrue);
      expect(result.temporaryMembership, isTrue);
      expect(result.channelId, 'chan_voice');
    });

    /// Every field is additive - the route answered with nothing at all before -
    /// so an empty body must behave exactly as this client did before, and never
    /// undo a join that has already happened.
    test('an empty 202 is still a successful join', () async {
      build((_) => (202, null));
      expect(await api.redeemInvite('invi_1'), isNull);
    });

    test('a body that will not parse does not undo the join', () async {
      build((_) => (202, {'guildId': 42}));
      expect(await api.redeemInvite('invi_1'), isNull);
    });

    /// `joinVoice` is false when the target channel has been deleted or has
    /// stopped being a voice channel since the link was made. The join still
    /// succeeds; only the landing is dropped. Deriving "should I connect" from
    /// `targetType` instead means trying to join a room that is not there.
    test('joinVoice, not targetType, decides whether to connect', () {
      final stale = RedeemResultDto.fromJson({
        'guildId': _guildId,
        'channelId': 'chan_gone',
        'targetType': 'VoiceChannel',
        'joinVoice': false,
      });

      expect(stale.targetType, InviteTargetType.voiceChannel);
      expect(stale.joinVoice, isFalse);
    });

    test('a verification refusal is still told apart from anything else', () async {
      build(
        (_) => (403, {
          'error': 'verification_level_not_met',
          'requiredLevel': 'Medium',
        }),
      );

      await expectLater(
        api.redeemInvite('invi_1'),
        throwsA(
          isA<VerificationLevelNotMetException>().having(
            (e) => e.requiredLevel,
            'requiredLevel',
            'Medium',
          ),
        ),
      );
    });
  });
}
