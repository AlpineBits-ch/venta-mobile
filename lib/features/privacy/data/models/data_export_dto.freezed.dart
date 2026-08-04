// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'data_export_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DataExportDto {

 String get exportId;@JsonKey(unknownEnumValue: DataExportStatus.pending) DataExportStatus get status; DateTime? get requestedAt; DateTime? get completedAt;/// The archive is deleted at this point, not merely hidden. Shown on the
/// row because a download put off for a week is a download that fails.
 DateTime? get expiresAt;/// Why a `Failed` export failed, and on a `Partial` one, the same thing
/// [missingServices] says but in a sentence - which is what a build of this
/// client that predates `Partial` would end up showing, and it stays true
/// there.
 String? get failureReason;/// Services that didn't return their data on a `Partial` export. Empty
/// otherwise, never null.
 List<String> get missingServices;
/// Create a copy of DataExportDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DataExportDtoCopyWith<DataExportDto> get copyWith => _$DataExportDtoCopyWithImpl<DataExportDto>(this as DataExportDto, _$identity);

  /// Serializes this DataExportDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DataExportDto&&(identical(other.exportId, exportId) || other.exportId == exportId)&&(identical(other.status, status) || other.status == status)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&const DeepCollectionEquality().equals(other.missingServices, missingServices));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exportId,status,requestedAt,completedAt,expiresAt,failureReason,const DeepCollectionEquality().hash(missingServices));

@override
String toString() {
  return 'DataExportDto(exportId: $exportId, status: $status, requestedAt: $requestedAt, completedAt: $completedAt, expiresAt: $expiresAt, failureReason: $failureReason, missingServices: $missingServices)';
}


}

