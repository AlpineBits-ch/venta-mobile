// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'maintenance_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MaintenanceAssetDto {

 String get id; String get channelId; String get name; String? get location; String? get brand; String? get model; String? get serialNumber; DateTime? get purchasedAt; DateTime? get warrantyUntil; String? get vendorName; String? get vendorPhone; String? get vendorEmail; String? get notes; int? get serviceIntervalDays; DateTime? get lastServicedAt; DateTime? get nextServiceAt;@JsonKey(unknownEnumValue: AssetStatus.ok) AssetStatus get status; String? get statusNote;/// Computed server-side rather than stored, so no client has to know the
/// sweep's cutoffs or carry a clock the server disagrees with.
 bool get isServiceOverdue; bool get isWarrantyExpiring; String get addedByUserId;
/// Create a copy of MaintenanceAssetDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MaintenanceAssetDtoCopyWith<MaintenanceAssetDto> get copyWith => _$MaintenanceAssetDtoCopyWithImpl<MaintenanceAssetDto>(this as MaintenanceAssetDto, _$identity);

  /// Serializes this MaintenanceAssetDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MaintenanceAssetDto&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.name, name) || other.name == name)&&(identical(other.location, location) || other.location == location)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.model, model) || other.model == model)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.purchasedAt, purchasedAt) || other.purchasedAt == purchasedAt)&&(identical(other.warrantyUntil, warrantyUntil) || other.warrantyUntil == warrantyUntil)&&(identical(other.vendorName, vendorName) || other.vendorName == vendorName)&&(identical(other.vendorPhone, vendorPhone) || other.vendorPhone == vendorPhone)&&(identical(other.vendorEmail, vendorEmail) || other.vendorEmail == vendorEmail)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.serviceIntervalDays, serviceIntervalDays) || other.serviceIntervalDays == serviceIntervalDays)&&(identical(other.lastServicedAt, lastServicedAt) || other.lastServicedAt == lastServicedAt)&&(identical(other.nextServiceAt, nextServiceAt) || other.nextServiceAt == nextServiceAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusNote, statusNote) || other.statusNote == statusNote)&&(identical(other.isServiceOverdue, isServiceOverdue) || other.isServiceOverdue == isServiceOverdue)&&(identical(other.isWarrantyExpiring, isWarrantyExpiring) || other.isWarrantyExpiring == isWarrantyExpiring)&&(identical(other.addedByUserId, addedByUserId) || other.addedByUserId == addedByUserId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,channelId,name,location,brand,model,serialNumber,purchasedAt,warrantyUntil,vendorName,vendorPhone,vendorEmail,notes,serviceIntervalDays,lastServicedAt,nextServiceAt,status,statusNote,isServiceOverdue,isWarrantyExpiring,addedByUserId]);

@override
String toString() {
  return 'MaintenanceAssetDto(id: $id, channelId: $channelId, name: $name, location: $location, brand: $brand, model: $model, serialNumber: $serialNumber, purchasedAt: $purchasedAt, warrantyUntil: $warrantyUntil, vendorName: $vendorName, vendorPhone: $vendorPhone, vendorEmail: $vendorEmail, notes: $notes, serviceIntervalDays: $serviceIntervalDays, lastServicedAt: $lastServicedAt, nextServiceAt: $nextServiceAt, status: $status, statusNote: $statusNote, isServiceOverdue: $isServiceOverdue, isWarrantyExpiring: $isWarrantyExpiring, addedByUserId: $addedByUserId)';
}


}

