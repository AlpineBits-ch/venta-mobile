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
mixin _$VoiceConnectionDto {

 String get backend; String get url; String get token; String get room; String get identity; String? get mediaSessionId; DateTime? get expiresAt; bool get canPublishAudio; bool get canPublishVideo;
/// Create a copy of VoiceConnectionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceConnectionDtoCopyWith<VoiceConnectionDto> get copyWith => _$VoiceConnectionDtoCopyWithImpl<VoiceConnectionDto>(this as VoiceConnectionDto, _$identity);

  /// Serializes this VoiceConnectionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceConnectionDto&&(identical(other.backend, backend) || other.backend == backend)&&(identical(other.url, url) || other.url == url)&&(identical(other.token, token) || other.token == token)&&(identical(other.room, room) || other.room == room)&&(identical(other.identity, identity) || other.identity == identity)&&(identical(other.mediaSessionId, mediaSessionId) || other.mediaSessionId == mediaSessionId)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.canPublishAudio, canPublishAudio) || other.canPublishAudio == canPublishAudio)&&(identical(other.canPublishVideo, canPublishVideo) || other.canPublishVideo == canPublishVideo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,backend,url,token,room,identity,mediaSessionId,expiresAt,canPublishAudio,canPublishVideo);

@override
String toString() {
  return 'VoiceConnectionDto(backend: $backend, url: $url, token: $token, room: $room, identity: $identity, mediaSessionId: $mediaSessionId, expiresAt: $expiresAt, canPublishAudio: $canPublishAudio, canPublishVideo: $canPublishVideo)';
}


}

