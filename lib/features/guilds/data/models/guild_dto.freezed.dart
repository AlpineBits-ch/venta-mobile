// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'guild_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GuildDto {

 String get id; String get name; String? get description; String get ownerId; List<CategoryDto> get categories; List<ChannelDto> get channels; List<RoleDto> get roles; String? get bannerUrl;/// Not yet sent by the backend - forward-compatible plumbing only, so
/// the client doesn't need a second change once it starts being sent.
/// `ServerRailIcon` falls back to the initial-letter circle while null.
 String? get iconUrl; String? get systemChannelId;@JsonKey(unknownEnumValue: VerificationLevel.none) VerificationLevel get verificationLevel;
/// Create a copy of GuildDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuildDtoCopyWith<GuildDto> get copyWith => _$GuildDtoCopyWithImpl<GuildDto>(this as GuildDto, _$identity);

  /// Serializes this GuildDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuildDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&const DeepCollectionEquality().equals(other.categories, categories)&&const DeepCollectionEquality().equals(other.channels, channels)&&const DeepCollectionEquality().equals(other.roles, roles)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.systemChannelId, systemChannelId) || other.systemChannelId == systemChannelId)&&(identical(other.verificationLevel, verificationLevel) || other.verificationLevel == verificationLevel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,ownerId,const DeepCollectionEquality().hash(categories),const DeepCollectionEquality().hash(channels),const DeepCollectionEquality().hash(roles),bannerUrl,iconUrl,systemChannelId,verificationLevel);

@override
String toString() {
  return 'GuildDto(id: $id, name: $name, description: $description, ownerId: $ownerId, categories: $categories, channels: $channels, roles: $roles, bannerUrl: $bannerUrl, iconUrl: $iconUrl, systemChannelId: $systemChannelId, verificationLevel: $verificationLevel)';
}


}

/// @nodoc
abstract mixin class $GuildDtoCopyWith<$Res>  {
  factory $GuildDtoCopyWith(GuildDto value, $Res Function(GuildDto) _then) = _$GuildDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, String ownerId, List<CategoryDto> categories, List<ChannelDto> channels, List<RoleDto> roles, String? bannerUrl, String? iconUrl, String? systemChannelId,@JsonKey(unknownEnumValue: VerificationLevel.none) VerificationLevel verificationLevel
});




}
/// @nodoc
class _$GuildDtoCopyWithImpl<$Res>
    implements $GuildDtoCopyWith<$Res> {
  _$GuildDtoCopyWithImpl(this._self, this._then);

  final GuildDto _self;
  final $Res Function(GuildDto) _then;

/// Create a copy of GuildDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? ownerId = null,Object? categories = null,Object? channels = null,Object? roles = null,Object? bannerUrl = freezed,Object? iconUrl = freezed,Object? systemChannelId = freezed,Object? verificationLevel = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<CategoryDto>,channels: null == channels ? _self.channels : channels // ignore: cast_nullable_to_non_nullable
as List<ChannelDto>,roles: null == roles ? _self.roles : roles // ignore: cast_nullable_to_non_nullable
as List<RoleDto>,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,systemChannelId: freezed == systemChannelId ? _self.systemChannelId : systemChannelId // ignore: cast_nullable_to_non_nullable
as String?,verificationLevel: null == verificationLevel ? _self.verificationLevel : verificationLevel // ignore: cast_nullable_to_non_nullable
as VerificationLevel,
  ));
}

}


