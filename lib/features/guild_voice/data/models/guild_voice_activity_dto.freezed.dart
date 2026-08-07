// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'guild_voice_activity_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GuildVoiceActivityChannelDto {

 String get channelId; int get participantCount; List<String> get userIds;/// Whether anyone in this channel is screen sharing.
 bool get hasStream; List<String> get streamerIds;
/// Create a copy of GuildVoiceActivityChannelDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuildVoiceActivityChannelDtoCopyWith<GuildVoiceActivityChannelDto> get copyWith => _$GuildVoiceActivityChannelDtoCopyWithImpl<GuildVoiceActivityChannelDto>(this as GuildVoiceActivityChannelDto, _$identity);

  /// Serializes this GuildVoiceActivityChannelDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuildVoiceActivityChannelDto&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.participantCount, participantCount) || other.participantCount == participantCount)&&const DeepCollectionEquality().equals(other.userIds, userIds)&&(identical(other.hasStream, hasStream) || other.hasStream == hasStream)&&const DeepCollectionEquality().equals(other.streamerIds, streamerIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,channelId,participantCount,const DeepCollectionEquality().hash(userIds),hasStream,const DeepCollectionEquality().hash(streamerIds));

@override
String toString() {
  return 'GuildVoiceActivityChannelDto(channelId: $channelId, participantCount: $participantCount, userIds: $userIds, hasStream: $hasStream, streamerIds: $streamerIds)';
}


}

