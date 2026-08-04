import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/realtime/realtime_service.dart';
import 'package:venta_mobile/core/session/session_cubit.dart';
import 'package:venta_mobile/features/auth/bloc/auth_bloc.dart';
import 'package:venta_mobile/features/auth/data/auth_api.dart';
import 'package:venta_mobile/features/auth/data/auth_repository.dart';

/// What these cover: **`POST /register` stopped being an account enumeration
/// oracle, and the client stopped depending on it being one.**
///
/// The endpoint used to answer `200 {"userId": …}` for a free address and
/// `400 "Email already exists"` for a taken one. Anyone with a list of
/// addresses could read membership of this platform straight off the status
/// code, unauthenticated. It now answers `202` with a fixed body in both cases,
/// carries no user id, and tells the *address owner* that someone tried.
///
/// Three things in this client leaned on the old shape and are pinned here:
///
/// * it signed in immediately after registering, using the
///   `403 Email not verified.` from that grant to reach the code screen. For an
///   address that already had an account the username just "registered" doesn't
///   exist, so the grant answers a flat `401` and the user was told their
///   brand-new password was wrong;
/// * a `400` was rendered through the login copy - "Incorrect username or
///   password." - which is now the *only* refusal signup still makes
///   specifically, and the one a user has to read to get past the form;
/// * a `409` branch claimed "that username or email is already taken". There is
///   no `409` and there never was.
class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockSessionCubit extends Mock implements SessionCubit {}

class _MockRealtime extends Mock implements RealtimeService {}

class _CapturingAdapter implements HttpClientAdapter {
  _CapturingAdapter(this.response);

  final ResponseBody Function() response;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return response();
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _body(Object body, int status) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

/// The fixed body, byte for byte, that a free address and a registered one both
/// get back.
const _accepted = {
  'status': 'verification_pending',
  'message':
      'If that address can be registered, we have sent it an email. '
      'Check your inbox to continue.',
};

List<Map<String, Object?>> _validation({
  required String propertyName,
  required String errorMessage,
  String? errorCode,
}) => [
  {
    'propertyName': propertyName,
    'errorMessage': errorMessage,
    'attemptedValue': null,
    'customState': null,
    'severity': 'Error',
    'errorCode': errorCode,
    'formattedMessagePlaceholderValues': null,
  },
];

Future<void> _register(AuthApi api) => api.register(
  baseUrl: 'https://api.venta.gg',
  email: 'user@example.com',
  username: 'someuser',
  password: 'SecurePass123!',
  birthdate: DateTime.utc(2000),
);

void main() {
  group('AuthApi.register', () {
    test('202 is a success - nothing may require a 200', () async {
      final adapter = _CapturingAdapter(() => _body(_accepted, 202));
      final api = AuthApi(dio: Dio()..httpClientAdapter = adapter);

      await expectLater(_register(api), completes);
    });

    test('a registered address gets the same 202, and no exception', () async {
      // Identical response by design. If this ever starts throwing - or
      // returning something a caller can branch on - the leak is back.
      final adapter = _CapturingAdapter(() => _body(_accepted, 202));
      final api = AuthApi(dio: Dio()..httpClientAdapter = adapter);

      await expectLater(_register(api), completes);
    });

    test('sends birthDate, the name the contract documents', () async {
      final adapter = _CapturingAdapter(() => _body(_accepted, 202));
      final api = AuthApi(dio: Dio()..httpClientAdapter = adapter);

      await _register(api);

      final sent = adapter.requests.single.data as Map<String, dynamic>;
      expect(sent['birthDate'], '2000-01-01T00:00:00.000Z');
      expect(sent.containsKey('birthdate'), isFalse);
      expect(sent['email'], 'user@example.com');
      expect(sent['username'], 'someuser');
    });

    test('a 400 validation array becomes a typed rejection', () async {
      final adapter = _CapturingAdapter(
        () => _body(
          _validation(
            propertyName: 'Username',
            errorMessage: 'That username is already taken.',
          ),
          400,
        ),
      );
      final api = AuthApi(dio: Dio()..httpClientAdapter = adapter);

      await expectLater(
        _register(api),
        throwsA(
          isA<RegistrationRejectedException>().having(
            (e) => e.failures.single.message,
            'message',
            'That username is already taken.',
          ),
        ),
      );
    });

    test('a 400 that is not a validation array stays a DioException', () async {
      final adapter = _CapturingAdapter(() => _body('nope', 400));
      final api = AuthApi(dio: Dio()..httpClientAdapter = adapter);

      await expectLater(_register(api), throwsA(isA<DioException>()));
    });
  });

  group('RegistrationFailure routes messages to the right field', () {
    // Two of these don't report the property you'd expect, which is the whole
    // reason the mapping is keyed off errorCode first.
    test('age reports an empty propertyName', () {
      const failure = RegistrationFailure(
        propertyName: '',
        message: 'Age must be greater than 13',
        errorCode: 'LessThanValidator',
      );
      expect(failure.field, RegistrationField.birthdate);
    });

    test('email format and disposable-domain report Value', () {
      const format = RegistrationFailure(
        propertyName: 'Value',
        message: 'Invalid email format',
        errorCode: 'EmailInvalidFormat',
      );
      const disposable = RegistrationFailure(
        propertyName: 'Value',
        message: 'One-time or disposable email addresses are not allowed.',
        errorCode: 'EmailDisposableNotAllowed',
      );
      expect(format.field, RegistrationField.email);
      expect(disposable.field, RegistrationField.email);
    });

    test('a blank address reports Email', () {
      const failure = RegistrationFailure(
        propertyName: 'Email',
        message: 'Email cannot be empty',
      );
      expect(failure.field, RegistrationField.email);
    });

    test('General is not attributed to any field', () {
      const failure = RegistrationFailure(
        propertyName: 'General',
        message: 'Could not create the account.',
      );
      expect(failure.field, RegistrationField.general);
    });
  });

  group('AuthBloc registration', () {
    late _MockAuthRepository repository;
    late _MockSessionCubit session;
    late _MockRealtime realtime;
    late AuthBloc bloc;

    setUp(() {
      repository = _MockAuthRepository();
      session = _MockSessionCubit();
      realtime = _MockRealtime();
      bloc = AuthBloc(
        authRepository: repository,
        sessionCubit: session,
        realtimeService: realtime,
      );
    });

    tearDown(() => bloc.close());

    void whenRegister(Future<void> Function() answer) => when(
      () => repository.register(
        email: any(named: 'email'),
        username: any(named: 'username'),
        password: any(named: 'password'),
        birthdate: any(named: 'birthdate'),
      ),
    ).thenAnswer((_) => answer());

    RegisterSubmitted submit() => RegisterSubmitted(
      email: 'user@example.com',
      username: 'someuser',
      password: 'SecurePass123!',
      birthdate: DateTime.utc(2000),
    );

    test('an accepted signup goes to the code screen, not into the app',
        () async {
      // There is no session to enter with: `202` carries no token and no id,
      // and may not even have created an account.
      whenRegister(() async {});

      bloc.add(submit());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<AuthState>((s) => s.status == AuthStatus.loading),
          predicate<AuthState>(
            (s) =>
                s.status == AuthStatus.emailVerificationRequired &&
                s.pendingVerificationEmail == 'user@example.com',
          ),
        ]),
      );

      verifyNever(() => session.signedIn(any()));
      verifyNever(() => realtime.start());
    });

