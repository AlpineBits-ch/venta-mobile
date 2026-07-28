// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'guild_voice_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VoiceParticipantDto {

 String get userId; String get channelId; String get guildId; String? get cfSessionId; String? get audioTrackName; bool get isSelfMuted; bool get isSelfDeafened; bool get isServerMuted; bool get isServerDeafened; bool get isStreaming; String? get joinedAt;
/// Create a copy of VoiceParticipantDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceParticipantDtoCopyWith<VoiceParticipantDto> get copyWith => _$VoiceParticipantDtoCopyWithImpl<VoiceParticipantDto>(this as VoiceParticipantDto, _$identity);

  /// Serializes this VoiceParticipantDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceParticipantDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.cfSessionId, cfSessionId) || other.cfSessionId == cfSessionId)&&(identical(other.audioTrackName, audioTrackName) || other.audioTrackName == audioTrackName)&&(identical(other.isSelfMuted, isSelfMuted) || other.isSelfMuted == isSelfMuted)&&(identical(other.isSelfDeafened, isSelfDeafened) || other.isSelfDeafened == isSelfDeafened)&&(identical(other.isServerMuted, isServerMuted) || other.isServerMuted == isServerMuted)&&(identical(other.isServerDeafened, isServerDeafened) || other.isServerDeafened == isServerDeafened)&&(identical(other.isStreaming, isStreaming) || other.isStreaming == isStreaming)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,channelId,guildId,cfSessionId,audioTrackName,isSelfMuted,isSelfDeafened,isServerMuted,isServerDeafened,isStreaming,joinedAt);

@override
String toString() {
  return 'VoiceParticipantDto(userId: $userId, channelId: $channelId, guildId: $guildId, cfSessionId: $cfSessionId, audioTrackName: $audioTrackName, isSelfMuted: $isSelfMuted, isSelfDeafened: $isSelfDeafened, isServerMuted: $isServerMuted, isServerDeafened: $isServerDeafened, isStreaming: $isStreaming, joinedAt: $joinedAt)';
}


}

