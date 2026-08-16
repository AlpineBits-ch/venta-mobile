// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voice_subscription_set.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VoiceSubscriptionTrackDto {

 String get userId; String? get mediaSessionId; String get trackName; String get kind; String? get shareId; String? get layer;
/// Create a copy of VoiceSubscriptionTrackDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceSubscriptionTrackDtoCopyWith<VoiceSubscriptionTrackDto> get copyWith => _$VoiceSubscriptionTrackDtoCopyWithImpl<VoiceSubscriptionTrackDto>(this as VoiceSubscriptionTrackDto, _$identity);

  /// Serializes this VoiceSubscriptionTrackDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceSubscriptionTrackDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.mediaSessionId, mediaSessionId) || other.mediaSessionId == mediaSessionId)&&(identical(other.trackName, trackName) || other.trackName == trackName)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.shareId, shareId) || other.shareId == shareId)&&(identical(other.layer, layer) || other.layer == layer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,mediaSessionId,trackName,kind,shareId,layer);

@override
String toString() {
  return 'VoiceSubscriptionTrackDto(userId: $userId, mediaSessionId: $mediaSessionId, trackName: $trackName, kind: $kind, shareId: $shareId, layer: $layer)';
}


}

/// @nodoc
abstract mixin class $VoiceSubscriptionTrackDtoCopyWith<$Res>  {
  factory $VoiceSubscriptionTrackDtoCopyWith(VoiceSubscriptionTrackDto value, $Res Function(VoiceSubscriptionTrackDto) _then) = _$VoiceSubscriptionTrackDtoCopyWithImpl;
@useResult
$Res call({
 String userId, String? mediaSessionId, String trackName, String kind, String? shareId, String? layer
});




}
/// @nodoc
class _$VoiceSubscriptionTrackDtoCopyWithImpl<$Res>
    implements $VoiceSubscriptionTrackDtoCopyWith<$Res> {
  _$VoiceSubscriptionTrackDtoCopyWithImpl(this._self, this._then);

  final VoiceSubscriptionTrackDto _self;
  final $Res Function(VoiceSubscriptionTrackDto) _then;

/// Create a copy of VoiceSubscriptionTrackDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? mediaSessionId = freezed,Object? trackName = null,Object? kind = null,Object? shareId = freezed,Object? layer = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,mediaSessionId: freezed == mediaSessionId ? _self.mediaSessionId : mediaSessionId // ignore: cast_nullable_to_non_nullable
as String?,trackName: null == trackName ? _self.trackName : trackName // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,shareId: freezed == shareId ? _self.shareId : shareId // ignore: cast_nullable_to_non_nullable
as String?,layer: freezed == layer ? _self.layer : layer // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VoiceSubscriptionTrackDto].
extension VoiceSubscriptionTrackDtoPatterns on VoiceSubscriptionTrackDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoiceSubscriptionTrackDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoiceSubscriptionTrackDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoiceSubscriptionTrackDto value)  $default,){
final _that = this;
switch (_that) {
case _VoiceSubscriptionTrackDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoiceSubscriptionTrackDto value)?  $default,){
final _that = this;
switch (_that) {
case _VoiceSubscriptionTrackDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String? mediaSessionId,  String trackName,  String kind,  String? shareId,  String? layer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoiceSubscriptionTrackDto() when $default != null:
return $default(_that.userId,_that.mediaSessionId,_that.trackName,_that.kind,_that.shareId,_that.layer);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String? mediaSessionId,  String trackName,  String kind,  String? shareId,  String? layer)  $default,) {final _that = this;
switch (_that) {
case _VoiceSubscriptionTrackDto():
return $default(_that.userId,_that.mediaSessionId,_that.trackName,_that.kind,_that.shareId,_that.layer);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String? mediaSessionId,  String trackName,  String kind,  String? shareId,  String? layer)?  $default,) {final _that = this;
switch (_that) {
case _VoiceSubscriptionTrackDto() when $default != null:
return $default(_that.userId,_that.mediaSessionId,_that.trackName,_that.kind,_that.shareId,_that.layer);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoiceSubscriptionTrackDto extends VoiceSubscriptionTrackDto {
  const _VoiceSubscriptionTrackDto({required this.userId, this.mediaSessionId, required this.trackName, this.kind = 'video', this.shareId, this.layer}): super._();
  factory _VoiceSubscriptionTrackDto.fromJson(Map<String, dynamic> json) => _$VoiceSubscriptionTrackDtoFromJson(json);

@override final  String userId;
@override final  String? mediaSessionId;
@override final  String trackName;
@override@JsonKey() final  String kind;
@override final  String? shareId;
@override final  String? layer;

/// Create a copy of VoiceSubscriptionTrackDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoiceSubscriptionTrackDtoCopyWith<_VoiceSubscriptionTrackDto> get copyWith => __$VoiceSubscriptionTrackDtoCopyWithImpl<_VoiceSubscriptionTrackDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoiceSubscriptionTrackDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoiceSubscriptionTrackDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.mediaSessionId, mediaSessionId) || other.mediaSessionId == mediaSessionId)&&(identical(other.trackName, trackName) || other.trackName == trackName)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.shareId, shareId) || other.shareId == shareId)&&(identical(other.layer, layer) || other.layer == layer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,mediaSessionId,trackName,kind,shareId,layer);

@override
String toString() {
  return 'VoiceSubscriptionTrackDto(userId: $userId, mediaSessionId: $mediaSessionId, trackName: $trackName, kind: $kind, shareId: $shareId, layer: $layer)';
}


}

/// @nodoc
abstract mixin class _$VoiceSubscriptionTrackDtoCopyWith<$Res> implements $VoiceSubscriptionTrackDtoCopyWith<$Res> {
  factory _$VoiceSubscriptionTrackDtoCopyWith(_VoiceSubscriptionTrackDto value, $Res Function(_VoiceSubscriptionTrackDto) _then) = __$VoiceSubscriptionTrackDtoCopyWithImpl;
@override @useResult
$Res call({
 String userId, String? mediaSessionId, String trackName, String kind, String? shareId, String? layer
});




}
/// @nodoc
class __$VoiceSubscriptionTrackDtoCopyWithImpl<$Res>
    implements _$VoiceSubscriptionTrackDtoCopyWith<$Res> {
  __$VoiceSubscriptionTrackDtoCopyWithImpl(this._self, this._then);

  final _VoiceSubscriptionTrackDto _self;
  final $Res Function(_VoiceSubscriptionTrackDto) _then;

/// Create a copy of VoiceSubscriptionTrackDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? mediaSessionId = freezed,Object? trackName = null,Object? kind = null,Object? shareId = freezed,Object? layer = freezed,}) {
  return _then(_VoiceSubscriptionTrackDto(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,mediaSessionId: freezed == mediaSessionId ? _self.mediaSessionId : mediaSessionId // ignore: cast_nullable_to_non_nullable
as String?,trackName: null == trackName ? _self.trackName : trackName // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,shareId: freezed == shareId ? _self.shareId : shareId // ignore: cast_nullable_to_non_nullable
as String?,layer: freezed == layer ? _self.layer : layer // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$VoiceSubscriptionSetDto {

 String get mode; int get revision; List<String> get activeSpeakers; List<VoiceSubscriptionTrackDto>? get tracks;
/// Create a copy of VoiceSubscriptionSetDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceSubscriptionSetDtoCopyWith<VoiceSubscriptionSetDto> get copyWith => _$VoiceSubscriptionSetDtoCopyWithImpl<VoiceSubscriptionSetDto>(this as VoiceSubscriptionSetDto, _$identity);

  /// Serializes this VoiceSubscriptionSetDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceSubscriptionSetDto&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.revision, revision) || other.revision == revision)&&const DeepCollectionEquality().equals(other.activeSpeakers, activeSpeakers)&&const DeepCollectionEquality().equals(other.tracks, tracks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mode,revision,const DeepCollectionEquality().hash(activeSpeakers),const DeepCollectionEquality().hash(tracks));

@override
String toString() {
  return 'VoiceSubscriptionSetDto(mode: $mode, revision: $revision, activeSpeakers: $activeSpeakers, tracks: $tracks)';
}


}

/// @nodoc
abstract mixin class $VoiceSubscriptionSetDtoCopyWith<$Res>  {
  factory $VoiceSubscriptionSetDtoCopyWith(VoiceSubscriptionSetDto value, $Res Function(VoiceSubscriptionSetDto) _then) = _$VoiceSubscriptionSetDtoCopyWithImpl;
@useResult
$Res call({
 String mode, int revision, List<String> activeSpeakers, List<VoiceSubscriptionTrackDto>? tracks
});




}
/// @nodoc
class _$VoiceSubscriptionSetDtoCopyWithImpl<$Res>
    implements $VoiceSubscriptionSetDtoCopyWith<$Res> {
  _$VoiceSubscriptionSetDtoCopyWithImpl(this._self, this._then);

  final VoiceSubscriptionSetDto _self;
  final $Res Function(VoiceSubscriptionSetDto) _then;

/// Create a copy of VoiceSubscriptionSetDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? revision = null,Object? activeSpeakers = null,Object? tracks = freezed,}) {
  return _then(_self.copyWith(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as String,revision: null == revision ? _self.revision : revision // ignore: cast_nullable_to_non_nullable
as int,activeSpeakers: null == activeSpeakers ? _self.activeSpeakers : activeSpeakers // ignore: cast_nullable_to_non_nullable
as List<String>,tracks: freezed == tracks ? _self.tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<VoiceSubscriptionTrackDto>?,
  ));
}

}


/// Adds pattern-matching-related methods to [VoiceSubscriptionSetDto].
extension VoiceSubscriptionSetDtoPatterns on VoiceSubscriptionSetDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoiceSubscriptionSetDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoiceSubscriptionSetDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoiceSubscriptionSetDto value)  $default,){
final _that = this;
switch (_that) {
case _VoiceSubscriptionSetDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoiceSubscriptionSetDto value)?  $default,){
final _that = this;
switch (_that) {
case _VoiceSubscriptionSetDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String mode,  int revision,  List<String> activeSpeakers,  List<VoiceSubscriptionTrackDto>? tracks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoiceSubscriptionSetDto() when $default != null:
return $default(_that.mode,_that.revision,_that.activeSpeakers,_that.tracks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String mode,  int revision,  List<String> activeSpeakers,  List<VoiceSubscriptionTrackDto>? tracks)  $default,) {final _that = this;
switch (_that) {
case _VoiceSubscriptionSetDto():
return $default(_that.mode,_that.revision,_that.activeSpeakers,_that.tracks);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String mode,  int revision,  List<String> activeSpeakers,  List<VoiceSubscriptionTrackDto>? tracks)?  $default,) {final _that = this;
switch (_that) {
case _VoiceSubscriptionSetDto() when $default != null:
return $default(_that.mode,_that.revision,_that.activeSpeakers,_that.tracks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoiceSubscriptionSetDto extends VoiceSubscriptionSetDto {
  const _VoiceSubscriptionSetDto({this.mode = VoiceSubscriptionMode.all, this.revision = 0, final  List<String> activeSpeakers = const <String>[], final  List<VoiceSubscriptionTrackDto>? tracks}): _activeSpeakers = activeSpeakers,_tracks = tracks,super._();
  factory _VoiceSubscriptionSetDto.fromJson(Map<String, dynamic> json) => _$VoiceSubscriptionSetDtoFromJson(json);

@override@JsonKey() final  String mode;
@override@JsonKey() final  int revision;
 final  List<String> _activeSpeakers;
@override@JsonKey() List<String> get activeSpeakers {
  if (_activeSpeakers is EqualUnmodifiableListView) return _activeSpeakers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_activeSpeakers);
}

 final  List<VoiceSubscriptionTrackDto>? _tracks;
@override List<VoiceSubscriptionTrackDto>? get tracks {
  final value = _tracks;
  if (value == null) return null;
  if (_tracks is EqualUnmodifiableListView) return _tracks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of VoiceSubscriptionSetDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoiceSubscriptionSetDtoCopyWith<_VoiceSubscriptionSetDto> get copyWith => __$VoiceSubscriptionSetDtoCopyWithImpl<_VoiceSubscriptionSetDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoiceSubscriptionSetDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoiceSubscriptionSetDto&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.revision, revision) || other.revision == revision)&&const DeepCollectionEquality().equals(other._activeSpeakers, _activeSpeakers)&&const DeepCollectionEquality().equals(other._tracks, _tracks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mode,revision,const DeepCollectionEquality().hash(_activeSpeakers),const DeepCollectionEquality().hash(_tracks));

@override
String toString() {
  return 'VoiceSubscriptionSetDto(mode: $mode, revision: $revision, activeSpeakers: $activeSpeakers, tracks: $tracks)';
}


}

/// @nodoc
abstract mixin class _$VoiceSubscriptionSetDtoCopyWith<$Res> implements $VoiceSubscriptionSetDtoCopyWith<$Res> {
  factory _$VoiceSubscriptionSetDtoCopyWith(_VoiceSubscriptionSetDto value, $Res Function(_VoiceSubscriptionSetDto) _then) = __$VoiceSubscriptionSetDtoCopyWithImpl;
@override @useResult
$Res call({
 String mode, int revision, List<String> activeSpeakers, List<VoiceSubscriptionTrackDto>? tracks
});




}
/// @nodoc
class __$VoiceSubscriptionSetDtoCopyWithImpl<$Res>
    implements _$VoiceSubscriptionSetDtoCopyWith<$Res> {
  __$VoiceSubscriptionSetDtoCopyWithImpl(this._self, this._then);

  final _VoiceSubscriptionSetDto _self;
  final $Res Function(_VoiceSubscriptionSetDto) _then;

/// Create a copy of VoiceSubscriptionSetDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? revision = null,Object? activeSpeakers = null,Object? tracks = freezed,}) {
  return _then(_VoiceSubscriptionSetDto(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as String,revision: null == revision ? _self.revision : revision // ignore: cast_nullable_to_non_nullable
as int,activeSpeakers: null == activeSpeakers ? _self._activeSpeakers : activeSpeakers // ignore: cast_nullable_to_non_nullable
as List<String>,tracks: freezed == tracks ? _self._tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<VoiceSubscriptionTrackDto>?,
  ));
}


}

// dart format on
