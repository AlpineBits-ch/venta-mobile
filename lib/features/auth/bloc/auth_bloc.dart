import 'dart:async';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/safe_emit.dart';
import '../../../core/di/injector.dart';
import '../../../core/diagnostics/secure_storage_fault.dart';
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

  /// The next thing needed is the code from the email. Reached two ways, and
  /// they mean subtly different things: after a sign-in it means "this account
  /// exists and isn't confirmed yet", after a registration it means only "the
  /// request was accepted" - the address may already have had an account, in
  /// which case nothing was created and what landed in the inbox is a notice,
  /// not a code. Deliberately not [failure] in either case.
  emailVerificationRequired,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.pendingVerificationEmail,
    this.infoMessage,
    this.registrationErrors = const {},
  });

  final AuthStatus status;
  final String? errorMessage;

  /// The address the code was sent to, shown on the code form so people can
  /// see which inbox to check (and spot a typo in what they registered with).
  final String? pendingVerificationEmail;

  /// Non-error feedback for the code step - "a new code is on its way".
  final String? infoMessage;

  /// Per-field refusals from the registration form, so a taken username or an
  /// unusable address is shown *on the field it's about* and the user stays on
  /// the form. Anything the server couldn't attribute to a field lands in
  /// [errorMessage] instead.
  final Map<RegistrationField, String> registrationErrors;

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    String? pendingVerificationEmail,
    String? infoMessage,
    Map<RegistrationField, String>? registrationErrors,
  }) => AuthState(
    status: status ?? this.status,
    errorMessage: errorMessage,
    // Sticky, unlike the messages: it has to survive every re-emit of the
    // code step (wrong code, resend) or the form loses the address it's
    // verifying halfway through.
    pendingVerificationEmail:
        pendingVerificationEmail ?? this.pendingVerificationEmail,
    infoMessage: infoMessage,
    // Cleared unless restated, like the messages - a resubmit shouldn't leave
    // last attempt's field errors sitting under the inputs.
    registrationErrors: registrationErrors ?? const {},
  );

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    pendingVerificationEmail,
    infoMessage,
    registrationErrors,
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
      emit.ifOpen(const AuthState());
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
    emit.ifOpen(state.copyWith(status: AuthStatus.loading));
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
      emit.ifOpen(state.copyWith(status: AuthStatus.success));
    } on MfaRequiredException {
      emit.ifOpen(
        state.copyWith(status: AuthStatus.mfaRequired, errorMessage: null),
      );
    } on MfaInvalidException {
      emit.ifOpen(
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
      emit.ifOpen(
        state.copyWith(
          status: AuthStatus.emailVerificationRequired,
          pendingVerificationEmail: '',
        ),
      );
    } catch (e, stack) {
      emit.ifOpen(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: _describeError(e, stack),
        ),
      );
    }
  }

  /// Signup is a *request*, not a creation, and this reflects that.
  ///
  /// A success here says only that the server accepted the form. It doesn't say
  /// an account was made - if the address already had one, none was, and the
  /// response is identical - so nothing below signs anybody in or claims a
  /// session exists. The next step is the same for all three outcomes (new
  /// account, unfinished account, address already verified): the code screen.
  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit.ifOpen(state.copyWith(status: AuthStatus.loading));
    try {
      await authRepository.register(
        email: event.email,
        username: event.username,
        password: event.password,
        birthdate: event.birthdate,
      );
    } on RegistrationRejectedException catch (e) {
      emit.ifOpen(_rejectedState(e));
      return;
    } catch (e, stack) {
      emit.ifOpen(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: _describeError(e, stack),
        ),
      );
      return;
    }
    // Held for the sign-in that follows verification, so confirming the address
    // lands them in the app rather than back on a login form. If the address
    // turned out to belong to somebody else's account these are simply never
    // used - the code they'd need was never sent.
    _pending = (
      login: event.username,
      email: event.email,
      password: event.password,
    );
    emit.ifOpen(
      state.copyWith(
        status: AuthStatus.emailVerificationRequired,
        pendingVerificationEmail: event.email,
      ),
    );
  }

  /// Splits a `400` into per-field messages and a leftover general one.
  ///
  /// The server's messages are used as-is. The one that matters is the taken
  /// username - it's the only signup refusal still allowed to be specific, and
  /// a user who isn't told to pick another name can't get past the form.
  AuthState _rejectedState(RegistrationRejectedException error) {
    final fieldErrors = <RegistrationField, String>{};
    final general = <String>[];
    for (final failure in error.failures) {
      if (failure.field == RegistrationField.general) {
        general.add(failure.message);
      } else {
        fieldErrors.putIfAbsent(failure.field, () => failure.message);
      }
    }
    reportSwallowed('AuthBloc/register', error, StackTrace.current);
    return state.copyWith(
      status: AuthStatus.failure,
      registrationErrors: fieldErrors,
      // Null rather than a filler sentence when every message already sits on
      // a field - otherwise the form shows the fault twice, once in place and
      // once in a snackbar saying something vaguer.
      errorMessage: general.isNotEmpty
          ? general.join('\n')
          : (fieldErrors.isEmpty ? 'That signup was refused.' : null),
    );
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
    emit.ifOpen(state.copyWith(status: AuthStatus.loading));
    try {
      await authRepository.verifyEmail(email: email, code: event.code.trim());
    } catch (e) {
      emit.ifOpen(
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
      emit.ifOpen(state.copyWith(status: AuthStatus.success));
    } catch (_) {
      // The address is confirmed either way - don't strand them on the code
      // form re-entering a code that has already been spent. A whole new
      // state rather than `copyWith`, to clear the pending email and put the
      // credentials form back.
      _pending = null;
      emit.ifOpen(
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
      emit.ifOpen(
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
      emit.ifOpen(
        state.copyWith(
          status: AuthStatus.emailVerificationRequired,
          infoMessage: 'A new code is on its way to $email.',
        ),
      );
    } catch (e) {
      emit.ifOpen(
        state.copyWith(
          status: AuthStatus.emailVerificationRequired,
          errorMessage: e is DioException && e.response?.statusCode == 400
              ? 'That address is already verified - try signing in.'
              : _describeError(e),
        ),
      );
    }
  }

  /// Turns whatever was thrown into something a person can act on, and reports
  /// it.
  ///
  /// **The reporting is half the point.** A caught exception is never sent to
  /// Sentry, so every path through here was invisible: the user saw "Something
  /// went wrong - please try again.", Sentry saw nothing at all, and a keychain
  /// refusing a write *after* a login the server had already completed was
  /// indistinguishable from a wrong password.
  String _describeError(Object error, [StackTrace? stackTrace]) {
    reportSwallowed('AuthBloc', error, stackTrace);

    // Checked before `DioException`, because this is the class of failure that
    // has nothing to do with the network or the credentials and was being
    // reported as though it did. The `OSStatus` is named because it is the
    // whole diagnosis - a -34018 and a -25308 have different causes and
    // different remedies.
    final fault = SecureStorageFault.from(error);
    if (fault != null) {
      final status = fault.osStatus == null ? '' : ' ${fault.osStatus}';
      return 'Your device refused to save the sign-in '
          '(${fault.statusName}$status). You may be able to continue, but you '
          'will have to sign in again next time you open the app.';
    }

    if (error is MissingPluginException) {
      return 'A part of the app did not load correctly. Please reinstall and '
          'try again.';
    }

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
      // Registration's `400`s never reach here - they're a validation array
      // handled as `RegistrationRejectedException` - so this is a sign-in.
      if (status == 400 || status == 401) {
        return 'Incorrect username or password.';
      }
      // There is no 409 branch. Signup used to answer one for a taken address
      // and doesn't any more - it can't, that was the enumeration oracle - and
      // guessing at "that email is already taken" from anything else is the
      // exact reconstruction the change exists to prevent.
      if (error.response != null) {
        return 'The server refused that (error $status). Please try again.';
      }
      return 'Network error - please try again.';
    }
    return 'Something went wrong - please try again.';
  }
}
