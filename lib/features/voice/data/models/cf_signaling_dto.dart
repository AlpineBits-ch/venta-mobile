import 'package:freezed_annotation/freezed_annotation.dart';

part 'cf_signaling_dto.freezed.dart';
part 'cf_signaling_dto.g.dart';

/// `sessionDescription` is kept as a raw `{type, sdp}` map rather than a
/// typed class - it's only ever handed straight to `RTCSessionDescription`
/// by `CallWebRtcService`, the one place that needs the flutter_webrtc type.

/// One entry of Cloudflare's `tracks/new` response.
///
/// [mid] is nullable because Cloudflare omits it on a failed track - it used
/// to be `required String`, so a failure response didn't just lose its error,
/// it blew up deserialization. Never substitute a locally resolved transceiver
/// mid for a missing one: media never arrives on it, and the subscribe looks
/// like it worked.
///
/// [errorCode]/[errorDescription] are Cloudflare's per-track failure fields.
/// The backend proxy now answers a response carrying them with a 502 instead
/// of relaying it as a success, so they should not reach this client - they are
/// declared because the wire contract has them.
@freezed
sealed class CfTrackResultDto with _$CfTrackResultDto {
  const factory CfTrackResultDto({
    String? mid,
    required String trackName,
    String? sessionId,
    String? location,
    String? errorCode,
    String? errorDescription,
  }) = _CfTrackResultDto;

  factory CfTrackResultDto.fromJson(Map<String, dynamic> json) =>
      _$CfTrackResultDtoFromJson(json);
}

@freezed
sealed class CfTracksNewResponseDto with _$CfTracksNewResponseDto {
  const factory CfTracksNewResponseDto({
    required Map<String, dynamic> sessionDescription,
    @Default(<CfTrackResultDto>[]) List<CfTrackResultDto> tracks,
    @Default(false) bool requiresImmediateRenegotiation,
  }) = _CfTracksNewResponseDto;

  factory CfTracksNewResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CfTracksNewResponseDtoFromJson(json);
}

@freezed
sealed class CfRenegotiateResponseDto with _$CfRenegotiateResponseDto {
  const factory CfRenegotiateResponseDto({
    required Map<String, dynamic> sessionDescription,
  }) = _CfRenegotiateResponseDto;

  factory CfRenegotiateResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CfRenegotiateResponseDtoFromJson(json);
}
