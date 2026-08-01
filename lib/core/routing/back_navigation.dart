import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_paths.dart';

/// Going "up" from a screen with nothing beneath it, and the page builder that
/// makes it *look* like going up.
///
/// A cold-start restore (`RoutePersistence`), a deep link and a tapped
/// notification all open their screen as the only entry on the stack, so
/// there's nothing to `pop` and back has to `go` to the parent location
/// instead. `go` replaces the whole stack, and Navigator resolves a replaced
/// stack as a *push*: the parent animates in from the right - the direction
/// that reads as "deeper" - on the one tap that means "back". Only that first
/// tap is wrong; by the second there's a real stack and a real pop.
///
/// [goBack] tags the location it's heading for and [appPage] hands that one
/// page the transition a pop would have given it, so the parent is revealed
/// from underneath the screen leaving instead of sliding in over it.
abstract final class BackNavigation {
  /// Path of the location the next [appPage] should treat as a pop, if any.
  ///
  /// Matched by location rather than cleared on a timer: only the page that
  /// was actually navigated back to can claim it, so a target that never
  /// builds one (`AppShell`'s routes use `NoTransitionPage`) can't leak the
  /// reverse transition onto an unrelated screen later.
  static String? _target;

  /// Pops when there's something to pop, otherwise goes to [location] with a
  /// backwards transition.
  static void goBack(BuildContext context, String location) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    goUp(GoRouter.of(context), location);
  }

  /// Replaces the stack with [location], animated as if it had been popped to.
  ///
  /// Only for when there is genuinely nothing to pop - [goBack] is the one to
  /// call from a screen.
  static void goUp(GoRouter router, String location) {
    _target = Uri.parse(location).path;
    router.go(location);
  }

  static bool _isReturningTo(GoRouterState state) {
    if (_target == null || _target != state.uri.path) return false;
    _target = null;
    return true;
  }
}

/// Sends the Android back button up to the parent location when the navigator
/// has nothing to pop, instead of closing the app.
///
/// The same one-page stack behind [BackNavigation]: cold-start restore, deep
/// links and notification taps all open their screen as the only entry, and a
/// back press there went straight past Flutter to Android, which read "no
/// route to pop" as "close the app" - from a channel the user had merely
/// reopened, with the app bar showing a back arrow that did work.
///
/// Runs strictly after the navigator has declined: a `PopScope` that blocked
/// the pop (an in-progress call, an unsaved editor) counts as handling it, so
/// this never overrides one.
class UpBackButtonDispatcher extends RootBackButtonDispatcher {
  UpBackButtonDispatcher(this._router);

  final GoRouter _router;

  @override
  Future<bool> invokeCallback(Future<bool> defaultValue) async {
    if (await super.invokeCallback(defaultValue)) return true;
    final parent = RoutePaths.parentOf(_router.state.uri.path);
    // Nowhere above this screen - let Android have the back press and close
    // the app, which from Home is what it should do.
    if (parent == null) return false;
    BackNavigation.goUp(_router, parent);
    return true;
  }
}

/// The page used by every route outside `AppShell`.
///
/// Deliberately not `MaterialPage`: the transition has to be chosen per
/// navigation (see [BackNavigation]), and a page whose *type* changed between
/// builds would be a different page to Navigator - it would tear the route
/// down and rebuild it rather than update it. So every navigation goes through
/// one `CustomTransitionPage` that delegates to the platform's own transition,
/// which also keeps iOS's edge swipe-back gesture that `MaterialPage` provided.
Page<void> appPage(GoRouterState state, Widget child) {
  final reverse = BackNavigation._isReturningTo(state);
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final route = ModalRoute.of(context)! as PageRoute<void>;
      final transitions = Theme.of(context).pageTransitionsTheme;
      if (!reverse) {
        return transitions.buildTransitions<void>(
          route,
          context,
          animation,
          secondaryAnimation,
          child,
        );
      }
      // Not "the entering transition, played backwards" - the page a pop
      // reveals is the one that was *underneath*, so it plays the exit
      // transition it had been holding, rewound: fully entered, with its
      // secondary animation running 1 -> 0.
      return transitions.buildTransitions<void>(
        route,
        context,
        kAlwaysCompleteAnimation,
        ReverseAnimation(animation),
        child,
      );
    },
    child: child,
  );
}
