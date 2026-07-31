// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wiki_revision_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WikiRevisionDto {

 String get id; String get pageId; String get content; String get editorId; DateTime? get createdAt; int get revisionNumber; String? get summary;
/// Create a copy of WikiRevisionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WikiRevisionDtoCopyWith<WikiRevisionDto> get copyWith => _$WikiRevisionDtoCopyWithImpl<WikiRevisionDto>(this as WikiRevisionDto, _$identity);

  /// Serializes this WikiRevisionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WikiRevisionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.pageId, pageId) || other.pageId == pageId)&&(identical(other.content, content) || other.content == content)&&(identical(other.editorId, editorId) || other.editorId == editorId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.revisionNumber, revisionNumber) || other.revisionNumber == revisionNumber)&&(identical(other.summary, summary) || other.summary == summary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,pageId,content,editorId,createdAt,revisionNumber,summary);

@override
String toString() {
  return 'WikiRevisionDto(id: $id, pageId: $pageId, content: $content, editorId: $editorId, createdAt: $createdAt, revisionNumber: $revisionNumber, summary: $summary)';
}


}

/// @nodoc
abstract mixin class $WikiRevisionDtoCopyWith<$Res>  {
  factory $WikiRevisionDtoCopyWith(WikiRevisionDto value, $Res Function(WikiRevisionDto) _then) = _$WikiRevisionDtoCopyWithImpl;
@useResult
$Res call({
 String id, String pageId, String content, String editorId, DateTime? createdAt, int revisionNumber, String? summary
});




}
/// @nodoc
class _$WikiRevisionDtoCopyWithImpl<$Res>
    implements $WikiRevisionDtoCopyWith<$Res> {
  _$WikiRevisionDtoCopyWithImpl(this._self, this._then);

  final WikiRevisionDto _self;
  final $Res Function(WikiRevisionDto) _then;

/// Create a copy of WikiRevisionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? pageId = null,Object? content = null,Object? editorId = null,Object? createdAt = freezed,Object? revisionNumber = null,Object? summary = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,pageId: null == pageId ? _self.pageId : pageId // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,editorId: null == editorId ? _self.editorId : editorId // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,revisionNumber: null == revisionNumber ? _self.revisionNumber : revisionNumber // ignore: cast_nullable_to_non_nullable
as int,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WikiRevisionDto].
extension WikiRevisionDtoPatterns on WikiRevisionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WikiRevisionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WikiRevisionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WikiRevisionDto value)  $default,){
final _that = this;
switch (_that) {
case _WikiRevisionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WikiRevisionDto value)?  $default,){
final _that = this;
switch (_that) {
case _WikiRevisionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String pageId,  String content,  String editorId,  DateTime? createdAt,  int revisionNumber,  String? summary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WikiRevisionDto() when $default != null:
return $default(_that.id,_that.pageId,_that.content,_that.editorId,_that.createdAt,_that.revisionNumber,_that.summary);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String pageId,  String content,  String editorId,  DateTime? createdAt,  int revisionNumber,  String? summary)  $default,) {final _that = this;
switch (_that) {
case _WikiRevisionDto():
return $default(_that.id,_that.pageId,_that.content,_that.editorId,_that.createdAt,_that.revisionNumber,_that.summary);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String pageId,  String content,  String editorId,  DateTime? createdAt,  int revisionNumber,  String? summary)?  $default,) {final _that = this;
switch (_that) {
case _WikiRevisionDto() when $default != null:
return $default(_that.id,_that.pageId,_that.content,_that.editorId,_that.createdAt,_that.revisionNumber,_that.summary);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _WikiRevisionDto implements WikiRevisionDto {
  const _WikiRevisionDto({required this.id, required this.pageId, required this.content, required this.editorId, this.createdAt, this.revisionNumber = 0, this.summary});
  factory _WikiRevisionDto.fromJson(Map<String, dynamic> json) => _$WikiRevisionDtoFromJson(json);

@override final  String id;
@override final  String pageId;
@override final  String content;
@override final  String editorId;
@override final  DateTime? createdAt;
@override@JsonKey() final  int revisionNumber;
@override final  String? summary;

/// Create a copy of WikiRevisionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WikiRevisionDtoCopyWith<_WikiRevisionDto> get copyWith => __$WikiRevisionDtoCopyWithImpl<_WikiRevisionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WikiRevisionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WikiRevisionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.pageId, pageId) || other.pageId == pageId)&&(identical(other.content, content) || other.content == content)&&(identical(other.editorId, editorId) || other.editorId == editorId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.revisionNumber, revisionNumber) || other.revisionNumber == revisionNumber)&&(identical(other.summary, summary) || other.summary == summary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,pageId,content,editorId,createdAt,revisionNumber,summary);

@override
String toString() {
  return 'WikiRevisionDto(id: $id, pageId: $pageId, content: $content, editorId: $editorId, createdAt: $createdAt, revisionNumber: $revisionNumber, summary: $summary)';
}


}

/// @nodoc
abstract mixin class _$WikiRevisionDtoCopyWith<$Res> implements $WikiRevisionDtoCopyWith<$Res> {
  factory _$WikiRevisionDtoCopyWith(_WikiRevisionDto value, $Res Function(_WikiRevisionDto) _then) = __$WikiRevisionDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String pageId, String content, String editorId, DateTime? createdAt, int revisionNumber, String? summary
});




}
/// @nodoc
class __$WikiRevisionDtoCopyWithImpl<$Res>
    implements _$WikiRevisionDtoCopyWith<$Res> {
  __$WikiRevisionDtoCopyWithImpl(this._self, this._then);

  final _WikiRevisionDto _self;
  final $Res Function(_WikiRevisionDto) _then;

/// Create a copy of WikiRevisionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? pageId = null,Object? content = null,Object? editorId = null,Object? createdAt = freezed,Object? revisionNumber = null,Object? summary = freezed,}) {
  return _then(_WikiRevisionDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,pageId: null == pageId ? _self.pageId : pageId // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,editorId: null == editorId ? _self.editorId : editorId // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,revisionNumber: null == revisionNumber ? _self.revisionNumber : revisionNumber // ignore: cast_nullable_to_non_nullable
as int,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
