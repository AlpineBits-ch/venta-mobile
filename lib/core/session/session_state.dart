import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_state.freezed.dart';

/// Drives [GoRouter]'s auth redirect. `Authenticated`/`Unauthenticated` are
/// filled in for real once `AuthRepository` lands in Phase 1 — for now a
/// stored token is trusted at face value with no refresh/validation.
@freezed
sealed class SessionState with _$SessionState {
  const factory SessionState.unknown() = SessionUnknown;
  const factory SessionState.unauthenticated() = SessionUnauthenticated;
  const factory SessionState.authenticated({required String userId}) =
      SessionAuthenticated;
  const factory SessionState.serverMisconfigured({required String message}) =
      SessionServerMisconfigured;
}
