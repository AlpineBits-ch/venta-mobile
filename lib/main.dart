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
import 'core/diagnostics/telemetry_consent.dart';
import 'core/push/push_notification_service.dart';
import 'core/realtime/realtime_service.dart';
import 'core/startup/app_bootstrap.dart';
import 'features/auth/data/auth_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Starts the app, and **always** reaches `runApp`.
///
/// This used to be eight bare `await`s with `runApp` nested inside the last of
/// them, so any one of them throwing produced a Flutter engine with no root
/// widget - a white screen, with no error text, no stack, and nothing to tell a
/// user or a developer which of the eight it was. Half of those calls are
/// plugin or platform calls whose iOS behaviour differs from Android's (the
/// keychain most of all), so the platform where it broke was also the platform
/// where nobody could see why.
///
/// Every step is now individually guarded and the app renders regardless. Where
/// a failure would otherwise poison something read during the first frame, a
/// fallback is installed rather than left to explode a beat later - see
/// [InMemoryHydratedStorage].
Future<void> main() async {
  // Before anything else, so a failure inside the bootstrap itself is drawn
  // rather than swallowed.
  WidgetsFlutterBinding.ensureInitialized();
  installGlobalErrorHandlers(report: _reportToSentry);

  final bootstrap = AppBootstrap();

  await bootstrap.step('orientation', () async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  });

  // Push notifications are dead without it; everything else works.
  await bootstrap.step('firebase', () async {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  });

  // `HydratedBloc.storage` is a `late` static, read during the first frame by
  // `ThemeCubit`'s construction and by `RoutePersistence`. Leaving it unassigned
  // turns a disk failure into a widget-tree failure one beat after launch, which
  // presents identically to the thing this file exists to prevent.
  final storageReady = await bootstrap.step('hydrated-storage', () async {
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: HydratedStorageDirectory(
        (await getApplicationDocumentsDirectory()).path,
      ),
    );
  });
  if (!storageReady) HydratedBloc.storage = InMemoryHydratedStorage();

  // Pure registration, no I/O - but a missing registration downstream is a
  // `StateError` thrown from a build method, so it is guarded like the rest.
  await bootstrap.step('dependencies', configureDependencies);

  // Before Sentry starts, so the very first report of the launch is already
  // attributed to the per-install pseudonym rather than to nothing. Never
  // throws - see `TelemetryConsent.init`.
  await bootstrap.step('telemetry-consent', getIt<TelemetryConsent>().init);

  // Keychain, and the likeliest single point of iOS-only failure on this path:
  // an access-group mismatch, an item written under a different accessibility
  // class, or a read before first unlock all surface here as a
  // `PlatformException` and have no Android analogue. `DeviceIdService.init`
  // installs an ephemeral id of its own rather than leaving its getters armed.
  await bootstrap.step('device-id', getIt<DeviceIdService>().init);

  // Reads the persisted session and force-refreshes the token: network *and*
  // keychain, and the one step whose behaviour depends on what the server does.
  await bootstrap.step('auth', getIt<AuthRepository>().init);

  await bootstrap.step('authenticated-services', () async {
    if (!getIt<AuthRepository>().isAuthenticated) return;
    unawaited(getIt<RealtimeService>().start());
    unawaited(startAuthenticatedServices());
  });

  if (!bootstrap.isClean) {
    debugPrint('startup completed with failures:\n${bootstrap.summary}');
  }

  // Sentry wraps `runApp` in its own error-capturing zone, which is why it is
  // the runner rather than just another step. If it cannot start, the app still
  // has to - so the fallback is a plain `runApp`, never an early return.
  final sentryStarted = await bootstrap.step('sentry', () async {
    await SentryFlutter.init((options) {
      options.dsn =
          'https://0de5da8d45ec13c46a2826e6bfbd0589@o4511596550946816.ingest.de.sentry.io/4511829505671248';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // The sampling rate for profiling is relative to tracesSampleRate
      // Setting to 1.0 will profile 100% of sampled transactions:
      options.enableLogs = true;
      // Explicit rather than relied upon: the default is already false, but
      // a report carrying an email address is the failure this whole gate
      // exists to prevent, and defaults change between majors.
      options.sendDefaultPii = false;
      // Runs on every event, consented or not. Consent decides whether a
      // report is *attributable*; it is never permission to sweep an email
      // address or a request body into one. See `TelemetryConsent`.
      options.beforeSend = TelemetryConsent.scrubEvent;
    }, appRunner: () => runApp(SentryWidget(child: const App())));
  });

  if (!sentryStarted) runApp(const App());
}

/// Best-effort, and guarded: the reporter is itself one of the things that can
/// be uninitialised when an early error fires, and an exception thrown out of an
/// error handler replaces a diagnosable fault with an undiagnosable one.
void _reportToSentry(Object error, StackTrace stack) {
  try {
    unawaited(Sentry.captureException(error, stackTrace: stack));
  } catch (_) {
    // Nothing useful left to do - the handler's own debugPrint already ran.
  }
}
