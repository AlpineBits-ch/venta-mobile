import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/di/injector.dart';
import 'core/push/push_notification_service.dart';
import 'core/realtime/realtime_service.dart';
import 'features/auth/data/auth_repository.dart';

/// Dedicated entrypoint for AppDelegate.swift's headless `voipEngine` -
/// exists purely to let a PushKit-triggered engine finish native plugin
/// registration (GeneratedPluginRegistrant.register, which needs a running
/// engine but not a running Dart isolate to have done anything) fast enough
/// to beat FrontBoard's watchdog. Running the real `main()` there instead
/// - Firebase, HydratedStorage disk I/O, the full DI graph, an auth token
/// refresh - took long enough to get the process SIGKILLed with
/// FRONTBOARD 0xbaadca11 before it ever finished, even though the plugin
/// registration itself completes near-instantly. Must stay a trivial,
/// top-level, `vm:entry-point`-annotated function or the AOT compiler tree-
/// shakes it and `FlutterEngine.run(withEntrypoint:)` fails to find it.
@pragma('vm:entry-point')
void voipHeadlessMain() {}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getApplicationDocumentsDirectory()).path,
    ),
  );
  await configureDependencies();
  await getIt<AuthRepository>().init();
  if (getIt<AuthRepository>().isAuthenticated) {
    unawaited(getIt<RealtimeService>().start());
    unawaited(startPushServices());
  }
  runApp(const App());
}
