import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/di/injector.dart';
import 'package:venta_mobile/core/network/api_client.dart';
import 'package:venta_mobile/core/theme/app_theme.dart';
import 'package:venta_mobile/features/auth/data/auth_repository.dart';
import 'package:venta_mobile/features/billing/data/billing_api.dart';
import 'package:venta_mobile/features/billing/data/degradation_log.dart';
import 'package:venta_mobile/features/billing/data/entitlement_api.dart';
import 'package:venta_mobile/features/billing/data/models/entitlement_degradation_dto.dart';
import 'package:venta_mobile/features/billing/data/plan_repository.dart';
import 'package:venta_mobile/features/billing/presentation/screens/plan_screen.dart';

/// What the plan screen actually puts on a handset, and - more importantly -
/// what it must never put there.
///
/// The scope of this screen is a compliance posture rather than an unfinished
/// feature, and it has two halves:
///
/// 1. **No route to a purchase.** No control, no link, no address, no price. An
///    in-app route to an external purchase is the expensive kind of mistake on
///    iOS, and a price with nothing to press beside it is the exact shape the
///    anti-steering rules are about.
/// 2. **No statement that a purchase is possible at all.** The harder half,
///    because breaking it takes a word rather than a widget: copy that frames
///    another plan as attainable, a marker ranking one plan above another, a
///    heading that reads as an offer, an ordering that reads as a ladder, or a
///    section that appears only when buying is available. Each makes the
///    statement a button would make.
///
/// Comments do not stop a well-meaning change from reintroducing either, so the
/// last group here is a guard written three ways over - what renders, what is
/// requested, and what the feature's own source contains - and its banned
/// vocabulary covers both halves: the verbs of buying, and the framing of
/// availability.

class _MockAuthRepository extends Mock implements AuthRepository {}

const _base = 'https://api.venta.test';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.handler);

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

/// The documented payload in full, including the four fields this client
/// deliberately does not model. They are here so the guards are exercised
/// against a response that really does carry them.
Map<String, dynamic> _snapshotJson({bool upgradesAvailable = true}) => {
  'licenseMode': 'hosted',
  'upgradesAvailable': upgradesAvailable,
  'stripePublishableKey': 'pk_live_should_never_be_read',
  'subject': {'kind': 'user', 'id': 'user-1'},
  'plan': {
    'name': 'free_user',
    'displayName': 'Free',
    'version': 1,
    'currentVersion': 1,
  },
  'entitlements': {
    'user.upload_max_bytes': _numeric(26214400),
    'user.max_devices': _numeric(5),
    'voice.video_ceiling': _ladder('1080p30', 3),
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
      'versionNumber': 1,
      'subjectKind': 'user',
      'priceMinorUnits': null,
      'currency': 'usd',
      'interval': 'month',
      'purchasable': false,
      'entitlements': {
        'user.upload_max_bytes': _numeric(26214400),
        'user.max_devices': _numeric(5),
      },
    },
    {
      'name': 'venta_plus',
      'displayName': 'Venta Plus',
      // Deliberately the worst thing an operator could write here. It is on the
      // wire, it is not modelled, and the guards below prove none of it reaches
      // the screen - which is the whole argument for dropping the field.
      'description': 'Upgrade now at venta.gg and unlock unlimited uploads!',
      'versionNumber': 3,
      'subjectKind': 'user',
      'priceMinorUnits': 900,
      'currency': 'usd',
      'interval': 'month',
      'purchasable': true,
      'entitlements': {
        'user.upload_max_bytes': _numeric(104857600),
        'user.max_devices': _numeric(null, unlimited: true),
      },
    },
  ],
};

Map<String, dynamic> _subscriptionJson({
  String subjectKind = 'guild',
  String subjectId = 'guild-1',
  String planDisplayName = 'Pro',
  String planName = 'pro',
  String status = 'active',
  Object? interval = 'month',
  bool includeInterval = true,
  String? gracePeriodEndsAt,
  bool isPayer = true,
}) => {
  'id': 'sub_1',
  'subjectKind': subjectKind,
  'subjectId': subjectId,
  'planName': planName,
  'planDisplayName': planDisplayName,
  'versionNumber': 3,
  'status': status,
  'currentPeriodEnd': '2026-09-14T10:12:00Z',
  'cancelAtPeriodEnd': false,
  'gracePeriodEndsAt': gracePeriodEndsAt,
  'priceMinorUnits': 2900,
  'currency': 'usd',
  if (includeInterval) 'interval': interval,
  'isPayer': isPayer,
};

