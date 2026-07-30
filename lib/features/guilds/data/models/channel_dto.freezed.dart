// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'channel_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChannelPermissionDto {

 String get id; String? get channelId; String? get roleId; String? get memberId; String? get categoryId; String get allowPermissions; String get denyPermissions;
/// Create a copy of ChannelPermissionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChannelPermissionDtoCopyWith<ChannelPermissionDto> get copyWith => _$ChannelPermissionDtoCopyWithImpl<ChannelPermissionDto>(this as ChannelPermissionDto, _$identity);

  /// Serializes this ChannelPermissionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChannelPermissionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.roleId, roleId) || other.roleId == roleId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.allowPermissions, allowPermissions) || other.allowPermissions == allowPermissions)&&(identical(other.denyPermissions, denyPermissions) || other.denyPermissions == denyPermissions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,roleId,memberId,categoryId,allowPermissions,denyPermissions);

@override
String toString() {
  return 'ChannelPermissionDto(id: $id, channelId: $channelId, roleId: $roleId, memberId: $memberId, categoryId: $categoryId, allowPermissions: $allowPermissions, denyPermissions: $denyPermissions)';
}


}

/// @nodoc
abstract mixin class $ChannelPermissionDtoCopyWith<$Res>  {
  factory $ChannelPermissionDtoCopyWith(ChannelPermissionDto value, $Res Function(ChannelPermissionDto) _then) = _$ChannelPermissionDtoCopyWithImpl;
@useResult
$Res call({
 String id, String? channelId, String? roleId, String? memberId, String? categoryId, String allowPermissions, String denyPermissions
});




}
/// @nodoc
class _$ChannelPermissionDtoCopyWithImpl<$Res>
    implements $ChannelPermissionDtoCopyWith<$Res> {
  _$ChannelPermissionDtoCopyWithImpl(this._self, this._then);

  final ChannelPermissionDto _self;
  final $Res Function(ChannelPermissionDto) _then;

/// Create a copy of ChannelPermissionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? channelId = freezed,Object? roleId = freezed,Object? memberId = freezed,Object? categoryId = freezed,Object? allowPermissions = null,Object? denyPermissions = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channelId: freezed == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String?,roleId: freezed == roleId ? _self.roleId : roleId // ignore: cast_nullable_to_non_nullable
as String?,memberId: freezed == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,allowPermissions: null == allowPermissions ? _self.allowPermissions : allowPermissions // ignore: cast_nullable_to_non_nullable
as String,denyPermissions: null == denyPermissions ? _self.denyPermissions : denyPermissions // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ChannelPermissionDto].
extension ChannelPermissionDtoPatterns on ChannelPermissionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChannelPermissionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChannelPermissionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChannelPermissionDto value)  $default,){
final _that = this;
switch (_that) {
case _ChannelPermissionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChannelPermissionDto value)?  $default,){
final _that = this;
switch (_that) {
case _ChannelPermissionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? channelId,  String? roleId,  String? memberId,  String? categoryId,  String allowPermissions,  String denyPermissions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChannelPermissionDto() when $default != null:
return $default(_that.id,_that.channelId,_that.roleId,_that.memberId,_that.categoryId,_that.allowPermissions,_that.denyPermissions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? channelId,  String? roleId,  String? memberId,  String? categoryId,  String allowPermissions,  String denyPermissions)  $default,) {final _that = this;
switch (_that) {
case _ChannelPermissionDto():
return $default(_that.id,_that.channelId,_that.roleId,_that.memberId,_that.categoryId,_that.allowPermissions,_that.denyPermissions);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? channelId,  String? roleId,  String? memberId,  String? categoryId,  String allowPermissions,  String denyPermissions)?  $default,) {final _that = this;
switch (_that) {
case _ChannelPermissionDto() when $default != null:
return $default(_that.id,_that.channelId,_that.roleId,_that.memberId,_that.categoryId,_that.allowPermissions,_that.denyPermissions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChannelPermissionDto implements ChannelPermissionDto {
  const _ChannelPermissionDto({required this.id, this.channelId, this.roleId, this.memberId, this.categoryId, required this.allowPermissions, required this.denyPermissions});
  factory _ChannelPermissionDto.fromJson(Map<String, dynamic> json) => _$ChannelPermissionDtoFromJson(json);

@override final  String id;
@override final  String? channelId;
@override final  String? roleId;
@override final  String? memberId;
@override final  String? categoryId;
@override final  String allowPermissions;
@override final  String denyPermissions;

/// Create a copy of ChannelPermissionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChannelPermissionDtoCopyWith<_ChannelPermissionDto> get copyWith => __$ChannelPermissionDtoCopyWithImpl<_ChannelPermissionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChannelPermissionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChannelPermissionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.roleId, roleId) || other.roleId == roleId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.allowPermissions, allowPermissions) || other.allowPermissions == allowPermissions)&&(identical(other.denyPermissions, denyPermissions) || other.denyPermissions == denyPermissions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,roleId,memberId,categoryId,allowPermissions,denyPermissions);

@override
String toString() {
  return 'ChannelPermissionDto(id: $id, channelId: $channelId, roleId: $roleId, memberId: $memberId, categoryId: $categoryId, allowPermissions: $allowPermissions, denyPermissions: $denyPermissions)';
}


}

/// @nodoc
abstract mixin class _$ChannelPermissionDtoCopyWith<$Res> implements $ChannelPermissionDtoCopyWith<$Res> {
  factory _$ChannelPermissionDtoCopyWith(_ChannelPermissionDto value, $Res Function(_ChannelPermissionDto) _then) = __$ChannelPermissionDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String? channelId, String? roleId, String? memberId, String? categoryId, String allowPermissions, String denyPermissions
});




}
/// @nodoc
class __$ChannelPermissionDtoCopyWithImpl<$Res>
    implements _$ChannelPermissionDtoCopyWith<$Res> {
  __$ChannelPermissionDtoCopyWithImpl(this._self, this._then);

  final _ChannelPermissionDto _self;
  final $Res Function(_ChannelPermissionDto) _then;

/// Create a copy of ChannelPermissionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? channelId = freezed,Object? roleId = freezed,Object? memberId = freezed,Object? categoryId = freezed,Object? allowPermissions = null,Object? denyPermissions = null,}) {
  return _then(_ChannelPermissionDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channelId: freezed == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String?,roleId: freezed == roleId ? _self.roleId : roleId // ignore: cast_nullable_to_non_nullable
as String?,memberId: freezed == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,allowPermissions: null == allowPermissions ? _self.allowPermissions : allowPermissions // ignore: cast_nullable_to_non_nullable
as String,denyPermissions: null == denyPermissions ? _self.denyPermissions : denyPermissions // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ChannelDto {

 String get id; String get name; String? get description;@JsonKey(unknownEnumValue: ChannelType.unknown) ChannelType get type; String get guildId; bool get isAgeRestricted; bool get isPrivate; String? get categoryId; List<ChannelPermissionDto> get permissions; int get position; int get slowModeSeconds; String? get parentChannelId; List<String> get tagIds; bool get isPinned;/// No new messages, by moderator decision - distinct from archived, and
/// persisting independently of it.
 bool get isLocked; bool get isArchived; DateTime? get lastActivityAt; int get messageCount; DateTime? get autoArchiveAt;
/// Create a copy of ChannelDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChannelDtoCopyWith<ChannelDto> get copyWith => _$ChannelDtoCopyWithImpl<ChannelDto>(this as ChannelDto, _$identity);

  /// Serializes this ChannelDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChannelDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.isAgeRestricted, isAgeRestricted) || other.isAgeRestricted == isAgeRestricted)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&const DeepCollectionEquality().equals(other.permissions, permissions)&&(identical(other.position, position) || other.position == position)&&(identical(other.slowModeSeconds, slowModeSeconds) || other.slowModeSeconds == slowModeSeconds)&&(identical(other.parentChannelId, parentChannelId) || other.parentChannelId == parentChannelId)&&const DeepCollectionEquality().equals(other.tagIds, tagIds)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.lastActivityAt, lastActivityAt) || other.lastActivityAt == lastActivityAt)&&(identical(other.messageCount, messageCount) || other.messageCount == messageCount)&&(identical(other.autoArchiveAt, autoArchiveAt) || other.autoArchiveAt == autoArchiveAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,description,type,guildId,isAgeRestricted,isPrivate,categoryId,const DeepCollectionEquality().hash(permissions),position,slowModeSeconds,parentChannelId,const DeepCollectionEquality().hash(tagIds),isPinned,isLocked,isArchived,lastActivityAt,messageCount,autoArchiveAt]);

@override
String toString() {
  return 'ChannelDto(id: $id, name: $name, description: $description, type: $type, guildId: $guildId, isAgeRestricted: $isAgeRestricted, isPrivate: $isPrivate, categoryId: $categoryId, permissions: $permissions, position: $position, slowModeSeconds: $slowModeSeconds, parentChannelId: $parentChannelId, tagIds: $tagIds, isPinned: $isPinned, isLocked: $isLocked, isArchived: $isArchived, lastActivityAt: $lastActivityAt, messageCount: $messageCount, autoArchiveAt: $autoArchiveAt)';
}


}

/// @nodoc
abstract mixin class $ChannelDtoCopyWith<$Res>  {
  factory $ChannelDtoCopyWith(ChannelDto value, $Res Function(ChannelDto) _then) = _$ChannelDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description,@JsonKey(unknownEnumValue: ChannelType.unknown) ChannelType type, String guildId, bool isAgeRestricted, bool isPrivate, String? categoryId, List<ChannelPermissionDto> permissions, int position, int slowModeSeconds, String? parentChannelId, List<String> tagIds, bool isPinned, bool isLocked, bool isArchived, DateTime? lastActivityAt, int messageCount, DateTime? autoArchiveAt
});




}
/// @nodoc
class _$ChannelDtoCopyWithImpl<$Res>
    implements $ChannelDtoCopyWith<$Res> {
  _$ChannelDtoCopyWithImpl(this._self, this._then);

  final ChannelDto _self;
  final $Res Function(ChannelDto) _then;

/// Create a copy of ChannelDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? type = null,Object? guildId = null,Object? isAgeRestricted = null,Object? isPrivate = null,Object? categoryId = freezed,Object? permissions = null,Object? position = null,Object? slowModeSeconds = null,Object? parentChannelId = freezed,Object? tagIds = null,Object? isPinned = null,Object? isLocked = null,Object? isArchived = null,Object? lastActivityAt = freezed,Object? messageCount = null,Object? autoArchiveAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ChannelType,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,isAgeRestricted: null == isAgeRestricted ? _self.isAgeRestricted : isAgeRestricted // ignore: cast_nullable_to_non_nullable
as bool,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<ChannelPermissionDto>,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,slowModeSeconds: null == slowModeSeconds ? _self.slowModeSeconds : slowModeSeconds // ignore: cast_nullable_to_non_nullable
as int,parentChannelId: freezed == parentChannelId ? _self.parentChannelId : parentChannelId // ignore: cast_nullable_to_non_nullable
as String?,tagIds: null == tagIds ? _self.tagIds : tagIds // ignore: cast_nullable_to_non_nullable
as List<String>,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,isLocked: null == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,lastActivityAt: freezed == lastActivityAt ? _self.lastActivityAt : lastActivityAt // ignore: cast_nullable_to_non_nullable
as DateTime?,messageCount: null == messageCount ? _self.messageCount : messageCount // ignore: cast_nullable_to_non_nullable
as int,autoArchiveAt: freezed == autoArchiveAt ? _self.autoArchiveAt : autoArchiveAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChannelDto].
extension ChannelDtoPatterns on ChannelDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChannelDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChannelDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChannelDto value)  $default,){
final _that = this;
switch (_that) {
case _ChannelDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChannelDto value)?  $default,){
final _that = this;
switch (_that) {
case _ChannelDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description, @JsonKey(unknownEnumValue: ChannelType.unknown)  ChannelType type,  String guildId,  bool isAgeRestricted,  bool isPrivate,  String? categoryId,  List<ChannelPermissionDto> permissions,  int position,  int slowModeSeconds,  String? parentChannelId,  List<String> tagIds,  bool isPinned,  bool isLocked,  bool isArchived,  DateTime? lastActivityAt,  int messageCount,  DateTime? autoArchiveAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChannelDto() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.type,_that.guildId,_that.isAgeRestricted,_that.isPrivate,_that.categoryId,_that.permissions,_that.position,_that.slowModeSeconds,_that.parentChannelId,_that.tagIds,_that.isPinned,_that.isLocked,_that.isArchived,_that.lastActivityAt,_that.messageCount,_that.autoArchiveAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description, @JsonKey(unknownEnumValue: ChannelType.unknown)  ChannelType type,  String guildId,  bool isAgeRestricted,  bool isPrivate,  String? categoryId,  List<ChannelPermissionDto> permissions,  int position,  int slowModeSeconds,  String? parentChannelId,  List<String> tagIds,  bool isPinned,  bool isLocked,  bool isArchived,  DateTime? lastActivityAt,  int messageCount,  DateTime? autoArchiveAt)  $default,) {final _that = this;
switch (_that) {
case _ChannelDto():
return $default(_that.id,_that.name,_that.description,_that.type,_that.guildId,_that.isAgeRestricted,_that.isPrivate,_that.categoryId,_that.permissions,_that.position,_that.slowModeSeconds,_that.parentChannelId,_that.tagIds,_that.isPinned,_that.isLocked,_that.isArchived,_that.lastActivityAt,_that.messageCount,_that.autoArchiveAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description, @JsonKey(unknownEnumValue: ChannelType.unknown)  ChannelType type,  String guildId,  bool isAgeRestricted,  bool isPrivate,  String? categoryId,  List<ChannelPermissionDto> permissions,  int position,  int slowModeSeconds,  String? parentChannelId,  List<String> tagIds,  bool isPinned,  bool isLocked,  bool isArchived,  DateTime? lastActivityAt,  int messageCount,  DateTime? autoArchiveAt)?  $default,) {final _that = this;
switch (_that) {
case _ChannelDto() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.type,_that.guildId,_that.isAgeRestricted,_that.isPrivate,_that.categoryId,_that.permissions,_that.position,_that.slowModeSeconds,_that.parentChannelId,_that.tagIds,_that.isPinned,_that.isLocked,_that.isArchived,_that.lastActivityAt,_that.messageCount,_that.autoArchiveAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChannelDto implements ChannelDto {
  const _ChannelDto({required this.id, required this.name, this.description, @JsonKey(unknownEnumValue: ChannelType.unknown) required this.type, required this.guildId, this.isAgeRestricted = false, this.isPrivate = false, this.categoryId, final  List<ChannelPermissionDto> permissions = const <ChannelPermissionDto>[], this.position = 0, this.slowModeSeconds = 0, this.parentChannelId, final  List<String> tagIds = const <String>[], this.isPinned = false, this.isLocked = false, this.isArchived = false, this.lastActivityAt, this.messageCount = 0, this.autoArchiveAt}): _permissions = permissions,_tagIds = tagIds;
  factory _ChannelDto.fromJson(Map<String, dynamic> json) => _$ChannelDtoFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override@JsonKey(unknownEnumValue: ChannelType.unknown) final  ChannelType type;
@override final  String guildId;
@override@JsonKey() final  bool isAgeRestricted;
@override@JsonKey() final  bool isPrivate;
@override final  String? categoryId;
 final  List<ChannelPermissionDto> _permissions;
@override@JsonKey() List<ChannelPermissionDto> get permissions {
  if (_permissions is EqualUnmodifiableListView) return _permissions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_permissions);
}

@override@JsonKey() final  int position;
@override@JsonKey() final  int slowModeSeconds;
@override final  String? parentChannelId;
 final  List<String> _tagIds;
@override@JsonKey() List<String> get tagIds {
  if (_tagIds is EqualUnmodifiableListView) return _tagIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tagIds);
}

@override@JsonKey() final  bool isPinned;
/// No new messages, by moderator decision - distinct from archived, and
/// persisting independently of it.
@override@JsonKey() final  bool isLocked;
@override@JsonKey() final  bool isArchived;
@override final  DateTime? lastActivityAt;
@override@JsonKey() final  int messageCount;
@override final  DateTime? autoArchiveAt;

/// Create a copy of ChannelDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChannelDtoCopyWith<_ChannelDto> get copyWith => __$ChannelDtoCopyWithImpl<_ChannelDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChannelDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChannelDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.isAgeRestricted, isAgeRestricted) || other.isAgeRestricted == isAgeRestricted)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&const DeepCollectionEquality().equals(other._permissions, _permissions)&&(identical(other.position, position) || other.position == position)&&(identical(other.slowModeSeconds, slowModeSeconds) || other.slowModeSeconds == slowModeSeconds)&&(identical(other.parentChannelId, parentChannelId) || other.parentChannelId == parentChannelId)&&const DeepCollectionEquality().equals(other._tagIds, _tagIds)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.lastActivityAt, lastActivityAt) || other.lastActivityAt == lastActivityAt)&&(identical(other.messageCount, messageCount) || other.messageCount == messageCount)&&(identical(other.autoArchiveAt, autoArchiveAt) || other.autoArchiveAt == autoArchiveAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,description,type,guildId,isAgeRestricted,isPrivate,categoryId,const DeepCollectionEquality().hash(_permissions),position,slowModeSeconds,parentChannelId,const DeepCollectionEquality().hash(_tagIds),isPinned,isLocked,isArchived,lastActivityAt,messageCount,autoArchiveAt]);

@override
String toString() {
  return 'ChannelDto(id: $id, name: $name, description: $description, type: $type, guildId: $guildId, isAgeRestricted: $isAgeRestricted, isPrivate: $isPrivate, categoryId: $categoryId, permissions: $permissions, position: $position, slowModeSeconds: $slowModeSeconds, parentChannelId: $parentChannelId, tagIds: $tagIds, isPinned: $isPinned, isLocked: $isLocked, isArchived: $isArchived, lastActivityAt: $lastActivityAt, messageCount: $messageCount, autoArchiveAt: $autoArchiveAt)';
}


}

/// @nodoc
abstract mixin class _$ChannelDtoCopyWith<$Res> implements $ChannelDtoCopyWith<$Res> {
  factory _$ChannelDtoCopyWith(_ChannelDto value, $Res Function(_ChannelDto) _then) = __$ChannelDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description,@JsonKey(unknownEnumValue: ChannelType.unknown) ChannelType type, String guildId, bool isAgeRestricted, bool isPrivate, String? categoryId, List<ChannelPermissionDto> permissions, int position, int slowModeSeconds, String? parentChannelId, List<String> tagIds, bool isPinned, bool isLocked, bool isArchived, DateTime? lastActivityAt, int messageCount, DateTime? autoArchiveAt
});




}
/// @nodoc
class __$ChannelDtoCopyWithImpl<$Res>
    implements _$ChannelDtoCopyWith<$Res> {
  __$ChannelDtoCopyWithImpl(this._self, this._then);

  final _ChannelDto _self;
  final $Res Function(_ChannelDto) _then;

/// Create a copy of ChannelDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? type = null,Object? guildId = null,Object? isAgeRestricted = null,Object? isPrivate = null,Object? categoryId = freezed,Object? permissions = null,Object? position = null,Object? slowModeSeconds = null,Object? parentChannelId = freezed,Object? tagIds = null,Object? isPinned = null,Object? isLocked = null,Object? isArchived = null,Object? lastActivityAt = freezed,Object? messageCount = null,Object? autoArchiveAt = freezed,}) {
  return _then(_ChannelDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ChannelType,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,isAgeRestricted: null == isAgeRestricted ? _self.isAgeRestricted : isAgeRestricted // ignore: cast_nullable_to_non_nullable
as bool,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,permissions: null == permissions ? _self._permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<ChannelPermissionDto>,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,slowModeSeconds: null == slowModeSeconds ? _self.slowModeSeconds : slowModeSeconds // ignore: cast_nullable_to_non_nullable
as int,parentChannelId: freezed == parentChannelId ? _self.parentChannelId : parentChannelId // ignore: cast_nullable_to_non_nullable
as String?,tagIds: null == tagIds ? _self._tagIds : tagIds // ignore: cast_nullable_to_non_nullable
as List<String>,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,isLocked: null == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,lastActivityAt: freezed == lastActivityAt ? _self.lastActivityAt : lastActivityAt // ignore: cast_nullable_to_non_nullable
as DateTime?,messageCount: null == messageCount ? _self.messageCount : messageCount // ignore: cast_nullable_to_non_nullable
as int,autoArchiveAt: freezed == autoArchiveAt ? _self.autoArchiveAt : autoArchiveAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
