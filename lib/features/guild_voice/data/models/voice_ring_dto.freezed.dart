// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voice_ring_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VoiceRingDto {

 String get ringId; String get guildId; String get channelId;/// Null on the response to your own send - you sent it, you know the
/// channel. Populated on the catch-up read and on the realtime event, where
/// the reader may not.
 String? get channelName; String get inviterId; String get targetUserId;@JsonKey(unknownEnumValue: VoiceRingStatus.unknown) VoiceRingStatus get status;@JsonKey(unknownEnumValue: VoiceRingReason.unknown) VoiceRingReason? get reason; DateTime? get createdAt; DateTime? get expiresAt;/// **Count down from this, not from [expiresAt].** A handset whose clock is
/// a few minutes out is ordinary rather than exotic, and trusting an
/// absolute deadline there draws an invitation that is already dead or one
/// that never lapses.
 int get expiresInSeconds;/// The device that answered, or null for a resolution nobody pressed a
/// button for. If it is this device, it already knows.
 String? get resolvedByDeviceId;
/// Create a copy of VoiceRingDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceRingDtoCopyWith<VoiceRingDto> get copyWith => _$VoiceRingDtoCopyWithImpl<VoiceRingDto>(this as VoiceRingDto, _$identity);

  /// Serializes this VoiceRingDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceRingDto&&(identical(other.ringId, ringId) || other.ringId == ringId)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.channelName, channelName) || other.channelName == channelName)&&(identical(other.inviterId, inviterId) || other.inviterId == inviterId)&&(identical(other.targetUserId, targetUserId) || other.targetUserId == targetUserId)&&(identical(other.status, status) || other.status == status)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.expiresInSeconds, expiresInSeconds) || other.expiresInSeconds == expiresInSeconds)&&(identical(other.resolvedByDeviceId, resolvedByDeviceId) || other.resolvedByDeviceId == resolvedByDeviceId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ringId,guildId,channelId,channelName,inviterId,targetUserId,status,reason,createdAt,expiresAt,expiresInSeconds,resolvedByDeviceId);

@override
String toString() {
  return 'VoiceRingDto(ringId: $ringId, guildId: $guildId, channelId: $channelId, channelName: $channelName, inviterId: $inviterId, targetUserId: $targetUserId, status: $status, reason: $reason, createdAt: $createdAt, expiresAt: $expiresAt, expiresInSeconds: $expiresInSeconds, resolvedByDeviceId: $resolvedByDeviceId)';
}


}

