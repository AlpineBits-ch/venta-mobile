import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/di/injector.dart';
import 'core/device/device_id_service.dart';
import 'core/push/push_notification_service.dart';
import 'core/realtime/realtime_service.dart';
import 'features/auth/data/auth_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      
      (await getApplicationDocumentsDirectory()).path,
    ),
  );
  await configureDependencies();
  await getIt<DeviceIdService>().init();
  await getIt<AuthRepository>().init();
  if (getIt<AuthRepository>().isAuthenticated) {
    unawaited(getIt<RealtimeService>().start());
    unawaited(startAuthenticatedServices());
  }
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://0de5da8d45ec13c46a2826e6bfbd0589@o4511596550946816.ingest.de.sentry.io/4511829505671248';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // The sampling rate for profiling is relative to tracesSampleRate
      // Setting to 1.0 will profile 100% of sampled transactions:
      options.enableLogs = true;

    },
    appRunner: () => runApp(SentryWidget(child: const App())),
  );

}
