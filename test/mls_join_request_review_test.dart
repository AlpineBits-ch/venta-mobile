import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/device/device_id_service.dart';
import 'package:venta_mobile/core/di/injector.dart';
import 'package:venta_mobile/core/mls/device_admission_service.dart';
import 'package:venta_mobile/core/mls/mls_join_request_service.dart';
import 'package:venta_mobile/core/mls/mls_service.dart';
import 'package:venta_mobile/core/realtime/realtime_event.dart';
import 'package:venta_mobile/core/realtime/realtime_service.dart';
import 'package:venta_mobile/core/theme/app_theme.dart';
import 'package:venta_mobile/features/auth/data/auth_repository.dart';
import 'package:venta_mobile/features/mls/data/models/mls_dtos.dart';
import 'package:venta_mobile/features/mls/presentation/widgets/mls_join_request_review.dart';
import 'package:venta_mobile/features/profile/data/models/profile_dto.dart';
import 'package:venta_mobile/features/profile/data/profile_repository.dart';

/// What these cover: the missing half of contract §B on this client.
///
/// A join request against a **conversation** reached the server, sat at
/// `Pending` until it expired, and was never shown to a human - because the only
/// review queue in the app lived behind guild channel settings, which a DM does
/// not have. The reporter's words were "neither mobile or anything else shows a
/// prompt that allows me to set it". The mechanism worked the whole time;
/// nobody was ever asked.
///
/// Three properties here are load-bearing and none is cosmetic:
///
/// 1. **The fingerprint is what gets shown.** It is the long-lived value a human
///    compares out of band. The key-package hash changes on every request and
///    cannot be read aloud, so showing it would look like verification while
///    verifying nothing.
/// 2. **Own device and correspondent's device are different questions.** "Is
///    this really my laptop" and "is this really their new phone" have different
///    answers and different consequences, and one wording for both invites a
///    reviewer to approve without checking anything.
/// 3. **A verification failure is not a generic error.** It means the bytes on
///    offer were not the bytes that were reviewed, which cannot happen by
///    accident.

class _MockJoinRequests extends Mock implements MlsJoinRequestService {}

class _MockAdmission extends Mock implements DeviceAdmissionService {}

class _MockMls extends Mock implements MlsService {}

class _MockDeviceIds extends Mock implements DeviceIdService {}

class _MockAuth extends Mock implements AuthRepository {}

class _MockRealtime extends Mock implements RealtimeService {}

class _MockProfiles extends Mock implements ProfileRepository {}

const _context = 'conv_1';
const _myUserId = 'user_me';
const _myDeviceId = 'device-this';
const _fingerprint = '517F4-D75A0-AD0A2-6BBCF';

MlsJoinRequestDto _request({
  String requesterUserId = 'user_peer',
  String requesterDeviceId = 'device-theirs',
  String? deviceName,
  List<String> approvers = const [],
}) => MlsJoinRequestDto(
  id: 'mljr_1',
  contextId: _context,
  conversationId: _context,
  generation: 1,
  requesterUserId: requesterUserId,
  requesterDeviceId: requesterDeviceId,
  requesterDeviceName: deviceName,
  keyPackageHash: 'a-hash-nobody-can-read-aloud',
  signatureKeyFingerprint: _fingerprint,
  state: MlsJoinRequestState.pending,
  requiredApprovals: 1,
  approverUserIds: approvers,
);

