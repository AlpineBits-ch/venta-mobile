import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/device/device_id_service.dart';
import 'package:venta_mobile/core/diagnostics/secure_storage_fault.dart';
import 'package:venta_mobile/core/storage/secure_storage_service.dart';
import 'package:venta_mobile/core/realtime/realtime_service.dart';
import 'package:venta_mobile/core/session/session_cubit.dart';
import 'package:venta_mobile/features/auth/bloc/auth_bloc.dart';
import 'package:venta_mobile/features/auth/data/auth_api.dart';
import 'package:venta_mobile/features/auth/data/auth_repository.dart';
import 'package:venta_mobile/features/auth/data/models/token_response.dart';

/// What these cover: **"Something went wrong - please try again." on a login the
/// server had already completed.**
///
/// The Identity logs showed OpenIddict validating the request, creating the
/// authorization and inserting access, refresh and id tokens. The client then
/// told the user it had failed. Two unguarded keychain writes sat after the
/// grant returned - `_applyTokens` and `writeServerUrl` - and `AuthBloc` had no
/// branch for a `PlatformException`, so a device whose keychain was refusing
/// produced the generic message reserved for "we have no idea".
///
/// Corroborating detail from the same logs: the client sent a device id the
/// server had never seen, so the session row was written with `device_id NULL`.
/// That is precisely what the ephemeral fallback in `DeviceIdService` produces -
/// meaning the keychain *read* had already failed at startup and been absorbed
/// silently. Every layer degraded quietly and the fault reached the user as a
/// sentence that named nothing.

class _MockSecureStorage extends Mock implements SecureStorageService {}

class _MockAuthApi extends Mock implements AuthApi {}

