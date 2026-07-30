// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'guild_member_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RoleMembershipDto {

 RoleDto get role;/// Set only for a guest-access grant (`GuestAccess` module). The grant
/// lapses on its own - permission resolution ignores it from the exact
/// instant it expires - but the row is only tidied up a week later, so a
/// past [expiresAt] means "no longer granted" even though it's still
/// listed. Existing memberships are null and behave as they always did.
 DateTime? get expiresAt;
/// Create a copy of RoleMembershipDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoleMembershipDtoCopyWith<RoleMembershipDto> get copyWith => _$RoleMembershipDtoCopyWithImpl<RoleMembershipDto>(this as RoleMembershipDto, _$identity);

  /// Serializes this RoleMembershipDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoleMembershipDto&&(identical(other.role, role) || other.role == role)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,role,expiresAt);

@override
String toString() {
  return 'RoleMembershipDto(role: $role, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $RoleMembershipDtoCopyWith<$Res>  {
  factory $RoleMembershipDtoCopyWith(RoleMembershipDto value, $Res Function(RoleMembershipDto) _then) = _$RoleMembershipDtoCopyWithImpl;
@useResult
$Res call({
 RoleDto role, DateTime? expiresAt
});


$RoleDtoCopyWith<$Res> get role;

}
/// @nodoc
class _$RoleMembershipDtoCopyWithImpl<$Res>
    implements $RoleMembershipDtoCopyWith<$Res> {
  _$RoleMembershipDtoCopyWithImpl(this._self, this._then);

  final RoleMembershipDto _self;
  final $Res Function(RoleMembershipDto) _then;

/// Create a copy of RoleMembershipDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? role = null,Object? expiresAt = freezed,}) {
  return _then(_self.copyWith(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as RoleDto,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of RoleMembershipDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RoleDtoCopyWith<$Res> get role {
  
  return $RoleDtoCopyWith<$Res>(_self.role, (value) {
    return _then(_self.copyWith(role: value));
  });
}
}


/// Adds pattern-matching-related methods to [RoleMembershipDto].
extension RoleMembershipDtoPatterns on RoleMembershipDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoleMembershipDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoleMembershipDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoleMembershipDto value)  $default,){
final _that = this;
switch (_that) {
case _RoleMembershipDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoleMembershipDto value)?  $default,){
final _that = this;
switch (_that) {
case _RoleMembershipDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RoleDto role,  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoleMembershipDto() when $default != null:
return $default(_that.role,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RoleDto role,  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _RoleMembershipDto():
return $default(_that.role,_that.expiresAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RoleDto role,  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _RoleMembershipDto() when $default != null:
return $default(_that.role,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoleMembershipDto implements RoleMembershipDto {
  const _RoleMembershipDto({required this.role, this.expiresAt});
  factory _RoleMembershipDto.fromJson(Map<String, dynamic> json) => _$RoleMembershipDtoFromJson(json);

@override final  RoleDto role;
/// Set only for a guest-access grant (`GuestAccess` module). The grant
/// lapses on its own - permission resolution ignores it from the exact
/// instant it expires - but the row is only tidied up a week later, so a
/// past [expiresAt] means "no longer granted" even though it's still
/// listed. Existing memberships are null and behave as they always did.
@override final  DateTime? expiresAt;

/// Create a copy of RoleMembershipDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoleMembershipDtoCopyWith<_RoleMembershipDto> get copyWith => __$RoleMembershipDtoCopyWithImpl<_RoleMembershipDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoleMembershipDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoleMembershipDto&&(identical(other.role, role) || other.role == role)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,role,expiresAt);

@override
String toString() {
  return 'RoleMembershipDto(role: $role, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$RoleMembershipDtoCopyWith<$Res> implements $RoleMembershipDtoCopyWith<$Res> {
  factory _$RoleMembershipDtoCopyWith(_RoleMembershipDto value, $Res Function(_RoleMembershipDto) _then) = __$RoleMembershipDtoCopyWithImpl;
@override @useResult
$Res call({
 RoleDto role, DateTime? expiresAt
});


@override $RoleDtoCopyWith<$Res> get role;

}
/// @nodoc
class __$RoleMembershipDtoCopyWithImpl<$Res>
    implements _$RoleMembershipDtoCopyWith<$Res> {
  __$RoleMembershipDtoCopyWithImpl(this._self, this._then);

  final _RoleMembershipDto _self;
  final $Res Function(_RoleMembershipDto) _then;

/// Create a copy of RoleMembershipDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? role = null,Object? expiresAt = freezed,}) {
  return _then(_RoleMembershipDto(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as RoleDto,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of RoleMembershipDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RoleDtoCopyWith<$Res> get role {
  
  return $RoleDtoCopyWith<$Res>(_self.role, (value) {
    return _then(_self.copyWith(role: value));
  });
}
}


/// @nodoc
mixin _$GuildMemberDto {

 String get id; String get guildId; String get userId; String get permissions; OnlineStatus get status; MemberType get type; String? get nickname; ProfileDto? get profile; List<RoleMembershipDto> get roleMembers;
/// Create a copy of GuildMemberDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuildMemberDtoCopyWith<GuildMemberDto> get copyWith => _$GuildMemberDtoCopyWithImpl<GuildMemberDto>(this as GuildMemberDto, _$identity);

  /// Serializes this GuildMemberDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuildMemberDto&&(identical(other.id, id) || other.id == id)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.permissions, permissions) || other.permissions == permissions)&&(identical(other.status, status) || other.status == status)&&(identical(other.type, type) || other.type == type)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.profile, profile) || other.profile == profile)&&const DeepCollectionEquality().equals(other.roleMembers, roleMembers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,guildId,userId,permissions,status,type,nickname,profile,const DeepCollectionEquality().hash(roleMembers));

@override
String toString() {
  return 'GuildMemberDto(id: $id, guildId: $guildId, userId: $userId, permissions: $permissions, status: $status, type: $type, nickname: $nickname, profile: $profile, roleMembers: $roleMembers)';
}


}

/// @nodoc
abstract mixin class $GuildMemberDtoCopyWith<$Res>  {
  factory $GuildMemberDtoCopyWith(GuildMemberDto value, $Res Function(GuildMemberDto) _then) = _$GuildMemberDtoCopyWithImpl;
@useResult
$Res call({
 String id, String guildId, String userId, String permissions, OnlineStatus status, MemberType type, String? nickname, ProfileDto? profile, List<RoleMembershipDto> roleMembers
});


$ProfileDtoCopyWith<$Res>? get profile;

}
/// @nodoc
class _$GuildMemberDtoCopyWithImpl<$Res>
    implements $GuildMemberDtoCopyWith<$Res> {
  _$GuildMemberDtoCopyWithImpl(this._self, this._then);

  final GuildMemberDto _self;
  final $Res Function(GuildMemberDto) _then;

/// Create a copy of GuildMemberDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? guildId = null,Object? userId = null,Object? permissions = null,Object? status = null,Object? type = null,Object? nickname = freezed,Object? profile = freezed,Object? roleMembers = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OnlineStatus,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MemberType,nickname: freezed == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String?,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as ProfileDto?,roleMembers: null == roleMembers ? _self.roleMembers : roleMembers // ignore: cast_nullable_to_non_nullable
as List<RoleMembershipDto>,
  ));
}
/// Create a copy of GuildMemberDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileDtoCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $ProfileDtoCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// Adds pattern-matching-related methods to [GuildMemberDto].
extension GuildMemberDtoPatterns on GuildMemberDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuildMemberDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuildMemberDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuildMemberDto value)  $default,){
final _that = this;
switch (_that) {
case _GuildMemberDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuildMemberDto value)?  $default,){
final _that = this;
switch (_that) {
case _GuildMemberDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String guildId,  String userId,  String permissions,  OnlineStatus status,  MemberType type,  String? nickname,  ProfileDto? profile,  List<RoleMembershipDto> roleMembers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuildMemberDto() when $default != null:
return $default(_that.id,_that.guildId,_that.userId,_that.permissions,_that.status,_that.type,_that.nickname,_that.profile,_that.roleMembers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String guildId,  String userId,  String permissions,  OnlineStatus status,  MemberType type,  String? nickname,  ProfileDto? profile,  List<RoleMembershipDto> roleMembers)  $default,) {final _that = this;
switch (_that) {
case _GuildMemberDto():
return $default(_that.id,_that.guildId,_that.userId,_that.permissions,_that.status,_that.type,_that.nickname,_that.profile,_that.roleMembers);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String guildId,  String userId,  String permissions,  OnlineStatus status,  MemberType type,  String? nickname,  ProfileDto? profile,  List<RoleMembershipDto> roleMembers)?  $default,) {final _that = this;
switch (_that) {
case _GuildMemberDto() when $default != null:
return $default(_that.id,_that.guildId,_that.userId,_that.permissions,_that.status,_that.type,_that.nickname,_that.profile,_that.roleMembers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GuildMemberDto implements GuildMemberDto {
  const _GuildMemberDto({required this.id, required this.guildId, required this.userId, this.permissions = '', this.status = OnlineStatus.offline, this.type = MemberType.standard, this.nickname, this.profile, final  List<RoleMembershipDto> roleMembers = const <RoleMembershipDto>[]}): _roleMembers = roleMembers;
  factory _GuildMemberDto.fromJson(Map<String, dynamic> json) => _$GuildMemberDtoFromJson(json);

@override final  String id;
@override final  String guildId;
@override final  String userId;
@override@JsonKey() final  String permissions;
@override@JsonKey() final  OnlineStatus status;
@override@JsonKey() final  MemberType type;
@override final  String? nickname;
@override final  ProfileDto? profile;
 final  List<RoleMembershipDto> _roleMembers;
@override@JsonKey() List<RoleMembershipDto> get roleMembers {
  if (_roleMembers is EqualUnmodifiableListView) return _roleMembers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roleMembers);
}


/// Create a copy of GuildMemberDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuildMemberDtoCopyWith<_GuildMemberDto> get copyWith => __$GuildMemberDtoCopyWithImpl<_GuildMemberDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GuildMemberDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuildMemberDto&&(identical(other.id, id) || other.id == id)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.permissions, permissions) || other.permissions == permissions)&&(identical(other.status, status) || other.status == status)&&(identical(other.type, type) || other.type == type)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.profile, profile) || other.profile == profile)&&const DeepCollectionEquality().equals(other._roleMembers, _roleMembers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,guildId,userId,permissions,status,type,nickname,profile,const DeepCollectionEquality().hash(_roleMembers));

@override
String toString() {
  return 'GuildMemberDto(id: $id, guildId: $guildId, userId: $userId, permissions: $permissions, status: $status, type: $type, nickname: $nickname, profile: $profile, roleMembers: $roleMembers)';
}


}

/// @nodoc
abstract mixin class _$GuildMemberDtoCopyWith<$Res> implements $GuildMemberDtoCopyWith<$Res> {
  factory _$GuildMemberDtoCopyWith(_GuildMemberDto value, $Res Function(_GuildMemberDto) _then) = __$GuildMemberDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String guildId, String userId, String permissions, OnlineStatus status, MemberType type, String? nickname, ProfileDto? profile, List<RoleMembershipDto> roleMembers
});


@override $ProfileDtoCopyWith<$Res>? get profile;

}
/// @nodoc
class __$GuildMemberDtoCopyWithImpl<$Res>
    implements _$GuildMemberDtoCopyWith<$Res> {
  __$GuildMemberDtoCopyWithImpl(this._self, this._then);

  final _GuildMemberDto _self;
  final $Res Function(_GuildMemberDto) _then;

/// Create a copy of GuildMemberDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? guildId = null,Object? userId = null,Object? permissions = null,Object? status = null,Object? type = null,Object? nickname = freezed,Object? profile = freezed,Object? roleMembers = null,}) {
  return _then(_GuildMemberDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OnlineStatus,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MemberType,nickname: freezed == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String?,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as ProfileDto?,roleMembers: null == roleMembers ? _self._roleMembers : roleMembers // ignore: cast_nullable_to_non_nullable
as List<RoleMembershipDto>,
  ));
}

/// Create a copy of GuildMemberDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileDtoCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $ProfileDtoCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}

// dart format on
