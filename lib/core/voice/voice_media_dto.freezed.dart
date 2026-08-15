// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voice_media_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VoiceSessionDto {

 String get mediaSessionId; String get backend;
/// Create a copy of VoiceSessionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceSessionDtoCopyWith<VoiceSessionDto> get copyWith => _$VoiceSessionDtoCopyWithImpl<VoiceSessionDto>(this as VoiceSessionDto, _$identity);

  /// Serializes this VoiceSessionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceSessionDto&&(identical(other.mediaSessionId, mediaSessionId) || other.mediaSessionId == mediaSessionId)&&(identical(other.backend, backend) || other.backend == backend));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaSessionId,backend);

@override
String toString() {
  return 'VoiceSessionDto(mediaSessionId: $mediaSessionId, backend: $backend)';
}


}

/// @nodoc
abstract mixin class $VoiceSessionDtoCopyWith<$Res>  {
  factory $VoiceSessionDtoCopyWith(VoiceSessionDto value, $Res Function(VoiceSessionDto) _then) = _$VoiceSessionDtoCopyWithImpl;
@useResult
$Res call({
 String mediaSessionId, String backend
});




}
/// @nodoc
class _$VoiceSessionDtoCopyWithImpl<$Res>
    implements $VoiceSessionDtoCopyWith<$Res> {
  _$VoiceSessionDtoCopyWithImpl(this._self, this._then);

  final VoiceSessionDto _self;
  final $Res Function(VoiceSessionDto) _then;

/// Create a copy of VoiceSessionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mediaSessionId = null,Object? backend = null,}) {
  return _then(_self.copyWith(
mediaSessionId: null == mediaSessionId ? _self.mediaSessionId : mediaSessionId // ignore: cast_nullable_to_non_nullable
as String,backend: null == backend ? _self.backend : backend // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VoiceSessionDto].
extension VoiceSessionDtoPatterns on VoiceSessionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoiceSessionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoiceSessionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoiceSessionDto value)  $default,){
final _that = this;
switch (_that) {
case _VoiceSessionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoiceSessionDto value)?  $default,){
final _that = this;
switch (_that) {
case _VoiceSessionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String mediaSessionId,  String backend)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoiceSessionDto() when $default != null:
return $default(_that.mediaSessionId,_that.backend);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String mediaSessionId,  String backend)  $default,) {final _that = this;
switch (_that) {
case _VoiceSessionDto():
return $default(_that.mediaSessionId,_that.backend);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String mediaSessionId,  String backend)?  $default,) {final _that = this;
switch (_that) {
case _VoiceSessionDto() when $default != null:
return $default(_that.mediaSessionId,_that.backend);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoiceSessionDto implements VoiceSessionDto {
  const _VoiceSessionDto({required this.mediaSessionId, this.backend = ''});
  factory _VoiceSessionDto.fromJson(Map<String, dynamic> json) => _$VoiceSessionDtoFromJson(json);

@override final  String mediaSessionId;
@override@JsonKey() final  String backend;

/// Create a copy of VoiceSessionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoiceSessionDtoCopyWith<_VoiceSessionDto> get copyWith => __$VoiceSessionDtoCopyWithImpl<_VoiceSessionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoiceSessionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoiceSessionDto&&(identical(other.mediaSessionId, mediaSessionId) || other.mediaSessionId == mediaSessionId)&&(identical(other.backend, backend) || other.backend == backend));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaSessionId,backend);

@override
String toString() {
  return 'VoiceSessionDto(mediaSessionId: $mediaSessionId, backend: $backend)';
}


}

/// @nodoc
abstract mixin class _$VoiceSessionDtoCopyWith<$Res> implements $VoiceSessionDtoCopyWith<$Res> {
  factory _$VoiceSessionDtoCopyWith(_VoiceSessionDto value, $Res Function(_VoiceSessionDto) _then) = __$VoiceSessionDtoCopyWithImpl;
@override @useResult
$Res call({
 String mediaSessionId, String backend
});




}
/// @nodoc
class __$VoiceSessionDtoCopyWithImpl<$Res>
    implements _$VoiceSessionDtoCopyWith<$Res> {
  __$VoiceSessionDtoCopyWithImpl(this._self, this._then);

  final _VoiceSessionDto _self;
  final $Res Function(_VoiceSessionDto) _then;

/// Create a copy of VoiceSessionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mediaSessionId = null,Object? backend = null,}) {
  return _then(_VoiceSessionDto(
mediaSessionId: null == mediaSessionId ? _self.mediaSessionId : mediaSessionId // ignore: cast_nullable_to_non_nullable
as String,backend: null == backend ? _self.backend : backend // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$VoiceTrackResultDto {

 String? get mid; String get trackName; String? get mediaSessionId; String? get direction;
/// Create a copy of VoiceTrackResultDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceTrackResultDtoCopyWith<VoiceTrackResultDto> get copyWith => _$VoiceTrackResultDtoCopyWithImpl<VoiceTrackResultDto>(this as VoiceTrackResultDto, _$identity);

  /// Serializes this VoiceTrackResultDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceTrackResultDto&&(identical(other.mid, mid) || other.mid == mid)&&(identical(other.trackName, trackName) || other.trackName == trackName)&&(identical(other.mediaSessionId, mediaSessionId) || other.mediaSessionId == mediaSessionId)&&(identical(other.direction, direction) || other.direction == direction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mid,trackName,mediaSessionId,direction);

@override
String toString() {
  return 'VoiceTrackResultDto(mid: $mid, trackName: $trackName, mediaSessionId: $mediaSessionId, direction: $direction)';
}


}

/// @nodoc
abstract mixin class $VoiceTrackResultDtoCopyWith<$Res>  {
  factory $VoiceTrackResultDtoCopyWith(VoiceTrackResultDto value, $Res Function(VoiceTrackResultDto) _then) = _$VoiceTrackResultDtoCopyWithImpl;
@useResult
$Res call({
 String? mid, String trackName, String? mediaSessionId, String? direction
});




}
/// @nodoc
class _$VoiceTrackResultDtoCopyWithImpl<$Res>
    implements $VoiceTrackResultDtoCopyWith<$Res> {
  _$VoiceTrackResultDtoCopyWithImpl(this._self, this._then);

  final VoiceTrackResultDto _self;
  final $Res Function(VoiceTrackResultDto) _then;

/// Create a copy of VoiceTrackResultDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mid = freezed,Object? trackName = null,Object? mediaSessionId = freezed,Object? direction = freezed,}) {
  return _then(_self.copyWith(
mid: freezed == mid ? _self.mid : mid // ignore: cast_nullable_to_non_nullable
as String?,trackName: null == trackName ? _self.trackName : trackName // ignore: cast_nullable_to_non_nullable
as String,mediaSessionId: freezed == mediaSessionId ? _self.mediaSessionId : mediaSessionId // ignore: cast_nullable_to_non_nullable
as String?,direction: freezed == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VoiceTrackResultDto].
extension VoiceTrackResultDtoPatterns on VoiceTrackResultDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoiceTrackResultDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoiceTrackResultDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoiceTrackResultDto value)  $default,){
final _that = this;
switch (_that) {
case _VoiceTrackResultDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoiceTrackResultDto value)?  $default,){
final _that = this;
switch (_that) {
case _VoiceTrackResultDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? mid,  String trackName,  String? mediaSessionId,  String? direction)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoiceTrackResultDto() when $default != null:
return $default(_that.mid,_that.trackName,_that.mediaSessionId,_that.direction);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? mid,  String trackName,  String? mediaSessionId,  String? direction)  $default,) {final _that = this;
switch (_that) {
case _VoiceTrackResultDto():
return $default(_that.mid,_that.trackName,_that.mediaSessionId,_that.direction);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? mid,  String trackName,  String? mediaSessionId,  String? direction)?  $default,) {final _that = this;
switch (_that) {
case _VoiceTrackResultDto() when $default != null:
return $default(_that.mid,_that.trackName,_that.mediaSessionId,_that.direction);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoiceTrackResultDto implements VoiceTrackResultDto {
  const _VoiceTrackResultDto({this.mid, required this.trackName, this.mediaSessionId, this.direction});
  factory _VoiceTrackResultDto.fromJson(Map<String, dynamic> json) => _$VoiceTrackResultDtoFromJson(json);

@override final  String? mid;
@override final  String trackName;
@override final  String? mediaSessionId;
@override final  String? direction;

/// Create a copy of VoiceTrackResultDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoiceTrackResultDtoCopyWith<_VoiceTrackResultDto> get copyWith => __$VoiceTrackResultDtoCopyWithImpl<_VoiceTrackResultDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoiceTrackResultDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoiceTrackResultDto&&(identical(other.mid, mid) || other.mid == mid)&&(identical(other.trackName, trackName) || other.trackName == trackName)&&(identical(other.mediaSessionId, mediaSessionId) || other.mediaSessionId == mediaSessionId)&&(identical(other.direction, direction) || other.direction == direction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mid,trackName,mediaSessionId,direction);

@override
String toString() {
  return 'VoiceTrackResultDto(mid: $mid, trackName: $trackName, mediaSessionId: $mediaSessionId, direction: $direction)';
}


}

/// @nodoc
abstract mixin class _$VoiceTrackResultDtoCopyWith<$Res> implements $VoiceTrackResultDtoCopyWith<$Res> {
  factory _$VoiceTrackResultDtoCopyWith(_VoiceTrackResultDto value, $Res Function(_VoiceTrackResultDto) _then) = __$VoiceTrackResultDtoCopyWithImpl;
@override @useResult
$Res call({
 String? mid, String trackName, String? mediaSessionId, String? direction
});




}
/// @nodoc
class __$VoiceTrackResultDtoCopyWithImpl<$Res>
    implements _$VoiceTrackResultDtoCopyWith<$Res> {
  __$VoiceTrackResultDtoCopyWithImpl(this._self, this._then);

  final _VoiceTrackResultDto _self;
  final $Res Function(_VoiceTrackResultDto) _then;

/// Create a copy of VoiceTrackResultDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mid = freezed,Object? trackName = null,Object? mediaSessionId = freezed,Object? direction = freezed,}) {
  return _then(_VoiceTrackResultDto(
mid: freezed == mid ? _self.mid : mid // ignore: cast_nullable_to_non_nullable
as String?,trackName: null == trackName ? _self.trackName : trackName // ignore: cast_nullable_to_non_nullable
as String,mediaSessionId: freezed == mediaSessionId ? _self.mediaSessionId : mediaSessionId // ignore: cast_nullable_to_non_nullable
as String?,direction: freezed == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$VoiceNegotiateResponseDto {

 Map<String, dynamic> get sessionDescription; List<VoiceTrackResultDto> get tracks; bool get requiresImmediateRenegotiation; List<EntitlementDegradationDto> get degradations;
/// Create a copy of VoiceNegotiateResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceNegotiateResponseDtoCopyWith<VoiceNegotiateResponseDto> get copyWith => _$VoiceNegotiateResponseDtoCopyWithImpl<VoiceNegotiateResponseDto>(this as VoiceNegotiateResponseDto, _$identity);

  /// Serializes this VoiceNegotiateResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceNegotiateResponseDto&&const DeepCollectionEquality().equals(other.sessionDescription, sessionDescription)&&const DeepCollectionEquality().equals(other.tracks, tracks)&&(identical(other.requiresImmediateRenegotiation, requiresImmediateRenegotiation) || other.requiresImmediateRenegotiation == requiresImmediateRenegotiation)&&const DeepCollectionEquality().equals(other.degradations, degradations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(sessionDescription),const DeepCollectionEquality().hash(tracks),requiresImmediateRenegotiation,const DeepCollectionEquality().hash(degradations));

@override
String toString() {
  return 'VoiceNegotiateResponseDto(sessionDescription: $sessionDescription, tracks: $tracks, requiresImmediateRenegotiation: $requiresImmediateRenegotiation, degradations: $degradations)';
}


}

/// @nodoc
abstract mixin class $VoiceNegotiateResponseDtoCopyWith<$Res>  {
  factory $VoiceNegotiateResponseDtoCopyWith(VoiceNegotiateResponseDto value, $Res Function(VoiceNegotiateResponseDto) _then) = _$VoiceNegotiateResponseDtoCopyWithImpl;
@useResult
$Res call({
 Map<String, dynamic> sessionDescription, List<VoiceTrackResultDto> tracks, bool requiresImmediateRenegotiation, List<EntitlementDegradationDto> degradations
});




}
/// @nodoc
class _$VoiceNegotiateResponseDtoCopyWithImpl<$Res>
    implements $VoiceNegotiateResponseDtoCopyWith<$Res> {
  _$VoiceNegotiateResponseDtoCopyWithImpl(this._self, this._then);

  final VoiceNegotiateResponseDto _self;
  final $Res Function(VoiceNegotiateResponseDto) _then;

/// Create a copy of VoiceNegotiateResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionDescription = null,Object? tracks = null,Object? requiresImmediateRenegotiation = null,Object? degradations = null,}) {
  return _then(_self.copyWith(
sessionDescription: null == sessionDescription ? _self.sessionDescription : sessionDescription // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,tracks: null == tracks ? _self.tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<VoiceTrackResultDto>,requiresImmediateRenegotiation: null == requiresImmediateRenegotiation ? _self.requiresImmediateRenegotiation : requiresImmediateRenegotiation // ignore: cast_nullable_to_non_nullable
as bool,degradations: null == degradations ? _self.degradations : degradations // ignore: cast_nullable_to_non_nullable
as List<EntitlementDegradationDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [VoiceNegotiateResponseDto].
extension VoiceNegotiateResponseDtoPatterns on VoiceNegotiateResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoiceNegotiateResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoiceNegotiateResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoiceNegotiateResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _VoiceNegotiateResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoiceNegotiateResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _VoiceNegotiateResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, dynamic> sessionDescription,  List<VoiceTrackResultDto> tracks,  bool requiresImmediateRenegotiation,  List<EntitlementDegradationDto> degradations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoiceNegotiateResponseDto() when $default != null:
return $default(_that.sessionDescription,_that.tracks,_that.requiresImmediateRenegotiation,_that.degradations);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, dynamic> sessionDescription,  List<VoiceTrackResultDto> tracks,  bool requiresImmediateRenegotiation,  List<EntitlementDegradationDto> degradations)  $default,) {final _that = this;
switch (_that) {
case _VoiceNegotiateResponseDto():
return $default(_that.sessionDescription,_that.tracks,_that.requiresImmediateRenegotiation,_that.degradations);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, dynamic> sessionDescription,  List<VoiceTrackResultDto> tracks,  bool requiresImmediateRenegotiation,  List<EntitlementDegradationDto> degradations)?  $default,) {final _that = this;
switch (_that) {
case _VoiceNegotiateResponseDto() when $default != null:
return $default(_that.sessionDescription,_that.tracks,_that.requiresImmediateRenegotiation,_that.degradations);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoiceNegotiateResponseDto implements VoiceNegotiateResponseDto {
  const _VoiceNegotiateResponseDto({required final  Map<String, dynamic> sessionDescription, final  List<VoiceTrackResultDto> tracks = const <VoiceTrackResultDto>[], this.requiresImmediateRenegotiation = false, final  List<EntitlementDegradationDto> degradations = const <EntitlementDegradationDto>[]}): _sessionDescription = sessionDescription,_tracks = tracks,_degradations = degradations;
  factory _VoiceNegotiateResponseDto.fromJson(Map<String, dynamic> json) => _$VoiceNegotiateResponseDtoFromJson(json);

 final  Map<String, dynamic> _sessionDescription;
@override Map<String, dynamic> get sessionDescription {
  if (_sessionDescription is EqualUnmodifiableMapView) return _sessionDescription;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_sessionDescription);
}

 final  List<VoiceTrackResultDto> _tracks;
@override@JsonKey() List<VoiceTrackResultDto> get tracks {
  if (_tracks is EqualUnmodifiableListView) return _tracks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tracks);
}

@override@JsonKey() final  bool requiresImmediateRenegotiation;
 final  List<EntitlementDegradationDto> _degradations;
@override@JsonKey() List<EntitlementDegradationDto> get degradations {
  if (_degradations is EqualUnmodifiableListView) return _degradations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_degradations);
}


/// Create a copy of VoiceNegotiateResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoiceNegotiateResponseDtoCopyWith<_VoiceNegotiateResponseDto> get copyWith => __$VoiceNegotiateResponseDtoCopyWithImpl<_VoiceNegotiateResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoiceNegotiateResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoiceNegotiateResponseDto&&const DeepCollectionEquality().equals(other._sessionDescription, _sessionDescription)&&const DeepCollectionEquality().equals(other._tracks, _tracks)&&(identical(other.requiresImmediateRenegotiation, requiresImmediateRenegotiation) || other.requiresImmediateRenegotiation == requiresImmediateRenegotiation)&&const DeepCollectionEquality().equals(other._degradations, _degradations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_sessionDescription),const DeepCollectionEquality().hash(_tracks),requiresImmediateRenegotiation,const DeepCollectionEquality().hash(_degradations));

@override
String toString() {
  return 'VoiceNegotiateResponseDto(sessionDescription: $sessionDescription, tracks: $tracks, requiresImmediateRenegotiation: $requiresImmediateRenegotiation, degradations: $degradations)';
}


}

/// @nodoc
abstract mixin class _$VoiceNegotiateResponseDtoCopyWith<$Res> implements $VoiceNegotiateResponseDtoCopyWith<$Res> {
  factory _$VoiceNegotiateResponseDtoCopyWith(_VoiceNegotiateResponseDto value, $Res Function(_VoiceNegotiateResponseDto) _then) = __$VoiceNegotiateResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 Map<String, dynamic> sessionDescription, List<VoiceTrackResultDto> tracks, bool requiresImmediateRenegotiation, List<EntitlementDegradationDto> degradations
});




}
/// @nodoc
class __$VoiceNegotiateResponseDtoCopyWithImpl<$Res>
    implements _$VoiceNegotiateResponseDtoCopyWith<$Res> {
  __$VoiceNegotiateResponseDtoCopyWithImpl(this._self, this._then);

  final _VoiceNegotiateResponseDto _self;
  final $Res Function(_VoiceNegotiateResponseDto) _then;

/// Create a copy of VoiceNegotiateResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionDescription = null,Object? tracks = null,Object? requiresImmediateRenegotiation = null,Object? degradations = null,}) {
  return _then(_VoiceNegotiateResponseDto(
sessionDescription: null == sessionDescription ? _self._sessionDescription : sessionDescription // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,tracks: null == tracks ? _self._tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<VoiceTrackResultDto>,requiresImmediateRenegotiation: null == requiresImmediateRenegotiation ? _self.requiresImmediateRenegotiation : requiresImmediateRenegotiation // ignore: cast_nullable_to_non_nullable
as bool,degradations: null == degradations ? _self._degradations : degradations // ignore: cast_nullable_to_non_nullable
as List<EntitlementDegradationDto>,
  ));
}


}


/// @nodoc
mixin _$VoiceRenegotiateResponseDto {

 Map<String, dynamic> get sessionDescription;
/// Create a copy of VoiceRenegotiateResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceRenegotiateResponseDtoCopyWith<VoiceRenegotiateResponseDto> get copyWith => _$VoiceRenegotiateResponseDtoCopyWithImpl<VoiceRenegotiateResponseDto>(this as VoiceRenegotiateResponseDto, _$identity);

  /// Serializes this VoiceRenegotiateResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceRenegotiateResponseDto&&const DeepCollectionEquality().equals(other.sessionDescription, sessionDescription));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(sessionDescription));

@override
String toString() {
  return 'VoiceRenegotiateResponseDto(sessionDescription: $sessionDescription)';
}


}

/// @nodoc
abstract mixin class $VoiceRenegotiateResponseDtoCopyWith<$Res>  {
  factory $VoiceRenegotiateResponseDtoCopyWith(VoiceRenegotiateResponseDto value, $Res Function(VoiceRenegotiateResponseDto) _then) = _$VoiceRenegotiateResponseDtoCopyWithImpl;
@useResult
$Res call({
 Map<String, dynamic> sessionDescription
});




}
/// @nodoc
class _$VoiceRenegotiateResponseDtoCopyWithImpl<$Res>
    implements $VoiceRenegotiateResponseDtoCopyWith<$Res> {
  _$VoiceRenegotiateResponseDtoCopyWithImpl(this._self, this._then);

  final VoiceRenegotiateResponseDto _self;
  final $Res Function(VoiceRenegotiateResponseDto) _then;

/// Create a copy of VoiceRenegotiateResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionDescription = null,}) {
  return _then(_self.copyWith(
sessionDescription: null == sessionDescription ? _self.sessionDescription : sessionDescription // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [VoiceRenegotiateResponseDto].
extension VoiceRenegotiateResponseDtoPatterns on VoiceRenegotiateResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoiceRenegotiateResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoiceRenegotiateResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoiceRenegotiateResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _VoiceRenegotiateResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoiceRenegotiateResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _VoiceRenegotiateResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, dynamic> sessionDescription)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoiceRenegotiateResponseDto() when $default != null:
return $default(_that.sessionDescription);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, dynamic> sessionDescription)  $default,) {final _that = this;
switch (_that) {
case _VoiceRenegotiateResponseDto():
return $default(_that.sessionDescription);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, dynamic> sessionDescription)?  $default,) {final _that = this;
switch (_that) {
case _VoiceRenegotiateResponseDto() when $default != null:
return $default(_that.sessionDescription);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoiceRenegotiateResponseDto implements VoiceRenegotiateResponseDto {
  const _VoiceRenegotiateResponseDto({required final  Map<String, dynamic> sessionDescription}): _sessionDescription = sessionDescription;
  factory _VoiceRenegotiateResponseDto.fromJson(Map<String, dynamic> json) => _$VoiceRenegotiateResponseDtoFromJson(json);

 final  Map<String, dynamic> _sessionDescription;
@override Map<String, dynamic> get sessionDescription {
  if (_sessionDescription is EqualUnmodifiableMapView) return _sessionDescription;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_sessionDescription);
}


/// Create a copy of VoiceRenegotiateResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoiceRenegotiateResponseDtoCopyWith<_VoiceRenegotiateResponseDto> get copyWith => __$VoiceRenegotiateResponseDtoCopyWithImpl<_VoiceRenegotiateResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoiceRenegotiateResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoiceRenegotiateResponseDto&&const DeepCollectionEquality().equals(other._sessionDescription, _sessionDescription));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_sessionDescription));

@override
String toString() {
  return 'VoiceRenegotiateResponseDto(sessionDescription: $sessionDescription)';
}


}

/// @nodoc
abstract mixin class _$VoiceRenegotiateResponseDtoCopyWith<$Res> implements $VoiceRenegotiateResponseDtoCopyWith<$Res> {
  factory _$VoiceRenegotiateResponseDtoCopyWith(_VoiceRenegotiateResponseDto value, $Res Function(_VoiceRenegotiateResponseDto) _then) = __$VoiceRenegotiateResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 Map<String, dynamic> sessionDescription
});




}
/// @nodoc
class __$VoiceRenegotiateResponseDtoCopyWithImpl<$Res>
    implements _$VoiceRenegotiateResponseDtoCopyWith<$Res> {
  __$VoiceRenegotiateResponseDtoCopyWithImpl(this._self, this._then);

  final _VoiceRenegotiateResponseDto _self;
  final $Res Function(_VoiceRenegotiateResponseDto) _then;

/// Create a copy of VoiceRenegotiateResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionDescription = null,}) {
  return _then(_VoiceRenegotiateResponseDto(
sessionDescription: null == sessionDescription ? _self._sessionDescription : sessionDescription // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
