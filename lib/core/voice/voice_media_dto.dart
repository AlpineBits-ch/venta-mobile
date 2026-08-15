import 'package:freezed_annotation/freezed_annotation.dart';

import '../../features/billing/data/models/entitlement_degradation_dto.dart';

part 'voice_media_dto.freezed.dart';
part 'voice_media_dto.g.dart';

/// `sessionDescription` is kept as a raw `{type, sdp}` map rather than a typed
/// class - it is only ever handed straight to `RTCSessionDescription` by
/// `VoiceWebRtcService`, the one place that needs the flutter_webrtc type.

/// Which way a track flows, from this client's point of view.
///
/// The server's own vocabulary, and deliberately not the SFU's `local`/
/// `remote`: those describe where the media happens to sit rather than what
/// the caller is doing with it.
class VoiceTrackDirection {
  const VoiceTrackDirection._();

  static const String publish = 'publish';
  static const String subscribe = 'subscribe';
}

/// The answer to opening a media session.
///
/// [backend] names the SFU behind it. Nothing else in the voice contract is
/// backend-specific - routes, bodies and responses are all neutral - so this
/// is the one value a client may branch on, and an unrecognised one means
/// "I cannot handle this room" rather than "guess".
@freezed
sealed class VoiceSessionDto with _$VoiceSessionDto {
  const factory VoiceSessionDto({
    required String mediaSessionId,
    @Default('') String backend,
  }) = _VoiceSessionDto;

  factory VoiceSessionDto.fromJson(Map<String, dynamic> json) =>
      _$VoiceSessionDtoFromJson(json);
}

/// One entry of a negotiation response.
///
/// [mid] is nullable because the transport omits it on a track it could not
/// set up. Never substitute a locally resolved transceiver mid for a missing
/// one: media never arrives on it, and the subscribe looks like it worked.
@freezed
sealed class VoiceTrackResultDto with _$VoiceTrackResultDto {
  const factory VoiceTrackResultDto({
    String? mid,
    required String trackName,
    String? mediaSessionId,
    String? direction,
  }) = _VoiceTrackResultDto;

  factory VoiceTrackResultDto.fromJson(Map<String, dynamic> json) =>
      _$VoiceTrackResultDtoFromJson(json);
}

/// The answer to a negotiation, including the case where it succeeded smaller.
///
/// [degradations] is what a clamped publish looks like: a `200` carrying the
/// normal body plus the reduction that was applied. **Nothing here rolls back
/// on one.** The publish worked, at a lower rung than was asked for, and a
/// client that treated the array as a failure would have turned "degrade, do
/// not deny" into a denial with extra steps.
///
/// It is read here as well as by `DegradationInterceptor` because the two do
/// different jobs. The interceptor files every reduction the app sees into the
/// session log, which is what lets Settings account for one later; this hands
/// the same object to the room that caused it, while the person is still
/// looking at the room.
@freezed
sealed class VoiceNegotiateResponseDto with _$VoiceNegotiateResponseDto {
  const factory VoiceNegotiateResponseDto({
    required Map<String, dynamic> sessionDescription,
    @Default(<VoiceTrackResultDto>[]) List<VoiceTrackResultDto> tracks,
    @Default(false) bool requiresImmediateRenegotiation,
    @Default(<EntitlementDegradationDto>[])
    List<EntitlementDegradationDto> degradations,
  }) = _VoiceNegotiateResponseDto;

  factory VoiceNegotiateResponseDto.fromJson(Map<String, dynamic> json) =>
      _$VoiceNegotiateResponseDtoFromJson(json);
}

@freezed
sealed class VoiceRenegotiateResponseDto with _$VoiceRenegotiateResponseDto {
  const factory VoiceRenegotiateResponseDto({
    required Map<String, dynamic> sessionDescription,
  }) = _VoiceRenegotiateResponseDto;

  factory VoiceRenegotiateResponseDto.fromJson(Map<String, dynamic> json) =>
      _$VoiceRenegotiateResponseDtoFromJson(json);
}
