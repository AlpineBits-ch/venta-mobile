// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ledger_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExpenseShareDto {

 String get userId;/// Weight or exact minor amount, depending on the expense's
/// [ExpenseDto.splitKind]; ignored entirely for [SplitKind.equal].
 int get shareValue;/// What this person actually owes, in minor units - computed server-side,
/// including the remainder distribution.
 int get amountMinor;
/// Create a copy of ExpenseShareDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpenseShareDtoCopyWith<ExpenseShareDto> get copyWith => _$ExpenseShareDtoCopyWithImpl<ExpenseShareDto>(this as ExpenseShareDto, _$identity);

  /// Serializes this ExpenseShareDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpenseShareDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.shareValue, shareValue) || other.shareValue == shareValue)&&(identical(other.amountMinor, amountMinor) || other.amountMinor == amountMinor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,shareValue,amountMinor);

@override
String toString() {
  return 'ExpenseShareDto(userId: $userId, shareValue: $shareValue, amountMinor: $amountMinor)';
}


}

/// @nodoc
abstract mixin class $ExpenseShareDtoCopyWith<$Res>  {
  factory $ExpenseShareDtoCopyWith(ExpenseShareDto value, $Res Function(ExpenseShareDto) _then) = _$ExpenseShareDtoCopyWithImpl;
@useResult
$Res call({
 String userId, int shareValue, int amountMinor
});




}
/// @nodoc
class _$ExpenseShareDtoCopyWithImpl<$Res>
    implements $ExpenseShareDtoCopyWith<$Res> {
  _$ExpenseShareDtoCopyWithImpl(this._self, this._then);

  final ExpenseShareDto _self;
  final $Res Function(ExpenseShareDto) _then;

/// Create a copy of ExpenseShareDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? shareValue = null,Object? amountMinor = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,shareValue: null == shareValue ? _self.shareValue : shareValue // ignore: cast_nullable_to_non_nullable
as int,amountMinor: null == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ExpenseShareDto].
extension ExpenseShareDtoPatterns on ExpenseShareDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpenseShareDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpenseShareDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpenseShareDto value)  $default,){
final _that = this;
switch (_that) {
case _ExpenseShareDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpenseShareDto value)?  $default,){
final _that = this;
switch (_that) {
case _ExpenseShareDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  int shareValue,  int amountMinor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpenseShareDto() when $default != null:
return $default(_that.userId,_that.shareValue,_that.amountMinor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  int shareValue,  int amountMinor)  $default,) {final _that = this;
switch (_that) {
case _ExpenseShareDto():
return $default(_that.userId,_that.shareValue,_that.amountMinor);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  int shareValue,  int amountMinor)?  $default,) {final _that = this;
switch (_that) {
case _ExpenseShareDto() when $default != null:
return $default(_that.userId,_that.shareValue,_that.amountMinor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExpenseShareDto implements ExpenseShareDto {
  const _ExpenseShareDto({this.userId = '', this.shareValue = 0, this.amountMinor = 0});
  factory _ExpenseShareDto.fromJson(Map<String, dynamic> json) => _$ExpenseShareDtoFromJson(json);

@override@JsonKey() final  String userId;
/// Weight or exact minor amount, depending on the expense's
/// [ExpenseDto.splitKind]; ignored entirely for [SplitKind.equal].
@override@JsonKey() final  int shareValue;
/// What this person actually owes, in minor units - computed server-side,
/// including the remainder distribution.
@override@JsonKey() final  int amountMinor;

/// Create a copy of ExpenseShareDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpenseShareDtoCopyWith<_ExpenseShareDto> get copyWith => __$ExpenseShareDtoCopyWithImpl<_ExpenseShareDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpenseShareDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpenseShareDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.shareValue, shareValue) || other.shareValue == shareValue)&&(identical(other.amountMinor, amountMinor) || other.amountMinor == amountMinor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,shareValue,amountMinor);

@override
String toString() {
  return 'ExpenseShareDto(userId: $userId, shareValue: $shareValue, amountMinor: $amountMinor)';
}


}

/// @nodoc
abstract mixin class _$ExpenseShareDtoCopyWith<$Res> implements $ExpenseShareDtoCopyWith<$Res> {
  factory _$ExpenseShareDtoCopyWith(_ExpenseShareDto value, $Res Function(_ExpenseShareDto) _then) = __$ExpenseShareDtoCopyWithImpl;
@override @useResult
$Res call({
 String userId, int shareValue, int amountMinor
});




}
/// @nodoc
class __$ExpenseShareDtoCopyWithImpl<$Res>
    implements _$ExpenseShareDtoCopyWith<$Res> {
  __$ExpenseShareDtoCopyWithImpl(this._self, this._then);

  final _ExpenseShareDto _self;
  final $Res Function(_ExpenseShareDto) _then;

/// Create a copy of ExpenseShareDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? shareValue = null,Object? amountMinor = null,}) {
  return _then(_ExpenseShareDto(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,shareValue: null == shareValue ? _self.shareValue : shareValue // ignore: cast_nullable_to_non_nullable
as int,amountMinor: null == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ExpenseDto {

 String get id; String get channelId;/// Who actually paid - often not [createdByUserId], who merely typed it in.
 String get payerUserId; String get description; int get amountMinor; String get currency; DateTime? get occurredAt;@JsonKey(unknownEnumValue: SplitKind.equal) SplitKind get splitKind; String get createdByUserId; List<ExpenseShareDto> get shares;
/// Create a copy of ExpenseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpenseDtoCopyWith<ExpenseDto> get copyWith => _$ExpenseDtoCopyWithImpl<ExpenseDto>(this as ExpenseDto, _$identity);

  /// Serializes this ExpenseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpenseDto&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.payerUserId, payerUserId) || other.payerUserId == payerUserId)&&(identical(other.description, description) || other.description == description)&&(identical(other.amountMinor, amountMinor) || other.amountMinor == amountMinor)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.splitKind, splitKind) || other.splitKind == splitKind)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId)&&const DeepCollectionEquality().equals(other.shares, shares));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,payerUserId,description,amountMinor,currency,occurredAt,splitKind,createdByUserId,const DeepCollectionEquality().hash(shares));

@override
String toString() {
  return 'ExpenseDto(id: $id, channelId: $channelId, payerUserId: $payerUserId, description: $description, amountMinor: $amountMinor, currency: $currency, occurredAt: $occurredAt, splitKind: $splitKind, createdByUserId: $createdByUserId, shares: $shares)';
}


}

/// @nodoc
abstract mixin class $ExpenseDtoCopyWith<$Res>  {
  factory $ExpenseDtoCopyWith(ExpenseDto value, $Res Function(ExpenseDto) _then) = _$ExpenseDtoCopyWithImpl;
@useResult
$Res call({
 String id, String channelId, String payerUserId, String description, int amountMinor, String currency, DateTime? occurredAt,@JsonKey(unknownEnumValue: SplitKind.equal) SplitKind splitKind, String createdByUserId, List<ExpenseShareDto> shares
});




}
/// @nodoc
class _$ExpenseDtoCopyWithImpl<$Res>
    implements $ExpenseDtoCopyWith<$Res> {
  _$ExpenseDtoCopyWithImpl(this._self, this._then);

  final ExpenseDto _self;
  final $Res Function(ExpenseDto) _then;

/// Create a copy of ExpenseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? channelId = null,Object? payerUserId = null,Object? description = null,Object? amountMinor = null,Object? currency = null,Object? occurredAt = freezed,Object? splitKind = null,Object? createdByUserId = null,Object? shares = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,payerUserId: null == payerUserId ? _self.payerUserId : payerUserId // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,amountMinor: null == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,occurredAt: freezed == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,splitKind: null == splitKind ? _self.splitKind : splitKind // ignore: cast_nullable_to_non_nullable
as SplitKind,createdByUserId: null == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String,shares: null == shares ? _self.shares : shares // ignore: cast_nullable_to_non_nullable
as List<ExpenseShareDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExpenseDto].
extension ExpenseDtoPatterns on ExpenseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpenseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpenseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpenseDto value)  $default,){
final _that = this;
switch (_that) {
case _ExpenseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpenseDto value)?  $default,){
final _that = this;
switch (_that) {
case _ExpenseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String channelId,  String payerUserId,  String description,  int amountMinor,  String currency,  DateTime? occurredAt, @JsonKey(unknownEnumValue: SplitKind.equal)  SplitKind splitKind,  String createdByUserId,  List<ExpenseShareDto> shares)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpenseDto() when $default != null:
return $default(_that.id,_that.channelId,_that.payerUserId,_that.description,_that.amountMinor,_that.currency,_that.occurredAt,_that.splitKind,_that.createdByUserId,_that.shares);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String channelId,  String payerUserId,  String description,  int amountMinor,  String currency,  DateTime? occurredAt, @JsonKey(unknownEnumValue: SplitKind.equal)  SplitKind splitKind,  String createdByUserId,  List<ExpenseShareDto> shares)  $default,) {final _that = this;
switch (_that) {
case _ExpenseDto():
return $default(_that.id,_that.channelId,_that.payerUserId,_that.description,_that.amountMinor,_that.currency,_that.occurredAt,_that.splitKind,_that.createdByUserId,_that.shares);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String channelId,  String payerUserId,  String description,  int amountMinor,  String currency,  DateTime? occurredAt, @JsonKey(unknownEnumValue: SplitKind.equal)  SplitKind splitKind,  String createdByUserId,  List<ExpenseShareDto> shares)?  $default,) {final _that = this;
switch (_that) {
case _ExpenseDto() when $default != null:
return $default(_that.id,_that.channelId,_that.payerUserId,_that.description,_that.amountMinor,_that.currency,_that.occurredAt,_that.splitKind,_that.createdByUserId,_that.shares);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _ExpenseDto implements ExpenseDto {
  const _ExpenseDto({required this.id, required this.channelId, this.payerUserId = '', this.description = '', this.amountMinor = 0, this.currency = 'CHF', this.occurredAt, @JsonKey(unknownEnumValue: SplitKind.equal) this.splitKind = SplitKind.equal, this.createdByUserId = '', final  List<ExpenseShareDto> shares = const <ExpenseShareDto>[]}): _shares = shares;
  factory _ExpenseDto.fromJson(Map<String, dynamic> json) => _$ExpenseDtoFromJson(json);

@override final  String id;
@override final  String channelId;
/// Who actually paid - often not [createdByUserId], who merely typed it in.
@override@JsonKey() final  String payerUserId;
@override@JsonKey() final  String description;
@override@JsonKey() final  int amountMinor;
@override@JsonKey() final  String currency;
@override final  DateTime? occurredAt;
@override@JsonKey(unknownEnumValue: SplitKind.equal) final  SplitKind splitKind;
@override@JsonKey() final  String createdByUserId;
 final  List<ExpenseShareDto> _shares;
@override@JsonKey() List<ExpenseShareDto> get shares {
  if (_shares is EqualUnmodifiableListView) return _shares;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_shares);
}


/// Create a copy of ExpenseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpenseDtoCopyWith<_ExpenseDto> get copyWith => __$ExpenseDtoCopyWithImpl<_ExpenseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpenseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpenseDto&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.payerUserId, payerUserId) || other.payerUserId == payerUserId)&&(identical(other.description, description) || other.description == description)&&(identical(other.amountMinor, amountMinor) || other.amountMinor == amountMinor)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.splitKind, splitKind) || other.splitKind == splitKind)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId)&&const DeepCollectionEquality().equals(other._shares, _shares));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,payerUserId,description,amountMinor,currency,occurredAt,splitKind,createdByUserId,const DeepCollectionEquality().hash(_shares));

@override
String toString() {
  return 'ExpenseDto(id: $id, channelId: $channelId, payerUserId: $payerUserId, description: $description, amountMinor: $amountMinor, currency: $currency, occurredAt: $occurredAt, splitKind: $splitKind, createdByUserId: $createdByUserId, shares: $shares)';
}


}

/// @nodoc
abstract mixin class _$ExpenseDtoCopyWith<$Res> implements $ExpenseDtoCopyWith<$Res> {
  factory _$ExpenseDtoCopyWith(_ExpenseDto value, $Res Function(_ExpenseDto) _then) = __$ExpenseDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String channelId, String payerUserId, String description, int amountMinor, String currency, DateTime? occurredAt,@JsonKey(unknownEnumValue: SplitKind.equal) SplitKind splitKind, String createdByUserId, List<ExpenseShareDto> shares
});




}
/// @nodoc
class __$ExpenseDtoCopyWithImpl<$Res>
    implements _$ExpenseDtoCopyWith<$Res> {
  __$ExpenseDtoCopyWithImpl(this._self, this._then);

  final _ExpenseDto _self;
  final $Res Function(_ExpenseDto) _then;

/// Create a copy of ExpenseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? channelId = null,Object? payerUserId = null,Object? description = null,Object? amountMinor = null,Object? currency = null,Object? occurredAt = freezed,Object? splitKind = null,Object? createdByUserId = null,Object? shares = null,}) {
  return _then(_ExpenseDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,payerUserId: null == payerUserId ? _self.payerUserId : payerUserId // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,amountMinor: null == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,occurredAt: freezed == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,splitKind: null == splitKind ? _self.splitKind : splitKind // ignore: cast_nullable_to_non_nullable
as SplitKind,createdByUserId: null == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String,shares: null == shares ? _self._shares : shares // ignore: cast_nullable_to_non_nullable
as List<ExpenseShareDto>,
  ));
}


}


/// @nodoc
mixin _$LedgerBalanceDto {

 String get userId; int get netMinor;
/// Create a copy of LedgerBalanceDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LedgerBalanceDtoCopyWith<LedgerBalanceDto> get copyWith => _$LedgerBalanceDtoCopyWithImpl<LedgerBalanceDto>(this as LedgerBalanceDto, _$identity);

  /// Serializes this LedgerBalanceDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LedgerBalanceDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.netMinor, netMinor) || other.netMinor == netMinor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,netMinor);

@override
String toString() {
  return 'LedgerBalanceDto(userId: $userId, netMinor: $netMinor)';
}


}

/// @nodoc
abstract mixin class $LedgerBalanceDtoCopyWith<$Res>  {
  factory $LedgerBalanceDtoCopyWith(LedgerBalanceDto value, $Res Function(LedgerBalanceDto) _then) = _$LedgerBalanceDtoCopyWithImpl;
@useResult
$Res call({
 String userId, int netMinor
});




}
/// @nodoc
class _$LedgerBalanceDtoCopyWithImpl<$Res>
    implements $LedgerBalanceDtoCopyWith<$Res> {
  _$LedgerBalanceDtoCopyWithImpl(this._self, this._then);

  final LedgerBalanceDto _self;
  final $Res Function(LedgerBalanceDto) _then;

/// Create a copy of LedgerBalanceDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? netMinor = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,netMinor: null == netMinor ? _self.netMinor : netMinor // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LedgerBalanceDto].
extension LedgerBalanceDtoPatterns on LedgerBalanceDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LedgerBalanceDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LedgerBalanceDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LedgerBalanceDto value)  $default,){
final _that = this;
switch (_that) {
case _LedgerBalanceDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LedgerBalanceDto value)?  $default,){
final _that = this;
switch (_that) {
case _LedgerBalanceDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  int netMinor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LedgerBalanceDto() when $default != null:
return $default(_that.userId,_that.netMinor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  int netMinor)  $default,) {final _that = this;
switch (_that) {
case _LedgerBalanceDto():
return $default(_that.userId,_that.netMinor);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  int netMinor)?  $default,) {final _that = this;
switch (_that) {
case _LedgerBalanceDto() when $default != null:
return $default(_that.userId,_that.netMinor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LedgerBalanceDto implements LedgerBalanceDto {
  const _LedgerBalanceDto({this.userId = '', this.netMinor = 0});
  factory _LedgerBalanceDto.fromJson(Map<String, dynamic> json) => _$LedgerBalanceDtoFromJson(json);

@override@JsonKey() final  String userId;
@override@JsonKey() final  int netMinor;

/// Create a copy of LedgerBalanceDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LedgerBalanceDtoCopyWith<_LedgerBalanceDto> get copyWith => __$LedgerBalanceDtoCopyWithImpl<_LedgerBalanceDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LedgerBalanceDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LedgerBalanceDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.netMinor, netMinor) || other.netMinor == netMinor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,netMinor);

@override
String toString() {
  return 'LedgerBalanceDto(userId: $userId, netMinor: $netMinor)';
}


}

/// @nodoc
abstract mixin class _$LedgerBalanceDtoCopyWith<$Res> implements $LedgerBalanceDtoCopyWith<$Res> {
  factory _$LedgerBalanceDtoCopyWith(_LedgerBalanceDto value, $Res Function(_LedgerBalanceDto) _then) = __$LedgerBalanceDtoCopyWithImpl;
@override @useResult
$Res call({
 String userId, int netMinor
});




}
/// @nodoc
class __$LedgerBalanceDtoCopyWithImpl<$Res>
    implements _$LedgerBalanceDtoCopyWith<$Res> {
  __$LedgerBalanceDtoCopyWithImpl(this._self, this._then);

  final _LedgerBalanceDto _self;
  final $Res Function(_LedgerBalanceDto) _then;

/// Create a copy of LedgerBalanceDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? netMinor = null,}) {
  return _then(_LedgerBalanceDto(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,netMinor: null == netMinor ? _self.netMinor : netMinor // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TransferSuggestionDto {

 String get fromUserId; String get toUserId; int get amountMinor;
/// Create a copy of TransferSuggestionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransferSuggestionDtoCopyWith<TransferSuggestionDto> get copyWith => _$TransferSuggestionDtoCopyWithImpl<TransferSuggestionDto>(this as TransferSuggestionDto, _$identity);

  /// Serializes this TransferSuggestionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransferSuggestionDto&&(identical(other.fromUserId, fromUserId) || other.fromUserId == fromUserId)&&(identical(other.toUserId, toUserId) || other.toUserId == toUserId)&&(identical(other.amountMinor, amountMinor) || other.amountMinor == amountMinor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fromUserId,toUserId,amountMinor);

@override
String toString() {
  return 'TransferSuggestionDto(fromUserId: $fromUserId, toUserId: $toUserId, amountMinor: $amountMinor)';
}


}

/// @nodoc
abstract mixin class $TransferSuggestionDtoCopyWith<$Res>  {
  factory $TransferSuggestionDtoCopyWith(TransferSuggestionDto value, $Res Function(TransferSuggestionDto) _then) = _$TransferSuggestionDtoCopyWithImpl;
@useResult
$Res call({
 String fromUserId, String toUserId, int amountMinor
});




}
/// @nodoc
class _$TransferSuggestionDtoCopyWithImpl<$Res>
    implements $TransferSuggestionDtoCopyWith<$Res> {
  _$TransferSuggestionDtoCopyWithImpl(this._self, this._then);

  final TransferSuggestionDto _self;
  final $Res Function(TransferSuggestionDto) _then;

/// Create a copy of TransferSuggestionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fromUserId = null,Object? toUserId = null,Object? amountMinor = null,}) {
  return _then(_self.copyWith(
fromUserId: null == fromUserId ? _self.fromUserId : fromUserId // ignore: cast_nullable_to_non_nullable
as String,toUserId: null == toUserId ? _self.toUserId : toUserId // ignore: cast_nullable_to_non_nullable
as String,amountMinor: null == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TransferSuggestionDto].
extension TransferSuggestionDtoPatterns on TransferSuggestionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransferSuggestionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransferSuggestionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransferSuggestionDto value)  $default,){
final _that = this;
switch (_that) {
case _TransferSuggestionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransferSuggestionDto value)?  $default,){
final _that = this;
switch (_that) {
case _TransferSuggestionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fromUserId,  String toUserId,  int amountMinor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransferSuggestionDto() when $default != null:
return $default(_that.fromUserId,_that.toUserId,_that.amountMinor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fromUserId,  String toUserId,  int amountMinor)  $default,) {final _that = this;
switch (_that) {
case _TransferSuggestionDto():
return $default(_that.fromUserId,_that.toUserId,_that.amountMinor);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fromUserId,  String toUserId,  int amountMinor)?  $default,) {final _that = this;
switch (_that) {
case _TransferSuggestionDto() when $default != null:
return $default(_that.fromUserId,_that.toUserId,_that.amountMinor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransferSuggestionDto implements TransferSuggestionDto {
  const _TransferSuggestionDto({this.fromUserId = '', this.toUserId = '', this.amountMinor = 0});
  factory _TransferSuggestionDto.fromJson(Map<String, dynamic> json) => _$TransferSuggestionDtoFromJson(json);

@override@JsonKey() final  String fromUserId;
@override@JsonKey() final  String toUserId;
@override@JsonKey() final  int amountMinor;

/// Create a copy of TransferSuggestionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransferSuggestionDtoCopyWith<_TransferSuggestionDto> get copyWith => __$TransferSuggestionDtoCopyWithImpl<_TransferSuggestionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransferSuggestionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransferSuggestionDto&&(identical(other.fromUserId, fromUserId) || other.fromUserId == fromUserId)&&(identical(other.toUserId, toUserId) || other.toUserId == toUserId)&&(identical(other.amountMinor, amountMinor) || other.amountMinor == amountMinor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fromUserId,toUserId,amountMinor);

@override
String toString() {
  return 'TransferSuggestionDto(fromUserId: $fromUserId, toUserId: $toUserId, amountMinor: $amountMinor)';
}


}

/// @nodoc
abstract mixin class _$TransferSuggestionDtoCopyWith<$Res> implements $TransferSuggestionDtoCopyWith<$Res> {
  factory _$TransferSuggestionDtoCopyWith(_TransferSuggestionDto value, $Res Function(_TransferSuggestionDto) _then) = __$TransferSuggestionDtoCopyWithImpl;
@override @useResult
$Res call({
 String fromUserId, String toUserId, int amountMinor
});




}
/// @nodoc
class __$TransferSuggestionDtoCopyWithImpl<$Res>
    implements _$TransferSuggestionDtoCopyWith<$Res> {
  __$TransferSuggestionDtoCopyWithImpl(this._self, this._then);

  final _TransferSuggestionDto _self;
  final $Res Function(_TransferSuggestionDto) _then;

/// Create a copy of TransferSuggestionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fromUserId = null,Object? toUserId = null,Object? amountMinor = null,}) {
  return _then(_TransferSuggestionDto(
fromUserId: null == fromUserId ? _self.fromUserId : fromUserId // ignore: cast_nullable_to_non_nullable
as String,toUserId: null == toUserId ? _self.toUserId : toUserId // ignore: cast_nullable_to_non_nullable
as String,amountMinor: null == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$LedgerConfigDto {

 String get channelId; String get currency;
/// Create a copy of LedgerConfigDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LedgerConfigDtoCopyWith<LedgerConfigDto> get copyWith => _$LedgerConfigDtoCopyWithImpl<LedgerConfigDto>(this as LedgerConfigDto, _$identity);

  /// Serializes this LedgerConfigDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LedgerConfigDto&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,channelId,currency);

@override
String toString() {
  return 'LedgerConfigDto(channelId: $channelId, currency: $currency)';
}


}

/// @nodoc
abstract mixin class $LedgerConfigDtoCopyWith<$Res>  {
  factory $LedgerConfigDtoCopyWith(LedgerConfigDto value, $Res Function(LedgerConfigDto) _then) = _$LedgerConfigDtoCopyWithImpl;
@useResult
$Res call({
 String channelId, String currency
});




}
/// @nodoc
class _$LedgerConfigDtoCopyWithImpl<$Res>
    implements $LedgerConfigDtoCopyWith<$Res> {
  _$LedgerConfigDtoCopyWithImpl(this._self, this._then);

  final LedgerConfigDto _self;
  final $Res Function(LedgerConfigDto) _then;

/// Create a copy of LedgerConfigDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? channelId = null,Object? currency = null,}) {
  return _then(_self.copyWith(
channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LedgerConfigDto].
extension LedgerConfigDtoPatterns on LedgerConfigDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LedgerConfigDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LedgerConfigDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LedgerConfigDto value)  $default,){
final _that = this;
switch (_that) {
case _LedgerConfigDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LedgerConfigDto value)?  $default,){
final _that = this;
switch (_that) {
case _LedgerConfigDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String channelId,  String currency)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LedgerConfigDto() when $default != null:
return $default(_that.channelId,_that.currency);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String channelId,  String currency)  $default,) {final _that = this;
switch (_that) {
case _LedgerConfigDto():
return $default(_that.channelId,_that.currency);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String channelId,  String currency)?  $default,) {final _that = this;
switch (_that) {
case _LedgerConfigDto() when $default != null:
return $default(_that.channelId,_that.currency);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LedgerConfigDto implements LedgerConfigDto {
  const _LedgerConfigDto({this.channelId = '', this.currency = 'CHF'});
  factory _LedgerConfigDto.fromJson(Map<String, dynamic> json) => _$LedgerConfigDtoFromJson(json);

@override@JsonKey() final  String channelId;
@override@JsonKey() final  String currency;

/// Create a copy of LedgerConfigDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LedgerConfigDtoCopyWith<_LedgerConfigDto> get copyWith => __$LedgerConfigDtoCopyWithImpl<_LedgerConfigDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LedgerConfigDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LedgerConfigDto&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,channelId,currency);

@override
String toString() {
  return 'LedgerConfigDto(channelId: $channelId, currency: $currency)';
}


}

/// @nodoc
abstract mixin class _$LedgerConfigDtoCopyWith<$Res> implements $LedgerConfigDtoCopyWith<$Res> {
  factory _$LedgerConfigDtoCopyWith(_LedgerConfigDto value, $Res Function(_LedgerConfigDto) _then) = __$LedgerConfigDtoCopyWithImpl;
@override @useResult
$Res call({
 String channelId, String currency
});




}
/// @nodoc
class __$LedgerConfigDtoCopyWithImpl<$Res>
    implements _$LedgerConfigDtoCopyWith<$Res> {
  __$LedgerConfigDtoCopyWithImpl(this._self, this._then);

  final _LedgerConfigDto _self;
  final $Res Function(_LedgerConfigDto) _then;

/// Create a copy of LedgerConfigDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? channelId = null,Object? currency = null,}) {
  return _then(_LedgerConfigDto(
channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
