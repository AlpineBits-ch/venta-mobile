// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wiki_category_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WikiCategoryDto {

 String get id; String get guildId; String get name; int get position; String? get parentCategoryId;
/// Create a copy of WikiCategoryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WikiCategoryDtoCopyWith<WikiCategoryDto> get copyWith => _$WikiCategoryDtoCopyWithImpl<WikiCategoryDto>(this as WikiCategoryDto, _$identity);

  /// Serializes this WikiCategoryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WikiCategoryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.name, name) || other.name == name)&&(identical(other.position, position) || other.position == position)&&(identical(other.parentCategoryId, parentCategoryId) || other.parentCategoryId == parentCategoryId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,guildId,name,position,parentCategoryId);

@override
String toString() {
  return 'WikiCategoryDto(id: $id, guildId: $guildId, name: $name, position: $position, parentCategoryId: $parentCategoryId)';
}


}

/// @nodoc
abstract mixin class $WikiCategoryDtoCopyWith<$Res>  {
  factory $WikiCategoryDtoCopyWith(WikiCategoryDto value, $Res Function(WikiCategoryDto) _then) = _$WikiCategoryDtoCopyWithImpl;
@useResult
$Res call({
 String id, String guildId, String name, int position, String? parentCategoryId
});




}
/// @nodoc
class _$WikiCategoryDtoCopyWithImpl<$Res>
    implements $WikiCategoryDtoCopyWith<$Res> {
  _$WikiCategoryDtoCopyWithImpl(this._self, this._then);

  final WikiCategoryDto _self;
  final $Res Function(WikiCategoryDto) _then;

/// Create a copy of WikiCategoryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? guildId = null,Object? name = null,Object? position = null,Object? parentCategoryId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,parentCategoryId: freezed == parentCategoryId ? _self.parentCategoryId : parentCategoryId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WikiCategoryDto].
extension WikiCategoryDtoPatterns on WikiCategoryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WikiCategoryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WikiCategoryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WikiCategoryDto value)  $default,){
final _that = this;
switch (_that) {
case _WikiCategoryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WikiCategoryDto value)?  $default,){
final _that = this;
switch (_that) {
case _WikiCategoryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String guildId,  String name,  int position,  String? parentCategoryId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WikiCategoryDto() when $default != null:
return $default(_that.id,_that.guildId,_that.name,_that.position,_that.parentCategoryId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String guildId,  String name,  int position,  String? parentCategoryId)  $default,) {final _that = this;
switch (_that) {
case _WikiCategoryDto():
return $default(_that.id,_that.guildId,_that.name,_that.position,_that.parentCategoryId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String guildId,  String name,  int position,  String? parentCategoryId)?  $default,) {final _that = this;
switch (_that) {
case _WikiCategoryDto() when $default != null:
return $default(_that.id,_that.guildId,_that.name,_that.position,_that.parentCategoryId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WikiCategoryDto implements WikiCategoryDto {
  const _WikiCategoryDto({required this.id, required this.guildId, required this.name, this.position = 0, this.parentCategoryId});
  factory _WikiCategoryDto.fromJson(Map<String, dynamic> json) => _$WikiCategoryDtoFromJson(json);

@override final  String id;
@override final  String guildId;
@override final  String name;
@override@JsonKey() final  int position;
@override final  String? parentCategoryId;

/// Create a copy of WikiCategoryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WikiCategoryDtoCopyWith<_WikiCategoryDto> get copyWith => __$WikiCategoryDtoCopyWithImpl<_WikiCategoryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WikiCategoryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WikiCategoryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.name, name) || other.name == name)&&(identical(other.position, position) || other.position == position)&&(identical(other.parentCategoryId, parentCategoryId) || other.parentCategoryId == parentCategoryId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,guildId,name,position,parentCategoryId);

@override
String toString() {
  return 'WikiCategoryDto(id: $id, guildId: $guildId, name: $name, position: $position, parentCategoryId: $parentCategoryId)';
}


}

/// @nodoc
abstract mixin class _$WikiCategoryDtoCopyWith<$Res> implements $WikiCategoryDtoCopyWith<$Res> {
  factory _$WikiCategoryDtoCopyWith(_WikiCategoryDto value, $Res Function(_WikiCategoryDto) _then) = __$WikiCategoryDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String guildId, String name, int position, String? parentCategoryId
});




}
/// @nodoc
class __$WikiCategoryDtoCopyWithImpl<$Res>
    implements _$WikiCategoryDtoCopyWith<$Res> {
  __$WikiCategoryDtoCopyWithImpl(this._self, this._then);

  final _WikiCategoryDto _self;
  final $Res Function(_WikiCategoryDto) _then;

/// Create a copy of WikiCategoryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? guildId = null,Object? name = null,Object? position = null,Object? parentCategoryId = freezed,}) {
  return _then(_WikiCategoryDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,parentCategoryId: freezed == parentCategoryId ? _self.parentCategoryId : parentCategoryId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
