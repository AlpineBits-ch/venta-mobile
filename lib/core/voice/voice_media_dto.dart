import 'package:freezed_annotation/freezed_annotation.dart';

import '../../features/billing/data/models/entitlement_degradation_dto.dart';
import '../format/api_date_time.dart';

part 'voice_media_dto.freezed.dart';
part 'voice_media_dto.g.dart';

/// Everything needed to open a connection to the SFU, and everything the token
/// actually grants once it is open.
///
/// This replaces the media session the old SDP relay minted. The difference is
/// not cosmetic: there is no server-held session id to go stale any more, so
/// there is nothing to recover *from* - a token that has expired is replaced by
/// asking for another, and asking is cheap and touches nothing.
@freezed
sealed class VoiceConnectionDto with _$VoiceConnectionDto {
  /// [url] is the node this room lives on. There is no shared hostname in front
  /// of the fleet, so this is the routing answer rather than a detail - but it
  /// is also stable for the life of the room, because a room is placed on a
  /// node once and is never moved while it exists. Cache it for a *resume*;
  /// never derive it, and never carry it across a room.
  ///
  /// [identity] is how the SFU names this connection and is the same handle the
  /// roster records as [mediaSessionId]. Both fields carry it so a client can
  /// adopt the new name without changing its snapshot handling on the same day.
  /// It is the bare user id - see [VoiceIdentity].
  ///
  /// [canPublishAudio] and [canPublishVideo] are what the token grants, which
  /// is not the same question as what the UI would like to offer. Render the
  /// microphone and camera controls from these: a member whose plan carries no
  /// video connects, hears everyone, and cannot turn a camera on however the
  /// client is patched.
  @ApiDateTimeConverter()
  const factory VoiceConnectionDto({
    @Default('') String backend,
    required String url,
    required String token,
    @Default('') String room,
    required String identity,
    String? mediaSessionId,
    DateTime? expiresAt,
    @Default(true) bool canPublishAudio,
    @Default(true) bool canPublishVideo,
  }) = _VoiceConnectionDto;

  const VoiceConnectionDto._();

  factory VoiceConnectionDto.fromJson(Map<String, dynamic> json) =>
      _$VoiceConnectionDtoFromJson(json);

  /// The handle to assert on the heartbeat and to match tracks against.
  /// [identity] is authoritative; `mediaSessionId` is the same value under the
  /// older name and is only read if the newer one is somehow absent.
  String get sessionHandle => identity.isNotEmpty
      ? identity
      : (mediaSessionId ?? '');
}

/// The answer to declaring a publish.
///
/// [maxLayer] is the best simulcast layer of *this client's* video that the
/// room will distribute to anybody, in the same vocabulary as `layer` on a
/// subscription set. **Null is the ordinary case** and means nothing caps this
/// publisher - every publish inside its rung, and every publish that declared
/// no size at all.
///
/// A non-null value means more was declared than the plan allows: the track is
/// still up and still flowing, but no viewer is served above that layer however
/// large their tile. Re-encoding to [rung] and declaring it again clears it.
///
/// [degradations] is what a clamped publish looks like: a `200` carrying the
/// normal body plus the reduction applied. **Nothing rolls back on one.** The
/// publish worked, smaller than asked for, and treating the array as a failure
/// would turn "degrade, do not deny" into a denial with extra steps.
@freezed
sealed class VoicePublishResultDto with _$VoicePublishResultDto {
  const factory VoicePublishResultDto({
    @Default('') String identity,
    String? rung,
    int? height,
    int? framerate,
    String? maxLayer,
    @Default(<EntitlementDegradationDto>[])
    List<EntitlementDegradationDto> degradations,
  }) = _VoicePublishResultDto;

  const VoicePublishResultDto._();

  factory VoicePublishResultDto.fromJson(Map<String, dynamic> json) =>
      _$VoicePublishResultDtoFromJson(json);

  /// Whether the room will withhold this client's top layer from everybody.
  bool get isLayerCapped => maxLayer != null;
}
