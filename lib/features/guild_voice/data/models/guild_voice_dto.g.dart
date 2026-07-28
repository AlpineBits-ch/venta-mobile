// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guild_voice_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VoiceParticipantDto _$VoiceParticipantDtoFromJson(Map<String, dynamic> json) =>
    _VoiceParticipantDto(
      userId: json['userId'] as String,
      channelId: json['channelId'] as String,
      guildId: json['guildId'] as String,
      cfSessionId: json['cfSessionId'] as String?,
      audioTrackName: json['audioTrackName'] as String?,
      isSelfMuted: json['isSelfMuted'] as bool? ?? false,
      isSelfDeafened: json['isSelfDeafened'] as bool? ?? false,
      isServerMuted: json['isServerMuted'] as bool? ?? false,
      isServerDeafened: json['isServerDeafened'] as bool? ?? false,
      isStreaming: json['isStreaming'] as bool? ?? false,
      joinedAt: json['joinedAt'] as String?,
    );

Map<String, dynamic> _$VoiceParticipantDtoToJson(
  _VoiceParticipantDto instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'channelId': instance.channelId,
  'guildId': instance.guildId,
  'cfSessionId': instance.cfSessionId,
  'audioTrackName': instance.audioTrackName,
  'isSelfMuted': instance.isSelfMuted,
  'isSelfDeafened': instance.isSelfDeafened,
  'isServerMuted': instance.isServerMuted,
  'isServerDeafened': instance.isServerDeafened,
  'isStreaming': instance.isStreaming,
  'joinedAt': instance.joinedAt,
};

_VoiceStateDto _$VoiceStateDtoFromJson(Map<String, dynamic> json) =>
    _VoiceStateDto(
      channelId: json['channelId'] as String,
      guildId: json['guildId'] as String,
      participants:
          (json['participants'] as List<dynamic>?)
              ?.map(
                (e) => VoiceParticipantDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <VoiceParticipantDto>[],
    );

Map<String, dynamic> _$VoiceStateDtoToJson(_VoiceStateDto instance) =>
    <String, dynamic>{
      'channelId': instance.channelId,
      'guildId': instance.guildId,
      'participants': instance.participants,
    };
