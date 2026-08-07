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
 String get payerUserId; String get description; int get amountMinor; String get currency; DateTime? get occurredAt;@JsonKey(unknownEnumValue: SplitKind.equal) SplitKind get splitKind; String get createdByUserId; List<ExpenseShareDto> get shares;/// What it was for. Coarse on purpose - see [ExpenseCategory]. Expenses
/// that predate the field arrive as `Uncategorized`, which is a real
/// bucket in the rollup rather than a synonym for "Other".
@JsonKey(unknownEnumValue: ExpenseCategory.uncategorized) ExpenseCategory get category;
/// Create a copy of ExpenseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpenseDtoCopyWith<ExpenseDto> get copyWith => _$ExpenseDtoCopyWithImpl<ExpenseDto>(this as ExpenseDto, _$identity);

  /// Serializes this ExpenseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpenseDto&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.payerUserId, payerUserId) || other.payerUserId == payerUserId)&&(identical(other.description, description) || other.description == description)&&(identical(other.amountMinor, amountMinor) || other.amountMinor == amountMinor)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.splitKind, splitKind) || other.splitKind == splitKind)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId)&&const DeepCollectionEquality().equals(other.shares, shares)&&(identical(other.category, category) || other.category == category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,payerUserId,description,amountMinor,currency,occurredAt,splitKind,createdByUserId,const DeepCollectionEquality().hash(shares),category);

@override
String toString() {
  return 'ExpenseDto(id: $id, channelId: $channelId, payerUserId: $payerUserId, description: $description, amountMinor: $amountMinor, currency: $currency, occurredAt: $occurredAt, splitKind: $splitKind, createdByUserId: $createdByUserId, shares: $shares, category: $category)';
}


}

/// @nodoc
abstract mixin class $ExpenseDtoCopyWith<$Res>  {
  factory $ExpenseDtoCopyWith(ExpenseDto value, $Res Function(ExpenseDto) _then) = _$ExpenseDtoCopyWithImpl;
@useResult
$Res call({
 String id, String channelId, String payerUserId, String description, int amountMinor, String currency, DateTime? occurredAt,@JsonKey(unknownEnumValue: SplitKind.equal) SplitKind splitKind, String createdByUserId, List<ExpenseShareDto> shares,@JsonKey(unknownEnumValue: ExpenseCategory.uncategorized) ExpenseCategory category
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? channelId = null,Object? payerUserId = null,Object? description = null,Object? amountMinor = null,Object? currency = null,Object? occurredAt = freezed,Object? splitKind = null,Object? createdByUserId = null,Object? shares = null,Object? category = null,}) {
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
as List<ExpenseShareDto>,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ExpenseCategory,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String channelId,  String payerUserId,  String description,  int amountMinor,  String currency,  DateTime? occurredAt, @JsonKey(unknownEnumValue: SplitKind.equal)  SplitKind splitKind,  String createdByUserId,  List<ExpenseShareDto> shares, @JsonKey(unknownEnumValue: ExpenseCategory.uncategorized)  ExpenseCategory category)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpenseDto() when $default != null:
return $default(_that.id,_that.channelId,_that.payerUserId,_that.description,_that.amountMinor,_that.currency,_that.occurredAt,_that.splitKind,_that.createdByUserId,_that.shares,_that.category);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String channelId,  String payerUserId,  String description,  int amountMinor,  String currency,  DateTime? occurredAt, @JsonKey(unknownEnumValue: SplitKind.equal)  SplitKind splitKind,  String createdByUserId,  List<ExpenseShareDto> shares, @JsonKey(unknownEnumValue: ExpenseCategory.uncategorized)  ExpenseCategory category)  $default,) {final _that = this;
switch (_that) {
case _ExpenseDto():
return $default(_that.id,_that.channelId,_that.payerUserId,_that.description,_that.amountMinor,_that.currency,_that.occurredAt,_that.splitKind,_that.createdByUserId,_that.shares,_that.category);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String channelId,  String payerUserId,  String description,  int amountMinor,  String currency,  DateTime? occurredAt, @JsonKey(unknownEnumValue: SplitKind.equal)  SplitKind splitKind,  String createdByUserId,  List<ExpenseShareDto> shares, @JsonKey(unknownEnumValue: ExpenseCategory.uncategorized)  ExpenseCategory category)?  $default,) {final _that = this;
switch (_that) {
case _ExpenseDto() when $default != null:
return $default(_that.id,_that.channelId,_that.payerUserId,_that.description,_that.amountMinor,_that.currency,_that.occurredAt,_that.splitKind,_that.createdByUserId,_that.shares,_that.category);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _ExpenseDto implements ExpenseDto {
  const _ExpenseDto({required this.id, required this.channelId, this.payerUserId = '', this.description = '', this.amountMinor = 0, this.currency = 'CHF', this.occurredAt, @JsonKey(unknownEnumValue: SplitKind.equal) this.splitKind = SplitKind.equal, this.createdByUserId = '', final  List<ExpenseShareDto> shares = const <ExpenseShareDto>[], @JsonKey(unknownEnumValue: ExpenseCategory.uncategorized) this.category = ExpenseCategory.uncategorized}): _shares = shares;
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

/// What it was for. Coarse on purpose - see [ExpenseCategory]. Expenses
/// that predate the field arrive as `Uncategorized`, which is a real
/// bucket in the rollup rather than a synonym for "Other".
@override@JsonKey(unknownEnumValue: ExpenseCategory.uncategorized) final  ExpenseCategory category;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpenseDto&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.payerUserId, payerUserId) || other.payerUserId == payerUserId)&&(identical(other.description, description) || other.description == description)&&(identical(other.amountMinor, amountMinor) || other.amountMinor == amountMinor)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.splitKind, splitKind) || other.splitKind == splitKind)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId)&&const DeepCollectionEquality().equals(other._shares, _shares)&&(identical(other.category, category) || other.category == category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,payerUserId,description,amountMinor,currency,occurredAt,splitKind,createdByUserId,const DeepCollectionEquality().hash(_shares),category);

