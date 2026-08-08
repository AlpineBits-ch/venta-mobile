import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/device/device_id_service.dart';
import 'package:venta_mobile/core/di/injector.dart';
import 'package:venta_mobile/core/mls/mls_coverage_service.dart';
import 'package:venta_mobile/core/mls/mls_failure_log.dart';
import 'package:venta_mobile/core/mls/mls_join_request_service.dart';
import 'package:venta_mobile/core/mls/mls_service.dart';
import 'package:venta_mobile/core/theme/app_theme.dart';
import 'package:venta_mobile/features/auth/data/auth_repository.dart';
import 'package:venta_mobile/features/mls/data/mls_api.dart';
import 'package:venta_mobile/features/mls/data/models/mls_dtos.dart';
import 'package:venta_mobile/features/mls/presentation/widgets/channel_access_banner.dart';
import 'package:venta_mobile/features/mls/presentation/widgets/device_coverage_section.dart';
import 'package:venta_mobile/features/profile/data/models/profile_dto.dart';
import 'package:venta_mobile/features/profile/data/profile_repository.dart';

/// What these cover: the words on the screen, which are the whole feature.
///
/// Three situations reach a user, they read differently, and they resolve
/// differently. Only the device in hand can ask to be let in, so only that one
/// gets an action and a place above the composer; the other two are reference
/// material on a screen somebody went looking at, because a warning that fires
/// on an inconvenience the reader is not having is a warning they learn to
/// dismiss.
///
/// The copy is also the honest part. A device admitted now joins at the current
/// epoch, so the messages sent before it joined stay unreadable on it forever -
/// "we'll sync your messages" would be a lie, and this pins the sentence that
/// says so instead.
class _MockJoinRequests extends Mock implements MlsJoinRequestService {}

class _MockMls extends Mock implements MlsService {}

class _MockDeviceIds extends Mock implements DeviceIdService {}

class _MockAuth extends Mock implements AuthRepository {}

class _MockCoverageApi extends Mock implements MlsApi {}

class _MockProfiles extends Mock implements ProfileRepository {}

const _context = 'conv_1';
const _myUserId = 'user_me';
const _thisDevice = 'device-this';

MlsJoinRequestDto _pending() => const MlsJoinRequestDto(
  id: 'mljr_1',
  contextId: _context,
  conversationId: _context,
  generation: 1,
  requesterUserId: _myUserId,
  requesterDeviceId: _thisDevice,
  keyPackageHash: 'hash',
  signatureKeyFingerprint: '517F4-D75A0-AD0A2-6BBCF',
  state: MlsJoinRequestState.pending,
  requiredApprovals: 1,
);

