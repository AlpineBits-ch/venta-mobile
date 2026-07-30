import 'dart:async';

import 'package:flutter/material.dart';
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
import '../../features/guilds/presentation/screens/channel_host_screen.dart';
import '../../features/guilds/presentation/screens/channel_settings_screen.dart';
import '../../features/guilds/presentation/screens/events_screen.dart';
import '../../features/guilds/presentation/screens/channels_and_roles_screen.dart';
import '../../features/guilds/presentation/screens/forum_settings_screen.dart';
import '../../features/guilds/presentation/screens/guild_detail_screen.dart';
import '../../features/guilds/presentation/screens/guild_members_screen.dart';
import '../../features/guilds/presentation/screens/guild_settings/guild_settings_screen.dart';
import '../../features/messaging/presentation/screens/conversation_screen.dart';
import '../../features/wiki/presentation/screens/wiki_editor_screen.dart';
import '../../features/wiki/presentation/screens/wiki_history_screen.dart';
import '../../features/wiki/presentation/screens/wiki_home_screen.dart';
import '../../features/wiki/presentation/screens/wiki_page_view_screen.dart';
import '../../features/profile/bloc/self_profile_cubit.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/mfa_settings_screen.dart';
import '../../features/profile/presentation/screens/self_profile_screen.dart';
import '../../features/profile/presentation/screens/user_profile_screen.dart';
import '../../features/settings/presentation/screens/account_settings_screen.dart';
import '../../features/settings/presentation/screens/appearance_settings_screen.dart';
import '../../features/settings/presentation/screens/devices_screen.dart';
import '../../features/settings/presentation/screens/notification_settings_screen.dart';
import '../../features/settings/presentation/screens/qr_login_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../di/injector.dart';
import '../realtime/realtime_service.dart';
import '../session/session_cubit.dart';
import '../session/session_state.dart';
import '../theme/widget_styles.dart';
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
    // go_router's own error page offers a "Home" link to `/`, which this app
    // doesn't route - so its one way out is itself a dead end. Anything that
    // still fails to match gets a real way back instead.
    errorBuilder: (context, state) =>
        _RouteNotFoundScreen(location: state.uri.toString()),
    redirect: (context, state) {
      final session = sessionCubit.state;

      // A cold start from a `venta://…` intent arrives as the platform's
      // initial route, and go_router prefers that over `initialLocation`
      // whenever it isn't `/` - so the router tried to match
      // `venta://invite/CODE` as a path, found nothing, and dropped the user
      // on "Page Not Found" whose only affordance ("Home") points at `/`,
      // which isn't a route either. That is the dead end.
      //
      // Deep links are `DeepLinkHandler`/`App`'s job, not the router's: this
      // only has to refuse to treat one as a location.
      if (state.uri.hasScheme) {
        return session is SessionAuthenticated
            ? (RoutePersistence.lastLocation ?? RoutePaths.home)
            : RoutePaths.login;
      }

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
        SessionAuthenticated() =>
          loggingIn ? (RoutePersistence.lastLocation ?? RoutePaths.home) : null,
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
        // Which screen a channel opens into depends on its type, and the type
        // isn't always known at route time - a cold start into a persisted
        // location has an empty guild cache. `ChannelHostScreen` waits for the
        // channel before choosing, rather than defaulting to a message thread
        // and putting a composer on a shopping list.
        builder: (context, state) => ChannelHostScreen(
          guildId: state.pathParameters['guildId']!,
          channelId: state.pathParameters['channelId']!,
        ),
      ),
      GoRoute(
        path: RoutePaths.serverChannelForumSettings,
        builder: (context, state) => ForumSettingsScreen(
          guildId: state.pathParameters['guildId']!,
          channelId: state.pathParameters['channelId']!,
        ),
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
        path: RoutePaths.serverChannelsRoles,
        builder: (context, state) =>
            ChannelsAndRolesScreen(guildId: state.pathParameters['guildId']!),
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
      // Your own profile and the form that edits it each get their own cubit -
      // both stay in sync through `ProfileRepository.selfStream`, so pushing
      // the editor on top of the profile doesn't need shared bloc scope.
      GoRoute(
        path: RoutePaths.selfProfile,
        builder: (context, state) => BlocProvider(
          create: (_) => SelfProfileCubit(repository: getIt()),
          child: const SelfProfileScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.editProfile,
        builder: (context, state) => BlocProvider(
          create: (_) => SelfProfileCubit(repository: getIt()),
          child: const EditProfileScreen(),
        ),
      ),
      // Where profile *and* settings used to live as one screen. Kept as a
      // redirect because `RoutePersistence` may have saved it as the last
      // location, and an unmatched path on cold start is an error page.
      GoRoute(
        path: RoutePaths.legacyProfileSettings,
        redirect: (context, state) => RoutePaths.selfProfile,
      ),
      GoRoute(
        path: RoutePaths.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RoutePaths.accountSettings,
        builder: (context, state) => const AccountSettingsScreen(),
      ),
      GoRoute(
        path: RoutePaths.mfaSettings,
        // `enabled` comes from the caller's already-loaded account when there
        // is one; a restored route has no caller and the screen looks it up.
        builder: (context, state) =>
            MfaSettingsScreen(enabled: state.extra as bool?),
      ),
      GoRoute(
        path: RoutePaths.notificationSettings,
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: RoutePaths.appearanceSettings,
        builder: (context, state) => const AppearanceSettingsScreen(),
      ),
      GoRoute(
        path: RoutePaths.qrLogin,
        builder: (context, state) => const QrLoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.devices,
        builder: (context, state) => const DevicesScreen(),
      ),
      GoRoute(
        path: RoutePaths.userProfile,
        builder: (context, state) =>
            UserProfileScreen(userId: state.pathParameters['userId']!),
      ),
    ],
  );
}

/// Replaces go_router's built-in "Page Not Found", whose only action links to
/// `/` - a location this app doesn't route, so pressing it lands you back on
/// the same screen with no way out.
class _RouteNotFoundScreen extends StatelessWidget {
  const _RouteNotFoundScreen({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.explore_off_outlined,
                size: 44,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
              ),
              const SizedBox(height: AppSpacing.m),
              Text(
                'This link went nowhere',
                style: theme.textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                location,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.l),
              FilledButton(
                onPressed: () => context.go(RoutePaths.home),
                child: const Text('Back to Venta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
