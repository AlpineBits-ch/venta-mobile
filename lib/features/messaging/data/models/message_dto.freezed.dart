// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MessageDto {

 String get id;/// Base64 on the wire either way, but of different things: UTF-8 plaintext
/// when [encryptionState] is plain, a TLS-serialized MLS message when it is
/// encrypted. `MessageDecryptor` is what turns the latter into the former;
/// `MessageContentCodec` only ever handles the plaintext side.
 String get content; String? get conversationId; String? get channelId; String get authorId; DateTime? get createdAt; bool get isPending; bool get isFailed; String? get inReplyTo; List<String> get mentions; List<String> get roleMentions; bool get mentionsEveryone; bool get mentionsHere; List<AttachmentDto> get attachments; List<MessageReactionDto> get reactions; MessageEncryptionState get encryptionState; MessageType get type;@JsonKey(unknownEnumValue: MessageAuthorType.standard) MessageAuthorType get authorIdType; bool get isPinned; DateTime? get pinnedAt; String? get pinnedById;/// Picks the wording variant for `MessageType.system`/`guildMemberJoin`/
/// `guildMemberLeave` copy (server-assigned, matches Alpine's flavor-text
/// rotation) - null/out-of-range falls back to variant 0.
 int? get systemMessageVariant;/// Which `MlsGroupGeneration` of the context this was encrypted under. Null
/// on plaintext messages.
///
/// Required to decrypt: encryption can be toggled off and on, and each
/// stretch is a distinct group whose epochs restart at zero, so the epoch
/// alone is ambiguous the moment a context has been toggled twice.
 int? get mlsGeneration;/// Group epoch this was encrypted at.
 int? get mlsEpoch;/// Client device id of the sender. Set on encrypted messages so a device can
/// recognise its own traffic coming back to it.
 String? get senderDeviceId;/// Client-only: a synthetic placeholder for an in-flight/failed bot
