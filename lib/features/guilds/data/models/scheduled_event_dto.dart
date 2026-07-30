import 'package:freezed_annotation/freezed_annotation.dart';

part 'scheduled_event_dto.freezed.dart';
part 'scheduled_event_dto.g.dart';

enum EventStatus {
  @JsonValue('Scheduled')
  scheduled,
  @JsonValue('Active')
  active,
  @JsonValue('Completed')
  completed,
  @JsonValue('Cancelled')
  cancelled,
}

/// A guild scheduled event (Discord's "Events" tab equivalent). No reminder
/// notifications and no automatic `status` transitions in this pass - treat
/// [startsAt]/[endsAt] as the source of truth for "is this happening now"
/// rather than relying on [status] for that, per the backend guide.
@freezed
sealed class ScheduledEventDto with _$ScheduledEventDto {
  const factory ScheduledEventDto({
    required String id,
    required String guildId,
    required String creatorUserId,
    required String title,
    String? description,
    required DateTime startsAt,
    DateTime? endsAt,
    String? location,
    String? voiceChannelId,
    @Default(EventStatus.scheduled) EventStatus status,
    @Default(0) int interestedCount,
    @Default(false) bool isInterested,
  }) = _ScheduledEventDto;

  factory ScheduledEventDto.fromJson(Map<String, dynamic> json) =>
      _$ScheduledEventDtoFromJson(json);
}
