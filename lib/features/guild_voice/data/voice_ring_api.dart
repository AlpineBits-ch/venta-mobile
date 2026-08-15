import 'package:dio/dio.dart';

import '../../../core/device/device_id_service.dart';
import '../../../core/network/api_client.dart';
import 'models/voice_ring_dto.dart';

/// The ephemeral "come and join me in here" ring.
///
/// **This is not the DM call ring.** That is a phone call: the caller is on the
/// line waiting, it raises a CallKit screen on iOS and it appears in the system
/// call log. This is an ordinary invitation to somebody who may never look at
/// it, it lives 60 seconds, and it grants nothing.
///
/// **And it is not the persistent invite link with a voice-channel target.**
/// That is a credential - a URL anybody can paste anywhere, which admits a
/// stranger to the guild. This is a message to somebody who is already a member,
/// addressed to them personally. The two share nothing but the word "invite".
///
/// Only the send is channel-scoped. Once a ring exists it is addressed by its
/// own id from a client that may have no idea which channel it belongs to - a
/// phone woken by a push knows a ring id and nothing else - so the rest of the
/// lifecycle is flat.
class VoiceRingApi {
  VoiceRingApi({required this.client, required this.deviceIdService});

  final ApiClient client;
  final DeviceIdService deviceIdService;

  /// The gateway strips its own `/api/v1/guild` and the Guild service's own
  /// routes start with `/api/v1/guilds`, which is why this reads doubled. Same
  /// shape `GuildVoiceApi` already uses for the join these calls hand off to.
  String get _base => client.url('/api/v1/guild/guilds');

  /// Optional here and never fatal - unlike a join, an unknown device only
  /// costs the ability to tell this handset's own answer apart from another's.
  Options get _deviceOptions =>
      Options(headers: {'X-Device-Id': deviceIdService.deviceId});

  /// Asks one member into the voice channel the caller is sitting in.
  ///
  /// Throws [VoiceRingRefusedException] for every refusal the server explains,
  /// so a caller has one thing to catch rather than a status code and a body
  /// shape. Repeating a ring you already have out is **not** a refusal: it is
  /// idempotent and answers `200` with the ring that is already out, so the
  /// button can be naive.
  Future<VoiceRingDto> ring({
    required String guildId,
    required String channelId,
    required String targetUserId,
  }) async {
    try {
      final response = await client.dio.post<Map<String, dynamic>>(
        '$_base/$guildId/channels/$channelId/voice/rings',
        data: {'targetUserId': targetUserId},
        options: _deviceOptions,
      );
      return VoiceRingDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw _refusalFor(e) ?? e;
    }
  }

  /// Every ring currently asking this account in.
  ///
  /// **Call this on every app launch and on every realtime reconnect.**
  /// `guild.VoiceRingIncoming` is a live broadcast that is never replayed and
  /// the push is best-effort; this read is the third leg, and without it a
  /// client that was offline for ten seconds never finds out it was asked.
  ///
  /// Always an array, never a `204`.
  Future<List<VoiceRingDto>> pending() async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/voice/rings/pending',
    );
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(VoiceRingDto.fromJson)
        .toList();
  }

  /// The target says yes.
  ///
  /// **This does not join anybody to anything.** It closes the invitation and
  /// hands back the channel's coordinates; the caller then makes the ordinary
  /// join call. Two calls, in that order, and no second join path.
  Future<VoiceRingDto> accept(String ringId) => _answer(ringId, 'accept');

  /// The target says no.
  ///
  /// **Declining is meaningful, not cosmetic**: it locks that one inviter out of
  /// ringing this account again for 15 minutes, then 2 hours, then 24 hours if
  /// they keep coming back. Letting the card lapse is a different act and
  /// carries none of it, which is why the decline button has to be obviously the
  /// decline button.
  Future<VoiceRingDto> decline(String ringId) => _answer(ringId, 'decline');

  /// The inviter takes it back. `403` if you are not the inviter - the target
  /// has decline, and they are deliberately different acts.
  Future<VoiceRingDto> cancel(String ringId) async {
    try {
      final response = await client.dio.delete<Map<String, dynamic>>(
        '$_base/voice/rings/$ringId',
        options: _deviceOptions,
      );
      return VoiceRingDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw _resolutionConflict(e) ?? e;
    }
  }

  Future<VoiceRingDto> _answer(String ringId, String verb) async {
    try {
      final response = await client.dio.post<Map<String, dynamic>>(
        '$_base/voice/rings/$ringId/$verb',
        data: const {},
        options: _deviceOptions,
      );
      return VoiceRingDto.fromJson(response.data!);
    } on DioException catch (e) {
      // The channel was deleted, stopped being voice, or access was lost while
      // the ring was out. Distinct from a conflict: the ring is closed either
      // way, but there is nowhere to offer a plain Join button to.
      if (e.response?.statusCode == 410) {
        throw const VoiceRingChannelGoneException();
      }
      throw _resolutionConflict(e) ?? e;
    }
  }

  /// A `409` is the normal multi-device outcome, not an error.
  ///
  /// Two of this account's devices both answered and one of them lost. The body
  /// is the resolved ring, which says what actually happened - so this is
  /// carried as a value rather than swallowed, and the caller renders the real
  /// ending and takes the card down.
  VoiceRingAlreadyResolvedException? _resolutionConflict(DioException e) {
    if (e.response?.statusCode != 409) return null;
    final data = e.response?.data;
    if (data is! Map) return null;
    try {
      return VoiceRingAlreadyResolvedException(
        VoiceRingDto.fromJson(data.cast<String, dynamic>()),
      );
    } catch (_) {
      return null;
    }
  }

  VoiceRingRefusedException? _refusalFor(DioException e) {
    final status = e.response?.statusCode;
    if (status != 403 && status != 409 && status != 429) return null;

    final data = e.response?.data;
    // A bare 403 with no body is "you are not in that voice channel", which is
    // a bug in this client rather than something to put on screen - the invite
    // affordance should not have been offered at all.
    if (data is! Map) return null;

    try {
      final refusal = VoiceRingRefusalDto.fromJson(data.cast<String, dynamic>());
      return VoiceRingRefusedException(refusal);
    } catch (_) {
      return null;
    }
  }
}

/// A refusal the server explained. See [VoiceRingRefusalX.message] for the copy.
class VoiceRingRefusedException implements Exception {
  const VoiceRingRefusedException(this.refusal);
  final VoiceRingRefusalDto refusal;

  VoiceRingRefusal get reason => refusal.reason;
  int get retryAfterSeconds => refusal.retryAfterSeconds;
}

/// The ring was already over when this device answered - expired, declined,
/// cancelled, or answered on another of this account's devices.
///
/// **Never surface this as an error.** It is the ordinary outcome of having more
/// than one device, and the ring it carries says what actually happened.
class VoiceRingAlreadyResolvedException implements Exception {
  const VoiceRingAlreadyResolvedException(this.ring);
  final VoiceRingDto ring;
}

/// `410` on accept. Take the card down and do **not** offer a join button:
/// there is nothing there to join.
class VoiceRingChannelGoneException implements Exception {
  const VoiceRingChannelGoneException();
}
