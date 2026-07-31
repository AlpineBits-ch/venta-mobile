// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wiki_page_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WikiPageDto {

 String get id; String get guildId; String get title; String get slug; String get authorId; String? get lastEditorId; DateTime? get createdAt; DateTime? get updatedAt; String? get parentPageId; String? get categoryId; WikiVisibility get visibility; List<String> get tags; bool get isPinned; int get revisionCount; String get content;
/// Create a copy of WikiPageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WikiPageDtoCopyWith<WikiPageDto> get copyWith => _$WikiPageDtoCopyWithImpl<WikiPageDto>(this as WikiPageDto, _$identity);

  /// Serializes this WikiPageDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WikiPageDto&&(identical(other.id, id) || other.id == id)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.title, title) || other.title == title)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.lastEditorId, lastEditorId) || other.lastEditorId == lastEditorId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.parentPageId, parentPageId) || other.parentPageId == parentPageId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.revisionCount, revisionCount) || other.revisionCount == revisionCount)&&(identical(other.content, content) || other.content == content));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,guildId,title,slug,authorId,lastEditorId,createdAt,updatedAt,parentPageId,categoryId,visibility,const DeepCollectionEquality().hash(tags),isPinned,revisionCount,content);

@override
String toString() {
  return 'WikiPageDto(id: $id, guildId: $guildId, title: $title, slug: $slug, authorId: $authorId, lastEditorId: $lastEditorId, createdAt: $createdAt, updatedAt: $updatedAt, parentPageId: $parentPageId, categoryId: $categoryId, visibility: $visibility, tags: $tags, isPinned: $isPinned, revisionCount: $revisionCount, content: $content)';
}


}

