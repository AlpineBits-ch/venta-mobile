// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_snapshot_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VoiceShareDto _$VoiceShareDtoFromJson(Map<String, dynamic> json) =>
    _VoiceShareDto(
      shareId: json['shareId'] as String,
      trackNames:
          (json['trackNames'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      mediaSessionId: json['mediaSessionId'] as String?,
    );

Map<String, dynamic> _$VoiceShareDtoToJson(_VoiceShareDto instance) =>
    <String, dynamic>{
      'shareId': instance.shareId,
      'trackNames': instance.trackNames,
      'mediaSessionId': instance.mediaSessionId,
    };

_VoiceParticipantSnapshotDto _$VoiceParticipantSnapshotDtoFromJson(
  Map<String, dynamic> json,
) => _VoiceParticipantSnapshotDto(
  userId: json['userId'] as String,
  mediaSessionId: json['mediaSessionId'] as String?,
  audioTrackName: json['audioTrackName'] as String?,
  publishState: json['publishState'] as String? ?? VoicePublishState.joined,
  isSelfMuted: json['isSelfMuted'] as bool? ?? false,
  isSelfDeafened: json['isSelfDeafened'] as bool? ?? false,
  isServerMuted: json['isServerMuted'] as bool? ?? false,
  isServerDeafened: json['isServerDeafened'] as bool? ?? false,
  isStreaming: json['isStreaming'] as bool? ?? false,
  shares:
      (json['shares'] as List<dynamic>?)
          ?.map((e) => VoiceShareDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <VoiceShareDto>[],
  joinedAt: _$JsonConverterFromJson<String, DateTime>(
    json['joinedAt'],
    const ApiDateTimeConverter().fromJson,
  ),
);

Map<String, dynamic> _$VoiceParticipantSnapshotDtoToJson(
  _VoiceParticipantSnapshotDto instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'mediaSessionId': instance.mediaSessionId,
  'audioTrackName': instance.audioTrackName,
  'publishState': instance.publishState,
  'isSelfMuted': instance.isSelfMuted,
  'isSelfDeafened': instance.isSelfDeafened,
  'isServerMuted': instance.isServerMuted,
  'isServerDeafened': instance.isServerDeafened,
  'isStreaming': instance.isStreaming,
  'shares': instance.shares,
  'joinedAt': _$JsonConverterToJson<String, DateTime>(
    instance.joinedAt,
    const ApiDateTimeConverter().toJson,
  ),
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_VoiceRoomSnapshotDto _$VoiceRoomSnapshotDtoFromJson(
  Map<String, dynamic> json,
) => _VoiceRoomSnapshotDto(
  roomId: json['roomId'] as String,
  kind: json['kind'] as String,
  guildId: json['guildId'] as String?,
  instanceId: json['instanceId'] as String? ?? '',
  version: (json['version'] as num?)?.toInt() ?? 0,
  participants:
      (json['participants'] as List<dynamic>?)
          ?.map(
            (e) =>
                VoiceParticipantSnapshotDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <VoiceParticipantSnapshotDto>[],
  limits: voiceRoomLimitsFromJson(json['limits'] as Map<String, dynamic>?),
  subscriptions: voiceSubscriptionSetFromJson(json['subscriptions']),
);

Map<String, dynamic> _$VoiceRoomSnapshotDtoToJson(
  _VoiceRoomSnapshotDto instance,
) => <String, dynamic>{
  'roomId': instance.roomId,
  'kind': instance.kind,
  'guildId': instance.guildId,
  'instanceId': instance.instanceId,
  'version': instance.version,
  'participants': instance.participants,
  'limits': voiceRoomLimitsToJson(instance.limits),
  'subscriptions': voiceSubscriptionSetToJson(instance.subscriptions),
};
