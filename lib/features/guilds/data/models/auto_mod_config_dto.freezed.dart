// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auto_mod_config_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AutoModConfigDto {

 bool get enabled; List<String> get blockedWords; int? get maxMessagesPerInterval; int? get intervalSeconds;
/// Create a copy of AutoModConfigDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AutoModConfigDtoCopyWith<AutoModConfigDto> get copyWith => _$AutoModConfigDtoCopyWithImpl<AutoModConfigDto>(this as AutoModConfigDto, _$identity);

  /// Serializes this AutoModConfigDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AutoModConfigDto&&(identical(other.enabled, enabled) || other.enabled == enabled)&&const DeepCollectionEquality().equals(other.blockedWords, blockedWords)&&(identical(other.maxMessagesPerInterval, maxMessagesPerInterval) || other.maxMessagesPerInterval == maxMessagesPerInterval)&&(identical(other.intervalSeconds, intervalSeconds) || other.intervalSeconds == intervalSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,const DeepCollectionEquality().hash(blockedWords),maxMessagesPerInterval,intervalSeconds);

@override
String toString() {
  return 'AutoModConfigDto(enabled: $enabled, blockedWords: $blockedWords, maxMessagesPerInterval: $maxMessagesPerInterval, intervalSeconds: $intervalSeconds)';
}


}

/// @nodoc
abstract mixin class $AutoModConfigDtoCopyWith<$Res>  {
  factory $AutoModConfigDtoCopyWith(AutoModConfigDto value, $Res Function(AutoModConfigDto) _then) = _$AutoModConfigDtoCopyWithImpl;
@useResult
$Res call({
 bool enabled, List<String> blockedWords, int? maxMessagesPerInterval, int? intervalSeconds
});




}
/// @nodoc
class _$AutoModConfigDtoCopyWithImpl<$Res>
    implements $AutoModConfigDtoCopyWith<$Res> {
  _$AutoModConfigDtoCopyWithImpl(this._self, this._then);

  final AutoModConfigDto _self;
  final $Res Function(AutoModConfigDto) _then;

/// Create a copy of AutoModConfigDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? blockedWords = null,Object? maxMessagesPerInterval = freezed,Object? intervalSeconds = freezed,}) {
  return _then(_self.copyWith(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,blockedWords: null == blockedWords ? _self.blockedWords : blockedWords // ignore: cast_nullable_to_non_nullable
as List<String>,maxMessagesPerInterval: freezed == maxMessagesPerInterval ? _self.maxMessagesPerInterval : maxMessagesPerInterval // ignore: cast_nullable_to_non_nullable
as int?,intervalSeconds: freezed == intervalSeconds ? _self.intervalSeconds : intervalSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [AutoModConfigDto].
extension AutoModConfigDtoPatterns on AutoModConfigDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AutoModConfigDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AutoModConfigDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AutoModConfigDto value)  $default,){
final _that = this;
switch (_that) {
case _AutoModConfigDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AutoModConfigDto value)?  $default,){
final _that = this;
switch (_that) {
case _AutoModConfigDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  List<String> blockedWords,  int? maxMessagesPerInterval,  int? intervalSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AutoModConfigDto() when $default != null:
return $default(_that.enabled,_that.blockedWords,_that.maxMessagesPerInterval,_that.intervalSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  List<String> blockedWords,  int? maxMessagesPerInterval,  int? intervalSeconds)  $default,) {final _that = this;
switch (_that) {
case _AutoModConfigDto():
return $default(_that.enabled,_that.blockedWords,_that.maxMessagesPerInterval,_that.intervalSeconds);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  List<String> blockedWords,  int? maxMessagesPerInterval,  int? intervalSeconds)?  $default,) {final _that = this;
switch (_that) {
case _AutoModConfigDto() when $default != null:
return $default(_that.enabled,_that.blockedWords,_that.maxMessagesPerInterval,_that.intervalSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AutoModConfigDto implements AutoModConfigDto {
  const _AutoModConfigDto({this.enabled = false, final  List<String> blockedWords = const [], this.maxMessagesPerInterval, this.intervalSeconds}): _blockedWords = blockedWords;
  factory _AutoModConfigDto.fromJson(Map<String, dynamic> json) => _$AutoModConfigDtoFromJson(json);

@override@JsonKey() final  bool enabled;
 final  List<String> _blockedWords;
@override@JsonKey() List<String> get blockedWords {
  if (_blockedWords is EqualUnmodifiableListView) return _blockedWords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blockedWords);
}

@override final  int? maxMessagesPerInterval;
@override final  int? intervalSeconds;

/// Create a copy of AutoModConfigDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AutoModConfigDtoCopyWith<_AutoModConfigDto> get copyWith => __$AutoModConfigDtoCopyWithImpl<_AutoModConfigDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AutoModConfigDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AutoModConfigDto&&(identical(other.enabled, enabled) || other.enabled == enabled)&&const DeepCollectionEquality().equals(other._blockedWords, _blockedWords)&&(identical(other.maxMessagesPerInterval, maxMessagesPerInterval) || other.maxMessagesPerInterval == maxMessagesPerInterval)&&(identical(other.intervalSeconds, intervalSeconds) || other.intervalSeconds == intervalSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,const DeepCollectionEquality().hash(_blockedWords),maxMessagesPerInterval,intervalSeconds);

@override
String toString() {
  return 'AutoModConfigDto(enabled: $enabled, blockedWords: $blockedWords, maxMessagesPerInterval: $maxMessagesPerInterval, intervalSeconds: $intervalSeconds)';
}


}

/// @nodoc
abstract mixin class _$AutoModConfigDtoCopyWith<$Res> implements $AutoModConfigDtoCopyWith<$Res> {
  factory _$AutoModConfigDtoCopyWith(_AutoModConfigDto value, $Res Function(_AutoModConfigDto) _then) = __$AutoModConfigDtoCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, List<String> blockedWords, int? maxMessagesPerInterval, int? intervalSeconds
});




}
/// @nodoc
class __$AutoModConfigDtoCopyWithImpl<$Res>
    implements _$AutoModConfigDtoCopyWith<$Res> {
  __$AutoModConfigDtoCopyWithImpl(this._self, this._then);

  final _AutoModConfigDto _self;
  final $Res Function(_AutoModConfigDto) _then;

/// Create a copy of AutoModConfigDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? blockedWords = null,Object? maxMessagesPerInterval = freezed,Object? intervalSeconds = freezed,}) {
  return _then(_AutoModConfigDto(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,blockedWords: null == blockedWords ? _self._blockedWords : blockedWords // ignore: cast_nullable_to_non_nullable
as List<String>,maxMessagesPerInterval: freezed == maxMessagesPerInterval ? _self.maxMessagesPerInterval : maxMessagesPerInterval // ignore: cast_nullable_to_non_nullable
as int?,intervalSeconds: freezed == intervalSeconds ? _self.intervalSeconds : intervalSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