/// @nodoc
abstract mixin class $VoiceParticipantDtoCopyWith<$Res>  {
  factory $VoiceParticipantDtoCopyWith(VoiceParticipantDto value, $Res Function(VoiceParticipantDto) _then) = _$VoiceParticipantDtoCopyWithImpl;
@useResult
$Res call({
 String userId, String channelId, String guildId, String? cfSessionId, String? audioTrackName, bool isSelfMuted, bool isSelfDeafened, bool isServerMuted, bool isServerDeafened, bool isStreaming, String? joinedAt
});




}
/// @nodoc
class _$VoiceParticipantDtoCopyWithImpl<$Res>
    implements $VoiceParticipantDtoCopyWith<$Res> {
  _$VoiceParticipantDtoCopyWithImpl(this._self, this._then);

  final VoiceParticipantDto _self;
  final $Res Function(VoiceParticipantDto) _then;

/// Create a copy of VoiceParticipantDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? channelId = null,Object? guildId = null,Object? cfSessionId = freezed,Object? audioTrackName = freezed,Object? isSelfMuted = null,Object? isSelfDeafened = null,Object? isServerMuted = null,Object? isServerDeafened = null,Object? isStreaming = null,Object? joinedAt = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,cfSessionId: freezed == cfSessionId ? _self.cfSessionId : cfSessionId // ignore: cast_nullable_to_non_nullable
as String?,audioTrackName: freezed == audioTrackName ? _self.audioTrackName : audioTrackName // ignore: cast_nullable_to_non_nullable
as String?,isSelfMuted: null == isSelfMuted ? _self.isSelfMuted : isSelfMuted // ignore: cast_nullable_to_non_nullable
as bool,isSelfDeafened: null == isSelfDeafened ? _self.isSelfDeafened : isSelfDeafened // ignore: cast_nullable_to_non_nullable
as bool,isServerMuted: null == isServerMuted ? _self.isServerMuted : isServerMuted // ignore: cast_nullable_to_non_nullable
as bool,isServerDeafened: null == isServerDeafened ? _self.isServerDeafened : isServerDeafened // ignore: cast_nullable_to_non_nullable
as bool,isStreaming: null == isStreaming ? _self.isStreaming : isStreaming // ignore: cast_nullable_to_non_nullable
as bool,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VoiceParticipantDto].
extension VoiceParticipantDtoPatterns on VoiceParticipantDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoiceParticipantDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoiceParticipantDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoiceParticipantDto value)  $default,){
final _that = this;
switch (_that) {
case _VoiceParticipantDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoiceParticipantDto value)?  $default,){
final _that = this;
switch (_that) {
case _VoiceParticipantDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String channelId,  String guildId,  String? cfSessionId,  String? audioTrackName,  bool isSelfMuted,  bool isSelfDeafened,  bool isServerMuted,  bool isServerDeafened,  bool isStreaming,  String? joinedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoiceParticipantDto() when $default != null:
return $default(_that.userId,_that.channelId,_that.guildId,_that.cfSessionId,_that.audioTrackName,_that.isSelfMuted,_that.isSelfDeafened,_that.isServerMuted,_that.isServerDeafened,_that.isStreaming,_that.joinedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String channelId,  String guildId,  String? cfSessionId,  String? audioTrackName,  bool isSelfMuted,  bool isSelfDeafened,  bool isServerMuted,  bool isServerDeafened,  bool isStreaming,  String? joinedAt)  $default,) {final _that = this;
switch (_that) {
case _VoiceParticipantDto():
return $default(_that.userId,_that.channelId,_that.guildId,_that.cfSessionId,_that.audioTrackName,_that.isSelfMuted,_that.isSelfDeafened,_that.isServerMuted,_that.isServerDeafened,_that.isStreaming,_that.joinedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String channelId,  String guildId,  String? cfSessionId,  String? audioTrackName,  bool isSelfMuted,  bool isSelfDeafened,  bool isServerMuted,  bool isServerDeafened,  bool isStreaming,  String? joinedAt)?  $default,) {final _that = this;
switch (_that) {
case _VoiceParticipantDto() when $default != null:
return $default(_that.userId,_that.channelId,_that.guildId,_that.cfSessionId,_that.audioTrackName,_that.isSelfMuted,_that.isSelfDeafened,_that.isServerMuted,_that.isServerDeafened,_that.isStreaming,_that.joinedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoiceParticipantDto implements VoiceParticipantDto {
  const _VoiceParticipantDto({required this.userId, required this.channelId, required this.guildId, this.cfSessionId, this.audioTrackName, this.isSelfMuted = false, this.isSelfDeafened = false, this.isServerMuted = false, this.isServerDeafened = false, this.isStreaming = false, this.joinedAt});
  factory _VoiceParticipantDto.fromJson(Map<String, dynamic> json) => _$VoiceParticipantDtoFromJson(json);

@override final  String userId;
@override final  String channelId;
@override final  String guildId;
@override final  String? cfSessionId;
@override final  String? audioTrackName;
@override@JsonKey() final  bool isSelfMuted;
@override@JsonKey() final  bool isSelfDeafened;
@override@JsonKey() final  bool isServerMuted;
@override@JsonKey() final  bool isServerDeafened;
@override@JsonKey() final  bool isStreaming;
@override final  String? joinedAt;

/// Create a copy of VoiceParticipantDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoiceParticipantDtoCopyWith<_VoiceParticipantDto> get copyWith => __$VoiceParticipantDtoCopyWithImpl<_VoiceParticipantDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoiceParticipantDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoiceParticipantDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.cfSessionId, cfSessionId) || other.cfSessionId == cfSessionId)&&(identical(other.audioTrackName, audioTrackName) || other.audioTrackName == audioTrackName)&&(identical(other.isSelfMuted, isSelfMuted) || other.isSelfMuted == isSelfMuted)&&(identical(other.isSelfDeafened, isSelfDeafened) || other.isSelfDeafened == isSelfDeafened)&&(identical(other.isServerMuted, isServerMuted) || other.isServerMuted == isServerMuted)&&(identical(other.isServerDeafened, isServerDeafened) || other.isServerDeafened == isServerDeafened)&&(identical(other.isStreaming, isStreaming) || other.isStreaming == isStreaming)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,channelId,guildId,cfSessionId,audioTrackName,isSelfMuted,isSelfDeafened,isServerMuted,isServerDeafened,isStreaming,joinedAt);

@override
String toString() {
  return 'VoiceParticipantDto(userId: $userId, channelId: $channelId, guildId: $guildId, cfSessionId: $cfSessionId, audioTrackName: $audioTrackName, isSelfMuted: $isSelfMuted, isSelfDeafened: $isSelfDeafened, isServerMuted: $isServerMuted, isServerDeafened: $isServerDeafened, isStreaming: $isStreaming, joinedAt: $joinedAt)';
}


}

/// @nodoc
abstract mixin class _$VoiceParticipantDtoCopyWith<$Res> implements $VoiceParticipantDtoCopyWith<$Res> {
  factory _$VoiceParticipantDtoCopyWith(_VoiceParticipantDto value, $Res Function(_VoiceParticipantDto) _then) = __$VoiceParticipantDtoCopyWithImpl;
@override @useResult
$Res call({
 String userId, String channelId, String guildId, String? cfSessionId, String? audioTrackName, bool isSelfMuted, bool isSelfDeafened, bool isServerMuted, bool isServerDeafened, bool isStreaming, String? joinedAt
});




}
/// @nodoc
class __$VoiceParticipantDtoCopyWithImpl<$Res>
    implements _$VoiceParticipantDtoCopyWith<$Res> {
  __$VoiceParticipantDtoCopyWithImpl(this._self, this._then);

  final _VoiceParticipantDto _self;
  final $Res Function(_VoiceParticipantDto) _then;

/// Create a copy of VoiceParticipantDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? channelId = null,Object? guildId = null,Object? cfSessionId = freezed,Object? audioTrackName = freezed,Object? isSelfMuted = null,Object? isSelfDeafened = null,Object? isServerMuted = null,Object? isServerDeafened = null,Object? isStreaming = null,Object? joinedAt = freezed,}) {
  return _then(_VoiceParticipantDto(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,cfSessionId: freezed == cfSessionId ? _self.cfSessionId : cfSessionId // ignore: cast_nullable_to_non_nullable
as String?,audioTrackName: freezed == audioTrackName ? _self.audioTrackName : audioTrackName // ignore: cast_nullable_to_non_nullable
as String?,isSelfMuted: null == isSelfMuted ? _self.isSelfMuted : isSelfMuted // ignore: cast_nullable_to_non_nullable
as bool,isSelfDeafened: null == isSelfDeafened ? _self.isSelfDeafened : isSelfDeafened // ignore: cast_nullable_to_non_nullable
as bool,isServerMuted: null == isServerMuted ? _self.isServerMuted : isServerMuted // ignore: cast_nullable_to_non_nullable
as bool,isServerDeafened: null == isServerDeafened ? _self.isServerDeafened : isServerDeafened // ignore: cast_nullable_to_non_nullable
as bool,isStreaming: null == isStreaming ? _self.isStreaming : isStreaming // ignore: cast_nullable_to_non_nullable
as bool,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$VoiceStateDto {

 String get channelId; String get guildId; List<VoiceParticipantDto> get participants;
/// Create a copy of VoiceStateDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceStateDtoCopyWith<VoiceStateDto> get copyWith => _$VoiceStateDtoCopyWithImpl<VoiceStateDto>(this as VoiceStateDto, _$identity);

  /// Serializes this VoiceStateDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceStateDto&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&const DeepCollectionEquality().equals(other.participants, participants));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,channelId,guildId,const DeepCollectionEquality().hash(participants));

@override
String toString() {
  return 'VoiceStateDto(channelId: $channelId, guildId: $guildId, participants: $participants)';
}


}

/// @nodoc
abstract mixin class $VoiceStateDtoCopyWith<$Res>  {
  factory $VoiceStateDtoCopyWith(VoiceStateDto value, $Res Function(VoiceStateDto) _then) = _$VoiceStateDtoCopyWithImpl;
@useResult
$Res call({
 String channelId, String guildId, List<VoiceParticipantDto> participants
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
@pragma('vm:prefer-inline') @override $Res call({Object? channelId = null,Object? guildId = null,Object? participants = null,}) {
  return _then(_self.copyWith(
channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,participants: null == participants ? _self.participants : participants // ignore: cast_nullable_to_non_nullable
as List<VoiceParticipantDto>,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String channelId,  String guildId,  List<VoiceParticipantDto> participants)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoiceStateDto() when $default != null:
return $default(_that.channelId,_that.guildId,_that.participants);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String channelId,  String guildId,  List<VoiceParticipantDto> participants)  $default,) {final _that = this;
switch (_that) {
case _VoiceStateDto():
return $default(_that.channelId,_that.guildId,_that.participants);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String channelId,  String guildId,  List<VoiceParticipantDto> participants)?  $default,) {final _that = this;
switch (_that) {
case _VoiceStateDto() when $default != null:
return $default(_that.channelId,_that.guildId,_that.participants);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoiceStateDto implements VoiceStateDto {
  const _VoiceStateDto({required this.channelId, required this.guildId, final  List<VoiceParticipantDto> participants = const <VoiceParticipantDto>[]}): _participants = participants;
  factory _VoiceStateDto.fromJson(Map<String, dynamic> json) => _$VoiceStateDtoFromJson(json);

@override final  String channelId;
@override final  String guildId;
 final  List<VoiceParticipantDto> _participants;
@override@JsonKey() List<VoiceParticipantDto> get participants {
  if (_participants is EqualUnmodifiableListView) return _participants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participants);
}


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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoiceStateDto&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&const DeepCollectionEquality().equals(other._participants, _participants));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,channelId,guildId,const DeepCollectionEquality().hash(_participants));

@override
String toString() {
  return 'VoiceStateDto(channelId: $channelId, guildId: $guildId, participants: $participants)';
}


}

/// @nodoc
abstract mixin class _$VoiceStateDtoCopyWith<$Res> implements $VoiceStateDtoCopyWith<$Res> {
  factory _$VoiceStateDtoCopyWith(_VoiceStateDto value, $Res Function(_VoiceStateDto) _then) = __$VoiceStateDtoCopyWithImpl;
@override @useResult
$Res call({
 String channelId, String guildId, List<VoiceParticipantDto> participants
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
@override @pragma('vm:prefer-inline') $Res call({Object? channelId = null,Object? guildId = null,Object? participants = null,}) {
  return _then(_VoiceStateDto(
channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,participants: null == participants ? _self._participants : participants // ignore: cast_nullable_to_non_nullable
as List<VoiceParticipantDto>,
  ));
}


}

// dart format on
