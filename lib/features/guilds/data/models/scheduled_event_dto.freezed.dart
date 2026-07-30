// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scheduled_event_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScheduledEventDto {

 String get id; String get guildId; String get creatorUserId; String get title; String? get description; DateTime get startsAt; DateTime? get endsAt; String? get location; String? get voiceChannelId; EventStatus get status; int get interestedCount; bool get isInterested;
/// Create a copy of ScheduledEventDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduledEventDtoCopyWith<ScheduledEventDto> get copyWith => _$ScheduledEventDtoCopyWithImpl<ScheduledEventDto>(this as ScheduledEventDto, _$identity);

  /// Serializes this ScheduledEventDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduledEventDto&&(identical(other.id, id) || other.id == id)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.creatorUserId, creatorUserId) || other.creatorUserId == creatorUserId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt)&&(identical(other.location, location) || other.location == location)&&(identical(other.voiceChannelId, voiceChannelId) || other.voiceChannelId == voiceChannelId)&&(identical(other.status, status) || other.status == status)&&(identical(other.interestedCount, interestedCount) || other.interestedCount == interestedCount)&&(identical(other.isInterested, isInterested) || other.isInterested == isInterested));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,guildId,creatorUserId,title,description,startsAt,endsAt,location,voiceChannelId,status,interestedCount,isInterested);

@override
String toString() {
  return 'ScheduledEventDto(id: $id, guildId: $guildId, creatorUserId: $creatorUserId, title: $title, description: $description, startsAt: $startsAt, endsAt: $endsAt, location: $location, voiceChannelId: $voiceChannelId, status: $status, interestedCount: $interestedCount, isInterested: $isInterested)';
}


}

