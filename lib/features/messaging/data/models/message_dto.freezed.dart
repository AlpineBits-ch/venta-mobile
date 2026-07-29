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

 String get id;/// Always base64(UTF-8) on the wire, even in Plain mode — see
/// `MessageContentCodec`, the seam where MLS decrypt gets added later.
 String get content; String? get conversationId; String? get channelId; String get authorId; DateTime? get createdAt; bool get isPending; bool get isFailed; String? get inReplyTo; List<String> get mentions; List<AttachmentDto> get attachments; List<MessageReactionDto> get reactions; MessageEncryptionState get encryptionState; MessageType get type;@JsonKey(unknownEnumValue: MessageAuthorType.standard) MessageAuthorType get authorIdType;/// Client-only: a synthetic placeholder for an in-flight/failed bot
/// command invocation, never sent or received over the wire — see
/// `ThreadBotPlaceholderAdded` in `MessageThreadBloc`.
@JsonKey(includeFromJson: false, includeToJson: false) bool get isBotCommandPlaceholder;
/// Create a copy of MessageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageDtoCopyWith<MessageDto> get copyWith => _$MessageDtoCopyWithImpl<MessageDto>(this as MessageDto, _$identity);

  /// Serializes this MessageDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageDto&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isPending, isPending) || other.isPending == isPending)&&(identical(other.isFailed, isFailed) || other.isFailed == isFailed)&&(identical(other.inReplyTo, inReplyTo) || other.inReplyTo == inReplyTo)&&const DeepCollectionEquality().equals(other.mentions, mentions)&&const DeepCollectionEquality().equals(other.attachments, attachments)&&const DeepCollectionEquality().equals(other.reactions, reactions)&&(identical(other.encryptionState, encryptionState) || other.encryptionState == encryptionState)&&(identical(other.type, type) || other.type == type)&&(identical(other.authorIdType, authorIdType) || other.authorIdType == authorIdType)&&(identical(other.isBotCommandPlaceholder, isBotCommandPlaceholder) || other.isBotCommandPlaceholder == isBotCommandPlaceholder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,content,conversationId,channelId,authorId,createdAt,isPending,isFailed,inReplyTo,const DeepCollectionEquality().hash(mentions),const DeepCollectionEquality().hash(attachments),const DeepCollectionEquality().hash(reactions),encryptionState,type,authorIdType,isBotCommandPlaceholder);

@override
String toString() {
  return 'MessageDto(id: $id, content: $content, conversationId: $conversationId, channelId: $channelId, authorId: $authorId, createdAt: $createdAt, isPending: $isPending, isFailed: $isFailed, inReplyTo: $inReplyTo, mentions: $mentions, attachments: $attachments, reactions: $reactions, encryptionState: $encryptionState, type: $type, authorIdType: $authorIdType, isBotCommandPlaceholder: $isBotCommandPlaceholder)';
}


}

