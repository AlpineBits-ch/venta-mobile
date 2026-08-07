// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ongoing_call_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OngoingCallDto {

 String get callId; String get conversationId;/// `Pending` while it is still ringing, `Connected` once somebody answered.
 String get status; String? get creatorId; DateTime? get startedAt;/// Only the participants actually connected - an invitee still ringing is
/// not one of them.
 List<String> get connectedUserIds;
/// Create a copy of OngoingCallDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OngoingCallDtoCopyWith<OngoingCallDto> get copyWith => _$OngoingCallDtoCopyWithImpl<OngoingCallDto>(this as OngoingCallDto, _$identity);

  /// Serializes this OngoingCallDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OngoingCallDto&&(identical(other.callId, callId) || other.callId == callId)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.status, status) || other.status == status)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&const DeepCollectionEquality().equals(other.connectedUserIds, connectedUserIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,callId,conversationId,status,creatorId,startedAt,const DeepCollectionEquality().hash(connectedUserIds));

@override
String toString() {
  return 'OngoingCallDto(callId: $callId, conversationId: $conversationId, status: $status, creatorId: $creatorId, startedAt: $startedAt, connectedUserIds: $connectedUserIds)';
}


}

/// @nodoc
abstract mixin class $OngoingCallDtoCopyWith<$Res>  {
  factory $OngoingCallDtoCopyWith(OngoingCallDto value, $Res Function(OngoingCallDto) _then) = _$OngoingCallDtoCopyWithImpl;
@useResult
$Res call({
 String callId, String conversationId, String status, String? creatorId, DateTime? startedAt, List<String> connectedUserIds
});




}
/// @nodoc
class _$OngoingCallDtoCopyWithImpl<$Res>
    implements $OngoingCallDtoCopyWith<$Res> {
  _$OngoingCallDtoCopyWithImpl(this._self, this._then);

  final OngoingCallDto _self;
  final $Res Function(OngoingCallDto) _then;

/// Create a copy of OngoingCallDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? callId = null,Object? conversationId = null,Object? status = null,Object? creatorId = freezed,Object? startedAt = freezed,Object? connectedUserIds = null,}) {
  return _then(_self.copyWith(
callId: null == callId ? _self.callId : callId // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,creatorId: freezed == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,connectedUserIds: null == connectedUserIds ? _self.connectedUserIds : connectedUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [OngoingCallDto].
extension OngoingCallDtoPatterns on OngoingCallDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OngoingCallDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OngoingCallDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OngoingCallDto value)  $default,){
final _that = this;
switch (_that) {
case _OngoingCallDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OngoingCallDto value)?  $default,){
final _that = this;
switch (_that) {
case _OngoingCallDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String callId,  String conversationId,  String status,  String? creatorId,  DateTime? startedAt,  List<String> connectedUserIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OngoingCallDto() when $default != null:
return $default(_that.callId,_that.conversationId,_that.status,_that.creatorId,_that.startedAt,_that.connectedUserIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String callId,  String conversationId,  String status,  String? creatorId,  DateTime? startedAt,  List<String> connectedUserIds)  $default,) {final _that = this;
switch (_that) {
case _OngoingCallDto():
return $default(_that.callId,_that.conversationId,_that.status,_that.creatorId,_that.startedAt,_that.connectedUserIds);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String callId,  String conversationId,  String status,  String? creatorId,  DateTime? startedAt,  List<String> connectedUserIds)?  $default,) {final _that = this;
switch (_that) {
case _OngoingCallDto() when $default != null:
return $default(_that.callId,_that.conversationId,_that.status,_that.creatorId,_that.startedAt,_that.connectedUserIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _OngoingCallDto extends OngoingCallDto {
  const _OngoingCallDto({required this.callId, required this.conversationId, this.status = '', this.creatorId, this.startedAt, final  List<String> connectedUserIds = const <String>[]}): _connectedUserIds = connectedUserIds,super._();
  factory _OngoingCallDto.fromJson(Map<String, dynamic> json) => _$OngoingCallDtoFromJson(json);

@override final  String callId;
@override final  String conversationId;
/// `Pending` while it is still ringing, `Connected` once somebody answered.
@override@JsonKey() final  String status;
@override final  String? creatorId;
@override final  DateTime? startedAt;
/// Only the participants actually connected - an invitee still ringing is
/// not one of them.
 final  List<String> _connectedUserIds;
/// Only the participants actually connected - an invitee still ringing is
/// not one of them.
@override@JsonKey() List<String> get connectedUserIds {
  if (_connectedUserIds is EqualUnmodifiableListView) return _connectedUserIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_connectedUserIds);
}


/// Create a copy of OngoingCallDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OngoingCallDtoCopyWith<_OngoingCallDto> get copyWith => __$OngoingCallDtoCopyWithImpl<_OngoingCallDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OngoingCallDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OngoingCallDto&&(identical(other.callId, callId) || other.callId == callId)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.status, status) || other.status == status)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&const DeepCollectionEquality().equals(other._connectedUserIds, _connectedUserIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,callId,conversationId,status,creatorId,startedAt,const DeepCollectionEquality().hash(_connectedUserIds));

@override
String toString() {
  return 'OngoingCallDto(callId: $callId, conversationId: $conversationId, status: $status, creatorId: $creatorId, startedAt: $startedAt, connectedUserIds: $connectedUserIds)';
}


}

/// @nodoc
abstract mixin class _$OngoingCallDtoCopyWith<$Res> implements $OngoingCallDtoCopyWith<$Res> {
  factory _$OngoingCallDtoCopyWith(_OngoingCallDto value, $Res Function(_OngoingCallDto) _then) = __$OngoingCallDtoCopyWithImpl;
@override @useResult
$Res call({
 String callId, String conversationId, String status, String? creatorId, DateTime? startedAt, List<String> connectedUserIds
});




}
/// @nodoc
class __$OngoingCallDtoCopyWithImpl<$Res>
    implements _$OngoingCallDtoCopyWith<$Res> {
  __$OngoingCallDtoCopyWithImpl(this._self, this._then);

  final _OngoingCallDto _self;
  final $Res Function(_OngoingCallDto) _then;

/// Create a copy of OngoingCallDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? callId = null,Object? conversationId = null,Object? status = null,Object? creatorId = freezed,Object? startedAt = freezed,Object? connectedUserIds = null,}) {
  return _then(_OngoingCallDto(
callId: null == callId ? _self.callId : callId // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,creatorId: freezed == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,connectedUserIds: null == connectedUserIds ? _self._connectedUserIds : connectedUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
