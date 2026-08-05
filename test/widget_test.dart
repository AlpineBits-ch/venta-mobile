import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:venta_mobile/app.dart';
import 'package:venta_mobile/core/di/injector.dart';
import 'package:venta_mobile/features/status/data/status_repository.dart';

class _InMemoryStorage extends Mock implements Storage {}

void main() {
  setUpAll(() async {
    // flutter_secure_storage talks to a platform channel that doesn't exist
    // in the widget-test harness; stub it out so SessionCubit's restore()
    // call resolves instead of throwing MissingPluginException.
    const channel = MethodChannel(
      'plugins.it_nomads.com/flutter_secure_storage',
    );
    TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'readAll') return <String, String>{};
          return null;
        });

    final storage = _InMemoryStorage();
    when(() => storage.write(any(), any())).thenAnswer((_) async {});
    when(() => storage.read(any())).thenReturn(null);
    when(() => storage.delete(any())).thenAnswer((_) async {});
    when(() => storage.clear()).thenAnswer((_) async {});
    HydratedBloc.storage = storage;

    await configureDependencies();
  });

  testWidgets('unauthenticated launch lands on the themed login screen', (
    tester,
  ) async {
    // `App` starts the platform-status poll on launch, and its 60-second
    // periodic timer outlives this test's widget tree - the harness reports
    // that as a pending timer rather than as anything to do with the login
    // screen. Stopped explicitly so the failure mode is "the timer was left
    // running", not a mystery in an unrelated assertion.
    addTearDown(getIt<StatusRepository>().pause);

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Log In'), findsOneWidget);
  });
}
