import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/di/injector.dart';
import 'core/realtime/realtime_service.dart';
import 'features/auth/data/auth_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getApplicationDocumentsDirectory()).path,
    ),
  );
  await configureDependencies();
  await getIt<AuthRepository>().init();
  if (getIt<AuthRepository>().isAuthenticated) {
    unawaited(getIt<RealtimeService>().start());
  }
  runApp(const App());
}
