// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_handles_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaymentHandlesDto {

/// Whether **the caller** is sharing their own number with this household.
///
/// Read from the `SharePhoneForPayments` flag on the caller's membership
/// row, not from whether a number exists - so this can still be `true`
/// for somebody whose account has no number at all, in which case they
/// appear in nobody's [phoneNumbers] and adding a number republishes it
/// here with no further action.
///
/// That combination is now rare rather than routine: removing a number
/// clears this flag in every household, so only accounts that removed
/// theirs before Identity started publishing the revocation are still in
/// it. The server stays the authority either way. See `PhoneSharingCard`.
 bool get sharingPhoneNumber;/// One entry per member who has both opted in *and* has a number.
///
/// A member who opted out and a member with no number are field-for-field
/// identical on the wire - both are simply absent - and the server has a
/// test asserting exactly that. Nothing in this app may render a sentence
/// that distinguishes them, because every available phrasing ("Anna hasn't
/// shared her number") asserts that Anna has one.
 List<SharedPhoneNumberDto> get phoneNumbers;
/// Create a copy of PaymentHandlesDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentHandlesDtoCopyWith<PaymentHandlesDto> get copyWith => _$PaymentHandlesDtoCopyWithImpl<PaymentHandlesDto>(this as PaymentHandlesDto, _$identity);

  /// Serializes this PaymentHandlesDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentHandlesDto&&(identical(other.sharingPhoneNumber, sharingPhoneNumber) || other.sharingPhoneNumber == sharingPhoneNumber)&&const DeepCollectionEquality().equals(other.phoneNumbers, phoneNumbers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sharingPhoneNumber,const DeepCollectionEquality().hash(phoneNumbers));

@override
String toString() {
  return 'PaymentHandlesDto(sharingPhoneNumber: $sharingPhoneNumber, phoneNumbers: $phoneNumbers)';
}


}

