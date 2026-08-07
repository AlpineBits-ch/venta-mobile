// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pantry_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PantryItemDto {

 String get id; String get channelId; String get name; double get quantity; String? get unit;/// `null` turns restock tracking off for this item specifically.
 double? get lowThreshold; DateTime? get expiresAt; bool get isLow;/// Non-null while this item is sitting on the shopping list. It's the
/// idempotency guard for the restock loop, not a timestamp anyone needs
/// to read - released when the quantity climbs back above the threshold
/// or the list line is bought/cleared.
 DateTime? get restockedAt; String get addedByUserId;/// The code scanned off the packet.
///
/// Two different things can put a name against it and they are not
/// interchangeable: this house's own name, which always wins when there is
/// one, and failing that a suggestion from a shared public product catalog.
/// Only when both come up empty does a scan ask somebody to type one.
 String? get barcode;
/// Create a copy of PantryItemDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PantryItemDtoCopyWith<PantryItemDto> get copyWith => _$PantryItemDtoCopyWithImpl<PantryItemDto>(this as PantryItemDto, _$identity);

  /// Serializes this PantryItemDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PantryItemDto&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.name, name) || other.name == name)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.lowThreshold, lowThreshold) || other.lowThreshold == lowThreshold)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.isLow, isLow) || other.isLow == isLow)&&(identical(other.restockedAt, restockedAt) || other.restockedAt == restockedAt)&&(identical(other.addedByUserId, addedByUserId) || other.addedByUserId == addedByUserId)&&(identical(other.barcode, barcode) || other.barcode == barcode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,name,quantity,unit,lowThreshold,expiresAt,isLow,restockedAt,addedByUserId,barcode);

@override
String toString() {
  return 'PantryItemDto(id: $id, channelId: $channelId, name: $name, quantity: $quantity, unit: $unit, lowThreshold: $lowThreshold, expiresAt: $expiresAt, isLow: $isLow, restockedAt: $restockedAt, addedByUserId: $addedByUserId, barcode: $barcode)';
}


}

