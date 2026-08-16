import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livekit_client/livekit_client.dart' show VideoQuality;
import 'package:venta_mobile/core/voice/track_naming.dart';
import 'package:venta_mobile/core/voice/video_layers.dart';
import 'package:venta_mobile/core/voice/voice_identity.dart';
import 'package:venta_mobile/core/voice/voice_media_api.dart';
import 'package:venta_mobile/core/voice/voice_room_gate.dart';
import 'package:venta_mobile/core/voice/voice_room_version.dart';
import 'package:venta_mobile/core/voice/voice_snapshot_dto.dart';
import 'package:venta_mobile/core/voice/voice_speaking_detector.dart';
import 'package:venta_mobile/core/voice/voice_subscription_set.dart';

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
            requestOptions: RequestOptions(path: '/publish'),
            response: Response<Map<String, dynamic>>(
              requestOptions: RequestOptions(path: '/publish'),
              statusCode: status,
              data: body,
            ),
          ),
          'publish',
        );

    /// The three 503s are three different situations sharing one status, and
    /// telling them apart is the whole of this group. Collapsed together they
    /// produce the two worst outcomes available: a retry loop against a server
    /// that will never have voice, and a call torn down over a control-plane
    /// blip that the media never noticed.
    test('voiceNotConfigured is a supported state, not a fault', () {
      final notConfigured = failureOf(503, {
        'error': 'voiceNotConfigured',
        'action': 'contactOperator',
      });

      expect(notConfigured.isVoiceNotConfigured, isTrue);
      expect(notConfigured.isContended, isFalse);
      expect(notConfigured.isSfuUnavailable, isFalse);
      expect(notConfigured.action, 'contactOperator');
    });

    test('a server without voice is never retried', () {
      // There is no SFU on this instance and there will not be one before the
      // operator configures it. A retry loop is one request per interval for
      // the life of the session, answering a question already answered.
      expect(
        voiceRetryDelay(failureOf(503, {'error': 'voiceNotConfigured'}), 1),
        isNull,
      );
    });

    test('sfuUnavailable is transient and backs off', () {
      // The control plane could not be reached. Media does not travel that
      // path, so every call in progress is unaffected - this must never be read
      // as a reason to tear anything down.
      final unavailable = failureOf(503, {
        'error': 'sfuUnavailable',
        'action': 'retry',
      });

      expect(unavailable.isSfuUnavailable, isTrue);
      expect(unavailable.isVoiceNotConfigured, isFalse);
      expect(unavailable.isContended, isFalse);
      expect(voiceRetryDelay(unavailable, 1), const Duration(seconds: 1));
      expect(voiceRetryDelay(unavailable, 3), const Duration(seconds: 4));
    });

    test('an unlabelled 503 is the contended room', () {
      // Nothing about the request was wrong and the change simply was not
      // applied, so this is the one 503 that is retried quickly.
      final contended = failureOf(503, null);

      expect(contended.isContended, isTrue);
      expect(contended.isVoiceNotConfigured, isFalse);
      expect(contended.isSfuUnavailable, isFalse);
      expect(
        voiceRetryDelay(contended, 1),
        lessThan(const Duration(seconds: 1)),
      );
    });

    test('the other statuses keep their own meanings', () {
      final transport = failureOf(502, {
        'operation': 'publish',
        'error': 'boom',
      });

      expect(transport.isTransportFailure, isTrue);
      expect(transport.isContended, isFalse);
      expect(failureOf(403, null).isFatal, isTrue);
      expect(failureOf(404, null).isFatal, isTrue);
    });

    test('a permission or missing-room failure is never retried', () {
      expect(voiceRetryDelay(failureOf(403, null), 1), isNull);
      expect(voiceRetryDelay(failureOf(404, null), 1), isNull);
    });

    test('a transport failure backs off exponentially from a second', () {
      // Incident VNT-GE21R3P7: the same operation reattempted every 5-6 seconds
      // against a state that could not have changed in between, which turned
      // one bad moment into the burst that tripped a degraded threshold.
      final failure = failureOf(502, {'operation': 'publish', 'error': 'boom'});

      expect(voiceRetryDelay(failure, 1), const Duration(seconds: 1));
      expect(voiceRetryDelay(failure, 2), const Duration(seconds: 2));
      expect(voiceRetryDelay(failure, 3), const Duration(seconds: 4));
    });

    test('this build drives livekit, and refuses to guess at anything else', () {
      // An unrecognised backend means "I cannot handle this room". Guessing
      // would drive a transport with different semantics and fail in a way that
      // looks like a network problem.
      expect(supportedVoiceBackends, contains('livekit'));
      expect(supportedVoiceBackends, isNot(contains('cloudflare')));
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

    test('an absent subscription set is not an empty one', () {
      // The difference between "pull everyone publishing" and "pull nobody".
      // A `@Default` on the field would collapse the first into the second and
      // silence the ordinary small room.
      final snapshot = VoiceRoomSnapshotDto.fromJson({
        'roomId': 'channel-1',
        'kind': 'channel',
        'instanceId': 'i1',
        'version': 1,
        'participants': <Map<String, dynamic>>[],
      });

      expect(snapshot.subscriptions, isNull);
    });

    test('a subscription set on the snapshot parses whole', () {
      final snapshot = VoiceRoomSnapshotDto.fromJson({
        'roomId': 'channel-1',
        'kind': 'channel',
        'instanceId': 'i1',
        'version': 42,
        'participants': <Map<String, dynamic>>[],
        'subscriptions': {
          'mode': 'activeSpeaker',
          'revision': 12,
          'activeSpeakers': ['user-1', 'user-9'],
          'tracks': [
            {
              'userId': 'user-1',
              'mediaSessionId': 'user-1',
              'trackName': 'audio',
              'kind': 'audio',
              'shareId': null,
              'layer': null,
            },
            {
              'userId': 'user-4',
              'mediaSessionId': 'user-2',
              'trackName': 'screen-abc123',
              'kind': 'screen',
              'shareId': 'abc123',
              'layer': 'b',
            },
          ],
        },
      });

      final set = snapshot.subscriptions!;
      expect(set.isRanked, isTrue);
      expect(set.revision, 12);
      expect(set.activeSpeakers, ['user-1', 'user-9']);
      expect(set.isInForce, isTrue);
      expect(set.tracks, hasLength(2));
      expect(set.tracks!.last.trackKind, TrackKind.screen);
      expect(set.tracks!.last.layer, VoiceVideoLayer.medium);
    });
  });

  group('subscription plan', () {
    late VoiceSubscriptionPlan plan;

    setUp(() => plan = VoiceSubscriptionPlan());

    VoiceSubscriptionSetDto setAt(
      int revision, {
      List<String> speakers = const [],
      List<VoiceSubscriptionTrackDto> tracks = const [],
    }) => VoiceSubscriptionSetDto(
      mode: VoiceSubscriptionMode.activeSpeaker,
      revision: revision,
      activeSpeakers: speakers,
      tracks: tracks,
    );

    test('no set means pull everyone, which is the small room', () {
      expect(plan.isManaged, isFalse);
      expect(plan.allows(userId: 'anyone', trackName: 'audio'), isTrue);
    });

    /// The three-state rule, which is the one thing here that fails silently.
    ///
    /// `tracks` absent and `tracks: []` are *opposite* instructions - "pull
    /// everyone publishing" and "pull nobody" - and they arrive as the same
    /// well-formed payload shape. Collapsing them is not refused by anything:
    /// no request errors, no event is dropped, the room simply goes quiet in
    /// the ordinary small case.
    test('absent tracks is a revocation, not an empty set', () {
      plan.adopt(
        setAt(
          1,
          tracks: const [
            VoiceSubscriptionTrackDto(userId: 'user-1', trackName: 'audio'),
          ],
        ),
      );
      expect(plan.isManaged, isTrue);

      final changed = plan.adopt(
        const VoiceSubscriptionSetDto(revision: 2),
      );

      expect(changed, isTrue);
      expect(plan.isManaged, isFalse);
      expect(plan.allows(userId: 'anyone', trackName: 'audio'), isTrue);
    });

    test('an empty set in force pulls nobody', () {
      // Every tile collapsed. The opposite of the case above, and it has to
      // stay reachable - a client that treated this as "no set" would keep
      // paying for streams it has just been told nobody is looking at.
      plan.adopt(setAt(1, tracks: const []));

      expect(plan.isManaged, isTrue);
      expect(plan.allows(userId: 'anyone', trackName: 'audio'), isFalse);
    });

    test('the DTO keeps absent and empty apart on the wire', () {
      expect(
        VoiceSubscriptionSetDto.fromJson({
          'mode': 'all',
          'revision': 3,
        }).isInForce,
        isFalse,
      );
      expect(
        VoiceSubscriptionSetDto.fromJson({
          'mode': 'all',
          'revision': 3,
          'tracks': <dynamic>[],
        }).isInForce,
        isTrue,
      );
    });

    test('a revocation still respects revision ordering', () {
      // Two server instances can interleave across a revocation as easily as
      // across any other change. Forgetting the revision when the room goes
      // unplanned would let the stale set that preceded it be adopted as new.
      plan.adopt(setAt(12, tracks: const []));
      plan.adopt(const VoiceSubscriptionSetDto(revision: 13));
      expect(plan.isManaged, isFalse);

      final changed = plan.adopt(
        setAt(
          12,
          tracks: const [
            VoiceSubscriptionTrackDto(userId: 'user-1', trackName: 'audio'),
          ],
        ),
      );

      expect(changed, isFalse);
      expect(plan.isManaged, isFalse);
    });

    test('a set narrows to what it names', () {
      plan.adopt(
        setAt(
          1,
          tracks: const [
            VoiceSubscriptionTrackDto(
              userId: 'user-1',
              trackName: 'audio',
              kind: 'audio',
            ),
          ],
        ),
      );

      expect(plan.isManaged, isTrue);
      expect(plan.allows(userId: 'user-1', trackName: 'audio'), isTrue);
      expect(plan.allows(userId: 'user-2', trackName: 'audio'), isFalse);
    });

    test('an older revision is ignored', () {
      // Two server instances can interleave. A late arrival describes a set
      // that has since moved on, so applying it resubscribes to whoever was
      // talking a moment ago and then waits for the next change to correct
      // itself. `revision` is unrelated to the room version.
      plan.adopt(setAt(12, speakers: const ['user-9']));
      final changed = plan.adopt(setAt(11, speakers: const ['user-1']));

      expect(changed, isFalse);
      expect(plan.activeSpeakers, ['user-9']);
    });

    test('an identical set is not a change', () {
      // Every snapshot carries the current set whether or not it moved, so this
      // is most adoptions - and each one that reported a change would cost a
      // needless reconcile pass over every publication in the room.
      plan.adopt(setAt(12, speakers: const ['user-9']));

      expect(plan.adopt(setAt(12, speakers: const ['user-9'])), isFalse);
    });

    test('dropping the set goes back to pulling everyone', () {
      // The room fell below the threshold, or stopped withholding anything.
      plan.adopt(setAt(3));
      final changed = plan.adopt(null);

      expect(changed, isTrue);
      expect(plan.isManaged, isFalse);
      expect(plan.allows(userId: 'anyone', trackName: 'audio'), isTrue);
    });

    test('the layer is read per track, and null where nothing was said', () {
      plan.adopt(
        setAt(
          1,
          tracks: const [
            VoiceSubscriptionTrackDto(
              userId: 'user-4',
              trackName: 'camera',
              layer: VoiceVideoLayer.low,
            ),
          ],
        ),
      );

      expect(plan.layerFor(userId: 'user-4', trackName: 'camera'), 'c');
      expect(plan.layerFor(userId: 'user-9', trackName: 'camera'), isNull);
    });

    test('a layer maps onto the SDK quality, and silence means full', () {
      // `a`/`b`/`c` is a ranking of the server's, not a rid and not a
      // resolution - the SFU never sees a rid. An unknown or absent layer
      // resolves to the top: an unreadable tile is a worse failure than an
      // expensive one.
      expect(videoQualityForLayer(VoiceVideoLayer.full), VideoQuality.HIGH);
      expect(videoQualityForLayer(VoiceVideoLayer.medium), VideoQuality.MEDIUM);
      expect(videoQualityForLayer(VoiceVideoLayer.low), VideoQuality.LOW);
      expect(videoQualityForLayer(null), VideoQuality.HIGH);
      expect(videoQualityForLayer('q'), VideoQuality.HIGH);
    });
  });

  group('identity', () {
    test('a primary identity is the bare user id', () {
      // Not `user-{userId}`, whatever the worked examples look like at a
      // glance. This is what lets a remote SFU participant be mapped to a user
      // without consulting the snapshot.
      expect(VoiceIdentity.userIdOf('AbC123'), 'AbC123');
      expect(VoiceIdentity.tagOf('AbC123'), isNull);
      expect(VoiceIdentity.isPrimaryOf('AbC123', 'AbC123'), isTrue);
    });

    test('a secondary identity splits on the first separator', () {
      // User ids are Sqids and never contain a `#`, and a tag is stripped to
      // alphanumerics before it is appended - so the first one is always the
      // boundary.
      expect(VoiceIdentity.userIdOf('AbC123#screen'), 'AbC123');
      expect(VoiceIdentity.tagOf('AbC123#screen'), 'screen');
      expect(VoiceIdentity.isPrimaryOf('AbC123#screen', 'AbC123'), isFalse);
    });

    test('a tag is sanitised the way the server sanitises it', () {
      expect(VoiceIdentity.connectionTag('screen'), 'screen');
      expect(VoiceIdentity.connectionTag('screen-2!'), 'screen2');
      expect(VoiceIdentity.connectionTag('***'), 'alt');
      expect(VoiceIdentity.connectionTag('a' * 40).length, 32);
    });
  });

  group('speaking detector', () {
    test('onset is immediate, because latency here is audible', () async {
      // The server admits a speaker the instant it is told, deliberately:
      // gating entry on duration makes the first person to talk in a quiet room
      // inaudible for seconds.
      final reports = <bool>[];
      final detector = VoiceSpeakingDetector(
        report: (speaking) async => reports.add(speaking),
        releaseDelay: const Duration(milliseconds: 40),
      );
      addTearDown(detector.dispose);

      detector.update(isSpeaking: true);

      expect(reports, [true]);
    });

    test('a gap between words does not report a stop', () async {
      // The overwhelming majority of raw transitions. Each one reported would
      // be a subscription-set change for every other client in the room.
      final reports = <bool>[];
      final detector = VoiceSpeakingDetector(
        report: (speaking) async => reports.add(speaking),
        releaseDelay: const Duration(milliseconds: 40),
      );
      addTearDown(detector.dispose);

      detector.update(isSpeaking: true);
      detector.update(isSpeaking: false);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      detector.update(isSpeaking: true);
      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(reports, [true]);
      expect(detector.reportedState, isTrue);
    });

    test('sustained silence does report a stop', () async {
      final reports = <bool>[];
      final detector = VoiceSpeakingDetector(
        report: (speaking) async => reports.add(speaking),
        releaseDelay: const Duration(milliseconds: 40),
      );
      addTearDown(detector.dispose);

      detector.update(isSpeaking: true);
      detector.update(isSpeaking: false);
      await Future<void>.delayed(const Duration(milliseconds: 80));

      expect(reports, [true, false]);
    });

    test('muting silences now rather than waiting out the release', () async {
      // Muting is not a pause in speech. Held through the delay, this device
      // stays ranked as talking with its microphone off - and every other
      // client in the room stays subscribed to the silence.
      final reports = <bool>[];
      final detector = VoiceSpeakingDetector(
        report: (speaking) async => reports.add(speaking),
        releaseDelay: const Duration(seconds: 30),
      );
      addTearDown(detector.dispose);

      detector.update(isSpeaking: true);
      detector.silenceNow();

      expect(reports, [true, false]);
      expect(detector.isReleasePending, isFalse);
    });
  });
}
