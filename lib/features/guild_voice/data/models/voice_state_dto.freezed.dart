// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voice_state_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VoiceStateDto {

 String get guildId; String get channelId;/// Null when the channel was deleted under a roster that has not been
/// swept yet.
 String? get channelName;/// The device that took the seat.
///
/// Ours after a relaunch; somebody else's phone or second machine
/// otherwise, and that difference decides whether the seat may be released
/// on its behalf - see `VoiceResumeCubit.reconnect`.
 String? get deviceId; DateTime? get joinedAt;
/// Create a copy of VoiceStateDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceStateDtoCopyWith<VoiceStateDto> get copyWith => _$VoiceStateDtoCopyWithImpl<VoiceStateDto>(this as VoiceStateDto, _$identity);

  /// Serializes this VoiceStateDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceStateDto&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.channelName, channelName) || other.channelName == channelName)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,guildId,channelId,channelName,deviceId,joinedAt);

@override
String toString() {
  return 'VoiceStateDto(guildId: $guildId, channelId: $channelId, channelName: $channelName, deviceId: $deviceId, joinedAt: $joinedAt)';
}


}

/// @nodoc
abstract mixin class $VoiceStateDtoCopyWith<$Res>  {
  factory $VoiceStateDtoCopyWith(VoiceStateDto value, $Res Function(VoiceStateDto) _then) = _$VoiceStateDtoCopyWithImpl;
@useResult
$Res call({
 String guildId, String channelId, String? channelName, String? deviceId, DateTime? joinedAt
});




}
/// @nodoc
class _$VoiceStateDtoCopyWithImpl<$Res>
    implements $VoiceStateDtoCopyWith<$Res> {
  _$VoiceStateDtoCopyWithImpl(this._self, this._then);

  final VoiceStateDto _self;
  final $Res Function(VoiceStateDto) _then;

/// Create a copy of VoiceStateDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? guildId = null,Object? channelId = null,Object? channelName = freezed,Object? deviceId = freezed,Object? joinedAt = freezed,}) {
  return _then(_self.copyWith(
guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,channelName: freezed == channelName ? _self.channelName : channelName // ignore: cast_nullable_to_non_nullable
as String?,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [VoiceStateDto].
extension VoiceStateDtoPatterns on VoiceStateDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoiceStateDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoiceStateDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoiceStateDto value)  $default,){
final _that = this;
switch (_that) {
case _VoiceStateDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoiceStateDto value)?  $default,){
final _that = this;
switch (_that) {
case _VoiceStateDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String guildId,  String channelId,  String? channelName,  String? deviceId,  DateTime? joinedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoiceStateDto() when $default != null:
return $default(_that.guildId,_that.channelId,_that.channelName,_that.deviceId,_that.joinedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String guildId,  String channelId,  String? channelName,  String? deviceId,  DateTime? joinedAt)  $default,) {final _that = this;
switch (_that) {
case _VoiceStateDto():
return $default(_that.guildId,_that.channelId,_that.channelName,_that.deviceId,_that.joinedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String guildId,  String channelId,  String? channelName,  String? deviceId,  DateTime? joinedAt)?  $default,) {final _that = this;
switch (_that) {
case _VoiceStateDto() when $default != null:
return $default(_that.guildId,_that.channelId,_that.channelName,_that.deviceId,_that.joinedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _VoiceStateDto implements VoiceStateDto {
  const _VoiceStateDto({required this.guildId, required this.channelId, this.channelName, this.deviceId, this.joinedAt});
  factory _VoiceStateDto.fromJson(Map<String, dynamic> json) => _$VoiceStateDtoFromJson(json);

@override final  String guildId;
@override final  String channelId;
/// Null when the channel was deleted under a roster that has not been
/// swept yet.
@override final  String? channelName;
/// The device that took the seat.
///
/// Ours after a relaunch; somebody else's phone or second machine
/// otherwise, and that difference decides whether the seat may be released
/// on its behalf - see `VoiceResumeCubit.reconnect`.
@override final  String? deviceId;
@override final  DateTime? joinedAt;

/// Create a copy of VoiceStateDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoiceStateDtoCopyWith<_VoiceStateDto> get copyWith => __$VoiceStateDtoCopyWithImpl<_VoiceStateDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoiceStateDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoiceStateDto&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.channelName, channelName) || other.channelName == channelName)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,guildId,channelId,channelName,deviceId,joinedAt);

@override
String toString() {
  return 'VoiceStateDto(guildId: $guildId, channelId: $channelId, channelName: $channelName, deviceId: $deviceId, joinedAt: $joinedAt)';
}


}

/// @nodoc
abstract mixin class _$VoiceStateDtoCopyWith<$Res> implements $VoiceStateDtoCopyWith<$Res> {
  factory _$VoiceStateDtoCopyWith(_VoiceStateDto value, $Res Function(_VoiceStateDto) _then) = __$VoiceStateDtoCopyWithImpl;
@override @useResult
$Res call({
 String guildId, String channelId, String? channelName, String? deviceId, DateTime? joinedAt
});




}
/// @nodoc
class __$VoiceStateDtoCopyWithImpl<$Res>
    implements _$VoiceStateDtoCopyWith<$Res> {
  __$VoiceStateDtoCopyWithImpl(this._self, this._then);

  final _VoiceStateDto _self;
  final $Res Function(_VoiceStateDto) _then;

/// Create a copy of VoiceStateDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? guildId = null,Object? channelId = null,Object? channelName = freezed,Object? deviceId = freezed,Object? joinedAt = freezed,}) {
  return _then(_VoiceStateDto(
guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,channelName: freezed == channelName ? _self.channelName : channelName // ignore: cast_nullable_to_non_nullable
as String?,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
