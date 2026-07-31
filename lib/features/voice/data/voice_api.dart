import 'package:dio/dio.dart';

import '../../../core/device/device_id_service.dart';
import '../../../core/network/api_client.dart';
import 'models/call_dto.dart';
import 'models/cf_signaling_dto.dart';

/// REST surface for 1:1 calling - call lifecycle plus the Cloudflare Calls
/// SFU proxy endpoints (App ID/secret never leave the server; the backend
/// proxies each of these straight to `rtc.live.cloudflare.com`).
///
/// Every request here carries `X-Device-Id`, sourced centrally from
/// [DeviceIdService] rather than passed in per call site. That is deliberate
/// and load-bearing, not tidiness: the backend runs its device-takeover
/// detection (`Call.ConnectDevice`) on *both* `PUT call/{id}/accept` and
/// `POST calls/{id}/session`, comparing the header on one against the header
/// on the other. Omitting it anywhere makes the server read `"default"` for
/// that request only, so an accept (real id) followed by a session create
/// (`"default"`) looks exactly like the user answering on a second device -
/// the server fires `call.CallDeviceTakeover` at the very device that just
/// joined and wipes its `CfSessionId`/`AudioTrackName`. See the regression
/// test in `test/voice_device_id_test.dart`.
class VoiceApi {
  VoiceApi({required this.client, required this.deviceIdService});

  final ApiClient client;
  final DeviceIdService deviceIdService;

  static const _base = '/api/v1/messaging/voice';

  Options get _deviceOptions =>
      Options(headers: {'X-Device-Id': deviceIdService.deviceId});

  /// Authoritative current-state fetch - the catch-up path when a live
  /// `call.*` SignalR event may have been missed (e.g. a reconnect gap).
  Future<CallDto> getCall(String callId) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      client.url('$_base/call/$callId'),
      options: _deviceOptions,
    );
    return CallDto.fromJson(response.data!);
  }

  Future<CallDto> createCall({
    required String conversationId,
    required List<String> participantUserIds,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      client.url('$_base/call'),
      data: {
        'conversationId': conversationId,
        'participants': participantUserIds,
      },
      options: _deviceOptions,
    );
    return CallDto.fromJson(response.data!);
  }

  Future<CallDto> acceptCall(String callId) async {
    final response = await client.dio.put<Map<String, dynamic>>(
      client.url('$_base/call/$callId/accept'),
      options: _deviceOptions,
    );
    return CallDto.fromJson(response.data!);
  }

  Future<CallDto> declineCall(String callId) async {
    final response = await client.dio.put<Map<String, dynamic>>(
      client.url('$_base/call/$callId/decline'),
      options: _deviceOptions,
    );
    return CallDto.fromJson(response.data!);
  }

  /// Removes just this participant from an active call - the rest of the
  /// call keeps running. This is what a "hang up" action should call for a
  /// call with other participants still connected; [endCall] force-terminates
  /// for everyone regardless of how many remain.
  ///
  /// The backend no-ops this unless `X-Device-Id` matches the participant's
  /// current `ActiveDeviceId`, so a hang-up sent with the wrong id leaves the
  /// caller connected server-side until the alone-timeout fires.
  Future<CallDto> leaveCall(String callId) async {
    final response = await client.dio.put<Map<String, dynamic>>(
      client.url('$_base/call/$callId/leave'),
      options: _deviceOptions,
    );
    return CallDto.fromJson(response.data!);
  }

  /// Force-terminates the call for every participant. Not currently wired to
  /// any UI action (this client has no "end call for everyone" button - see
  /// [leaveCall]), kept available like `GuildVoiceApi.serverDeafen` mirrors
  /// the full backend contract for a future moderator-style action.
  Future<CallDto> endCall(String callId) async {
    final response = await client.dio.put<Map<String, dynamic>>(
      client.url('$_base/call/$callId/end'),
      options: _deviceOptions,
    );
    return CallDto.fromJson(response.data!);
  }

  /// [primary] mirrors the backend's query flag: a primary session carries
  /// this participant's microphone and runs the device-connect/takeover path
  /// server-side; a secondary one (a second session for a screen track alone)
  /// deliberately skips it. This client only ever opens primary sessions -
  /// it publishes screen share on the same peer connection as its mic - so
  /// the parameter exists to keep the call site explicit about which branch
  /// of `CloudflareController.CreateSession` it is taking.
  Future<String> cfCreateSession(String callId, {bool primary = true}) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      client.url('$_base/calls/$callId/session'),
      queryParameters: {'primary': primary},
      options: _deviceOptions,
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
      options: _deviceOptions,
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
      options: _deviceOptions,
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
      options: _deviceOptions,
    );
  }
}
