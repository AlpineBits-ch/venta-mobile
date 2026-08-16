import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/voice/track_naming.dart';
import 'package:venta_mobile/features/voice/data/voice_api.dart';
import 'package:venta_mobile/features/voice/webrtc/call_webrtc_service.dart';

/// The bug these cover: a 1:1 call could connect cleanly and still be silent
/// in one direction, more often on a cold start.
///
/// `CallCubit` moves to `CallPhase.active` and begins handling
/// `call.ParticipantJoined` as soon as the accept/create response lands, while
/// `CallWebRtcService.connect` is still awaiting `getUserMedia` behind the OS
/// microphone prompt. The other party publishes their audio in that window -
/// they are not waiting on us - so their `ParticipantJoined` regularly arrived
/// first, hit the `_pc == null` guard in `_subscribeTrack`, and was dropped
/// with no retry anywhere. The backfill in `CallCubit._connect` could not
/// recover it either: it reads the accept response, serialized before the
/// other side published, so it carries no `mediaSessionId` for them.
///
/// Requests are now held and issued once `connect` finishes. The flush needs a
/// live peer connection, so these tests cover the queueing half - that nothing
/// is silently discarded before `connect`, and that the queue stays consistent
/// with the events that arrive while it is waiting.
class _MockVoiceApi extends Mock implements VoiceApi {}

void main() {
  late _MockVoiceApi api;
  late CallWebRtcService service;

  setUp(() {
    api = _MockVoiceApi();
    // Never connected - exactly the pre-`connect` state these exercise.
    service = CallWebRtcService(api: api);
  });

  group('subscribes arriving before connect', () {
    test('are held rather than dropped', () async {
      await service.subscribeToParticipant(
        userId: 'u2',
        mediaSessionId: 'cf-2',
        trackName: 'audio',
      );

      expect(service.pendingSubscribeKeys, contains('u2|audio'));
      // Nothing should have gone to the wire without a session to send it on.
      verifyZeroInteractions(api);
    });

    test('do not duplicate when the same participant is announced twice', () {
      // Both the live `ParticipantJoined` and the reconnect backfill can
      // announce the same participant while connect is still in flight.
      Future<void> announce() => service.subscribeToParticipant(
        userId: 'u2',
        mediaSessionId: 'cf-2',
        trackName: 'audio',
      );

      return announce().then((_) => announce()).then((_) {
        expect(service.pendingSubscribeKeys, ['u2|audio']);
      });
    });

    test('are dropped again if that participant leaves first', () async {
      await service.subscribeToParticipant(
        userId: 'u2',
        mediaSessionId: 'cf-2',
        trackName: 'audio',
      );
      expect(service.pendingSubscribeKeys, isNotEmpty);

      // A participant who joins and leaves inside the connect window must not
      // be subscribed to by the flush afterwards.
      service.unsubscribeParticipant('u2');

      expect(service.pendingSubscribeKeys, isEmpty);
    });

    test('keep audio and video for one participant apart', () async {
      await service.subscribeToParticipant(
        userId: 'u2',
        mediaSessionId: 'cf-2',
        trackName: 'audio',
      );
      await service.subscribeToTrack(
        userId: 'u2',
        mediaSessionId: 'cf-2',
        trackName: 'camera',
        kind: TrackKind.video,
      );

      // Keyed by track *name* rather than by kind: the name is what the SFU
      // and the roster agree on, and it is what a publication carries. Keying
      // on kind collapses two video tracks from one publisher into one entry.
      expect(
        service.pendingSubscribeKeys,
        containsAll(<String>['u2|audio', 'u2|camera']),
      );

      // Dropping the camera must not take the microphone with it.
      service.unsubscribeTrack(userId: 'u2', kind: TrackKind.video);

      expect(service.pendingSubscribeKeys, ['u2|audio']);
    });

    test('hold one entry per participant', () async {
      await service.subscribeToParticipant(
        userId: 'u2',
        mediaSessionId: 'cf-2',
        trackName: 'audio',
      );
      await service.subscribeToParticipant(
        userId: 'u3',
        mediaSessionId: 'cf-3',
        trackName: 'audio',
      );

      expect(
        service.pendingSubscribeKeys,
        containsAll(<String>['u2|audio', 'u3|audio']),
      );
    });
  });
}
