// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_settings_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationSettingsDto {

 bool get enabled; bool get dm; bool get mentions; bool get sounds; bool get cooldownEnabled; int get cooldownSeconds;
/// Create a copy of NotificationSettingsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationSettingsDtoCopyWith<NotificationSettingsDto> get copyWith => _$NotificationSettingsDtoCopyWithImpl<NotificationSettingsDto>(this as NotificationSettingsDto, _$identity);

  /// Serializes this NotificationSettingsDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationSettingsDto&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.dm, dm) || other.dm == dm)&&(identical(other.mentions, mentions) || other.mentions == mentions)&&(identical(other.sounds, sounds) || other.sounds == sounds)&&(identical(other.cooldownEnabled, cooldownEnabled) || other.cooldownEnabled == cooldownEnabled)&&(identical(other.cooldownSeconds, cooldownSeconds) || other.cooldownSeconds == cooldownSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,dm,mentions,sounds,cooldownEnabled,cooldownSeconds);

@override
String toString() {
  return 'NotificationSettingsDto(enabled: $enabled, dm: $dm, mentions: $mentions, sounds: $sounds, cooldownEnabled: $cooldownEnabled, cooldownSeconds: $cooldownSeconds)';
}


}

/// @nodoc
abstract mixin class $NotificationSettingsDtoCopyWith<$Res>  {
  factory $NotificationSettingsDtoCopyWith(NotificationSettingsDto value, $Res Function(NotificationSettingsDto) _then) = _$NotificationSettingsDtoCopyWithImpl;
@useResult
$Res call({
 bool enabled, bool dm, bool mentions, bool sounds, bool cooldownEnabled, int cooldownSeconds
});




}
/// @nodoc
class _$NotificationSettingsDtoCopyWithImpl<$Res>
    implements $NotificationSettingsDtoCopyWith<$Res> {
  _$NotificationSettingsDtoCopyWithImpl(this._self, this._then);

  final NotificationSettingsDto _self;
  final $Res Function(NotificationSettingsDto) _then;

/// Create a copy of NotificationSettingsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? dm = null,Object? mentions = null,Object? sounds = null,Object? cooldownEnabled = null,Object? cooldownSeconds = null,}) {
  return _then(_self.copyWith(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,dm: null == dm ? _self.dm : dm // ignore: cast_nullable_to_non_nullable
as bool,mentions: null == mentions ? _self.mentions : mentions // ignore: cast_nullable_to_non_nullable
as bool,sounds: null == sounds ? _self.sounds : sounds // ignore: cast_nullable_to_non_nullable
as bool,cooldownEnabled: null == cooldownEnabled ? _self.cooldownEnabled : cooldownEnabled // ignore: cast_nullable_to_non_nullable
as bool,cooldownSeconds: null == cooldownSeconds ? _self.cooldownSeconds : cooldownSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationSettingsDto].
extension NotificationSettingsDtoPatterns on NotificationSettingsDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationSettingsDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationSettingsDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationSettingsDto value)  $default,){
final _that = this;
switch (_that) {
case _NotificationSettingsDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationSettingsDto value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationSettingsDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  bool dm,  bool mentions,  bool sounds,  bool cooldownEnabled,  int cooldownSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationSettingsDto() when $default != null:
return $default(_that.enabled,_that.dm,_that.mentions,_that.sounds,_that.cooldownEnabled,_that.cooldownSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  bool dm,  bool mentions,  bool sounds,  bool cooldownEnabled,  int cooldownSeconds)  $default,) {final _that = this;
switch (_that) {
case _NotificationSettingsDto():
return $default(_that.enabled,_that.dm,_that.mentions,_that.sounds,_that.cooldownEnabled,_that.cooldownSeconds);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  bool dm,  bool mentions,  bool sounds,  bool cooldownEnabled,  int cooldownSeconds)?  $default,) {final _that = this;
switch (_that) {
case _NotificationSettingsDto() when $default != null:
return $default(_that.enabled,_that.dm,_that.mentions,_that.sounds,_that.cooldownEnabled,_that.cooldownSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationSettingsDto implements NotificationSettingsDto {
  const _NotificationSettingsDto({this.enabled = true, this.dm = true, this.mentions = true, this.sounds = true, this.cooldownEnabled = true, this.cooldownSeconds = 10});
  factory _NotificationSettingsDto.fromJson(Map<String, dynamic> json) => _$NotificationSettingsDtoFromJson(json);

@override@JsonKey() final  bool enabled;
@override@JsonKey() final  bool dm;
@override@JsonKey() final  bool mentions;
@override@JsonKey() final  bool sounds;
@override@JsonKey() final  bool cooldownEnabled;
@override@JsonKey() final  int cooldownSeconds;

/// Create a copy of NotificationSettingsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationSettingsDtoCopyWith<_NotificationSettingsDto> get copyWith => __$NotificationSettingsDtoCopyWithImpl<_NotificationSettingsDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationSettingsDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationSettingsDto&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.dm, dm) || other.dm == dm)&&(identical(other.mentions, mentions) || other.mentions == mentions)&&(identical(other.sounds, sounds) || other.sounds == sounds)&&(identical(other.cooldownEnabled, cooldownEnabled) || other.cooldownEnabled == cooldownEnabled)&&(identical(other.cooldownSeconds, cooldownSeconds) || other.cooldownSeconds == cooldownSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,dm,mentions,sounds,cooldownEnabled,cooldownSeconds);

@override
String toString() {
  return 'NotificationSettingsDto(enabled: $enabled, dm: $dm, mentions: $mentions, sounds: $sounds, cooldownEnabled: $cooldownEnabled, cooldownSeconds: $cooldownSeconds)';
}


}

/// @nodoc
abstract mixin class _$NotificationSettingsDtoCopyWith<$Res> implements $NotificationSettingsDtoCopyWith<$Res> {
  factory _$NotificationSettingsDtoCopyWith(_NotificationSettingsDto value, $Res Function(_NotificationSettingsDto) _then) = __$NotificationSettingsDtoCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, bool dm, bool mentions, bool sounds, bool cooldownEnabled, int cooldownSeconds
});




}
/// @nodoc
class __$NotificationSettingsDtoCopyWithImpl<$Res>
    implements _$NotificationSettingsDtoCopyWith<$Res> {
  __$NotificationSettingsDtoCopyWithImpl(this._self, this._then);

  final _NotificationSettingsDto _self;
  final $Res Function(_NotificationSettingsDto) _then;

/// Create a copy of NotificationSettingsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? dm = null,Object? mentions = null,Object? sounds = null,Object? cooldownEnabled = null,Object? cooldownSeconds = null,}) {
  return _then(_NotificationSettingsDto(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,dm: null == dm ? _self.dm : dm // ignore: cast_nullable_to_non_nullable
as bool,mentions: null == mentions ? _self.mentions : mentions // ignore: cast_nullable_to_non_nullable
as bool,sounds: null == sounds ? _self.sounds : sounds // ignore: cast_nullable_to_non_nullable
as bool,cooldownEnabled: null == cooldownEnabled ? _self.cooldownEnabled : cooldownEnabled // ignore: cast_nullable_to_non_nullable
as bool,cooldownSeconds: null == cooldownSeconds ? _self.cooldownSeconds : cooldownSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