/// @nodoc
abstract mixin class $PantryItemDtoCopyWith<$Res>  {
  factory $PantryItemDtoCopyWith(PantryItemDto value, $Res Function(PantryItemDto) _then) = _$PantryItemDtoCopyWithImpl;
@useResult
$Res call({
 String id, String channelId, String name, double quantity, String? unit, double? lowThreshold, DateTime? expiresAt, bool isLow, DateTime? restockedAt, String addedByUserId, String? barcode
});




}
/// @nodoc
class _$PantryItemDtoCopyWithImpl<$Res>
    implements $PantryItemDtoCopyWith<$Res> {
  _$PantryItemDtoCopyWithImpl(this._self, this._then);

  final PantryItemDto _self;
  final $Res Function(PantryItemDto) _then;

/// Create a copy of PantryItemDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? channelId = null,Object? name = null,Object? quantity = null,Object? unit = freezed,Object? lowThreshold = freezed,Object? expiresAt = freezed,Object? isLow = null,Object? restockedAt = freezed,Object? addedByUserId = null,Object? barcode = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,lowThreshold: freezed == lowThreshold ? _self.lowThreshold : lowThreshold // ignore: cast_nullable_to_non_nullable
as double?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isLow: null == isLow ? _self.isLow : isLow // ignore: cast_nullable_to_non_nullable
as bool,restockedAt: freezed == restockedAt ? _self.restockedAt : restockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,addedByUserId: null == addedByUserId ? _self.addedByUserId : addedByUserId // ignore: cast_nullable_to_non_nullable
as String,barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PantryItemDto].
extension PantryItemDtoPatterns on PantryItemDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PantryItemDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PantryItemDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PantryItemDto value)  $default,){
final _that = this;
switch (_that) {
case _PantryItemDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PantryItemDto value)?  $default,){
final _that = this;
switch (_that) {
case _PantryItemDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String channelId,  String name,  double quantity,  String? unit,  double? lowThreshold,  DateTime? expiresAt,  bool isLow,  DateTime? restockedAt,  String addedByUserId,  String? barcode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PantryItemDto() when $default != null:
return $default(_that.id,_that.channelId,_that.name,_that.quantity,_that.unit,_that.lowThreshold,_that.expiresAt,_that.isLow,_that.restockedAt,_that.addedByUserId,_that.barcode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String channelId,  String name,  double quantity,  String? unit,  double? lowThreshold,  DateTime? expiresAt,  bool isLow,  DateTime? restockedAt,  String addedByUserId,  String? barcode)  $default,) {final _that = this;
switch (_that) {
case _PantryItemDto():
return $default(_that.id,_that.channelId,_that.name,_that.quantity,_that.unit,_that.lowThreshold,_that.expiresAt,_that.isLow,_that.restockedAt,_that.addedByUserId,_that.barcode);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String channelId,  String name,  double quantity,  String? unit,  double? lowThreshold,  DateTime? expiresAt,  bool isLow,  DateTime? restockedAt,  String addedByUserId,  String? barcode)?  $default,) {final _that = this;
switch (_that) {
case _PantryItemDto() when $default != null:
return $default(_that.id,_that.channelId,_that.name,_that.quantity,_that.unit,_that.lowThreshold,_that.expiresAt,_that.isLow,_that.restockedAt,_that.addedByUserId,_that.barcode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _PantryItemDto implements PantryItemDto {
  const _PantryItemDto({required this.id, required this.channelId, required this.name, this.quantity = 0, this.unit, this.lowThreshold, this.expiresAt, this.isLow = false, this.restockedAt, this.addedByUserId = '', this.barcode});
  factory _PantryItemDto.fromJson(Map<String, dynamic> json) => _$PantryItemDtoFromJson(json);

@override final  String id;
@override final  String channelId;
@override final  String name;
@override@JsonKey() final  double quantity;
@override final  String? unit;
/// `null` turns restock tracking off for this item specifically.
@override final  double? lowThreshold;
@override final  DateTime? expiresAt;
@override@JsonKey() final  bool isLow;
/// Non-null while this item is sitting on the shopping list. It's the
/// idempotency guard for the restock loop, not a timestamp anyone needs
/// to read - released when the quantity climbs back above the threshold
/// or the list line is bought/cleared.
@override final  DateTime? restockedAt;
@override@JsonKey() final  String addedByUserId;
/// The code scanned off the packet.
///
/// Two different things can put a name against it and they are not
/// interchangeable: this house's own name, which always wins when there is
/// one, and failing that a suggestion from a shared public product catalog.
/// Only when both come up empty does a scan ask somebody to type one.
@override final  String? barcode;

/// Create a copy of PantryItemDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PantryItemDtoCopyWith<_PantryItemDto> get copyWith => __$PantryItemDtoCopyWithImpl<_PantryItemDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PantryItemDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PantryItemDto&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.name, name) || other.name == name)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.lowThreshold, lowThreshold) || other.lowThreshold == lowThreshold)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.isLow, isLow) || other.isLow == isLow)&&(identical(other.restockedAt, restockedAt) || other.restockedAt == restockedAt)&&(identical(other.addedByUserId, addedByUserId) || other.addedByUserId == addedByUserId)&&(identical(other.barcode, barcode) || other.barcode == barcode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,name,quantity,unit,lowThreshold,expiresAt,isLow,restockedAt,addedByUserId,barcode);

@override
String toString() {
  return 'PantryItemDto(id: $id, channelId: $channelId, name: $name, quantity: $quantity, unit: $unit, lowThreshold: $lowThreshold, expiresAt: $expiresAt, isLow: $isLow, restockedAt: $restockedAt, addedByUserId: $addedByUserId, barcode: $barcode)';
}


}

/// @nodoc
abstract mixin class _$PantryItemDtoCopyWith<$Res> implements $PantryItemDtoCopyWith<$Res> {
  factory _$PantryItemDtoCopyWith(_PantryItemDto value, $Res Function(_PantryItemDto) _then) = __$PantryItemDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String channelId, String name, double quantity, String? unit, double? lowThreshold, DateTime? expiresAt, bool isLow, DateTime? restockedAt, String addedByUserId, String? barcode
});




}
/// @nodoc
class __$PantryItemDtoCopyWithImpl<$Res>
    implements _$PantryItemDtoCopyWith<$Res> {
  __$PantryItemDtoCopyWithImpl(this._self, this._then);

  final _PantryItemDto _self;
  final $Res Function(_PantryItemDto) _then;

/// Create a copy of PantryItemDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? channelId = null,Object? name = null,Object? quantity = null,Object? unit = freezed,Object? lowThreshold = freezed,Object? expiresAt = freezed,Object? isLow = null,Object? restockedAt = freezed,Object? addedByUserId = null,Object? barcode = freezed,}) {
  return _then(_PantryItemDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,lowThreshold: freezed == lowThreshold ? _self.lowThreshold : lowThreshold // ignore: cast_nullable_to_non_nullable
as double?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isLow: null == isLow ? _self.isLow : isLow // ignore: cast_nullable_to_non_nullable
as bool,restockedAt: freezed == restockedAt ? _self.restockedAt : restockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,addedByUserId: null == addedByUserId ? _self.addedByUserId : addedByUserId // ignore: cast_nullable_to_non_nullable
as String,barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ScanResultDto {

 PantryItemDto get item; bool get created; bool get learned; ProductCatalogMatchDto? get catalog;
/// Create a copy of ScanResultDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScanResultDtoCopyWith<ScanResultDto> get copyWith => _$ScanResultDtoCopyWithImpl<ScanResultDto>(this as ScanResultDto, _$identity);

  /// Serializes this ScanResultDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScanResultDto&&(identical(other.item, item) || other.item == item)&&(identical(other.created, created) || other.created == created)&&(identical(other.learned, learned) || other.learned == learned)&&(identical(other.catalog, catalog) || other.catalog == catalog));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,item,created,learned,catalog);

@override
String toString() {
  return 'ScanResultDto(item: $item, created: $created, learned: $learned, catalog: $catalog)';
}


}

/// @nodoc
abstract mixin class $ScanResultDtoCopyWith<$Res>  {
  factory $ScanResultDtoCopyWith(ScanResultDto value, $Res Function(ScanResultDto) _then) = _$ScanResultDtoCopyWithImpl;
@useResult
$Res call({
 PantryItemDto item, bool created, bool learned, ProductCatalogMatchDto? catalog
});


$PantryItemDtoCopyWith<$Res> get item;$ProductCatalogMatchDtoCopyWith<$Res>? get catalog;

}
/// @nodoc
class _$ScanResultDtoCopyWithImpl<$Res>
    implements $ScanResultDtoCopyWith<$Res> {
  _$ScanResultDtoCopyWithImpl(this._self, this._then);

  final ScanResultDto _self;
  final $Res Function(ScanResultDto) _then;

/// Create a copy of ScanResultDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? item = null,Object? created = null,Object? learned = null,Object? catalog = freezed,}) {
  return _then(_self.copyWith(
item: null == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as PantryItemDto,created: null == created ? _self.created : created // ignore: cast_nullable_to_non_nullable
as bool,learned: null == learned ? _self.learned : learned // ignore: cast_nullable_to_non_nullable
as bool,catalog: freezed == catalog ? _self.catalog : catalog // ignore: cast_nullable_to_non_nullable
as ProductCatalogMatchDto?,
  ));
}
/// Create a copy of ScanResultDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PantryItemDtoCopyWith<$Res> get item {
  
  return $PantryItemDtoCopyWith<$Res>(_self.item, (value) {
    return _then(_self.copyWith(item: value));
  });
}/// Create a copy of ScanResultDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductCatalogMatchDtoCopyWith<$Res>? get catalog {
    if (_self.catalog == null) {
    return null;
  }

  return $ProductCatalogMatchDtoCopyWith<$Res>(_self.catalog!, (value) {
    return _then(_self.copyWith(catalog: value));
  });
}
}


/// Adds pattern-matching-related methods to [ScanResultDto].
extension ScanResultDtoPatterns on ScanResultDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScanResultDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScanResultDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScanResultDto value)  $default,){
final _that = this;
switch (_that) {
case _ScanResultDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScanResultDto value)?  $default,){
final _that = this;
switch (_that) {
case _ScanResultDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PantryItemDto item,  bool created,  bool learned,  ProductCatalogMatchDto? catalog)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScanResultDto() when $default != null:
return $default(_that.item,_that.created,_that.learned,_that.catalog);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PantryItemDto item,  bool created,  bool learned,  ProductCatalogMatchDto? catalog)  $default,) {final _that = this;
switch (_that) {
case _ScanResultDto():
return $default(_that.item,_that.created,_that.learned,_that.catalog);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PantryItemDto item,  bool created,  bool learned,  ProductCatalogMatchDto? catalog)?  $default,) {final _that = this;
switch (_that) {
case _ScanResultDto() when $default != null:
return $default(_that.item,_that.created,_that.learned,_that.catalog);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScanResultDto implements ScanResultDto {
  const _ScanResultDto({required this.item, this.created = false, this.learned = false, this.catalog});
  factory _ScanResultDto.fromJson(Map<String, dynamic> json) => _$ScanResultDtoFromJson(json);

@override final  PantryItemDto item;
@override@JsonKey() final  bool created;
@override@JsonKey() final  bool learned;
@override final  ProductCatalogMatchDto? catalog;

/// Create a copy of ScanResultDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScanResultDtoCopyWith<_ScanResultDto> get copyWith => __$ScanResultDtoCopyWithImpl<_ScanResultDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScanResultDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScanResultDto&&(identical(other.item, item) || other.item == item)&&(identical(other.created, created) || other.created == created)&&(identical(other.learned, learned) || other.learned == learned)&&(identical(other.catalog, catalog) || other.catalog == catalog));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,item,created,learned,catalog);

@override
String toString() {
  return 'ScanResultDto(item: $item, created: $created, learned: $learned, catalog: $catalog)';
}


}

/// @nodoc
abstract mixin class _$ScanResultDtoCopyWith<$Res> implements $ScanResultDtoCopyWith<$Res> {
  factory _$ScanResultDtoCopyWith(_ScanResultDto value, $Res Function(_ScanResultDto) _then) = __$ScanResultDtoCopyWithImpl;
@override @useResult
$Res call({
 PantryItemDto item, bool created, bool learned, ProductCatalogMatchDto? catalog
});


@override $PantryItemDtoCopyWith<$Res> get item;@override $ProductCatalogMatchDtoCopyWith<$Res>? get catalog;

}
/// @nodoc
class __$ScanResultDtoCopyWithImpl<$Res>
    implements _$ScanResultDtoCopyWith<$Res> {
  __$ScanResultDtoCopyWithImpl(this._self, this._then);

  final _ScanResultDto _self;
  final $Res Function(_ScanResultDto) _then;

/// Create a copy of ScanResultDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? item = null,Object? created = null,Object? learned = null,Object? catalog = freezed,}) {
  return _then(_ScanResultDto(
item: null == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as PantryItemDto,created: null == created ? _self.created : created // ignore: cast_nullable_to_non_nullable
as bool,learned: null == learned ? _self.learned : learned // ignore: cast_nullable_to_non_nullable
as bool,catalog: freezed == catalog ? _self.catalog : catalog // ignore: cast_nullable_to_non_nullable
as ProductCatalogMatchDto?,
  ));
}

/// Create a copy of ScanResultDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PantryItemDtoCopyWith<$Res> get item {
  
  return $PantryItemDtoCopyWith<$Res>(_self.item, (value) {
    return _then(_self.copyWith(item: value));
  });
}/// Create a copy of ScanResultDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductCatalogMatchDtoCopyWith<$Res>? get catalog {
    if (_self.catalog == null) {
    return null;
  }

  return $ProductCatalogMatchDtoCopyWith<$Res>(_self.catalog!, (value) {
    return _then(_self.copyWith(catalog: value));
  });
}
}


