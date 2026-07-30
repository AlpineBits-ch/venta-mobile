// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'welcome_screen_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WelcomeChannelDto {

 String get channelId;/// Max 50 chars, server-enforced.
 String get description; String? get emoji; int get position;
/// Create a copy of WelcomeChannelDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WelcomeChannelDtoCopyWith<WelcomeChannelDto> get copyWith => _$WelcomeChannelDtoCopyWithImpl<WelcomeChannelDto>(this as WelcomeChannelDto, _$identity);

  /// Serializes this WelcomeChannelDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WelcomeChannelDto&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.description, description) || other.description == description)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.position, position) || other.position == position));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,channelId,description,emoji,position);

@override
String toString() {
  return 'WelcomeChannelDto(channelId: $channelId, description: $description, emoji: $emoji, position: $position)';
}


}

/// @nodoc
abstract mixin class $WelcomeChannelDtoCopyWith<$Res>  {
  factory $WelcomeChannelDtoCopyWith(WelcomeChannelDto value, $Res Function(WelcomeChannelDto) _then) = _$WelcomeChannelDtoCopyWithImpl;
@useResult
$Res call({
 String channelId, String description, String? emoji, int position
});




}
/// @nodoc
class _$WelcomeChannelDtoCopyWithImpl<$Res>
    implements $WelcomeChannelDtoCopyWith<$Res> {
  _$WelcomeChannelDtoCopyWithImpl(this._self, this._then);

  final WelcomeChannelDto _self;
  final $Res Function(WelcomeChannelDto) _then;

/// Create a copy of WelcomeChannelDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? channelId = null,Object? description = null,Object? emoji = freezed,Object? position = null,}) {
  return _then(_self.copyWith(
channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,emoji: freezed == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String?,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [WelcomeChannelDto].
extension WelcomeChannelDtoPatterns on WelcomeChannelDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WelcomeChannelDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WelcomeChannelDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WelcomeChannelDto value)  $default,){
final _that = this;
switch (_that) {
case _WelcomeChannelDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WelcomeChannelDto value)?  $default,){
final _that = this;
switch (_that) {
case _WelcomeChannelDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String channelId,  String description,  String? emoji,  int position)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WelcomeChannelDto() when $default != null:
return $default(_that.channelId,_that.description,_that.emoji,_that.position);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String channelId,  String description,  String? emoji,  int position)  $default,) {final _that = this;
switch (_that) {
case _WelcomeChannelDto():
return $default(_that.channelId,_that.description,_that.emoji,_that.position);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String channelId,  String description,  String? emoji,  int position)?  $default,) {final _that = this;
switch (_that) {
case _WelcomeChannelDto() when $default != null:
return $default(_that.channelId,_that.description,_that.emoji,_that.position);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WelcomeChannelDto implements WelcomeChannelDto {
  const _WelcomeChannelDto({required this.channelId, this.description = '', this.emoji, this.position = 0});
  factory _WelcomeChannelDto.fromJson(Map<String, dynamic> json) => _$WelcomeChannelDtoFromJson(json);

@override final  String channelId;
/// Max 50 chars, server-enforced.
@override@JsonKey() final  String description;
@override final  String? emoji;
@override@JsonKey() final  int position;

/// Create a copy of WelcomeChannelDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WelcomeChannelDtoCopyWith<_WelcomeChannelDto> get copyWith => __$WelcomeChannelDtoCopyWithImpl<_WelcomeChannelDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WelcomeChannelDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WelcomeChannelDto&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.description, description) || other.description == description)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.position, position) || other.position == position));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,channelId,description,emoji,position);

@override
String toString() {
  return 'WelcomeChannelDto(channelId: $channelId, description: $description, emoji: $emoji, position: $position)';
}


}

/// @nodoc
abstract mixin class _$WelcomeChannelDtoCopyWith<$Res> implements $WelcomeChannelDtoCopyWith<$Res> {
  factory _$WelcomeChannelDtoCopyWith(_WelcomeChannelDto value, $Res Function(_WelcomeChannelDto) _then) = __$WelcomeChannelDtoCopyWithImpl;
@override @useResult
$Res call({
 String channelId, String description, String? emoji, int position
});




}
/// @nodoc
class __$WelcomeChannelDtoCopyWithImpl<$Res>
    implements _$WelcomeChannelDtoCopyWith<$Res> {
  __$WelcomeChannelDtoCopyWithImpl(this._self, this._then);

  final _WelcomeChannelDto _self;
  final $Res Function(_WelcomeChannelDto) _then;

/// Create a copy of WelcomeChannelDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? channelId = null,Object? description = null,Object? emoji = freezed,Object? position = null,}) {
  return _then(_WelcomeChannelDto(
channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,emoji: freezed == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String?,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$WelcomeScreenDto {

 bool get enabled;/// Max 140 chars, server-enforced.
 String? get description; List<WelcomeChannelDto> get channels;
/// Create a copy of WelcomeScreenDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WelcomeScreenDtoCopyWith<WelcomeScreenDto> get copyWith => _$WelcomeScreenDtoCopyWithImpl<WelcomeScreenDto>(this as WelcomeScreenDto, _$identity);

  /// Serializes this WelcomeScreenDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WelcomeScreenDto&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.channels, channels));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,description,const DeepCollectionEquality().hash(channels));

@override
String toString() {
  return 'WelcomeScreenDto(enabled: $enabled, description: $description, channels: $channels)';
}


}

/// @nodoc
abstract mixin class $WelcomeScreenDtoCopyWith<$Res>  {
  factory $WelcomeScreenDtoCopyWith(WelcomeScreenDto value, $Res Function(WelcomeScreenDto) _then) = _$WelcomeScreenDtoCopyWithImpl;
@useResult
$Res call({
 bool enabled, String? description, List<WelcomeChannelDto> channels
});




}
/// @nodoc
class _$WelcomeScreenDtoCopyWithImpl<$Res>
    implements $WelcomeScreenDtoCopyWith<$Res> {
  _$WelcomeScreenDtoCopyWithImpl(this._self, this._then);

  final WelcomeScreenDto _self;
  final $Res Function(WelcomeScreenDto) _then;

/// Create a copy of WelcomeScreenDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? description = freezed,Object? channels = null,}) {
  return _then(_self.copyWith(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,channels: null == channels ? _self.channels : channels // ignore: cast_nullable_to_non_nullable
as List<WelcomeChannelDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [WelcomeScreenDto].
extension WelcomeScreenDtoPatterns on WelcomeScreenDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WelcomeScreenDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WelcomeScreenDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WelcomeScreenDto value)  $default,){
final _that = this;
switch (_that) {
case _WelcomeScreenDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WelcomeScreenDto value)?  $default,){
final _that = this;
switch (_that) {
case _WelcomeScreenDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  String? description,  List<WelcomeChannelDto> channels)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WelcomeScreenDto() when $default != null:
return $default(_that.enabled,_that.description,_that.channels);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  String? description,  List<WelcomeChannelDto> channels)  $default,) {final _that = this;
switch (_that) {
case _WelcomeScreenDto():
return $default(_that.enabled,_that.description,_that.channels);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  String? description,  List<WelcomeChannelDto> channels)?  $default,) {final _that = this;
switch (_that) {
case _WelcomeScreenDto() when $default != null:
return $default(_that.enabled,_that.description,_that.channels);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WelcomeScreenDto implements WelcomeScreenDto {
  const _WelcomeScreenDto({this.enabled = false, this.description, final  List<WelcomeChannelDto> channels = const <WelcomeChannelDto>[]}): _channels = channels;
  factory _WelcomeScreenDto.fromJson(Map<String, dynamic> json) => _$WelcomeScreenDtoFromJson(json);

@override@JsonKey() final  bool enabled;
/// Max 140 chars, server-enforced.
@override final  String? description;
 final  List<WelcomeChannelDto> _channels;
@override@JsonKey() List<WelcomeChannelDto> get channels {
  if (_channels is EqualUnmodifiableListView) return _channels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_channels);
}


/// Create a copy of WelcomeScreenDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WelcomeScreenDtoCopyWith<_WelcomeScreenDto> get copyWith => __$WelcomeScreenDtoCopyWithImpl<_WelcomeScreenDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WelcomeScreenDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WelcomeScreenDto&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._channels, _channels));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,description,const DeepCollectionEquality().hash(_channels));

@override
String toString() {
  return 'WelcomeScreenDto(enabled: $enabled, description: $description, channels: $channels)';
}


}

/// @nodoc
abstract mixin class _$WelcomeScreenDtoCopyWith<$Res> implements $WelcomeScreenDtoCopyWith<$Res> {
  factory _$WelcomeScreenDtoCopyWith(_WelcomeScreenDto value, $Res Function(_WelcomeScreenDto) _then) = __$WelcomeScreenDtoCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, String? description, List<WelcomeChannelDto> channels
});




}
/// @nodoc
class __$WelcomeScreenDtoCopyWithImpl<$Res>
    implements _$WelcomeScreenDtoCopyWith<$Res> {
  __$WelcomeScreenDtoCopyWithImpl(this._self, this._then);

  final _WelcomeScreenDto _self;
  final $Res Function(_WelcomeScreenDto) _then;

/// Create a copy of WelcomeScreenDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? description = freezed,Object? channels = null,}) {
  return _then(_WelcomeScreenDto(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,channels: null == channels ? _self._channels : channels // ignore: cast_nullable_to_non_nullable
as List<WelcomeChannelDto>,
  ));
}


}

// dart format on
