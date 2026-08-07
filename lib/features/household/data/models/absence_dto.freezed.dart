// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'absence_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AbsenceDto {

 String get id; String get guildId; String get userId; DateTime get startAt; DateTime get endAt;/// Optional, and usually where it is: "Lisbon", "at my parents'".
 String? get note; String get createdByUserId; DateTime? get createdAt;
/// Create a copy of AbsenceDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AbsenceDtoCopyWith<AbsenceDto> get copyWith => _$AbsenceDtoCopyWithImpl<AbsenceDto>(this as AbsenceDto, _$identity);

  /// Serializes this AbsenceDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AbsenceDto&&(identical(other.id, id) || other.id == id)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,guildId,userId,startAt,endAt,note,createdByUserId,createdAt);

@override
String toString() {
  return 'AbsenceDto(id: $id, guildId: $guildId, userId: $userId, startAt: $startAt, endAt: $endAt, note: $note, createdByUserId: $createdByUserId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AbsenceDtoCopyWith<$Res>  {
  factory $AbsenceDtoCopyWith(AbsenceDto value, $Res Function(AbsenceDto) _then) = _$AbsenceDtoCopyWithImpl;
@useResult
$Res call({
 String id, String guildId, String userId, DateTime startAt, DateTime endAt, String? note, String createdByUserId, DateTime? createdAt
});




}
/// @nodoc
class _$AbsenceDtoCopyWithImpl<$Res>
    implements $AbsenceDtoCopyWith<$Res> {
  _$AbsenceDtoCopyWithImpl(this._self, this._then);

  final AbsenceDto _self;
  final $Res Function(AbsenceDto) _then;

/// Create a copy of AbsenceDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? guildId = null,Object? userId = null,Object? startAt = null,Object? endAt = null,Object? note = freezed,Object? createdByUserId = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdByUserId: null == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AbsenceDto].
extension AbsenceDtoPatterns on AbsenceDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AbsenceDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AbsenceDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AbsenceDto value)  $default,){
final _that = this;
switch (_that) {
case _AbsenceDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AbsenceDto value)?  $default,){
final _that = this;
switch (_that) {
case _AbsenceDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String guildId,  String userId,  DateTime startAt,  DateTime endAt,  String? note,  String createdByUserId,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AbsenceDto() when $default != null:
return $default(_that.id,_that.guildId,_that.userId,_that.startAt,_that.endAt,_that.note,_that.createdByUserId,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String guildId,  String userId,  DateTime startAt,  DateTime endAt,  String? note,  String createdByUserId,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _AbsenceDto():
return $default(_that.id,_that.guildId,_that.userId,_that.startAt,_that.endAt,_that.note,_that.createdByUserId,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String guildId,  String userId,  DateTime startAt,  DateTime endAt,  String? note,  String createdByUserId,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AbsenceDto() when $default != null:
return $default(_that.id,_that.guildId,_that.userId,_that.startAt,_that.endAt,_that.note,_that.createdByUserId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _AbsenceDto implements AbsenceDto {
  const _AbsenceDto({required this.id, this.guildId = '', this.userId = '', required this.startAt, required this.endAt, this.note, this.createdByUserId = '', this.createdAt});
  factory _AbsenceDto.fromJson(Map<String, dynamic> json) => _$AbsenceDtoFromJson(json);

@override final  String id;
@override@JsonKey() final  String guildId;
@override@JsonKey() final  String userId;
@override final  DateTime startAt;
@override final  DateTime endAt;
/// Optional, and usually where it is: "Lisbon", "at my parents'".
@override final  String? note;
@override@JsonKey() final  String createdByUserId;
@override final  DateTime? createdAt;

/// Create a copy of AbsenceDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AbsenceDtoCopyWith<_AbsenceDto> get copyWith => __$AbsenceDtoCopyWithImpl<_AbsenceDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AbsenceDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AbsenceDto&&(identical(other.id, id) || other.id == id)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,guildId,userId,startAt,endAt,note,createdByUserId,createdAt);

@override
String toString() {
  return 'AbsenceDto(id: $id, guildId: $guildId, userId: $userId, startAt: $startAt, endAt: $endAt, note: $note, createdByUserId: $createdByUserId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AbsenceDtoCopyWith<$Res> implements $AbsenceDtoCopyWith<$Res> {
  factory _$AbsenceDtoCopyWith(_AbsenceDto value, $Res Function(_AbsenceDto) _then) = __$AbsenceDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String guildId, String userId, DateTime startAt, DateTime endAt, String? note, String createdByUserId, DateTime? createdAt
});




}
/// @nodoc
class __$AbsenceDtoCopyWithImpl<$Res>
    implements _$AbsenceDtoCopyWith<$Res> {
  __$AbsenceDtoCopyWithImpl(this._self, this._then);

  final _AbsenceDto _self;
  final $Res Function(_AbsenceDto) _then;

/// Create a copy of AbsenceDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? guildId = null,Object? userId = null,Object? startAt = null,Object? endAt = null,Object? note = freezed,Object? createdByUserId = null,Object? createdAt = freezed,}) {
  return _then(_AbsenceDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdByUserId: null == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$AbsenceSavedDto {

 AbsenceDto get absence; int get choresReassigned;
/// Create a copy of AbsenceSavedDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AbsenceSavedDtoCopyWith<AbsenceSavedDto> get copyWith => _$AbsenceSavedDtoCopyWithImpl<AbsenceSavedDto>(this as AbsenceSavedDto, _$identity);

  /// Serializes this AbsenceSavedDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AbsenceSavedDto&&(identical(other.absence, absence) || other.absence == absence)&&(identical(other.choresReassigned, choresReassigned) || other.choresReassigned == choresReassigned));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,absence,choresReassigned);

@override
String toString() {
  return 'AbsenceSavedDto(absence: $absence, choresReassigned: $choresReassigned)';
}


}

/// @nodoc
abstract mixin class $AbsenceSavedDtoCopyWith<$Res>  {
  factory $AbsenceSavedDtoCopyWith(AbsenceSavedDto value, $Res Function(AbsenceSavedDto) _then) = _$AbsenceSavedDtoCopyWithImpl;
@useResult
$Res call({
 AbsenceDto absence, int choresReassigned
});


$AbsenceDtoCopyWith<$Res> get absence;

}
/// @nodoc
class _$AbsenceSavedDtoCopyWithImpl<$Res>
    implements $AbsenceSavedDtoCopyWith<$Res> {
  _$AbsenceSavedDtoCopyWithImpl(this._self, this._then);

  final AbsenceSavedDto _self;
  final $Res Function(AbsenceSavedDto) _then;

/// Create a copy of AbsenceSavedDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? absence = null,Object? choresReassigned = null,}) {
  return _then(_self.copyWith(
absence: null == absence ? _self.absence : absence // ignore: cast_nullable_to_non_nullable
as AbsenceDto,choresReassigned: null == choresReassigned ? _self.choresReassigned : choresReassigned // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of AbsenceSavedDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AbsenceDtoCopyWith<$Res> get absence {
  
  return $AbsenceDtoCopyWith<$Res>(_self.absence, (value) {
    return _then(_self.copyWith(absence: value));
  });
}
}


/// Adds pattern-matching-related methods to [AbsenceSavedDto].
extension AbsenceSavedDtoPatterns on AbsenceSavedDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AbsenceSavedDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AbsenceSavedDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AbsenceSavedDto value)  $default,){
final _that = this;
switch (_that) {
case _AbsenceSavedDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AbsenceSavedDto value)?  $default,){
final _that = this;
switch (_that) {
case _AbsenceSavedDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AbsenceDto absence,  int choresReassigned)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AbsenceSavedDto() when $default != null:
return $default(_that.absence,_that.choresReassigned);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AbsenceDto absence,  int choresReassigned)  $default,) {final _that = this;
switch (_that) {
case _AbsenceSavedDto():
return $default(_that.absence,_that.choresReassigned);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AbsenceDto absence,  int choresReassigned)?  $default,) {final _that = this;
switch (_that) {
case _AbsenceSavedDto() when $default != null:
return $default(_that.absence,_that.choresReassigned);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AbsenceSavedDto implements AbsenceSavedDto {
  const _AbsenceSavedDto({required this.absence, this.choresReassigned = 0});
  factory _AbsenceSavedDto.fromJson(Map<String, dynamic> json) => _$AbsenceSavedDtoFromJson(json);

@override final  AbsenceDto absence;
@override@JsonKey() final  int choresReassigned;

/// Create a copy of AbsenceSavedDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AbsenceSavedDtoCopyWith<_AbsenceSavedDto> get copyWith => __$AbsenceSavedDtoCopyWithImpl<_AbsenceSavedDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AbsenceSavedDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AbsenceSavedDto&&(identical(other.absence, absence) || other.absence == absence)&&(identical(other.choresReassigned, choresReassigned) || other.choresReassigned == choresReassigned));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,absence,choresReassigned);

@override
String toString() {
  return 'AbsenceSavedDto(absence: $absence, choresReassigned: $choresReassigned)';
}


}

/// @nodoc
abstract mixin class _$AbsenceSavedDtoCopyWith<$Res> implements $AbsenceSavedDtoCopyWith<$Res> {
  factory _$AbsenceSavedDtoCopyWith(_AbsenceSavedDto value, $Res Function(_AbsenceSavedDto) _then) = __$AbsenceSavedDtoCopyWithImpl;
@override @useResult
$Res call({
 AbsenceDto absence, int choresReassigned
});


@override $AbsenceDtoCopyWith<$Res> get absence;

}
/// @nodoc
class __$AbsenceSavedDtoCopyWithImpl<$Res>
    implements _$AbsenceSavedDtoCopyWith<$Res> {
  __$AbsenceSavedDtoCopyWithImpl(this._self, this._then);

  final _AbsenceSavedDto _self;
  final $Res Function(_AbsenceSavedDto) _then;

/// Create a copy of AbsenceSavedDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? absence = null,Object? choresReassigned = null,}) {
  return _then(_AbsenceSavedDto(
absence: null == absence ? _self.absence : absence // ignore: cast_nullable_to_non_nullable
as AbsenceDto,choresReassigned: null == choresReassigned ? _self.choresReassigned : choresReassigned // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of AbsenceSavedDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AbsenceDtoCopyWith<$Res> get absence {
  
  return $AbsenceDtoCopyWith<$Res>(_self.absence, (value) {
    return _then(_self.copyWith(absence: value));
  });
}
}

// dart format on
