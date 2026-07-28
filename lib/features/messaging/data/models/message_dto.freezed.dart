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
 String get content; String? get conversationId; String? get channelId; String get authorId; DateTime? get createdAt; bool get isPending; bool get isFailed; String? get inReplyTo; List<String> get mentions; MessageEncryptionState get encryptionState; MessageType get type;
/// Create a copy of MessageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageDtoCopyWith<MessageDto> get copyWith => _$MessageDtoCopyWithImpl<MessageDto>(this as MessageDto, _$identity);

  /// Serializes this MessageDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageDto&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isPending, isPending) || other.isPending == isPending)&&(identical(other.isFailed, isFailed) || other.isFailed == isFailed)&&(identical(other.inReplyTo, inReplyTo) || other.inReplyTo == inReplyTo)&&const DeepCollectionEquality().equals(other.mentions, mentions)&&(identical(other.encryptionState, encryptionState) || other.encryptionState == encryptionState)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,content,conversationId,channelId,authorId,createdAt,isPending,isFailed,inReplyTo,const DeepCollectionEquality().hash(mentions),encryptionState,type);

@override
String toString() {
  return 'MessageDto(id: $id, content: $content, conversationId: $conversationId, channelId: $channelId, authorId: $authorId, createdAt: $createdAt, isPending: $isPending, isFailed: $isFailed, inReplyTo: $inReplyTo, mentions: $mentions, encryptionState: $encryptionState, type: $type)';
}


}

/// @nodoc
abstract mixin class $MessageDtoCopyWith<$Res>  {
  factory $MessageDtoCopyWith(MessageDto value, $Res Function(MessageDto) _then) = _$MessageDtoCopyWithImpl;
@useResult
$Res call({
 String id, String content, String? conversationId, String? channelId, String authorId, DateTime? createdAt, bool isPending, bool isFailed, String? inReplyTo, List<String> mentions, MessageEncryptionState encryptionState, MessageType type
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? content = null,Object? conversationId = freezed,Object? channelId = freezed,Object? authorId = null,Object? createdAt = freezed,Object? isPending = null,Object? isFailed = null,Object? inReplyTo = freezed,Object? mentions = null,Object? encryptionState = null,Object? type = null,}) {
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
as List<String>,encryptionState: null == encryptionState ? _self.encryptionState : encryptionState // ignore: cast_nullable_to_non_nullable
as MessageEncryptionState,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MessageType,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String content,  String? conversationId,  String? channelId,  String authorId,  DateTime? createdAt,  bool isPending,  bool isFailed,  String? inReplyTo,  List<String> mentions,  MessageEncryptionState encryptionState,  MessageType type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageDto() when $default != null:
return $default(_that.id,_that.content,_that.conversationId,_that.channelId,_that.authorId,_that.createdAt,_that.isPending,_that.isFailed,_that.inReplyTo,_that.mentions,_that.encryptionState,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String content,  String? conversationId,  String? channelId,  String authorId,  DateTime? createdAt,  bool isPending,  bool isFailed,  String? inReplyTo,  List<String> mentions,  MessageEncryptionState encryptionState,  MessageType type)  $default,) {final _that = this;
switch (_that) {
case _MessageDto():
return $default(_that.id,_that.content,_that.conversationId,_that.channelId,_that.authorId,_that.createdAt,_that.isPending,_that.isFailed,_that.inReplyTo,_that.mentions,_that.encryptionState,_that.type);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String content,  String? conversationId,  String? channelId,  String authorId,  DateTime? createdAt,  bool isPending,  bool isFailed,  String? inReplyTo,  List<String> mentions,  MessageEncryptionState encryptionState,  MessageType type)?  $default,) {final _that = this;
switch (_that) {
case _MessageDto() when $default != null:
return $default(_that.id,_that.content,_that.conversationId,_that.channelId,_that.authorId,_that.createdAt,_that.isPending,_that.isFailed,_that.inReplyTo,_that.mentions,_that.encryptionState,_that.type);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessageDto implements MessageDto {
  const _MessageDto({required this.id, required this.content, this.conversationId, this.channelId, required this.authorId, this.createdAt, this.isPending = false, this.isFailed = false, this.inReplyTo, final  List<String> mentions = const <String>[], this.encryptionState = MessageEncryptionState.plain, this.type = MessageType.message}): _mentions = mentions;
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

@override@JsonKey() final  MessageEncryptionState encryptionState;
@override@JsonKey() final  MessageType type;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageDto&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isPending, isPending) || other.isPending == isPending)&&(identical(other.isFailed, isFailed) || other.isFailed == isFailed)&&(identical(other.inReplyTo, inReplyTo) || other.inReplyTo == inReplyTo)&&const DeepCollectionEquality().equals(other._mentions, _mentions)&&(identical(other.encryptionState, encryptionState) || other.encryptionState == encryptionState)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,content,conversationId,channelId,authorId,createdAt,isPending,isFailed,inReplyTo,const DeepCollectionEquality().hash(_mentions),encryptionState,type);

@override
String toString() {
  return 'MessageDto(id: $id, content: $content, conversationId: $conversationId, channelId: $channelId, authorId: $authorId, createdAt: $createdAt, isPending: $isPending, isFailed: $isFailed, inReplyTo: $inReplyTo, mentions: $mentions, encryptionState: $encryptionState, type: $type)';
}


}

/// @nodoc
abstract mixin class _$MessageDtoCopyWith<$Res> implements $MessageDtoCopyWith<$Res> {
  factory _$MessageDtoCopyWith(_MessageDto value, $Res Function(_MessageDto) _then) = __$MessageDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String content, String? conversationId, String? channelId, String authorId, DateTime? createdAt, bool isPending, bool isFailed, String? inReplyTo, List<String> mentions, MessageEncryptionState encryptionState, MessageType type
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? content = null,Object? conversationId = freezed,Object? channelId = freezed,Object? authorId = null,Object? createdAt = freezed,Object? isPending = null,Object? isFailed = null,Object? inReplyTo = freezed,Object? mentions = null,Object? encryptionState = null,Object? type = null,}) {
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
as List<String>,encryptionState: null == encryptionState ? _self.encryptionState : encryptionState // ignore: cast_nullable_to_non_nullable
as MessageEncryptionState,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MessageType,
  ));
}


}

// dart format on
