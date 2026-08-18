import 'package:dio/dio.dart';

import '../../../core/device/device_id_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/voice/voice_liveness.dart';
import '../../../core/voice/voice_media_api.dart';
import '../../../core/voice/voice_media_dto.dart';
import '../../../core/voice/voice_snapshot_dto.dart';
import '../../../core/voice/voice_subscription_set.dart';
import 'models/call_dto.dart';
import 'models/ongoing_call_dto.dart';

/// REST surface for 1:1 calling - the call lifecycle (ring, accept, decline,
/// leave, end) plus the voice-room surface every call shares with guild voice
/// channels: the snapshot, the Cloudflare Calls SFU proxy, and screen-share
/// viewership.
///
/// Note the two path shapes, which are historical and both correct as written:
/// lifecycle routes live under `voice/call/{callId}` (singular) while the SFU
/// routes live under `voice/calls/{callId}` (plural).
///
/// Every request here carries `X-Device-Id`, sourced centrally from
/// [DeviceIdService] rather than passed in per call site. That is deliberate
/// and load-bearing, not tidiness: the backend runs its device-takeover
/// detection on *both* `PUT call/{id}/accept` and `POST calls/{id}/session`,
/// comparing the header on one against the header on the other. Omitting it
/// anywhere makes the server read `"default"` for that request only, so an
/// accept (real id) followed by a session create (`"default"`) looks exactly
/// like the user answering on a second device - the server fires a takeover at
/// the very device that just joined and wipes its session. See the regression
/// test in `test/voice_device_id_test.dart`.
class VoiceApi {
  VoiceApi({required this.client, required this.deviceIdService});

  final ApiClient client;
  final DeviceIdService deviceIdService;

  static const _base = '/api/v1/messaging/voice';

  Options get _deviceOptions =>
      Options(headers: {'X-Device-Id': deviceIdService.deviceId});

  // ── Call lifecycle ────────────────────────────────────────────────────────

