// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'server_configuration.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ServerConfiguration {

 bool get isRegisterEnabled; bool get isLoginEnabled;
/// Create a copy of ServerConfiguration
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerConfigurationCopyWith<ServerConfiguration> get copyWith => _$ServerConfigurationCopyWithImpl<ServerConfiguration>(this as ServerConfiguration, _$identity);

  /// Serializes this ServerConfiguration to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerConfiguration&&(identical(other.isRegisterEnabled, isRegisterEnabled) || other.isRegisterEnabled == isRegisterEnabled)&&(identical(other.isLoginEnabled, isLoginEnabled) || other.isLoginEnabled == isLoginEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isRegisterEnabled,isLoginEnabled);

@override
String toString() {
  return 'ServerConfiguration(isRegisterEnabled: $isRegisterEnabled, isLoginEnabled: $isLoginEnabled)';
}


}

/// @nodoc
abstract mixin class $ServerConfigurationCopyWith<$Res>  {
  factory $ServerConfigurationCopyWith(ServerConfiguration value, $Res Function(ServerConfiguration) _then) = _$ServerConfigurationCopyWithImpl;
@useResult
$Res call({
 bool isRegisterEnabled, bool isLoginEnabled
});




}
/// @nodoc
class _$ServerConfigurationCopyWithImpl<$Res>
    implements $ServerConfigurationCopyWith<$Res> {
  _$ServerConfigurationCopyWithImpl(this._self, this._then);

  final ServerConfiguration _self;
  final $Res Function(ServerConfiguration) _then;

/// Create a copy of ServerConfiguration
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isRegisterEnabled = null,Object? isLoginEnabled = null,}) {
  return _then(_self.copyWith(
isRegisterEnabled: null == isRegisterEnabled ? _self.isRegisterEnabled : isRegisterEnabled // ignore: cast_nullable_to_non_nullable
as bool,isLoginEnabled: null == isLoginEnabled ? _self.isLoginEnabled : isLoginEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ServerConfiguration].
extension ServerConfigurationPatterns on ServerConfiguration {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServerConfiguration value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServerConfiguration() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServerConfiguration value)  $default,){
final _that = this;
switch (_that) {
case _ServerConfiguration():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServerConfiguration value)?  $default,){
final _that = this;
switch (_that) {
case _ServerConfiguration() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isRegisterEnabled,  bool isLoginEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServerConfiguration() when $default != null:
return $default(_that.isRegisterEnabled,_that.isLoginEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isRegisterEnabled,  bool isLoginEnabled)  $default,) {final _that = this;
switch (_that) {
case _ServerConfiguration():
return $default(_that.isRegisterEnabled,_that.isLoginEnabled);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isRegisterEnabled,  bool isLoginEnabled)?  $default,) {final _that = this;
switch (_that) {
case _ServerConfiguration() when $default != null:
return $default(_that.isRegisterEnabled,_that.isLoginEnabled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ServerConfiguration implements ServerConfiguration {
  const _ServerConfiguration({required this.isRegisterEnabled, required this.isLoginEnabled});
  factory _ServerConfiguration.fromJson(Map<String, dynamic> json) => _$ServerConfigurationFromJson(json);

@override final  bool isRegisterEnabled;
@override final  bool isLoginEnabled;

/// Create a copy of ServerConfiguration
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServerConfigurationCopyWith<_ServerConfiguration> get copyWith => __$ServerConfigurationCopyWithImpl<_ServerConfiguration>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ServerConfigurationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServerConfiguration&&(identical(other.isRegisterEnabled, isRegisterEnabled) || other.isRegisterEnabled == isRegisterEnabled)&&(identical(other.isLoginEnabled, isLoginEnabled) || other.isLoginEnabled == isLoginEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isRegisterEnabled,isLoginEnabled);

@override
String toString() {
  return 'ServerConfiguration(isRegisterEnabled: $isRegisterEnabled, isLoginEnabled: $isLoginEnabled)';
}


}

/// @nodoc
abstract mixin class _$ServerConfigurationCopyWith<$Res> implements $ServerConfigurationCopyWith<$Res> {
  factory _$ServerConfigurationCopyWith(_ServerConfiguration value, $Res Function(_ServerConfiguration) _then) = __$ServerConfigurationCopyWithImpl;
@override @useResult
$Res call({
 bool isRegisterEnabled, bool isLoginEnabled
});




}
/// @nodoc
class __$ServerConfigurationCopyWithImpl<$Res>
    implements _$ServerConfigurationCopyWith<$Res> {
  __$ServerConfigurationCopyWithImpl(this._self, this._then);

  final _ServerConfiguration _self;
  final $Res Function(_ServerConfiguration) _then;

/// Create a copy of ServerConfiguration
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isRegisterEnabled = null,Object? isLoginEnabled = null,}) {
  return _then(_ServerConfiguration(
isRegisterEnabled: null == isRegisterEnabled ? _self.isRegisterEnabled : isRegisterEnabled // ignore: cast_nullable_to_non_nullable
as bool,isLoginEnabled: null == isLoginEnabled ? _self.isLoginEnabled : isLoginEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
