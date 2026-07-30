// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'house_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HomeStatusDto {

 String get userId;@JsonKey(unknownEnumValue: HomeStatusKind.home) HomeStatusKind get kind;/// <= 100 chars.
 String? get note; DateTime? get expiresAt;
/// Create a copy of HomeStatusDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeStatusDtoCopyWith<HomeStatusDto> get copyWith => _$HomeStatusDtoCopyWithImpl<HomeStatusDto>(this as HomeStatusDto, _$identity);

  /// Serializes this HomeStatusDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeStatusDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.note, note) || other.note == note)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,kind,note,expiresAt);

@override
String toString() {
  return 'HomeStatusDto(userId: $userId, kind: $kind, note: $note, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $HomeStatusDtoCopyWith<$Res>  {
  factory $HomeStatusDtoCopyWith(HomeStatusDto value, $Res Function(HomeStatusDto) _then) = _$HomeStatusDtoCopyWithImpl;
@useResult
$Res call({
 String userId,@JsonKey(unknownEnumValue: HomeStatusKind.home) HomeStatusKind kind, String? note, DateTime? expiresAt
});




}
/// @nodoc
class _$HomeStatusDtoCopyWithImpl<$Res>
    implements $HomeStatusDtoCopyWith<$Res> {
  _$HomeStatusDtoCopyWithImpl(this._self, this._then);

  final HomeStatusDto _self;
  final $Res Function(HomeStatusDto) _then;

/// Create a copy of HomeStatusDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? kind = null,Object? note = freezed,Object? expiresAt = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as HomeStatusKind,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeStatusDto].
extension HomeStatusDtoPatterns on HomeStatusDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeStatusDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeStatusDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeStatusDto value)  $default,){
final _that = this;
switch (_that) {
case _HomeStatusDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeStatusDto value)?  $default,){
final _that = this;
switch (_that) {
case _HomeStatusDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId, @JsonKey(unknownEnumValue: HomeStatusKind.home)  HomeStatusKind kind,  String? note,  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeStatusDto() when $default != null:
return $default(_that.userId,_that.kind,_that.note,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId, @JsonKey(unknownEnumValue: HomeStatusKind.home)  HomeStatusKind kind,  String? note,  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _HomeStatusDto():
return $default(_that.userId,_that.kind,_that.note,_that.expiresAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId, @JsonKey(unknownEnumValue: HomeStatusKind.home)  HomeStatusKind kind,  String? note,  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _HomeStatusDto() when $default != null:
return $default(_that.userId,_that.kind,_that.note,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HomeStatusDto implements HomeStatusDto {
  const _HomeStatusDto({this.userId = '', @JsonKey(unknownEnumValue: HomeStatusKind.home) this.kind = HomeStatusKind.home, this.note, this.expiresAt});
  factory _HomeStatusDto.fromJson(Map<String, dynamic> json) => _$HomeStatusDtoFromJson(json);

@override@JsonKey() final  String userId;
@override@JsonKey(unknownEnumValue: HomeStatusKind.home) final  HomeStatusKind kind;
/// <= 100 chars.
@override final  String? note;
@override final  DateTime? expiresAt;

/// Create a copy of HomeStatusDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeStatusDtoCopyWith<_HomeStatusDto> get copyWith => __$HomeStatusDtoCopyWithImpl<_HomeStatusDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HomeStatusDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeStatusDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.note, note) || other.note == note)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,kind,note,expiresAt);

@override
String toString() {
  return 'HomeStatusDto(userId: $userId, kind: $kind, note: $note, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$HomeStatusDtoCopyWith<$Res> implements $HomeStatusDtoCopyWith<$Res> {
  factory _$HomeStatusDtoCopyWith(_HomeStatusDto value, $Res Function(_HomeStatusDto) _then) = __$HomeStatusDtoCopyWithImpl;
@override @useResult
$Res call({
 String userId,@JsonKey(unknownEnumValue: HomeStatusKind.home) HomeStatusKind kind, String? note, DateTime? expiresAt
});




}
/// @nodoc
class __$HomeStatusDtoCopyWithImpl<$Res>
    implements _$HomeStatusDtoCopyWith<$Res> {
  __$HomeStatusDtoCopyWithImpl(this._self, this._then);

  final _HomeStatusDto _self;
  final $Res Function(_HomeStatusDto) _then;

/// Create a copy of HomeStatusDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? kind = null,Object? note = freezed,Object? expiresAt = freezed,}) {
  return _then(_HomeStatusDto(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as HomeStatusKind,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$QuietHoursDto {

 bool get enabled;/// 0-1439.
 int get startMinuteLocal; int get endMinuteLocal;/// IANA id, e.g. `Europe/Zurich`.
 String get timeZoneId;
/// Create a copy of QuietHoursDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuietHoursDtoCopyWith<QuietHoursDto> get copyWith => _$QuietHoursDtoCopyWithImpl<QuietHoursDto>(this as QuietHoursDto, _$identity);

  /// Serializes this QuietHoursDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuietHoursDto&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.startMinuteLocal, startMinuteLocal) || other.startMinuteLocal == startMinuteLocal)&&(identical(other.endMinuteLocal, endMinuteLocal) || other.endMinuteLocal == endMinuteLocal)&&(identical(other.timeZoneId, timeZoneId) || other.timeZoneId == timeZoneId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,startMinuteLocal,endMinuteLocal,timeZoneId);

@override
String toString() {
  return 'QuietHoursDto(enabled: $enabled, startMinuteLocal: $startMinuteLocal, endMinuteLocal: $endMinuteLocal, timeZoneId: $timeZoneId)';
}


}

/// @nodoc
abstract mixin class $QuietHoursDtoCopyWith<$Res>  {
  factory $QuietHoursDtoCopyWith(QuietHoursDto value, $Res Function(QuietHoursDto) _then) = _$QuietHoursDtoCopyWithImpl;
@useResult
$Res call({
 bool enabled, int startMinuteLocal, int endMinuteLocal, String timeZoneId
});




}
/// @nodoc
class _$QuietHoursDtoCopyWithImpl<$Res>
    implements $QuietHoursDtoCopyWith<$Res> {
  _$QuietHoursDtoCopyWithImpl(this._self, this._then);

  final QuietHoursDto _self;
  final $Res Function(QuietHoursDto) _then;

/// Create a copy of QuietHoursDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? startMinuteLocal = null,Object? endMinuteLocal = null,Object? timeZoneId = null,}) {
  return _then(_self.copyWith(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,startMinuteLocal: null == startMinuteLocal ? _self.startMinuteLocal : startMinuteLocal // ignore: cast_nullable_to_non_nullable
as int,endMinuteLocal: null == endMinuteLocal ? _self.endMinuteLocal : endMinuteLocal // ignore: cast_nullable_to_non_nullable
as int,timeZoneId: null == timeZoneId ? _self.timeZoneId : timeZoneId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [QuietHoursDto].
extension QuietHoursDtoPatterns on QuietHoursDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuietHoursDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuietHoursDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuietHoursDto value)  $default,){
final _that = this;
switch (_that) {
case _QuietHoursDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuietHoursDto value)?  $default,){
final _that = this;
switch (_that) {
case _QuietHoursDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  int startMinuteLocal,  int endMinuteLocal,  String timeZoneId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuietHoursDto() when $default != null:
return $default(_that.enabled,_that.startMinuteLocal,_that.endMinuteLocal,_that.timeZoneId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  int startMinuteLocal,  int endMinuteLocal,  String timeZoneId)  $default,) {final _that = this;
switch (_that) {
case _QuietHoursDto():
return $default(_that.enabled,_that.startMinuteLocal,_that.endMinuteLocal,_that.timeZoneId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  int startMinuteLocal,  int endMinuteLocal,  String timeZoneId)?  $default,) {final _that = this;
switch (_that) {
case _QuietHoursDto() when $default != null:
return $default(_that.enabled,_that.startMinuteLocal,_that.endMinuteLocal,_that.timeZoneId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QuietHoursDto implements QuietHoursDto {
  const _QuietHoursDto({this.enabled = false, this.startMinuteLocal = 1320, this.endMinuteLocal = 420, this.timeZoneId = 'Europe/Zurich'});
  factory _QuietHoursDto.fromJson(Map<String, dynamic> json) => _$QuietHoursDtoFromJson(json);

@override@JsonKey() final  bool enabled;
/// 0-1439.
@override@JsonKey() final  int startMinuteLocal;
@override@JsonKey() final  int endMinuteLocal;
/// IANA id, e.g. `Europe/Zurich`.
@override@JsonKey() final  String timeZoneId;

/// Create a copy of QuietHoursDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuietHoursDtoCopyWith<_QuietHoursDto> get copyWith => __$QuietHoursDtoCopyWithImpl<_QuietHoursDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuietHoursDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuietHoursDto&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.startMinuteLocal, startMinuteLocal) || other.startMinuteLocal == startMinuteLocal)&&(identical(other.endMinuteLocal, endMinuteLocal) || other.endMinuteLocal == endMinuteLocal)&&(identical(other.timeZoneId, timeZoneId) || other.timeZoneId == timeZoneId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,startMinuteLocal,endMinuteLocal,timeZoneId);

@override
String toString() {
  return 'QuietHoursDto(enabled: $enabled, startMinuteLocal: $startMinuteLocal, endMinuteLocal: $endMinuteLocal, timeZoneId: $timeZoneId)';
}


}

/// @nodoc
abstract mixin class _$QuietHoursDtoCopyWith<$Res> implements $QuietHoursDtoCopyWith<$Res> {
  factory _$QuietHoursDtoCopyWith(_QuietHoursDto value, $Res Function(_QuietHoursDto) _then) = __$QuietHoursDtoCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, int startMinuteLocal, int endMinuteLocal, String timeZoneId
});




}
/// @nodoc
class __$QuietHoursDtoCopyWithImpl<$Res>
    implements _$QuietHoursDtoCopyWith<$Res> {
  __$QuietHoursDtoCopyWithImpl(this._self, this._then);

  final _QuietHoursDto _self;
  final $Res Function(_QuietHoursDto) _then;

/// Create a copy of QuietHoursDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? startMinuteLocal = null,Object? endMinuteLocal = null,Object? timeZoneId = null,}) {
  return _then(_QuietHoursDto(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,startMinuteLocal: null == startMinuteLocal ? _self.startMinuteLocal : startMinuteLocal // ignore: cast_nullable_to_non_nullable
as int,endMinuteLocal: null == endMinuteLocal ? _self.endMinuteLocal : endMinuteLocal // ignore: cast_nullable_to_non_nullable
as int,timeZoneId: null == timeZoneId ? _self.timeZoneId : timeZoneId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