@override
String toString() {
  return 'ExpenseDto(id: $id, channelId: $channelId, payerUserId: $payerUserId, description: $description, amountMinor: $amountMinor, currency: $currency, occurredAt: $occurredAt, splitKind: $splitKind, createdByUserId: $createdByUserId, shares: $shares, category: $category)';
}


}

/// @nodoc
abstract mixin class _$ExpenseDtoCopyWith<$Res> implements $ExpenseDtoCopyWith<$Res> {
  factory _$ExpenseDtoCopyWith(_ExpenseDto value, $Res Function(_ExpenseDto) _then) = __$ExpenseDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String channelId, String payerUserId, String description, int amountMinor, String currency, DateTime? occurredAt,@JsonKey(unknownEnumValue: SplitKind.equal) SplitKind splitKind, String createdByUserId, List<ExpenseShareDto> shares,@JsonKey(unknownEnumValue: ExpenseCategory.uncategorized) ExpenseCategory category
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? channelId = null,Object? payerUserId = null,Object? description = null,Object? amountMinor = null,Object? currency = null,Object? occurredAt = freezed,Object? splitKind = null,Object? createdByUserId = null,Object? shares = null,Object? category = null,}) {
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
as List<ExpenseShareDto>,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ExpenseCategory,
  ));
}


}


