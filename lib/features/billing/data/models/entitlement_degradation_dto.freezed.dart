// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entitlement_degradation_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EntitlementDegradationDto {

/// The catalogue key that bound. The display-name lookup is keyed on it -
/// see [entitlementKeyLabel].
 String get key;/// What was asked for and what was given. Always the same shape as each
/// other and as the key's declared kind, which is what lets the sentence
/// name both numbers.
 EntitlementValueDto? get requested; EntitlementValueDto? get granted;@JsonKey(unknownEnumValue: DegradationReason.unknown) DegradationReason get reason;@JsonKey(unknownEnumValue: DegradationBoundBy.unknown) DegradationBoundBy? get boundBy;/// Whose limit this was. For a paired ceiling it is the side named by
/// [boundBy].
 EntitlementSubjectDto get subject;
/// Create a copy of EntitlementDegradationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntitlementDegradationDtoCopyWith<EntitlementDegradationDto> get copyWith => _$EntitlementDegradationDtoCopyWithImpl<EntitlementDegradationDto>(this as EntitlementDegradationDto, _$identity);

  /// Serializes this EntitlementDegradationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EntitlementDegradationDto&&(identical(other.key, key) || other.key == key)&&(identical(other.requested, requested) || other.requested == requested)&&(identical(other.granted, granted) || other.granted == granted)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.boundBy, boundBy) || other.boundBy == boundBy)&&(identical(other.subject, subject) || other.subject == subject));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,requested,granted,reason,boundBy,subject);

@override
String toString() {
  return 'EntitlementDegradationDto(key: $key, requested: $requested, granted: $granted, reason: $reason, boundBy: $boundBy, subject: $subject)';
}


}

/// @nodoc
abstract mixin class $EntitlementDegradationDtoCopyWith<$Res>  {
  factory $EntitlementDegradationDtoCopyWith(EntitlementDegradationDto value, $Res Function(EntitlementDegradationDto) _then) = _$EntitlementDegradationDtoCopyWithImpl;
@useResult
$Res call({
 String key, EntitlementValueDto? requested, EntitlementValueDto? granted,@JsonKey(unknownEnumValue: DegradationReason.unknown) DegradationReason reason,@JsonKey(unknownEnumValue: DegradationBoundBy.unknown) DegradationBoundBy? boundBy, EntitlementSubjectDto subject
});


$EntitlementSubjectDtoCopyWith<$Res> get subject;

}
/// @nodoc
class _$EntitlementDegradationDtoCopyWithImpl<$Res>
    implements $EntitlementDegradationDtoCopyWith<$Res> {
  _$EntitlementDegradationDtoCopyWithImpl(this._self, this._then);

  final EntitlementDegradationDto _self;
  final $Res Function(EntitlementDegradationDto) _then;

/// Create a copy of EntitlementDegradationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? requested = freezed,Object? granted = freezed,Object? reason = null,Object? boundBy = freezed,Object? subject = null,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,requested: freezed == requested ? _self.requested : requested // ignore: cast_nullable_to_non_nullable
as EntitlementValueDto?,granted: freezed == granted ? _self.granted : granted // ignore: cast_nullable_to_non_nullable
as EntitlementValueDto?,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as DegradationReason,boundBy: freezed == boundBy ? _self.boundBy : boundBy // ignore: cast_nullable_to_non_nullable
as DegradationBoundBy?,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as EntitlementSubjectDto,
  ));
}
/// Create a copy of EntitlementDegradationDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EntitlementSubjectDtoCopyWith<$Res> get subject {
  
  return $EntitlementSubjectDtoCopyWith<$Res>(_self.subject, (value) {
    return _then(_self.copyWith(subject: value));
  });
}
}


