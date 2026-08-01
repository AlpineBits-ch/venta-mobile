import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injector.dart';
import 'core/mls/mls_session_manager.dart';
import 'core/mls/mls_store.dart';
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

    // Decrypted message content is written behind a short debounce, and Android
    // kills backgrounded apps without warning. Losing that window is not a
    // dropped cache entry - MLS ratchets forward only, so a message that was
    // decrypted and not written is unreadable on this device forever.
    _lifecycle = AppLifecycleListener(
      onPause: () => unawaited(getIt<MlsStore>().flush()),
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
      },
    );
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
        // App-lifetime singleton, provided at the root (not inside `AppShell`)
        // so it's still reachable from screens pushed via the *root*
        // navigator - like `CallScreen`, which lives outside the shell.
        BlocProvider.value(value: getIt<CallCubit>()),
        // Same root-navigator reasoning as `CallCubit` - `GuildVoiceScreen`
        // is pushed via `Navigator.of(context, rootNavigator: true)`.
        BlocProvider.value(value: getIt<GuildVoiceCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'Venta',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
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
    );
  }
}
