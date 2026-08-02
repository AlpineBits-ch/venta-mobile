import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mls/venta_mls.dart';
import 'package:venta_mobile/core/device/device_api.dart';
import 'package:venta_mobile/core/device/device_id_service.dart';
import 'package:venta_mobile/core/mls/mls_join_request_service.dart';
import 'package:venta_mobile/core/mls/mls_service.dart';
import 'package:venta_mobile/core/mls/mls_session_manager.dart';
import 'package:venta_mobile/core/mls/mls_sync_service.dart';
import 'package:venta_mobile/core/storage/secure_storage_service.dart';
import 'package:venta_mobile/features/auth/data/auth_repository.dart';
import 'package:venta_mobile/features/conversations/data/conversation_repository.dart';
import 'package:venta_mobile/features/conversations/data/models/conversation_dto.dart';
import 'package:venta_mobile/features/mls/data/models/mls_dtos.dart';

/// What these cover: key package supply, which fails silently and asymmetrically.
///
/// Every group this device is added to consumes one single-use package. Run out
/// and the server has nothing to hand callers, so this device is quietly left
/// out of new conversations - readable by everyone except the person holding it.
/// The last-resort package is the floor that prevents that, and it is reusable
/// precisely because it is the fallback.
///
/// The server decides the count, not the client: it is the one that knows what
/// has been consumed, expired or swept.

class _MockMls extends Mock implements MlsService {}

class _MockDeviceApi extends Mock implements DeviceApi {}

class _MockDeviceId extends Mock implements DeviceIdService {}

class _MockSync extends Mock implements MlsSyncService {}

class _MockAuth extends Mock implements AuthRepository {}

class _MockStorage extends Mock implements SecureStorageService {}

class _MockJoinRequests extends Mock implements MlsJoinRequestService {}

class _MockConversations extends Mock implements ConversationRepository {}

const _device = 'device-a';

KeyPackageResult _package(String id) =>
    KeyPackageResult(keyPackage: 'kp-$id', initPrivateKey: 'init-$id');

ConversationDto _conversation(String id, {required bool encrypted}) =>
    ConversationDto(
      id: id,
      members: const [],
      encryptionState: encrypted
          ? ConversationEncryption.encrypted
          : ConversationEncryption.plain,
    );