/// command invocation, never sent or received over the wire - see
/// `ThreadBotPlaceholderAdded` in `MessageThreadBloc`.
@JsonKey(includeFromJson: false, includeToJson: false) bool get isBotCommandPlaceholder;/// Client-only: this message is ciphertext we hold no keys for.
///
/// MLS ratchets forward and never backward, so a message can be decrypted
/// from the wire exactly once, on a device that was in the group at the
/// time. Anything older than this install - or from a generation it was
/// never admitted to - lands here. The flag exists so the UI can say so
/// plainly instead of rendering base64 at the user.
@JsonKey(includeFromJson: false, includeToJson: false) bool get isUndecryptable;/// Client-only: cleartext, in a context this device holds a live MLS group
/// for.
///
/// `encryptionState` is a plain server field, so flipping it to `Plain` is
/// the whole of what it takes to put server-chosen text into an end-to-end
/// encrypted thread. Not refused - a context that had encryption switched on
/// has genuine cleartext history above the switch, and hiding it would be a
/// bigger lie than showing it - but marked, so the difference between an
/// injection that is invisible and one that is obvious is a line of UI
/// rather than nothing at all.
@JsonKey(includeFromJson: false, includeToJson: false) bool get isUnverifiedPlaintext;
/// Create a copy of MessageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageDtoCopyWith<MessageDto> get copyWith => _$MessageDtoCopyWithImpl<MessageDto>(this as MessageDto, _$identity);

  /// Serializes this MessageDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageDto&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isPending, isPending) || other.isPending == isPending)&&(identical(other.isFailed, isFailed) || other.isFailed == isFailed)&&(identical(other.inReplyTo, inReplyTo) || other.inReplyTo == inReplyTo)&&const DeepCollectionEquality().equals(other.mentions, mentions)&&const DeepCollectionEquality().equals(other.roleMentions, roleMentions)&&(identical(other.mentionsEveryone, mentionsEveryone) || other.mentionsEveryone == mentionsEveryone)&&(identical(other.mentionsHere, mentionsHere) || other.mentionsHere == mentionsHere)&&const DeepCollectionEquality().equals(other.attachments, attachments)&&const DeepCollectionEquality().equals(other.reactions, reactions)&&(identical(other.encryptionState, encryptionState) || other.encryptionState == encryptionState)&&(identical(other.type, type) || other.type == type)&&(identical(other.authorIdType, authorIdType) || other.authorIdType == authorIdType)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.pinnedAt, pinnedAt) || other.pinnedAt == pinnedAt)&&(identical(other.pinnedById, pinnedById) || other.pinnedById == pinnedById)&&(identical(other.systemMessageVariant, systemMessageVariant) || other.systemMessageVariant == systemMessageVariant)&&(identical(other.mlsGeneration, mlsGeneration) || other.mlsGeneration == mlsGeneration)&&(identical(other.mlsEpoch, mlsEpoch) || other.mlsEpoch == mlsEpoch)&&(identical(other.senderDeviceId, senderDeviceId) || other.senderDeviceId == senderDeviceId)&&(identical(other.isBotCommandPlaceholder, isBotCommandPlaceholder) || other.isBotCommandPlaceholder == isBotCommandPlaceholder)&&(identical(other.isUndecryptable, isUndecryptable) || other.isUndecryptable == isUndecryptable)&&(identical(other.isUnverifiedPlaintext, isUnverifiedPlaintext) || other.isUnverifiedPlaintext == isUnverifiedPlaintext));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,content,conversationId,channelId,authorId,createdAt,isPending,isFailed,inReplyTo,const DeepCollectionEquality().hash(mentions),const DeepCollectionEquality().hash(roleMentions),mentionsEveryone,mentionsHere,const DeepCollectionEquality().hash(attachments),const DeepCollectionEquality().hash(reactions),encryptionState,type,authorIdType,isPinned,pinnedAt,pinnedById,systemMessageVariant,mlsGeneration,mlsEpoch,senderDeviceId,isBotCommandPlaceholder,isUndecryptable,isUnverifiedPlaintext]);

@override
String toString() {
  return 'MessageDto(id: $id, content: $content, conversationId: $conversationId, channelId: $channelId, authorId: $authorId, createdAt: $createdAt, isPending: $isPending, isFailed: $isFailed, inReplyTo: $inReplyTo, mentions: $mentions, roleMentions: $roleMentions, mentionsEveryone: $mentionsEveryone, mentionsHere: $mentionsHere, attachments: $attachments, reactions: $reactions, encryptionState: $encryptionState, type: $type, authorIdType: $authorIdType, isPinned: $isPinned, pinnedAt: $pinnedAt, pinnedById: $pinnedById, systemMessageVariant: $systemMessageVariant, mlsGeneration: $mlsGeneration, mlsEpoch: $mlsEpoch, senderDeviceId: $senderDeviceId, isBotCommandPlaceholder: $isBotCommandPlaceholder, isUndecryptable: $isUndecryptable, isUnverifiedPlaintext: $isUnverifiedPlaintext)';
}


}

