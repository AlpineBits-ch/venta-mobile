// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'legal_document_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LegalDocumentDto {

@JsonKey(unknownEnumValue: LegalDocumentType.terms) LegalDocumentType get documentType; String get version; String? get url; String? get contentHash; DateTime? get effectiveAt;
/// Create a copy of LegalDocumentDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LegalDocumentDtoCopyWith<LegalDocumentDto> get copyWith => _$LegalDocumentDtoCopyWithImpl<LegalDocumentDto>(this as LegalDocumentDto, _$identity);

  /// Serializes this LegalDocumentDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LegalDocumentDto&&(identical(other.documentType, documentType) || other.documentType == documentType)&&(identical(other.version, version) || other.version == version)&&(identical(other.url, url) || other.url == url)&&(identical(other.contentHash, contentHash) || other.contentHash == contentHash)&&(identical(other.effectiveAt, effectiveAt) || other.effectiveAt == effectiveAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentType,version,url,contentHash,effectiveAt);

@override
String toString() {
  return 'LegalDocumentDto(documentType: $documentType, version: $version, url: $url, contentHash: $contentHash, effectiveAt: $effectiveAt)';
}


}

/// @nodoc
abstract mixin class $LegalDocumentDtoCopyWith<$Res>  {
  factory $LegalDocumentDtoCopyWith(LegalDocumentDto value, $Res Function(LegalDocumentDto) _then) = _$LegalDocumentDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: LegalDocumentType.terms) LegalDocumentType documentType, String version, String? url, String? contentHash, DateTime? effectiveAt
});




}
/// @nodoc
class _$LegalDocumentDtoCopyWithImpl<$Res>
    implements $LegalDocumentDtoCopyWith<$Res> {
  _$LegalDocumentDtoCopyWithImpl(this._self, this._then);

  final LegalDocumentDto _self;
  final $Res Function(LegalDocumentDto) _then;

/// Create a copy of LegalDocumentDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? documentType = null,Object? version = null,Object? url = freezed,Object? contentHash = freezed,Object? effectiveAt = freezed,}) {
  return _then(_self.copyWith(
documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as LegalDocumentType,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,contentHash: freezed == contentHash ? _self.contentHash : contentHash // ignore: cast_nullable_to_non_nullable
as String?,effectiveAt: freezed == effectiveAt ? _self.effectiveAt : effectiveAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [LegalDocumentDto].
extension LegalDocumentDtoPatterns on LegalDocumentDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LegalDocumentDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LegalDocumentDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LegalDocumentDto value)  $default,){
final _that = this;
switch (_that) {
case _LegalDocumentDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LegalDocumentDto value)?  $default,){
final _that = this;
switch (_that) {
case _LegalDocumentDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: LegalDocumentType.terms)  LegalDocumentType documentType,  String version,  String? url,  String? contentHash,  DateTime? effectiveAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LegalDocumentDto() when $default != null:
return $default(_that.documentType,_that.version,_that.url,_that.contentHash,_that.effectiveAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: LegalDocumentType.terms)  LegalDocumentType documentType,  String version,  String? url,  String? contentHash,  DateTime? effectiveAt)  $default,) {final _that = this;
switch (_that) {
case _LegalDocumentDto():
return $default(_that.documentType,_that.version,_that.url,_that.contentHash,_that.effectiveAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: LegalDocumentType.terms)  LegalDocumentType documentType,  String version,  String? url,  String? contentHash,  DateTime? effectiveAt)?  $default,) {final _that = this;
switch (_that) {
case _LegalDocumentDto() when $default != null:
return $default(_that.documentType,_that.version,_that.url,_that.contentHash,_that.effectiveAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _LegalDocumentDto implements LegalDocumentDto {
  const _LegalDocumentDto({@JsonKey(unknownEnumValue: LegalDocumentType.terms) required this.documentType, required this.version, this.url, this.contentHash, this.effectiveAt});
  factory _LegalDocumentDto.fromJson(Map<String, dynamic> json) => _$LegalDocumentDtoFromJson(json);

@override@JsonKey(unknownEnumValue: LegalDocumentType.terms) final  LegalDocumentType documentType;
@override final  String version;
@override final  String? url;
@override final  String? contentHash;
@override final  DateTime? effectiveAt;

/// Create a copy of LegalDocumentDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LegalDocumentDtoCopyWith<_LegalDocumentDto> get copyWith => __$LegalDocumentDtoCopyWithImpl<_LegalDocumentDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LegalDocumentDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LegalDocumentDto&&(identical(other.documentType, documentType) || other.documentType == documentType)&&(identical(other.version, version) || other.version == version)&&(identical(other.url, url) || other.url == url)&&(identical(other.contentHash, contentHash) || other.contentHash == contentHash)&&(identical(other.effectiveAt, effectiveAt) || other.effectiveAt == effectiveAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentType,version,url,contentHash,effectiveAt);

@override
String toString() {
  return 'LegalDocumentDto(documentType: $documentType, version: $version, url: $url, contentHash: $contentHash, effectiveAt: $effectiveAt)';
}


}

/// @nodoc
abstract mixin class _$LegalDocumentDtoCopyWith<$Res> implements $LegalDocumentDtoCopyWith<$Res> {
  factory _$LegalDocumentDtoCopyWith(_LegalDocumentDto value, $Res Function(_LegalDocumentDto) _then) = __$LegalDocumentDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: LegalDocumentType.terms) LegalDocumentType documentType, String version, String? url, String? contentHash, DateTime? effectiveAt
});




}
/// @nodoc
class __$LegalDocumentDtoCopyWithImpl<$Res>
    implements _$LegalDocumentDtoCopyWith<$Res> {
  __$LegalDocumentDtoCopyWithImpl(this._self, this._then);

  final _LegalDocumentDto _self;
  final $Res Function(_LegalDocumentDto) _then;

/// Create a copy of LegalDocumentDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? documentType = null,Object? version = null,Object? url = freezed,Object? contentHash = freezed,Object? effectiveAt = freezed,}) {
  return _then(_LegalDocumentDto(
documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as LegalDocumentType,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,contentHash: freezed == contentHash ? _self.contentHash : contentHash // ignore: cast_nullable_to_non_nullable
as String?,effectiveAt: freezed == effectiveAt ? _self.effectiveAt : effectiveAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ConsentRequirementDto {

 String get documentType; String get version; DateTime? get effectiveAt; String? get url;
/// Create a copy of ConsentRequirementDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConsentRequirementDtoCopyWith<ConsentRequirementDto> get copyWith => _$ConsentRequirementDtoCopyWithImpl<ConsentRequirementDto>(this as ConsentRequirementDto, _$identity);

  /// Serializes this ConsentRequirementDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConsentRequirementDto&&(identical(other.documentType, documentType) || other.documentType == documentType)&&(identical(other.version, version) || other.version == version)&&(identical(other.effectiveAt, effectiveAt) || other.effectiveAt == effectiveAt)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentType,version,effectiveAt,url);

@override
String toString() {
  return 'ConsentRequirementDto(documentType: $documentType, version: $version, effectiveAt: $effectiveAt, url: $url)';
}


}

/// @nodoc
abstract mixin class $ConsentRequirementDtoCopyWith<$Res>  {
  factory $ConsentRequirementDtoCopyWith(ConsentRequirementDto value, $Res Function(ConsentRequirementDto) _then) = _$ConsentRequirementDtoCopyWithImpl;
@useResult
$Res call({
 String documentType, String version, DateTime? effectiveAt, String? url
});




}
/// @nodoc
class _$ConsentRequirementDtoCopyWithImpl<$Res>
    implements $ConsentRequirementDtoCopyWith<$Res> {
  _$ConsentRequirementDtoCopyWithImpl(this._self, this._then);

  final ConsentRequirementDto _self;
  final $Res Function(ConsentRequirementDto) _then;

/// Create a copy of ConsentRequirementDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? documentType = null,Object? version = null,Object? effectiveAt = freezed,Object? url = freezed,}) {
  return _then(_self.copyWith(
documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,effectiveAt: freezed == effectiveAt ? _self.effectiveAt : effectiveAt // ignore: cast_nullable_to_non_nullable
as DateTime?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ConsentRequirementDto].
extension ConsentRequirementDtoPatterns on ConsentRequirementDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConsentRequirementDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConsentRequirementDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConsentRequirementDto value)  $default,){
final _that = this;
switch (_that) {
case _ConsentRequirementDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConsentRequirementDto value)?  $default,){
final _that = this;
switch (_that) {
case _ConsentRequirementDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String documentType,  String version,  DateTime? effectiveAt,  String? url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConsentRequirementDto() when $default != null:
return $default(_that.documentType,_that.version,_that.effectiveAt,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String documentType,  String version,  DateTime? effectiveAt,  String? url)  $default,) {final _that = this;
switch (_that) {
case _ConsentRequirementDto():
return $default(_that.documentType,_that.version,_that.effectiveAt,_that.url);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String documentType,  String version,  DateTime? effectiveAt,  String? url)?  $default,) {final _that = this;
switch (_that) {
case _ConsentRequirementDto() when $default != null:
return $default(_that.documentType,_that.version,_that.effectiveAt,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _ConsentRequirementDto implements ConsentRequirementDto {
  const _ConsentRequirementDto({required this.documentType, required this.version, this.effectiveAt, this.url});
  factory _ConsentRequirementDto.fromJson(Map<String, dynamic> json) => _$ConsentRequirementDtoFromJson(json);

@override final  String documentType;
@override final  String version;
@override final  DateTime? effectiveAt;
@override final  String? url;

/// Create a copy of ConsentRequirementDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConsentRequirementDtoCopyWith<_ConsentRequirementDto> get copyWith => __$ConsentRequirementDtoCopyWithImpl<_ConsentRequirementDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConsentRequirementDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConsentRequirementDto&&(identical(other.documentType, documentType) || other.documentType == documentType)&&(identical(other.version, version) || other.version == version)&&(identical(other.effectiveAt, effectiveAt) || other.effectiveAt == effectiveAt)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentType,version,effectiveAt,url);

@override
String toString() {
  return 'ConsentRequirementDto(documentType: $documentType, version: $version, effectiveAt: $effectiveAt, url: $url)';
}


}

/// @nodoc
abstract mixin class _$ConsentRequirementDtoCopyWith<$Res> implements $ConsentRequirementDtoCopyWith<$Res> {
  factory _$ConsentRequirementDtoCopyWith(_ConsentRequirementDto value, $Res Function(_ConsentRequirementDto) _then) = __$ConsentRequirementDtoCopyWithImpl;
@override @useResult
$Res call({
 String documentType, String version, DateTime? effectiveAt, String? url
});




}
/// @nodoc
class __$ConsentRequirementDtoCopyWithImpl<$Res>
    implements _$ConsentRequirementDtoCopyWith<$Res> {
  __$ConsentRequirementDtoCopyWithImpl(this._self, this._then);

  final _ConsentRequirementDto _self;
  final $Res Function(_ConsentRequirementDto) _then;

/// Create a copy of ConsentRequirementDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? documentType = null,Object? version = null,Object? effectiveAt = freezed,Object? url = freezed,}) {
  return _then(_ConsentRequirementDto(
documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,effectiveAt: freezed == effectiveAt ? _self.effectiveAt : effectiveAt // ignore: cast_nullable_to_non_nullable
as DateTime?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UserConsentDto {

@JsonKey(unknownEnumValue: LegalDocumentType.terms) LegalDocumentType get documentType; String get version; DateTime? get acceptedAt;
/// Create a copy of UserConsentDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserConsentDtoCopyWith<UserConsentDto> get copyWith => _$UserConsentDtoCopyWithImpl<UserConsentDto>(this as UserConsentDto, _$identity);

  /// Serializes this UserConsentDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserConsentDto&&(identical(other.documentType, documentType) || other.documentType == documentType)&&(identical(other.version, version) || other.version == version)&&(identical(other.acceptedAt, acceptedAt) || other.acceptedAt == acceptedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentType,version,acceptedAt);

@override
String toString() {
  return 'UserConsentDto(documentType: $documentType, version: $version, acceptedAt: $acceptedAt)';
}


}

/// @nodoc
abstract mixin class $UserConsentDtoCopyWith<$Res>  {
  factory $UserConsentDtoCopyWith(UserConsentDto value, $Res Function(UserConsentDto) _then) = _$UserConsentDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: LegalDocumentType.terms) LegalDocumentType documentType, String version, DateTime? acceptedAt
});




}
/// @nodoc
class _$UserConsentDtoCopyWithImpl<$Res>
    implements $UserConsentDtoCopyWith<$Res> {
  _$UserConsentDtoCopyWithImpl(this._self, this._then);

  final UserConsentDto _self;
  final $Res Function(UserConsentDto) _then;

/// Create a copy of UserConsentDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? documentType = null,Object? version = null,Object? acceptedAt = freezed,}) {
  return _then(_self.copyWith(
documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as LegalDocumentType,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,acceptedAt: freezed == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserConsentDto].
extension UserConsentDtoPatterns on UserConsentDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserConsentDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserConsentDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserConsentDto value)  $default,){
final _that = this;
switch (_that) {
case _UserConsentDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserConsentDto value)?  $default,){
final _that = this;
switch (_that) {
case _UserConsentDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: LegalDocumentType.terms)  LegalDocumentType documentType,  String version,  DateTime? acceptedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserConsentDto() when $default != null:
return $default(_that.documentType,_that.version,_that.acceptedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: LegalDocumentType.terms)  LegalDocumentType documentType,  String version,  DateTime? acceptedAt)  $default,) {final _that = this;
switch (_that) {
case _UserConsentDto():
return $default(_that.documentType,_that.version,_that.acceptedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: LegalDocumentType.terms)  LegalDocumentType documentType,  String version,  DateTime? acceptedAt)?  $default,) {final _that = this;
switch (_that) {
case _UserConsentDto() when $default != null:
return $default(_that.documentType,_that.version,_that.acceptedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _UserConsentDto implements UserConsentDto {
  const _UserConsentDto({@JsonKey(unknownEnumValue: LegalDocumentType.terms) required this.documentType, required this.version, this.acceptedAt});
  factory _UserConsentDto.fromJson(Map<String, dynamic> json) => _$UserConsentDtoFromJson(json);

@override@JsonKey(unknownEnumValue: LegalDocumentType.terms) final  LegalDocumentType documentType;
@override final  String version;
@override final  DateTime? acceptedAt;

/// Create a copy of UserConsentDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserConsentDtoCopyWith<_UserConsentDto> get copyWith => __$UserConsentDtoCopyWithImpl<_UserConsentDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserConsentDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserConsentDto&&(identical(other.documentType, documentType) || other.documentType == documentType)&&(identical(other.version, version) || other.version == version)&&(identical(other.acceptedAt, acceptedAt) || other.acceptedAt == acceptedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentType,version,acceptedAt);

@override
String toString() {
  return 'UserConsentDto(documentType: $documentType, version: $version, acceptedAt: $acceptedAt)';
}


}

/// @nodoc
abstract mixin class _$UserConsentDtoCopyWith<$Res> implements $UserConsentDtoCopyWith<$Res> {
  factory _$UserConsentDtoCopyWith(_UserConsentDto value, $Res Function(_UserConsentDto) _then) = __$UserConsentDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: LegalDocumentType.terms) LegalDocumentType documentType, String version, DateTime? acceptedAt
});




}
/// @nodoc
class __$UserConsentDtoCopyWithImpl<$Res>
    implements _$UserConsentDtoCopyWith<$Res> {
  __$UserConsentDtoCopyWithImpl(this._self, this._then);

  final _UserConsentDto _self;
  final $Res Function(_UserConsentDto) _then;

/// Create a copy of UserConsentDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? documentType = null,Object? version = null,Object? acceptedAt = freezed,}) {
  return _then(_UserConsentDto(
documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as LegalDocumentType,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,acceptedAt: freezed == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
