import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../voice/data/models/cf_signaling_dto.dart';
import 'models/guild_voice_dto.dart';

/// REST surface for guild voice channels — a parallel abstraction to
/// `VoiceApi` (1:1 calling), scoped to `{guildId}/channels/{channelId}`
/// rather than a bare call id. Mirrors Alpine's `GuildVoiceService`: no
/// accept/decline (joining is unilateral), CF Calls session/track/SDP
/// concepts are reused as-is (one `cfSessionId`-bearing peer connection per
/// channel session, same tracksNew/renegotiate/closeTracks triad).
class GuildVoiceApi {
  GuildVoiceApi({required this.client});

  final ApiClient client;

  String _base(String guildId, String channelId) =>
      client.url('/api/v1/guild/guilds/$guildId/channels/$channelId/voice');

  Future<VoiceStateDto> join(
    String guildId,
    String channelId, {
    required String deviceId,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '${_base(guildId, channelId)}/join',
      data: const {},
      options: Options(headers: {'X-Device-Id': deviceId}),
    );
    return VoiceStateDto.fromJson(response.data!);
  }

  Future<void> leave(
    String guildId,
    String channelId, {
    String? deviceId,
  }) async {
    await client.dio.post<void>(
      '${_base(guildId, channelId)}/leave',
      data: const {},
      options: deviceId != null
          ? Options(headers: {'X-Device-Id': deviceId})
          : null,
    );
  }

  /// Roster-only fetch, without joining — used to populate participant
  /// counts/avatars for voice channels the user hasn't joined yet.
  Future<VoiceStateDto> getState(String guildId, String channelId) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      _base(guildId, channelId),
    );
    return VoiceStateDto.fromJson(response.data!);
  }

  Future<String> cfCreateSession(String guildId, String channelId) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '${_base(guildId, channelId)}/session',
      data: const {},
    );
    return response.data!['cfSessionId'] as String;
  }

  Future<CfTracksNewResponseDto> cfTracksNew({
    required String guildId,
    required String channelId,
    required String cfSessionId,
    required Map<String, dynamic> sessionDescription,
    required List<Map<String, dynamic>> tracks,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '${_base(guildId, channelId)}/cf/tracks/new',
      data: {
        'cfSessionId': cfSessionId,
        'sessionDescription': sessionDescription,
        'tracks': tracks,
      },
    );
    return CfTracksNewResponseDto.fromJson(response.data!);
  }

  Future<CfRenegotiateResponseDto> cfRenegotiate({
    required String guildId,
    required String channelId,
    required String cfSessionId,
    required Map<String, dynamic> sessionDescription,
  }) async {
    final response = await client.dio.put<Map<String, dynamic>>(
      '${_base(guildId, channelId)}/cf/renegotiate',
      data: {
        'cfSessionId': cfSessionId,
        'sessionDescription': sessionDescription,
      },
    );
    return CfRenegotiateResponseDto.fromJson(response.data!);
  }

  Future<void> cfCloseTracks({
    required String guildId,
    required String channelId,
    required String cfSessionId,
    required List<String> trackNames,
  }) async {
    await client.dio.put<void>(
      '${_base(guildId, channelId)}/cf/tracks/close',
      data: {'cfSessionId': cfSessionId, 'trackNames': trackNames},
    );
  }

  Future<void> serverDeafen({
    required String guildId,
    required String channelId,
    required String userId,
    required bool isDeafened,
  }) async {
    await client.dio.patch<void>(
      '${_base(guildId, channelId)}/participants/$userId/deafen',
      data: {'isDeafened': isDeafened},
    );
  }
}
