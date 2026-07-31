import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';

part 'message_reaction_dto.freezed.dart';
part 'message_reaction_dto.g.dart';

/// One emoji reaction on a message, embedded in `MessageDto.reactions` - the
/// server sends the full list per message. Mirrors Alpine's
/// `MessageReaction` (`dtos/response/message.dto.ts`).
@freezed
sealed class MessageReactionDto with _$MessageReactionDto {
  @ApiDateTimeConverter()
  const factory MessageReactionDto({
    required String messageId,
    required String emoji,
    required String userId,

    /// Set when this reaction used a custom guild emoji - `emoji` still
    /// carries the emoji's name as a text fallback (server-populated), this
    /// is the id to resolve against the guild's emoji list for the actual
    /// image. Null/absent for ordinary Unicode reactions.
    String? emojiId,

    /// `conversationId` or `channelId`, whichever this message belongs to -
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
