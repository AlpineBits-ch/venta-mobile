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
import '../../features/inbox/presentation/screens/inbox_screen.dart';
import '../../features/messaging/presentation/screens/conversation_screen.dart';
import '../../features/privacy/presentation/screens/blocked_users_screen.dart';
import '../../features/privacy/presentation/screens/data_export_screen.dart';
import '../../features/privacy/presentation/screens/guild_dm_privacy_screen.dart';
import '../../features/privacy/presentation/screens/legal_documents_screen.dart';
import '../../features/privacy/presentation/screens/privacy_settings_screen.dart';
import '../../features/support/presentation/screens/my_reports_screen.dart';
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
import '../../features/status/presentation/screens/platform_status_screen.dart';
import '../di/injector.dart';
import '../realtime/realtime_service.dart';
import 'household_deep_link.dart';
import '../session/session_cubit.dart';
import '../session/session_state.dart';
import '../theme/widget_styles.dart';
import 'app_shell.dart';
import 'back_navigation.dart';
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

/// A [GoRoute] whose screen is built as an [appPage] rather than go_router's
/// default `MaterialPage` - every route outside `AppShell` can be reached as
/// the only entry on the stack, and its back button then depends on the
/// transition [appPage] picks. See `BackNavigation`.
GoRoute _route(
  String path,
  Widget Function(BuildContext context, GoRouterState state) build,
) {
  return GoRoute(
    path: path,
    pageBuilder: (context, state) => appPage(state, build(context, state)),
  );
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
      _route(
        RoutePaths.login,
        (context, state) => BlocProvider(
          create: (_) => AuthBloc(
            authRepository: getIt<AuthRepository>(),
            sessionCubit: sessionCubit,
            realtimeService: getIt<RealtimeService>(),
          ),
          child: const LoginScreen(),
        ),
      ),
      _route(
        RoutePaths.register,
        (context, state) => BlocProvider(
          create: (_) => AuthBloc(
            authRepository: getIt<AuthRepository>(),
            sessionCubit: sessionCubit,
            realtimeService: getIt<RealtimeService>(),
          ),
          child: const RegisterScreen(),
        ),
      ),
      _route(
        RoutePaths.serverSetup,
        (context, state) => const ServerSetupScreen(),
      ),
      _route(
        RoutePaths.forgotPassword,
        (context, state) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        // `pageBuilder`, not `builder`: the shell needs its own page in the
        // root navigator to be an `appPage` like every other route. A
        // `ShellRoute` with only a `builder` gets whatever page go_router
        // picks for the app type - a plain `MaterialPage` under `MaterialApp`
        // - which has no way to be handed a reverse transition. Backing out
        // of a channel or conversation that was the only entry on the stack
        // (cold-start restore, deep link, notification tap) therefore slid
        // Home/the guild in from the right, as a push, on the one tap that
        // meant "back". The `NoTransitionPage`s below govern the *inner*
        // navigator and never covered this.
        pageBuilder: (context, state, child) => appPage(
          state,
          AppShell(currentLocation: state.matchedLocation, child: child),
        ),
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
      _route(
        RoutePaths.conversation,
        (context, state) => ConversationScreen(
          conversationId: state.pathParameters['conversationId']!,
        ),
      ),
      _route(
        RoutePaths.inbox,
        (context, state) =>
            InboxScreen(guildId: state.uri.queryParameters['guildId']),
      ),
      // Which screen a channel opens into depends on its type, and the type
      // isn't always known at route time - a cold start into a persisted
      // location has an empty guild cache. `ChannelHostScreen` waits for the
      // channel before choosing, rather than defaulting to a message thread
      // and putting a composer on a shopping list.
      _route(
        RoutePaths.serverChannel,
        (context, state) => ChannelHostScreen(
          guildId: state.pathParameters['guildId']!,
          channelId: state.pathParameters['channelId']!,
          // Only household boards read this. It names the row a notification
          // was about, because a chore occurrence or a bill has no screen of
          // its own to route to - it is a row on a board that opens scrolled
          // to it. Absent for every other channel type, and for a channel
          // opened from the sidebar.
          focus: HouseholdFocus.tryParse(
            state.uri.queryParameters['focusKind'],
            state.uri.queryParameters['focus'],
          ),
        ),
      ),
      _route(
        RoutePaths.serverChannelForumSettings,
        (context, state) => ForumSettingsScreen(
          guildId: state.pathParameters['guildId']!,
          channelId: state.pathParameters['channelId']!,
        ),
      ),
      _route(
        RoutePaths.serverChannelSettings,
        (context, state) => ChannelSettingsScreen(
          guildId: state.pathParameters['guildId']!,
          channelId: state.pathParameters['channelId']!,
        ),
      ),
      _route(
        RoutePaths.serverMembers,
        (context, state) =>
            GuildMembersScreen(guildId: state.pathParameters['guildId']!),
      ),
      _route(
        RoutePaths.serverChannelsRoles,
        (context, state) =>
            ChannelsAndRolesScreen(guildId: state.pathParameters['guildId']!),
      ),
      _route(
        RoutePaths.serverEvents,
        (context, state) =>
            EventsScreen(guildId: state.pathParameters['guildId']!),
      ),
      _route(
        RoutePaths.serverSettings,
        (context, state) =>
            GuildSettingsScreen(guildId: state.pathParameters['guildId']!),
      ),
      _route(
        RoutePaths.serverWiki,
        (context, state) =>
            WikiHomeScreen(guildId: state.pathParameters['guildId']!),
      ),
      // Declared before serverWikiPage - see the comment on
      // RoutePaths.serverWikiNewPage for why literal `new` must be tried
      // before the `:pageId` wildcard.
      _route(
        RoutePaths.serverWikiNewPage,
        (context, state) =>
            WikiEditorScreen(guildId: state.pathParameters['guildId']!),
      ),
      _route(
        RoutePaths.serverWikiPageEdit,
        (context, state) => WikiEditorScreen(
          guildId: state.pathParameters['guildId']!,
          pageId: state.pathParameters['pageId']!,
        ),
      ),
      _route(
        RoutePaths.serverWikiHistory,
        (context, state) => WikiHistoryScreen(
          guildId: state.pathParameters['guildId']!,
          pageId: state.pathParameters['pageId']!,
        ),
      ),
      _route(
        RoutePaths.serverWikiPage,
        (context, state) => WikiPageViewScreen(
          guildId: state.pathParameters['guildId']!,
          pageId: state.pathParameters['pageId']!,
        ),
      ),
      // Your own profile and the form that edits it each get their own cubit -
      // both stay in sync through `ProfileRepository.selfStream`, so pushing
      // the editor on top of the profile doesn't need shared bloc scope.
      _route(
        RoutePaths.selfProfile,
        (context, state) => BlocProvider(
          create: (_) => SelfProfileCubit(repository: getIt()),
          child: const SelfProfileScreen(),
        ),
      ),
      _route(
        RoutePaths.editProfile,
        (context, state) => BlocProvider(
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
      _route(RoutePaths.settings, (context, state) => const SettingsScreen()),
      _route(
        RoutePaths.accountSettings,
        (context, state) => const AccountSettingsScreen(),
      ),
      // `enabled` comes from the caller's already-loaded account when there
      // is one; a restored route has no caller and the screen looks it up.
      _route(
        RoutePaths.mfaSettings,
        (context, state) => MfaSettingsScreen(enabled: state.extra as bool?),
      ),
      _route(
        RoutePaths.notificationSettings,
        (context, state) => const NotificationSettingsScreen(),
      ),
      _route(
        RoutePaths.appearanceSettings,
        (context, state) => const AppearanceSettingsScreen(),
      ),
      _route(
        RoutePaths.privacy,
        (context, state) => const PrivacySettingsScreen(),
      ),
      _route(
        RoutePaths.blockedUsers,
        (context, state) => const BlockedUsersScreen(),
      ),
      _route(
        RoutePaths.guildDmPrivacy,
        (context, state) => const GuildDmPrivacyScreen(),
      ),
      _route(
        RoutePaths.dataExport,
        (context, state) => const DataExportScreen(),
      ),
      _route(
        RoutePaths.legalDocuments,
        (context, state) => const LegalDocumentsScreen(),
      ),
      _route(RoutePaths.myReports, (context, state) => const MyReportsScreen()),
      _route(
        RoutePaths.platformStatus,
        (context, state) => const PlatformStatusScreen(),
      ),
      _route(RoutePaths.qrLogin, (context, state) => const QrLoginScreen()),
      _route(RoutePaths.devices, (context, state) => const DevicesScreen()),
      _route(
        RoutePaths.userProfile,
        (context, state) =>
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
