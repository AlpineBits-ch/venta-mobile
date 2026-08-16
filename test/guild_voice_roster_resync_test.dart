import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/realtime/realtime_transport.dart';
import 'package:venta_mobile/core/sound/sound_service.dart';
import 'package:venta_mobile/core/voice/voice_snapshot_dto.dart';
import 'package:venta_mobile/features/auth/data/auth_repository.dart';
import 'package:venta_mobile/features/guild_voice/bloc/guild_voice_cubit.dart';
import 'package:venta_mobile/features/guild_voice/data/guild_voice_repository.dart';

/// The bug these cover: come back to the app after it has been in the
/// background and the voice channels in the sidebar still show whoever was in
/// them when the screen went off.
///
/// Those rosters are kept current by the guild-wide `UserJoinedVoice` /
/// `UserLeftVoice` fan-out, which SignalR drops outright across a gap and never
/// replays. Nothing re-read them: the reconnect handler only refetched the room
/// this device is *joined to*, and the sidebar is mostly channels it is not.
class _MockRepository extends Mock implements GuildVoiceRepository {}

class _MockAuth extends Mock implements AuthRepository {}

class _MockSound extends Mock implements SoundService {}

const _guildId = 'guild-1';
const _channelA = 'chan-a';
const _channelB = 'chan-b';
const _me = 'user-me';

VoiceRoomSnapshotDto _snapshot(String channelId, List<String> userIds) =>
    VoiceRoomSnapshotDto(
      roomId: channelId,
      kind: VoiceRoomKind.channel,
      guildId: _guildId,
      instanceId: 'inst-1',
      version: 1,
      participants: [
        for (final id in userIds) VoiceParticipantSnapshotDto(userId: id),
      ],
    );

void main() {
  late _MockRepository repository;
  late StreamController<GuildVoiceEvent> events;
  late StreamController<RealtimeConnectionStatus> connection;
  late GuildVoiceCubit cubit;

  /// Who each channel's snapshot currently reports - the server's answer,
  /// changed by a test to stand for people joining while the app was away.
  late Map<String, List<String>> occupancy;

  setUp(() {
    repository = _MockRepository();
    events = StreamController<GuildVoiceEvent>.broadcast();
    connection = StreamController<RealtimeConnectionStatus>.broadcast();
    occupancy = {
      _channelA: [_me],
      _channelB: [],
    };

    when(() => repository.events).thenAnswer((_) => events.stream);
    when(
      () => repository.connectionStatus,
    ).thenAnswer((_) => connection.stream);
    when(() => repository.getSnapshot(any(), any())).thenAnswer((invocation) {
      final channelId = invocation.positionalArguments[1] as String;
      return Future.value(
        _snapshot(channelId, occupancy[channelId] ?? const []),
      );
    });

    final auth = _MockAuth();
    when(() => auth.currentUserId).thenReturn(_me);
    final sound = _MockSound();

    cubit = GuildVoiceCubit(
      repository: repository,
      authRepository: auth,
      soundService: sound,
      // Never reached: nothing here joins a channel.
      webRtcServiceFactory: () =>
          throw StateError('no media in a roster-only test'),
    );
  });

  tearDown(() async {
    await cubit.close();
    await events.close();
    await connection.close();
  });

  test('a reconnect re-reads the sidebar rosters', () async {
    await cubit.hydrateChannelRoster(_guildId, _channelA);
    await cubit.hydrateChannelRoster(_guildId, _channelB);
    expect(cubit.state.rosterFor(_channelA).map((p) => p.userId), [_me]);
    expect(cubit.state.rosterFor(_channelB), isEmpty);

    // The app is away. Two people join B and the one in A leaves; both events
    // are broadcast to a socket nobody is holding.
    occupancy = {
      _channelA: [],
      _channelB: ['user-1', 'user-2'],
    };

    connection.add(RealtimeConnectionStatus.connected);
    await pumpEventQueue();

    expect(cubit.state.rosterFor(_channelA), isEmpty);
    expect(cubit.state.rosterFor(_channelB).map((p) => p.userId), [
      'user-1',
      'user-2',
    ]);
  });

  test('a guild-wide join teaches it a channel it never hydrated', () async {
    events.add(
      const UserJoinedVoiceChannel(
        userId: 'user-1',
        channelId: _channelB,
        guildId: _guildId,
      ),
    );
    await pumpEventQueue();
    expect(cubit.state.rosterFor(_channelB).map((p) => p.userId), ['user-1']);

    occupancy = {
      _channelB: ['user-1', 'user-2'],
    };
    connection.add(RealtimeConnectionStatus.connected);
    await pumpEventQueue();

    // Without the guild id recorded off the event, this channel would have no
    // way back to a snapshot read and would stay one participant short.
    expect(cubit.state.rosterFor(_channelB).map((p) => p.userId), [
      'user-1',
      'user-2',
    ]);
  });

  test('anything but connected leaves the rosters alone', () async {
    await cubit.hydrateChannelRoster(_guildId, _channelA);
    clearInteractions(repository);

    connection.add(RealtimeConnectionStatus.disconnected);
    connection.add(RealtimeConnectionStatus.connecting);
    await pumpEventQueue();

    verifyNever(() => repository.getSnapshot(any(), any()));
  });

  test('signing out drops the rosters it would otherwise re-read', () async {
    await cubit.hydrateChannelRoster(_guildId, _channelA);
    cubit.clearRosters();
    expect(cubit.state.rosters, isEmpty);

    clearInteractions(repository);
    connection.add(RealtimeConnectionStatus.connected);
    await pumpEventQueue();

    // The next account is in a different set of guilds; re-reading the previous
    // one's channels is a handful of 403s and nothing else.
    verifyNever(() => repository.getSnapshot(any(), any()));
  });
}