/// @nodoc
abstract mixin class $MaintenanceAssetDtoCopyWith<$Res>  {
  factory $MaintenanceAssetDtoCopyWith(MaintenanceAssetDto value, $Res Function(MaintenanceAssetDto) _then) = _$MaintenanceAssetDtoCopyWithImpl;
@useResult
$Res call({
 String id, String channelId, String name, String? location, String? brand, String? model, String? serialNumber, DateTime? purchasedAt, DateTime? warrantyUntil, String? vendorName, String? vendorPhone, String? vendorEmail, String? notes, int? serviceIntervalDays, DateTime? lastServicedAt, DateTime? nextServiceAt,@JsonKey(unknownEnumValue: AssetStatus.ok) AssetStatus status, String? statusNote, bool isServiceOverdue, bool isWarrantyExpiring, String addedByUserId
});




}
/// @nodoc
class _$MaintenanceAssetDtoCopyWithImpl<$Res>
    implements $MaintenanceAssetDtoCopyWith<$Res> {
  _$MaintenanceAssetDtoCopyWithImpl(this._self, this._then);

  final MaintenanceAssetDto _self;
  final $Res Function(MaintenanceAssetDto) _then;

/// Create a copy of MaintenanceAssetDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? channelId = null,Object? name = null,Object? location = freezed,Object? brand = freezed,Object? model = freezed,Object? serialNumber = freezed,Object? purchasedAt = freezed,Object? warrantyUntil = freezed,Object? vendorName = freezed,Object? vendorPhone = freezed,Object? vendorEmail = freezed,Object? notes = freezed,Object? serviceIntervalDays = freezed,Object? lastServicedAt = freezed,Object? nextServiceAt = freezed,Object? status = null,Object? statusNote = freezed,Object? isServiceOverdue = null,Object? isWarrantyExpiring = null,Object? addedByUserId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,serialNumber: freezed == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String?,purchasedAt: freezed == purchasedAt ? _self.purchasedAt : purchasedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,warrantyUntil: freezed == warrantyUntil ? _self.warrantyUntil : warrantyUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,vendorName: freezed == vendorName ? _self.vendorName : vendorName // ignore: cast_nullable_to_non_nullable
as String?,vendorPhone: freezed == vendorPhone ? _self.vendorPhone : vendorPhone // ignore: cast_nullable_to_non_nullable
as String?,vendorEmail: freezed == vendorEmail ? _self.vendorEmail : vendorEmail // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,serviceIntervalDays: freezed == serviceIntervalDays ? _self.serviceIntervalDays : serviceIntervalDays // ignore: cast_nullable_to_non_nullable
as int?,lastServicedAt: freezed == lastServicedAt ? _self.lastServicedAt : lastServicedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,nextServiceAt: freezed == nextServiceAt ? _self.nextServiceAt : nextServiceAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AssetStatus,statusNote: freezed == statusNote ? _self.statusNote : statusNote // ignore: cast_nullable_to_non_nullable
as String?,isServiceOverdue: null == isServiceOverdue ? _self.isServiceOverdue : isServiceOverdue // ignore: cast_nullable_to_non_nullable
as bool,isWarrantyExpiring: null == isWarrantyExpiring ? _self.isWarrantyExpiring : isWarrantyExpiring // ignore: cast_nullable_to_non_nullable
as bool,addedByUserId: null == addedByUserId ? _self.addedByUserId : addedByUserId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MaintenanceAssetDto].
extension MaintenanceAssetDtoPatterns on MaintenanceAssetDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MaintenanceAssetDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MaintenanceAssetDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MaintenanceAssetDto value)  $default,){
final _that = this;
switch (_that) {
case _MaintenanceAssetDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MaintenanceAssetDto value)?  $default,){
final _that = this;
switch (_that) {
case _MaintenanceAssetDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String channelId,  String name,  String? location,  String? brand,  String? model,  String? serialNumber,  DateTime? purchasedAt,  DateTime? warrantyUntil,  String? vendorName,  String? vendorPhone,  String? vendorEmail,  String? notes,  int? serviceIntervalDays,  DateTime? lastServicedAt,  DateTime? nextServiceAt, @JsonKey(unknownEnumValue: AssetStatus.ok)  AssetStatus status,  String? statusNote,  bool isServiceOverdue,  bool isWarrantyExpiring,  String addedByUserId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MaintenanceAssetDto() when $default != null:
return $default(_that.id,_that.channelId,_that.name,_that.location,_that.brand,_that.model,_that.serialNumber,_that.purchasedAt,_that.warrantyUntil,_that.vendorName,_that.vendorPhone,_that.vendorEmail,_that.notes,_that.serviceIntervalDays,_that.lastServicedAt,_that.nextServiceAt,_that.status,_that.statusNote,_that.isServiceOverdue,_that.isWarrantyExpiring,_that.addedByUserId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String channelId,  String name,  String? location,  String? brand,  String? model,  String? serialNumber,  DateTime? purchasedAt,  DateTime? warrantyUntil,  String? vendorName,  String? vendorPhone,  String? vendorEmail,  String? notes,  int? serviceIntervalDays,  DateTime? lastServicedAt,  DateTime? nextServiceAt, @JsonKey(unknownEnumValue: AssetStatus.ok)  AssetStatus status,  String? statusNote,  bool isServiceOverdue,  bool isWarrantyExpiring,  String addedByUserId)  $default,) {final _that = this;
switch (_that) {
case _MaintenanceAssetDto():
return $default(_that.id,_that.channelId,_that.name,_that.location,_that.brand,_that.model,_that.serialNumber,_that.purchasedAt,_that.warrantyUntil,_that.vendorName,_that.vendorPhone,_that.vendorEmail,_that.notes,_that.serviceIntervalDays,_that.lastServicedAt,_that.nextServiceAt,_that.status,_that.statusNote,_that.isServiceOverdue,_that.isWarrantyExpiring,_that.addedByUserId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String channelId,  String name,  String? location,  String? brand,  String? model,  String? serialNumber,  DateTime? purchasedAt,  DateTime? warrantyUntil,  String? vendorName,  String? vendorPhone,  String? vendorEmail,  String? notes,  int? serviceIntervalDays,  DateTime? lastServicedAt,  DateTime? nextServiceAt, @JsonKey(unknownEnumValue: AssetStatus.ok)  AssetStatus status,  String? statusNote,  bool isServiceOverdue,  bool isWarrantyExpiring,  String addedByUserId)?  $default,) {final _that = this;
switch (_that) {
case _MaintenanceAssetDto() when $default != null:
return $default(_that.id,_that.channelId,_that.name,_that.location,_that.brand,_that.model,_that.serialNumber,_that.purchasedAt,_that.warrantyUntil,_that.vendorName,_that.vendorPhone,_that.vendorEmail,_that.notes,_that.serviceIntervalDays,_that.lastServicedAt,_that.nextServiceAt,_that.status,_that.statusNote,_that.isServiceOverdue,_that.isWarrantyExpiring,_that.addedByUserId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _MaintenanceAssetDto implements MaintenanceAssetDto {
  const _MaintenanceAssetDto({required this.id, required this.channelId, this.name = '', this.location, this.brand, this.model, this.serialNumber, this.purchasedAt, this.warrantyUntil, this.vendorName, this.vendorPhone, this.vendorEmail, this.notes, this.serviceIntervalDays, this.lastServicedAt, this.nextServiceAt, @JsonKey(unknownEnumValue: AssetStatus.ok) this.status = AssetStatus.ok, this.statusNote, this.isServiceOverdue = false, this.isWarrantyExpiring = false, this.addedByUserId = ''});
  factory _MaintenanceAssetDto.fromJson(Map<String, dynamic> json) => _$MaintenanceAssetDtoFromJson(json);

@override final  String id;
@override final  String channelId;
@override@JsonKey() final  String name;
@override final  String? location;
@override final  String? brand;
@override final  String? model;
@override final  String? serialNumber;
@override final  DateTime? purchasedAt;
@override final  DateTime? warrantyUntil;
@override final  String? vendorName;
@override final  String? vendorPhone;
@override final  String? vendorEmail;
@override final  String? notes;
@override final  int? serviceIntervalDays;
@override final  DateTime? lastServicedAt;
@override final  DateTime? nextServiceAt;
@override@JsonKey(unknownEnumValue: AssetStatus.ok) final  AssetStatus status;
@override final  String? statusNote;
/// Computed server-side rather than stored, so no client has to know the
/// sweep's cutoffs or carry a clock the server disagrees with.
@override@JsonKey() final  bool isServiceOverdue;
@override@JsonKey() final  bool isWarrantyExpiring;
@override@JsonKey() final  String addedByUserId;

/// Create a copy of MaintenanceAssetDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MaintenanceAssetDtoCopyWith<_MaintenanceAssetDto> get copyWith => __$MaintenanceAssetDtoCopyWithImpl<_MaintenanceAssetDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MaintenanceAssetDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MaintenanceAssetDto&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.name, name) || other.name == name)&&(identical(other.location, location) || other.location == location)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.model, model) || other.model == model)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.purchasedAt, purchasedAt) || other.purchasedAt == purchasedAt)&&(identical(other.warrantyUntil, warrantyUntil) || other.warrantyUntil == warrantyUntil)&&(identical(other.vendorName, vendorName) || other.vendorName == vendorName)&&(identical(other.vendorPhone, vendorPhone) || other.vendorPhone == vendorPhone)&&(identical(other.vendorEmail, vendorEmail) || other.vendorEmail == vendorEmail)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.serviceIntervalDays, serviceIntervalDays) || other.serviceIntervalDays == serviceIntervalDays)&&(identical(other.lastServicedAt, lastServicedAt) || other.lastServicedAt == lastServicedAt)&&(identical(other.nextServiceAt, nextServiceAt) || other.nextServiceAt == nextServiceAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusNote, statusNote) || other.statusNote == statusNote)&&(identical(other.isServiceOverdue, isServiceOverdue) || other.isServiceOverdue == isServiceOverdue)&&(identical(other.isWarrantyExpiring, isWarrantyExpiring) || other.isWarrantyExpiring == isWarrantyExpiring)&&(identical(other.addedByUserId, addedByUserId) || other.addedByUserId == addedByUserId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,channelId,name,location,brand,model,serialNumber,purchasedAt,warrantyUntil,vendorName,vendorPhone,vendorEmail,notes,serviceIntervalDays,lastServicedAt,nextServiceAt,status,statusNote,isServiceOverdue,isWarrantyExpiring,addedByUserId]);

@override
String toString() {
  return 'MaintenanceAssetDto(id: $id, channelId: $channelId, name: $name, location: $location, brand: $brand, model: $model, serialNumber: $serialNumber, purchasedAt: $purchasedAt, warrantyUntil: $warrantyUntil, vendorName: $vendorName, vendorPhone: $vendorPhone, vendorEmail: $vendorEmail, notes: $notes, serviceIntervalDays: $serviceIntervalDays, lastServicedAt: $lastServicedAt, nextServiceAt: $nextServiceAt, status: $status, statusNote: $statusNote, isServiceOverdue: $isServiceOverdue, isWarrantyExpiring: $isWarrantyExpiring, addedByUserId: $addedByUserId)';
}


}

/// @nodoc
abstract mixin class _$MaintenanceAssetDtoCopyWith<$Res> implements $MaintenanceAssetDtoCopyWith<$Res> {
  factory _$MaintenanceAssetDtoCopyWith(_MaintenanceAssetDto value, $Res Function(_MaintenanceAssetDto) _then) = __$MaintenanceAssetDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String channelId, String name, String? location, String? brand, String? model, String? serialNumber, DateTime? purchasedAt, DateTime? warrantyUntil, String? vendorName, String? vendorPhone, String? vendorEmail, String? notes, int? serviceIntervalDays, DateTime? lastServicedAt, DateTime? nextServiceAt,@JsonKey(unknownEnumValue: AssetStatus.ok) AssetStatus status, String? statusNote, bool isServiceOverdue, bool isWarrantyExpiring, String addedByUserId
});




}
/// @nodoc
class __$MaintenanceAssetDtoCopyWithImpl<$Res>
    implements _$MaintenanceAssetDtoCopyWith<$Res> {
  __$MaintenanceAssetDtoCopyWithImpl(this._self, this._then);

  final _MaintenanceAssetDto _self;
  final $Res Function(_MaintenanceAssetDto) _then;

/// Create a copy of MaintenanceAssetDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? channelId = null,Object? name = null,Object? location = freezed,Object? brand = freezed,Object? model = freezed,Object? serialNumber = freezed,Object? purchasedAt = freezed,Object? warrantyUntil = freezed,Object? vendorName = freezed,Object? vendorPhone = freezed,Object? vendorEmail = freezed,Object? notes = freezed,Object? serviceIntervalDays = freezed,Object? lastServicedAt = freezed,Object? nextServiceAt = freezed,Object? status = null,Object? statusNote = freezed,Object? isServiceOverdue = null,Object? isWarrantyExpiring = null,Object? addedByUserId = null,}) {
  return _then(_MaintenanceAssetDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,serialNumber: freezed == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String?,purchasedAt: freezed == purchasedAt ? _self.purchasedAt : purchasedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,warrantyUntil: freezed == warrantyUntil ? _self.warrantyUntil : warrantyUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,vendorName: freezed == vendorName ? _self.vendorName : vendorName // ignore: cast_nullable_to_non_nullable
as String?,vendorPhone: freezed == vendorPhone ? _self.vendorPhone : vendorPhone // ignore: cast_nullable_to_non_nullable
as String?,vendorEmail: freezed == vendorEmail ? _self.vendorEmail : vendorEmail // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,serviceIntervalDays: freezed == serviceIntervalDays ? _self.serviceIntervalDays : serviceIntervalDays // ignore: cast_nullable_to_non_nullable
as int?,lastServicedAt: freezed == lastServicedAt ? _self.lastServicedAt : lastServicedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,nextServiceAt: freezed == nextServiceAt ? _self.nextServiceAt : nextServiceAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AssetStatus,statusNote: freezed == statusNote ? _self.statusNote : statusNote // ignore: cast_nullable_to_non_nullable
as String?,isServiceOverdue: null == isServiceOverdue ? _self.isServiceOverdue : isServiceOverdue // ignore: cast_nullable_to_non_nullable
as bool,isWarrantyExpiring: null == isWarrantyExpiring ? _self.isWarrantyExpiring : isWarrantyExpiring // ignore: cast_nullable_to_non_nullable
as bool,addedByUserId: null == addedByUserId ? _self.addedByUserId : addedByUserId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MaintenanceRecordDto {

 String get id;/// Null for work on the house rather than on one machine.
 String? get assetId; String get channelId; String get title; String? get description; DateTime get performedAt; String get performedByUserId; String? get vendorName;/// Minor units, like every other amount in this app.
 int? get costMinor; String? get currency;/// The ledger entry it was paid through, when somebody linked one.
 String? get expenseId;
/// Create a copy of MaintenanceRecordDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MaintenanceRecordDtoCopyWith<MaintenanceRecordDto> get copyWith => _$MaintenanceRecordDtoCopyWithImpl<MaintenanceRecordDto>(this as MaintenanceRecordDto, _$identity);

  /// Serializes this MaintenanceRecordDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MaintenanceRecordDto&&(identical(other.id, id) || other.id == id)&&(identical(other.assetId, assetId) || other.assetId == assetId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.performedAt, performedAt) || other.performedAt == performedAt)&&(identical(other.performedByUserId, performedByUserId) || other.performedByUserId == performedByUserId)&&(identical(other.vendorName, vendorName) || other.vendorName == vendorName)&&(identical(other.costMinor, costMinor) || other.costMinor == costMinor)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.expenseId, expenseId) || other.expenseId == expenseId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,assetId,channelId,title,description,performedAt,performedByUserId,vendorName,costMinor,currency,expenseId);

@override
String toString() {
  return 'MaintenanceRecordDto(id: $id, assetId: $assetId, channelId: $channelId, title: $title, description: $description, performedAt: $performedAt, performedByUserId: $performedByUserId, vendorName: $vendorName, costMinor: $costMinor, currency: $currency, expenseId: $expenseId)';
}


}

/// @nodoc
abstract mixin class $MaintenanceRecordDtoCopyWith<$Res>  {
  factory $MaintenanceRecordDtoCopyWith(MaintenanceRecordDto value, $Res Function(MaintenanceRecordDto) _then) = _$MaintenanceRecordDtoCopyWithImpl;
@useResult
$Res call({
 String id, String? assetId, String channelId, String title, String? description, DateTime performedAt, String performedByUserId, String? vendorName, int? costMinor, String? currency, String? expenseId
});




}
/// @nodoc
class _$MaintenanceRecordDtoCopyWithImpl<$Res>
    implements $MaintenanceRecordDtoCopyWith<$Res> {
  _$MaintenanceRecordDtoCopyWithImpl(this._self, this._then);

  final MaintenanceRecordDto _self;
  final $Res Function(MaintenanceRecordDto) _then;

/// Create a copy of MaintenanceRecordDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? assetId = freezed,Object? channelId = null,Object? title = null,Object? description = freezed,Object? performedAt = null,Object? performedByUserId = null,Object? vendorName = freezed,Object? costMinor = freezed,Object? currency = freezed,Object? expenseId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,assetId: freezed == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as String?,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,performedAt: null == performedAt ? _self.performedAt : performedAt // ignore: cast_nullable_to_non_nullable
as DateTime,performedByUserId: null == performedByUserId ? _self.performedByUserId : performedByUserId // ignore: cast_nullable_to_non_nullable
as String,vendorName: freezed == vendorName ? _self.vendorName : vendorName // ignore: cast_nullable_to_non_nullable
as String?,costMinor: freezed == costMinor ? _self.costMinor : costMinor // ignore: cast_nullable_to_non_nullable
as int?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,expenseId: freezed == expenseId ? _self.expenseId : expenseId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MaintenanceRecordDto].
extension MaintenanceRecordDtoPatterns on MaintenanceRecordDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MaintenanceRecordDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MaintenanceRecordDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MaintenanceRecordDto value)  $default,){
final _that = this;
switch (_that) {
case _MaintenanceRecordDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MaintenanceRecordDto value)?  $default,){
final _that = this;
switch (_that) {
case _MaintenanceRecordDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? assetId,  String channelId,  String title,  String? description,  DateTime performedAt,  String performedByUserId,  String? vendorName,  int? costMinor,  String? currency,  String? expenseId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MaintenanceRecordDto() when $default != null:
return $default(_that.id,_that.assetId,_that.channelId,_that.title,_that.description,_that.performedAt,_that.performedByUserId,_that.vendorName,_that.costMinor,_that.currency,_that.expenseId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? assetId,  String channelId,  String title,  String? description,  DateTime performedAt,  String performedByUserId,  String? vendorName,  int? costMinor,  String? currency,  String? expenseId)  $default,) {final _that = this;
switch (_that) {
case _MaintenanceRecordDto():
return $default(_that.id,_that.assetId,_that.channelId,_that.title,_that.description,_that.performedAt,_that.performedByUserId,_that.vendorName,_that.costMinor,_that.currency,_that.expenseId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? assetId,  String channelId,  String title,  String? description,  DateTime performedAt,  String performedByUserId,  String? vendorName,  int? costMinor,  String? currency,  String? expenseId)?  $default,) {final _that = this;
switch (_that) {
case _MaintenanceRecordDto() when $default != null:
return $default(_that.id,_that.assetId,_that.channelId,_that.title,_that.description,_that.performedAt,_that.performedByUserId,_that.vendorName,_that.costMinor,_that.currency,_that.expenseId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _MaintenanceRecordDto implements MaintenanceRecordDto {
  const _MaintenanceRecordDto({required this.id, this.assetId, required this.channelId, this.title = '', this.description, required this.performedAt, this.performedByUserId = '', this.vendorName, this.costMinor, this.currency, this.expenseId});
  factory _MaintenanceRecordDto.fromJson(Map<String, dynamic> json) => _$MaintenanceRecordDtoFromJson(json);

@override final  String id;
/// Null for work on the house rather than on one machine.
@override final  String? assetId;
@override final  String channelId;
@override@JsonKey() final  String title;
@override final  String? description;
@override final  DateTime performedAt;
@override@JsonKey() final  String performedByUserId;
@override final  String? vendorName;
/// Minor units, like every other amount in this app.
@override final  int? costMinor;
@override final  String? currency;
/// The ledger entry it was paid through, when somebody linked one.
@override final  String? expenseId;

/// Create a copy of MaintenanceRecordDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MaintenanceRecordDtoCopyWith<_MaintenanceRecordDto> get copyWith => __$MaintenanceRecordDtoCopyWithImpl<_MaintenanceRecordDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MaintenanceRecordDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MaintenanceRecordDto&&(identical(other.id, id) || other.id == id)&&(identical(other.assetId, assetId) || other.assetId == assetId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.performedAt, performedAt) || other.performedAt == performedAt)&&(identical(other.performedByUserId, performedByUserId) || other.performedByUserId == performedByUserId)&&(identical(other.vendorName, vendorName) || other.vendorName == vendorName)&&(identical(other.costMinor, costMinor) || other.costMinor == costMinor)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.expenseId, expenseId) || other.expenseId == expenseId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,assetId,channelId,title,description,performedAt,performedByUserId,vendorName,costMinor,currency,expenseId);

@override
String toString() {
  return 'MaintenanceRecordDto(id: $id, assetId: $assetId, channelId: $channelId, title: $title, description: $description, performedAt: $performedAt, performedByUserId: $performedByUserId, vendorName: $vendorName, costMinor: $costMinor, currency: $currency, expenseId: $expenseId)';
}


}

/// @nodoc
abstract mixin class _$MaintenanceRecordDtoCopyWith<$Res> implements $MaintenanceRecordDtoCopyWith<$Res> {
  factory _$MaintenanceRecordDtoCopyWith(_MaintenanceRecordDto value, $Res Function(_MaintenanceRecordDto) _then) = __$MaintenanceRecordDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String? assetId, String channelId, String title, String? description, DateTime performedAt, String performedByUserId, String? vendorName, int? costMinor, String? currency, String? expenseId
});




}
/// @nodoc
class __$MaintenanceRecordDtoCopyWithImpl<$Res>
    implements _$MaintenanceRecordDtoCopyWith<$Res> {
  __$MaintenanceRecordDtoCopyWithImpl(this._self, this._then);

  final _MaintenanceRecordDto _self;
  final $Res Function(_MaintenanceRecordDto) _then;

/// Create a copy of MaintenanceRecordDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? assetId = freezed,Object? channelId = null,Object? title = null,Object? description = freezed,Object? performedAt = null,Object? performedByUserId = null,Object? vendorName = freezed,Object? costMinor = freezed,Object? currency = freezed,Object? expenseId = freezed,}) {
  return _then(_MaintenanceRecordDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,assetId: freezed == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as String?,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,performedAt: null == performedAt ? _self.performedAt : performedAt // ignore: cast_nullable_to_non_nullable
as DateTime,performedByUserId: null == performedByUserId ? _self.performedByUserId : performedByUserId // ignore: cast_nullable_to_non_nullable
as String,vendorName: freezed == vendorName ? _self.vendorName : vendorName // ignore: cast_nullable_to_non_nullable
as String?,costMinor: freezed == costMinor ? _self.costMinor : costMinor // ignore: cast_nullable_to_non_nullable
as int?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,expenseId: freezed == expenseId ? _self.expenseId : expenseId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$MaintenanceRecordPageDto {

 List<MaintenanceRecordDto> get items; String? get nextCursor;
/// Create a copy of MaintenanceRecordPageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MaintenanceRecordPageDtoCopyWith<MaintenanceRecordPageDto> get copyWith => _$MaintenanceRecordPageDtoCopyWithImpl<MaintenanceRecordPageDto>(this as MaintenanceRecordPageDto, _$identity);

  /// Serializes this MaintenanceRecordPageDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MaintenanceRecordPageDto&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),nextCursor);

@override
String toString() {
  return 'MaintenanceRecordPageDto(items: $items, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class $MaintenanceRecordPageDtoCopyWith<$Res>  {
  factory $MaintenanceRecordPageDtoCopyWith(MaintenanceRecordPageDto value, $Res Function(MaintenanceRecordPageDto) _then) = _$MaintenanceRecordPageDtoCopyWithImpl;
@useResult
$Res call({
 List<MaintenanceRecordDto> items, String? nextCursor
});




}
/// @nodoc
class _$MaintenanceRecordPageDtoCopyWithImpl<$Res>
    implements $MaintenanceRecordPageDtoCopyWith<$Res> {
  _$MaintenanceRecordPageDtoCopyWithImpl(this._self, this._then);

  final MaintenanceRecordPageDto _self;
  final $Res Function(MaintenanceRecordPageDto) _then;

/// Create a copy of MaintenanceRecordPageDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? nextCursor = freezed,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<MaintenanceRecordDto>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MaintenanceRecordPageDto].
extension MaintenanceRecordPageDtoPatterns on MaintenanceRecordPageDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MaintenanceRecordPageDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MaintenanceRecordPageDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MaintenanceRecordPageDto value)  $default,){
final _that = this;
switch (_that) {
case _MaintenanceRecordPageDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MaintenanceRecordPageDto value)?  $default,){
final _that = this;
switch (_that) {
case _MaintenanceRecordPageDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MaintenanceRecordDto> items,  String? nextCursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MaintenanceRecordPageDto() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MaintenanceRecordDto> items,  String? nextCursor)  $default,) {final _that = this;
switch (_that) {
case _MaintenanceRecordPageDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MaintenanceRecordDto> items,  String? nextCursor)?  $default,) {final _that = this;
switch (_that) {
case _MaintenanceRecordPageDto() when $default != null:
return $default(_that.items,_that.nextCursor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MaintenanceRecordPageDto implements MaintenanceRecordPageDto {
  const _MaintenanceRecordPageDto({final  List<MaintenanceRecordDto> items = const <MaintenanceRecordDto>[], this.nextCursor}): _items = items;
  factory _MaintenanceRecordPageDto.fromJson(Map<String, dynamic> json) => _$MaintenanceRecordPageDtoFromJson(json);

 final  List<MaintenanceRecordDto> _items;
@override@JsonKey() List<MaintenanceRecordDto> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? nextCursor;

/// Create a copy of MaintenanceRecordPageDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MaintenanceRecordPageDtoCopyWith<_MaintenanceRecordPageDto> get copyWith => __$MaintenanceRecordPageDtoCopyWithImpl<_MaintenanceRecordPageDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MaintenanceRecordPageDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MaintenanceRecordPageDto&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),nextCursor);

@override
String toString() {
  return 'MaintenanceRecordPageDto(items: $items, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class _$MaintenanceRecordPageDtoCopyWith<$Res> implements $MaintenanceRecordPageDtoCopyWith<$Res> {
  factory _$MaintenanceRecordPageDtoCopyWith(_MaintenanceRecordPageDto value, $Res Function(_MaintenanceRecordPageDto) _then) = __$MaintenanceRecordPageDtoCopyWithImpl;
@override @useResult
$Res call({
 List<MaintenanceRecordDto> items, String? nextCursor
});




}
/// @nodoc
class __$MaintenanceRecordPageDtoCopyWithImpl<$Res>
    implements _$MaintenanceRecordPageDtoCopyWith<$Res> {
  __$MaintenanceRecordPageDtoCopyWithImpl(this._self, this._then);

  final _MaintenanceRecordPageDto _self;
  final $Res Function(_MaintenanceRecordPageDto) _then;

/// Create a copy of MaintenanceRecordPageDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? nextCursor = freezed,}) {
  return _then(_MaintenanceRecordPageDto(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<MaintenanceRecordDto>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$MaintenanceAttentionDto {

 MaintenanceAssetDto get asset;/// Stable tokens: `broken`, `needs_attention`, `service_overdue`,
/// `warranty_expiring`. An asset can carry more than one.
 List<String> get reasons;
/// Create a copy of MaintenanceAttentionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MaintenanceAttentionDtoCopyWith<MaintenanceAttentionDto> get copyWith => _$MaintenanceAttentionDtoCopyWithImpl<MaintenanceAttentionDto>(this as MaintenanceAttentionDto, _$identity);

  /// Serializes this MaintenanceAttentionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MaintenanceAttentionDto&&(identical(other.asset, asset) || other.asset == asset)&&const DeepCollectionEquality().equals(other.reasons, reasons));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,asset,const DeepCollectionEquality().hash(reasons));

@override
String toString() {
  return 'MaintenanceAttentionDto(asset: $asset, reasons: $reasons)';
}


}

/// @nodoc
abstract mixin class $MaintenanceAttentionDtoCopyWith<$Res>  {
  factory $MaintenanceAttentionDtoCopyWith(MaintenanceAttentionDto value, $Res Function(MaintenanceAttentionDto) _then) = _$MaintenanceAttentionDtoCopyWithImpl;
@useResult
$Res call({
 MaintenanceAssetDto asset, List<String> reasons
});


$MaintenanceAssetDtoCopyWith<$Res> get asset;

}
/// @nodoc
class _$MaintenanceAttentionDtoCopyWithImpl<$Res>
    implements $MaintenanceAttentionDtoCopyWith<$Res> {
  _$MaintenanceAttentionDtoCopyWithImpl(this._self, this._then);

  final MaintenanceAttentionDto _self;
  final $Res Function(MaintenanceAttentionDto) _then;

/// Create a copy of MaintenanceAttentionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? asset = null,Object? reasons = null,}) {
  return _then(_self.copyWith(
asset: null == asset ? _self.asset : asset // ignore: cast_nullable_to_non_nullable
as MaintenanceAssetDto,reasons: null == reasons ? _self.reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of MaintenanceAttentionDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MaintenanceAssetDtoCopyWith<$Res> get asset {
  
  return $MaintenanceAssetDtoCopyWith<$Res>(_self.asset, (value) {
    return _then(_self.copyWith(asset: value));
  });
}
}


/// Adds pattern-matching-related methods to [MaintenanceAttentionDto].
extension MaintenanceAttentionDtoPatterns on MaintenanceAttentionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MaintenanceAttentionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MaintenanceAttentionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MaintenanceAttentionDto value)  $default,){
final _that = this;
switch (_that) {
case _MaintenanceAttentionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MaintenanceAttentionDto value)?  $default,){
final _that = this;
switch (_that) {
case _MaintenanceAttentionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MaintenanceAssetDto asset,  List<String> reasons)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MaintenanceAttentionDto() when $default != null:
return $default(_that.asset,_that.reasons);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MaintenanceAssetDto asset,  List<String> reasons)  $default,) {final _that = this;
switch (_that) {
case _MaintenanceAttentionDto():
return $default(_that.asset,_that.reasons);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MaintenanceAssetDto asset,  List<String> reasons)?  $default,) {final _that = this;
switch (_that) {
case _MaintenanceAttentionDto() when $default != null:
return $default(_that.asset,_that.reasons);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MaintenanceAttentionDto implements MaintenanceAttentionDto {
  const _MaintenanceAttentionDto({required this.asset, final  List<String> reasons = const <String>[]}): _reasons = reasons;
  factory _MaintenanceAttentionDto.fromJson(Map<String, dynamic> json) => _$MaintenanceAttentionDtoFromJson(json);

@override final  MaintenanceAssetDto asset;
/// Stable tokens: `broken`, `needs_attention`, `service_overdue`,
/// `warranty_expiring`. An asset can carry more than one.
 final  List<String> _reasons;
/// Stable tokens: `broken`, `needs_attention`, `service_overdue`,
/// `warranty_expiring`. An asset can carry more than one.
@override@JsonKey() List<String> get reasons {
  if (_reasons is EqualUnmodifiableListView) return _reasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reasons);
}


/// Create a copy of MaintenanceAttentionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MaintenanceAttentionDtoCopyWith<_MaintenanceAttentionDto> get copyWith => __$MaintenanceAttentionDtoCopyWithImpl<_MaintenanceAttentionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MaintenanceAttentionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MaintenanceAttentionDto&&(identical(other.asset, asset) || other.asset == asset)&&const DeepCollectionEquality().equals(other._reasons, _reasons));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,asset,const DeepCollectionEquality().hash(_reasons));

@override
String toString() {
  return 'MaintenanceAttentionDto(asset: $asset, reasons: $reasons)';
}


}

/// @nodoc
abstract mixin class _$MaintenanceAttentionDtoCopyWith<$Res> implements $MaintenanceAttentionDtoCopyWith<$Res> {
  factory _$MaintenanceAttentionDtoCopyWith(_MaintenanceAttentionDto value, $Res Function(_MaintenanceAttentionDto) _then) = __$MaintenanceAttentionDtoCopyWithImpl;
@override @useResult
$Res call({
 MaintenanceAssetDto asset, List<String> reasons
});


@override $MaintenanceAssetDtoCopyWith<$Res> get asset;

}
/// @nodoc
class __$MaintenanceAttentionDtoCopyWithImpl<$Res>
    implements _$MaintenanceAttentionDtoCopyWith<$Res> {
  __$MaintenanceAttentionDtoCopyWithImpl(this._self, this._then);

  final _MaintenanceAttentionDto _self;
  final $Res Function(_MaintenanceAttentionDto) _then;

/// Create a copy of MaintenanceAttentionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? asset = null,Object? reasons = null,}) {
  return _then(_MaintenanceAttentionDto(
asset: null == asset ? _self.asset : asset // ignore: cast_nullable_to_non_nullable
as MaintenanceAssetDto,reasons: null == reasons ? _self._reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of MaintenanceAttentionDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MaintenanceAssetDtoCopyWith<$Res> get asset {
  
  return $MaintenanceAssetDtoCopyWith<$Res>(_self.asset, (value) {
    return _then(_self.copyWith(asset: value));
  });
}
}

// dart format on
