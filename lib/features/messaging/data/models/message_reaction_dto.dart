import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_reaction_dto.freezed.dart';
part 'message_reaction_dto.g.dart';

/// One emoji reaction on a message, embedded in `MessageDto.reactions` — the
/// server sends the full list per message. Mirrors Alpine's
/// `MessageReaction` (`dtos/response/message.dto.ts`).
@freezed
sealed class MessageReactionDto with _$MessageReactionDto {
  const factory MessageReactionDto({
    required String messageId,
    required String emoji,
    required String userId,

    /// `conversationId` or `channelId`, whichever this message belongs to —
    /// present on the wire but unused client-side (the message it's
    /// attached to already carries that context).
    String? contextId,
    DateTime? createdAt,
    String? conversationId,
    String? channelId,
  }) = _MessageReactionDto;

  factory MessageReactionDto.fromJson(Map<String, dynamic> json) =>
      _$MessageReactionDtoFromJson(json);
}