/// @nodoc
mixin _$ProductCatalogMatchDto {

 String get name;/// Which language the name actually came from, which is not always the one
/// asked for: a French-speaking flat scanning a product the catalog only
/// holds in German gets the German name, and this says so rather than
/// pretending.
 String get language; String? get brand; double? get quantity; String? get quantityUnit; String get source; String get sourceName; String get sourceUrl; String get license; String get licenseUrl; String get attribution; DateTime? get importedAt;
/// Create a copy of ProductCatalogMatchDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductCatalogMatchDtoCopyWith<ProductCatalogMatchDto> get copyWith => _$ProductCatalogMatchDtoCopyWithImpl<ProductCatalogMatchDto>(this as ProductCatalogMatchDto, _$identity);

  /// Serializes this ProductCatalogMatchDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductCatalogMatchDto&&(identical(other.name, name) || other.name == name)&&(identical(other.language, language) || other.language == language)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.quantityUnit, quantityUnit) || other.quantityUnit == quantityUnit)&&(identical(other.source, source) || other.source == source)&&(identical(other.sourceName, sourceName) || other.sourceName == sourceName)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.license, license) || other.license == license)&&(identical(other.licenseUrl, licenseUrl) || other.licenseUrl == licenseUrl)&&(identical(other.attribution, attribution) || other.attribution == attribution)&&(identical(other.importedAt, importedAt) || other.importedAt == importedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,language,brand,quantity,quantityUnit,source,sourceName,sourceUrl,license,licenseUrl,attribution,importedAt);

@override
String toString() {
  return 'ProductCatalogMatchDto(name: $name, language: $language, brand: $brand, quantity: $quantity, quantityUnit: $quantityUnit, source: $source, sourceName: $sourceName, sourceUrl: $sourceUrl, license: $license, licenseUrl: $licenseUrl, attribution: $attribution, importedAt: $importedAt)';
}


}

