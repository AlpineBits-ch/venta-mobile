import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injector.dart';
import 'core/locale/app_language.dart';
import 'core/locale/locale_cubit.dart';
import 'core/mls/mls_session_manager.dart';
import 'core/mls/mls_store.dart';
import 'core/push/nse_diagnostics_reporter.dart';
import 'core/push/push_decrypt_diagnostics.dart';
import 'core/push/push_notification_service.dart';
import 'core/routing/app_router.dart';
import 'core/routing/back_navigation.dart';
import 'core/routing/deep_link_handler.dart';
import 'core/session/session_cubit.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/guild_voice/bloc/guild_voice_cubit.dart';
import 'features/invites/presentation/widgets/invite_dialog.dart';
import 'features/status/data/status_repository.dart';
import 'features/status/presentation/widgets/platform_status_banner.dart';
import 'features/voice/bloc/call_cubit.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final SessionCubit _sessionCubit;
  late final GoRouter _router;
  late final UpBackButtonDispatcher _backButtonDispatcher;
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSub;
  StreamSubscription<String>? _notificationTapSub;
  AppLifecycleListener? _lifecycle;

  @override
  void initState() {
    super.initState();
    _sessionCubit = SessionCubit(authRepository: getIt<AuthRepository>())
      ..restore();
    _router = buildAppRouter(_sessionCubit);
    _backButtonDispatcher = UpBackButtonDispatcher(_router);
    _initDeepLinks();
    _notificationTapSub = getIt<PushNotificationService>().onNotificationTap
        .listen(_router.push);

    // Started here rather than in `main()` so the poll's lifetime is the widget
    // tree's: it is paused on background and stopped in `dispose`, per the
    // status spec's "do not poll on a timer that survives backgrounding".
    _startStatusPolling();

    // Decrypted message content is written behind a short debounce, and Android
    // kills backgrounded apps without warning. Losing that window is not a
    // dropped cache entry - MLS ratchets forward only, so a message that was
    // decrypted and not written is unreadable on this device forever.
    _lifecycle = AppLifecycleListener(
      onPause: () {
        unawaited(getIt<MlsStore>().flush());
        // "A million idle clients polling a status endpoint is its own outage."
        _statusRepository?.pause();
      },
      // Every group this device is added to burns one of its key packages. A
      // phone app stays resident for days, so waiting for the next cold start
      // to notice the supply is low - which is all the desktop client does -
      // would leave it quietly unaddable to new conversations in the meantime.
      onResume: () {
        unawaited(getIt<MlsSessionManager>().replenishIfStale());
        // Push notifications are decrypted outside this isolate - Android's FCM
        // background handler, iOS's notification service extension - and MLS
        // only lets a message be read off the wire once. Whatever they read
        // while the app was away exists solely in that file, so a conversation
        // opened from a notification would otherwise show "cannot decrypt" for
        // the exact message the user tapped.
        unawaited(getIt<MlsStore>().reloadMessageCache());
        // The same trip to the same container, for the same reason: the
        // extension ran while this isolate did not, and what it recorded is the
        // only account of why a notification showed the placeholder.
        unawaited(_nseDiagnostics.drain());
        // And the Android half of the same account, written by the FCM
        // background isolate - which has no Sentry of its own, so this process
        // is the only one that can forward what it found.
        unawaited(_pushDiagnostics.drain());
        // An incident can start and end while the app is away, so a resume
        // needs an answer immediately rather than on the next 60s tick.
        _statusRepository?.resume();
      },
    );

    // On launch too, not only on resume. A push that arrives while the app is
    // fully killed - which is most of them - is handled by an extension this
    // process never sees start or finish, so a cold start is the first moment
    // anything can report what it found.
    unawaited(_nseDiagnostics.drain());
    unawaited(_pushDiagnostics.drain());
  }

  final _nseDiagnostics = NseDiagnosticsReporter();
  final _pushDiagnostics = PushDecryptDiagnostics();

  /// Null only if dependency registration failed on this launch - which is
  /// exactly the kind of launch where nothing else should be made to depend on
  /// status working. Every call site is null-aware for that reason.
  StatusRepository? _statusRepository;

  void _startStatusPolling() {
    try {
      _statusRepository = getIt<StatusRepository>()..resume();
    } catch (e) {
      debugPrint('status polling not started: $e');
    }
  }

  /// The launch URI, held only until the stream replays it.
  ///
  /// `app_links` delivers a cold start's link twice - once from
  /// [AppLinks.getInitialLink] and again on [AppLinks.uriLinkStream] - which
  /// opened two invite popups stacked on top of each other, so dismissing
  /// left one behind and it read as the app being stuck.
  Uri? _launchUri;

  Future<void> _initDeepLinks() async {
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _launchUri = initialUri;
      _handleUri(initialUri);
    }
    _linkSub = _appLinks.uriLinkStream.listen((uri) {
      // Only the first replay is swallowed - opening the same invite again
      // later is a real second request and has to still work.
      if (uri == _launchUri) {
        _launchUri = null;
        return;
      }
      _handleUri(uri);
    });
  }

  void _handleUri(Uri uri) {
    switch (DeepLinkHandler.resolve(uri)) {
      case RouteTarget(:final path):
        _router.push(path);
      case InviteTarget(:final code):
        _showInviteDialog(code);
      case null:
        break;
    }
  }

  /// Shows the invite popup over whatever is on screen, waiting for a
  /// navigator if there isn't one yet.
  ///
  /// A cold start *is* the invite: `getInitialLink` resolves before the first
  /// frame, so the navigator's context is still null and dropping the code
  /// there meant the whole point of the link was silently discarded. Retries
  /// once per frame, and gives up rather than spinning forever if no
  /// navigator ever appears.
  void _showInviteDialog(String code, {int attempt = 0}) {
    final context = _router.routerDelegate.navigatorKey.currentContext;
    if (context == null) {
      if (attempt >= 20) return;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _showInviteDialog(code, attempt: attempt + 1),
      );
      return;
    }
    showDialog<void>(
      context: context,
      builder: (_) => InviteDialog(code: code),
    );
  }

  @override
  void dispose() {
    // The poll's lifetime is the widget tree's, not the process's. Without
    // this, the repository is an app-lifetime singleton holding a periodic
    // timer that nothing ever cancels.
    _statusRepository?.pause();
    _lifecycle?.dispose();
    _linkSub?.cancel();
    _notificationTapSub?.cancel();
    _sessionCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _sessionCubit),
        BlocProvider(create: (_) => ThemeCubit()),
        // From `getIt` rather than constructed here, unlike its neighbour
        // above: `AcceptLanguageInterceptor` reads the chosen language on
        // every request and has no context to read it from, so the container
        // owns the one instance and this tree only borrows it. Two instances
        // would mean the settings screen writing to one and the network layer
        // reading the other.
        BlocProvider.value(value: getIt<LocaleCubit>()),
        // App-lifetime singleton, provided at the root (not inside `AppShell`)
        // so it's still reachable from screens pushed via the *root*
        // navigator - like `CallScreen`, which lives outside the shell.
        BlocProvider.value(value: getIt<CallCubit>()),
        // Same root-navigator reasoning as `CallCubit` - `GuildVoiceScreen`
        // is pushed via `Navigator.of(context, rootNavigator: true)`.
        BlocProvider.value(value: getIt<GuildVoiceCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) => BlocBuilder<LocaleCubit, AppLanguage>(
          builder: (context, language) {
            return MaterialApp.router(
              title: 'Venta',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,
              // Null for `AppLanguage.system`, which is not a gap - it is how
              // `MaterialApp` is told to match `supportedLocales` against the
              // device itself rather than being handed an answer.
              locale: language.locale,
              supportedLocales: AppLanguage.supportedLocales,
              // The app's own strings are still English only, so these three
              // do all the visible work for now: `MaterialLocalizations` and
              // its siblings are what draw the date picker the pantry opens
              // for an expiry date, the text-selection menu, and every
              // "Cancel"/"OK" Flutter supplies. Without the delegates,
              // declaring `de` and `it` above is a locale the app claims to
              // support and cannot render a single dialog in.
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              // Above every route rather than inside `AppShell`, where the other
              // app-wide banners live: an outage is most worth announcing to
              // somebody stuck on the login screen, which is outside the shell.
              builder: (context, child) =>
                  PlatformStatusScope(child: child ?? const SizedBox.shrink()),
              // Spelled out rather than passed as `routerConfig`, which is the
              // same four fields but hard-wires `GoRouter`'s own back button
              // dispatcher - and the one thing that needs changing is what
              // happens when nothing pops.
              routerDelegate: _router.routerDelegate,
              routeInformationParser: _router.routeInformationParser,
              routeInformationProvider: _router.routeInformationProvider,
              backButtonDispatcher: _backButtonDispatcher,
            );
          },
        ),
      ),
    );
  }
}
