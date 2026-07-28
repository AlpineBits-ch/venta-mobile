// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'relationship_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MinimalProfileId {

 String get id; String get userName; String get userId;
/// Create a copy of MinimalProfileId
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MinimalProfileIdCopyWith<MinimalProfileId> get copyWith => _$MinimalProfileIdCopyWithImpl<MinimalProfileId>(this as MinimalProfileId, _$identity);

  /// Serializes this MinimalProfileId to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MinimalProfileId&&(identical(other.id, id) || other.id == id)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userId, userId) || other.userId == userId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userName,userId);

@override
String toString() {
  return 'MinimalProfileId(id: $id, userName: $userName, userId: $userId)';
}


}

/// @nodoc
abstract mixin class $MinimalProfileIdCopyWith<$Res>  {
  factory $MinimalProfileIdCopyWith(MinimalProfileId value, $Res Function(MinimalProfileId) _then) = _$MinimalProfileIdCopyWithImpl;
@useResult
$Res call({
 String id, String userName, String userId
});




}
/// @nodoc
class _$MinimalProfileIdCopyWithImpl<$Res>
    implements $MinimalProfileIdCopyWith<$Res> {
  _$MinimalProfileIdCopyWithImpl(this._self, this._then);

  final MinimalProfileId _self;
  final $Res Function(MinimalProfileId) _then;

/// Create a copy of MinimalProfileId
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userName = null,Object? userId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MinimalProfileId].
extension MinimalProfileIdPatterns on MinimalProfileId {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MinimalProfileId value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MinimalProfileId() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MinimalProfileId value)  $default,){
final _that = this;
switch (_that) {
case _MinimalProfileId():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MinimalProfileId value)?  $default,){
final _that = this;
switch (_that) {
case _MinimalProfileId() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userName,  String userId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MinimalProfileId() when $default != null:
return $default(_that.id,_that.userName,_that.userId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userName,  String userId)  $default,) {final _that = this;
switch (_that) {
case _MinimalProfileId():
return $default(_that.id,_that.userName,_that.userId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userName,  String userId)?  $default,) {final _that = this;
switch (_that) {
case _MinimalProfileId() when $default != null:
return $default(_that.id,_that.userName,_that.userId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MinimalProfileId implements MinimalProfileId {
  const _MinimalProfileId({required this.id, required this.userName, required this.userId});
  factory _MinimalProfileId.fromJson(Map<String, dynamic> json) => _$MinimalProfileIdFromJson(json);

@override final  String id;
@override final  String userName;
@override final  String userId;

/// Create a copy of MinimalProfileId
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MinimalProfileIdCopyWith<_MinimalProfileId> get copyWith => __$MinimalProfileIdCopyWithImpl<_MinimalProfileId>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MinimalProfileIdToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MinimalProfileId&&(identical(other.id, id) || other.id == id)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userId, userId) || other.userId == userId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userName,userId);

@override
String toString() {
  return 'MinimalProfileId(id: $id, userName: $userName, userId: $userId)';
}


}

/// @nodoc
abstract mixin class _$MinimalProfileIdCopyWith<$Res> implements $MinimalProfileIdCopyWith<$Res> {
  factory _$MinimalProfileIdCopyWith(_MinimalProfileId value, $Res Function(_MinimalProfileId) _then) = __$MinimalProfileIdCopyWithImpl;
@override @useResult
$Res call({
 String id, String userName, String userId
});




}
/// @nodoc
class __$MinimalProfileIdCopyWithImpl<$Res>
    implements _$MinimalProfileIdCopyWith<$Res> {
  __$MinimalProfileIdCopyWithImpl(this._self, this._then);

  final _MinimalProfileId _self;
  final $Res Function(_MinimalProfileId) _then;

/// Create a copy of MinimalProfileId
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userName = null,Object? userId = null,}) {
  return _then(_MinimalProfileId(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RelationshipModel {

 String get id; String get ownerId; MinimalProfileId get owner; String get targetId; MinimalProfileId get target; RelationshipStatus get status;
/// Create a copy of RelationshipModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RelationshipModelCopyWith<RelationshipModel> get copyWith => _$RelationshipModelCopyWithImpl<RelationshipModel>(this as RelationshipModel, _$identity);

  /// Serializes this RelationshipModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RelationshipModel&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.owner, owner) || other.owner == owner)&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.target, target) || other.target == target)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerId,owner,targetId,target,status);

@override
String toString() {
  return 'RelationshipModel(id: $id, ownerId: $ownerId, owner: $owner, targetId: $targetId, target: $target, status: $status)';
}


}

/// @nodoc
abstract mixin class $RelationshipModelCopyWith<$Res>  {
  factory $RelationshipModelCopyWith(RelationshipModel value, $Res Function(RelationshipModel) _then) = _$RelationshipModelCopyWithImpl;
@useResult
$Res call({
 String id, String ownerId, MinimalProfileId owner, String targetId, MinimalProfileId target, RelationshipStatus status
});


$MinimalProfileIdCopyWith<$Res> get owner;$MinimalProfileIdCopyWith<$Res> get target;

}
/// @nodoc
class _$RelationshipModelCopyWithImpl<$Res>
    implements $RelationshipModelCopyWith<$Res> {
  _$RelationshipModelCopyWithImpl(this._self, this._then);

  final RelationshipModel _self;
  final $Res Function(RelationshipModel) _then;

/// Create a copy of RelationshipModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ownerId = null,Object? owner = null,Object? targetId = null,Object? target = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,owner: null == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as MinimalProfileId,targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as MinimalProfileId,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RelationshipStatus,
  ));
}
/// Create a copy of RelationshipModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MinimalProfileIdCopyWith<$Res> get owner {
  
  return $MinimalProfileIdCopyWith<$Res>(_self.owner, (value) {
    return _then(_self.copyWith(owner: value));
  });
}/// Create a copy of RelationshipModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MinimalProfileIdCopyWith<$Res> get target {
  
  return $MinimalProfileIdCopyWith<$Res>(_self.target, (value) {
    return _then(_self.copyWith(target: value));
  });
}
}


