import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/data/auth_repository.dart';
import '../routing/route_persistence.dart';
import 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  SessionCubit({required this.authRepository})
    : super(const SessionState.unknown()) {
    _sessionExpiredSub = authRepository.sessionExpired.listen((_) {
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

  void signedIn(String userId) =>
      emit(SessionState.authenticated(userId: userId));

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
