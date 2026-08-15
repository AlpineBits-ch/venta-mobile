// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entitlement_snapshot_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EntitlementSubjectDto {

/// Lowercase `user` or `guild`. Compare with [sameSubjectKind] rather than
/// `==`: this build talks to instances running older services, and a
/// subscription that arrives as `Guild` should still land on the servers
/// section rather than nowhere.
 String get kind; String get id;
/// Create a copy of EntitlementSubjectDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntitlementSubjectDtoCopyWith<EntitlementSubjectDto> get copyWith => _$EntitlementSubjectDtoCopyWithImpl<EntitlementSubjectDto>(this as EntitlementSubjectDto, _$identity);

  /// Serializes this EntitlementSubjectDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EntitlementSubjectDto&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.id, id) || other.id == id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,id);

@override
String toString() {
  return 'EntitlementSubjectDto(kind: $kind, id: $id)';
}


}

/// @nodoc
abstract mixin class $EntitlementSubjectDtoCopyWith<$Res>  {
  factory $EntitlementSubjectDtoCopyWith(EntitlementSubjectDto value, $Res Function(EntitlementSubjectDto) _then) = _$EntitlementSubjectDtoCopyWithImpl;
@useResult
$Res call({
 String kind, String id
});




}
/// @nodoc
class _$EntitlementSubjectDtoCopyWithImpl<$Res>
    implements $EntitlementSubjectDtoCopyWith<$Res> {
  _$EntitlementSubjectDtoCopyWithImpl(this._self, this._then);

  final EntitlementSubjectDto _self;
  final $Res Function(EntitlementSubjectDto) _then;

/// Create a copy of EntitlementSubjectDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? id = null,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [EntitlementSubjectDto].
extension EntitlementSubjectDtoPatterns on EntitlementSubjectDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EntitlementSubjectDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EntitlementSubjectDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EntitlementSubjectDto value)  $default,){
final _that = this;
switch (_that) {
case _EntitlementSubjectDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EntitlementSubjectDto value)?  $default,){
final _that = this;
switch (_that) {
case _EntitlementSubjectDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String kind,  String id)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EntitlementSubjectDto() when $default != null:
return $default(_that.kind,_that.id);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String kind,  String id)  $default,) {final _that = this;
switch (_that) {
case _EntitlementSubjectDto():
return $default(_that.kind,_that.id);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String kind,  String id)?  $default,) {final _that = this;
switch (_that) {
case _EntitlementSubjectDto() when $default != null:
return $default(_that.kind,_that.id);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EntitlementSubjectDto implements EntitlementSubjectDto {
  const _EntitlementSubjectDto({this.kind = '', this.id = ''});
  factory _EntitlementSubjectDto.fromJson(Map<String, dynamic> json) => _$EntitlementSubjectDtoFromJson(json);

/// Lowercase `user` or `guild`. Compare with [sameSubjectKind] rather than
/// `==`: this build talks to instances running older services, and a
/// subscription that arrives as `Guild` should still land on the servers
/// section rather than nowhere.
@override@JsonKey() final  String kind;
@override@JsonKey() final  String id;

/// Create a copy of EntitlementSubjectDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntitlementSubjectDtoCopyWith<_EntitlementSubjectDto> get copyWith => __$EntitlementSubjectDtoCopyWithImpl<_EntitlementSubjectDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EntitlementSubjectDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EntitlementSubjectDto&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.id, id) || other.id == id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,id);

@override
String toString() {
  return 'EntitlementSubjectDto(kind: $kind, id: $id)';
}


}

/// @nodoc
abstract mixin class _$EntitlementSubjectDtoCopyWith<$Res> implements $EntitlementSubjectDtoCopyWith<$Res> {
  factory _$EntitlementSubjectDtoCopyWith(_EntitlementSubjectDto value, $Res Function(_EntitlementSubjectDto) _then) = __$EntitlementSubjectDtoCopyWithImpl;
@override @useResult
$Res call({
 String kind, String id
});




}
/// @nodoc
class __$EntitlementSubjectDtoCopyWithImpl<$Res>
    implements _$EntitlementSubjectDtoCopyWith<$Res> {
  __$EntitlementSubjectDtoCopyWithImpl(this._self, this._then);

  final _EntitlementSubjectDto _self;
  final $Res Function(_EntitlementSubjectDto) _then;

/// Create a copy of EntitlementSubjectDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? id = null,}) {
  return _then(_EntitlementSubjectDto(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$EntitlementPlanDto {

/// The key. Stable, and the thing to match on. Never rendered.
 String get name;/// What to render. The server never sends this null - a plan an operator
/// gave no display name reports its own name - so nothing has to choose
/// between two fields.
 String get displayName;/// The version this subject is actually on, which is not necessarily the
/// current one.
 int? get version;/// The plan's newest version, when the catalogue publishes versions.
 int? get currentVersion;
/// Create a copy of EntitlementPlanDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntitlementPlanDtoCopyWith<EntitlementPlanDto> get copyWith => _$EntitlementPlanDtoCopyWithImpl<EntitlementPlanDto>(this as EntitlementPlanDto, _$identity);

  /// Serializes this EntitlementPlanDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EntitlementPlanDto&&(identical(other.name, name) || other.name == name)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.version, version) || other.version == version)&&(identical(other.currentVersion, currentVersion) || other.currentVersion == currentVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,displayName,version,currentVersion);

@override
String toString() {
  return 'EntitlementPlanDto(name: $name, displayName: $displayName, version: $version, currentVersion: $currentVersion)';
}


}

/// @nodoc
abstract mixin class $EntitlementPlanDtoCopyWith<$Res>  {
  factory $EntitlementPlanDtoCopyWith(EntitlementPlanDto value, $Res Function(EntitlementPlanDto) _then) = _$EntitlementPlanDtoCopyWithImpl;
@useResult
$Res call({
 String name, String displayName, int? version, int? currentVersion
});




}
/// @nodoc
class _$EntitlementPlanDtoCopyWithImpl<$Res>
    implements $EntitlementPlanDtoCopyWith<$Res> {
  _$EntitlementPlanDtoCopyWithImpl(this._self, this._then);

  final EntitlementPlanDto _self;
  final $Res Function(EntitlementPlanDto) _then;

/// Create a copy of EntitlementPlanDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? displayName = null,Object? version = freezed,Object? currentVersion = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int?,currentVersion: freezed == currentVersion ? _self.currentVersion : currentVersion // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [EntitlementPlanDto].
extension EntitlementPlanDtoPatterns on EntitlementPlanDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EntitlementPlanDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EntitlementPlanDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EntitlementPlanDto value)  $default,){
final _that = this;
switch (_that) {
case _EntitlementPlanDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EntitlementPlanDto value)?  $default,){
final _that = this;
switch (_that) {
case _EntitlementPlanDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String displayName,  int? version,  int? currentVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EntitlementPlanDto() when $default != null:
return $default(_that.name,_that.displayName,_that.version,_that.currentVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String displayName,  int? version,  int? currentVersion)  $default,) {final _that = this;
switch (_that) {
case _EntitlementPlanDto():
return $default(_that.name,_that.displayName,_that.version,_that.currentVersion);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String displayName,  int? version,  int? currentVersion)?  $default,) {final _that = this;
switch (_that) {
case _EntitlementPlanDto() when $default != null:
return $default(_that.name,_that.displayName,_that.version,_that.currentVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EntitlementPlanDto extends EntitlementPlanDto {
  const _EntitlementPlanDto({this.name = '', this.displayName = '', this.version, this.currentVersion}): super._();
  factory _EntitlementPlanDto.fromJson(Map<String, dynamic> json) => _$EntitlementPlanDtoFromJson(json);

/// The key. Stable, and the thing to match on. Never rendered.
@override@JsonKey() final  String name;
/// What to render. The server never sends this null - a plan an operator
/// gave no display name reports its own name - so nothing has to choose
/// between two fields.
@override@JsonKey() final  String displayName;
/// The version this subject is actually on, which is not necessarily the
/// current one.
@override final  int? version;
/// The plan's newest version, when the catalogue publishes versions.
@override final  int? currentVersion;

/// Create a copy of EntitlementPlanDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntitlementPlanDtoCopyWith<_EntitlementPlanDto> get copyWith => __$EntitlementPlanDtoCopyWithImpl<_EntitlementPlanDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EntitlementPlanDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EntitlementPlanDto&&(identical(other.name, name) || other.name == name)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.version, version) || other.version == version)&&(identical(other.currentVersion, currentVersion) || other.currentVersion == currentVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,displayName,version,currentVersion);

@override
String toString() {
  return 'EntitlementPlanDto(name: $name, displayName: $displayName, version: $version, currentVersion: $currentVersion)';
}


}

/// @nodoc
abstract mixin class _$EntitlementPlanDtoCopyWith<$Res> implements $EntitlementPlanDtoCopyWith<$Res> {
  factory _$EntitlementPlanDtoCopyWith(_EntitlementPlanDto value, $Res Function(_EntitlementPlanDto) _then) = __$EntitlementPlanDtoCopyWithImpl;
@override @useResult
$Res call({
 String name, String displayName, int? version, int? currentVersion
});




}
/// @nodoc
class __$EntitlementPlanDtoCopyWithImpl<$Res>
    implements _$EntitlementPlanDtoCopyWith<$Res> {
  __$EntitlementPlanDtoCopyWithImpl(this._self, this._then);

  final _EntitlementPlanDto _self;
  final $Res Function(_EntitlementPlanDto) _then;

/// Create a copy of EntitlementPlanDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? displayName = null,Object? version = freezed,Object? currentVersion = freezed,}) {
  return _then(_EntitlementPlanDto(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int?,currentVersion: freezed == currentVersion ? _self.currentVersion : currentVersion // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$EntitlementSnapshotDto {

 EntitlementSubjectDto get subject;/// Null when no plan resolved these numbers. See [EntitlementPlanDto].
 EntitlementPlanDto? get plan;/// Ceilings only, never consumption. How many emoji slots a server has and
/// how many are used are two different payloads with opposite caching
/// properties, and the usage half is not implemented server-side yet.
 Map<String, EntitlementValueDto> get entitlements;
/// Create a copy of EntitlementSnapshotDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntitlementSnapshotDtoCopyWith<EntitlementSnapshotDto> get copyWith => _$EntitlementSnapshotDtoCopyWithImpl<EntitlementSnapshotDto>(this as EntitlementSnapshotDto, _$identity);

  /// Serializes this EntitlementSnapshotDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EntitlementSnapshotDto&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.plan, plan) || other.plan == plan)&&const DeepCollectionEquality().equals(other.entitlements, entitlements));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,subject,plan,const DeepCollectionEquality().hash(entitlements));

@override
String toString() {
  return 'EntitlementSnapshotDto(subject: $subject, plan: $plan, entitlements: $entitlements)';
}


}

/// @nodoc
abstract mixin class $EntitlementSnapshotDtoCopyWith<$Res>  {
  factory $EntitlementSnapshotDtoCopyWith(EntitlementSnapshotDto value, $Res Function(EntitlementSnapshotDto) _then) = _$EntitlementSnapshotDtoCopyWithImpl;
@useResult
$Res call({
 EntitlementSubjectDto subject, EntitlementPlanDto? plan, Map<String, EntitlementValueDto> entitlements
});


$EntitlementSubjectDtoCopyWith<$Res> get subject;$EntitlementPlanDtoCopyWith<$Res>? get plan;

}
/// @nodoc
class _$EntitlementSnapshotDtoCopyWithImpl<$Res>
    implements $EntitlementSnapshotDtoCopyWith<$Res> {
  _$EntitlementSnapshotDtoCopyWithImpl(this._self, this._then);

  final EntitlementSnapshotDto _self;
  final $Res Function(EntitlementSnapshotDto) _then;

/// Create a copy of EntitlementSnapshotDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? subject = null,Object? plan = freezed,Object? entitlements = null,}) {
  return _then(_self.copyWith(
subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as EntitlementSubjectDto,plan: freezed == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as EntitlementPlanDto?,entitlements: null == entitlements ? _self.entitlements : entitlements // ignore: cast_nullable_to_non_nullable
as Map<String, EntitlementValueDto>,
  ));
}
/// Create a copy of EntitlementSnapshotDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EntitlementSubjectDtoCopyWith<$Res> get subject {
  
  return $EntitlementSubjectDtoCopyWith<$Res>(_self.subject, (value) {
    return _then(_self.copyWith(subject: value));
  });
}/// Create a copy of EntitlementSnapshotDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EntitlementPlanDtoCopyWith<$Res>? get plan {
    if (_self.plan == null) {
    return null;
  }

  return $EntitlementPlanDtoCopyWith<$Res>(_self.plan!, (value) {
    return _then(_self.copyWith(plan: value));
  });
}
}


/// Adds pattern-matching-related methods to [EntitlementSnapshotDto].
extension EntitlementSnapshotDtoPatterns on EntitlementSnapshotDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EntitlementSnapshotDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EntitlementSnapshotDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EntitlementSnapshotDto value)  $default,){
final _that = this;
switch (_that) {
case _EntitlementSnapshotDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EntitlementSnapshotDto value)?  $default,){
final _that = this;
switch (_that) {
case _EntitlementSnapshotDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( EntitlementSubjectDto subject,  EntitlementPlanDto? plan,  Map<String, EntitlementValueDto> entitlements)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EntitlementSnapshotDto() when $default != null:
return $default(_that.subject,_that.plan,_that.entitlements);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( EntitlementSubjectDto subject,  EntitlementPlanDto? plan,  Map<String, EntitlementValueDto> entitlements)  $default,) {final _that = this;
switch (_that) {
case _EntitlementSnapshotDto():
return $default(_that.subject,_that.plan,_that.entitlements);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( EntitlementSubjectDto subject,  EntitlementPlanDto? plan,  Map<String, EntitlementValueDto> entitlements)?  $default,) {final _that = this;
switch (_that) {
case _EntitlementSnapshotDto() when $default != null:
return $default(_that.subject,_that.plan,_that.entitlements);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EntitlementSnapshotDto implements EntitlementSnapshotDto {
  const _EntitlementSnapshotDto({this.subject = const EntitlementSubjectDto(), this.plan, final  Map<String, EntitlementValueDto> entitlements = const <String, EntitlementValueDto>{}}): _entitlements = entitlements;
  factory _EntitlementSnapshotDto.fromJson(Map<String, dynamic> json) => _$EntitlementSnapshotDtoFromJson(json);

@override@JsonKey() final  EntitlementSubjectDto subject;
/// Null when no plan resolved these numbers. See [EntitlementPlanDto].
@override final  EntitlementPlanDto? plan;
/// Ceilings only, never consumption. How many emoji slots a server has and
/// how many are used are two different payloads with opposite caching
/// properties, and the usage half is not implemented server-side yet.
 final  Map<String, EntitlementValueDto> _entitlements;
/// Ceilings only, never consumption. How many emoji slots a server has and
/// how many are used are two different payloads with opposite caching
/// properties, and the usage half is not implemented server-side yet.
@override@JsonKey() Map<String, EntitlementValueDto> get entitlements {
  if (_entitlements is EqualUnmodifiableMapView) return _entitlements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_entitlements);
}


/// Create a copy of EntitlementSnapshotDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntitlementSnapshotDtoCopyWith<_EntitlementSnapshotDto> get copyWith => __$EntitlementSnapshotDtoCopyWithImpl<_EntitlementSnapshotDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EntitlementSnapshotDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EntitlementSnapshotDto&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.plan, plan) || other.plan == plan)&&const DeepCollectionEquality().equals(other._entitlements, _entitlements));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,subject,plan,const DeepCollectionEquality().hash(_entitlements));

@override
String toString() {
  return 'EntitlementSnapshotDto(subject: $subject, plan: $plan, entitlements: $entitlements)';
}


}

/// @nodoc
abstract mixin class _$EntitlementSnapshotDtoCopyWith<$Res> implements $EntitlementSnapshotDtoCopyWith<$Res> {
  factory _$EntitlementSnapshotDtoCopyWith(_EntitlementSnapshotDto value, $Res Function(_EntitlementSnapshotDto) _then) = __$EntitlementSnapshotDtoCopyWithImpl;
@override @useResult
$Res call({
 EntitlementSubjectDto subject, EntitlementPlanDto? plan, Map<String, EntitlementValueDto> entitlements
});


@override $EntitlementSubjectDtoCopyWith<$Res> get subject;@override $EntitlementPlanDtoCopyWith<$Res>? get plan;

}
/// @nodoc
class __$EntitlementSnapshotDtoCopyWithImpl<$Res>
    implements _$EntitlementSnapshotDtoCopyWith<$Res> {
  __$EntitlementSnapshotDtoCopyWithImpl(this._self, this._then);

  final _EntitlementSnapshotDto _self;
  final $Res Function(_EntitlementSnapshotDto) _then;

/// Create a copy of EntitlementSnapshotDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? subject = null,Object? plan = freezed,Object? entitlements = null,}) {
  return _then(_EntitlementSnapshotDto(
subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as EntitlementSubjectDto,plan: freezed == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as EntitlementPlanDto?,entitlements: null == entitlements ? _self._entitlements : entitlements // ignore: cast_nullable_to_non_nullable
as Map<String, EntitlementValueDto>,
  ));
}

/// Create a copy of EntitlementSnapshotDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EntitlementSubjectDtoCopyWith<$Res> get subject {
  
  return $EntitlementSubjectDtoCopyWith<$Res>(_self.subject, (value) {
    return _then(_self.copyWith(subject: value));
  });
}/// Create a copy of EntitlementSnapshotDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EntitlementPlanDtoCopyWith<$Res>? get plan {
    if (_self.plan == null) {
    return null;
  }

  return $EntitlementPlanDtoCopyWith<$Res>(_self.plan!, (value) {
    return _then(_self.copyWith(plan: value));
  });
}
}

// dart format on
