import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venta_mobile/core/voice/track_naming.dart';
import 'package:venta_mobile/core/voice/voice_media_api.dart';
import 'package:venta_mobile/core/voice/voice_room_gate.dart';
import 'package:venta_mobile/core/voice/voice_room_version.dart';
import 'package:venta_mobile/core/voice/voice_snapshot_dto.dart';

/// The two rules a voice client cannot skip, and the one string-parsing trap
/// that silently subscribes it to a track that does not exist.
///
/// Both room kinds - guild voice channels and 1:1 calls - run through the code
/// under test here, because the server runs one implementation for both.
void main() {
  group('version gate', () {
    late VoiceRoomVersionTracker tracker;

    setUp(() => tracker = VoiceRoomVersionTracker());

    VoiceEventVerdict evaluate(
      String instanceId,
      int version, {
      bool isRelay = false,
    }) => tracker.evaluate(
      instanceId: instanceId,
      version: version,
      isRelay: isRelay,
    );

    test('an event before any snapshot forces a refetch', () {
      // There is no baseline to apply a delta to, so applying it would leave
      // the client confidently holding a roster it never received.
      expect(evaluate('inst-1', 5), VoiceEventVerdict.refetch);
    });

    test(
      'the next version in sequence is applied and advances the baseline',
      () {
        tracker.adoptSnapshot(instanceId: 'inst-1', version: 7);

        expect(evaluate('inst-1', 8), VoiceEventVerdict.apply);
        expect(tracker.version, 8);
      },
    );

    test('a gap is refetched rather than applied', () {
      tracker.adoptSnapshot(instanceId: 'inst-1', version: 7);

      // v9 after v7 means v8 was dropped. Without this branch that one dropped
      // event stays wrong for the rest of the session - nothing repeats it.
      expect(evaluate('inst-1', 9), VoiceEventVerdict.refetch);
      expect(tracker.version, 7, reason: 'a refused event must not advance');
    });

    test('a strictly older event never overwrites newer state', () {
      tracker.adoptSnapshot(instanceId: 'inst-1', version: 7);

      // Two server instances can interleave; one arriving late must not win.
      expect(evaluate('inst-1', 3), VoiceEventVerdict.ignore);
      expect(tracker.version, 7);
    });

    test('several events at the same version all apply', () {
      tracker.adoptSnapshot(instanceId: 'inst-1', version: 7);

      // One mutation can produce several events: publishing a screen share
      // with audio bumps the version once and emits one TrackPublished per
      // track. Treating equal versions as duplicates drops every track after
      // the first, so the share arrives silent.
      expect(evaluate('inst-1', 8), VoiceEventVerdict.apply);
      expect(evaluate('inst-1', 8), VoiceEventVerdict.apply);
      expect(tracker.version, 8);
    });

    test('a relay applies without advancing the baseline', () {
      tracker.adoptSnapshot(instanceId: 'inst-1', version: 7);

      // SpeakingChanged and CameraChanged are not stored and do not bump the
      // version, so they arrive at the version already held. Advancing on one
      // would let it stand in for a state change actually missed, and the next
      // real event would look contiguous when it is not.
      expect(evaluate('inst-1', 7, isRelay: true), VoiceEventVerdict.apply);
      expect(tracker.version, 7);
      expect(evaluate('inst-1', 9), VoiceEventVerdict.refetch);
    });

    test('a relay from a rebuilt room still forces a refetch', () {
      tracker.adoptSnapshot(instanceId: 'inst-1', version: 7);

      expect(evaluate('inst-2', 7, isRelay: true), VoiceEventVerdict.refetch);
    });

    test('a rebuilt room is caught by instanceId, not by version', () {
      tracker.adoptSnapshot(instanceId: 'inst-1', version: 7);

      // A room rebuilt after a Redis loss climbs from zero again, so v8 is a
      // perfectly ordinary-looking number behind an entirely different roster.
      // Only the instance distinguishes it.
      expect(evaluate('inst-2', 8), VoiceEventVerdict.refetch);
    });

    test(
      'an event from a rebuilt room is refetched even at a lower version',
      () {
        tracker.adoptSnapshot(instanceId: 'inst-1', version: 7);

        expect(evaluate('inst-2', 1), VoiceEventVerdict.refetch);
      },
    );

    test('an event with no envelope is applied rather than dropped', () {
      tracker.adoptSnapshot(instanceId: 'inst-1', version: 7);

      // Nothing to order it against; refusing it would make this client deaf
      // to a server that predates the versioned contract.
      expect(
        tracker.evaluate(instanceId: null, version: null),
        VoiceEventVerdict.apply,
      );
    });
  });

  group('room gate', () {
    late List<String> fetched;
    late List<VoiceRoomSnapshotDto> delivered;
    late VoiceRoomGate gate;

    VoiceRoomSnapshotDto snapshotOf(
      String roomId, {
      String instanceId = 'inst-1',
      int version = 4,
    }) => VoiceRoomSnapshotDto(
      roomId: roomId,
      kind: VoiceRoomKind.channel,
      instanceId: instanceId,
      version: version,
    );

    setUp(() {
      fetched = [];
      delivered = [];
      gate = VoiceRoomGate(
        fetchSnapshot: (roomId) async {
          fetched.add(roomId);
          return snapshotOf(roomId);
        },
        onSnapshot: delivered.add,
      );
    });

    test('events for other rooms pass through ungated', () async {
      gate.enterRoom('chan-1');
      gate.adopt(snapshotOf('chan-1'));

      // Guild-wide presence is about channels this client is not in. Gating it
      // would refetch a snapshot per event for rooms with no baseline at all.
      expect(
        gate.admit('chan-2', {'instanceId': 'other', 'version': 99}),
        isTrue,
      );
      await Future<void>.delayed(Duration.zero);
      expect(fetched, isEmpty);
    });

    test('a gap refetches once and delivers the snapshot', () async {
      gate.enterRoom('chan-1');
      gate.adopt(snapshotOf('chan-1'));

      expect(
        gate.admit('chan-1', {'instanceId': 'inst-1', 'version': 9}),
        isFalse,
      );
      await Future<void>.delayed(Duration.zero);

      expect(fetched, ['chan-1']);
      expect(delivered, hasLength(1));
      expect(gate.version, 4);
    });

    test('an empty instanceId is never adopted as a baseline', () {
      gate.enterRoom('chan-1');
      // The server answers a room it does not have with a blank instance; a
      // client that stored it would believe it was in sync with a room that is
      // gone, and would then apply deltas to nothing.
      gate.adopt(snapshotOf('chan-1', instanceId: '', version: 0));

      expect(gate.instanceId, isNull);
    });

    test('leaving a room drops the baseline', () {
      gate.enterRoom('chan-1');
      gate.adopt(snapshotOf('chan-1'));
      gate.leaveRoom();

      expect(gate.instanceId, isNull);
      expect(gate.version, 0);
    });
  });

  group('media errors', () {
    VoiceMediaException failureOf(int status, Map<String, dynamic>? body) =>
        VoiceMediaException.from(
          DioException(
            requestOptions: RequestOptions(path: '/tracks'),
            response: Response<Map<String, dynamic>>(
              requestOptions: RequestOptions(path: '/tracks'),
              statusCode: status,
              data: body,
            ),
          ),
          'tracks',
        );

    test('a 409 staleSubscription is a stale client, not a failure', () {
      // Incident VNT-GE21R3P7: a publisher stopped a share without closing its
      // tracks, so the snapshot kept advertising it and watchers kept pulling
      // media nobody was sending. The server answered 502 after six seconds of
      // SFU retries, clients retried the identical body, and four rounds of
      // that put voice on the status page.
      final stale = failureOf(409, {
        'error': 'staleSubscription',
        'tracks': ['screen-7c41c31c'],
        'action': 'refetchSnapshot',
      });

      expect(stale.isStale, isTrue);
      expect(stale.staleTracks, ['screen-7c41c31c']);
      expect(stale.action, 'refetchSnapshot');
      expect(stale.isTransportFailure, isFalse);
    });

    test('a 409 with no body still reads as stale', () {
      // `tracks` is absent when the publisher vanished mid-request. The meaning
      // is identical, so nothing may branch on its presence.
      expect(failureOf(409, null).isStale, isTrue);
      expect(failureOf(409, null).staleTracks, isEmpty);
    });

    test('the other statuses keep their own meanings', () {
      expect(
        failureOf(502, {'operation': 'tracks', 'error': 'boom'}).isStale,
        isFalse,
      );
      expect(
        failureOf(502, {
          'operation': 'tracks',
          'error': 'boom',
        }).isTransportFailure,
        isTrue,
      );
      expect(failureOf(503, null).isContended, isTrue);
      expect(failureOf(403, null).isFatal, isTrue);
      expect(failureOf(404, null).isFatal, isTrue);
    });

    /// "Our own session is gone", as opposed to "the track we asked for is gone".
    ///
    /// Both are 409s and they are told apart by the code alone, so this pair is the whole
    /// distinction. Confusing them either rebuilds a healthy session over a stopped share, or
    /// answers a spent session with a roster refetch that cannot possibly help.
    test(
      'a 409 sessionGone is our own session, not somebody else\'s track',
      () {
        final gone = failureOf(409, {
          'error': 'sessionGone',
          'action': 'recreateSession',
        });

        expect(gone.isSessionGone, isTrue);
        expect(gone.isStale, isFalse);
        expect(gone.action, 'recreateSession');
      },
    );

    test('a stale subscription is not a dead session', () {
      final stale = failureOf(409, {'error': 'staleSubscription'});

      expect(stale.isSessionGone, isFalse);
    });

    test('the transport wording for the same condition is recognised too', () {
      // What leaks through when the operation reaches the SFU before the server classifies it -
      // and what this client was actually being sent in the field.
      final gone = failureOf(502, {
        'operation': 'tracks/new',
        'error':
            '{"errorCode":"session_error","errorDescription":"Session appears '
            'to be disconnected. Please check if the PeerConnection is connected."}',
      });

      expect(gone.isSessionGone, isTrue);
    });

    test('an ordinary transport failure is not a dead session', () {
      // It must keep its backoff. Treating every 502 as a dead session would tear down a healthy
      // one over a blip and lose every subscription on it.
      final failure = failureOf(502, {'operation': 'tracks', 'error': 'boom'});

      expect(failure.isSessionGone, isFalse);
      expect(voiceRetryDelay(failure, 1), isNotNull);
    });

    test('a dead session is never retried, on either status', () {
      // The session is spent: the identical body fails identically for as long as anyone tries.
      // Recreating it is the only move, and that is the owner's to make.
      expect(
        voiceRetryDelay(failureOf(409, {'error': 'sessionGone'}), 1),
        isNull,
      );
      expect(
        voiceRetryDelay(
          failureOf(502, {'operation': 'tracks', 'error': 'session_error'}),
          1,
        ),
        isNull,
      );
    });

    test('a stale subscribe is never retried', () {
      // Retrying the identical body is guaranteed to fail again. The only
      // useful move is refetching the snapshot and subscribing from that.
      final stale = failureOf(409, {'error': 'staleSubscription'});

      expect(voiceRetryDelay(stale, 1), isNull);
    });

    test('a permission or missing-room failure is never retried', () {
      expect(voiceRetryDelay(failureOf(403, null), 1), isNull);
      expect(voiceRetryDelay(failureOf(404, null), 1), isNull);
    });

    test('a transport failure backs off exponentially from a second', () {
      final failure = failureOf(502, {'operation': 'tracks', 'error': 'boom'});

      expect(voiceRetryDelay(failure, 1), const Duration(seconds: 1));
      expect(voiceRetryDelay(failure, 2), const Duration(seconds: 2));
      expect(voiceRetryDelay(failure, 3), const Duration(seconds: 4));
    });

    test('a contended room is retried quickly, since nothing was wrong', () {
      final contended = failureOf(503, null);

      expect(
        voiceRetryDelay(contended, 1),
        lessThan(const Duration(seconds: 1)),
      );
    });
  });

  group('track naming', () {
    test('screen audio is classified before screen', () {
      // `screen-audio-x` also satisfies startsWith("screen-"). Backwards, a
      // share's audio reads as the video of a share called `audio-x`, which
      // does not exist - so the subscribe returns a mid nothing arrives on.
      final descriptor = TrackNaming.describe('screen-audio-abc123');

      expect(descriptor.kind, TrackKind.screenAudio);
      expect(descriptor.shareId, 'abc123');
    });

    test('screen video keeps its share id', () {
      final descriptor = TrackNaming.describe('screen-abc123');

      expect(descriptor.kind, TrackKind.screen);
      expect(descriptor.shareId, 'abc123');
    });

    test('both halves of one share resolve to the same share id', () {
      expect(
        TrackNaming.describe(TrackNaming.screenTrack('s1')).shareId,
        TrackNaming.describe(TrackNaming.screenAudioTrack('s1')).shareId,
      );
    });

    test('the microphone is audio and belongs to no share', () {
      final descriptor = TrackNaming.describe('audio');

      expect(descriptor.kind, TrackKind.audio);
      expect(descriptor.shareId, isNull);
    });

    test('anything else is a camera, not an error', () {
      // An unrecognised name still has to be relayed; refusing to describe it
      // would drop the publish silently. Matches the server's own fallback.
      expect(TrackNaming.describe('camera').kind, TrackKind.video);
      expect(TrackNaming.describe('whatever').kind, TrackKind.video);
    });

    test(
      'an unknown wire kind degrades to video rather than being dropped',
      () {
        expect(trackKindFromWire('somethingNew'), TrackKind.video);
        expect(trackKindFromWire('screenAudio'), TrackKind.screenAudio);
      },
    );
  });

  group('snapshot', () {
    VoiceParticipantSnapshotDto participant({
      required String userId,
      String publishState = VoicePublishState.publishing,
      String? mediaSessionId = 'cf-1',
      String? audioTrackName = 'audio',
      List<VoiceShareDto> shares = const [],
    }) => VoiceParticipantSnapshotDto(
      userId: userId,
      publishState: publishState,
      mediaSessionId: mediaSessionId,
      audioTrackName: audioTrackName,
      shares: shares,
    );

    test('only Publishing participants are offered as pullable', () {
      final snapshot = VoiceRoomSnapshotDto(
        roomId: 'call-1',
        kind: VoiceRoomKind.call,
        instanceId: 'inst-1',
        participants: [
          participant(userId: 'me'),
          participant(userId: 'them'),
          // In the room, but nothing behind the session yet.
          participant(
            userId: 'joining',
            publishState: VoicePublishState.joined,
            mediaSessionId: null,
            audioTrackName: null,
          ),
        ],
      );

      expect(snapshot.publishersExcept('me').map((p) => p.userId), ['them']);
    });

    test('a session id without a track name is not pullable', () {
      // The server withholds both together, but a client must not treat a
      // session id alone as an invitation - that announcement burns the
      // per-user dedupe guard on a subscription that can never carry media.
      final p = participant(userId: 'u1', audioTrackName: null);

      expect(p.isPublishing, isFalse);
    });

    test('a share reports only the halves that exist', () {
      const videoOnly = VoiceShareDto(shareId: 's1', trackNames: ['screen-s1']);
      const withAudio = VoiceShareDto(
        shareId: 's2',
        trackNames: ['screen-s2', 'screen-audio-s2'],
      );

      expect(videoOnly.videoTrackName, 'screen-s1');
      expect(videoOnly.audioTrackName, isNull);
      expect(withAudio.audioTrackName, 'screen-audio-s2');
    });

    test('parses the wire shape the server sends', () {
      final snapshot = VoiceRoomSnapshotDto.fromJson({
        'roomId': 'channel-123',
        'kind': 'channel',
        'guildId': 'guild-1',
        'instanceId': 'f4904db35c9d4cc0befc8ad9793f33a9',
        'version': 42,
        'participants': [
          {
            'userId': 'user-1',
            'mediaSessionId': 'cf-abc',
            'audioTrackName': 'audio',
            'publishState': 'Publishing',
            'isSelfMuted': false,
            'isSelfDeafened': false,
            'isServerMuted': false,
            'isServerDeafened': false,
            'isStreaming': true,
            'shares': [
              {
                'shareId': 'abc123',
                'trackNames': ['screen-abc123', 'screen-audio-abc123'],
                // Deliberately different from the participant's: a share is
                // published on whichever session its publisher opened for it,
                // and on the desktop client that is never the microphone's.
                'mediaSessionId': 'cf-share',
              },
            ],
            'joinedAt': '2026-08-07T12:00:00Z',
          },
        ],
      });

      expect(snapshot.version, 42);
      expect(snapshot.guildId, 'guild-1');
      final user = snapshot.find('user-1')!;
      expect(user.isPublishing, isTrue);
      expect(user.shares.single.trackNames, hasLength(2));
      // Read rather than dropped. A client that ignores it pulls the share from
      // the microphone's session, where the track does not exist.
      expect(user.shares.single.mediaSessionId, 'cf-share');
      expect(user.joinedAt, isNotNull);
    });
  });
}
