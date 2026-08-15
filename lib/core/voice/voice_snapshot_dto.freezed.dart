// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voice_snapshot_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VoiceShareDto {

 String get shareId; List<String> get trackNames; String? get mediaSessionId;
/// Create a copy of VoiceShareDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceShareDtoCopyWith<VoiceShareDto> get copyWith => _$VoiceShareDtoCopyWithImpl<VoiceShareDto>(this as VoiceShareDto, _$identity);

  /// Serializes this VoiceShareDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceShareDto&&(identical(other.shareId, shareId) || other.shareId == shareId)&&const DeepCollectionEquality().equals(other.trackNames, trackNames)&&(identical(other.mediaSessionId, mediaSessionId) || other.mediaSessionId == mediaSessionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,shareId,const DeepCollectionEquality().hash(trackNames),mediaSessionId);

@override
String toString() {
  return 'VoiceShareDto(shareId: $shareId, trackNames: $trackNames, mediaSessionId: $mediaSessionId)';
}


}

/// @nodoc
abstract mixin class $VoiceShareDtoCopyWith<$Res>  {
  factory $VoiceShareDtoCopyWith(VoiceShareDto value, $Res Function(VoiceShareDto) _then) = _$VoiceShareDtoCopyWithImpl;
@useResult
$Res call({
 String shareId, List<String> trackNames, String? mediaSessionId
});




}
/// @nodoc
class _$VoiceShareDtoCopyWithImpl<$Res>
    implements $VoiceShareDtoCopyWith<$Res> {
  _$VoiceShareDtoCopyWithImpl(this._self, this._then);

  final VoiceShareDto _self;
  final $Res Function(VoiceShareDto) _then;

/// Create a copy of VoiceShareDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? shareId = null,Object? trackNames = null,Object? mediaSessionId = freezed,}) {
  return _then(_self.copyWith(
shareId: null == shareId ? _self.shareId : shareId // ignore: cast_nullable_to_non_nullable
as String,trackNames: null == trackNames ? _self.trackNames : trackNames // ignore: cast_nullable_to_non_nullable
as List<String>,mediaSessionId: freezed == mediaSessionId ? _self.mediaSessionId : mediaSessionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VoiceShareDto].
extension VoiceShareDtoPatterns on VoiceShareDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoiceShareDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoiceShareDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoiceShareDto value)  $default,){
final _that = this;
switch (_that) {
case _VoiceShareDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoiceShareDto value)?  $default,){
final _that = this;
switch (_that) {
case _VoiceShareDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String shareId,  List<String> trackNames,  String? mediaSessionId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoiceShareDto() when $default != null:
return $default(_that.shareId,_that.trackNames,_that.mediaSessionId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String shareId,  List<String> trackNames,  String? mediaSessionId)  $default,) {final _that = this;
switch (_that) {
case _VoiceShareDto():
return $default(_that.shareId,_that.trackNames,_that.mediaSessionId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String shareId,  List<String> trackNames,  String? mediaSessionId)?  $default,) {final _that = this;
switch (_that) {
case _VoiceShareDto() when $default != null:
return $default(_that.shareId,_that.trackNames,_that.mediaSessionId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoiceShareDto extends VoiceShareDto {
  const _VoiceShareDto({required this.shareId, final  List<String> trackNames = const <String>[], this.mediaSessionId}): _trackNames = trackNames,super._();
  factory _VoiceShareDto.fromJson(Map<String, dynamic> json) => _$VoiceShareDtoFromJson(json);

@override final  String shareId;
 final  List<String> _trackNames;
@override@JsonKey() List<String> get trackNames {
  if (_trackNames is EqualUnmodifiableListView) return _trackNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_trackNames);
}

@override final  String? mediaSessionId;

/// Create a copy of VoiceShareDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoiceShareDtoCopyWith<_VoiceShareDto> get copyWith => __$VoiceShareDtoCopyWithImpl<_VoiceShareDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoiceShareDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoiceShareDto&&(identical(other.shareId, shareId) || other.shareId == shareId)&&const DeepCollectionEquality().equals(other._trackNames, _trackNames)&&(identical(other.mediaSessionId, mediaSessionId) || other.mediaSessionId == mediaSessionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,shareId,const DeepCollectionEquality().hash(_trackNames),mediaSessionId);

@override
String toString() {
  return 'VoiceShareDto(shareId: $shareId, trackNames: $trackNames, mediaSessionId: $mediaSessionId)';
}


}

/// @nodoc
abstract mixin class _$VoiceShareDtoCopyWith<$Res> implements $VoiceShareDtoCopyWith<$Res> {
  factory _$VoiceShareDtoCopyWith(_VoiceShareDto value, $Res Function(_VoiceShareDto) _then) = __$VoiceShareDtoCopyWithImpl;
@override @useResult
$Res call({
 String shareId, List<String> trackNames, String? mediaSessionId
});




}
/// @nodoc
class __$VoiceShareDtoCopyWithImpl<$Res>
    implements _$VoiceShareDtoCopyWith<$Res> {
  __$VoiceShareDtoCopyWithImpl(this._self, this._then);

  final _VoiceShareDto _self;
  final $Res Function(_VoiceShareDto) _then;

/// Create a copy of VoiceShareDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? shareId = null,Object? trackNames = null,Object? mediaSessionId = freezed,}) {
  return _then(_VoiceShareDto(
shareId: null == shareId ? _self.shareId : shareId // ignore: cast_nullable_to_non_nullable
as String,trackNames: null == trackNames ? _self._trackNames : trackNames // ignore: cast_nullable_to_non_nullable
as List<String>,mediaSessionId: freezed == mediaSessionId ? _self.mediaSessionId : mediaSessionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$VoiceParticipantSnapshotDto {

 String get userId; String? get mediaSessionId; String? get audioTrackName; String get publishState; bool get isSelfMuted; bool get isSelfDeafened; bool get isServerMuted; bool get isServerDeafened; bool get isStreaming; List<VoiceShareDto> get shares; DateTime? get joinedAt;
/// Create a copy of VoiceParticipantSnapshotDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceParticipantSnapshotDtoCopyWith<VoiceParticipantSnapshotDto> get copyWith => _$VoiceParticipantSnapshotDtoCopyWithImpl<VoiceParticipantSnapshotDto>(this as VoiceParticipantSnapshotDto, _$identity);

  /// Serializes this VoiceParticipantSnapshotDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceParticipantSnapshotDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.mediaSessionId, mediaSessionId) || other.mediaSessionId == mediaSessionId)&&(identical(other.audioTrackName, audioTrackName) || other.audioTrackName == audioTrackName)&&(identical(other.publishState, publishState) || other.publishState == publishState)&&(identical(other.isSelfMuted, isSelfMuted) || other.isSelfMuted == isSelfMuted)&&(identical(other.isSelfDeafened, isSelfDeafened) || other.isSelfDeafened == isSelfDeafened)&&(identical(other.isServerMuted, isServerMuted) || other.isServerMuted == isServerMuted)&&(identical(other.isServerDeafened, isServerDeafened) || other.isServerDeafened == isServerDeafened)&&(identical(other.isStreaming, isStreaming) || other.isStreaming == isStreaming)&&const DeepCollectionEquality().equals(other.shares, shares)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,mediaSessionId,audioTrackName,publishState,isSelfMuted,isSelfDeafened,isServerMuted,isServerDeafened,isStreaming,const DeepCollectionEquality().hash(shares),joinedAt);

@override
String toString() {
  return 'VoiceParticipantSnapshotDto(userId: $userId, mediaSessionId: $mediaSessionId, audioTrackName: $audioTrackName, publishState: $publishState, isSelfMuted: $isSelfMuted, isSelfDeafened: $isSelfDeafened, isServerMuted: $isServerMuted, isServerDeafened: $isServerDeafened, isStreaming: $isStreaming, shares: $shares, joinedAt: $joinedAt)';
}


}

/// @nodoc
abstract mixin class $VoiceParticipantSnapshotDtoCopyWith<$Res>  {
  factory $VoiceParticipantSnapshotDtoCopyWith(VoiceParticipantSnapshotDto value, $Res Function(VoiceParticipantSnapshotDto) _then) = _$VoiceParticipantSnapshotDtoCopyWithImpl;
@useResult
$Res call({
 String userId, String? mediaSessionId, String? audioTrackName, String publishState, bool isSelfMuted, bool isSelfDeafened, bool isServerMuted, bool isServerDeafened, bool isStreaming, List<VoiceShareDto> shares, DateTime? joinedAt
});




}
/// @nodoc
class _$VoiceParticipantSnapshotDtoCopyWithImpl<$Res>
    implements $VoiceParticipantSnapshotDtoCopyWith<$Res> {
  _$VoiceParticipantSnapshotDtoCopyWithImpl(this._self, this._then);

  final VoiceParticipantSnapshotDto _self;
  final $Res Function(VoiceParticipantSnapshotDto) _then;

/// Create a copy of VoiceParticipantSnapshotDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? mediaSessionId = freezed,Object? audioTrackName = freezed,Object? publishState = null,Object? isSelfMuted = null,Object? isSelfDeafened = null,Object? isServerMuted = null,Object? isServerDeafened = null,Object? isStreaming = null,Object? shares = null,Object? joinedAt = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,mediaSessionId: freezed == mediaSessionId ? _self.mediaSessionId : mediaSessionId // ignore: cast_nullable_to_non_nullable
as String?,audioTrackName: freezed == audioTrackName ? _self.audioTrackName : audioTrackName // ignore: cast_nullable_to_non_nullable
as String?,publishState: null == publishState ? _self.publishState : publishState // ignore: cast_nullable_to_non_nullable
as String,isSelfMuted: null == isSelfMuted ? _self.isSelfMuted : isSelfMuted // ignore: cast_nullable_to_non_nullable
as bool,isSelfDeafened: null == isSelfDeafened ? _self.isSelfDeafened : isSelfDeafened // ignore: cast_nullable_to_non_nullable
as bool,isServerMuted: null == isServerMuted ? _self.isServerMuted : isServerMuted // ignore: cast_nullable_to_non_nullable
as bool,isServerDeafened: null == isServerDeafened ? _self.isServerDeafened : isServerDeafened // ignore: cast_nullable_to_non_nullable
as bool,isStreaming: null == isStreaming ? _self.isStreaming : isStreaming // ignore: cast_nullable_to_non_nullable
as bool,shares: null == shares ? _self.shares : shares // ignore: cast_nullable_to_non_nullable
as List<VoiceShareDto>,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [VoiceParticipantSnapshotDto].
extension VoiceParticipantSnapshotDtoPatterns on VoiceParticipantSnapshotDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoiceParticipantSnapshotDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoiceParticipantSnapshotDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoiceParticipantSnapshotDto value)  $default,){
final _that = this;
switch (_that) {
case _VoiceParticipantSnapshotDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoiceParticipantSnapshotDto value)?  $default,){
final _that = this;
switch (_that) {
case _VoiceParticipantSnapshotDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String? mediaSessionId,  String? audioTrackName,  String publishState,  bool isSelfMuted,  bool isSelfDeafened,  bool isServerMuted,  bool isServerDeafened,  bool isStreaming,  List<VoiceShareDto> shares,  DateTime? joinedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoiceParticipantSnapshotDto() when $default != null:
return $default(_that.userId,_that.mediaSessionId,_that.audioTrackName,_that.publishState,_that.isSelfMuted,_that.isSelfDeafened,_that.isServerMuted,_that.isServerDeafened,_that.isStreaming,_that.shares,_that.joinedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String? mediaSessionId,  String? audioTrackName,  String publishState,  bool isSelfMuted,  bool isSelfDeafened,  bool isServerMuted,  bool isServerDeafened,  bool isStreaming,  List<VoiceShareDto> shares,  DateTime? joinedAt)  $default,) {final _that = this;
switch (_that) {
case _VoiceParticipantSnapshotDto():
return $default(_that.userId,_that.mediaSessionId,_that.audioTrackName,_that.publishState,_that.isSelfMuted,_that.isSelfDeafened,_that.isServerMuted,_that.isServerDeafened,_that.isStreaming,_that.shares,_that.joinedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String? mediaSessionId,  String? audioTrackName,  String publishState,  bool isSelfMuted,  bool isSelfDeafened,  bool isServerMuted,  bool isServerDeafened,  bool isStreaming,  List<VoiceShareDto> shares,  DateTime? joinedAt)?  $default,) {final _that = this;
switch (_that) {
case _VoiceParticipantSnapshotDto() when $default != null:
return $default(_that.userId,_that.mediaSessionId,_that.audioTrackName,_that.publishState,_that.isSelfMuted,_that.isSelfDeafened,_that.isServerMuted,_that.isServerDeafened,_that.isStreaming,_that.shares,_that.joinedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _VoiceParticipantSnapshotDto extends VoiceParticipantSnapshotDto {
  const _VoiceParticipantSnapshotDto({required this.userId, this.mediaSessionId, this.audioTrackName, this.publishState = VoicePublishState.joined, this.isSelfMuted = false, this.isSelfDeafened = false, this.isServerMuted = false, this.isServerDeafened = false, this.isStreaming = false, final  List<VoiceShareDto> shares = const <VoiceShareDto>[], this.joinedAt}): _shares = shares,super._();
  factory _VoiceParticipantSnapshotDto.fromJson(Map<String, dynamic> json) => _$VoiceParticipantSnapshotDtoFromJson(json);

@override final  String userId;
@override final  String? mediaSessionId;
@override final  String? audioTrackName;
@override@JsonKey() final  String publishState;
@override@JsonKey() final  bool isSelfMuted;
@override@JsonKey() final  bool isSelfDeafened;
@override@JsonKey() final  bool isServerMuted;
@override@JsonKey() final  bool isServerDeafened;
@override@JsonKey() final  bool isStreaming;
 final  List<VoiceShareDto> _shares;
@override@JsonKey() List<VoiceShareDto> get shares {
  if (_shares is EqualUnmodifiableListView) return _shares;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_shares);
}

@override final  DateTime? joinedAt;

/// Create a copy of VoiceParticipantSnapshotDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoiceParticipantSnapshotDtoCopyWith<_VoiceParticipantSnapshotDto> get copyWith => __$VoiceParticipantSnapshotDtoCopyWithImpl<_VoiceParticipantSnapshotDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoiceParticipantSnapshotDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoiceParticipantSnapshotDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.mediaSessionId, mediaSessionId) || other.mediaSessionId == mediaSessionId)&&(identical(other.audioTrackName, audioTrackName) || other.audioTrackName == audioTrackName)&&(identical(other.publishState, publishState) || other.publishState == publishState)&&(identical(other.isSelfMuted, isSelfMuted) || other.isSelfMuted == isSelfMuted)&&(identical(other.isSelfDeafened, isSelfDeafened) || other.isSelfDeafened == isSelfDeafened)&&(identical(other.isServerMuted, isServerMuted) || other.isServerMuted == isServerMuted)&&(identical(other.isServerDeafened, isServerDeafened) || other.isServerDeafened == isServerDeafened)&&(identical(other.isStreaming, isStreaming) || other.isStreaming == isStreaming)&&const DeepCollectionEquality().equals(other._shares, _shares)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,mediaSessionId,audioTrackName,publishState,isSelfMuted,isSelfDeafened,isServerMuted,isServerDeafened,isStreaming,const DeepCollectionEquality().hash(_shares),joinedAt);

@override
String toString() {
  return 'VoiceParticipantSnapshotDto(userId: $userId, mediaSessionId: $mediaSessionId, audioTrackName: $audioTrackName, publishState: $publishState, isSelfMuted: $isSelfMuted, isSelfDeafened: $isSelfDeafened, isServerMuted: $isServerMuted, isServerDeafened: $isServerDeafened, isStreaming: $isStreaming, shares: $shares, joinedAt: $joinedAt)';
}


}

/// @nodoc
abstract mixin class _$VoiceParticipantSnapshotDtoCopyWith<$Res> implements $VoiceParticipantSnapshotDtoCopyWith<$Res> {
  factory _$VoiceParticipantSnapshotDtoCopyWith(_VoiceParticipantSnapshotDto value, $Res Function(_VoiceParticipantSnapshotDto) _then) = __$VoiceParticipantSnapshotDtoCopyWithImpl;
@override @useResult
$Res call({
 String userId, String? mediaSessionId, String? audioTrackName, String publishState, bool isSelfMuted, bool isSelfDeafened, bool isServerMuted, bool isServerDeafened, bool isStreaming, List<VoiceShareDto> shares, DateTime? joinedAt
});




}
/// @nodoc
class __$VoiceParticipantSnapshotDtoCopyWithImpl<$Res>
    implements _$VoiceParticipantSnapshotDtoCopyWith<$Res> {
  __$VoiceParticipantSnapshotDtoCopyWithImpl(this._self, this._then);

  final _VoiceParticipantSnapshotDto _self;
  final $Res Function(_VoiceParticipantSnapshotDto) _then;

/// Create a copy of VoiceParticipantSnapshotDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? mediaSessionId = freezed,Object? audioTrackName = freezed,Object? publishState = null,Object? isSelfMuted = null,Object? isSelfDeafened = null,Object? isServerMuted = null,Object? isServerDeafened = null,Object? isStreaming = null,Object? shares = null,Object? joinedAt = freezed,}) {
  return _then(_VoiceParticipantSnapshotDto(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,mediaSessionId: freezed == mediaSessionId ? _self.mediaSessionId : mediaSessionId // ignore: cast_nullable_to_non_nullable
as String?,audioTrackName: freezed == audioTrackName ? _self.audioTrackName : audioTrackName // ignore: cast_nullable_to_non_nullable
as String?,publishState: null == publishState ? _self.publishState : publishState // ignore: cast_nullable_to_non_nullable
as String,isSelfMuted: null == isSelfMuted ? _self.isSelfMuted : isSelfMuted // ignore: cast_nullable_to_non_nullable
as bool,isSelfDeafened: null == isSelfDeafened ? _self.isSelfDeafened : isSelfDeafened // ignore: cast_nullable_to_non_nullable
as bool,isServerMuted: null == isServerMuted ? _self.isServerMuted : isServerMuted // ignore: cast_nullable_to_non_nullable
as bool,isServerDeafened: null == isServerDeafened ? _self.isServerDeafened : isServerDeafened // ignore: cast_nullable_to_non_nullable
as bool,isStreaming: null == isStreaming ? _self.isStreaming : isStreaming // ignore: cast_nullable_to_non_nullable
as bool,shares: null == shares ? _self._shares : shares // ignore: cast_nullable_to_non_nullable
as List<VoiceShareDto>,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$VoiceRoomSnapshotDto {

 String get roomId; String get kind;/// Null for calls, exactly as the server leaves it absent there.
 String? get guildId;/// Identifies this incarnation of the room. A blank instance is an empty
/// room the server does not actually have - never adopt it as a baseline.
 String get instanceId; int get version; List<VoiceParticipantSnapshotDto> get participants;/// What this room may carry. Absent on a room whose limits have never been
/// computed, and on every server that predates them - which is why it is
/// nullable rather than defaulted: an empty [VoiceRoomLimitsDto] would say
/// "no ceilings" where the truth is "nobody said".
@JsonKey(fromJson: voiceRoomLimitsFromJson, toJson: voiceRoomLimitsToJson) VoiceRoomLimitsDto? get limits;
/// Create a copy of VoiceRoomSnapshotDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceRoomSnapshotDtoCopyWith<VoiceRoomSnapshotDto> get copyWith => _$VoiceRoomSnapshotDtoCopyWithImpl<VoiceRoomSnapshotDto>(this as VoiceRoomSnapshotDto, _$identity);

  /// Serializes this VoiceRoomSnapshotDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceRoomSnapshotDto&&(identical(other.roomId, roomId) || other.roomId == roomId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.instanceId, instanceId) || other.instanceId == instanceId)&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other.participants, participants)&&(identical(other.limits, limits) || other.limits == limits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,roomId,kind,guildId,instanceId,version,const DeepCollectionEquality().hash(participants),limits);

@override
String toString() {
  return 'VoiceRoomSnapshotDto(roomId: $roomId, kind: $kind, guildId: $guildId, instanceId: $instanceId, version: $version, participants: $participants, limits: $limits)';
}


}

/// @nodoc
abstract mixin class $VoiceRoomSnapshotDtoCopyWith<$Res>  {
  factory $VoiceRoomSnapshotDtoCopyWith(VoiceRoomSnapshotDto value, $Res Function(VoiceRoomSnapshotDto) _then) = _$VoiceRoomSnapshotDtoCopyWithImpl;
@useResult
$Res call({
 String roomId, String kind, String? guildId, String instanceId, int version, List<VoiceParticipantSnapshotDto> participants,@JsonKey(fromJson: voiceRoomLimitsFromJson, toJson: voiceRoomLimitsToJson) VoiceRoomLimitsDto? limits
});




}
/// @nodoc
class _$VoiceRoomSnapshotDtoCopyWithImpl<$Res>
    implements $VoiceRoomSnapshotDtoCopyWith<$Res> {
  _$VoiceRoomSnapshotDtoCopyWithImpl(this._self, this._then);

  final VoiceRoomSnapshotDto _self;
  final $Res Function(VoiceRoomSnapshotDto) _then;

/// Create a copy of VoiceRoomSnapshotDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? roomId = null,Object? kind = null,Object? guildId = freezed,Object? instanceId = null,Object? version = null,Object? participants = null,Object? limits = freezed,}) {
  return _then(_self.copyWith(
roomId: null == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,guildId: freezed == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String?,instanceId: null == instanceId ? _self.instanceId : instanceId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,participants: null == participants ? _self.participants : participants // ignore: cast_nullable_to_non_nullable
as List<VoiceParticipantSnapshotDto>,limits: freezed == limits ? _self.limits : limits // ignore: cast_nullable_to_non_nullable
as VoiceRoomLimitsDto?,
  ));
}

}


/// Adds pattern-matching-related methods to [VoiceRoomSnapshotDto].
extension VoiceRoomSnapshotDtoPatterns on VoiceRoomSnapshotDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoiceRoomSnapshotDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoiceRoomSnapshotDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoiceRoomSnapshotDto value)  $default,){
final _that = this;
switch (_that) {
case _VoiceRoomSnapshotDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoiceRoomSnapshotDto value)?  $default,){
final _that = this;
switch (_that) {
case _VoiceRoomSnapshotDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String roomId,  String kind,  String? guildId,  String instanceId,  int version,  List<VoiceParticipantSnapshotDto> participants, @JsonKey(fromJson: voiceRoomLimitsFromJson, toJson: voiceRoomLimitsToJson)  VoiceRoomLimitsDto? limits)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoiceRoomSnapshotDto() when $default != null:
return $default(_that.roomId,_that.kind,_that.guildId,_that.instanceId,_that.version,_that.participants,_that.limits);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String roomId,  String kind,  String? guildId,  String instanceId,  int version,  List<VoiceParticipantSnapshotDto> participants, @JsonKey(fromJson: voiceRoomLimitsFromJson, toJson: voiceRoomLimitsToJson)  VoiceRoomLimitsDto? limits)  $default,) {final _that = this;
switch (_that) {
case _VoiceRoomSnapshotDto():
return $default(_that.roomId,_that.kind,_that.guildId,_that.instanceId,_that.version,_that.participants,_that.limits);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String roomId,  String kind,  String? guildId,  String instanceId,  int version,  List<VoiceParticipantSnapshotDto> participants, @JsonKey(fromJson: voiceRoomLimitsFromJson, toJson: voiceRoomLimitsToJson)  VoiceRoomLimitsDto? limits)?  $default,) {final _that = this;
switch (_that) {
case _VoiceRoomSnapshotDto() when $default != null:
return $default(_that.roomId,_that.kind,_that.guildId,_that.instanceId,_that.version,_that.participants,_that.limits);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoiceRoomSnapshotDto extends VoiceRoomSnapshotDto {
  const _VoiceRoomSnapshotDto({required this.roomId, required this.kind, this.guildId, this.instanceId = '', this.version = 0, final  List<VoiceParticipantSnapshotDto> participants = const <VoiceParticipantSnapshotDto>[], @JsonKey(fromJson: voiceRoomLimitsFromJson, toJson: voiceRoomLimitsToJson) this.limits}): _participants = participants,super._();
  factory _VoiceRoomSnapshotDto.fromJson(Map<String, dynamic> json) => _$VoiceRoomSnapshotDtoFromJson(json);

@override final  String roomId;
@override final  String kind;
/// Null for calls, exactly as the server leaves it absent there.
@override final  String? guildId;
/// Identifies this incarnation of the room. A blank instance is an empty
/// room the server does not actually have - never adopt it as a baseline.
@override@JsonKey() final  String instanceId;
@override@JsonKey() final  int version;
 final  List<VoiceParticipantSnapshotDto> _participants;
@override@JsonKey() List<VoiceParticipantSnapshotDto> get participants {
  if (_participants is EqualUnmodifiableListView) return _participants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participants);
}

/// What this room may carry. Absent on a room whose limits have never been
/// computed, and on every server that predates them - which is why it is
/// nullable rather than defaulted: an empty [VoiceRoomLimitsDto] would say
/// "no ceilings" where the truth is "nobody said".
@override@JsonKey(fromJson: voiceRoomLimitsFromJson, toJson: voiceRoomLimitsToJson) final  VoiceRoomLimitsDto? limits;

/// Create a copy of VoiceRoomSnapshotDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoiceRoomSnapshotDtoCopyWith<_VoiceRoomSnapshotDto> get copyWith => __$VoiceRoomSnapshotDtoCopyWithImpl<_VoiceRoomSnapshotDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoiceRoomSnapshotDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoiceRoomSnapshotDto&&(identical(other.roomId, roomId) || other.roomId == roomId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.instanceId, instanceId) || other.instanceId == instanceId)&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other._participants, _participants)&&(identical(other.limits, limits) || other.limits == limits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,roomId,kind,guildId,instanceId,version,const DeepCollectionEquality().hash(_participants),limits);

@override
String toString() {
  return 'VoiceRoomSnapshotDto(roomId: $roomId, kind: $kind, guildId: $guildId, instanceId: $instanceId, version: $version, participants: $participants, limits: $limits)';
}


}

/// @nodoc
abstract mixin class _$VoiceRoomSnapshotDtoCopyWith<$Res> implements $VoiceRoomSnapshotDtoCopyWith<$Res> {
  factory _$VoiceRoomSnapshotDtoCopyWith(_VoiceRoomSnapshotDto value, $Res Function(_VoiceRoomSnapshotDto) _then) = __$VoiceRoomSnapshotDtoCopyWithImpl;
@override @useResult
$Res call({
 String roomId, String kind, String? guildId, String instanceId, int version, List<VoiceParticipantSnapshotDto> participants,@JsonKey(fromJson: voiceRoomLimitsFromJson, toJson: voiceRoomLimitsToJson) VoiceRoomLimitsDto? limits
});




}
/// @nodoc
class __$VoiceRoomSnapshotDtoCopyWithImpl<$Res>
    implements _$VoiceRoomSnapshotDtoCopyWith<$Res> {
  __$VoiceRoomSnapshotDtoCopyWithImpl(this._self, this._then);

  final _VoiceRoomSnapshotDto _self;
  final $Res Function(_VoiceRoomSnapshotDto) _then;

/// Create a copy of VoiceRoomSnapshotDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? roomId = null,Object? kind = null,Object? guildId = freezed,Object? instanceId = null,Object? version = null,Object? participants = null,Object? limits = freezed,}) {
  return _then(_VoiceRoomSnapshotDto(
roomId: null == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,guildId: freezed == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String?,instanceId: null == instanceId ? _self.instanceId : instanceId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,participants: null == participants ? _self._participants : participants // ignore: cast_nullable_to_non_nullable
as List<VoiceParticipantSnapshotDto>,limits: freezed == limits ? _self.limits : limits // ignore: cast_nullable_to_non_nullable
as VoiceRoomLimitsDto?,
  ));
}


}

// dart format on