Map<String, dynamic> _degradationJson() => {
  'key': 'voice.video_ceiling',
  'requested': _ladder('1080p60', 4),
  'granted': _ladder('720p30', 2),
  'reason': 'guild_plan_limit',
  'boundBy': 'guild',
  'remedy': 'upgrade_guild',
  'actorCanRemedy': false,
  'subject': {'kind': 'guild', 'id': 'guild-1'},
};

Future<_Adapter> _install({
  Object? Function(String path)? handler,
  String? Function(String guildId)? guildName,
  List<Map<String, dynamic>> degradations = const [],
}) async {
  await getIt.reset();

  final auth = _MockAuthRepository();
  when(() => auth.baseUrl).thenReturn(_base);
  when(() => auth.ensureValidToken()).thenAnswer((_) async => 'token');

  final log = DegradationLog();
  for (final entry in degradations) {
    log.record(EntitlementDegradationDto.fromJson(entry), surface: 'Voice');
  }

  final adapter = _Adapter(
    handler ??
        (path) => switch (path) {
          final p when p.endsWith('/entitlements/me') => _snapshotJson(),
          final p when p.endsWith('/billing/catalogue') => _catalogueJson(),
          _ => <Map<String, dynamic>>[],
        },
  );
  final client = ApiClient(authRepository: auth, degradations: log);
  client.dio.httpClientAdapter = adapter;

  getIt.registerSingleton<DegradationLog>(log);
  getIt.registerSingleton<PlanRepository>(
    PlanRepository(
      entitlements: EntitlementApi(client: client),
      billing: BillingApi(client: client),
      guildName: guildName ?? (_) => null,
    ),
  );

  return adapter;
}

Widget _wrap(Widget child) => MaterialApp(theme: AppTheme.light, home: child);

/// Pumps the screen and lets its `initState` read land.
Future<void> _open(WidgetTester tester) async {
  await tester.pumpWidget(_wrap(const PlanScreen()));
  await tester.pump(const Duration(seconds: 5));
}

/// Every string the widget tree currently renders.
List<String> _renderedText(WidgetTester tester) => [
  for (final widget in tester.allWidgets)
    if (widget is Text && widget.data != null) widget.data!,
];

/// Copy this feature may never contain, lowercase, checked as substrings.
///
/// Two vocabularies in one list because they are two halves of one rule and
/// splitting them invites somebody to satisfy one and forget the other.
///
/// **The action half** is the verbs and nouns of buying, plus anything that
/// leaves the app. **The implication half** is the framing that presents
/// another plan as attainable without ever naming a route: "unlock", "what
/// you'd get", "available", "more than", comparatives, and the invitations that
/// point at a person instead of a place ("ask an admin" is still a route).
///
/// Every entry was checked against the copy this feature actually renders, and
/// a few near-misses are deliberately narrowed rather than dropped:
///
/// * `payment method`, not `payment`. "A payment did not go through" is a fact
///   about a charge that already failed and has to be sayable.
/// * `included when` and `available`, not `included`. "Included" and "Not
///   included" are how a flag entitlement renders.
/// * `what you get`, not `what you`. The heading "What your account includes"
///   is a description of a list.
/// * `only on`, not `only`. "Only servers you manage or pay for appear here"
///   scopes a list.
const _forbiddenCopy = <String>[
  // Money, in any shape. The catalogue payload carries 900 and 2900 minor units
  // and a currency, and none of it may reach a screen.
  '9.00',
  '29.00',
  'usd',
  'eur',
  'price',
  'cost',
  'per month',
  '/mo',
  'save ',
  'discount',

  // Leaving the app, or being told where to go.
  'http',
  'venta.gg',
  'www.',
  'visit',
  'go to',
  'learn more',
  'find out',
  'see our',
  'website',
  'contact',
  'email us',

  // The verbs of buying.
  'upgrade',
  'downgrade',
  'buy',
  'purchase',
  'subscribe',
  'checkout',
  'stripe',
  'card',
  'payment method',
  'payment details',
  'billing portal',
  'sign up',
  'start your',
  'update your',

  // The framing of availability. None of these names a route, and every one of
  // them says a different plan is there to be had.
  'unlock',
  'available',
  'eligible',
  'entitled to',
  'you could',
  'you can have',
  'you get',
  'what you get',
  "what you'd get",
  'get more',
  'more than',
  'better',
  'best',
  'higher',
  'top tier',
  'premium',
  'included when',
  'only on',
  'requires',
  'instead',
  'compare',
  'switch',
  'change plan',
  'move to',
  'offer',
  'adds',
  'ask an',
  'ask the',
  'ask your',
  'admin can',
  'owner can',
];

