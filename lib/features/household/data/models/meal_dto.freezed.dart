// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meal_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecipeIngredientDto {

 int get position;/// As written on the recipe - "2 onions, chopped".
 String get text;/// What the pantry and the shopping list match on, when the free text is
/// too wordy to match by itself.
 String? get matchName;/// Garnish. Left out of the shopping list unless asked for, and never
/// counted against whether a recipe is cookable.
 bool get isOptional;
/// Create a copy of RecipeIngredientDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecipeIngredientDtoCopyWith<RecipeIngredientDto> get copyWith => _$RecipeIngredientDtoCopyWithImpl<RecipeIngredientDto>(this as RecipeIngredientDto, _$identity);

  /// Serializes this RecipeIngredientDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecipeIngredientDto&&(identical(other.position, position) || other.position == position)&&(identical(other.text, text) || other.text == text)&&(identical(other.matchName, matchName) || other.matchName == matchName)&&(identical(other.isOptional, isOptional) || other.isOptional == isOptional));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,position,text,matchName,isOptional);

@override
String toString() {
  return 'RecipeIngredientDto(position: $position, text: $text, matchName: $matchName, isOptional: $isOptional)';
}


}

/// @nodoc
abstract mixin class $RecipeIngredientDtoCopyWith<$Res>  {
  factory $RecipeIngredientDtoCopyWith(RecipeIngredientDto value, $Res Function(RecipeIngredientDto) _then) = _$RecipeIngredientDtoCopyWithImpl;
@useResult
$Res call({
 int position, String text, String? matchName, bool isOptional
});




}
/// @nodoc
class _$RecipeIngredientDtoCopyWithImpl<$Res>
    implements $RecipeIngredientDtoCopyWith<$Res> {
  _$RecipeIngredientDtoCopyWithImpl(this._self, this._then);

  final RecipeIngredientDto _self;
  final $Res Function(RecipeIngredientDto) _then;

/// Create a copy of RecipeIngredientDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? position = null,Object? text = null,Object? matchName = freezed,Object? isOptional = null,}) {
  return _then(_self.copyWith(
position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,matchName: freezed == matchName ? _self.matchName : matchName // ignore: cast_nullable_to_non_nullable
as String?,isOptional: null == isOptional ? _self.isOptional : isOptional // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RecipeIngredientDto].
extension RecipeIngredientDtoPatterns on RecipeIngredientDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecipeIngredientDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecipeIngredientDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecipeIngredientDto value)  $default,){
final _that = this;
switch (_that) {
case _RecipeIngredientDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecipeIngredientDto value)?  $default,){
final _that = this;
switch (_that) {
case _RecipeIngredientDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int position,  String text,  String? matchName,  bool isOptional)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecipeIngredientDto() when $default != null:
return $default(_that.position,_that.text,_that.matchName,_that.isOptional);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int position,  String text,  String? matchName,  bool isOptional)  $default,) {final _that = this;
switch (_that) {
case _RecipeIngredientDto():
return $default(_that.position,_that.text,_that.matchName,_that.isOptional);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int position,  String text,  String? matchName,  bool isOptional)?  $default,) {final _that = this;
switch (_that) {
case _RecipeIngredientDto() when $default != null:
return $default(_that.position,_that.text,_that.matchName,_that.isOptional);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecipeIngredientDto implements RecipeIngredientDto {
  const _RecipeIngredientDto({this.position = 0, this.text = '', this.matchName, this.isOptional = false});
  factory _RecipeIngredientDto.fromJson(Map<String, dynamic> json) => _$RecipeIngredientDtoFromJson(json);

@override@JsonKey() final  int position;
/// As written on the recipe - "2 onions, chopped".
@override@JsonKey() final  String text;
/// What the pantry and the shopping list match on, when the free text is
/// too wordy to match by itself.
@override final  String? matchName;
/// Garnish. Left out of the shopping list unless asked for, and never
/// counted against whether a recipe is cookable.
@override@JsonKey() final  bool isOptional;

/// Create a copy of RecipeIngredientDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecipeIngredientDtoCopyWith<_RecipeIngredientDto> get copyWith => __$RecipeIngredientDtoCopyWithImpl<_RecipeIngredientDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecipeIngredientDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecipeIngredientDto&&(identical(other.position, position) || other.position == position)&&(identical(other.text, text) || other.text == text)&&(identical(other.matchName, matchName) || other.matchName == matchName)&&(identical(other.isOptional, isOptional) || other.isOptional == isOptional));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,position,text,matchName,isOptional);

@override
String toString() {
  return 'RecipeIngredientDto(position: $position, text: $text, matchName: $matchName, isOptional: $isOptional)';
}


}

/// @nodoc
abstract mixin class _$RecipeIngredientDtoCopyWith<$Res> implements $RecipeIngredientDtoCopyWith<$Res> {
  factory _$RecipeIngredientDtoCopyWith(_RecipeIngredientDto value, $Res Function(_RecipeIngredientDto) _then) = __$RecipeIngredientDtoCopyWithImpl;
@override @useResult
$Res call({
 int position, String text, String? matchName, bool isOptional
});




}
/// @nodoc
class __$RecipeIngredientDtoCopyWithImpl<$Res>
    implements _$RecipeIngredientDtoCopyWith<$Res> {
  __$RecipeIngredientDtoCopyWithImpl(this._self, this._then);

  final _RecipeIngredientDto _self;
  final $Res Function(_RecipeIngredientDto) _then;

/// Create a copy of RecipeIngredientDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? position = null,Object? text = null,Object? matchName = freezed,Object? isOptional = null,}) {
  return _then(_RecipeIngredientDto(
position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,matchName: freezed == matchName ? _self.matchName : matchName // ignore: cast_nullable_to_non_nullable
as String?,isOptional: null == isOptional ? _self.isOptional : isOptional // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$RecipeDto {

 String get id; String get channelId; String get title; String? get description; int get servings; int? get prepMinutes; String? get sourceUrl; String get createdByUserId; List<RecipeIngredientDto> get ingredients; DateTime? get createdAt;
/// Create a copy of RecipeDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecipeDtoCopyWith<RecipeDto> get copyWith => _$RecipeDtoCopyWithImpl<RecipeDto>(this as RecipeDto, _$identity);

  /// Serializes this RecipeDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecipeDto&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.servings, servings) || other.servings == servings)&&(identical(other.prepMinutes, prepMinutes) || other.prepMinutes == prepMinutes)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId)&&const DeepCollectionEquality().equals(other.ingredients, ingredients)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,title,description,servings,prepMinutes,sourceUrl,createdByUserId,const DeepCollectionEquality().hash(ingredients),createdAt);

@override
String toString() {
  return 'RecipeDto(id: $id, channelId: $channelId, title: $title, description: $description, servings: $servings, prepMinutes: $prepMinutes, sourceUrl: $sourceUrl, createdByUserId: $createdByUserId, ingredients: $ingredients, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $RecipeDtoCopyWith<$Res>  {
  factory $RecipeDtoCopyWith(RecipeDto value, $Res Function(RecipeDto) _then) = _$RecipeDtoCopyWithImpl;
@useResult
$Res call({
 String id, String channelId, String title, String? description, int servings, int? prepMinutes, String? sourceUrl, String createdByUserId, List<RecipeIngredientDto> ingredients, DateTime? createdAt
});




}
/// @nodoc
class _$RecipeDtoCopyWithImpl<$Res>
    implements $RecipeDtoCopyWith<$Res> {
  _$RecipeDtoCopyWithImpl(this._self, this._then);

  final RecipeDto _self;
  final $Res Function(RecipeDto) _then;

/// Create a copy of RecipeDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? channelId = null,Object? title = null,Object? description = freezed,Object? servings = null,Object? prepMinutes = freezed,Object? sourceUrl = freezed,Object? createdByUserId = null,Object? ingredients = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,servings: null == servings ? _self.servings : servings // ignore: cast_nullable_to_non_nullable
as int,prepMinutes: freezed == prepMinutes ? _self.prepMinutes : prepMinutes // ignore: cast_nullable_to_non_nullable
as int?,sourceUrl: freezed == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String?,createdByUserId: null == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String,ingredients: null == ingredients ? _self.ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as List<RecipeIngredientDto>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecipeDto].
extension RecipeDtoPatterns on RecipeDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecipeDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecipeDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecipeDto value)  $default,){
final _that = this;
switch (_that) {
case _RecipeDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecipeDto value)?  $default,){
final _that = this;
switch (_that) {
case _RecipeDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String channelId,  String title,  String? description,  int servings,  int? prepMinutes,  String? sourceUrl,  String createdByUserId,  List<RecipeIngredientDto> ingredients,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecipeDto() when $default != null:
return $default(_that.id,_that.channelId,_that.title,_that.description,_that.servings,_that.prepMinutes,_that.sourceUrl,_that.createdByUserId,_that.ingredients,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String channelId,  String title,  String? description,  int servings,  int? prepMinutes,  String? sourceUrl,  String createdByUserId,  List<RecipeIngredientDto> ingredients,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _RecipeDto():
return $default(_that.id,_that.channelId,_that.title,_that.description,_that.servings,_that.prepMinutes,_that.sourceUrl,_that.createdByUserId,_that.ingredients,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String channelId,  String title,  String? description,  int servings,  int? prepMinutes,  String? sourceUrl,  String createdByUserId,  List<RecipeIngredientDto> ingredients,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _RecipeDto() when $default != null:
return $default(_that.id,_that.channelId,_that.title,_that.description,_that.servings,_that.prepMinutes,_that.sourceUrl,_that.createdByUserId,_that.ingredients,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _RecipeDto implements RecipeDto {
  const _RecipeDto({required this.id, required this.channelId, this.title = '', this.description, this.servings = 2, this.prepMinutes, this.sourceUrl, this.createdByUserId = '', final  List<RecipeIngredientDto> ingredients = const <RecipeIngredientDto>[], this.createdAt}): _ingredients = ingredients;
  factory _RecipeDto.fromJson(Map<String, dynamic> json) => _$RecipeDtoFromJson(json);

@override final  String id;
@override final  String channelId;
@override@JsonKey() final  String title;
@override final  String? description;
@override@JsonKey() final  int servings;
@override final  int? prepMinutes;
@override final  String? sourceUrl;
@override@JsonKey() final  String createdByUserId;
 final  List<RecipeIngredientDto> _ingredients;
@override@JsonKey() List<RecipeIngredientDto> get ingredients {
  if (_ingredients is EqualUnmodifiableListView) return _ingredients;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ingredients);
}

@override final  DateTime? createdAt;

/// Create a copy of RecipeDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecipeDtoCopyWith<_RecipeDto> get copyWith => __$RecipeDtoCopyWithImpl<_RecipeDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecipeDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecipeDto&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.servings, servings) || other.servings == servings)&&(identical(other.prepMinutes, prepMinutes) || other.prepMinutes == prepMinutes)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId)&&const DeepCollectionEquality().equals(other._ingredients, _ingredients)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,title,description,servings,prepMinutes,sourceUrl,createdByUserId,const DeepCollectionEquality().hash(_ingredients),createdAt);

@override
String toString() {
  return 'RecipeDto(id: $id, channelId: $channelId, title: $title, description: $description, servings: $servings, prepMinutes: $prepMinutes, sourceUrl: $sourceUrl, createdByUserId: $createdByUserId, ingredients: $ingredients, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$RecipeDtoCopyWith<$Res> implements $RecipeDtoCopyWith<$Res> {
  factory _$RecipeDtoCopyWith(_RecipeDto value, $Res Function(_RecipeDto) _then) = __$RecipeDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String channelId, String title, String? description, int servings, int? prepMinutes, String? sourceUrl, String createdByUserId, List<RecipeIngredientDto> ingredients, DateTime? createdAt
});




}
/// @nodoc
class __$RecipeDtoCopyWithImpl<$Res>
    implements _$RecipeDtoCopyWith<$Res> {
  __$RecipeDtoCopyWithImpl(this._self, this._then);

  final _RecipeDto _self;
  final $Res Function(_RecipeDto) _then;

/// Create a copy of RecipeDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? channelId = null,Object? title = null,Object? description = freezed,Object? servings = null,Object? prepMinutes = freezed,Object? sourceUrl = freezed,Object? createdByUserId = null,Object? ingredients = null,Object? createdAt = freezed,}) {
  return _then(_RecipeDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,servings: null == servings ? _self.servings : servings // ignore: cast_nullable_to_non_nullable
as int,prepMinutes: freezed == prepMinutes ? _self.prepMinutes : prepMinutes // ignore: cast_nullable_to_non_nullable
as int?,sourceUrl: freezed == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String?,createdByUserId: null == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String,ingredients: null == ingredients ? _self._ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as List<RecipeIngredientDto>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$RecipePageDto {

 List<RecipeDto> get items; String? get nextCursor;
/// Create a copy of RecipePageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecipePageDtoCopyWith<RecipePageDto> get copyWith => _$RecipePageDtoCopyWithImpl<RecipePageDto>(this as RecipePageDto, _$identity);

  /// Serializes this RecipePageDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecipePageDto&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),nextCursor);

@override
String toString() {
  return 'RecipePageDto(items: $items, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class $RecipePageDtoCopyWith<$Res>  {
  factory $RecipePageDtoCopyWith(RecipePageDto value, $Res Function(RecipePageDto) _then) = _$RecipePageDtoCopyWithImpl;
@useResult
$Res call({
 List<RecipeDto> items, String? nextCursor
});




}
/// @nodoc
class _$RecipePageDtoCopyWithImpl<$Res>
    implements $RecipePageDtoCopyWith<$Res> {
  _$RecipePageDtoCopyWithImpl(this._self, this._then);

  final RecipePageDto _self;
  final $Res Function(RecipePageDto) _then;

/// Create a copy of RecipePageDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? nextCursor = freezed,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<RecipeDto>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecipePageDto].
extension RecipePageDtoPatterns on RecipePageDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecipePageDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecipePageDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecipePageDto value)  $default,){
final _that = this;
switch (_that) {
case _RecipePageDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecipePageDto value)?  $default,){
final _that = this;
switch (_that) {
case _RecipePageDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<RecipeDto> items,  String? nextCursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecipePageDto() when $default != null:
return $default(_that.items,_that.nextCursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<RecipeDto> items,  String? nextCursor)  $default,) {final _that = this;
switch (_that) {
case _RecipePageDto():
return $default(_that.items,_that.nextCursor);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<RecipeDto> items,  String? nextCursor)?  $default,) {final _that = this;
switch (_that) {
case _RecipePageDto() when $default != null:
return $default(_that.items,_that.nextCursor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecipePageDto implements RecipePageDto {
  const _RecipePageDto({final  List<RecipeDto> items = const <RecipeDto>[], this.nextCursor}): _items = items;
  factory _RecipePageDto.fromJson(Map<String, dynamic> json) => _$RecipePageDtoFromJson(json);

 final  List<RecipeDto> _items;
@override@JsonKey() List<RecipeDto> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? nextCursor;

/// Create a copy of RecipePageDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecipePageDtoCopyWith<_RecipePageDto> get copyWith => __$RecipePageDtoCopyWithImpl<_RecipePageDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecipePageDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecipePageDto&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),nextCursor);

@override
String toString() {
  return 'RecipePageDto(items: $items, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class _$RecipePageDtoCopyWith<$Res> implements $RecipePageDtoCopyWith<$Res> {
  factory _$RecipePageDtoCopyWith(_RecipePageDto value, $Res Function(_RecipePageDto) _then) = __$RecipePageDtoCopyWithImpl;
@override @useResult
$Res call({
 List<RecipeDto> items, String? nextCursor
});




}
/// @nodoc
class __$RecipePageDtoCopyWithImpl<$Res>
    implements _$RecipePageDtoCopyWith<$Res> {
  __$RecipePageDtoCopyWithImpl(this._self, this._then);

  final _RecipePageDto _self;
  final $Res Function(_RecipePageDto) _then;

/// Create a copy of RecipePageDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? nextCursor = freezed,}) {
  return _then(_RecipePageDto(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<RecipeDto>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$MealPlanEntryDto {

 String get id; String get channelId;/// A plain date, deliberately: Thursday dinner is Thursday dinner wherever
/// your phone is. See [PlainDate].
 PlainDate get date;@JsonKey(unknownEnumValue: MealSlot.dinner) MealSlot get slot; String? get recipeId;/// Denormalized so a week renders without fetching every recipe it names.
 String? get recipeTitle; String? get freeText; String? get cookUserId; int? get servings; int get position;
/// Create a copy of MealPlanEntryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MealPlanEntryDtoCopyWith<MealPlanEntryDto> get copyWith => _$MealPlanEntryDtoCopyWithImpl<MealPlanEntryDto>(this as MealPlanEntryDto, _$identity);

  /// Serializes this MealPlanEntryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MealPlanEntryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.date, date) || other.date == date)&&(identical(other.slot, slot) || other.slot == slot)&&(identical(other.recipeId, recipeId) || other.recipeId == recipeId)&&(identical(other.recipeTitle, recipeTitle) || other.recipeTitle == recipeTitle)&&(identical(other.freeText, freeText) || other.freeText == freeText)&&(identical(other.cookUserId, cookUserId) || other.cookUserId == cookUserId)&&(identical(other.servings, servings) || other.servings == servings)&&(identical(other.position, position) || other.position == position));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,date,slot,recipeId,recipeTitle,freeText,cookUserId,servings,position);

@override
String toString() {
  return 'MealPlanEntryDto(id: $id, channelId: $channelId, date: $date, slot: $slot, recipeId: $recipeId, recipeTitle: $recipeTitle, freeText: $freeText, cookUserId: $cookUserId, servings: $servings, position: $position)';
}


}

/// @nodoc
abstract mixin class $MealPlanEntryDtoCopyWith<$Res>  {
  factory $MealPlanEntryDtoCopyWith(MealPlanEntryDto value, $Res Function(MealPlanEntryDto) _then) = _$MealPlanEntryDtoCopyWithImpl;
@useResult
$Res call({
 String id, String channelId, PlainDate date,@JsonKey(unknownEnumValue: MealSlot.dinner) MealSlot slot, String? recipeId, String? recipeTitle, String? freeText, String? cookUserId, int? servings, int position
});




}
/// @nodoc
class _$MealPlanEntryDtoCopyWithImpl<$Res>
    implements $MealPlanEntryDtoCopyWith<$Res> {
  _$MealPlanEntryDtoCopyWithImpl(this._self, this._then);

  final MealPlanEntryDto _self;
  final $Res Function(MealPlanEntryDto) _then;

/// Create a copy of MealPlanEntryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? channelId = null,Object? date = null,Object? slot = null,Object? recipeId = freezed,Object? recipeTitle = freezed,Object? freeText = freezed,Object? cookUserId = freezed,Object? servings = freezed,Object? position = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as PlainDate,slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as MealSlot,recipeId: freezed == recipeId ? _self.recipeId : recipeId // ignore: cast_nullable_to_non_nullable
as String?,recipeTitle: freezed == recipeTitle ? _self.recipeTitle : recipeTitle // ignore: cast_nullable_to_non_nullable
as String?,freeText: freezed == freeText ? _self.freeText : freeText // ignore: cast_nullable_to_non_nullable
as String?,cookUserId: freezed == cookUserId ? _self.cookUserId : cookUserId // ignore: cast_nullable_to_non_nullable
as String?,servings: freezed == servings ? _self.servings : servings // ignore: cast_nullable_to_non_nullable
as int?,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MealPlanEntryDto].
extension MealPlanEntryDtoPatterns on MealPlanEntryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MealPlanEntryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MealPlanEntryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MealPlanEntryDto value)  $default,){
final _that = this;
switch (_that) {
case _MealPlanEntryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MealPlanEntryDto value)?  $default,){
final _that = this;
switch (_that) {
case _MealPlanEntryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String channelId,  PlainDate date, @JsonKey(unknownEnumValue: MealSlot.dinner)  MealSlot slot,  String? recipeId,  String? recipeTitle,  String? freeText,  String? cookUserId,  int? servings,  int position)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MealPlanEntryDto() when $default != null:
return $default(_that.id,_that.channelId,_that.date,_that.slot,_that.recipeId,_that.recipeTitle,_that.freeText,_that.cookUserId,_that.servings,_that.position);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String channelId,  PlainDate date, @JsonKey(unknownEnumValue: MealSlot.dinner)  MealSlot slot,  String? recipeId,  String? recipeTitle,  String? freeText,  String? cookUserId,  int? servings,  int position)  $default,) {final _that = this;
switch (_that) {
case _MealPlanEntryDto():
return $default(_that.id,_that.channelId,_that.date,_that.slot,_that.recipeId,_that.recipeTitle,_that.freeText,_that.cookUserId,_that.servings,_that.position);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String channelId,  PlainDate date, @JsonKey(unknownEnumValue: MealSlot.dinner)  MealSlot slot,  String? recipeId,  String? recipeTitle,  String? freeText,  String? cookUserId,  int? servings,  int position)?  $default,) {final _that = this;
switch (_that) {
case _MealPlanEntryDto() when $default != null:
return $default(_that.id,_that.channelId,_that.date,_that.slot,_that.recipeId,_that.recipeTitle,_that.freeText,_that.cookUserId,_that.servings,_that.position);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@PlainDateConverter()
class _MealPlanEntryDto implements MealPlanEntryDto {
  const _MealPlanEntryDto({required this.id, required this.channelId, required this.date, @JsonKey(unknownEnumValue: MealSlot.dinner) this.slot = MealSlot.dinner, this.recipeId, this.recipeTitle, this.freeText, this.cookUserId, this.servings, this.position = 0});
  factory _MealPlanEntryDto.fromJson(Map<String, dynamic> json) => _$MealPlanEntryDtoFromJson(json);

@override final  String id;
@override final  String channelId;
/// A plain date, deliberately: Thursday dinner is Thursday dinner wherever
/// your phone is. See [PlainDate].
@override final  PlainDate date;
@override@JsonKey(unknownEnumValue: MealSlot.dinner) final  MealSlot slot;
@override final  String? recipeId;
/// Denormalized so a week renders without fetching every recipe it names.
@override final  String? recipeTitle;
@override final  String? freeText;
@override final  String? cookUserId;
@override final  int? servings;
@override@JsonKey() final  int position;

/// Create a copy of MealPlanEntryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MealPlanEntryDtoCopyWith<_MealPlanEntryDto> get copyWith => __$MealPlanEntryDtoCopyWithImpl<_MealPlanEntryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MealPlanEntryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MealPlanEntryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.date, date) || other.date == date)&&(identical(other.slot, slot) || other.slot == slot)&&(identical(other.recipeId, recipeId) || other.recipeId == recipeId)&&(identical(other.recipeTitle, recipeTitle) || other.recipeTitle == recipeTitle)&&(identical(other.freeText, freeText) || other.freeText == freeText)&&(identical(other.cookUserId, cookUserId) || other.cookUserId == cookUserId)&&(identical(other.servings, servings) || other.servings == servings)&&(identical(other.position, position) || other.position == position));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,date,slot,recipeId,recipeTitle,freeText,cookUserId,servings,position);

@override
String toString() {
  return 'MealPlanEntryDto(id: $id, channelId: $channelId, date: $date, slot: $slot, recipeId: $recipeId, recipeTitle: $recipeTitle, freeText: $freeText, cookUserId: $cookUserId, servings: $servings, position: $position)';
}


}

/// @nodoc
abstract mixin class _$MealPlanEntryDtoCopyWith<$Res> implements $MealPlanEntryDtoCopyWith<$Res> {
  factory _$MealPlanEntryDtoCopyWith(_MealPlanEntryDto value, $Res Function(_MealPlanEntryDto) _then) = __$MealPlanEntryDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String channelId, PlainDate date,@JsonKey(unknownEnumValue: MealSlot.dinner) MealSlot slot, String? recipeId, String? recipeTitle, String? freeText, String? cookUserId, int? servings, int position
});




}
/// @nodoc
class __$MealPlanEntryDtoCopyWithImpl<$Res>
    implements _$MealPlanEntryDtoCopyWith<$Res> {
  __$MealPlanEntryDtoCopyWithImpl(this._self, this._then);

  final _MealPlanEntryDto _self;
  final $Res Function(_MealPlanEntryDto) _then;

/// Create a copy of MealPlanEntryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? channelId = null,Object? date = null,Object? slot = null,Object? recipeId = freezed,Object? recipeTitle = freezed,Object? freeText = freezed,Object? cookUserId = freezed,Object? servings = freezed,Object? position = null,}) {
  return _then(_MealPlanEntryDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as PlainDate,slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as MealSlot,recipeId: freezed == recipeId ? _self.recipeId : recipeId // ignore: cast_nullable_to_non_nullable
as String?,recipeTitle: freezed == recipeTitle ? _self.recipeTitle : recipeTitle // ignore: cast_nullable_to_non_nullable
as String?,freeText: freezed == freeText ? _self.freeText : freeText // ignore: cast_nullable_to_non_nullable
as String?,cookUserId: freezed == cookUserId ? _self.cookUserId : cookUserId // ignore: cast_nullable_to_non_nullable
as String?,servings: freezed == servings ? _self.servings : servings // ignore: cast_nullable_to_non_nullable
as int?,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$MealPlanConfigDto {

 String get channelId;/// Where the plan-to-shopping-list button writes. Must be a `List` channel
/// in this guild.
 String? get shoppingListChannelId;/// What "we already have that" is checked against. Without it the pantry
/// skip cannot happen and every ingredient is added.
 String? get pantryChannelId;
/// Create a copy of MealPlanConfigDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MealPlanConfigDtoCopyWith<MealPlanConfigDto> get copyWith => _$MealPlanConfigDtoCopyWithImpl<MealPlanConfigDto>(this as MealPlanConfigDto, _$identity);

  /// Serializes this MealPlanConfigDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MealPlanConfigDto&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.shoppingListChannelId, shoppingListChannelId) || other.shoppingListChannelId == shoppingListChannelId)&&(identical(other.pantryChannelId, pantryChannelId) || other.pantryChannelId == pantryChannelId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,channelId,shoppingListChannelId,pantryChannelId);

@override
String toString() {
  return 'MealPlanConfigDto(channelId: $channelId, shoppingListChannelId: $shoppingListChannelId, pantryChannelId: $pantryChannelId)';
}


}

/// @nodoc
abstract mixin class $MealPlanConfigDtoCopyWith<$Res>  {
  factory $MealPlanConfigDtoCopyWith(MealPlanConfigDto value, $Res Function(MealPlanConfigDto) _then) = _$MealPlanConfigDtoCopyWithImpl;
@useResult
$Res call({
 String channelId, String? shoppingListChannelId, String? pantryChannelId
});




}
/// @nodoc
class _$MealPlanConfigDtoCopyWithImpl<$Res>
    implements $MealPlanConfigDtoCopyWith<$Res> {
  _$MealPlanConfigDtoCopyWithImpl(this._self, this._then);

  final MealPlanConfigDto _self;
  final $Res Function(MealPlanConfigDto) _then;

/// Create a copy of MealPlanConfigDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? channelId = null,Object? shoppingListChannelId = freezed,Object? pantryChannelId = freezed,}) {
  return _then(_self.copyWith(
channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,shoppingListChannelId: freezed == shoppingListChannelId ? _self.shoppingListChannelId : shoppingListChannelId // ignore: cast_nullable_to_non_nullable
as String?,pantryChannelId: freezed == pantryChannelId ? _self.pantryChannelId : pantryChannelId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MealPlanConfigDto].
extension MealPlanConfigDtoPatterns on MealPlanConfigDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MealPlanConfigDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MealPlanConfigDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MealPlanConfigDto value)  $default,){
final _that = this;
switch (_that) {
case _MealPlanConfigDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MealPlanConfigDto value)?  $default,){
final _that = this;
switch (_that) {
case _MealPlanConfigDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String channelId,  String? shoppingListChannelId,  String? pantryChannelId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MealPlanConfigDto() when $default != null:
return $default(_that.channelId,_that.shoppingListChannelId,_that.pantryChannelId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String channelId,  String? shoppingListChannelId,  String? pantryChannelId)  $default,) {final _that = this;
switch (_that) {
case _MealPlanConfigDto():
return $default(_that.channelId,_that.shoppingListChannelId,_that.pantryChannelId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String channelId,  String? shoppingListChannelId,  String? pantryChannelId)?  $default,) {final _that = this;
switch (_that) {
case _MealPlanConfigDto() when $default != null:
return $default(_that.channelId,_that.shoppingListChannelId,_that.pantryChannelId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MealPlanConfigDto implements MealPlanConfigDto {
  const _MealPlanConfigDto({this.channelId = '', this.shoppingListChannelId, this.pantryChannelId});
  factory _MealPlanConfigDto.fromJson(Map<String, dynamic> json) => _$MealPlanConfigDtoFromJson(json);

@override@JsonKey() final  String channelId;
/// Where the plan-to-shopping-list button writes. Must be a `List` channel
/// in this guild.
@override final  String? shoppingListChannelId;
/// What "we already have that" is checked against. Without it the pantry
/// skip cannot happen and every ingredient is added.
@override final  String? pantryChannelId;

/// Create a copy of MealPlanConfigDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MealPlanConfigDtoCopyWith<_MealPlanConfigDto> get copyWith => __$MealPlanConfigDtoCopyWithImpl<_MealPlanConfigDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MealPlanConfigDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MealPlanConfigDto&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.shoppingListChannelId, shoppingListChannelId) || other.shoppingListChannelId == shoppingListChannelId)&&(identical(other.pantryChannelId, pantryChannelId) || other.pantryChannelId == pantryChannelId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,channelId,shoppingListChannelId,pantryChannelId);

@override
String toString() {
  return 'MealPlanConfigDto(channelId: $channelId, shoppingListChannelId: $shoppingListChannelId, pantryChannelId: $pantryChannelId)';
}


}

/// @nodoc
abstract mixin class _$MealPlanConfigDtoCopyWith<$Res> implements $MealPlanConfigDtoCopyWith<$Res> {
  factory _$MealPlanConfigDtoCopyWith(_MealPlanConfigDto value, $Res Function(_MealPlanConfigDto) _then) = __$MealPlanConfigDtoCopyWithImpl;
@override @useResult
$Res call({
 String channelId, String? shoppingListChannelId, String? pantryChannelId
});




}
/// @nodoc
class __$MealPlanConfigDtoCopyWithImpl<$Res>
    implements _$MealPlanConfigDtoCopyWith<$Res> {
  __$MealPlanConfigDtoCopyWithImpl(this._self, this._then);

  final _MealPlanConfigDto _self;
  final $Res Function(_MealPlanConfigDto) _then;

/// Create a copy of MealPlanConfigDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? channelId = null,Object? shoppingListChannelId = freezed,Object? pantryChannelId = freezed,}) {
  return _then(_MealPlanConfigDto(
channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,shoppingListChannelId: freezed == shoppingListChannelId ? _self.shoppingListChannelId : shoppingListChannelId // ignore: cast_nullable_to_non_nullable
as String?,pantryChannelId: freezed == pantryChannelId ? _self.pantryChannelId : pantryChannelId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ShoppingListResultDto {

 List<ListItemDto> get added;/// Dropped because the configured pantry already has them.
 List<String> get skippedInPantry;/// Dropped because an unchecked line on the target list already covers
/// them.
 List<String> get skippedOnList;/// The per-call line cap was hit and the plan had more - offer to run it
/// again for the rest rather than quietly shipping half a week.
 bool get truncated;
/// Create a copy of ShoppingListResultDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShoppingListResultDtoCopyWith<ShoppingListResultDto> get copyWith => _$ShoppingListResultDtoCopyWithImpl<ShoppingListResultDto>(this as ShoppingListResultDto, _$identity);

  /// Serializes this ShoppingListResultDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShoppingListResultDto&&const DeepCollectionEquality().equals(other.added, added)&&const DeepCollectionEquality().equals(other.skippedInPantry, skippedInPantry)&&const DeepCollectionEquality().equals(other.skippedOnList, skippedOnList)&&(identical(other.truncated, truncated) || other.truncated == truncated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(added),const DeepCollectionEquality().hash(skippedInPantry),const DeepCollectionEquality().hash(skippedOnList),truncated);

@override
String toString() {
  return 'ShoppingListResultDto(added: $added, skippedInPantry: $skippedInPantry, skippedOnList: $skippedOnList, truncated: $truncated)';
}


}

/// @nodoc
abstract mixin class $ShoppingListResultDtoCopyWith<$Res>  {
  factory $ShoppingListResultDtoCopyWith(ShoppingListResultDto value, $Res Function(ShoppingListResultDto) _then) = _$ShoppingListResultDtoCopyWithImpl;
@useResult
$Res call({
 List<ListItemDto> added, List<String> skippedInPantry, List<String> skippedOnList, bool truncated
});




}
/// @nodoc
class _$ShoppingListResultDtoCopyWithImpl<$Res>
    implements $ShoppingListResultDtoCopyWith<$Res> {
  _$ShoppingListResultDtoCopyWithImpl(this._self, this._then);

  final ShoppingListResultDto _self;
  final $Res Function(ShoppingListResultDto) _then;

/// Create a copy of ShoppingListResultDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? added = null,Object? skippedInPantry = null,Object? skippedOnList = null,Object? truncated = null,}) {
  return _then(_self.copyWith(
added: null == added ? _self.added : added // ignore: cast_nullable_to_non_nullable
as List<ListItemDto>,skippedInPantry: null == skippedInPantry ? _self.skippedInPantry : skippedInPantry // ignore: cast_nullable_to_non_nullable
as List<String>,skippedOnList: null == skippedOnList ? _self.skippedOnList : skippedOnList // ignore: cast_nullable_to_non_nullable
as List<String>,truncated: null == truncated ? _self.truncated : truncated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ShoppingListResultDto].
extension ShoppingListResultDtoPatterns on ShoppingListResultDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShoppingListResultDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShoppingListResultDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShoppingListResultDto value)  $default,){
final _that = this;
switch (_that) {
case _ShoppingListResultDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShoppingListResultDto value)?  $default,){
final _that = this;
switch (_that) {
case _ShoppingListResultDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ListItemDto> added,  List<String> skippedInPantry,  List<String> skippedOnList,  bool truncated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShoppingListResultDto() when $default != null:
return $default(_that.added,_that.skippedInPantry,_that.skippedOnList,_that.truncated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ListItemDto> added,  List<String> skippedInPantry,  List<String> skippedOnList,  bool truncated)  $default,) {final _that = this;
switch (_that) {
case _ShoppingListResultDto():
return $default(_that.added,_that.skippedInPantry,_that.skippedOnList,_that.truncated);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ListItemDto> added,  List<String> skippedInPantry,  List<String> skippedOnList,  bool truncated)?  $default,) {final _that = this;
switch (_that) {
case _ShoppingListResultDto() when $default != null:
return $default(_that.added,_that.skippedInPantry,_that.skippedOnList,_that.truncated);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShoppingListResultDto implements ShoppingListResultDto {
  const _ShoppingListResultDto({final  List<ListItemDto> added = const <ListItemDto>[], final  List<String> skippedInPantry = const <String>[], final  List<String> skippedOnList = const <String>[], this.truncated = false}): _added = added,_skippedInPantry = skippedInPantry,_skippedOnList = skippedOnList;
  factory _ShoppingListResultDto.fromJson(Map<String, dynamic> json) => _$ShoppingListResultDtoFromJson(json);

 final  List<ListItemDto> _added;
@override@JsonKey() List<ListItemDto> get added {
  if (_added is EqualUnmodifiableListView) return _added;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_added);
}

/// Dropped because the configured pantry already has them.
 final  List<String> _skippedInPantry;
/// Dropped because the configured pantry already has them.
@override@JsonKey() List<String> get skippedInPantry {
  if (_skippedInPantry is EqualUnmodifiableListView) return _skippedInPantry;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_skippedInPantry);
}

/// Dropped because an unchecked line on the target list already covers
/// them.
 final  List<String> _skippedOnList;
/// Dropped because an unchecked line on the target list already covers
/// them.
@override@JsonKey() List<String> get skippedOnList {
  if (_skippedOnList is EqualUnmodifiableListView) return _skippedOnList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_skippedOnList);
}

/// The per-call line cap was hit and the plan had more - offer to run it
/// again for the rest rather than quietly shipping half a week.
@override@JsonKey() final  bool truncated;

/// Create a copy of ShoppingListResultDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShoppingListResultDtoCopyWith<_ShoppingListResultDto> get copyWith => __$ShoppingListResultDtoCopyWithImpl<_ShoppingListResultDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShoppingListResultDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShoppingListResultDto&&const DeepCollectionEquality().equals(other._added, _added)&&const DeepCollectionEquality().equals(other._skippedInPantry, _skippedInPantry)&&const DeepCollectionEquality().equals(other._skippedOnList, _skippedOnList)&&(identical(other.truncated, truncated) || other.truncated == truncated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_added),const DeepCollectionEquality().hash(_skippedInPantry),const DeepCollectionEquality().hash(_skippedOnList),truncated);

@override
String toString() {
  return 'ShoppingListResultDto(added: $added, skippedInPantry: $skippedInPantry, skippedOnList: $skippedOnList, truncated: $truncated)';
}


}

/// @nodoc
abstract mixin class _$ShoppingListResultDtoCopyWith<$Res> implements $ShoppingListResultDtoCopyWith<$Res> {
  factory _$ShoppingListResultDtoCopyWith(_ShoppingListResultDto value, $Res Function(_ShoppingListResultDto) _then) = __$ShoppingListResultDtoCopyWithImpl;
@override @useResult
$Res call({
 List<ListItemDto> added, List<String> skippedInPantry, List<String> skippedOnList, bool truncated
});




}
/// @nodoc
class __$ShoppingListResultDtoCopyWithImpl<$Res>
    implements _$ShoppingListResultDtoCopyWith<$Res> {
  __$ShoppingListResultDtoCopyWithImpl(this._self, this._then);

  final _ShoppingListResultDto _self;
  final $Res Function(_ShoppingListResultDto) _then;

/// Create a copy of ShoppingListResultDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? added = null,Object? skippedInPantry = null,Object? skippedOnList = null,Object? truncated = null,}) {
  return _then(_ShoppingListResultDto(
added: null == added ? _self._added : added // ignore: cast_nullable_to_non_nullable
as List<ListItemDto>,skippedInPantry: null == skippedInPantry ? _self._skippedInPantry : skippedInPantry // ignore: cast_nullable_to_non_nullable
as List<String>,skippedOnList: null == skippedOnList ? _self._skippedOnList : skippedOnList // ignore: cast_nullable_to_non_nullable
as List<String>,truncated: null == truncated ? _self.truncated : truncated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$CookableRecipeDto {

 RecipeDto get recipe;/// Ingredients the pantry can cover, optional ones included.
 int get haveCount;/// **Required** ingredients the pantry cannot cover. Optional lines are
/// excluded: counting garnish would rank a dinner you can absolutely cook
/// tonight below one you cannot.
 int get missingCount;/// How many of the covering items are inside the expiry horizon. The
/// primary sort key, and the entire reason this exists.
 int get expiringCount; List<String> get expiringNames; List<String> get missing;
/// Create a copy of CookableRecipeDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CookableRecipeDtoCopyWith<CookableRecipeDto> get copyWith => _$CookableRecipeDtoCopyWithImpl<CookableRecipeDto>(this as CookableRecipeDto, _$identity);

  /// Serializes this CookableRecipeDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CookableRecipeDto&&(identical(other.recipe, recipe) || other.recipe == recipe)&&(identical(other.haveCount, haveCount) || other.haveCount == haveCount)&&(identical(other.missingCount, missingCount) || other.missingCount == missingCount)&&(identical(other.expiringCount, expiringCount) || other.expiringCount == expiringCount)&&const DeepCollectionEquality().equals(other.expiringNames, expiringNames)&&const DeepCollectionEquality().equals(other.missing, missing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recipe,haveCount,missingCount,expiringCount,const DeepCollectionEquality().hash(expiringNames),const DeepCollectionEquality().hash(missing));

@override
String toString() {
  return 'CookableRecipeDto(recipe: $recipe, haveCount: $haveCount, missingCount: $missingCount, expiringCount: $expiringCount, expiringNames: $expiringNames, missing: $missing)';
}


}

/// @nodoc
abstract mixin class $CookableRecipeDtoCopyWith<$Res>  {
  factory $CookableRecipeDtoCopyWith(CookableRecipeDto value, $Res Function(CookableRecipeDto) _then) = _$CookableRecipeDtoCopyWithImpl;
@useResult
$Res call({
 RecipeDto recipe, int haveCount, int missingCount, int expiringCount, List<String> expiringNames, List<String> missing
});


$RecipeDtoCopyWith<$Res> get recipe;

}
/// @nodoc
class _$CookableRecipeDtoCopyWithImpl<$Res>
    implements $CookableRecipeDtoCopyWith<$Res> {
  _$CookableRecipeDtoCopyWithImpl(this._self, this._then);

  final CookableRecipeDto _self;
  final $Res Function(CookableRecipeDto) _then;

/// Create a copy of CookableRecipeDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recipe = null,Object? haveCount = null,Object? missingCount = null,Object? expiringCount = null,Object? expiringNames = null,Object? missing = null,}) {
  return _then(_self.copyWith(
recipe: null == recipe ? _self.recipe : recipe // ignore: cast_nullable_to_non_nullable
as RecipeDto,haveCount: null == haveCount ? _self.haveCount : haveCount // ignore: cast_nullable_to_non_nullable
as int,missingCount: null == missingCount ? _self.missingCount : missingCount // ignore: cast_nullable_to_non_nullable
as int,expiringCount: null == expiringCount ? _self.expiringCount : expiringCount // ignore: cast_nullable_to_non_nullable
as int,expiringNames: null == expiringNames ? _self.expiringNames : expiringNames // ignore: cast_nullable_to_non_nullable
as List<String>,missing: null == missing ? _self.missing : missing // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of CookableRecipeDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecipeDtoCopyWith<$Res> get recipe {
  
  return $RecipeDtoCopyWith<$Res>(_self.recipe, (value) {
    return _then(_self.copyWith(recipe: value));
  });
}
}


/// Adds pattern-matching-related methods to [CookableRecipeDto].
extension CookableRecipeDtoPatterns on CookableRecipeDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CookableRecipeDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CookableRecipeDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CookableRecipeDto value)  $default,){
final _that = this;
switch (_that) {
case _CookableRecipeDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CookableRecipeDto value)?  $default,){
final _that = this;
switch (_that) {
case _CookableRecipeDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RecipeDto recipe,  int haveCount,  int missingCount,  int expiringCount,  List<String> expiringNames,  List<String> missing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CookableRecipeDto() when $default != null:
return $default(_that.recipe,_that.haveCount,_that.missingCount,_that.expiringCount,_that.expiringNames,_that.missing);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RecipeDto recipe,  int haveCount,  int missingCount,  int expiringCount,  List<String> expiringNames,  List<String> missing)  $default,) {final _that = this;
switch (_that) {
case _CookableRecipeDto():
return $default(_that.recipe,_that.haveCount,_that.missingCount,_that.expiringCount,_that.expiringNames,_that.missing);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RecipeDto recipe,  int haveCount,  int missingCount,  int expiringCount,  List<String> expiringNames,  List<String> missing)?  $default,) {final _that = this;
switch (_that) {
case _CookableRecipeDto() when $default != null:
return $default(_that.recipe,_that.haveCount,_that.missingCount,_that.expiringCount,_that.expiringNames,_that.missing);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CookableRecipeDto implements CookableRecipeDto {
  const _CookableRecipeDto({required this.recipe, this.haveCount = 0, this.missingCount = 0, this.expiringCount = 0, final  List<String> expiringNames = const <String>[], final  List<String> missing = const <String>[]}): _expiringNames = expiringNames,_missing = missing;
  factory _CookableRecipeDto.fromJson(Map<String, dynamic> json) => _$CookableRecipeDtoFromJson(json);

@override final  RecipeDto recipe;
/// Ingredients the pantry can cover, optional ones included.
@override@JsonKey() final  int haveCount;
/// **Required** ingredients the pantry cannot cover. Optional lines are
/// excluded: counting garnish would rank a dinner you can absolutely cook
/// tonight below one you cannot.
@override@JsonKey() final  int missingCount;
/// How many of the covering items are inside the expiry horizon. The
/// primary sort key, and the entire reason this exists.
@override@JsonKey() final  int expiringCount;
 final  List<String> _expiringNames;
@override@JsonKey() List<String> get expiringNames {
  if (_expiringNames is EqualUnmodifiableListView) return _expiringNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_expiringNames);
}

 final  List<String> _missing;
@override@JsonKey() List<String> get missing {
  if (_missing is EqualUnmodifiableListView) return _missing;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_missing);
}


/// Create a copy of CookableRecipeDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CookableRecipeDtoCopyWith<_CookableRecipeDto> get copyWith => __$CookableRecipeDtoCopyWithImpl<_CookableRecipeDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CookableRecipeDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CookableRecipeDto&&(identical(other.recipe, recipe) || other.recipe == recipe)&&(identical(other.haveCount, haveCount) || other.haveCount == haveCount)&&(identical(other.missingCount, missingCount) || other.missingCount == missingCount)&&(identical(other.expiringCount, expiringCount) || other.expiringCount == expiringCount)&&const DeepCollectionEquality().equals(other._expiringNames, _expiringNames)&&const DeepCollectionEquality().equals(other._missing, _missing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recipe,haveCount,missingCount,expiringCount,const DeepCollectionEquality().hash(_expiringNames),const DeepCollectionEquality().hash(_missing));

@override
String toString() {
  return 'CookableRecipeDto(recipe: $recipe, haveCount: $haveCount, missingCount: $missingCount, expiringCount: $expiringCount, expiringNames: $expiringNames, missing: $missing)';
}


}

/// @nodoc
abstract mixin class _$CookableRecipeDtoCopyWith<$Res> implements $CookableRecipeDtoCopyWith<$Res> {
  factory _$CookableRecipeDtoCopyWith(_CookableRecipeDto value, $Res Function(_CookableRecipeDto) _then) = __$CookableRecipeDtoCopyWithImpl;
@override @useResult
$Res call({
 RecipeDto recipe, int haveCount, int missingCount, int expiringCount, List<String> expiringNames, List<String> missing
});


@override $RecipeDtoCopyWith<$Res> get recipe;

}
/// @nodoc
class __$CookableRecipeDtoCopyWithImpl<$Res>
    implements _$CookableRecipeDtoCopyWith<$Res> {
  __$CookableRecipeDtoCopyWithImpl(this._self, this._then);

  final _CookableRecipeDto _self;
  final $Res Function(_CookableRecipeDto) _then;

/// Create a copy of CookableRecipeDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recipe = null,Object? haveCount = null,Object? missingCount = null,Object? expiringCount = null,Object? expiringNames = null,Object? missing = null,}) {
  return _then(_CookableRecipeDto(
recipe: null == recipe ? _self.recipe : recipe // ignore: cast_nullable_to_non_nullable
as RecipeDto,haveCount: null == haveCount ? _self.haveCount : haveCount // ignore: cast_nullable_to_non_nullable
as int,missingCount: null == missingCount ? _self.missingCount : missingCount // ignore: cast_nullable_to_non_nullable
as int,expiringCount: null == expiringCount ? _self.expiringCount : expiringCount // ignore: cast_nullable_to_non_nullable
as int,expiringNames: null == expiringNames ? _self._expiringNames : expiringNames // ignore: cast_nullable_to_non_nullable
as List<String>,missing: null == missing ? _self._missing : missing // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of CookableRecipeDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecipeDtoCopyWith<$Res> get recipe {
  
  return $RecipeDtoCopyWith<$Res>(_self.recipe, (value) {
    return _then(_self.copyWith(recipe: value));
  });
}
}


/// @nodoc
mixin _$CookableResultDto {

 List<CookableRecipeDto> get items;/// Why [items] is empty when it is: no pantry module, no configured
/// pantry, or nothing in stock. Null when the ranking is genuine. Rendered
/// rather than swallowed - a bare empty list leaves the house believing the
/// feature is broken when it is only unconfigured.
 String? get reason;
/// Create a copy of CookableResultDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CookableResultDtoCopyWith<CookableResultDto> get copyWith => _$CookableResultDtoCopyWithImpl<CookableResultDto>(this as CookableResultDto, _$identity);

  /// Serializes this CookableResultDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CookableResultDto&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),reason);

@override
String toString() {
  return 'CookableResultDto(items: $items, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $CookableResultDtoCopyWith<$Res>  {
  factory $CookableResultDtoCopyWith(CookableResultDto value, $Res Function(CookableResultDto) _then) = _$CookableResultDtoCopyWithImpl;
@useResult
$Res call({
 List<CookableRecipeDto> items, String? reason
});




}
/// @nodoc
class _$CookableResultDtoCopyWithImpl<$Res>
    implements $CookableResultDtoCopyWith<$Res> {
  _$CookableResultDtoCopyWithImpl(this._self, this._then);

  final CookableResultDto _self;
  final $Res Function(CookableResultDto) _then;

/// Create a copy of CookableResultDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? reason = freezed,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CookableRecipeDto>,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CookableResultDto].
extension CookableResultDtoPatterns on CookableResultDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CookableResultDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CookableResultDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CookableResultDto value)  $default,){
final _that = this;
switch (_that) {
case _CookableResultDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CookableResultDto value)?  $default,){
final _that = this;
switch (_that) {
case _CookableResultDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CookableRecipeDto> items,  String? reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CookableResultDto() when $default != null:
return $default(_that.items,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CookableRecipeDto> items,  String? reason)  $default,) {final _that = this;
switch (_that) {
case _CookableResultDto():
return $default(_that.items,_that.reason);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CookableRecipeDto> items,  String? reason)?  $default,) {final _that = this;
switch (_that) {
case _CookableResultDto() when $default != null:
return $default(_that.items,_that.reason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CookableResultDto implements CookableResultDto {
  const _CookableResultDto({final  List<CookableRecipeDto> items = const <CookableRecipeDto>[], this.reason}): _items = items;
  factory _CookableResultDto.fromJson(Map<String, dynamic> json) => _$CookableResultDtoFromJson(json);

 final  List<CookableRecipeDto> _items;
@override@JsonKey() List<CookableRecipeDto> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

/// Why [items] is empty when it is: no pantry module, no configured
/// pantry, or nothing in stock. Null when the ranking is genuine. Rendered
/// rather than swallowed - a bare empty list leaves the house believing the
/// feature is broken when it is only unconfigured.
@override final  String? reason;

/// Create a copy of CookableResultDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CookableResultDtoCopyWith<_CookableResultDto> get copyWith => __$CookableResultDtoCopyWithImpl<_CookableResultDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CookableResultDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CookableResultDto&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),reason);

@override
String toString() {
  return 'CookableResultDto(items: $items, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$CookableResultDtoCopyWith<$Res> implements $CookableResultDtoCopyWith<$Res> {
  factory _$CookableResultDtoCopyWith(_CookableResultDto value, $Res Function(_CookableResultDto) _then) = __$CookableResultDtoCopyWithImpl;
@override @useResult
$Res call({
 List<CookableRecipeDto> items, String? reason
});




}
/// @nodoc
class __$CookableResultDtoCopyWithImpl<$Res>
    implements _$CookableResultDtoCopyWith<$Res> {
  __$CookableResultDtoCopyWithImpl(this._self, this._then);

  final _CookableResultDto _self;
  final $Res Function(_CookableResultDto) _then;

/// Create a copy of CookableResultDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? reason = freezed,}) {
  return _then(_CookableResultDto(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CookableRecipeDto>,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
