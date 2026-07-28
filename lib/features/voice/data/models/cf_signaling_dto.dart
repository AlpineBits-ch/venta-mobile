import 'package:freezed_annotation/freezed_annotation.dart';

part 'cf_signaling_dto.freezed.dart';
part 'cf_signaling_dto.g.dart';

/// `sessionDescription` is kept as a raw `{type, sdp}` map rather than a
/// typed class — it's only ever handed straight to `RTCSessionDescription`
/// by `CallWebRtcService`, the one place that needs the flutter_webrtc type.

@freezed
sealed class CfTrackResultDto with _$CfTrackResultDto {
  const factory CfTrackResultDto({
    required String mid,
    required String trackName,
    String? sessionId,
    String? location,
    String? error,
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
