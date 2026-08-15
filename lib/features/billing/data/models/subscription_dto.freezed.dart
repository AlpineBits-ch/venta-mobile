// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubscriptionDto {

 String get id;/// Lowercase `guild` or `user`.
 String get subjectKind; String get subjectId;/// The key, for matching against the catalogue. [planDisplayName] is what
/// gets rendered.
 String get planName; String get planDisplayName; int get versionNumber;/// Stripe's own vocabulary. Classify with [subscriptionStanding] rather
/// than switching on it.
 String get status; DateTime? get currentPeriodEnd;/// True after a cancellation. Nothing has ended yet, which is why the copy
/// has to say when access actually stops.
 bool get cancelAtPeriodEnd;/// Non-null means a payment failed and the tier is being held until this
/// moment. The single most important field here for somebody whose card
/// expired, and it needs a plain sentence with a date, not a status chip.
 DateTime? get gracePeriodEndsAt;/// How often the plan bills.
///
/// **Nullable, and absent entirely from servers that predate it.** The
/// field was added after the first clients were written, and an older
/// service during a rolling deploy is a real case rather than a
/// hypothetical one. It is also genuinely null in one live case: the plan
/// version behind the subscription could not be resolved. Both fall back
/// through [renewalLine] rather than rendering a period nobody sent.
 String? get interval;/// False means the caller manages the server but somebody else's card is
/// behind it. On this client that changes nothing anybody can do - there is
/// nothing here to do - and it is read so the copy does not imply the
/// reader is the one paying.
 bool get isPayer;
/// Create a copy of SubscriptionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionDtoCopyWith<SubscriptionDto> get copyWith => _$SubscriptionDtoCopyWithImpl<SubscriptionDto>(this as SubscriptionDto, _$identity);

  /// Serializes this SubscriptionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.subjectKind, subjectKind) || other.subjectKind == subjectKind)&&(identical(other.subjectId, subjectId) || other.subjectId == subjectId)&&(identical(other.planName, planName) || other.planName == planName)&&(identical(other.planDisplayName, planDisplayName) || other.planDisplayName == planDisplayName)&&(identical(other.versionNumber, versionNumber) || other.versionNumber == versionNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.currentPeriodEnd, currentPeriodEnd) || other.currentPeriodEnd == currentPeriodEnd)&&(identical(other.cancelAtPeriodEnd, cancelAtPeriodEnd) || other.cancelAtPeriodEnd == cancelAtPeriodEnd)&&(identical(other.gracePeriodEndsAt, gracePeriodEndsAt) || other.gracePeriodEndsAt == gracePeriodEndsAt)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.isPayer, isPayer) || other.isPayer == isPayer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,subjectKind,subjectId,planName,planDisplayName,versionNumber,status,currentPeriodEnd,cancelAtPeriodEnd,gracePeriodEndsAt,interval,isPayer);

@override
String toString() {
  return 'SubscriptionDto(id: $id, subjectKind: $subjectKind, subjectId: $subjectId, planName: $planName, planDisplayName: $planDisplayName, versionNumber: $versionNumber, status: $status, currentPeriodEnd: $currentPeriodEnd, cancelAtPeriodEnd: $cancelAtPeriodEnd, gracePeriodEndsAt: $gracePeriodEndsAt, interval: $interval, isPayer: $isPayer)';
}


}