/// @nodoc
abstract mixin class $ProductCatalogMatchDtoCopyWith<$Res>  {
  factory $ProductCatalogMatchDtoCopyWith(ProductCatalogMatchDto value, $Res Function(ProductCatalogMatchDto) _then) = _$ProductCatalogMatchDtoCopyWithImpl;
@useResult
$Res call({
 String name, String language, String? brand, double? quantity, String? quantityUnit, String source, String sourceName, String sourceUrl, String license, String licenseUrl, String attribution, DateTime? importedAt
});




}
/// @nodoc
class _$ProductCatalogMatchDtoCopyWithImpl<$Res>
    implements $ProductCatalogMatchDtoCopyWith<$Res> {
  _$ProductCatalogMatchDtoCopyWithImpl(this._self, this._then);

  final ProductCatalogMatchDto _self;
  final $Res Function(ProductCatalogMatchDto) _then;

/// Create a copy of ProductCatalogMatchDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? language = null,Object? brand = freezed,Object? quantity = freezed,Object? quantityUnit = freezed,Object? source = null,Object? sourceName = null,Object? sourceUrl = null,Object? license = null,Object? licenseUrl = null,Object? attribution = null,Object? importedAt = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double?,quantityUnit: freezed == quantityUnit ? _self.quantityUnit : quantityUnit // ignore: cast_nullable_to_non_nullable
as String?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,sourceName: null == sourceName ? _self.sourceName : sourceName // ignore: cast_nullable_to_non_nullable
as String,sourceUrl: null == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String,license: null == license ? _self.license : license // ignore: cast_nullable_to_non_nullable
as String,licenseUrl: null == licenseUrl ? _self.licenseUrl : licenseUrl // ignore: cast_nullable_to_non_nullable
as String,attribution: null == attribution ? _self.attribution : attribution // ignore: cast_nullable_to_non_nullable
as String,importedAt: freezed == importedAt ? _self.importedAt : importedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductCatalogMatchDto].
extension ProductCatalogMatchDtoPatterns on ProductCatalogMatchDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductCatalogMatchDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductCatalogMatchDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductCatalogMatchDto value)  $default,){
final _that = this;
switch (_that) {
case _ProductCatalogMatchDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductCatalogMatchDto value)?  $default,){
final _that = this;
switch (_that) {
case _ProductCatalogMatchDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String language,  String? brand,  double? quantity,  String? quantityUnit,  String source,  String sourceName,  String sourceUrl,  String license,  String licenseUrl,  String attribution,  DateTime? importedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductCatalogMatchDto() when $default != null:
return $default(_that.name,_that.language,_that.brand,_that.quantity,_that.quantityUnit,_that.source,_that.sourceName,_that.sourceUrl,_that.license,_that.licenseUrl,_that.attribution,_that.importedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String language,  String? brand,  double? quantity,  String? quantityUnit,  String source,  String sourceName,  String sourceUrl,  String license,  String licenseUrl,  String attribution,  DateTime? importedAt)  $default,) {final _that = this;
switch (_that) {
case _ProductCatalogMatchDto():
return $default(_that.name,_that.language,_that.brand,_that.quantity,_that.quantityUnit,_that.source,_that.sourceName,_that.sourceUrl,_that.license,_that.licenseUrl,_that.attribution,_that.importedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String language,  String? brand,  double? quantity,  String? quantityUnit,  String source,  String sourceName,  String sourceUrl,  String license,  String licenseUrl,  String attribution,  DateTime? importedAt)?  $default,) {final _that = this;
switch (_that) {
case _ProductCatalogMatchDto() when $default != null:
return $default(_that.name,_that.language,_that.brand,_that.quantity,_that.quantityUnit,_that.source,_that.sourceName,_that.sourceUrl,_that.license,_that.licenseUrl,_that.attribution,_that.importedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _ProductCatalogMatchDto implements ProductCatalogMatchDto {
  const _ProductCatalogMatchDto({this.name = '', this.language = '', this.brand, this.quantity, this.quantityUnit, this.source = '', this.sourceName = '', this.sourceUrl = '', this.license = '', this.licenseUrl = '', this.attribution = '', this.importedAt});
  factory _ProductCatalogMatchDto.fromJson(Map<String, dynamic> json) => _$ProductCatalogMatchDtoFromJson(json);

@override@JsonKey() final  String name;
/// Which language the name actually came from, which is not always the one
/// asked for: a French-speaking flat scanning a product the catalog only
/// holds in German gets the German name, and this says so rather than
/// pretending.
@override@JsonKey() final  String language;
@override final  String? brand;
@override final  double? quantity;
@override final  String? quantityUnit;
@override@JsonKey() final  String source;
@override@JsonKey() final  String sourceName;
@override@JsonKey() final  String sourceUrl;
@override@JsonKey() final  String license;
@override@JsonKey() final  String licenseUrl;
@override@JsonKey() final  String attribution;
@override final  DateTime? importedAt;

/// Create a copy of ProductCatalogMatchDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCatalogMatchDtoCopyWith<_ProductCatalogMatchDto> get copyWith => __$ProductCatalogMatchDtoCopyWithImpl<_ProductCatalogMatchDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductCatalogMatchDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductCatalogMatchDto&&(identical(other.name, name) || other.name == name)&&(identical(other.language, language) || other.language == language)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.quantityUnit, quantityUnit) || other.quantityUnit == quantityUnit)&&(identical(other.source, source) || other.source == source)&&(identical(other.sourceName, sourceName) || other.sourceName == sourceName)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.license, license) || other.license == license)&&(identical(other.licenseUrl, licenseUrl) || other.licenseUrl == licenseUrl)&&(identical(other.attribution, attribution) || other.attribution == attribution)&&(identical(other.importedAt, importedAt) || other.importedAt == importedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,language,brand,quantity,quantityUnit,source,sourceName,sourceUrl,license,licenseUrl,attribution,importedAt);

@override
String toString() {
  return 'ProductCatalogMatchDto(name: $name, language: $language, brand: $brand, quantity: $quantity, quantityUnit: $quantityUnit, source: $source, sourceName: $sourceName, sourceUrl: $sourceUrl, license: $license, licenseUrl: $licenseUrl, attribution: $attribution, importedAt: $importedAt)';
}


}

/// @nodoc
abstract mixin class _$ProductCatalogMatchDtoCopyWith<$Res> implements $ProductCatalogMatchDtoCopyWith<$Res> {
  factory _$ProductCatalogMatchDtoCopyWith(_ProductCatalogMatchDto value, $Res Function(_ProductCatalogMatchDto) _then) = __$ProductCatalogMatchDtoCopyWithImpl;
@override @useResult
$Res call({
 String name, String language, String? brand, double? quantity, String? quantityUnit, String source, String sourceName, String sourceUrl, String license, String licenseUrl, String attribution, DateTime? importedAt
});




}
/// @nodoc
class __$ProductCatalogMatchDtoCopyWithImpl<$Res>
    implements _$ProductCatalogMatchDtoCopyWith<$Res> {
  __$ProductCatalogMatchDtoCopyWithImpl(this._self, this._then);

  final _ProductCatalogMatchDto _self;
  final $Res Function(_ProductCatalogMatchDto) _then;

/// Create a copy of ProductCatalogMatchDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? language = null,Object? brand = freezed,Object? quantity = freezed,Object? quantityUnit = freezed,Object? source = null,Object? sourceName = null,Object? sourceUrl = null,Object? license = null,Object? licenseUrl = null,Object? attribution = null,Object? importedAt = freezed,}) {
  return _then(_ProductCatalogMatchDto(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double?,quantityUnit: freezed == quantityUnit ? _self.quantityUnit : quantityUnit // ignore: cast_nullable_to_non_nullable
as String?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,sourceName: null == sourceName ? _self.sourceName : sourceName // ignore: cast_nullable_to_non_nullable
as String,sourceUrl: null == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String,license: null == license ? _self.license : license // ignore: cast_nullable_to_non_nullable
as String,licenseUrl: null == licenseUrl ? _self.licenseUrl : licenseUrl // ignore: cast_nullable_to_non_nullable
as String,attribution: null == attribution ? _self.attribution : attribution // ignore: cast_nullable_to_non_nullable
as String,importedAt: freezed == importedAt ? _self.importedAt : importedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$TeachBarcodeResultDto {

 PantryBarcodeDto get barcode; bool get learned; List<PantryItemDto> get renamedItems;
/// Create a copy of TeachBarcodeResultDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeachBarcodeResultDtoCopyWith<TeachBarcodeResultDto> get copyWith => _$TeachBarcodeResultDtoCopyWithImpl<TeachBarcodeResultDto>(this as TeachBarcodeResultDto, _$identity);

  /// Serializes this TeachBarcodeResultDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeachBarcodeResultDto&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.learned, learned) || other.learned == learned)&&const DeepCollectionEquality().equals(other.renamedItems, renamedItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,barcode,learned,const DeepCollectionEquality().hash(renamedItems));

@override
String toString() {
  return 'TeachBarcodeResultDto(barcode: $barcode, learned: $learned, renamedItems: $renamedItems)';
}


}

/// @nodoc
abstract mixin class $TeachBarcodeResultDtoCopyWith<$Res>  {
  factory $TeachBarcodeResultDtoCopyWith(TeachBarcodeResultDto value, $Res Function(TeachBarcodeResultDto) _then) = _$TeachBarcodeResultDtoCopyWithImpl;
@useResult
$Res call({
 PantryBarcodeDto barcode, bool learned, List<PantryItemDto> renamedItems
});


$PantryBarcodeDtoCopyWith<$Res> get barcode;

}
/// @nodoc
class _$TeachBarcodeResultDtoCopyWithImpl<$Res>
    implements $TeachBarcodeResultDtoCopyWith<$Res> {
  _$TeachBarcodeResultDtoCopyWithImpl(this._self, this._then);

  final TeachBarcodeResultDto _self;
  final $Res Function(TeachBarcodeResultDto) _then;

/// Create a copy of TeachBarcodeResultDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? barcode = null,Object? learned = null,Object? renamedItems = null,}) {
  return _then(_self.copyWith(
barcode: null == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as PantryBarcodeDto,learned: null == learned ? _self.learned : learned // ignore: cast_nullable_to_non_nullable
as bool,renamedItems: null == renamedItems ? _self.renamedItems : renamedItems // ignore: cast_nullable_to_non_nullable
as List<PantryItemDto>,
  ));
}
/// Create a copy of TeachBarcodeResultDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PantryBarcodeDtoCopyWith<$Res> get barcode {
  
  return $PantryBarcodeDtoCopyWith<$Res>(_self.barcode, (value) {
    return _then(_self.copyWith(barcode: value));
  });
}
}


/// Adds pattern-matching-related methods to [TeachBarcodeResultDto].
extension TeachBarcodeResultDtoPatterns on TeachBarcodeResultDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeachBarcodeResultDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeachBarcodeResultDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeachBarcodeResultDto value)  $default,){
final _that = this;
switch (_that) {
case _TeachBarcodeResultDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeachBarcodeResultDto value)?  $default,){
final _that = this;
switch (_that) {
case _TeachBarcodeResultDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PantryBarcodeDto barcode,  bool learned,  List<PantryItemDto> renamedItems)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeachBarcodeResultDto() when $default != null:
return $default(_that.barcode,_that.learned,_that.renamedItems);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PantryBarcodeDto barcode,  bool learned,  List<PantryItemDto> renamedItems)  $default,) {final _that = this;
switch (_that) {
case _TeachBarcodeResultDto():
return $default(_that.barcode,_that.learned,_that.renamedItems);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PantryBarcodeDto barcode,  bool learned,  List<PantryItemDto> renamedItems)?  $default,) {final _that = this;
switch (_that) {
case _TeachBarcodeResultDto() when $default != null:
return $default(_that.barcode,_that.learned,_that.renamedItems);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TeachBarcodeResultDto implements TeachBarcodeResultDto {
  const _TeachBarcodeResultDto({required this.barcode, this.learned = false, final  List<PantryItemDto> renamedItems = const <PantryItemDto>[]}): _renamedItems = renamedItems;
  factory _TeachBarcodeResultDto.fromJson(Map<String, dynamic> json) => _$TeachBarcodeResultDtoFromJson(json);

@override final  PantryBarcodeDto barcode;
@override@JsonKey() final  bool learned;
 final  List<PantryItemDto> _renamedItems;
@override@JsonKey() List<PantryItemDto> get renamedItems {
  if (_renamedItems is EqualUnmodifiableListView) return _renamedItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_renamedItems);
}


/// Create a copy of TeachBarcodeResultDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeachBarcodeResultDtoCopyWith<_TeachBarcodeResultDto> get copyWith => __$TeachBarcodeResultDtoCopyWithImpl<_TeachBarcodeResultDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeachBarcodeResultDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeachBarcodeResultDto&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.learned, learned) || other.learned == learned)&&const DeepCollectionEquality().equals(other._renamedItems, _renamedItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,barcode,learned,const DeepCollectionEquality().hash(_renamedItems));

@override
String toString() {
  return 'TeachBarcodeResultDto(barcode: $barcode, learned: $learned, renamedItems: $renamedItems)';
}


}

/// @nodoc
abstract mixin class _$TeachBarcodeResultDtoCopyWith<$Res> implements $TeachBarcodeResultDtoCopyWith<$Res> {
  factory _$TeachBarcodeResultDtoCopyWith(_TeachBarcodeResultDto value, $Res Function(_TeachBarcodeResultDto) _then) = __$TeachBarcodeResultDtoCopyWithImpl;
@override @useResult
$Res call({
 PantryBarcodeDto barcode, bool learned, List<PantryItemDto> renamedItems
});


@override $PantryBarcodeDtoCopyWith<$Res> get barcode;

}
/// @nodoc
class __$TeachBarcodeResultDtoCopyWithImpl<$Res>
    implements _$TeachBarcodeResultDtoCopyWith<$Res> {
  __$TeachBarcodeResultDtoCopyWithImpl(this._self, this._then);

  final _TeachBarcodeResultDto _self;
  final $Res Function(_TeachBarcodeResultDto) _then;

/// Create a copy of TeachBarcodeResultDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? barcode = null,Object? learned = null,Object? renamedItems = null,}) {
  return _then(_TeachBarcodeResultDto(
barcode: null == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as PantryBarcodeDto,learned: null == learned ? _self.learned : learned // ignore: cast_nullable_to_non_nullable
as bool,renamedItems: null == renamedItems ? _self._renamedItems : renamedItems // ignore: cast_nullable_to_non_nullable
as List<PantryItemDto>,
  ));
}

/// Create a copy of TeachBarcodeResultDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PantryBarcodeDtoCopyWith<$Res> get barcode {
  
  return $PantryBarcodeDtoCopyWith<$Res>(_self.barcode, (value) {
    return _then(_self.copyWith(barcode: value));
  });
}
}


/// @nodoc
mixin _$PantryBarcodeDto {

 String get barcode; String get name; String? get unit; double get defaultQuantity; double? get lowThreshold; int get timesSeen; DateTime? get lastUsedAt;
/// Create a copy of PantryBarcodeDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PantryBarcodeDtoCopyWith<PantryBarcodeDto> get copyWith => _$PantryBarcodeDtoCopyWithImpl<PantryBarcodeDto>(this as PantryBarcodeDto, _$identity);

  /// Serializes this PantryBarcodeDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PantryBarcodeDto&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.name, name) || other.name == name)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.defaultQuantity, defaultQuantity) || other.defaultQuantity == defaultQuantity)&&(identical(other.lowThreshold, lowThreshold) || other.lowThreshold == lowThreshold)&&(identical(other.timesSeen, timesSeen) || other.timesSeen == timesSeen)&&(identical(other.lastUsedAt, lastUsedAt) || other.lastUsedAt == lastUsedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,barcode,name,unit,defaultQuantity,lowThreshold,timesSeen,lastUsedAt);

@override
String toString() {
  return 'PantryBarcodeDto(barcode: $barcode, name: $name, unit: $unit, defaultQuantity: $defaultQuantity, lowThreshold: $lowThreshold, timesSeen: $timesSeen, lastUsedAt: $lastUsedAt)';
}


}

/// @nodoc
abstract mixin class $PantryBarcodeDtoCopyWith<$Res>  {
  factory $PantryBarcodeDtoCopyWith(PantryBarcodeDto value, $Res Function(PantryBarcodeDto) _then) = _$PantryBarcodeDtoCopyWithImpl;
@useResult
$Res call({
 String barcode, String name, String? unit, double defaultQuantity, double? lowThreshold, int timesSeen, DateTime? lastUsedAt
});




}
/// @nodoc
class _$PantryBarcodeDtoCopyWithImpl<$Res>
    implements $PantryBarcodeDtoCopyWith<$Res> {
  _$PantryBarcodeDtoCopyWithImpl(this._self, this._then);

  final PantryBarcodeDto _self;
  final $Res Function(PantryBarcodeDto) _then;

/// Create a copy of PantryBarcodeDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? barcode = null,Object? name = null,Object? unit = freezed,Object? defaultQuantity = null,Object? lowThreshold = freezed,Object? timesSeen = null,Object? lastUsedAt = freezed,}) {
  return _then(_self.copyWith(
barcode: null == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,defaultQuantity: null == defaultQuantity ? _self.defaultQuantity : defaultQuantity // ignore: cast_nullable_to_non_nullable
as double,lowThreshold: freezed == lowThreshold ? _self.lowThreshold : lowThreshold // ignore: cast_nullable_to_non_nullable
as double?,timesSeen: null == timesSeen ? _self.timesSeen : timesSeen // ignore: cast_nullable_to_non_nullable
as int,lastUsedAt: freezed == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PantryBarcodeDto].
extension PantryBarcodeDtoPatterns on PantryBarcodeDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PantryBarcodeDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PantryBarcodeDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PantryBarcodeDto value)  $default,){
final _that = this;
switch (_that) {
case _PantryBarcodeDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PantryBarcodeDto value)?  $default,){
final _that = this;
switch (_that) {
case _PantryBarcodeDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String barcode,  String name,  String? unit,  double defaultQuantity,  double? lowThreshold,  int timesSeen,  DateTime? lastUsedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PantryBarcodeDto() when $default != null:
return $default(_that.barcode,_that.name,_that.unit,_that.defaultQuantity,_that.lowThreshold,_that.timesSeen,_that.lastUsedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String barcode,  String name,  String? unit,  double defaultQuantity,  double? lowThreshold,  int timesSeen,  DateTime? lastUsedAt)  $default,) {final _that = this;
switch (_that) {
case _PantryBarcodeDto():
return $default(_that.barcode,_that.name,_that.unit,_that.defaultQuantity,_that.lowThreshold,_that.timesSeen,_that.lastUsedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String barcode,  String name,  String? unit,  double defaultQuantity,  double? lowThreshold,  int timesSeen,  DateTime? lastUsedAt)?  $default,) {final _that = this;
switch (_that) {
case _PantryBarcodeDto() when $default != null:
return $default(_that.barcode,_that.name,_that.unit,_that.defaultQuantity,_that.lowThreshold,_that.timesSeen,_that.lastUsedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _PantryBarcodeDto implements PantryBarcodeDto {
  const _PantryBarcodeDto({this.barcode = '', this.name = '', this.unit, this.defaultQuantity = 1, this.lowThreshold, this.timesSeen = 0, this.lastUsedAt});
  factory _PantryBarcodeDto.fromJson(Map<String, dynamic> json) => _$PantryBarcodeDtoFromJson(json);

@override@JsonKey() final  String barcode;
@override@JsonKey() final  String name;
@override final  String? unit;
@override@JsonKey() final  double defaultQuantity;
@override final  double? lowThreshold;
@override@JsonKey() final  int timesSeen;
@override final  DateTime? lastUsedAt;

/// Create a copy of PantryBarcodeDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PantryBarcodeDtoCopyWith<_PantryBarcodeDto> get copyWith => __$PantryBarcodeDtoCopyWithImpl<_PantryBarcodeDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PantryBarcodeDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PantryBarcodeDto&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.name, name) || other.name == name)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.defaultQuantity, defaultQuantity) || other.defaultQuantity == defaultQuantity)&&(identical(other.lowThreshold, lowThreshold) || other.lowThreshold == lowThreshold)&&(identical(other.timesSeen, timesSeen) || other.timesSeen == timesSeen)&&(identical(other.lastUsedAt, lastUsedAt) || other.lastUsedAt == lastUsedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,barcode,name,unit,defaultQuantity,lowThreshold,timesSeen,lastUsedAt);

@override
String toString() {
  return 'PantryBarcodeDto(barcode: $barcode, name: $name, unit: $unit, defaultQuantity: $defaultQuantity, lowThreshold: $lowThreshold, timesSeen: $timesSeen, lastUsedAt: $lastUsedAt)';
}


}

/// @nodoc
abstract mixin class _$PantryBarcodeDtoCopyWith<$Res> implements $PantryBarcodeDtoCopyWith<$Res> {
  factory _$PantryBarcodeDtoCopyWith(_PantryBarcodeDto value, $Res Function(_PantryBarcodeDto) _then) = __$PantryBarcodeDtoCopyWithImpl;
@override @useResult
$Res call({
 String barcode, String name, String? unit, double defaultQuantity, double? lowThreshold, int timesSeen, DateTime? lastUsedAt
});




}
/// @nodoc
class __$PantryBarcodeDtoCopyWithImpl<$Res>
    implements _$PantryBarcodeDtoCopyWith<$Res> {
  __$PantryBarcodeDtoCopyWithImpl(this._self, this._then);

  final _PantryBarcodeDto _self;
  final $Res Function(_PantryBarcodeDto) _then;

/// Create a copy of PantryBarcodeDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? barcode = null,Object? name = null,Object? unit = freezed,Object? defaultQuantity = null,Object? lowThreshold = freezed,Object? timesSeen = null,Object? lastUsedAt = freezed,}) {
  return _then(_PantryBarcodeDto(
barcode: null == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,defaultQuantity: null == defaultQuantity ? _self.defaultQuantity : defaultQuantity // ignore: cast_nullable_to_non_nullable
as double,lowThreshold: freezed == lowThreshold ? _self.lowThreshold : lowThreshold // ignore: cast_nullable_to_non_nullable
as double?,timesSeen: null == timesSeen ? _self.timesSeen : timesSeen // ignore: cast_nullable_to_non_nullable
as int,lastUsedAt: freezed == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$PantryConfigDto {

 String get channelId;/// Must be a `List` channel in the same guild.
 String? get restockListChannelId;/// 1-90.
 int get expiryWarningDays;
/// Create a copy of PantryConfigDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PantryConfigDtoCopyWith<PantryConfigDto> get copyWith => _$PantryConfigDtoCopyWithImpl<PantryConfigDto>(this as PantryConfigDto, _$identity);

  /// Serializes this PantryConfigDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PantryConfigDto&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.restockListChannelId, restockListChannelId) || other.restockListChannelId == restockListChannelId)&&(identical(other.expiryWarningDays, expiryWarningDays) || other.expiryWarningDays == expiryWarningDays));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,channelId,restockListChannelId,expiryWarningDays);

@override
String toString() {
  return 'PantryConfigDto(channelId: $channelId, restockListChannelId: $restockListChannelId, expiryWarningDays: $expiryWarningDays)';
}


}

/// @nodoc
abstract mixin class $PantryConfigDtoCopyWith<$Res>  {
  factory $PantryConfigDtoCopyWith(PantryConfigDto value, $Res Function(PantryConfigDto) _then) = _$PantryConfigDtoCopyWithImpl;
@useResult
$Res call({
 String channelId, String? restockListChannelId, int expiryWarningDays
});




}
/// @nodoc
class _$PantryConfigDtoCopyWithImpl<$Res>
    implements $PantryConfigDtoCopyWith<$Res> {
  _$PantryConfigDtoCopyWithImpl(this._self, this._then);

  final PantryConfigDto _self;
  final $Res Function(PantryConfigDto) _then;

/// Create a copy of PantryConfigDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? channelId = null,Object? restockListChannelId = freezed,Object? expiryWarningDays = null,}) {
  return _then(_self.copyWith(
channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,restockListChannelId: freezed == restockListChannelId ? _self.restockListChannelId : restockListChannelId // ignore: cast_nullable_to_non_nullable
as String?,expiryWarningDays: null == expiryWarningDays ? _self.expiryWarningDays : expiryWarningDays // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PantryConfigDto].
extension PantryConfigDtoPatterns on PantryConfigDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PantryConfigDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PantryConfigDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PantryConfigDto value)  $default,){
final _that = this;
switch (_that) {
case _PantryConfigDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PantryConfigDto value)?  $default,){
final _that = this;
switch (_that) {
case _PantryConfigDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String channelId,  String? restockListChannelId,  int expiryWarningDays)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PantryConfigDto() when $default != null:
return $default(_that.channelId,_that.restockListChannelId,_that.expiryWarningDays);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String channelId,  String? restockListChannelId,  int expiryWarningDays)  $default,) {final _that = this;
switch (_that) {
case _PantryConfigDto():
return $default(_that.channelId,_that.restockListChannelId,_that.expiryWarningDays);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String channelId,  String? restockListChannelId,  int expiryWarningDays)?  $default,) {final _that = this;
switch (_that) {
case _PantryConfigDto() when $default != null:
return $default(_that.channelId,_that.restockListChannelId,_that.expiryWarningDays);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PantryConfigDto implements PantryConfigDto {
  const _PantryConfigDto({this.channelId = '', this.restockListChannelId, this.expiryWarningDays = 3});
  factory _PantryConfigDto.fromJson(Map<String, dynamic> json) => _$PantryConfigDtoFromJson(json);

@override@JsonKey() final  String channelId;
/// Must be a `List` channel in the same guild.
@override final  String? restockListChannelId;
/// 1-90.
@override@JsonKey() final  int expiryWarningDays;

/// Create a copy of PantryConfigDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PantryConfigDtoCopyWith<_PantryConfigDto> get copyWith => __$PantryConfigDtoCopyWithImpl<_PantryConfigDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PantryConfigDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PantryConfigDto&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.restockListChannelId, restockListChannelId) || other.restockListChannelId == restockListChannelId)&&(identical(other.expiryWarningDays, expiryWarningDays) || other.expiryWarningDays == expiryWarningDays));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,channelId,restockListChannelId,expiryWarningDays);

@override
String toString() {
  return 'PantryConfigDto(channelId: $channelId, restockListChannelId: $restockListChannelId, expiryWarningDays: $expiryWarningDays)';
}


}

/// @nodoc
abstract mixin class _$PantryConfigDtoCopyWith<$Res> implements $PantryConfigDtoCopyWith<$Res> {
  factory _$PantryConfigDtoCopyWith(_PantryConfigDto value, $Res Function(_PantryConfigDto) _then) = __$PantryConfigDtoCopyWithImpl;
@override @useResult
$Res call({
 String channelId, String? restockListChannelId, int expiryWarningDays
});




}
/// @nodoc
class __$PantryConfigDtoCopyWithImpl<$Res>
    implements _$PantryConfigDtoCopyWith<$Res> {
  __$PantryConfigDtoCopyWithImpl(this._self, this._then);

  final _PantryConfigDto _self;
  final $Res Function(_PantryConfigDto) _then;

/// Create a copy of PantryConfigDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? channelId = null,Object? restockListChannelId = freezed,Object? expiryWarningDays = null,}) {
  return _then(_PantryConfigDto(
channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,restockListChannelId: freezed == restockListChannelId ? _self.restockListChannelId : restockListChannelId // ignore: cast_nullable_to_non_nullable
as String?,expiryWarningDays: null == expiryWarningDays ? _self.expiryWarningDays : expiryWarningDays // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
