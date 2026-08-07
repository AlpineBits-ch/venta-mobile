import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' show MediaStreamTrack;
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/realtime/realtime_transport.dart';
import 'package:venta_mobile/core/sound/sound_service.dart';
import 'package:venta_mobile/core/voice/track_naming.dart';
import 'package:venta_mobile/core/voice/voice_heartbeat.dart';
import 'package:venta_mobile/core/voice/voice_snapshot_dto.dart';
import 'package:venta_mobile/core/voice/voice_webrtc_service.dart';
import 'package:venta_mobile/features/auth/data/auth_repository.dart';
import 'package:venta_mobile/features/guild_voice/bloc/guild_voice_cubit.dart';
import 'package:venta_mobile/features/guild_voice/data/guild_voice_repository.dart';
import 'package:venta_mobile/features/guild_voice/webrtc/guild_voice_webrtc_service.dart';

/// The bug these cover: a received screen share renders once, if you are lucky,
/// and then never again for the rest of the session.
///
/// `MediaStreamTrack`s cannot live in `Equatable` cubit state, so the screens
/// re-read them imperatively from the transport and rely on `videoRevision`
/// changing to know when to look. Every bump of that counter happened where a
/// subscribe was *requested* - and a subscribe returns long before the media
/// does. Nothing at all fired when a track actually arrived, so the tile the
/// screen had already built with `track: null` kept its placeholder until some
/// unrelated event happened to emit.
///
/// That is why it looked intermittent. Joining a channel produces a flurry of
/// state for several seconds (roster, participants publishing, mute and
/// speaking relays), so a re-read usually landed after the track by luck. The
/// path that has no such churn is the one that broke every time: open the voice
/// screen while somebody is *already* sharing, and `setSharesVisible(true)`
/// refetches a snapshot that changes nothing about the roster, subscribes from
/// it, and emits nothing. The share arrives into a map nobody reads again.
class _MockRepository extends Mock implements GuildVoiceRepository {}

class _MockAuth extends Mock implements AuthRepository {}

class _MockSound extends Mock implements SoundService {}

class _FakeTrack extends Mock implements MediaStreamTrack {}

/// A transport that behaves like the real one where it matters: tracks turn up
/// some time after the subscribe that asked for them, and the only way anyone
/// finds out is [VoiceWebRtcService.onTracksChanged].
///
/// The hook is a real field here rather than a mocked one so the pre-fix
/// behaviour is reproducible: leave it unassigned - which is what the cubit did
/// before this fix, and what `onTracksChanged = null` below restores - and
/// [deliverScreenTrack] reaches nobody.
class _FakeTransport extends Mock implements GuildVoiceWebRtcService {
  @override
  void Function()? onTracksChanged;

  @override
  void Function()? onStaleSubscription;

  final Map<String, MediaStreamTrack> _screenTracks = {};
  final Map<String, String> _shareOwners = {};
  final Map<String, MediaStreamTrack> _cameraTracks = {};

  /// The SFU delivering a track that was subscribed to earlier.
  void deliverScreenTrack(String userId, String shareId, MediaStreamTrack t) {
    _shareOwners[shareId] = userId;
    _screenTracks[shareId] = t;
    onTracksChanged?.call();
  }

  void deliverCameraTrack(String userId, MediaStreamTrack t) {
    _cameraTracks[userId] = t;
    onTracksChanged?.call();
  }

  @override
  MediaStreamTrack? remoteScreenTrackFor(String userId) {
    for (final e in _shareOwners.entries) {
      if (e.value == userId) return _screenTracks[e.key];
    }
    return null;
  }

  @override
  MediaStreamTrack? remoteScreenTrackForShare(String shareId) =>
      _screenTracks[shareId];

  @override
  MediaStreamTrack? remoteVideoTrackFor(String userId) => _cameraTracks[userId];
}

const _guildId = 'guild-1';
const _channelId = 'chan-1';
const _me = 'user-me';
const _peer = 'user-peer';
const _shareId = 'share-1';

