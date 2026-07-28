import 'package:freezed_annotation/freezed_annotation.dart';

part 'guild_voice_dto.freezed.dart';
part 'guild_voice_dto.g.dart';

@freezed
sealed class VoiceParticipantDto with _$VoiceParticipantDto {
  const factory VoiceParticipantDto({
    required String userId,
    required String channelId,
    required String guildId,
    String? cfSessionId,
    String? audioTrackName,
    @Default(false) bool isSelfMuted,
    @Default(false) bool isSelfDeafened,
    @Default(false) bool isServerMuted,
    @Default(false) bool isServerDeafened,
    @Default(false) bool isStreaming,
    String? joinedAt,
  }) = _VoiceParticipantDto;

  factory VoiceParticipantDto.fromJson(Map<String, dynamic> json) =>
      _$VoiceParticipantDtoFromJson(json);
}

@freezed
sealed class VoiceStateDto with _$VoiceStateDto {
  const factory VoiceStateDto({
    required String channelId,
    required String guildId,
    @Default(<VoiceParticipantDto>[]) List<VoiceParticipantDto> participants,
  }) = _VoiceStateDto;

  factory VoiceStateDto.fromJson(Map<String, dynamic> json) => _$VoiceStateDtoFromJson(json);
}
