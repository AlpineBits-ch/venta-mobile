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

  /// Somebody asked you into a voice channel - the durable half of a voice
  /// ring, written by the server into the 1:1 conversation between the two.
  ///
  /// **Not a system row, deliberately.** Unlike a join notice or a call entry,
  /// this is addressed by one person to another and carries a card you can act
  /// on, so it renders as an ordinary message from the inviter rather than as
  /// centred grey copy - which also means the reply they send a moment later
  /// groups under it, exactly as it should. See [MessageTypeX.isSystemRow],
  /// which leaves this out on purpose.
  ///
  /// Everything renderable is in the message's single `venta.voice_invite`
  /// embed ([EmbedType.ventaVoiceInvite]). [MessageDto.content] is a
  /// plain-English fallback for consumers that do not understand this type, and
  /// the timeline suppresses it so it is not shown twice - see
  /// [MessageDtoX.isVoiceChannelInvite].
  @JsonValue('VoiceChannelInvite')
  voiceChannelInvite,

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

    /// Client-only: a bot reply only this user was sent, which the server never
    /// stored (`guild.EphemeralMessageCreated`).
    ///
    /// It lives in the open thread's in-memory list and nowhere else - a reload
    /// loses it, which is the whole point, and it is deliberately not counted
    /// towards the pagination offset either, since that offset is a cursor into
    /// server-side history and shifting it by a message history does not
    /// contain would make the next page skip a real one.
    ///
    /// **Nothing may offer edit, delete, pin or reply on it**: there is no
    /// server-side row for any of those to act on, and every one of them would
    /// 404. It is also not a candidate for the read marker, for the same
    /// reason - `MessageThreadBloc` skips it there.
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(false)
    bool isEphemeral,

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

extension MessageTypeX on MessageType {
  /// Whether a message of this type renders as centred grey copy rather than as
  /// an authored message.
  ///
  /// Also what stops the next real message being grouped under it: grouping
  /// keys on the author, and a call entry is authored by whoever placed the
  /// call - so without this the caller's next message would fold into the call
  /// notice and lose its avatar and timestamp.
  ///
  /// **[MessageType.voiceChannelInvite] is deliberately absent.** It is a
  /// server-written message like the others, but it is not one to *read* like
  /// them: the rest are a record of something that already happened, whereas
  /// this is one person asking another something, with a card they can answer.
  bool get isSystemRow =>
      this == MessageType.system ||
      this == MessageType.guildMemberJoin ||
      this == MessageType.guildMemberLeave ||
      this == MessageType.callEnded ||
      this == MessageType.callMissed;
}

extension MessageDtoX on MessageDto {
  /// Memoised - safe to call from `build`.
  List<EmbedDto> get embeds => parseEmbedsJson(embedsJson);

  /// See [MessageTypeX.isSystemRow].
  bool get isSystemRow => type.isSystemRow;

  /// An invitation into a voice channel, whose whole readable content is its
  /// `venta.voice_invite` card.
  ///
  /// The timeline draws this as an ordinary message from the inviter - avatar,
  /// name, timestamp, groupable - and **suppresses [MessageDto.content]**,
  /// which is only a plain-English fallback for a client that does not know the
  /// type and would otherwise be shown above the card saying the same thing.
  bool get isVoiceChannelInvite => type == MessageType.voiceChannelInvite;

  /// Somebody dismissed this message's previews, for everybody. Distinct from
  /// "there never were any", which is what tells the action sheet whether to
  /// offer "Remove preview" or "Restore preview".
  bool get hasSuppressedEmbeds => (flags & _suppressEmbeds) != 0;

  /// The author changed the text. Never [MessageDto.updatedAt] - see its doc.
  bool get isEdited => editedAt != null;
}

const _suppressEmbeds = 1 << 2;