/// @nodoc
abstract mixin class $MessageDtoCopyWith<$Res>  {
  factory $MessageDtoCopyWith(MessageDto value, $Res Function(MessageDto) _then) = _$MessageDtoCopyWithImpl;
@useResult
$Res call({
 String id, String content, String? conversationId, String? channelId, String authorId, DateTime? createdAt, bool isPending, bool isFailed, String? inReplyTo, List<String> mentions, List<String> roleMentions, bool mentionsEveryone, bool mentionsHere, List<AttachmentDto> attachments, List<MessageReactionDto> reactions, MessageEncryptionState encryptionState, MessageType type,@JsonKey(unknownEnumValue: MessageAuthorType.standard) MessageAuthorType authorIdType, bool isPinned, DateTime? pinnedAt, String? pinnedById, int? systemMessageVariant, int? mlsGeneration, int? mlsEpoch, String? senderDeviceId,@JsonKey(includeFromJson: false, includeToJson: false) bool isBotCommandPlaceholder,@JsonKey(includeFromJson: false, includeToJson: false) bool isUndecryptable,@JsonKey(includeFromJson: false, includeToJson: false) bool isUnverifiedPlaintext
});




}
/// @nodoc
class _$MessageDtoCopyWithImpl<$Res>
    implements $MessageDtoCopyWith<$Res> {
  _$MessageDtoCopyWithImpl(this._self, this._then);

  final MessageDto _self;
  final $Res Function(MessageDto) _then;

/// Create a copy of MessageDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? content = null,Object? conversationId = freezed,Object? channelId = freezed,Object? authorId = null,Object? createdAt = freezed,Object? isPending = null,Object? isFailed = null,Object? inReplyTo = freezed,Object? mentions = null,Object? roleMentions = null,Object? mentionsEveryone = null,Object? mentionsHere = null,Object? attachments = null,Object? reactions = null,Object? encryptionState = null,Object? type = null,Object? authorIdType = null,Object? isPinned = null,Object? pinnedAt = freezed,Object? pinnedById = freezed,Object? systemMessageVariant = freezed,Object? mlsGeneration = freezed,Object? mlsEpoch = freezed,Object? senderDeviceId = freezed,Object? isBotCommandPlaceholder = null,Object? isUndecryptable = null,Object? isUnverifiedPlaintext = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,conversationId: freezed == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String?,channelId: freezed == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String?,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isPending: null == isPending ? _self.isPending : isPending // ignore: cast_nullable_to_non_nullable
as bool,isFailed: null == isFailed ? _self.isFailed : isFailed // ignore: cast_nullable_to_non_nullable
as bool,inReplyTo: freezed == inReplyTo ? _self.inReplyTo : inReplyTo // ignore: cast_nullable_to_non_nullable
as String?,mentions: null == mentions ? _self.mentions : mentions // ignore: cast_nullable_to_non_nullable
as List<String>,roleMentions: null == roleMentions ? _self.roleMentions : roleMentions // ignore: cast_nullable_to_non_nullable
as List<String>,mentionsEveryone: null == mentionsEveryone ? _self.mentionsEveryone : mentionsEveryone // ignore: cast_nullable_to_non_nullable
as bool,mentionsHere: null == mentionsHere ? _self.mentionsHere : mentionsHere // ignore: cast_nullable_to_non_nullable
as bool,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<AttachmentDto>,reactions: null == reactions ? _self.reactions : reactions // ignore: cast_nullable_to_non_nullable
as List<MessageReactionDto>,encryptionState: null == encryptionState ? _self.encryptionState : encryptionState // ignore: cast_nullable_to_non_nullable
as MessageEncryptionState,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MessageType,authorIdType: null == authorIdType ? _self.authorIdType : authorIdType // ignore: cast_nullable_to_non_nullable
as MessageAuthorType,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,pinnedAt: freezed == pinnedAt ? _self.pinnedAt : pinnedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,pinnedById: freezed == pinnedById ? _self.pinnedById : pinnedById // ignore: cast_nullable_to_non_nullable
as String?,systemMessageVariant: freezed == systemMessageVariant ? _self.systemMessageVariant : systemMessageVariant // ignore: cast_nullable_to_non_nullable
as int?,mlsGeneration: freezed == mlsGeneration ? _self.mlsGeneration : mlsGeneration // ignore: cast_nullable_to_non_nullable
as int?,mlsEpoch: freezed == mlsEpoch ? _self.mlsEpoch : mlsEpoch // ignore: cast_nullable_to_non_nullable
as int?,senderDeviceId: freezed == senderDeviceId ? _self.senderDeviceId : senderDeviceId // ignore: cast_nullable_to_non_nullable
as String?,isBotCommandPlaceholder: null == isBotCommandPlaceholder ? _self.isBotCommandPlaceholder : isBotCommandPlaceholder // ignore: cast_nullable_to_non_nullable
as bool,isUndecryptable: null == isUndecryptable ? _self.isUndecryptable : isUndecryptable // ignore: cast_nullable_to_non_nullable
as bool,isUnverifiedPlaintext: null == isUnverifiedPlaintext ? _self.isUnverifiedPlaintext : isUnverifiedPlaintext // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageDto].
extension MessageDtoPatterns on MessageDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageDto value)  $default,){
final _that = this;
switch (_that) {
case _MessageDto():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageDto value)?  $default,){
final _that = this;
switch (_that) {
case _MessageDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String content,  String? conversationId,  String? channelId,  String authorId,  DateTime? createdAt,  bool isPending,  bool isFailed,  String? inReplyTo,  List<String> mentions,  List<String> roleMentions,  bool mentionsEveryone,  bool mentionsHere,  List<AttachmentDto> attachments,  List<MessageReactionDto> reactions,  MessageEncryptionState encryptionState,  MessageType type, @JsonKey(unknownEnumValue: MessageAuthorType.standard)  MessageAuthorType authorIdType,  bool isPinned,  DateTime? pinnedAt,  String? pinnedById,  int? systemMessageVariant,  int? mlsGeneration,  int? mlsEpoch,  String? senderDeviceId, @JsonKey(includeFromJson: false, includeToJson: false)  bool isBotCommandPlaceholder, @JsonKey(includeFromJson: false, includeToJson: false)  bool isUndecryptable, @JsonKey(includeFromJson: false, includeToJson: false)  bool isUnverifiedPlaintext)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageDto() when $default != null:
return $default(_that.id,_that.content,_that.conversationId,_that.channelId,_that.authorId,_that.createdAt,_that.isPending,_that.isFailed,_that.inReplyTo,_that.mentions,_that.roleMentions,_that.mentionsEveryone,_that.mentionsHere,_that.attachments,_that.reactions,_that.encryptionState,_that.type,_that.authorIdType,_that.isPinned,_that.pinnedAt,_that.pinnedById,_that.systemMessageVariant,_that.mlsGeneration,_that.mlsEpoch,_that.senderDeviceId,_that.isBotCommandPlaceholder,_that.isUndecryptable,_that.isUnverifiedPlaintext);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String content,  String? conversationId,  String? channelId,  String authorId,  DateTime? createdAt,  bool isPending,  bool isFailed,  String? inReplyTo,  List<String> mentions,  List<String> roleMentions,  bool mentionsEveryone,  bool mentionsHere,  List<AttachmentDto> attachments,  List<MessageReactionDto> reactions,  MessageEncryptionState encryptionState,  MessageType type, @JsonKey(unknownEnumValue: MessageAuthorType.standard)  MessageAuthorType authorIdType,  bool isPinned,  DateTime? pinnedAt,  String? pinnedById,  int? systemMessageVariant,  int? mlsGeneration,  int? mlsEpoch,  String? senderDeviceId, @JsonKey(includeFromJson: false, includeToJson: false)  bool isBotCommandPlaceholder, @JsonKey(includeFromJson: false, includeToJson: false)  bool isUndecryptable, @JsonKey(includeFromJson: false, includeToJson: false)  bool isUnverifiedPlaintext)  $default,) {final _that = this;
switch (_that) {
case _MessageDto():
return $default(_that.id,_that.content,_that.conversationId,_that.channelId,_that.authorId,_that.createdAt,_that.isPending,_that.isFailed,_that.inReplyTo,_that.mentions,_that.roleMentions,_that.mentionsEveryone,_that.mentionsHere,_that.attachments,_that.reactions,_that.encryptionState,_that.type,_that.authorIdType,_that.isPinned,_that.pinnedAt,_that.pinnedById,_that.systemMessageVariant,_that.mlsGeneration,_that.mlsEpoch,_that.senderDeviceId,_that.isBotCommandPlaceholder,_that.isUndecryptable,_that.isUnverifiedPlaintext);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String content,  String? conversationId,  String? channelId,  String authorId,  DateTime? createdAt,  bool isPending,  bool isFailed,  String? inReplyTo,  List<String> mentions,  List<String> roleMentions,  bool mentionsEveryone,  bool mentionsHere,  List<AttachmentDto> attachments,  List<MessageReactionDto> reactions,  MessageEncryptionState encryptionState,  MessageType type, @JsonKey(unknownEnumValue: MessageAuthorType.standard)  MessageAuthorType authorIdType,  bool isPinned,  DateTime? pinnedAt,  String? pinnedById,  int? systemMessageVariant,  int? mlsGeneration,  int? mlsEpoch,  String? senderDeviceId, @JsonKey(includeFromJson: false, includeToJson: false)  bool isBotCommandPlaceholder, @JsonKey(includeFromJson: false, includeToJson: false)  bool isUndecryptable, @JsonKey(includeFromJson: false, includeToJson: false)  bool isUnverifiedPlaintext)?  $default,) {final _that = this;
switch (_that) {
case _MessageDto() when $default != null:
return $default(_that.id,_that.content,_that.conversationId,_that.channelId,_that.authorId,_that.createdAt,_that.isPending,_that.isFailed,_that.inReplyTo,_that.mentions,_that.roleMentions,_that.mentionsEveryone,_that.mentionsHere,_that.attachments,_that.reactions,_that.encryptionState,_that.type,_that.authorIdType,_that.isPinned,_that.pinnedAt,_that.pinnedById,_that.systemMessageVariant,_that.mlsGeneration,_that.mlsEpoch,_that.senderDeviceId,_that.isBotCommandPlaceholder,_that.isUndecryptable,_that.isUnverifiedPlaintext);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _MessageDto implements MessageDto {
  const _MessageDto({required this.id, required this.content, this.conversationId, this.channelId, required this.authorId, this.createdAt, this.isPending = false, this.isFailed = false, this.inReplyTo, final  List<String> mentions = const <String>[], final  List<String> roleMentions = const <String>[], this.mentionsEveryone = false, this.mentionsHere = false, final  List<AttachmentDto> attachments = const <AttachmentDto>[], final  List<MessageReactionDto> reactions = const <MessageReactionDto>[], this.encryptionState = MessageEncryptionState.plain, this.type = MessageType.message, @JsonKey(unknownEnumValue: MessageAuthorType.standard) this.authorIdType = MessageAuthorType.standard, this.isPinned = false, this.pinnedAt, this.pinnedById, this.systemMessageVariant, this.mlsGeneration, this.mlsEpoch, this.senderDeviceId, @JsonKey(includeFromJson: false, includeToJson: false) this.isBotCommandPlaceholder = false, @JsonKey(includeFromJson: false, includeToJson: false) this.isUndecryptable = false, @JsonKey(includeFromJson: false, includeToJson: false) this.isUnverifiedPlaintext = false}): _mentions = mentions,_roleMentions = roleMentions,_attachments = attachments,_reactions = reactions;
  factory _MessageDto.fromJson(Map<String, dynamic> json) => _$MessageDtoFromJson(json);

@override final  String id;
/// Base64 on the wire either way, but of different things: UTF-8 plaintext
/// when [encryptionState] is plain, a TLS-serialized MLS message when it is
/// encrypted. `MessageDecryptor` is what turns the latter into the former;
/// `MessageContentCodec` only ever handles the plaintext side.
@override final  String content;
@override final  String? conversationId;
@override final  String? channelId;
@override final  String authorId;
@override final  DateTime? createdAt;
@override@JsonKey() final  bool isPending;
@override@JsonKey() final  bool isFailed;
@override final  String? inReplyTo;
 final  List<String> _mentions;
@override@JsonKey() List<String> get mentions {
  if (_mentions is EqualUnmodifiableListView) return _mentions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mentions);
}

 final  List<String> _roleMentions;
@override@JsonKey() List<String> get roleMentions {
  if (_roleMentions is EqualUnmodifiableListView) return _roleMentions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roleMentions);
}

@override@JsonKey() final  bool mentionsEveryone;
@override@JsonKey() final  bool mentionsHere;
 final  List<AttachmentDto> _attachments;
@override@JsonKey() List<AttachmentDto> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}

 final  List<MessageReactionDto> _reactions;
