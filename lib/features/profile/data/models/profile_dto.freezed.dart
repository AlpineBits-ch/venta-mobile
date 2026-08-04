// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProfileDto {

 String get id; String get userId; String get userName; String? get bio; String? get avatarUrl; String? get bannerUrl; String? get accentColor; ProfileFont get font; OnlineStatus get onlineStatus; List<MutualEntry>? get mutualFriends; List<MutualEntry>? get mutualServers; List<ProfileConnection>? get connections;/// A date, sent without a time. Kept as the raw string: it is displayed and
/// never compared, and parsing a date-only value into a `DateTime` would
/// shift it a day either way depending on the device's timezone.
 String? get birthday; ProfileActivity? get activity;
/// Create a copy of ProfileDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileDtoCopyWith<ProfileDto> get copyWith => _$ProfileDtoCopyWithImpl<ProfileDto>(this as ProfileDto, _$identity);

  /// Serializes this ProfileDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileDto&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl)&&(identical(other.accentColor, accentColor) || other.accentColor == accentColor)&&(identical(other.font, font) || other.font == font)&&(identical(other.onlineStatus, onlineStatus) || other.onlineStatus == onlineStatus)&&const DeepCollectionEquality().equals(other.mutualFriends, mutualFriends)&&const DeepCollectionEquality().equals(other.mutualServers, mutualServers)&&const DeepCollectionEquality().equals(other.connections, connections)&&(identical(other.birthday, birthday) || other.birthday == birthday)&&(identical(other.activity, activity) || other.activity == activity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,userName,bio,avatarUrl,bannerUrl,accentColor,font,onlineStatus,const DeepCollectionEquality().hash(mutualFriends),const DeepCollectionEquality().hash(mutualServers),const DeepCollectionEquality().hash(connections),birthday,activity);

@override
String toString() {
  return 'ProfileDto(id: $id, userId: $userId, userName: $userName, bio: $bio, avatarUrl: $avatarUrl, bannerUrl: $bannerUrl, accentColor: $accentColor, font: $font, onlineStatus: $onlineStatus, mutualFriends: $mutualFriends, mutualServers: $mutualServers, connections: $connections, birthday: $birthday, activity: $activity)';
}


}