void main() {
  late _MockJoinRequests joinRequests;
  late _MockAdmission admission;
  late _MockMls mls;
  late StreamController<RealtimeEvent> events;
  late ValueNotifier<List<AdmittedDevice>> admitted;

  setUpAll(() => registerFallbackValue(_request()));

  setUp(() {
    joinRequests = _MockJoinRequests();
    admission = _MockAdmission();
    mls = _MockMls();
    events = StreamController<RealtimeEvent>.broadcast();
    admitted = ValueNotifier<List<AdmittedDevice>>(const []);

    final deviceIds = _MockDeviceIds();
    when(() => deviceIds.deviceIdOrNull).thenReturn(_myDeviceId);
    when(() => mls.deviceIdService).thenReturn(deviceIds);
    when(() => mls.activeGroupId(any())).thenReturn('group-id');

    final auth = _MockAuth();
    when(() => auth.currentUserId).thenReturn(_myUserId);

    final realtime = _MockRealtime();
    when(() => realtime.events).thenAnswer((_) => events.stream);

    final profiles = _MockProfiles();
    when(() => profiles.cachedByUserId(any())).thenReturn(null);
    // Never resolves. The card falls back to the user id, which is all these
    // assertions need and keeps the profile layer out of them.
    when(
      () => profiles.getByUserId(any()),
    ).thenAnswer((_) => Completer<ProfileDto>().future);

    when(() => admission.recentlyAdmitted).thenReturn(admitted);
    when(() => admission.acknowledge(any())).thenReturn(null);
    when(
      () => joinRequests.list(any(), isChannel: any(named: 'isChannel')),
    ).thenAnswer((_) async => const []);
    when(
      () => joinRequests.approve(
        contextId: any(named: 'contextId'),
        request: any(named: 'request'),
        isChannel: any(named: 'isChannel'),
      ),
    ).thenAnswer((_) async => true);
    when(
      () => joinRequests.deny(
        contextId: any(named: 'contextId'),
        requestId: any(named: 'requestId'),
        isChannel: any(named: 'isChannel'),
      ),
    ).thenAnswer((_) async {});

    getIt
      ..registerSingleton<MlsJoinRequestService>(joinRequests)
      ..registerSingleton<DeviceAdmissionService>(admission)
      ..registerSingleton<MlsService>(mls)
      ..registerSingleton<AuthRepository>(auth)
      ..registerSingleton<RealtimeService>(realtime)
      ..registerSingleton<ProfileRepository>(profiles);
  });

  tearDown(() async {
    await events.close();
    await getIt.reset();
  });

  void queueHolds(List<MlsJoinRequestDto> requests) {
    when(
      () => joinRequests.list(any(), isChannel: any(named: 'isChannel')),
    ).thenAnswer((_) async => requests);
  }

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        // The real theme, because the card reads `context.statusColors` - an
        // extension the app installs and a bare `MaterialApp` does not.
        theme: AppTheme.dark,
        home: const Scaffold(
          body: SingleChildScrollView(
            child: MlsJoinRequestReview(contextId: _context, isChannel: false),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows nothing when there is nothing to review', (tester) async {
    await pump(tester);

    expect(find.text('ACCESS REQUESTS'), findsNothing);
  });

  testWidgets('surfaces a pending request for a DM', (tester) async {
    // The reported bug in one assertion: this queue existed only for guild
    // channels, so this request was unapprovable through any UI in the app.
    queueHolds([_request()]);

    await pump(tester);

    expect(find.text('ACCESS REQUESTS'), findsOneWidget);
    expect(find.text('Approve'), findsOneWidget);
    expect(find.text('Deny'), findsOneWidget);
  });

  testWidgets('shows the fingerprint and never the key-package hash', (
    tester,
  ) async {
    queueHolds([_request()]);

    await pump(tester);

    expect(find.text(_fingerprint), findsOneWidget);
    expect(find.text('a-hash-nobody-can-read-aloud'), findsNothing);
  });

  testWidgets('words our own device differently from a correspondent\'s', (
    tester,
  ) async {
    queueHolds([
      _request(
        requesterUserId: _myUserId,
        requesterDeviceId: 'device-my-laptop',
        deviceName: 'Desktop',
      ),
    ]);

    await pump(tester);

    expect(find.text('"Desktop" wants in'), findsOneWidget);
    expect(
      find.textContaining('signed in to your account'),
      findsOneWidget,
      reason: 'the trust question for our own device is not the peer one',
    );
  });

  testWidgets('hides this device\'s own request', (tester) async {
    // The server refuses a device approving itself, and the access banner
    // already renders this case as "waiting to be let in". An Approve button
    // here could only ever produce a 400.
    queueHolds([
      _request(requesterUserId: _myUserId, requesterDeviceId: _myDeviceId),
    ]);

    await pump(tester);

    expect(find.text('ACCESS REQUESTS'), findsNothing);
  });

  testWidgets('offers no approval from a device outside the group', (
    tester,
  ) async {
    // Approving is what makes *this* client mint the Add commit. A device with
    // no leaf cannot produce one, so the action must not be offered - it would
    // record an approval server-side and then fail, which reads to everyone
    // else as though somebody vouched and the join broke.
    when(() => mls.activeGroupId(any())).thenReturn(null);
    queueHolds([_request()]);

    await pump(tester);

    final approve = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(approve.onPressed, isNull);
    expect(find.textContaining('isn\'t in the group either'), findsOneWidget);
  });

  testWidgets('a verification failure is not a generic error', (tester) async {
    // It means the bytes on offer were not the bytes that were reviewed, which
    // is the substitution the whole review exists to catch. Rendering it as
    // "could not approve that request" would tell the user to retry into it.
    when(
      () => joinRequests.approve(
        contextId: any(named: 'contextId'),
        request: any(named: 'request'),
        isChannel: any(named: 'isChannel'),
      ),
    ).thenThrow(
      const JoinRequestVerificationException(
        'The key package does not match the one that was reviewed.',
      ),
    );
    queueHolds([_request()]);

    await pump(tester);
    await tester.tap(find.text('Approve'));
    await tester.pumpAndSettle();

    expect(find.text('That key did not match'), findsOneWidget);
    expect(find.text('Could not approve that request.'), findsNothing);
  });

  testWidgets('an ordinary failure stays an ordinary error', (tester) async {
    when(
      () => joinRequests.approve(
        contextId: any(named: 'contextId'),
        request: any(named: 'request'),
        isChannel: any(named: 'isChannel'),
      ),
    ).thenThrow(Exception('offline'));
    queueHolds([_request()]);

    await pump(tester);
    await tester.tap(find.text('Approve'));
    await tester.pumpAndSettle();

    expect(find.text('Could not approve that request.'), findsOneWidget);
    expect(find.text('That key did not match'), findsNothing);
  });

  testWidgets('denying goes to the conversation route, not the channel one', (
    tester,
  ) async {
    queueHolds([_request()]);

    await pump(tester);
    await tester.tap(find.text('Deny'));
    await tester.pumpAndSettle();

    verify(
      () => joinRequests.deny(
        contextId: _context,
        requestId: 'mljr_1',
        isChannel: false,
      ),
    ).called(1);
  });

  testWidgets('picks up a request raised while the thread is open', (
    tester,
  ) async {
    await pump(tester);
    expect(find.text('ACCESS REQUESTS'), findsNothing);

    queueHolds([_request()]);
    events.add(
      RealtimeEvent('conversation.MlsJoinRequest', [
        {'contextId': _context, 'requestId': 'mljr_1'},
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('ACCESS REQUESTS'), findsOneWidget);
  });

  testWidgets('ignores a push for a different conversation', (tester) async {
    await pump(tester);

    queueHolds([_request()]);
    events.add(
      RealtimeEvent('conversation.MlsJoinRequest', [
        {'contextId': 'conv_elsewhere', 'requestId': 'mljr_9'},
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('ACCESS REQUESTS'), findsNothing);
  });

  testWidgets('an automatic admission is announced, not silent', (
    tester,
  ) async {
    // §G.2, item 1. Auto-approval is silent *admission*, never silent
    // *notification* - an admission nobody is told about is one nobody can
    // dispute, so it carries the fingerprint a manual approval would have shown.
    admitted.value = [
      AdmittedDevice(
        deviceId: 'device-my-laptop',
        userId: _myUserId,
        contextId: _context,
        fingerprint: _fingerprint,
        at: DateTime.now(),
      ),
    ];

    await pump(tester);

    expect(
      find.text('A device of yours joined this conversation'),
      findsOneWidget,
    );
    expect(find.text(_fingerprint), findsOneWidget);

    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();
    verify(() => admission.acknowledge('device-my-laptop')).called(1);
  });

  testWidgets('does not announce an admission from another conversation', (
    tester,
  ) async {
    admitted.value = [
      AdmittedDevice(
        deviceId: 'device-my-laptop',
        userId: _myUserId,
        contextId: 'conv_elsewhere',
        fingerprint: _fingerprint,
        at: DateTime.now(),
      ),
    ];

    await pump(tester);

    expect(
      find.text('A device of yours joined this conversation'),
      findsNothing,
    );
  });
}
