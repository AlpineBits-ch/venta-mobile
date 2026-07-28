import '../../../core/network/api_client.dart';
import 'models/call_dto.dart';
import 'models/cf_signaling_dto.dart';

/// REST surface for 1:1 calling — call lifecycle plus the Cloudflare Calls
/// SFU proxy endpoints (App ID/secret never leave the server; the backend
/// proxies each of these straight to `rtc.live.cloudflare.com`).
class VoiceApi {
  VoiceApi({required this.client});

  final ApiClient client;

  static const _base = '/api/v1/messaging/voice';

  Future<CallDto> createCall({
    required String conversationId,
    required List<String> participantUserIds,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      client.url('$_base/call'),
      data: {'conversationId': conversationId, 'participants': participantUserIds},
    );
    return CallDto.fromJson(response.data!);
  }

  Future<CallDto> acceptCall(String callId) async {
    final response = await client.dio.put<Map<String, dynamic>>(
      client.url('$_base/call/$callId/accept'),
    );
    return CallDto.fromJson(response.data!);
  }

  Future<CallDto> declineCall(String callId) async {
    final response = await client.dio.put<Map<String, dynamic>>(
      client.url('$_base/call/$callId/decline'),
    );
    return CallDto.fromJson(response.data!);
  }

  Future<CallDto> endCall(String callId) async {
    final response = await client.dio.put<Map<String, dynamic>>(
      client.url('$_base/call/$callId/end'),
    );
    return CallDto.fromJson(response.data!);
  }

  Future<String> cfCreateSession(String callId) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      client.url('$_base/calls/$callId/session'),
    );
    return response.data!['cfSessionId'] as String;
  }

  Future<CfTracksNewResponseDto> cfTracksNew({
    required String callId,
    required String cfSessionId,
    required Map<String, dynamic> sessionDescription,
    required List<Map<String, dynamic>> tracks,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      client.url('$_base/calls/$callId/cf/tracks/new'),
      data: {
        'cfSessionId': cfSessionId,
        'sessionDescription': sessionDescription,
        'tracks': tracks,
      },
    );
    return CfTracksNewResponseDto.fromJson(response.data!);
  }

  Future<CfRenegotiateResponseDto> cfRenegotiate({
    required String callId,
    required String cfSessionId,
    required Map<String, dynamic> sessionDescription,
  }) async {
    final response = await client.dio.put<Map<String, dynamic>>(
      client.url('$_base/calls/$callId/cf/renegotiate'),
      data: {'cfSessionId': cfSessionId, 'sessionDescription': sessionDescription},
    );
    return CfRenegotiateResponseDto.fromJson(response.data!);
  }

  Future<void> cfCloseTracks({
    required String callId,
    required String cfSessionId,
    required List<String> trackNames,
  }) async {
    await client.dio.put<void>(
      client.url('$_base/calls/$callId/cf/tracks/close'),
      data: {'cfSessionId': cfSessionId, 'trackNames': trackNames},
    );
  }
}
