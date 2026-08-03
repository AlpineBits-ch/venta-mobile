import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';

part 'call_dto.freezed.dart';
part 'call_dto.g.dart';

@freezed
sealed class CallParticipantDto with _$CallParticipantDto {
  /// [cfSessionId]/[audioTrackName] are only set once this participant has
  /// actually published an audio track - used to backfill-subscribe on
  /// connect/reconnect without waiting for a live `call.ParticipantJoined`
  /// event, which can be missed across a SignalR reconnect gap.
  const factory CallParticipantDto({
    required String userId,
    String? cfSessionId,
    String? audioTrackName,
  }) = _CallParticipantDto;

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

  factory CallTrackDto.fromJson(Map<String, dynamic> json) =>
      _$CallTrackDtoFromJson(json);
}

@freezed
sealed class CallDto with _$CallDto {
  /// [status] is the backend's `CallStatus` enum as a string (Pending,
  /// Ringing, Rejected, Connected, Completed) - used to detect a missed
  /// `call.CallEnded` event on reconnect.
  @ApiDateTimeConverter()
  const factory CallDto({
    required String id,
    required String conversationId,

    /// Who placed the call. The one reliable way to name the caller on the
    /// incoming-call UI: picking "the participant that isn't me" off
    /// [participants] is wrong the moment a call has three people in it, and
    /// picks the wrong row entirely on a cold start where this device hasn't
    /// loaded its own user id yet.
    String? creatorId,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(<CallTrackDto>[]) List<CallTrackDto> tracks,
    @Default(<CallParticipantDto>[]) List<CallParticipantDto> participants,
  }) = _CallDto;

  factory CallDto.fromJson(Map<String, dynamic> json) =>
      _$CallDtoFromJson(json);
}