/// @nodoc
abstract mixin class $SubscriptionDtoCopyWith<$Res>  {
  factory $SubscriptionDtoCopyWith(SubscriptionDto value, $Res Function(SubscriptionDto) _then) = _$SubscriptionDtoCopyWithImpl;
@useResult
$Res call({
 String id, String subjectKind, String subjectId, String planName, String planDisplayName, int versionNumber, String status, DateTime? currentPeriodEnd, bool cancelAtPeriodEnd, DateTime? gracePeriodEndsAt, String? interval, bool isPayer
});




}
/// @nodoc
class _$SubscriptionDtoCopyWithImpl<$Res>
    implements $SubscriptionDtoCopyWith<$Res> {
  _$SubscriptionDtoCopyWithImpl(this._self, this._then);

  final SubscriptionDto _self;
  final $Res Function(SubscriptionDto) _then;

/// Create a copy of SubscriptionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? subjectKind = null,Object? subjectId = null,Object? planName = null,Object? planDisplayName = null,Object? versionNumber = null,Object? status = null,Object? currentPeriodEnd = freezed,Object? cancelAtPeriodEnd = null,Object? gracePeriodEndsAt = freezed,Object? interval = freezed,Object? isPayer = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,subjectKind: null == subjectKind ? _self.subjectKind : subjectKind // ignore: cast_nullable_to_non_nullable
as String,subjectId: null == subjectId ? _self.subjectId : subjectId // ignore: cast_nullable_to_non_nullable
as String,planName: null == planName ? _self.planName : planName // ignore: cast_nullable_to_non_nullable
as String,planDisplayName: null == planDisplayName ? _self.planDisplayName : planDisplayName // ignore: cast_nullable_to_non_nullable
as String,versionNumber: null == versionNumber ? _self.versionNumber : versionNumber // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,currentPeriodEnd: freezed == currentPeriodEnd ? _self.currentPeriodEnd : currentPeriodEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelAtPeriodEnd: null == cancelAtPeriodEnd ? _self.cancelAtPeriodEnd : cancelAtPeriodEnd // ignore: cast_nullable_to_non_nullable
as bool,gracePeriodEndsAt: freezed == gracePeriodEndsAt ? _self.gracePeriodEndsAt : gracePeriodEndsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,interval: freezed == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as String?,isPayer: null == isPayer ? _self.isPayer : isPayer // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionDto].
extension SubscriptionDtoPatterns on SubscriptionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionDto value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionDto value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String subjectKind,  String subjectId,  String planName,  String planDisplayName,  int versionNumber,  String status,  DateTime? currentPeriodEnd,  bool cancelAtPeriodEnd,  DateTime? gracePeriodEndsAt,  String? interval,  bool isPayer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionDto() when $default != null:
return $default(_that.id,_that.subjectKind,_that.subjectId,_that.planName,_that.planDisplayName,_that.versionNumber,_that.status,_that.currentPeriodEnd,_that.cancelAtPeriodEnd,_that.gracePeriodEndsAt,_that.interval,_that.isPayer);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String subjectKind,  String subjectId,  String planName,  String planDisplayName,  int versionNumber,  String status,  DateTime? currentPeriodEnd,  bool cancelAtPeriodEnd,  DateTime? gracePeriodEndsAt,  String? interval,  bool isPayer)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionDto():
return $default(_that.id,_that.subjectKind,_that.subjectId,_that.planName,_that.planDisplayName,_that.versionNumber,_that.status,_that.currentPeriodEnd,_that.cancelAtPeriodEnd,_that.gracePeriodEndsAt,_that.interval,_that.isPayer);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String subjectKind,  String subjectId,  String planName,  String planDisplayName,  int versionNumber,  String status,  DateTime? currentPeriodEnd,  bool cancelAtPeriodEnd,  DateTime? gracePeriodEndsAt,  String? interval,  bool isPayer)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionDto() when $default != null:
return $default(_that.id,_that.subjectKind,_that.subjectId,_that.planName,_that.planDisplayName,_that.versionNumber,_that.status,_that.currentPeriodEnd,_that.cancelAtPeriodEnd,_that.gracePeriodEndsAt,_that.interval,_that.isPayer);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _SubscriptionDto extends SubscriptionDto {
  const _SubscriptionDto({this.id = '', this.subjectKind = '', this.subjectId = '', this.planName = '', this.planDisplayName = '', this.versionNumber = 0, this.status = '', this.currentPeriodEnd, this.cancelAtPeriodEnd = false, this.gracePeriodEndsAt, this.interval, this.isPayer = false}): super._();
  factory _SubscriptionDto.fromJson(Map<String, dynamic> json) => _$SubscriptionDtoFromJson(json);

@override@JsonKey() final  String id;
/// Lowercase `guild` or `user`.
@override@JsonKey() final  String subjectKind;
@override@JsonKey() final  String subjectId;
/// The key, for matching against the catalogue. [planDisplayName] is what
/// gets rendered.
@override@JsonKey() final  String planName;
@override@JsonKey() final  String planDisplayName;
@override@JsonKey() final  int versionNumber;
/// Stripe's own vocabulary. Classify with [subscriptionStanding] rather
/// than switching on it.
@override@JsonKey() final  String status;
@override final  DateTime? currentPeriodEnd;
/// True after a cancellation. Nothing has ended yet, which is why the copy
/// has to say when access actually stops.
@override@JsonKey() final  bool cancelAtPeriodEnd;
/// Non-null means a payment failed and the tier is being held until this
/// moment. The single most important field here for somebody whose card
/// expired, and it needs a plain sentence with a date, not a status chip.
@override final  DateTime? gracePeriodEndsAt;
/// How often the plan bills.
///
/// **Nullable, and absent entirely from servers that predate it.** The
/// field was added after the first clients were written, and an older
/// service during a rolling deploy is a real case rather than a
/// hypothetical one. It is also genuinely null in one live case: the plan
/// version behind the subscription could not be resolved. Both fall back
/// through [renewalLine] rather than rendering a period nobody sent.
@override final  String? interval;
/// False means the caller manages the server but somebody else's card is
/// behind it. On this client that changes nothing anybody can do - there is
/// nothing here to do - and it is read so the copy does not imply the
/// reader is the one paying.
@override@JsonKey() final  bool isPayer;

/// Create a copy of SubscriptionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionDtoCopyWith<_SubscriptionDto> get copyWith => __$SubscriptionDtoCopyWithImpl<_SubscriptionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.subjectKind, subjectKind) || other.subjectKind == subjectKind)&&(identical(other.subjectId, subjectId) || other.subjectId == subjectId)&&(identical(other.planName, planName) || other.planName == planName)&&(identical(other.planDisplayName, planDisplayName) || other.planDisplayName == planDisplayName)&&(identical(other.versionNumber, versionNumber) || other.versionNumber == versionNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.currentPeriodEnd, currentPeriodEnd) || other.currentPeriodEnd == currentPeriodEnd)&&(identical(other.cancelAtPeriodEnd, cancelAtPeriodEnd) || other.cancelAtPeriodEnd == cancelAtPeriodEnd)&&(identical(other.gracePeriodEndsAt, gracePeriodEndsAt) || other.gracePeriodEndsAt == gracePeriodEndsAt)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.isPayer, isPayer) || other.isPayer == isPayer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,subjectKind,subjectId,planName,planDisplayName,versionNumber,status,currentPeriodEnd,cancelAtPeriodEnd,gracePeriodEndsAt,interval,isPayer);

@override
String toString() {
  return 'SubscriptionDto(id: $id, subjectKind: $subjectKind, subjectId: $subjectId, planName: $planName, planDisplayName: $planDisplayName, versionNumber: $versionNumber, status: $status, currentPeriodEnd: $currentPeriodEnd, cancelAtPeriodEnd: $cancelAtPeriodEnd, gracePeriodEndsAt: $gracePeriodEndsAt, interval: $interval, isPayer: $isPayer)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionDtoCopyWith<$Res> implements $SubscriptionDtoCopyWith<$Res> {
  factory _$SubscriptionDtoCopyWith(_SubscriptionDto value, $Res Function(_SubscriptionDto) _then) = __$SubscriptionDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String subjectKind, String subjectId, String planName, String planDisplayName, int versionNumber, String status, DateTime? currentPeriodEnd, bool cancelAtPeriodEnd, DateTime? gracePeriodEndsAt, String? interval, bool isPayer
});




}
/// @nodoc
class __$SubscriptionDtoCopyWithImpl<$Res>
    implements _$SubscriptionDtoCopyWith<$Res> {
  __$SubscriptionDtoCopyWithImpl(this._self, this._then);

  final _SubscriptionDto _self;
  final $Res Function(_SubscriptionDto) _then;

/// Create a copy of SubscriptionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? subjectKind = null,Object? subjectId = null,Object? planName = null,Object? planDisplayName = null,Object? versionNumber = null,Object? status = null,Object? currentPeriodEnd = freezed,Object? cancelAtPeriodEnd = null,Object? gracePeriodEndsAt = freezed,Object? interval = freezed,Object? isPayer = null,}) {
  return _then(_SubscriptionDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,subjectKind: null == subjectKind ? _self.subjectKind : subjectKind // ignore: cast_nullable_to_non_nullable
as String,subjectId: null == subjectId ? _self.subjectId : subjectId // ignore: cast_nullable_to_non_nullable
as String,planName: null == planName ? _self.planName : planName // ignore: cast_nullable_to_non_nullable
as String,planDisplayName: null == planDisplayName ? _self.planDisplayName : planDisplayName // ignore: cast_nullable_to_non_nullable
as String,versionNumber: null == versionNumber ? _self.versionNumber : versionNumber // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,currentPeriodEnd: freezed == currentPeriodEnd ? _self.currentPeriodEnd : currentPeriodEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelAtPeriodEnd: null == cancelAtPeriodEnd ? _self.cancelAtPeriodEnd : cancelAtPeriodEnd // ignore: cast_nullable_to_non_nullable
as bool,gracePeriodEndsAt: freezed == gracePeriodEndsAt ? _self.gracePeriodEndsAt : gracePeriodEndsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,interval: freezed == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as String?,isPayer: null == isPayer ? _self.isPayer : isPayer // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