/// @nodoc
abstract mixin class $ScheduledEventDtoCopyWith<$Res>  {
  factory $ScheduledEventDtoCopyWith(ScheduledEventDto value, $Res Function(ScheduledEventDto) _then) = _$ScheduledEventDtoCopyWithImpl;
@useResult
$Res call({
 String id, String guildId, String creatorUserId, String title, String? description, DateTime startsAt, DateTime? endsAt, String? location, String? voiceChannelId, EventStatus status, int interestedCount, bool isInterested
});




}
/// @nodoc
class _$ScheduledEventDtoCopyWithImpl<$Res>
    implements $ScheduledEventDtoCopyWith<$Res> {
  _$ScheduledEventDtoCopyWithImpl(this._self, this._then);

  final ScheduledEventDto _self;
  final $Res Function(ScheduledEventDto) _then;

/// Create a copy of ScheduledEventDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? guildId = null,Object? creatorUserId = null,Object? title = null,Object? description = freezed,Object? startsAt = null,Object? endsAt = freezed,Object? location = freezed,Object? voiceChannelId = freezed,Object? status = null,Object? interestedCount = null,Object? isInterested = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,creatorUserId: null == creatorUserId ? _self.creatorUserId : creatorUserId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,endsAt: freezed == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,voiceChannelId: freezed == voiceChannelId ? _self.voiceChannelId : voiceChannelId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EventStatus,interestedCount: null == interestedCount ? _self.interestedCount : interestedCount // ignore: cast_nullable_to_non_nullable
as int,isInterested: null == isInterested ? _self.isInterested : isInterested // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ScheduledEventDto].
extension ScheduledEventDtoPatterns on ScheduledEventDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScheduledEventDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScheduledEventDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScheduledEventDto value)  $default,){
final _that = this;
switch (_that) {
case _ScheduledEventDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScheduledEventDto value)?  $default,){
final _that = this;
switch (_that) {
case _ScheduledEventDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String guildId,  String creatorUserId,  String title,  String? description,  DateTime startsAt,  DateTime? endsAt,  String? location,  String? voiceChannelId,  EventStatus status,  int interestedCount,  bool isInterested)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScheduledEventDto() when $default != null:
return $default(_that.id,_that.guildId,_that.creatorUserId,_that.title,_that.description,_that.startsAt,_that.endsAt,_that.location,_that.voiceChannelId,_that.status,_that.interestedCount,_that.isInterested);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String guildId,  String creatorUserId,  String title,  String? description,  DateTime startsAt,  DateTime? endsAt,  String? location,  String? voiceChannelId,  EventStatus status,  int interestedCount,  bool isInterested)  $default,) {final _that = this;
switch (_that) {
case _ScheduledEventDto():
return $default(_that.id,_that.guildId,_that.creatorUserId,_that.title,_that.description,_that.startsAt,_that.endsAt,_that.location,_that.voiceChannelId,_that.status,_that.interestedCount,_that.isInterested);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String guildId,  String creatorUserId,  String title,  String? description,  DateTime startsAt,  DateTime? endsAt,  String? location,  String? voiceChannelId,  EventStatus status,  int interestedCount,  bool isInterested)?  $default,) {final _that = this;
switch (_that) {
case _ScheduledEventDto() when $default != null:
return $default(_that.id,_that.guildId,_that.creatorUserId,_that.title,_that.description,_that.startsAt,_that.endsAt,_that.location,_that.voiceChannelId,_that.status,_that.interestedCount,_that.isInterested);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScheduledEventDto implements ScheduledEventDto {
  const _ScheduledEventDto({required this.id, required this.guildId, required this.creatorUserId, required this.title, this.description, required this.startsAt, this.endsAt, this.location, this.voiceChannelId, this.status = EventStatus.scheduled, this.interestedCount = 0, this.isInterested = false});
  factory _ScheduledEventDto.fromJson(Map<String, dynamic> json) => _$ScheduledEventDtoFromJson(json);

@override final  String id;
@override final  String guildId;
@override final  String creatorUserId;
@override final  String title;
@override final  String? description;
@override final  DateTime startsAt;
@override final  DateTime? endsAt;
@override final  String? location;
@override final  String? voiceChannelId;
@override@JsonKey() final  EventStatus status;
@override@JsonKey() final  int interestedCount;
@override@JsonKey() final  bool isInterested;

/// Create a copy of ScheduledEventDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScheduledEventDtoCopyWith<_ScheduledEventDto> get copyWith => __$ScheduledEventDtoCopyWithImpl<_ScheduledEventDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScheduledEventDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScheduledEventDto&&(identical(other.id, id) || other.id == id)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.creatorUserId, creatorUserId) || other.creatorUserId == creatorUserId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt)&&(identical(other.location, location) || other.location == location)&&(identical(other.voiceChannelId, voiceChannelId) || other.voiceChannelId == voiceChannelId)&&(identical(other.status, status) || other.status == status)&&(identical(other.interestedCount, interestedCount) || other.interestedCount == interestedCount)&&(identical(other.isInterested, isInterested) || other.isInterested == isInterested));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,guildId,creatorUserId,title,description,startsAt,endsAt,location,voiceChannelId,status,interestedCount,isInterested);

@override
String toString() {
  return 'ScheduledEventDto(id: $id, guildId: $guildId, creatorUserId: $creatorUserId, title: $title, description: $description, startsAt: $startsAt, endsAt: $endsAt, location: $location, voiceChannelId: $voiceChannelId, status: $status, interestedCount: $interestedCount, isInterested: $isInterested)';
}


}

/// @nodoc
abstract mixin class _$ScheduledEventDtoCopyWith<$Res> implements $ScheduledEventDtoCopyWith<$Res> {
  factory _$ScheduledEventDtoCopyWith(_ScheduledEventDto value, $Res Function(_ScheduledEventDto) _then) = __$ScheduledEventDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String guildId, String creatorUserId, String title, String? description, DateTime startsAt, DateTime? endsAt, String? location, String? voiceChannelId, EventStatus status, int interestedCount, bool isInterested
});




}
/// @nodoc
class __$ScheduledEventDtoCopyWithImpl<$Res>
    implements _$ScheduledEventDtoCopyWith<$Res> {
  __$ScheduledEventDtoCopyWithImpl(this._self, this._then);

  final _ScheduledEventDto _self;
  final $Res Function(_ScheduledEventDto) _then;

/// Create a copy of ScheduledEventDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? guildId = null,Object? creatorUserId = null,Object? title = null,Object? description = freezed,Object? startsAt = null,Object? endsAt = freezed,Object? location = freezed,Object? voiceChannelId = freezed,Object? status = null,Object? interestedCount = null,Object? isInterested = null,}) {
  return _then(_ScheduledEventDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,creatorUserId: null == creatorUserId ? _self.creatorUserId : creatorUserId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,endsAt: freezed == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,voiceChannelId: freezed == voiceChannelId ? _self.voiceChannelId : voiceChannelId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EventStatus,interestedCount: null == interestedCount ? _self.interestedCount : interestedCount // ignore: cast_nullable_to_non_nullable
as int,isInterested: null == isInterested ? _self.isInterested : isInterested // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
