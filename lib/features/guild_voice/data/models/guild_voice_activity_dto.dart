import 'package:freezed_annotation/freezed_annotation.dart';

part 'guild_voice_activity_dto.freezed.dart';
part 'guild_voice_activity_dto.g.dart';

/// Voice occupancy of one channel, as the guild-level index reports it.
@freezed
sealed class GuildVoiceActivityChannelDto with _$GuildVoiceActivityChannelDto {
  const factory GuildVoiceActivityChannelDto({
    required String channelId,
    @Default(0) int participantCount,
    @Default(<String>[]) List<String> userIds,

    /// Whether anyone in this channel is screen sharing.
    @Default(false) bool hasStream,
    @Default(<String>[]) List<String> streamerIds,
  }) = _GuildVoiceActivityChannelDto;

  factory GuildVoiceActivityChannelDto.fromJson(Map<String, dynamic> json) =>
      _$GuildVoiceActivityChannelDtoFromJson(json);
}

/// One guild's voice occupancy. Guilds with nobody in voice are omitted from
/// the response rather than returned empty, so the presence of a row is itself
/// the "something is happening here" signal.
@freezed
sealed class GuildVoiceActivityDto with _$GuildVoiceActivityDto {
  const factory GuildVoiceActivityDto({
    required String guildId,
    @Default(0) int participantCount,
    @Default(false) bool hasStream,
    @Default(<GuildVoiceActivityChannelDto>[])
    List<GuildVoiceActivityChannelDto> channels,
  }) = _GuildVoiceActivityDto;

  factory GuildVoiceActivityDto.fromJson(Map<String, dynamic> json) =>
      _$GuildVoiceActivityDtoFromJson(json);
}