@override@JsonKey() List<MessageReactionDto> get reactions {
  if (_reactions is EqualUnmodifiableListView) return _reactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reactions);
}

@override@JsonKey() final  MessageEncryptionState encryptionState;
@override@JsonKey() final  MessageType type;
@override@JsonKey(unknownEnumValue: MessageAuthorType.standard) final  MessageAuthorType authorIdType;
@override@JsonKey() final  bool isPinned;
@override final  DateTime? pinnedAt;
@override final  String? pinnedById;
/// Picks the wording variant for `MessageType.system`/`guildMemberJoin`/
/// `guildMemberLeave` copy (server-assigned, matches Alpine's flavor-text
/// rotation) - null/out-of-range falls back to variant 0.
@override final  int? systemMessageVariant;
/// Which `MlsGroupGeneration` of the context this was encrypted under. Null
/// on plaintext messages.
///
/// Required to decrypt: encryption can be toggled off and on, and each
/// stretch is a distinct group whose epochs restart at zero, so the epoch
/// alone is ambiguous the moment a context has been toggled twice.
@override final  int? mlsGeneration;
/// Group epoch this was encrypted at.
@override final  int? mlsEpoch;
/// Client device id of the sender. Set on encrypted messages so a device can
/// recognise its own traffic coming back to it.
@override final  String? senderDeviceId;
/// Client-only: a synthetic placeholder for an in-flight/failed bot
/// command invocation, never sent or received over the wire - see
/// `ThreadBotPlaceholderAdded` in `MessageThreadBloc`.
@override@JsonKey(includeFromJson: false, includeToJson: false) final  bool isBotCommandPlaceholder;
/// Client-only: this message is ciphertext we hold no keys for.
///
/// MLS ratchets forward and never backward, so a message can be decrypted
/// from the wire exactly once, on a device that was in the group at the
/// time. Anything older than this install - or from a generation it was
/// never admitted to - lands here. The flag exists so the UI can say so
/// plainly instead of rendering base64 at the user.
@override@JsonKey(includeFromJson: false, includeToJson: false) final  bool isUndecryptable;
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
@override@JsonKey(includeFromJson: false, includeToJson: false) final  bool isUnverifiedPlaintext;

