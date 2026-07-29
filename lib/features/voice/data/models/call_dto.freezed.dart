// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'call_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CallParticipantDto {

 String get userId; String? get cfSessionId; String? get audioTrackName;
/// Create a copy of CallParticipantDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CallParticipantDtoCopyWith<CallParticipantDto> get copyWith => _$CallParticipantDtoCopyWithImpl<CallParticipantDto>(this as CallParticipantDto, _$identity);

  /// Serializes this CallParticipantDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallParticipantDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.cfSessionId, cfSessionId) || other.cfSessionId == cfSessionId)&&(identical(other.audioTrackName, audioTrackName) || other.audioTrackName == audioTrackName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,cfSessionId,audioTrackName);

@override
String toString() {
  return 'CallParticipantDto(userId: $userId, cfSessionId: $cfSessionId, audioTrackName: $audioTrackName)';
}


}

/// @nodoc
abstract mixin class $CallParticipantDtoCopyWith<$Res>  {
  factory $CallParticipantDtoCopyWith(CallParticipantDto value, $Res Function(CallParticipantDto) _then) = _$CallParticipantDtoCopyWithImpl;
@useResult
$Res call({
 String userId, String? cfSessionId, String? audioTrackName
});




}
/// @nodoc
class _$CallParticipantDtoCopyWithImpl<$Res>
    implements $CallParticipantDtoCopyWith<$Res> {
  _$CallParticipantDtoCopyWithImpl(this._self, this._then);

  final CallParticipantDto _self;
  final $Res Function(CallParticipantDto) _then;

/// Create a copy of CallParticipantDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? cfSessionId = freezed,Object? audioTrackName = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,cfSessionId: freezed == cfSessionId ? _self.cfSessionId : cfSessionId // ignore: cast_nullable_to_non_nullable
as String?,audioTrackName: freezed == audioTrackName ? _self.audioTrackName : audioTrackName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CallParticipantDto].
extension CallParticipantDtoPatterns on CallParticipantDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CallParticipantDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CallParticipantDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CallParticipantDto value)  $default,){
final _that = this;
switch (_that) {
case _CallParticipantDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CallParticipantDto value)?  $default,){
final _that = this;
switch (_that) {
case _CallParticipantDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String? cfSessionId,  String? audioTrackName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CallParticipantDto() when $default != null:
return $default(_that.userId,_that.cfSessionId,_that.audioTrackName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String? cfSessionId,  String? audioTrackName)  $default,) {final _that = this;
switch (_that) {
case _CallParticipantDto():
return $default(_that.userId,_that.cfSessionId,_that.audioTrackName);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String? cfSessionId,  String? audioTrackName)?  $default,) {final _that = this;
switch (_that) {
case _CallParticipantDto() when $default != null:
return $default(_that.userId,_that.cfSessionId,_that.audioTrackName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CallParticipantDto implements CallParticipantDto {
  const _CallParticipantDto({required this.userId, this.cfSessionId, this.audioTrackName});
  factory _CallParticipantDto.fromJson(Map<String, dynamic> json) => _$CallParticipantDtoFromJson(json);

@override final  String userId;
@override final  String? cfSessionId;
@override final  String? audioTrackName;

/// Create a copy of CallParticipantDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CallParticipantDtoCopyWith<_CallParticipantDto> get copyWith => __$CallParticipantDtoCopyWithImpl<_CallParticipantDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CallParticipantDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CallParticipantDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.cfSessionId, cfSessionId) || other.cfSessionId == cfSessionId)&&(identical(other.audioTrackName, audioTrackName) || other.audioTrackName == audioTrackName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,cfSessionId,audioTrackName);

@override
String toString() {
  return 'CallParticipantDto(userId: $userId, cfSessionId: $cfSessionId, audioTrackName: $audioTrackName)';
}


}

/// @nodoc
abstract mixin class _$CallParticipantDtoCopyWith<$Res> implements $CallParticipantDtoCopyWith<$Res> {
  factory _$CallParticipantDtoCopyWith(_CallParticipantDto value, $Res Function(_CallParticipantDto) _then) = __$CallParticipantDtoCopyWithImpl;
@override @useResult
$Res call({
 String userId, String? cfSessionId, String? audioTrackName
});




}
/// @nodoc
class __$CallParticipantDtoCopyWithImpl<$Res>
    implements _$CallParticipantDtoCopyWith<$Res> {
  __$CallParticipantDtoCopyWithImpl(this._self, this._then);

  final _CallParticipantDto _self;
  final $Res Function(_CallParticipantDto) _then;

/// Create a copy of CallParticipantDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? cfSessionId = freezed,Object? audioTrackName = freezed,}) {
  return _then(_CallParticipantDto(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,cfSessionId: freezed == cfSessionId ? _self.cfSessionId : cfSessionId // ignore: cast_nullable_to_non_nullable
as String?,audioTrackName: freezed == audioTrackName ? _self.audioTrackName : audioTrackName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CallTrackDto {

 String get trackId; String get userId; String get status;
/// Create a copy of CallTrackDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CallTrackDtoCopyWith<CallTrackDto> get copyWith => _$CallTrackDtoCopyWithImpl<CallTrackDto>(this as CallTrackDto, _$identity);

  /// Serializes this CallTrackDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallTrackDto&&(identical(other.trackId, trackId) || other.trackId == trackId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,trackId,userId,status);

@override
String toString() {
  return 'CallTrackDto(trackId: $trackId, userId: $userId, status: $status)';
}


}

/// @nodoc
abstract mixin class $CallTrackDtoCopyWith<$Res>  {
  factory $CallTrackDtoCopyWith(CallTrackDto value, $Res Function(CallTrackDto) _then) = _$CallTrackDtoCopyWithImpl;
@useResult
$Res call({
 String trackId, String userId, String status
});




}
/// @nodoc
class _$CallTrackDtoCopyWithImpl<$Res>
    implements $CallTrackDtoCopyWith<$Res> {
  _$CallTrackDtoCopyWithImpl(this._self, this._then);

  final CallTrackDto _self;
  final $Res Function(CallTrackDto) _then;

/// Create a copy of CallTrackDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? trackId = null,Object? userId = null,Object? status = null,}) {
  return _then(_self.copyWith(
trackId: null == trackId ? _self.trackId : trackId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CallTrackDto].
extension CallTrackDtoPatterns on CallTrackDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CallTrackDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CallTrackDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CallTrackDto value)  $default,){
final _that = this;
switch (_that) {
case _CallTrackDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CallTrackDto value)?  $default,){
final _that = this;
switch (_that) {
case _CallTrackDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String trackId,  String userId,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CallTrackDto() when $default != null:
return $default(_that.trackId,_that.userId,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String trackId,  String userId,  String status)  $default,) {final _that = this;
switch (_that) {
case _CallTrackDto():
return $default(_that.trackId,_that.userId,_that.status);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String trackId,  String userId,  String status)?  $default,) {final _that = this;
switch (_that) {
case _CallTrackDto() when $default != null:
return $default(_that.trackId,_that.userId,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CallTrackDto implements CallTrackDto {
  const _CallTrackDto({required this.trackId, required this.userId, required this.status});
  factory _CallTrackDto.fromJson(Map<String, dynamic> json) => _$CallTrackDtoFromJson(json);

@override final  String trackId;
@override final  String userId;
@override final  String status;

/// Create a copy of CallTrackDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CallTrackDtoCopyWith<_CallTrackDto> get copyWith => __$CallTrackDtoCopyWithImpl<_CallTrackDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CallTrackDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CallTrackDto&&(identical(other.trackId, trackId) || other.trackId == trackId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,trackId,userId,status);

@override
String toString() {
  return 'CallTrackDto(trackId: $trackId, userId: $userId, status: $status)';
}


}

/// @nodoc
abstract mixin class _$CallTrackDtoCopyWith<$Res> implements $CallTrackDtoCopyWith<$Res> {
  factory _$CallTrackDtoCopyWith(_CallTrackDto value, $Res Function(_CallTrackDto) _then) = __$CallTrackDtoCopyWithImpl;
@override @useResult
$Res call({
 String trackId, String userId, String status
});




}
/// @nodoc
class __$CallTrackDtoCopyWithImpl<$Res>
    implements _$CallTrackDtoCopyWith<$Res> {
  __$CallTrackDtoCopyWithImpl(this._self, this._then);

  final _CallTrackDto _self;
  final $Res Function(_CallTrackDto) _then;

/// Create a copy of CallTrackDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? trackId = null,Object? userId = null,Object? status = null,}) {
  return _then(_CallTrackDto(
trackId: null == trackId ? _self.trackId : trackId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CallDto {

 String get id; String get conversationId; String? get status; DateTime? get createdAt; DateTime? get updatedAt; List<CallTrackDto> get tracks; List<CallParticipantDto> get participants;
/// Create a copy of CallDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CallDtoCopyWith<CallDto> get copyWith => _$CallDtoCopyWithImpl<CallDto>(this as CallDto, _$identity);

  /// Serializes this CallDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallDto&&(identical(other.id, id) || other.id == id)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.tracks, tracks)&&const DeepCollectionEquality().equals(other.participants, participants));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,conversationId,status,createdAt,updatedAt,const DeepCollectionEquality().hash(tracks),const DeepCollectionEquality().hash(participants));

@override
String toString() {
  return 'CallDto(id: $id, conversationId: $conversationId, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, tracks: $tracks, participants: $participants)';
}


}

/// @nodoc
abstract mixin class $CallDtoCopyWith<$Res>  {
  factory $CallDtoCopyWith(CallDto value, $Res Function(CallDto) _then) = _$CallDtoCopyWithImpl;
@useResult
$Res call({
 String id, String conversationId, String? status, DateTime? createdAt, DateTime? updatedAt, List<CallTrackDto> tracks, List<CallParticipantDto> participants
});




}
/// @nodoc
class _$CallDtoCopyWithImpl<$Res>
    implements $CallDtoCopyWith<$Res> {
  _$CallDtoCopyWithImpl(this._self, this._then);

  final CallDto _self;
  final $Res Function(CallDto) _then;

/// Create a copy of CallDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? conversationId = null,Object? status = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? tracks = null,Object? participants = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,tracks: null == tracks ? _self.tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<CallTrackDto>,participants: null == participants ? _self.participants : participants // ignore: cast_nullable_to_non_nullable
as List<CallParticipantDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [CallDto].
extension CallDtoPatterns on CallDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CallDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CallDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CallDto value)  $default,){
final _that = this;
switch (_that) {
case _CallDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CallDto value)?  $default,){
final _that = this;
switch (_that) {
case _CallDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String conversationId,  String? status,  DateTime? createdAt,  DateTime? updatedAt,  List<CallTrackDto> tracks,  List<CallParticipantDto> participants)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CallDto() when $default != null:
return $default(_that.id,_that.conversationId,_that.status,_that.createdAt,_that.updatedAt,_that.tracks,_that.participants);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String conversationId,  String? status,  DateTime? createdAt,  DateTime? updatedAt,  List<CallTrackDto> tracks,  List<CallParticipantDto> participants)  $default,) {final _that = this;
switch (_that) {
case _CallDto():
return $default(_that.id,_that.conversationId,_that.status,_that.createdAt,_that.updatedAt,_that.tracks,_that.participants);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String conversationId,  String? status,  DateTime? createdAt,  DateTime? updatedAt,  List<CallTrackDto> tracks,  List<CallParticipantDto> participants)?  $default,) {final _that = this;
switch (_that) {
case _CallDto() when $default != null:
return $default(_that.id,_that.conversationId,_that.status,_that.createdAt,_that.updatedAt,_that.tracks,_that.participants);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CallDto implements CallDto {
  const _CallDto({required this.id, required this.conversationId, this.status, this.createdAt, this.updatedAt, final  List<CallTrackDto> tracks = const <CallTrackDto>[], final  List<CallParticipantDto> participants = const <CallParticipantDto>[]}): _tracks = tracks,_participants = participants;
  factory _CallDto.fromJson(Map<String, dynamic> json) => _$CallDtoFromJson(json);

@override final  String id;
@override final  String conversationId;
@override final  String? status;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
 final  List<CallTrackDto> _tracks;
@override@JsonKey() List<CallTrackDto> get tracks {
  if (_tracks is EqualUnmodifiableListView) return _tracks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tracks);
}

 final  List<CallParticipantDto> _participants;
@override@JsonKey() List<CallParticipantDto> get participants {
  if (_participants is EqualUnmodifiableListView) return _participants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participants);
}


/// Create a copy of CallDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CallDtoCopyWith<_CallDto> get copyWith => __$CallDtoCopyWithImpl<_CallDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CallDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CallDto&&(identical(other.id, id) || other.id == id)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._tracks, _tracks)&&const DeepCollectionEquality().equals(other._participants, _participants));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,conversationId,status,createdAt,updatedAt,const DeepCollectionEquality().hash(_tracks),const DeepCollectionEquality().hash(_participants));

@override
String toString() {
  return 'CallDto(id: $id, conversationId: $conversationId, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, tracks: $tracks, participants: $participants)';
}


}

/// @nodoc
abstract mixin class _$CallDtoCopyWith<$Res> implements $CallDtoCopyWith<$Res> {
  factory _$CallDtoCopyWith(_CallDto value, $Res Function(_CallDto) _then) = __$CallDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String conversationId, String? status, DateTime? createdAt, DateTime? updatedAt, List<CallTrackDto> tracks, List<CallParticipantDto> participants
});




}
/// @nodoc
class __$CallDtoCopyWithImpl<$Res>
    implements _$CallDtoCopyWith<$Res> {
  __$CallDtoCopyWithImpl(this._self, this._then);

  final _CallDto _self;
  final $Res Function(_CallDto) _then;

/// Create a copy of CallDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? conversationId = null,Object? status = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? tracks = null,Object? participants = null,}) {
  return _then(_CallDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,tracks: null == tracks ? _self._tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<CallTrackDto>,participants: null == participants ? _self._participants : participants // ignore: cast_nullable_to_non_nullable
as List<CallParticipantDto>,
  ));
}


}

// dart format on
