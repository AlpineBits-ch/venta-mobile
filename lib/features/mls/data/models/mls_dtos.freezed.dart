// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mls_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeviceWelcomeDto {

 String get deviceId; String get userId;/// Base64 TLS-serialized MLS Welcome.
 String get welcome;
/// Create a copy of DeviceWelcomeDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviceWelcomeDtoCopyWith<DeviceWelcomeDto> get copyWith => _$DeviceWelcomeDtoCopyWithImpl<DeviceWelcomeDto>(this as DeviceWelcomeDto, _$identity);

  /// Serializes this DeviceWelcomeDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceWelcomeDto&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.welcome, welcome) || other.welcome == welcome));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,deviceId,userId,welcome);

@override
String toString() {
  return 'DeviceWelcomeDto(deviceId: $deviceId, userId: $userId, welcome: $welcome)';
}


}

/// @nodoc
abstract mixin class $DeviceWelcomeDtoCopyWith<$Res>  {
  factory $DeviceWelcomeDtoCopyWith(DeviceWelcomeDto value, $Res Function(DeviceWelcomeDto) _then) = _$DeviceWelcomeDtoCopyWithImpl;
@useResult
$Res call({
 String deviceId, String userId, String welcome
});




}
/// @nodoc
class _$DeviceWelcomeDtoCopyWithImpl<$Res>
    implements $DeviceWelcomeDtoCopyWith<$Res> {
  _$DeviceWelcomeDtoCopyWithImpl(this._self, this._then);

  final DeviceWelcomeDto _self;
  final $Res Function(DeviceWelcomeDto) _then;

/// Create a copy of DeviceWelcomeDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? deviceId = null,Object? userId = null,Object? welcome = null,}) {
  return _then(_self.copyWith(
deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,welcome: null == welcome ? _self.welcome : welcome // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DeviceWelcomeDto].
extension DeviceWelcomeDtoPatterns on DeviceWelcomeDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeviceWelcomeDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeviceWelcomeDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeviceWelcomeDto value)  $default,){
final _that = this;
switch (_that) {
case _DeviceWelcomeDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeviceWelcomeDto value)?  $default,){
final _that = this;
switch (_that) {
case _DeviceWelcomeDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String deviceId,  String userId,  String welcome)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeviceWelcomeDto() when $default != null:
return $default(_that.deviceId,_that.userId,_that.welcome);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String deviceId,  String userId,  String welcome)  $default,) {final _that = this;
switch (_that) {
case _DeviceWelcomeDto():
return $default(_that.deviceId,_that.userId,_that.welcome);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String deviceId,  String userId,  String welcome)?  $default,) {final _that = this;
switch (_that) {
case _DeviceWelcomeDto() when $default != null:
return $default(_that.deviceId,_that.userId,_that.welcome);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeviceWelcomeDto implements DeviceWelcomeDto {
  const _DeviceWelcomeDto({required this.deviceId, required this.userId, required this.welcome});
  factory _DeviceWelcomeDto.fromJson(Map<String, dynamic> json) => _$DeviceWelcomeDtoFromJson(json);

@override final  String deviceId;
@override final  String userId;
/// Base64 TLS-serialized MLS Welcome.
@override final  String welcome;

/// Create a copy of DeviceWelcomeDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeviceWelcomeDtoCopyWith<_DeviceWelcomeDto> get copyWith => __$DeviceWelcomeDtoCopyWithImpl<_DeviceWelcomeDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeviceWelcomeDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeviceWelcomeDto&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.welcome, welcome) || other.welcome == welcome));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,deviceId,userId,welcome);

@override
String toString() {
  return 'DeviceWelcomeDto(deviceId: $deviceId, userId: $userId, welcome: $welcome)';
}


}

/// @nodoc
abstract mixin class _$DeviceWelcomeDtoCopyWith<$Res> implements $DeviceWelcomeDtoCopyWith<$Res> {
  factory _$DeviceWelcomeDtoCopyWith(_DeviceWelcomeDto value, $Res Function(_DeviceWelcomeDto) _then) = __$DeviceWelcomeDtoCopyWithImpl;
@override @useResult
$Res call({
 String deviceId, String userId, String welcome
});




}
/// @nodoc
class __$DeviceWelcomeDtoCopyWithImpl<$Res>
    implements _$DeviceWelcomeDtoCopyWith<$Res> {
  __$DeviceWelcomeDtoCopyWithImpl(this._self, this._then);

  final _DeviceWelcomeDto _self;
  final $Res Function(_DeviceWelcomeDto) _then;

/// Create a copy of DeviceWelcomeDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? deviceId = null,Object? userId = null,Object? welcome = null,}) {
  return _then(_DeviceWelcomeDto(
deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,welcome: null == welcome ? _self.welcome : welcome // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PendingWelcomeDto {

 String get id; String get contextId; String? get conversationId; String? get channelId; String get userId; String get deviceId; String get welcome;/// Which encryption era of the context this Welcome admits us to.
 int get generation;/// Epoch the joining device lands on - where its commit catch-up starts.
 int get epoch; DateTime? get consumedAt; DateTime? get createdAt;
/// Create a copy of PendingWelcomeDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingWelcomeDtoCopyWith<PendingWelcomeDto> get copyWith => _$PendingWelcomeDtoCopyWithImpl<PendingWelcomeDto>(this as PendingWelcomeDto, _$identity);

  /// Serializes this PendingWelcomeDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingWelcomeDto&&(identical(other.id, id) || other.id == id)&&(identical(other.contextId, contextId) || other.contextId == contextId)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.welcome, welcome) || other.welcome == welcome)&&(identical(other.generation, generation) || other.generation == generation)&&(identical(other.epoch, epoch) || other.epoch == epoch)&&(identical(other.consumedAt, consumedAt) || other.consumedAt == consumedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,contextId,conversationId,channelId,userId,deviceId,welcome,generation,epoch,consumedAt,createdAt);

@override
String toString() {
  return 'PendingWelcomeDto(id: $id, contextId: $contextId, conversationId: $conversationId, channelId: $channelId, userId: $userId, deviceId: $deviceId, welcome: $welcome, generation: $generation, epoch: $epoch, consumedAt: $consumedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PendingWelcomeDtoCopyWith<$Res>  {
  factory $PendingWelcomeDtoCopyWith(PendingWelcomeDto value, $Res Function(PendingWelcomeDto) _then) = _$PendingWelcomeDtoCopyWithImpl;
@useResult
$Res call({
 String id, String contextId, String? conversationId, String? channelId, String userId, String deviceId, String welcome, int generation, int epoch, DateTime? consumedAt, DateTime? createdAt
});




}
/// @nodoc
class _$PendingWelcomeDtoCopyWithImpl<$Res>
    implements $PendingWelcomeDtoCopyWith<$Res> {
  _$PendingWelcomeDtoCopyWithImpl(this._self, this._then);

  final PendingWelcomeDto _self;
  final $Res Function(PendingWelcomeDto) _then;

/// Create a copy of PendingWelcomeDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? contextId = null,Object? conversationId = freezed,Object? channelId = freezed,Object? userId = null,Object? deviceId = null,Object? welcome = null,Object? generation = null,Object? epoch = null,Object? consumedAt = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,contextId: null == contextId ? _self.contextId : contextId // ignore: cast_nullable_to_non_nullable
as String,conversationId: freezed == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String?,channelId: freezed == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,welcome: null == welcome ? _self.welcome : welcome // ignore: cast_nullable_to_non_nullable
as String,generation: null == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int,epoch: null == epoch ? _self.epoch : epoch // ignore: cast_nullable_to_non_nullable
as int,consumedAt: freezed == consumedAt ? _self.consumedAt : consumedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PendingWelcomeDto].
extension PendingWelcomeDtoPatterns on PendingWelcomeDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PendingWelcomeDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PendingWelcomeDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PendingWelcomeDto value)  $default,){
final _that = this;
switch (_that) {
case _PendingWelcomeDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PendingWelcomeDto value)?  $default,){
final _that = this;
switch (_that) {
case _PendingWelcomeDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String contextId,  String? conversationId,  String? channelId,  String userId,  String deviceId,  String welcome,  int generation,  int epoch,  DateTime? consumedAt,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PendingWelcomeDto() when $default != null:
return $default(_that.id,_that.contextId,_that.conversationId,_that.channelId,_that.userId,_that.deviceId,_that.welcome,_that.generation,_that.epoch,_that.consumedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String contextId,  String? conversationId,  String? channelId,  String userId,  String deviceId,  String welcome,  int generation,  int epoch,  DateTime? consumedAt,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _PendingWelcomeDto():
return $default(_that.id,_that.contextId,_that.conversationId,_that.channelId,_that.userId,_that.deviceId,_that.welcome,_that.generation,_that.epoch,_that.consumedAt,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String contextId,  String? conversationId,  String? channelId,  String userId,  String deviceId,  String welcome,  int generation,  int epoch,  DateTime? consumedAt,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PendingWelcomeDto() when $default != null:
return $default(_that.id,_that.contextId,_that.conversationId,_that.channelId,_that.userId,_that.deviceId,_that.welcome,_that.generation,_that.epoch,_that.consumedAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _PendingWelcomeDto extends PendingWelcomeDto {
  const _PendingWelcomeDto({required this.id, required this.contextId, this.conversationId, this.channelId, required this.userId, required this.deviceId, required this.welcome, required this.generation, required this.epoch, this.consumedAt, this.createdAt}): super._();
  factory _PendingWelcomeDto.fromJson(Map<String, dynamic> json) => _$PendingWelcomeDtoFromJson(json);

@override final  String id;
@override final  String contextId;
@override final  String? conversationId;
@override final  String? channelId;
@override final  String userId;
@override final  String deviceId;
@override final  String welcome;
/// Which encryption era of the context this Welcome admits us to.
@override final  int generation;
/// Epoch the joining device lands on - where its commit catch-up starts.
@override final  int epoch;
@override final  DateTime? consumedAt;
@override final  DateTime? createdAt;

/// Create a copy of PendingWelcomeDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PendingWelcomeDtoCopyWith<_PendingWelcomeDto> get copyWith => __$PendingWelcomeDtoCopyWithImpl<_PendingWelcomeDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PendingWelcomeDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PendingWelcomeDto&&(identical(other.id, id) || other.id == id)&&(identical(other.contextId, contextId) || other.contextId == contextId)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.welcome, welcome) || other.welcome == welcome)&&(identical(other.generation, generation) || other.generation == generation)&&(identical(other.epoch, epoch) || other.epoch == epoch)&&(identical(other.consumedAt, consumedAt) || other.consumedAt == consumedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,contextId,conversationId,channelId,userId,deviceId,welcome,generation,epoch,consumedAt,createdAt);

@override
String toString() {
  return 'PendingWelcomeDto(id: $id, contextId: $contextId, conversationId: $conversationId, channelId: $channelId, userId: $userId, deviceId: $deviceId, welcome: $welcome, generation: $generation, epoch: $epoch, consumedAt: $consumedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PendingWelcomeDtoCopyWith<$Res> implements $PendingWelcomeDtoCopyWith<$Res> {
  factory _$PendingWelcomeDtoCopyWith(_PendingWelcomeDto value, $Res Function(_PendingWelcomeDto) _then) = __$PendingWelcomeDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String contextId, String? conversationId, String? channelId, String userId, String deviceId, String welcome, int generation, int epoch, DateTime? consumedAt, DateTime? createdAt
});




}
/// @nodoc
class __$PendingWelcomeDtoCopyWithImpl<$Res>
    implements _$PendingWelcomeDtoCopyWith<$Res> {
  __$PendingWelcomeDtoCopyWithImpl(this._self, this._then);

  final _PendingWelcomeDto _self;
  final $Res Function(_PendingWelcomeDto) _then;

/// Create a copy of PendingWelcomeDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? contextId = null,Object? conversationId = freezed,Object? channelId = freezed,Object? userId = null,Object? deviceId = null,Object? welcome = null,Object? generation = null,Object? epoch = null,Object? consumedAt = freezed,Object? createdAt = freezed,}) {
  return _then(_PendingWelcomeDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,contextId: null == contextId ? _self.contextId : contextId // ignore: cast_nullable_to_non_nullable
as String,conversationId: freezed == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String?,channelId: freezed == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,welcome: null == welcome ? _self.welcome : welcome // ignore: cast_nullable_to_non_nullable
as String,generation: null == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int,epoch: null == epoch ? _self.epoch : epoch // ignore: cast_nullable_to_non_nullable
as int,consumedAt: freezed == consumedAt ? _self.consumedAt : consumedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$MlsCommitDto {

 String get id; String get contextId; String? get conversationId; String? get channelId; int get generation;/// Group epoch *after* this commit is applied.
 int get epoch; String get commit; String get senderUserId; String get senderDeviceId;/// Set by the server. Read rather than inferred: a proposal must not count
/// toward the "did this page make progress" decision, and guessing from the
/// payload means parsing MLS bytes the transport layer has no business
/// parsing.
 bool get isProposal; DateTime? get createdAt;
/// Create a copy of MlsCommitDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MlsCommitDtoCopyWith<MlsCommitDto> get copyWith => _$MlsCommitDtoCopyWithImpl<MlsCommitDto>(this as MlsCommitDto, _$identity);

  /// Serializes this MlsCommitDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MlsCommitDto&&(identical(other.id, id) || other.id == id)&&(identical(other.contextId, contextId) || other.contextId == contextId)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.generation, generation) || other.generation == generation)&&(identical(other.epoch, epoch) || other.epoch == epoch)&&(identical(other.commit, commit) || other.commit == commit)&&(identical(other.senderUserId, senderUserId) || other.senderUserId == senderUserId)&&(identical(other.senderDeviceId, senderDeviceId) || other.senderDeviceId == senderDeviceId)&&(identical(other.isProposal, isProposal) || other.isProposal == isProposal)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,contextId,conversationId,channelId,generation,epoch,commit,senderUserId,senderDeviceId,isProposal,createdAt);

@override
String toString() {
  return 'MlsCommitDto(id: $id, contextId: $contextId, conversationId: $conversationId, channelId: $channelId, generation: $generation, epoch: $epoch, commit: $commit, senderUserId: $senderUserId, senderDeviceId: $senderDeviceId, isProposal: $isProposal, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $MlsCommitDtoCopyWith<$Res>  {
  factory $MlsCommitDtoCopyWith(MlsCommitDto value, $Res Function(MlsCommitDto) _then) = _$MlsCommitDtoCopyWithImpl;
@useResult
$Res call({
 String id, String contextId, String? conversationId, String? channelId, int generation, int epoch, String commit, String senderUserId, String senderDeviceId, bool isProposal, DateTime? createdAt
});




}
/// @nodoc
class _$MlsCommitDtoCopyWithImpl<$Res>
    implements $MlsCommitDtoCopyWith<$Res> {
  _$MlsCommitDtoCopyWithImpl(this._self, this._then);

  final MlsCommitDto _self;
  final $Res Function(MlsCommitDto) _then;

/// Create a copy of MlsCommitDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? contextId = null,Object? conversationId = freezed,Object? channelId = freezed,Object? generation = null,Object? epoch = null,Object? commit = null,Object? senderUserId = null,Object? senderDeviceId = null,Object? isProposal = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,contextId: null == contextId ? _self.contextId : contextId // ignore: cast_nullable_to_non_nullable
as String,conversationId: freezed == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String?,channelId: freezed == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String?,generation: null == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int,epoch: null == epoch ? _self.epoch : epoch // ignore: cast_nullable_to_non_nullable
as int,commit: null == commit ? _self.commit : commit // ignore: cast_nullable_to_non_nullable
as String,senderUserId: null == senderUserId ? _self.senderUserId : senderUserId // ignore: cast_nullable_to_non_nullable
as String,senderDeviceId: null == senderDeviceId ? _self.senderDeviceId : senderDeviceId // ignore: cast_nullable_to_non_nullable
as String,isProposal: null == isProposal ? _self.isProposal : isProposal // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MlsCommitDto].
extension MlsCommitDtoPatterns on MlsCommitDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MlsCommitDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MlsCommitDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MlsCommitDto value)  $default,){
final _that = this;
switch (_that) {
case _MlsCommitDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MlsCommitDto value)?  $default,){
final _that = this;
switch (_that) {
case _MlsCommitDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String contextId,  String? conversationId,  String? channelId,  int generation,  int epoch,  String commit,  String senderUserId,  String senderDeviceId,  bool isProposal,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MlsCommitDto() when $default != null:
return $default(_that.id,_that.contextId,_that.conversationId,_that.channelId,_that.generation,_that.epoch,_that.commit,_that.senderUserId,_that.senderDeviceId,_that.isProposal,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String contextId,  String? conversationId,  String? channelId,  int generation,  int epoch,  String commit,  String senderUserId,  String senderDeviceId,  bool isProposal,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _MlsCommitDto():
return $default(_that.id,_that.contextId,_that.conversationId,_that.channelId,_that.generation,_that.epoch,_that.commit,_that.senderUserId,_that.senderDeviceId,_that.isProposal,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String contextId,  String? conversationId,  String? channelId,  int generation,  int epoch,  String commit,  String senderUserId,  String senderDeviceId,  bool isProposal,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _MlsCommitDto() when $default != null:
return $default(_that.id,_that.contextId,_that.conversationId,_that.channelId,_that.generation,_that.epoch,_that.commit,_that.senderUserId,_that.senderDeviceId,_that.isProposal,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _MlsCommitDto implements MlsCommitDto {
  const _MlsCommitDto({required this.id, required this.contextId, this.conversationId, this.channelId, required this.generation, required this.epoch, required this.commit, required this.senderUserId, required this.senderDeviceId, this.isProposal = false, this.createdAt});
  factory _MlsCommitDto.fromJson(Map<String, dynamic> json) => _$MlsCommitDtoFromJson(json);

@override final  String id;
@override final  String contextId;
@override final  String? conversationId;
@override final  String? channelId;
@override final  int generation;
/// Group epoch *after* this commit is applied.
@override final  int epoch;
@override final  String commit;
@override final  String senderUserId;
@override final  String senderDeviceId;
/// Set by the server. Read rather than inferred: a proposal must not count
/// toward the "did this page make progress" decision, and guessing from the
/// payload means parsing MLS bytes the transport layer has no business
/// parsing.
@override@JsonKey() final  bool isProposal;
@override final  DateTime? createdAt;

/// Create a copy of MlsCommitDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MlsCommitDtoCopyWith<_MlsCommitDto> get copyWith => __$MlsCommitDtoCopyWithImpl<_MlsCommitDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MlsCommitDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MlsCommitDto&&(identical(other.id, id) || other.id == id)&&(identical(other.contextId, contextId) || other.contextId == contextId)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.generation, generation) || other.generation == generation)&&(identical(other.epoch, epoch) || other.epoch == epoch)&&(identical(other.commit, commit) || other.commit == commit)&&(identical(other.senderUserId, senderUserId) || other.senderUserId == senderUserId)&&(identical(other.senderDeviceId, senderDeviceId) || other.senderDeviceId == senderDeviceId)&&(identical(other.isProposal, isProposal) || other.isProposal == isProposal)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,contextId,conversationId,channelId,generation,epoch,commit,senderUserId,senderDeviceId,isProposal,createdAt);

@override
String toString() {
  return 'MlsCommitDto(id: $id, contextId: $contextId, conversationId: $conversationId, channelId: $channelId, generation: $generation, epoch: $epoch, commit: $commit, senderUserId: $senderUserId, senderDeviceId: $senderDeviceId, isProposal: $isProposal, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MlsCommitDtoCopyWith<$Res> implements $MlsCommitDtoCopyWith<$Res> {
  factory _$MlsCommitDtoCopyWith(_MlsCommitDto value, $Res Function(_MlsCommitDto) _then) = __$MlsCommitDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String contextId, String? conversationId, String? channelId, int generation, int epoch, String commit, String senderUserId, String senderDeviceId, bool isProposal, DateTime? createdAt
});




}
/// @nodoc
class __$MlsCommitDtoCopyWithImpl<$Res>
    implements _$MlsCommitDtoCopyWith<$Res> {
  __$MlsCommitDtoCopyWithImpl(this._self, this._then);

  final _MlsCommitDto _self;
  final $Res Function(_MlsCommitDto) _then;

/// Create a copy of MlsCommitDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? contextId = null,Object? conversationId = freezed,Object? channelId = freezed,Object? generation = null,Object? epoch = null,Object? commit = null,Object? senderUserId = null,Object? senderDeviceId = null,Object? isProposal = null,Object? createdAt = freezed,}) {
  return _then(_MlsCommitDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,contextId: null == contextId ? _self.contextId : contextId // ignore: cast_nullable_to_non_nullable
as String,conversationId: freezed == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String?,channelId: freezed == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String?,generation: null == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int,epoch: null == epoch ? _self.epoch : epoch // ignore: cast_nullable_to_non_nullable
as int,commit: null == commit ? _self.commit : commit // ignore: cast_nullable_to_non_nullable
as String,senderUserId: null == senderUserId ? _self.senderUserId : senderUserId // ignore: cast_nullable_to_non_nullable
as String,senderDeviceId: null == senderDeviceId ? _self.senderDeviceId : senderDeviceId // ignore: cast_nullable_to_non_nullable
as String,isProposal: null == isProposal ? _self.isProposal : isProposal // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$PublishMlsCommitDto {

 int get epoch; String get commit; String get senderDeviceId;/// True for a Remove **proposal** riding the commit channel.
///
/// A wire flag rather than something the server infers: it has to be told,
/// or it advances the group epoch for a payload that advances nobody's MLS
/// epoch - which is what made catch-up return the same row forever. The
/// unique index on (generation, epoch) is filtered on this, so a proposal no
/// longer occupies the slot the real commit needs.
 bool get isProposal;/// Always sent. Omitting it makes the server assume the live generation,
/// which is exactly wrong if encryption was toggled while we were building.
 int? get generation;/// Refreshed GroupInfo so a device that falls too far behind can rejoin by
/// external commit.
 String? get groupInfo; List<DeviceWelcomeDto> get welcomes;/// Join requests this commit admits. The server closes them only once the
/// commit lands, never on approval - an approval that never produced a
/// commit must leave the request open for someone else to act on.
 List<String> get fulfilledJoinRequestIds;
/// Create a copy of PublishMlsCommitDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublishMlsCommitDtoCopyWith<PublishMlsCommitDto> get copyWith => _$PublishMlsCommitDtoCopyWithImpl<PublishMlsCommitDto>(this as PublishMlsCommitDto, _$identity);

  /// Serializes this PublishMlsCommitDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublishMlsCommitDto&&(identical(other.epoch, epoch) || other.epoch == epoch)&&(identical(other.commit, commit) || other.commit == commit)&&(identical(other.senderDeviceId, senderDeviceId) || other.senderDeviceId == senderDeviceId)&&(identical(other.isProposal, isProposal) || other.isProposal == isProposal)&&(identical(other.generation, generation) || other.generation == generation)&&(identical(other.groupInfo, groupInfo) || other.groupInfo == groupInfo)&&const DeepCollectionEquality().equals(other.welcomes, welcomes)&&const DeepCollectionEquality().equals(other.fulfilledJoinRequestIds, fulfilledJoinRequestIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,epoch,commit,senderDeviceId,isProposal,generation,groupInfo,const DeepCollectionEquality().hash(welcomes),const DeepCollectionEquality().hash(fulfilledJoinRequestIds));

@override
String toString() {
  return 'PublishMlsCommitDto(epoch: $epoch, commit: $commit, senderDeviceId: $senderDeviceId, isProposal: $isProposal, generation: $generation, groupInfo: $groupInfo, welcomes: $welcomes, fulfilledJoinRequestIds: $fulfilledJoinRequestIds)';
}


}

/// @nodoc
abstract mixin class $PublishMlsCommitDtoCopyWith<$Res>  {
  factory $PublishMlsCommitDtoCopyWith(PublishMlsCommitDto value, $Res Function(PublishMlsCommitDto) _then) = _$PublishMlsCommitDtoCopyWithImpl;
@useResult
$Res call({
 int epoch, String commit, String senderDeviceId, bool isProposal, int? generation, String? groupInfo, List<DeviceWelcomeDto> welcomes, List<String> fulfilledJoinRequestIds
});




}
/// @nodoc
class _$PublishMlsCommitDtoCopyWithImpl<$Res>
    implements $PublishMlsCommitDtoCopyWith<$Res> {
  _$PublishMlsCommitDtoCopyWithImpl(this._self, this._then);

  final PublishMlsCommitDto _self;
  final $Res Function(PublishMlsCommitDto) _then;

/// Create a copy of PublishMlsCommitDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? epoch = null,Object? commit = null,Object? senderDeviceId = null,Object? isProposal = null,Object? generation = freezed,Object? groupInfo = freezed,Object? welcomes = null,Object? fulfilledJoinRequestIds = null,}) {
  return _then(_self.copyWith(
epoch: null == epoch ? _self.epoch : epoch // ignore: cast_nullable_to_non_nullable
as int,commit: null == commit ? _self.commit : commit // ignore: cast_nullable_to_non_nullable
as String,senderDeviceId: null == senderDeviceId ? _self.senderDeviceId : senderDeviceId // ignore: cast_nullable_to_non_nullable
as String,isProposal: null == isProposal ? _self.isProposal : isProposal // ignore: cast_nullable_to_non_nullable
as bool,generation: freezed == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int?,groupInfo: freezed == groupInfo ? _self.groupInfo : groupInfo // ignore: cast_nullable_to_non_nullable
as String?,welcomes: null == welcomes ? _self.welcomes : welcomes // ignore: cast_nullable_to_non_nullable
as List<DeviceWelcomeDto>,fulfilledJoinRequestIds: null == fulfilledJoinRequestIds ? _self.fulfilledJoinRequestIds : fulfilledJoinRequestIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [PublishMlsCommitDto].
extension PublishMlsCommitDtoPatterns on PublishMlsCommitDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublishMlsCommitDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublishMlsCommitDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublishMlsCommitDto value)  $default,){
final _that = this;
switch (_that) {
case _PublishMlsCommitDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublishMlsCommitDto value)?  $default,){
final _that = this;
switch (_that) {
case _PublishMlsCommitDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int epoch,  String commit,  String senderDeviceId,  bool isProposal,  int? generation,  String? groupInfo,  List<DeviceWelcomeDto> welcomes,  List<String> fulfilledJoinRequestIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublishMlsCommitDto() when $default != null:
return $default(_that.epoch,_that.commit,_that.senderDeviceId,_that.isProposal,_that.generation,_that.groupInfo,_that.welcomes,_that.fulfilledJoinRequestIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int epoch,  String commit,  String senderDeviceId,  bool isProposal,  int? generation,  String? groupInfo,  List<DeviceWelcomeDto> welcomes,  List<String> fulfilledJoinRequestIds)  $default,) {final _that = this;
switch (_that) {
case _PublishMlsCommitDto():
return $default(_that.epoch,_that.commit,_that.senderDeviceId,_that.isProposal,_that.generation,_that.groupInfo,_that.welcomes,_that.fulfilledJoinRequestIds);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int epoch,  String commit,  String senderDeviceId,  bool isProposal,  int? generation,  String? groupInfo,  List<DeviceWelcomeDto> welcomes,  List<String> fulfilledJoinRequestIds)?  $default,) {final _that = this;
switch (_that) {
case _PublishMlsCommitDto() when $default != null:
return $default(_that.epoch,_that.commit,_that.senderDeviceId,_that.isProposal,_that.generation,_that.groupInfo,_that.welcomes,_that.fulfilledJoinRequestIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PublishMlsCommitDto implements PublishMlsCommitDto {
  const _PublishMlsCommitDto({required this.epoch, required this.commit, required this.senderDeviceId, this.isProposal = false, this.generation, this.groupInfo, final  List<DeviceWelcomeDto> welcomes = const <DeviceWelcomeDto>[], final  List<String> fulfilledJoinRequestIds = const <String>[]}): _welcomes = welcomes,_fulfilledJoinRequestIds = fulfilledJoinRequestIds;
  factory _PublishMlsCommitDto.fromJson(Map<String, dynamic> json) => _$PublishMlsCommitDtoFromJson(json);

@override final  int epoch;
@override final  String commit;
@override final  String senderDeviceId;
/// True for a Remove **proposal** riding the commit channel.
///
/// A wire flag rather than something the server infers: it has to be told,
/// or it advances the group epoch for a payload that advances nobody's MLS
/// epoch - which is what made catch-up return the same row forever. The
/// unique index on (generation, epoch) is filtered on this, so a proposal no
/// longer occupies the slot the real commit needs.
@override@JsonKey() final  bool isProposal;
/// Always sent. Omitting it makes the server assume the live generation,
/// which is exactly wrong if encryption was toggled while we were building.
@override final  int? generation;
/// Refreshed GroupInfo so a device that falls too far behind can rejoin by
/// external commit.
@override final  String? groupInfo;
 final  List<DeviceWelcomeDto> _welcomes;
@override@JsonKey() List<DeviceWelcomeDto> get welcomes {
  if (_welcomes is EqualUnmodifiableListView) return _welcomes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_welcomes);
}

/// Join requests this commit admits. The server closes them only once the
/// commit lands, never on approval - an approval that never produced a
/// commit must leave the request open for someone else to act on.
 final  List<String> _fulfilledJoinRequestIds;
/// Join requests this commit admits. The server closes them only once the
/// commit lands, never on approval - an approval that never produced a
/// commit must leave the request open for someone else to act on.
@override@JsonKey() List<String> get fulfilledJoinRequestIds {
  if (_fulfilledJoinRequestIds is EqualUnmodifiableListView) return _fulfilledJoinRequestIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fulfilledJoinRequestIds);
}


/// Create a copy of PublishMlsCommitDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublishMlsCommitDtoCopyWith<_PublishMlsCommitDto> get copyWith => __$PublishMlsCommitDtoCopyWithImpl<_PublishMlsCommitDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PublishMlsCommitDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublishMlsCommitDto&&(identical(other.epoch, epoch) || other.epoch == epoch)&&(identical(other.commit, commit) || other.commit == commit)&&(identical(other.senderDeviceId, senderDeviceId) || other.senderDeviceId == senderDeviceId)&&(identical(other.isProposal, isProposal) || other.isProposal == isProposal)&&(identical(other.generation, generation) || other.generation == generation)&&(identical(other.groupInfo, groupInfo) || other.groupInfo == groupInfo)&&const DeepCollectionEquality().equals(other._welcomes, _welcomes)&&const DeepCollectionEquality().equals(other._fulfilledJoinRequestIds, _fulfilledJoinRequestIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,epoch,commit,senderDeviceId,isProposal,generation,groupInfo,const DeepCollectionEquality().hash(_welcomes),const DeepCollectionEquality().hash(_fulfilledJoinRequestIds));

@override
String toString() {
  return 'PublishMlsCommitDto(epoch: $epoch, commit: $commit, senderDeviceId: $senderDeviceId, isProposal: $isProposal, generation: $generation, groupInfo: $groupInfo, welcomes: $welcomes, fulfilledJoinRequestIds: $fulfilledJoinRequestIds)';
}


}

/// @nodoc
abstract mixin class _$PublishMlsCommitDtoCopyWith<$Res> implements $PublishMlsCommitDtoCopyWith<$Res> {
  factory _$PublishMlsCommitDtoCopyWith(_PublishMlsCommitDto value, $Res Function(_PublishMlsCommitDto) _then) = __$PublishMlsCommitDtoCopyWithImpl;
@override @useResult
$Res call({
 int epoch, String commit, String senderDeviceId, bool isProposal, int? generation, String? groupInfo, List<DeviceWelcomeDto> welcomes, List<String> fulfilledJoinRequestIds
});




}
/// @nodoc
class __$PublishMlsCommitDtoCopyWithImpl<$Res>
    implements _$PublishMlsCommitDtoCopyWith<$Res> {
  __$PublishMlsCommitDtoCopyWithImpl(this._self, this._then);

  final _PublishMlsCommitDto _self;
  final $Res Function(_PublishMlsCommitDto) _then;

/// Create a copy of PublishMlsCommitDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? epoch = null,Object? commit = null,Object? senderDeviceId = null,Object? isProposal = null,Object? generation = freezed,Object? groupInfo = freezed,Object? welcomes = null,Object? fulfilledJoinRequestIds = null,}) {
  return _then(_PublishMlsCommitDto(
epoch: null == epoch ? _self.epoch : epoch // ignore: cast_nullable_to_non_nullable
as int,commit: null == commit ? _self.commit : commit // ignore: cast_nullable_to_non_nullable
as String,senderDeviceId: null == senderDeviceId ? _self.senderDeviceId : senderDeviceId // ignore: cast_nullable_to_non_nullable
as String,isProposal: null == isProposal ? _self.isProposal : isProposal // ignore: cast_nullable_to_non_nullable
as bool,generation: freezed == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int?,groupInfo: freezed == groupInfo ? _self.groupInfo : groupInfo // ignore: cast_nullable_to_non_nullable
as String?,welcomes: null == welcomes ? _self._welcomes : welcomes // ignore: cast_nullable_to_non_nullable
as List<DeviceWelcomeDto>,fulfilledJoinRequestIds: null == fulfilledJoinRequestIds ? _self._fulfilledJoinRequestIds : fulfilledJoinRequestIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$MlsCommitPublishedDto {

 String get contextId; String? get conversationId; int get generation; int get epoch; bool get isProposal;/// The §E4 idempotent replay: this exact commit was already stored, matched
/// on (senderDeviceId, generation, epoch, payload hash).
///
/// **The publish succeeded.** It is not a lost race, so the staged commit
/// must be merged and kept - discarding it here is precisely the bug that
/// stranded a device whose first response went missing.
 bool get duplicate;
/// Create a copy of MlsCommitPublishedDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MlsCommitPublishedDtoCopyWith<MlsCommitPublishedDto> get copyWith => _$MlsCommitPublishedDtoCopyWithImpl<MlsCommitPublishedDto>(this as MlsCommitPublishedDto, _$identity);

  /// Serializes this MlsCommitPublishedDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MlsCommitPublishedDto&&(identical(other.contextId, contextId) || other.contextId == contextId)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.generation, generation) || other.generation == generation)&&(identical(other.epoch, epoch) || other.epoch == epoch)&&(identical(other.isProposal, isProposal) || other.isProposal == isProposal)&&(identical(other.duplicate, duplicate) || other.duplicate == duplicate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contextId,conversationId,generation,epoch,isProposal,duplicate);

@override
String toString() {
  return 'MlsCommitPublishedDto(contextId: $contextId, conversationId: $conversationId, generation: $generation, epoch: $epoch, isProposal: $isProposal, duplicate: $duplicate)';
}


}

/// @nodoc
abstract mixin class $MlsCommitPublishedDtoCopyWith<$Res>  {
  factory $MlsCommitPublishedDtoCopyWith(MlsCommitPublishedDto value, $Res Function(MlsCommitPublishedDto) _then) = _$MlsCommitPublishedDtoCopyWithImpl;
@useResult
$Res call({
 String contextId, String? conversationId, int generation, int epoch, bool isProposal, bool duplicate
});




}
/// @nodoc
class _$MlsCommitPublishedDtoCopyWithImpl<$Res>
    implements $MlsCommitPublishedDtoCopyWith<$Res> {
  _$MlsCommitPublishedDtoCopyWithImpl(this._self, this._then);

  final MlsCommitPublishedDto _self;
  final $Res Function(MlsCommitPublishedDto) _then;

/// Create a copy of MlsCommitPublishedDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contextId = null,Object? conversationId = freezed,Object? generation = null,Object? epoch = null,Object? isProposal = null,Object? duplicate = null,}) {
  return _then(_self.copyWith(
contextId: null == contextId ? _self.contextId : contextId // ignore: cast_nullable_to_non_nullable
as String,conversationId: freezed == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String?,generation: null == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int,epoch: null == epoch ? _self.epoch : epoch // ignore: cast_nullable_to_non_nullable
as int,isProposal: null == isProposal ? _self.isProposal : isProposal // ignore: cast_nullable_to_non_nullable
as bool,duplicate: null == duplicate ? _self.duplicate : duplicate // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MlsCommitPublishedDto].
extension MlsCommitPublishedDtoPatterns on MlsCommitPublishedDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MlsCommitPublishedDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MlsCommitPublishedDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MlsCommitPublishedDto value)  $default,){
final _that = this;
switch (_that) {
case _MlsCommitPublishedDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MlsCommitPublishedDto value)?  $default,){
final _that = this;
switch (_that) {
case _MlsCommitPublishedDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String contextId,  String? conversationId,  int generation,  int epoch,  bool isProposal,  bool duplicate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MlsCommitPublishedDto() when $default != null:
return $default(_that.contextId,_that.conversationId,_that.generation,_that.epoch,_that.isProposal,_that.duplicate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String contextId,  String? conversationId,  int generation,  int epoch,  bool isProposal,  bool duplicate)  $default,) {final _that = this;
switch (_that) {
case _MlsCommitPublishedDto():
return $default(_that.contextId,_that.conversationId,_that.generation,_that.epoch,_that.isProposal,_that.duplicate);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String contextId,  String? conversationId,  int generation,  int epoch,  bool isProposal,  bool duplicate)?  $default,) {final _that = this;
switch (_that) {
case _MlsCommitPublishedDto() when $default != null:
return $default(_that.contextId,_that.conversationId,_that.generation,_that.epoch,_that.isProposal,_that.duplicate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MlsCommitPublishedDto implements MlsCommitPublishedDto {
  const _MlsCommitPublishedDto({required this.contextId, this.conversationId, required this.generation, required this.epoch, this.isProposal = false, this.duplicate = false});
  factory _MlsCommitPublishedDto.fromJson(Map<String, dynamic> json) => _$MlsCommitPublishedDtoFromJson(json);

@override final  String contextId;
@override final  String? conversationId;
@override final  int generation;
@override final  int epoch;
@override@JsonKey() final  bool isProposal;
/// The §E4 idempotent replay: this exact commit was already stored, matched
/// on (senderDeviceId, generation, epoch, payload hash).
///
/// **The publish succeeded.** It is not a lost race, so the staged commit
/// must be merged and kept - discarding it here is precisely the bug that
/// stranded a device whose first response went missing.
@override@JsonKey() final  bool duplicate;

/// Create a copy of MlsCommitPublishedDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MlsCommitPublishedDtoCopyWith<_MlsCommitPublishedDto> get copyWith => __$MlsCommitPublishedDtoCopyWithImpl<_MlsCommitPublishedDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MlsCommitPublishedDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MlsCommitPublishedDto&&(identical(other.contextId, contextId) || other.contextId == contextId)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.generation, generation) || other.generation == generation)&&(identical(other.epoch, epoch) || other.epoch == epoch)&&(identical(other.isProposal, isProposal) || other.isProposal == isProposal)&&(identical(other.duplicate, duplicate) || other.duplicate == duplicate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contextId,conversationId,generation,epoch,isProposal,duplicate);

@override
String toString() {
  return 'MlsCommitPublishedDto(contextId: $contextId, conversationId: $conversationId, generation: $generation, epoch: $epoch, isProposal: $isProposal, duplicate: $duplicate)';
}


}

/// @nodoc
abstract mixin class _$MlsCommitPublishedDtoCopyWith<$Res> implements $MlsCommitPublishedDtoCopyWith<$Res> {
  factory _$MlsCommitPublishedDtoCopyWith(_MlsCommitPublishedDto value, $Res Function(_MlsCommitPublishedDto) _then) = __$MlsCommitPublishedDtoCopyWithImpl;
@override @useResult
$Res call({
 String contextId, String? conversationId, int generation, int epoch, bool isProposal, bool duplicate
});




}
/// @nodoc
class __$MlsCommitPublishedDtoCopyWithImpl<$Res>
    implements _$MlsCommitPublishedDtoCopyWith<$Res> {
  __$MlsCommitPublishedDtoCopyWithImpl(this._self, this._then);

  final _MlsCommitPublishedDto _self;
  final $Res Function(_MlsCommitPublishedDto) _then;

/// Create a copy of MlsCommitPublishedDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contextId = null,Object? conversationId = freezed,Object? generation = null,Object? epoch = null,Object? isProposal = null,Object? duplicate = null,}) {
  return _then(_MlsCommitPublishedDto(
contextId: null == contextId ? _self.contextId : contextId // ignore: cast_nullable_to_non_nullable
as String,conversationId: freezed == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String?,generation: null == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int,epoch: null == epoch ? _self.epoch : epoch // ignore: cast_nullable_to_non_nullable
as int,isProposal: null == isProposal ? _self.isProposal : isProposal // ignore: cast_nullable_to_non_nullable
as bool,duplicate: null == duplicate ? _self.duplicate : duplicate // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$MlsGenerationDto {

 String get id; String get contextId; int get generation; String? get mlsGroupId; String? get mlsGroupInfo; int get epoch;@JsonKey(unknownEnumValue: MlsGenerationState.active) MlsGenerationState get state; DateTime? get activatedAt; String? get activatedByUserId; DateTime? get terminatedAt; String? get terminatedByUserId;
/// Create a copy of MlsGenerationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MlsGenerationDtoCopyWith<MlsGenerationDto> get copyWith => _$MlsGenerationDtoCopyWithImpl<MlsGenerationDto>(this as MlsGenerationDto, _$identity);

  /// Serializes this MlsGenerationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MlsGenerationDto&&(identical(other.id, id) || other.id == id)&&(identical(other.contextId, contextId) || other.contextId == contextId)&&(identical(other.generation, generation) || other.generation == generation)&&(identical(other.mlsGroupId, mlsGroupId) || other.mlsGroupId == mlsGroupId)&&(identical(other.mlsGroupInfo, mlsGroupInfo) || other.mlsGroupInfo == mlsGroupInfo)&&(identical(other.epoch, epoch) || other.epoch == epoch)&&(identical(other.state, state) || other.state == state)&&(identical(other.activatedAt, activatedAt) || other.activatedAt == activatedAt)&&(identical(other.activatedByUserId, activatedByUserId) || other.activatedByUserId == activatedByUserId)&&(identical(other.terminatedAt, terminatedAt) || other.terminatedAt == terminatedAt)&&(identical(other.terminatedByUserId, terminatedByUserId) || other.terminatedByUserId == terminatedByUserId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,contextId,generation,mlsGroupId,mlsGroupInfo,epoch,state,activatedAt,activatedByUserId,terminatedAt,terminatedByUserId);

@override
String toString() {
  return 'MlsGenerationDto(id: $id, contextId: $contextId, generation: $generation, mlsGroupId: $mlsGroupId, mlsGroupInfo: $mlsGroupInfo, epoch: $epoch, state: $state, activatedAt: $activatedAt, activatedByUserId: $activatedByUserId, terminatedAt: $terminatedAt, terminatedByUserId: $terminatedByUserId)';
}


}

/// @nodoc
abstract mixin class $MlsGenerationDtoCopyWith<$Res>  {
  factory $MlsGenerationDtoCopyWith(MlsGenerationDto value, $Res Function(MlsGenerationDto) _then) = _$MlsGenerationDtoCopyWithImpl;
@useResult
$Res call({
 String id, String contextId, int generation, String? mlsGroupId, String? mlsGroupInfo, int epoch,@JsonKey(unknownEnumValue: MlsGenerationState.active) MlsGenerationState state, DateTime? activatedAt, String? activatedByUserId, DateTime? terminatedAt, String? terminatedByUserId
});




}
/// @nodoc
class _$MlsGenerationDtoCopyWithImpl<$Res>
    implements $MlsGenerationDtoCopyWith<$Res> {
  _$MlsGenerationDtoCopyWithImpl(this._self, this._then);

  final MlsGenerationDto _self;
  final $Res Function(MlsGenerationDto) _then;

/// Create a copy of MlsGenerationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? contextId = null,Object? generation = null,Object? mlsGroupId = freezed,Object? mlsGroupInfo = freezed,Object? epoch = null,Object? state = null,Object? activatedAt = freezed,Object? activatedByUserId = freezed,Object? terminatedAt = freezed,Object? terminatedByUserId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,contextId: null == contextId ? _self.contextId : contextId // ignore: cast_nullable_to_non_nullable
as String,generation: null == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int,mlsGroupId: freezed == mlsGroupId ? _self.mlsGroupId : mlsGroupId // ignore: cast_nullable_to_non_nullable
as String?,mlsGroupInfo: freezed == mlsGroupInfo ? _self.mlsGroupInfo : mlsGroupInfo // ignore: cast_nullable_to_non_nullable
as String?,epoch: null == epoch ? _self.epoch : epoch // ignore: cast_nullable_to_non_nullable
as int,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as MlsGenerationState,activatedAt: freezed == activatedAt ? _self.activatedAt : activatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,activatedByUserId: freezed == activatedByUserId ? _self.activatedByUserId : activatedByUserId // ignore: cast_nullable_to_non_nullable
as String?,terminatedAt: freezed == terminatedAt ? _self.terminatedAt : terminatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,terminatedByUserId: freezed == terminatedByUserId ? _self.terminatedByUserId : terminatedByUserId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MlsGenerationDto].
extension MlsGenerationDtoPatterns on MlsGenerationDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MlsGenerationDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MlsGenerationDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MlsGenerationDto value)  $default,){
final _that = this;
switch (_that) {
case _MlsGenerationDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MlsGenerationDto value)?  $default,){
final _that = this;
switch (_that) {
case _MlsGenerationDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String contextId,  int generation,  String? mlsGroupId,  String? mlsGroupInfo,  int epoch, @JsonKey(unknownEnumValue: MlsGenerationState.active)  MlsGenerationState state,  DateTime? activatedAt,  String? activatedByUserId,  DateTime? terminatedAt,  String? terminatedByUserId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MlsGenerationDto() when $default != null:
return $default(_that.id,_that.contextId,_that.generation,_that.mlsGroupId,_that.mlsGroupInfo,_that.epoch,_that.state,_that.activatedAt,_that.activatedByUserId,_that.terminatedAt,_that.terminatedByUserId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String contextId,  int generation,  String? mlsGroupId,  String? mlsGroupInfo,  int epoch, @JsonKey(unknownEnumValue: MlsGenerationState.active)  MlsGenerationState state,  DateTime? activatedAt,  String? activatedByUserId,  DateTime? terminatedAt,  String? terminatedByUserId)  $default,) {final _that = this;
switch (_that) {
case _MlsGenerationDto():
return $default(_that.id,_that.contextId,_that.generation,_that.mlsGroupId,_that.mlsGroupInfo,_that.epoch,_that.state,_that.activatedAt,_that.activatedByUserId,_that.terminatedAt,_that.terminatedByUserId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String contextId,  int generation,  String? mlsGroupId,  String? mlsGroupInfo,  int epoch, @JsonKey(unknownEnumValue: MlsGenerationState.active)  MlsGenerationState state,  DateTime? activatedAt,  String? activatedByUserId,  DateTime? terminatedAt,  String? terminatedByUserId)?  $default,) {final _that = this;
switch (_that) {
case _MlsGenerationDto() when $default != null:
return $default(_that.id,_that.contextId,_that.generation,_that.mlsGroupId,_that.mlsGroupInfo,_that.epoch,_that.state,_that.activatedAt,_that.activatedByUserId,_that.terminatedAt,_that.terminatedByUserId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _MlsGenerationDto implements MlsGenerationDto {
  const _MlsGenerationDto({required this.id, required this.contextId, required this.generation, this.mlsGroupId, this.mlsGroupInfo, required this.epoch, @JsonKey(unknownEnumValue: MlsGenerationState.active) required this.state, this.activatedAt, this.activatedByUserId, this.terminatedAt, this.terminatedByUserId});
  factory _MlsGenerationDto.fromJson(Map<String, dynamic> json) => _$MlsGenerationDtoFromJson(json);

@override final  String id;
@override final  String contextId;
@override final  int generation;
@override final  String? mlsGroupId;
@override final  String? mlsGroupInfo;
@override final  int epoch;
@override@JsonKey(unknownEnumValue: MlsGenerationState.active) final  MlsGenerationState state;
@override final  DateTime? activatedAt;
@override final  String? activatedByUserId;
@override final  DateTime? terminatedAt;
@override final  String? terminatedByUserId;

/// Create a copy of MlsGenerationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MlsGenerationDtoCopyWith<_MlsGenerationDto> get copyWith => __$MlsGenerationDtoCopyWithImpl<_MlsGenerationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MlsGenerationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MlsGenerationDto&&(identical(other.id, id) || other.id == id)&&(identical(other.contextId, contextId) || other.contextId == contextId)&&(identical(other.generation, generation) || other.generation == generation)&&(identical(other.mlsGroupId, mlsGroupId) || other.mlsGroupId == mlsGroupId)&&(identical(other.mlsGroupInfo, mlsGroupInfo) || other.mlsGroupInfo == mlsGroupInfo)&&(identical(other.epoch, epoch) || other.epoch == epoch)&&(identical(other.state, state) || other.state == state)&&(identical(other.activatedAt, activatedAt) || other.activatedAt == activatedAt)&&(identical(other.activatedByUserId, activatedByUserId) || other.activatedByUserId == activatedByUserId)&&(identical(other.terminatedAt, terminatedAt) || other.terminatedAt == terminatedAt)&&(identical(other.terminatedByUserId, terminatedByUserId) || other.terminatedByUserId == terminatedByUserId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,contextId,generation,mlsGroupId,mlsGroupInfo,epoch,state,activatedAt,activatedByUserId,terminatedAt,terminatedByUserId);

@override
String toString() {
  return 'MlsGenerationDto(id: $id, contextId: $contextId, generation: $generation, mlsGroupId: $mlsGroupId, mlsGroupInfo: $mlsGroupInfo, epoch: $epoch, state: $state, activatedAt: $activatedAt, activatedByUserId: $activatedByUserId, terminatedAt: $terminatedAt, terminatedByUserId: $terminatedByUserId)';
}


}

/// @nodoc
abstract mixin class _$MlsGenerationDtoCopyWith<$Res> implements $MlsGenerationDtoCopyWith<$Res> {
  factory _$MlsGenerationDtoCopyWith(_MlsGenerationDto value, $Res Function(_MlsGenerationDto) _then) = __$MlsGenerationDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String contextId, int generation, String? mlsGroupId, String? mlsGroupInfo, int epoch,@JsonKey(unknownEnumValue: MlsGenerationState.active) MlsGenerationState state, DateTime? activatedAt, String? activatedByUserId, DateTime? terminatedAt, String? terminatedByUserId
});




}
/// @nodoc
class __$MlsGenerationDtoCopyWithImpl<$Res>
    implements _$MlsGenerationDtoCopyWith<$Res> {
  __$MlsGenerationDtoCopyWithImpl(this._self, this._then);

  final _MlsGenerationDto _self;
  final $Res Function(_MlsGenerationDto) _then;

/// Create a copy of MlsGenerationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? contextId = null,Object? generation = null,Object? mlsGroupId = freezed,Object? mlsGroupInfo = freezed,Object? epoch = null,Object? state = null,Object? activatedAt = freezed,Object? activatedByUserId = freezed,Object? terminatedAt = freezed,Object? terminatedByUserId = freezed,}) {
  return _then(_MlsGenerationDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,contextId: null == contextId ? _self.contextId : contextId // ignore: cast_nullable_to_non_nullable
as String,generation: null == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int,mlsGroupId: freezed == mlsGroupId ? _self.mlsGroupId : mlsGroupId // ignore: cast_nullable_to_non_nullable
as String?,mlsGroupInfo: freezed == mlsGroupInfo ? _self.mlsGroupInfo : mlsGroupInfo // ignore: cast_nullable_to_non_nullable
as String?,epoch: null == epoch ? _self.epoch : epoch // ignore: cast_nullable_to_non_nullable
as int,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as MlsGenerationState,activatedAt: freezed == activatedAt ? _self.activatedAt : activatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,activatedByUserId: freezed == activatedByUserId ? _self.activatedByUserId : activatedByUserId // ignore: cast_nullable_to_non_nullable
as String?,terminatedAt: freezed == terminatedAt ? _self.terminatedAt : terminatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,terminatedByUserId: freezed == terminatedByUserId ? _self.terminatedByUserId : terminatedByUserId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$MlsContextStateDto {

 String get contextId; bool get encrypted; int? get activeGeneration; int? get epoch; String? get mlsGroupId; String? get mlsGroupInfo;/// Every era the context has had, oldest first - including terminated ones,
/// whose messages are still in the history. Without them, a stretch we
/// cannot decrypt is indistinguishable from corruption.
 List<MlsGenerationDto> get generations;
/// Create a copy of MlsContextStateDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MlsContextStateDtoCopyWith<MlsContextStateDto> get copyWith => _$MlsContextStateDtoCopyWithImpl<MlsContextStateDto>(this as MlsContextStateDto, _$identity);

  /// Serializes this MlsContextStateDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MlsContextStateDto&&(identical(other.contextId, contextId) || other.contextId == contextId)&&(identical(other.encrypted, encrypted) || other.encrypted == encrypted)&&(identical(other.activeGeneration, activeGeneration) || other.activeGeneration == activeGeneration)&&(identical(other.epoch, epoch) || other.epoch == epoch)&&(identical(other.mlsGroupId, mlsGroupId) || other.mlsGroupId == mlsGroupId)&&(identical(other.mlsGroupInfo, mlsGroupInfo) || other.mlsGroupInfo == mlsGroupInfo)&&const DeepCollectionEquality().equals(other.generations, generations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contextId,encrypted,activeGeneration,epoch,mlsGroupId,mlsGroupInfo,const DeepCollectionEquality().hash(generations));

@override
String toString() {
  return 'MlsContextStateDto(contextId: $contextId, encrypted: $encrypted, activeGeneration: $activeGeneration, epoch: $epoch, mlsGroupId: $mlsGroupId, mlsGroupInfo: $mlsGroupInfo, generations: $generations)';
}


}

/// @nodoc
abstract mixin class $MlsContextStateDtoCopyWith<$Res>  {
  factory $MlsContextStateDtoCopyWith(MlsContextStateDto value, $Res Function(MlsContextStateDto) _then) = _$MlsContextStateDtoCopyWithImpl;
@useResult
$Res call({
 String contextId, bool encrypted, int? activeGeneration, int? epoch, String? mlsGroupId, String? mlsGroupInfo, List<MlsGenerationDto> generations
});




}
/// @nodoc
class _$MlsContextStateDtoCopyWithImpl<$Res>
    implements $MlsContextStateDtoCopyWith<$Res> {
  _$MlsContextStateDtoCopyWithImpl(this._self, this._then);

  final MlsContextStateDto _self;
  final $Res Function(MlsContextStateDto) _then;

/// Create a copy of MlsContextStateDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contextId = null,Object? encrypted = null,Object? activeGeneration = freezed,Object? epoch = freezed,Object? mlsGroupId = freezed,Object? mlsGroupInfo = freezed,Object? generations = null,}) {
  return _then(_self.copyWith(
contextId: null == contextId ? _self.contextId : contextId // ignore: cast_nullable_to_non_nullable
as String,encrypted: null == encrypted ? _self.encrypted : encrypted // ignore: cast_nullable_to_non_nullable
as bool,activeGeneration: freezed == activeGeneration ? _self.activeGeneration : activeGeneration // ignore: cast_nullable_to_non_nullable
as int?,epoch: freezed == epoch ? _self.epoch : epoch // ignore: cast_nullable_to_non_nullable
as int?,mlsGroupId: freezed == mlsGroupId ? _self.mlsGroupId : mlsGroupId // ignore: cast_nullable_to_non_nullable
as String?,mlsGroupInfo: freezed == mlsGroupInfo ? _self.mlsGroupInfo : mlsGroupInfo // ignore: cast_nullable_to_non_nullable
as String?,generations: null == generations ? _self.generations : generations // ignore: cast_nullable_to_non_nullable
as List<MlsGenerationDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [MlsContextStateDto].
extension MlsContextStateDtoPatterns on MlsContextStateDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MlsContextStateDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MlsContextStateDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MlsContextStateDto value)  $default,){
final _that = this;
switch (_that) {
case _MlsContextStateDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MlsContextStateDto value)?  $default,){
final _that = this;
switch (_that) {
case _MlsContextStateDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String contextId,  bool encrypted,  int? activeGeneration,  int? epoch,  String? mlsGroupId,  String? mlsGroupInfo,  List<MlsGenerationDto> generations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MlsContextStateDto() when $default != null:
return $default(_that.contextId,_that.encrypted,_that.activeGeneration,_that.epoch,_that.mlsGroupId,_that.mlsGroupInfo,_that.generations);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String contextId,  bool encrypted,  int? activeGeneration,  int? epoch,  String? mlsGroupId,  String? mlsGroupInfo,  List<MlsGenerationDto> generations)  $default,) {final _that = this;
switch (_that) {
case _MlsContextStateDto():
return $default(_that.contextId,_that.encrypted,_that.activeGeneration,_that.epoch,_that.mlsGroupId,_that.mlsGroupInfo,_that.generations);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String contextId,  bool encrypted,  int? activeGeneration,  int? epoch,  String? mlsGroupId,  String? mlsGroupInfo,  List<MlsGenerationDto> generations)?  $default,) {final _that = this;
switch (_that) {
case _MlsContextStateDto() when $default != null:
return $default(_that.contextId,_that.encrypted,_that.activeGeneration,_that.epoch,_that.mlsGroupId,_that.mlsGroupInfo,_that.generations);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MlsContextStateDto extends MlsContextStateDto {
  const _MlsContextStateDto({required this.contextId, this.encrypted = false, this.activeGeneration, this.epoch, this.mlsGroupId, this.mlsGroupInfo, final  List<MlsGenerationDto> generations = const <MlsGenerationDto>[]}): _generations = generations,super._();
  factory _MlsContextStateDto.fromJson(Map<String, dynamic> json) => _$MlsContextStateDtoFromJson(json);

@override final  String contextId;
@override@JsonKey() final  bool encrypted;
@override final  int? activeGeneration;
@override final  int? epoch;
@override final  String? mlsGroupId;
@override final  String? mlsGroupInfo;
/// Every era the context has had, oldest first - including terminated ones,
/// whose messages are still in the history. Without them, a stretch we
/// cannot decrypt is indistinguishable from corruption.
 final  List<MlsGenerationDto> _generations;
/// Every era the context has had, oldest first - including terminated ones,
/// whose messages are still in the history. Without them, a stretch we
/// cannot decrypt is indistinguishable from corruption.
@override@JsonKey() List<MlsGenerationDto> get generations {
  if (_generations is EqualUnmodifiableListView) return _generations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_generations);
}


/// Create a copy of MlsContextStateDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MlsContextStateDtoCopyWith<_MlsContextStateDto> get copyWith => __$MlsContextStateDtoCopyWithImpl<_MlsContextStateDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MlsContextStateDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MlsContextStateDto&&(identical(other.contextId, contextId) || other.contextId == contextId)&&(identical(other.encrypted, encrypted) || other.encrypted == encrypted)&&(identical(other.activeGeneration, activeGeneration) || other.activeGeneration == activeGeneration)&&(identical(other.epoch, epoch) || other.epoch == epoch)&&(identical(other.mlsGroupId, mlsGroupId) || other.mlsGroupId == mlsGroupId)&&(identical(other.mlsGroupInfo, mlsGroupInfo) || other.mlsGroupInfo == mlsGroupInfo)&&const DeepCollectionEquality().equals(other._generations, _generations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contextId,encrypted,activeGeneration,epoch,mlsGroupId,mlsGroupInfo,const DeepCollectionEquality().hash(_generations));

@override
String toString() {
  return 'MlsContextStateDto(contextId: $contextId, encrypted: $encrypted, activeGeneration: $activeGeneration, epoch: $epoch, mlsGroupId: $mlsGroupId, mlsGroupInfo: $mlsGroupInfo, generations: $generations)';
}


}

/// @nodoc
abstract mixin class _$MlsContextStateDtoCopyWith<$Res> implements $MlsContextStateDtoCopyWith<$Res> {
  factory _$MlsContextStateDtoCopyWith(_MlsContextStateDto value, $Res Function(_MlsContextStateDto) _then) = __$MlsContextStateDtoCopyWithImpl;
@override @useResult
$Res call({
 String contextId, bool encrypted, int? activeGeneration, int? epoch, String? mlsGroupId, String? mlsGroupInfo, List<MlsGenerationDto> generations
});




}
/// @nodoc
class __$MlsContextStateDtoCopyWithImpl<$Res>
    implements _$MlsContextStateDtoCopyWith<$Res> {
  __$MlsContextStateDtoCopyWithImpl(this._self, this._then);

  final _MlsContextStateDto _self;
  final $Res Function(_MlsContextStateDto) _then;

/// Create a copy of MlsContextStateDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contextId = null,Object? encrypted = null,Object? activeGeneration = freezed,Object? epoch = freezed,Object? mlsGroupId = freezed,Object? mlsGroupInfo = freezed,Object? generations = null,}) {
  return _then(_MlsContextStateDto(
contextId: null == contextId ? _self.contextId : contextId // ignore: cast_nullable_to_non_nullable
as String,encrypted: null == encrypted ? _self.encrypted : encrypted // ignore: cast_nullable_to_non_nullable
as bool,activeGeneration: freezed == activeGeneration ? _self.activeGeneration : activeGeneration // ignore: cast_nullable_to_non_nullable
as int?,epoch: freezed == epoch ? _self.epoch : epoch // ignore: cast_nullable_to_non_nullable
as int?,mlsGroupId: freezed == mlsGroupId ? _self.mlsGroupId : mlsGroupId // ignore: cast_nullable_to_non_nullable
as String?,mlsGroupInfo: freezed == mlsGroupInfo ? _self.mlsGroupInfo : mlsGroupInfo // ignore: cast_nullable_to_non_nullable
as String?,generations: null == generations ? _self._generations : generations // ignore: cast_nullable_to_non_nullable
as List<MlsGenerationDto>,
  ));
}


}


/// @nodoc
mixin _$EnableMlsDto {

 String get mlsGroupId; int get epoch; String? get mlsGroupInfo; List<DeviceWelcomeDto> get welcomes;
/// Create a copy of EnableMlsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EnableMlsDtoCopyWith<EnableMlsDto> get copyWith => _$EnableMlsDtoCopyWithImpl<EnableMlsDto>(this as EnableMlsDto, _$identity);

  /// Serializes this EnableMlsDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EnableMlsDto&&(identical(other.mlsGroupId, mlsGroupId) || other.mlsGroupId == mlsGroupId)&&(identical(other.epoch, epoch) || other.epoch == epoch)&&(identical(other.mlsGroupInfo, mlsGroupInfo) || other.mlsGroupInfo == mlsGroupInfo)&&const DeepCollectionEquality().equals(other.welcomes, welcomes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mlsGroupId,epoch,mlsGroupInfo,const DeepCollectionEquality().hash(welcomes));

@override
String toString() {
  return 'EnableMlsDto(mlsGroupId: $mlsGroupId, epoch: $epoch, mlsGroupInfo: $mlsGroupInfo, welcomes: $welcomes)';
}


}

/// @nodoc
abstract mixin class $EnableMlsDtoCopyWith<$Res>  {
  factory $EnableMlsDtoCopyWith(EnableMlsDto value, $Res Function(EnableMlsDto) _then) = _$EnableMlsDtoCopyWithImpl;
@useResult
$Res call({
 String mlsGroupId, int epoch, String? mlsGroupInfo, List<DeviceWelcomeDto> welcomes
});




}
/// @nodoc
class _$EnableMlsDtoCopyWithImpl<$Res>
    implements $EnableMlsDtoCopyWith<$Res> {
  _$EnableMlsDtoCopyWithImpl(this._self, this._then);

  final EnableMlsDto _self;
  final $Res Function(EnableMlsDto) _then;

/// Create a copy of EnableMlsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mlsGroupId = null,Object? epoch = null,Object? mlsGroupInfo = freezed,Object? welcomes = null,}) {
  return _then(_self.copyWith(
mlsGroupId: null == mlsGroupId ? _self.mlsGroupId : mlsGroupId // ignore: cast_nullable_to_non_nullable
as String,epoch: null == epoch ? _self.epoch : epoch // ignore: cast_nullable_to_non_nullable
as int,mlsGroupInfo: freezed == mlsGroupInfo ? _self.mlsGroupInfo : mlsGroupInfo // ignore: cast_nullable_to_non_nullable
as String?,welcomes: null == welcomes ? _self.welcomes : welcomes // ignore: cast_nullable_to_non_nullable
as List<DeviceWelcomeDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [EnableMlsDto].
extension EnableMlsDtoPatterns on EnableMlsDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EnableMlsDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EnableMlsDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EnableMlsDto value)  $default,){
final _that = this;
switch (_that) {
case _EnableMlsDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EnableMlsDto value)?  $default,){
final _that = this;
switch (_that) {
case _EnableMlsDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String mlsGroupId,  int epoch,  String? mlsGroupInfo,  List<DeviceWelcomeDto> welcomes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EnableMlsDto() when $default != null:
return $default(_that.mlsGroupId,_that.epoch,_that.mlsGroupInfo,_that.welcomes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String mlsGroupId,  int epoch,  String? mlsGroupInfo,  List<DeviceWelcomeDto> welcomes)  $default,) {final _that = this;
switch (_that) {
case _EnableMlsDto():
return $default(_that.mlsGroupId,_that.epoch,_that.mlsGroupInfo,_that.welcomes);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String mlsGroupId,  int epoch,  String? mlsGroupInfo,  List<DeviceWelcomeDto> welcomes)?  $default,) {final _that = this;
switch (_that) {
case _EnableMlsDto() when $default != null:
return $default(_that.mlsGroupId,_that.epoch,_that.mlsGroupInfo,_that.welcomes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EnableMlsDto implements EnableMlsDto {
  const _EnableMlsDto({required this.mlsGroupId, required this.epoch, this.mlsGroupInfo, final  List<DeviceWelcomeDto> welcomes = const <DeviceWelcomeDto>[]}): _welcomes = welcomes;
  factory _EnableMlsDto.fromJson(Map<String, dynamic> json) => _$EnableMlsDtoFromJson(json);

@override final  String mlsGroupId;
@override final  int epoch;
@override final  String? mlsGroupInfo;
 final  List<DeviceWelcomeDto> _welcomes;
@override@JsonKey() List<DeviceWelcomeDto> get welcomes {
  if (_welcomes is EqualUnmodifiableListView) return _welcomes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_welcomes);
}


/// Create a copy of EnableMlsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EnableMlsDtoCopyWith<_EnableMlsDto> get copyWith => __$EnableMlsDtoCopyWithImpl<_EnableMlsDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EnableMlsDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EnableMlsDto&&(identical(other.mlsGroupId, mlsGroupId) || other.mlsGroupId == mlsGroupId)&&(identical(other.epoch, epoch) || other.epoch == epoch)&&(identical(other.mlsGroupInfo, mlsGroupInfo) || other.mlsGroupInfo == mlsGroupInfo)&&const DeepCollectionEquality().equals(other._welcomes, _welcomes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mlsGroupId,epoch,mlsGroupInfo,const DeepCollectionEquality().hash(_welcomes));

@override
String toString() {
  return 'EnableMlsDto(mlsGroupId: $mlsGroupId, epoch: $epoch, mlsGroupInfo: $mlsGroupInfo, welcomes: $welcomes)';
}


}

/// @nodoc
abstract mixin class _$EnableMlsDtoCopyWith<$Res> implements $EnableMlsDtoCopyWith<$Res> {
  factory _$EnableMlsDtoCopyWith(_EnableMlsDto value, $Res Function(_EnableMlsDto) _then) = __$EnableMlsDtoCopyWithImpl;
@override @useResult
$Res call({
 String mlsGroupId, int epoch, String? mlsGroupInfo, List<DeviceWelcomeDto> welcomes
});




}
/// @nodoc
class __$EnableMlsDtoCopyWithImpl<$Res>
    implements _$EnableMlsDtoCopyWith<$Res> {
  __$EnableMlsDtoCopyWithImpl(this._self, this._then);

  final _EnableMlsDto _self;
  final $Res Function(_EnableMlsDto) _then;

/// Create a copy of EnableMlsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mlsGroupId = null,Object? epoch = null,Object? mlsGroupInfo = freezed,Object? welcomes = null,}) {
  return _then(_EnableMlsDto(
mlsGroupId: null == mlsGroupId ? _self.mlsGroupId : mlsGroupId // ignore: cast_nullable_to_non_nullable
as String,epoch: null == epoch ? _self.epoch : epoch // ignore: cast_nullable_to_non_nullable
as int,mlsGroupInfo: freezed == mlsGroupInfo ? _self.mlsGroupInfo : mlsGroupInfo // ignore: cast_nullable_to_non_nullable
as String?,welcomes: null == welcomes ? _self._welcomes : welcomes // ignore: cast_nullable_to_non_nullable
as List<DeviceWelcomeDto>,
  ));
}


}


/// @nodoc
mixin _$MlsToggleResultDto {

 String get contextId; bool get encrypted; int? get generation;/// Set on disable: messages from this era stay ciphertext, readable only by
/// devices that still hold that group's keys.
 int? get terminatedGeneration; bool get alreadyInRequestedState;
/// Create a copy of MlsToggleResultDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MlsToggleResultDtoCopyWith<MlsToggleResultDto> get copyWith => _$MlsToggleResultDtoCopyWithImpl<MlsToggleResultDto>(this as MlsToggleResultDto, _$identity);

  /// Serializes this MlsToggleResultDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MlsToggleResultDto&&(identical(other.contextId, contextId) || other.contextId == contextId)&&(identical(other.encrypted, encrypted) || other.encrypted == encrypted)&&(identical(other.generation, generation) || other.generation == generation)&&(identical(other.terminatedGeneration, terminatedGeneration) || other.terminatedGeneration == terminatedGeneration)&&(identical(other.alreadyInRequestedState, alreadyInRequestedState) || other.alreadyInRequestedState == alreadyInRequestedState));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contextId,encrypted,generation,terminatedGeneration,alreadyInRequestedState);

@override
String toString() {
  return 'MlsToggleResultDto(contextId: $contextId, encrypted: $encrypted, generation: $generation, terminatedGeneration: $terminatedGeneration, alreadyInRequestedState: $alreadyInRequestedState)';
}


}

/// @nodoc
abstract mixin class $MlsToggleResultDtoCopyWith<$Res>  {
  factory $MlsToggleResultDtoCopyWith(MlsToggleResultDto value, $Res Function(MlsToggleResultDto) _then) = _$MlsToggleResultDtoCopyWithImpl;
@useResult
$Res call({
 String contextId, bool encrypted, int? generation, int? terminatedGeneration, bool alreadyInRequestedState
});




}
/// @nodoc
class _$MlsToggleResultDtoCopyWithImpl<$Res>
    implements $MlsToggleResultDtoCopyWith<$Res> {
  _$MlsToggleResultDtoCopyWithImpl(this._self, this._then);

  final MlsToggleResultDto _self;
  final $Res Function(MlsToggleResultDto) _then;

/// Create a copy of MlsToggleResultDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contextId = null,Object? encrypted = null,Object? generation = freezed,Object? terminatedGeneration = freezed,Object? alreadyInRequestedState = null,}) {
  return _then(_self.copyWith(
contextId: null == contextId ? _self.contextId : contextId // ignore: cast_nullable_to_non_nullable
as String,encrypted: null == encrypted ? _self.encrypted : encrypted // ignore: cast_nullable_to_non_nullable
as bool,generation: freezed == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int?,terminatedGeneration: freezed == terminatedGeneration ? _self.terminatedGeneration : terminatedGeneration // ignore: cast_nullable_to_non_nullable
as int?,alreadyInRequestedState: null == alreadyInRequestedState ? _self.alreadyInRequestedState : alreadyInRequestedState // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MlsToggleResultDto].
extension MlsToggleResultDtoPatterns on MlsToggleResultDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MlsToggleResultDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MlsToggleResultDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MlsToggleResultDto value)  $default,){
final _that = this;
switch (_that) {
case _MlsToggleResultDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MlsToggleResultDto value)?  $default,){
final _that = this;
switch (_that) {
case _MlsToggleResultDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String contextId,  bool encrypted,  int? generation,  int? terminatedGeneration,  bool alreadyInRequestedState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MlsToggleResultDto() when $default != null:
return $default(_that.contextId,_that.encrypted,_that.generation,_that.terminatedGeneration,_that.alreadyInRequestedState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String contextId,  bool encrypted,  int? generation,  int? terminatedGeneration,  bool alreadyInRequestedState)  $default,) {final _that = this;
switch (_that) {
case _MlsToggleResultDto():
return $default(_that.contextId,_that.encrypted,_that.generation,_that.terminatedGeneration,_that.alreadyInRequestedState);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String contextId,  bool encrypted,  int? generation,  int? terminatedGeneration,  bool alreadyInRequestedState)?  $default,) {final _that = this;
switch (_that) {
case _MlsToggleResultDto() when $default != null:
return $default(_that.contextId,_that.encrypted,_that.generation,_that.terminatedGeneration,_that.alreadyInRequestedState);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MlsToggleResultDto implements MlsToggleResultDto {
  const _MlsToggleResultDto({required this.contextId, this.encrypted = false, this.generation, this.terminatedGeneration, this.alreadyInRequestedState = false});
  factory _MlsToggleResultDto.fromJson(Map<String, dynamic> json) => _$MlsToggleResultDtoFromJson(json);

@override final  String contextId;
@override@JsonKey() final  bool encrypted;
@override final  int? generation;
/// Set on disable: messages from this era stay ciphertext, readable only by
/// devices that still hold that group's keys.
@override final  int? terminatedGeneration;
@override@JsonKey() final  bool alreadyInRequestedState;

/// Create a copy of MlsToggleResultDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MlsToggleResultDtoCopyWith<_MlsToggleResultDto> get copyWith => __$MlsToggleResultDtoCopyWithImpl<_MlsToggleResultDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MlsToggleResultDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MlsToggleResultDto&&(identical(other.contextId, contextId) || other.contextId == contextId)&&(identical(other.encrypted, encrypted) || other.encrypted == encrypted)&&(identical(other.generation, generation) || other.generation == generation)&&(identical(other.terminatedGeneration, terminatedGeneration) || other.terminatedGeneration == terminatedGeneration)&&(identical(other.alreadyInRequestedState, alreadyInRequestedState) || other.alreadyInRequestedState == alreadyInRequestedState));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contextId,encrypted,generation,terminatedGeneration,alreadyInRequestedState);

@override
String toString() {
  return 'MlsToggleResultDto(contextId: $contextId, encrypted: $encrypted, generation: $generation, terminatedGeneration: $terminatedGeneration, alreadyInRequestedState: $alreadyInRequestedState)';
}


}

/// @nodoc
abstract mixin class _$MlsToggleResultDtoCopyWith<$Res> implements $MlsToggleResultDtoCopyWith<$Res> {
  factory _$MlsToggleResultDtoCopyWith(_MlsToggleResultDto value, $Res Function(_MlsToggleResultDto) _then) = __$MlsToggleResultDtoCopyWithImpl;
@override @useResult
$Res call({
 String contextId, bool encrypted, int? generation, int? terminatedGeneration, bool alreadyInRequestedState
});




}
/// @nodoc
class __$MlsToggleResultDtoCopyWithImpl<$Res>
    implements _$MlsToggleResultDtoCopyWith<$Res> {
  __$MlsToggleResultDtoCopyWithImpl(this._self, this._then);

  final _MlsToggleResultDto _self;
  final $Res Function(_MlsToggleResultDto) _then;

/// Create a copy of MlsToggleResultDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contextId = null,Object? encrypted = null,Object? generation = freezed,Object? terminatedGeneration = freezed,Object? alreadyInRequestedState = null,}) {
  return _then(_MlsToggleResultDto(
contextId: null == contextId ? _self.contextId : contextId // ignore: cast_nullable_to_non_nullable
as String,encrypted: null == encrypted ? _self.encrypted : encrypted // ignore: cast_nullable_to_non_nullable
as bool,generation: freezed == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int?,terminatedGeneration: freezed == terminatedGeneration ? _self.terminatedGeneration : terminatedGeneration // ignore: cast_nullable_to_non_nullable
as int?,alreadyInRequestedState: null == alreadyInRequestedState ? _self.alreadyInRequestedState : alreadyInRequestedState // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$MlsEpochConflictDto {

 int get currentEpoch; int get rejectedEpoch; int get currentGeneration; int get rejectedGeneration; String get reason;
/// Create a copy of MlsEpochConflictDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MlsEpochConflictDtoCopyWith<MlsEpochConflictDto> get copyWith => _$MlsEpochConflictDtoCopyWithImpl<MlsEpochConflictDto>(this as MlsEpochConflictDto, _$identity);

  /// Serializes this MlsEpochConflictDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MlsEpochConflictDto&&(identical(other.currentEpoch, currentEpoch) || other.currentEpoch == currentEpoch)&&(identical(other.rejectedEpoch, rejectedEpoch) || other.rejectedEpoch == rejectedEpoch)&&(identical(other.currentGeneration, currentGeneration) || other.currentGeneration == currentGeneration)&&(identical(other.rejectedGeneration, rejectedGeneration) || other.rejectedGeneration == rejectedGeneration)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentEpoch,rejectedEpoch,currentGeneration,rejectedGeneration,reason);

@override
String toString() {
  return 'MlsEpochConflictDto(currentEpoch: $currentEpoch, rejectedEpoch: $rejectedEpoch, currentGeneration: $currentGeneration, rejectedGeneration: $rejectedGeneration, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $MlsEpochConflictDtoCopyWith<$Res>  {
  factory $MlsEpochConflictDtoCopyWith(MlsEpochConflictDto value, $Res Function(MlsEpochConflictDto) _then) = _$MlsEpochConflictDtoCopyWithImpl;
@useResult
$Res call({
 int currentEpoch, int rejectedEpoch, int currentGeneration, int rejectedGeneration, String reason
});




}
/// @nodoc
class _$MlsEpochConflictDtoCopyWithImpl<$Res>
    implements $MlsEpochConflictDtoCopyWith<$Res> {
  _$MlsEpochConflictDtoCopyWithImpl(this._self, this._then);

  final MlsEpochConflictDto _self;
  final $Res Function(MlsEpochConflictDto) _then;

/// Create a copy of MlsEpochConflictDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentEpoch = null,Object? rejectedEpoch = null,Object? currentGeneration = null,Object? rejectedGeneration = null,Object? reason = null,}) {
  return _then(_self.copyWith(
currentEpoch: null == currentEpoch ? _self.currentEpoch : currentEpoch // ignore: cast_nullable_to_non_nullable
as int,rejectedEpoch: null == rejectedEpoch ? _self.rejectedEpoch : rejectedEpoch // ignore: cast_nullable_to_non_nullable
as int,currentGeneration: null == currentGeneration ? _self.currentGeneration : currentGeneration // ignore: cast_nullable_to_non_nullable
as int,rejectedGeneration: null == rejectedGeneration ? _self.rejectedGeneration : rejectedGeneration // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MlsEpochConflictDto].
extension MlsEpochConflictDtoPatterns on MlsEpochConflictDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MlsEpochConflictDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MlsEpochConflictDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MlsEpochConflictDto value)  $default,){
final _that = this;
switch (_that) {
case _MlsEpochConflictDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MlsEpochConflictDto value)?  $default,){
final _that = this;
switch (_that) {
case _MlsEpochConflictDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int currentEpoch,  int rejectedEpoch,  int currentGeneration,  int rejectedGeneration,  String reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MlsEpochConflictDto() when $default != null:
return $default(_that.currentEpoch,_that.rejectedEpoch,_that.currentGeneration,_that.rejectedGeneration,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int currentEpoch,  int rejectedEpoch,  int currentGeneration,  int rejectedGeneration,  String reason)  $default,) {final _that = this;
switch (_that) {
case _MlsEpochConflictDto():
return $default(_that.currentEpoch,_that.rejectedEpoch,_that.currentGeneration,_that.rejectedGeneration,_that.reason);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int currentEpoch,  int rejectedEpoch,  int currentGeneration,  int rejectedGeneration,  String reason)?  $default,) {final _that = this;
switch (_that) {
case _MlsEpochConflictDto() when $default != null:
return $default(_that.currentEpoch,_that.rejectedEpoch,_that.currentGeneration,_that.rejectedGeneration,_that.reason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MlsEpochConflictDto implements MlsEpochConflictDto {
  const _MlsEpochConflictDto({this.currentEpoch = 0, this.rejectedEpoch = 0, this.currentGeneration = 0, this.rejectedGeneration = 0, this.reason = ''});
  factory _MlsEpochConflictDto.fromJson(Map<String, dynamic> json) => _$MlsEpochConflictDtoFromJson(json);

@override@JsonKey() final  int currentEpoch;
@override@JsonKey() final  int rejectedEpoch;
@override@JsonKey() final  int currentGeneration;
@override@JsonKey() final  int rejectedGeneration;
@override@JsonKey() final  String reason;

/// Create a copy of MlsEpochConflictDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MlsEpochConflictDtoCopyWith<_MlsEpochConflictDto> get copyWith => __$MlsEpochConflictDtoCopyWithImpl<_MlsEpochConflictDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MlsEpochConflictDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MlsEpochConflictDto&&(identical(other.currentEpoch, currentEpoch) || other.currentEpoch == currentEpoch)&&(identical(other.rejectedEpoch, rejectedEpoch) || other.rejectedEpoch == rejectedEpoch)&&(identical(other.currentGeneration, currentGeneration) || other.currentGeneration == currentGeneration)&&(identical(other.rejectedGeneration, rejectedGeneration) || other.rejectedGeneration == rejectedGeneration)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentEpoch,rejectedEpoch,currentGeneration,rejectedGeneration,reason);

@override
String toString() {
  return 'MlsEpochConflictDto(currentEpoch: $currentEpoch, rejectedEpoch: $rejectedEpoch, currentGeneration: $currentGeneration, rejectedGeneration: $rejectedGeneration, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$MlsEpochConflictDtoCopyWith<$Res> implements $MlsEpochConflictDtoCopyWith<$Res> {
  factory _$MlsEpochConflictDtoCopyWith(_MlsEpochConflictDto value, $Res Function(_MlsEpochConflictDto) _then) = __$MlsEpochConflictDtoCopyWithImpl;
@override @useResult
$Res call({
 int currentEpoch, int rejectedEpoch, int currentGeneration, int rejectedGeneration, String reason
});




}
/// @nodoc
class __$MlsEpochConflictDtoCopyWithImpl<$Res>
    implements _$MlsEpochConflictDtoCopyWith<$Res> {
  __$MlsEpochConflictDtoCopyWithImpl(this._self, this._then);

  final _MlsEpochConflictDto _self;
  final $Res Function(_MlsEpochConflictDto) _then;

/// Create a copy of MlsEpochConflictDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentEpoch = null,Object? rejectedEpoch = null,Object? currentGeneration = null,Object? rejectedGeneration = null,Object? reason = null,}) {
  return _then(_MlsEpochConflictDto(
currentEpoch: null == currentEpoch ? _self.currentEpoch : currentEpoch // ignore: cast_nullable_to_non_nullable
as int,rejectedEpoch: null == rejectedEpoch ? _self.rejectedEpoch : rejectedEpoch // ignore: cast_nullable_to_non_nullable
as int,currentGeneration: null == currentGeneration ? _self.currentGeneration : currentGeneration // ignore: cast_nullable_to_non_nullable
as int,rejectedGeneration: null == rejectedGeneration ? _self.rejectedGeneration : rejectedGeneration // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MlsToggleConflictDto {

 String get contextId; bool get encrypted; String get reason; int? get retryAfterSeconds;
/// Create a copy of MlsToggleConflictDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MlsToggleConflictDtoCopyWith<MlsToggleConflictDto> get copyWith => _$MlsToggleConflictDtoCopyWithImpl<MlsToggleConflictDto>(this as MlsToggleConflictDto, _$identity);

  /// Serializes this MlsToggleConflictDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MlsToggleConflictDto&&(identical(other.contextId, contextId) || other.contextId == contextId)&&(identical(other.encrypted, encrypted) || other.encrypted == encrypted)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.retryAfterSeconds, retryAfterSeconds) || other.retryAfterSeconds == retryAfterSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contextId,encrypted,reason,retryAfterSeconds);

@override
String toString() {
  return 'MlsToggleConflictDto(contextId: $contextId, encrypted: $encrypted, reason: $reason, retryAfterSeconds: $retryAfterSeconds)';
}


}

/// @nodoc
abstract mixin class $MlsToggleConflictDtoCopyWith<$Res>  {
  factory $MlsToggleConflictDtoCopyWith(MlsToggleConflictDto value, $Res Function(MlsToggleConflictDto) _then) = _$MlsToggleConflictDtoCopyWithImpl;
@useResult
$Res call({
 String contextId, bool encrypted, String reason, int? retryAfterSeconds
});




}
/// @nodoc
class _$MlsToggleConflictDtoCopyWithImpl<$Res>
    implements $MlsToggleConflictDtoCopyWith<$Res> {
  _$MlsToggleConflictDtoCopyWithImpl(this._self, this._then);

  final MlsToggleConflictDto _self;
  final $Res Function(MlsToggleConflictDto) _then;

/// Create a copy of MlsToggleConflictDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contextId = null,Object? encrypted = null,Object? reason = null,Object? retryAfterSeconds = freezed,}) {
  return _then(_self.copyWith(
contextId: null == contextId ? _self.contextId : contextId // ignore: cast_nullable_to_non_nullable
as String,encrypted: null == encrypted ? _self.encrypted : encrypted // ignore: cast_nullable_to_non_nullable
as bool,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,retryAfterSeconds: freezed == retryAfterSeconds ? _self.retryAfterSeconds : retryAfterSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [MlsToggleConflictDto].
extension MlsToggleConflictDtoPatterns on MlsToggleConflictDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MlsToggleConflictDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MlsToggleConflictDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MlsToggleConflictDto value)  $default,){
final _that = this;
switch (_that) {
case _MlsToggleConflictDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MlsToggleConflictDto value)?  $default,){
final _that = this;
switch (_that) {
case _MlsToggleConflictDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String contextId,  bool encrypted,  String reason,  int? retryAfterSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MlsToggleConflictDto() when $default != null:
return $default(_that.contextId,_that.encrypted,_that.reason,_that.retryAfterSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String contextId,  bool encrypted,  String reason,  int? retryAfterSeconds)  $default,) {final _that = this;
switch (_that) {
case _MlsToggleConflictDto():
return $default(_that.contextId,_that.encrypted,_that.reason,_that.retryAfterSeconds);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String contextId,  bool encrypted,  String reason,  int? retryAfterSeconds)?  $default,) {final _that = this;
switch (_that) {
case _MlsToggleConflictDto() when $default != null:
return $default(_that.contextId,_that.encrypted,_that.reason,_that.retryAfterSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MlsToggleConflictDto implements MlsToggleConflictDto {
  const _MlsToggleConflictDto({this.contextId = '', this.encrypted = false, this.reason = '', this.retryAfterSeconds});
  factory _MlsToggleConflictDto.fromJson(Map<String, dynamic> json) => _$MlsToggleConflictDtoFromJson(json);

@override@JsonKey() final  String contextId;
@override@JsonKey() final  bool encrypted;
@override@JsonKey() final  String reason;
@override final  int? retryAfterSeconds;

/// Create a copy of MlsToggleConflictDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MlsToggleConflictDtoCopyWith<_MlsToggleConflictDto> get copyWith => __$MlsToggleConflictDtoCopyWithImpl<_MlsToggleConflictDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MlsToggleConflictDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MlsToggleConflictDto&&(identical(other.contextId, contextId) || other.contextId == contextId)&&(identical(other.encrypted, encrypted) || other.encrypted == encrypted)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.retryAfterSeconds, retryAfterSeconds) || other.retryAfterSeconds == retryAfterSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contextId,encrypted,reason,retryAfterSeconds);

@override
String toString() {
  return 'MlsToggleConflictDto(contextId: $contextId, encrypted: $encrypted, reason: $reason, retryAfterSeconds: $retryAfterSeconds)';
}


}

/// @nodoc
abstract mixin class _$MlsToggleConflictDtoCopyWith<$Res> implements $MlsToggleConflictDtoCopyWith<$Res> {
  factory _$MlsToggleConflictDtoCopyWith(_MlsToggleConflictDto value, $Res Function(_MlsToggleConflictDto) _then) = __$MlsToggleConflictDtoCopyWithImpl;
@override @useResult
$Res call({
 String contextId, bool encrypted, String reason, int? retryAfterSeconds
});




}
/// @nodoc
class __$MlsToggleConflictDtoCopyWithImpl<$Res>
    implements _$MlsToggleConflictDtoCopyWith<$Res> {
  __$MlsToggleConflictDtoCopyWithImpl(this._self, this._then);

  final _MlsToggleConflictDto _self;
  final $Res Function(_MlsToggleConflictDto) _then;

/// Create a copy of MlsToggleConflictDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contextId = null,Object? encrypted = null,Object? reason = null,Object? retryAfterSeconds = freezed,}) {
  return _then(_MlsToggleConflictDto(
contextId: null == contextId ? _self.contextId : contextId // ignore: cast_nullable_to_non_nullable
as String,encrypted: null == encrypted ? _self.encrypted : encrypted // ignore: cast_nullable_to_non_nullable
as bool,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,retryAfterSeconds: freezed == retryAfterSeconds ? _self.retryAfterSeconds : retryAfterSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$AckWelcomesResultDto {

 int get acknowledged;
/// Create a copy of AckWelcomesResultDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AckWelcomesResultDtoCopyWith<AckWelcomesResultDto> get copyWith => _$AckWelcomesResultDtoCopyWithImpl<AckWelcomesResultDto>(this as AckWelcomesResultDto, _$identity);

  /// Serializes this AckWelcomesResultDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AckWelcomesResultDto&&(identical(other.acknowledged, acknowledged) || other.acknowledged == acknowledged));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,acknowledged);

@override
String toString() {
  return 'AckWelcomesResultDto(acknowledged: $acknowledged)';
}


}

/// @nodoc
abstract mixin class $AckWelcomesResultDtoCopyWith<$Res>  {
  factory $AckWelcomesResultDtoCopyWith(AckWelcomesResultDto value, $Res Function(AckWelcomesResultDto) _then) = _$AckWelcomesResultDtoCopyWithImpl;
@useResult
$Res call({
 int acknowledged
});




}
/// @nodoc
class _$AckWelcomesResultDtoCopyWithImpl<$Res>
    implements $AckWelcomesResultDtoCopyWith<$Res> {
  _$AckWelcomesResultDtoCopyWithImpl(this._self, this._then);

  final AckWelcomesResultDto _self;
  final $Res Function(AckWelcomesResultDto) _then;

/// Create a copy of AckWelcomesResultDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? acknowledged = null,}) {
  return _then(_self.copyWith(
acknowledged: null == acknowledged ? _self.acknowledged : acknowledged // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AckWelcomesResultDto].
extension AckWelcomesResultDtoPatterns on AckWelcomesResultDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AckWelcomesResultDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AckWelcomesResultDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AckWelcomesResultDto value)  $default,){
final _that = this;
switch (_that) {
case _AckWelcomesResultDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AckWelcomesResultDto value)?  $default,){
final _that = this;
switch (_that) {
case _AckWelcomesResultDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int acknowledged)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AckWelcomesResultDto() when $default != null:
return $default(_that.acknowledged);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int acknowledged)  $default,) {final _that = this;
switch (_that) {
case _AckWelcomesResultDto():
return $default(_that.acknowledged);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int acknowledged)?  $default,) {final _that = this;
switch (_that) {
case _AckWelcomesResultDto() when $default != null:
return $default(_that.acknowledged);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AckWelcomesResultDto implements AckWelcomesResultDto {
  const _AckWelcomesResultDto({this.acknowledged = 0});
  factory _AckWelcomesResultDto.fromJson(Map<String, dynamic> json) => _$AckWelcomesResultDtoFromJson(json);

@override@JsonKey() final  int acknowledged;

/// Create a copy of AckWelcomesResultDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AckWelcomesResultDtoCopyWith<_AckWelcomesResultDto> get copyWith => __$AckWelcomesResultDtoCopyWithImpl<_AckWelcomesResultDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AckWelcomesResultDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AckWelcomesResultDto&&(identical(other.acknowledged, acknowledged) || other.acknowledged == acknowledged));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,acknowledged);

@override
String toString() {
  return 'AckWelcomesResultDto(acknowledged: $acknowledged)';
}


}

/// @nodoc
abstract mixin class _$AckWelcomesResultDtoCopyWith<$Res> implements $AckWelcomesResultDtoCopyWith<$Res> {
  factory _$AckWelcomesResultDtoCopyWith(_AckWelcomesResultDto value, $Res Function(_AckWelcomesResultDto) _then) = __$AckWelcomesResultDtoCopyWithImpl;
@override @useResult
$Res call({
 int acknowledged
});




}
/// @nodoc
class __$AckWelcomesResultDtoCopyWithImpl<$Res>
    implements _$AckWelcomesResultDtoCopyWith<$Res> {
  __$AckWelcomesResultDtoCopyWithImpl(this._self, this._then);

  final _AckWelcomesResultDto _self;
  final $Res Function(_AckWelcomesResultDto) _then;

/// Create a copy of AckWelcomesResultDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? acknowledged = null,}) {
  return _then(_AckWelcomesResultDto(
acknowledged: null == acknowledged ? _self.acknowledged : acknowledged // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$MlsDeviceTokenDto {

 String get deviceId; String get userId; String get token;
/// Create a copy of MlsDeviceTokenDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MlsDeviceTokenDtoCopyWith<MlsDeviceTokenDto> get copyWith => _$MlsDeviceTokenDtoCopyWithImpl<MlsDeviceTokenDto>(this as MlsDeviceTokenDto, _$identity);

  /// Serializes this MlsDeviceTokenDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MlsDeviceTokenDto&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.token, token) || other.token == token));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,deviceId,userId,token);

@override
String toString() {
  return 'MlsDeviceTokenDto(deviceId: $deviceId, userId: $userId, token: $token)';
}


}

/// @nodoc
abstract mixin class $MlsDeviceTokenDtoCopyWith<$Res>  {
  factory $MlsDeviceTokenDtoCopyWith(MlsDeviceTokenDto value, $Res Function(MlsDeviceTokenDto) _then) = _$MlsDeviceTokenDtoCopyWithImpl;
@useResult
$Res call({
 String deviceId, String userId, String token
});




}
/// @nodoc
class _$MlsDeviceTokenDtoCopyWithImpl<$Res>
    implements $MlsDeviceTokenDtoCopyWith<$Res> {
  _$MlsDeviceTokenDtoCopyWithImpl(this._self, this._then);

  final MlsDeviceTokenDto _self;
  final $Res Function(MlsDeviceTokenDto) _then;

/// Create a copy of MlsDeviceTokenDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? deviceId = null,Object? userId = null,Object? token = null,}) {
  return _then(_self.copyWith(
deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MlsDeviceTokenDto].
extension MlsDeviceTokenDtoPatterns on MlsDeviceTokenDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MlsDeviceTokenDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MlsDeviceTokenDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MlsDeviceTokenDto value)  $default,){
final _that = this;
switch (_that) {
case _MlsDeviceTokenDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MlsDeviceTokenDto value)?  $default,){
final _that = this;
switch (_that) {
case _MlsDeviceTokenDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String deviceId,  String userId,  String token)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MlsDeviceTokenDto() when $default != null:
return $default(_that.deviceId,_that.userId,_that.token);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String deviceId,  String userId,  String token)  $default,) {final _that = this;
switch (_that) {
case _MlsDeviceTokenDto():
return $default(_that.deviceId,_that.userId,_that.token);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String deviceId,  String userId,  String token)?  $default,) {final _that = this;
switch (_that) {
case _MlsDeviceTokenDto() when $default != null:
return $default(_that.deviceId,_that.userId,_that.token);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MlsDeviceTokenDto implements MlsDeviceTokenDto {
  const _MlsDeviceTokenDto({required this.deviceId, required this.userId, required this.token});
  factory _MlsDeviceTokenDto.fromJson(Map<String, dynamic> json) => _$MlsDeviceTokenDtoFromJson(json);

@override final  String deviceId;
@override final  String userId;
@override final  String token;

/// Create a copy of MlsDeviceTokenDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MlsDeviceTokenDtoCopyWith<_MlsDeviceTokenDto> get copyWith => __$MlsDeviceTokenDtoCopyWithImpl<_MlsDeviceTokenDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MlsDeviceTokenDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MlsDeviceTokenDto&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.token, token) || other.token == token));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,deviceId,userId,token);

@override
String toString() {
  return 'MlsDeviceTokenDto(deviceId: $deviceId, userId: $userId, token: $token)';
}


}

/// @nodoc
abstract mixin class _$MlsDeviceTokenDtoCopyWith<$Res> implements $MlsDeviceTokenDtoCopyWith<$Res> {
  factory _$MlsDeviceTokenDtoCopyWith(_MlsDeviceTokenDto value, $Res Function(_MlsDeviceTokenDto) _then) = __$MlsDeviceTokenDtoCopyWithImpl;
@override @useResult
$Res call({
 String deviceId, String userId, String token
});




}
/// @nodoc
class __$MlsDeviceTokenDtoCopyWithImpl<$Res>
    implements _$MlsDeviceTokenDtoCopyWith<$Res> {
  __$MlsDeviceTokenDtoCopyWithImpl(this._self, this._then);

  final _MlsDeviceTokenDto _self;
  final $Res Function(_MlsDeviceTokenDto) _then;

/// Create a copy of MlsDeviceTokenDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? deviceId = null,Object? userId = null,Object? token = null,}) {
  return _then(_MlsDeviceTokenDto(
deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$UnreachableDeviceDto {

 String get userId; String get deviceId; String? get deviceName;
/// Create a copy of UnreachableDeviceDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnreachableDeviceDtoCopyWith<UnreachableDeviceDto> get copyWith => _$UnreachableDeviceDtoCopyWithImpl<UnreachableDeviceDto>(this as UnreachableDeviceDto, _$identity);

  /// Serializes this UnreachableDeviceDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnreachableDeviceDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,deviceId,deviceName);

@override
String toString() {
  return 'UnreachableDeviceDto(userId: $userId, deviceId: $deviceId, deviceName: $deviceName)';
}


}

/// @nodoc
abstract mixin class $UnreachableDeviceDtoCopyWith<$Res>  {
  factory $UnreachableDeviceDtoCopyWith(UnreachableDeviceDto value, $Res Function(UnreachableDeviceDto) _then) = _$UnreachableDeviceDtoCopyWithImpl;
@useResult
$Res call({
 String userId, String deviceId, String? deviceName
});




}
/// @nodoc
class _$UnreachableDeviceDtoCopyWithImpl<$Res>
    implements $UnreachableDeviceDtoCopyWith<$Res> {
  _$UnreachableDeviceDtoCopyWithImpl(this._self, this._then);

  final UnreachableDeviceDto _self;
  final $Res Function(UnreachableDeviceDto) _then;

/// Create a copy of UnreachableDeviceDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? deviceId = null,Object? deviceName = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UnreachableDeviceDto].
extension UnreachableDeviceDtoPatterns on UnreachableDeviceDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UnreachableDeviceDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UnreachableDeviceDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UnreachableDeviceDto value)  $default,){
final _that = this;
switch (_that) {
case _UnreachableDeviceDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UnreachableDeviceDto value)?  $default,){
final _that = this;
switch (_that) {
case _UnreachableDeviceDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String deviceId,  String? deviceName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UnreachableDeviceDto() when $default != null:
return $default(_that.userId,_that.deviceId,_that.deviceName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String deviceId,  String? deviceName)  $default,) {final _that = this;
switch (_that) {
case _UnreachableDeviceDto():
return $default(_that.userId,_that.deviceId,_that.deviceName);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String deviceId,  String? deviceName)?  $default,) {final _that = this;
switch (_that) {
case _UnreachableDeviceDto() when $default != null:
return $default(_that.userId,_that.deviceId,_that.deviceName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UnreachableDeviceDto implements UnreachableDeviceDto {
  const _UnreachableDeviceDto({required this.userId, required this.deviceId, this.deviceName});
  factory _UnreachableDeviceDto.fromJson(Map<String, dynamic> json) => _$UnreachableDeviceDtoFromJson(json);

@override final  String userId;
@override final  String deviceId;
@override final  String? deviceName;

/// Create a copy of UnreachableDeviceDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnreachableDeviceDtoCopyWith<_UnreachableDeviceDto> get copyWith => __$UnreachableDeviceDtoCopyWithImpl<_UnreachableDeviceDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UnreachableDeviceDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnreachableDeviceDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,deviceId,deviceName);

@override
String toString() {
  return 'UnreachableDeviceDto(userId: $userId, deviceId: $deviceId, deviceName: $deviceName)';
}


}

/// @nodoc
abstract mixin class _$UnreachableDeviceDtoCopyWith<$Res> implements $UnreachableDeviceDtoCopyWith<$Res> {
  factory _$UnreachableDeviceDtoCopyWith(_UnreachableDeviceDto value, $Res Function(_UnreachableDeviceDto) _then) = __$UnreachableDeviceDtoCopyWithImpl;
@override @useResult
$Res call({
 String userId, String deviceId, String? deviceName
});




}
/// @nodoc
class __$UnreachableDeviceDtoCopyWithImpl<$Res>
    implements _$UnreachableDeviceDtoCopyWith<$Res> {
  __$UnreachableDeviceDtoCopyWithImpl(this._self, this._then);

  final _UnreachableDeviceDto _self;
  final $Res Function(_UnreachableDeviceDto) _then;

/// Create a copy of UnreachableDeviceDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? deviceId = null,Object? deviceName = freezed,}) {
  return _then(_UnreachableDeviceDto(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ConsumeTokensResultDto {

 List<MlsDeviceTokenDto> get deviceTokens; List<UnreachableDeviceDto> get unreachableDevices;
/// Create a copy of ConsumeTokensResultDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConsumeTokensResultDtoCopyWith<ConsumeTokensResultDto> get copyWith => _$ConsumeTokensResultDtoCopyWithImpl<ConsumeTokensResultDto>(this as ConsumeTokensResultDto, _$identity);

  /// Serializes this ConsumeTokensResultDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConsumeTokensResultDto&&const DeepCollectionEquality().equals(other.deviceTokens, deviceTokens)&&const DeepCollectionEquality().equals(other.unreachableDevices, unreachableDevices));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(deviceTokens),const DeepCollectionEquality().hash(unreachableDevices));

@override
String toString() {
  return 'ConsumeTokensResultDto(deviceTokens: $deviceTokens, unreachableDevices: $unreachableDevices)';
}


}

/// @nodoc
abstract mixin class $ConsumeTokensResultDtoCopyWith<$Res>  {
  factory $ConsumeTokensResultDtoCopyWith(ConsumeTokensResultDto value, $Res Function(ConsumeTokensResultDto) _then) = _$ConsumeTokensResultDtoCopyWithImpl;
@useResult
$Res call({
 List<MlsDeviceTokenDto> deviceTokens, List<UnreachableDeviceDto> unreachableDevices
});




}
/// @nodoc
class _$ConsumeTokensResultDtoCopyWithImpl<$Res>
    implements $ConsumeTokensResultDtoCopyWith<$Res> {
  _$ConsumeTokensResultDtoCopyWithImpl(this._self, this._then);

  final ConsumeTokensResultDto _self;
  final $Res Function(ConsumeTokensResultDto) _then;

/// Create a copy of ConsumeTokensResultDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? deviceTokens = null,Object? unreachableDevices = null,}) {
  return _then(_self.copyWith(
deviceTokens: null == deviceTokens ? _self.deviceTokens : deviceTokens // ignore: cast_nullable_to_non_nullable
as List<MlsDeviceTokenDto>,unreachableDevices: null == unreachableDevices ? _self.unreachableDevices : unreachableDevices // ignore: cast_nullable_to_non_nullable
as List<UnreachableDeviceDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [ConsumeTokensResultDto].
extension ConsumeTokensResultDtoPatterns on ConsumeTokensResultDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConsumeTokensResultDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConsumeTokensResultDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConsumeTokensResultDto value)  $default,){
final _that = this;
switch (_that) {
case _ConsumeTokensResultDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConsumeTokensResultDto value)?  $default,){
final _that = this;
switch (_that) {
case _ConsumeTokensResultDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MlsDeviceTokenDto> deviceTokens,  List<UnreachableDeviceDto> unreachableDevices)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConsumeTokensResultDto() when $default != null:
return $default(_that.deviceTokens,_that.unreachableDevices);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MlsDeviceTokenDto> deviceTokens,  List<UnreachableDeviceDto> unreachableDevices)  $default,) {final _that = this;
switch (_that) {
case _ConsumeTokensResultDto():
return $default(_that.deviceTokens,_that.unreachableDevices);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MlsDeviceTokenDto> deviceTokens,  List<UnreachableDeviceDto> unreachableDevices)?  $default,) {final _that = this;
switch (_that) {
case _ConsumeTokensResultDto() when $default != null:
return $default(_that.deviceTokens,_that.unreachableDevices);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConsumeTokensResultDto implements ConsumeTokensResultDto {
  const _ConsumeTokensResultDto({final  List<MlsDeviceTokenDto> deviceTokens = const <MlsDeviceTokenDto>[], final  List<UnreachableDeviceDto> unreachableDevices = const <UnreachableDeviceDto>[]}): _deviceTokens = deviceTokens,_unreachableDevices = unreachableDevices;
  factory _ConsumeTokensResultDto.fromJson(Map<String, dynamic> json) => _$ConsumeTokensResultDtoFromJson(json);

 final  List<MlsDeviceTokenDto> _deviceTokens;
@override@JsonKey() List<MlsDeviceTokenDto> get deviceTokens {
  if (_deviceTokens is EqualUnmodifiableListView) return _deviceTokens;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_deviceTokens);
}

 final  List<UnreachableDeviceDto> _unreachableDevices;
@override@JsonKey() List<UnreachableDeviceDto> get unreachableDevices {
  if (_unreachableDevices is EqualUnmodifiableListView) return _unreachableDevices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_unreachableDevices);
}


/// Create a copy of ConsumeTokensResultDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConsumeTokensResultDtoCopyWith<_ConsumeTokensResultDto> get copyWith => __$ConsumeTokensResultDtoCopyWithImpl<_ConsumeTokensResultDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConsumeTokensResultDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConsumeTokensResultDto&&const DeepCollectionEquality().equals(other._deviceTokens, _deviceTokens)&&const DeepCollectionEquality().equals(other._unreachableDevices, _unreachableDevices));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_deviceTokens),const DeepCollectionEquality().hash(_unreachableDevices));

@override
String toString() {
  return 'ConsumeTokensResultDto(deviceTokens: $deviceTokens, unreachableDevices: $unreachableDevices)';
}


}

/// @nodoc
abstract mixin class _$ConsumeTokensResultDtoCopyWith<$Res> implements $ConsumeTokensResultDtoCopyWith<$Res> {
  factory _$ConsumeTokensResultDtoCopyWith(_ConsumeTokensResultDto value, $Res Function(_ConsumeTokensResultDto) _then) = __$ConsumeTokensResultDtoCopyWithImpl;
@override @useResult
$Res call({
 List<MlsDeviceTokenDto> deviceTokens, List<UnreachableDeviceDto> unreachableDevices
});




}
/// @nodoc
class __$ConsumeTokensResultDtoCopyWithImpl<$Res>
    implements _$ConsumeTokensResultDtoCopyWith<$Res> {
  __$ConsumeTokensResultDtoCopyWithImpl(this._self, this._then);

  final _ConsumeTokensResultDto _self;
  final $Res Function(_ConsumeTokensResultDto) _then;

/// Create a copy of ConsumeTokensResultDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? deviceTokens = null,Object? unreachableDevices = null,}) {
  return _then(_ConsumeTokensResultDto(
deviceTokens: null == deviceTokens ? _self._deviceTokens : deviceTokens // ignore: cast_nullable_to_non_nullable
as List<MlsDeviceTokenDto>,unreachableDevices: null == unreachableDevices ? _self._unreachableDevices : unreachableDevices // ignore: cast_nullable_to_non_nullable
as List<UnreachableDeviceDto>,
  ));
}


}


/// @nodoc
mixin _$MlsJoinRequestDto {

 String get id; String get contextId; String? get channelId; String? get conversationId; int get generation; String get requesterUserId;/// Admission is per device, not per user - each device holds its own leaf,
/// so a user's second device needs its own request.
 String get requesterDeviceId;/// SHA-256 of the key package that would be added.
 String get keyPackageHash;/// The exact key-package bytes, present only on requests belonging to the
/// **reading** account (contract §L.3 and `MlsJoinRequestService.cs:217`).
///
/// Null for a peer's request, which is correct and not a failure: a peer has
/// no use for the bytes until the approval threshold is met, and
/// [MlsJoinRequestApprovalResultDto.keyPackage] is where they arrive then.
///
/// Omitting this field is what made own-device admission unreachable. The
/// §G ceremony ends with *this* device minting an Add commit over these
/// bytes; with nowhere to put them the bridge passed an empty string into
/// `inspectKeyPackage`, which cannot parse and never could, so every
/// automatic admission failed at the last step with the proof already
/// verified.
 String? get keyPackage;/// The requester's long-lived identity fingerprint, for out-of-band
/// comparison. Stable across all their key packages, which is what makes it
/// readable aloud - a key-package hash changes on every request.
 String get signatureKeyFingerprint;@JsonKey(unknownEnumValue: MlsJoinRequestState.pending) MlsJoinRequestState get state; DateTime? get createdAt; DateTime? get expiresAt; int get requiredApprovals;/// Who has already vouched. Lets a reviewer see they have approved, and see
/// who else did - a second opinion is only worth something if you can tell
/// whose it was.
 List<String> get approverUserIds;/// The server's published verdict on whether this may be admitted without a
/// human (contract §J.4).
///
/// The server cannot *enforce* it - it holds no group keys, so only a
/// member's client can produce an Add commit or decline to. It decides the
/// 24h auto-admission budget and records how it was spent; honouring the
/// answer is entirely on this side.
 bool get requiresManualApproval;/// Display only, so an approval prompt can say "Alice's new phone" instead
/// of an opaque id. Nothing is authorized on it.
 String? get requesterDeviceName;
/// Create a copy of MlsJoinRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MlsJoinRequestDtoCopyWith<MlsJoinRequestDto> get copyWith => _$MlsJoinRequestDtoCopyWithImpl<MlsJoinRequestDto>(this as MlsJoinRequestDto, _$identity);

  /// Serializes this MlsJoinRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MlsJoinRequestDto&&(identical(other.id, id) || other.id == id)&&(identical(other.contextId, contextId) || other.contextId == contextId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.generation, generation) || other.generation == generation)&&(identical(other.requesterUserId, requesterUserId) || other.requesterUserId == requesterUserId)&&(identical(other.requesterDeviceId, requesterDeviceId) || other.requesterDeviceId == requesterDeviceId)&&(identical(other.keyPackageHash, keyPackageHash) || other.keyPackageHash == keyPackageHash)&&(identical(other.keyPackage, keyPackage) || other.keyPackage == keyPackage)&&(identical(other.signatureKeyFingerprint, signatureKeyFingerprint) || other.signatureKeyFingerprint == signatureKeyFingerprint)&&(identical(other.state, state) || other.state == state)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.requiredApprovals, requiredApprovals) || other.requiredApprovals == requiredApprovals)&&const DeepCollectionEquality().equals(other.approverUserIds, approverUserIds)&&(identical(other.requiresManualApproval, requiresManualApproval) || other.requiresManualApproval == requiresManualApproval)&&(identical(other.requesterDeviceName, requesterDeviceName) || other.requesterDeviceName == requesterDeviceName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,contextId,channelId,conversationId,generation,requesterUserId,requesterDeviceId,keyPackageHash,keyPackage,signatureKeyFingerprint,state,createdAt,expiresAt,requiredApprovals,const DeepCollectionEquality().hash(approverUserIds),requiresManualApproval,requesterDeviceName);

@override
String toString() {
  return 'MlsJoinRequestDto(id: $id, contextId: $contextId, channelId: $channelId, conversationId: $conversationId, generation: $generation, requesterUserId: $requesterUserId, requesterDeviceId: $requesterDeviceId, keyPackageHash: $keyPackageHash, keyPackage: $keyPackage, signatureKeyFingerprint: $signatureKeyFingerprint, state: $state, createdAt: $createdAt, expiresAt: $expiresAt, requiredApprovals: $requiredApprovals, approverUserIds: $approverUserIds, requiresManualApproval: $requiresManualApproval, requesterDeviceName: $requesterDeviceName)';
}


}

/// @nodoc
abstract mixin class $MlsJoinRequestDtoCopyWith<$Res>  {
  factory $MlsJoinRequestDtoCopyWith(MlsJoinRequestDto value, $Res Function(MlsJoinRequestDto) _then) = _$MlsJoinRequestDtoCopyWithImpl;
@useResult
$Res call({
 String id, String contextId, String? channelId, String? conversationId, int generation, String requesterUserId, String requesterDeviceId, String keyPackageHash, String? keyPackage, String signatureKeyFingerprint,@JsonKey(unknownEnumValue: MlsJoinRequestState.pending) MlsJoinRequestState state, DateTime? createdAt, DateTime? expiresAt, int requiredApprovals, List<String> approverUserIds, bool requiresManualApproval, String? requesterDeviceName
});




}
/// @nodoc
class _$MlsJoinRequestDtoCopyWithImpl<$Res>
    implements $MlsJoinRequestDtoCopyWith<$Res> {
  _$MlsJoinRequestDtoCopyWithImpl(this._self, this._then);

  final MlsJoinRequestDto _self;
  final $Res Function(MlsJoinRequestDto) _then;

/// Create a copy of MlsJoinRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? contextId = null,Object? channelId = freezed,Object? conversationId = freezed,Object? generation = null,Object? requesterUserId = null,Object? requesterDeviceId = null,Object? keyPackageHash = null,Object? keyPackage = freezed,Object? signatureKeyFingerprint = null,Object? state = null,Object? createdAt = freezed,Object? expiresAt = freezed,Object? requiredApprovals = null,Object? approverUserIds = null,Object? requiresManualApproval = null,Object? requesterDeviceName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,contextId: null == contextId ? _self.contextId : contextId // ignore: cast_nullable_to_non_nullable
as String,channelId: freezed == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String?,conversationId: freezed == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String?,generation: null == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int,requesterUserId: null == requesterUserId ? _self.requesterUserId : requesterUserId // ignore: cast_nullable_to_non_nullable
as String,requesterDeviceId: null == requesterDeviceId ? _self.requesterDeviceId : requesterDeviceId // ignore: cast_nullable_to_non_nullable
as String,keyPackageHash: null == keyPackageHash ? _self.keyPackageHash : keyPackageHash // ignore: cast_nullable_to_non_nullable
as String,keyPackage: freezed == keyPackage ? _self.keyPackage : keyPackage // ignore: cast_nullable_to_non_nullable
as String?,signatureKeyFingerprint: null == signatureKeyFingerprint ? _self.signatureKeyFingerprint : signatureKeyFingerprint // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as MlsJoinRequestState,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,requiredApprovals: null == requiredApprovals ? _self.requiredApprovals : requiredApprovals // ignore: cast_nullable_to_non_nullable
as int,approverUserIds: null == approverUserIds ? _self.approverUserIds : approverUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,requiresManualApproval: null == requiresManualApproval ? _self.requiresManualApproval : requiresManualApproval // ignore: cast_nullable_to_non_nullable
as bool,requesterDeviceName: freezed == requesterDeviceName ? _self.requesterDeviceName : requesterDeviceName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MlsJoinRequestDto].
extension MlsJoinRequestDtoPatterns on MlsJoinRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MlsJoinRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MlsJoinRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MlsJoinRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _MlsJoinRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MlsJoinRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _MlsJoinRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String contextId,  String? channelId,  String? conversationId,  int generation,  String requesterUserId,  String requesterDeviceId,  String keyPackageHash,  String? keyPackage,  String signatureKeyFingerprint, @JsonKey(unknownEnumValue: MlsJoinRequestState.pending)  MlsJoinRequestState state,  DateTime? createdAt,  DateTime? expiresAt,  int requiredApprovals,  List<String> approverUserIds,  bool requiresManualApproval,  String? requesterDeviceName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MlsJoinRequestDto() when $default != null:
return $default(_that.id,_that.contextId,_that.channelId,_that.conversationId,_that.generation,_that.requesterUserId,_that.requesterDeviceId,_that.keyPackageHash,_that.keyPackage,_that.signatureKeyFingerprint,_that.state,_that.createdAt,_that.expiresAt,_that.requiredApprovals,_that.approverUserIds,_that.requiresManualApproval,_that.requesterDeviceName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String contextId,  String? channelId,  String? conversationId,  int generation,  String requesterUserId,  String requesterDeviceId,  String keyPackageHash,  String? keyPackage,  String signatureKeyFingerprint, @JsonKey(unknownEnumValue: MlsJoinRequestState.pending)  MlsJoinRequestState state,  DateTime? createdAt,  DateTime? expiresAt,  int requiredApprovals,  List<String> approverUserIds,  bool requiresManualApproval,  String? requesterDeviceName)  $default,) {final _that = this;
switch (_that) {
case _MlsJoinRequestDto():
return $default(_that.id,_that.contextId,_that.channelId,_that.conversationId,_that.generation,_that.requesterUserId,_that.requesterDeviceId,_that.keyPackageHash,_that.keyPackage,_that.signatureKeyFingerprint,_that.state,_that.createdAt,_that.expiresAt,_that.requiredApprovals,_that.approverUserIds,_that.requiresManualApproval,_that.requesterDeviceName);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String contextId,  String? channelId,  String? conversationId,  int generation,  String requesterUserId,  String requesterDeviceId,  String keyPackageHash,  String? keyPackage,  String signatureKeyFingerprint, @JsonKey(unknownEnumValue: MlsJoinRequestState.pending)  MlsJoinRequestState state,  DateTime? createdAt,  DateTime? expiresAt,  int requiredApprovals,  List<String> approverUserIds,  bool requiresManualApproval,  String? requesterDeviceName)?  $default,) {final _that = this;
switch (_that) {
case _MlsJoinRequestDto() when $default != null:
return $default(_that.id,_that.contextId,_that.channelId,_that.conversationId,_that.generation,_that.requesterUserId,_that.requesterDeviceId,_that.keyPackageHash,_that.keyPackage,_that.signatureKeyFingerprint,_that.state,_that.createdAt,_that.expiresAt,_that.requiredApprovals,_that.approverUserIds,_that.requiresManualApproval,_that.requesterDeviceName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _MlsJoinRequestDto implements MlsJoinRequestDto {
  const _MlsJoinRequestDto({required this.id, required this.contextId, this.channelId, this.conversationId, required this.generation, required this.requesterUserId, required this.requesterDeviceId, required this.keyPackageHash, this.keyPackage, required this.signatureKeyFingerprint, @JsonKey(unknownEnumValue: MlsJoinRequestState.pending) required this.state, this.createdAt, this.expiresAt, this.requiredApprovals = 0, final  List<String> approverUserIds = const <String>[], this.requiresManualApproval = false, this.requesterDeviceName}): _approverUserIds = approverUserIds;
  factory _MlsJoinRequestDto.fromJson(Map<String, dynamic> json) => _$MlsJoinRequestDtoFromJson(json);

@override final  String id;
@override final  String contextId;
@override final  String? channelId;
@override final  String? conversationId;
@override final  int generation;
@override final  String requesterUserId;
/// Admission is per device, not per user - each device holds its own leaf,
/// so a user's second device needs its own request.
@override final  String requesterDeviceId;
/// SHA-256 of the key package that would be added.
@override final  String keyPackageHash;
/// The exact key-package bytes, present only on requests belonging to the
/// **reading** account (contract §L.3 and `MlsJoinRequestService.cs:217`).
///
/// Null for a peer's request, which is correct and not a failure: a peer has
/// no use for the bytes until the approval threshold is met, and
/// [MlsJoinRequestApprovalResultDto.keyPackage] is where they arrive then.
///
/// Omitting this field is what made own-device admission unreachable. The
/// §G ceremony ends with *this* device minting an Add commit over these
/// bytes; with nowhere to put them the bridge passed an empty string into
/// `inspectKeyPackage`, which cannot parse and never could, so every
/// automatic admission failed at the last step with the proof already
/// verified.
@override final  String? keyPackage;
/// The requester's long-lived identity fingerprint, for out-of-band
/// comparison. Stable across all their key packages, which is what makes it
/// readable aloud - a key-package hash changes on every request.
@override final  String signatureKeyFingerprint;
@override@JsonKey(unknownEnumValue: MlsJoinRequestState.pending) final  MlsJoinRequestState state;
@override final  DateTime? createdAt;
@override final  DateTime? expiresAt;
@override@JsonKey() final  int requiredApprovals;
/// Who has already vouched. Lets a reviewer see they have approved, and see
/// who else did - a second opinion is only worth something if you can tell
/// whose it was.
 final  List<String> _approverUserIds;
/// Who has already vouched. Lets a reviewer see they have approved, and see
/// who else did - a second opinion is only worth something if you can tell
/// whose it was.
@override@JsonKey() List<String> get approverUserIds {
  if (_approverUserIds is EqualUnmodifiableListView) return _approverUserIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_approverUserIds);
}

/// The server's published verdict on whether this may be admitted without a
/// human (contract §J.4).
///
/// The server cannot *enforce* it - it holds no group keys, so only a
/// member's client can produce an Add commit or decline to. It decides the
/// 24h auto-admission budget and records how it was spent; honouring the
/// answer is entirely on this side.
@override@JsonKey() final  bool requiresManualApproval;
/// Display only, so an approval prompt can say "Alice's new phone" instead
/// of an opaque id. Nothing is authorized on it.
@override final  String? requesterDeviceName;

/// Create a copy of MlsJoinRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MlsJoinRequestDtoCopyWith<_MlsJoinRequestDto> get copyWith => __$MlsJoinRequestDtoCopyWithImpl<_MlsJoinRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MlsJoinRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MlsJoinRequestDto&&(identical(other.id, id) || other.id == id)&&(identical(other.contextId, contextId) || other.contextId == contextId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.generation, generation) || other.generation == generation)&&(identical(other.requesterUserId, requesterUserId) || other.requesterUserId == requesterUserId)&&(identical(other.requesterDeviceId, requesterDeviceId) || other.requesterDeviceId == requesterDeviceId)&&(identical(other.keyPackageHash, keyPackageHash) || other.keyPackageHash == keyPackageHash)&&(identical(other.keyPackage, keyPackage) || other.keyPackage == keyPackage)&&(identical(other.signatureKeyFingerprint, signatureKeyFingerprint) || other.signatureKeyFingerprint == signatureKeyFingerprint)&&(identical(other.state, state) || other.state == state)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.requiredApprovals, requiredApprovals) || other.requiredApprovals == requiredApprovals)&&const DeepCollectionEquality().equals(other._approverUserIds, _approverUserIds)&&(identical(other.requiresManualApproval, requiresManualApproval) || other.requiresManualApproval == requiresManualApproval)&&(identical(other.requesterDeviceName, requesterDeviceName) || other.requesterDeviceName == requesterDeviceName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,contextId,channelId,conversationId,generation,requesterUserId,requesterDeviceId,keyPackageHash,keyPackage,signatureKeyFingerprint,state,createdAt,expiresAt,requiredApprovals,const DeepCollectionEquality().hash(_approverUserIds),requiresManualApproval,requesterDeviceName);

@override
String toString() {
  return 'MlsJoinRequestDto(id: $id, contextId: $contextId, channelId: $channelId, conversationId: $conversationId, generation: $generation, requesterUserId: $requesterUserId, requesterDeviceId: $requesterDeviceId, keyPackageHash: $keyPackageHash, keyPackage: $keyPackage, signatureKeyFingerprint: $signatureKeyFingerprint, state: $state, createdAt: $createdAt, expiresAt: $expiresAt, requiredApprovals: $requiredApprovals, approverUserIds: $approverUserIds, requiresManualApproval: $requiresManualApproval, requesterDeviceName: $requesterDeviceName)';
}


}

/// @nodoc
abstract mixin class _$MlsJoinRequestDtoCopyWith<$Res> implements $MlsJoinRequestDtoCopyWith<$Res> {
  factory _$MlsJoinRequestDtoCopyWith(_MlsJoinRequestDto value, $Res Function(_MlsJoinRequestDto) _then) = __$MlsJoinRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String contextId, String? channelId, String? conversationId, int generation, String requesterUserId, String requesterDeviceId, String keyPackageHash, String? keyPackage, String signatureKeyFingerprint,@JsonKey(unknownEnumValue: MlsJoinRequestState.pending) MlsJoinRequestState state, DateTime? createdAt, DateTime? expiresAt, int requiredApprovals, List<String> approverUserIds, bool requiresManualApproval, String? requesterDeviceName
});




}
/// @nodoc
class __$MlsJoinRequestDtoCopyWithImpl<$Res>
    implements _$MlsJoinRequestDtoCopyWith<$Res> {
  __$MlsJoinRequestDtoCopyWithImpl(this._self, this._then);

  final _MlsJoinRequestDto _self;
  final $Res Function(_MlsJoinRequestDto) _then;

/// Create a copy of MlsJoinRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? contextId = null,Object? channelId = freezed,Object? conversationId = freezed,Object? generation = null,Object? requesterUserId = null,Object? requesterDeviceId = null,Object? keyPackageHash = null,Object? keyPackage = freezed,Object? signatureKeyFingerprint = null,Object? state = null,Object? createdAt = freezed,Object? expiresAt = freezed,Object? requiredApprovals = null,Object? approverUserIds = null,Object? requiresManualApproval = null,Object? requesterDeviceName = freezed,}) {
  return _then(_MlsJoinRequestDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,contextId: null == contextId ? _self.contextId : contextId // ignore: cast_nullable_to_non_nullable
as String,channelId: freezed == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String?,conversationId: freezed == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String?,generation: null == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int,requesterUserId: null == requesterUserId ? _self.requesterUserId : requesterUserId // ignore: cast_nullable_to_non_nullable
as String,requesterDeviceId: null == requesterDeviceId ? _self.requesterDeviceId : requesterDeviceId // ignore: cast_nullable_to_non_nullable
as String,keyPackageHash: null == keyPackageHash ? _self.keyPackageHash : keyPackageHash // ignore: cast_nullable_to_non_nullable
as String,keyPackage: freezed == keyPackage ? _self.keyPackage : keyPackage // ignore: cast_nullable_to_non_nullable
as String?,signatureKeyFingerprint: null == signatureKeyFingerprint ? _self.signatureKeyFingerprint : signatureKeyFingerprint // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as MlsJoinRequestState,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,requiredApprovals: null == requiredApprovals ? _self.requiredApprovals : requiredApprovals // ignore: cast_nullable_to_non_nullable
as int,approverUserIds: null == approverUserIds ? _self._approverUserIds : approverUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,requiresManualApproval: null == requiresManualApproval ? _self.requiresManualApproval : requiresManualApproval // ignore: cast_nullable_to_non_nullable
as bool,requesterDeviceName: freezed == requesterDeviceName ? _self.requesterDeviceName : requesterDeviceName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$MlsJoinRequestApprovalResultDto {

 String get requestId; int get approvals; int get requiredApprovals;/// True when this approval completed the threshold and the caller should now
/// mint the Add commit.
 bool get thresholdMet;/// The exact bytes to add. Present only once [thresholdMet].
 String? get keyPackage; String get keyPackageHash; int get generation;
/// Create a copy of MlsJoinRequestApprovalResultDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MlsJoinRequestApprovalResultDtoCopyWith<MlsJoinRequestApprovalResultDto> get copyWith => _$MlsJoinRequestApprovalResultDtoCopyWithImpl<MlsJoinRequestApprovalResultDto>(this as MlsJoinRequestApprovalResultDto, _$identity);

  /// Serializes this MlsJoinRequestApprovalResultDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MlsJoinRequestApprovalResultDto&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.approvals, approvals) || other.approvals == approvals)&&(identical(other.requiredApprovals, requiredApprovals) || other.requiredApprovals == requiredApprovals)&&(identical(other.thresholdMet, thresholdMet) || other.thresholdMet == thresholdMet)&&(identical(other.keyPackage, keyPackage) || other.keyPackage == keyPackage)&&(identical(other.keyPackageHash, keyPackageHash) || other.keyPackageHash == keyPackageHash)&&(identical(other.generation, generation) || other.generation == generation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,requestId,approvals,requiredApprovals,thresholdMet,keyPackage,keyPackageHash,generation);

@override
String toString() {
  return 'MlsJoinRequestApprovalResultDto(requestId: $requestId, approvals: $approvals, requiredApprovals: $requiredApprovals, thresholdMet: $thresholdMet, keyPackage: $keyPackage, keyPackageHash: $keyPackageHash, generation: $generation)';
}


}

/// @nodoc
abstract mixin class $MlsJoinRequestApprovalResultDtoCopyWith<$Res>  {
  factory $MlsJoinRequestApprovalResultDtoCopyWith(MlsJoinRequestApprovalResultDto value, $Res Function(MlsJoinRequestApprovalResultDto) _then) = _$MlsJoinRequestApprovalResultDtoCopyWithImpl;
@useResult
$Res call({
 String requestId, int approvals, int requiredApprovals, bool thresholdMet, String? keyPackage, String keyPackageHash, int generation
});




}
/// @nodoc
class _$MlsJoinRequestApprovalResultDtoCopyWithImpl<$Res>
    implements $MlsJoinRequestApprovalResultDtoCopyWith<$Res> {
  _$MlsJoinRequestApprovalResultDtoCopyWithImpl(this._self, this._then);

  final MlsJoinRequestApprovalResultDto _self;
  final $Res Function(MlsJoinRequestApprovalResultDto) _then;

/// Create a copy of MlsJoinRequestApprovalResultDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? requestId = null,Object? approvals = null,Object? requiredApprovals = null,Object? thresholdMet = null,Object? keyPackage = freezed,Object? keyPackageHash = null,Object? generation = null,}) {
  return _then(_self.copyWith(
requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,approvals: null == approvals ? _self.approvals : approvals // ignore: cast_nullable_to_non_nullable
as int,requiredApprovals: null == requiredApprovals ? _self.requiredApprovals : requiredApprovals // ignore: cast_nullable_to_non_nullable
as int,thresholdMet: null == thresholdMet ? _self.thresholdMet : thresholdMet // ignore: cast_nullable_to_non_nullable
as bool,keyPackage: freezed == keyPackage ? _self.keyPackage : keyPackage // ignore: cast_nullable_to_non_nullable
as String?,keyPackageHash: null == keyPackageHash ? _self.keyPackageHash : keyPackageHash // ignore: cast_nullable_to_non_nullable
as String,generation: null == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MlsJoinRequestApprovalResultDto].
extension MlsJoinRequestApprovalResultDtoPatterns on MlsJoinRequestApprovalResultDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MlsJoinRequestApprovalResultDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MlsJoinRequestApprovalResultDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MlsJoinRequestApprovalResultDto value)  $default,){
final _that = this;
switch (_that) {
case _MlsJoinRequestApprovalResultDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MlsJoinRequestApprovalResultDto value)?  $default,){
final _that = this;
switch (_that) {
case _MlsJoinRequestApprovalResultDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String requestId,  int approvals,  int requiredApprovals,  bool thresholdMet,  String? keyPackage,  String keyPackageHash,  int generation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MlsJoinRequestApprovalResultDto() when $default != null:
return $default(_that.requestId,_that.approvals,_that.requiredApprovals,_that.thresholdMet,_that.keyPackage,_that.keyPackageHash,_that.generation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String requestId,  int approvals,  int requiredApprovals,  bool thresholdMet,  String? keyPackage,  String keyPackageHash,  int generation)  $default,) {final _that = this;
switch (_that) {
case _MlsJoinRequestApprovalResultDto():
return $default(_that.requestId,_that.approvals,_that.requiredApprovals,_that.thresholdMet,_that.keyPackage,_that.keyPackageHash,_that.generation);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String requestId,  int approvals,  int requiredApprovals,  bool thresholdMet,  String? keyPackage,  String keyPackageHash,  int generation)?  $default,) {final _that = this;
switch (_that) {
case _MlsJoinRequestApprovalResultDto() when $default != null:
return $default(_that.requestId,_that.approvals,_that.requiredApprovals,_that.thresholdMet,_that.keyPackage,_that.keyPackageHash,_that.generation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MlsJoinRequestApprovalResultDto implements MlsJoinRequestApprovalResultDto {
  const _MlsJoinRequestApprovalResultDto({required this.requestId, this.approvals = 0, this.requiredApprovals = 0, this.thresholdMet = false, this.keyPackage, this.keyPackageHash = '', this.generation = 0});
  factory _MlsJoinRequestApprovalResultDto.fromJson(Map<String, dynamic> json) => _$MlsJoinRequestApprovalResultDtoFromJson(json);

@override final  String requestId;
@override@JsonKey() final  int approvals;
@override@JsonKey() final  int requiredApprovals;
/// True when this approval completed the threshold and the caller should now
/// mint the Add commit.
@override@JsonKey() final  bool thresholdMet;
/// The exact bytes to add. Present only once [thresholdMet].
@override final  String? keyPackage;
@override@JsonKey() final  String keyPackageHash;
@override@JsonKey() final  int generation;

/// Create a copy of MlsJoinRequestApprovalResultDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MlsJoinRequestApprovalResultDtoCopyWith<_MlsJoinRequestApprovalResultDto> get copyWith => __$MlsJoinRequestApprovalResultDtoCopyWithImpl<_MlsJoinRequestApprovalResultDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MlsJoinRequestApprovalResultDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MlsJoinRequestApprovalResultDto&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.approvals, approvals) || other.approvals == approvals)&&(identical(other.requiredApprovals, requiredApprovals) || other.requiredApprovals == requiredApprovals)&&(identical(other.thresholdMet, thresholdMet) || other.thresholdMet == thresholdMet)&&(identical(other.keyPackage, keyPackage) || other.keyPackage == keyPackage)&&(identical(other.keyPackageHash, keyPackageHash) || other.keyPackageHash == keyPackageHash)&&(identical(other.generation, generation) || other.generation == generation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,requestId,approvals,requiredApprovals,thresholdMet,keyPackage,keyPackageHash,generation);

@override
String toString() {
  return 'MlsJoinRequestApprovalResultDto(requestId: $requestId, approvals: $approvals, requiredApprovals: $requiredApprovals, thresholdMet: $thresholdMet, keyPackage: $keyPackage, keyPackageHash: $keyPackageHash, generation: $generation)';
}


}

/// @nodoc
abstract mixin class _$MlsJoinRequestApprovalResultDtoCopyWith<$Res> implements $MlsJoinRequestApprovalResultDtoCopyWith<$Res> {
  factory _$MlsJoinRequestApprovalResultDtoCopyWith(_MlsJoinRequestApprovalResultDto value, $Res Function(_MlsJoinRequestApprovalResultDto) _then) = __$MlsJoinRequestApprovalResultDtoCopyWithImpl;
@override @useResult
$Res call({
 String requestId, int approvals, int requiredApprovals, bool thresholdMet, String? keyPackage, String keyPackageHash, int generation
});




}
/// @nodoc
class __$MlsJoinRequestApprovalResultDtoCopyWithImpl<$Res>
    implements _$MlsJoinRequestApprovalResultDtoCopyWith<$Res> {
  __$MlsJoinRequestApprovalResultDtoCopyWithImpl(this._self, this._then);

  final _MlsJoinRequestApprovalResultDto _self;
  final $Res Function(_MlsJoinRequestApprovalResultDto) _then;

/// Create a copy of MlsJoinRequestApprovalResultDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? requestId = null,Object? approvals = null,Object? requiredApprovals = null,Object? thresholdMet = null,Object? keyPackage = freezed,Object? keyPackageHash = null,Object? generation = null,}) {
  return _then(_MlsJoinRequestApprovalResultDto(
requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,approvals: null == approvals ? _self.approvals : approvals // ignore: cast_nullable_to_non_nullable
as int,requiredApprovals: null == requiredApprovals ? _self.requiredApprovals : requiredApprovals // ignore: cast_nullable_to_non_nullable
as int,thresholdMet: null == thresholdMet ? _self.thresholdMet : thresholdMet // ignore: cast_nullable_to_non_nullable
as bool,keyPackage: freezed == keyPackage ? _self.keyPackage : keyPackage // ignore: cast_nullable_to_non_nullable
as String?,keyPackageHash: null == keyPackageHash ? _self.keyPackageHash : keyPackageHash // ignore: cast_nullable_to_non_nullable
as String,generation: null == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$GenerateKeyPackagesDto {

 int get count;/// True when the server holds no last-resort package for this device. That
/// package is the floor that keeps a device addable after its single-use
/// supply runs dry - without one it is silently left out of new groups.
 bool get needsLastResort;
/// Create a copy of GenerateKeyPackagesDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenerateKeyPackagesDtoCopyWith<GenerateKeyPackagesDto> get copyWith => _$GenerateKeyPackagesDtoCopyWithImpl<GenerateKeyPackagesDto>(this as GenerateKeyPackagesDto, _$identity);

  /// Serializes this GenerateKeyPackagesDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenerateKeyPackagesDto&&(identical(other.count, count) || other.count == count)&&(identical(other.needsLastResort, needsLastResort) || other.needsLastResort == needsLastResort));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count,needsLastResort);

@override
String toString() {
  return 'GenerateKeyPackagesDto(count: $count, needsLastResort: $needsLastResort)';
}


}

/// @nodoc
abstract mixin class $GenerateKeyPackagesDtoCopyWith<$Res>  {
  factory $GenerateKeyPackagesDtoCopyWith(GenerateKeyPackagesDto value, $Res Function(GenerateKeyPackagesDto) _then) = _$GenerateKeyPackagesDtoCopyWithImpl;
@useResult
$Res call({
 int count, bool needsLastResort
});




}
/// @nodoc
class _$GenerateKeyPackagesDtoCopyWithImpl<$Res>
    implements $GenerateKeyPackagesDtoCopyWith<$Res> {
  _$GenerateKeyPackagesDtoCopyWithImpl(this._self, this._then);

  final GenerateKeyPackagesDto _self;
  final $Res Function(GenerateKeyPackagesDto) _then;

/// Create a copy of GenerateKeyPackagesDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? count = null,Object? needsLastResort = null,}) {
  return _then(_self.copyWith(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,needsLastResort: null == needsLastResort ? _self.needsLastResort : needsLastResort // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [GenerateKeyPackagesDto].
extension GenerateKeyPackagesDtoPatterns on GenerateKeyPackagesDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GenerateKeyPackagesDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GenerateKeyPackagesDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GenerateKeyPackagesDto value)  $default,){
final _that = this;
switch (_that) {
case _GenerateKeyPackagesDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GenerateKeyPackagesDto value)?  $default,){
final _that = this;
switch (_that) {
case _GenerateKeyPackagesDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int count,  bool needsLastResort)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GenerateKeyPackagesDto() when $default != null:
return $default(_that.count,_that.needsLastResort);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int count,  bool needsLastResort)  $default,) {final _that = this;
switch (_that) {
case _GenerateKeyPackagesDto():
return $default(_that.count,_that.needsLastResort);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int count,  bool needsLastResort)?  $default,) {final _that = this;
switch (_that) {
case _GenerateKeyPackagesDto() when $default != null:
return $default(_that.count,_that.needsLastResort);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GenerateKeyPackagesDto implements GenerateKeyPackagesDto {
  const _GenerateKeyPackagesDto({this.count = 0, this.needsLastResort = false});
  factory _GenerateKeyPackagesDto.fromJson(Map<String, dynamic> json) => _$GenerateKeyPackagesDtoFromJson(json);

@override@JsonKey() final  int count;
/// True when the server holds no last-resort package for this device. That
/// package is the floor that keeps a device addable after its single-use
/// supply runs dry - without one it is silently left out of new groups.
@override@JsonKey() final  bool needsLastResort;

/// Create a copy of GenerateKeyPackagesDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GenerateKeyPackagesDtoCopyWith<_GenerateKeyPackagesDto> get copyWith => __$GenerateKeyPackagesDtoCopyWithImpl<_GenerateKeyPackagesDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GenerateKeyPackagesDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GenerateKeyPackagesDto&&(identical(other.count, count) || other.count == count)&&(identical(other.needsLastResort, needsLastResort) || other.needsLastResort == needsLastResort));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count,needsLastResort);

@override
String toString() {
  return 'GenerateKeyPackagesDto(count: $count, needsLastResort: $needsLastResort)';
}


}

/// @nodoc
abstract mixin class _$GenerateKeyPackagesDtoCopyWith<$Res> implements $GenerateKeyPackagesDtoCopyWith<$Res> {
  factory _$GenerateKeyPackagesDtoCopyWith(_GenerateKeyPackagesDto value, $Res Function(_GenerateKeyPackagesDto) _then) = __$GenerateKeyPackagesDtoCopyWithImpl;
@override @useResult
$Res call({
 int count, bool needsLastResort
});




}
/// @nodoc
class __$GenerateKeyPackagesDtoCopyWithImpl<$Res>
    implements _$GenerateKeyPackagesDtoCopyWith<$Res> {
  __$GenerateKeyPackagesDtoCopyWithImpl(this._self, this._then);

  final _GenerateKeyPackagesDto _self;
  final $Res Function(_GenerateKeyPackagesDto) _then;

/// Create a copy of GenerateKeyPackagesDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? count = null,Object? needsLastResort = null,}) {
  return _then(_GenerateKeyPackagesDto(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,needsLastResort: null == needsLastResort ? _self.needsLastResort : needsLastResort // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$MlsAdmissionChallengeDto {

 String get id; String get requestId;/// 32 random bytes, base64.
 String get challenge;/// Which device issued it - shown to the joiner so "your laptop is checking
/// this device" is something the user can recognise or not.
 String? get issuedByDeviceId; DateTime? get expiresAt;
/// Create a copy of MlsAdmissionChallengeDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MlsAdmissionChallengeDtoCopyWith<MlsAdmissionChallengeDto> get copyWith => _$MlsAdmissionChallengeDtoCopyWithImpl<MlsAdmissionChallengeDto>(this as MlsAdmissionChallengeDto, _$identity);

  /// Serializes this MlsAdmissionChallengeDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MlsAdmissionChallengeDto&&(identical(other.id, id) || other.id == id)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.challenge, challenge) || other.challenge == challenge)&&(identical(other.issuedByDeviceId, issuedByDeviceId) || other.issuedByDeviceId == issuedByDeviceId)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,requestId,challenge,issuedByDeviceId,expiresAt);

@override
String toString() {
  return 'MlsAdmissionChallengeDto(id: $id, requestId: $requestId, challenge: $challenge, issuedByDeviceId: $issuedByDeviceId, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $MlsAdmissionChallengeDtoCopyWith<$Res>  {
  factory $MlsAdmissionChallengeDtoCopyWith(MlsAdmissionChallengeDto value, $Res Function(MlsAdmissionChallengeDto) _then) = _$MlsAdmissionChallengeDtoCopyWithImpl;
@useResult
$Res call({
 String id, String requestId, String challenge, String? issuedByDeviceId, DateTime? expiresAt
});




}
/// @nodoc
class _$MlsAdmissionChallengeDtoCopyWithImpl<$Res>
    implements $MlsAdmissionChallengeDtoCopyWith<$Res> {
  _$MlsAdmissionChallengeDtoCopyWithImpl(this._self, this._then);

  final MlsAdmissionChallengeDto _self;
  final $Res Function(MlsAdmissionChallengeDto) _then;

/// Create a copy of MlsAdmissionChallengeDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? requestId = null,Object? challenge = null,Object? issuedByDeviceId = freezed,Object? expiresAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,challenge: null == challenge ? _self.challenge : challenge // ignore: cast_nullable_to_non_nullable
as String,issuedByDeviceId: freezed == issuedByDeviceId ? _self.issuedByDeviceId : issuedByDeviceId // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MlsAdmissionChallengeDto].
extension MlsAdmissionChallengeDtoPatterns on MlsAdmissionChallengeDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MlsAdmissionChallengeDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MlsAdmissionChallengeDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MlsAdmissionChallengeDto value)  $default,){
final _that = this;
switch (_that) {
case _MlsAdmissionChallengeDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MlsAdmissionChallengeDto value)?  $default,){
final _that = this;
switch (_that) {
case _MlsAdmissionChallengeDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String requestId,  String challenge,  String? issuedByDeviceId,  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MlsAdmissionChallengeDto() when $default != null:
return $default(_that.id,_that.requestId,_that.challenge,_that.issuedByDeviceId,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String requestId,  String challenge,  String? issuedByDeviceId,  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _MlsAdmissionChallengeDto():
return $default(_that.id,_that.requestId,_that.challenge,_that.issuedByDeviceId,_that.expiresAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String requestId,  String challenge,  String? issuedByDeviceId,  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _MlsAdmissionChallengeDto() when $default != null:
return $default(_that.id,_that.requestId,_that.challenge,_that.issuedByDeviceId,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _MlsAdmissionChallengeDto extends MlsAdmissionChallengeDto {
  const _MlsAdmissionChallengeDto({required this.id, required this.requestId, required this.challenge, this.issuedByDeviceId, this.expiresAt}): super._();
  factory _MlsAdmissionChallengeDto.fromJson(Map<String, dynamic> json) => _$MlsAdmissionChallengeDtoFromJson(json);

@override final  String id;
@override final  String requestId;
/// 32 random bytes, base64.
@override final  String challenge;
/// Which device issued it - shown to the joiner so "your laptop is checking
/// this device" is something the user can recognise or not.
@override final  String? issuedByDeviceId;
@override final  DateTime? expiresAt;

/// Create a copy of MlsAdmissionChallengeDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MlsAdmissionChallengeDtoCopyWith<_MlsAdmissionChallengeDto> get copyWith => __$MlsAdmissionChallengeDtoCopyWithImpl<_MlsAdmissionChallengeDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MlsAdmissionChallengeDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MlsAdmissionChallengeDto&&(identical(other.id, id) || other.id == id)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.challenge, challenge) || other.challenge == challenge)&&(identical(other.issuedByDeviceId, issuedByDeviceId) || other.issuedByDeviceId == issuedByDeviceId)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,requestId,challenge,issuedByDeviceId,expiresAt);

@override
String toString() {
  return 'MlsAdmissionChallengeDto(id: $id, requestId: $requestId, challenge: $challenge, issuedByDeviceId: $issuedByDeviceId, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$MlsAdmissionChallengeDtoCopyWith<$Res> implements $MlsAdmissionChallengeDtoCopyWith<$Res> {
  factory _$MlsAdmissionChallengeDtoCopyWith(_MlsAdmissionChallengeDto value, $Res Function(_MlsAdmissionChallengeDto) _then) = __$MlsAdmissionChallengeDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String requestId, String challenge, String? issuedByDeviceId, DateTime? expiresAt
});




}
/// @nodoc
class __$MlsAdmissionChallengeDtoCopyWithImpl<$Res>
    implements _$MlsAdmissionChallengeDtoCopyWith<$Res> {
  __$MlsAdmissionChallengeDtoCopyWithImpl(this._self, this._then);

  final _MlsAdmissionChallengeDto _self;
  final $Res Function(_MlsAdmissionChallengeDto) _then;

/// Create a copy of MlsAdmissionChallengeDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? requestId = null,Object? challenge = null,Object? issuedByDeviceId = freezed,Object? expiresAt = freezed,}) {
  return _then(_MlsAdmissionChallengeDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,challenge: null == challenge ? _self.challenge : challenge // ignore: cast_nullable_to_non_nullable
as String,issuedByDeviceId: freezed == issuedByDeviceId ? _self.issuedByDeviceId : issuedByDeviceId // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$MlsAdmissionProofDto {

 String get challengeId; String get requestId;/// HMAC over `challenge || requesterDeviceId || signatureKeyFingerprint`,
/// keyed by HKDF of the account master key. Base64.
 String get proof;
/// Create a copy of MlsAdmissionProofDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MlsAdmissionProofDtoCopyWith<MlsAdmissionProofDto> get copyWith => _$MlsAdmissionProofDtoCopyWithImpl<MlsAdmissionProofDto>(this as MlsAdmissionProofDto, _$identity);

  /// Serializes this MlsAdmissionProofDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MlsAdmissionProofDto&&(identical(other.challengeId, challengeId) || other.challengeId == challengeId)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.proof, proof) || other.proof == proof));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,challengeId,requestId,proof);

@override
String toString() {
  return 'MlsAdmissionProofDto(challengeId: $challengeId, requestId: $requestId, proof: $proof)';
}


}

/// @nodoc
abstract mixin class $MlsAdmissionProofDtoCopyWith<$Res>  {
  factory $MlsAdmissionProofDtoCopyWith(MlsAdmissionProofDto value, $Res Function(MlsAdmissionProofDto) _then) = _$MlsAdmissionProofDtoCopyWithImpl;
@useResult
$Res call({
 String challengeId, String requestId, String proof
});




}
/// @nodoc
class _$MlsAdmissionProofDtoCopyWithImpl<$Res>
    implements $MlsAdmissionProofDtoCopyWith<$Res> {
  _$MlsAdmissionProofDtoCopyWithImpl(this._self, this._then);

  final MlsAdmissionProofDto _self;
  final $Res Function(MlsAdmissionProofDto) _then;

/// Create a copy of MlsAdmissionProofDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? challengeId = null,Object? requestId = null,Object? proof = null,}) {
  return _then(_self.copyWith(
challengeId: null == challengeId ? _self.challengeId : challengeId // ignore: cast_nullable_to_non_nullable
as String,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,proof: null == proof ? _self.proof : proof // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MlsAdmissionProofDto].
extension MlsAdmissionProofDtoPatterns on MlsAdmissionProofDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MlsAdmissionProofDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MlsAdmissionProofDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MlsAdmissionProofDto value)  $default,){
final _that = this;
switch (_that) {
case _MlsAdmissionProofDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MlsAdmissionProofDto value)?  $default,){
final _that = this;
switch (_that) {
case _MlsAdmissionProofDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String challengeId,  String requestId,  String proof)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MlsAdmissionProofDto() when $default != null:
return $default(_that.challengeId,_that.requestId,_that.proof);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String challengeId,  String requestId,  String proof)  $default,) {final _that = this;
switch (_that) {
case _MlsAdmissionProofDto():
return $default(_that.challengeId,_that.requestId,_that.proof);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String challengeId,  String requestId,  String proof)?  $default,) {final _that = this;
switch (_that) {
case _MlsAdmissionProofDto() when $default != null:
return $default(_that.challengeId,_that.requestId,_that.proof);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MlsAdmissionProofDto implements MlsAdmissionProofDto {
  const _MlsAdmissionProofDto({required this.challengeId, required this.requestId, required this.proof});
  factory _MlsAdmissionProofDto.fromJson(Map<String, dynamic> json) => _$MlsAdmissionProofDtoFromJson(json);

@override final  String challengeId;
@override final  String requestId;
/// HMAC over `challenge || requesterDeviceId || signatureKeyFingerprint`,
/// keyed by HKDF of the account master key. Base64.
@override final  String proof;

/// Create a copy of MlsAdmissionProofDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MlsAdmissionProofDtoCopyWith<_MlsAdmissionProofDto> get copyWith => __$MlsAdmissionProofDtoCopyWithImpl<_MlsAdmissionProofDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MlsAdmissionProofDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MlsAdmissionProofDto&&(identical(other.challengeId, challengeId) || other.challengeId == challengeId)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.proof, proof) || other.proof == proof));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,challengeId,requestId,proof);

@override
String toString() {
  return 'MlsAdmissionProofDto(challengeId: $challengeId, requestId: $requestId, proof: $proof)';
}


}

/// @nodoc
abstract mixin class _$MlsAdmissionProofDtoCopyWith<$Res> implements $MlsAdmissionProofDtoCopyWith<$Res> {
  factory _$MlsAdmissionProofDtoCopyWith(_MlsAdmissionProofDto value, $Res Function(_MlsAdmissionProofDto) _then) = __$MlsAdmissionProofDtoCopyWithImpl;
@override @useResult
$Res call({
 String challengeId, String requestId, String proof
});




}
/// @nodoc
class __$MlsAdmissionProofDtoCopyWithImpl<$Res>
    implements _$MlsAdmissionProofDtoCopyWith<$Res> {
  __$MlsAdmissionProofDtoCopyWithImpl(this._self, this._then);

  final _MlsAdmissionProofDto _self;
  final $Res Function(_MlsAdmissionProofDto) _then;

/// Create a copy of MlsAdmissionProofDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? challengeId = null,Object? requestId = null,Object? proof = null,}) {
  return _then(_MlsAdmissionProofDto(
challengeId: null == challengeId ? _self.challengeId : challengeId // ignore: cast_nullable_to_non_nullable
as String,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,proof: null == proof ? _self.proof : proof // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