/// @nodoc
mixin _$ExpensePageDto {

 List<ExpenseDto> get items; String? get nextCursor;
/// Create a copy of ExpensePageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpensePageDtoCopyWith<ExpensePageDto> get copyWith => _$ExpensePageDtoCopyWithImpl<ExpensePageDto>(this as ExpensePageDto, _$identity);

  /// Serializes this ExpensePageDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpensePageDto&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),nextCursor);

@override
String toString() {
  return 'ExpensePageDto(items: $items, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class $ExpensePageDtoCopyWith<$Res>  {
  factory $ExpensePageDtoCopyWith(ExpensePageDto value, $Res Function(ExpensePageDto) _then) = _$ExpensePageDtoCopyWithImpl;
@useResult
$Res call({
 List<ExpenseDto> items, String? nextCursor
});




}
/// @nodoc
class _$ExpensePageDtoCopyWithImpl<$Res>
    implements $ExpensePageDtoCopyWith<$Res> {
  _$ExpensePageDtoCopyWithImpl(this._self, this._then);

  final ExpensePageDto _self;
  final $Res Function(ExpensePageDto) _then;

/// Create a copy of ExpensePageDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? nextCursor = freezed,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ExpenseDto>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExpensePageDto].
extension ExpensePageDtoPatterns on ExpensePageDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpensePageDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpensePageDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpensePageDto value)  $default,){
final _that = this;
switch (_that) {
case _ExpensePageDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpensePageDto value)?  $default,){
final _that = this;
switch (_that) {
case _ExpensePageDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ExpenseDto> items,  String? nextCursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpensePageDto() when $default != null:
return $default(_that.items,_that.nextCursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ExpenseDto> items,  String? nextCursor)  $default,) {final _that = this;
switch (_that) {
case _ExpensePageDto():
return $default(_that.items,_that.nextCursor);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ExpenseDto> items,  String? nextCursor)?  $default,) {final _that = this;
switch (_that) {
case _ExpensePageDto() when $default != null:
return $default(_that.items,_that.nextCursor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExpensePageDto implements ExpensePageDto {
  const _ExpensePageDto({final  List<ExpenseDto> items = const <ExpenseDto>[], this.nextCursor}): _items = items;
  factory _ExpensePageDto.fromJson(Map<String, dynamic> json) => _$ExpensePageDtoFromJson(json);

 final  List<ExpenseDto> _items;
@override@JsonKey() List<ExpenseDto> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? nextCursor;

/// Create a copy of ExpensePageDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpensePageDtoCopyWith<_ExpensePageDto> get copyWith => __$ExpensePageDtoCopyWithImpl<_ExpensePageDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpensePageDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpensePageDto&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),nextCursor);

@override
String toString() {
  return 'ExpensePageDto(items: $items, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class _$ExpensePageDtoCopyWith<$Res> implements $ExpensePageDtoCopyWith<$Res> {
  factory _$ExpensePageDtoCopyWith(_ExpensePageDto value, $Res Function(_ExpensePageDto) _then) = __$ExpensePageDtoCopyWithImpl;
@override @useResult
$Res call({
 List<ExpenseDto> items, String? nextCursor
});




}
/// @nodoc
class __$ExpensePageDtoCopyWithImpl<$Res>
    implements _$ExpensePageDtoCopyWith<$Res> {
  __$ExpensePageDtoCopyWithImpl(this._self, this._then);

  final _ExpensePageDto _self;
  final $Res Function(_ExpensePageDto) _then;

/// Create a copy of ExpensePageDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? nextCursor = freezed,}) {
  return _then(_ExpensePageDto(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ExpenseDto>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
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
mixin _$LedgerSummaryDto {

 String get channelId; String get currency; DateTime? get from; DateTime? get to; int get totalMinor;/// The caller's own share of everything in the window - their half of the
/// shop, not what they happened to pay for. This is the number people
/// actually want.
 int get myShareMinor; List<LedgerCategoryTotalDto> get byCategory;/// **Not zero-filled.** A month with no spending is absent rather than
/// present as a zero, so a chart must not draw the gap as a data point.
 List<LedgerPeriodTotalDto> get byPeriod; List<LedgerPayerTotalDto> get byPayer;/// The requested window was longer than the cap and was shortened. Shown
/// rather than silently applied: a total that quietly covers less than what
/// was asked for is a number somebody will act on and be wrong about.
 bool get clamped;
/// Create a copy of LedgerSummaryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LedgerSummaryDtoCopyWith<LedgerSummaryDto> get copyWith => _$LedgerSummaryDtoCopyWithImpl<LedgerSummaryDto>(this as LedgerSummaryDto, _$identity);

  /// Serializes this LedgerSummaryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LedgerSummaryDto&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.totalMinor, totalMinor) || other.totalMinor == totalMinor)&&(identical(other.myShareMinor, myShareMinor) || other.myShareMinor == myShareMinor)&&const DeepCollectionEquality().equals(other.byCategory, byCategory)&&const DeepCollectionEquality().equals(other.byPeriod, byPeriod)&&const DeepCollectionEquality().equals(other.byPayer, byPayer)&&(identical(other.clamped, clamped) || other.clamped == clamped));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,channelId,currency,from,to,totalMinor,myShareMinor,const DeepCollectionEquality().hash(byCategory),const DeepCollectionEquality().hash(byPeriod),const DeepCollectionEquality().hash(byPayer),clamped);

@override
String toString() {
  return 'LedgerSummaryDto(channelId: $channelId, currency: $currency, from: $from, to: $to, totalMinor: $totalMinor, myShareMinor: $myShareMinor, byCategory: $byCategory, byPeriod: $byPeriod, byPayer: $byPayer, clamped: $clamped)';
}


}

/// @nodoc
abstract mixin class $LedgerSummaryDtoCopyWith<$Res>  {
  factory $LedgerSummaryDtoCopyWith(LedgerSummaryDto value, $Res Function(LedgerSummaryDto) _then) = _$LedgerSummaryDtoCopyWithImpl;
@useResult
$Res call({
 String channelId, String currency, DateTime? from, DateTime? to, int totalMinor, int myShareMinor, List<LedgerCategoryTotalDto> byCategory, List<LedgerPeriodTotalDto> byPeriod, List<LedgerPayerTotalDto> byPayer, bool clamped
});




}
/// @nodoc
class _$LedgerSummaryDtoCopyWithImpl<$Res>
    implements $LedgerSummaryDtoCopyWith<$Res> {
  _$LedgerSummaryDtoCopyWithImpl(this._self, this._then);

  final LedgerSummaryDto _self;
  final $Res Function(LedgerSummaryDto) _then;

/// Create a copy of LedgerSummaryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? channelId = null,Object? currency = null,Object? from = freezed,Object? to = freezed,Object? totalMinor = null,Object? myShareMinor = null,Object? byCategory = null,Object? byPeriod = null,Object? byPayer = null,Object? clamped = null,}) {
  return _then(_self.copyWith(
channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime?,totalMinor: null == totalMinor ? _self.totalMinor : totalMinor // ignore: cast_nullable_to_non_nullable
as int,myShareMinor: null == myShareMinor ? _self.myShareMinor : myShareMinor // ignore: cast_nullable_to_non_nullable
as int,byCategory: null == byCategory ? _self.byCategory : byCategory // ignore: cast_nullable_to_non_nullable
as List<LedgerCategoryTotalDto>,byPeriod: null == byPeriod ? _self.byPeriod : byPeriod // ignore: cast_nullable_to_non_nullable
as List<LedgerPeriodTotalDto>,byPayer: null == byPayer ? _self.byPayer : byPayer // ignore: cast_nullable_to_non_nullable
as List<LedgerPayerTotalDto>,clamped: null == clamped ? _self.clamped : clamped // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LedgerSummaryDto].
extension LedgerSummaryDtoPatterns on LedgerSummaryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LedgerSummaryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LedgerSummaryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LedgerSummaryDto value)  $default,){
final _that = this;
switch (_that) {
case _LedgerSummaryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LedgerSummaryDto value)?  $default,){
final _that = this;
switch (_that) {
case _LedgerSummaryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String channelId,  String currency,  DateTime? from,  DateTime? to,  int totalMinor,  int myShareMinor,  List<LedgerCategoryTotalDto> byCategory,  List<LedgerPeriodTotalDto> byPeriod,  List<LedgerPayerTotalDto> byPayer,  bool clamped)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LedgerSummaryDto() when $default != null:
return $default(_that.channelId,_that.currency,_that.from,_that.to,_that.totalMinor,_that.myShareMinor,_that.byCategory,_that.byPeriod,_that.byPayer,_that.clamped);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String channelId,  String currency,  DateTime? from,  DateTime? to,  int totalMinor,  int myShareMinor,  List<LedgerCategoryTotalDto> byCategory,  List<LedgerPeriodTotalDto> byPeriod,  List<LedgerPayerTotalDto> byPayer,  bool clamped)  $default,) {final _that = this;
switch (_that) {
case _LedgerSummaryDto():
return $default(_that.channelId,_that.currency,_that.from,_that.to,_that.totalMinor,_that.myShareMinor,_that.byCategory,_that.byPeriod,_that.byPayer,_that.clamped);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String channelId,  String currency,  DateTime? from,  DateTime? to,  int totalMinor,  int myShareMinor,  List<LedgerCategoryTotalDto> byCategory,  List<LedgerPeriodTotalDto> byPeriod,  List<LedgerPayerTotalDto> byPayer,  bool clamped)?  $default,) {final _that = this;
switch (_that) {
case _LedgerSummaryDto() when $default != null:
return $default(_that.channelId,_that.currency,_that.from,_that.to,_that.totalMinor,_that.myShareMinor,_that.byCategory,_that.byPeriod,_that.byPayer,_that.clamped);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _LedgerSummaryDto implements LedgerSummaryDto {
  const _LedgerSummaryDto({this.channelId = '', this.currency = 'CHF', this.from, this.to, this.totalMinor = 0, this.myShareMinor = 0, final  List<LedgerCategoryTotalDto> byCategory = const <LedgerCategoryTotalDto>[], final  List<LedgerPeriodTotalDto> byPeriod = const <LedgerPeriodTotalDto>[], final  List<LedgerPayerTotalDto> byPayer = const <LedgerPayerTotalDto>[], this.clamped = false}): _byCategory = byCategory,_byPeriod = byPeriod,_byPayer = byPayer;
  factory _LedgerSummaryDto.fromJson(Map<String, dynamic> json) => _$LedgerSummaryDtoFromJson(json);

@override@JsonKey() final  String channelId;
@override@JsonKey() final  String currency;
@override final  DateTime? from;
@override final  DateTime? to;
@override@JsonKey() final  int totalMinor;
/// The caller's own share of everything in the window - their half of the
/// shop, not what they happened to pay for. This is the number people
/// actually want.
@override@JsonKey() final  int myShareMinor;
 final  List<LedgerCategoryTotalDto> _byCategory;
@override@JsonKey() List<LedgerCategoryTotalDto> get byCategory {
  if (_byCategory is EqualUnmodifiableListView) return _byCategory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_byCategory);
}

/// **Not zero-filled.** A month with no spending is absent rather than
/// present as a zero, so a chart must not draw the gap as a data point.
 final  List<LedgerPeriodTotalDto> _byPeriod;
/// **Not zero-filled.** A month with no spending is absent rather than
/// present as a zero, so a chart must not draw the gap as a data point.
@override@JsonKey() List<LedgerPeriodTotalDto> get byPeriod {
  if (_byPeriod is EqualUnmodifiableListView) return _byPeriod;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_byPeriod);
}

 final  List<LedgerPayerTotalDto> _byPayer;
@override@JsonKey() List<LedgerPayerTotalDto> get byPayer {
  if (_byPayer is EqualUnmodifiableListView) return _byPayer;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_byPayer);
}

/// The requested window was longer than the cap and was shortened. Shown
/// rather than silently applied: a total that quietly covers less than what
/// was asked for is a number somebody will act on and be wrong about.
@override@JsonKey() final  bool clamped;

/// Create a copy of LedgerSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LedgerSummaryDtoCopyWith<_LedgerSummaryDto> get copyWith => __$LedgerSummaryDtoCopyWithImpl<_LedgerSummaryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LedgerSummaryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LedgerSummaryDto&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.totalMinor, totalMinor) || other.totalMinor == totalMinor)&&(identical(other.myShareMinor, myShareMinor) || other.myShareMinor == myShareMinor)&&const DeepCollectionEquality().equals(other._byCategory, _byCategory)&&const DeepCollectionEquality().equals(other._byPeriod, _byPeriod)&&const DeepCollectionEquality().equals(other._byPayer, _byPayer)&&(identical(other.clamped, clamped) || other.clamped == clamped));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,channelId,currency,from,to,totalMinor,myShareMinor,const DeepCollectionEquality().hash(_byCategory),const DeepCollectionEquality().hash(_byPeriod),const DeepCollectionEquality().hash(_byPayer),clamped);

@override
String toString() {
  return 'LedgerSummaryDto(channelId: $channelId, currency: $currency, from: $from, to: $to, totalMinor: $totalMinor, myShareMinor: $myShareMinor, byCategory: $byCategory, byPeriod: $byPeriod, byPayer: $byPayer, clamped: $clamped)';
}


}

/// @nodoc
abstract mixin class _$LedgerSummaryDtoCopyWith<$Res> implements $LedgerSummaryDtoCopyWith<$Res> {
  factory _$LedgerSummaryDtoCopyWith(_LedgerSummaryDto value, $Res Function(_LedgerSummaryDto) _then) = __$LedgerSummaryDtoCopyWithImpl;
@override @useResult
$Res call({
 String channelId, String currency, DateTime? from, DateTime? to, int totalMinor, int myShareMinor, List<LedgerCategoryTotalDto> byCategory, List<LedgerPeriodTotalDto> byPeriod, List<LedgerPayerTotalDto> byPayer, bool clamped
});




}
/// @nodoc
class __$LedgerSummaryDtoCopyWithImpl<$Res>
    implements _$LedgerSummaryDtoCopyWith<$Res> {
  __$LedgerSummaryDtoCopyWithImpl(this._self, this._then);

  final _LedgerSummaryDto _self;
  final $Res Function(_LedgerSummaryDto) _then;

/// Create a copy of LedgerSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? channelId = null,Object? currency = null,Object? from = freezed,Object? to = freezed,Object? totalMinor = null,Object? myShareMinor = null,Object? byCategory = null,Object? byPeriod = null,Object? byPayer = null,Object? clamped = null,}) {
  return _then(_LedgerSummaryDto(
channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime?,totalMinor: null == totalMinor ? _self.totalMinor : totalMinor // ignore: cast_nullable_to_non_nullable
as int,myShareMinor: null == myShareMinor ? _self.myShareMinor : myShareMinor // ignore: cast_nullable_to_non_nullable
as int,byCategory: null == byCategory ? _self._byCategory : byCategory // ignore: cast_nullable_to_non_nullable
as List<LedgerCategoryTotalDto>,byPeriod: null == byPeriod ? _self._byPeriod : byPeriod // ignore: cast_nullable_to_non_nullable
as List<LedgerPeriodTotalDto>,byPayer: null == byPayer ? _self._byPayer : byPayer // ignore: cast_nullable_to_non_nullable
as List<LedgerPayerTotalDto>,clamped: null == clamped ? _self.clamped : clamped // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$LedgerCategoryTotalDto {

@JsonKey(unknownEnumValue: ExpenseCategory.uncategorized) ExpenseCategory get category; int get totalMinor; int get myShareMinor; int get count;
/// Create a copy of LedgerCategoryTotalDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LedgerCategoryTotalDtoCopyWith<LedgerCategoryTotalDto> get copyWith => _$LedgerCategoryTotalDtoCopyWithImpl<LedgerCategoryTotalDto>(this as LedgerCategoryTotalDto, _$identity);

  /// Serializes this LedgerCategoryTotalDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LedgerCategoryTotalDto&&(identical(other.category, category) || other.category == category)&&(identical(other.totalMinor, totalMinor) || other.totalMinor == totalMinor)&&(identical(other.myShareMinor, myShareMinor) || other.myShareMinor == myShareMinor)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,category,totalMinor,myShareMinor,count);

@override
String toString() {
  return 'LedgerCategoryTotalDto(category: $category, totalMinor: $totalMinor, myShareMinor: $myShareMinor, count: $count)';
}


}

/// @nodoc
abstract mixin class $LedgerCategoryTotalDtoCopyWith<$Res>  {
  factory $LedgerCategoryTotalDtoCopyWith(LedgerCategoryTotalDto value, $Res Function(LedgerCategoryTotalDto) _then) = _$LedgerCategoryTotalDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: ExpenseCategory.uncategorized) ExpenseCategory category, int totalMinor, int myShareMinor, int count
});




}
/// @nodoc
class _$LedgerCategoryTotalDtoCopyWithImpl<$Res>
    implements $LedgerCategoryTotalDtoCopyWith<$Res> {
  _$LedgerCategoryTotalDtoCopyWithImpl(this._self, this._then);

  final LedgerCategoryTotalDto _self;
  final $Res Function(LedgerCategoryTotalDto) _then;

/// Create a copy of LedgerCategoryTotalDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? category = null,Object? totalMinor = null,Object? myShareMinor = null,Object? count = null,}) {
  return _then(_self.copyWith(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ExpenseCategory,totalMinor: null == totalMinor ? _self.totalMinor : totalMinor // ignore: cast_nullable_to_non_nullable
as int,myShareMinor: null == myShareMinor ? _self.myShareMinor : myShareMinor // ignore: cast_nullable_to_non_nullable
as int,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LedgerCategoryTotalDto].
extension LedgerCategoryTotalDtoPatterns on LedgerCategoryTotalDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LedgerCategoryTotalDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LedgerCategoryTotalDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LedgerCategoryTotalDto value)  $default,){
final _that = this;
switch (_that) {
case _LedgerCategoryTotalDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LedgerCategoryTotalDto value)?  $default,){
final _that = this;
switch (_that) {
case _LedgerCategoryTotalDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: ExpenseCategory.uncategorized)  ExpenseCategory category,  int totalMinor,  int myShareMinor,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LedgerCategoryTotalDto() when $default != null:
return $default(_that.category,_that.totalMinor,_that.myShareMinor,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: ExpenseCategory.uncategorized)  ExpenseCategory category,  int totalMinor,  int myShareMinor,  int count)  $default,) {final _that = this;
switch (_that) {
case _LedgerCategoryTotalDto():
return $default(_that.category,_that.totalMinor,_that.myShareMinor,_that.count);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: ExpenseCategory.uncategorized)  ExpenseCategory category,  int totalMinor,  int myShareMinor,  int count)?  $default,) {final _that = this;
switch (_that) {
case _LedgerCategoryTotalDto() when $default != null:
return $default(_that.category,_that.totalMinor,_that.myShareMinor,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LedgerCategoryTotalDto implements LedgerCategoryTotalDto {
  const _LedgerCategoryTotalDto({@JsonKey(unknownEnumValue: ExpenseCategory.uncategorized) this.category = ExpenseCategory.uncategorized, this.totalMinor = 0, this.myShareMinor = 0, this.count = 0});
  factory _LedgerCategoryTotalDto.fromJson(Map<String, dynamic> json) => _$LedgerCategoryTotalDtoFromJson(json);

@override@JsonKey(unknownEnumValue: ExpenseCategory.uncategorized) final  ExpenseCategory category;
@override@JsonKey() final  int totalMinor;
@override@JsonKey() final  int myShareMinor;
@override@JsonKey() final  int count;

/// Create a copy of LedgerCategoryTotalDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LedgerCategoryTotalDtoCopyWith<_LedgerCategoryTotalDto> get copyWith => __$LedgerCategoryTotalDtoCopyWithImpl<_LedgerCategoryTotalDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LedgerCategoryTotalDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LedgerCategoryTotalDto&&(identical(other.category, category) || other.category == category)&&(identical(other.totalMinor, totalMinor) || other.totalMinor == totalMinor)&&(identical(other.myShareMinor, myShareMinor) || other.myShareMinor == myShareMinor)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,category,totalMinor,myShareMinor,count);

@override
String toString() {
  return 'LedgerCategoryTotalDto(category: $category, totalMinor: $totalMinor, myShareMinor: $myShareMinor, count: $count)';
}


}

/// @nodoc
abstract mixin class _$LedgerCategoryTotalDtoCopyWith<$Res> implements $LedgerCategoryTotalDtoCopyWith<$Res> {
  factory _$LedgerCategoryTotalDtoCopyWith(_LedgerCategoryTotalDto value, $Res Function(_LedgerCategoryTotalDto) _then) = __$LedgerCategoryTotalDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: ExpenseCategory.uncategorized) ExpenseCategory category, int totalMinor, int myShareMinor, int count
});




}
/// @nodoc
class __$LedgerCategoryTotalDtoCopyWithImpl<$Res>
    implements _$LedgerCategoryTotalDtoCopyWith<$Res> {
  __$LedgerCategoryTotalDtoCopyWithImpl(this._self, this._then);

  final _LedgerCategoryTotalDto _self;
  final $Res Function(_LedgerCategoryTotalDto) _then;

/// Create a copy of LedgerCategoryTotalDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? category = null,Object? totalMinor = null,Object? myShareMinor = null,Object? count = null,}) {
  return _then(_LedgerCategoryTotalDto(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ExpenseCategory,totalMinor: null == totalMinor ? _self.totalMinor : totalMinor // ignore: cast_nullable_to_non_nullable
as int,myShareMinor: null == myShareMinor ? _self.myShareMinor : myShareMinor // ignore: cast_nullable_to_non_nullable
as int,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$LedgerPeriodTotalDto {

/// `2026-07`. A month, because that is the unit rent, salaries and every
/// other household comparison already run on.
 String get period; int get totalMinor; int get myShareMinor; int get count;
/// Create a copy of LedgerPeriodTotalDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LedgerPeriodTotalDtoCopyWith<LedgerPeriodTotalDto> get copyWith => _$LedgerPeriodTotalDtoCopyWithImpl<LedgerPeriodTotalDto>(this as LedgerPeriodTotalDto, _$identity);

  /// Serializes this LedgerPeriodTotalDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LedgerPeriodTotalDto&&(identical(other.period, period) || other.period == period)&&(identical(other.totalMinor, totalMinor) || other.totalMinor == totalMinor)&&(identical(other.myShareMinor, myShareMinor) || other.myShareMinor == myShareMinor)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,period,totalMinor,myShareMinor,count);

@override
String toString() {
  return 'LedgerPeriodTotalDto(period: $period, totalMinor: $totalMinor, myShareMinor: $myShareMinor, count: $count)';
}


}

/// @nodoc
abstract mixin class $LedgerPeriodTotalDtoCopyWith<$Res>  {
  factory $LedgerPeriodTotalDtoCopyWith(LedgerPeriodTotalDto value, $Res Function(LedgerPeriodTotalDto) _then) = _$LedgerPeriodTotalDtoCopyWithImpl;
@useResult
$Res call({
 String period, int totalMinor, int myShareMinor, int count
});




}
/// @nodoc
class _$LedgerPeriodTotalDtoCopyWithImpl<$Res>
    implements $LedgerPeriodTotalDtoCopyWith<$Res> {
  _$LedgerPeriodTotalDtoCopyWithImpl(this._self, this._then);

  final LedgerPeriodTotalDto _self;
  final $Res Function(LedgerPeriodTotalDto) _then;

/// Create a copy of LedgerPeriodTotalDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? period = null,Object? totalMinor = null,Object? myShareMinor = null,Object? count = null,}) {
  return _then(_self.copyWith(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String,totalMinor: null == totalMinor ? _self.totalMinor : totalMinor // ignore: cast_nullable_to_non_nullable
as int,myShareMinor: null == myShareMinor ? _self.myShareMinor : myShareMinor // ignore: cast_nullable_to_non_nullable
as int,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LedgerPeriodTotalDto].
extension LedgerPeriodTotalDtoPatterns on LedgerPeriodTotalDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LedgerPeriodTotalDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LedgerPeriodTotalDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LedgerPeriodTotalDto value)  $default,){
final _that = this;
switch (_that) {
case _LedgerPeriodTotalDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LedgerPeriodTotalDto value)?  $default,){
final _that = this;
switch (_that) {
case _LedgerPeriodTotalDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String period,  int totalMinor,  int myShareMinor,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LedgerPeriodTotalDto() when $default != null:
return $default(_that.period,_that.totalMinor,_that.myShareMinor,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String period,  int totalMinor,  int myShareMinor,  int count)  $default,) {final _that = this;
switch (_that) {
case _LedgerPeriodTotalDto():
return $default(_that.period,_that.totalMinor,_that.myShareMinor,_that.count);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String period,  int totalMinor,  int myShareMinor,  int count)?  $default,) {final _that = this;
switch (_that) {
case _LedgerPeriodTotalDto() when $default != null:
return $default(_that.period,_that.totalMinor,_that.myShareMinor,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LedgerPeriodTotalDto implements LedgerPeriodTotalDto {
  const _LedgerPeriodTotalDto({this.period = '', this.totalMinor = 0, this.myShareMinor = 0, this.count = 0});
  factory _LedgerPeriodTotalDto.fromJson(Map<String, dynamic> json) => _$LedgerPeriodTotalDtoFromJson(json);

/// `2026-07`. A month, because that is the unit rent, salaries and every
/// other household comparison already run on.
@override@JsonKey() final  String period;
@override@JsonKey() final  int totalMinor;
@override@JsonKey() final  int myShareMinor;
@override@JsonKey() final  int count;

/// Create a copy of LedgerPeriodTotalDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LedgerPeriodTotalDtoCopyWith<_LedgerPeriodTotalDto> get copyWith => __$LedgerPeriodTotalDtoCopyWithImpl<_LedgerPeriodTotalDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LedgerPeriodTotalDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LedgerPeriodTotalDto&&(identical(other.period, period) || other.period == period)&&(identical(other.totalMinor, totalMinor) || other.totalMinor == totalMinor)&&(identical(other.myShareMinor, myShareMinor) || other.myShareMinor == myShareMinor)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,period,totalMinor,myShareMinor,count);

@override
String toString() {
  return 'LedgerPeriodTotalDto(period: $period, totalMinor: $totalMinor, myShareMinor: $myShareMinor, count: $count)';
}


}

/// @nodoc
abstract mixin class _$LedgerPeriodTotalDtoCopyWith<$Res> implements $LedgerPeriodTotalDtoCopyWith<$Res> {
  factory _$LedgerPeriodTotalDtoCopyWith(_LedgerPeriodTotalDto value, $Res Function(_LedgerPeriodTotalDto) _then) = __$LedgerPeriodTotalDtoCopyWithImpl;
@override @useResult
$Res call({
 String period, int totalMinor, int myShareMinor, int count
});




}
/// @nodoc
class __$LedgerPeriodTotalDtoCopyWithImpl<$Res>
    implements _$LedgerPeriodTotalDtoCopyWith<$Res> {
  __$LedgerPeriodTotalDtoCopyWithImpl(this._self, this._then);

  final _LedgerPeriodTotalDto _self;
  final $Res Function(_LedgerPeriodTotalDto) _then;

/// Create a copy of LedgerPeriodTotalDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? period = null,Object? totalMinor = null,Object? myShareMinor = null,Object? count = null,}) {
  return _then(_LedgerPeriodTotalDto(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String,totalMinor: null == totalMinor ? _self.totalMinor : totalMinor // ignore: cast_nullable_to_non_nullable
as int,myShareMinor: null == myShareMinor ? _self.myShareMinor : myShareMinor // ignore: cast_nullable_to_non_nullable
as int,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$LedgerPayerTotalDto {

 String get userId; int get paidMinor;
/// Create a copy of LedgerPayerTotalDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LedgerPayerTotalDtoCopyWith<LedgerPayerTotalDto> get copyWith => _$LedgerPayerTotalDtoCopyWithImpl<LedgerPayerTotalDto>(this as LedgerPayerTotalDto, _$identity);

  /// Serializes this LedgerPayerTotalDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LedgerPayerTotalDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.paidMinor, paidMinor) || other.paidMinor == paidMinor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,paidMinor);

@override
String toString() {
  return 'LedgerPayerTotalDto(userId: $userId, paidMinor: $paidMinor)';
}


}

/// @nodoc
abstract mixin class $LedgerPayerTotalDtoCopyWith<$Res>  {
  factory $LedgerPayerTotalDtoCopyWith(LedgerPayerTotalDto value, $Res Function(LedgerPayerTotalDto) _then) = _$LedgerPayerTotalDtoCopyWithImpl;
@useResult
$Res call({
 String userId, int paidMinor
});




}
/// @nodoc
class _$LedgerPayerTotalDtoCopyWithImpl<$Res>
    implements $LedgerPayerTotalDtoCopyWith<$Res> {
  _$LedgerPayerTotalDtoCopyWithImpl(this._self, this._then);

  final LedgerPayerTotalDto _self;
  final $Res Function(LedgerPayerTotalDto) _then;

/// Create a copy of LedgerPayerTotalDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? paidMinor = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,paidMinor: null == paidMinor ? _self.paidMinor : paidMinor // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LedgerPayerTotalDto].
extension LedgerPayerTotalDtoPatterns on LedgerPayerTotalDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LedgerPayerTotalDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LedgerPayerTotalDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LedgerPayerTotalDto value)  $default,){
final _that = this;
switch (_that) {
case _LedgerPayerTotalDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LedgerPayerTotalDto value)?  $default,){
final _that = this;
switch (_that) {
case _LedgerPayerTotalDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  int paidMinor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LedgerPayerTotalDto() when $default != null:
return $default(_that.userId,_that.paidMinor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  int paidMinor)  $default,) {final _that = this;
switch (_that) {
case _LedgerPayerTotalDto():
return $default(_that.userId,_that.paidMinor);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  int paidMinor)?  $default,) {final _that = this;
switch (_that) {
case _LedgerPayerTotalDto() when $default != null:
return $default(_that.userId,_that.paidMinor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LedgerPayerTotalDto implements LedgerPayerTotalDto {
  const _LedgerPayerTotalDto({this.userId = '', this.paidMinor = 0});
  factory _LedgerPayerTotalDto.fromJson(Map<String, dynamic> json) => _$LedgerPayerTotalDtoFromJson(json);

@override@JsonKey() final  String userId;
@override@JsonKey() final  int paidMinor;

/// Create a copy of LedgerPayerTotalDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LedgerPayerTotalDtoCopyWith<_LedgerPayerTotalDto> get copyWith => __$LedgerPayerTotalDtoCopyWithImpl<_LedgerPayerTotalDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LedgerPayerTotalDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LedgerPayerTotalDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.paidMinor, paidMinor) || other.paidMinor == paidMinor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,paidMinor);

@override
String toString() {
  return 'LedgerPayerTotalDto(userId: $userId, paidMinor: $paidMinor)';
}


}

/// @nodoc
abstract mixin class _$LedgerPayerTotalDtoCopyWith<$Res> implements $LedgerPayerTotalDtoCopyWith<$Res> {
  factory _$LedgerPayerTotalDtoCopyWith(_LedgerPayerTotalDto value, $Res Function(_LedgerPayerTotalDto) _then) = __$LedgerPayerTotalDtoCopyWithImpl;
@override @useResult
$Res call({
 String userId, int paidMinor
});




}
/// @nodoc
class __$LedgerPayerTotalDtoCopyWithImpl<$Res>
    implements _$LedgerPayerTotalDtoCopyWith<$Res> {
  __$LedgerPayerTotalDtoCopyWithImpl(this._self, this._then);

  final _LedgerPayerTotalDto _self;
  final $Res Function(_LedgerPayerTotalDto) _then;

/// Create a copy of LedgerPayerTotalDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? paidMinor = null,}) {
  return _then(_LedgerPayerTotalDto(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,paidMinor: null == paidMinor ? _self.paidMinor : paidMinor // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ExpenseReceiptDto {

 String get id; String get expenseId; String get fileName; String get contentType; int get sizeBytes; String get uploadedByUserId; DateTime? get uploadedAt; String? get url;
/// Create a copy of ExpenseReceiptDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpenseReceiptDtoCopyWith<ExpenseReceiptDto> get copyWith => _$ExpenseReceiptDtoCopyWithImpl<ExpenseReceiptDto>(this as ExpenseReceiptDto, _$identity);

  /// Serializes this ExpenseReceiptDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpenseReceiptDto&&(identical(other.id, id) || other.id == id)&&(identical(other.expenseId, expenseId) || other.expenseId == expenseId)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.uploadedByUserId, uploadedByUserId) || other.uploadedByUserId == uploadedByUserId)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,expenseId,fileName,contentType,sizeBytes,uploadedByUserId,uploadedAt,url);

@override
String toString() {
  return 'ExpenseReceiptDto(id: $id, expenseId: $expenseId, fileName: $fileName, contentType: $contentType, sizeBytes: $sizeBytes, uploadedByUserId: $uploadedByUserId, uploadedAt: $uploadedAt, url: $url)';
}


}

/// @nodoc
abstract mixin class $ExpenseReceiptDtoCopyWith<$Res>  {
  factory $ExpenseReceiptDtoCopyWith(ExpenseReceiptDto value, $Res Function(ExpenseReceiptDto) _then) = _$ExpenseReceiptDtoCopyWithImpl;
@useResult
$Res call({
 String id, String expenseId, String fileName, String contentType, int sizeBytes, String uploadedByUserId, DateTime? uploadedAt, String? url
});




}
/// @nodoc
class _$ExpenseReceiptDtoCopyWithImpl<$Res>
    implements $ExpenseReceiptDtoCopyWith<$Res> {
  _$ExpenseReceiptDtoCopyWithImpl(this._self, this._then);

  final ExpenseReceiptDto _self;
  final $Res Function(ExpenseReceiptDto) _then;

/// Create a copy of ExpenseReceiptDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? expenseId = null,Object? fileName = null,Object? contentType = null,Object? sizeBytes = null,Object? uploadedByUserId = null,Object? uploadedAt = freezed,Object? url = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,expenseId: null == expenseId ? _self.expenseId : expenseId // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,uploadedByUserId: null == uploadedByUserId ? _self.uploadedByUserId : uploadedByUserId // ignore: cast_nullable_to_non_nullable
as String,uploadedAt: freezed == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExpenseReceiptDto].
extension ExpenseReceiptDtoPatterns on ExpenseReceiptDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpenseReceiptDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpenseReceiptDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpenseReceiptDto value)  $default,){
final _that = this;
switch (_that) {
case _ExpenseReceiptDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpenseReceiptDto value)?  $default,){
final _that = this;
switch (_that) {
case _ExpenseReceiptDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String expenseId,  String fileName,  String contentType,  int sizeBytes,  String uploadedByUserId,  DateTime? uploadedAt,  String? url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpenseReceiptDto() when $default != null:
return $default(_that.id,_that.expenseId,_that.fileName,_that.contentType,_that.sizeBytes,_that.uploadedByUserId,_that.uploadedAt,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String expenseId,  String fileName,  String contentType,  int sizeBytes,  String uploadedByUserId,  DateTime? uploadedAt,  String? url)  $default,) {final _that = this;
switch (_that) {
case _ExpenseReceiptDto():
return $default(_that.id,_that.expenseId,_that.fileName,_that.contentType,_that.sizeBytes,_that.uploadedByUserId,_that.uploadedAt,_that.url);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String expenseId,  String fileName,  String contentType,  int sizeBytes,  String uploadedByUserId,  DateTime? uploadedAt,  String? url)?  $default,) {final _that = this;
switch (_that) {
case _ExpenseReceiptDto() when $default != null:
return $default(_that.id,_that.expenseId,_that.fileName,_that.contentType,_that.sizeBytes,_that.uploadedByUserId,_that.uploadedAt,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _ExpenseReceiptDto implements ExpenseReceiptDto {
  const _ExpenseReceiptDto({required this.id, this.expenseId = '', this.fileName = '', this.contentType = '', this.sizeBytes = 0, this.uploadedByUserId = '', this.uploadedAt, this.url});
  factory _ExpenseReceiptDto.fromJson(Map<String, dynamic> json) => _$ExpenseReceiptDtoFromJson(json);

@override final  String id;
@override@JsonKey() final  String expenseId;
@override@JsonKey() final  String fileName;
@override@JsonKey() final  String contentType;
@override@JsonKey() final  int sizeBytes;
@override@JsonKey() final  String uploadedByUserId;
@override final  DateTime? uploadedAt;
@override final  String? url;

/// Create a copy of ExpenseReceiptDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpenseReceiptDtoCopyWith<_ExpenseReceiptDto> get copyWith => __$ExpenseReceiptDtoCopyWithImpl<_ExpenseReceiptDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpenseReceiptDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpenseReceiptDto&&(identical(other.id, id) || other.id == id)&&(identical(other.expenseId, expenseId) || other.expenseId == expenseId)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.uploadedByUserId, uploadedByUserId) || other.uploadedByUserId == uploadedByUserId)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,expenseId,fileName,contentType,sizeBytes,uploadedByUserId,uploadedAt,url);

@override
String toString() {
  return 'ExpenseReceiptDto(id: $id, expenseId: $expenseId, fileName: $fileName, contentType: $contentType, sizeBytes: $sizeBytes, uploadedByUserId: $uploadedByUserId, uploadedAt: $uploadedAt, url: $url)';
}


}

/// @nodoc
abstract mixin class _$ExpenseReceiptDtoCopyWith<$Res> implements $ExpenseReceiptDtoCopyWith<$Res> {
  factory _$ExpenseReceiptDtoCopyWith(_ExpenseReceiptDto value, $Res Function(_ExpenseReceiptDto) _then) = __$ExpenseReceiptDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String expenseId, String fileName, String contentType, int sizeBytes, String uploadedByUserId, DateTime? uploadedAt, String? url
});




}
/// @nodoc
class __$ExpenseReceiptDtoCopyWithImpl<$Res>
    implements _$ExpenseReceiptDtoCopyWith<$Res> {
  __$ExpenseReceiptDtoCopyWithImpl(this._self, this._then);

  final _ExpenseReceiptDto _self;
  final $Res Function(_ExpenseReceiptDto) _then;

/// Create a copy of ExpenseReceiptDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? expenseId = null,Object? fileName = null,Object? contentType = null,Object? sizeBytes = null,Object? uploadedByUserId = null,Object? uploadedAt = freezed,Object? url = freezed,}) {
  return _then(_ExpenseReceiptDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,expenseId: null == expenseId ? _self.expenseId : expenseId // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,uploadedByUserId: null == uploadedByUserId ? _self.uploadedByUserId : uploadedByUserId // ignore: cast_nullable_to_non_nullable
as String,uploadedAt: freezed == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
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
