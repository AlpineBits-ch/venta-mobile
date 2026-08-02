import 'dart:async';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injector.dart';
import '../../../core/realtime/realtime_service.dart';
import '../../../core/session/session_cubit.dart';
import '../data/auth_api.dart';
import '../data/auth_repository.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends AuthEvent {
  const LoginSubmitted({
    required this.input,
    required this.password,
    this.mfaCode,
  });

  final String input;
  final String password;
  final String? mfaCode;

  @override
  List<Object?> get props => [input, password, mfaCode];
}

/// Backs out of the [AuthStatus.mfaRequired] prompt to the credentials form.
/// Without this the code screen is a dead end - someone who can't reach their
/// authenticator has no way back short of killing the app.
class LoginCancelled extends AuthEvent {
  const LoginCancelled();
}

/// The 6-digit code from the verification email.
///
/// [email] is carried only when the flow couldn't know the address for itself
/// - signing in, where the field holds a username. Registering already has it.
class VerificationCodeSubmitted extends AuthEvent {
  const VerificationCodeSubmitted(this.code, {this.email});

  final String code;
  final String? email;

  @override
  List<Object?> get props => [code, email];
}

/// "Send it again" - the code expires, and mail gets lost.
class VerificationCodeResendRequested extends AuthEvent {
  const VerificationCodeResendRequested({this.email});

  final String? email;

  @override
  List<Object?> get props => [email];
}

class RegisterSubmitted extends AuthEvent {
  const RegisterSubmitted({
    required this.email,
    required this.username,
    required this.password,
    required this.birthdate,
  });

  final String email;
  final String username;
  final String password;
  final DateTime birthdate;

  @override
  List<Object?> get props => [email, username, password, birthdate];
}

enum AuthStatus {
  initial,
  loading,
  success,
  failure,
  mfaRequired,

