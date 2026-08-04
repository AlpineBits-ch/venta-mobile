import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/crypto/account_encryption_service.dart';
import 'package:venta_mobile/core/crypto/master_key_service.dart';
import 'package:venta_mobile/core/device/device_id_service.dart';
import 'package:venta_mobile/core/di/injector.dart';
import 'package:venta_mobile/core/storage/secure_storage_service.dart';
import 'package:venta_mobile/features/auth/data/auth_repository.dart';
import 'package:venta_mobile/features/mls/presentation/screens/recovery_code_setup_screen.dart';
import 'package:venta_mobile/features/mls/presentation/widgets/recovery_code_banner.dart';

/// What these cover: the flow that finally gives §C.1.1 a way to reach a human.
///
/// `RecoveryCodeScreen` existed, was tested, and had zero production callers - so
/// no real account could ever obtain a recovery code, which means the fix that
/// stops a password reset from destroying all encrypted history was inactive for
/// every user despite both halves being built.
///
/// Two properties are load-bearing and neither is obvious:
///
/// 1. **Nothing is written until the code is confirmed.** The tempting order -
///    commit, then show - leaves an account reporting `ready` while the human
///    holds no copy of the credential, and the prompt never fires again.
/// 2. **The offer never blocks the app.** Every account in the field needs this,
///    so a modal gate would meet the whole install base with a wall on the launch
///    after an update, over an improvement to an account that works today.

class _MockMasterKeys extends Mock implements MasterKeyService {}

class _MockEncryption extends Mock implements AccountEncryptionService {}

class _MockAuth extends Mock implements AuthRepository {}

class _MockDeviceIds extends Mock implements DeviceIdService {}

class _MockStorage extends Mock implements SecureStorageService {}

const _userId = 'user_1';
const _deviceId = 'device_1';
const _code = 'WXYZ-2345-6789-ABCD-JKMN-PQRS-TVWX-YZ23';

