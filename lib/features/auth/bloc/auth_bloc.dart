import 'dart:async';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injector.dart';
import '../../../core/realtime/realtime_service.dart';
import '../../../core/session/session_cubit.dart';
import '../data/auth_repository.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends AuthEvent {
  const LoginSubmitted({required this.input, required this.password});

  final String input;
  final String password;

  @override
  List<Object?> get props => [input, password];
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

enum AuthStatus { initial, loading, success, failure }

class AuthState extends Equatable {
  const AuthState({this.status = AuthStatus.initial, this.errorMessage});

  final AuthStatus status;
  final String? errorMessage;

  AuthState copyWith({AuthStatus? status, String? errorMessage}) => AuthState(
        status: status ?? this.status,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, errorMessage];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this.authRepository,
    required this.sessionCubit,
    required this.realtimeService,
  }) : super(const AuthState()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  final AuthRepository authRepository;
  final SessionCubit sessionCubit;
  final RealtimeService realtimeService;

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await authRepository.login(event.input, event.password);
      sessionCubit.signedIn(authRepository.currentUserId ?? '');
      unawaited(realtimeService.start());
      unawaited(startPushServices());
      emit(state.copyWith(status: AuthStatus.success));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: _describeError(e)));
    }
  }

  Future<void> _onRegisterSubmitted(RegisterSubmitted event, Emitter<AuthState> emit) async {
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
      unawaited(startPushServices());
      emit(state.copyWith(status: AuthStatus.success));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: _describeError(e)));
    }
  }

  String _describeError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['error_description'] is String) {
        return data['error_description'] as String;
      }
      final status = error.response?.statusCode;
      if (status == 400 || status == 401) {
        return 'Incorrect username or password.';
      }
      if (status == 409) {
        return 'That username or email is already taken.';
      }
      return 'Network error — please try again.';
    }
    return 'Something went wrong — please try again.';
  }
}
