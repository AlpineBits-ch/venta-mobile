import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/realtime/realtime_transport.dart';
import 'package:venta_mobile/core/sound/sound_service.dart';
import 'package:venta_mobile/features/auth/data/auth_repository.dart';
import 'package:venta_mobile/features/voice/bloc/call_cubit.dart';
import 'package:venta_mobile/features/voice/data/models/call_dto.dart';
import 'package:venta_mobile/features/voice/data/voice_repository.dart';
import 'package:venta_mobile/features/voice/webrtc/call_webrtc_service.dart';

/// The gap this covers: `call.IncomingCall` is broadcast once over SignalR and
/// never replayed. Open the app while somebody is already calling and the
/// socket connects seconds after that event went out, so nothing ever raises
/// the incoming-call UI - the phone is ringing and the app shows nothing. A
/// reconnect after a dropped connection has the identical gap, and the call
/// push that would otherwise cover it is best-effort by construction.
///
/// `CallCubit` now asks the server (`GET voice/call/pending`) on every realtime
/// connect, and once explicitly at startup because the socket connects before
/// this cubit exists to hear about it.
class _MockVoiceRepository extends Mock implements VoiceRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockSoundService extends Mock implements SoundService {}

class _MockWebRtcService extends Mock implements CallWebRtcService {}

const _ringingCall = CallDto(
  id: 'call-9',
  conversationId: 'conv-1',
  creatorId: 'user-caller',
  status: 'Pending',
  participants: [
    CallParticipantDto(userId: 'user-me'),
    CallParticipantDto(userId: 'user-caller'),
  ],
);

void main() {
  late _MockVoiceRepository repository;
  late _MockAuthRepository auth;
  late StreamController<VoiceRepositoryEvent> events;
  late StreamController<RealtimeConnectionStatus> connection;

  CallCubit build() => CallCubit(
    repository: repository,
    authRepository: auth,
    soundService: _MockSoundService(),
    webRtcServiceFactory: _MockWebRtcService.new,
  );

  setUp(() {
    repository = _MockVoiceRepository();
    auth = _MockAuthRepository();
    events = StreamController<VoiceRepositoryEvent>.broadcast();
    connection = StreamController<RealtimeConnectionStatus>.broadcast();

    when(() => repository.events).thenAnswer((_) => events.stream);
    when(() => repository.connectionStatus).thenAnswer((_) => connection.stream);
    when(() => auth.currentUserId).thenReturn('user-me');
  });

  tearDown(() async {
    await events.close();
    await connection.close();
  });

  test('raises the ring for a call this client was never told about', () async {
    when(repository.getPendingCall).thenAnswer((_) async => _ringingCall);
    final cubit = build();

    await cubit.catchUpOnPendingCall();

    expect(cubit.state.phase, CallPhase.incoming);
    expect(cubit.state.call?.id, 'call-9');
    await cubit.close();
  });

  test('stays idle when nothing is ringing', () async {
    when(repository.getPendingCall).thenAnswer((_) async => null);
    final cubit = build();

    await cubit.catchUpOnPendingCall();

    expect(cubit.state.phase, CallPhase.idle);
    await cubit.close();
  });

  test('a failed lookup is swallowed, not surfaced as a call error', () async {
    // Nobody asked for this request. An error banner for a background catch-up
    // that nothing depends on would be worse than the silence it replaces, and
    // the next connect tries again anyway.
    when(repository.getPendingCall).thenThrow(Exception('offline'));
    final cubit = build();

    await cubit.catchUpOnPendingCall();

    expect(cubit.state.phase, CallPhase.idle);
    expect(cubit.state.errorMessage, isNull);
    await cubit.close();
  });

  test('runs on every realtime connect, not only at startup', () async {
    when(repository.getPendingCall).thenAnswer((_) async => _ringingCall);
    final cubit = build();

    connection.add(RealtimeConnectionStatus.connected);
    await pumpEventQueue();

    expect(cubit.state.phase, CallPhase.incoming);
    await cubit.close();
  });

  test('does not run while a call is already in progress', () async {
    when(repository.getPendingCall).thenAnswer((_) async => _ringingCall);
    final cubit = build();
    // A reconnect mid-call has its own resync path (participants, ended-while-
    // away); this must not talk over it.
    events.add(const IncomingCallReceived(_ringingCall));
    await pumpEventQueue();
    expect(cubit.state.phase, CallPhase.incoming);
    clearInteractions(repository);

    connection.add(RealtimeConnectionStatus.connected);
    await pumpEventQueue();

    verifyNever(repository.getPendingCall);
    await cubit.close();
  });
}
