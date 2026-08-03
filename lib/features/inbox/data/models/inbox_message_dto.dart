import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';

part 'inbox_message_dto.freezed.dart';
part 'inbox_message_dto.g.dart';

/// The inbox's own message-type wire values, which are **ints** where
/// `MessageDto.type`'s are strings (`"Message"`, `"GuildMemberJoin"`, …) - the
/// two shapes come off different services and are not interchangeable, so this
/// is deliberately a separate enum rather than a reuse of [MessageType].
///
/// There is no `System` member: the inbox only ever carries the four below.
enum InboxMessageType {
  @JsonValue(0)
  message,
  @JsonValue(1)
  invite,
  @JsonValue(2)
  guildMemberJoin,
  @JsonValue(3)
  guildMemberLeave,

  /// A value this build has never heard of. Renders as a plain message rather
  /// than as nothing, which is the safe direction for a preview.
  unknown,
}

/// One preview line in the inbox - a deliberately thin projection of a message,
/// not the full [MessageDto]. No reactions, no attachments, no reply target:
/// the inbox shows enough to decide whether to open the channel.
///
/// [content] is base64 bytes, exactly as everywhere else on this API (see
/// `MessageContentCodec`). When [isEncrypted] it is ciphertext and
/// [mlsGeneration] picks the group to open it with - the server holds no keys,
/// so an encrypted channel's previews arrive unreadable and this client is what
/// turns them back into text (`InboxRepository`).
@freezed
sealed class InboxMessageDto with _$InboxMessageDto {
  @ApiDateTimeConverter()
  const factory InboxMessageDto({
    required String id,
    DateTime? createdAt,
    @Default('') String authorId,

    /// Set for webhook and bot authors, whose name doesn't come from a profile
    /// lookup - prefer it over resolving [authorId] when it's present.
    String? authorDisplayName,
    String? authorAvatarUrl,
    @Default('') String content,
    @Default(false) bool isEncrypted,
    int? mlsGeneration,
    @Default(InboxMessageType.message)
    @JsonKey(unknownEnumValue: InboxMessageType.unknown)
    InboxMessageType type,

    /// Picks the wording for [InboxMessageType.guildMemberJoin]/
    /// [InboxMessageType.guildMemberLeave], whose [content] is empty - same
    /// server-assigned index `ThreadView` renders from.
    int? systemMessageVariant,
    String? embedsJson,

    /// Client-only: ciphertext this device holds no keys for. Set by
    /// `InboxRepository`, never sent or received.
    ///
    /// MLS ratchets forward only, so a preview from before this device joined
    /// the group cannot be opened at all. The flag exists so the row can say so
    /// instead of rendering base64.
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(false)
    bool isUndecryptable,
  }) = _InboxMessageDto;

  factory InboxMessageDto.fromJson(Map<String, dynamic> json) =>
      _$InboxMessageDtoFromJson(json);
}

extension InboxMessageDtoX on InboxMessageDto {
  /// Join/leave rows carry no body - the variant index is the whole message.
  bool get isSystemEvent =>
      type == InboxMessageType.guildMemberJoin ||
      type == InboxMessageType.guildMemberLeave;
}