class _MockDeviceIds extends Mock implements DeviceIdService {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockSessionCubit extends Mock implements SessionCubit {}

class _MockRealtime extends Mock implements RealtimeService {}

/// Exactly what `flutter_secure_storage_darwin` produces: its
/// `handleResponse` wraps any non-`noErr` `OSStatus` as this shape, with the
/// raw status in `details`.
PlatformException _keychainRefused([int status = -34018]) => PlatformException(
  code: 'Unexpected security result code',
  message: 'Code: $status, Message: A required entitlement is not present.',
  details: status,
);

const _tokens = TokenResponse(
  accessToken: 'access-token',
  refreshToken: 'refresh-token',
  expiresIn: 3600,
);

void main() {
  late _MockSecureStorage storage;
  late _MockAuthApi api;
  late AuthRepository repository;

  setUp(() {
    storage = _MockSecureStorage();
    api = _MockAuthApi();
    final deviceIds = _MockDeviceIds();
    when(() => deviceIds.deviceIdOrNull).thenReturn('device-1');

    repository = AuthRepository(
      api: api,
      secureStorage: storage,
      deviceIdService: deviceIds,
    );

    when(
      () => api.passwordGrant(
        baseUrl: any(named: 'baseUrl'),
        username: any(named: 'username'),
        password: any(named: 'password'),
        mfaCode: any(named: 'mfaCode'),
        deviceId: any(named: 'deviceId'),
      ),
    ).thenAnswer((_) async => _tokens);
    when(
      () => storage.writeTokens(
        accessToken: any(named: 'accessToken'),
        refreshToken: any(named: 'refreshToken'),
      ),
    ).thenAnswer((_) async {});
    when(() => storage.writeServerUrl(any())).thenAnswer((_) async {});
  });

  group('a refused keychain does not fail a successful login', () {
    test('a refused token write still signs the user in', () async {
      when(
        () => storage.writeTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ),
      ).thenThrow(_keychainRefused());

      await expectLater(repository.login('someone', 'hunter2'), completes);

      expect(
        repository.isAuthenticated,
        isTrue,
        reason:
            'the grant succeeded and the tokens are in memory - the only '
            'thing that failed is durability',
      );
      expect(repository.currentUserId, isNull); // the fake token has no sub
    });

    test('a refused server-url write still signs the user in', () async {
      when(() => storage.writeServerUrl(any())).thenThrow(_keychainRefused());

      await expectLater(repository.login('someone', 'hunter2'), completes);

      expect(repository.isAuthenticated, isTrue);
    });

    test('the degradation is reported, not concealed', () async {
      when(
        () => storage.writeTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ),
      ).thenThrow(_keychainRefused());

      expect(repository.sessionPersisted.value, isTrue);
      await repository.login('someone', 'hunter2');

      expect(
        repository.sessionPersisted.value,
        isFalse,
        reason: 'the user has to be told they will be signed out on relaunch',
      );
    });

    test('an ordinary login persists and says so', () async {
      await repository.login('someone', 'hunter2');

      expect(repository.isAuthenticated, isTrue);
      expect(repository.sessionPersisted.value, isTrue);
      verify(
        () => storage.writeTokens(
          accessToken: 'access-token',
          refreshToken: 'refresh-token',
        ),
      ).called(1);
    });

    test('a real credential failure is still a failure', () async {
      // The guard must not swallow the thing it is next to. A rejected grant is
      // a login failure and the caller has to see it.
      when(
        () => api.passwordGrant(
          baseUrl: any(named: 'baseUrl'),
          username: any(named: 'username'),
          password: any(named: 'password'),
          mfaCode: any(named: 'mfaCode'),
          deviceId: any(named: 'deviceId'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/connect/token'),
          response: Response<void>(
            requestOptions: RequestOptions(path: '/connect/token'),
            statusCode: 401,
          ),
        ),
      );

      await expectLater(
        repository.login('someone', 'wrong'),
        throwsA(isA<DioException>()),
      );
      expect(repository.isAuthenticated, isFalse);
    });

    test('a token response with no refresh token does not throw', () async {
      // Was `_refreshToken!`. The server is asked for `offline_access` and has
      // always answered with one, but "has always" is not a type - and the
      // resulting `TypeError` presented identically to the keychain fault.
      when(
        () => api.passwordGrant(
          baseUrl: any(named: 'baseUrl'),
          username: any(named: 'username'),
          password: any(named: 'password'),
          mfaCode: any(named: 'mfaCode'),
          deviceId: any(named: 'deviceId'),
        ),
      ).thenAnswer(
        (_) async =>
            const TokenResponse(accessToken: 'access-token', expiresIn: 3600),
      );

      await expectLater(repository.login('someone', 'hunter2'), completes);
      expect(repository.sessionPersisted.value, isFalse);
    });
  });

