// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OnboardingConfigDto {

 bool get enabled; String? get rulesText; List<String> get defaultChannelIds;
/// Create a copy of OnboardingConfigDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingConfigDtoCopyWith<OnboardingConfigDto> get copyWith => _$OnboardingConfigDtoCopyWithImpl<OnboardingConfigDto>(this as OnboardingConfigDto, _$identity);

  /// Serializes this OnboardingConfigDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingConfigDto&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.rulesText, rulesText) || other.rulesText == rulesText)&&const DeepCollectionEquality().equals(other.defaultChannelIds, defaultChannelIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,rulesText,const DeepCollectionEquality().hash(defaultChannelIds));

@override
String toString() {
  return 'OnboardingConfigDto(enabled: $enabled, rulesText: $rulesText, defaultChannelIds: $defaultChannelIds)';
}


}

/// @nodoc
abstract mixin class $OnboardingConfigDtoCopyWith<$Res>  {
  factory $OnboardingConfigDtoCopyWith(OnboardingConfigDto value, $Res Function(OnboardingConfigDto) _then) = _$OnboardingConfigDtoCopyWithImpl;
@useResult
$Res call({
 bool enabled, String? rulesText, List<String> defaultChannelIds
});




}
/// @nodoc
class _$OnboardingConfigDtoCopyWithImpl<$Res>
    implements $OnboardingConfigDtoCopyWith<$Res> {
  _$OnboardingConfigDtoCopyWithImpl(this._self, this._then);

  final OnboardingConfigDto _self;
  final $Res Function(OnboardingConfigDto) _then;

/// Create a copy of OnboardingConfigDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? rulesText = freezed,Object? defaultChannelIds = null,}) {
  return _then(_self.copyWith(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,rulesText: freezed == rulesText ? _self.rulesText : rulesText // ignore: cast_nullable_to_non_nullable
as String?,defaultChannelIds: null == defaultChannelIds ? _self.defaultChannelIds : defaultChannelIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [OnboardingConfigDto].
extension OnboardingConfigDtoPatterns on OnboardingConfigDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnboardingConfigDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnboardingConfigDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnboardingConfigDto value)  $default,){
final _that = this;
switch (_that) {
case _OnboardingConfigDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnboardingConfigDto value)?  $default,){
final _that = this;
switch (_that) {
case _OnboardingConfigDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  String? rulesText,  List<String> defaultChannelIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingConfigDto() when $default != null:
return $default(_that.enabled,_that.rulesText,_that.defaultChannelIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  String? rulesText,  List<String> defaultChannelIds)  $default,) {final _that = this;
switch (_that) {
case _OnboardingConfigDto():
return $default(_that.enabled,_that.rulesText,_that.defaultChannelIds);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  String? rulesText,  List<String> defaultChannelIds)?  $default,) {final _that = this;
switch (_that) {
case _OnboardingConfigDto() when $default != null:
return $default(_that.enabled,_that.rulesText,_that.defaultChannelIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OnboardingConfigDto implements OnboardingConfigDto {
  const _OnboardingConfigDto({this.enabled = false, this.rulesText, final  List<String> defaultChannelIds = const []}): _defaultChannelIds = defaultChannelIds;
  factory _OnboardingConfigDto.fromJson(Map<String, dynamic> json) => _$OnboardingConfigDtoFromJson(json);

@override@JsonKey() final  bool enabled;
@override final  String? rulesText;
 final  List<String> _defaultChannelIds;
@override@JsonKey() List<String> get defaultChannelIds {
  if (_defaultChannelIds is EqualUnmodifiableListView) return _defaultChannelIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_defaultChannelIds);
}


/// Create a copy of OnboardingConfigDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingConfigDtoCopyWith<_OnboardingConfigDto> get copyWith => __$OnboardingConfigDtoCopyWithImpl<_OnboardingConfigDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OnboardingConfigDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingConfigDto&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.rulesText, rulesText) || other.rulesText == rulesText)&&const DeepCollectionEquality().equals(other._defaultChannelIds, _defaultChannelIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,rulesText,const DeepCollectionEquality().hash(_defaultChannelIds));

@override
String toString() {
  return 'OnboardingConfigDto(enabled: $enabled, rulesText: $rulesText, defaultChannelIds: $defaultChannelIds)';
}


}

/// @nodoc
abstract mixin class _$OnboardingConfigDtoCopyWith<$Res> implements $OnboardingConfigDtoCopyWith<$Res> {
  factory _$OnboardingConfigDtoCopyWith(_OnboardingConfigDto value, $Res Function(_OnboardingConfigDto) _then) = __$OnboardingConfigDtoCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, String? rulesText, List<String> defaultChannelIds
});




}
/// @nodoc
class __$OnboardingConfigDtoCopyWithImpl<$Res>
    implements _$OnboardingConfigDtoCopyWith<$Res> {
  __$OnboardingConfigDtoCopyWithImpl(this._self, this._then);

  final _OnboardingConfigDto _self;
  final $Res Function(_OnboardingConfigDto) _then;

/// Create a copy of OnboardingConfigDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? rulesText = freezed,Object? defaultChannelIds = null,}) {
  return _then(_OnboardingConfigDto(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,rulesText: freezed == rulesText ? _self.rulesText : rulesText // ignore: cast_nullable_to_non_nullable
as String?,defaultChannelIds: null == defaultChannelIds ? _self._defaultChannelIds : defaultChannelIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$OnboardingStatusDto {

 bool get completed; String? get rulesText; List<String> get defaultChannelIds;
/// Create a copy of OnboardingStatusDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingStatusDtoCopyWith<OnboardingStatusDto> get copyWith => _$OnboardingStatusDtoCopyWithImpl<OnboardingStatusDto>(this as OnboardingStatusDto, _$identity);

  /// Serializes this OnboardingStatusDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingStatusDto&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.rulesText, rulesText) || other.rulesText == rulesText)&&const DeepCollectionEquality().equals(other.defaultChannelIds, defaultChannelIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,completed,rulesText,const DeepCollectionEquality().hash(defaultChannelIds));

@override
String toString() {
  return 'OnboardingStatusDto(completed: $completed, rulesText: $rulesText, defaultChannelIds: $defaultChannelIds)';
}


}

/// @nodoc
abstract mixin class $OnboardingStatusDtoCopyWith<$Res>  {
  factory $OnboardingStatusDtoCopyWith(OnboardingStatusDto value, $Res Function(OnboardingStatusDto) _then) = _$OnboardingStatusDtoCopyWithImpl;
@useResult
$Res call({
 bool completed, String? rulesText, List<String> defaultChannelIds
});




}
/// @nodoc
class _$OnboardingStatusDtoCopyWithImpl<$Res>
    implements $OnboardingStatusDtoCopyWith<$Res> {
  _$OnboardingStatusDtoCopyWithImpl(this._self, this._then);

  final OnboardingStatusDto _self;
  final $Res Function(OnboardingStatusDto) _then;

/// Create a copy of OnboardingStatusDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? completed = null,Object? rulesText = freezed,Object? defaultChannelIds = null,}) {
  return _then(_self.copyWith(
completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,rulesText: freezed == rulesText ? _self.rulesText : rulesText // ignore: cast_nullable_to_non_nullable
as String?,defaultChannelIds: null == defaultChannelIds ? _self.defaultChannelIds : defaultChannelIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [OnboardingStatusDto].
extension OnboardingStatusDtoPatterns on OnboardingStatusDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnboardingStatusDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnboardingStatusDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnboardingStatusDto value)  $default,){
final _that = this;
switch (_that) {
case _OnboardingStatusDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnboardingStatusDto value)?  $default,){
final _that = this;
switch (_that) {
case _OnboardingStatusDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool completed,  String? rulesText,  List<String> defaultChannelIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingStatusDto() when $default != null:
return $default(_that.completed,_that.rulesText,_that.defaultChannelIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool completed,  String? rulesText,  List<String> defaultChannelIds)  $default,) {final _that = this;
switch (_that) {
case _OnboardingStatusDto():
return $default(_that.completed,_that.rulesText,_that.defaultChannelIds);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool completed,  String? rulesText,  List<String> defaultChannelIds)?  $default,) {final _that = this;
switch (_that) {
case _OnboardingStatusDto() when $default != null:
return $default(_that.completed,_that.rulesText,_that.defaultChannelIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OnboardingStatusDto implements OnboardingStatusDto {
  const _OnboardingStatusDto({this.completed = true, this.rulesText, final  List<String> defaultChannelIds = const []}): _defaultChannelIds = defaultChannelIds;
  factory _OnboardingStatusDto.fromJson(Map<String, dynamic> json) => _$OnboardingStatusDtoFromJson(json);

@override@JsonKey() final  bool completed;
@override final  String? rulesText;
 final  List<String> _defaultChannelIds;
@override@JsonKey() List<String> get defaultChannelIds {
  if (_defaultChannelIds is EqualUnmodifiableListView) return _defaultChannelIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_defaultChannelIds);
}


/// Create a copy of OnboardingStatusDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingStatusDtoCopyWith<_OnboardingStatusDto> get copyWith => __$OnboardingStatusDtoCopyWithImpl<_OnboardingStatusDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OnboardingStatusDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingStatusDto&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.rulesText, rulesText) || other.rulesText == rulesText)&&const DeepCollectionEquality().equals(other._defaultChannelIds, _defaultChannelIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,completed,rulesText,const DeepCollectionEquality().hash(_defaultChannelIds));

@override
String toString() {
  return 'OnboardingStatusDto(completed: $completed, rulesText: $rulesText, defaultChannelIds: $defaultChannelIds)';
}


}

/// @nodoc
abstract mixin class _$OnboardingStatusDtoCopyWith<$Res> implements $OnboardingStatusDtoCopyWith<$Res> {
  factory _$OnboardingStatusDtoCopyWith(_OnboardingStatusDto value, $Res Function(_OnboardingStatusDto) _then) = __$OnboardingStatusDtoCopyWithImpl;
@override @useResult
$Res call({
 bool completed, String? rulesText, List<String> defaultChannelIds
});




}
/// @nodoc
class __$OnboardingStatusDtoCopyWithImpl<$Res>
    implements _$OnboardingStatusDtoCopyWith<$Res> {
  __$OnboardingStatusDtoCopyWithImpl(this._self, this._then);

  final _OnboardingStatusDto _self;
  final $Res Function(_OnboardingStatusDto) _then;

/// Create a copy of OnboardingStatusDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? completed = null,Object? rulesText = freezed,Object? defaultChannelIds = null,}) {
  return _then(_OnboardingStatusDto(
completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,rulesText: freezed == rulesText ? _self.rulesText : rulesText // ignore: cast_nullable_to_non_nullable
as String?,defaultChannelIds: null == defaultChannelIds ? _self._defaultChannelIds : defaultChannelIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
