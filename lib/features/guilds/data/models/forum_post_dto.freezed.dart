// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'forum_post_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ForumPostDto {

 String get id; String get guildId;/// The forum channel this post belongs to.
 String? get parentChannelId;/// The post title.
 String get name; String? get description; DateTime? get createdAt; DateTime? get updatedAt; String? get createdByUserId;/// Applied tags, already ordered by each tag's own `position` - render in
/// array order rather than re-sorting.
 List<String> get tagIds; bool get isPinned; bool get isLocked; bool get isArchived;/// When this post auto-archives absent further activity. Honoured by a
/// periodic sweep, so it can lag a few minutes - don't render a live
/// countdown that hits zero and stalls.
 DateTime? get autoArchiveAt;/// This post's own archive window, snapshotted from the forum's config at
/// creation - so changing the forum default later leaves it alone.
 int? get autoArchiveMinutes;/// Last message timestamp; null for a post nobody has replied in (and for
/// every post created before the backend started tracking it).
 DateTime? get lastActivityAt; int get messageCount; bool get isAgeRestricted; bool get isPrivate; int get slowModeSeconds;
/// Create a copy of ForumPostDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ForumPostDtoCopyWith<ForumPostDto> get copyWith => _$ForumPostDtoCopyWithImpl<ForumPostDto>(this as ForumPostDto, _$identity);

  /// Serializes this ForumPostDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ForumPostDto&&(identical(other.id, id) || other.id == id)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.parentChannelId, parentChannelId) || other.parentChannelId == parentChannelId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId)&&const DeepCollectionEquality().equals(other.tagIds, tagIds)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.autoArchiveAt, autoArchiveAt) || other.autoArchiveAt == autoArchiveAt)&&(identical(other.autoArchiveMinutes, autoArchiveMinutes) || other.autoArchiveMinutes == autoArchiveMinutes)&&(identical(other.lastActivityAt, lastActivityAt) || other.lastActivityAt == lastActivityAt)&&(identical(other.messageCount, messageCount) || other.messageCount == messageCount)&&(identical(other.isAgeRestricted, isAgeRestricted) || other.isAgeRestricted == isAgeRestricted)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.slowModeSeconds, slowModeSeconds) || other.slowModeSeconds == slowModeSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,guildId,parentChannelId,name,description,createdAt,updatedAt,createdByUserId,const DeepCollectionEquality().hash(tagIds),isPinned,isLocked,isArchived,autoArchiveAt,autoArchiveMinutes,lastActivityAt,messageCount,isAgeRestricted,isPrivate,slowModeSeconds]);

@override
String toString() {
  return 'ForumPostDto(id: $id, guildId: $guildId, parentChannelId: $parentChannelId, name: $name, description: $description, createdAt: $createdAt, updatedAt: $updatedAt, createdByUserId: $createdByUserId, tagIds: $tagIds, isPinned: $isPinned, isLocked: $isLocked, isArchived: $isArchived, autoArchiveAt: $autoArchiveAt, autoArchiveMinutes: $autoArchiveMinutes, lastActivityAt: $lastActivityAt, messageCount: $messageCount, isAgeRestricted: $isAgeRestricted, isPrivate: $isPrivate, slowModeSeconds: $slowModeSeconds)';
}


}

