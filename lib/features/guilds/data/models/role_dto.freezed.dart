// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'role_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RoleDto {

 String get id; String get name; String? get description; String? get color; String get guildId; String get permissions; RoleType get type; int get position;
/// Create a copy of RoleDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoleDtoCopyWith<RoleDto> get copyWith => _$RoleDtoCopyWithImpl<RoleDto>(this as RoleDto, _$identity);

  /// Serializes this RoleDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoleDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.color, color) || other.color == color)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.permissions, permissions) || other.permissions == permissions)&&(identical(other.type, type) || other.type == type)&&(identical(other.position, position) || other.position == position));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,color,guildId,permissions,type,position);

@override
String toString() {
  return 'RoleDto(id: $id, name: $name, description: $description, color: $color, guildId: $guildId, permissions: $permissions, type: $type, position: $position)';
}


}

/// @nodoc
abstract mixin class $RoleDtoCopyWith<$Res>  {
  factory $RoleDtoCopyWith(RoleDto value, $Res Function(RoleDto) _then) = _$RoleDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, String? color, String guildId, String permissions, RoleType type, int position
});




}
/// @nodoc
class _$RoleDtoCopyWithImpl<$Res>
    implements $RoleDtoCopyWith<$Res> {
  _$RoleDtoCopyWithImpl(this._self, this._then);

  final RoleDto _self;
  final $Res Function(RoleDto) _then;

/// Create a copy of RoleDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? color = freezed,Object? guildId = null,Object? permissions = null,Object? type = null,Object? position = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as RoleType,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RoleDto].
extension RoleDtoPatterns on RoleDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoleDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoleDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoleDto value)  $default,){
final _that = this;
switch (_that) {
case _RoleDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoleDto value)?  $default,){
final _that = this;
switch (_that) {
case _RoleDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String? color,  String guildId,  String permissions,  RoleType type,  int position)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoleDto() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.color,_that.guildId,_that.permissions,_that.type,_that.position);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String? color,  String guildId,  String permissions,  RoleType type,  int position)  $default,) {final _that = this;
switch (_that) {
case _RoleDto():
return $default(_that.id,_that.name,_that.description,_that.color,_that.guildId,_that.permissions,_that.type,_that.position);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  String? color,  String guildId,  String permissions,  RoleType type,  int position)?  $default,) {final _that = this;
switch (_that) {
case _RoleDto() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.color,_that.guildId,_that.permissions,_that.type,_that.position);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoleDto implements RoleDto {
  const _RoleDto({required this.id, required this.name, this.description, this.color, required this.guildId, required this.permissions, this.type = RoleType.none, this.position = 0});
  factory _RoleDto.fromJson(Map<String, dynamic> json) => _$RoleDtoFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override final  String? color;
@override final  String guildId;
@override final  String permissions;
@override@JsonKey() final  RoleType type;
@override@JsonKey() final  int position;

/// Create a copy of RoleDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoleDtoCopyWith<_RoleDto> get copyWith => __$RoleDtoCopyWithImpl<_RoleDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoleDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoleDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.color, color) || other.color == color)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.permissions, permissions) || other.permissions == permissions)&&(identical(other.type, type) || other.type == type)&&(identical(other.position, position) || other.position == position));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,color,guildId,permissions,type,position);

@override
String toString() {
  return 'RoleDto(id: $id, name: $name, description: $description, color: $color, guildId: $guildId, permissions: $permissions, type: $type, position: $position)';
}


}

/// @nodoc
abstract mixin class _$RoleDtoCopyWith<$Res> implements $RoleDtoCopyWith<$Res> {
  factory _$RoleDtoCopyWith(_RoleDto value, $Res Function(_RoleDto) _then) = __$RoleDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, String? color, String guildId, String permissions, RoleType type, int position
});




}
/// @nodoc
class __$RoleDtoCopyWithImpl<$Res>
    implements _$RoleDtoCopyWith<$Res> {
  __$RoleDtoCopyWithImpl(this._self, this._then);

  final _RoleDto _self;
  final $Res Function(_RoleDto) _then;

/// Create a copy of RoleDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? color = freezed,Object? guildId = null,Object? permissions = null,Object? type = null,Object? position = null,}) {
  return _then(_RoleDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as RoleType,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