/// Create a copy of MessageDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageDtoCopyWith<_MessageDto> get copyWith => __$MessageDtoCopyWithImpl<_MessageDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageDto&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isPending, isPending) || other.isPending == isPending)&&(identical(other.isFailed, isFailed) || other.isFailed == isFailed)&&(identical(other.inReplyTo, inReplyTo) || other.inReplyTo == inReplyTo)&&const DeepCollectionEquality().equals(other._mentions, _mentions)&&const DeepCollectionEquality().equals(other._roleMentions, _roleMentions)&&(identical(other.mentionsEveryone, mentionsEveryone) || other.mentionsEveryone == mentionsEveryone)&&(identical(other.mentionsHere, mentionsHere) || other.mentionsHere == mentionsHere)&&const DeepCollectionEquality().equals(other._attachments, _attachments)&&const DeepCollectionEquality().equals(other._reactions, _reactions)&&(identical(other.encryptionState, encryptionState) || other.encryptionState == encryptionState)&&(identical(other.type, type) || other.type == type)&&(identical(other.authorIdType, authorIdType) || other.authorIdType == authorIdType)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.pinnedAt, pinnedAt) || other.pinnedAt == pinnedAt)&&(identical(other.pinnedById, pinnedById) || other.pinnedById == pinnedById)&&(identical(other.systemMessageVariant, systemMessageVariant) || other.systemMessageVariant == systemMessageVariant)&&(identical(other.mlsGeneration, mlsGeneration) || other.mlsGeneration == mlsGeneration)&&(identical(other.mlsEpoch, mlsEpoch) || other.mlsEpoch == mlsEpoch)&&(identical(other.senderDeviceId, senderDeviceId) || other.senderDeviceId == senderDeviceId)&&(identical(other.isBotCommandPlaceholder, isBotCommandPlaceholder) || other.isBotCommandPlaceholder == isBotCommandPlaceholder)&&(identical(other.isUndecryptable, isUndecryptable) || other.isUndecryptable == isUndecryptable)&&(identical(other.isUnverifiedPlaintext, isUnverifiedPlaintext) || other.isUnverifiedPlaintext == isUnverifiedPlaintext));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,content,conversationId,channelId,authorId,createdAt,isPending,isFailed,inReplyTo,const DeepCollectionEquality().hash(_mentions),const DeepCollectionEquality().hash(_roleMentions),mentionsEveryone,mentionsHere,const DeepCollectionEquality().hash(_attachments),const DeepCollectionEquality().hash(_reactions),encryptionState,type,authorIdType,isPinned,pinnedAt,pinnedById,systemMessageVariant,mlsGeneration,mlsEpoch,senderDeviceId,isBotCommandPlaceholder,isUndecryptable,isUnverifiedPlaintext]);