/// @nodoc
abstract mixin class $PaymentHandlesDtoCopyWith<$Res>  {
  factory $PaymentHandlesDtoCopyWith(PaymentHandlesDto value, $Res Function(PaymentHandlesDto) _then) = _$PaymentHandlesDtoCopyWithImpl;
@useResult
$Res call({
 bool sharingPhoneNumber, List<SharedPhoneNumberDto> phoneNumbers
});




}
/// @nodoc
class _$PaymentHandlesDtoCopyWithImpl<$Res>
    implements $PaymentHandlesDtoCopyWith<$Res> {
  _$PaymentHandlesDtoCopyWithImpl(this._self, this._then);

  final PaymentHandlesDto _self;
  final $Res Function(PaymentHandlesDto) _then;

/// Create a copy of PaymentHandlesDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sharingPhoneNumber = null,Object? phoneNumbers = null,}) {
  return _then(_self.copyWith(
sharingPhoneNumber: null == sharingPhoneNumber ? _self.sharingPhoneNumber : sharingPhoneNumber // ignore: cast_nullable_to_non_nullable
as bool,phoneNumbers: null == phoneNumbers ? _self.phoneNumbers : phoneNumbers // ignore: cast_nullable_to_non_nullable
as List<SharedPhoneNumberDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentHandlesDto].
extension PaymentHandlesDtoPatterns on PaymentHandlesDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentHandlesDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentHandlesDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentHandlesDto value)  $default,){
final _that = this;
switch (_that) {
case _PaymentHandlesDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentHandlesDto value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentHandlesDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool sharingPhoneNumber,  List<SharedPhoneNumberDto> phoneNumbers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentHandlesDto() when $default != null:
return $default(_that.sharingPhoneNumber,_that.phoneNumbers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool sharingPhoneNumber,  List<SharedPhoneNumberDto> phoneNumbers)  $default,) {final _that = this;
switch (_that) {
case _PaymentHandlesDto():
return $default(_that.sharingPhoneNumber,_that.phoneNumbers);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool sharingPhoneNumber,  List<SharedPhoneNumberDto> phoneNumbers)?  $default,) {final _that = this;
switch (_that) {
case _PaymentHandlesDto() when $default != null:
return $default(_that.sharingPhoneNumber,_that.phoneNumbers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentHandlesDto implements PaymentHandlesDto {
  const _PaymentHandlesDto({this.sharingPhoneNumber = false, final  List<SharedPhoneNumberDto> phoneNumbers = const <SharedPhoneNumberDto>[]}): _phoneNumbers = phoneNumbers;
  factory _PaymentHandlesDto.fromJson(Map<String, dynamic> json) => _$PaymentHandlesDtoFromJson(json);

/// Whether **the caller** is sharing their own number with this household.
///
/// Read from the `SharePhoneForPayments` flag on the caller's membership
/// row, not from whether a number exists - so this can still be `true`
/// for somebody whose account has no number at all, in which case they
/// appear in nobody's [phoneNumbers] and adding a number republishes it
/// here with no further action.
///
/// That combination is now rare rather than routine: removing a number
/// clears this flag in every household, so only accounts that removed
/// theirs before Identity started publishing the revocation are still in
/// it. The server stays the authority either way. See `PhoneSharingCard`.
@override@JsonKey() final  bool sharingPhoneNumber;
/// One entry per member who has both opted in *and* has a number.
///
/// A member who opted out and a member with no number are field-for-field
/// identical on the wire - both are simply absent - and the server has a
/// test asserting exactly that. Nothing in this app may render a sentence
/// that distinguishes them, because every available phrasing ("Anna hasn't
/// shared her number") asserts that Anna has one.
 final  List<SharedPhoneNumberDto> _phoneNumbers;
/// One entry per member who has both opted in *and* has a number.
///
/// A member who opted out and a member with no number are field-for-field
/// identical on the wire - both are simply absent - and the server has a
/// test asserting exactly that. Nothing in this app may render a sentence
/// that distinguishes them, because every available phrasing ("Anna hasn't
/// shared her number") asserts that Anna has one.
@override@JsonKey() List<SharedPhoneNumberDto> get phoneNumbers {
  if (_phoneNumbers is EqualUnmodifiableListView) return _phoneNumbers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_phoneNumbers);
}


/// Create a copy of PaymentHandlesDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentHandlesDtoCopyWith<_PaymentHandlesDto> get copyWith => __$PaymentHandlesDtoCopyWithImpl<_PaymentHandlesDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentHandlesDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentHandlesDto&&(identical(other.sharingPhoneNumber, sharingPhoneNumber) || other.sharingPhoneNumber == sharingPhoneNumber)&&const DeepCollectionEquality().equals(other._phoneNumbers, _phoneNumbers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sharingPhoneNumber,const DeepCollectionEquality().hash(_phoneNumbers));

@override
String toString() {
  return 'PaymentHandlesDto(sharingPhoneNumber: $sharingPhoneNumber, phoneNumbers: $phoneNumbers)';
}


}

/// @nodoc
abstract mixin class _$PaymentHandlesDtoCopyWith<$Res> implements $PaymentHandlesDtoCopyWith<$Res> {
  factory _$PaymentHandlesDtoCopyWith(_PaymentHandlesDto value, $Res Function(_PaymentHandlesDto) _then) = __$PaymentHandlesDtoCopyWithImpl;
@override @useResult
$Res call({
 bool sharingPhoneNumber, List<SharedPhoneNumberDto> phoneNumbers
});




}
/// @nodoc
class __$PaymentHandlesDtoCopyWithImpl<$Res>
    implements _$PaymentHandlesDtoCopyWith<$Res> {
  __$PaymentHandlesDtoCopyWithImpl(this._self, this._then);

  final _PaymentHandlesDto _self;
  final $Res Function(_PaymentHandlesDto) _then;

/// Create a copy of PaymentHandlesDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sharingPhoneNumber = null,Object? phoneNumbers = null,}) {
  return _then(_PaymentHandlesDto(
sharingPhoneNumber: null == sharingPhoneNumber ? _self.sharingPhoneNumber : sharingPhoneNumber // ignore: cast_nullable_to_non_nullable
as bool,phoneNumbers: null == phoneNumbers ? _self._phoneNumbers : phoneNumbers // ignore: cast_nullable_to_non_nullable
as List<SharedPhoneNumberDto>,
  ));
}


}


/// @nodoc
mixin _$SharedPhoneNumberDto {

 String get userId;/// E.164, normalised by Identity on write. Plain text, readable by the
/// server, and checked by nothing.
 String get phoneNumber;/// The account's last-updated stamp rather than a phone-specific one, so
/// it moves when anything about the account moves. Not shown as "number
/// last changed", which it isn't.
 DateTime? get updatedAt;
/// Create a copy of SharedPhoneNumberDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SharedPhoneNumberDtoCopyWith<SharedPhoneNumberDto> get copyWith => _$SharedPhoneNumberDtoCopyWithImpl<SharedPhoneNumberDto>(this as SharedPhoneNumberDto, _$identity);

  /// Serializes this SharedPhoneNumberDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SharedPhoneNumberDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,phoneNumber,updatedAt);

@override
String toString() {
  return 'SharedPhoneNumberDto(userId: $userId, phoneNumber: $phoneNumber, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SharedPhoneNumberDtoCopyWith<$Res>  {
  factory $SharedPhoneNumberDtoCopyWith(SharedPhoneNumberDto value, $Res Function(SharedPhoneNumberDto) _then) = _$SharedPhoneNumberDtoCopyWithImpl;
@useResult
$Res call({
 String userId, String phoneNumber, DateTime? updatedAt
});




}
/// @nodoc
class _$SharedPhoneNumberDtoCopyWithImpl<$Res>
    implements $SharedPhoneNumberDtoCopyWith<$Res> {
  _$SharedPhoneNumberDtoCopyWithImpl(this._self, this._then);

  final SharedPhoneNumberDto _self;
  final $Res Function(SharedPhoneNumberDto) _then;

/// Create a copy of SharedPhoneNumberDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? phoneNumber = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SharedPhoneNumberDto].
extension SharedPhoneNumberDtoPatterns on SharedPhoneNumberDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SharedPhoneNumberDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SharedPhoneNumberDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SharedPhoneNumberDto value)  $default,){
final _that = this;
switch (_that) {
case _SharedPhoneNumberDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SharedPhoneNumberDto value)?  $default,){
final _that = this;
switch (_that) {
case _SharedPhoneNumberDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String phoneNumber,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SharedPhoneNumberDto() when $default != null:
return $default(_that.userId,_that.phoneNumber,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String phoneNumber,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SharedPhoneNumberDto():
return $default(_that.userId,_that.phoneNumber,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String phoneNumber,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SharedPhoneNumberDto() when $default != null:
return $default(_that.userId,_that.phoneNumber,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _SharedPhoneNumberDto implements SharedPhoneNumberDto {
  const _SharedPhoneNumberDto({required this.userId, required this.phoneNumber, this.updatedAt});
  factory _SharedPhoneNumberDto.fromJson(Map<String, dynamic> json) => _$SharedPhoneNumberDtoFromJson(json);

@override final  String userId;
/// E.164, normalised by Identity on write. Plain text, readable by the
/// server, and checked by nothing.
@override final  String phoneNumber;
/// The account's last-updated stamp rather than a phone-specific one, so
/// it moves when anything about the account moves. Not shown as "number
/// last changed", which it isn't.
@override final  DateTime? updatedAt;

/// Create a copy of SharedPhoneNumberDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SharedPhoneNumberDtoCopyWith<_SharedPhoneNumberDto> get copyWith => __$SharedPhoneNumberDtoCopyWithImpl<_SharedPhoneNumberDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SharedPhoneNumberDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SharedPhoneNumberDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,phoneNumber,updatedAt);

@override
String toString() {
  return 'SharedPhoneNumberDto(userId: $userId, phoneNumber: $phoneNumber, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SharedPhoneNumberDtoCopyWith<$Res> implements $SharedPhoneNumberDtoCopyWith<$Res> {
  factory _$SharedPhoneNumberDtoCopyWith(_SharedPhoneNumberDto value, $Res Function(_SharedPhoneNumberDto) _then) = __$SharedPhoneNumberDtoCopyWithImpl;
@override @useResult
$Res call({
 String userId, String phoneNumber, DateTime? updatedAt
});




}
/// @nodoc
class __$SharedPhoneNumberDtoCopyWithImpl<$Res>
    implements _$SharedPhoneNumberDtoCopyWith<$Res> {
  __$SharedPhoneNumberDtoCopyWithImpl(this._self, this._then);

  final _SharedPhoneNumberDto _self;
  final $Res Function(_SharedPhoneNumberDto) _then;

/// Create a copy of SharedPhoneNumberDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? phoneNumber = null,Object? updatedAt = freezed,}) {
  return _then(_SharedPhoneNumberDto(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