/// @nodoc
abstract mixin class $ForumPostDtoCopyWith<$Res>  {
  factory $ForumPostDtoCopyWith(ForumPostDto value, $Res Function(ForumPostDto) _then) = _$ForumPostDtoCopyWithImpl;
@useResult
$Res call({
 String id, String guildId, String? parentChannelId, String name, String? description, DateTime? createdAt, DateTime? updatedAt, String? createdByUserId, List<String> tagIds, bool isPinned, bool isLocked, bool isArchived, DateTime? autoArchiveAt, int? autoArchiveMinutes, DateTime? lastActivityAt, int messageCount, bool isAgeRestricted, bool isPrivate, int slowModeSeconds
});




}
/// @nodoc
class _$ForumPostDtoCopyWithImpl<$Res>
    implements $ForumPostDtoCopyWith<$Res> {
  _$ForumPostDtoCopyWithImpl(this._self, this._then);

  final ForumPostDto _self;
  final $Res Function(ForumPostDto) _then;

/// Create a copy of ForumPostDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? guildId = null,Object? parentChannelId = freezed,Object? name = null,Object? description = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? createdByUserId = freezed,Object? tagIds = null,Object? isPinned = null,Object? isLocked = null,Object? isArchived = null,Object? autoArchiveAt = freezed,Object? autoArchiveMinutes = freezed,Object? lastActivityAt = freezed,Object? messageCount = null,Object? isAgeRestricted = null,Object? isPrivate = null,Object? slowModeSeconds = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,parentChannelId: freezed == parentChannelId ? _self.parentChannelId : parentChannelId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdByUserId: freezed == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String?,tagIds: null == tagIds ? _self.tagIds : tagIds // ignore: cast_nullable_to_non_nullable
as List<String>,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,isLocked: null == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,autoArchiveAt: freezed == autoArchiveAt ? _self.autoArchiveAt : autoArchiveAt // ignore: cast_nullable_to_non_nullable
as DateTime?,autoArchiveMinutes: freezed == autoArchiveMinutes ? _self.autoArchiveMinutes : autoArchiveMinutes // ignore: cast_nullable_to_non_nullable
as int?,lastActivityAt: freezed == lastActivityAt ? _self.lastActivityAt : lastActivityAt // ignore: cast_nullable_to_non_nullable
as DateTime?,messageCount: null == messageCount ? _self.messageCount : messageCount // ignore: cast_nullable_to_non_nullable
as int,isAgeRestricted: null == isAgeRestricted ? _self.isAgeRestricted : isAgeRestricted // ignore: cast_nullable_to_non_nullable
as bool,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,slowModeSeconds: null == slowModeSeconds ? _self.slowModeSeconds : slowModeSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ForumPostDto].
extension ForumPostDtoPatterns on ForumPostDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ForumPostDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ForumPostDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ForumPostDto value)  $default,){
final _that = this;
switch (_that) {
case _ForumPostDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ForumPostDto value)?  $default,){
final _that = this;
switch (_that) {
case _ForumPostDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String guildId,  String? parentChannelId,  String name,  String? description,  DateTime? createdAt,  DateTime? updatedAt,  String? createdByUserId,  List<String> tagIds,  bool isPinned,  bool isLocked,  bool isArchived,  DateTime? autoArchiveAt,  int? autoArchiveMinutes,  DateTime? lastActivityAt,  int messageCount,  bool isAgeRestricted,  bool isPrivate,  int slowModeSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ForumPostDto() when $default != null:
return $default(_that.id,_that.guildId,_that.parentChannelId,_that.name,_that.description,_that.createdAt,_that.updatedAt,_that.createdByUserId,_that.tagIds,_that.isPinned,_that.isLocked,_that.isArchived,_that.autoArchiveAt,_that.autoArchiveMinutes,_that.lastActivityAt,_that.messageCount,_that.isAgeRestricted,_that.isPrivate,_that.slowModeSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String guildId,  String? parentChannelId,  String name,  String? description,  DateTime? createdAt,  DateTime? updatedAt,  String? createdByUserId,  List<String> tagIds,  bool isPinned,  bool isLocked,  bool isArchived,  DateTime? autoArchiveAt,  int? autoArchiveMinutes,  DateTime? lastActivityAt,  int messageCount,  bool isAgeRestricted,  bool isPrivate,  int slowModeSeconds)  $default,) {final _that = this;
switch (_that) {
case _ForumPostDto():
return $default(_that.id,_that.guildId,_that.parentChannelId,_that.name,_that.description,_that.createdAt,_that.updatedAt,_that.createdByUserId,_that.tagIds,_that.isPinned,_that.isLocked,_that.isArchived,_that.autoArchiveAt,_that.autoArchiveMinutes,_that.lastActivityAt,_that.messageCount,_that.isAgeRestricted,_that.isPrivate,_that.slowModeSeconds);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String guildId,  String? parentChannelId,  String name,  String? description,  DateTime? createdAt,  DateTime? updatedAt,  String? createdByUserId,  List<String> tagIds,  bool isPinned,  bool isLocked,  bool isArchived,  DateTime? autoArchiveAt,  int? autoArchiveMinutes,  DateTime? lastActivityAt,  int messageCount,  bool isAgeRestricted,  bool isPrivate,  int slowModeSeconds)?  $default,) {final _that = this;
switch (_that) {
case _ForumPostDto() when $default != null:
return $default(_that.id,_that.guildId,_that.parentChannelId,_that.name,_that.description,_that.createdAt,_that.updatedAt,_that.createdByUserId,_that.tagIds,_that.isPinned,_that.isLocked,_that.isArchived,_that.autoArchiveAt,_that.autoArchiveMinutes,_that.lastActivityAt,_that.messageCount,_that.isAgeRestricted,_that.isPrivate,_that.slowModeSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ForumPostDto implements ForumPostDto {
  const _ForumPostDto({required this.id, required this.guildId, this.parentChannelId, required this.name, this.description, this.createdAt, this.updatedAt, this.createdByUserId, final  List<String> tagIds = const <String>[], this.isPinned = false, this.isLocked = false, this.isArchived = false, this.autoArchiveAt, this.autoArchiveMinutes, this.lastActivityAt, this.messageCount = 0, this.isAgeRestricted = false, this.isPrivate = false, this.slowModeSeconds = 0}): _tagIds = tagIds;
  factory _ForumPostDto.fromJson(Map<String, dynamic> json) => _$ForumPostDtoFromJson(json);

@override final  String id;
@override final  String guildId;
/// The forum channel this post belongs to.
@override final  String? parentChannelId;
/// The post title.
@override final  String name;
@override final  String? description;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
@override final  String? createdByUserId;
/// Applied tags, already ordered by each tag's own `position` - render in
/// array order rather than re-sorting.
 final  List<String> _tagIds;
/// Applied tags, already ordered by each tag's own `position` - render in
/// array order rather than re-sorting.
@override@JsonKey() List<String> get tagIds {
  if (_tagIds is EqualUnmodifiableListView) return _tagIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tagIds);
}

@override@JsonKey() final  bool isPinned;
@override@JsonKey() final  bool isLocked;
@override@JsonKey() final  bool isArchived;
/// When this post auto-archives absent further activity. Honoured by a
/// periodic sweep, so it can lag a few minutes - don't render a live
/// countdown that hits zero and stalls.
@override final  DateTime? autoArchiveAt;
/// This post's own archive window, snapshotted from the forum's config at
/// creation - so changing the forum default later leaves it alone.
@override final  int? autoArchiveMinutes;
/// Last message timestamp; null for a post nobody has replied in (and for
/// every post created before the backend started tracking it).
@override final  DateTime? lastActivityAt;
@override@JsonKey() final  int messageCount;
@override@JsonKey() final  bool isAgeRestricted;
@override@JsonKey() final  bool isPrivate;
@override@JsonKey() final  int slowModeSeconds;

/// Create a copy of ForumPostDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ForumPostDtoCopyWith<_ForumPostDto> get copyWith => __$ForumPostDtoCopyWithImpl<_ForumPostDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ForumPostDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ForumPostDto&&(identical(other.id, id) || other.id == id)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.parentChannelId, parentChannelId) || other.parentChannelId == parentChannelId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId)&&const DeepCollectionEquality().equals(other._tagIds, _tagIds)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.autoArchiveAt, autoArchiveAt) || other.autoArchiveAt == autoArchiveAt)&&(identical(other.autoArchiveMinutes, autoArchiveMinutes) || other.autoArchiveMinutes == autoArchiveMinutes)&&(identical(other.lastActivityAt, lastActivityAt) || other.lastActivityAt == lastActivityAt)&&(identical(other.messageCount, messageCount) || other.messageCount == messageCount)&&(identical(other.isAgeRestricted, isAgeRestricted) || other.isAgeRestricted == isAgeRestricted)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.slowModeSeconds, slowModeSeconds) || other.slowModeSeconds == slowModeSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,guildId,parentChannelId,name,description,createdAt,updatedAt,createdByUserId,const DeepCollectionEquality().hash(_tagIds),isPinned,isLocked,isArchived,autoArchiveAt,autoArchiveMinutes,lastActivityAt,messageCount,isAgeRestricted,isPrivate,slowModeSeconds]);

@override
String toString() {
  return 'ForumPostDto(id: $id, guildId: $guildId, parentChannelId: $parentChannelId, name: $name, description: $description, createdAt: $createdAt, updatedAt: $updatedAt, createdByUserId: $createdByUserId, tagIds: $tagIds, isPinned: $isPinned, isLocked: $isLocked, isArchived: $isArchived, autoArchiveAt: $autoArchiveAt, autoArchiveMinutes: $autoArchiveMinutes, lastActivityAt: $lastActivityAt, messageCount: $messageCount, isAgeRestricted: $isAgeRestricted, isPrivate: $isPrivate, slowModeSeconds: $slowModeSeconds)';
}


}

/// @nodoc
abstract mixin class _$ForumPostDtoCopyWith<$Res> implements $ForumPostDtoCopyWith<$Res> {
  factory _$ForumPostDtoCopyWith(_ForumPostDto value, $Res Function(_ForumPostDto) _then) = __$ForumPostDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String guildId, String? parentChannelId, String name, String? description, DateTime? createdAt, DateTime? updatedAt, String? createdByUserId, List<String> tagIds, bool isPinned, bool isLocked, bool isArchived, DateTime? autoArchiveAt, int? autoArchiveMinutes, DateTime? lastActivityAt, int messageCount, bool isAgeRestricted, bool isPrivate, int slowModeSeconds
});




}
/// @nodoc
class __$ForumPostDtoCopyWithImpl<$Res>
    implements _$ForumPostDtoCopyWith<$Res> {
  __$ForumPostDtoCopyWithImpl(this._self, this._then);

  final _ForumPostDto _self;
  final $Res Function(_ForumPostDto) _then;

/// Create a copy of ForumPostDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? guildId = null,Object? parentChannelId = freezed,Object? name = null,Object? description = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? createdByUserId = freezed,Object? tagIds = null,Object? isPinned = null,Object? isLocked = null,Object? isArchived = null,Object? autoArchiveAt = freezed,Object? autoArchiveMinutes = freezed,Object? lastActivityAt = freezed,Object? messageCount = null,Object? isAgeRestricted = null,Object? isPrivate = null,Object? slowModeSeconds = null,}) {
  return _then(_ForumPostDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,parentChannelId: freezed == parentChannelId ? _self.parentChannelId : parentChannelId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdByUserId: freezed == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String?,tagIds: null == tagIds ? _self._tagIds : tagIds // ignore: cast_nullable_to_non_nullable
as List<String>,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,isLocked: null == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,autoArchiveAt: freezed == autoArchiveAt ? _self.autoArchiveAt : autoArchiveAt // ignore: cast_nullable_to_non_nullable
as DateTime?,autoArchiveMinutes: freezed == autoArchiveMinutes ? _self.autoArchiveMinutes : autoArchiveMinutes // ignore: cast_nullable_to_non_nullable
as int?,lastActivityAt: freezed == lastActivityAt ? _self.lastActivityAt : lastActivityAt // ignore: cast_nullable_to_non_nullable
as DateTime?,messageCount: null == messageCount ? _self.messageCount : messageCount // ignore: cast_nullable_to_non_nullable
as int,isAgeRestricted: null == isAgeRestricted ? _self.isAgeRestricted : isAgeRestricted // ignore: cast_nullable_to_non_nullable
as bool,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,slowModeSeconds: null == slowModeSeconds ? _self.slowModeSeconds : slowModeSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ForumPostPageDto {

 List<ForumPostDto> get posts; String? get nextCursor;
/// Create a copy of ForumPostPageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ForumPostPageDtoCopyWith<ForumPostPageDto> get copyWith => _$ForumPostPageDtoCopyWithImpl<ForumPostPageDto>(this as ForumPostPageDto, _$identity);

  /// Serializes this ForumPostPageDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ForumPostPageDto&&const DeepCollectionEquality().equals(other.posts, posts)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(posts),nextCursor);

@override
String toString() {
  return 'ForumPostPageDto(posts: $posts, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class $ForumPostPageDtoCopyWith<$Res>  {
  factory $ForumPostPageDtoCopyWith(ForumPostPageDto value, $Res Function(ForumPostPageDto) _then) = _$ForumPostPageDtoCopyWithImpl;
@useResult
$Res call({
 List<ForumPostDto> posts, String? nextCursor
});




}
/// @nodoc
class _$ForumPostPageDtoCopyWithImpl<$Res>
    implements $ForumPostPageDtoCopyWith<$Res> {
  _$ForumPostPageDtoCopyWithImpl(this._self, this._then);

  final ForumPostPageDto _self;
  final $Res Function(ForumPostPageDto) _then;

/// Create a copy of ForumPostPageDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? posts = null,Object? nextCursor = freezed,}) {
  return _then(_self.copyWith(
posts: null == posts ? _self.posts : posts // ignore: cast_nullable_to_non_nullable
as List<ForumPostDto>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ForumPostPageDto].
extension ForumPostPageDtoPatterns on ForumPostPageDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ForumPostPageDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ForumPostPageDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ForumPostPageDto value)  $default,){
final _that = this;
switch (_that) {
case _ForumPostPageDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ForumPostPageDto value)?  $default,){
final _that = this;
switch (_that) {
case _ForumPostPageDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ForumPostDto> posts,  String? nextCursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ForumPostPageDto() when $default != null:
return $default(_that.posts,_that.nextCursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ForumPostDto> posts,  String? nextCursor)  $default,) {final _that = this;
switch (_that) {
case _ForumPostPageDto():
return $default(_that.posts,_that.nextCursor);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ForumPostDto> posts,  String? nextCursor)?  $default,) {final _that = this;
switch (_that) {
case _ForumPostPageDto() when $default != null:
return $default(_that.posts,_that.nextCursor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ForumPostPageDto implements ForumPostPageDto {
  const _ForumPostPageDto({final  List<ForumPostDto> posts = const <ForumPostDto>[], this.nextCursor}): _posts = posts;
  factory _ForumPostPageDto.fromJson(Map<String, dynamic> json) => _$ForumPostPageDtoFromJson(json);

 final  List<ForumPostDto> _posts;
@override@JsonKey() List<ForumPostDto> get posts {
  if (_posts is EqualUnmodifiableListView) return _posts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_posts);
}

@override final  String? nextCursor;

/// Create a copy of ForumPostPageDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ForumPostPageDtoCopyWith<_ForumPostPageDto> get copyWith => __$ForumPostPageDtoCopyWithImpl<_ForumPostPageDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ForumPostPageDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ForumPostPageDto&&const DeepCollectionEquality().equals(other._posts, _posts)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_posts),nextCursor);

@override
String toString() {
  return 'ForumPostPageDto(posts: $posts, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class _$ForumPostPageDtoCopyWith<$Res> implements $ForumPostPageDtoCopyWith<$Res> {
  factory _$ForumPostPageDtoCopyWith(_ForumPostPageDto value, $Res Function(_ForumPostPageDto) _then) = __$ForumPostPageDtoCopyWithImpl;
@override @useResult
$Res call({
 List<ForumPostDto> posts, String? nextCursor
});




}
/// @nodoc
class __$ForumPostPageDtoCopyWithImpl<$Res>
    implements _$ForumPostPageDtoCopyWith<$Res> {
  __$ForumPostPageDtoCopyWithImpl(this._self, this._then);

  final _ForumPostPageDto _self;
  final $Res Function(_ForumPostPageDto) _then;

/// Create a copy of ForumPostPageDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? posts = null,Object? nextCursor = freezed,}) {
  return _then(_ForumPostPageDto(
posts: null == posts ? _self._posts : posts // ignore: cast_nullable_to_non_nullable
as List<ForumPostDto>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
