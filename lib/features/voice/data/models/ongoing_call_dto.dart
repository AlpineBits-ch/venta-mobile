import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';

part 'ongoing_call_dto.freezed.dart';
part 'ongoing_call_dto.g.dart';

/// A call already happening in a conversation, as seen by a member who is not
/// in it - the read behind a "join call" affordance.
///
/// Deliberately **not** the call object. It carries no `mediaSessionId` and no
/// `audioTrackName`: those are a live capability over media on a shared SFU,
/// and a member who has not joined has no business holding them. Once joined,
/// they come from the room snapshot.
///
/// It answers for any member of the conversation - including one who declined,
/// one who left, and one who was never invited - none of whom the other signals
/// reach: `call.IncomingCall` is addressed to invitees and never replayed, and
/// `voice/call/pending` answers only for someone currently being rung.
@freezed
sealed class OngoingCallDto with _$OngoingCallDto {
  @ApiDateTimeConverter()
  const factory OngoingCallDto({
    required String callId,
    required String conversationId,

    /// `Pending` while it is still ringing, `Connected` once somebody answered.
    @Default('') String status,
    String? creatorId,
    DateTime? startedAt,

    /// Only the participants actually connected - an invitee still ringing is
    /// not one of them.
    @Default(<String>[]) List<String> connectedUserIds,
  }) = _OngoingCallDto;

  const OngoingCallDto._();

  factory OngoingCallDto.fromJson(Map<String, dynamic> json) =>
      _$OngoingCallDtoFromJson(json);

  bool get isConnected => status == 'Connected';
}
