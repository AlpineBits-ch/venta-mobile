// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'guild_dm_preference_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GuildDmPreferenceDto {

 String get guildId; bool get allowDirectMessages;/// True for every row the endpoint returns - it only returns overrides.
/// Carried rather than assumed so a future shape that also lists inherited
/// guilds doesn't silently turn them all into overrides here.
 bool get isOverride; DateTime? get updatedAt;
/// Create a copy of GuildDmPreferenceDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuildDmPreferenceDtoCopyWith<GuildDmPreferenceDto> get copyWith => _$GuildDmPreferenceDtoCopyWithImpl<GuildDmPreferenceDto>(this as GuildDmPreferenceDto, _$identity);

  /// Serializes this GuildDmPreferenceDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuildDmPreferenceDto&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.allowDirectMessages, allowDirectMessages) || other.allowDirectMessages == allowDirectMessages)&&(identical(other.isOverride, isOverride) || other.isOverride == isOverride)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,guildId,allowDirectMessages,isOverride,updatedAt);

@override
String toString() {
  return 'GuildDmPreferenceDto(guildId: $guildId, allowDirectMessages: $allowDirectMessages, isOverride: $isOverride, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $GuildDmPreferenceDtoCopyWith<$Res>  {
  factory $GuildDmPreferenceDtoCopyWith(GuildDmPreferenceDto value, $Res Function(GuildDmPreferenceDto) _then) = _$GuildDmPreferenceDtoCopyWithImpl;
@useResult
$Res call({
 String guildId, bool allowDirectMessages, bool isOverride, DateTime? updatedAt
});




}
/// @nodoc
class _$GuildDmPreferenceDtoCopyWithImpl<$Res>
    implements $GuildDmPreferenceDtoCopyWith<$Res> {
  _$GuildDmPreferenceDtoCopyWithImpl(this._self, this._then);

  final GuildDmPreferenceDto _self;
  final $Res Function(GuildDmPreferenceDto) _then;

/// Create a copy of GuildDmPreferenceDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? guildId = null,Object? allowDirectMessages = null,Object? isOverride = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,allowDirectMessages: null == allowDirectMessages ? _self.allowDirectMessages : allowDirectMessages // ignore: cast_nullable_to_non_nullable
as bool,isOverride: null == isOverride ? _self.isOverride : isOverride // ignore: cast_nullable_to_non_nullable
as bool,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [GuildDmPreferenceDto].
extension GuildDmPreferenceDtoPatterns on GuildDmPreferenceDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuildDmPreferenceDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuildDmPreferenceDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuildDmPreferenceDto value)  $default,){
final _that = this;
switch (_that) {
case _GuildDmPreferenceDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuildDmPreferenceDto value)?  $default,){
final _that = this;
switch (_that) {
case _GuildDmPreferenceDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String guildId,  bool allowDirectMessages,  bool isOverride,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuildDmPreferenceDto() when $default != null:
return $default(_that.guildId,_that.allowDirectMessages,_that.isOverride,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String guildId,  bool allowDirectMessages,  bool isOverride,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _GuildDmPreferenceDto():
return $default(_that.guildId,_that.allowDirectMessages,_that.isOverride,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String guildId,  bool allowDirectMessages,  bool isOverride,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _GuildDmPreferenceDto() when $default != null:
return $default(_that.guildId,_that.allowDirectMessages,_that.isOverride,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _GuildDmPreferenceDto implements GuildDmPreferenceDto {
  const _GuildDmPreferenceDto({required this.guildId, required this.allowDirectMessages, this.isOverride = true, this.updatedAt});
  factory _GuildDmPreferenceDto.fromJson(Map<String, dynamic> json) => _$GuildDmPreferenceDtoFromJson(json);

@override final  String guildId;
@override final  bool allowDirectMessages;
/// True for every row the endpoint returns - it only returns overrides.
/// Carried rather than assumed so a future shape that also lists inherited
/// guilds doesn't silently turn them all into overrides here.
@override@JsonKey() final  bool isOverride;
@override final  DateTime? updatedAt;

/// Create a copy of GuildDmPreferenceDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuildDmPreferenceDtoCopyWith<_GuildDmPreferenceDto> get copyWith => __$GuildDmPreferenceDtoCopyWithImpl<_GuildDmPreferenceDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GuildDmPreferenceDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuildDmPreferenceDto&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.allowDirectMessages, allowDirectMessages) || other.allowDirectMessages == allowDirectMessages)&&(identical(other.isOverride, isOverride) || other.isOverride == isOverride)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,guildId,allowDirectMessages,isOverride,updatedAt);

@override
String toString() {
  return 'GuildDmPreferenceDto(guildId: $guildId, allowDirectMessages: $allowDirectMessages, isOverride: $isOverride, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$GuildDmPreferenceDtoCopyWith<$Res> implements $GuildDmPreferenceDtoCopyWith<$Res> {
  factory _$GuildDmPreferenceDtoCopyWith(_GuildDmPreferenceDto value, $Res Function(_GuildDmPreferenceDto) _then) = __$GuildDmPreferenceDtoCopyWithImpl;
@override @useResult
$Res call({
 String guildId, bool allowDirectMessages, bool isOverride, DateTime? updatedAt
});




}
/// @nodoc
class __$GuildDmPreferenceDtoCopyWithImpl<$Res>
    implements _$GuildDmPreferenceDtoCopyWith<$Res> {
  __$GuildDmPreferenceDtoCopyWithImpl(this._self, this._then);

  final _GuildDmPreferenceDto _self;
  final $Res Function(_GuildDmPreferenceDto) _then;

/// Create a copy of GuildDmPreferenceDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? guildId = null,Object? allowDirectMessages = null,Object? isOverride = null,Object? updatedAt = freezed,}) {
  return _then(_GuildDmPreferenceDto(
guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,allowDirectMessages: null == allowDirectMessages ? _self.allowDirectMessages : allowDirectMessages // ignore: cast_nullable_to_non_nullable
as bool,isOverride: null == isOverride ? _self.isOverride : isOverride // ignore: cast_nullable_to_non_nullable
as bool,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
