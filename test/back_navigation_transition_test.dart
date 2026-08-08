import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/routing/app_router.dart';
import 'package:venta_mobile/core/routing/back_navigation.dart';
import 'package:venta_mobile/core/session/session_cubit.dart';
import 'package:venta_mobile/core/widgets/app_back_button.dart';
import 'package:venta_mobile/features/auth/data/auth_repository.dart';

class _FakeAuthRepository extends Mock implements AuthRepository {}

/// Backing out of a screen that is the only entry on the stack - what a
/// cold-start restore, a deep link and a notification tap all leave behind -
/// has to *look* like a pop: the parent revealed from underneath, moving
/// left-to-right, not sliding in from the right as a push.
///
/// Measured rather than asserted on the widget tree, because the direction is
/// the whole bug: the parent's x position must start left of where it settles.

Widget _screen(String label, String parent) => Scaffold(
  appBar: AppBar(leading: AppBackButton(fallbackLocation: parent)),
  body: Center(child: Text(label)),
);

GoRoute _route(String path, Widget Function() build) => GoRoute(
  path: path,
  pageBuilder: (context, state) => appPage(state, build()),
);

Future<void> _pumpRouter(WidgetTester tester, GoRouter router) async {
  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(platform: TargetPlatform.android),
    ),
  );
  await tester.pumpAndSettle();
}

/// x of [label] one frame into the back transition, and where it ends up.
Future<(double, double)> _tapBack(WidgetTester tester, String label) async {
  await tester.tap(find.byTooltip('Back'));
  await tester.pump();
  await tester.pump();
  final start = tester.getTopLeft(find.text(label)).dx;
  await tester.pumpAndSettle();
  return (start, tester.getTopLeft(find.text(label)).dx);
}

void main() {
  testWidgets('back from a lone leaf route reveals its parent', (tester) async {
    await _pumpRouter(
      tester,
      GoRouter(
        initialLocation: '/settings/privacy',
        routes: [
          _route('/settings', () => _screen('SETTINGS', '/home')),
          _route('/settings/privacy', () => _screen('PRIVACY', '/settings')),
        ],
      ),
    );
    expect(find.text('PRIVACY'), findsOneWidget);

    final (start, settled) = await _tapBack(tester, 'SETTINGS');
    expect(start, lessThan(settled), reason: 'parent slid in from the right');
  });

  testWidgets('back from a lone channel reveals the shell', (tester) async {
    await _pumpRouter(
      tester,
      GoRouter(
        initialLocation: '/server/g1/channel/c1',
        routes: [
          ShellRoute(
            // Stands in for `AppShell`, which needs the DI container - what
            // matters here is that the shell's own page in the root navigator
            // is an `appPage`, the way `buildAppRouter` builds it.
            pageBuilder: (context, state, child) => appPage(
              state,
              Row(
                children: [
                  const SizedBox(width: 60),
                  Expanded(child: child),
                ],
              ),
            ),
            routes: [
              GoRoute(
                path: '/server/:guildId',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: Scaffold(body: Center(child: Text('GUILD'))),
                ),
              ),
            ],
          ),
          _route(
            '/server/:guildId/channel/:channelId',
            () => _screen('CHANNEL', '/server/g1'),
          ),
        ],
      ),
    );
    expect(find.text('CHANNEL'), findsOneWidget);

    final (start, settled) = await _tapBack(tester, 'GUILD');
    expect(start, lessThan(settled), reason: 'shell slid in from the right');
  });

  testWidgets('a router refresh mid-transition keeps the reveal', (
    tester,
  ) async {
    final refresh = ValueNotifier<int>(0);
    addTearDown(refresh.dispose);
    await _pumpRouter(
      tester,
      GoRouter(
        initialLocation: '/settings/privacy',
        refreshListenable: refresh,
        routes: [
          _route('/settings', () => _screen('SETTINGS', '/home')),
          _route('/settings/privacy', () => _screen('PRIVACY', '/settings')),
        ],
      ),
    );

    await tester.tap(find.byTooltip('Back'));
    await tester.pump();
    await tester.pump();
    final start = tester.getTopLeft(find.text('SETTINGS')).dx;
    await tester.pump(const Duration(milliseconds: 100));
    final midway = tester.getTopLeft(find.text('SETTINGS')).dx;

    // Anything that re-runs `redirect` rebuilds every page mid-animation.
    refresh.value++;
    await tester.pump();
    expect(
      tester.getTopLeft(find.text('SETTINGS')).dx,
      closeTo(midway, 1),
      reason: 'the transition jumped when the router rebuilt',
    );

    await tester.pumpAndSettle();
    expect(start, lessThan(tester.getTopLeft(find.text('SETTINGS')).dx));
  });

  test('the app shell builds its own page', () {
    final authRepository = _FakeAuthRepository();
    when(
      () => authRepository.sessionExpired,
    ).thenAnswer((_) => const Stream<void>.empty());
    final router = buildAppRouter(SessionCubit(authRepository: authRepository));

    final shell = router.configuration.routes.whereType<ShellRoute>().single;
    // Without one, go_router wraps the shell in a `MaterialPage` that can only
    // push - see the comment on it in `buildAppRouter`.
    expect(shell.pageBuilder, isNotNull);
  });
}
