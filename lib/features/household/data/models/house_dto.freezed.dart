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
@ApiDateTimeConverter()
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


/// @nodoc
mixin _$OutstandingBalanceDto {

 String get channelId; String get currency;/// Minor units, signed the same way [LedgerBalanceDto.netMinor] is:
/// negative means they owe the house.
 int get netMinor;
/// Create a copy of OutstandingBalanceDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutstandingBalanceDtoCopyWith<OutstandingBalanceDto> get copyWith => _$OutstandingBalanceDtoCopyWithImpl<OutstandingBalanceDto>(this as OutstandingBalanceDto, _$identity);

  /// Serializes this OutstandingBalanceDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutstandingBalanceDto&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.netMinor, netMinor) || other.netMinor == netMinor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,channelId,currency,netMinor);

@override
String toString() {
  return 'OutstandingBalanceDto(channelId: $channelId, currency: $currency, netMinor: $netMinor)';
}


}

/// @nodoc
abstract mixin class $OutstandingBalanceDtoCopyWith<$Res>  {
  factory $OutstandingBalanceDtoCopyWith(OutstandingBalanceDto value, $Res Function(OutstandingBalanceDto) _then) = _$OutstandingBalanceDtoCopyWithImpl;
@useResult
$Res call({
 String channelId, String currency, int netMinor
});




}
/// @nodoc
class _$OutstandingBalanceDtoCopyWithImpl<$Res>
    implements $OutstandingBalanceDtoCopyWith<$Res> {
  _$OutstandingBalanceDtoCopyWithImpl(this._self, this._then);

  final OutstandingBalanceDto _self;
  final $Res Function(OutstandingBalanceDto) _then;

/// Create a copy of OutstandingBalanceDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? channelId = null,Object? currency = null,Object? netMinor = null,}) {
  return _then(_self.copyWith(
channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,netMinor: null == netMinor ? _self.netMinor : netMinor // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [OutstandingBalanceDto].
extension OutstandingBalanceDtoPatterns on OutstandingBalanceDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OutstandingBalanceDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OutstandingBalanceDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OutstandingBalanceDto value)  $default,){
final _that = this;
switch (_that) {
case _OutstandingBalanceDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OutstandingBalanceDto value)?  $default,){
final _that = this;
switch (_that) {
case _OutstandingBalanceDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String channelId,  String currency,  int netMinor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OutstandingBalanceDto() when $default != null:
return $default(_that.channelId,_that.currency,_that.netMinor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String channelId,  String currency,  int netMinor)  $default,) {final _that = this;
switch (_that) {
case _OutstandingBalanceDto():
return $default(_that.channelId,_that.currency,_that.netMinor);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String channelId,  String currency,  int netMinor)?  $default,) {final _that = this;
switch (_that) {
case _OutstandingBalanceDto() when $default != null:
return $default(_that.channelId,_that.currency,_that.netMinor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OutstandingBalanceDto implements OutstandingBalanceDto {
  const _OutstandingBalanceDto({this.channelId = '', this.currency = 'CHF', this.netMinor = 0});
  factory _OutstandingBalanceDto.fromJson(Map<String, dynamic> json) => _$OutstandingBalanceDtoFromJson(json);

@override@JsonKey() final  String channelId;
@override@JsonKey() final  String currency;
/// Minor units, signed the same way [LedgerBalanceDto.netMinor] is:
/// negative means they owe the house.
@override@JsonKey() final  int netMinor;

/// Create a copy of OutstandingBalanceDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OutstandingBalanceDtoCopyWith<_OutstandingBalanceDto> get copyWith => __$OutstandingBalanceDtoCopyWithImpl<_OutstandingBalanceDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OutstandingBalanceDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OutstandingBalanceDto&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.netMinor, netMinor) || other.netMinor == netMinor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,channelId,currency,netMinor);

@override
String toString() {
  return 'OutstandingBalanceDto(channelId: $channelId, currency: $currency, netMinor: $netMinor)';
}


}

/// @nodoc
abstract mixin class _$OutstandingBalanceDtoCopyWith<$Res> implements $OutstandingBalanceDtoCopyWith<$Res> {
  factory _$OutstandingBalanceDtoCopyWith(_OutstandingBalanceDto value, $Res Function(_OutstandingBalanceDto) _then) = __$OutstandingBalanceDtoCopyWithImpl;
@override @useResult
$Res call({
 String channelId, String currency, int netMinor
});




}
/// @nodoc
class __$OutstandingBalanceDtoCopyWithImpl<$Res>
    implements _$OutstandingBalanceDtoCopyWith<$Res> {
  __$OutstandingBalanceDtoCopyWithImpl(this._self, this._then);

  final _OutstandingBalanceDto _self;
  final $Res Function(_OutstandingBalanceDto) _then;

/// Create a copy of OutstandingBalanceDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? channelId = null,Object? currency = null,Object? netMinor = null,}) {
  return _then(_OutstandingBalanceDto(
channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,netMinor: null == netMinor ? _self.netMinor : netMinor // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$MoveOutSummaryDto {

 String get userId;/// Unfinished turns handed to the next lightest-loaded member.
 int get choresReassigned;/// Unfinished turns deleted because the rota had nobody left.
 int get choresDropped;/// Chores that named them as the fixed assignee, now paused.
 int get choresPaused; int get listItemsUnassigned;/// The settlements recorded to zero them. Empty unless the house asked for
/// a write-off - and a write-off doesn't pretend money moved, it's the
/// house agreeing to stop counting the debt.
 List<TransferSuggestionDto> get balancesWrittenOff;
/// Create a copy of MoveOutSummaryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoveOutSummaryDtoCopyWith<MoveOutSummaryDto> get copyWith => _$MoveOutSummaryDtoCopyWithImpl<MoveOutSummaryDto>(this as MoveOutSummaryDto, _$identity);

  /// Serializes this MoveOutSummaryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MoveOutSummaryDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.choresReassigned, choresReassigned) || other.choresReassigned == choresReassigned)&&(identical(other.choresDropped, choresDropped) || other.choresDropped == choresDropped)&&(identical(other.choresPaused, choresPaused) || other.choresPaused == choresPaused)&&(identical(other.listItemsUnassigned, listItemsUnassigned) || other.listItemsUnassigned == listItemsUnassigned)&&const DeepCollectionEquality().equals(other.balancesWrittenOff, balancesWrittenOff));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,choresReassigned,choresDropped,choresPaused,listItemsUnassigned,const DeepCollectionEquality().hash(balancesWrittenOff));

@override
String toString() {
  return 'MoveOutSummaryDto(userId: $userId, choresReassigned: $choresReassigned, choresDropped: $choresDropped, choresPaused: $choresPaused, listItemsUnassigned: $listItemsUnassigned, balancesWrittenOff: $balancesWrittenOff)';
}


}

/// @nodoc
abstract mixin class $MoveOutSummaryDtoCopyWith<$Res>  {
  factory $MoveOutSummaryDtoCopyWith(MoveOutSummaryDto value, $Res Function(MoveOutSummaryDto) _then) = _$MoveOutSummaryDtoCopyWithImpl;
@useResult
$Res call({
 String userId, int choresReassigned, int choresDropped, int choresPaused, int listItemsUnassigned, List<TransferSuggestionDto> balancesWrittenOff
});




}
/// @nodoc
class _$MoveOutSummaryDtoCopyWithImpl<$Res>
    implements $MoveOutSummaryDtoCopyWith<$Res> {
  _$MoveOutSummaryDtoCopyWithImpl(this._self, this._then);

  final MoveOutSummaryDto _self;
  final $Res Function(MoveOutSummaryDto) _then;

/// Create a copy of MoveOutSummaryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? choresReassigned = null,Object? choresDropped = null,Object? choresPaused = null,Object? listItemsUnassigned = null,Object? balancesWrittenOff = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,choresReassigned: null == choresReassigned ? _self.choresReassigned : choresReassigned // ignore: cast_nullable_to_non_nullable
as int,choresDropped: null == choresDropped ? _self.choresDropped : choresDropped // ignore: cast_nullable_to_non_nullable
as int,choresPaused: null == choresPaused ? _self.choresPaused : choresPaused // ignore: cast_nullable_to_non_nullable
as int,listItemsUnassigned: null == listItemsUnassigned ? _self.listItemsUnassigned : listItemsUnassigned // ignore: cast_nullable_to_non_nullable
as int,balancesWrittenOff: null == balancesWrittenOff ? _self.balancesWrittenOff : balancesWrittenOff // ignore: cast_nullable_to_non_nullable
as List<TransferSuggestionDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [MoveOutSummaryDto].
extension MoveOutSummaryDtoPatterns on MoveOutSummaryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MoveOutSummaryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MoveOutSummaryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MoveOutSummaryDto value)  $default,){
final _that = this;
switch (_that) {
case _MoveOutSummaryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MoveOutSummaryDto value)?  $default,){
final _that = this;
switch (_that) {
case _MoveOutSummaryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  int choresReassigned,  int choresDropped,  int choresPaused,  int listItemsUnassigned,  List<TransferSuggestionDto> balancesWrittenOff)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MoveOutSummaryDto() when $default != null:
return $default(_that.userId,_that.choresReassigned,_that.choresDropped,_that.choresPaused,_that.listItemsUnassigned,_that.balancesWrittenOff);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  int choresReassigned,  int choresDropped,  int choresPaused,  int listItemsUnassigned,  List<TransferSuggestionDto> balancesWrittenOff)  $default,) {final _that = this;
switch (_that) {
case _MoveOutSummaryDto():
return $default(_that.userId,_that.choresReassigned,_that.choresDropped,_that.choresPaused,_that.listItemsUnassigned,_that.balancesWrittenOff);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  int choresReassigned,  int choresDropped,  int choresPaused,  int listItemsUnassigned,  List<TransferSuggestionDto> balancesWrittenOff)?  $default,) {final _that = this;
switch (_that) {
case _MoveOutSummaryDto() when $default != null:
return $default(_that.userId,_that.choresReassigned,_that.choresDropped,_that.choresPaused,_that.listItemsUnassigned,_that.balancesWrittenOff);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MoveOutSummaryDto implements MoveOutSummaryDto {
  const _MoveOutSummaryDto({this.userId = '', this.choresReassigned = 0, this.choresDropped = 0, this.choresPaused = 0, this.listItemsUnassigned = 0, final  List<TransferSuggestionDto> balancesWrittenOff = const <TransferSuggestionDto>[]}): _balancesWrittenOff = balancesWrittenOff;
  factory _MoveOutSummaryDto.fromJson(Map<String, dynamic> json) => _$MoveOutSummaryDtoFromJson(json);

@override@JsonKey() final  String userId;
/// Unfinished turns handed to the next lightest-loaded member.
@override@JsonKey() final  int choresReassigned;
/// Unfinished turns deleted because the rota had nobody left.
@override@JsonKey() final  int choresDropped;
/// Chores that named them as the fixed assignee, now paused.
@override@JsonKey() final  int choresPaused;
@override@JsonKey() final  int listItemsUnassigned;
/// The settlements recorded to zero them. Empty unless the house asked for
/// a write-off - and a write-off doesn't pretend money moved, it's the
/// house agreeing to stop counting the debt.
 final  List<TransferSuggestionDto> _balancesWrittenOff;
/// The settlements recorded to zero them. Empty unless the house asked for
/// a write-off - and a write-off doesn't pretend money moved, it's the
/// house agreeing to stop counting the debt.
@override@JsonKey() List<TransferSuggestionDto> get balancesWrittenOff {
  if (_balancesWrittenOff is EqualUnmodifiableListView) return _balancesWrittenOff;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_balancesWrittenOff);
}


/// Create a copy of MoveOutSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MoveOutSummaryDtoCopyWith<_MoveOutSummaryDto> get copyWith => __$MoveOutSummaryDtoCopyWithImpl<_MoveOutSummaryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MoveOutSummaryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MoveOutSummaryDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.choresReassigned, choresReassigned) || other.choresReassigned == choresReassigned)&&(identical(other.choresDropped, choresDropped) || other.choresDropped == choresDropped)&&(identical(other.choresPaused, choresPaused) || other.choresPaused == choresPaused)&&(identical(other.listItemsUnassigned, listItemsUnassigned) || other.listItemsUnassigned == listItemsUnassigned)&&const DeepCollectionEquality().equals(other._balancesWrittenOff, _balancesWrittenOff));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,choresReassigned,choresDropped,choresPaused,listItemsUnassigned,const DeepCollectionEquality().hash(_balancesWrittenOff));

@override
String toString() {
  return 'MoveOutSummaryDto(userId: $userId, choresReassigned: $choresReassigned, choresDropped: $choresDropped, choresPaused: $choresPaused, listItemsUnassigned: $listItemsUnassigned, balancesWrittenOff: $balancesWrittenOff)';
}


}

/// @nodoc
abstract mixin class _$MoveOutSummaryDtoCopyWith<$Res> implements $MoveOutSummaryDtoCopyWith<$Res> {
  factory _$MoveOutSummaryDtoCopyWith(_MoveOutSummaryDto value, $Res Function(_MoveOutSummaryDto) _then) = __$MoveOutSummaryDtoCopyWithImpl;
@override @useResult
$Res call({
 String userId, int choresReassigned, int choresDropped, int choresPaused, int listItemsUnassigned, List<TransferSuggestionDto> balancesWrittenOff
});




}
/// @nodoc
class __$MoveOutSummaryDtoCopyWithImpl<$Res>
    implements _$MoveOutSummaryDtoCopyWith<$Res> {
  __$MoveOutSummaryDtoCopyWithImpl(this._self, this._then);

  final _MoveOutSummaryDto _self;
  final $Res Function(_MoveOutSummaryDto) _then;

/// Create a copy of MoveOutSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? choresReassigned = null,Object? choresDropped = null,Object? choresPaused = null,Object? listItemsUnassigned = null,Object? balancesWrittenOff = null,}) {
  return _then(_MoveOutSummaryDto(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,choresReassigned: null == choresReassigned ? _self.choresReassigned : choresReassigned // ignore: cast_nullable_to_non_nullable
as int,choresDropped: null == choresDropped ? _self.choresDropped : choresDropped // ignore: cast_nullable_to_non_nullable
as int,choresPaused: null == choresPaused ? _self.choresPaused : choresPaused // ignore: cast_nullable_to_non_nullable
as int,listItemsUnassigned: null == listItemsUnassigned ? _self.listItemsUnassigned : listItemsUnassigned // ignore: cast_nullable_to_non_nullable
as int,balancesWrittenOff: null == balancesWrittenOff ? _self._balancesWrittenOff : balancesWrittenOff // ignore: cast_nullable_to_non_nullable
as List<TransferSuggestionDto>,
  ));
}


}

// dart format on
