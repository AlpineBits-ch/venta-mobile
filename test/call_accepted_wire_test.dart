import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/realtime/realtime_event.dart';
import 'package:venta_mobile/core/realtime/realtime_service.dart';
import 'package:venta_mobile/features/voice/data/voice_api.dart';
import 'package:venta_mobile/features/voice/data/voice_repository.dart';

/// `call.CallAccepted` is the event that stops a ring - on the callee's other
/// devices, and on the caller, whose ringback has no other answer-shaped signal
/// to key off.
///
/// It was read with a hard `payload['callId'] as String` while the server was
/// still sending the bare `Call` entity, whose id field is `id`. The cast threw,
/// the branch died before adding anything, and the ring carried on with nothing
/// in the logs pointing at a contract. The server sends `{callId, userId,
/// deviceId, call}` now, but the lesson is the cast: a payload this client
/// cannot read must cost one dropped event, never the handler.
class _MockVoiceApi extends Mock implements VoiceApi {}

class _MockRealtimeService extends Mock implements RealtimeService {}

void main() {
  late StreamController<RealtimeEvent> hub;
  late VoiceRepository repository;

  setUp(() {
    hub = StreamController<RealtimeEvent>.broadcast();
    final realtime = _MockRealtimeService();
    when(() => realtime.events).thenAnswer((_) => hub.stream);
    repository = VoiceRepository(api: _MockVoiceApi(), realtimeService: realtime);
  });

  tearDown(() async {
    await hub.close();
  });

  /// The next repository event, with [payloads] pushed through the hub after the
  /// listener is attached.
  Future<VoiceRepositoryEvent> nextFrom(
    List<Map<String, dynamic>> payloads,
  ) async {
    final next = repository.events.first;
    for (final payload in payloads) {
      hub.add(RealtimeEvent('call.CallAccepted', [payload]));
    }
    return next;
  }

  test('names the call from the top-level callId', () async {
    final event = await nextFrom([
      {
        'callId': 'call-1',
        'userId': 'callee',
        'deviceId': 'phone-1',
        'call': {'id': 'call-1', 'conversationId': 'conv-1'},
      },
    ]);

    expect(event, isA<CallAcceptedElsewhere>());
    expect((event as CallAcceptedElsewhere).callId, 'call-1');
  });

  test('falls back to the nested call id when no callId is sent', () async {
    // What a client talking to a backend that predates the payload fix sees.
    // Recovering the id here is the difference between a ring that stops during
    // a rolling deploy and one that does not.
    final event = await nextFrom([
      {
        'id': 'call-1',
        'conversationId': 'conv-1',
        'participants': <dynamic>[],
      },
    ]);

    expect((event as CallAcceptedElsewhere).callId, 'call-1');
  });

  test('a payload naming no call is dropped, not fatal', () async {
    // The handler has to survive it: this stream carries every `call.*` event,
    // so a throw here takes the rest of the call's signalling with it for that
    // delivery, and the next good event is what proves it did not.
    final event = await nextFrom([
      <String, dynamic>{},
      {'callId': 'call-2'},
    ]);

    expect((event as CallAcceptedElsewhere).callId, 'call-2');
  });

  test('is not held back by the room version gate', () async {
    // Call lifecycle, not a room delta: it is sent straight from
    // CallAcceptedHandler over IHubContext and carries no instanceId/version.
    // Gating it against the room the client is sitting in would swallow the one
    // event that says somebody answered.
    repository.enterCall('call-1');

    final event = await nextFrom([
      {
        'callId': 'call-1',
        'userId': 'callee',
        'call': {'id': 'call-1'},
      },
    ]);

    expect((event as CallAcceptedElsewhere).callId, 'call-1');
  });
}
