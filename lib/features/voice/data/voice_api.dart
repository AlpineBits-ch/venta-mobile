import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import 'models/call_dto.dart';
import 'models/cf_signaling_dto.dart';

/// REST surface for 1:1 calling - call lifecycle plus the Cloudflare Calls
/// SFU proxy endpoints (App ID/secret never leave the server; the backend
/// proxies each of these straight to `rtc.live.cloudflare.com`).
class VoiceApi {
  VoiceApi({required this.client});

  final ApiClient client;

  static const _base = '/api/v1/messaging/voice';

  /// Authoritative current-state fetch - the catch-up path when a live
  /// `call.*` SignalR event may have been missed (e.g. a reconnect gap).
  Future<CallDto> getCall(String callId) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      client.url('$_base/call/$callId'),
    );
    return CallDto.fromJson(response.data!);
  }

  Options _deviceHeader(String deviceId) =>
      Options(headers: {'X-Device-Id': deviceId});

  Future<CallDto> createCall({
    required String conversationId,
    required List<String> participantUserIds,
    required String deviceId,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      client.url('$_base/call'),
      data: {
        'conversationId': conversationId,
        'participants': participantUserIds,
      },
      options: _deviceHeader(deviceId),
    );
    return CallDto.fromJson(response.data!);
  }

  Future<CallDto> acceptCall(String callId, {required String deviceId}) async {
    final response = await client.dio.put<Map<String, dynamic>>(
      client.url('$_base/call/$callId/accept'),
      options: _deviceHeader(deviceId),
    );
    return CallDto.fromJson(response.data!);
  }

  Future<CallDto> declineCall(String callId, {required String deviceId}) async {
    final response = await client.dio.put<Map<String, dynamic>>(
      client.url('$_base/call/$callId/decline'),
      options: _deviceHeader(deviceId),
    );
    return CallDto.fromJson(response.data!);
  }

  /// Removes just this participant from an active call - the rest of the
  /// call keeps running. This is what a "hang up" action should call for a
  /// call with other participants still connected; [endCall] force-terminates
  /// for everyone regardless of how many remain.
  Future<CallDto> leaveCall(String callId, {required String deviceId}) async {
    final response = await client.dio.put<Map<String, dynamic>>(
      client.url('$_base/call/$callId/leave'),
      options: _deviceHeader(deviceId),
    );
    return CallDto.fromJson(response.data!);
  }

  /// Force-terminates the call for every participant. Not currently wired to
  /// any UI action (this client has no "end call for everyone" button - see
  /// [leaveCall]), kept available like `GuildVoiceApi.serverDeafen` mirrors
  /// the full backend contract for a future moderator-style action.
  Future<CallDto> endCall(String callId, {required String deviceId}) async {
    final response = await client.dio.put<Map<String, dynamic>>(
      client.url('$_base/call/$callId/end'),
      options: _deviceHeader(deviceId),
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
      data: {
        'cfSessionId': cfSessionId,
        'sessionDescription': sessionDescription,
      },
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
