import 'package:dio/dio.dart';

import '../../../core/device/device_id_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/voice/voice_liveness.dart';
import '../../../core/voice/voice_media_api.dart';
import '../../../core/voice/voice_media_dto.dart';
import '../../../core/voice/voice_snapshot_dto.dart';
import '../../../core/voice/voice_subscription_set.dart';
import 'models/voice_state_dto.dart';
import 'models/guild_voice_activity_dto.dart';

/// REST surface for guild voice channels.
///
/// The same voice room as a 1:1 call, addressed by `{guildId}/{channelId}`
/// instead of a call id, plus the two things only a standing channel has:
/// moderation, and a join that is unilateral rather than rung.
///
/// `X-Device-Id` goes on join, leave and session creation for the same reason
/// it does on the call routes - one user is in one room on one device at a
/// time, and the server compares the header across requests to decide whether
/// a join is a takeover. A missing header reads as the literal `"default"`,
/// which makes a real device look like a second one.
class GuildVoiceApi {
  GuildVoiceApi({required this.client, required this.deviceIdService});

  final ApiClient client;
  final DeviceIdService deviceIdService;

  String _base(String guildId, String channelId) =>
      client.url('/api/v1/guild/guilds/$guildId/channels/$channelId/voice');

  Options get _deviceOptions =>
      Options(headers: {'X-Device-Id': deviceIdService.deviceId});

  // ── Membership ────────────────────────────────────────────────────────────

