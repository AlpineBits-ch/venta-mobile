// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'guild_emoji_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GuildEmojiDto {

 String get id; String get guildId; String get name; bool get animated; String get createdByUserId; DateTime? get createdAt;/// Presigned, expires ~1h - refetch the list rather than caching this
/// URL long-term.
 String get imageUrl;
/// Create a copy of GuildEmojiDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuildEmojiDtoCopyWith<GuildEmojiDto> get copyWith => _$GuildEmojiDtoCopyWithImpl<GuildEmojiDto>(this as GuildEmojiDto, _$identity);

  /// Serializes this GuildEmojiDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuildEmojiDto&&(identical(other.id, id) || other.id == id)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.name, name) || other.name == name)&&(identical(other.animated, animated) || other.animated == animated)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,guildId,name,animated,createdByUserId,createdAt,imageUrl);

@override
String toString() {
  return 'GuildEmojiDto(id: $id, guildId: $guildId, name: $name, animated: $animated, createdByUserId: $createdByUserId, createdAt: $createdAt, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class $GuildEmojiDtoCopyWith<$Res>  {
  factory $GuildEmojiDtoCopyWith(GuildEmojiDto value, $Res Function(GuildEmojiDto) _then) = _$GuildEmojiDtoCopyWithImpl;
@useResult
$Res call({
 String id, String guildId, String name, bool animated, String createdByUserId, DateTime? createdAt, String imageUrl
});




}
/// @nodoc
class _$GuildEmojiDtoCopyWithImpl<$Res>
    implements $GuildEmojiDtoCopyWith<$Res> {
  _$GuildEmojiDtoCopyWithImpl(this._self, this._then);

  final GuildEmojiDto _self;
  final $Res Function(GuildEmojiDto) _then;

/// Create a copy of GuildEmojiDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? guildId = null,Object? name = null,Object? animated = null,Object? createdByUserId = null,Object? createdAt = freezed,Object? imageUrl = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,animated: null == animated ? _self.animated : animated // ignore: cast_nullable_to_non_nullable
as bool,createdByUserId: null == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GuildEmojiDto].
extension GuildEmojiDtoPatterns on GuildEmojiDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuildEmojiDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuildEmojiDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuildEmojiDto value)  $default,){
final _that = this;
switch (_that) {
case _GuildEmojiDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuildEmojiDto value)?  $default,){
final _that = this;
switch (_that) {
case _GuildEmojiDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String guildId,  String name,  bool animated,  String createdByUserId,  DateTime? createdAt,  String imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuildEmojiDto() when $default != null:
return $default(_that.id,_that.guildId,_that.name,_that.animated,_that.createdByUserId,_that.createdAt,_that.imageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String guildId,  String name,  bool animated,  String createdByUserId,  DateTime? createdAt,  String imageUrl)  $default,) {final _that = this;
switch (_that) {
case _GuildEmojiDto():
return $default(_that.id,_that.guildId,_that.name,_that.animated,_that.createdByUserId,_that.createdAt,_that.imageUrl);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String guildId,  String name,  bool animated,  String createdByUserId,  DateTime? createdAt,  String imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _GuildEmojiDto() when $default != null:
return $default(_that.id,_that.guildId,_that.name,_that.animated,_that.createdByUserId,_that.createdAt,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _GuildEmojiDto implements GuildEmojiDto {
  const _GuildEmojiDto({required this.id, required this.guildId, required this.name, this.animated = false, required this.createdByUserId, this.createdAt, required this.imageUrl});
  factory _GuildEmojiDto.fromJson(Map<String, dynamic> json) => _$GuildEmojiDtoFromJson(json);

@override final  String id;
@override final  String guildId;
@override final  String name;
@override@JsonKey() final  bool animated;
@override final  String createdByUserId;
@override final  DateTime? createdAt;
/// Presigned, expires ~1h - refetch the list rather than caching this
/// URL long-term.
@override final  String imageUrl;

/// Create a copy of GuildEmojiDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuildEmojiDtoCopyWith<_GuildEmojiDto> get copyWith => __$GuildEmojiDtoCopyWithImpl<_GuildEmojiDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GuildEmojiDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuildEmojiDto&&(identical(other.id, id) || other.id == id)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.name, name) || other.name == name)&&(identical(other.animated, animated) || other.animated == animated)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,guildId,name,animated,createdByUserId,createdAt,imageUrl);

@override
String toString() {
  return 'GuildEmojiDto(id: $id, guildId: $guildId, name: $name, animated: $animated, createdByUserId: $createdByUserId, createdAt: $createdAt, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$GuildEmojiDtoCopyWith<$Res> implements $GuildEmojiDtoCopyWith<$Res> {
  factory _$GuildEmojiDtoCopyWith(_GuildEmojiDto value, $Res Function(_GuildEmojiDto) _then) = __$GuildEmojiDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String guildId, String name, bool animated, String createdByUserId, DateTime? createdAt, String imageUrl
});




}
/// @nodoc
class __$GuildEmojiDtoCopyWithImpl<$Res>
    implements _$GuildEmojiDtoCopyWith<$Res> {
  __$GuildEmojiDtoCopyWithImpl(this._self, this._then);

  final _GuildEmojiDto _self;
  final $Res Function(_GuildEmojiDto) _then;

/// Create a copy of GuildEmojiDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? guildId = null,Object? name = null,Object? animated = null,Object? createdByUserId = null,Object? createdAt = freezed,Object? imageUrl = null,}) {
  return _then(_GuildEmojiDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,animated: null == animated ? _self.animated : animated // ignore: cast_nullable_to_non_nullable
as bool,createdByUserId: null == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
