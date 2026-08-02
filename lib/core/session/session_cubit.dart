import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/data/auth_repository.dart';
import '../bloc/safe_emit.dart';
import '../di/injector.dart';
import '../routing/route_persistence.dart';
import 'session_state.dart';

class SessionCubit extends Cubit<SessionState> with SafeEmit<SessionState> {
  SessionCubit({required this.authRepository})
    : super(const SessionState.unknown()) {
    _sessionExpiredSub = authRepository.sessionExpired.listen((_) {
      // Covers explicit logout and a refresh that could not be renewed. The
      // signed-in caches are worthless from here on and actively harmful if
      // the next sign-in is a different account.
      resetSessionScopedCaches();
      emitIfOpen(const SessionState.unauthenticated());
    });
  }

  final AuthRepository authRepository;
  late final StreamSubscription<void> _sessionExpiredSub;

  /// Call once, after [AuthRepository.init] has resolved any persisted
  /// session, to move off the initial `unknown` state.
  void restore() {
    emitIfOpen(
      authRepository.isAuthenticated
          ? SessionState.authenticated(
              userId: authRepository.currentUserId ?? '',
            )
          : const SessionState.unauthenticated(),
    );
  }

  /// Clears before emitting, not after: the router reacts to this state and
  /// mounts the shell (and its user banner) synchronously, so anything left
  /// from a previous account has to be gone by the time they read it.
  void signedIn(String userId) {
    resetSessionScopedCaches();
    emitIfOpen(SessionState.authenticated(userId: userId));
  }

  /// Deregisters this handset's push tokens before dropping the session -
  /// both calls need the bearer token [AuthRepository.logout] is about to
  /// throw away, and a token left registered keeps a signed-out phone ringing
  /// and buzzing for the account that just left it.
  ///
  /// Never allowed to block the sign-out itself: if the network is down, the
  /// user still gets signed out and the stale token is cleaned up the next
  /// time this device registers (the server re-points a token at whoever
  /// registers it) or when the session is revoked from another device.
  Future<void> signOut() async {
    try {
      await stopAuthenticatedServices();
    } catch (_) {
      // Best effort - see above.
    }
    await authRepository.logout();
    RoutePersistence.clear();
    emitIfOpen(const SessionState.unauthenticated());
  }

  @override
  Future<void> close() {
    unawaited(_sessionExpiredSub.cancel());
    return super.close();
  }
}