/// Banned on screen but not in source, because in source they are not copy.
///
/// `$` is string interpolation on nearly every line that builds a sentence.
/// `trial` is Stripe's own `trialing` status, which arrives on the wire and is
/// matched by name - it is deliberately never rendered, which is exactly what
/// this asserts.
const _forbiddenOnScreen = <String>[r'$', '€', '£', '¥', 'trial'];

/// Identifiers and paths this feature's *code* may never contain.
///
/// Distinct from [_forbiddenCopy] because it is matched against code rather
/// than against strings: banning the word "upgrade" in code would trip on the
/// wire field `upgradesAvailable`, and banning "available" would trip on the
/// repository's own `available` notifier. These are mechanisms, and a mechanism
/// present but unused is the first half of somebody adding the second half.
const _forbiddenMechanisms = <String>[
  // Leaving the app is how an in-app pointer at an external shop is built,
  // whatever the copy around it says.
  'url_launcher',
  'launchUrl',
  'Share.share',
  'Clipboard.setData',
  'https://',
  'http://',
  'venta.gg',
  // Every write on the billing surface. The gateway prefix is a literal in this
  // feature, so a path is greppable.
  'billing/subscriptions/',
  'payment-methods',
  'setup-intent',
  'preview-change',
  '/invoices',
  'stripePublishableKey',
  // The two fields that answer "can this be bought", which nothing here may
  // branch on - including the settings row's own visibility.
  'upgradesAvailable',
  'actorCanRemedy',
  'purchasable',
  'priceMinorUnits',
  // And the verbs, in case a future route is spelled some other way.
  '.post(',
  '.put(',
  '.patch(',
  '.delete(',
];

/// [source] with comments and directives removed.
///
/// Comments go because this feature's comments necessarily discuss what is
/// banned in order to explain why it is absent, and the explanation would trip
/// the guard it explains.
///
/// `import`, `export` and `part` go because their literals are file paths, and
/// a path is not copy: `data/models/...` contains "/mo", which is a price
/// suffix everywhere except in a directory name.
String _codeOf(String source) => source
    .split('\n')
    .map((line) => line.trimLeft())
    .where((line) => !line.startsWith('///'))
    .where((line) => !line.startsWith('//'))
    .where((line) => !line.startsWith('import '))
    .where((line) => !line.startsWith('export '))
    .where((line) => !line.startsWith('part '))
    .join('\n');

/// Single- and double-quoted Dart string literals, one line at a time.
final _literalPattern = RegExp(
  r"'(?:[^'\\"
  '\n'
  r"]|\\.)*'"
  r'|'
  r'"(?:[^"\\'
  '\n'
  r']|\\.)*"',
);

/// Every string literal in [code].
///
/// Copy is checked against these rather than against the whole file so that an
/// identifier like `available` is left alone while a literal `'available'` is
/// not. Interpolation stays inside its literal, which is harmless: the words
/// around it are exactly what needs checking.
///
/// Adjacent literals are matched separately, so a banned phrase split across a
/// line break would slip through here. That is the case the rendered-text guard
/// catches, which is one of the reasons there are two.
Iterable<String> _stringLiterals(String code) =>
    _literalPattern.allMatches(code).map((match) => match.group(0)!);

