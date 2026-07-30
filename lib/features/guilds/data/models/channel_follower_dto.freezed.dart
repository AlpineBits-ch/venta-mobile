// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'channel_follower_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChannelFollowerDto {

 String get id; String get targetChannelId;
/// Create a copy of ChannelFollowerDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChannelFollowerDtoCopyWith<ChannelFollowerDto> get copyWith => _$ChannelFollowerDtoCopyWithImpl<ChannelFollowerDto>(this as ChannelFollowerDto, _$identity);

  /// Serializes this ChannelFollowerDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChannelFollowerDto&&(identical(other.id, id) || other.id == id)&&(identical(other.targetChannelId, targetChannelId) || other.targetChannelId == targetChannelId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,targetChannelId);

@override
String toString() {
  return 'ChannelFollowerDto(id: $id, targetChannelId: $targetChannelId)';
}


}

/// @nodoc
abstract mixin class $ChannelFollowerDtoCopyWith<$Res>  {
  factory $ChannelFollowerDtoCopyWith(ChannelFollowerDto value, $Res Function(ChannelFollowerDto) _then) = _$ChannelFollowerDtoCopyWithImpl;
@useResult
$Res call({
 String id, String targetChannelId
});




}
/// @nodoc
class _$ChannelFollowerDtoCopyWithImpl<$Res>
    implements $ChannelFollowerDtoCopyWith<$Res> {
  _$ChannelFollowerDtoCopyWithImpl(this._self, this._then);

  final ChannelFollowerDto _self;
  final $Res Function(ChannelFollowerDto) _then;

/// Create a copy of ChannelFollowerDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? targetChannelId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,targetChannelId: null == targetChannelId ? _self.targetChannelId : targetChannelId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ChannelFollowerDto].
extension ChannelFollowerDtoPatterns on ChannelFollowerDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChannelFollowerDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChannelFollowerDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChannelFollowerDto value)  $default,){
final _that = this;
switch (_that) {
case _ChannelFollowerDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChannelFollowerDto value)?  $default,){
final _that = this;
switch (_that) {
case _ChannelFollowerDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String targetChannelId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChannelFollowerDto() when $default != null:
return $default(_that.id,_that.targetChannelId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String targetChannelId)  $default,) {final _that = this;
switch (_that) {
case _ChannelFollowerDto():
return $default(_that.id,_that.targetChannelId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String targetChannelId)?  $default,) {final _that = this;
switch (_that) {
case _ChannelFollowerDto() when $default != null:
return $default(_that.id,_that.targetChannelId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChannelFollowerDto implements ChannelFollowerDto {
  const _ChannelFollowerDto({required this.id, required this.targetChannelId});
  factory _ChannelFollowerDto.fromJson(Map<String, dynamic> json) => _$ChannelFollowerDtoFromJson(json);

@override final  String id;
@override final  String targetChannelId;

/// Create a copy of ChannelFollowerDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChannelFollowerDtoCopyWith<_ChannelFollowerDto> get copyWith => __$ChannelFollowerDtoCopyWithImpl<_ChannelFollowerDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChannelFollowerDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChannelFollowerDto&&(identical(other.id, id) || other.id == id)&&(identical(other.targetChannelId, targetChannelId) || other.targetChannelId == targetChannelId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,targetChannelId);

@override
String toString() {
  return 'ChannelFollowerDto(id: $id, targetChannelId: $targetChannelId)';
}


}

/// @nodoc
abstract mixin class _$ChannelFollowerDtoCopyWith<$Res> implements $ChannelFollowerDtoCopyWith<$Res> {
  factory _$ChannelFollowerDtoCopyWith(_ChannelFollowerDto value, $Res Function(_ChannelFollowerDto) _then) = __$ChannelFollowerDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String targetChannelId
});




}
/// @nodoc
class __$ChannelFollowerDtoCopyWithImpl<$Res>
    implements _$ChannelFollowerDtoCopyWith<$Res> {
  __$ChannelFollowerDtoCopyWithImpl(this._self, this._then);

  final _ChannelFollowerDto _self;
  final $Res Function(_ChannelFollowerDto) _then;

/// Create a copy of ChannelFollowerDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? targetChannelId = null,}) {
  return _then(_ChannelFollowerDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,targetChannelId: null == targetChannelId ? _self.targetChannelId : targetChannelId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