    test('a taken username lands on the username field, verbatim', () async {
      whenRegister(
        () async => throw const RegistrationRejectedException([
          RegistrationFailure(
            propertyName: 'Username',
            message: 'That username is already taken.',
          ),
        ]),
      );

      bloc.add(submit());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<AuthState>((s) => s.status == AuthStatus.loading),
          predicate<AuthState>(
            (s) =>
                s.status == AuthStatus.failure &&
                s.registrationErrors[RegistrationField.username] ==
                    'That username is already taken.' &&
                // Nothing duplicated into the snackbar, and above all not the
                // old "Incorrect username or password."
                s.errorMessage == null,
          ),
        ]),
      );
    });

    test('a General failure has no field, so it gets the message', () async {
      whenRegister(
        () async => throw const RegistrationRejectedException([
          RegistrationFailure(
            propertyName: 'General',
            message: 'Could not create the account.',
          ),
        ]),
      );

      bloc.add(submit());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<AuthState>((s) => s.status == AuthStatus.loading),
          predicate<AuthState>(
            (s) =>
                s.status == AuthStatus.failure &&
                s.registrationErrors.isEmpty &&
                s.errorMessage == 'Could not create the account.',
          ),
        ]),
      );
    });

    test('field errors do not survive the next attempt', () async {
      whenRegister(
        () async => throw const RegistrationRejectedException([
          RegistrationFailure(
            propertyName: 'Username',
            message: 'That username is already taken.',
          ),
        ]),
      );
      bloc.add(submit());
      await bloc.stream.firstWhere((s) => s.status == AuthStatus.failure);

      whenRegister(() async {});
      bloc.add(submit());
      final loading = await bloc.stream.first;

      expect(loading.status, AuthStatus.loading);
      expect(loading.registrationErrors, isEmpty);
    });
  });
}
