import 'package:freezed_annotation/freezed_annotation.dart';

import 'attachment_dto.dart';
import 'message_reaction_dto.dart';

part 'message_dto.freezed.dart';
part 'message_dto.g.dart';

enum MessageEncryptionState {
  @JsonValue('Plain')
  plain,
  @JsonValue('Encrypted')
  encrypted,
}

enum MessageType {
  @JsonValue('Message')
  message,
  @JsonValue('System')
  system,
  @JsonValue('Invite')
  invite,
  @JsonValue('GuildMemberJoin')
  guildMemberJoin,
  @JsonValue('GuildMemberLeave')
  guildMemberLeave,
}

/// Mirrors `MemberType` — bots and humans are both just users, distinguished
/// by this field on the message so the bubble can show a "BOT" badge.
enum MessageAuthorType {
  @JsonValue('Default')
  standard,
  @JsonValue('Bot')
  bot,
}

@freezed
sealed class MessageDto with _$MessageDto {
  const factory MessageDto({
    required String id,

    /// Always base64(UTF-8) on the wire, even in Plain mode — see
    /// `MessageContentCodec`, the seam where MLS decrypt gets added later.
    required String content,
    String? conversationId,
    String? channelId,
    required String authorId,
    DateTime? createdAt,
    @Default(false) bool isPending,
    @Default(false) bool isFailed,
    String? inReplyTo,
    @Default(<String>[]) List<String> mentions,
    @Default(<String>[]) List<String> roleMentions,
    @Default(false) bool mentionsEveryone,
    @Default(false) bool mentionsHere,
    @Default(<AttachmentDto>[]) List<AttachmentDto> attachments,
    @Default(<MessageReactionDto>[]) List<MessageReactionDto> reactions,
    @Default(MessageEncryptionState.plain)
    MessageEncryptionState encryptionState,
    @Default(MessageType.message) MessageType type,
    @Default(MessageAuthorType.standard)
    @JsonKey(unknownEnumValue: MessageAuthorType.standard)
    MessageAuthorType authorIdType,

    /// Picks the wording variant for `MessageType.system`/`guildMemberJoin`/
    /// `guildMemberLeave` copy (server-assigned, matches Alpine's flavor-text
    /// rotation) — null/out-of-range falls back to variant 0.
    int? systemMessageVariant,

    /// Client-only: a synthetic placeholder for an in-flight/failed bot
    /// command invocation, never sent or received over the wire — see
    /// `ThreadBotPlaceholderAdded` in `MessageThreadBloc`.
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(false)
    bool isBotCommandPlaceholder,
  }) = _MessageDto;

  factory MessageDto.fromJson(Map<String, dynamic> json) =>
      _$MessageDtoFromJson(json);
}