  group('register no longer signs in', () {
    test(
      'the keychain is never reached, because no session is created',
      () async {
        // This used to call `login` and inherit its keychain exposure. It can't
        // any more: registration answers `202` with no token and no user id, and
        // the same `202` whether or not an account was created - so there is
        // nothing to sign in with. See `registration_contract_test.dart`.
        when(
          () => api.register(
            baseUrl: any(named: 'baseUrl'),
            email: any(named: 'email'),
            username: any(named: 'username'),
            password: any(named: 'password'),
            birthdate: any(named: 'birthdate'),
          ),
        ).thenAnswer((_) async {});

        await expectLater(
          repository.register(
            email: 'a@b.c',
            username: 'someone',
            password: 'hunter2',
            birthdate: DateTime(2000),
          ),
          completes,
        );
        expect(repository.isAuthenticated, isFalse);
        verifyNever(
          () => api.passwordGrant(
            baseUrl: any(named: 'baseUrl'),
            username: any(named: 'username'),
            password: any(named: 'password'),
            mfaCode: any(named: 'mfaCode'),
            deviceId: any(named: 'deviceId'),
          ),
        );
        verifyNever(
          () => storage.writeTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          ),
        );
      },
    );
  });

  group('SecureStorageFault names the OSStatus', () {
    test('decodes the plugin shape, status first', () {
      // The number is the diagnosis. -34018 is a signing mistake no user action
      // fixes; -25308 is a locked device that fixes itself. Reporting them as
      // one string is what left us guessing.
      final fault = SecureStorageFault.from(_keychainRefused())!;

      expect(fault.osStatus, -34018);
      expect(fault.statusName, 'errSecMissingEntitlement');
      expect(fault.explanation, contains('keychain access group'));
      expect(fault.toString(), contains('-34018'));
    });

    test('falls back to parsing the message when details is absent', () {
      final fault = SecureStorageFault.from(
        PlatformException(
          code: 'Unexpected security result code',
          message: 'Code: -25308, Message: Interaction is not allowed.',
        ),
      )!;

      expect(fault.osStatus, -25308);
      expect(fault.statusName, 'errSecInteractionNotAllowed');
      expect(fault.explanation, contains('locked'));
    });

    test('an unknown status still carries its number', () {
      final fault = SecureStorageFault.from(_keychainRefused(-99999))!;

      expect(fault.statusName, 'OSStatus -99999');
      expect(fault.toString(), contains('-99999'));
    });

    test('is null for anything that is not a platform failure', () {
      expect(
        SecureStorageFault.from(
          DioException(requestOptions: RequestOptions(path: '/')),
        ),
        isNull,
      );
      expect(SecureStorageFault.from(StateError('nope')), isNull);
    });

    test('reporting a swallowed fault never throws', () {
      // It runs on the launch path, where Sentry is the last thing to start. An
      // error reporter that throws replaces a diagnosable fault with an
      // undiagnosable one.
      expect(
        () => reportSwallowed('test', _keychainRefused(), StackTrace.current),
        returnsNormally,
      );
      expect(
        () => reportSwallowed('test', StateError('plain'), null),
        returnsNormally,
      );
    });
  });

  group('AuthBloc reports the fault instead of "something went wrong"', () {
    late _MockAuthRepository authRepository;
    late AuthBloc bloc;

    setUp(() {
      authRepository = _MockAuthRepository();
      when(() => authRepository.currentUserId).thenReturn('user-1');
      final session = _MockSessionCubit();
      when(() => session.signedIn(any())).thenReturn(null);
      final realtime = _MockRealtime();
      when(() => realtime.start()).thenAnswer((_) async {});

      bloc = AuthBloc(
        authRepository: authRepository,
        sessionCubit: session,
        realtimeService: realtime,
      );
    });

    tearDown(() => bloc.close());

    test('a keychain failure is named, with its OSStatus', () async {
      // This is the exact string the user saw replaced by one that says what
      // happened. "Something went wrong - please try again." was reserved for
      // "we have no idea", and a -34018 is not that.
      when(
        () =>
            authRepository.login(any(), any(), mfaCode: any(named: 'mfaCode')),
      ).thenThrow(_keychainRefused());

      bloc.add(const LoginSubmitted(input: 'someone', password: 'hunter2'));
      final state = await bloc.stream.firstWhere(
        (s) => s.status == AuthStatus.failure,
      );

      expect(state.errorMessage, isNot(contains('Something went wrong')));
      expect(state.errorMessage, contains('errSecMissingEntitlement'));
      expect(state.errorMessage, contains('-34018'));
      expect(state.errorMessage, contains('sign in again'));
    });

    test('a wrong password is still a wrong password', () async {
      when(
        () =>
            authRepository.login(any(), any(), mfaCode: any(named: 'mfaCode')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/connect/token'),
          response: Response<void>(
            requestOptions: RequestOptions(path: '/connect/token'),
            statusCode: 401,
          ),
        ),
      );

      bloc.add(const LoginSubmitted(input: 'someone', password: 'wrong'));
      final state = await bloc.stream.firstWhere(
        (s) => s.status == AuthStatus.failure,
      );

      expect(state.errorMessage, 'Incorrect username or password.');
    });

    test('an unrecognised failure still gets the generic message', () async {
      when(
        () =>
            authRepository.login(any(), any(), mfaCode: any(named: 'mfaCode')),
      ).thenThrow(StateError('something genuinely unexpected'));

      bloc.add(const LoginSubmitted(input: 'someone', password: 'hunter2'));
      final state = await bloc.stream.firstWhere(
        (s) => s.status == AuthStatus.failure,
      );

      expect(state.errorMessage, 'Something went wrong - please try again.');
    });
  });
}