void main() {
  tearDown(getIt.reset);

  group('what it shows', () {
    testWidgets('the current plan and what it includes', (tester) async {
      await tester.runAsync(_install);
      await _open(tester);

      expect(find.text('Free'), findsWidgets);
      expect(
        find.text('What your account includes'.toUpperCase()),
        findsOneWidget,
      );
      // Once in the includes list and once per plan card that lists it, which
      // is the point of the plan cards.
      expect(find.text('Largest upload'), findsWidgets);
      expect(find.text('25 MB'), findsWidgets);
      expect(find.text('Devices on your account'), findsWidgets);
      expect(find.text('Video quality'), findsWidgets);
      expect(find.text('1080p30'), findsOneWidget);
    });

    testWidgets('a plan with no plan object still shows the limits', (
      tester,
    ) async {
      await tester.runAsync(
        () => _install(
          handler: (path) => switch (path) {
            final p when p.endsWith('/entitlements/me') => {
              ..._snapshotJson(),
            }..remove('plan'),
            final p when p.endsWith('/billing/catalogue') => _catalogueJson(),
            _ => <Map<String, dynamic>>[],
          },
        ),
      );
      await _open(tester);

      // Not an invented "Free" tier. Nobody configured one, and putting a tier
      // boundary on the screen of somebody who is not being charged is the one
      // sentence that reads as a paywall.
      expect(find.text('Standard limits'), findsOneWidget);
      expect(find.text('Largest upload'), findsWidgets);
    });

    testWidgets('every plan in the catalogue, with what each includes', (
      tester,
    ) async {
      await tester.runAsync(_install);
      await _open(tester);

      expect(find.text('Account plans'.toUpperCase()), findsOneWidget);
      // Both plans, not only the ones above the reader.
      expect(find.text('Free'), findsWidgets);
      expect(find.text('Venta Plus'), findsOneWidget);
      // What Venta Plus includes, in human terms.
      expect(find.text('100 MB'), findsOneWidget);
      expect(find.text('Unlimited'), findsOneWidget);
      // Which one is theirs, stated once and neutrally.
      expect(find.text('Current'), findsOneWidget);
    });

    // Every plan is drawn the same. The old version marked keys where a plan
    // exceeded the reader's with an upward arrow, which is a ladder pointing
    // at somewhere to go.
    testWidgets('no plan is marked as exceeding another', (tester) async {
      await tester.runAsync(_install);
      await _open(tester);

      expect(find.byIcon(Icons.arrow_upward), findsNothing);
      expect(find.byIcon(Icons.arrow_upward_rounded), findsNothing);
      expect(find.byIcon(Icons.trending_up), findsNothing);
      expect(find.byIcon(Icons.star), findsNothing);
      expect(find.byIcon(Icons.workspace_premium), findsNothing);
      expect(find.byIcon(Icons.lock_outline), findsNothing);
    });

    // The operator writes it, so no test could guard what it says. The fixture
    // carries the worst plausible version of it.
    testWidgets('an operator-written plan description never renders', (
      tester,
    ) async {
      await tester.runAsync(_install);
      await _open(tester);

      expect(find.textContaining('Upgrade now'), findsNothing);
      expect(find.textContaining('unlock'), findsNothing);
      expect(find.textContaining('venta.gg'), findsNothing);
    });

    testWidgets('servers and their plans', (tester) async {
      await tester.runAsync(
        () => _install(
          handler: (path) => switch (path) {
            final p when p.endsWith('/entitlements/me') => _snapshotJson(),
            final p when p.endsWith('/billing/catalogue') => _catalogueJson(),
            _ => [_subscriptionJson()],
          },
          guildName: (_) => 'The Hangout',
        ),
      );
      await _open(tester);

      expect(find.text('Your servers'.toUpperCase()), findsOneWidget);
      expect(find.text('The Hangout'), findsOneWidget);
      expect(find.text('Pro'), findsOneWidget);
      expect(find.textContaining('Renews monthly'), findsOneWidget);
    });

    testWidgets('a null interval renders a date, never "per null"', (
      tester,
    ) async {
      await tester.runAsync(
        () => _install(
          handler: (path) => switch (path) {
            final p when p.endsWith('/entitlements/me') => _snapshotJson(),
            final p when p.endsWith('/billing/catalogue') => _catalogueJson(),
            _ => [_subscriptionJson(interval: null)],
          },
          guildName: (_) => 'The Hangout',
        ),
      );
      await _open(tester);

      expect(find.textContaining('Renews '), findsOneWidget);
      expect(find.textContaining('null'), findsNothing);
      expect(find.textContaining('monthly'), findsNothing);
    });

    testWidgets('an absent interval renders the same fallback', (tester) async {
      await tester.runAsync(
        () => _install(
          handler: (path) => switch (path) {
            final p when p.endsWith('/entitlements/me') => _snapshotJson(),
            final p when p.endsWith('/billing/catalogue') => _catalogueJson(),
            _ => [_subscriptionJson(includeInterval: false)],
          },
          guildName: (_) => 'The Hangout',
        ),
      );
      await _open(tester);

      expect(find.textContaining('Renews '), findsOneWidget);
      expect(find.textContaining('null'), findsNothing);
    });

    testWidgets('a load failure is its own state, with a retry', (
      tester,
    ) async {
      await tester.runAsync(() => _install(handler: (_) => null));
      await _open(tester);

      // Not a spinner that never stops, and not an empty plan card either.
      expect(find.text('Could not load your plan.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });

  group('degradations', () {
    testWidgets('a reduction renders with its reason and where it happened', (
      tester,
    ) async {
      await tester.runAsync(() => _install(degradations: [_degradationJson()]));
      await _open(tester);

      expect(find.text('Recently limited'), findsNothing);
      expect(find.text('Recently limited'.toUpperCase()), findsOneWidget);
      expect(find.text('Video quality in Voice'), findsOneWidget);
      expect(find.text('1080p60 was reduced to 720p30'), findsOneWidget);
      // Attribution and nothing else. Not what would lift it, not how this
      // compares to the plans listed above, not that it could be otherwise.
      expect(find.text("Limited by this server's plan."), findsOneWidget);
      // Said out loud, because a reduction is a success and a client that
      // implies otherwise has turned it into a denial with extra steps.
      expect(find.textContaining('Nothing failed.'), findsOneWidget);
    });

    testWidgets('nothing reduced means no section at all', (tester) async {
      await tester.runAsync(_install);
      await _open(tester);

      expect(find.textContaining('Recently limited'), findsNothing);
      expect(find.byIcon(Icons.trending_down), findsNothing);
    });

    testWidgets('an unknown reason code is never rendered raw', (tester) async {
      await tester.runAsync(
        () => _install(
          degradations: [
            {..._degradationJson(), 'reason': 'sunspots', 'boundBy': null},
          ],
        ),
      );
      await _open(tester);

      expect(find.text('A limit applied.'), findsOneWidget);
      expect(find.textContaining('sunspots'), findsNothing);
    });
  });

  group('an instance with no billing service', () {
    testWidgets('shows the limits and no plan lists at all', (tester) async {
      await tester.runAsync(
        () => _install(
          handler: (path) =>
              path.endsWith('/entitlements/me') ? _snapshotJson() : null,
        ),
      );
      await _open(tester);

      // The ceilings are still worth having.
      expect(find.text('Largest upload'), findsOneWidget);
      // And the lists are absent rather than empty headings. A heading over
      // nothing reads as "there are none", which is a claim this client is in
      // no position to make.
      expect(find.text('Account plans'.toUpperCase()), findsNothing);
      expect(find.text('Server plans'.toUpperCase()), findsNothing);
      expect(find.text('Your servers'.toUpperCase()), findsNothing);
      // No zero, no blank plan card.
      expect(find.text('0'), findsNothing);
      expect(find.text('Venta Plus'), findsNothing);
    });

    testWidgets('the settings row is absent when there is no catalogue', (
      tester,
    ) async {
      await tester.runAsync(
        () => _install(
          handler: (path) =>
              path.endsWith('/entitlements/me') ? _snapshotJson() : null,
        ),
      );

      final repository = getIt<PlanRepository>();
      await tester.runAsync(repository.ensureProbed);

      expect(repository.available.value, isFalse);
    });

    // The gate is about the deployment, not about the reader. An instance that
    // publishes plans and cannot take money still has plans to describe, and a
    // row that appeared only where buying works would announce that buying
    // works.
    testWidgets('the settings row is present wherever there are plans', (
      tester,
    ) async {
      await tester.runAsync(
        () => _install(
          handler: (path) => switch (path) {
            final p when p.endsWith('/entitlements/me') => _snapshotJson(
              upgradesAvailable: false,
            ),
            final p when p.endsWith('/billing/catalogue') => {
              ..._catalogueJson(),
              'enabled': false,
            },
            _ => <Map<String, dynamic>>[],
          },
        ),
      );

      final repository = getIt<PlanRepository>();
      await tester.runAsync(repository.ensureProbed);

      expect(repository.available.value, isTrue);
    });
  });

  /// The constraint most likely to be eroded by a future well-meaning change.
  ///
  /// Written three ways on purpose - what is rendered, what is requested, and
  /// what the source contains - because each catches something the others
  /// cannot. A widget assertion misses copy on a screen this test does not
  /// pump; a request assertion misses a `launchUrl`; a source scan misses a
  /// string assembled at runtime.
  group('nothing offers a purchase or says one is possible', () {
    testWidgets('nothing rendered is pressable, priced or a link', (
      tester,
    ) async {
      await tester.runAsync(
        () => _install(
          handler: (path) => switch (path) {
            final p when p.endsWith('/entitlements/me') => _snapshotJson(),
            final p when p.endsWith('/billing/catalogue') => _catalogueJson(),
            // Past due with a grace period, so the one sentence on this screen
            // that mentions a failed charge is actually exercised by the guard
            // rather than quietly skipped.
            _ => [
              _subscriptionJson(
                status: 'past_due',
                gracePeriodEndsAt: '2026-08-20T10:00:00Z',
                isPayer: false,
              ),
            ],
          },
          guildName: (_) => 'The Hangout',
          degradations: [_degradationJson()],
        ),
      );
      await _open(tester);

      // Nothing to press. The back button lives in the app bar and is an
      // IconButton, so the button finders below are scoped to the body.
      expect(find.byType(FilledButton), findsNothing);
      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.byType(TextButton), findsNothing);
      expect(find.byType(OutlinedButton), findsNothing);
      // No open-in-new affordance, which is what an external purchase link
      // would look like on every other screen in this app, and no chevron,
      // which is what a row that goes somewhere looks like on this one.
      expect(find.byIcon(Icons.open_in_new), findsNothing);
      expect(find.byIcon(Icons.chevron_right), findsNothing);

      final rendered = _renderedText(tester).join('\n').toLowerCase();
      // The fixture really did carry the things being banned, or this proves
      // nothing about a screen that happened to render almost nothing.
      expect(rendered, contains('venta plus'));
      expect(rendered, contains('limited by'));
      expect(rendered, contains('payment did not go through'));

      for (final forbidden in [..._forbiddenCopy, ..._forbiddenOnScreen]) {
        expect(
          rendered.contains(forbidden),
          isFalse,
          reason:
              'the plan screen rendered "$forbidden", which is either a route '
              'to a purchase or a statement that one is possible',
        );
      }
    });

    testWidgets('only the three read routes are ever called', (tester) async {
      final adapter = await tester.runAsync(
        () => _install(
          handler: (path) => switch (path) {
            final p when p.endsWith('/entitlements/me') => _snapshotJson(),
            final p when p.endsWith('/billing/catalogue') => _catalogueJson(),
            _ => [_subscriptionJson()],
          },
        ),
      );
      await _open(tester);

      expect(adapter!.requests.map((r) => '${r.method} ${r.path}').toList(), [
        'GET $_base/api/v1/entitlements/me',
        'GET $_base/api/v1/billing/catalogue',
        'GET $_base/api/v1/billing/subscriptions',
      ]);
    });

    // The durable half. A widget test only sees the tree it pumped; these two
    // read every line the feature ships, whether or not anything renders it
    // today.
    test('the feature ships no purchase mechanism and no way out of the app', () {
      final sources = _featureSources();

      for (final file in sources) {
        final code = _codeOf(file.readAsStringSync());

        for (final forbidden in _forbiddenMechanisms) {
          expect(
            code.contains(forbidden),
            isFalse,
            reason:
                '${file.path} contains "$forbidden". This platform describes '
                'plans and must neither offer a route to buying one nor branch '
                'on whether buying is possible - see the class comment on '
                'BillingApi.',
          );
        }
      }
    });

    // The framing half, and the one a mechanism scan cannot see. A screen can
    // be perfectly free of buttons, links and prices and still tell the reader
    // that another plan is theirs for the taking, in a sentence.
    test('no string in the feature frames another plan as attainable', () {
      final sources = _featureSources();
      var literalsScanned = 0;

      for (final file in sources) {
        for (final literal in _stringLiterals(
          _codeOf(file.readAsStringSync()),
        )) {
          literalsScanned++;
          final lowered = literal.toLowerCase();

          for (final forbidden in _forbiddenCopy) {
            expect(
              lowered.contains(forbidden),
              isFalse,
              reason:
                  '${file.path} contains the string $literal, which includes '
                  '"$forbidden". This platform says which plan you are on and '
                  'what each plan includes. It does not say that another one '
                  'could be had, or where.',
            );
          }
        }
      }

      expect(
        literalsScanned,
        greaterThan(50),
        reason: 'the literal scan found almost nothing, so it is not scanning',
      );
    });
  });
}

/// Every non-generated source file the billing feature ships.
List<File> _featureSources() {
  final sources = Directory('lib/features/billing')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .where((file) => !file.path.endsWith('.freezed.dart'))
      .where((file) => !file.path.endsWith('.g.dart'))
      .toList();

  expect(
    sources,
    isNotEmpty,
    reason: 'the guard found no sources, so it is guarding nothing',
  );
  return sources;
}
