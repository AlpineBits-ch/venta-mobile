// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chore_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChoreDto {

 String get id; String get channelId; String get title; String? get description;/// 1-365. The cadence steps from [anchorAt].
 int get intervalDays; DateTime? get anchorAt;/// 1-600. The fairness weight - taking the bins out doesn't count the
/// same as cleaning the bathroom.
 int get effortMinutes;/// The rotation pool is just this role's membership, so adding someone to
/// the rota means giving them the role.
 String? get rotationRoleId; String? get fixedAssigneeUserId;/// How long past [ChoreOccurrenceDto.dueAt] before it counts as overdue.
 int get graceHours; bool get isPaused; DateTime? get nextDueAt;
/// Create a copy of ChoreDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChoreDtoCopyWith<ChoreDto> get copyWith => _$ChoreDtoCopyWithImpl<ChoreDto>(this as ChoreDto, _$identity);

  /// Serializes this ChoreDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChoreDto&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.intervalDays, intervalDays) || other.intervalDays == intervalDays)&&(identical(other.anchorAt, anchorAt) || other.anchorAt == anchorAt)&&(identical(other.effortMinutes, effortMinutes) || other.effortMinutes == effortMinutes)&&(identical(other.rotationRoleId, rotationRoleId) || other.rotationRoleId == rotationRoleId)&&(identical(other.fixedAssigneeUserId, fixedAssigneeUserId) || other.fixedAssigneeUserId == fixedAssigneeUserId)&&(identical(other.graceHours, graceHours) || other.graceHours == graceHours)&&(identical(other.isPaused, isPaused) || other.isPaused == isPaused)&&(identical(other.nextDueAt, nextDueAt) || other.nextDueAt == nextDueAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,title,description,intervalDays,anchorAt,effortMinutes,rotationRoleId,fixedAssigneeUserId,graceHours,isPaused,nextDueAt);

@override
String toString() {
  return 'ChoreDto(id: $id, channelId: $channelId, title: $title, description: $description, intervalDays: $intervalDays, anchorAt: $anchorAt, effortMinutes: $effortMinutes, rotationRoleId: $rotationRoleId, fixedAssigneeUserId: $fixedAssigneeUserId, graceHours: $graceHours, isPaused: $isPaused, nextDueAt: $nextDueAt)';
}


}

