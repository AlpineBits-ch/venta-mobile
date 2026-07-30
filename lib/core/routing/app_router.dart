import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/server_setup_screen.dart';
import '../../features/conversations/presentation/screens/home_screen.dart';
import '../../features/friends/bloc/friends_bloc.dart';
import '../../features/friends/presentation/screens/friends_screen.dart';
import '../../features/guilds/data/guild_repository.dart';
import '../../features/guilds/data/models/channel_dto.dart';
import '../../features/guilds/presentation/screens/channel_screen.dart';
import '../../features/guilds/presentation/screens/channel_settings_screen.dart';
import '../../features/guilds/presentation/screens/events_screen.dart';
import '../../features/guilds/presentation/screens/forum_channel_screen.dart';
import '../../features/guilds/presentation/screens/guild_detail_screen.dart';
import '../../features/guilds/presentation/screens/guild_members_screen.dart';
import '../../features/guilds/presentation/screens/guild_settings/guild_settings_screen.dart';
import '../../features/messaging/presentation/screens/conversation_screen.dart';
import '../../features/wiki/presentation/screens/wiki_editor_screen.dart';
import '../../features/wiki/presentation/screens/wiki_history_screen.dart';
import '../../features/wiki/presentation/screens/wiki_home_screen.dart';
import '../../features/wiki/presentation/screens/wiki_page_view_screen.dart';
import '../../features/profile/bloc/self_profile_cubit.dart';
import '../../features/profile/presentation/screens/profile_settings_screen.dart';
import '../../features/profile/presentation/screens/user_profile_screen.dart';
import '../di/injector.dart';
import '../realtime/realtime_service.dart';
import '../session/session_cubit.dart';
import '../session/session_state.dart';
import 'app_shell.dart';
import 'route_paths.dart';
import 'route_persistence.dart';

/// go_router removed its bundled `GoRouterRefreshStream` back in v5 - this
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
      final loggingIn =
          state.matchedLocation == RoutePaths.login ||
          state.matchedLocation == RoutePaths.register ||
          state.matchedLocation == RoutePaths.serverSetup ||
          state.matchedLocation == RoutePaths.forgotPassword;

      // Every authenticated navigation is a candidate "last place the user
      // was" - remembered so a cold relaunch (app process killed, not just
      // backgrounded) reopens there instead of always on Home.
      if (session is SessionAuthenticated && !loggingIn) {
        RoutePersistence.save(state.uri.toString());
      }

      return switch (session) {
        SessionUnknown() => null,
        SessionUnauthenticated() ||
        SessionServerMisconfigured() => loggingIn ? null : RoutePaths.login,
        SessionAuthenticated() => loggingIn
            ? (RoutePersistence.lastLocation ?? RoutePaths.home)
            : null,
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
      GoRoute(
        path: RoutePaths.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(currentLocation: state.matchedLocation, child: child),
        routes: [
          // These three routes are siblings toggled by the persistent server
          // rail (AppShell) rather than screens drilled into - the content
          // pane should swap in place, not slide, unlike every other route
          // below (opening a conversation/channel/profile keeps the normal
          // platform push transition).
          GoRoute(
            path: RoutePaths.home,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: RoutePaths.homeFriends,
            pageBuilder: (context, state) => NoTransitionPage(
              child: BlocProvider(
                create: (_) => FriendsBloc(repository: getIt()),
                child: const FriendsScreen(),
              ),
            ),
          ),
          GoRoute(
            path: RoutePaths.server,
            pageBuilder: (context, state) => NoTransitionPage(
              child: GuildDetailScreen(
                guildId: state.pathParameters['guildId']!,
              ),
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
        builder: (context, state) {
          final guildId = state.pathParameters['guildId']!;
          final channelId = state.pathParameters['channelId']!;
          // A Forum channel is a post list, not a message thread - every
          // other channel type (including a post itself, which is just a
          // Thread channel) opens the normal ChannelScreen.
          final channel = getIt<GuildRepository>()
              .cachedById(guildId)
              ?.channels
              .where((c) => c.id == channelId)
              .firstOrNull;
          if (channel?.type == ChannelType.forum) {
            return ForumChannelScreen(guildId: guildId, channelId: channelId);
          }
          return ChannelScreen(guildId: guildId, channelId: channelId);
        },
      ),
      GoRoute(
        path: RoutePaths.serverChannelSettings,
        builder: (context, state) => ChannelSettingsScreen(
          guildId: state.pathParameters['guildId']!,
          channelId: state.pathParameters['channelId']!,
        ),
      ),
      GoRoute(
        path: RoutePaths.serverMembers,
        builder: (context, state) =>
            GuildMembersScreen(guildId: state.pathParameters['guildId']!),
      ),
      GoRoute(
        path: RoutePaths.serverEvents,
        builder: (context, state) =>
            EventsScreen(guildId: state.pathParameters['guildId']!),
      ),
      GoRoute(
        path: RoutePaths.serverSettings,
        builder: (context, state) =>
            GuildSettingsScreen(guildId: state.pathParameters['guildId']!),
      ),
      GoRoute(
        path: RoutePaths.serverWiki,
        builder: (context, state) =>
            WikiHomeScreen(guildId: state.pathParameters['guildId']!),
      ),
      // Declared before serverWikiPage - see the comment on
      // RoutePaths.serverWikiNewPage for why literal `new` must be tried
      // before the `:pageId` wildcard.
      GoRoute(
        path: RoutePaths.serverWikiNewPage,
        builder: (context, state) =>
            WikiEditorScreen(guildId: state.pathParameters['guildId']!),
      ),
      GoRoute(
        path: RoutePaths.serverWikiPageEdit,
        builder: (context, state) => WikiEditorScreen(
          guildId: state.pathParameters['guildId']!,
          pageId: state.pathParameters['pageId']!,
        ),
      ),
      GoRoute(
        path: RoutePaths.serverWikiHistory,
        builder: (context, state) => WikiHistoryScreen(
          guildId: state.pathParameters['guildId']!,
          pageId: state.pathParameters['pageId']!,
        ),
      ),
      GoRoute(
        path: RoutePaths.serverWikiPage,
        builder: (context, state) => WikiPageViewScreen(
          guildId: state.pathParameters['guildId']!,
          pageId: state.pathParameters['pageId']!,
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
        builder: (context, state) =>
            UserProfileScreen(userId: state.pathParameters['userId']!),
      ),
    ],
  );
}
