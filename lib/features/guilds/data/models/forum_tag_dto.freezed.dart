// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'forum_tag_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ForumTagDto {

 String get id; String get channelId; String get guildId; String get name;/// A guild custom emoji id (`emoj_...`) - mutually exclusive with
/// [emojiName]. May outlive the emoji itself: if the guild emoji was
/// deleted this still resolves to nothing, so render the tag bare rather
/// than showing a broken image.
 String? get emojiId;/// A unicode emoji glyph, e.g. `🐛`.
 String? get emojiName; String get color; int get position;/// Only moderators may apply/remove this tag. Flipping it on doesn't
/// strip the tag from posts that already carry it.
 bool get moderated;/// Non-archived posts currently carrying this tag, computed per request -
/// fine for a filter-bar badge, not something to cache.
 int get postCount;
/// Create a copy of ForumTagDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ForumTagDtoCopyWith<ForumTagDto> get copyWith => _$ForumTagDtoCopyWithImpl<ForumTagDto>(this as ForumTagDto, _$identity);

  /// Serializes this ForumTagDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ForumTagDto&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.name, name) || other.name == name)&&(identical(other.emojiId, emojiId) || other.emojiId == emojiId)&&(identical(other.emojiName, emojiName) || other.emojiName == emojiName)&&(identical(other.color, color) || other.color == color)&&(identical(other.position, position) || other.position == position)&&(identical(other.moderated, moderated) || other.moderated == moderated)&&(identical(other.postCount, postCount) || other.postCount == postCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,guildId,name,emojiId,emojiName,color,position,moderated,postCount);

@override
String toString() {
  return 'ForumTagDto(id: $id, channelId: $channelId, guildId: $guildId, name: $name, emojiId: $emojiId, emojiName: $emojiName, color: $color, position: $position, moderated: $moderated, postCount: $postCount)';
}


}

