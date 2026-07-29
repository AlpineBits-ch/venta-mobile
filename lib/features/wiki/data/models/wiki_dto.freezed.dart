// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wiki_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WikiDto {

 String get id; String get guildId; List<WikiCategoryDto> get categories; List<WikiPageSummaryDto> get pages;
/// Create a copy of WikiDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WikiDtoCopyWith<WikiDto> get copyWith => _$WikiDtoCopyWithImpl<WikiDto>(this as WikiDto, _$identity);

  /// Serializes this WikiDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WikiDto&&(identical(other.id, id) || other.id == id)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&const DeepCollectionEquality().equals(other.categories, categories)&&const DeepCollectionEquality().equals(other.pages, pages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,guildId,const DeepCollectionEquality().hash(categories),const DeepCollectionEquality().hash(pages));

@override
String toString() {
  return 'WikiDto(id: $id, guildId: $guildId, categories: $categories, pages: $pages)';
}


}

/// @nodoc
abstract mixin class $WikiDtoCopyWith<$Res>  {
  factory $WikiDtoCopyWith(WikiDto value, $Res Function(WikiDto) _then) = _$WikiDtoCopyWithImpl;
@useResult
$Res call({
 String id, String guildId, List<WikiCategoryDto> categories, List<WikiPageSummaryDto> pages
});




}
/// @nodoc
class _$WikiDtoCopyWithImpl<$Res>
    implements $WikiDtoCopyWith<$Res> {
  _$WikiDtoCopyWithImpl(this._self, this._then);

  final WikiDto _self;
  final $Res Function(WikiDto) _then;

/// Create a copy of WikiDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? guildId = null,Object? categories = null,Object? pages = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<WikiCategoryDto>,pages: null == pages ? _self.pages : pages // ignore: cast_nullable_to_non_nullable
as List<WikiPageSummaryDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [WikiDto].
extension WikiDtoPatterns on WikiDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WikiDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WikiDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WikiDto value)  $default,){
final _that = this;
switch (_that) {
case _WikiDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WikiDto value)?  $default,){
final _that = this;
switch (_that) {
case _WikiDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String guildId,  List<WikiCategoryDto> categories,  List<WikiPageSummaryDto> pages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WikiDto() when $default != null:
return $default(_that.id,_that.guildId,_that.categories,_that.pages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String guildId,  List<WikiCategoryDto> categories,  List<WikiPageSummaryDto> pages)  $default,) {final _that = this;
switch (_that) {
case _WikiDto():
return $default(_that.id,_that.guildId,_that.categories,_that.pages);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String guildId,  List<WikiCategoryDto> categories,  List<WikiPageSummaryDto> pages)?  $default,) {final _that = this;
switch (_that) {
case _WikiDto() when $default != null:
return $default(_that.id,_that.guildId,_that.categories,_that.pages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WikiDto implements WikiDto {
  const _WikiDto({required this.id, required this.guildId, final  List<WikiCategoryDto> categories = const <WikiCategoryDto>[], final  List<WikiPageSummaryDto> pages = const <WikiPageSummaryDto>[]}): _categories = categories,_pages = pages;
  factory _WikiDto.fromJson(Map<String, dynamic> json) => _$WikiDtoFromJson(json);

@override final  String id;
@override final  String guildId;
 final  List<WikiCategoryDto> _categories;
@override@JsonKey() List<WikiCategoryDto> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

 final  List<WikiPageSummaryDto> _pages;
@override@JsonKey() List<WikiPageSummaryDto> get pages {
  if (_pages is EqualUnmodifiableListView) return _pages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pages);
}


/// Create a copy of WikiDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WikiDtoCopyWith<_WikiDto> get copyWith => __$WikiDtoCopyWithImpl<_WikiDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WikiDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WikiDto&&(identical(other.id, id) || other.id == id)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&const DeepCollectionEquality().equals(other._categories, _categories)&&const DeepCollectionEquality().equals(other._pages, _pages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,guildId,const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_pages));

@override
String toString() {
  return 'WikiDto(id: $id, guildId: $guildId, categories: $categories, pages: $pages)';
}


}

/// @nodoc
abstract mixin class _$WikiDtoCopyWith<$Res> implements $WikiDtoCopyWith<$Res> {
  factory _$WikiDtoCopyWith(_WikiDto value, $Res Function(_WikiDto) _then) = __$WikiDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String guildId, List<WikiCategoryDto> categories, List<WikiPageSummaryDto> pages
});




}
/// @nodoc
class __$WikiDtoCopyWithImpl<$Res>
    implements _$WikiDtoCopyWith<$Res> {
  __$WikiDtoCopyWithImpl(this._self, this._then);

  final _WikiDto _self;
  final $Res Function(_WikiDto) _then;

/// Create a copy of WikiDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? guildId = null,Object? categories = null,Object? pages = null,}) {
  return _then(_WikiDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<WikiCategoryDto>,pages: null == pages ? _self._pages : pages // ignore: cast_nullable_to_non_nullable
as List<WikiPageSummaryDto>,
  ));
}


}

// dart format on