/// @nodoc
abstract mixin class $GuildVoiceActivityChannelDtoCopyWith<$Res>  {
  factory $GuildVoiceActivityChannelDtoCopyWith(GuildVoiceActivityChannelDto value, $Res Function(GuildVoiceActivityChannelDto) _then) = _$GuildVoiceActivityChannelDtoCopyWithImpl;
@useResult
$Res call({
 String channelId, int participantCount, List<String> userIds, bool hasStream, List<String> streamerIds
});




}
/// @nodoc
class _$GuildVoiceActivityChannelDtoCopyWithImpl<$Res>
    implements $GuildVoiceActivityChannelDtoCopyWith<$Res> {
  _$GuildVoiceActivityChannelDtoCopyWithImpl(this._self, this._then);

  final GuildVoiceActivityChannelDto _self;
  final $Res Function(GuildVoiceActivityChannelDto) _then;

/// Create a copy of GuildVoiceActivityChannelDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? channelId = null,Object? participantCount = null,Object? userIds = null,Object? hasStream = null,Object? streamerIds = null,}) {
  return _then(_self.copyWith(
channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,participantCount: null == participantCount ? _self.participantCount : participantCount // ignore: cast_nullable_to_non_nullable
as int,userIds: null == userIds ? _self.userIds : userIds // ignore: cast_nullable_to_non_nullable
as List<String>,hasStream: null == hasStream ? _self.hasStream : hasStream // ignore: cast_nullable_to_non_nullable
as bool,streamerIds: null == streamerIds ? _self.streamerIds : streamerIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [GuildVoiceActivityChannelDto].
extension GuildVoiceActivityChannelDtoPatterns on GuildVoiceActivityChannelDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuildVoiceActivityChannelDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuildVoiceActivityChannelDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuildVoiceActivityChannelDto value)  $default,){
final _that = this;
switch (_that) {
case _GuildVoiceActivityChannelDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuildVoiceActivityChannelDto value)?  $default,){
final _that = this;
switch (_that) {
case _GuildVoiceActivityChannelDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String channelId,  int participantCount,  List<String> userIds,  bool hasStream,  List<String> streamerIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuildVoiceActivityChannelDto() when $default != null:
return $default(_that.channelId,_that.participantCount,_that.userIds,_that.hasStream,_that.streamerIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String channelId,  int participantCount,  List<String> userIds,  bool hasStream,  List<String> streamerIds)  $default,) {final _that = this;
switch (_that) {
case _GuildVoiceActivityChannelDto():
return $default(_that.channelId,_that.participantCount,_that.userIds,_that.hasStream,_that.streamerIds);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String channelId,  int participantCount,  List<String> userIds,  bool hasStream,  List<String> streamerIds)?  $default,) {final _that = this;
switch (_that) {
case _GuildVoiceActivityChannelDto() when $default != null:
return $default(_that.channelId,_that.participantCount,_that.userIds,_that.hasStream,_that.streamerIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GuildVoiceActivityChannelDto implements GuildVoiceActivityChannelDto {
  const _GuildVoiceActivityChannelDto({required this.channelId, this.participantCount = 0, final  List<String> userIds = const <String>[], this.hasStream = false, final  List<String> streamerIds = const <String>[]}): _userIds = userIds,_streamerIds = streamerIds;
  factory _GuildVoiceActivityChannelDto.fromJson(Map<String, dynamic> json) => _$GuildVoiceActivityChannelDtoFromJson(json);

@override final  String channelId;
@override@JsonKey() final  int participantCount;
 final  List<String> _userIds;
@override@JsonKey() List<String> get userIds {
  if (_userIds is EqualUnmodifiableListView) return _userIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_userIds);
}

/// Whether anyone in this channel is screen sharing.
@override@JsonKey() final  bool hasStream;
 final  List<String> _streamerIds;
@override@JsonKey() List<String> get streamerIds {
  if (_streamerIds is EqualUnmodifiableListView) return _streamerIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_streamerIds);
}


/// Create a copy of GuildVoiceActivityChannelDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuildVoiceActivityChannelDtoCopyWith<_GuildVoiceActivityChannelDto> get copyWith => __$GuildVoiceActivityChannelDtoCopyWithImpl<_GuildVoiceActivityChannelDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GuildVoiceActivityChannelDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuildVoiceActivityChannelDto&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.participantCount, participantCount) || other.participantCount == participantCount)&&const DeepCollectionEquality().equals(other._userIds, _userIds)&&(identical(other.hasStream, hasStream) || other.hasStream == hasStream)&&const DeepCollectionEquality().equals(other._streamerIds, _streamerIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,channelId,participantCount,const DeepCollectionEquality().hash(_userIds),hasStream,const DeepCollectionEquality().hash(_streamerIds));

@override
String toString() {
  return 'GuildVoiceActivityChannelDto(channelId: $channelId, participantCount: $participantCount, userIds: $userIds, hasStream: $hasStream, streamerIds: $streamerIds)';
}


}

/// @nodoc
abstract mixin class _$GuildVoiceActivityChannelDtoCopyWith<$Res> implements $GuildVoiceActivityChannelDtoCopyWith<$Res> {
  factory _$GuildVoiceActivityChannelDtoCopyWith(_GuildVoiceActivityChannelDto value, $Res Function(_GuildVoiceActivityChannelDto) _then) = __$GuildVoiceActivityChannelDtoCopyWithImpl;
@override @useResult
$Res call({
 String channelId, int participantCount, List<String> userIds, bool hasStream, List<String> streamerIds
});




}
/// @nodoc
class __$GuildVoiceActivityChannelDtoCopyWithImpl<$Res>
    implements _$GuildVoiceActivityChannelDtoCopyWith<$Res> {
  __$GuildVoiceActivityChannelDtoCopyWithImpl(this._self, this._then);

  final _GuildVoiceActivityChannelDto _self;
  final $Res Function(_GuildVoiceActivityChannelDto) _then;

/// Create a copy of GuildVoiceActivityChannelDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? channelId = null,Object? participantCount = null,Object? userIds = null,Object? hasStream = null,Object? streamerIds = null,}) {
  return _then(_GuildVoiceActivityChannelDto(
channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,participantCount: null == participantCount ? _self.participantCount : participantCount // ignore: cast_nullable_to_non_nullable
as int,userIds: null == userIds ? _self._userIds : userIds // ignore: cast_nullable_to_non_nullable
as List<String>,hasStream: null == hasStream ? _self.hasStream : hasStream // ignore: cast_nullable_to_non_nullable
as bool,streamerIds: null == streamerIds ? _self._streamerIds : streamerIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$GuildVoiceActivityDto {

 String get guildId; int get participantCount; bool get hasStream; List<GuildVoiceActivityChannelDto> get channels;
/// Create a copy of GuildVoiceActivityDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuildVoiceActivityDtoCopyWith<GuildVoiceActivityDto> get copyWith => _$GuildVoiceActivityDtoCopyWithImpl<GuildVoiceActivityDto>(this as GuildVoiceActivityDto, _$identity);

  /// Serializes this GuildVoiceActivityDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuildVoiceActivityDto&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.participantCount, participantCount) || other.participantCount == participantCount)&&(identical(other.hasStream, hasStream) || other.hasStream == hasStream)&&const DeepCollectionEquality().equals(other.channels, channels));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,guildId,participantCount,hasStream,const DeepCollectionEquality().hash(channels));

@override
String toString() {
  return 'GuildVoiceActivityDto(guildId: $guildId, participantCount: $participantCount, hasStream: $hasStream, channels: $channels)';
}


}

/// @nodoc
abstract mixin class $GuildVoiceActivityDtoCopyWith<$Res>  {
  factory $GuildVoiceActivityDtoCopyWith(GuildVoiceActivityDto value, $Res Function(GuildVoiceActivityDto) _then) = _$GuildVoiceActivityDtoCopyWithImpl;
@useResult
$Res call({
 String guildId, int participantCount, bool hasStream, List<GuildVoiceActivityChannelDto> channels
});




}
/// @nodoc
class _$GuildVoiceActivityDtoCopyWithImpl<$Res>
    implements $GuildVoiceActivityDtoCopyWith<$Res> {
  _$GuildVoiceActivityDtoCopyWithImpl(this._self, this._then);

  final GuildVoiceActivityDto _self;
  final $Res Function(GuildVoiceActivityDto) _then;

/// Create a copy of GuildVoiceActivityDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? guildId = null,Object? participantCount = null,Object? hasStream = null,Object? channels = null,}) {
  return _then(_self.copyWith(
guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,participantCount: null == participantCount ? _self.participantCount : participantCount // ignore: cast_nullable_to_non_nullable
as int,hasStream: null == hasStream ? _self.hasStream : hasStream // ignore: cast_nullable_to_non_nullable
as bool,channels: null == channels ? _self.channels : channels // ignore: cast_nullable_to_non_nullable
as List<GuildVoiceActivityChannelDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [GuildVoiceActivityDto].
extension GuildVoiceActivityDtoPatterns on GuildVoiceActivityDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuildVoiceActivityDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuildVoiceActivityDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuildVoiceActivityDto value)  $default,){
final _that = this;
switch (_that) {
case _GuildVoiceActivityDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuildVoiceActivityDto value)?  $default,){
final _that = this;
switch (_that) {
case _GuildVoiceActivityDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String guildId,  int participantCount,  bool hasStream,  List<GuildVoiceActivityChannelDto> channels)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuildVoiceActivityDto() when $default != null:
return $default(_that.guildId,_that.participantCount,_that.hasStream,_that.channels);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String guildId,  int participantCount,  bool hasStream,  List<GuildVoiceActivityChannelDto> channels)  $default,) {final _that = this;
switch (_that) {
case _GuildVoiceActivityDto():
return $default(_that.guildId,_that.participantCount,_that.hasStream,_that.channels);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String guildId,  int participantCount,  bool hasStream,  List<GuildVoiceActivityChannelDto> channels)?  $default,) {final _that = this;
switch (_that) {
case _GuildVoiceActivityDto() when $default != null:
return $default(_that.guildId,_that.participantCount,_that.hasStream,_that.channels);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GuildVoiceActivityDto implements GuildVoiceActivityDto {
  const _GuildVoiceActivityDto({required this.guildId, this.participantCount = 0, this.hasStream = false, final  List<GuildVoiceActivityChannelDto> channels = const <GuildVoiceActivityChannelDto>[]}): _channels = channels;
  factory _GuildVoiceActivityDto.fromJson(Map<String, dynamic> json) => _$GuildVoiceActivityDtoFromJson(json);

@override final  String guildId;
@override@JsonKey() final  int participantCount;
@override@JsonKey() final  bool hasStream;
 final  List<GuildVoiceActivityChannelDto> _channels;
@override@JsonKey() List<GuildVoiceActivityChannelDto> get channels {
  if (_channels is EqualUnmodifiableListView) return _channels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_channels);
}


/// Create a copy of GuildVoiceActivityDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuildVoiceActivityDtoCopyWith<_GuildVoiceActivityDto> get copyWith => __$GuildVoiceActivityDtoCopyWithImpl<_GuildVoiceActivityDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GuildVoiceActivityDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuildVoiceActivityDto&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.participantCount, participantCount) || other.participantCount == participantCount)&&(identical(other.hasStream, hasStream) || other.hasStream == hasStream)&&const DeepCollectionEquality().equals(other._channels, _channels));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,guildId,participantCount,hasStream,const DeepCollectionEquality().hash(_channels));

@override
String toString() {
  return 'GuildVoiceActivityDto(guildId: $guildId, participantCount: $participantCount, hasStream: $hasStream, channels: $channels)';
}


}

/// @nodoc
abstract mixin class _$GuildVoiceActivityDtoCopyWith<$Res> implements $GuildVoiceActivityDtoCopyWith<$Res> {
  factory _$GuildVoiceActivityDtoCopyWith(_GuildVoiceActivityDto value, $Res Function(_GuildVoiceActivityDto) _then) = __$GuildVoiceActivityDtoCopyWithImpl;
@override @useResult
$Res call({
 String guildId, int participantCount, bool hasStream, List<GuildVoiceActivityChannelDto> channels
});




}
/// @nodoc
class __$GuildVoiceActivityDtoCopyWithImpl<$Res>
    implements _$GuildVoiceActivityDtoCopyWith<$Res> {
  __$GuildVoiceActivityDtoCopyWithImpl(this._self, this._then);

  final _GuildVoiceActivityDto _self;
  final $Res Function(_GuildVoiceActivityDto) _then;

/// Create a copy of GuildVoiceActivityDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? guildId = null,Object? participantCount = null,Object? hasStream = null,Object? channels = null,}) {
  return _then(_GuildVoiceActivityDto(
guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,participantCount: null == participantCount ? _self.participantCount : participantCount // ignore: cast_nullable_to_non_nullable
as int,hasStream: null == hasStream ? _self.hasStream : hasStream // ignore: cast_nullable_to_non_nullable
as bool,channels: null == channels ? _self._channels : channels // ignore: cast_nullable_to_non_nullable
as List<GuildVoiceActivityChannelDto>,
  ));
}


}

// dart format on