/// Adds pattern-matching-related methods to [EntitlementDegradationDto].
extension EntitlementDegradationDtoPatterns on EntitlementDegradationDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EntitlementDegradationDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EntitlementDegradationDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EntitlementDegradationDto value)  $default,){
final _that = this;
switch (_that) {
case _EntitlementDegradationDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EntitlementDegradationDto value)?  $default,){
final _that = this;
switch (_that) {
case _EntitlementDegradationDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  EntitlementValueDto? requested,  EntitlementValueDto? granted, @JsonKey(unknownEnumValue: DegradationReason.unknown)  DegradationReason reason, @JsonKey(unknownEnumValue: DegradationBoundBy.unknown)  DegradationBoundBy? boundBy,  EntitlementSubjectDto subject)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EntitlementDegradationDto() when $default != null:
return $default(_that.key,_that.requested,_that.granted,_that.reason,_that.boundBy,_that.subject);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  EntitlementValueDto? requested,  EntitlementValueDto? granted, @JsonKey(unknownEnumValue: DegradationReason.unknown)  DegradationReason reason, @JsonKey(unknownEnumValue: DegradationBoundBy.unknown)  DegradationBoundBy? boundBy,  EntitlementSubjectDto subject)  $default,) {final _that = this;
switch (_that) {
case _EntitlementDegradationDto():
return $default(_that.key,_that.requested,_that.granted,_that.reason,_that.boundBy,_that.subject);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  EntitlementValueDto? requested,  EntitlementValueDto? granted, @JsonKey(unknownEnumValue: DegradationReason.unknown)  DegradationReason reason, @JsonKey(unknownEnumValue: DegradationBoundBy.unknown)  DegradationBoundBy? boundBy,  EntitlementSubjectDto subject)?  $default,) {final _that = this;
switch (_that) {
case _EntitlementDegradationDto() when $default != null:
return $default(_that.key,_that.requested,_that.granted,_that.reason,_that.boundBy,_that.subject);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EntitlementDegradationDto extends EntitlementDegradationDto {
  const _EntitlementDegradationDto({this.key = '', this.requested, this.granted, @JsonKey(unknownEnumValue: DegradationReason.unknown) this.reason = DegradationReason.unknown, @JsonKey(unknownEnumValue: DegradationBoundBy.unknown) this.boundBy, this.subject = const EntitlementSubjectDto()}): super._();
  factory _EntitlementDegradationDto.fromJson(Map<String, dynamic> json) => _$EntitlementDegradationDtoFromJson(json);

/// The catalogue key that bound. The display-name lookup is keyed on it -
/// see [entitlementKeyLabel].
@override@JsonKey() final  String key;
/// What was asked for and what was given. Always the same shape as each
/// other and as the key's declared kind, which is what lets the sentence
/// name both numbers.
@override final  EntitlementValueDto? requested;
@override final  EntitlementValueDto? granted;
@override@JsonKey(unknownEnumValue: DegradationReason.unknown) final  DegradationReason reason;
@override@JsonKey(unknownEnumValue: DegradationBoundBy.unknown) final  DegradationBoundBy? boundBy;
/// Whose limit this was. For a paired ceiling it is the side named by
/// [boundBy].
@override@JsonKey() final  EntitlementSubjectDto subject;

/// Create a copy of EntitlementDegradationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntitlementDegradationDtoCopyWith<_EntitlementDegradationDto> get copyWith => __$EntitlementDegradationDtoCopyWithImpl<_EntitlementDegradationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EntitlementDegradationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EntitlementDegradationDto&&(identical(other.key, key) || other.key == key)&&(identical(other.requested, requested) || other.requested == requested)&&(identical(other.granted, granted) || other.granted == granted)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.boundBy, boundBy) || other.boundBy == boundBy)&&(identical(other.subject, subject) || other.subject == subject));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,requested,granted,reason,boundBy,subject);

@override
String toString() {
  return 'EntitlementDegradationDto(key: $key, requested: $requested, granted: $granted, reason: $reason, boundBy: $boundBy, subject: $subject)';
}


}

/// @nodoc
abstract mixin class _$EntitlementDegradationDtoCopyWith<$Res> implements $EntitlementDegradationDtoCopyWith<$Res> {
  factory _$EntitlementDegradationDtoCopyWith(_EntitlementDegradationDto value, $Res Function(_EntitlementDegradationDto) _then) = __$EntitlementDegradationDtoCopyWithImpl;
@override @useResult
$Res call({
 String key, EntitlementValueDto? requested, EntitlementValueDto? granted,@JsonKey(unknownEnumValue: DegradationReason.unknown) DegradationReason reason,@JsonKey(unknownEnumValue: DegradationBoundBy.unknown) DegradationBoundBy? boundBy, EntitlementSubjectDto subject
});


@override $EntitlementSubjectDtoCopyWith<$Res> get subject;

}
/// @nodoc
class __$EntitlementDegradationDtoCopyWithImpl<$Res>
    implements _$EntitlementDegradationDtoCopyWith<$Res> {
  __$EntitlementDegradationDtoCopyWithImpl(this._self, this._then);

  final _EntitlementDegradationDto _self;
  final $Res Function(_EntitlementDegradationDto) _then;

/// Create a copy of EntitlementDegradationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? requested = freezed,Object? granted = freezed,Object? reason = null,Object? boundBy = freezed,Object? subject = null,}) {
  return _then(_EntitlementDegradationDto(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,requested: freezed == requested ? _self.requested : requested // ignore: cast_nullable_to_non_nullable
as EntitlementValueDto?,granted: freezed == granted ? _self.granted : granted // ignore: cast_nullable_to_non_nullable
as EntitlementValueDto?,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as DegradationReason,boundBy: freezed == boundBy ? _self.boundBy : boundBy // ignore: cast_nullable_to_non_nullable
as DegradationBoundBy?,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as EntitlementSubjectDto,
  ));
}

/// Create a copy of EntitlementDegradationDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EntitlementSubjectDtoCopyWith<$Res> get subject {
  
  return $EntitlementSubjectDtoCopyWith<$Res>(_self.subject, (value) {
    return _then(_self.copyWith(subject: value));
  });
}
}

// dart format on
