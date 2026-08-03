// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inbox_message_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InboxMessageDto {

 String get id; DateTime? get createdAt; String get authorId;/// Set for webhook and bot authors, whose name doesn't come from a profile
/// lookup - prefer it over resolving [authorId] when it's present.
 String? get authorDisplayName; String? get authorAvatarUrl; String get content; bool get isEncrypted; int? get mlsGeneration;@JsonKey(unknownEnumValue: InboxMessageType.unknown) InboxMessageType get type;/// Picks the wording for [InboxMessageType.guildMemberJoin]/
/// [InboxMessageType.guildMemberLeave], whose [content] is empty - same
/// server-assigned index `ThreadView` renders from.
 int? get systemMessageVariant; String? get embedsJson;/// Client-only: ciphertext this device holds no keys for. Set by
/// `InboxRepository`, never sent or received.
///
/// MLS ratchets forward only, so a preview from before this device joined
/// the group cannot be opened at all. The flag exists so the row can say so
/// instead of rendering base64.
@JsonKey(includeFromJson: false, includeToJson: false) bool get isUndecryptable;
/// Create a copy of InboxMessageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InboxMessageDtoCopyWith<InboxMessageDto> get copyWith => _$InboxMessageDtoCopyWithImpl<InboxMessageDto>(this as InboxMessageDto, _$identity);

  /// Serializes this InboxMessageDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InboxMessageDto&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.authorDisplayName, authorDisplayName) || other.authorDisplayName == authorDisplayName)&&(identical(other.authorAvatarUrl, authorAvatarUrl) || other.authorAvatarUrl == authorAvatarUrl)&&(identical(other.content, content) || other.content == content)&&(identical(other.isEncrypted, isEncrypted) || other.isEncrypted == isEncrypted)&&(identical(other.mlsGeneration, mlsGeneration) || other.mlsGeneration == mlsGeneration)&&(identical(other.type, type) || other.type == type)&&(identical(other.systemMessageVariant, systemMessageVariant) || other.systemMessageVariant == systemMessageVariant)&&(identical(other.embedsJson, embedsJson) || other.embedsJson == embedsJson)&&(identical(other.isUndecryptable, isUndecryptable) || other.isUndecryptable == isUndecryptable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,authorId,authorDisplayName,authorAvatarUrl,content,isEncrypted,mlsGeneration,type,systemMessageVariant,embedsJson,isUndecryptable);

@override
String toString() {
  return 'InboxMessageDto(id: $id, createdAt: $createdAt, authorId: $authorId, authorDisplayName: $authorDisplayName, authorAvatarUrl: $authorAvatarUrl, content: $content, isEncrypted: $isEncrypted, mlsGeneration: $mlsGeneration, type: $type, systemMessageVariant: $systemMessageVariant, embedsJson: $embedsJson, isUndecryptable: $isUndecryptable)';
}


}

