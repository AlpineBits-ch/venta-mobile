// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_subscription_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VoiceSubscriptionTrackDto _$VoiceSubscriptionTrackDtoFromJson(
  Map<String, dynamic> json,
) => _VoiceSubscriptionTrackDto(
  userId: json['userId'] as String,
  mediaSessionId: json['mediaSessionId'] as String?,
  trackName: json['trackName'] as String,
  kind: json['kind'] as String? ?? 'video',
  shareId: json['shareId'] as String?,
  layer: json['layer'] as String?,
);

Map<String, dynamic> _$VoiceSubscriptionTrackDtoToJson(
  _VoiceSubscriptionTrackDto instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'mediaSessionId': instance.mediaSessionId,
  'trackName': instance.trackName,
  'kind': instance.kind,
  'shareId': instance.shareId,
  'layer': instance.layer,
};

_VoiceSubscriptionSetDto _$VoiceSubscriptionSetDtoFromJson(
  Map<String, dynamic> json,
) => _VoiceSubscriptionSetDto(
  mode: json['mode'] as String? ?? VoiceSubscriptionMode.all,
  revision: (json['revision'] as num?)?.toInt() ?? 0,
  activeSpeakers:
      (json['activeSpeakers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  tracks: (json['tracks'] as List<dynamic>?)
      ?.map(
        (e) => VoiceSubscriptionTrackDto.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
);

Map<String, dynamic> _$VoiceSubscriptionSetDtoToJson(
  _VoiceSubscriptionSetDto instance,
) => <String, dynamic>{
  'mode': instance.mode,
  'revision': instance.revision,
  'activeSpeakers': instance.activeSpeakers,
  'tracks': instance.tracks,
};
