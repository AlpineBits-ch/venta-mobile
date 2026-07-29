import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/di/injector.dart';
import 'core/device/device_id_service.dart';
import 'core/push/push_notification_service.dart';
import 'core/realtime/realtime_service.dart';
import 'features/auth/data/auth_repository.dart';

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
  await getIt<DeviceIdService>().init();
  await getIt<AuthRepository>().init();
  if (getIt<AuthRepository>().isAuthenticated) {
    unawaited(getIt<RealtimeService>().start());
    unawaited(startPushServices());
  }
  runApp(const App());
}
