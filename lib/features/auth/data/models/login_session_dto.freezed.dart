// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_session_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LoginSessionDto {

 String get id; String? get deviceName;/// `Desktop`, `Mobile` or `Web` - only used to pick an icon.
 String? get deviceType; String? get ipAddress; DateTime? get createdAt; DateTime? get lastUsedAt;/// The session this app is signed in with. It has no revoke button - use
/// Log Out for that.
 bool get isCurrent;
/// Create a copy of LoginSessionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginSessionDtoCopyWith<LoginSessionDto> get copyWith => _$LoginSessionDtoCopyWithImpl<LoginSessionDto>(this as LoginSessionDto, _$identity);

  /// Serializes this LoginSessionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginSessionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.deviceType, deviceType) || other.deviceType == deviceType)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastUsedAt, lastUsedAt) || other.lastUsedAt == lastUsedAt)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,deviceName,deviceType,ipAddress,createdAt,lastUsedAt,isCurrent);

@override
String toString() {
  return 'LoginSessionDto(id: $id, deviceName: $deviceName, deviceType: $deviceType, ipAddress: $ipAddress, createdAt: $createdAt, lastUsedAt: $lastUsedAt, isCurrent: $isCurrent)';
}


}

/// @nodoc
abstract mixin class $LoginSessionDtoCopyWith<$Res>  {
  factory $LoginSessionDtoCopyWith(LoginSessionDto value, $Res Function(LoginSessionDto) _then) = _$LoginSessionDtoCopyWithImpl;
@useResult
$Res call({
 String id, String? deviceName, String? deviceType, String? ipAddress, DateTime? createdAt, DateTime? lastUsedAt, bool isCurrent
});




}
/// @nodoc
class _$LoginSessionDtoCopyWithImpl<$Res>
    implements $LoginSessionDtoCopyWith<$Res> {
  _$LoginSessionDtoCopyWithImpl(this._self, this._then);

  final LoginSessionDto _self;
  final $Res Function(LoginSessionDto) _then;

/// Create a copy of LoginSessionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? deviceName = freezed,Object? deviceType = freezed,Object? ipAddress = freezed,Object? createdAt = freezed,Object? lastUsedAt = freezed,Object? isCurrent = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,deviceType: freezed == deviceType ? _self.deviceType : deviceType // ignore: cast_nullable_to_non_nullable
as String?,ipAddress: freezed == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastUsedAt: freezed == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LoginSessionDto].
extension LoginSessionDtoPatterns on LoginSessionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginSessionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginSessionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginSessionDto value)  $default,){
final _that = this;
switch (_that) {
case _LoginSessionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginSessionDto value)?  $default,){
final _that = this;
switch (_that) {
case _LoginSessionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? deviceName,  String? deviceType,  String? ipAddress,  DateTime? createdAt,  DateTime? lastUsedAt,  bool isCurrent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginSessionDto() when $default != null:
return $default(_that.id,_that.deviceName,_that.deviceType,_that.ipAddress,_that.createdAt,_that.lastUsedAt,_that.isCurrent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? deviceName,  String? deviceType,  String? ipAddress,  DateTime? createdAt,  DateTime? lastUsedAt,  bool isCurrent)  $default,) {final _that = this;
switch (_that) {
case _LoginSessionDto():
return $default(_that.id,_that.deviceName,_that.deviceType,_that.ipAddress,_that.createdAt,_that.lastUsedAt,_that.isCurrent);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? deviceName,  String? deviceType,  String? ipAddress,  DateTime? createdAt,  DateTime? lastUsedAt,  bool isCurrent)?  $default,) {final _that = this;
switch (_that) {
case _LoginSessionDto() when $default != null:
return $default(_that.id,_that.deviceName,_that.deviceType,_that.ipAddress,_that.createdAt,_that.lastUsedAt,_that.isCurrent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoginSessionDto implements LoginSessionDto {
  const _LoginSessionDto({required this.id, this.deviceName, this.deviceType, this.ipAddress, this.createdAt, this.lastUsedAt, this.isCurrent = false});
  factory _LoginSessionDto.fromJson(Map<String, dynamic> json) => _$LoginSessionDtoFromJson(json);

@override final  String id;
@override final  String? deviceName;
/// `Desktop`, `Mobile` or `Web` - only used to pick an icon.
@override final  String? deviceType;
@override final  String? ipAddress;
@override final  DateTime? createdAt;
@override final  DateTime? lastUsedAt;
/// The session this app is signed in with. It has no revoke button - use
/// Log Out for that.
@override@JsonKey() final  bool isCurrent;

/// Create a copy of LoginSessionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginSessionDtoCopyWith<_LoginSessionDto> get copyWith => __$LoginSessionDtoCopyWithImpl<_LoginSessionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoginSessionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginSessionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.deviceType, deviceType) || other.deviceType == deviceType)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastUsedAt, lastUsedAt) || other.lastUsedAt == lastUsedAt)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,deviceName,deviceType,ipAddress,createdAt,lastUsedAt,isCurrent);

@override
String toString() {
  return 'LoginSessionDto(id: $id, deviceName: $deviceName, deviceType: $deviceType, ipAddress: $ipAddress, createdAt: $createdAt, lastUsedAt: $lastUsedAt, isCurrent: $isCurrent)';
}


}

/// @nodoc
abstract mixin class _$LoginSessionDtoCopyWith<$Res> implements $LoginSessionDtoCopyWith<$Res> {
  factory _$LoginSessionDtoCopyWith(_LoginSessionDto value, $Res Function(_LoginSessionDto) _then) = __$LoginSessionDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String? deviceName, String? deviceType, String? ipAddress, DateTime? createdAt, DateTime? lastUsedAt, bool isCurrent
});




}
/// @nodoc
class __$LoginSessionDtoCopyWithImpl<$Res>
    implements _$LoginSessionDtoCopyWith<$Res> {
  __$LoginSessionDtoCopyWithImpl(this._self, this._then);

  final _LoginSessionDto _self;
  final $Res Function(_LoginSessionDto) _then;

/// Create a copy of LoginSessionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? deviceName = freezed,Object? deviceType = freezed,Object? ipAddress = freezed,Object? createdAt = freezed,Object? lastUsedAt = freezed,Object? isCurrent = null,}) {
  return _then(_LoginSessionDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,deviceType: freezed == deviceType ? _self.deviceType : deviceType // ignore: cast_nullable_to_non_nullable
as String?,ipAddress: freezed == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastUsedAt: freezed == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
