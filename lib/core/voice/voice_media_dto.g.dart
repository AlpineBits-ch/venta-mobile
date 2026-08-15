// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_media_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VoiceSessionDto _$VoiceSessionDtoFromJson(Map<String, dynamic> json) =>
    _VoiceSessionDto(
      mediaSessionId: json['mediaSessionId'] as String,
      backend: json['backend'] as String? ?? '',
    );

Map<String, dynamic> _$VoiceSessionDtoToJson(_VoiceSessionDto instance) =>
    <String, dynamic>{
      'mediaSessionId': instance.mediaSessionId,
      'backend': instance.backend,
    };

_VoiceTrackResultDto _$VoiceTrackResultDtoFromJson(Map<String, dynamic> json) =>
    _VoiceTrackResultDto(
      mid: json['mid'] as String?,
      trackName: json['trackName'] as String,
      mediaSessionId: json['mediaSessionId'] as String?,
      direction: json['direction'] as String?,
    );

Map<String, dynamic> _$VoiceTrackResultDtoToJson(
  _VoiceTrackResultDto instance,
) => <String, dynamic>{
  'mid': instance.mid,
  'trackName': instance.trackName,
  'mediaSessionId': instance.mediaSessionId,
  'direction': instance.direction,
};

_VoiceNegotiateResponseDto _$VoiceNegotiateResponseDtoFromJson(
  Map<String, dynamic> json,
) => _VoiceNegotiateResponseDto(
  sessionDescription: json['sessionDescription'] as Map<String, dynamic>,
  tracks:
      (json['tracks'] as List<dynamic>?)
          ?.map((e) => VoiceTrackResultDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <VoiceTrackResultDto>[],
  requiresImmediateRenegotiation:
      json['requiresImmediateRenegotiation'] as bool? ?? false,
  degradations:
      (json['degradations'] as List<dynamic>?)
          ?.map(
            (e) =>
                EntitlementDegradationDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <EntitlementDegradationDto>[],
);

Map<String, dynamic> _$VoiceNegotiateResponseDtoToJson(
  _VoiceNegotiateResponseDto instance,
) => <String, dynamic>{
  'sessionDescription': instance.sessionDescription,
  'tracks': instance.tracks,
  'requiresImmediateRenegotiation': instance.requiresImmediateRenegotiation,
  'degradations': instance.degradations,
};

_VoiceRenegotiateResponseDto _$VoiceRenegotiateResponseDtoFromJson(
  Map<String, dynamic> json,
) => _VoiceRenegotiateResponseDto(
  sessionDescription: json['sessionDescription'] as Map<String, dynamic>,
);

Map<String, dynamic> _$VoiceRenegotiateResponseDtoToJson(
  _VoiceRenegotiateResponseDto instance,
) => <String, dynamic>{'sessionDescription': instance.sessionDescription};
