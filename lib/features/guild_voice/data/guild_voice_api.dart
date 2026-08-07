import 'package:dio/dio.dart';

import '../../../core/device/device_id_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/voice/voice_media_api.dart';
import '../../../core/voice/voice_media_dto.dart';
import '../../../core/voice/voice_snapshot_dto.dart';
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

  /// See `VoiceApi.createSession` for what [primary] selects. This client only
  /// opens primary sessions - screen share rides the same peer connection as
  /// the microphone.
  Future<VoiceSessionDto> createSession(
    String guildId,
    String channelId, {
    bool primary = true,
  }) => mapMediaErrors('session', () async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '${_base(guildId, channelId)}/session',
      data: const {},
      queryParameters: {'primary': primary},
      options: _deviceOptions,
    );
    return VoiceSessionDto.fromJson(response.data!);
  });

  /// Publishes and/or subscribes tracks in one negotiation.
  Future<VoiceNegotiateResponseDto> negotiate({
    required String guildId,
    required String channelId,
    required String mediaSessionId,
    required Map<String, dynamic> sessionDescription,
    required List<Map<String, dynamic>> tracks,
  }) => mapMediaErrors('tracks', () async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '${_base(guildId, channelId)}/tracks',
      data: {
        'mediaSessionId': mediaSessionId,
        'sessionDescription': sessionDescription,
        'tracks': tracks,
      },
      options: _deviceOptions,
    );
    return VoiceNegotiateResponseDto.fromJson(response.data!);
  });

  Future<VoiceRenegotiateResponseDto> renegotiate({
    required String guildId,
    required String channelId,
    required String mediaSessionId,
    required Map<String, dynamic> sessionDescription,
  }) => mapMediaErrors('negotiate', () async {
    final response = await client.dio.put<Map<String, dynamic>>(
      '${_base(guildId, channelId)}/negotiate',
      data: {
        'mediaSessionId': mediaSessionId,
        'sessionDescription': sessionDescription,
      },
      options: _deviceOptions,
    );
    return VoiceRenegotiateResponseDto.fromJson(response.data!);
  });

  Future<void> closeTracks({
    required String guildId,
    required String channelId,
    required String mediaSessionId,
    required List<String> trackNames,
  }) => mapMediaErrors('tracks/close', () async {
    await client.dio.post<void>(
      '${_base(guildId, channelId)}/tracks/close',
      data: {'mediaSessionId': mediaSessionId, 'trackNames': trackNames},
      options: _deviceOptions,
    );
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
