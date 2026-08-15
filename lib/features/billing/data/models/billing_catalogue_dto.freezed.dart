// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'billing_catalogue_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BillingPlanDto {

/// The key. Stable, and the thing to match a subscription or a snapshot's
/// plan against. Never rendered.
 String get name; String get displayName; int get versionNumber;/// Lowercase `guild` or `user`. `free`/`plus`/`pro` are server plans;
/// `free_user`/`venta_plus` are account plans, and the two are never listed
/// together.
 String get subjectKind;/// Byte-identical in shape to the entitlement snapshot's own
/// `entitlements`, and typed as the same value so one renderer serves both.
 Map<String, EntitlementValueDto> get entitlements;
/// Create a copy of BillingPlanDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillingPlanDtoCopyWith<BillingPlanDto> get copyWith => _$BillingPlanDtoCopyWithImpl<BillingPlanDto>(this as BillingPlanDto, _$identity);

  /// Serializes this BillingPlanDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillingPlanDto&&(identical(other.name, name) || other.name == name)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.versionNumber, versionNumber) || other.versionNumber == versionNumber)&&(identical(other.subjectKind, subjectKind) || other.subjectKind == subjectKind)&&const DeepCollectionEquality().equals(other.entitlements, entitlements));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,displayName,versionNumber,subjectKind,const DeepCollectionEquality().hash(entitlements));

@override
String toString() {
  return 'BillingPlanDto(name: $name, displayName: $displayName, versionNumber: $versionNumber, subjectKind: $subjectKind, entitlements: $entitlements)';
}


}

