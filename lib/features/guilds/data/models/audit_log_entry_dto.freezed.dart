// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audit_log_entry_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuditLogEntryDto {

 String get id; String get guildId; String get actorUserId;@JsonKey(unknownEnumValue: AuditActionType.unknown) AuditActionType get actionType; String? get targetId;/// Raw JSON string, shape varies per [actionType] - parsed defensively.
 String? get metadata; DateTime? get createdAt;
/// Create a copy of AuditLogEntryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuditLogEntryDtoCopyWith<AuditLogEntryDto> get copyWith => _$AuditLogEntryDtoCopyWithImpl<AuditLogEntryDto>(this as AuditLogEntryDto, _$identity);

  /// Serializes this AuditLogEntryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuditLogEntryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.actorUserId, actorUserId) || other.actorUserId == actorUserId)&&(identical(other.actionType, actionType) || other.actionType == actionType)&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,guildId,actorUserId,actionType,targetId,metadata,createdAt);

@override
String toString() {
  return 'AuditLogEntryDto(id: $id, guildId: $guildId, actorUserId: $actorUserId, actionType: $actionType, targetId: $targetId, metadata: $metadata, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AuditLogEntryDtoCopyWith<$Res>  {
  factory $AuditLogEntryDtoCopyWith(AuditLogEntryDto value, $Res Function(AuditLogEntryDto) _then) = _$AuditLogEntryDtoCopyWithImpl;
@useResult
$Res call({
 String id, String guildId, String actorUserId,@JsonKey(unknownEnumValue: AuditActionType.unknown) AuditActionType actionType, String? targetId, String? metadata, DateTime? createdAt
});




}
/// @nodoc
class _$AuditLogEntryDtoCopyWithImpl<$Res>
    implements $AuditLogEntryDtoCopyWith<$Res> {
  _$AuditLogEntryDtoCopyWithImpl(this._self, this._then);

  final AuditLogEntryDto _self;
  final $Res Function(AuditLogEntryDto) _then;

/// Create a copy of AuditLogEntryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? guildId = null,Object? actorUserId = null,Object? actionType = null,Object? targetId = freezed,Object? metadata = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,actorUserId: null == actorUserId ? _self.actorUserId : actorUserId // ignore: cast_nullable_to_non_nullable
as String,actionType: null == actionType ? _self.actionType : actionType // ignore: cast_nullable_to_non_nullable
as AuditActionType,targetId: freezed == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AuditLogEntryDto].
extension AuditLogEntryDtoPatterns on AuditLogEntryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuditLogEntryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuditLogEntryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuditLogEntryDto value)  $default,){
final _that = this;
switch (_that) {
case _AuditLogEntryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuditLogEntryDto value)?  $default,){
final _that = this;
switch (_that) {
case _AuditLogEntryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String guildId,  String actorUserId, @JsonKey(unknownEnumValue: AuditActionType.unknown)  AuditActionType actionType,  String? targetId,  String? metadata,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuditLogEntryDto() when $default != null:
return $default(_that.id,_that.guildId,_that.actorUserId,_that.actionType,_that.targetId,_that.metadata,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String guildId,  String actorUserId, @JsonKey(unknownEnumValue: AuditActionType.unknown)  AuditActionType actionType,  String? targetId,  String? metadata,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _AuditLogEntryDto():
return $default(_that.id,_that.guildId,_that.actorUserId,_that.actionType,_that.targetId,_that.metadata,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String guildId,  String actorUserId, @JsonKey(unknownEnumValue: AuditActionType.unknown)  AuditActionType actionType,  String? targetId,  String? metadata,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AuditLogEntryDto() when $default != null:
return $default(_that.id,_that.guildId,_that.actorUserId,_that.actionType,_that.targetId,_that.metadata,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuditLogEntryDto implements AuditLogEntryDto {
  const _AuditLogEntryDto({required this.id, required this.guildId, required this.actorUserId, @JsonKey(unknownEnumValue: AuditActionType.unknown) required this.actionType, this.targetId, this.metadata, this.createdAt});
  factory _AuditLogEntryDto.fromJson(Map<String, dynamic> json) => _$AuditLogEntryDtoFromJson(json);

@override final  String id;
@override final  String guildId;
@override final  String actorUserId;
@override@JsonKey(unknownEnumValue: AuditActionType.unknown) final  AuditActionType actionType;
@override final  String? targetId;
/// Raw JSON string, shape varies per [actionType] - parsed defensively.
@override final  String? metadata;
@override final  DateTime? createdAt;

/// Create a copy of AuditLogEntryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuditLogEntryDtoCopyWith<_AuditLogEntryDto> get copyWith => __$AuditLogEntryDtoCopyWithImpl<_AuditLogEntryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuditLogEntryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuditLogEntryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.actorUserId, actorUserId) || other.actorUserId == actorUserId)&&(identical(other.actionType, actionType) || other.actionType == actionType)&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,guildId,actorUserId,actionType,targetId,metadata,createdAt);

@override
String toString() {
  return 'AuditLogEntryDto(id: $id, guildId: $guildId, actorUserId: $actorUserId, actionType: $actionType, targetId: $targetId, metadata: $metadata, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AuditLogEntryDtoCopyWith<$Res> implements $AuditLogEntryDtoCopyWith<$Res> {
  factory _$AuditLogEntryDtoCopyWith(_AuditLogEntryDto value, $Res Function(_AuditLogEntryDto) _then) = __$AuditLogEntryDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String guildId, String actorUserId,@JsonKey(unknownEnumValue: AuditActionType.unknown) AuditActionType actionType, String? targetId, String? metadata, DateTime? createdAt
});




}
/// @nodoc
class __$AuditLogEntryDtoCopyWithImpl<$Res>
    implements _$AuditLogEntryDtoCopyWith<$Res> {
  __$AuditLogEntryDtoCopyWithImpl(this._self, this._then);

  final _AuditLogEntryDto _self;
  final $Res Function(_AuditLogEntryDto) _then;

/// Create a copy of AuditLogEntryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? guildId = null,Object? actorUserId = null,Object? actionType = null,Object? targetId = freezed,Object? metadata = freezed,Object? createdAt = freezed,}) {
  return _then(_AuditLogEntryDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,actorUserId: null == actorUserId ? _self.actorUserId : actorUserId // ignore: cast_nullable_to_non_nullable
as String,actionType: null == actionType ? _self.actionType : actionType // ignore: cast_nullable_to_non_nullable
as AuditActionType,targetId: freezed == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
