import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/data/auth_repository.dart';
import '../di/injector.dart';
import '../routing/route_persistence.dart';
import 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  SessionCubit({required this.authRepository})
    : super(const SessionState.unknown()) {
    _sessionExpiredSub = authRepository.sessionExpired.listen((_) {
      // Covers explicit logout and a refresh that could not be renewed. The
      // signed-in caches are worthless from here on and actively harmful if
      // the next sign-in is a different account.
      resetSessionScopedCaches();
      emit(const SessionState.unauthenticated());
    });
  }

  final AuthRepository authRepository;
  late final StreamSubscription<void> _sessionExpiredSub;

  /// Call once, after [AuthRepository.init] has resolved any persisted
  /// session, to move off the initial `unknown` state.
  void restore() {
    emit(
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
    emit(SessionState.authenticated(userId: userId));
  }

  Future<void> signOut() async {
    await authRepository.logout();
    RoutePersistence.clear();
    emit(const SessionState.unauthenticated());
  }

  @override
  Future<void> close() {
    unawaited(_sessionExpiredSub.cancel());
    return super.close();
  }
}
