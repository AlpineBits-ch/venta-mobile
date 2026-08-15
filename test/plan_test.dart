import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/format/date_time_format.dart';
import 'package:venta_mobile/core/network/api_client.dart';
import 'package:venta_mobile/core/network/degradation_interceptor.dart';
import 'package:venta_mobile/features/auth/data/auth_repository.dart';
import 'package:venta_mobile/features/billing/data/billing_api.dart';
import 'package:venta_mobile/features/billing/data/degradation_log.dart';
import 'package:venta_mobile/features/billing/data/models/billing_catalogue_dto.dart';
import 'package:venta_mobile/features/billing/data/entitlement_api.dart';
import 'package:venta_mobile/features/billing/data/models/entitlement_degradation_dto.dart';
import 'package:venta_mobile/features/billing/data/models/entitlement_value.dart';
import 'package:venta_mobile/features/billing/data/models/subscription_dto.dart';
import 'package:venta_mobile/features/billing/data/plan_repository.dart';

/// The read-only plan surface, concentrating on the places where being wrong is
/// silent or expensive:
///
/// * a `404` from billing rendering as "this instance sells nothing" instead of
///   as "there is no billing service here",
/// * an `interval` that is null, or absent because the server predates the
///   field, rendering as "per null",
/// * a value shape or a reason code added after this build shipped taking the
///   screen down or, worse, understating a plan,
/// * and a degradation that never reaches the screen at all, because it rides
///   the response of the request that caused it and nothing fetches one.

class _MockAuthRepository extends Mock implements AuthRepository {}

const _base = 'https://api.venta.test';

