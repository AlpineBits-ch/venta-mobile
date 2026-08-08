import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/di/injector.dart';
import 'package:venta_mobile/core/realtime/realtime_event.dart';
import 'package:venta_mobile/core/realtime/realtime_service.dart';
import 'package:venta_mobile/core/realtime/realtime_transport.dart';
import 'package:venta_mobile/core/theme/app_theme.dart';
import 'package:venta_mobile/features/auth/data/auth_repository.dart';
import 'package:venta_mobile/features/status/data/status_api.dart';
import 'package:venta_mobile/features/status/data/status_repository.dart';
import 'package:venta_mobile/features/status/presentation/screens/platform_status_screen.dart';
import 'package:venta_mobile/features/status/presentation/widgets/platform_status_banner.dart';

/// What the two status surfaces actually put on screen.
///
/// The three assertions worth having are all about restraint: the banner says
/// exactly what the server said and nothing composed here, it disappears when
/// dismissed, and a status endpoint that can't be reached produces no banner at
/// all - only the settings screen admits to it.

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockRealtimeService extends Mock implements RealtimeService {}

class _Adapter implements HttpClientAdapter {
  _Adapter(this.body);

  /// Null answers `503`. Mutable so a test can change what the next poll finds.
  Map<String, dynamic>? body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    body == null ? '' : jsonEncode(body),
    body == null ? 503 : 200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

const _title = 'Elevated error rates affecting Sign-in and accounts';
const _body =
    'Some people may not be able to sign in or create an account. We are '
    'investigating.';

Map<String, dynamic> get _summaryJson => {
  'indicator': 'degraded',
  'updatedAt': '2026-08-05T12:04:20Z',
  'banner': {
    'title': _title,
    'body': _body,
    'severity': 'warning',
    'incidentReference': 'VNT-4KQ7M2XB',
    'url': 'https://status.venta.gg/incident?ref=VNT-4KQ7M2XB',
  },
  'components': [
    {
      'key': 'accounts',
      'name': 'Sign-in and accounts',
      'status': 'degraded_performance',
      'uptime90d': 0.9987,
    },
  ],
};

/// Registers a repository over a scripted transport and loads it once.
Future<({StatusRepository repository, _Adapter adapter})> _install(
  Map<String, dynamic>? body,
) async {
  await getIt.reset();

  final auth = _MockAuthRepository();
  when(() => auth.baseUrl).thenReturn('https://api.venta.test');

  final realtime = _MockRealtimeService();
  when(
    () => realtime.events,
  ).thenAnswer((_) => const Stream<RealtimeEvent>.empty());
  when(
    () => realtime.connectionStatus,
  ).thenAnswer((_) => const Stream<RealtimeConnectionStatus>.empty());

  final adapter = _Adapter(body);
  final repository = StatusRepository(
    api: StatusApi(
      authRepository: auth,
      dio: Dio()..httpClientAdapter = adapter,
    ),
    authRepository: auth,
    realtimeService: realtime,
  );
  getIt.registerSingleton<StatusRepository>(repository);
  await repository.refresh();
  return (repository: repository, adapter: adapter);
}

Widget _wrap(Widget child) => MaterialApp(theme: AppTheme.light, home: child);

void main() {
  tearDown(getIt.reset);

  testWidgets('renders the server copy verbatim and dismisses', (tester) async {
    await tester.runAsync(() => _install(_summaryJson));

    await tester.pumpWidget(
      _wrap(
        const PlatformStatusScope(child: Scaffold(body: Text('app content'))),
      ),
    );
    await tester.pump();

    // Not a sentence assembled from the component name and a status enum - the
    // server's own title and body, character for character.
    expect(find.text(_title), findsOneWidget);
    expect(find.text(_body), findsOneWidget);
    // And the app underneath is not blocked by it.
    expect(find.text('app content'), findsOneWidget);

    await tester.tap(find.byTooltip('Dismiss'));
    await tester.pumpAndSettle();

    expect(find.text(_title), findsNothing);
    expect(find.text('app content'), findsOneWidget);
  });

  testWidgets('says nothing app-wide when the status call itself fails', (
    tester,
  ) async {
    await tester.runAsync(() => _install(null));

    await tester.pumpWidget(
      _wrap(
        const PlatformStatusScope(child: Scaffold(body: Text('app content'))),
      ),
    );
    await tester.pump();

    // "A failed status check is not evidence of an incident and 'could not load
    // status' is noise." Nothing but the app.
    expect(find.textContaining('status'), findsNothing);
    expect(find.text('app content'), findsOneWidget);
  });

  testWidgets('the settings screen does admit it could not be verified', (
    tester,
  ) async {
    await tester.runAsync(() => _install(null));

    await tester.pumpWidget(_wrap(const PlatformStatusScreen()));
    // The screen fires its own refresh in `initState`; advancing fake time lets
    // that round-trip finish instead of leaving a timer pending at teardown.
    await tester.pump(const Duration(seconds: 10));

    expect(
      find.text('The system status could not be verified'),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('the settings screen lists components and uptime', (
    tester,
  ) async {
    await tester.runAsync(() => _install(_summaryJson));

    await tester.pumpWidget(_wrap(const PlatformStatusScreen()));
    // The screen fires its own refresh in `initState`; advancing fake time lets
    // that round-trip finish instead of leaving a timer pending at teardown.
    await tester.pump(const Duration(seconds: 10));

    expect(find.text('Degraded performance'), findsWidgets);
    expect(find.text('Sign-in and accounts'), findsOneWidget);
    // Two decimals - the difference between 99.9% and 99.87% is the point of
    // publishing the number at all.
    expect(find.text('99.87%'), findsOneWidget);
  });

  // The banner is installed as `MaterialApp.builder`, directly above the
  // router's navigator, and the trap there is silent: if the tree *shape*
  // changes when the banner appears - a bare child one moment, a Column the
  // next - the navigator's element is re-parented, every route is rebuilt from
  // scratch, and the user loses their half-written message to an outage notice.
  // Hence the always-present empty slot in `PlatformStatusScope`.
  testWidgets('a banner appearing does not reset the screen underneath', (
    tester,
  ) async {
    final installed = await tester.runAsync(() => _install(null));

    await tester.pumpWidget(
      _wrap(const PlatformStatusScope(child: _Counter())),
    );
    await tester.pump();
    expect(find.text('banner: no'), findsOneWidget);

    await tester.tap(find.text('count: 0'));
    await tester.pump();
    expect(find.text('count: 1'), findsOneWidget);

    // The incident starts while the user is mid-task.
    installed!.adapter.body = _summaryJson;
    await tester.runAsync(installed.repository.refresh);
    await tester.pumpAndSettle();

    expect(find.text(_title), findsOneWidget);
    // Same State object, not a fresh one.
    expect(find.text('count: 1'), findsOneWidget);
  });
}

/// A stand-in for any screen with state worth not losing.
class _Counter extends StatefulWidget {
  const _Counter();

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text(
            'banner: ${getIt<StatusRepository>().snapshot.value.visibleBanner == null ? 'no' : 'yes'}',
          ),
          GestureDetector(
            onTap: () => setState(() => _count++),
            child: Text('count: $_count'),
          ),
        ],
      ),
    );
  }
}