/// @nodoc
abstract mixin class $ChoreDtoCopyWith<$Res>  {
  factory $ChoreDtoCopyWith(ChoreDto value, $Res Function(ChoreDto) _then) = _$ChoreDtoCopyWithImpl;
@useResult
$Res call({
 String id, String channelId, String title, String? description, int intervalDays, DateTime? anchorAt, int effortMinutes, String? rotationRoleId, String? fixedAssigneeUserId, int graceHours, bool isPaused, DateTime? nextDueAt
});




}
/// @nodoc
class _$ChoreDtoCopyWithImpl<$Res>
    implements $ChoreDtoCopyWith<$Res> {
  _$ChoreDtoCopyWithImpl(this._self, this._then);

  final ChoreDto _self;
  final $Res Function(ChoreDto) _then;

/// Create a copy of ChoreDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? channelId = null,Object? title = null,Object? description = freezed,Object? intervalDays = null,Object? anchorAt = freezed,Object? effortMinutes = null,Object? rotationRoleId = freezed,Object? fixedAssigneeUserId = freezed,Object? graceHours = null,Object? isPaused = null,Object? nextDueAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,intervalDays: null == intervalDays ? _self.intervalDays : intervalDays // ignore: cast_nullable_to_non_nullable
as int,anchorAt: freezed == anchorAt ? _self.anchorAt : anchorAt // ignore: cast_nullable_to_non_nullable
as DateTime?,effortMinutes: null == effortMinutes ? _self.effortMinutes : effortMinutes // ignore: cast_nullable_to_non_nullable
as int,rotationRoleId: freezed == rotationRoleId ? _self.rotationRoleId : rotationRoleId // ignore: cast_nullable_to_non_nullable
as String?,fixedAssigneeUserId: freezed == fixedAssigneeUserId ? _self.fixedAssigneeUserId : fixedAssigneeUserId // ignore: cast_nullable_to_non_nullable
as String?,graceHours: null == graceHours ? _self.graceHours : graceHours // ignore: cast_nullable_to_non_nullable
as int,isPaused: null == isPaused ? _self.isPaused : isPaused // ignore: cast_nullable_to_non_nullable
as bool,nextDueAt: freezed == nextDueAt ? _self.nextDueAt : nextDueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChoreDto].
extension ChoreDtoPatterns on ChoreDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChoreDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChoreDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChoreDto value)  $default,){
final _that = this;
switch (_that) {
case _ChoreDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChoreDto value)?  $default,){
final _that = this;
switch (_that) {
case _ChoreDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String channelId,  String title,  String? description,  int intervalDays,  DateTime? anchorAt,  int effortMinutes,  String? rotationRoleId,  String? fixedAssigneeUserId,  int graceHours,  bool isPaused,  DateTime? nextDueAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChoreDto() when $default != null:
return $default(_that.id,_that.channelId,_that.title,_that.description,_that.intervalDays,_that.anchorAt,_that.effortMinutes,_that.rotationRoleId,_that.fixedAssigneeUserId,_that.graceHours,_that.isPaused,_that.nextDueAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String channelId,  String title,  String? description,  int intervalDays,  DateTime? anchorAt,  int effortMinutes,  String? rotationRoleId,  String? fixedAssigneeUserId,  int graceHours,  bool isPaused,  DateTime? nextDueAt)  $default,) {final _that = this;
switch (_that) {
case _ChoreDto():
return $default(_that.id,_that.channelId,_that.title,_that.description,_that.intervalDays,_that.anchorAt,_that.effortMinutes,_that.rotationRoleId,_that.fixedAssigneeUserId,_that.graceHours,_that.isPaused,_that.nextDueAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String channelId,  String title,  String? description,  int intervalDays,  DateTime? anchorAt,  int effortMinutes,  String? rotationRoleId,  String? fixedAssigneeUserId,  int graceHours,  bool isPaused,  DateTime? nextDueAt)?  $default,) {final _that = this;
switch (_that) {
case _ChoreDto() when $default != null:
return $default(_that.id,_that.channelId,_that.title,_that.description,_that.intervalDays,_that.anchorAt,_that.effortMinutes,_that.rotationRoleId,_that.fixedAssigneeUserId,_that.graceHours,_that.isPaused,_that.nextDueAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChoreDto implements ChoreDto {
  const _ChoreDto({required this.id, required this.channelId, required this.title, this.description, this.intervalDays = 7, this.anchorAt, this.effortMinutes = 15, this.rotationRoleId, this.fixedAssigneeUserId, this.graceHours = 0, this.isPaused = false, this.nextDueAt});
  factory _ChoreDto.fromJson(Map<String, dynamic> json) => _$ChoreDtoFromJson(json);

@override final  String id;
@override final  String channelId;
@override final  String title;
@override final  String? description;
/// 1-365. The cadence steps from [anchorAt].
@override@JsonKey() final  int intervalDays;
@override final  DateTime? anchorAt;
/// 1-600. The fairness weight - taking the bins out doesn't count the
/// same as cleaning the bathroom.
@override@JsonKey() final  int effortMinutes;
/// The rotation pool is just this role's membership, so adding someone to
/// the rota means giving them the role.
@override final  String? rotationRoleId;
@override final  String? fixedAssigneeUserId;
/// How long past [ChoreOccurrenceDto.dueAt] before it counts as overdue.
@override@JsonKey() final  int graceHours;
@override@JsonKey() final  bool isPaused;
@override final  DateTime? nextDueAt;

/// Create a copy of ChoreDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChoreDtoCopyWith<_ChoreDto> get copyWith => __$ChoreDtoCopyWithImpl<_ChoreDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChoreDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChoreDto&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.intervalDays, intervalDays) || other.intervalDays == intervalDays)&&(identical(other.anchorAt, anchorAt) || other.anchorAt == anchorAt)&&(identical(other.effortMinutes, effortMinutes) || other.effortMinutes == effortMinutes)&&(identical(other.rotationRoleId, rotationRoleId) || other.rotationRoleId == rotationRoleId)&&(identical(other.fixedAssigneeUserId, fixedAssigneeUserId) || other.fixedAssigneeUserId == fixedAssigneeUserId)&&(identical(other.graceHours, graceHours) || other.graceHours == graceHours)&&(identical(other.isPaused, isPaused) || other.isPaused == isPaused)&&(identical(other.nextDueAt, nextDueAt) || other.nextDueAt == nextDueAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,title,description,intervalDays,anchorAt,effortMinutes,rotationRoleId,fixedAssigneeUserId,graceHours,isPaused,nextDueAt);

@override
String toString() {
  return 'ChoreDto(id: $id, channelId: $channelId, title: $title, description: $description, intervalDays: $intervalDays, anchorAt: $anchorAt, effortMinutes: $effortMinutes, rotationRoleId: $rotationRoleId, fixedAssigneeUserId: $fixedAssigneeUserId, graceHours: $graceHours, isPaused: $isPaused, nextDueAt: $nextDueAt)';
}


}

/// @nodoc
abstract mixin class _$ChoreDtoCopyWith<$Res> implements $ChoreDtoCopyWith<$Res> {
  factory _$ChoreDtoCopyWith(_ChoreDto value, $Res Function(_ChoreDto) _then) = __$ChoreDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String channelId, String title, String? description, int intervalDays, DateTime? anchorAt, int effortMinutes, String? rotationRoleId, String? fixedAssigneeUserId, int graceHours, bool isPaused, DateTime? nextDueAt
});




}
/// @nodoc
class __$ChoreDtoCopyWithImpl<$Res>
    implements _$ChoreDtoCopyWith<$Res> {
  __$ChoreDtoCopyWithImpl(this._self, this._then);

  final _ChoreDto _self;
  final $Res Function(_ChoreDto) _then;

/// Create a copy of ChoreDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? channelId = null,Object? title = null,Object? description = freezed,Object? intervalDays = null,Object? anchorAt = freezed,Object? effortMinutes = null,Object? rotationRoleId = freezed,Object? fixedAssigneeUserId = freezed,Object? graceHours = null,Object? isPaused = null,Object? nextDueAt = freezed,}) {
  return _then(_ChoreDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,intervalDays: null == intervalDays ? _self.intervalDays : intervalDays // ignore: cast_nullable_to_non_nullable
as int,anchorAt: freezed == anchorAt ? _self.anchorAt : anchorAt // ignore: cast_nullable_to_non_nullable
as DateTime?,effortMinutes: null == effortMinutes ? _self.effortMinutes : effortMinutes // ignore: cast_nullable_to_non_nullable
as int,rotationRoleId: freezed == rotationRoleId ? _self.rotationRoleId : rotationRoleId // ignore: cast_nullable_to_non_nullable
as String?,fixedAssigneeUserId: freezed == fixedAssigneeUserId ? _self.fixedAssigneeUserId : fixedAssigneeUserId // ignore: cast_nullable_to_non_nullable
as String?,graceHours: null == graceHours ? _self.graceHours : graceHours // ignore: cast_nullable_to_non_nullable
as int,isPaused: null == isPaused ? _self.isPaused : isPaused // ignore: cast_nullable_to_non_nullable
as bool,nextDueAt: freezed == nextDueAt ? _self.nextDueAt : nextDueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ChoreOccurrenceDto {

 String get id; String get choreId; String get channelId;/// Denormalized off the chore so a board can render without joining.
 String get title; DateTime get dueAt; String get assignedUserId;/// Snapshot at generation time - editing the chore's weight doesn't
/// retroactively repay past turns.
 int get effortMinutes; DateTime? get completedAt; String? get completedByUserId; DateTime? get skippedAt; bool get isOverdue;
/// Create a copy of ChoreOccurrenceDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChoreOccurrenceDtoCopyWith<ChoreOccurrenceDto> get copyWith => _$ChoreOccurrenceDtoCopyWithImpl<ChoreOccurrenceDto>(this as ChoreOccurrenceDto, _$identity);

  /// Serializes this ChoreOccurrenceDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChoreOccurrenceDto&&(identical(other.id, id) || other.id == id)&&(identical(other.choreId, choreId) || other.choreId == choreId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.title, title) || other.title == title)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.assignedUserId, assignedUserId) || other.assignedUserId == assignedUserId)&&(identical(other.effortMinutes, effortMinutes) || other.effortMinutes == effortMinutes)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.completedByUserId, completedByUserId) || other.completedByUserId == completedByUserId)&&(identical(other.skippedAt, skippedAt) || other.skippedAt == skippedAt)&&(identical(other.isOverdue, isOverdue) || other.isOverdue == isOverdue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,choreId,channelId,title,dueAt,assignedUserId,effortMinutes,completedAt,completedByUserId,skippedAt,isOverdue);

@override
String toString() {
  return 'ChoreOccurrenceDto(id: $id, choreId: $choreId, channelId: $channelId, title: $title, dueAt: $dueAt, assignedUserId: $assignedUserId, effortMinutes: $effortMinutes, completedAt: $completedAt, completedByUserId: $completedByUserId, skippedAt: $skippedAt, isOverdue: $isOverdue)';
}


}

/// @nodoc
abstract mixin class $ChoreOccurrenceDtoCopyWith<$Res>  {
  factory $ChoreOccurrenceDtoCopyWith(ChoreOccurrenceDto value, $Res Function(ChoreOccurrenceDto) _then) = _$ChoreOccurrenceDtoCopyWithImpl;
@useResult
$Res call({
 String id, String choreId, String channelId, String title, DateTime dueAt, String assignedUserId, int effortMinutes, DateTime? completedAt, String? completedByUserId, DateTime? skippedAt, bool isOverdue
});




}
/// @nodoc
class _$ChoreOccurrenceDtoCopyWithImpl<$Res>
    implements $ChoreOccurrenceDtoCopyWith<$Res> {
  _$ChoreOccurrenceDtoCopyWithImpl(this._self, this._then);

  final ChoreOccurrenceDto _self;
  final $Res Function(ChoreOccurrenceDto) _then;

/// Create a copy of ChoreOccurrenceDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? choreId = null,Object? channelId = null,Object? title = null,Object? dueAt = null,Object? assignedUserId = null,Object? effortMinutes = null,Object? completedAt = freezed,Object? completedByUserId = freezed,Object? skippedAt = freezed,Object? isOverdue = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,choreId: null == choreId ? _self.choreId : choreId // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,dueAt: null == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime,assignedUserId: null == assignedUserId ? _self.assignedUserId : assignedUserId // ignore: cast_nullable_to_non_nullable
as String,effortMinutes: null == effortMinutes ? _self.effortMinutes : effortMinutes // ignore: cast_nullable_to_non_nullable
as int,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedByUserId: freezed == completedByUserId ? _self.completedByUserId : completedByUserId // ignore: cast_nullable_to_non_nullable
as String?,skippedAt: freezed == skippedAt ? _self.skippedAt : skippedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isOverdue: null == isOverdue ? _self.isOverdue : isOverdue // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ChoreOccurrenceDto].
extension ChoreOccurrenceDtoPatterns on ChoreOccurrenceDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChoreOccurrenceDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChoreOccurrenceDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChoreOccurrenceDto value)  $default,){
final _that = this;
switch (_that) {
case _ChoreOccurrenceDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChoreOccurrenceDto value)?  $default,){
final _that = this;
switch (_that) {
case _ChoreOccurrenceDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String choreId,  String channelId,  String title,  DateTime dueAt,  String assignedUserId,  int effortMinutes,  DateTime? completedAt,  String? completedByUserId,  DateTime? skippedAt,  bool isOverdue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChoreOccurrenceDto() when $default != null:
return $default(_that.id,_that.choreId,_that.channelId,_that.title,_that.dueAt,_that.assignedUserId,_that.effortMinutes,_that.completedAt,_that.completedByUserId,_that.skippedAt,_that.isOverdue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String choreId,  String channelId,  String title,  DateTime dueAt,  String assignedUserId,  int effortMinutes,  DateTime? completedAt,  String? completedByUserId,  DateTime? skippedAt,  bool isOverdue)  $default,) {final _that = this;
switch (_that) {
case _ChoreOccurrenceDto():
return $default(_that.id,_that.choreId,_that.channelId,_that.title,_that.dueAt,_that.assignedUserId,_that.effortMinutes,_that.completedAt,_that.completedByUserId,_that.skippedAt,_that.isOverdue);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String choreId,  String channelId,  String title,  DateTime dueAt,  String assignedUserId,  int effortMinutes,  DateTime? completedAt,  String? completedByUserId,  DateTime? skippedAt,  bool isOverdue)?  $default,) {final _that = this;
switch (_that) {
case _ChoreOccurrenceDto() when $default != null:
return $default(_that.id,_that.choreId,_that.channelId,_that.title,_that.dueAt,_that.assignedUserId,_that.effortMinutes,_that.completedAt,_that.completedByUserId,_that.skippedAt,_that.isOverdue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChoreOccurrenceDto implements ChoreOccurrenceDto {
  const _ChoreOccurrenceDto({required this.id, required this.choreId, required this.channelId, this.title = '', required this.dueAt, this.assignedUserId = '', this.effortMinutes = 0, this.completedAt, this.completedByUserId, this.skippedAt, this.isOverdue = false});
  factory _ChoreOccurrenceDto.fromJson(Map<String, dynamic> json) => _$ChoreOccurrenceDtoFromJson(json);

@override final  String id;
@override final  String choreId;
@override final  String channelId;
/// Denormalized off the chore so a board can render without joining.
@override@JsonKey() final  String title;
@override final  DateTime dueAt;
@override@JsonKey() final  String assignedUserId;
/// Snapshot at generation time - editing the chore's weight doesn't
/// retroactively repay past turns.
@override@JsonKey() final  int effortMinutes;
@override final  DateTime? completedAt;
@override final  String? completedByUserId;
@override final  DateTime? skippedAt;
@override@JsonKey() final  bool isOverdue;

/// Create a copy of ChoreOccurrenceDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChoreOccurrenceDtoCopyWith<_ChoreOccurrenceDto> get copyWith => __$ChoreOccurrenceDtoCopyWithImpl<_ChoreOccurrenceDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChoreOccurrenceDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChoreOccurrenceDto&&(identical(other.id, id) || other.id == id)&&(identical(other.choreId, choreId) || other.choreId == choreId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.title, title) || other.title == title)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.assignedUserId, assignedUserId) || other.assignedUserId == assignedUserId)&&(identical(other.effortMinutes, effortMinutes) || other.effortMinutes == effortMinutes)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.completedByUserId, completedByUserId) || other.completedByUserId == completedByUserId)&&(identical(other.skippedAt, skippedAt) || other.skippedAt == skippedAt)&&(identical(other.isOverdue, isOverdue) || other.isOverdue == isOverdue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,choreId,channelId,title,dueAt,assignedUserId,effortMinutes,completedAt,completedByUserId,skippedAt,isOverdue);

@override
String toString() {
  return 'ChoreOccurrenceDto(id: $id, choreId: $choreId, channelId: $channelId, title: $title, dueAt: $dueAt, assignedUserId: $assignedUserId, effortMinutes: $effortMinutes, completedAt: $completedAt, completedByUserId: $completedByUserId, skippedAt: $skippedAt, isOverdue: $isOverdue)';
}


}

/// @nodoc
abstract mixin class _$ChoreOccurrenceDtoCopyWith<$Res> implements $ChoreOccurrenceDtoCopyWith<$Res> {
  factory _$ChoreOccurrenceDtoCopyWith(_ChoreOccurrenceDto value, $Res Function(_ChoreOccurrenceDto) _then) = __$ChoreOccurrenceDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String choreId, String channelId, String title, DateTime dueAt, String assignedUserId, int effortMinutes, DateTime? completedAt, String? completedByUserId, DateTime? skippedAt, bool isOverdue
});




}
/// @nodoc
class __$ChoreOccurrenceDtoCopyWithImpl<$Res>
    implements _$ChoreOccurrenceDtoCopyWith<$Res> {
  __$ChoreOccurrenceDtoCopyWithImpl(this._self, this._then);

  final _ChoreOccurrenceDto _self;
  final $Res Function(_ChoreOccurrenceDto) _then;

/// Create a copy of ChoreOccurrenceDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? choreId = null,Object? channelId = null,Object? title = null,Object? dueAt = null,Object? assignedUserId = null,Object? effortMinutes = null,Object? completedAt = freezed,Object? completedByUserId = freezed,Object? skippedAt = freezed,Object? isOverdue = null,}) {
  return _then(_ChoreOccurrenceDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,choreId: null == choreId ? _self.choreId : choreId // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,dueAt: null == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime,assignedUserId: null == assignedUserId ? _self.assignedUserId : assignedUserId // ignore: cast_nullable_to_non_nullable
as String,effortMinutes: null == effortMinutes ? _self.effortMinutes : effortMinutes // ignore: cast_nullable_to_non_nullable
as int,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedByUserId: freezed == completedByUserId ? _self.completedByUserId : completedByUserId // ignore: cast_nullable_to_non_nullable
as String?,skippedAt: freezed == skippedAt ? _self.skippedAt : skippedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isOverdue: null == isOverdue ? _self.isOverdue : isOverdue // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$ChoreBalanceEntryDto {

 String get userId; int get completedMinutes; int get completedCount; int get balanceMinutes;
/// Create a copy of ChoreBalanceEntryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChoreBalanceEntryDtoCopyWith<ChoreBalanceEntryDto> get copyWith => _$ChoreBalanceEntryDtoCopyWithImpl<ChoreBalanceEntryDto>(this as ChoreBalanceEntryDto, _$identity);

  /// Serializes this ChoreBalanceEntryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChoreBalanceEntryDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.completedMinutes, completedMinutes) || other.completedMinutes == completedMinutes)&&(identical(other.completedCount, completedCount) || other.completedCount == completedCount)&&(identical(other.balanceMinutes, balanceMinutes) || other.balanceMinutes == balanceMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,completedMinutes,completedCount,balanceMinutes);

@override
String toString() {
  return 'ChoreBalanceEntryDto(userId: $userId, completedMinutes: $completedMinutes, completedCount: $completedCount, balanceMinutes: $balanceMinutes)';
}


}

/// @nodoc
abstract mixin class $ChoreBalanceEntryDtoCopyWith<$Res>  {
  factory $ChoreBalanceEntryDtoCopyWith(ChoreBalanceEntryDto value, $Res Function(ChoreBalanceEntryDto) _then) = _$ChoreBalanceEntryDtoCopyWithImpl;
@useResult
$Res call({
 String userId, int completedMinutes, int completedCount, int balanceMinutes
});




}
/// @nodoc
class _$ChoreBalanceEntryDtoCopyWithImpl<$Res>
    implements $ChoreBalanceEntryDtoCopyWith<$Res> {
  _$ChoreBalanceEntryDtoCopyWithImpl(this._self, this._then);

  final ChoreBalanceEntryDto _self;
  final $Res Function(ChoreBalanceEntryDto) _then;

/// Create a copy of ChoreBalanceEntryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? completedMinutes = null,Object? completedCount = null,Object? balanceMinutes = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,completedMinutes: null == completedMinutes ? _self.completedMinutes : completedMinutes // ignore: cast_nullable_to_non_nullable
as int,completedCount: null == completedCount ? _self.completedCount : completedCount // ignore: cast_nullable_to_non_nullable
as int,balanceMinutes: null == balanceMinutes ? _self.balanceMinutes : balanceMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ChoreBalanceEntryDto].
extension ChoreBalanceEntryDtoPatterns on ChoreBalanceEntryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChoreBalanceEntryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChoreBalanceEntryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChoreBalanceEntryDto value)  $default,){
final _that = this;
switch (_that) {
case _ChoreBalanceEntryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChoreBalanceEntryDto value)?  $default,){
final _that = this;
switch (_that) {
case _ChoreBalanceEntryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  int completedMinutes,  int completedCount,  int balanceMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChoreBalanceEntryDto() when $default != null:
return $default(_that.userId,_that.completedMinutes,_that.completedCount,_that.balanceMinutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  int completedMinutes,  int completedCount,  int balanceMinutes)  $default,) {final _that = this;
switch (_that) {
case _ChoreBalanceEntryDto():
return $default(_that.userId,_that.completedMinutes,_that.completedCount,_that.balanceMinutes);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  int completedMinutes,  int completedCount,  int balanceMinutes)?  $default,) {final _that = this;
switch (_that) {
case _ChoreBalanceEntryDto() when $default != null:
return $default(_that.userId,_that.completedMinutes,_that.completedCount,_that.balanceMinutes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChoreBalanceEntryDto implements ChoreBalanceEntryDto {
  const _ChoreBalanceEntryDto({this.userId = '', this.completedMinutes = 0, this.completedCount = 0, this.balanceMinutes = 0});
  factory _ChoreBalanceEntryDto.fromJson(Map<String, dynamic> json) => _$ChoreBalanceEntryDtoFromJson(json);

@override@JsonKey() final  String userId;
@override@JsonKey() final  int completedMinutes;
@override@JsonKey() final  int completedCount;
@override@JsonKey() final  int balanceMinutes;

/// Create a copy of ChoreBalanceEntryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChoreBalanceEntryDtoCopyWith<_ChoreBalanceEntryDto> get copyWith => __$ChoreBalanceEntryDtoCopyWithImpl<_ChoreBalanceEntryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChoreBalanceEntryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChoreBalanceEntryDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.completedMinutes, completedMinutes) || other.completedMinutes == completedMinutes)&&(identical(other.completedCount, completedCount) || other.completedCount == completedCount)&&(identical(other.balanceMinutes, balanceMinutes) || other.balanceMinutes == balanceMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,completedMinutes,completedCount,balanceMinutes);

@override
String toString() {
  return 'ChoreBalanceEntryDto(userId: $userId, completedMinutes: $completedMinutes, completedCount: $completedCount, balanceMinutes: $balanceMinutes)';
}


}

/// @nodoc
abstract mixin class _$ChoreBalanceEntryDtoCopyWith<$Res> implements $ChoreBalanceEntryDtoCopyWith<$Res> {
  factory _$ChoreBalanceEntryDtoCopyWith(_ChoreBalanceEntryDto value, $Res Function(_ChoreBalanceEntryDto) _then) = __$ChoreBalanceEntryDtoCopyWithImpl;
@override @useResult
$Res call({
 String userId, int completedMinutes, int completedCount, int balanceMinutes
});




}
/// @nodoc
class __$ChoreBalanceEntryDtoCopyWithImpl<$Res>
    implements _$ChoreBalanceEntryDtoCopyWith<$Res> {
  __$ChoreBalanceEntryDtoCopyWithImpl(this._self, this._then);

  final _ChoreBalanceEntryDto _self;
  final $Res Function(_ChoreBalanceEntryDto) _then;

/// Create a copy of ChoreBalanceEntryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? completedMinutes = null,Object? completedCount = null,Object? balanceMinutes = null,}) {
  return _then(_ChoreBalanceEntryDto(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,completedMinutes: null == completedMinutes ? _self.completedMinutes : completedMinutes // ignore: cast_nullable_to_non_nullable
as int,completedCount: null == completedCount ? _self.completedCount : completedCount // ignore: cast_nullable_to_non_nullable
as int,balanceMinutes: null == balanceMinutes ? _self.balanceMinutes : balanceMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