/// Answers by path. A null body is a `404`, which is exactly how an instance
/// with no billing service answers the two billing routes.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.handler);

  final List<RequestOptions> requests = [];
  final Object? Function(String path) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final body = handler(options.path);
    return ResponseBody.fromString(
      body == null ? '' : jsonEncode(body),
      body == null ? 404 : 200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _numeric(int? value, {bool unlimited = false}) => {
  'kind': 'numeric',
  'value': value,
  'unlimited': unlimited,
};

Map<String, dynamic> _ladder(String rung, int rank) => {
  'kind': 'ladder',
  'rung': rung,
  'rank': rank,
  'ladder': 'video_quality',
};

/// The guide's own `/entitlements/me` example, trimmed to the keys a user
/// snapshot carries.
Map<String, dynamic> _snapshotJson({
  bool upgradesAvailable = true,
  String licenseMode = 'hosted',
  Map<String, dynamic>? plan = const {
    'name': 'venta_plus',
    'displayName': 'Venta Plus',
    'version': 2,
    'currentVersion': 3,
  },
}) => {
  'licenseMode': licenseMode,
  'upgradesAvailable': upgradesAvailable,
  'vocabularyVersion': 1,
  'subject': {'kind': 'user', 'id': 'user-1'},
  'resolvedAt': '2026-08-15T10:00:00Z',
  'version': 7,
  'ttlSeconds': 60,
  'plan': ?plan,
  'stripePublishableKey': 'pk_live_should_never_be_read',
  'entitlements': {
    'user.upload_max_bytes': _numeric(26214400),
    'user.max_devices': _numeric(5),
    'voice.video_ceiling': _ladder('1080p30', 3),
  },
  'ladders': {
    'video_quality': [
      {'rung': 'none', 'rank': 0},
      {'rung': '1080p30', 'rank': 3},
    ],
  },
  'remedy': 'upgrade_user',
  'actorCanRemedy': true,
};

Map<String, dynamic> _catalogueJson() => {
  'enabled': true,
  'currency': 'usd',
  'plans': [
    {
      'name': 'free_user',
      'displayName': 'Free',
      'description': 'What every account gets.',
      'versionNumber': 1,
      'subjectKind': 'user',
      'priceMinorUnits': null,
      'currency': 'usd',
      'interval': 'month',
      'purchasable': false,
      'entitlements': {
        'user.upload_max_bytes': _numeric(26214400),
        'user.max_devices': _numeric(5),
        'voice.video_ceiling': _ladder('1080p30', 3),
      },
    },
    {
      'name': 'venta_plus',
      'displayName': 'Venta Plus',
      'description': 'For people who send big files.',
      'versionNumber': 3,
      'subjectKind': 'user',
      'priceMinorUnits': 900,
      'currency': 'usd',
      'interval': 'month',
      'purchasable': true,
      'entitlements': {
        'user.upload_max_bytes': _numeric(104857600),
        'user.max_devices': _numeric(null, unlimited: true),
        'voice.video_ceiling': _ladder('2160p60', 6),
      },
    },
    {
      'name': 'pro',
      'displayName': 'Pro',
      'description': 'For communities that stream.',
      'versionNumber': 3,
      'subjectKind': 'guild',
      'priceMinorUnits': 2900,
      'currency': 'usd',
      'interval': 'month',
      'purchasable': true,
      'entitlements': {'voice.max_participants': _numeric(75)},
    },
    {
      'name': 'free',
      'displayName': 'Free server',
      'versionNumber': 1,
      'subjectKind': 'guild',
      'priceMinorUnits': null,
      'currency': 'usd',
      'interval': 'month',
      'purchasable': false,
      'entitlements': {'voice.max_participants': _numeric(10)},
    },
  ],
};

Map<String, dynamic> _subscriptionJson({
  String id = 'sub_1',
  String subjectKind = 'user',
  String subjectId = 'user-1',
  String planName = 'venta_plus',
  String planDisplayName = 'Venta Plus',
  String status = 'active',
  bool cancelAtPeriodEnd = false,
  String? gracePeriodEndsAt,
  Object? interval = 'month',
  bool includeInterval = true,
  bool isPayer = true,
}) => {
  'id': id,
  'subjectKind': subjectKind,
  'subjectId': subjectId,
  'planName': planName,
  'planDisplayName': planDisplayName,
  'versionNumber': 3,
  'status': status,
  'currentPeriodEnd': '2026-09-14T10:12:00Z',
  'cancelAtPeriodEnd': cancelAtPeriodEnd,
  'gracePeriodEndsAt': gracePeriodEndsAt,
  'priceMinorUnits': 900,
  'currency': 'usd',
  if (includeInterval) 'interval': interval,
  'isPayer': isPayer,
};

({PlanRepository repository, _ScriptedAdapter adapter, DegradationLog log})
_build({
  Object? Function(String path)? handler,
  String? Function(String guildId)? guildName,
}) {
  final auth = _MockAuthRepository();
  when(() => auth.baseUrl).thenReturn(_base);
  when(() => auth.ensureValidToken()).thenAnswer((_) async => 'token');

  final log = DegradationLog();
  final adapter = _ScriptedAdapter(
    handler ??
        (path) => switch (path) {
          final p when p.endsWith('/entitlements/me') => _snapshotJson(),
          final p when p.endsWith('/billing/catalogue') => _catalogueJson(),
          _ => null,
        },
  );
  final client = ApiClient(authRepository: auth, degradations: log);
  client.dio.httpClientAdapter = adapter;

  return (
    repository: PlanRepository(
      entitlements: EntitlementApi(client: client),
      billing: BillingApi(client: client),
      guildName: guildName ?? (_) => null,
    ),
    adapter: adapter,
    log: log,
  );
}

/// The default handler plus a subscriptions list, which is a JSON array rather
/// than an object - hence the handler being typed `Object?`.
Object? Function(String) _handlerWith(
  List<Map<String, dynamic>> subscriptions, {
  Map<String, dynamic>? snapshot,
}) =>
    (path) => switch (path) {
      final p when p.endsWith('/entitlements/me') =>
        snapshot ?? _snapshotJson(),
      final p when p.endsWith('/billing/catalogue') => _catalogueJson(),
      _ => subscriptions,
    };

void main() {
  group('entitlement values', () {
    test('reads the three documented shapes', () {
      expect(EntitlementValueDto.fromJson(_numeric(26214400)).value, 26214400);
      expect(
        EntitlementValueDto.fromJson(_numeric(null, unlimited: true)).unlimited,
        isTrue,
      );
      expect(
        EntitlementValueDto.fromJson({'kind': 'flag', 'granted': true}).granted,
        isTrue,
      );
      expect(EntitlementValueDto.fromJson(_ladder('720p30', 2)).rung, '720p30');
    });

    // One new value kind must not take the whole screen offline, and must not
    // render as zero either - zero is a real ceiling meaning "none of this".
    test('a kind this build has never heard of is unknown, not zero', () {
      final value = EntitlementValueDto.fromJson({
        'kind': 'colour',
        'hue': 'blue',
      });

      expect(value.kind, EntitlementValueKind.unknown);
      expect(describeEntitlementValue('guild.emoji_slots', value), 'Unknown');
      expect(
        describeEntitlementValue('guild.emoji_slots', value),
        isNot(contains('0')),
      );
    });

    test('reads unlimited before value', () {
      // A server that sent both would still have to be read as unlimited: the
      // null is the contract, and a number beside it is the bug.
      final value = EntitlementValueDto.fromJson({
        'kind': 'numeric',
        'value': 7,
        'unlimited': true,
      });

      expect(value.unlimited, isTrue);
      expect(describeEntitlementValue('user.max_devices', value), 'Unlimited');
    });

    test('renders bytes, days and counts by the key suffix', () {
      expect(
        describeEntitlementValue(
          'user.upload_max_bytes',
          const EntitlementValueDto.numeric(value: 26214400),
        ),
        '25 MB',
      );
      expect(
        describeEntitlementValue(
          'guild.audit_log_days',
          const EntitlementValueDto.numeric(value: 90),
        ),
        '90 days',
      );
      expect(
        describeEntitlementValue(
          'guild.emoji_slots',
          const EntitlementValueDto.numeric(value: 50),
        ),
        '50',
      );
    });

    // Not a blank. "This plan does not list this key" and "this plan lists it
    // as off" are different facts and a blank says the second about the first.
    test('an absent key is "Not listed", not empty and not "Not included"', () {
      expect(describeEntitlementValue('guild.vanity_url', null), 'Not listed');
      expect(
        describeEntitlementValue(
          'guild.vanity_url',
          const EntitlementValueDto.flag(),
        ),
        'Not included',
      );
    });

    test('names the catalogue keys, and falls back to the key itself', () {
      expect(entitlementKeyLabel('voice.video_ceiling'), 'Video quality');
      expect(
        entitlementKeyLabel('storage.archive_bytes'),
        'storage.archive_bytes',
      );
    });

    test('orders named keys first and unnamed ones last', () {
      final ordered = orderEntitlementKeys([
        'zz.unknown_key',
        'user.max_devices',
        'voice.video_ceiling',
      ]);

      expect(ordered, [
        'voice.video_ceiling',
        'user.max_devices',
        'zz.unknown_key',
      ]);
    });
  });

  group('plans are never ranked against each other', () {
    // The value type used to carry `isMoreThan`, and `PlanOption` used to carry
    // the set of keys where a plan exceeded what the reader has. Both existed
    // to mark another plan as granting more, which presents it as somewhere to
    // move to - the statement a control would make, drawn as an icon. Both are
    // gone, and these assert the absence, because the absence is the
    // requirement rather than a consequence of one.
    test('an entitlement value cannot be ranked against another', () {
      const value = EntitlementValueDto.numeric(value: 5);

      // Equality only: "is this the same value", which the degradation change
      // line needs. Nothing answers "is this the bigger one".
      expect(value == const EntitlementValueDto.numeric(value: 5), isTrue);
      expect(value == const EntitlementValueDto.numeric(value: 6), isFalse);
      expect(
        () => (value as dynamic).isMoreThan(
          const EntitlementValueDto.numeric(value: 1),
        ),
        throwsNoSuchMethodError,
        reason: 'plan values must not be rankable against one another',
      );
    });

    test('a plan option carries no comparison against the reader', () async {
      final harness = _build();
      final overview = await harness.repository.load();
      final option = overview.accountPlanOptions.first;

      // Three fields: the plan, whether it is the reader's, and its keys.
      expect(
        () => (option as dynamic).improvements,
        throwsNoSuchMethodError,
        reason: 'a plan must not carry what it would add over another',
      );
      expect(() => (option as dynamic).addsSomething, throwsNoSuchMethodError);
    });
  });

  group('subscription rendering', () {
    // Computed with the app's own formatter rather than written out, so these
    // assertions are about the sentence being composed and not about which
    // time zone the machine running them happens to be in.
    final periodEnd = formatShortDateTime(DateTime.utc(2026, 9, 14, 10, 12));

    test('says the cadence when the server sent one', () {
      final subscription = SubscriptionDto.fromJson(_subscriptionJson());

      expect(subscription.renewalLine, startsWith('Renews monthly'));
      expect(subscription.standing, SubscriptionStanding.live);
    });

    // The field was added after the first clients were written. A null and an
    // absent one are the same fact and must fall back the same way.
    test('a null interval falls back to the renewal date', () {
      final subscription = SubscriptionDto.fromJson(
        _subscriptionJson(interval: null),
      );

      expect(subscription.interval, isNull);
      expect(subscription.renewalLine, 'Renews $periodEnd');
      expect(subscription.renewalLine, isNot(contains('null')));
      expect(subscription.renewalLine, isNot(contains('month')));
    });

    test('an absent interval falls back the same way', () {
      final subscription = SubscriptionDto.fromJson(
        _subscriptionJson(includeInterval: false),
      );

      expect(subscription.interval, isNull);
      expect(subscription.renewalLine, 'Renews $periodEnd');
      expect(subscription.renewalLine, isNot(contains('null')));
    });

    test('a cadence this build has no word for renders the server token', () {
      final subscription = SubscriptionDto.fromJson(
        _subscriptionJson(interval: 'quarter'),
      );

      expect(subscription.renewalLine, startsWith('Renews every quarter'));
    });

    // "Cancelled" on its own tells somebody nothing about the twenty-eight days
    // they already paid for.
    test('a cancelled subscription says when access stops', () {
      final subscription = SubscriptionDto.fromJson(
        _subscriptionJson(cancelAtPeriodEnd: true),
      );

      expect(subscription.renewalLine, 'Ends $periodEnd');
      expect(subscription.renewalLine, isNot(contains('Renews')));
    });

    test('a grace period gets a plain sentence with a date', () {
      final subscription = SubscriptionDto.fromJson(
        _subscriptionJson(
          status: 'past_due',
          gracePeriodEndsAt: '2026-08-20T10:00:00Z',
        ),
      );

      expect(subscription.standing, SubscriptionStanding.attention);
      expect(
        subscription.gracePeriodLine,
        contains(formatShortDateTime(DateTime.utc(2026, 8, 20, 10))),
      );
    });

    // Stripe adds statuses. An unrecognised one is "needs attention", never
    // "active" - handing out a tier on the strength of an unknown string is the
    // one direction this must not fail in.
    test('an unrecognised status is attention, never live', () {
      expect(
        subscriptionStanding('quantum_superposition'),
        SubscriptionStanding.attention,
      );
      expect(subscriptionStanding('paused'), SubscriptionStanding.attention);
      expect(subscriptionStanding('trialing'), SubscriptionStanding.live);
    });

    // A subject can legitimately have both, and the list carries both.
    test('picks the live subscription over the ended one', () {
      final subscriptions = [
        SubscriptionDto.fromJson(
          _subscriptionJson(id: 'sub_old', status: 'canceled'),
        ),
        SubscriptionDto.fromJson(_subscriptionJson(id: 'sub_new')),
      ];

      expect(pickForSubject(subscriptions, 'user', 'user-1')?.id, 'sub_new');
    });

    test('falls back to an ended one when that is all there is', () {
      final subscriptions = [
        SubscriptionDto.fromJson(
          _subscriptionJson(id: 'sub_old', status: 'canceled'),
        ),
      ];

      expect(pickForSubject(subscriptions, 'user', 'user-1')?.id, 'sub_old');
      expect(pickForSubject(subscriptions, 'user', 'someone-else'), isNull);
    });
  });

  group('degradations', () {
    Map<String, dynamic> degradationJson({
      String reason = 'guild_plan_limit',
      String? boundBy = 'guild',
    }) => {
      'key': 'voice.video_ceiling',
      'requested': _ladder('1080p60', 4),
      'granted': _ladder('720p30', 2),
      'reason': reason,
      'boundBy': ?boundBy,
      'remedy': 'upgrade_guild',
      'actorCanRemedy': false,
      'subject': {'kind': 'guild', 'id': 'guild-1'},
    };

    test('reads the documented shape and names both numbers', () {
      final degradation = EntitlementDegradationDto.fromJson(degradationJson());

      expect(degradation.reason, DegradationReason.guildPlanLimit);
      expect(degradation.boundBy, DegradationBoundBy.guild);
      expect(degradation.change, '1080p60 was reduced to 720p30');
      expect(
        degradation.reason.sentence(degradation.boundBy),
        "Limited by this server's plan.",
      );
    });

    // Without `boundBy` a paired ceiling eventually tells a member paying for
    // their own plan that it limited them, which is both wrong and the exact
    // error the field prevents.
    test('a paired ceiling says which side bound', () {
      final guild = EntitlementDegradationDto.fromJson(
        degradationJson(reason: 'paired_ceiling', boundBy: 'guild'),
      );
      final user = EntitlementDegradationDto.fromJson(
        degradationJson(reason: 'paired_ceiling', boundBy: 'user'),
      );

      expect(
        guild.reason.sentence(guild.boundBy),
        "Limited by this server's plan.",
      );
      expect(user.reason.sentence(user.boundBy), 'Limited by your plan.');
    });

    test('a paired ceiling with no side falls back rather than guessing', () {
      final degradation = EntitlementDegradationDto.fromJson(
        degradationJson(reason: 'paired_ceiling', boundBy: null),
      );

      final sentence = degradation.reason.sentence(degradation.boundBy);
      expect(sentence, 'Limited by a plan.');
      expect(sentence, isNot(contains('your')));
      expect(sentence, isNot(contains('server')));
    });

    // Never a raw code. A reason added after this build shipped is still a
    // reduction the user is owed an account of.
    test('an unknown reason renders a sentence, not the code', () {
      final degradation = EntitlementDegradationDto.fromJson(
        degradationJson(reason: 'sunspots', boundBy: null),
      );

      expect(degradation.reason, DegradationReason.unknown);
      final sentence = degradation.reason.sentence(null);
      expect(sentence, 'A limit applied.');
      expect(sentence, isNot(contains('sunspots')));
    });

    // The whole reason vocabulary in one assertion. Every arm attributes the
    // limit and stops: nothing says what would lift it, nothing measures it
    // against another plan, and nothing describes it as temporary. An earlier
    // draft said a paired ceiling was "the lower of the two", which reads as an
    // invitation to raise one of them.
    test('every reason attributes the limit and offers nothing', () {
      const sides = [
        null,
        DegradationBoundBy.guild,
        DegradationBoundBy.user,
        DegradationBoundBy.unknown,
      ];

      for (final reason in DegradationReason.values) {
        for (final side in sides) {
          final sentence = reason.sentence(side).toLowerCase();

          for (final forbidden in [
            'upgrade',
            'lower',
            'higher',
            'more',
            'instead',
            'available',
            'unlock',
            'you could',
            'you can',
            'change',
            'switch',
            'buy',
            'subscribe',
            'whatever the plan',
            'ask',
            'admin',
            'owner',
            'contact',
          ]) {
            expect(
              sentence.contains(forbidden),
              isFalse,
              reason:
                  '$reason/$side reads as an offer: "$sentence" contains '
                  '"$forbidden"',
            );
          }

          // And it is still a sentence rather than a blank or a code.
          expect(sentence, isNotEmpty);
          expect(sentence.endsWith('.'), isTrue);
        }
      }
    });

    test('names where it happened from the request path', () {
      // Guild voice matches both the voice rule and the server rule, and it is
      // voice.
      expect(
        surfaceForPath('/api/v1/guilds/g1/channels/c1/voice/join'),
        'Voice',
      );
      expect(surfaceForPath('/api/v1/voice/calls/c1/session'), 'Voice');
      expect(surfaceForPath('/api/v1/guilds/g1/emojis'), 'Custom emoji');
      expect(surfaceForPath('/api/v1/guilds/g1'), 'Server settings');
      // A wrong "where" sends somebody looking at the wrong feature.
      expect(surfaceForPath('/api/v1/something/else'), isNull);
    });

    test('the log keeps the newest of a repeated limit, once', () {
      final log = DegradationLog();
      final degradation = EntitlementDegradationDto.fromJson(degradationJson());

      log.record(degradation, surface: 'Voice');
      log.record(degradation, surface: 'Voice');
      log.record(degradation, surface: 'Voice');

      expect(log.entries.value, hasLength(1));
    });

    test('the log is bounded', () {
      final log = DegradationLog();
      for (var i = 0; i < DegradationLog.maxEntries + 10; i++) {
        log.record(
          EntitlementDegradationDto.fromJson(
            degradationJson(),
          ).copyWith(key: 'key.$i'),
        );
      }

      expect(log.entries.value, hasLength(DegradationLog.maxEntries));
      // Newest first.
      expect(log.entries.value.first.degradation.key, 'key.29');
    });

    test('clearing empties it, for the next account to sign in', () {
      final log = DegradationLog();
      log.record(EntitlementDegradationDto.fromJson(degradationJson()));
      log.clear();

      expect(log.entries.value, isEmpty);
    });

    // A degradation rides the 200 of the request that caused it. Nothing
    // fetches one, so an interceptor is the only thing that ever sees one.
    test('the interceptor files one off a successful response', () async {
      final log = DegradationLog();
      final dio = Dio()
        ..httpClientAdapter = _ScriptedAdapter(
          (_) => {
            'roomId': 'channel-123',
            'degradations': [degradationJson()],
          },
        )
        ..interceptors.add(DegradationInterceptor(log));

      final response = await dio.post<Map<String, dynamic>>(
        '$_base/api/v1/guilds/g1/channels/c1/voice/join',
      );

      // The body is handed on unchanged: a reduction is a success, and a client
      // that rolls one back has turned it into a denial with extra steps.
      expect(response.data!['roomId'], 'channel-123');
      expect(log.entries.value, hasLength(1));
      expect(log.entries.value.single.surface, 'Voice');
      expect(log.entries.value.single.degradation.key, 'voice.video_ceiling');
    });

    test(
      'an absent degradations array is the normal case, not an error',
      () async {
        final log = DegradationLog();
        final dio = Dio()
          ..httpClientAdapter = _ScriptedAdapter((_) => {'roomId': 'r'})
          ..interceptors.add(DegradationInterceptor(log));

        await dio.get<Map<String, dynamic>>('$_base/api/v1/anything');

        expect(log.entries.value, isEmpty);
      },
    );

    test('a malformed degradation does not fail the request', () async {
      final log = DegradationLog();
      final dio = Dio()
        ..httpClientAdapter = _ScriptedAdapter(
          (_) => {
            'roomId': 'r',
            'degradations': ['not an object'],
          },
        )
        ..interceptors.add(DegradationInterceptor(log));

      final response = await dio.get<Map<String, dynamic>>(
        '$_base/api/v1/anything',
      );

      expect(response.data!['roomId'], 'r');
      expect(log.entries.value, isEmpty);
    });
  });

  group('loading the overview', () {
    test('reads the snapshot, the catalogue and the subscriptions', () async {
      final harness = _build(
        handler: _handlerWith([_subscriptionJson()]),
        guildName: (_) => null,
      );
      final overview = await harness.repository.load();

      expect(overview.accountPlan?.displayName, 'Venta Plus');
      expect(overview.accountPlan?.isGrandfathered, isTrue);
      expect(overview.catalogue, isNotNull);
      expect(overview.accountSubscription?.id, 'sub_1');
      expect(
        describeEntitlementValue(
          'user.upload_max_bytes',
          overview.snapshot.entitlements['user.upload_max_bytes'],
        ),
        '25 MB',
      );
    });

    test(
      'only the two documented read routes are called, and only with GET',
      () async {
        final harness = _build(handler: _handlerWith([_subscriptionJson()]));
        await harness.repository.load();

        expect(
          harness.adapter.requests.map((r) => '${r.method} ${r.path}').toList(),
          [
            'GET $_base/api/v1/entitlements/me',
            'GET $_base/api/v1/billing/catalogue',
            'GET $_base/api/v1/billing/subscriptions',
          ],
        );
      },
    );

    // "The section must be absent, not empty." A blank plan card is a statement
    // about somebody's account; no billing service is a statement about the
    // instance, and only one of them is true here.
    test('a 404 from billing leaves no catalogue and no zeroes', () async {
      final harness = _build(
        handler: (path) =>
            path.endsWith('/entitlements/me') ? _snapshotJson() : null,
      );
      final overview = await harness.repository.load();

      expect(overview.catalogue, isNull);
      expect(overview.accountPlanOptions, isEmpty);
      expect(overview.guildPlanOptions(null), isEmpty);
      expect(overview.guildPlans, isEmpty);
      expect(overview.accountSubscription, isNull);
      // And the entitlements are still there: the ceilings are worth rendering
      // without a shop beside them.
      expect(overview.accountKeys, isNotEmpty);
    });

    test(
      'subscriptions are not even asked for once the catalogue 404s',
      () async {
        final harness = _build(
          handler: (path) =>
              path.endsWith('/entitlements/me') ? _snapshotJson() : null,
        );
        await harness.repository.load();

        expect(
          harness.adapter.requests.map((r) => r.path),
          isNot(contains('$_base/api/v1/billing/subscriptions')),
        );
      },
    );

    // A 500 is a request to retry, not evidence that the instance sells
    // nothing. Folding it into the absent case would render a temporary outage
    // as a permanent absence.
    test(
      'a 500 from the snapshot fails the load rather than emptying it',
      () async {
        final auth = _MockAuthRepository();
        when(() => auth.baseUrl).thenReturn(_base);
        when(() => auth.ensureValidToken()).thenAnswer((_) async => 'token');

        final client = ApiClient(authRepository: auth);
        client.dio.httpClientAdapter = _FailingAdapter(500);
        final repository = PlanRepository(
          entitlements: EntitlementApi(client: client),
          billing: BillingApi(client: client),
          guildName: (_) => null,
        );

        await expectLater(repository.load(), throwsA(isA<DioException>()));
      },
    );

    test(
      'a 500 from the catalogue also fails rather than hiding the section',
      () async {
        final auth = _MockAuthRepository();
        when(() => auth.baseUrl).thenReturn(_base);
        when(() => auth.ensureValidToken()).thenAnswer((_) async => 'token');

        final client = ApiClient(authRepository: auth);
        client.dio.httpClientAdapter = _MixedAdapter(
          ok: (path) =>
              path.endsWith('/entitlements/me') ? _snapshotJson() : null,
          failStatus: 500,
        );
        final repository = PlanRepository(
          entitlements: EntitlementApi(client: client),
          billing: BillingApi(client: client),
          guildName: (_) => null,
        );

        await expectLater(repository.load(), throwsA(isA<DioException>()));
      },
    );

    test('resolves server names, and describes one it cannot', () async {
      final harness = _build(
        handler: _handlerWith([
          _subscriptionJson(
            id: 'sub_g1',
            subjectKind: 'guild',
            subjectId: 'guild-1',
            planName: 'pro',
            planDisplayName: 'Pro',
          ),
          _subscriptionJson(
            id: 'sub_g2',
            subjectKind: 'guild',
            subjectId: 'guild-2',
            planName: 'pro',
            planDisplayName: 'Pro',
          ),
        ]),
        guildName: (id) => id == 'guild-1' ? 'The Hangout' : null,
      );
      final overview = await harness.repository.load();

      expect(overview.guildPlans.map((g) => g.name), [
        'The Hangout',
        'A server you manage',
      ]);
      expect(overview.commonGuildPlanName, 'pro');
    });

    test(
      'a server with an ended and a live subscription appears once',
      () async {
        final harness = _build(
          handler: _handlerWith([
            _subscriptionJson(
              id: 'sub_old',
              subjectKind: 'guild',
              subjectId: 'guild-1',
              status: 'canceled',
            ),
            _subscriptionJson(
              id: 'sub_new',
              subjectKind: 'guild',
              subjectId: 'guild-1',
            ),
          ]),
        );
        final overview = await harness.repository.load();

        expect(overview.guildPlans, hasLength(1));
        expect(overview.guildPlans.single.subscription.id, 'sub_new');
      },
    );

    test('servers on different plans mark none of them as current', () async {
      final harness = _build(
        handler: _handlerWith([
          _subscriptionJson(
            id: 'a',
            subjectKind: 'guild',
            subjectId: 'guild-1',
            planName: 'pro',
          ),
          _subscriptionJson(
            id: 'b',
            subjectKind: 'guild',
            subjectId: 'guild-2',
            planName: 'free',
          ),
        ]),
      );
      final overview = await harness.repository.load();

      expect(overview.commonGuildPlanName, isNull);
      final options = overview.guildPlanOptions(null);
      expect(options.every((o) => !o.isCurrent), isTrue);
    });
  });

  group('the plan catalogue', () {
    test('lists every plan of one kind, in the order the server sent', () async {
      final harness = _build();
      final overview = await harness.repository.load();
      final options = overview.accountPlanOptions;

      // Not filtered to the ones above the reader, not re-ordered, and the one
      // they are on is in its catalogue position rather than pulled to the top.
      expect(options.map((o) => o.plan.name), ['free_user', 'venta_plus']);
      expect(options.map((o) => o.isCurrent), [false, true]);
    });

    test('every plan lists its own keys, whatever the reader has', () async {
      // The account resolves to Venta Plus here, so the free plan lists smaller
      // numbers. It still lists them: this is a catalogue, and a plan is not
      // dropped or dimmed for being smaller than the reader's.
      final harness = _build();
      final overview = await harness.repository.load();
      final free = overview.accountPlanOptions.firstWhere(
        (o) => o.plan.name == 'free_user',
      );

      expect(free.keys, isNotEmpty);
      expect(
        describeEntitlementValue(
          'user.upload_max_bytes',
          free.plan.entitlements['user.upload_max_bytes'],
        ),
        '25 MB',
      );
    });

    // The operator writes it, so this client cannot know what it says, and no
    // test could guard copy that arrives at runtime.
    test('an operator-written plan description never reaches the model', () {
      final plan = BillingPlanDto.fromJson({
        'name': 'venta_plus',
        'displayName': 'Venta Plus',
        'description': 'Upgrade now at example.com for unlimited everything!',
        'subjectKind': 'user',
        'entitlements': <String, dynamic>{},
      });

      expect(plan.displayName, 'Venta Plus');
      expect(
        () => (plan as dynamic).description,
        throwsNoSuchMethodError,
        reason: 'operator prose must not be renderable on a plan card',
      );
      expect(plan.toJson().containsKey('description'), isFalse);
    });

    // Both are the wire's answer to "could this be bought", and nothing on this
    // platform may turn on that.
    test('purchasability never reaches the model either', () {
      final catalogue = BillingCatalogueDto.fromJson({
        'enabled': true,
        'currency': 'usd',
        'plans': [
          {
            'name': 'venta_plus',
            'displayName': 'Venta Plus',
            'subjectKind': 'user',
            'priceMinorUnits': 900,
            'currency': 'usd',
            'purchasable': true,
            'entitlements': <String, dynamic>{},
          },
        ],
      });

      expect(() => (catalogue as dynamic).enabled, throwsNoSuchMethodError);
      expect(
        () => (catalogue.plans.single as dynamic).purchasable,
        throwsNoSuchMethodError,
      );
      expect(
        () => (catalogue.plans.single as dynamic).priceMinorUnits,
        throwsNoSuchMethodError,
      );
      final json = catalogue.toJson();
      expect(json.containsKey('enabled'), isFalse);
      expect(jsonEncode(json).contains('900'), isFalse);
    });

    test('server plans and account plans never mix', () async {
      final harness = _build();
      final overview = await harness.repository.load();

      expect(
        overview.accountPlanOptions.map((o) => o.plan.subjectKind).toSet(),
        {'user'},
      );
      expect(
        overview.guildPlanOptions('pro').map((o) => o.plan.subjectKind).toSet(),
        {'guild'},
      );
    });

    // A subscription from an older service arrives with a PascalCase kind. It
    // should still land on the servers side rather than nowhere.
    test('subject kinds match whatever case they arrived in', () async {
      final harness = _build(
        handler: _handlerWith([
          _subscriptionJson(
            subjectKind: 'Guild',
            subjectId: 'guild-1',
            planName: 'pro',
          ),
        ]),
      );
      final overview = await harness.repository.load();

      expect(overview.guildPlans, hasLength(1));
    });
  });

  /// What decides whether the settings row exists.
  ///
  /// Deliberately "does this instance publish a plan catalogue" and not "can
  /// this account buy something". A row conditioned on the second would be a
  /// statement that buying is possible, made by the row existing - the same
  /// signal a button gives, and the one this platform must not send.
  group('whether there is a plan catalogue to describe', () {
    test('answers true when the catalogue answers', () async {
      final harness = _build();
      await harness.repository.ensureProbed();

      expect(harness.repository.available.value, isTrue);
    });

    // The probe must not read the entitlement snapshot, because the field it
    // would read there - `upgradesAvailable` - is exactly the purchasability
    // signal this gate is not allowed to be.
    test('asks the catalogue, not the entitlement snapshot', () async {
      final harness = _build();
      await harness.repository.ensureProbed();

      expect(harness.adapter.requests.single.path, endsWith('/catalogue'));
    });

    // Self-hosted: Billing refuses to start and the gateway filters the route.
    test('answers false when the instance has no billing service', () async {
      final harness = _build(handler: (_) => null);
      await harness.repository.ensureProbed();

      expect(harness.repository.available.value, isFalse);
    });

    // The one case where this gate differs from the old one, and it comes out
    // better: a hosted instance with Billing deployed and no Stripe key. It has
    // plans and publishes them and cannot take money. The plan list is a
    // description of the product, so it renders.
    test(
      'answers true on an instance with plans that cannot take money',
      () async {
        final harness = _build(
          handler: (path) => switch (path) {
            final p when p.endsWith('/entitlements/me') => _snapshotJson(),
            final p when p.endsWith('/billing/catalogue') => {
              ..._catalogueJson(),
              'enabled': false,
            },
            _ => <Map<String, dynamic>>[],
          },
        );
        await harness.repository.ensureProbed();

        expect(harness.repository.available.value, isTrue);
      },
    );

    // Null hides the row too. A row that appears late is found on a second
    // visit; a row that appears where there is no catalogue opens an empty
    // screen.
    test('a transport failure stays unanswered rather than guessing', () async {
      final auth = _MockAuthRepository();
      when(() => auth.baseUrl).thenReturn(_base);
      when(() => auth.ensureValidToken()).thenAnswer((_) async => 'token');

      final client = ApiClient(authRepository: auth);
      client.dio.httpClientAdapter = _FailingAdapter(503);
      final repository = PlanRepository(
        entitlements: EntitlementApi(client: client),
        billing: BillingApi(client: client),
        guildName: (_) => null,
      );

      await repository.ensureProbed();

      expect(repository.available.value, isNull);
    });

    test('the probe is asked once, not once per rebuild', () async {
      final harness = _build();
      await Future.wait([
        harness.repository.ensureProbed(),
        harness.repository.ensureProbed(),
      ]);
      await harness.repository.ensureProbed();

      expect(harness.adapter.requests, hasLength(1));
    });

    test('a full load answers it too, and agrees with the probe', () async {
      final present = _build();
      await present.repository.load();
      expect(present.repository.available.value, isTrue);

      final absent = _build(
        handler: (path) =>
            path.endsWith('/entitlements/me') ? _snapshotJson() : null,
      );
      await absent.repository.load();
      expect(absent.repository.available.value, isFalse);
    });
  });
}

/// Fails everything with one status.
class _FailingAdapter implements HttpClientAdapter {
  _FailingAdapter(this.status);

  final int status;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString('', status);

  @override
  void close({bool force = false}) {}
}

/// Answers [ok] where it has something, and [failStatus] where it does not.
class _MixedAdapter implements HttpClientAdapter {
  _MixedAdapter({required this.ok, required this.failStatus});

  final Map<String, dynamic>? Function(String path) ok;
  final int failStatus;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body = ok(options.path);
    if (body == null) return ResponseBody.fromString('', failStatus);
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