  /// The account exists but its address isn't confirmed yet, so the code entry
  /// takes over the form. Deliberately not [failure] after a registration:
  /// registration worked, and telling somebody it didn't sends them round
  /// again into a "username already taken" on an account they just made.
  emailVerificationRequired,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.pendingVerificationEmail,
    this.infoMessage,
  });

  final AuthStatus status;
  final String? errorMessage;

  /// The address the code was sent to, shown on the code form so people can
  /// see which inbox to check (and spot a typo in what they registered with).
  final String? pendingVerificationEmail;

  /// Non-error feedback for the code step - "a new code is on its way".
  final String? infoMessage;

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    String? pendingVerificationEmail,
    String? infoMessage,
  }) => AuthState(
    status: status ?? this.status,
    errorMessage: errorMessage,
    // Sticky, unlike the messages: it has to survive every re-emit of the
    // code step (wrong code, resend) or the form loses the address it's
    // verifying halfway through.
    pendingVerificationEmail:
        pendingVerificationEmail ?? this.pendingVerificationEmail,
    infoMessage: infoMessage,
  );

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    pendingVerificationEmail,
    infoMessage,
  ];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this.authRepository,
    required this.sessionCubit,
    required this.realtimeService,
  }) : super(const AuthState()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginCancelled>((_, emit) {
      _pending = null;
      emit(const AuthState());
    });
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<VerificationCodeSubmitted>(_onVerificationCodeSubmitted);
    on<VerificationCodeResendRequested>(_onResendRequested);
  }

  final AuthRepository authRepository;
  final SessionCubit sessionCubit;
  final RealtimeService realtimeService;

  /// The credentials to sign in with once the address is confirmed, so
  /// verifying lands you in the app rather than back on a login form typing
  /// the password you entered a minute ago. Kept off [AuthState] on purpose -
  /// state gets compared, copied and logged; a password shouldn't ride along.
  ({String login, String email, String password})? _pending;

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await authRepository.login(
        event.input,
        event.password,
        mfaCode: event.mfaCode,
      );
      sessionCubit.signedIn(authRepository.currentUserId ?? '');
      unawaited(realtimeService.start());
      // The password is handed on rather than dropped: publishing the account
      // identity key and writing the recovery-key envelope are both gated on it
      // server-side, and a sign-in is the only moment this client legitimately
      // holds one. It is passed, used and never stored - the same reasoning as
      // `_pending` below.
      unawaited(startAuthenticatedServices(password: event.password));
      emit(state.copyWith(status: AuthStatus.success));
    } on MfaRequiredException {
      emit(state.copyWith(status: AuthStatus.mfaRequired, errorMessage: null));
    } on MfaInvalidException {
      emit(
        state.copyWith(
          status: AuthStatus.mfaRequired,
          errorMessage: 'Invalid code - try again.',
        ),
      );
    } on EmailNotVerifiedException {
      // The login field is a username *or* `user@self-hosted-server` (see
      // `AuthRepository.login`) - neither is an email address, so signing in
      // can't know where the code was sent. The form asks for it.
      _pending = (login: event.input, email: '', password: event.password);
      emit(
        state.copyWith(
          status: AuthStatus.emailVerificationRequired,
          pendingVerificationEmail: '',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: _describeError(e),
        ),
      );
    }
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await authRepository.register(
        email: event.email,
        username: event.username,
        password: event.password,
        birthdate: event.birthdate,
      );
      sessionCubit.signedIn(authRepository.currentUserId ?? '');
      unawaited(realtimeService.start());
      unawaited(startAuthenticatedServices(password: event.password));
      emit(state.copyWith(status: AuthStatus.success));
    } on EmailNotVerifiedException {
      // The account is created; only the sign-in that follows it was refused.
      // Registration always knows the address, so this always gets a code.
      _pending = (
        login: event.username,
        email: event.email,
        password: event.password,
      );
      emit(
        state.copyWith(
          status: AuthStatus.emailVerificationRequired,
          pendingVerificationEmail: event.email,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: _describeError(e),
        ),
      );
    }
  }

  Future<void> _onVerificationCodeSubmitted(
    VerificationCodeSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final pending = _pending;
    if (pending == null) return;
    // Signing in doesn't know the address, so the form collects it; keep it
    // so a later resend goes to the same place.
    final email = (event.email?.trim().isNotEmpty ?? false)
        ? event.email!.trim()
        : pending.email;
    if (email.isEmpty) return;
    _pending = (login: pending.login, email: email, password: pending.password);
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await authRepository.verifyEmail(email: email, code: event.code.trim());
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.emailVerificationRequired,
          errorMessage: e is DioException && e.response?.statusCode == 400
              ? 'That code is wrong or has expired.'
              : _describeError(e),
        ),
      );
      return;
    }
    try {
      // Verified - finish the sign-in they were already trying to make.
      await authRepository.login(pending.login, pending.password);
      sessionCubit.signedIn(authRepository.currentUserId ?? '');
      unawaited(realtimeService.start());
      unawaited(startAuthenticatedServices(password: pending.password));
      _pending = null;
      emit(state.copyWith(status: AuthStatus.success));
    } catch (_) {
      // The address is confirmed either way - don't strand them on the code
      // form re-entering a code that has already been spent. A whole new
      // state rather than `copyWith`, to clear the pending email and put the
      // credentials form back.
      _pending = null;
      emit(
        const AuthState(
          status: AuthStatus.failure,
          errorMessage: 'Email verified - please sign in.',
        ),
      );
    }
  }

  Future<void> _onResendRequested(
    VerificationCodeResendRequested event,
    Emitter<AuthState> emit,
  ) async {
    final pending = _pending;
    if (pending == null) return;
    final email = (event.email?.trim().isNotEmpty ?? false)
        ? event.email!.trim()
        : pending.email;
    if (email.isEmpty) {
      emit(
        state.copyWith(
          status: AuthStatus.emailVerificationRequired,
          errorMessage: 'Enter the email address you signed up with first.',
        ),
      );
      return;
    }
    _pending = (login: pending.login, email: email, password: pending.password);
    try {
      await authRepository.resendVerificationCode(email);
      emit(
        state.copyWith(
          status: AuthStatus.emailVerificationRequired,
          infoMessage: 'A new code is on its way to $email.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.emailVerificationRequired,
          errorMessage: e is DioException && e.response?.statusCode == 400
              ? 'That address is already verified - try signing in.'
              : _describeError(e),
        ),
      );
    }
  }

  String _describeError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['error_description'] is String) {
        return data['error_description'] as String;
      }
      // Several identity endpoints answer with a bare string rather than the
      // OAuth error shape ("Email not verified." is one). Saying what the
      // server said beats inventing "network error" for a request that very
      // much reached the network.
      if (data is String && data.trim().isNotEmpty && data.length < 200) {
        return data.trim();
      }
      final status = error.response?.statusCode;
      if (status == 400 || status == 401) {
        return 'Incorrect username or password.';
      }
      if (status == 409) {
        return 'That username or email is already taken.';
      }
      if (error.response != null) {
        return 'The server refused that (error $status). Please try again.';
      }
      return 'Network error - please try again.';
    }
    return 'Something went wrong - please try again.';
  }
}
