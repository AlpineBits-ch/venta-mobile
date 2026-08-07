import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/safe_emit.dart';
import '../../../core/realtime/realtime_transport.dart';
import '../data/guild_voice_repository.dart';

/// Who is in voice in one channel, as the guild-level index sees it. Just the
/// occupancy - the full roster for a channel lives in `GuildVoiceCubit`, which
/// only knows about channels something has actually asked it to load.
class ChannelVoiceActivity extends Equatable {
  const ChannelVoiceActivity({
    required this.channelId,
    this.userIds = const {},
    this.streamerIds = const {},
  });

  final String channelId;
  final Set<String> userIds;

  /// Subset of [userIds] currently screen sharing.
  final Set<String> streamerIds;

  int get participantCount => userIds.length;
  bool get hasStream => streamerIds.isNotEmpty;
  bool get isEmpty => userIds.isEmpty;

  ChannelVoiceActivity copyWith({
    Set<String>? userIds,
    Set<String>? streamerIds,
  }) => ChannelVoiceActivity(
    channelId: channelId,
    userIds: userIds ?? this.userIds,
    streamerIds: streamerIds ?? this.streamerIds,
  );

  @override
  List<Object?> get props => [channelId, userIds, streamerIds];
}

/// One guild's voice occupancy, keyed by channel. A guild with nothing
/// happening is absent from [GuildVoiceActivityState.guilds] rather than
/// present and empty, so "is anything happening here" is a map lookup.
class GuildVoiceActivity extends Equatable {
  const GuildVoiceActivity({required this.guildId, this.channels = const {}});

  final String guildId;
  final Map<String, ChannelVoiceActivity> channels;

  int get participantCount =>
      channels.values.fold(0, (sum, c) => sum + c.participantCount);

  bool get hasStream => channels.values.any((c) => c.hasStream);

  @override
  List<Object?> get props => [guildId, channels];
}

class GuildVoiceActivityState extends Equatable {
  const GuildVoiceActivityState({this.guilds = const {}});

  final Map<String, GuildVoiceActivity> guilds;

  GuildVoiceActivity? forGuild(String guildId) => guilds[guildId];

  bool hasVoice(String guildId) => guilds.containsKey(guildId);

  @override
  List<Object?> get props => [guilds];
}

