// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cf_signaling_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CfTrackResultDto {

 String? get mid; String get trackName; String? get sessionId; String? get location; String? get errorCode; String? get errorDescription;
/// Create a copy of CfTrackResultDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CfTrackResultDtoCopyWith<CfTrackResultDto> get copyWith => _$CfTrackResultDtoCopyWithImpl<CfTrackResultDto>(this as CfTrackResultDto, _$identity);

  /// Serializes this CfTrackResultDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CfTrackResultDto&&(identical(other.mid, mid) || other.mid == mid)&&(identical(other.trackName, trackName) || other.trackName == trackName)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.location, location) || other.location == location)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.errorDescription, errorDescription) || other.errorDescription == errorDescription));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mid,trackName,sessionId,location,errorCode,errorDescription);

@override
String toString() {
  return 'CfTrackResultDto(mid: $mid, trackName: $trackName, sessionId: $sessionId, location: $location, errorCode: $errorCode, errorDescription: $errorDescription)';
}


}

/// @nodoc
abstract mixin class $CfTrackResultDtoCopyWith<$Res>  {
  factory $CfTrackResultDtoCopyWith(CfTrackResultDto value, $Res Function(CfTrackResultDto) _then) = _$CfTrackResultDtoCopyWithImpl;
@useResult
$Res call({
 String? mid, String trackName, String? sessionId, String? location, String? errorCode, String? errorDescription
});




}
/// @nodoc
class _$CfTrackResultDtoCopyWithImpl<$Res>
    implements $CfTrackResultDtoCopyWith<$Res> {
  _$CfTrackResultDtoCopyWithImpl(this._self, this._then);

  final CfTrackResultDto _self;
  final $Res Function(CfTrackResultDto) _then;

/// Create a copy of CfTrackResultDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mid = freezed,Object? trackName = null,Object? sessionId = freezed,Object? location = freezed,Object? errorCode = freezed,Object? errorDescription = freezed,}) {
  return _then(_self.copyWith(
mid: freezed == mid ? _self.mid : mid // ignore: cast_nullable_to_non_nullable
as String?,trackName: null == trackName ? _self.trackName : trackName // ignore: cast_nullable_to_non_nullable
as String,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,errorDescription: freezed == errorDescription ? _self.errorDescription : errorDescription // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CfTrackResultDto].
extension CfTrackResultDtoPatterns on CfTrackResultDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CfTrackResultDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CfTrackResultDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CfTrackResultDto value)  $default,){
final _that = this;
switch (_that) {
case _CfTrackResultDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CfTrackResultDto value)?  $default,){
final _that = this;
switch (_that) {
case _CfTrackResultDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? mid,  String trackName,  String? sessionId,  String? location,  String? errorCode,  String? errorDescription)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CfTrackResultDto() when $default != null:
return $default(_that.mid,_that.trackName,_that.sessionId,_that.location,_that.errorCode,_that.errorDescription);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? mid,  String trackName,  String? sessionId,  String? location,  String? errorCode,  String? errorDescription)  $default,) {final _that = this;
switch (_that) {
case _CfTrackResultDto():
return $default(_that.mid,_that.trackName,_that.sessionId,_that.location,_that.errorCode,_that.errorDescription);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? mid,  String trackName,  String? sessionId,  String? location,  String? errorCode,  String? errorDescription)?  $default,) {final _that = this;
switch (_that) {
case _CfTrackResultDto() when $default != null:
return $default(_that.mid,_that.trackName,_that.sessionId,_that.location,_that.errorCode,_that.errorDescription);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CfTrackResultDto implements CfTrackResultDto {
  const _CfTrackResultDto({this.mid, required this.trackName, this.sessionId, this.location, this.errorCode, this.errorDescription});
  factory _CfTrackResultDto.fromJson(Map<String, dynamic> json) => _$CfTrackResultDtoFromJson(json);

@override final  String? mid;
@override final  String trackName;
@override final  String? sessionId;
@override final  String? location;
@override final  String? errorCode;
@override final  String? errorDescription;

/// Create a copy of CfTrackResultDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CfTrackResultDtoCopyWith<_CfTrackResultDto> get copyWith => __$CfTrackResultDtoCopyWithImpl<_CfTrackResultDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CfTrackResultDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CfTrackResultDto&&(identical(other.mid, mid) || other.mid == mid)&&(identical(other.trackName, trackName) || other.trackName == trackName)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.location, location) || other.location == location)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.errorDescription, errorDescription) || other.errorDescription == errorDescription));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mid,trackName,sessionId,location,errorCode,errorDescription);

@override
String toString() {
  return 'CfTrackResultDto(mid: $mid, trackName: $trackName, sessionId: $sessionId, location: $location, errorCode: $errorCode, errorDescription: $errorDescription)';
}


}

/// @nodoc
abstract mixin class _$CfTrackResultDtoCopyWith<$Res> implements $CfTrackResultDtoCopyWith<$Res> {
  factory _$CfTrackResultDtoCopyWith(_CfTrackResultDto value, $Res Function(_CfTrackResultDto) _then) = __$CfTrackResultDtoCopyWithImpl;
@override @useResult
$Res call({
 String? mid, String trackName, String? sessionId, String? location, String? errorCode, String? errorDescription
});




}
/// @nodoc
class __$CfTrackResultDtoCopyWithImpl<$Res>
    implements _$CfTrackResultDtoCopyWith<$Res> {
  __$CfTrackResultDtoCopyWithImpl(this._self, this._then);

  final _CfTrackResultDto _self;
  final $Res Function(_CfTrackResultDto) _then;

/// Create a copy of CfTrackResultDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mid = freezed,Object? trackName = null,Object? sessionId = freezed,Object? location = freezed,Object? errorCode = freezed,Object? errorDescription = freezed,}) {
  return _then(_CfTrackResultDto(
mid: freezed == mid ? _self.mid : mid // ignore: cast_nullable_to_non_nullable
as String?,trackName: null == trackName ? _self.trackName : trackName // ignore: cast_nullable_to_non_nullable
as String,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,errorDescription: freezed == errorDescription ? _self.errorDescription : errorDescription // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CfTracksNewResponseDto {

 Map<String, dynamic> get sessionDescription; List<CfTrackResultDto> get tracks; bool get requiresImmediateRenegotiation;
/// Create a copy of CfTracksNewResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CfTracksNewResponseDtoCopyWith<CfTracksNewResponseDto> get copyWith => _$CfTracksNewResponseDtoCopyWithImpl<CfTracksNewResponseDto>(this as CfTracksNewResponseDto, _$identity);

  /// Serializes this CfTracksNewResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CfTracksNewResponseDto&&const DeepCollectionEquality().equals(other.sessionDescription, sessionDescription)&&const DeepCollectionEquality().equals(other.tracks, tracks)&&(identical(other.requiresImmediateRenegotiation, requiresImmediateRenegotiation) || other.requiresImmediateRenegotiation == requiresImmediateRenegotiation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(sessionDescription),const DeepCollectionEquality().hash(tracks),requiresImmediateRenegotiation);

@override
String toString() {
  return 'CfTracksNewResponseDto(sessionDescription: $sessionDescription, tracks: $tracks, requiresImmediateRenegotiation: $requiresImmediateRenegotiation)';
}


}

/// @nodoc
abstract mixin class $CfTracksNewResponseDtoCopyWith<$Res>  {
  factory $CfTracksNewResponseDtoCopyWith(CfTracksNewResponseDto value, $Res Function(CfTracksNewResponseDto) _then) = _$CfTracksNewResponseDtoCopyWithImpl;
@useResult
$Res call({
 Map<String, dynamic> sessionDescription, List<CfTrackResultDto> tracks, bool requiresImmediateRenegotiation
});




}
/// @nodoc
class _$CfTracksNewResponseDtoCopyWithImpl<$Res>
    implements $CfTracksNewResponseDtoCopyWith<$Res> {
  _$CfTracksNewResponseDtoCopyWithImpl(this._self, this._then);

  final CfTracksNewResponseDto _self;
  final $Res Function(CfTracksNewResponseDto) _then;

/// Create a copy of CfTracksNewResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionDescription = null,Object? tracks = null,Object? requiresImmediateRenegotiation = null,}) {
  return _then(_self.copyWith(
sessionDescription: null == sessionDescription ? _self.sessionDescription : sessionDescription // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,tracks: null == tracks ? _self.tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<CfTrackResultDto>,requiresImmediateRenegotiation: null == requiresImmediateRenegotiation ? _self.requiresImmediateRenegotiation : requiresImmediateRenegotiation // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CfTracksNewResponseDto].
extension CfTracksNewResponseDtoPatterns on CfTracksNewResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CfTracksNewResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CfTracksNewResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CfTracksNewResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _CfTracksNewResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CfTracksNewResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _CfTracksNewResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, dynamic> sessionDescription,  List<CfTrackResultDto> tracks,  bool requiresImmediateRenegotiation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CfTracksNewResponseDto() when $default != null:
return $default(_that.sessionDescription,_that.tracks,_that.requiresImmediateRenegotiation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, dynamic> sessionDescription,  List<CfTrackResultDto> tracks,  bool requiresImmediateRenegotiation)  $default,) {final _that = this;
switch (_that) {
case _CfTracksNewResponseDto():
return $default(_that.sessionDescription,_that.tracks,_that.requiresImmediateRenegotiation);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, dynamic> sessionDescription,  List<CfTrackResultDto> tracks,  bool requiresImmediateRenegotiation)?  $default,) {final _that = this;
switch (_that) {
case _CfTracksNewResponseDto() when $default != null:
return $default(_that.sessionDescription,_that.tracks,_that.requiresImmediateRenegotiation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CfTracksNewResponseDto implements CfTracksNewResponseDto {
  const _CfTracksNewResponseDto({required final  Map<String, dynamic> sessionDescription, final  List<CfTrackResultDto> tracks = const <CfTrackResultDto>[], this.requiresImmediateRenegotiation = false}): _sessionDescription = sessionDescription,_tracks = tracks;
  factory _CfTracksNewResponseDto.fromJson(Map<String, dynamic> json) => _$CfTracksNewResponseDtoFromJson(json);

 final  Map<String, dynamic> _sessionDescription;
@override Map<String, dynamic> get sessionDescription {
  if (_sessionDescription is EqualUnmodifiableMapView) return _sessionDescription;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_sessionDescription);
}

 final  List<CfTrackResultDto> _tracks;
@override@JsonKey() List<CfTrackResultDto> get tracks {
  if (_tracks is EqualUnmodifiableListView) return _tracks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tracks);
}

@override@JsonKey() final  bool requiresImmediateRenegotiation;

/// Create a copy of CfTracksNewResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CfTracksNewResponseDtoCopyWith<_CfTracksNewResponseDto> get copyWith => __$CfTracksNewResponseDtoCopyWithImpl<_CfTracksNewResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CfTracksNewResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CfTracksNewResponseDto&&const DeepCollectionEquality().equals(other._sessionDescription, _sessionDescription)&&const DeepCollectionEquality().equals(other._tracks, _tracks)&&(identical(other.requiresImmediateRenegotiation, requiresImmediateRenegotiation) || other.requiresImmediateRenegotiation == requiresImmediateRenegotiation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_sessionDescription),const DeepCollectionEquality().hash(_tracks),requiresImmediateRenegotiation);

@override
String toString() {
  return 'CfTracksNewResponseDto(sessionDescription: $sessionDescription, tracks: $tracks, requiresImmediateRenegotiation: $requiresImmediateRenegotiation)';
}


}

/// @nodoc
abstract mixin class _$CfTracksNewResponseDtoCopyWith<$Res> implements $CfTracksNewResponseDtoCopyWith<$Res> {
  factory _$CfTracksNewResponseDtoCopyWith(_CfTracksNewResponseDto value, $Res Function(_CfTracksNewResponseDto) _then) = __$CfTracksNewResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 Map<String, dynamic> sessionDescription, List<CfTrackResultDto> tracks, bool requiresImmediateRenegotiation
});




}
/// @nodoc
class __$CfTracksNewResponseDtoCopyWithImpl<$Res>
    implements _$CfTracksNewResponseDtoCopyWith<$Res> {
  __$CfTracksNewResponseDtoCopyWithImpl(this._self, this._then);

  final _CfTracksNewResponseDto _self;
  final $Res Function(_CfTracksNewResponseDto) _then;

/// Create a copy of CfTracksNewResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionDescription = null,Object? tracks = null,Object? requiresImmediateRenegotiation = null,}) {
  return _then(_CfTracksNewResponseDto(
sessionDescription: null == sessionDescription ? _self._sessionDescription : sessionDescription // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,tracks: null == tracks ? _self._tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<CfTrackResultDto>,requiresImmediateRenegotiation: null == requiresImmediateRenegotiation ? _self.requiresImmediateRenegotiation : requiresImmediateRenegotiation // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$CfRenegotiateResponseDto {

 Map<String, dynamic> get sessionDescription;
/// Create a copy of CfRenegotiateResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CfRenegotiateResponseDtoCopyWith<CfRenegotiateResponseDto> get copyWith => _$CfRenegotiateResponseDtoCopyWithImpl<CfRenegotiateResponseDto>(this as CfRenegotiateResponseDto, _$identity);

  /// Serializes this CfRenegotiateResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CfRenegotiateResponseDto&&const DeepCollectionEquality().equals(other.sessionDescription, sessionDescription));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(sessionDescription));

@override
String toString() {
  return 'CfRenegotiateResponseDto(sessionDescription: $sessionDescription)';
}


}

/// @nodoc
abstract mixin class $CfRenegotiateResponseDtoCopyWith<$Res>  {
  factory $CfRenegotiateResponseDtoCopyWith(CfRenegotiateResponseDto value, $Res Function(CfRenegotiateResponseDto) _then) = _$CfRenegotiateResponseDtoCopyWithImpl;
@useResult
$Res call({
 Map<String, dynamic> sessionDescription
});




}
/// @nodoc
class _$CfRenegotiateResponseDtoCopyWithImpl<$Res>
    implements $CfRenegotiateResponseDtoCopyWith<$Res> {
  _$CfRenegotiateResponseDtoCopyWithImpl(this._self, this._then);

  final CfRenegotiateResponseDto _self;
  final $Res Function(CfRenegotiateResponseDto) _then;

/// Create a copy of CfRenegotiateResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionDescription = null,}) {
  return _then(_self.copyWith(
sessionDescription: null == sessionDescription ? _self.sessionDescription : sessionDescription // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [CfRenegotiateResponseDto].
extension CfRenegotiateResponseDtoPatterns on CfRenegotiateResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CfRenegotiateResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CfRenegotiateResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CfRenegotiateResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _CfRenegotiateResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CfRenegotiateResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _CfRenegotiateResponseDto() when $default != null:
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
case _CfRenegotiateResponseDto() when $default != null:
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
case _CfRenegotiateResponseDto():
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
case _CfRenegotiateResponseDto() when $default != null:
return $default(_that.sessionDescription);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CfRenegotiateResponseDto implements CfRenegotiateResponseDto {
  const _CfRenegotiateResponseDto({required final  Map<String, dynamic> sessionDescription}): _sessionDescription = sessionDescription;
  factory _CfRenegotiateResponseDto.fromJson(Map<String, dynamic> json) => _$CfRenegotiateResponseDtoFromJson(json);

 final  Map<String, dynamic> _sessionDescription;
@override Map<String, dynamic> get sessionDescription {
  if (_sessionDescription is EqualUnmodifiableMapView) return _sessionDescription;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_sessionDescription);
}


/// Create a copy of CfRenegotiateResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CfRenegotiateResponseDtoCopyWith<_CfRenegotiateResponseDto> get copyWith => __$CfRenegotiateResponseDtoCopyWithImpl<_CfRenegotiateResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CfRenegotiateResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CfRenegotiateResponseDto&&const DeepCollectionEquality().equals(other._sessionDescription, _sessionDescription));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_sessionDescription));

@override
String toString() {
  return 'CfRenegotiateResponseDto(sessionDescription: $sessionDescription)';
}


}

/// @nodoc
abstract mixin class _$CfRenegotiateResponseDtoCopyWith<$Res> implements $CfRenegotiateResponseDtoCopyWith<$Res> {
  factory _$CfRenegotiateResponseDtoCopyWith(_CfRenegotiateResponseDto value, $Res Function(_CfRenegotiateResponseDto) _then) = __$CfRenegotiateResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 Map<String, dynamic> sessionDescription
});




}
/// @nodoc
class __$CfRenegotiateResponseDtoCopyWithImpl<$Res>
    implements _$CfRenegotiateResponseDtoCopyWith<$Res> {
  __$CfRenegotiateResponseDtoCopyWithImpl(this._self, this._then);

  final _CfRenegotiateResponseDto _self;
  final $Res Function(_CfRenegotiateResponseDto) _then;

/// Create a copy of CfRenegotiateResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionDescription = null,}) {
  return _then(_CfRenegotiateResponseDto(
sessionDescription: null == sessionDescription ? _self._sessionDescription : sessionDescription // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