/// @nodoc
abstract mixin class $ForumTagDtoCopyWith<$Res>  {
  factory $ForumTagDtoCopyWith(ForumTagDto value, $Res Function(ForumTagDto) _then) = _$ForumTagDtoCopyWithImpl;
@useResult
$Res call({
 String id, String channelId, String guildId, String name, String? emojiId, String? emojiName, String color, int position, bool moderated, int postCount
});




}
/// @nodoc
class _$ForumTagDtoCopyWithImpl<$Res>
    implements $ForumTagDtoCopyWith<$Res> {
  _$ForumTagDtoCopyWithImpl(this._self, this._then);

  final ForumTagDto _self;
  final $Res Function(ForumTagDto) _then;

/// Create a copy of ForumTagDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? channelId = null,Object? guildId = null,Object? name = null,Object? emojiId = freezed,Object? emojiName = freezed,Object? color = null,Object? position = null,Object? moderated = null,Object? postCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emojiId: freezed == emojiId ? _self.emojiId : emojiId // ignore: cast_nullable_to_non_nullable
as String?,emojiName: freezed == emojiName ? _self.emojiName : emojiName // ignore: cast_nullable_to_non_nullable
as String?,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,moderated: null == moderated ? _self.moderated : moderated // ignore: cast_nullable_to_non_nullable
as bool,postCount: null == postCount ? _self.postCount : postCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ForumTagDto].
extension ForumTagDtoPatterns on ForumTagDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ForumTagDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ForumTagDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ForumTagDto value)  $default,){
final _that = this;
switch (_that) {
case _ForumTagDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ForumTagDto value)?  $default,){
final _that = this;
switch (_that) {
case _ForumTagDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String channelId,  String guildId,  String name,  String? emojiId,  String? emojiName,  String color,  int position,  bool moderated,  int postCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ForumTagDto() when $default != null:
return $default(_that.id,_that.channelId,_that.guildId,_that.name,_that.emojiId,_that.emojiName,_that.color,_that.position,_that.moderated,_that.postCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String channelId,  String guildId,  String name,  String? emojiId,  String? emojiName,  String color,  int position,  bool moderated,  int postCount)  $default,) {final _that = this;
switch (_that) {
case _ForumTagDto():
return $default(_that.id,_that.channelId,_that.guildId,_that.name,_that.emojiId,_that.emojiName,_that.color,_that.position,_that.moderated,_that.postCount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String channelId,  String guildId,  String name,  String? emojiId,  String? emojiName,  String color,  int position,  bool moderated,  int postCount)?  $default,) {final _that = this;
switch (_that) {
case _ForumTagDto() when $default != null:
return $default(_that.id,_that.channelId,_that.guildId,_that.name,_that.emojiId,_that.emojiName,_that.color,_that.position,_that.moderated,_that.postCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ForumTagDto implements ForumTagDto {
  const _ForumTagDto({required this.id, required this.channelId, required this.guildId, required this.name, this.emojiId, this.emojiName, this.color = '#000000', this.position = 0, this.moderated = false, this.postCount = 0});
  factory _ForumTagDto.fromJson(Map<String, dynamic> json) => _$ForumTagDtoFromJson(json);

@override final  String id;
@override final  String channelId;
@override final  String guildId;
@override final  String name;
/// A guild custom emoji id (`emoj_...`) - mutually exclusive with
/// [emojiName]. May outlive the emoji itself: if the guild emoji was
/// deleted this still resolves to nothing, so render the tag bare rather
/// than showing a broken image.
@override final  String? emojiId;
/// A unicode emoji glyph, e.g. `🐛`.
@override final  String? emojiName;
@override@JsonKey() final  String color;
@override@JsonKey() final  int position;
/// Only moderators may apply/remove this tag. Flipping it on doesn't
/// strip the tag from posts that already carry it.
@override@JsonKey() final  bool moderated;
/// Non-archived posts currently carrying this tag, computed per request -
/// fine for a filter-bar badge, not something to cache.
@override@JsonKey() final  int postCount;

/// Create a copy of ForumTagDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ForumTagDtoCopyWith<_ForumTagDto> get copyWith => __$ForumTagDtoCopyWithImpl<_ForumTagDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ForumTagDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ForumTagDto&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.name, name) || other.name == name)&&(identical(other.emojiId, emojiId) || other.emojiId == emojiId)&&(identical(other.emojiName, emojiName) || other.emojiName == emojiName)&&(identical(other.color, color) || other.color == color)&&(identical(other.position, position) || other.position == position)&&(identical(other.moderated, moderated) || other.moderated == moderated)&&(identical(other.postCount, postCount) || other.postCount == postCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,guildId,name,emojiId,emojiName,color,position,moderated,postCount);

@override
String toString() {
  return 'ForumTagDto(id: $id, channelId: $channelId, guildId: $guildId, name: $name, emojiId: $emojiId, emojiName: $emojiName, color: $color, position: $position, moderated: $moderated, postCount: $postCount)';
}


}

/// @nodoc
abstract mixin class _$ForumTagDtoCopyWith<$Res> implements $ForumTagDtoCopyWith<$Res> {
  factory _$ForumTagDtoCopyWith(_ForumTagDto value, $Res Function(_ForumTagDto) _then) = __$ForumTagDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String channelId, String guildId, String name, String? emojiId, String? emojiName, String color, int position, bool moderated, int postCount
});




}
/// @nodoc
class __$ForumTagDtoCopyWithImpl<$Res>
    implements _$ForumTagDtoCopyWith<$Res> {
  __$ForumTagDtoCopyWithImpl(this._self, this._then);

  final _ForumTagDto _self;
  final $Res Function(_ForumTagDto) _then;

/// Create a copy of ForumTagDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? channelId = null,Object? guildId = null,Object? name = null,Object? emojiId = freezed,Object? emojiName = freezed,Object? color = null,Object? position = null,Object? moderated = null,Object? postCount = null,}) {
  return _then(_ForumTagDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emojiId: freezed == emojiId ? _self.emojiId : emojiId // ignore: cast_nullable_to_non_nullable
as String?,emojiName: freezed == emojiName ? _self.emojiName : emojiName // ignore: cast_nullable_to_non_nullable
as String?,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,moderated: null == moderated ? _self.moderated : moderated // ignore: cast_nullable_to_non_nullable
as bool,postCount: null == postCount ? _self.postCount : postCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