  /// Ring state and roster. The catch-up read for a call already joined; for
  /// media state use [getSnapshot], which is the authoritative one.
  Future<CallDto> getCall(String callId) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      client.url('$_base/call/$callId'),
      options: _deviceOptions,
    );
    return CallDto.fromJson(response.data!);
  }

  /// The call ringing for this user right now, or null when none is.
  ///
  /// `call.IncomingCall` is broadcast once and never replayed, so a client that
  /// wasn't connected when it went out - killed, backgrounded onto a dead
  /// socket, or opened while the phone was already ringing - never hears about
  /// the call at all, and the push fallback can be missed too. This is the
  /// catch-up read for that.
  ///
  /// The server answers `204` with no body for "nothing ringing", which is the
  /// overwhelmingly common case - hence the null return rather than a throw.
  /// Deliberately requested as `dynamic`: a typed `get<Map<String, dynamic>>`
  /// against an empty body is a cast error, not a null.
  Future<CallDto?> getPendingCall() async {
    final response = await client.dio.get<dynamic>(
      client.url('$_base/call/pending'),
      options: _deviceOptions,
    );
    final data = response.data;
    if (data is! Map<String, dynamic> || data.isEmpty) return null;
    return CallDto.fromJson(data);
  }

  /// Whether a call is already happening in this conversation - the read
  /// behind a "join call in progress" affordance.
  ///
  /// Answers for any member of the conversation, including one who declined,
  /// left, or was never invited. `204` with no body means no call; a
  /// non-member gets `404`, because the existence of the call is itself
  /// withheld. Deliberately not a [CallDto] - see [OngoingCallDto].
  Future<OngoingCallDto?> getConversationCall(String conversationId) async {
    final response = await client.dio.get<dynamic>(
      client.url('$_base/conversations/$conversationId/call'),
      options: _deviceOptions,
    );
    final data = response.data;
    if (data is! Map<String, dynamic> || data.isEmpty) return null;
    return OngoingCallDto.fromJson(data);
  }

  /// The call this account is still placed in, or null - the launch read
  /// behind the reconnect banner.
  ///
  /// Unlike [getPendingCall] this is not about being rung: it answers for a
  /// call this client had already joined and then vanished from. A call is
  /// hung up as its socket drops, so unlike a guild-voice seat there is no
  /// stale roster entry here - only, sometimes, a call that carried on without
  /// us. It is therefore an offer to put to the user rather than state to
  /// paint, and `204` is by far the commonest answer: a call that has since
  /// ended, one answered on another device, and one nobody is left in all read
  /// as "you are in nothing".
  Future<OngoingCallDto?> getActiveCall() async {
    final response = await client.dio.get<dynamic>(
      client.url('$_base/call/active'),
      options: _deviceOptions,
    );
    final data = response.data;
    if (data is! Map<String, dynamic> || data.isEmpty) return null;
    return OngoingCallDto.fromJson(data);
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

  /// Removes just this participant from an active call - the rest of the call
  /// keeps running. This is what a "hang up" action should call; [endCall]
  /// force-terminates for everyone regardless of how many remain.
  ///
  /// The backend no-ops this unless `X-Device-Id` matches the participant's
  /// current active device, so a hang-up sent with the wrong id leaves the
  /// caller connected server-side until the alone-timeout fires.
  Future<CallDto> leaveCall(String callId) async {
    final response = await client.dio.put<Map<String, dynamic>>(
      client.url('$_base/call/$callId/leave'),
      options: _deviceOptions,
    );
    return CallDto.fromJson(response.data!);
  }

  /// Force-terminates the call for every participant. Not wired to any UI
  /// action in this client (there is no "end for everyone" button - see
  /// [leaveCall]); kept because the contract has it.
  Future<CallDto> endCall(String callId) async {
    final response = await client.dio.put<Map<String, dynamic>>(
      client.url('$_base/call/$callId/end'),
      options: _deviceOptions,
    );
    return CallDto.fromJson(response.data!);
  }

  // ── Voice room ────────────────────────────────────────────────────────────

  /// The authoritative media state of the call: who is publishing, what to
  /// pull to hear them, and which screen shares exist. Sufficient on its own,
  /// whatever was missed.
  Future<VoiceRoomSnapshotDto> getSnapshot(String callId) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      client.url('$_base/call/$callId/snapshot'),
      options: _deviceOptions,
    );
    return VoiceRoomSnapshotDto.fromJson(response.data!);
  }

  /// "I am still here", over HTTP rather than over the hub - see
  /// [VoiceLiveness] for why the room needs telling twice by two different
  /// routes.
  ///
  /// Note the **plural** `calls` segment: this is one of the voice-room routes,
  /// not one of the call-lifecycle ones, and the two path shapes are both
  /// correct as written (see the class comment). Answers an outcome instead of
  /// throwing, because `404` and `409` are two of the three expected replies
  /// rather than faults - the loop that calls this every 30 seconds has to
  /// branch on all three.
  Future<VoiceLivenessOutcome> assertAlive(String callId) async {
    try {
      await client.dio.post<void>(
        client.url('$_base/calls/$callId/alive'),
        options: _deviceOptions,
      );
      return VoiceLivenessOutcome.alive;
    } on DioException catch (e) {
      return voiceLivenessOutcomeFor(e.response?.statusCode);
    }
  }

  /// Mints a connection to the SFU node this call lives on.
  ///
  /// [primary] mirrors the backend's query flag: a primary connection carries
  /// this participant's microphone and runs the device-connect/takeover path
  /// server-side. This client only ever opens primary connections - it
  /// publishes screen share over the same one as its microphone, which is what
  /// a single-process client should do.
  ///
  /// The response names the media backend as well as the connection, so the
  /// client picks its media layer from a declared value rather than inferring
  /// one from the shape of what came back.
  Future<VoiceConnectionDto> createConnection(
    String callId, {
    bool primary = true,
    String? tag,
  }) => mapMediaErrors('connection', () async {
    final response = await client.dio.post<Map<String, dynamic>>(
      client.url('$_base/calls/$callId/connection'),
      queryParameters: {'primary': primary, 'tag': ?tag},
      options: _deviceOptions,
    );
    return VoiceConnectionDto.fromJson(response.data!);
  });

  /// Declares tracks already published through the SDK. See
  /// `VoiceMediaApi.declarePublish` for why this is not optional despite the
  /// media working without it.
  Future<VoicePublishResultDto> declarePublish({
    required String callId,
    required List<String> trackNames,
    Map<String, dynamic>? video,
  }) => mapMediaErrors('publish', () async {
    final response = await client.dio.post<Map<String, dynamic>>(
      client.url('$_base/calls/$callId/publish'),
      data: {'trackNames': trackNames, 'video': ?video},
      options: _deviceOptions,
    );
    return VoicePublishResultDto.fromJson(response.data ?? const {});
  });

  Future<void> unpublish({
    required String callId,
    required List<String> trackNames,
  }) => mapMediaErrors('unpublish', () async {
    await client.dio.post<void>(
      client.url('$_base/calls/$callId/unpublish'),
      data: {'trackNames': trackNames},
      options: _deviceOptions,
    );
  });

  /// Declares a resolution change made without republishing. Never refuses.
  Future<void> declareVideo({
    required String callId,
    required Map<String, dynamic> video,
  }) => mapMediaErrors('video', () async {
    await client.dio.put<void>(
      client.url('$_base/calls/$callId/video'),
      data: video,
      options: _deviceOptions,
    );
  });

  /// Reports this client's own rendering - tile sizes, pins, collapsed tiles,
  /// backgrounding and share audio. Omitted fields are left alone server-side,
  /// so a tile resize is a body with `tileHeights` in it and nothing else.
  ///
  /// The reply is this client's own subscription set, so a caller can act on
  /// what it just reported without waiting for the push.
  Future<VoiceSubscriptionSetDto?> updateSubscriber({
    required String callId,
    bool? paused,
    Map<String, int>? tileHeights,
    List<String>? pinned,
    List<String>? pausedPublishers,
    List<String>? screenAudioShares,
  }) => mapMediaErrors('subscriptions', () async {
    final response = await client.dio.post<dynamic>(
      client.url('$_base/calls/$callId/subscriptions'),
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

  /// Claims a viewer slot. Watching is announced explicitly because a
  /// subscribe is not a reliable signal - it has no teardown a client is
  /// obliged to send, and a hidden or paused stream stays subscribed. The
  /// claim expires after 90 seconds, so this is re-posted on the heartbeat.
  Future<void> watchShare(String callId, String shareId) async {
    await client.dio.post<void>(
      client.url('$_base/call/$callId/shares/$shareId/watch'),
      options: _deviceOptions,
    );
  }

  Future<void> unwatchShare(String callId, String shareId) async {
    await client.dio.delete<void>(
      client.url('$_base/call/$callId/shares/$shareId/watch'),
      options: _deviceOptions,
    );
  }

  Future<Map<String, List<String>>> shareViewers(String callId) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      client.url('$_base/call/$callId/shares/viewers'),
      options: _deviceOptions,
    );
    return (response.data ?? const {}).map(
      (shareId, viewers) =>
          MapEntry(shareId, (viewers as List? ?? const []).cast<String>()),
    );
  }
}
