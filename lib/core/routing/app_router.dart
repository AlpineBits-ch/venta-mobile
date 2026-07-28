import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/server_setup_screen.dart';
import '../../features/conversations/presentation/screens/home_screen.dart';
import '../../features/friends/bloc/friends_bloc.dart';
import '../../features/friends/presentation/screens/friends_screen.dart';
import '../../features/guilds/presentation/screens/channel_screen.dart';
import '../../features/guilds/presentation/screens/guild_detail_screen.dart';
import '../../features/guilds/presentation/screens/guild_members_screen.dart';
import '../../features/guilds/presentation/screens/guild_settings/guild_settings_screen.dart';
import '../../features/messaging/presentation/screens/conversation_screen.dart';
import '../../features/profile/bloc/self_profile_cubit.dart';
import '../../features/profile/presentation/screens/profile_settings_screen.dart';
import '../../features/profile/presentation/screens/user_profile_screen.dart';
import '../di/injector.dart';
import '../realtime/realtime_service.dart';
import '../session/session_cubit.dart';
import '../session/session_state.dart';
import 'app_shell.dart';
import 'route_paths.dart';

/// go_router removed its bundled `GoRouterRefreshStream` back in v5 — this
/// is the same small adapter from its own migration docs, converting a
/// bloc/cubit's `Stream<State>` into the `Listenable` `refreshListenable`
/// expects, so `redirect` re-runs on every [SessionCubit] state change.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter buildAppRouter(SessionCubit sessionCubit) {
  return GoRouter(
    initialLocation: RoutePaths.login,
    refreshListenable: GoRouterRefreshStream(sessionCubit.stream),
    redirect: (context, state) {
      final session = sessionCubit.state;
      final loggingIn = state.matchedLocation == RoutePaths.login ||
          state.matchedLocation == RoutePaths.register ||
          state.matchedLocation == RoutePaths.serverSetup;

      return switch (session) {
        SessionUnknown() => null,
        SessionUnauthenticated() || SessionServerMisconfigured() =>
          loggingIn ? null : RoutePaths.login,
        SessionAuthenticated() => loggingIn ? RoutePaths.home : null,
      };
    },
    routes: [
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => BlocProvider(
          create: (_) => AuthBloc(
            authRepository: getIt<AuthRepository>(),
            sessionCubit: sessionCubit,
            realtimeService: getIt<RealtimeService>(),
          ),
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.register,
        builder: (context, state) => BlocProvider(
          create: (_) => AuthBloc(
            authRepository: getIt<AuthRepository>(),
            sessionCubit: sessionCubit,
            realtimeService: getIt<RealtimeService>(),
          ),
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.serverSetup,
        builder: (context, state) => const ServerSetupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(currentLocation: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: RoutePaths.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: RoutePaths.homeFriends,
            builder: (context, state) => BlocProvider(
              create: (_) => FriendsBloc(repository: getIt()),
              child: const FriendsScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.server,
            builder: (context, state) => GuildDetailScreen(
              guildId: state.pathParameters['guildId']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.conversation,
        builder: (context, state) => ConversationScreen(
          conversationId: state.pathParameters['conversationId']!,
        ),
      ),
      GoRoute(
        path: RoutePaths.serverChannel,
        builder: (context, state) => ChannelScreen(
          guildId: state.pathParameters['guildId']!,
          channelId: state.pathParameters['channelId']!,
        ),
      ),
      GoRoute(
        path: RoutePaths.serverMembers,
        builder: (context, state) => GuildMembersScreen(
          guildId: state.pathParameters['guildId']!,
        ),
      ),
      GoRoute(
        path: RoutePaths.serverSettings,
        builder: (context, state) => GuildSettingsScreen(
          guildId: state.pathParameters['guildId']!,
        ),
      ),
      GoRoute(
        path: RoutePaths.profileSettings,
        builder: (context, state) => BlocProvider(
          create: (_) => SelfProfileCubit(repository: getIt()),
          child: const ProfileSettingsScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.userProfile,
        builder: (context, state) => UserProfileScreen(
          userId: state.pathParameters['userId']!,
        ),
      ),
    ],
  );
}