/// @nodoc
abstract mixin class $VoiceRingDtoCopyWith<$Res>  {
  factory $VoiceRingDtoCopyWith(VoiceRingDto value, $Res Function(VoiceRingDto) _then) = _$VoiceRingDtoCopyWithImpl;
@useResult
$Res call({
 String ringId, String guildId, String channelId, String? channelName, String inviterId, String targetUserId,@JsonKey(unknownEnumValue: VoiceRingStatus.unknown) VoiceRingStatus status,@JsonKey(unknownEnumValue: VoiceRingReason.unknown) VoiceRingReason? reason, DateTime? createdAt, DateTime? expiresAt, int expiresInSeconds, String? resolvedByDeviceId
});




}
/// @nodoc
class _$VoiceRingDtoCopyWithImpl<$Res>
    implements $VoiceRingDtoCopyWith<$Res> {
  _$VoiceRingDtoCopyWithImpl(this._self, this._then);

  final VoiceRingDto _self;
  final $Res Function(VoiceRingDto) _then;

/// Create a copy of VoiceRingDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ringId = null,Object? guildId = null,Object? channelId = null,Object? channelName = freezed,Object? inviterId = null,Object? targetUserId = null,Object? status = null,Object? reason = freezed,Object? createdAt = freezed,Object? expiresAt = freezed,Object? expiresInSeconds = null,Object? resolvedByDeviceId = freezed,}) {
  return _then(_self.copyWith(
ringId: null == ringId ? _self.ringId : ringId // ignore: cast_nullable_to_non_nullable
as String,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,channelName: freezed == channelName ? _self.channelName : channelName // ignore: cast_nullable_to_non_nullable
as String?,inviterId: null == inviterId ? _self.inviterId : inviterId // ignore: cast_nullable_to_non_nullable
as String,targetUserId: null == targetUserId ? _self.targetUserId : targetUserId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VoiceRingStatus,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as VoiceRingReason?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresInSeconds: null == expiresInSeconds ? _self.expiresInSeconds : expiresInSeconds // ignore: cast_nullable_to_non_nullable
as int,resolvedByDeviceId: freezed == resolvedByDeviceId ? _self.resolvedByDeviceId : resolvedByDeviceId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VoiceRingDto].
extension VoiceRingDtoPatterns on VoiceRingDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoiceRingDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoiceRingDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoiceRingDto value)  $default,){
final _that = this;
switch (_that) {
case _VoiceRingDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoiceRingDto value)?  $default,){
final _that = this;
switch (_that) {
case _VoiceRingDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ringId,  String guildId,  String channelId,  String? channelName,  String inviterId,  String targetUserId, @JsonKey(unknownEnumValue: VoiceRingStatus.unknown)  VoiceRingStatus status, @JsonKey(unknownEnumValue: VoiceRingReason.unknown)  VoiceRingReason? reason,  DateTime? createdAt,  DateTime? expiresAt,  int expiresInSeconds,  String? resolvedByDeviceId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoiceRingDto() when $default != null:
return $default(_that.ringId,_that.guildId,_that.channelId,_that.channelName,_that.inviterId,_that.targetUserId,_that.status,_that.reason,_that.createdAt,_that.expiresAt,_that.expiresInSeconds,_that.resolvedByDeviceId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ringId,  String guildId,  String channelId,  String? channelName,  String inviterId,  String targetUserId, @JsonKey(unknownEnumValue: VoiceRingStatus.unknown)  VoiceRingStatus status, @JsonKey(unknownEnumValue: VoiceRingReason.unknown)  VoiceRingReason? reason,  DateTime? createdAt,  DateTime? expiresAt,  int expiresInSeconds,  String? resolvedByDeviceId)  $default,) {final _that = this;
switch (_that) {
case _VoiceRingDto():
return $default(_that.ringId,_that.guildId,_that.channelId,_that.channelName,_that.inviterId,_that.targetUserId,_that.status,_that.reason,_that.createdAt,_that.expiresAt,_that.expiresInSeconds,_that.resolvedByDeviceId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ringId,  String guildId,  String channelId,  String? channelName,  String inviterId,  String targetUserId, @JsonKey(unknownEnumValue: VoiceRingStatus.unknown)  VoiceRingStatus status, @JsonKey(unknownEnumValue: VoiceRingReason.unknown)  VoiceRingReason? reason,  DateTime? createdAt,  DateTime? expiresAt,  int expiresInSeconds,  String? resolvedByDeviceId)?  $default,) {final _that = this;
switch (_that) {
case _VoiceRingDto() when $default != null:
return $default(_that.ringId,_that.guildId,_that.channelId,_that.channelName,_that.inviterId,_that.targetUserId,_that.status,_that.reason,_that.createdAt,_that.expiresAt,_that.expiresInSeconds,_that.resolvedByDeviceId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _VoiceRingDto implements VoiceRingDto {
  const _VoiceRingDto({required this.ringId, required this.guildId, required this.channelId, this.channelName, required this.inviterId, required this.targetUserId, @JsonKey(unknownEnumValue: VoiceRingStatus.unknown) this.status = VoiceRingStatus.pending, @JsonKey(unknownEnumValue: VoiceRingReason.unknown) this.reason, this.createdAt, this.expiresAt, this.expiresInSeconds = 0, this.resolvedByDeviceId});
  factory _VoiceRingDto.fromJson(Map<String, dynamic> json) => _$VoiceRingDtoFromJson(json);

@override final  String ringId;
@override final  String guildId;
@override final  String channelId;
/// Null on the response to your own send - you sent it, you know the
/// channel. Populated on the catch-up read and on the realtime event, where
/// the reader may not.
@override final  String? channelName;
@override final  String inviterId;
@override final  String targetUserId;
@override@JsonKey(unknownEnumValue: VoiceRingStatus.unknown) final  VoiceRingStatus status;
@override@JsonKey(unknownEnumValue: VoiceRingReason.unknown) final  VoiceRingReason? reason;
@override final  DateTime? createdAt;
@override final  DateTime? expiresAt;
/// **Count down from this, not from [expiresAt].** A handset whose clock is
/// a few minutes out is ordinary rather than exotic, and trusting an
/// absolute deadline there draws an invitation that is already dead or one
/// that never lapses.
@override@JsonKey() final  int expiresInSeconds;
/// The device that answered, or null for a resolution nobody pressed a
/// button for. If it is this device, it already knows.
@override final  String? resolvedByDeviceId;

/// Create a copy of VoiceRingDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoiceRingDtoCopyWith<_VoiceRingDto> get copyWith => __$VoiceRingDtoCopyWithImpl<_VoiceRingDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoiceRingDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoiceRingDto&&(identical(other.ringId, ringId) || other.ringId == ringId)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.channelName, channelName) || other.channelName == channelName)&&(identical(other.inviterId, inviterId) || other.inviterId == inviterId)&&(identical(other.targetUserId, targetUserId) || other.targetUserId == targetUserId)&&(identical(other.status, status) || other.status == status)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.expiresInSeconds, expiresInSeconds) || other.expiresInSeconds == expiresInSeconds)&&(identical(other.resolvedByDeviceId, resolvedByDeviceId) || other.resolvedByDeviceId == resolvedByDeviceId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ringId,guildId,channelId,channelName,inviterId,targetUserId,status,reason,createdAt,expiresAt,expiresInSeconds,resolvedByDeviceId);

@override
String toString() {
  return 'VoiceRingDto(ringId: $ringId, guildId: $guildId, channelId: $channelId, channelName: $channelName, inviterId: $inviterId, targetUserId: $targetUserId, status: $status, reason: $reason, createdAt: $createdAt, expiresAt: $expiresAt, expiresInSeconds: $expiresInSeconds, resolvedByDeviceId: $resolvedByDeviceId)';
}


}

/// @nodoc
abstract mixin class _$VoiceRingDtoCopyWith<$Res> implements $VoiceRingDtoCopyWith<$Res> {
  factory _$VoiceRingDtoCopyWith(_VoiceRingDto value, $Res Function(_VoiceRingDto) _then) = __$VoiceRingDtoCopyWithImpl;
@override @useResult
$Res call({
 String ringId, String guildId, String channelId, String? channelName, String inviterId, String targetUserId,@JsonKey(unknownEnumValue: VoiceRingStatus.unknown) VoiceRingStatus status,@JsonKey(unknownEnumValue: VoiceRingReason.unknown) VoiceRingReason? reason, DateTime? createdAt, DateTime? expiresAt, int expiresInSeconds, String? resolvedByDeviceId
});




}
/// @nodoc
class __$VoiceRingDtoCopyWithImpl<$Res>
    implements _$VoiceRingDtoCopyWith<$Res> {
  __$VoiceRingDtoCopyWithImpl(this._self, this._then);

  final _VoiceRingDto _self;
  final $Res Function(_VoiceRingDto) _then;

/// Create a copy of VoiceRingDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ringId = null,Object? guildId = null,Object? channelId = null,Object? channelName = freezed,Object? inviterId = null,Object? targetUserId = null,Object? status = null,Object? reason = freezed,Object? createdAt = freezed,Object? expiresAt = freezed,Object? expiresInSeconds = null,Object? resolvedByDeviceId = freezed,}) {
  return _then(_VoiceRingDto(
ringId: null == ringId ? _self.ringId : ringId // ignore: cast_nullable_to_non_nullable
as String,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,channelName: freezed == channelName ? _self.channelName : channelName // ignore: cast_nullable_to_non_nullable
as String?,inviterId: null == inviterId ? _self.inviterId : inviterId // ignore: cast_nullable_to_non_nullable
as String,targetUserId: null == targetUserId ? _self.targetUserId : targetUserId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VoiceRingStatus,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as VoiceRingReason?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresInSeconds: null == expiresInSeconds ? _self.expiresInSeconds : expiresInSeconds // ignore: cast_nullable_to_non_nullable
as int,resolvedByDeviceId: freezed == resolvedByDeviceId ? _self.resolvedByDeviceId : resolvedByDeviceId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$VoiceInviteSentDto {

 String get conversationId;
/// Create a copy of VoiceInviteSentDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceInviteSentDtoCopyWith<VoiceInviteSentDto> get copyWith => _$VoiceInviteSentDtoCopyWithImpl<VoiceInviteSentDto>(this as VoiceInviteSentDto, _$identity);

  /// Serializes this VoiceInviteSentDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceInviteSentDto&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,conversationId);

@override
String toString() {
  return 'VoiceInviteSentDto(conversationId: $conversationId)';
}


}

/// @nodoc
abstract mixin class $VoiceInviteSentDtoCopyWith<$Res>  {
  factory $VoiceInviteSentDtoCopyWith(VoiceInviteSentDto value, $Res Function(VoiceInviteSentDto) _then) = _$VoiceInviteSentDtoCopyWithImpl;
@useResult
$Res call({
 String conversationId
});




}
/// @nodoc
class _$VoiceInviteSentDtoCopyWithImpl<$Res>
    implements $VoiceInviteSentDtoCopyWith<$Res> {
  _$VoiceInviteSentDtoCopyWithImpl(this._self, this._then);

  final VoiceInviteSentDto _self;
  final $Res Function(VoiceInviteSentDto) _then;

/// Create a copy of VoiceInviteSentDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? conversationId = null,}) {
  return _then(_self.copyWith(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VoiceInviteSentDto].
extension VoiceInviteSentDtoPatterns on VoiceInviteSentDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoiceInviteSentDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoiceInviteSentDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoiceInviteSentDto value)  $default,){
final _that = this;
switch (_that) {
case _VoiceInviteSentDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoiceInviteSentDto value)?  $default,){
final _that = this;
switch (_that) {
case _VoiceInviteSentDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String conversationId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoiceInviteSentDto() when $default != null:
return $default(_that.conversationId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String conversationId)  $default,) {final _that = this;
switch (_that) {
case _VoiceInviteSentDto():
return $default(_that.conversationId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String conversationId)?  $default,) {final _that = this;
switch (_that) {
case _VoiceInviteSentDto() when $default != null:
return $default(_that.conversationId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoiceInviteSentDto implements VoiceInviteSentDto {
  const _VoiceInviteSentDto({this.conversationId = ''});
  factory _VoiceInviteSentDto.fromJson(Map<String, dynamic> json) => _$VoiceInviteSentDtoFromJson(json);

@override@JsonKey() final  String conversationId;

/// Create a copy of VoiceInviteSentDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoiceInviteSentDtoCopyWith<_VoiceInviteSentDto> get copyWith => __$VoiceInviteSentDtoCopyWithImpl<_VoiceInviteSentDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoiceInviteSentDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoiceInviteSentDto&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,conversationId);

@override
String toString() {
  return 'VoiceInviteSentDto(conversationId: $conversationId)';
}


}

/// @nodoc
abstract mixin class _$VoiceInviteSentDtoCopyWith<$Res> implements $VoiceInviteSentDtoCopyWith<$Res> {
  factory _$VoiceInviteSentDtoCopyWith(_VoiceInviteSentDto value, $Res Function(_VoiceInviteSentDto) _then) = __$VoiceInviteSentDtoCopyWithImpl;
@override @useResult
$Res call({
 String conversationId
});




}
/// @nodoc
class __$VoiceInviteSentDtoCopyWithImpl<$Res>
    implements _$VoiceInviteSentDtoCopyWith<$Res> {
  __$VoiceInviteSentDtoCopyWithImpl(this._self, this._then);

  final _VoiceInviteSentDto _self;
  final $Res Function(_VoiceInviteSentDto) _then;

/// Create a copy of VoiceInviteSentDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? conversationId = null,}) {
  return _then(_VoiceInviteSentDto(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$VoiceRingRefusalDto {

@JsonKey(unknownEnumValue: VoiceRingRefusal.unknown) VoiceRingRefusal get reason; int get retryAfterSeconds;
/// Create a copy of VoiceRingRefusalDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceRingRefusalDtoCopyWith<VoiceRingRefusalDto> get copyWith => _$VoiceRingRefusalDtoCopyWithImpl<VoiceRingRefusalDto>(this as VoiceRingRefusalDto, _$identity);

  /// Serializes this VoiceRingRefusalDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceRingRefusalDto&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.retryAfterSeconds, retryAfterSeconds) || other.retryAfterSeconds == retryAfterSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reason,retryAfterSeconds);

@override
String toString() {
  return 'VoiceRingRefusalDto(reason: $reason, retryAfterSeconds: $retryAfterSeconds)';
}


}

/// @nodoc
abstract mixin class $VoiceRingRefusalDtoCopyWith<$Res>  {
  factory $VoiceRingRefusalDtoCopyWith(VoiceRingRefusalDto value, $Res Function(VoiceRingRefusalDto) _then) = _$VoiceRingRefusalDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: VoiceRingRefusal.unknown) VoiceRingRefusal reason, int retryAfterSeconds
});




}
/// @nodoc
class _$VoiceRingRefusalDtoCopyWithImpl<$Res>
    implements $VoiceRingRefusalDtoCopyWith<$Res> {
  _$VoiceRingRefusalDtoCopyWithImpl(this._self, this._then);

  final VoiceRingRefusalDto _self;
  final $Res Function(VoiceRingRefusalDto) _then;

/// Create a copy of VoiceRingRefusalDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reason = null,Object? retryAfterSeconds = null,}) {
  return _then(_self.copyWith(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as VoiceRingRefusal,retryAfterSeconds: null == retryAfterSeconds ? _self.retryAfterSeconds : retryAfterSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [VoiceRingRefusalDto].
extension VoiceRingRefusalDtoPatterns on VoiceRingRefusalDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoiceRingRefusalDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoiceRingRefusalDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoiceRingRefusalDto value)  $default,){
final _that = this;
switch (_that) {
case _VoiceRingRefusalDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoiceRingRefusalDto value)?  $default,){
final _that = this;
switch (_that) {
case _VoiceRingRefusalDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: VoiceRingRefusal.unknown)  VoiceRingRefusal reason,  int retryAfterSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoiceRingRefusalDto() when $default != null:
return $default(_that.reason,_that.retryAfterSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: VoiceRingRefusal.unknown)  VoiceRingRefusal reason,  int retryAfterSeconds)  $default,) {final _that = this;
switch (_that) {
case _VoiceRingRefusalDto():
return $default(_that.reason,_that.retryAfterSeconds);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: VoiceRingRefusal.unknown)  VoiceRingRefusal reason,  int retryAfterSeconds)?  $default,) {final _that = this;
switch (_that) {
case _VoiceRingRefusalDto() when $default != null:
return $default(_that.reason,_that.retryAfterSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoiceRingRefusalDto implements VoiceRingRefusalDto {
  const _VoiceRingRefusalDto({@JsonKey(unknownEnumValue: VoiceRingRefusal.unknown) this.reason = VoiceRingRefusal.unknown, this.retryAfterSeconds = 0});
  factory _VoiceRingRefusalDto.fromJson(Map<String, dynamic> json) => _$VoiceRingRefusalDtoFromJson(json);

@override@JsonKey(unknownEnumValue: VoiceRingRefusal.unknown) final  VoiceRingRefusal reason;
@override@JsonKey() final  int retryAfterSeconds;

/// Create a copy of VoiceRingRefusalDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoiceRingRefusalDtoCopyWith<_VoiceRingRefusalDto> get copyWith => __$VoiceRingRefusalDtoCopyWithImpl<_VoiceRingRefusalDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoiceRingRefusalDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoiceRingRefusalDto&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.retryAfterSeconds, retryAfterSeconds) || other.retryAfterSeconds == retryAfterSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reason,retryAfterSeconds);

@override
String toString() {
  return 'VoiceRingRefusalDto(reason: $reason, retryAfterSeconds: $retryAfterSeconds)';
}


}

/// @nodoc
abstract mixin class _$VoiceRingRefusalDtoCopyWith<$Res> implements $VoiceRingRefusalDtoCopyWith<$Res> {
  factory _$VoiceRingRefusalDtoCopyWith(_VoiceRingRefusalDto value, $Res Function(_VoiceRingRefusalDto) _then) = __$VoiceRingRefusalDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: VoiceRingRefusal.unknown) VoiceRingRefusal reason, int retryAfterSeconds
});




}
/// @nodoc
class __$VoiceRingRefusalDtoCopyWithImpl<$Res>
    implements _$VoiceRingRefusalDtoCopyWith<$Res> {
  __$VoiceRingRefusalDtoCopyWithImpl(this._self, this._then);

  final _VoiceRingRefusalDto _self;
  final $Res Function(_VoiceRingRefusalDto) _then;

/// Create a copy of VoiceRingRefusalDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reason = null,Object? retryAfterSeconds = null,}) {
  return _then(_VoiceRingRefusalDto(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as VoiceRingRefusal,retryAfterSeconds: null == retryAfterSeconds ? _self.retryAfterSeconds : retryAfterSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$VoiceRingInvitationDto {

 String get ringId; String get guildId; String get channelId; String? get channelName; String get inviterId;/// Can be null if the profile lookup failed. [inviterId] never is - resolve
/// the person from that rather than trusting the frozen copy.
 String? get inviterName; String? get inviterAvatarUrl; String get targetUserId; DateTime? get createdAt; DateTime? get expiresAt; int get expiresInSeconds;/// Who is already in the channel, so the card can show faces. Safe to
/// render: the server only sends this ring to somebody who has `ViewChannel`
/// on the channel.
 List<String> get participantUserIds;
/// Create a copy of VoiceRingInvitationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceRingInvitationDtoCopyWith<VoiceRingInvitationDto> get copyWith => _$VoiceRingInvitationDtoCopyWithImpl<VoiceRingInvitationDto>(this as VoiceRingInvitationDto, _$identity);

  /// Serializes this VoiceRingInvitationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceRingInvitationDto&&(identical(other.ringId, ringId) || other.ringId == ringId)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.channelName, channelName) || other.channelName == channelName)&&(identical(other.inviterId, inviterId) || other.inviterId == inviterId)&&(identical(other.inviterName, inviterName) || other.inviterName == inviterName)&&(identical(other.inviterAvatarUrl, inviterAvatarUrl) || other.inviterAvatarUrl == inviterAvatarUrl)&&(identical(other.targetUserId, targetUserId) || other.targetUserId == targetUserId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.expiresInSeconds, expiresInSeconds) || other.expiresInSeconds == expiresInSeconds)&&const DeepCollectionEquality().equals(other.participantUserIds, participantUserIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ringId,guildId,channelId,channelName,inviterId,inviterName,inviterAvatarUrl,targetUserId,createdAt,expiresAt,expiresInSeconds,const DeepCollectionEquality().hash(participantUserIds));

@override
String toString() {
  return 'VoiceRingInvitationDto(ringId: $ringId, guildId: $guildId, channelId: $channelId, channelName: $channelName, inviterId: $inviterId, inviterName: $inviterName, inviterAvatarUrl: $inviterAvatarUrl, targetUserId: $targetUserId, createdAt: $createdAt, expiresAt: $expiresAt, expiresInSeconds: $expiresInSeconds, participantUserIds: $participantUserIds)';
}


}

/// @nodoc
abstract mixin class $VoiceRingInvitationDtoCopyWith<$Res>  {
  factory $VoiceRingInvitationDtoCopyWith(VoiceRingInvitationDto value, $Res Function(VoiceRingInvitationDto) _then) = _$VoiceRingInvitationDtoCopyWithImpl;
@useResult
$Res call({
 String ringId, String guildId, String channelId, String? channelName, String inviterId, String? inviterName, String? inviterAvatarUrl, String targetUserId, DateTime? createdAt, DateTime? expiresAt, int expiresInSeconds, List<String> participantUserIds
});




}
/// @nodoc
class _$VoiceRingInvitationDtoCopyWithImpl<$Res>
    implements $VoiceRingInvitationDtoCopyWith<$Res> {
  _$VoiceRingInvitationDtoCopyWithImpl(this._self, this._then);

  final VoiceRingInvitationDto _self;
  final $Res Function(VoiceRingInvitationDto) _then;

/// Create a copy of VoiceRingInvitationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ringId = null,Object? guildId = null,Object? channelId = null,Object? channelName = freezed,Object? inviterId = null,Object? inviterName = freezed,Object? inviterAvatarUrl = freezed,Object? targetUserId = null,Object? createdAt = freezed,Object? expiresAt = freezed,Object? expiresInSeconds = null,Object? participantUserIds = null,}) {
  return _then(_self.copyWith(
ringId: null == ringId ? _self.ringId : ringId // ignore: cast_nullable_to_non_nullable
as String,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,channelName: freezed == channelName ? _self.channelName : channelName // ignore: cast_nullable_to_non_nullable
as String?,inviterId: null == inviterId ? _self.inviterId : inviterId // ignore: cast_nullable_to_non_nullable
as String,inviterName: freezed == inviterName ? _self.inviterName : inviterName // ignore: cast_nullable_to_non_nullable
as String?,inviterAvatarUrl: freezed == inviterAvatarUrl ? _self.inviterAvatarUrl : inviterAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,targetUserId: null == targetUserId ? _self.targetUserId : targetUserId // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresInSeconds: null == expiresInSeconds ? _self.expiresInSeconds : expiresInSeconds // ignore: cast_nullable_to_non_nullable
as int,participantUserIds: null == participantUserIds ? _self.participantUserIds : participantUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [VoiceRingInvitationDto].
extension VoiceRingInvitationDtoPatterns on VoiceRingInvitationDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoiceRingInvitationDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoiceRingInvitationDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoiceRingInvitationDto value)  $default,){
final _that = this;
switch (_that) {
case _VoiceRingInvitationDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoiceRingInvitationDto value)?  $default,){
final _that = this;
switch (_that) {
case _VoiceRingInvitationDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ringId,  String guildId,  String channelId,  String? channelName,  String inviterId,  String? inviterName,  String? inviterAvatarUrl,  String targetUserId,  DateTime? createdAt,  DateTime? expiresAt,  int expiresInSeconds,  List<String> participantUserIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoiceRingInvitationDto() when $default != null:
return $default(_that.ringId,_that.guildId,_that.channelId,_that.channelName,_that.inviterId,_that.inviterName,_that.inviterAvatarUrl,_that.targetUserId,_that.createdAt,_that.expiresAt,_that.expiresInSeconds,_that.participantUserIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ringId,  String guildId,  String channelId,  String? channelName,  String inviterId,  String? inviterName,  String? inviterAvatarUrl,  String targetUserId,  DateTime? createdAt,  DateTime? expiresAt,  int expiresInSeconds,  List<String> participantUserIds)  $default,) {final _that = this;
switch (_that) {
case _VoiceRingInvitationDto():
return $default(_that.ringId,_that.guildId,_that.channelId,_that.channelName,_that.inviterId,_that.inviterName,_that.inviterAvatarUrl,_that.targetUserId,_that.createdAt,_that.expiresAt,_that.expiresInSeconds,_that.participantUserIds);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ringId,  String guildId,  String channelId,  String? channelName,  String inviterId,  String? inviterName,  String? inviterAvatarUrl,  String targetUserId,  DateTime? createdAt,  DateTime? expiresAt,  int expiresInSeconds,  List<String> participantUserIds)?  $default,) {final _that = this;
switch (_that) {
case _VoiceRingInvitationDto() when $default != null:
return $default(_that.ringId,_that.guildId,_that.channelId,_that.channelName,_that.inviterId,_that.inviterName,_that.inviterAvatarUrl,_that.targetUserId,_that.createdAt,_that.expiresAt,_that.expiresInSeconds,_that.participantUserIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _VoiceRingInvitationDto implements VoiceRingInvitationDto {
  const _VoiceRingInvitationDto({required this.ringId, required this.guildId, required this.channelId, this.channelName, required this.inviterId, this.inviterName, this.inviterAvatarUrl, required this.targetUserId, this.createdAt, this.expiresAt, this.expiresInSeconds = 0, final  List<String> participantUserIds = const <String>[]}): _participantUserIds = participantUserIds;
  factory _VoiceRingInvitationDto.fromJson(Map<String, dynamic> json) => _$VoiceRingInvitationDtoFromJson(json);

@override final  String ringId;
@override final  String guildId;
@override final  String channelId;
@override final  String? channelName;
@override final  String inviterId;
/// Can be null if the profile lookup failed. [inviterId] never is - resolve
/// the person from that rather than trusting the frozen copy.
@override final  String? inviterName;
@override final  String? inviterAvatarUrl;
@override final  String targetUserId;
@override final  DateTime? createdAt;
@override final  DateTime? expiresAt;
@override@JsonKey() final  int expiresInSeconds;
/// Who is already in the channel, so the card can show faces. Safe to
/// render: the server only sends this ring to somebody who has `ViewChannel`
/// on the channel.
 final  List<String> _participantUserIds;
/// Who is already in the channel, so the card can show faces. Safe to
/// render: the server only sends this ring to somebody who has `ViewChannel`
/// on the channel.
@override@JsonKey() List<String> get participantUserIds {
  if (_participantUserIds is EqualUnmodifiableListView) return _participantUserIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participantUserIds);
}


/// Create a copy of VoiceRingInvitationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoiceRingInvitationDtoCopyWith<_VoiceRingInvitationDto> get copyWith => __$VoiceRingInvitationDtoCopyWithImpl<_VoiceRingInvitationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoiceRingInvitationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoiceRingInvitationDto&&(identical(other.ringId, ringId) || other.ringId == ringId)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.channelName, channelName) || other.channelName == channelName)&&(identical(other.inviterId, inviterId) || other.inviterId == inviterId)&&(identical(other.inviterName, inviterName) || other.inviterName == inviterName)&&(identical(other.inviterAvatarUrl, inviterAvatarUrl) || other.inviterAvatarUrl == inviterAvatarUrl)&&(identical(other.targetUserId, targetUserId) || other.targetUserId == targetUserId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.expiresInSeconds, expiresInSeconds) || other.expiresInSeconds == expiresInSeconds)&&const DeepCollectionEquality().equals(other._participantUserIds, _participantUserIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ringId,guildId,channelId,channelName,inviterId,inviterName,inviterAvatarUrl,targetUserId,createdAt,expiresAt,expiresInSeconds,const DeepCollectionEquality().hash(_participantUserIds));

@override
String toString() {
  return 'VoiceRingInvitationDto(ringId: $ringId, guildId: $guildId, channelId: $channelId, channelName: $channelName, inviterId: $inviterId, inviterName: $inviterName, inviterAvatarUrl: $inviterAvatarUrl, targetUserId: $targetUserId, createdAt: $createdAt, expiresAt: $expiresAt, expiresInSeconds: $expiresInSeconds, participantUserIds: $participantUserIds)';
}


}

/// @nodoc
abstract mixin class _$VoiceRingInvitationDtoCopyWith<$Res> implements $VoiceRingInvitationDtoCopyWith<$Res> {
  factory _$VoiceRingInvitationDtoCopyWith(_VoiceRingInvitationDto value, $Res Function(_VoiceRingInvitationDto) _then) = __$VoiceRingInvitationDtoCopyWithImpl;
@override @useResult
$Res call({
 String ringId, String guildId, String channelId, String? channelName, String inviterId, String? inviterName, String? inviterAvatarUrl, String targetUserId, DateTime? createdAt, DateTime? expiresAt, int expiresInSeconds, List<String> participantUserIds
});




}
/// @nodoc
class __$VoiceRingInvitationDtoCopyWithImpl<$Res>
    implements _$VoiceRingInvitationDtoCopyWith<$Res> {
  __$VoiceRingInvitationDtoCopyWithImpl(this._self, this._then);

  final _VoiceRingInvitationDto _self;
  final $Res Function(_VoiceRingInvitationDto) _then;

/// Create a copy of VoiceRingInvitationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ringId = null,Object? guildId = null,Object? channelId = null,Object? channelName = freezed,Object? inviterId = null,Object? inviterName = freezed,Object? inviterAvatarUrl = freezed,Object? targetUserId = null,Object? createdAt = freezed,Object? expiresAt = freezed,Object? expiresInSeconds = null,Object? participantUserIds = null,}) {
  return _then(_VoiceRingInvitationDto(
ringId: null == ringId ? _self.ringId : ringId // ignore: cast_nullable_to_non_nullable
as String,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,channelName: freezed == channelName ? _self.channelName : channelName // ignore: cast_nullable_to_non_nullable
as String?,inviterId: null == inviterId ? _self.inviterId : inviterId // ignore: cast_nullable_to_non_nullable
as String,inviterName: freezed == inviterName ? _self.inviterName : inviterName // ignore: cast_nullable_to_non_nullable
as String?,inviterAvatarUrl: freezed == inviterAvatarUrl ? _self.inviterAvatarUrl : inviterAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,targetUserId: null == targetUserId ? _self.targetUserId : targetUserId // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresInSeconds: null == expiresInSeconds ? _self.expiresInSeconds : expiresInSeconds // ignore: cast_nullable_to_non_nullable
as int,participantUserIds: null == participantUserIds ? _self._participantUserIds : participantUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$VoiceRingResolvedDto {

 String get ringId; String get guildId; String get channelId; String get inviterId; String get targetUserId;@JsonKey(unknownEnumValue: VoiceRingStatus.unknown) VoiceRingStatus get status;@JsonKey(unknownEnumValue: VoiceRingReason.unknown) VoiceRingReason? get reason; DateTime? get resolvedAt; String? get resolvedByDeviceId;
/// Create a copy of VoiceRingResolvedDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceRingResolvedDtoCopyWith<VoiceRingResolvedDto> get copyWith => _$VoiceRingResolvedDtoCopyWithImpl<VoiceRingResolvedDto>(this as VoiceRingResolvedDto, _$identity);

  /// Serializes this VoiceRingResolvedDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceRingResolvedDto&&(identical(other.ringId, ringId) || other.ringId == ringId)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.inviterId, inviterId) || other.inviterId == inviterId)&&(identical(other.targetUserId, targetUserId) || other.targetUserId == targetUserId)&&(identical(other.status, status) || other.status == status)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.resolvedByDeviceId, resolvedByDeviceId) || other.resolvedByDeviceId == resolvedByDeviceId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ringId,guildId,channelId,inviterId,targetUserId,status,reason,resolvedAt,resolvedByDeviceId);

@override
String toString() {
  return 'VoiceRingResolvedDto(ringId: $ringId, guildId: $guildId, channelId: $channelId, inviterId: $inviterId, targetUserId: $targetUserId, status: $status, reason: $reason, resolvedAt: $resolvedAt, resolvedByDeviceId: $resolvedByDeviceId)';
}


}

/// @nodoc
abstract mixin class $VoiceRingResolvedDtoCopyWith<$Res>  {
  factory $VoiceRingResolvedDtoCopyWith(VoiceRingResolvedDto value, $Res Function(VoiceRingResolvedDto) _then) = _$VoiceRingResolvedDtoCopyWithImpl;
@useResult
$Res call({
 String ringId, String guildId, String channelId, String inviterId, String targetUserId,@JsonKey(unknownEnumValue: VoiceRingStatus.unknown) VoiceRingStatus status,@JsonKey(unknownEnumValue: VoiceRingReason.unknown) VoiceRingReason? reason, DateTime? resolvedAt, String? resolvedByDeviceId
});




}
/// @nodoc
class _$VoiceRingResolvedDtoCopyWithImpl<$Res>
    implements $VoiceRingResolvedDtoCopyWith<$Res> {
  _$VoiceRingResolvedDtoCopyWithImpl(this._self, this._then);

  final VoiceRingResolvedDto _self;
  final $Res Function(VoiceRingResolvedDto) _then;

/// Create a copy of VoiceRingResolvedDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ringId = null,Object? guildId = null,Object? channelId = null,Object? inviterId = null,Object? targetUserId = null,Object? status = null,Object? reason = freezed,Object? resolvedAt = freezed,Object? resolvedByDeviceId = freezed,}) {
  return _then(_self.copyWith(
ringId: null == ringId ? _self.ringId : ringId // ignore: cast_nullable_to_non_nullable
as String,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,inviterId: null == inviterId ? _self.inviterId : inviterId // ignore: cast_nullable_to_non_nullable
as String,targetUserId: null == targetUserId ? _self.targetUserId : targetUserId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VoiceRingStatus,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as VoiceRingReason?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolvedByDeviceId: freezed == resolvedByDeviceId ? _self.resolvedByDeviceId : resolvedByDeviceId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VoiceRingResolvedDto].
extension VoiceRingResolvedDtoPatterns on VoiceRingResolvedDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoiceRingResolvedDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoiceRingResolvedDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoiceRingResolvedDto value)  $default,){
final _that = this;
switch (_that) {
case _VoiceRingResolvedDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoiceRingResolvedDto value)?  $default,){
final _that = this;
switch (_that) {
case _VoiceRingResolvedDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ringId,  String guildId,  String channelId,  String inviterId,  String targetUserId, @JsonKey(unknownEnumValue: VoiceRingStatus.unknown)  VoiceRingStatus status, @JsonKey(unknownEnumValue: VoiceRingReason.unknown)  VoiceRingReason? reason,  DateTime? resolvedAt,  String? resolvedByDeviceId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoiceRingResolvedDto() when $default != null:
return $default(_that.ringId,_that.guildId,_that.channelId,_that.inviterId,_that.targetUserId,_that.status,_that.reason,_that.resolvedAt,_that.resolvedByDeviceId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ringId,  String guildId,  String channelId,  String inviterId,  String targetUserId, @JsonKey(unknownEnumValue: VoiceRingStatus.unknown)  VoiceRingStatus status, @JsonKey(unknownEnumValue: VoiceRingReason.unknown)  VoiceRingReason? reason,  DateTime? resolvedAt,  String? resolvedByDeviceId)  $default,) {final _that = this;
switch (_that) {
case _VoiceRingResolvedDto():
return $default(_that.ringId,_that.guildId,_that.channelId,_that.inviterId,_that.targetUserId,_that.status,_that.reason,_that.resolvedAt,_that.resolvedByDeviceId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ringId,  String guildId,  String channelId,  String inviterId,  String targetUserId, @JsonKey(unknownEnumValue: VoiceRingStatus.unknown)  VoiceRingStatus status, @JsonKey(unknownEnumValue: VoiceRingReason.unknown)  VoiceRingReason? reason,  DateTime? resolvedAt,  String? resolvedByDeviceId)?  $default,) {final _that = this;
switch (_that) {
case _VoiceRingResolvedDto() when $default != null:
return $default(_that.ringId,_that.guildId,_that.channelId,_that.inviterId,_that.targetUserId,_that.status,_that.reason,_that.resolvedAt,_that.resolvedByDeviceId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _VoiceRingResolvedDto implements VoiceRingResolvedDto {
  const _VoiceRingResolvedDto({required this.ringId, required this.guildId, required this.channelId, required this.inviterId, required this.targetUserId, @JsonKey(unknownEnumValue: VoiceRingStatus.unknown) this.status = VoiceRingStatus.unknown, @JsonKey(unknownEnumValue: VoiceRingReason.unknown) this.reason, this.resolvedAt, this.resolvedByDeviceId});
  factory _VoiceRingResolvedDto.fromJson(Map<String, dynamic> json) => _$VoiceRingResolvedDtoFromJson(json);

@override final  String ringId;
@override final  String guildId;
@override final  String channelId;
@override final  String inviterId;
@override final  String targetUserId;
@override@JsonKey(unknownEnumValue: VoiceRingStatus.unknown) final  VoiceRingStatus status;
@override@JsonKey(unknownEnumValue: VoiceRingReason.unknown) final  VoiceRingReason? reason;
@override final  DateTime? resolvedAt;
@override final  String? resolvedByDeviceId;

/// Create a copy of VoiceRingResolvedDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoiceRingResolvedDtoCopyWith<_VoiceRingResolvedDto> get copyWith => __$VoiceRingResolvedDtoCopyWithImpl<_VoiceRingResolvedDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoiceRingResolvedDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoiceRingResolvedDto&&(identical(other.ringId, ringId) || other.ringId == ringId)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.inviterId, inviterId) || other.inviterId == inviterId)&&(identical(other.targetUserId, targetUserId) || other.targetUserId == targetUserId)&&(identical(other.status, status) || other.status == status)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.resolvedByDeviceId, resolvedByDeviceId) || other.resolvedByDeviceId == resolvedByDeviceId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ringId,guildId,channelId,inviterId,targetUserId,status,reason,resolvedAt,resolvedByDeviceId);

@override
String toString() {
  return 'VoiceRingResolvedDto(ringId: $ringId, guildId: $guildId, channelId: $channelId, inviterId: $inviterId, targetUserId: $targetUserId, status: $status, reason: $reason, resolvedAt: $resolvedAt, resolvedByDeviceId: $resolvedByDeviceId)';
}


}

/// @nodoc
abstract mixin class _$VoiceRingResolvedDtoCopyWith<$Res> implements $VoiceRingResolvedDtoCopyWith<$Res> {
  factory _$VoiceRingResolvedDtoCopyWith(_VoiceRingResolvedDto value, $Res Function(_VoiceRingResolvedDto) _then) = __$VoiceRingResolvedDtoCopyWithImpl;
@override @useResult
$Res call({
 String ringId, String guildId, String channelId, String inviterId, String targetUserId,@JsonKey(unknownEnumValue: VoiceRingStatus.unknown) VoiceRingStatus status,@JsonKey(unknownEnumValue: VoiceRingReason.unknown) VoiceRingReason? reason, DateTime? resolvedAt, String? resolvedByDeviceId
});




}
/// @nodoc
class __$VoiceRingResolvedDtoCopyWithImpl<$Res>
    implements _$VoiceRingResolvedDtoCopyWith<$Res> {
  __$VoiceRingResolvedDtoCopyWithImpl(this._self, this._then);

  final _VoiceRingResolvedDto _self;
  final $Res Function(_VoiceRingResolvedDto) _then;

/// Create a copy of VoiceRingResolvedDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ringId = null,Object? guildId = null,Object? channelId = null,Object? inviterId = null,Object? targetUserId = null,Object? status = null,Object? reason = freezed,Object? resolvedAt = freezed,Object? resolvedByDeviceId = freezed,}) {
  return _then(_VoiceRingResolvedDto(
ringId: null == ringId ? _self.ringId : ringId // ignore: cast_nullable_to_non_nullable
as String,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,inviterId: null == inviterId ? _self.inviterId : inviterId // ignore: cast_nullable_to_non_nullable
as String,targetUserId: null == targetUserId ? _self.targetUserId : targetUserId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VoiceRingStatus,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as VoiceRingReason?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolvedByDeviceId: freezed == resolvedByDeviceId ? _self.resolvedByDeviceId : resolvedByDeviceId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$VoiceRingDismissedDto {

 String get ringId; String get deviceId;@JsonKey(unknownEnumValue: VoiceRingStatus.unknown) VoiceRingStatus get status;@JsonKey(unknownEnumValue: VoiceRingReason.unknown) VoiceRingReason? get reason;
/// Create a copy of VoiceRingDismissedDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceRingDismissedDtoCopyWith<VoiceRingDismissedDto> get copyWith => _$VoiceRingDismissedDtoCopyWithImpl<VoiceRingDismissedDto>(this as VoiceRingDismissedDto, _$identity);

  /// Serializes this VoiceRingDismissedDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceRingDismissedDto&&(identical(other.ringId, ringId) || other.ringId == ringId)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.status, status) || other.status == status)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ringId,deviceId,status,reason);

@override
String toString() {
  return 'VoiceRingDismissedDto(ringId: $ringId, deviceId: $deviceId, status: $status, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $VoiceRingDismissedDtoCopyWith<$Res>  {
  factory $VoiceRingDismissedDtoCopyWith(VoiceRingDismissedDto value, $Res Function(VoiceRingDismissedDto) _then) = _$VoiceRingDismissedDtoCopyWithImpl;
@useResult
$Res call({
 String ringId, String deviceId,@JsonKey(unknownEnumValue: VoiceRingStatus.unknown) VoiceRingStatus status,@JsonKey(unknownEnumValue: VoiceRingReason.unknown) VoiceRingReason? reason
});




}
/// @nodoc
class _$VoiceRingDismissedDtoCopyWithImpl<$Res>
    implements $VoiceRingDismissedDtoCopyWith<$Res> {
  _$VoiceRingDismissedDtoCopyWithImpl(this._self, this._then);

  final VoiceRingDismissedDto _self;
  final $Res Function(VoiceRingDismissedDto) _then;

/// Create a copy of VoiceRingDismissedDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ringId = null,Object? deviceId = null,Object? status = null,Object? reason = freezed,}) {
  return _then(_self.copyWith(
ringId: null == ringId ? _self.ringId : ringId // ignore: cast_nullable_to_non_nullable
as String,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VoiceRingStatus,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as VoiceRingReason?,
  ));
}

}


/// Adds pattern-matching-related methods to [VoiceRingDismissedDto].
extension VoiceRingDismissedDtoPatterns on VoiceRingDismissedDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoiceRingDismissedDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoiceRingDismissedDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoiceRingDismissedDto value)  $default,){
final _that = this;
switch (_that) {
case _VoiceRingDismissedDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoiceRingDismissedDto value)?  $default,){
final _that = this;
switch (_that) {
case _VoiceRingDismissedDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ringId,  String deviceId, @JsonKey(unknownEnumValue: VoiceRingStatus.unknown)  VoiceRingStatus status, @JsonKey(unknownEnumValue: VoiceRingReason.unknown)  VoiceRingReason? reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoiceRingDismissedDto() when $default != null:
return $default(_that.ringId,_that.deviceId,_that.status,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ringId,  String deviceId, @JsonKey(unknownEnumValue: VoiceRingStatus.unknown)  VoiceRingStatus status, @JsonKey(unknownEnumValue: VoiceRingReason.unknown)  VoiceRingReason? reason)  $default,) {final _that = this;
switch (_that) {
case _VoiceRingDismissedDto():
return $default(_that.ringId,_that.deviceId,_that.status,_that.reason);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ringId,  String deviceId, @JsonKey(unknownEnumValue: VoiceRingStatus.unknown)  VoiceRingStatus status, @JsonKey(unknownEnumValue: VoiceRingReason.unknown)  VoiceRingReason? reason)?  $default,) {final _that = this;
switch (_that) {
case _VoiceRingDismissedDto() when $default != null:
return $default(_that.ringId,_that.deviceId,_that.status,_that.reason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoiceRingDismissedDto implements VoiceRingDismissedDto {
  const _VoiceRingDismissedDto({required this.ringId, required this.deviceId, @JsonKey(unknownEnumValue: VoiceRingStatus.unknown) this.status = VoiceRingStatus.unknown, @JsonKey(unknownEnumValue: VoiceRingReason.unknown) this.reason});
  factory _VoiceRingDismissedDto.fromJson(Map<String, dynamic> json) => _$VoiceRingDismissedDtoFromJson(json);

@override final  String ringId;
@override final  String deviceId;
@override@JsonKey(unknownEnumValue: VoiceRingStatus.unknown) final  VoiceRingStatus status;
@override@JsonKey(unknownEnumValue: VoiceRingReason.unknown) final  VoiceRingReason? reason;

/// Create a copy of VoiceRingDismissedDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoiceRingDismissedDtoCopyWith<_VoiceRingDismissedDto> get copyWith => __$VoiceRingDismissedDtoCopyWithImpl<_VoiceRingDismissedDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoiceRingDismissedDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoiceRingDismissedDto&&(identical(other.ringId, ringId) || other.ringId == ringId)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.status, status) || other.status == status)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ringId,deviceId,status,reason);

@override
String toString() {
  return 'VoiceRingDismissedDto(ringId: $ringId, deviceId: $deviceId, status: $status, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$VoiceRingDismissedDtoCopyWith<$Res> implements $VoiceRingDismissedDtoCopyWith<$Res> {
  factory _$VoiceRingDismissedDtoCopyWith(_VoiceRingDismissedDto value, $Res Function(_VoiceRingDismissedDto) _then) = __$VoiceRingDismissedDtoCopyWithImpl;
@override @useResult
$Res call({
 String ringId, String deviceId,@JsonKey(unknownEnumValue: VoiceRingStatus.unknown) VoiceRingStatus status,@JsonKey(unknownEnumValue: VoiceRingReason.unknown) VoiceRingReason? reason
});




}
/// @nodoc
class __$VoiceRingDismissedDtoCopyWithImpl<$Res>
    implements _$VoiceRingDismissedDtoCopyWith<$Res> {
  __$VoiceRingDismissedDtoCopyWithImpl(this._self, this._then);

  final _VoiceRingDismissedDto _self;
  final $Res Function(_VoiceRingDismissedDto) _then;

/// Create a copy of VoiceRingDismissedDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ringId = null,Object? deviceId = null,Object? status = null,Object? reason = freezed,}) {
  return _then(_VoiceRingDismissedDto(
ringId: null == ringId ? _self.ringId : ringId // ignore: cast_nullable_to_non_nullable
as String,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VoiceRingStatus,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as VoiceRingReason?,
  ));
}


}

// dart format on
