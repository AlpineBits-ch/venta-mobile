// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guild_voice_activity_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GuildVoiceActivityChannelDto _$GuildVoiceActivityChannelDtoFromJson(
  Map<String, dynamic> json,
) => _GuildVoiceActivityChannelDto(
  channelId: json['channelId'] as String,
  participantCount: (json['participantCount'] as num?)?.toInt() ?? 0,
  userIds:
      (json['userIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  hasStream: json['hasStream'] as bool? ?? false,
  streamerIds:
      (json['streamerIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
);

Map<String, dynamic> _$GuildVoiceActivityChannelDtoToJson(
  _GuildVoiceActivityChannelDto instance,
) => <String, dynamic>{
  'channelId': instance.channelId,
  'participantCount': instance.participantCount,
  'userIds': instance.userIds,
  'hasStream': instance.hasStream,
  'streamerIds': instance.streamerIds,
};

_GuildVoiceActivityDto _$GuildVoiceActivityDtoFromJson(
  Map<String, dynamic> json,
) => _GuildVoiceActivityDto(
  guildId: json['guildId'] as String,
  participantCount: (json['participantCount'] as num?)?.toInt() ?? 0,
  hasStream: json['hasStream'] as bool? ?? false,
  channels:
      (json['channels'] as List<dynamic>?)
          ?.map(
            (e) => GuildVoiceActivityChannelDto.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList() ??
      const <GuildVoiceActivityChannelDto>[],
);

Map<String, dynamic> _$GuildVoiceActivityDtoToJson(
  _GuildVoiceActivityDto instance,
) => <String, dynamic>{
  'guildId': instance.guildId,
  'participantCount': instance.participantCount,
  'hasStream': instance.hasStream,
  'channels': instance.channels,
};