void main() {
  late _MockMasterKeys masterKeys;
  late _MockEncryption encryption;
  late ValueNotifier<bool> owed;

  setUp(() {
    masterKeys = _MockMasterKeys();
    encryption = _MockEncryption();
    owed = ValueNotifier<bool>(true);

    final auth = _MockAuth();
    when(() => auth.currentUserId).thenReturn(_userId);
    final deviceIds = _MockDeviceIds();
    when(() => deviceIds.deviceIdOrNull).thenReturn(_deviceId);

    when(() => encryption.recoveryCodeOwed).thenReturn(owed);
    when(
      () => encryption.markRecoveryCodeSaved(any()),
    ).thenAnswer((_) async {});
    when(
      () => masterKeys.generateRecoveryCode(),
    ).thenAnswer((_) async => _code);
    when(
      () => masterKeys.addRecoveryCode(
        userId: any(named: 'userId'),
        deviceId: any(named: 'deviceId'),
        password: any(named: 'password'),
        recoveryCode: any(named: 'recoveryCode'),
      ),
    ).thenAnswer((_) async => _code);

    getIt
      ..registerSingleton<MasterKeyService>(masterKeys)
      ..registerSingleton<AccountEncryptionService>(encryption)
      ..registerSingleton<AuthRepository>(auth)
      ..registerSingleton<DeviceIdService>(deviceIds)
      ..registerSingleton<SecureStorageService>(_MockStorage());
  });

  tearDown(() => getIt.reset());

  Future<void> pumpSetup(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RecoveryCodeSetupScreen()));
  }

  /// Types the password and walks through show -> confirm -> re-entry.
  Future<void> confirmTheCode(WidgetTester tester, {String? typed}) async {
    await tester.enterText(find.byType(TextField).first, 'hunter2');
    await tester.tap(find.text('Show my recovery code'));
    await tester.pumpAndSettle();

    // The code screen, on the show step.
    expect(find.text(_code), findsOneWidget);
    await tester.tap(find.text('I have saved it'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, typed ?? _code);
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
  }

  group('the banner cannot blank the app', () {
    // The white-screen class of failure, and the reason this is a test rather
    // than a comment: `RecoveryCodeBanner` is mounted in `AppShell`, the root of
    // every authenticated screen. Anything it throws from `build` takes the whole
    // shell with it - a red screen in debug, a blank one in release, with no
    // route back and no diagnostic the user can act on.
    //
    // `getIt` throws `StateError` for an unregistered type. Moving the lookup
    // back into `build` turns this red immediately.
    testWidgets(
      'an unregistered encryption service renders nothing, not an error',
      (tester) async {
        await getIt.reset();

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Column(children: [RecoveryCodeBanner(), Text('the app')]),
            ),
          ),
        );
        await tester.pump();

        expect(
          tester.takeException(),
          isNull,
          reason:
              'a cosmetic offer must degrade to nothing, never take the shell '
              'with it',
        );
        expect(find.text('the app'), findsOneWidget);
        expect(find.text('Set up'), findsNothing);
      },
    );
  });

  group('the banner', () {
    testWidgets('offers setup when a code is owed and nothing when it is not', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: RecoveryCodeBanner())),
      );
      await tester.pump();
      expect(find.text('Set up'), findsOneWidget);

      owed.value = false;
      await tester.pump();
      expect(find.text('Set up'), findsNothing);
    });

    testWidgets('is dismissible and blocks nothing behind it', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(children: [RecoveryCodeBanner(), Text('the app')]),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('the app'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(find.text('Set up'), findsNothing);
      expect(
        find.text('the app'),
        findsOneWidget,
        reason: 'the offer is an upgrade, not a gate',
      );
    });
  });

  group('the setup flow', () {
    testWidgets('writes nothing until the code has been typed back', (
      tester,
    ) async {
      await pumpSetup(tester);
      await tester.enterText(find.byType(TextField).first, 'hunter2');
      await tester.tap(find.text('Show my recovery code'));
      await tester.pumpAndSettle();

      // Shown, not yet confirmed.
      expect(find.text(_code), findsOneWidget);
      verify(() => masterKeys.generateRecoveryCode()).called(1);
      verifyNever(
        () => masterKeys.addRecoveryCode(
          userId: any(named: 'userId'),
          deviceId: any(named: 'deviceId'),
          password: any(named: 'password'),
          recoveryCode: any(named: 'recoveryCode'),
        ),
      );
    });

    testWidgets('commits the confirmed code and records the acknowledgement', (
      tester,
    ) async {
      await pumpSetup(tester);
      await confirmTheCode(tester);

      verify(
        () => masterKeys.addRecoveryCode(
          userId: _userId,
          deviceId: _deviceId,
          password: 'hunter2',
          recoveryCode: _code,
        ),
      ).called(1);
      verify(() => encryption.markRecoveryCodeSaved(_userId)).called(1);
    });

    testWidgets('the code the user types back is the code that gets wrapped', (
      tester,
    ) async {
      // The confirmation is compared against the *displayed* code, and the code
      // handed to `addRecoveryCode` is that same string - not a second draw. A
      // UI that showed one code and wrapped another would hand somebody a
      // credential that opens nothing, discovered mid-recovery.
      await pumpSetup(tester);
      await confirmTheCode(tester, typed: _code.toLowerCase());

      verify(
        () => masterKeys.addRecoveryCode(
          userId: any(named: 'userId'),
          deviceId: any(named: 'deviceId'),
          password: any(named: 'password'),
          recoveryCode: _code,
        ),
      ).called(1);
      verify(() => masterKeys.generateRecoveryCode()).called(1);
    });

    testWidgets('backing out of the confirmation commits nothing', (
      tester,
    ) async {
      await pumpSetup(tester);
      await tester.enterText(find.byType(TextField).first, 'hunter2');
      await tester.tap(find.text('Show my recovery code'));
      await tester.pumpAndSettle();

      // The wrong code, twice - the user cannot confirm and gives up.
      await tester.tap(find.text('I have saved it'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '2222-2222');
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(
        find.text('That does not match. Check it and try again.'),
        findsOneWidget,
      );
      verifyNever(
        () => masterKeys.addRecoveryCode(
          userId: any(named: 'userId'),
          deviceId: any(named: 'deviceId'),
          password: any(named: 'password'),
          recoveryCode: any(named: 'recoveryCode'),
        ),
      );
      verifyNever(() => encryption.markRecoveryCodeSaved(any()));
    });

    testWidgets(
      'a server that accepted and did not store is reported, not claimed',
      (tester) async {
        when(
          () => masterKeys.addRecoveryCode(
            userId: any(named: 'userId'),
            deviceId: any(named: 'deviceId'),
            password: any(named: 'password'),
            recoveryCode: any(named: 'recoveryCode'),
          ),
        ).thenThrow(const RecoveryCodeNotStoredException());

        await pumpSetup(tester);
        await confirmTheCode(tester);

        expect(find.textContaining('did not store it'), findsOneWidget);
        verifyNever(() => encryption.markRecoveryCodeSaved(any()));
      },
    );

    testWidgets('a rejected password keeps the same code for the retry', (
      tester,
    ) async {
      when(
        () => masterKeys.addRecoveryCode(
          userId: any(named: 'userId'),
          deviceId: any(named: 'deviceId'),
          password: any(named: 'password'),
          recoveryCode: any(named: 'recoveryCode'),
        ),
      ).thenThrow(Exception('Incorrect password'));

      await pumpSetup(tester);
      await confirmTheCode(tester);
      expect(find.textContaining('was not accepted'), findsOneWidget);

      // Second attempt: the code the user already wrote down is reused rather
      // than redrawn, so a mistyped password does not cost them the paper copy.
      await tester.tap(find.text('Show my recovery code'));
      await tester.pumpAndSettle();
      expect(find.text(_code), findsOneWidget);
      verify(() => masterKeys.generateRecoveryCode()).called(1);
    });

    testWidgets('an unlocked master key is required and says so', (
      tester,
    ) async {
      when(
        () => masterKeys.addRecoveryCode(
          userId: any(named: 'userId'),
          deviceId: any(named: 'deviceId'),
          password: any(named: 'password'),
          recoveryCode: any(named: 'recoveryCode'),
        ),
      ).thenAnswer((_) async => null);

      await pumpSetup(tester);
      await confirmTheCode(tester);

      expect(
        find.textContaining('not unlocked on this device'),
        findsOneWidget,
      );
      verifyNever(() => encryption.markRecoveryCodeSaved(any()));
    });

    testWidgets('"not now" leaves the account exactly as it was', (
      tester,
    ) async {
      await pumpSetup(tester);
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();

      verifyNever(() => masterKeys.generateRecoveryCode());
      verifyNever(
        () => masterKeys.addRecoveryCode(
          userId: any(named: 'userId'),
          deviceId: any(named: 'deviceId'),
          password: any(named: 'password'),
          recoveryCode: any(named: 'recoveryCode'),
        ),
      );
    });
  });
}
