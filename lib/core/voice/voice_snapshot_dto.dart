import 'package:freezed_annotation/freezed_annotation.dart';

import '../format/api_date_time.dart';
import 'track_naming.dart';

part 'voice_snapshot_dto.freezed.dart';
part 'voice_snapshot_dto.g.dart';

/// Room kinds, as the server spells them. These strings are the cache key and
/// the `voice.Heartbeat` argument, so they are wire format, not display text.
class VoiceRoomKind {
  const VoiceRoomKind._();

  static const String channel = 'channel';
  static const String call = 'call';
}

/// Whether a participant's media is actually pullable.
class VoicePublishState {
  const VoicePublishState._();

  /// In the room, but publishing nothing peers can subscribe to yet.
  static const String joined = 'Joined';

  /// Has a session and a microphone track peers can pull.
  static const String publishing = 'Publishing';
}

/// One screen share, and which of its two halves actually exist.
///
/// A share may be video-only, so [trackNames] is read rather than assumed:
/// there is no guarantee a `screen-audio-{shareId}` accompanies every
/// `screen-{shareId}`.
@freezed
sealed class VoiceShareDto with _$VoiceShareDto {
  const factory VoiceShareDto({
    required String shareId,
    @Default(<String>[]) List<String> trackNames,
  }) = _VoiceShareDto;

  const VoiceShareDto._();

  factory VoiceShareDto.fromJson(Map<String, dynamic> json) =>
      _$VoiceShareDtoFromJson(json);

  String? get videoTrackName => trackNames
      .where((n) => TrackNaming.describe(n).kind == TrackKind.screen)
      .firstOrNull;

  String? get audioTrackName => trackNames
      .where((n) => TrackNaming.describe(n).kind == TrackKind.screenAudio)
      .firstOrNull;
}

/// One participant as a client sees them, including what to pull to hear them.
@freezed
sealed class VoiceParticipantSnapshotDto with _$VoiceParticipantSnapshotDto {
  /// [mediaSessionId] and [audioTrackName] are `null` unless [publishState] is
  /// `Publishing`. That is deliberate on the server side and must not be
  /// worked around: a session id alone is not an invitation to subscribe, and
  /// pulling one that has no track behind it burns the per-user dedupe guard
  /// on a subscription that can never carry media.
  @ApiDateTimeConverter()
  const factory VoiceParticipantSnapshotDto({
    required String userId,
    String? mediaSessionId,
    String? audioTrackName,
    @Default(VoicePublishState.joined) String publishState,
    @Default(false) bool isSelfMuted,
    @Default(false) bool isSelfDeafened,
    @Default(false) bool isServerMuted,
    @Default(false) bool isServerDeafened,
    @Default(false) bool isStreaming,
    @Default(<VoiceShareDto>[]) List<VoiceShareDto> shares,
    DateTime? joinedAt,
  }) = _VoiceParticipantSnapshotDto;

  const VoiceParticipantSnapshotDto._();

  factory VoiceParticipantSnapshotDto.fromJson(Map<String, dynamic> json) =>
      _$VoiceParticipantSnapshotDtoFromJson(json);

  /// The only condition under which peers may pull this participant.
  bool get isPublishing =>
      publishState == VoicePublishState.publishing &&
      mediaSessionId != null &&
      audioTrackName != null;

  bool get isMuted => isSelfMuted || isServerMuted;
  bool get isDeafened => isSelfDeafened || isServerDeafened;
}

/// The complete, authoritative state of one voice room - a guild voice channel
/// or a direct call, which are the same system addressed two ways.
///
/// This is sufficient on its own: whatever a client missed, whenever it asks.
/// Snapshots are adopted wholesale, never merged - see
/// `VoiceRoomVersionTracker`.
@freezed
sealed class VoiceRoomSnapshotDto with _$VoiceRoomSnapshotDto {
  const factory VoiceRoomSnapshotDto({
    required String roomId,
    required String kind,

    /// Null for calls, exactly as the server leaves it absent there.
    String? guildId,

    /// Identifies this incarnation of the room. A blank instance is an empty
    /// room the server does not actually have - never adopt it as a baseline.
    @Default('') String instanceId,
    @Default(0) int version,
    @Default(<VoiceParticipantSnapshotDto>[])
    List<VoiceParticipantSnapshotDto> participants,
  }) = _VoiceRoomSnapshotDto;

  const VoiceRoomSnapshotDto._();

  factory VoiceRoomSnapshotDto.fromJson(Map<String, dynamic> json) =>
      _$VoiceRoomSnapshotDtoFromJson(json);

  /// Everyone this client may subscribe to, excluding itself.
  Iterable<VoiceParticipantSnapshotDto> publishersExcept(String userId) =>
      participants.where((p) => p.userId != userId && p.isPublishing);

  VoiceParticipantSnapshotDto? find(String userId) =>
      participants.where((p) => p.userId == userId).firstOrNull;
}
