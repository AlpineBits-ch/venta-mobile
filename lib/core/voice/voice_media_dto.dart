import 'package:freezed_annotation/freezed_annotation.dart';

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

@freezed
sealed class VoiceNegotiateResponseDto with _$VoiceNegotiateResponseDto {
  const factory VoiceNegotiateResponseDto({
    required Map<String, dynamic> sessionDescription,
    @Default(<VoiceTrackResultDto>[]) List<VoiceTrackResultDto> tracks,
    @Default(false) bool requiresImmediateRenegotiation,
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