void main() {
  late _MockMls mls;
  late _MockDeviceApi deviceApi;
  late _MockDeviceId deviceIds;
  late _MockSync sync;
  late _MockJoinRequests joinRequests;
  late _MockConversations conversations;
  late MlsSessionManager manager;

  setUpAll(() {
    registerFallbackValue(const <KeyPackageUpload>[]);
    registerFallbackValue(const <MlsAdmissionCandidate>[]);
  });

  setUp(() {
    mls = _MockMls();
    deviceApi = _MockDeviceApi();
    deviceIds = _MockDeviceId();
    sync = _MockSync();
    joinRequests = _MockJoinRequests();
    conversations = _MockConversations();
    manager = MlsSessionManager(
      mls: mls,
      sync_: sync,
      deviceApi: deviceApi,
      deviceIdService: deviceIds,
      authRepository: _MockAuth(),
      secureStorage: _MockStorage(),
      joinRequests: joinRequests,
      conversations: conversations,
    );

    when(() => sync.processPendingWelcomes()).thenAnswer((_) async {});
    when(() => conversations.cached).thenReturn(const []);
    when(() => conversations.fetch()).thenAnswer((_) async => const []);
    when(
      () => joinRequests.requestAccessWhereMissing(any()),
    ).thenAnswer((_) async => const []);

    when(() => deviceIds.deviceIdOrNull).thenReturn(_device);
    when(() => mls.isUnlocked).thenReturn(true);
    when(
      () => deviceApi.uploadKeyPackages(
        clientDeviceId: any(named: 'clientDeviceId'),
        keyPackages: any(named: 'keyPackages'),
      ),
    ).thenAnswer((_) async => 0);
  });

  test('uploads exactly the count the server asked for', () async {
    when(() => deviceApi.keyPackagesToGenerate(_device)).thenAnswer(
      (_) async => const GenerateKeyPackagesDto(count: 40),
    );
    when(() => mls.generateKeyPackages(40))
        .thenAnswer((_) async => [for (var i = 0; i < 40; i++) _package('$i')]);

    await manager.replenishKeyPackages();

    final captured = verify(
      () => deviceApi.uploadKeyPackages(
        clientDeviceId: _device,
        keyPackages: captureAny(named: 'keyPackages'),
      ),
    ).captured.single as List<KeyPackageUpload>;

    expect(captured, hasLength(40));
    expect(captured.every((p) => !p.isLastResort), isTrue);
  });

  test('adds a last-resort package when the server holds none', () async {
    when(() => deviceApi.keyPackagesToGenerate(_device)).thenAnswer(
      (_) async =>
          const GenerateKeyPackagesDto(count: 2, needsLastResort: true),
    );
    when(() => mls.generateKeyPackages(2))
        .thenAnswer((_) async => [_package('a'), _package('b')]);
    when(() => mls.generateKeyPackages(1))
        .thenAnswer((_) async => [_package('lr')]);

    await manager.replenishKeyPackages();

    final captured = verify(
      () => deviceApi.uploadKeyPackages(
        clientDeviceId: _device,
        keyPackages: captureAny(named: 'keyPackages'),
      ),
    ).captured.single as List<KeyPackageUpload>;

    expect(captured, hasLength(3));
    expect(
      captured.where((p) => p.isLastResort).map((p) => p.keyPackage),
      ['kp-lr'],
      reason: 'exactly one package may be marked reusable',
    );
  });

  test('a fully stocked device uploads nothing at all', () async {
    when(() => deviceApi.keyPackagesToGenerate(_device))
        .thenAnswer((_) async => const GenerateKeyPackagesDto());

    await manager.replenishKeyPackages();

    verifyNever(
      () => deviceApi.uploadKeyPackages(
        clientDeviceId: any(named: 'clientDeviceId'),
        keyPackages: any(named: 'keyPackages'),
      ),
    );
    verifyNever(() => mls.generateKeyPackages(any()));
  });

  test('does nothing while the MLS session is locked', () async {
    when(() => mls.isUnlocked).thenReturn(false);

    await manager.replenishKeyPackages();

    verifyNever(() => deviceApi.keyPackagesToGenerate(any()));
  });

  group('resume trigger', () {
    test('checks once, then holds off until the interval elapses', () async {
      when(() => deviceApi.keyPackagesToGenerate(_device))
          .thenAnswer((_) async => const GenerateKeyPackagesDto());

      await manager.replenishIfStale();
      await manager.replenishIfStale();
      await manager.replenishIfStale();

      verify(() => deviceApi.keyPackagesToGenerate(_device)).called(1);
    });

    test('a failed check still holds off rather than retrying every resume', () async {
      when(() => deviceApi.keyPackagesToGenerate(_device))
          .thenThrow(Exception('offline'));

      // Must not throw - this runs detached from any UI.
      await manager.replenishIfStale();
      await manager.replenishIfStale();

      verify(() => deviceApi.keyPackagesToGenerate(_device)).called(1);
    });
  });

  /// Contract §B's discovery sweep, and the control-flow bug Alpine shipped.
  ///
  /// `requestAccessWhereMissing` had no caller on this client at all, so a
  /// handset locked out of an encrypted conversation never asked to be let back
  /// in unless its owner happened to open that conversation and read a banner -
  /// which is no use for the conversations they do not know they are missing
  /// from, and none at all for the ones they never open.
  group('launch sequence', () {
    setUp(() {
      when(() => deviceApi.keyPackagesToGenerate(_device))
          .thenAnswer((_) async => const GenerateKeyPackagesDto());
    });

    test('asks to be admitted to what this device holds no group for', () async {
      when(() => conversations.cached).thenReturn([
        _conversation('conv_a', encrypted: true),
        _conversation('conv_b', encrypted: false),
      ]);

      await manager.sync();

      final candidates = verify(
        () => joinRequests.requestAccessWhereMissing(captureAny()),
      ).captured.single as Iterable<MlsAdmissionCandidate>;

      expect(candidates.map((c) => c.contextId), ['conv_a', 'conv_b']);
      expect(
        candidates.map((c) => c.serverSaysEncrypted),
        [true, false],
        reason:
            'the list is generous because filtering it is free; the sweep '
            'decides locally which of these to probe',
      );
      expect(candidates.every((c) => !c.isChannel), isTrue);
    });

    test('a failed replenish does not skip the steps after it', () async {
      // Alpine's bug, verbatim: one `try` wrapped replenish, the master-key
      // check and Welcome processing, so a single failed key-package upload
      // silently cancelled the other two - permanently, because nothing else
      // processes pending Welcomes. The device sat outside a group it had been
      // properly invited to and nothing said so.
      when(() => deviceApi.keyPackagesToGenerate(_device))
          .thenThrow(Exception('upload refused'));

      await manager.sync();

      verify(() => sync.processPendingWelcomes()).called(1);
      verify(() => joinRequests.requestAccessWhereMissing(any())).called(1);
    });

    test('a failed Welcome pass does not skip the sweep', () async {
      when(() => sync.processPendingWelcomes()).thenThrow(Exception('offline'));

      await manager.sync();

      verify(() => joinRequests.requestAccessWhereMissing(any())).called(1);
    });

    test('a failed sweep is survivable, not fatal to launch', () async {
      when(
        () => joinRequests.requestAccessWhereMissing(any()),
      ).thenThrow(Exception('rate limited'));

      // Must not throw. A failure to *discover* an exclusion must not undo the
      // steps that already fixed one.
      await manager.sync();
    });

    test('fetches the conversation list when nothing is cached yet', () async {
      // The conversations this device is locked out of are exactly the ones its
      // owner has not opened, so an empty cache is the case that matters most.
      when(() => conversations.fetch()).thenAnswer(
        (_) async => [_conversation('conv_a', encrypted: true)],
      );

      await manager.sync();

      verify(() => conversations.fetch()).called(1);
    });

    test('does nothing at all while the session is locked', () async {
      when(() => mls.isUnlocked).thenReturn(false);

      await manager.sync();

      verifyNever(() => joinRequests.requestAccessWhereMissing(any()));
    });
  });
}