/// A room that is already settled: one peer, publishing, one live share. The
/// point of the fixture is that nothing about it is going to change again -
/// exactly the room in which the bug is permanent rather than intermittent.
VoiceRoomSnapshotDto _snapshot({int version = 4}) => VoiceRoomSnapshotDto(
  roomId: _channelId,
  kind: VoiceRoomKind.channel,
  guildId: _guildId,
  instanceId: 'inst-1',
  version: version,
  participants: const [
    VoiceParticipantSnapshotDto(userId: _me),
    VoiceParticipantSnapshotDto(
      userId: _peer,
      mediaSessionId: 'sess-peer',
      audioTrackName: 'audio',
      publishState: VoicePublishState.publishing,
      isStreaming: true,
      shares: [
        VoiceShareDto(shareId: _shareId, trackNames: ['screen-$_shareId']),
      ],
    ),
  ],
);

void main() {
  late _MockRepository repository;
  late _MockAuth auth;
  late StreamController<GuildVoiceEvent> events;
  late StreamController<RealtimeConnectionStatus> connection;
  late _FakeTransport transport;
  late _MockSound sound;
  late GuildVoiceCubit cubit;

  setUpAll(() {
    registerFallbackValue(_snapshot());
    registerFallbackValue(TrackKind.video);
    registerFallbackValue(
      const VoiceHeartbeatState(knownInstanceId: 'inst-1', knownVersion: 0),
    );
  });

  setUp(() async {
    repository = _MockRepository();
    auth = _MockAuth();
    transport = _FakeTransport();
    sound = _MockSound();
    when(sound.playJoinCall).thenAnswer((_) async {});
    when(sound.playLeaveCall).thenAnswer((_) async {});
    events = StreamController<GuildVoiceEvent>.broadcast();
    connection = StreamController<RealtimeConnectionStatus>.broadcast();

    when(() => repository.events).thenAnswer((_) => events.stream);
    when(
      () => repository.connectionStatus,
    ).thenAnswer((_) => connection.stream);
    when(() => repository.knownInstanceId).thenReturn('inst-1');
    when(() => repository.knownVersion).thenReturn(4);
    when(
      () => repository.enterChannel(
        guildId: any(named: 'guildId'),
        channelId: any(named: 'channelId'),
      ),
    ).thenReturn(null);
    when(repository.exitChannel).thenReturn(null);
    when(() => repository.adoptSnapshot(any())).thenReturn(null);
    when(
      () => repository.join(any(), any()),
    ).thenAnswer((_) async => _snapshot());
    // The gate answers a refetch by pushing the snapshot back through the
    // event stream - the same way the real one does.
    when(repository.refetchSnapshot).thenAnswer((_) async {
      events.add(VoiceSnapshotReceived(_snapshot()));
      await pumpEventQueue();
    });
    when(
      () => repository.watchShare(
        guildId: any(named: 'guildId'),
        channelId: any(named: 'channelId'),
        shareId: any(named: 'shareId'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => repository.unwatchShare(
        guildId: any(named: 'guildId'),
        channelId: any(named: 'channelId'),
        shareId: any(named: 'shareId'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => repository.invokeHeartbeat(
        channelId: any(named: 'channelId'),
        state: any(named: 'state'),
      ),
    ).thenAnswer((_) async {});

    when(() => auth.currentUserId).thenReturn(_me);

    when(() => transport.connect(any(), any())).thenAnswer((_) async {});
    when(() => transport.setMuted(any())).thenReturn(null);
    when(() => transport.setDeafened(any())).thenReturn(null);
    when(() => transport.setSpeakerphoneOn(any())).thenAnswer((_) async {});
    when(transport.disconnect).thenAnswer((_) async {});
    when(
      () => transport.subscribeToParticipant(
        userId: any(named: 'userId'),
        mediaSessionId: any(named: 'mediaSessionId'),
        trackName: any(named: 'trackName'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => transport.subscribeToShare(
        userId: any(named: 'userId'),
        mediaSessionId: any(named: 'mediaSessionId'),
        shareId: any(named: 'shareId'),
        trackNames: any(named: 'trackNames'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => transport.subscribeToTrack(
        userId: any(named: 'userId'),
        mediaSessionId: any(named: 'mediaSessionId'),
        trackName: any(named: 'trackName'),
        kind: any(named: 'kind'),
        shareId: any(named: 'shareId'),
      ),
    ).thenAnswer((_) async {});

    cubit = GuildVoiceCubit(
      repository: repository,
      authRepository: auth,
      soundService: sound,
      webRtcServiceFactory: () => transport,
    );

    // The voice screen is open, which is the only state in which shares are
    // watched at all.
    cubit.setSharesVisible(true);
    await cubit.join(
      guildId: _guildId,
      channelId: _channelId,
      channelName: 'General',
      guildName: 'Guild',
    );
    await pumpEventQueue();
  });

  tearDown(() async {
    await cubit.close();
    await events.close();
    await connection.close();
  });

  test('the share was subscribed to, but no track has arrived yet', () async {
    verify(
      () => transport.subscribeToShare(
        userId: _peer,
        mediaSessionId: 'sess-peer',
        shareId: _shareId,
        trackNames: ['screen-$_shareId'],
      ),
    ).called(greaterThanOrEqualTo(1));
    expect(cubit.remoteScreenTrackFor(_peer), isNull);
  });

  test('a screen track arriving makes the screen re-read it', () async {
    final emitted = <GuildVoiceState>[];
    final sub = cubit.stream.listen(emitted.add);
    final before = cubit.state.videoRevision;

    transport.deliverScreenTrack(_peer, _shareId, _FakeTrack());
    await pumpEventQueue();
    await sub.cancel();

    expect(
      emitted,
      isNotEmpty,
      reason:
          'the screen only re-reads the track when the state changes; '
          'without an emission here the tile keeps the placeholder it built '
          'before the track existed',
    );
    expect(cubit.state.videoRevision, greaterThan(before));
    expect(cubit.remoteScreenTrackFor(_peer), isNotNull);
  });

  test('a camera track arriving does too', () async {
    final emitted = <GuildVoiceState>[];
    final sub = cubit.stream.listen(emitted.add);

    transport.deliverCameraTrack(_peer, _FakeTrack());
    await pumpEventQueue();
    await sub.cancel();

    expect(emitted, isNotEmpty);
    expect(cubit.remoteVideoTrackFor(_peer), isNotNull);
  });

  /// Why the arrival has to be what emits. Re-opening the voice screen goes
  /// snapshot -> reconcile -> subscribe, and a settled room's snapshot changes
  /// nothing else, so that whole sequence is silent. Detaching the hook here
  /// is the transport as it behaved before the fix.
  test(
    'nothing else in the subscribe path tells the screen anything',
    () async {
      cubit.setSharesVisible(false);
      await pumpEventQueue();
      clearInteractions(transport);

      final emitted = <GuildVoiceState>[];
      final sub = cubit.stream.listen(emitted.add);
      transport.onTracksChanged = null;

      cubit.setSharesVisible(true);
      await pumpEventQueue();
      await sub.cancel();

      verify(
        () => transport.subscribeToShare(
          userId: _peer,
          mediaSessionId: 'sess-peer',
          shareId: _shareId,
          trackNames: ['screen-$_shareId'],
        ),
      ).called(greaterThanOrEqualTo(1));
      expect(
        emitted,
        isEmpty,
        reason:
            'the subscribe goes out and the room state is unchanged, so a '
            'client that waits for a roster change waits forever',
      );
    },
  );

  /// The transport half of the same contract, on the real service rather than
  /// the fake above.
  ///
  /// Only the drop side is reachable here: it is local bookkeeping, while the
  /// arrival side runs off `RTCPeerConnection.onTrack` and cannot be driven
  /// without a negotiated peer connection and the platform channels behind it.
  /// Both write the same two maps, so this at least pins that the hook is
  /// wired into the service rather than merely declared on it.
  test('the transport reports a track it stops handing out', () {
    final service = VoiceWebRtcService();
    var changes = 0;
    service.onTracksChanged = () => changes++;

    service.unsubscribeTrack(
      userId: _peer,
      kind: TrackKind.screen,
      shareId: _shareId,
    );

    expect(changes, 1);
  });
}