  /// Puts this user in the roster *before* any media work, and returns the
  /// authoritative snapshot. Nothing else has to be awaited to render the
  /// room.
  Future<VoiceRoomSnapshotDto> join(String guildId, String channelId) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '${_base(guildId, channelId)}/join',
      data: const {},
      options: _deviceOptions,
    );
    // Join answers with the snapshot itself - the same object the server also
    // pushes over SignalR - so the room renders from this response without
    // waiting for any event.
    return VoiceRoomSnapshotDto.fromJson(response.data!);
  }

  Future<void> leave(String guildId, String channelId) async {
    await client.dio.post<void>(
      '${_base(guildId, channelId)}/leave',
      data: const {},
      options: _deviceOptions,
    );
  }

  /// "I am still here", over HTTP rather than over the hub - see
  /// [VoiceLiveness] for why the room needs telling twice by two different
  /// routes.
  ///
  /// Answers an outcome instead of throwing, because `404` and `409` are two of
  /// the three expected replies rather than faults: the loop that calls this
  /// every 30 seconds has to branch on all three, and exception control flow
  /// for the ordinary case would be the wrong shape for it. `X-Device-Id` is
  /// load-bearing here in particular - the server compares it against the
  /// roster and answers `409` for a device the roster has superseded.
  Future<VoiceLivenessOutcome> assertAlive(
    String guildId,
    String channelId,
  ) async {
    try {
      await client.dio.post<void>(
        '${_base(guildId, channelId)}/alive',
        options: _deviceOptions,
      );
      return VoiceLivenessOutcome.alive;
    } on DioException catch (e) {
      return voiceLivenessOutcomeFor(e.response?.statusCode);
    }
  }

  /// The authoritative state of the channel: who is publishing, what to pull
  /// to hear them, and which screen shares exist. Also the roster read for
  /// channels the user has not joined, which is why it is safe to call for any
  /// visible voice channel.
  Future<VoiceRoomSnapshotDto> getSnapshot(
    String guildId,
    String channelId,
  ) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '${_base(guildId, channelId)}/snapshot',
    );
    return VoiceRoomSnapshotDto.fromJson(response.data!);
  }

  /// Where the server places this account in guild voice, or null when it
  /// places it nowhere. See [VoiceStateDto].
  ///
  /// Account-scoped rather than channel-scoped, so it does not go through
  /// [_base]. The `204` answer is the common one and arrives with no body, so
  /// this is requested as `dynamic` - a typed `Map` request against an empty
  /// body is a cast error rather than a null.
  ///
  /// No `X-Device-Id` on purpose: the question is "where is this *account*",
  /// and the answer names the device holding the seat rather than being
  /// filtered by it.
  Future<VoiceStateDto?> getVoiceState() async {
    final response = await client.dio.get<dynamic>(
      client.url('/api/v1/guild/voice/state'),
    );
    final data = response.data;
    if (data is! Map<String, dynamic> || data.isEmpty) return null;
    return VoiceStateDto.fromJson(data);
  }

  /// "Which of my servers has anyone in voice right now" - the snapshot behind
  /// the voice indicator in the server rail.
  ///
  /// Live updates need nothing else: `guild.voice.UserJoinedVoice` /
  /// `UserLeftVoice` already carry a guildId and already reach every member, so
  /// a connected client keeps its own counts. This exists for the moments it is
  /// not connected - launch, and the gap after a reconnect - where the
  /// alternative is one request per voice channel per guild.
  ///
  /// Guilds with nobody in voice are omitted rather than returned empty.
  Future<List<GuildVoiceActivityDto>> getVoiceActivity() async {
    final response = await client.dio.get<List<dynamic>>(
      client.url('/api/v1/guild/guilds/voice-activity'),
    );
    return (response.data ?? const [])
        .map((e) => GuildVoiceActivityDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Media ─────────────────────────────────────────────────────────────────

  /// See `VoiceApi.createConnection` for what [primary] selects. This client
  /// only opens primary connections - screen share rides the same one as the
  /// microphone.
  Future<VoiceConnectionDto> createConnection(
    String guildId,
    String channelId, {
    bool primary = true,
    String? tag,
  }) => mapMediaErrors('connection', () async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '${_base(guildId, channelId)}/connection',
      data: const {},
      queryParameters: {'primary': primary, 'tag': ?tag},
      options: _deviceOptions,
    );
    return VoiceConnectionDto.fromJson(response.data!);
  });

  /// Declares tracks already published through the SDK. See
  /// `VoiceMediaApi.declarePublish`.
  Future<VoicePublishResultDto> declarePublish({
    required String guildId,
    required String channelId,
    required List<String> trackNames,
    Map<String, dynamic>? video,
  }) => mapMediaErrors('publish', () async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '${_base(guildId, channelId)}/publish',
      data: {'trackNames': trackNames, 'video': ?video},
      options: _deviceOptions,
    );
    return VoicePublishResultDto.fromJson(response.data ?? const {});
  });

  Future<void> unpublish({
    required String guildId,
    required String channelId,
    required List<String> trackNames,
  }) => mapMediaErrors('unpublish', () async {
    await client.dio.post<void>(
      '${_base(guildId, channelId)}/unpublish',
      data: {'trackNames': trackNames},
      options: _deviceOptions,
    );
  });

  /// Declares a resolution change made without republishing. Never refuses.
  Future<void> declareVideo({
    required String guildId,
    required String channelId,
    required Map<String, dynamic> video,
  }) => mapMediaErrors('video', () async {
    await client.dio.put<void>(
      '${_base(guildId, channelId)}/video',
      data: video,
      options: _deviceOptions,
    );
  });

  /// Reports this client's own rendering - tile sizes, pins, collapsed tiles,
  /// backgrounding and share audio. Omitted fields are left alone server-side,
  /// so a tile resize is a body with `tileHeights` in it and nothing else.
  ///
  /// The reply is this client's own subscription set.
  Future<VoiceSubscriptionSetDto?> updateSubscriber({
    required String guildId,
    required String channelId,
    bool? paused,
    Map<String, int>? tileHeights,
    List<String>? pinned,
    List<String>? pausedPublishers,
    List<String>? screenAudioShares,
  }) => mapMediaErrors('subscriptions', () async {
    final response = await client.dio.post<dynamic>(
      '${_base(guildId, channelId)}/subscriptions',
      data: {
        'paused': ?paused,
        'tileHeights': ?tileHeights,
        'pinned': ?pinned,
        'pausedPublishers': ?pausedPublishers,
        'screenAudioShares': ?screenAudioShares,
      },
      options: _deviceOptions,
    );
    return voiceSubscriptionSetFromJson(response.data);
  });

  // ── Screen share viewership ───────────────────────────────────────────────

  /// Claims a viewer slot; expires after 90 seconds, so it is re-posted on the
  /// heartbeat rather than once. See `VoiceApi.watchShare`.
  Future<void> watchShare(
    String guildId,
    String channelId,
    String shareId,
  ) async {
    await client.dio.post<void>(
      '${_base(guildId, channelId)}/shares/$shareId/watch',
      options: _deviceOptions,
    );
  }

  Future<void> unwatchShare(
    String guildId,
    String channelId,
    String shareId,
  ) async {
    await client.dio.delete<void>(
      '${_base(guildId, channelId)}/shares/$shareId/watch',
      options: _deviceOptions,
    );
  }

  Future<Map<String, List<String>>> shareViewers(
    String guildId,
    String channelId,
  ) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '${_base(guildId, channelId)}/shares/viewers',
    );
    return (response.data ?? const {}).map(
      (shareId, viewers) =>
          MapEntry(shareId, (viewers as List? ?? const []).cast<String>()),
    );
  }

  // Moderation - server mute, server deafen and move - is not here: all three
  // are hub invocations (`guild.voice.ServerMute` / `ServerDeafen` /
  // `MoveUser`), so that the server sets the acting user from the connection
  // and a client can only ever name a target. See `GuildVoiceRepository`.
}
