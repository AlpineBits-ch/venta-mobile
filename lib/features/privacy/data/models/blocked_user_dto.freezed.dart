// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'blocked_user_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BlockedUserDto {

/// The **Identity** user id - the one `POST /relationships/{userId}/block`
/// and `/profiles/by-user/{id}` take, not the Social profile id below.
 String get userId; String get userName;/// The block's own row id, and the blocked account's Social profile id.
/// Neither is needed to unblock (that is keyed by [userId]); carried
/// because the server sends them and a screen that wants to link to the
/// profile shouldn't have to look one up.
 String? get relationshipId; String? get profileId;/// 404s when the account never uploaded one - render through `AvatarImage`,
/// which handles that, rather than branching on null.
 String? get avatarUrl; DateTime? get blockedAt;
/// Create a copy of BlockedUserDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BlockedUserDtoCopyWith<BlockedUserDto> get copyWith => _$BlockedUserDtoCopyWithImpl<BlockedUserDto>(this as BlockedUserDto, _$identity);

  /// Serializes this BlockedUserDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BlockedUserDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.relationshipId, relationshipId) || other.relationshipId == relationshipId)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.blockedAt, blockedAt) || other.blockedAt == blockedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,userName,relationshipId,profileId,avatarUrl,blockedAt);

@override
String toString() {
  return 'BlockedUserDto(userId: $userId, userName: $userName, relationshipId: $relationshipId, profileId: $profileId, avatarUrl: $avatarUrl, blockedAt: $blockedAt)';
}


}

/// @nodoc
abstract mixin class $BlockedUserDtoCopyWith<$Res>  {
  factory $BlockedUserDtoCopyWith(BlockedUserDto value, $Res Function(BlockedUserDto) _then) = _$BlockedUserDtoCopyWithImpl;
@useResult
$Res call({
 String userId, String userName, String? relationshipId, String? profileId, String? avatarUrl, DateTime? blockedAt
});




}
/// @nodoc
class _$BlockedUserDtoCopyWithImpl<$Res>
    implements $BlockedUserDtoCopyWith<$Res> {
  _$BlockedUserDtoCopyWithImpl(this._self, this._then);

  final BlockedUserDto _self;
  final $Res Function(BlockedUserDto) _then;

/// Create a copy of BlockedUserDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? userName = null,Object? relationshipId = freezed,Object? profileId = freezed,Object? avatarUrl = freezed,Object? blockedAt = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,relationshipId: freezed == relationshipId ? _self.relationshipId : relationshipId // ignore: cast_nullable_to_non_nullable
as String?,profileId: freezed == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,blockedAt: freezed == blockedAt ? _self.blockedAt : blockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [BlockedUserDto].
extension BlockedUserDtoPatterns on BlockedUserDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BlockedUserDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BlockedUserDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BlockedUserDto value)  $default,){
final _that = this;
switch (_that) {
case _BlockedUserDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BlockedUserDto value)?  $default,){
final _that = this;
switch (_that) {
case _BlockedUserDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String userName,  String? relationshipId,  String? profileId,  String? avatarUrl,  DateTime? blockedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BlockedUserDto() when $default != null:
return $default(_that.userId,_that.userName,_that.relationshipId,_that.profileId,_that.avatarUrl,_that.blockedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String userName,  String? relationshipId,  String? profileId,  String? avatarUrl,  DateTime? blockedAt)  $default,) {final _that = this;
switch (_that) {
case _BlockedUserDto():
return $default(_that.userId,_that.userName,_that.relationshipId,_that.profileId,_that.avatarUrl,_that.blockedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String userName,  String? relationshipId,  String? profileId,  String? avatarUrl,  DateTime? blockedAt)?  $default,) {final _that = this;
switch (_that) {
case _BlockedUserDto() when $default != null:
return $default(_that.userId,_that.userName,_that.relationshipId,_that.profileId,_that.avatarUrl,_that.blockedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _BlockedUserDto implements BlockedUserDto {
  const _BlockedUserDto({required this.userId, required this.userName, this.relationshipId, this.profileId, this.avatarUrl, this.blockedAt});
  factory _BlockedUserDto.fromJson(Map<String, dynamic> json) => _$BlockedUserDtoFromJson(json);

/// The **Identity** user id - the one `POST /relationships/{userId}/block`
/// and `/profiles/by-user/{id}` take, not the Social profile id below.
@override final  String userId;
@override final  String userName;
/// The block's own row id, and the blocked account's Social profile id.
/// Neither is needed to unblock (that is keyed by [userId]); carried
/// because the server sends them and a screen that wants to link to the
/// profile shouldn't have to look one up.
@override final  String? relationshipId;
@override final  String? profileId;
/// 404s when the account never uploaded one - render through `AvatarImage`,
/// which handles that, rather than branching on null.
@override final  String? avatarUrl;
@override final  DateTime? blockedAt;

/// Create a copy of BlockedUserDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BlockedUserDtoCopyWith<_BlockedUserDto> get copyWith => __$BlockedUserDtoCopyWithImpl<_BlockedUserDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BlockedUserDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BlockedUserDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.relationshipId, relationshipId) || other.relationshipId == relationshipId)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.blockedAt, blockedAt) || other.blockedAt == blockedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,userName,relationshipId,profileId,avatarUrl,blockedAt);

@override
String toString() {
  return 'BlockedUserDto(userId: $userId, userName: $userName, relationshipId: $relationshipId, profileId: $profileId, avatarUrl: $avatarUrl, blockedAt: $blockedAt)';
}


}

/// @nodoc
abstract mixin class _$BlockedUserDtoCopyWith<$Res> implements $BlockedUserDtoCopyWith<$Res> {
  factory _$BlockedUserDtoCopyWith(_BlockedUserDto value, $Res Function(_BlockedUserDto) _then) = __$BlockedUserDtoCopyWithImpl;
@override @useResult
$Res call({
 String userId, String userName, String? relationshipId, String? profileId, String? avatarUrl, DateTime? blockedAt
});




}
/// @nodoc
class __$BlockedUserDtoCopyWithImpl<$Res>
    implements _$BlockedUserDtoCopyWith<$Res> {
  __$BlockedUserDtoCopyWithImpl(this._self, this._then);

  final _BlockedUserDto _self;
  final $Res Function(_BlockedUserDto) _then;

/// Create a copy of BlockedUserDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? userName = null,Object? relationshipId = freezed,Object? profileId = freezed,Object? avatarUrl = freezed,Object? blockedAt = freezed,}) {
  return _then(_BlockedUserDto(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,relationshipId: freezed == relationshipId ? _self.relationshipId : relationshipId // ignore: cast_nullable_to_non_nullable
as String?,profileId: freezed == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,blockedAt: freezed == blockedAt ? _self.blockedAt : blockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
