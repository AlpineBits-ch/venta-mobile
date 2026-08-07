import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';

import 'attachment_dto.dart';
import 'embed_dto.dart';
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

  /// A call somebody answered. [MessageDto.content] is the duration in whole
  /// seconds as plain text, e.g. `"184"`; the author is whoever placed it.
  @JsonValue('CallEnded')
  callEnded,

  /// A call that ended with nobody but the caller ever connecting - a ring
  /// timeout, a decline, or an unanswered cancel. Content is empty, and the
  /// author being the caller is what lets "you missed a call from X" render
  /// without a second lookup.
  @JsonValue('CallMissed')
  callMissed,

  /// A type this build has never heard of.
  ///
  /// Not decoration: without it, one unrecognised value throws out of
  /// `fromJson` and takes the *whole message list* with it, so a server that
  /// adds a type turns every channel blank. That is exactly how the call
  /// history types above would have landed.
  unknown,
}

/// Mirrors `MemberType` - bots and humans are both just users, distinguished
/// by this field on the message so the bubble can show a "BOT" badge.
enum MessageAuthorType {
  @JsonValue('Default')
  standard,
  @JsonValue('Bot')
  bot,
}

@freezed
sealed class MessageDto with _$MessageDto {
  @ApiDateTimeConverter()
  const factory MessageDto({
    required String id,

    /// Base64 on the wire either way, but of different things: UTF-8 plaintext
    /// when [encryptionState] is plain, a TLS-serialized MLS message when it is
    /// encrypted. `MessageDecryptor` is what turns the latter into the former;
    /// `MessageContentCodec` only ever handles the plaintext side.
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
    @Default(MessageType.message)
    @JsonKey(unknownEnumValue: MessageType.unknown)
    MessageType type,
    @Default(MessageAuthorType.standard)
    @JsonKey(unknownEnumValue: MessageAuthorType.standard)
    MessageAuthorType authorIdType,
    @Default(false) bool isPinned,
    DateTime? pinnedAt,
    String? pinnedById,

    /// Bot-authored cards and server-generated link previews, as a
    /// JSON-encoded **string** rather than a nested object - read it through
    /// `parseEmbedsJson` (or the [embeds] getter), never `jsonDecode` inline.
    ///
    /// Arrives null on a message containing a link and fills in seconds later
    /// via `MessageUpdated`, once the server has fetched the page. Never hold a
    /// message back waiting for it: the site may be down, the link may 404, or
    /// the instance may have previews switched off, and none of those produce a
    /// signal to stop waiting on.
    String? embedsJson,

    /// Discord-compatible message bitfield. Bit 2 (`4`) is
    /// suppressed-embeds - see [hasSuppressedEmbeds].
    @Default(0) int flags,

    /// When the **author** last changed the text, and the only thing that may
    /// drive an "(edited)" marker. Null when never edited.
    DateTime? editedAt,

    /// When the row was last written *by anyone or anything* - including a
    /// preview attaching or a pin landing. Deliberately not the edit marker:
    /// driving it off this labels every message containing a link as edited a
    /// second after it was posted, by nobody.
    DateTime? updatedAt,

    /// Picks the wording variant for `MessageType.system`/`guildMemberJoin`/
    /// `guildMemberLeave` copy (server-assigned, matches Alpine's flavor-text
    /// rotation) - null/out-of-range falls back to variant 0.
    int? systemMessageVariant,

    /// Which `MlsGroupGeneration` of the context this was encrypted under. Null
    /// on plaintext messages.
    ///
    /// Required to decrypt: encryption can be toggled off and on, and each
    /// stretch is a distinct group whose epochs restart at zero, so the epoch
    /// alone is ambiguous the moment a context has been toggled twice.
    int? mlsGeneration,

    /// Group epoch this was encrypted at.
    int? mlsEpoch,

    /// Client device id of the sender. Set on encrypted messages so a device can
    /// recognise its own traffic coming back to it.
    String? senderDeviceId,

    /// Client-only: a synthetic placeholder for an in-flight/failed bot
    /// command invocation, never sent or received over the wire - see
    /// `ThreadBotPlaceholderAdded` in `MessageThreadBloc`.
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(false)
    bool isBotCommandPlaceholder,

    /// Client-only: this message is ciphertext we hold no keys for.
    ///
    /// MLS ratchets forward and never backward, so a message can be decrypted
    /// from the wire exactly once, on a device that was in the group at the
    /// time. Anything older than this install - or from a generation it was
    /// never admitted to - lands here. The flag exists so the UI can say so
    /// plainly instead of rendering base64 at the user.
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(false)
    bool isUndecryptable,

    /// Client-only: cleartext, in a context this device holds a live MLS group
    /// for.
    ///
    /// `encryptionState` is a plain server field, so flipping it to `Plain` is
    /// the whole of what it takes to put server-chosen text into an end-to-end
    /// encrypted thread. Not refused - a context that had encryption switched on
    /// has genuine cleartext history above the switch, and hiding it would be a
    /// bigger lie than showing it - but marked, so the difference between an
    /// injection that is invisible and one that is obvious is a line of UI
    /// rather than nothing at all.
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(false)
    bool isUnverifiedPlaintext,
  }) = _MessageDto;

  factory MessageDto.fromJson(Map<String, dynamic> json) =>
      _$MessageDtoFromJson(json);
}

extension MessageDtoX on MessageDto {
  /// Memoised - safe to call from `build`.
  List<EmbedDto> get embeds => parseEmbedsJson(embedsJson);

  /// Somebody dismissed this message's previews, for everybody. Distinct from
  /// "there never were any", which is what tells the action sheet whether to
  /// offer "Remove preview" or "Restore preview".
  bool get hasSuppressedEmbeds => (flags & _suppressEmbeds) != 0;

  /// The author changed the text. Never [MessageDto.updatedAt] - see its doc.
  bool get isEdited => editedAt != null;
}

const _suppressEmbeds = 1 << 2;