/// @nodoc
abstract mixin class $ProfileDtoCopyWith<$Res>  {
  factory $ProfileDtoCopyWith(ProfileDto value, $Res Function(ProfileDto) _then) = _$ProfileDtoCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String userName, String? bio, String? avatarUrl, String? bannerUrl, String? accentColor, ProfileFont font, OnlineStatus onlineStatus, List<MutualEntry>? mutualFriends, List<MutualEntry>? mutualServers, List<ProfileConnection>? connections, String? birthday, ProfileActivity? activity
});




}
/// @nodoc
class _$ProfileDtoCopyWithImpl<$Res>
    implements $ProfileDtoCopyWith<$Res> {
  _$ProfileDtoCopyWithImpl(this._self, this._then);

  final ProfileDto _self;
  final $Res Function(ProfileDto) _then;

/// Create a copy of ProfileDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? userName = null,Object? bio = freezed,Object? avatarUrl = freezed,Object? bannerUrl = freezed,Object? accentColor = freezed,Object? font = null,Object? onlineStatus = null,Object? mutualFriends = freezed,Object? mutualServers = freezed,Object? connections = freezed,Object? birthday = freezed,Object? activity = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,accentColor: freezed == accentColor ? _self.accentColor : accentColor // ignore: cast_nullable_to_non_nullable
as String?,font: null == font ? _self.font : font // ignore: cast_nullable_to_non_nullable
as ProfileFont,onlineStatus: null == onlineStatus ? _self.onlineStatus : onlineStatus // ignore: cast_nullable_to_non_nullable
as OnlineStatus,mutualFriends: freezed == mutualFriends ? _self.mutualFriends : mutualFriends // ignore: cast_nullable_to_non_nullable
as List<MutualEntry>?,mutualServers: freezed == mutualServers ? _self.mutualServers : mutualServers // ignore: cast_nullable_to_non_nullable
as List<MutualEntry>?,connections: freezed == connections ? _self.connections : connections // ignore: cast_nullable_to_non_nullable
as List<ProfileConnection>?,birthday: freezed == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as String?,activity: freezed == activity ? _self.activity : activity // ignore: cast_nullable_to_non_nullable
as ProfileActivity?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileDto].
extension ProfileDtoPatterns on ProfileDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileDto value)  $default,){
final _that = this;
switch (_that) {
case _ProfileDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileDto value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String userName,  String? bio,  String? avatarUrl,  String? bannerUrl,  String? accentColor,  ProfileFont font,  OnlineStatus onlineStatus,  List<MutualEntry>? mutualFriends,  List<MutualEntry>? mutualServers,  List<ProfileConnection>? connections,  String? birthday,  ProfileActivity? activity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileDto() when $default != null:
return $default(_that.id,_that.userId,_that.userName,_that.bio,_that.avatarUrl,_that.bannerUrl,_that.accentColor,_that.font,_that.onlineStatus,_that.mutualFriends,_that.mutualServers,_that.connections,_that.birthday,_that.activity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String userName,  String? bio,  String? avatarUrl,  String? bannerUrl,  String? accentColor,  ProfileFont font,  OnlineStatus onlineStatus,  List<MutualEntry>? mutualFriends,  List<MutualEntry>? mutualServers,  List<ProfileConnection>? connections,  String? birthday,  ProfileActivity? activity)  $default,) {final _that = this;
switch (_that) {
case _ProfileDto():
return $default(_that.id,_that.userId,_that.userName,_that.bio,_that.avatarUrl,_that.bannerUrl,_that.accentColor,_that.font,_that.onlineStatus,_that.mutualFriends,_that.mutualServers,_that.connections,_that.birthday,_that.activity);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String userName,  String? bio,  String? avatarUrl,  String? bannerUrl,  String? accentColor,  ProfileFont font,  OnlineStatus onlineStatus,  List<MutualEntry>? mutualFriends,  List<MutualEntry>? mutualServers,  List<ProfileConnection>? connections,  String? birthday,  ProfileActivity? activity)?  $default,) {final _that = this;
switch (_that) {
case _ProfileDto() when $default != null:
return $default(_that.id,_that.userId,_that.userName,_that.bio,_that.avatarUrl,_that.bannerUrl,_that.accentColor,_that.font,_that.onlineStatus,_that.mutualFriends,_that.mutualServers,_that.connections,_that.birthday,_that.activity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfileDto implements ProfileDto {
  const _ProfileDto({required this.id, required this.userId, required this.userName, this.bio, this.avatarUrl, this.bannerUrl, this.accentColor, this.font = ProfileFont.defaultFont, this.onlineStatus = OnlineStatus.offline, final  List<MutualEntry>? mutualFriends, final  List<MutualEntry>? mutualServers, final  List<ProfileConnection>? connections, this.birthday, this.activity}): _mutualFriends = mutualFriends,_mutualServers = mutualServers,_connections = connections;
  factory _ProfileDto.fromJson(Map<String, dynamic> json) => _$ProfileDtoFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String userName;
@override final  String? bio;
@override final  String? avatarUrl;
@override final  String? bannerUrl;
@override final  String? accentColor;
@override@JsonKey() final  ProfileFont font;
@override@JsonKey() final  OnlineStatus onlineStatus;
 final  List<MutualEntry>? _mutualFriends;
@override List<MutualEntry>? get mutualFriends {
  final value = _mutualFriends;
  if (value == null) return null;
  if (_mutualFriends is EqualUnmodifiableListView) return _mutualFriends;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<MutualEntry>? _mutualServers;
@override List<MutualEntry>? get mutualServers {
  final value = _mutualServers;
  if (value == null) return null;
  if (_mutualServers is EqualUnmodifiableListView) return _mutualServers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<ProfileConnection>? _connections;
@override List<ProfileConnection>? get connections {
  final value = _connections;
  if (value == null) return null;
  if (_connections is EqualUnmodifiableListView) return _connections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// A date, sent without a time. Kept as the raw string: it is displayed and
/// never compared, and parsing a date-only value into a `DateTime` would
/// shift it a day either way depending on the device's timezone.
@override final  String? birthday;
@override final  ProfileActivity? activity;

/// Create a copy of ProfileDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileDtoCopyWith<_ProfileDto> get copyWith => __$ProfileDtoCopyWithImpl<_ProfileDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileDto&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl)&&(identical(other.accentColor, accentColor) || other.accentColor == accentColor)&&(identical(other.font, font) || other.font == font)&&(identical(other.onlineStatus, onlineStatus) || other.onlineStatus == onlineStatus)&&const DeepCollectionEquality().equals(other._mutualFriends, _mutualFriends)&&const DeepCollectionEquality().equals(other._mutualServers, _mutualServers)&&const DeepCollectionEquality().equals(other._connections, _connections)&&(identical(other.birthday, birthday) || other.birthday == birthday)&&(identical(other.activity, activity) || other.activity == activity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,userName,bio,avatarUrl,bannerUrl,accentColor,font,onlineStatus,const DeepCollectionEquality().hash(_mutualFriends),const DeepCollectionEquality().hash(_mutualServers),const DeepCollectionEquality().hash(_connections),birthday,activity);

@override
String toString() {
  return 'ProfileDto(id: $id, userId: $userId, userName: $userName, bio: $bio, avatarUrl: $avatarUrl, bannerUrl: $bannerUrl, accentColor: $accentColor, font: $font, onlineStatus: $onlineStatus, mutualFriends: $mutualFriends, mutualServers: $mutualServers, connections: $connections, birthday: $birthday, activity: $activity)';
}


}

/// @nodoc
abstract mixin class _$ProfileDtoCopyWith<$Res> implements $ProfileDtoCopyWith<$Res> {
  factory _$ProfileDtoCopyWith(_ProfileDto value, $Res Function(_ProfileDto) _then) = __$ProfileDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String userName, String? bio, String? avatarUrl, String? bannerUrl, String? accentColor, ProfileFont font, OnlineStatus onlineStatus, List<MutualEntry>? mutualFriends, List<MutualEntry>? mutualServers, List<ProfileConnection>? connections, String? birthday, ProfileActivity? activity
});




}
/// @nodoc
class __$ProfileDtoCopyWithImpl<$Res>
    implements _$ProfileDtoCopyWith<$Res> {
  __$ProfileDtoCopyWithImpl(this._self, this._then);

  final _ProfileDto _self;
  final $Res Function(_ProfileDto) _then;

/// Create a copy of ProfileDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? userName = null,Object? bio = freezed,Object? avatarUrl = freezed,Object? bannerUrl = freezed,Object? accentColor = freezed,Object? font = null,Object? onlineStatus = null,Object? mutualFriends = freezed,Object? mutualServers = freezed,Object? connections = freezed,Object? birthday = freezed,Object? activity = freezed,}) {
  return _then(_ProfileDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,accentColor: freezed == accentColor ? _self.accentColor : accentColor // ignore: cast_nullable_to_non_nullable
as String?,font: null == font ? _self.font : font // ignore: cast_nullable_to_non_nullable
as ProfileFont,onlineStatus: null == onlineStatus ? _self.onlineStatus : onlineStatus // ignore: cast_nullable_to_non_nullable
as OnlineStatus,mutualFriends: freezed == mutualFriends ? _self._mutualFriends : mutualFriends // ignore: cast_nullable_to_non_nullable
as List<MutualEntry>?,mutualServers: freezed == mutualServers ? _self._mutualServers : mutualServers // ignore: cast_nullable_to_non_nullable
as List<MutualEntry>?,connections: freezed == connections ? _self._connections : connections // ignore: cast_nullable_to_non_nullable
as List<ProfileConnection>?,birthday: freezed == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as String?,activity: freezed == activity ? _self.activity : activity // ignore: cast_nullable_to_non_nullable
as ProfileActivity?,
  ));
}


}

// dart format on