/// Adds pattern-matching-related methods to [RelationshipModel].
extension RelationshipModelPatterns on RelationshipModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RelationshipModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RelationshipModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RelationshipModel value)  $default,){
final _that = this;
switch (_that) {
case _RelationshipModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RelationshipModel value)?  $default,){
final _that = this;
switch (_that) {
case _RelationshipModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String ownerId,  MinimalProfileId owner,  String targetId,  MinimalProfileId target,  RelationshipStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RelationshipModel() when $default != null:
return $default(_that.id,_that.ownerId,_that.owner,_that.targetId,_that.target,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String ownerId,  MinimalProfileId owner,  String targetId,  MinimalProfileId target,  RelationshipStatus status)  $default,) {final _that = this;
switch (_that) {
case _RelationshipModel():
return $default(_that.id,_that.ownerId,_that.owner,_that.targetId,_that.target,_that.status);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String ownerId,  MinimalProfileId owner,  String targetId,  MinimalProfileId target,  RelationshipStatus status)?  $default,) {final _that = this;
switch (_that) {
case _RelationshipModel() when $default != null:
return $default(_that.id,_that.ownerId,_that.owner,_that.targetId,_that.target,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RelationshipModel implements RelationshipModel {
  const _RelationshipModel({required this.id, required this.ownerId, required this.owner, required this.targetId, required this.target, required this.status});
  factory _RelationshipModel.fromJson(Map<String, dynamic> json) => _$RelationshipModelFromJson(json);

@override final  String id;
@override final  String ownerId;
@override final  MinimalProfileId owner;
@override final  String targetId;
@override final  MinimalProfileId target;
@override final  RelationshipStatus status;

/// Create a copy of RelationshipModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RelationshipModelCopyWith<_RelationshipModel> get copyWith => __$RelationshipModelCopyWithImpl<_RelationshipModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RelationshipModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RelationshipModel&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.owner, owner) || other.owner == owner)&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.target, target) || other.target == target)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerId,owner,targetId,target,status);

@override
String toString() {
  return 'RelationshipModel(id: $id, ownerId: $ownerId, owner: $owner, targetId: $targetId, target: $target, status: $status)';
}


}

/// @nodoc
abstract mixin class _$RelationshipModelCopyWith<$Res> implements $RelationshipModelCopyWith<$Res> {
  factory _$RelationshipModelCopyWith(_RelationshipModel value, $Res Function(_RelationshipModel) _then) = __$RelationshipModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String ownerId, MinimalProfileId owner, String targetId, MinimalProfileId target, RelationshipStatus status
});


@override $MinimalProfileIdCopyWith<$Res> get owner;@override $MinimalProfileIdCopyWith<$Res> get target;

}
/// @nodoc
class __$RelationshipModelCopyWithImpl<$Res>
    implements _$RelationshipModelCopyWith<$Res> {
  __$RelationshipModelCopyWithImpl(this._self, this._then);

  final _RelationshipModel _self;
  final $Res Function(_RelationshipModel) _then;

/// Create a copy of RelationshipModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ownerId = null,Object? owner = null,Object? targetId = null,Object? target = null,Object? status = null,}) {
  return _then(_RelationshipModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,owner: null == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as MinimalProfileId,targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as MinimalProfileId,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RelationshipStatus,
  ));
}

/// Create a copy of RelationshipModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MinimalProfileIdCopyWith<$Res> get owner {
  
  return $MinimalProfileIdCopyWith<$Res>(_self.owner, (value) {
    return _then(_self.copyWith(owner: value));
  });
}/// Create a copy of RelationshipModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MinimalProfileIdCopyWith<$Res> get target {
  
  return $MinimalProfileIdCopyWith<$Res>(_self.target, (value) {
    return _then(_self.copyWith(target: value));
  });
}
}

// dart format on