/// @nodoc
abstract mixin class $MessageDtoCopyWith<$Res>  {
  factory $MessageDtoCopyWith(MessageDto value, $Res Function(MessageDto) _then) = _$MessageDtoCopyWithImpl;
@useResult
$Res call({
 String id, String content, String? conversationId, String? channelId, String authorId, DateTime? createdAt, bool isPending, bool isFailed, String? inReplyTo, List<String> mentions, List<AttachmentDto> attachments, List<MessageReactionDto> reactions, MessageEncryptionState encryptionState, MessageType type,@JsonKey(unknownEnumValue: MessageAuthorType.standard) MessageAuthorType authorIdType,@JsonKey(includeFromJson: false, includeToJson: false) bool isBotCommandPlaceholder
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? content = null,Object? conversationId = freezed,Object? channelId = freezed,Object? authorId = null,Object? createdAt = freezed,Object? isPending = null,Object? isFailed = null,Object? inReplyTo = freezed,Object? mentions = null,Object? attachments = null,Object? reactions = null,Object? encryptionState = null,Object? type = null,Object? authorIdType = null,Object? isBotCommandPlaceholder = null,}) {
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
as List<String>,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<AttachmentDto>,reactions: null == reactions ? _self.reactions : reactions // ignore: cast_nullable_to_non_nullable
as List<MessageReactionDto>,encryptionState: null == encryptionState ? _self.encryptionState : encryptionState // ignore: cast_nullable_to_non_nullable
as MessageEncryptionState,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MessageType,authorIdType: null == authorIdType ? _self.authorIdType : authorIdType // ignore: cast_nullable_to_non_nullable
as MessageAuthorType,isBotCommandPlaceholder: null == isBotCommandPlaceholder ? _self.isBotCommandPlaceholder : isBotCommandPlaceholder // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String content,  String? conversationId,  String? channelId,  String authorId,  DateTime? createdAt,  bool isPending,  bool isFailed,  String? inReplyTo,  List<String> mentions,  List<AttachmentDto> attachments,  List<MessageReactionDto> reactions,  MessageEncryptionState encryptionState,  MessageType type, @JsonKey(unknownEnumValue: MessageAuthorType.standard)  MessageAuthorType authorIdType, @JsonKey(includeFromJson: false, includeToJson: false)  bool isBotCommandPlaceholder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageDto() when $default != null:
return $default(_that.id,_that.content,_that.conversationId,_that.channelId,_that.authorId,_that.createdAt,_that.isPending,_that.isFailed,_that.inReplyTo,_that.mentions,_that.attachments,_that.reactions,_that.encryptionState,_that.type,_that.authorIdType,_that.isBotCommandPlaceholder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String content,  String? conversationId,  String? channelId,  String authorId,  DateTime? createdAt,  bool isPending,  bool isFailed,  String? inReplyTo,  List<String> mentions,  List<AttachmentDto> attachments,  List<MessageReactionDto> reactions,  MessageEncryptionState encryptionState,  MessageType type, @JsonKey(unknownEnumValue: MessageAuthorType.standard)  MessageAuthorType authorIdType, @JsonKey(includeFromJson: false, includeToJson: false)  bool isBotCommandPlaceholder)  $default,) {final _that = this;
switch (_that) {
case _MessageDto():
return $default(_that.id,_that.content,_that.conversationId,_that.channelId,_that.authorId,_that.createdAt,_that.isPending,_that.isFailed,_that.inReplyTo,_that.mentions,_that.attachments,_that.reactions,_that.encryptionState,_that.type,_that.authorIdType,_that.isBotCommandPlaceholder);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String content,  String? conversationId,  String? channelId,  String authorId,  DateTime? createdAt,  bool isPending,  bool isFailed,  String? inReplyTo,  List<String> mentions,  List<AttachmentDto> attachments,  List<MessageReactionDto> reactions,  MessageEncryptionState encryptionState,  MessageType type, @JsonKey(unknownEnumValue: MessageAuthorType.standard)  MessageAuthorType authorIdType, @JsonKey(includeFromJson: false, includeToJson: false)  bool isBotCommandPlaceholder)?  $default,) {final _that = this;
switch (_that) {
case _MessageDto() when $default != null:
return $default(_that.id,_that.content,_that.conversationId,_that.channelId,_that.authorId,_that.createdAt,_that.isPending,_that.isFailed,_that.inReplyTo,_that.mentions,_that.attachments,_that.reactions,_that.encryptionState,_that.type,_that.authorIdType,_that.isBotCommandPlaceholder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessageDto implements MessageDto {
  const _MessageDto({required this.id, required this.content, this.conversationId, this.channelId, required this.authorId, this.createdAt, this.isPending = false, this.isFailed = false, this.inReplyTo, final  List<String> mentions = const <String>[], final  List<AttachmentDto> attachments = const <AttachmentDto>[], final  List<MessageReactionDto> reactions = const <MessageReactionDto>[], this.encryptionState = MessageEncryptionState.plain, this.type = MessageType.message, @JsonKey(unknownEnumValue: MessageAuthorType.standard) this.authorIdType = MessageAuthorType.standard, @JsonKey(includeFromJson: false, includeToJson: false) this.isBotCommandPlaceholder = false}): _mentions = mentions,_attachments = attachments,_reactions = reactions;
  factory _MessageDto.fromJson(Map<String, dynamic> json) => _$MessageDtoFromJson(json);

@override final  String id;
/// Always base64(UTF-8) on the wire, even in Plain mode — see
/// `MessageContentCodec`, the seam where MLS decrypt gets added later.
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
/// Client-only: a synthetic placeholder for an in-flight/failed bot
/// command invocation, never sent or received over the wire — see
/// `ThreadBotPlaceholderAdded` in `MessageThreadBloc`.
@override@JsonKey(includeFromJson: false, includeToJson: false) final  bool isBotCommandPlaceholder;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageDto&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isPending, isPending) || other.isPending == isPending)&&(identical(other.isFailed, isFailed) || other.isFailed == isFailed)&&(identical(other.inReplyTo, inReplyTo) || other.inReplyTo == inReplyTo)&&const DeepCollectionEquality().equals(other._mentions, _mentions)&&const DeepCollectionEquality().equals(other._attachments, _attachments)&&const DeepCollectionEquality().equals(other._reactions, _reactions)&&(identical(other.encryptionState, encryptionState) || other.encryptionState == encryptionState)&&(identical(other.type, type) || other.type == type)&&(identical(other.authorIdType, authorIdType) || other.authorIdType == authorIdType)&&(identical(other.isBotCommandPlaceholder, isBotCommandPlaceholder) || other.isBotCommandPlaceholder == isBotCommandPlaceholder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,content,conversationId,channelId,authorId,createdAt,isPending,isFailed,inReplyTo,const DeepCollectionEquality().hash(_mentions),const DeepCollectionEquality().hash(_attachments),const DeepCollectionEquality().hash(_reactions),encryptionState,type,authorIdType,isBotCommandPlaceholder);

@override
String toString() {
  return 'MessageDto(id: $id, content: $content, conversationId: $conversationId, channelId: $channelId, authorId: $authorId, createdAt: $createdAt, isPending: $isPending, isFailed: $isFailed, inReplyTo: $inReplyTo, mentions: $mentions, attachments: $attachments, reactions: $reactions, encryptionState: $encryptionState, type: $type, authorIdType: $authorIdType, isBotCommandPlaceholder: $isBotCommandPlaceholder)';
}


}

/// @nodoc
abstract mixin class _$MessageDtoCopyWith<$Res> implements $MessageDtoCopyWith<$Res> {
  factory _$MessageDtoCopyWith(_MessageDto value, $Res Function(_MessageDto) _then) = __$MessageDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String content, String? conversationId, String? channelId, String authorId, DateTime? createdAt, bool isPending, bool isFailed, String? inReplyTo, List<String> mentions, List<AttachmentDto> attachments, List<MessageReactionDto> reactions, MessageEncryptionState encryptionState, MessageType type,@JsonKey(unknownEnumValue: MessageAuthorType.standard) MessageAuthorType authorIdType,@JsonKey(includeFromJson: false, includeToJson: false) bool isBotCommandPlaceholder
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? content = null,Object? conversationId = freezed,Object? channelId = freezed,Object? authorId = null,Object? createdAt = freezed,Object? isPending = null,Object? isFailed = null,Object? inReplyTo = freezed,Object? mentions = null,Object? attachments = null,Object? reactions = null,Object? encryptionState = null,Object? type = null,Object? authorIdType = null,Object? isBotCommandPlaceholder = null,}) {
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
as List<String>,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<AttachmentDto>,reactions: null == reactions ? _self._reactions : reactions // ignore: cast_nullable_to_non_nullable
as List<MessageReactionDto>,encryptionState: null == encryptionState ? _self.encryptionState : encryptionState // ignore: cast_nullable_to_non_nullable
as MessageEncryptionState,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MessageType,authorIdType: null == authorIdType ? _self.authorIdType : authorIdType // ignore: cast_nullable_to_non_nullable
as MessageAuthorType,isBotCommandPlaceholder: null == isBotCommandPlaceholder ? _self.isBotCommandPlaceholder : isBotCommandPlaceholder // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
