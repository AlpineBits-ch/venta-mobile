// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bill_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecurringExpenseShareDto {

 String get userId; double get shareValue;
/// Create a copy of RecurringExpenseShareDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecurringExpenseShareDtoCopyWith<RecurringExpenseShareDto> get copyWith => _$RecurringExpenseShareDtoCopyWithImpl<RecurringExpenseShareDto>(this as RecurringExpenseShareDto, _$identity);

  /// Serializes this RecurringExpenseShareDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecurringExpenseShareDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.shareValue, shareValue) || other.shareValue == shareValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,shareValue);

@override
String toString() {
  return 'RecurringExpenseShareDto(userId: $userId, shareValue: $shareValue)';
}


}

/// @nodoc
abstract mixin class $RecurringExpenseShareDtoCopyWith<$Res>  {
  factory $RecurringExpenseShareDtoCopyWith(RecurringExpenseShareDto value, $Res Function(RecurringExpenseShareDto) _then) = _$RecurringExpenseShareDtoCopyWithImpl;
@useResult
$Res call({
 String userId, double shareValue
});




}
/// @nodoc
class _$RecurringExpenseShareDtoCopyWithImpl<$Res>
    implements $RecurringExpenseShareDtoCopyWith<$Res> {
  _$RecurringExpenseShareDtoCopyWithImpl(this._self, this._then);

  final RecurringExpenseShareDto _self;
  final $Res Function(RecurringExpenseShareDto) _then;

/// Create a copy of RecurringExpenseShareDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? shareValue = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,shareValue: null == shareValue ? _self.shareValue : shareValue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [RecurringExpenseShareDto].
extension RecurringExpenseShareDtoPatterns on RecurringExpenseShareDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecurringExpenseShareDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecurringExpenseShareDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecurringExpenseShareDto value)  $default,){
final _that = this;
switch (_that) {
case _RecurringExpenseShareDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecurringExpenseShareDto value)?  $default,){
final _that = this;
switch (_that) {
case _RecurringExpenseShareDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  double shareValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecurringExpenseShareDto() when $default != null:
return $default(_that.userId,_that.shareValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  double shareValue)  $default,) {final _that = this;
switch (_that) {
case _RecurringExpenseShareDto():
return $default(_that.userId,_that.shareValue);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  double shareValue)?  $default,) {final _that = this;
switch (_that) {
case _RecurringExpenseShareDto() when $default != null:
return $default(_that.userId,_that.shareValue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecurringExpenseShareDto implements RecurringExpenseShareDto {
  const _RecurringExpenseShareDto({this.userId = '', this.shareValue = 0});
  factory _RecurringExpenseShareDto.fromJson(Map<String, dynamic> json) => _$RecurringExpenseShareDtoFromJson(json);

@override@JsonKey() final  String userId;
@override@JsonKey() final  double shareValue;

/// Create a copy of RecurringExpenseShareDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecurringExpenseShareDtoCopyWith<_RecurringExpenseShareDto> get copyWith => __$RecurringExpenseShareDtoCopyWithImpl<_RecurringExpenseShareDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecurringExpenseShareDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecurringExpenseShareDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.shareValue, shareValue) || other.shareValue == shareValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,shareValue);

@override
String toString() {
  return 'RecurringExpenseShareDto(userId: $userId, shareValue: $shareValue)';
}


}

/// @nodoc
abstract mixin class _$RecurringExpenseShareDtoCopyWith<$Res> implements $RecurringExpenseShareDtoCopyWith<$Res> {
  factory _$RecurringExpenseShareDtoCopyWith(_RecurringExpenseShareDto value, $Res Function(_RecurringExpenseShareDto) _then) = __$RecurringExpenseShareDtoCopyWithImpl;
@override @useResult
$Res call({
 String userId, double shareValue
});




}
/// @nodoc
class __$RecurringExpenseShareDtoCopyWithImpl<$Res>
    implements _$RecurringExpenseShareDtoCopyWith<$Res> {
  __$RecurringExpenseShareDtoCopyWithImpl(this._self, this._then);

  final _RecurringExpenseShareDto _self;
  final $Res Function(_RecurringExpenseShareDto) _then;

/// Create a copy of RecurringExpenseShareDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? shareValue = null,}) {
  return _then(_RecurringExpenseShareDto(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,shareValue: null == shareValue ? _self.shareValue : shareValue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$RecurringExpenseDto {

 String get id; String get channelId; String get description;/// Null means the amount varies and each period waits for a figure.
/// [autoPost] is only legal alongside a fixed amount.
 int? get amountMinor; String get currency; String get payerUserId;@JsonKey(unknownEnumValue: SplitKind.equal) SplitKind get splitKind;@JsonKey(unknownEnumValue: ExpenseCategory.uncategorized) ExpenseCategory get category;@JsonKey(unknownEnumValue: RecurrenceUnit.month) RecurrenceUnit get recurrenceUnit; int get recurrenceInterval; DateTime? get anchorAt; DateTime? get nextDueAt;/// 0-30. How far ahead the house is told a period is coming, which is the
/// difference between a warning and a receipt.
 int get leadDays; bool get autoPost; bool get isPaused; String get createdByUserId; List<RecurringExpenseShareDto> get shares;
/// Create a copy of RecurringExpenseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecurringExpenseDtoCopyWith<RecurringExpenseDto> get copyWith => _$RecurringExpenseDtoCopyWithImpl<RecurringExpenseDto>(this as RecurringExpenseDto, _$identity);

  /// Serializes this RecurringExpenseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecurringExpenseDto&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.description, description) || other.description == description)&&(identical(other.amountMinor, amountMinor) || other.amountMinor == amountMinor)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.payerUserId, payerUserId) || other.payerUserId == payerUserId)&&(identical(other.splitKind, splitKind) || other.splitKind == splitKind)&&(identical(other.category, category) || other.category == category)&&(identical(other.recurrenceUnit, recurrenceUnit) || other.recurrenceUnit == recurrenceUnit)&&(identical(other.recurrenceInterval, recurrenceInterval) || other.recurrenceInterval == recurrenceInterval)&&(identical(other.anchorAt, anchorAt) || other.anchorAt == anchorAt)&&(identical(other.nextDueAt, nextDueAt) || other.nextDueAt == nextDueAt)&&(identical(other.leadDays, leadDays) || other.leadDays == leadDays)&&(identical(other.autoPost, autoPost) || other.autoPost == autoPost)&&(identical(other.isPaused, isPaused) || other.isPaused == isPaused)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId)&&const DeepCollectionEquality().equals(other.shares, shares));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,description,amountMinor,currency,payerUserId,splitKind,category,recurrenceUnit,recurrenceInterval,anchorAt,nextDueAt,leadDays,autoPost,isPaused,createdByUserId,const DeepCollectionEquality().hash(shares));

@override
String toString() {
  return 'RecurringExpenseDto(id: $id, channelId: $channelId, description: $description, amountMinor: $amountMinor, currency: $currency, payerUserId: $payerUserId, splitKind: $splitKind, category: $category, recurrenceUnit: $recurrenceUnit, recurrenceInterval: $recurrenceInterval, anchorAt: $anchorAt, nextDueAt: $nextDueAt, leadDays: $leadDays, autoPost: $autoPost, isPaused: $isPaused, createdByUserId: $createdByUserId, shares: $shares)';
}


}

/// @nodoc
abstract mixin class $RecurringExpenseDtoCopyWith<$Res>  {
  factory $RecurringExpenseDtoCopyWith(RecurringExpenseDto value, $Res Function(RecurringExpenseDto) _then) = _$RecurringExpenseDtoCopyWithImpl;
@useResult
$Res call({
 String id, String channelId, String description, int? amountMinor, String currency, String payerUserId,@JsonKey(unknownEnumValue: SplitKind.equal) SplitKind splitKind,@JsonKey(unknownEnumValue: ExpenseCategory.uncategorized) ExpenseCategory category,@JsonKey(unknownEnumValue: RecurrenceUnit.month) RecurrenceUnit recurrenceUnit, int recurrenceInterval, DateTime? anchorAt, DateTime? nextDueAt, int leadDays, bool autoPost, bool isPaused, String createdByUserId, List<RecurringExpenseShareDto> shares
});




}
/// @nodoc
class _$RecurringExpenseDtoCopyWithImpl<$Res>
    implements $RecurringExpenseDtoCopyWith<$Res> {
  _$RecurringExpenseDtoCopyWithImpl(this._self, this._then);

  final RecurringExpenseDto _self;
  final $Res Function(RecurringExpenseDto) _then;

/// Create a copy of RecurringExpenseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? channelId = null,Object? description = null,Object? amountMinor = freezed,Object? currency = null,Object? payerUserId = null,Object? splitKind = null,Object? category = null,Object? recurrenceUnit = null,Object? recurrenceInterval = null,Object? anchorAt = freezed,Object? nextDueAt = freezed,Object? leadDays = null,Object? autoPost = null,Object? isPaused = null,Object? createdByUserId = null,Object? shares = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,amountMinor: freezed == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,payerUserId: null == payerUserId ? _self.payerUserId : payerUserId // ignore: cast_nullable_to_non_nullable
as String,splitKind: null == splitKind ? _self.splitKind : splitKind // ignore: cast_nullable_to_non_nullable
as SplitKind,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ExpenseCategory,recurrenceUnit: null == recurrenceUnit ? _self.recurrenceUnit : recurrenceUnit // ignore: cast_nullable_to_non_nullable
as RecurrenceUnit,recurrenceInterval: null == recurrenceInterval ? _self.recurrenceInterval : recurrenceInterval // ignore: cast_nullable_to_non_nullable
as int,anchorAt: freezed == anchorAt ? _self.anchorAt : anchorAt // ignore: cast_nullable_to_non_nullable
as DateTime?,nextDueAt: freezed == nextDueAt ? _self.nextDueAt : nextDueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,leadDays: null == leadDays ? _self.leadDays : leadDays // ignore: cast_nullable_to_non_nullable
as int,autoPost: null == autoPost ? _self.autoPost : autoPost // ignore: cast_nullable_to_non_nullable
as bool,isPaused: null == isPaused ? _self.isPaused : isPaused // ignore: cast_nullable_to_non_nullable
as bool,createdByUserId: null == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String,shares: null == shares ? _self.shares : shares // ignore: cast_nullable_to_non_nullable
as List<RecurringExpenseShareDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [RecurringExpenseDto].
extension RecurringExpenseDtoPatterns on RecurringExpenseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecurringExpenseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecurringExpenseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecurringExpenseDto value)  $default,){
final _that = this;
switch (_that) {
case _RecurringExpenseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecurringExpenseDto value)?  $default,){
final _that = this;
switch (_that) {
case _RecurringExpenseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String channelId,  String description,  int? amountMinor,  String currency,  String payerUserId, @JsonKey(unknownEnumValue: SplitKind.equal)  SplitKind splitKind, @JsonKey(unknownEnumValue: ExpenseCategory.uncategorized)  ExpenseCategory category, @JsonKey(unknownEnumValue: RecurrenceUnit.month)  RecurrenceUnit recurrenceUnit,  int recurrenceInterval,  DateTime? anchorAt,  DateTime? nextDueAt,  int leadDays,  bool autoPost,  bool isPaused,  String createdByUserId,  List<RecurringExpenseShareDto> shares)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecurringExpenseDto() when $default != null:
return $default(_that.id,_that.channelId,_that.description,_that.amountMinor,_that.currency,_that.payerUserId,_that.splitKind,_that.category,_that.recurrenceUnit,_that.recurrenceInterval,_that.anchorAt,_that.nextDueAt,_that.leadDays,_that.autoPost,_that.isPaused,_that.createdByUserId,_that.shares);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String channelId,  String description,  int? amountMinor,  String currency,  String payerUserId, @JsonKey(unknownEnumValue: SplitKind.equal)  SplitKind splitKind, @JsonKey(unknownEnumValue: ExpenseCategory.uncategorized)  ExpenseCategory category, @JsonKey(unknownEnumValue: RecurrenceUnit.month)  RecurrenceUnit recurrenceUnit,  int recurrenceInterval,  DateTime? anchorAt,  DateTime? nextDueAt,  int leadDays,  bool autoPost,  bool isPaused,  String createdByUserId,  List<RecurringExpenseShareDto> shares)  $default,) {final _that = this;
switch (_that) {
case _RecurringExpenseDto():
return $default(_that.id,_that.channelId,_that.description,_that.amountMinor,_that.currency,_that.payerUserId,_that.splitKind,_that.category,_that.recurrenceUnit,_that.recurrenceInterval,_that.anchorAt,_that.nextDueAt,_that.leadDays,_that.autoPost,_that.isPaused,_that.createdByUserId,_that.shares);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String channelId,  String description,  int? amountMinor,  String currency,  String payerUserId, @JsonKey(unknownEnumValue: SplitKind.equal)  SplitKind splitKind, @JsonKey(unknownEnumValue: ExpenseCategory.uncategorized)  ExpenseCategory category, @JsonKey(unknownEnumValue: RecurrenceUnit.month)  RecurrenceUnit recurrenceUnit,  int recurrenceInterval,  DateTime? anchorAt,  DateTime? nextDueAt,  int leadDays,  bool autoPost,  bool isPaused,  String createdByUserId,  List<RecurringExpenseShareDto> shares)?  $default,) {final _that = this;
switch (_that) {
case _RecurringExpenseDto() when $default != null:
return $default(_that.id,_that.channelId,_that.description,_that.amountMinor,_that.currency,_that.payerUserId,_that.splitKind,_that.category,_that.recurrenceUnit,_that.recurrenceInterval,_that.anchorAt,_that.nextDueAt,_that.leadDays,_that.autoPost,_that.isPaused,_that.createdByUserId,_that.shares);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _RecurringExpenseDto implements RecurringExpenseDto {
  const _RecurringExpenseDto({required this.id, required this.channelId, this.description = '', this.amountMinor, this.currency = 'CHF', this.payerUserId = '', @JsonKey(unknownEnumValue: SplitKind.equal) this.splitKind = SplitKind.equal, @JsonKey(unknownEnumValue: ExpenseCategory.uncategorized) this.category = ExpenseCategory.uncategorized, @JsonKey(unknownEnumValue: RecurrenceUnit.month) this.recurrenceUnit = RecurrenceUnit.month, this.recurrenceInterval = 1, this.anchorAt, this.nextDueAt, this.leadDays = 0, this.autoPost = false, this.isPaused = false, this.createdByUserId = '', final  List<RecurringExpenseShareDto> shares = const <RecurringExpenseShareDto>[]}): _shares = shares;
  factory _RecurringExpenseDto.fromJson(Map<String, dynamic> json) => _$RecurringExpenseDtoFromJson(json);

@override final  String id;
@override final  String channelId;
@override@JsonKey() final  String description;
/// Null means the amount varies and each period waits for a figure.
/// [autoPost] is only legal alongside a fixed amount.
@override final  int? amountMinor;
@override@JsonKey() final  String currency;
@override@JsonKey() final  String payerUserId;
@override@JsonKey(unknownEnumValue: SplitKind.equal) final  SplitKind splitKind;
@override@JsonKey(unknownEnumValue: ExpenseCategory.uncategorized) final  ExpenseCategory category;
@override@JsonKey(unknownEnumValue: RecurrenceUnit.month) final  RecurrenceUnit recurrenceUnit;
@override@JsonKey() final  int recurrenceInterval;
@override final  DateTime? anchorAt;
@override final  DateTime? nextDueAt;
/// 0-30. How far ahead the house is told a period is coming, which is the
/// difference between a warning and a receipt.
@override@JsonKey() final  int leadDays;
@override@JsonKey() final  bool autoPost;
@override@JsonKey() final  bool isPaused;
@override@JsonKey() final  String createdByUserId;
 final  List<RecurringExpenseShareDto> _shares;
@override@JsonKey() List<RecurringExpenseShareDto> get shares {
  if (_shares is EqualUnmodifiableListView) return _shares;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_shares);
}


/// Create a copy of RecurringExpenseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecurringExpenseDtoCopyWith<_RecurringExpenseDto> get copyWith => __$RecurringExpenseDtoCopyWithImpl<_RecurringExpenseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecurringExpenseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecurringExpenseDto&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.description, description) || other.description == description)&&(identical(other.amountMinor, amountMinor) || other.amountMinor == amountMinor)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.payerUserId, payerUserId) || other.payerUserId == payerUserId)&&(identical(other.splitKind, splitKind) || other.splitKind == splitKind)&&(identical(other.category, category) || other.category == category)&&(identical(other.recurrenceUnit, recurrenceUnit) || other.recurrenceUnit == recurrenceUnit)&&(identical(other.recurrenceInterval, recurrenceInterval) || other.recurrenceInterval == recurrenceInterval)&&(identical(other.anchorAt, anchorAt) || other.anchorAt == anchorAt)&&(identical(other.nextDueAt, nextDueAt) || other.nextDueAt == nextDueAt)&&(identical(other.leadDays, leadDays) || other.leadDays == leadDays)&&(identical(other.autoPost, autoPost) || other.autoPost == autoPost)&&(identical(other.isPaused, isPaused) || other.isPaused == isPaused)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId)&&const DeepCollectionEquality().equals(other._shares, _shares));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,description,amountMinor,currency,payerUserId,splitKind,category,recurrenceUnit,recurrenceInterval,anchorAt,nextDueAt,leadDays,autoPost,isPaused,createdByUserId,const DeepCollectionEquality().hash(_shares));

@override
String toString() {
  return 'RecurringExpenseDto(id: $id, channelId: $channelId, description: $description, amountMinor: $amountMinor, currency: $currency, payerUserId: $payerUserId, splitKind: $splitKind, category: $category, recurrenceUnit: $recurrenceUnit, recurrenceInterval: $recurrenceInterval, anchorAt: $anchorAt, nextDueAt: $nextDueAt, leadDays: $leadDays, autoPost: $autoPost, isPaused: $isPaused, createdByUserId: $createdByUserId, shares: $shares)';
}


}

/// @nodoc
abstract mixin class _$RecurringExpenseDtoCopyWith<$Res> implements $RecurringExpenseDtoCopyWith<$Res> {
  factory _$RecurringExpenseDtoCopyWith(_RecurringExpenseDto value, $Res Function(_RecurringExpenseDto) _then) = __$RecurringExpenseDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String channelId, String description, int? amountMinor, String currency, String payerUserId,@JsonKey(unknownEnumValue: SplitKind.equal) SplitKind splitKind,@JsonKey(unknownEnumValue: ExpenseCategory.uncategorized) ExpenseCategory category,@JsonKey(unknownEnumValue: RecurrenceUnit.month) RecurrenceUnit recurrenceUnit, int recurrenceInterval, DateTime? anchorAt, DateTime? nextDueAt, int leadDays, bool autoPost, bool isPaused, String createdByUserId, List<RecurringExpenseShareDto> shares
});




}
/// @nodoc
class __$RecurringExpenseDtoCopyWithImpl<$Res>
    implements _$RecurringExpenseDtoCopyWith<$Res> {
  __$RecurringExpenseDtoCopyWithImpl(this._self, this._then);

  final _RecurringExpenseDto _self;
  final $Res Function(_RecurringExpenseDto) _then;

/// Create a copy of RecurringExpenseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? channelId = null,Object? description = null,Object? amountMinor = freezed,Object? currency = null,Object? payerUserId = null,Object? splitKind = null,Object? category = null,Object? recurrenceUnit = null,Object? recurrenceInterval = null,Object? anchorAt = freezed,Object? nextDueAt = freezed,Object? leadDays = null,Object? autoPost = null,Object? isPaused = null,Object? createdByUserId = null,Object? shares = null,}) {
  return _then(_RecurringExpenseDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,amountMinor: freezed == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,payerUserId: null == payerUserId ? _self.payerUserId : payerUserId // ignore: cast_nullable_to_non_nullable
as String,splitKind: null == splitKind ? _self.splitKind : splitKind // ignore: cast_nullable_to_non_nullable
as SplitKind,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ExpenseCategory,recurrenceUnit: null == recurrenceUnit ? _self.recurrenceUnit : recurrenceUnit // ignore: cast_nullable_to_non_nullable
as RecurrenceUnit,recurrenceInterval: null == recurrenceInterval ? _self.recurrenceInterval : recurrenceInterval // ignore: cast_nullable_to_non_nullable
as int,anchorAt: freezed == anchorAt ? _self.anchorAt : anchorAt // ignore: cast_nullable_to_non_nullable
as DateTime?,nextDueAt: freezed == nextDueAt ? _self.nextDueAt : nextDueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,leadDays: null == leadDays ? _self.leadDays : leadDays // ignore: cast_nullable_to_non_nullable
as int,autoPost: null == autoPost ? _self.autoPost : autoPost // ignore: cast_nullable_to_non_nullable
as bool,isPaused: null == isPaused ? _self.isPaused : isPaused // ignore: cast_nullable_to_non_nullable
as bool,createdByUserId: null == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String,shares: null == shares ? _self._shares : shares // ignore: cast_nullable_to_non_nullable
as List<RecurringExpenseShareDto>,
  ));
}


}


/// @nodoc
mixin _$BillOccurrenceDto {

 String get id; String get recurringExpenseId; String get channelId; String get description; DateTime get dueAt;/// Null until somebody reads the figure off the letter.
 int? get amountMinor; String get currency;@JsonKey(unknownEnumValue: BillStatus.pending) BillStatus get status;/// The expense this became, once posted.
 String? get expenseId; String? get postedByUserId; String? get skippedByUserId; String? get skipReason;/// Pending with nobody having said what it cost - the cue to ask for a
/// figure rather than to offer a "post" button that cannot work.
 bool get needsAmount;/// Pending and past due. Computed server-side so every surface agrees on
/// what late means.
 bool get isOverdue;
/// Create a copy of BillOccurrenceDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillOccurrenceDtoCopyWith<BillOccurrenceDto> get copyWith => _$BillOccurrenceDtoCopyWithImpl<BillOccurrenceDto>(this as BillOccurrenceDto, _$identity);

  /// Serializes this BillOccurrenceDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillOccurrenceDto&&(identical(other.id, id) || other.id == id)&&(identical(other.recurringExpenseId, recurringExpenseId) || other.recurringExpenseId == recurringExpenseId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.description, description) || other.description == description)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.amountMinor, amountMinor) || other.amountMinor == amountMinor)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.expenseId, expenseId) || other.expenseId == expenseId)&&(identical(other.postedByUserId, postedByUserId) || other.postedByUserId == postedByUserId)&&(identical(other.skippedByUserId, skippedByUserId) || other.skippedByUserId == skippedByUserId)&&(identical(other.skipReason, skipReason) || other.skipReason == skipReason)&&(identical(other.needsAmount, needsAmount) || other.needsAmount == needsAmount)&&(identical(other.isOverdue, isOverdue) || other.isOverdue == isOverdue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,recurringExpenseId,channelId,description,dueAt,amountMinor,currency,status,expenseId,postedByUserId,skippedByUserId,skipReason,needsAmount,isOverdue);

@override
String toString() {
  return 'BillOccurrenceDto(id: $id, recurringExpenseId: $recurringExpenseId, channelId: $channelId, description: $description, dueAt: $dueAt, amountMinor: $amountMinor, currency: $currency, status: $status, expenseId: $expenseId, postedByUserId: $postedByUserId, skippedByUserId: $skippedByUserId, skipReason: $skipReason, needsAmount: $needsAmount, isOverdue: $isOverdue)';
}


}

/// @nodoc
abstract mixin class $BillOccurrenceDtoCopyWith<$Res>  {
  factory $BillOccurrenceDtoCopyWith(BillOccurrenceDto value, $Res Function(BillOccurrenceDto) _then) = _$BillOccurrenceDtoCopyWithImpl;
@useResult
$Res call({
 String id, String recurringExpenseId, String channelId, String description, DateTime dueAt, int? amountMinor, String currency,@JsonKey(unknownEnumValue: BillStatus.pending) BillStatus status, String? expenseId, String? postedByUserId, String? skippedByUserId, String? skipReason, bool needsAmount, bool isOverdue
});




}
/// @nodoc
class _$BillOccurrenceDtoCopyWithImpl<$Res>
    implements $BillOccurrenceDtoCopyWith<$Res> {
  _$BillOccurrenceDtoCopyWithImpl(this._self, this._then);

  final BillOccurrenceDto _self;
  final $Res Function(BillOccurrenceDto) _then;

/// Create a copy of BillOccurrenceDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? recurringExpenseId = null,Object? channelId = null,Object? description = null,Object? dueAt = null,Object? amountMinor = freezed,Object? currency = null,Object? status = null,Object? expenseId = freezed,Object? postedByUserId = freezed,Object? skippedByUserId = freezed,Object? skipReason = freezed,Object? needsAmount = null,Object? isOverdue = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,recurringExpenseId: null == recurringExpenseId ? _self.recurringExpenseId : recurringExpenseId // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,dueAt: null == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime,amountMinor: freezed == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BillStatus,expenseId: freezed == expenseId ? _self.expenseId : expenseId // ignore: cast_nullable_to_non_nullable
as String?,postedByUserId: freezed == postedByUserId ? _self.postedByUserId : postedByUserId // ignore: cast_nullable_to_non_nullable
as String?,skippedByUserId: freezed == skippedByUserId ? _self.skippedByUserId : skippedByUserId // ignore: cast_nullable_to_non_nullable
as String?,skipReason: freezed == skipReason ? _self.skipReason : skipReason // ignore: cast_nullable_to_non_nullable
as String?,needsAmount: null == needsAmount ? _self.needsAmount : needsAmount // ignore: cast_nullable_to_non_nullable
as bool,isOverdue: null == isOverdue ? _self.isOverdue : isOverdue // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [BillOccurrenceDto].
extension BillOccurrenceDtoPatterns on BillOccurrenceDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BillOccurrenceDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BillOccurrenceDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BillOccurrenceDto value)  $default,){
final _that = this;
switch (_that) {
case _BillOccurrenceDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BillOccurrenceDto value)?  $default,){
final _that = this;
switch (_that) {
case _BillOccurrenceDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String recurringExpenseId,  String channelId,  String description,  DateTime dueAt,  int? amountMinor,  String currency, @JsonKey(unknownEnumValue: BillStatus.pending)  BillStatus status,  String? expenseId,  String? postedByUserId,  String? skippedByUserId,  String? skipReason,  bool needsAmount,  bool isOverdue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BillOccurrenceDto() when $default != null:
return $default(_that.id,_that.recurringExpenseId,_that.channelId,_that.description,_that.dueAt,_that.amountMinor,_that.currency,_that.status,_that.expenseId,_that.postedByUserId,_that.skippedByUserId,_that.skipReason,_that.needsAmount,_that.isOverdue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String recurringExpenseId,  String channelId,  String description,  DateTime dueAt,  int? amountMinor,  String currency, @JsonKey(unknownEnumValue: BillStatus.pending)  BillStatus status,  String? expenseId,  String? postedByUserId,  String? skippedByUserId,  String? skipReason,  bool needsAmount,  bool isOverdue)  $default,) {final _that = this;
switch (_that) {
case _BillOccurrenceDto():
return $default(_that.id,_that.recurringExpenseId,_that.channelId,_that.description,_that.dueAt,_that.amountMinor,_that.currency,_that.status,_that.expenseId,_that.postedByUserId,_that.skippedByUserId,_that.skipReason,_that.needsAmount,_that.isOverdue);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String recurringExpenseId,  String channelId,  String description,  DateTime dueAt,  int? amountMinor,  String currency, @JsonKey(unknownEnumValue: BillStatus.pending)  BillStatus status,  String? expenseId,  String? postedByUserId,  String? skippedByUserId,  String? skipReason,  bool needsAmount,  bool isOverdue)?  $default,) {final _that = this;
switch (_that) {
case _BillOccurrenceDto() when $default != null:
return $default(_that.id,_that.recurringExpenseId,_that.channelId,_that.description,_that.dueAt,_that.amountMinor,_that.currency,_that.status,_that.expenseId,_that.postedByUserId,_that.skippedByUserId,_that.skipReason,_that.needsAmount,_that.isOverdue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _BillOccurrenceDto implements BillOccurrenceDto {
  const _BillOccurrenceDto({required this.id, this.recurringExpenseId = '', required this.channelId, this.description = '', required this.dueAt, this.amountMinor, this.currency = 'CHF', @JsonKey(unknownEnumValue: BillStatus.pending) this.status = BillStatus.pending, this.expenseId, this.postedByUserId, this.skippedByUserId, this.skipReason, this.needsAmount = false, this.isOverdue = false});
  factory _BillOccurrenceDto.fromJson(Map<String, dynamic> json) => _$BillOccurrenceDtoFromJson(json);

@override final  String id;
@override@JsonKey() final  String recurringExpenseId;
@override final  String channelId;
@override@JsonKey() final  String description;
@override final  DateTime dueAt;
/// Null until somebody reads the figure off the letter.
@override final  int? amountMinor;
@override@JsonKey() final  String currency;
@override@JsonKey(unknownEnumValue: BillStatus.pending) final  BillStatus status;
/// The expense this became, once posted.
@override final  String? expenseId;
@override final  String? postedByUserId;
@override final  String? skippedByUserId;
@override final  String? skipReason;
/// Pending with nobody having said what it cost - the cue to ask for a
/// figure rather than to offer a "post" button that cannot work.
@override@JsonKey() final  bool needsAmount;
/// Pending and past due. Computed server-side so every surface agrees on
/// what late means.
@override@JsonKey() final  bool isOverdue;

/// Create a copy of BillOccurrenceDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillOccurrenceDtoCopyWith<_BillOccurrenceDto> get copyWith => __$BillOccurrenceDtoCopyWithImpl<_BillOccurrenceDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BillOccurrenceDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BillOccurrenceDto&&(identical(other.id, id) || other.id == id)&&(identical(other.recurringExpenseId, recurringExpenseId) || other.recurringExpenseId == recurringExpenseId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.description, description) || other.description == description)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.amountMinor, amountMinor) || other.amountMinor == amountMinor)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.expenseId, expenseId) || other.expenseId == expenseId)&&(identical(other.postedByUserId, postedByUserId) || other.postedByUserId == postedByUserId)&&(identical(other.skippedByUserId, skippedByUserId) || other.skippedByUserId == skippedByUserId)&&(identical(other.skipReason, skipReason) || other.skipReason == skipReason)&&(identical(other.needsAmount, needsAmount) || other.needsAmount == needsAmount)&&(identical(other.isOverdue, isOverdue) || other.isOverdue == isOverdue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,recurringExpenseId,channelId,description,dueAt,amountMinor,currency,status,expenseId,postedByUserId,skippedByUserId,skipReason,needsAmount,isOverdue);

@override
String toString() {
  return 'BillOccurrenceDto(id: $id, recurringExpenseId: $recurringExpenseId, channelId: $channelId, description: $description, dueAt: $dueAt, amountMinor: $amountMinor, currency: $currency, status: $status, expenseId: $expenseId, postedByUserId: $postedByUserId, skippedByUserId: $skippedByUserId, skipReason: $skipReason, needsAmount: $needsAmount, isOverdue: $isOverdue)';
}


}

/// @nodoc
abstract mixin class _$BillOccurrenceDtoCopyWith<$Res> implements $BillOccurrenceDtoCopyWith<$Res> {
  factory _$BillOccurrenceDtoCopyWith(_BillOccurrenceDto value, $Res Function(_BillOccurrenceDto) _then) = __$BillOccurrenceDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String recurringExpenseId, String channelId, String description, DateTime dueAt, int? amountMinor, String currency,@JsonKey(unknownEnumValue: BillStatus.pending) BillStatus status, String? expenseId, String? postedByUserId, String? skippedByUserId, String? skipReason, bool needsAmount, bool isOverdue
});




}
/// @nodoc
class __$BillOccurrenceDtoCopyWithImpl<$Res>
    implements _$BillOccurrenceDtoCopyWith<$Res> {
  __$BillOccurrenceDtoCopyWithImpl(this._self, this._then);

  final _BillOccurrenceDto _self;
  final $Res Function(_BillOccurrenceDto) _then;

/// Create a copy of BillOccurrenceDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? recurringExpenseId = null,Object? channelId = null,Object? description = null,Object? dueAt = null,Object? amountMinor = freezed,Object? currency = null,Object? status = null,Object? expenseId = freezed,Object? postedByUserId = freezed,Object? skippedByUserId = freezed,Object? skipReason = freezed,Object? needsAmount = null,Object? isOverdue = null,}) {
  return _then(_BillOccurrenceDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,recurringExpenseId: null == recurringExpenseId ? _self.recurringExpenseId : recurringExpenseId // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,dueAt: null == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime,amountMinor: freezed == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BillStatus,expenseId: freezed == expenseId ? _self.expenseId : expenseId // ignore: cast_nullable_to_non_nullable
as String?,postedByUserId: freezed == postedByUserId ? _self.postedByUserId : postedByUserId // ignore: cast_nullable_to_non_nullable
as String?,skippedByUserId: freezed == skippedByUserId ? _self.skippedByUserId : skippedByUserId // ignore: cast_nullable_to_non_nullable
as String?,skipReason: freezed == skipReason ? _self.skipReason : skipReason // ignore: cast_nullable_to_non_nullable
as String?,needsAmount: null == needsAmount ? _self.needsAmount : needsAmount // ignore: cast_nullable_to_non_nullable
as bool,isOverdue: null == isOverdue ? _self.isOverdue : isOverdue // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