/// @nodoc
abstract mixin class $InboxMessageDtoCopyWith<$Res>  {
  factory $InboxMessageDtoCopyWith(InboxMessageDto value, $Res Function(InboxMessageDto) _then) = _$InboxMessageDtoCopyWithImpl;
@useResult
$Res call({
 String id, DateTime? createdAt, String authorId, String? authorDisplayName, String? authorAvatarUrl, String content, bool isEncrypted, int? mlsGeneration,@JsonKey(unknownEnumValue: InboxMessageType.unknown) InboxMessageType type, int? systemMessageVariant, String? embedsJson,@JsonKey(includeFromJson: false, includeToJson: false) bool isUndecryptable
});




}
/// @nodoc
class _$InboxMessageDtoCopyWithImpl<$Res>
    implements $InboxMessageDtoCopyWith<$Res> {
  _$InboxMessageDtoCopyWithImpl(this._self, this._then);

  final InboxMessageDto _self;
  final $Res Function(InboxMessageDto) _then;

/// Create a copy of InboxMessageDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = freezed,Object? authorId = null,Object? authorDisplayName = freezed,Object? authorAvatarUrl = freezed,Object? content = null,Object? isEncrypted = null,Object? mlsGeneration = freezed,Object? type = null,Object? systemMessageVariant = freezed,Object? embedsJson = freezed,Object? isUndecryptable = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,authorDisplayName: freezed == authorDisplayName ? _self.authorDisplayName : authorDisplayName // ignore: cast_nullable_to_non_nullable
as String?,authorAvatarUrl: freezed == authorAvatarUrl ? _self.authorAvatarUrl : authorAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,isEncrypted: null == isEncrypted ? _self.isEncrypted : isEncrypted // ignore: cast_nullable_to_non_nullable
as bool,mlsGeneration: freezed == mlsGeneration ? _self.mlsGeneration : mlsGeneration // ignore: cast_nullable_to_non_nullable
as int?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as InboxMessageType,systemMessageVariant: freezed == systemMessageVariant ? _self.systemMessageVariant : systemMessageVariant // ignore: cast_nullable_to_non_nullable
as int?,embedsJson: freezed == embedsJson ? _self.embedsJson : embedsJson // ignore: cast_nullable_to_non_nullable
as String?,isUndecryptable: null == isUndecryptable ? _self.isUndecryptable : isUndecryptable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [InboxMessageDto].
extension InboxMessageDtoPatterns on InboxMessageDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InboxMessageDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InboxMessageDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InboxMessageDto value)  $default,){
final _that = this;
switch (_that) {
case _InboxMessageDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InboxMessageDto value)?  $default,){
final _that = this;
switch (_that) {
case _InboxMessageDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime? createdAt,  String authorId,  String? authorDisplayName,  String? authorAvatarUrl,  String content,  bool isEncrypted,  int? mlsGeneration, @JsonKey(unknownEnumValue: InboxMessageType.unknown)  InboxMessageType type,  int? systemMessageVariant,  String? embedsJson, @JsonKey(includeFromJson: false, includeToJson: false)  bool isUndecryptable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InboxMessageDto() when $default != null:
return $default(_that.id,_that.createdAt,_that.authorId,_that.authorDisplayName,_that.authorAvatarUrl,_that.content,_that.isEncrypted,_that.mlsGeneration,_that.type,_that.systemMessageVariant,_that.embedsJson,_that.isUndecryptable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime? createdAt,  String authorId,  String? authorDisplayName,  String? authorAvatarUrl,  String content,  bool isEncrypted,  int? mlsGeneration, @JsonKey(unknownEnumValue: InboxMessageType.unknown)  InboxMessageType type,  int? systemMessageVariant,  String? embedsJson, @JsonKey(includeFromJson: false, includeToJson: false)  bool isUndecryptable)  $default,) {final _that = this;
switch (_that) {
case _InboxMessageDto():
return $default(_that.id,_that.createdAt,_that.authorId,_that.authorDisplayName,_that.authorAvatarUrl,_that.content,_that.isEncrypted,_that.mlsGeneration,_that.type,_that.systemMessageVariant,_that.embedsJson,_that.isUndecryptable);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime? createdAt,  String authorId,  String? authorDisplayName,  String? authorAvatarUrl,  String content,  bool isEncrypted,  int? mlsGeneration, @JsonKey(unknownEnumValue: InboxMessageType.unknown)  InboxMessageType type,  int? systemMessageVariant,  String? embedsJson, @JsonKey(includeFromJson: false, includeToJson: false)  bool isUndecryptable)?  $default,) {final _that = this;
switch (_that) {
case _InboxMessageDto() when $default != null:
return $default(_that.id,_that.createdAt,_that.authorId,_that.authorDisplayName,_that.authorAvatarUrl,_that.content,_that.isEncrypted,_that.mlsGeneration,_that.type,_that.systemMessageVariant,_that.embedsJson,_that.isUndecryptable);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _InboxMessageDto implements InboxMessageDto {
  const _InboxMessageDto({required this.id, this.createdAt, this.authorId = '', this.authorDisplayName, this.authorAvatarUrl, this.content = '', this.isEncrypted = false, this.mlsGeneration, @JsonKey(unknownEnumValue: InboxMessageType.unknown) this.type = InboxMessageType.message, this.systemMessageVariant, this.embedsJson, @JsonKey(includeFromJson: false, includeToJson: false) this.isUndecryptable = false});
  factory _InboxMessageDto.fromJson(Map<String, dynamic> json) => _$InboxMessageDtoFromJson(json);

@override final  String id;
@override final  DateTime? createdAt;
@override@JsonKey() final  String authorId;
/// Set for webhook and bot authors, whose name doesn't come from a profile
/// lookup - prefer it over resolving [authorId] when it's present.
@override final  String? authorDisplayName;
@override final  String? authorAvatarUrl;
@override@JsonKey() final  String content;
@override@JsonKey() final  bool isEncrypted;
@override final  int? mlsGeneration;
@override@JsonKey(unknownEnumValue: InboxMessageType.unknown) final  InboxMessageType type;
/// Picks the wording for [InboxMessageType.guildMemberJoin]/
/// [InboxMessageType.guildMemberLeave], whose [content] is empty - same
/// server-assigned index `ThreadView` renders from.
@override final  int? systemMessageVariant;
@override final  String? embedsJson;
/// Client-only: ciphertext this device holds no keys for. Set by
/// `InboxRepository`, never sent or received.
///
/// MLS ratchets forward only, so a preview from before this device joined
/// the group cannot be opened at all. The flag exists so the row can say so
/// instead of rendering base64.
@override@JsonKey(includeFromJson: false, includeToJson: false) final  bool isUndecryptable;

/// Create a copy of InboxMessageDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InboxMessageDtoCopyWith<_InboxMessageDto> get copyWith => __$InboxMessageDtoCopyWithImpl<_InboxMessageDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InboxMessageDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InboxMessageDto&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.authorDisplayName, authorDisplayName) || other.authorDisplayName == authorDisplayName)&&(identical(other.authorAvatarUrl, authorAvatarUrl) || other.authorAvatarUrl == authorAvatarUrl)&&(identical(other.content, content) || other.content == content)&&(identical(other.isEncrypted, isEncrypted) || other.isEncrypted == isEncrypted)&&(identical(other.mlsGeneration, mlsGeneration) || other.mlsGeneration == mlsGeneration)&&(identical(other.type, type) || other.type == type)&&(identical(other.systemMessageVariant, systemMessageVariant) || other.systemMessageVariant == systemMessageVariant)&&(identical(other.embedsJson, embedsJson) || other.embedsJson == embedsJson)&&(identical(other.isUndecryptable, isUndecryptable) || other.isUndecryptable == isUndecryptable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,authorId,authorDisplayName,authorAvatarUrl,content,isEncrypted,mlsGeneration,type,systemMessageVariant,embedsJson,isUndecryptable);

@override
String toString() {
  return 'InboxMessageDto(id: $id, createdAt: $createdAt, authorId: $authorId, authorDisplayName: $authorDisplayName, authorAvatarUrl: $authorAvatarUrl, content: $content, isEncrypted: $isEncrypted, mlsGeneration: $mlsGeneration, type: $type, systemMessageVariant: $systemMessageVariant, embedsJson: $embedsJson, isUndecryptable: $isUndecryptable)';
}


}

/// @nodoc
abstract mixin class _$InboxMessageDtoCopyWith<$Res> implements $InboxMessageDtoCopyWith<$Res> {
  factory _$InboxMessageDtoCopyWith(_InboxMessageDto value, $Res Function(_InboxMessageDto) _then) = __$InboxMessageDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime? createdAt, String authorId, String? authorDisplayName, String? authorAvatarUrl, String content, bool isEncrypted, int? mlsGeneration,@JsonKey(unknownEnumValue: InboxMessageType.unknown) InboxMessageType type, int? systemMessageVariant, String? embedsJson,@JsonKey(includeFromJson: false, includeToJson: false) bool isUndecryptable
});




}
/// @nodoc
class __$InboxMessageDtoCopyWithImpl<$Res>
    implements _$InboxMessageDtoCopyWith<$Res> {
  __$InboxMessageDtoCopyWithImpl(this._self, this._then);

  final _InboxMessageDto _self;
  final $Res Function(_InboxMessageDto) _then;

/// Create a copy of InboxMessageDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = freezed,Object? authorId = null,Object? authorDisplayName = freezed,Object? authorAvatarUrl = freezed,Object? content = null,Object? isEncrypted = null,Object? mlsGeneration = freezed,Object? type = null,Object? systemMessageVariant = freezed,Object? embedsJson = freezed,Object? isUndecryptable = null,}) {
  return _then(_InboxMessageDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,authorDisplayName: freezed == authorDisplayName ? _self.authorDisplayName : authorDisplayName // ignore: cast_nullable_to_non_nullable
as String?,authorAvatarUrl: freezed == authorAvatarUrl ? _self.authorAvatarUrl : authorAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,isEncrypted: null == isEncrypted ? _self.isEncrypted : isEncrypted // ignore: cast_nullable_to_non_nullable
as bool,mlsGeneration: freezed == mlsGeneration ? _self.mlsGeneration : mlsGeneration // ignore: cast_nullable_to_non_nullable
as int?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as InboxMessageType,systemMessageVariant: freezed == systemMessageVariant ? _self.systemMessageVariant : systemMessageVariant // ignore: cast_nullable_to_non_nullable
as int?,embedsJson: freezed == embedsJson ? _self.embedsJson : embedsJson // ignore: cast_nullable_to_non_nullable
as String?,isUndecryptable: null == isUndecryptable ? _self.isUndecryptable : isUndecryptable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