/// @nodoc
abstract mixin class $WikiPageDtoCopyWith<$Res>  {
  factory $WikiPageDtoCopyWith(WikiPageDto value, $Res Function(WikiPageDto) _then) = _$WikiPageDtoCopyWithImpl;
@useResult
$Res call({
 String id, String guildId, String title, String slug, String authorId, String? lastEditorId, DateTime? createdAt, DateTime? updatedAt, String? parentPageId, String? categoryId, WikiVisibility visibility, List<String> tags, bool isPinned, int revisionCount, String content
});




}
/// @nodoc
class _$WikiPageDtoCopyWithImpl<$Res>
    implements $WikiPageDtoCopyWith<$Res> {
  _$WikiPageDtoCopyWithImpl(this._self, this._then);

  final WikiPageDto _self;
  final $Res Function(WikiPageDto) _then;

/// Create a copy of WikiPageDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? guildId = null,Object? title = null,Object? slug = null,Object? authorId = null,Object? lastEditorId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? parentPageId = freezed,Object? categoryId = freezed,Object? visibility = null,Object? tags = null,Object? isPinned = null,Object? revisionCount = null,Object? content = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,lastEditorId: freezed == lastEditorId ? _self.lastEditorId : lastEditorId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,parentPageId: freezed == parentPageId ? _self.parentPageId : parentPageId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as WikiVisibility,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,revisionCount: null == revisionCount ? _self.revisionCount : revisionCount // ignore: cast_nullable_to_non_nullable
as int,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WikiPageDto].
extension WikiPageDtoPatterns on WikiPageDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WikiPageDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WikiPageDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WikiPageDto value)  $default,){
final _that = this;
switch (_that) {
case _WikiPageDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WikiPageDto value)?  $default,){
final _that = this;
switch (_that) {
case _WikiPageDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String guildId,  String title,  String slug,  String authorId,  String? lastEditorId,  DateTime? createdAt,  DateTime? updatedAt,  String? parentPageId,  String? categoryId,  WikiVisibility visibility,  List<String> tags,  bool isPinned,  int revisionCount,  String content)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WikiPageDto() when $default != null:
return $default(_that.id,_that.guildId,_that.title,_that.slug,_that.authorId,_that.lastEditorId,_that.createdAt,_that.updatedAt,_that.parentPageId,_that.categoryId,_that.visibility,_that.tags,_that.isPinned,_that.revisionCount,_that.content);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String guildId,  String title,  String slug,  String authorId,  String? lastEditorId,  DateTime? createdAt,  DateTime? updatedAt,  String? parentPageId,  String? categoryId,  WikiVisibility visibility,  List<String> tags,  bool isPinned,  int revisionCount,  String content)  $default,) {final _that = this;
switch (_that) {
case _WikiPageDto():
return $default(_that.id,_that.guildId,_that.title,_that.slug,_that.authorId,_that.lastEditorId,_that.createdAt,_that.updatedAt,_that.parentPageId,_that.categoryId,_that.visibility,_that.tags,_that.isPinned,_that.revisionCount,_that.content);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String guildId,  String title,  String slug,  String authorId,  String? lastEditorId,  DateTime? createdAt,  DateTime? updatedAt,  String? parentPageId,  String? categoryId,  WikiVisibility visibility,  List<String> tags,  bool isPinned,  int revisionCount,  String content)?  $default,) {final _that = this;
switch (_that) {
case _WikiPageDto() when $default != null:
return $default(_that.id,_that.guildId,_that.title,_that.slug,_that.authorId,_that.lastEditorId,_that.createdAt,_that.updatedAt,_that.parentPageId,_that.categoryId,_that.visibility,_that.tags,_that.isPinned,_that.revisionCount,_that.content);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _WikiPageDto implements WikiPageDto {
  const _WikiPageDto({required this.id, required this.guildId, required this.title, required this.slug, required this.authorId, this.lastEditorId, this.createdAt, this.updatedAt, this.parentPageId, this.categoryId, this.visibility = WikiVisibility.private, final  List<String> tags = const <String>[], this.isPinned = false, this.revisionCount = 0, this.content = ''}): _tags = tags;
  factory _WikiPageDto.fromJson(Map<String, dynamic> json) => _$WikiPageDtoFromJson(json);

@override final  String id;
@override final  String guildId;
@override final  String title;
@override final  String slug;
@override final  String authorId;
@override final  String? lastEditorId;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
@override final  String? parentPageId;
@override final  String? categoryId;
@override@JsonKey() final  WikiVisibility visibility;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey() final  bool isPinned;
@override@JsonKey() final  int revisionCount;
@override@JsonKey() final  String content;

/// Create a copy of WikiPageDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WikiPageDtoCopyWith<_WikiPageDto> get copyWith => __$WikiPageDtoCopyWithImpl<_WikiPageDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WikiPageDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WikiPageDto&&(identical(other.id, id) || other.id == id)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.title, title) || other.title == title)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.lastEditorId, lastEditorId) || other.lastEditorId == lastEditorId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.parentPageId, parentPageId) || other.parentPageId == parentPageId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.revisionCount, revisionCount) || other.revisionCount == revisionCount)&&(identical(other.content, content) || other.content == content));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,guildId,title,slug,authorId,lastEditorId,createdAt,updatedAt,parentPageId,categoryId,visibility,const DeepCollectionEquality().hash(_tags),isPinned,revisionCount,content);

@override
String toString() {
  return 'WikiPageDto(id: $id, guildId: $guildId, title: $title, slug: $slug, authorId: $authorId, lastEditorId: $lastEditorId, createdAt: $createdAt, updatedAt: $updatedAt, parentPageId: $parentPageId, categoryId: $categoryId, visibility: $visibility, tags: $tags, isPinned: $isPinned, revisionCount: $revisionCount, content: $content)';
}


}

/// @nodoc
abstract mixin class _$WikiPageDtoCopyWith<$Res> implements $WikiPageDtoCopyWith<$Res> {
  factory _$WikiPageDtoCopyWith(_WikiPageDto value, $Res Function(_WikiPageDto) _then) = __$WikiPageDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String guildId, String title, String slug, String authorId, String? lastEditorId, DateTime? createdAt, DateTime? updatedAt, String? parentPageId, String? categoryId, WikiVisibility visibility, List<String> tags, bool isPinned, int revisionCount, String content
});




}
/// @nodoc
class __$WikiPageDtoCopyWithImpl<$Res>
    implements _$WikiPageDtoCopyWith<$Res> {
  __$WikiPageDtoCopyWithImpl(this._self, this._then);

  final _WikiPageDto _self;
  final $Res Function(_WikiPageDto) _then;

/// Create a copy of WikiPageDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? guildId = null,Object? title = null,Object? slug = null,Object? authorId = null,Object? lastEditorId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? parentPageId = freezed,Object? categoryId = freezed,Object? visibility = null,Object? tags = null,Object? isPinned = null,Object? revisionCount = null,Object? content = null,}) {
  return _then(_WikiPageDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,lastEditorId: freezed == lastEditorId ? _self.lastEditorId : lastEditorId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,parentPageId: freezed == parentPageId ? _self.parentPageId : parentPageId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as WikiVisibility,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,revisionCount: null == revisionCount ? _self.revisionCount : revisionCount // ignore: cast_nullable_to_non_nullable
as int,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
