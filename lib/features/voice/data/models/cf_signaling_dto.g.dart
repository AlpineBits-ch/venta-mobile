// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cf_signaling_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CfTrackResultDto _$CfTrackResultDtoFromJson(Map<String, dynamic> json) =>
    _CfTrackResultDto(
      mid: json['mid'] as String,
      trackName: json['trackName'] as String,
      sessionId: json['sessionId'] as String?,
      location: json['location'] as String?,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$CfTrackResultDtoToJson(_CfTrackResultDto instance) =>
    <String, dynamic>{
      'mid': instance.mid,
      'trackName': instance.trackName,
      'sessionId': instance.sessionId,
      'location': instance.location,
      'error': instance.error,
    };

_CfTracksNewResponseDto _$CfTracksNewResponseDtoFromJson(
  Map<String, dynamic> json,
) => _CfTracksNewResponseDto(
  sessionDescription: json['sessionDescription'] as Map<String, dynamic>,
  tracks:
      (json['tracks'] as List<dynamic>?)
          ?.map((e) => CfTrackResultDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CfTrackResultDto>[],
  requiresImmediateRenegotiation:
      json['requiresImmediateRenegotiation'] as bool? ?? false,
);

Map<String, dynamic> _$CfTracksNewResponseDtoToJson(
  _CfTracksNewResponseDto instance,
) => <String, dynamic>{
  'sessionDescription': instance.sessionDescription,
  'tracks': instance.tracks,
  'requiresImmediateRenegotiation': instance.requiresImmediateRenegotiation,
};

_CfRenegotiateResponseDto _$CfRenegotiateResponseDtoFromJson(
  Map<String, dynamic> json,
) => _CfRenegotiateResponseDto(
  sessionDescription: json['sessionDescription'] as Map<String, dynamic>,
);

Map<String, dynamic> _$CfRenegotiateResponseDtoToJson(
  _CfRenegotiateResponseDto instance,
) => <String, dynamic>{'sessionDescription': instance.sessionDescription};
