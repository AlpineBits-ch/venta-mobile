// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_reaction_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MessageReactionDto {

 String get messageId; String get emoji; String get userId;/// Set when this reaction used a custom guild emoji - `emoji` still
/// carries the emoji's name as a text fallback (server-populated), this
/// is the id to resolve against the guild's emoji list for the actual
/// image. Null/absent for ordinary Unicode reactions.
 String? get emojiId;/// `conversationId` or `channelId`, whichever this message belongs to -
/// present on the wire but unused client-side (the message it's
/// attached to already carries that context).
 String? get contextId; DateTime? get createdAt; String? get conversationId; String? get channelId;
/// Create a copy of MessageReactionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageReactionDtoCopyWith<MessageReactionDto> get copyWith => _$MessageReactionDtoCopyWithImpl<MessageReactionDto>(this as MessageReactionDto, _$identity);

  /// Serializes this MessageReactionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageReactionDto&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.emojiId, emojiId) || other.emojiId == emojiId)&&(identical(other.contextId, contextId) || other.contextId == contextId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.channelId, channelId) || other.channelId == channelId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,messageId,emoji,userId,emojiId,contextId,createdAt,conversationId,channelId);

@override
String toString() {
  return 'MessageReactionDto(messageId: $messageId, emoji: $emoji, userId: $userId, emojiId: $emojiId, contextId: $contextId, createdAt: $createdAt, conversationId: $conversationId, channelId: $channelId)';
}


}

/// @nodoc
abstract mixin class $MessageReactionDtoCopyWith<$Res>  {
  factory $MessageReactionDtoCopyWith(MessageReactionDto value, $Res Function(MessageReactionDto) _then) = _$MessageReactionDtoCopyWithImpl;
@useResult
$Res call({
 String messageId, String emoji, String userId, String? emojiId, String? contextId, DateTime? createdAt, String? conversationId, String? channelId
});




}
/// @nodoc
class _$MessageReactionDtoCopyWithImpl<$Res>
    implements $MessageReactionDtoCopyWith<$Res> {
  _$MessageReactionDtoCopyWithImpl(this._self, this._then);

  final MessageReactionDto _self;
  final $Res Function(MessageReactionDto) _then;

/// Create a copy of MessageReactionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? messageId = null,Object? emoji = null,Object? userId = null,Object? emojiId = freezed,Object? contextId = freezed,Object? createdAt = freezed,Object? conversationId = freezed,Object? channelId = freezed,}) {
  return _then(_self.copyWith(
messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,emojiId: freezed == emojiId ? _self.emojiId : emojiId // ignore: cast_nullable_to_non_nullable
as String?,contextId: freezed == contextId ? _self.contextId : contextId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,conversationId: freezed == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String?,channelId: freezed == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageReactionDto].
extension MessageReactionDtoPatterns on MessageReactionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageReactionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageReactionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageReactionDto value)  $default,){
final _that = this;
switch (_that) {
case _MessageReactionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageReactionDto value)?  $default,){
final _that = this;
switch (_that) {
case _MessageReactionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String messageId,  String emoji,  String userId,  String? emojiId,  String? contextId,  DateTime? createdAt,  String? conversationId,  String? channelId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageReactionDto() when $default != null:
return $default(_that.messageId,_that.emoji,_that.userId,_that.emojiId,_that.contextId,_that.createdAt,_that.conversationId,_that.channelId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String messageId,  String emoji,  String userId,  String? emojiId,  String? contextId,  DateTime? createdAt,  String? conversationId,  String? channelId)  $default,) {final _that = this;
switch (_that) {
case _MessageReactionDto():
return $default(_that.messageId,_that.emoji,_that.userId,_that.emojiId,_that.contextId,_that.createdAt,_that.conversationId,_that.channelId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String messageId,  String emoji,  String userId,  String? emojiId,  String? contextId,  DateTime? createdAt,  String? conversationId,  String? channelId)?  $default,) {final _that = this;
switch (_that) {
case _MessageReactionDto() when $default != null:
return $default(_that.messageId,_that.emoji,_that.userId,_that.emojiId,_that.contextId,_that.createdAt,_that.conversationId,_that.channelId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _MessageReactionDto implements MessageReactionDto {
  const _MessageReactionDto({required this.messageId, required this.emoji, required this.userId, this.emojiId, this.contextId, this.createdAt, this.conversationId, this.channelId});
  factory _MessageReactionDto.fromJson(Map<String, dynamic> json) => _$MessageReactionDtoFromJson(json);

@override final  String messageId;
@override final  String emoji;
@override final  String userId;
/// Set when this reaction used a custom guild emoji - `emoji` still
/// carries the emoji's name as a text fallback (server-populated), this
/// is the id to resolve against the guild's emoji list for the actual
/// image. Null/absent for ordinary Unicode reactions.
@override final  String? emojiId;
/// `conversationId` or `channelId`, whichever this message belongs to -
/// present on the wire but unused client-side (the message it's
/// attached to already carries that context).
@override final  String? contextId;
@override final  DateTime? createdAt;
@override final  String? conversationId;
@override final  String? channelId;

/// Create a copy of MessageReactionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageReactionDtoCopyWith<_MessageReactionDto> get copyWith => __$MessageReactionDtoCopyWithImpl<_MessageReactionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageReactionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageReactionDto&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.emojiId, emojiId) || other.emojiId == emojiId)&&(identical(other.contextId, contextId) || other.contextId == contextId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.channelId, channelId) || other.channelId == channelId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,messageId,emoji,userId,emojiId,contextId,createdAt,conversationId,channelId);

@override
String toString() {
  return 'MessageReactionDto(messageId: $messageId, emoji: $emoji, userId: $userId, emojiId: $emojiId, contextId: $contextId, createdAt: $createdAt, conversationId: $conversationId, channelId: $channelId)';
}


}

/// @nodoc
abstract mixin class _$MessageReactionDtoCopyWith<$Res> implements $MessageReactionDtoCopyWith<$Res> {
  factory _$MessageReactionDtoCopyWith(_MessageReactionDto value, $Res Function(_MessageReactionDto) _then) = __$MessageReactionDtoCopyWithImpl;
@override @useResult
$Res call({
 String messageId, String emoji, String userId, String? emojiId, String? contextId, DateTime? createdAt, String? conversationId, String? channelId
});




}
/// @nodoc
class __$MessageReactionDtoCopyWithImpl<$Res>
    implements _$MessageReactionDtoCopyWith<$Res> {
  __$MessageReactionDtoCopyWithImpl(this._self, this._then);

  final _MessageReactionDto _self;
  final $Res Function(_MessageReactionDto) _then;

/// Create a copy of MessageReactionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? messageId = null,Object? emoji = null,Object? userId = null,Object? emojiId = freezed,Object? contextId = freezed,Object? createdAt = freezed,Object? conversationId = freezed,Object? channelId = freezed,}) {
  return _then(_MessageReactionDto(
messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,emojiId: freezed == emojiId ? _self.emojiId : emojiId // ignore: cast_nullable_to_non_nullable
as String?,contextId: freezed == contextId ? _self.contextId : contextId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,conversationId: freezed == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String?,channelId: freezed == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