@override
String toString() {
  return 'MessageDto(id: $id, content: $content, conversationId: $conversationId, channelId: $channelId, authorId: $authorId, createdAt: $createdAt, isPending: $isPending, isFailed: $isFailed, inReplyTo: $inReplyTo, mentions: $mentions, roleMentions: $roleMentions, mentionsEveryone: $mentionsEveryone, mentionsHere: $mentionsHere, attachments: $attachments, reactions: $reactions, encryptionState: $encryptionState, type: $type, authorIdType: $authorIdType, isPinned: $isPinned, pinnedAt: $pinnedAt, pinnedById: $pinnedById, systemMessageVariant: $systemMessageVariant, mlsGeneration: $mlsGeneration, mlsEpoch: $mlsEpoch, senderDeviceId: $senderDeviceId, isBotCommandPlaceholder: $isBotCommandPlaceholder, isUndecryptable: $isUndecryptable, isUnverifiedPlaintext: $isUnverifiedPlaintext)';
}


}

/// @nodoc
abstract mixin class _$MessageDtoCopyWith<$Res> implements $MessageDtoCopyWith<$Res> {
  factory _$MessageDtoCopyWith(_MessageDto value, $Res Function(_MessageDto) _then) = __$MessageDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String content, String? conversationId, String? channelId, String authorId, DateTime? createdAt, bool isPending, bool isFailed, String? inReplyTo, List<String> mentions, List<String> roleMentions, bool mentionsEveryone, bool mentionsHere, List<AttachmentDto> attachments, List<MessageReactionDto> reactions, MessageEncryptionState encryptionState, MessageType type,@JsonKey(unknownEnumValue: MessageAuthorType.standard) MessageAuthorType authorIdType, bool isPinned, DateTime? pinnedAt, String? pinnedById, int? systemMessageVariant, int? mlsGeneration, int? mlsEpoch, String? senderDeviceId,@JsonKey(includeFromJson: false, includeToJson: false) bool isBotCommandPlaceholder,@JsonKey(includeFromJson: false, includeToJson: false) bool isUndecryptable,@JsonKey(includeFromJson: false, includeToJson: false) bool isUnverifiedPlaintext
});




}
/// @nodoc
class __$MessageDtoCopyWithImpl<$Res>
    implements _$MessageDtoCopyWith<$Res> {
  __$MessageDtoCopyWithImpl(this._self, this._then);

  final _MessageDto _self;
  final $Res Function(_MessageDto) _then;

/// Create a copy of MessageDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? content = null,Object? conversationId = freezed,Object? channelId = freezed,Object? authorId = null,Object? createdAt = freezed,Object? isPending = null,Object? isFailed = null,Object? inReplyTo = freezed,Object? mentions = null,Object? roleMentions = null,Object? mentionsEveryone = null,Object? mentionsHere = null,Object? attachments = null,Object? reactions = null,Object? encryptionState = null,Object? type = null,Object? authorIdType = null,Object? isPinned = null,Object? pinnedAt = freezed,Object? pinnedById = freezed,Object? systemMessageVariant = freezed,Object? mlsGeneration = freezed,Object? mlsEpoch = freezed,Object? senderDeviceId = freezed,Object? isBotCommandPlaceholder = null,Object? isUndecryptable = null,Object? isUnverifiedPlaintext = null,}) {
  return _then(_MessageDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,conversationId: freezed == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String?,channelId: freezed == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String?,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isPending: null == isPending ? _self.isPending : isPending // ignore: cast_nullable_to_non_nullable
as bool,isFailed: null == isFailed ? _self.isFailed : isFailed // ignore: cast_nullable_to_non_nullable
as bool,inReplyTo: freezed == inReplyTo ? _self.inReplyTo : inReplyTo // ignore: cast_nullable_to_non_nullable
as String?,mentions: null == mentions ? _self._mentions : mentions // ignore: cast_nullable_to_non_nullable
as List<String>,roleMentions: null == roleMentions ? _self._roleMentions : roleMentions // ignore: cast_nullable_to_non_nullable
as List<String>,mentionsEveryone: null == mentionsEveryone ? _self.mentionsEveryone : mentionsEveryone // ignore: cast_nullable_to_non_nullable
as bool,mentionsHere: null == mentionsHere ? _self.mentionsHere : mentionsHere // ignore: cast_nullable_to_non_nullable
as bool,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<AttachmentDto>,reactions: null == reactions ? _self._reactions : reactions // ignore: cast_nullable_to_non_nullable
as List<MessageReactionDto>,encryptionState: null == encryptionState ? _self.encryptionState : encryptionState // ignore: cast_nullable_to_non_nullable
as MessageEncryptionState,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MessageType,authorIdType: null == authorIdType ? _self.authorIdType : authorIdType // ignore: cast_nullable_to_non_nullable
as MessageAuthorType,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,pinnedAt: freezed == pinnedAt ? _self.pinnedAt : pinnedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,pinnedById: freezed == pinnedById ? _self.pinnedById : pinnedById // ignore: cast_nullable_to_non_nullable
as String?,systemMessageVariant: freezed == systemMessageVariant ? _self.systemMessageVariant : systemMessageVariant // ignore: cast_nullable_to_non_nullable
as int?,mlsGeneration: freezed == mlsGeneration ? _self.mlsGeneration : mlsGeneration // ignore: cast_nullable_to_non_nullable
as int?,mlsEpoch: freezed == mlsEpoch ? _self.mlsEpoch : mlsEpoch // ignore: cast_nullable_to_non_nullable
as int?,senderDeviceId: freezed == senderDeviceId ? _self.senderDeviceId : senderDeviceId // ignore: cast_nullable_to_non_nullable
as String?,isBotCommandPlaceholder: null == isBotCommandPlaceholder ? _self.isBotCommandPlaceholder : isBotCommandPlaceholder // ignore: cast_nullable_to_non_nullable
as bool,isUndecryptable: null == isUndecryptable ? _self.isUndecryptable : isUndecryptable // ignore: cast_nullable_to_non_nullable
as bool,isUnverifiedPlaintext: null == isUnverifiedPlaintext ? _self.isUnverifiedPlaintext : isUnverifiedPlaintext // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
