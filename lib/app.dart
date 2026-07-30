import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injector.dart';
import 'core/push/push_notification_service.dart';
import 'core/routing/app_router.dart';
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
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSub;
  StreamSubscription<String>? _notificationTapSub;

  @override
  void initState() {
    super.initState();
    _sessionCubit = SessionCubit(authRepository: getIt<AuthRepository>())
      ..restore();
    _router = buildAppRouter(_sessionCubit);
    _initDeepLinks();
    _notificationTapSub = getIt<PushNotificationService>().onNotificationTap
        .listen(_router.push);
  }

  Future<void> _initDeepLinks() async {
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) _handleUri(initialUri);
    _linkSub = _appLinks.uriLinkStream.listen(_handleUri);
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

  void _showInviteDialog(String code) {
    final context = _router.routerDelegate.navigatorKey.currentContext;
    if (context == null) return;
    showDialog<void>(
      context: context,
      builder: (_) => InviteDialog(code: code),
    );
  }

  @override
  void dispose() {
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
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