/// Keeps "somebody is in voice in this server" live for the server rail.
///
/// Two sources, and both are needed. The HTTP index answers the question for
/// every guild at once, which is what a cold start and the gap after a
/// reconnect need - the alternative is one request per voice channel per
/// guild. The guild-wide `UserJoinedVoice`/`UserLeftVoice` events, which reach
/// every member of a guild rather than only the room, keep it current after
/// that without any polling.
///
/// Membership is tracked as a set of user ids rather than a counter: a
/// duplicated join or a doubled leave then converges on the right answer
/// instead of drifting a tally nothing can correct. That is the same choice
/// the server's own index makes, for the same reason.
class GuildVoiceActivityCubit extends Cubit<GuildVoiceActivityState>
    with SafeEmit<GuildVoiceActivityState> {
  GuildVoiceActivityCubit({required this.repository})
    : super(const GuildVoiceActivityState()) {
    _sub = repository.events.listen(_handleEvent);
    _connectionSub = repository.connectionStatus.listen((status) {
      // A reconnect means presence events during the gap were dropped, and
      // there is no per-event recovery for a guild-wide fan-out - so the whole
      // index is re-read.
      if (status == RealtimeConnectionStatus.connected) unawaited(load());
    });
  }

  final GuildVoiceRepository repository;
  late final StreamSubscription<GuildVoiceEvent> _sub;
  late final StreamSubscription<RealtimeConnectionStatus> _connectionSub;

  /// Reads occupancy for every guild the user is a member of. Called at
  /// startup and on every realtime reconnect.
  Future<void> load() async {
    try {
      final activity = await repository.getVoiceActivity();
      emitIfOpen(
        GuildVoiceActivityState(
          guilds: {
            for (final guild in activity)
              guild.guildId: GuildVoiceActivity(
                guildId: guild.guildId,
                channels: {
                  for (final channel in guild.channels)
                    channel.channelId: ChannelVoiceActivity(
                      channelId: channel.channelId,
                      userIds: channel.userIds.toSet(),
                      streamerIds: channel.streamerIds.toSet(),
                    ),
                },
              ),
          },
        ),
      );
    } catch (_) {
      // Best-effort: this is an indicator, not a blocker, and the live events
      // rebuild it from whatever happens next.
    }
  }

  /// Drops everything. Called on sign-in and sign-out alike - this singleton
  /// outlives a session, and the next account is in a different set of guilds.
  void clear() => emitIfOpen(const GuildVoiceActivityState());

  void _handleEvent(GuildVoiceEvent event) {
    switch (event) {
      case UserJoinedVoiceChannel(
        :final guildId,
        :final channelId,
        :final userId,
      ):
        _mutate(guildId, channelId, (channel) {
          return channel.copyWith(userIds: {...channel.userIds, userId});
        });

      case UserLeftVoiceChannel(
        :final guildId,
        :final channelId,
        :final userId,
      ):
        _mutate(guildId, channelId, (channel) {
          return channel.copyWith(
            userIds: {...channel.userIds}..remove(userId),
            streamerIds: {...channel.streamerIds}..remove(userId),
          );
        });

      case VoiceScreenShareStarted(:final channelId, :final userId):
        _mutateChannel(channelId, (channel) {
          return channel.copyWith(
            streamerIds: {...channel.streamerIds, userId},
          );
        });

      case VoiceScreenShareStopped(:final channelId, :final userId):
        _mutateChannel(channelId, (channel) {
          return channel.copyWith(
            streamerIds: {...channel.streamerIds}..remove(userId),
          );
        });

      case VoiceSnapshotReceived(:final snapshot):
        // The snapshot is authoritative for the room it describes, so it also
        // repairs this index for that one channel - which is how a channel the
        // user is actually in stays right even if a presence event was missed.
        _mutateChannel(
          snapshot.roomId,
          (channel) => channel.copyWith(
            userIds: {for (final p in snapshot.participants) p.userId},
            streamerIds: {
              for (final p in snapshot.participants)
                if (p.shares.isNotEmpty) p.userId,
            },
          ),
          guildId: snapshot.guildId,
        );

      case VoiceResyncRequested():
      case VoiceParticipantJoined():
      case VoiceTrackPublished():
      case VoiceTrackClosed():
      case VoiceMuteChanged():
      case VoiceDeafenChanged():
      case VoiceCameraChanged():
      case VoiceSpeakingChanged():
      case VoiceShareViewersChanged():
      case VoiceMovedToChannel():
      case VoiceKickedByOtherDevice():
        break;
    }
  }

  /// Applies [update] to a channel whose guild is known.
  void _mutate(
    String guildId,
    String channelId,
    ChannelVoiceActivity Function(ChannelVoiceActivity) update,
  ) {
    final guilds = Map<String, GuildVoiceActivity>.from(state.guilds);
    final guild =
        guilds[guildId] ?? GuildVoiceActivity(guildId: guildId, channels: {});
    final channels = Map<String, ChannelVoiceActivity>.from(guild.channels);
    final channel =
        channels[channelId] ?? ChannelVoiceActivity(channelId: channelId);

    final updated = update(channel);
    // Empty channels are dropped rather than kept at zero: the question this
    // index answers is "is anything happening here", and an empty entry is a
    // no that would still light the rail.
    if (updated.isEmpty) {
      channels.remove(channelId);
    } else {
      channels[channelId] = updated;
    }

    if (channels.isEmpty) {
      guilds.remove(guildId);
    } else {
      guilds[guildId] = GuildVoiceActivity(
        guildId: guildId,
        channels: channels,
      );
    }
    emitIfOpen(GuildVoiceActivityState(guilds: guilds));
  }

  /// Applies [update] to a channel whose guild has to be found first. Screen
  /// share events name the channel but not the guild, so the guild is resolved
  /// from what is already indexed - and when it is not indexed at all, there is
  /// nothing to update, because nobody is recorded as being in voice there.
  void _mutateChannel(
    String channelId,
    ChannelVoiceActivity Function(ChannelVoiceActivity) update, {
    String? guildId,
  }) {
    final resolved = guildId ?? _guildOf(channelId);
    if (resolved == null) return;
    _mutate(resolved, channelId, update);
  }

  String? _guildOf(String channelId) {
    for (final guild in state.guilds.values) {
      if (guild.channels.containsKey(channelId)) return guild.guildId;
    }
    return null;
  }

  @override
  Future<void> close() {
    unawaited(_sub.cancel());
    unawaited(_connectionSub.cancel());
    return super.close();
  }
}