/// @nodoc
abstract mixin class $BillingPlanDtoCopyWith<$Res>  {
  factory $BillingPlanDtoCopyWith(BillingPlanDto value, $Res Function(BillingPlanDto) _then) = _$BillingPlanDtoCopyWithImpl;
@useResult
$Res call({
 String name, String displayName, int versionNumber, String subjectKind, Map<String, EntitlementValueDto> entitlements
});




}
/// @nodoc
class _$BillingPlanDtoCopyWithImpl<$Res>
    implements $BillingPlanDtoCopyWith<$Res> {
  _$BillingPlanDtoCopyWithImpl(this._self, this._then);

  final BillingPlanDto _self;
  final $Res Function(BillingPlanDto) _then;

/// Create a copy of BillingPlanDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? displayName = null,Object? versionNumber = null,Object? subjectKind = null,Object? entitlements = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,versionNumber: null == versionNumber ? _self.versionNumber : versionNumber // ignore: cast_nullable_to_non_nullable
as int,subjectKind: null == subjectKind ? _self.subjectKind : subjectKind // ignore: cast_nullable_to_non_nullable
as String,entitlements: null == entitlements ? _self.entitlements : entitlements // ignore: cast_nullable_to_non_nullable
as Map<String, EntitlementValueDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [BillingPlanDto].
extension BillingPlanDtoPatterns on BillingPlanDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BillingPlanDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BillingPlanDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BillingPlanDto value)  $default,){
final _that = this;
switch (_that) {
case _BillingPlanDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BillingPlanDto value)?  $default,){
final _that = this;
switch (_that) {
case _BillingPlanDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String displayName,  int versionNumber,  String subjectKind,  Map<String, EntitlementValueDto> entitlements)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BillingPlanDto() when $default != null:
return $default(_that.name,_that.displayName,_that.versionNumber,_that.subjectKind,_that.entitlements);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String displayName,  int versionNumber,  String subjectKind,  Map<String, EntitlementValueDto> entitlements)  $default,) {final _that = this;
switch (_that) {
case _BillingPlanDto():
return $default(_that.name,_that.displayName,_that.versionNumber,_that.subjectKind,_that.entitlements);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String displayName,  int versionNumber,  String subjectKind,  Map<String, EntitlementValueDto> entitlements)?  $default,) {final _that = this;
switch (_that) {
case _BillingPlanDto() when $default != null:
return $default(_that.name,_that.displayName,_that.versionNumber,_that.subjectKind,_that.entitlements);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BillingPlanDto implements BillingPlanDto {
  const _BillingPlanDto({this.name = '', this.displayName = '', this.versionNumber = 0, this.subjectKind = '', final  Map<String, EntitlementValueDto> entitlements = const <String, EntitlementValueDto>{}}): _entitlements = entitlements;
  factory _BillingPlanDto.fromJson(Map<String, dynamic> json) => _$BillingPlanDtoFromJson(json);

/// The key. Stable, and the thing to match a subscription or a snapshot's
/// plan against. Never rendered.
@override@JsonKey() final  String name;
@override@JsonKey() final  String displayName;
@override@JsonKey() final  int versionNumber;
/// Lowercase `guild` or `user`. `free`/`plus`/`pro` are server plans;
/// `free_user`/`venta_plus` are account plans, and the two are never listed
/// together.
@override@JsonKey() final  String subjectKind;
/// Byte-identical in shape to the entitlement snapshot's own
/// `entitlements`, and typed as the same value so one renderer serves both.
 final  Map<String, EntitlementValueDto> _entitlements;
/// Byte-identical in shape to the entitlement snapshot's own
/// `entitlements`, and typed as the same value so one renderer serves both.
@override@JsonKey() Map<String, EntitlementValueDto> get entitlements {
  if (_entitlements is EqualUnmodifiableMapView) return _entitlements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_entitlements);
}


/// Create a copy of BillingPlanDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillingPlanDtoCopyWith<_BillingPlanDto> get copyWith => __$BillingPlanDtoCopyWithImpl<_BillingPlanDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BillingPlanDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BillingPlanDto&&(identical(other.name, name) || other.name == name)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.versionNumber, versionNumber) || other.versionNumber == versionNumber)&&(identical(other.subjectKind, subjectKind) || other.subjectKind == subjectKind)&&const DeepCollectionEquality().equals(other._entitlements, _entitlements));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,displayName,versionNumber,subjectKind,const DeepCollectionEquality().hash(_entitlements));

@override
String toString() {
  return 'BillingPlanDto(name: $name, displayName: $displayName, versionNumber: $versionNumber, subjectKind: $subjectKind, entitlements: $entitlements)';
}


}

/// @nodoc
abstract mixin class _$BillingPlanDtoCopyWith<$Res> implements $BillingPlanDtoCopyWith<$Res> {
  factory _$BillingPlanDtoCopyWith(_BillingPlanDto value, $Res Function(_BillingPlanDto) _then) = __$BillingPlanDtoCopyWithImpl;
@override @useResult
$Res call({
 String name, String displayName, int versionNumber, String subjectKind, Map<String, EntitlementValueDto> entitlements
});




}
/// @nodoc
class __$BillingPlanDtoCopyWithImpl<$Res>
    implements _$BillingPlanDtoCopyWith<$Res> {
  __$BillingPlanDtoCopyWithImpl(this._self, this._then);

  final _BillingPlanDto _self;
  final $Res Function(_BillingPlanDto) _then;

/// Create a copy of BillingPlanDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? displayName = null,Object? versionNumber = null,Object? subjectKind = null,Object? entitlements = null,}) {
  return _then(_BillingPlanDto(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,versionNumber: null == versionNumber ? _self.versionNumber : versionNumber // ignore: cast_nullable_to_non_nullable
as int,subjectKind: null == subjectKind ? _self.subjectKind : subjectKind // ignore: cast_nullable_to_non_nullable
as String,entitlements: null == entitlements ? _self._entitlements : entitlements // ignore: cast_nullable_to_non_nullable
as Map<String, EntitlementValueDto>,
  ));
}


}


/// @nodoc
mixin _$BillingCatalogueDto {

/// In the order the server sent them, which is the only order this client
/// has and the only one it uses.
///
/// Deliberately not re-sorted, and deliberately not sorted *by* anything
/// here. The server happens to order by price; with no prices rendered and
/// every row drawn identically, that is a stable list rather than a
/// progression. Re-ordering it to put anything at the top or the bottom is
/// how a list becomes a ladder.
 List<BillingPlanDto> get plans;
/// Create a copy of BillingCatalogueDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillingCatalogueDtoCopyWith<BillingCatalogueDto> get copyWith => _$BillingCatalogueDtoCopyWithImpl<BillingCatalogueDto>(this as BillingCatalogueDto, _$identity);

  /// Serializes this BillingCatalogueDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillingCatalogueDto&&const DeepCollectionEquality().equals(other.plans, plans));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(plans));

@override
String toString() {
  return 'BillingCatalogueDto(plans: $plans)';
}


}