void main() {
  late _MockMls mls;
  late _MockAuth auth;

  setUp(() {
    mls = _MockMls();
    auth = _MockAuth();

    final deviceIds = _MockDeviceIds();
    when(() => deviceIds.deviceIdOrNull).thenReturn(_thisDevice);
    when(() => deviceIds.deviceId).thenReturn(_thisDevice);
    when(() => mls.deviceIdService).thenReturn(deviceIds);
    when(() => mls.isUnlocked).thenReturn(true);
    when(
      () => mls.identityStatus,
    ).thenReturn(ValueNotifier(MlsIdentityStatus.unlocked));
    when(() => mls.activeGroupId(any())).thenReturn(null);
    when(() => mls.groupId(any(), any())).thenReturn(null);

    when(() => auth.currentUserId).thenReturn(_myUserId);

    getIt
      ..registerSingleton<MlsService>(mls)
      ..registerSingleton<AuthRepository>(auth)
      ..registerSingleton<MlsFailureLog>(MlsFailureLog());
  });

  tearDown(() => getIt.reset());

  // ---------------------------------------------------------------------------
  // 5a - the device in hand, inline above the composer
  // ---------------------------------------------------------------------------

  group('this device cannot read it', () {
    late _MockJoinRequests joinRequests;

    setUp(() {
      joinRequests = _MockJoinRequests();
      when(
        () => joinRequests.list(any(), isChannel: any(named: 'isChannel')),
      ).thenAnswer((_) async => const []);
      when(
        () => joinRequests.rejoin(any(), isChannel: any(named: 'isChannel')),
      ).thenAnswer((_) async => false);
      when(
        () => joinRequests.requestAccess(
          any(),
          isChannel: any(named: 'isChannel'),
        ),
      ).thenAnswer((_) async => _pending());
      when(
        () => joinRequests.ownFingerprint(),
      ).thenAnswer((_) async => '517F4-D75A0-AD0A2-6BBCF');

      getIt.registerSingleton<MlsJoinRequestService>(joinRequests);
    });

    Future<void> pump(WidgetTester tester, {bool isChannel = false}) async {
      await tester.pumpWidget(
        MaterialApp(
          // The real theme: the notice reads `context.statusColors`, an
          // extension the app installs and a bare MaterialApp does not.
          theme: AppTheme.dark,
          home: Scaffold(
            body: SingleChildScrollView(
              child: ChannelAccessBanner(
                contextId: _context,
                isChannel: isChannel,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('says what happened, without the vocabulary', (tester) async {
      await pump(tester);

      expect(
        find.text('This device can\'t read these messages'),
        findsOneWidget,
      );
      // None of "MLS", "leaf", "generation", "epoch", "group" or "key package"
      // means anything to the person reading it.
      for (final jargon in const [
        'MLS',
        'leaf',
        'generation',
        'epoch',
        'key package',
      ]) {
        expect(
          find.textContaining(jargon),
          findsNothing,
          reason: '"$jargon" reached the screen',
        );
      }
    });

    testWidgets('is honest that history does not come back', (tester) async {
      // A device admitted now joins at the current epoch. Copy that implied a
      // sync was coming would be false, and it is the one promise this notice
      // must not make.
      await pump(tester);

      expect(
        find.textContaining('Older messages will stay unavailable here'),
        findsOneWidget,
      );
    });

    testWidgets('names the channel when it is one', (tester) async {
      await pump(tester, isChannel: true);

      expect(find.textContaining('this channel\'s encryption'), findsOneWidget);
    });

    testWidgets('the action submits a join request', (tester) async {
      await pump(tester);
      await tester.tap(find.text('Request access'));
      await tester.pumpAndSettle();

      verify(
        () => joinRequests.requestAccess(_context, isChannel: false),
      ).called(1);
    });

    testWidgets('walking back in on its own asks nobody', (tester) async {
      // An external commit needs no approval and no round trip through another
      // person. Raising a request as well would put a review in somebody's
      // queue for a device that is already in.
      when(
        () => joinRequests.rejoin(any(), isChannel: any(named: 'isChannel')),
      ).thenAnswer((_) async => true);

      await pump(tester);
      await tester.tap(find.text('Request access'));
      await tester.pumpAndSettle();

      verifyNever(
        () => joinRequests.requestAccess(
          any(),
          isChannel: any(named: 'isChannel'),
        ),
      );
    });

    testWidgets('becomes a waiting state, not a progress bar', (tester) async {
      // This can take days. A spinner that runs for days is a lie about what is
      // happening.
      await pump(tester);
      await tester.tap(find.text('Request access'));
      await tester.pumpAndSettle();

      expect(find.text('Waiting to be let in'), findsOneWidget);
      expect(
        find.textContaining('Approve this from another of your devices'),
        findsOneWidget,
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('a failed request says so and offers the button again', (
      tester,
    ) async {
      when(
        () => joinRequests.requestAccess(
          any(),
          isChannel: any(named: 'isChannel'),
        ),
      ).thenThrow(Exception('offline'));

      await pump(tester);
      await tester.tap(find.text('Request access'));
      await tester.pumpAndSettle();

      expect(
        find.text('Could not send that request. Try again.'),
        findsOneWidget,
      );
      expect(find.text('Request access'), findsOneWidget);
      expect(find.text('Waiting to be let in'), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // 5b and 5c - the security screen, and nowhere else
  // ---------------------------------------------------------------------------

  group('the security screen', () {
    late _MockCoverageApi api;

    setUp(() {
      api = _MockCoverageApi();

      final profiles = _MockProfiles();
      when(() => profiles.cachedByUserId(any())).thenReturn(
        const ProfileDto(id: 'p1', userId: 'user_peer', userName: 'Alex'),
      );
      when(
        () => profiles.getByUserId(any()),
      ).thenAnswer((_) => Completer<ProfileDto>().future);

      getIt
        ..registerSingleton<ProfileRepository>(profiles)
        ..registerSingleton<MlsCoverageService>(
          MlsCoverageService(api: api, mls: mls),
        );
    });

    void serverSays(MlsCoverageDto dto) {
      when(
        () => api.getCoverage(
          contextId: any(named: 'contextId'),
          isChannel: any(named: 'isChannel'),
        ),
      ).thenAnswer((_) async => dto);
    }

    /// [mount] names the state: a different value remounts the section, which
    /// is how a test makes it ask again the way reopening the screen does.
    Future<void> pump(
      WidgetTester tester, {
      bool isChannel = false,
      String mount = 'first',
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: SingleChildScrollView(
              child: DeviceCoverageSection(
                key: ValueKey(mount),
                contextId: _context,
                isChannel: isChannel,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('names another of your devices, with no action', (
      tester,
    ) async {
      // The stranded device has to ask for itself, so there is nothing to tap
      // here - and offering a button that cannot work is worse than offering
      // none.
      serverSays(
        const MlsCoverageDto(
          contextId: _context,
          encrypted: true,
          generation: 2,
          ownDevices: [
            MlsDeviceCoverageDto(
              deviceId: 'device-my-pixel',
              deviceName: 'Pixel 8',
              covered: false,
            ),
          ],
        ),
      );

      await pump(tester);

      expect(
        find.text('Pixel 8 can\'t read this conversation'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Open Venta on that device and it will ask to be let back in.',
        ),
        findsOneWidget,
      );
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('names somebody else\'s device without blaming them', (
      tester,
    ) async {
      serverSays(
        const MlsCoverageDto(
          contextId: _context,
          encrypted: true,
          generation: 2,
          unreachableDevices: [
            UnreachableDeviceDto(
              userId: 'user_peer',
              deviceId: 'device-theirs',
              deviceName: 'iPhone',
            ),
          ],
        ),
      );

      await pump(tester);

      expect(
        find.text('Alex\'s iPhone can\'t read this conversation'),
        findsOneWidget,
      );
      expect(
        find.text(
          'They\'ll be asked to let it in the next time they open Venta on it.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('leaves the device in hand to the inline notice', (
      tester,
    ) async {
      // It is the one case with an action, and the action is above the
      // composer. Listing it here as well would say the same thing twice, in
      // the place where nothing can be done about it.
      serverSays(
        const MlsCoverageDto(
          contextId: _context,
          encrypted: true,
          generation: 2,
          ownDevices: [
            MlsDeviceCoverageDto(
              deviceId: _thisDevice,
              deviceName: 'This phone',
              covered: false,
            ),
          ],
        ),
      );

      await pump(tester);

      expect(find.textContaining('This phone'), findsNothing);
    });

    testWidgets('renders nothing when encryption is off', (tester) async {
      serverSays(const MlsCoverageDto(contextId: _context, encrypted: false));

      await pump(tester);

      expect(find.byType(Text), findsNothing);
    });

    testWidgets('renders nothing when every device is in', (tester) async {
      serverSays(
        const MlsCoverageDto(
          contextId: _context,
          encrypted: true,
          generation: 2,
          ownDevices: [MlsDeviceCoverageDto(deviceId: 'd-1', covered: true)],
        ),
      );

      await pump(tester);

      expect(find.byType(Text), findsNothing);
    });

    testWidgets('admits it could not check rather than saying all clear', (
      tester,
    ) async {
      serverSays(
        const MlsCoverageDto(
          contextId: _context,
          encrypted: true,
          generation: 2,
          coverageUnavailable: true,
        ),
      );

      await pump(tester);

      expect(find.text('Couldn\'t check right now.'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('a failed check does not retract a device it already named', (
      tester,
    ) async {
      serverSays(
        const MlsCoverageDto(
          contextId: _context,
          encrypted: true,
          generation: 2,
          ownDevices: [
            MlsDeviceCoverageDto(
              deviceId: 'device-my-pixel',
              deviceName: 'Pixel 8',
              covered: false,
            ),
          ],
        ),
      );
      await pump(tester);
      expect(
        find.text('Pixel 8 can\'t read this conversation'),
        findsOneWidget,
      );

      serverSays(
        const MlsCoverageDto(
          contextId: _context,
          encrypted: true,
          generation: 2,
          coverageUnavailable: true,
        ),
      );
      await pump(tester, mount: 'reopened');

      expect(
        find.text('Pixel 8 can\'t read this conversation'),
        findsOneWidget,
      );
      expect(find.text('Couldn\'t finish checking right now.'), findsOneWidget);
    });
  });
}
