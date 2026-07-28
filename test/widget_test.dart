import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:venta_mobile/app.dart';
import 'package:venta_mobile/core/di/injector.dart';

class _InMemoryStorage extends Mock implements Storage {}

void main() {
  setUpAll(() async {
    // flutter_secure_storage talks to a platform channel that doesn't exist
    // in the widget-test harness; stub it out so SessionCubit's restore()
    // call resolves instead of throwing MissingPluginException.
    const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
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

  testWidgets('unauthenticated launch lands on the themed login screen',
      (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Log In'), findsOneWidget);
  });
}