/// @nodoc
abstract mixin class $DataExportDtoCopyWith<$Res>  {
  factory $DataExportDtoCopyWith(DataExportDto value, $Res Function(DataExportDto) _then) = _$DataExportDtoCopyWithImpl;
@useResult
$Res call({
 String exportId,@JsonKey(unknownEnumValue: DataExportStatus.pending) DataExportStatus status, DateTime? requestedAt, DateTime? completedAt, DateTime? expiresAt, String? failureReason, List<String> missingServices
});




}
/// @nodoc
class _$DataExportDtoCopyWithImpl<$Res>
    implements $DataExportDtoCopyWith<$Res> {
  _$DataExportDtoCopyWithImpl(this._self, this._then);

  final DataExportDto _self;
  final $Res Function(DataExportDto) _then;

/// Create a copy of DataExportDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exportId = null,Object? status = null,Object? requestedAt = freezed,Object? completedAt = freezed,Object? expiresAt = freezed,Object? failureReason = freezed,Object? missingServices = null,}) {
  return _then(_self.copyWith(
exportId: null == exportId ? _self.exportId : exportId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DataExportStatus,requestedAt: freezed == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,failureReason: freezed == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String?,missingServices: null == missingServices ? _self.missingServices : missingServices // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [DataExportDto].
extension DataExportDtoPatterns on DataExportDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DataExportDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DataExportDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DataExportDto value)  $default,){
final _that = this;
switch (_that) {
case _DataExportDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DataExportDto value)?  $default,){
final _that = this;
switch (_that) {
case _DataExportDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String exportId, @JsonKey(unknownEnumValue: DataExportStatus.pending)  DataExportStatus status,  DateTime? requestedAt,  DateTime? completedAt,  DateTime? expiresAt,  String? failureReason,  List<String> missingServices)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DataExportDto() when $default != null:
return $default(_that.exportId,_that.status,_that.requestedAt,_that.completedAt,_that.expiresAt,_that.failureReason,_that.missingServices);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String exportId, @JsonKey(unknownEnumValue: DataExportStatus.pending)  DataExportStatus status,  DateTime? requestedAt,  DateTime? completedAt,  DateTime? expiresAt,  String? failureReason,  List<String> missingServices)  $default,) {final _that = this;
switch (_that) {
case _DataExportDto():
return $default(_that.exportId,_that.status,_that.requestedAt,_that.completedAt,_that.expiresAt,_that.failureReason,_that.missingServices);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String exportId, @JsonKey(unknownEnumValue: DataExportStatus.pending)  DataExportStatus status,  DateTime? requestedAt,  DateTime? completedAt,  DateTime? expiresAt,  String? failureReason,  List<String> missingServices)?  $default,) {final _that = this;
switch (_that) {
case _DataExportDto() when $default != null:
return $default(_that.exportId,_that.status,_that.requestedAt,_that.completedAt,_that.expiresAt,_that.failureReason,_that.missingServices);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _DataExportDto implements DataExportDto {
  const _DataExportDto({required this.exportId, @JsonKey(unknownEnumValue: DataExportStatus.pending) required this.status, this.requestedAt, this.completedAt, this.expiresAt, this.failureReason, final  List<String> missingServices = const <String>[]}): _missingServices = missingServices;
  factory _DataExportDto.fromJson(Map<String, dynamic> json) => _$DataExportDtoFromJson(json);

@override final  String exportId;
@override@JsonKey(unknownEnumValue: DataExportStatus.pending) final  DataExportStatus status;
@override final  DateTime? requestedAt;
@override final  DateTime? completedAt;
/// The archive is deleted at this point, not merely hidden. Shown on the
/// row because a download put off for a week is a download that fails.
@override final  DateTime? expiresAt;
/// Why a `Failed` export failed, and on a `Partial` one, the same thing
/// [missingServices] says but in a sentence - which is what a build of this
/// client that predates `Partial` would end up showing, and it stays true
/// there.
@override final  String? failureReason;
/// Services that didn't return their data on a `Partial` export. Empty
/// otherwise, never null.
 final  List<String> _missingServices;
/// Services that didn't return their data on a `Partial` export. Empty
/// otherwise, never null.
@override@JsonKey() List<String> get missingServices {
  if (_missingServices is EqualUnmodifiableListView) return _missingServices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_missingServices);
}


/// Create a copy of DataExportDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DataExportDtoCopyWith<_DataExportDto> get copyWith => __$DataExportDtoCopyWithImpl<_DataExportDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DataExportDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DataExportDto&&(identical(other.exportId, exportId) || other.exportId == exportId)&&(identical(other.status, status) || other.status == status)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&const DeepCollectionEquality().equals(other._missingServices, _missingServices));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exportId,status,requestedAt,completedAt,expiresAt,failureReason,const DeepCollectionEquality().hash(_missingServices));

@override
String toString() {
  return 'DataExportDto(exportId: $exportId, status: $status, requestedAt: $requestedAt, completedAt: $completedAt, expiresAt: $expiresAt, failureReason: $failureReason, missingServices: $missingServices)';
}


}

/// @nodoc
abstract mixin class _$DataExportDtoCopyWith<$Res> implements $DataExportDtoCopyWith<$Res> {
  factory _$DataExportDtoCopyWith(_DataExportDto value, $Res Function(_DataExportDto) _then) = __$DataExportDtoCopyWithImpl;
@override @useResult
$Res call({
 String exportId,@JsonKey(unknownEnumValue: DataExportStatus.pending) DataExportStatus status, DateTime? requestedAt, DateTime? completedAt, DateTime? expiresAt, String? failureReason, List<String> missingServices
});




}
/// @nodoc
class __$DataExportDtoCopyWithImpl<$Res>
    implements _$DataExportDtoCopyWith<$Res> {
  __$DataExportDtoCopyWithImpl(this._self, this._then);

  final _DataExportDto _self;
  final $Res Function(_DataExportDto) _then;

/// Create a copy of DataExportDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exportId = null,Object? status = null,Object? requestedAt = freezed,Object? completedAt = freezed,Object? expiresAt = freezed,Object? failureReason = freezed,Object? missingServices = null,}) {
  return _then(_DataExportDto(
exportId: null == exportId ? _self.exportId : exportId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DataExportStatus,requestedAt: freezed == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,failureReason: freezed == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String?,missingServices: null == missingServices ? _self._missingServices : missingServices // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
