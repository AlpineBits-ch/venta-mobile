import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';

part 'voice_state_dto.freezed.dart';
part 'voice_state_dto.g.dart';

/// Where the server currently places this account in guild voice.
///
/// The launch read behind the reconnect banner. A force-quit or crashed client
/// never ran `leave`, and nothing but the server's eviction sweep removes its
/// seat - so the reopened app is still on the roster and everybody else is
/// looking at a ghost until it says otherwise.
///
/// Claims no liveness of its own and does not extend the seat it reports:
/// asking where you are must not be the thing that keeps you there.
@freezed
sealed class VoiceStateDto with _$VoiceStateDto {
  @ApiDateTimeConverter()
  const factory VoiceStateDto({
    required String guildId,
    required String channelId,

    /// Null when the channel was deleted under a roster that has not been
    /// swept yet.
    String? channelName,

    /// The device that took the seat.
    ///
    /// Ours after a relaunch; somebody else's phone or second machine
    /// otherwise, and that difference decides whether the seat may be released
    /// on its behalf - see `VoiceResumeCubit.reconnect`.
    String? deviceId,
    DateTime? joinedAt,
  }) = _VoiceStateDto;

  factory VoiceStateDto.fromJson(Map<String, dynamic> json) =>
      _$VoiceStateDtoFromJson(json);
}