/// @nodoc
abstract mixin class $BillingCatalogueDtoCopyWith<$Res>  {
  factory $BillingCatalogueDtoCopyWith(BillingCatalogueDto value, $Res Function(BillingCatalogueDto) _then) = _$BillingCatalogueDtoCopyWithImpl;
@useResult
$Res call({
 List<BillingPlanDto> plans
});




}
/// @nodoc
class _$BillingCatalogueDtoCopyWithImpl<$Res>
    implements $BillingCatalogueDtoCopyWith<$Res> {
  _$BillingCatalogueDtoCopyWithImpl(this._self, this._then);

  final BillingCatalogueDto _self;
  final $Res Function(BillingCatalogueDto) _then;

/// Create a copy of BillingCatalogueDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? plans = null,}) {
  return _then(_self.copyWith(
plans: null == plans ? _self.plans : plans // ignore: cast_nullable_to_non_nullable
as List<BillingPlanDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [BillingCatalogueDto].
extension BillingCatalogueDtoPatterns on BillingCatalogueDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BillingCatalogueDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BillingCatalogueDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BillingCatalogueDto value)  $default,){
final _that = this;
switch (_that) {
case _BillingCatalogueDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BillingCatalogueDto value)?  $default,){
final _that = this;
switch (_that) {
case _BillingCatalogueDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<BillingPlanDto> plans)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BillingCatalogueDto() when $default != null:
return $default(_that.plans);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<BillingPlanDto> plans)  $default,) {final _that = this;
switch (_that) {
case _BillingCatalogueDto():
return $default(_that.plans);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<BillingPlanDto> plans)?  $default,) {final _that = this;
switch (_that) {
case _BillingCatalogueDto() when $default != null:
return $default(_that.plans);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BillingCatalogueDto implements BillingCatalogueDto {
  const _BillingCatalogueDto({final  List<BillingPlanDto> plans = const <BillingPlanDto>[]}): _plans = plans;
  factory _BillingCatalogueDto.fromJson(Map<String, dynamic> json) => _$BillingCatalogueDtoFromJson(json);

/// In the order the server sent them, which is the only order this client
/// has and the only one it uses.
///
/// Deliberately not re-sorted, and deliberately not sorted *by* anything
/// here. The server happens to order by price; with no prices rendered and
/// every row drawn identically, that is a stable list rather than a
/// progression. Re-ordering it to put anything at the top or the bottom is
/// how a list becomes a ladder.
 final  List<BillingPlanDto> _plans;
/// In the order the server sent them, which is the only order this client
/// has and the only one it uses.
///
/// Deliberately not re-sorted, and deliberately not sorted *by* anything
/// here. The server happens to order by price; with no prices rendered and
/// every row drawn identically, that is a stable list rather than a
/// progression. Re-ordering it to put anything at the top or the bottom is
/// how a list becomes a ladder.
@override@JsonKey() List<BillingPlanDto> get plans {
  if (_plans is EqualUnmodifiableListView) return _plans;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_plans);
}


/// Create a copy of BillingCatalogueDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillingCatalogueDtoCopyWith<_BillingCatalogueDto> get copyWith => __$BillingCatalogueDtoCopyWithImpl<_BillingCatalogueDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BillingCatalogueDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BillingCatalogueDto&&const DeepCollectionEquality().equals(other._plans, _plans));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_plans));

@override
String toString() {
  return 'BillingCatalogueDto(plans: $plans)';
}


}

/// @nodoc
abstract mixin class _$BillingCatalogueDtoCopyWith<$Res> implements $BillingCatalogueDtoCopyWith<$Res> {
  factory _$BillingCatalogueDtoCopyWith(_BillingCatalogueDto value, $Res Function(_BillingCatalogueDto) _then) = __$BillingCatalogueDtoCopyWithImpl;
@override @useResult
$Res call({
 List<BillingPlanDto> plans
});




}
/// @nodoc
class __$BillingCatalogueDtoCopyWithImpl<$Res>
    implements _$BillingCatalogueDtoCopyWith<$Res> {
  __$BillingCatalogueDtoCopyWithImpl(this._self, this._then);

  final _BillingCatalogueDto _self;
  final $Res Function(_BillingCatalogueDto) _then;

/// Create a copy of BillingCatalogueDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? plans = null,}) {
  return _then(_BillingCatalogueDto(
plans: null == plans ? _self._plans : plans // ignore: cast_nullable_to_non_nullable
as List<BillingPlanDto>,
  ));
}


}

// dart format on