/// Adds pattern-matching-related methods to [GuildDto].
extension GuildDtoPatterns on GuildDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuildDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuildDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuildDto value)  $default,){
final _that = this;
switch (_that) {
case _GuildDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuildDto value)?  $default,){
final _that = this;
switch (_that) {
case _GuildDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String ownerId,  List<CategoryDto> categories,  List<ChannelDto> channels,  List<RoleDto> roles,  String? bannerUrl,  String? iconUrl,  String? systemChannelId, @JsonKey(unknownEnumValue: VerificationLevel.none)  VerificationLevel verificationLevel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuildDto() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.ownerId,_that.categories,_that.channels,_that.roles,_that.bannerUrl,_that.iconUrl,_that.systemChannelId,_that.verificationLevel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String ownerId,  List<CategoryDto> categories,  List<ChannelDto> channels,  List<RoleDto> roles,  String? bannerUrl,  String? iconUrl,  String? systemChannelId, @JsonKey(unknownEnumValue: VerificationLevel.none)  VerificationLevel verificationLevel)  $default,) {final _that = this;
switch (_that) {
case _GuildDto():
return $default(_that.id,_that.name,_that.description,_that.ownerId,_that.categories,_that.channels,_that.roles,_that.bannerUrl,_that.iconUrl,_that.systemChannelId,_that.verificationLevel);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  String ownerId,  List<CategoryDto> categories,  List<ChannelDto> channels,  List<RoleDto> roles,  String? bannerUrl,  String? iconUrl,  String? systemChannelId, @JsonKey(unknownEnumValue: VerificationLevel.none)  VerificationLevel verificationLevel)?  $default,) {final _that = this;
switch (_that) {
case _GuildDto() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.ownerId,_that.categories,_that.channels,_that.roles,_that.bannerUrl,_that.iconUrl,_that.systemChannelId,_that.verificationLevel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GuildDto implements GuildDto {
  const _GuildDto({required this.id, required this.name, this.description, required this.ownerId, final  List<CategoryDto> categories = const <CategoryDto>[], final  List<ChannelDto> channels = const <ChannelDto>[], final  List<RoleDto> roles = const <RoleDto>[], this.bannerUrl, this.iconUrl, this.systemChannelId, @JsonKey(unknownEnumValue: VerificationLevel.none) this.verificationLevel = VerificationLevel.none}): _categories = categories,_channels = channels,_roles = roles;
  factory _GuildDto.fromJson(Map<String, dynamic> json) => _$GuildDtoFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override final  String ownerId;
 final  List<CategoryDto> _categories;
@override@JsonKey() List<CategoryDto> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

 final  List<ChannelDto> _channels;
@override@JsonKey() List<ChannelDto> get channels {
  if (_channels is EqualUnmodifiableListView) return _channels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_channels);
}

 final  List<RoleDto> _roles;
@override@JsonKey() List<RoleDto> get roles {
  if (_roles is EqualUnmodifiableListView) return _roles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roles);
}

@override final  String? bannerUrl;
/// Not yet sent by the backend - forward-compatible plumbing only, so
/// the client doesn't need a second change once it starts being sent.
/// `ServerRailIcon` falls back to the initial-letter circle while null.
@override final  String? iconUrl;
@override final  String? systemChannelId;
@override@JsonKey(unknownEnumValue: VerificationLevel.none) final  VerificationLevel verificationLevel;

/// Create a copy of GuildDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuildDtoCopyWith<_GuildDto> get copyWith => __$GuildDtoCopyWithImpl<_GuildDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GuildDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuildDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&const DeepCollectionEquality().equals(other._categories, _categories)&&const DeepCollectionEquality().equals(other._channels, _channels)&&const DeepCollectionEquality().equals(other._roles, _roles)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.systemChannelId, systemChannelId) || other.systemChannelId == systemChannelId)&&(identical(other.verificationLevel, verificationLevel) || other.verificationLevel == verificationLevel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,ownerId,const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_channels),const DeepCollectionEquality().hash(_roles),bannerUrl,iconUrl,systemChannelId,verificationLevel);

@override
String toString() {
  return 'GuildDto(id: $id, name: $name, description: $description, ownerId: $ownerId, categories: $categories, channels: $channels, roles: $roles, bannerUrl: $bannerUrl, iconUrl: $iconUrl, systemChannelId: $systemChannelId, verificationLevel: $verificationLevel)';
}


}

/// @nodoc
abstract mixin class _$GuildDtoCopyWith<$Res> implements $GuildDtoCopyWith<$Res> {
  factory _$GuildDtoCopyWith(_GuildDto value, $Res Function(_GuildDto) _then) = __$GuildDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, String ownerId, List<CategoryDto> categories, List<ChannelDto> channels, List<RoleDto> roles, String? bannerUrl, String? iconUrl, String? systemChannelId,@JsonKey(unknownEnumValue: VerificationLevel.none) VerificationLevel verificationLevel
});




}
/// @nodoc
class __$GuildDtoCopyWithImpl<$Res>
    implements _$GuildDtoCopyWith<$Res> {
  __$GuildDtoCopyWithImpl(this._self, this._then);

  final _GuildDto _self;
  final $Res Function(_GuildDto) _then;

/// Create a copy of GuildDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? ownerId = null,Object? categories = null,Object? channels = null,Object? roles = null,Object? bannerUrl = freezed,Object? iconUrl = freezed,Object? systemChannelId = freezed,Object? verificationLevel = null,}) {
  return _then(_GuildDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<CategoryDto>,channels: null == channels ? _self._channels : channels // ignore: cast_nullable_to_non_nullable
as List<ChannelDto>,roles: null == roles ? _self._roles : roles // ignore: cast_nullable_to_non_nullable
as List<RoleDto>,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,systemChannelId: freezed == systemChannelId ? _self.systemChannelId : systemChannelId // ignore: cast_nullable_to_non_nullable
as String?,verificationLevel: null == verificationLevel ? _self.verificationLevel : verificationLevel // ignore: cast_nullable_to_non_nullable
as VerificationLevel,
  ));
}


}

// dart format on