/// @nodoc
abstract mixin class $VoiceConnectionDtoCopyWith<$Res>  {
  factory $VoiceConnectionDtoCopyWith(VoiceConnectionDto value, $Res Function(VoiceConnectionDto) _then) = _$VoiceConnectionDtoCopyWithImpl;
@useResult
$Res call({
 String backend, String url, String token, String room, String identity, String? mediaSessionId, DateTime? expiresAt, bool canPublishAudio, bool canPublishVideo
});




}
/// @nodoc
class _$VoiceConnectionDtoCopyWithImpl<$Res>
    implements $VoiceConnectionDtoCopyWith<$Res> {
  _$VoiceConnectionDtoCopyWithImpl(this._self, this._then);

  final VoiceConnectionDto _self;
  final $Res Function(VoiceConnectionDto) _then;

/// Create a copy of VoiceConnectionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? backend = null,Object? url = null,Object? token = null,Object? room = null,Object? identity = null,Object? mediaSessionId = freezed,Object? expiresAt = freezed,Object? canPublishAudio = null,Object? canPublishVideo = null,}) {
  return _then(_self.copyWith(
backend: null == backend ? _self.backend : backend // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,room: null == room ? _self.room : room // ignore: cast_nullable_to_non_nullable
as String,identity: null == identity ? _self.identity : identity // ignore: cast_nullable_to_non_nullable
as String,mediaSessionId: freezed == mediaSessionId ? _self.mediaSessionId : mediaSessionId // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,canPublishAudio: null == canPublishAudio ? _self.canPublishAudio : canPublishAudio // ignore: cast_nullable_to_non_nullable
as bool,canPublishVideo: null == canPublishVideo ? _self.canPublishVideo : canPublishVideo // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [VoiceConnectionDto].
extension VoiceConnectionDtoPatterns on VoiceConnectionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoiceConnectionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoiceConnectionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoiceConnectionDto value)  $default,){
final _that = this;
switch (_that) {
case _VoiceConnectionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoiceConnectionDto value)?  $default,){
final _that = this;
switch (_that) {
case _VoiceConnectionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String backend,  String url,  String token,  String room,  String identity,  String? mediaSessionId,  DateTime? expiresAt,  bool canPublishAudio,  bool canPublishVideo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoiceConnectionDto() when $default != null:
return $default(_that.backend,_that.url,_that.token,_that.room,_that.identity,_that.mediaSessionId,_that.expiresAt,_that.canPublishAudio,_that.canPublishVideo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String backend,  String url,  String token,  String room,  String identity,  String? mediaSessionId,  DateTime? expiresAt,  bool canPublishAudio,  bool canPublishVideo)  $default,) {final _that = this;
switch (_that) {
case _VoiceConnectionDto():
return $default(_that.backend,_that.url,_that.token,_that.room,_that.identity,_that.mediaSessionId,_that.expiresAt,_that.canPublishAudio,_that.canPublishVideo);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String backend,  String url,  String token,  String room,  String identity,  String? mediaSessionId,  DateTime? expiresAt,  bool canPublishAudio,  bool canPublishVideo)?  $default,) {final _that = this;
switch (_that) {
case _VoiceConnectionDto() when $default != null:
return $default(_that.backend,_that.url,_that.token,_that.room,_that.identity,_that.mediaSessionId,_that.expiresAt,_that.canPublishAudio,_that.canPublishVideo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _VoiceConnectionDto extends VoiceConnectionDto {
  const _VoiceConnectionDto({this.backend = '', required this.url, required this.token, this.room = '', required this.identity, this.mediaSessionId, this.expiresAt, this.canPublishAudio = true, this.canPublishVideo = true}): super._();
  factory _VoiceConnectionDto.fromJson(Map<String, dynamic> json) => _$VoiceConnectionDtoFromJson(json);

@override@JsonKey() final  String backend;
@override final  String url;
@override final  String token;
@override@JsonKey() final  String room;
@override final  String identity;
@override final  String? mediaSessionId;
@override final  DateTime? expiresAt;
@override@JsonKey() final  bool canPublishAudio;
@override@JsonKey() final  bool canPublishVideo;

/// Create a copy of VoiceConnectionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoiceConnectionDtoCopyWith<_VoiceConnectionDto> get copyWith => __$VoiceConnectionDtoCopyWithImpl<_VoiceConnectionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoiceConnectionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoiceConnectionDto&&(identical(other.backend, backend) || other.backend == backend)&&(identical(other.url, url) || other.url == url)&&(identical(other.token, token) || other.token == token)&&(identical(other.room, room) || other.room == room)&&(identical(other.identity, identity) || other.identity == identity)&&(identical(other.mediaSessionId, mediaSessionId) || other.mediaSessionId == mediaSessionId)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.canPublishAudio, canPublishAudio) || other.canPublishAudio == canPublishAudio)&&(identical(other.canPublishVideo, canPublishVideo) || other.canPublishVideo == canPublishVideo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,backend,url,token,room,identity,mediaSessionId,expiresAt,canPublishAudio,canPublishVideo);

@override
String toString() {
  return 'VoiceConnectionDto(backend: $backend, url: $url, token: $token, room: $room, identity: $identity, mediaSessionId: $mediaSessionId, expiresAt: $expiresAt, canPublishAudio: $canPublishAudio, canPublishVideo: $canPublishVideo)';
}


}

/// @nodoc
abstract mixin class _$VoiceConnectionDtoCopyWith<$Res> implements $VoiceConnectionDtoCopyWith<$Res> {
  factory _$VoiceConnectionDtoCopyWith(_VoiceConnectionDto value, $Res Function(_VoiceConnectionDto) _then) = __$VoiceConnectionDtoCopyWithImpl;
@override @useResult
$Res call({
 String backend, String url, String token, String room, String identity, String? mediaSessionId, DateTime? expiresAt, bool canPublishAudio, bool canPublishVideo
});




}
/// @nodoc
class __$VoiceConnectionDtoCopyWithImpl<$Res>
    implements _$VoiceConnectionDtoCopyWith<$Res> {
  __$VoiceConnectionDtoCopyWithImpl(this._self, this._then);

  final _VoiceConnectionDto _self;
  final $Res Function(_VoiceConnectionDto) _then;

/// Create a copy of VoiceConnectionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? backend = null,Object? url = null,Object? token = null,Object? room = null,Object? identity = null,Object? mediaSessionId = freezed,Object? expiresAt = freezed,Object? canPublishAudio = null,Object? canPublishVideo = null,}) {
  return _then(_VoiceConnectionDto(
backend: null == backend ? _self.backend : backend // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,room: null == room ? _self.room : room // ignore: cast_nullable_to_non_nullable
as String,identity: null == identity ? _self.identity : identity // ignore: cast_nullable_to_non_nullable
as String,mediaSessionId: freezed == mediaSessionId ? _self.mediaSessionId : mediaSessionId // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,canPublishAudio: null == canPublishAudio ? _self.canPublishAudio : canPublishAudio // ignore: cast_nullable_to_non_nullable
as bool,canPublishVideo: null == canPublishVideo ? _self.canPublishVideo : canPublishVideo // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$VoicePublishResultDto {

 String get identity; String? get rung; int? get height; int? get framerate; String? get maxLayer; List<EntitlementDegradationDto> get degradations;
/// Create a copy of VoicePublishResultDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoicePublishResultDtoCopyWith<VoicePublishResultDto> get copyWith => _$VoicePublishResultDtoCopyWithImpl<VoicePublishResultDto>(this as VoicePublishResultDto, _$identity);

  /// Serializes this VoicePublishResultDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoicePublishResultDto&&(identical(other.identity, identity) || other.identity == identity)&&(identical(other.rung, rung) || other.rung == rung)&&(identical(other.height, height) || other.height == height)&&(identical(other.framerate, framerate) || other.framerate == framerate)&&(identical(other.maxLayer, maxLayer) || other.maxLayer == maxLayer)&&const DeepCollectionEquality().equals(other.degradations, degradations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,identity,rung,height,framerate,maxLayer,const DeepCollectionEquality().hash(degradations));

@override
String toString() {
  return 'VoicePublishResultDto(identity: $identity, rung: $rung, height: $height, framerate: $framerate, maxLayer: $maxLayer, degradations: $degradations)';
}


}

/// @nodoc
abstract mixin class $VoicePublishResultDtoCopyWith<$Res>  {
  factory $VoicePublishResultDtoCopyWith(VoicePublishResultDto value, $Res Function(VoicePublishResultDto) _then) = _$VoicePublishResultDtoCopyWithImpl;
@useResult
$Res call({
 String identity, String? rung, int? height, int? framerate, String? maxLayer, List<EntitlementDegradationDto> degradations
});




}
/// @nodoc
class _$VoicePublishResultDtoCopyWithImpl<$Res>
    implements $VoicePublishResultDtoCopyWith<$Res> {
  _$VoicePublishResultDtoCopyWithImpl(this._self, this._then);

  final VoicePublishResultDto _self;
  final $Res Function(VoicePublishResultDto) _then;

/// Create a copy of VoicePublishResultDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? identity = null,Object? rung = freezed,Object? height = freezed,Object? framerate = freezed,Object? maxLayer = freezed,Object? degradations = null,}) {
  return _then(_self.copyWith(
identity: null == identity ? _self.identity : identity // ignore: cast_nullable_to_non_nullable
as String,rung: freezed == rung ? _self.rung : rung // ignore: cast_nullable_to_non_nullable
as String?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,framerate: freezed == framerate ? _self.framerate : framerate // ignore: cast_nullable_to_non_nullable
as int?,maxLayer: freezed == maxLayer ? _self.maxLayer : maxLayer // ignore: cast_nullable_to_non_nullable
as String?,degradations: null == degradations ? _self.degradations : degradations // ignore: cast_nullable_to_non_nullable
as List<EntitlementDegradationDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [VoicePublishResultDto].
extension VoicePublishResultDtoPatterns on VoicePublishResultDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoicePublishResultDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoicePublishResultDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoicePublishResultDto value)  $default,){
final _that = this;
switch (_that) {
case _VoicePublishResultDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoicePublishResultDto value)?  $default,){
final _that = this;
switch (_that) {
case _VoicePublishResultDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String identity,  String? rung,  int? height,  int? framerate,  String? maxLayer,  List<EntitlementDegradationDto> degradations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoicePublishResultDto() when $default != null:
return $default(_that.identity,_that.rung,_that.height,_that.framerate,_that.maxLayer,_that.degradations);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String identity,  String? rung,  int? height,  int? framerate,  String? maxLayer,  List<EntitlementDegradationDto> degradations)  $default,) {final _that = this;
switch (_that) {
case _VoicePublishResultDto():
return $default(_that.identity,_that.rung,_that.height,_that.framerate,_that.maxLayer,_that.degradations);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String identity,  String? rung,  int? height,  int? framerate,  String? maxLayer,  List<EntitlementDegradationDto> degradations)?  $default,) {final _that = this;
switch (_that) {
case _VoicePublishResultDto() when $default != null:
return $default(_that.identity,_that.rung,_that.height,_that.framerate,_that.maxLayer,_that.degradations);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoicePublishResultDto extends VoicePublishResultDto {
  const _VoicePublishResultDto({this.identity = '', this.rung, this.height, this.framerate, this.maxLayer, final  List<EntitlementDegradationDto> degradations = const <EntitlementDegradationDto>[]}): _degradations = degradations,super._();
  factory _VoicePublishResultDto.fromJson(Map<String, dynamic> json) => _$VoicePublishResultDtoFromJson(json);

@override@JsonKey() final  String identity;
@override final  String? rung;
@override final  int? height;
@override final  int? framerate;
@override final  String? maxLayer;
 final  List<EntitlementDegradationDto> _degradations;
@override@JsonKey() List<EntitlementDegradationDto> get degradations {
  if (_degradations is EqualUnmodifiableListView) return _degradations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_degradations);
}


/// Create a copy of VoicePublishResultDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoicePublishResultDtoCopyWith<_VoicePublishResultDto> get copyWith => __$VoicePublishResultDtoCopyWithImpl<_VoicePublishResultDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoicePublishResultDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoicePublishResultDto&&(identical(other.identity, identity) || other.identity == identity)&&(identical(other.rung, rung) || other.rung == rung)&&(identical(other.height, height) || other.height == height)&&(identical(other.framerate, framerate) || other.framerate == framerate)&&(identical(other.maxLayer, maxLayer) || other.maxLayer == maxLayer)&&const DeepCollectionEquality().equals(other._degradations, _degradations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,identity,rung,height,framerate,maxLayer,const DeepCollectionEquality().hash(_degradations));

@override
String toString() {
  return 'VoicePublishResultDto(identity: $identity, rung: $rung, height: $height, framerate: $framerate, maxLayer: $maxLayer, degradations: $degradations)';
}


}

/// @nodoc
abstract mixin class _$VoicePublishResultDtoCopyWith<$Res> implements $VoicePublishResultDtoCopyWith<$Res> {
  factory _$VoicePublishResultDtoCopyWith(_VoicePublishResultDto value, $Res Function(_VoicePublishResultDto) _then) = __$VoicePublishResultDtoCopyWithImpl;
@override @useResult
$Res call({
 String identity, String? rung, int? height, int? framerate, String? maxLayer, List<EntitlementDegradationDto> degradations
});




}
/// @nodoc
class __$VoicePublishResultDtoCopyWithImpl<$Res>
    implements _$VoicePublishResultDtoCopyWith<$Res> {
  __$VoicePublishResultDtoCopyWithImpl(this._self, this._then);

  final _VoicePublishResultDto _self;
  final $Res Function(_VoicePublishResultDto) _then;

/// Create a copy of VoicePublishResultDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? identity = null,Object? rung = freezed,Object? height = freezed,Object? framerate = freezed,Object? maxLayer = freezed,Object? degradations = null,}) {
  return _then(_VoicePublishResultDto(
identity: null == identity ? _self.identity : identity // ignore: cast_nullable_to_non_nullable
as String,rung: freezed == rung ? _self.rung : rung // ignore: cast_nullable_to_non_nullable
as String?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,framerate: freezed == framerate ? _self.framerate : framerate // ignore: cast_nullable_to_non_nullable
as int?,maxLayer: freezed == maxLayer ? _self.maxLayer : maxLayer // ignore: cast_nullable_to_non_nullable
as String?,degradations: null == degradations ? _self._degradations : degradations // ignore: cast_nullable_to_non_nullable
as List<EntitlementDegradationDto>,
  ));
}


}

// dart format on
