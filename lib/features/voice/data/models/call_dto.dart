import 'package:freezed_annotation/freezed_annotation.dart';

part 'call_dto.freezed.dart';
part 'call_dto.g.dart';

@freezed
sealed class CallParticipantDto with _$CallParticipantDto {
  const factory CallParticipantDto({required String userId}) = _CallParticipantDto;

  factory CallParticipantDto.fromJson(Map<String, dynamic> json) =>
      _$CallParticipantDtoFromJson(json);
}

@freezed
sealed class CallTrackDto with _$CallTrackDto {
  const factory CallTrackDto({
    required String trackId,
    required String userId,
    required String status,
  }) = _CallTrackDto;

  factory CallTrackDto.fromJson(Map<String, dynamic> json) => _$CallTrackDtoFromJson(json);
}

@freezed
sealed class CallDto with _$CallDto {
  const factory CallDto({
    required String id,
    required String conversationId,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(<CallTrackDto>[]) List<CallTrackDto> tracks,
    @Default(<CallParticipantDto>[]) List<CallParticipantDto> participants,
  }) = _CallDto;

  factory CallDto.fromJson(Map<String, dynamic> json) => _$CallDtoFromJson(json);
}
