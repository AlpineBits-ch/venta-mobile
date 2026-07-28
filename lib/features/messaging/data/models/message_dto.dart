import 'package:freezed_annotation/freezed_annotation.dart';

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
    @Default(MessageEncryptionState.plain) MessageEncryptionState encryptionState,
    @Default(MessageType.message) MessageType type,
  }) = _MessageDto;

  factory MessageDto.fromJson(Map<String, dynamic> json) => _$MessageDtoFromJson(json);
}
