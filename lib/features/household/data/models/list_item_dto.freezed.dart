// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'list_item_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ListItemDto {

 String get id; String get channelId; String get text; String? get quantity; String? get note;/// Free-text grouping ("Dairy") - not an entity, just a string the client
/// groups on.
 String? get section; String? get assigneeUserId; String get addedByUserId; bool get isChecked; DateTime? get checkedAt; String? get checkedByUserId; int get position;/// Set when the pantry's restock loop put this line here rather than a
/// person - badged in the UI so nobody has to wonder why milk appeared.
 String? get sourcePantryItemId; DateTime? get createdAt;
/// Create a copy of ListItemDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListItemDtoCopyWith<ListItemDto> get copyWith => _$ListItemDtoCopyWithImpl<ListItemDto>(this as ListItemDto, _$identity);

  /// Serializes this ListItemDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListItemDto&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.text, text) || other.text == text)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.note, note) || other.note == note)&&(identical(other.section, section) || other.section == section)&&(identical(other.assigneeUserId, assigneeUserId) || other.assigneeUserId == assigneeUserId)&&(identical(other.addedByUserId, addedByUserId) || other.addedByUserId == addedByUserId)&&(identical(other.isChecked, isChecked) || other.isChecked == isChecked)&&(identical(other.checkedAt, checkedAt) || other.checkedAt == checkedAt)&&(identical(other.checkedByUserId, checkedByUserId) || other.checkedByUserId == checkedByUserId)&&(identical(other.position, position) || other.position == position)&&(identical(other.sourcePantryItemId, sourcePantryItemId) || other.sourcePantryItemId == sourcePantryItemId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,text,quantity,note,section,assigneeUserId,addedByUserId,isChecked,checkedAt,checkedByUserId,position,sourcePantryItemId,createdAt);

@override
String toString() {
  return 'ListItemDto(id: $id, channelId: $channelId, text: $text, quantity: $quantity, note: $note, section: $section, assigneeUserId: $assigneeUserId, addedByUserId: $addedByUserId, isChecked: $isChecked, checkedAt: $checkedAt, checkedByUserId: $checkedByUserId, position: $position, sourcePantryItemId: $sourcePantryItemId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ListItemDtoCopyWith<$Res>  {
  factory $ListItemDtoCopyWith(ListItemDto value, $Res Function(ListItemDto) _then) = _$ListItemDtoCopyWithImpl;
@useResult
$Res call({
 String id, String channelId, String text, String? quantity, String? note, String? section, String? assigneeUserId, String addedByUserId, bool isChecked, DateTime? checkedAt, String? checkedByUserId, int position, String? sourcePantryItemId, DateTime? createdAt
});




}
/// @nodoc
class _$ListItemDtoCopyWithImpl<$Res>
    implements $ListItemDtoCopyWith<$Res> {
  _$ListItemDtoCopyWithImpl(this._self, this._then);

  final ListItemDto _self;
  final $Res Function(ListItemDto) _then;

/// Create a copy of ListItemDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? channelId = null,Object? text = null,Object? quantity = freezed,Object? note = freezed,Object? section = freezed,Object? assigneeUserId = freezed,Object? addedByUserId = null,Object? isChecked = null,Object? checkedAt = freezed,Object? checkedByUserId = freezed,Object? position = null,Object? sourcePantryItemId = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,section: freezed == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
as String?,assigneeUserId: freezed == assigneeUserId ? _self.assigneeUserId : assigneeUserId // ignore: cast_nullable_to_non_nullable
as String?,addedByUserId: null == addedByUserId ? _self.addedByUserId : addedByUserId // ignore: cast_nullable_to_non_nullable
as String,isChecked: null == isChecked ? _self.isChecked : isChecked // ignore: cast_nullable_to_non_nullable
as bool,checkedAt: freezed == checkedAt ? _self.checkedAt : checkedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,checkedByUserId: freezed == checkedByUserId ? _self.checkedByUserId : checkedByUserId // ignore: cast_nullable_to_non_nullable
as String?,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,sourcePantryItemId: freezed == sourcePantryItemId ? _self.sourcePantryItemId : sourcePantryItemId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ListItemDto].
extension ListItemDtoPatterns on ListItemDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListItemDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListItemDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListItemDto value)  $default,){
final _that = this;
switch (_that) {
case _ListItemDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListItemDto value)?  $default,){
final _that = this;
switch (_that) {
case _ListItemDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String channelId,  String text,  String? quantity,  String? note,  String? section,  String? assigneeUserId,  String addedByUserId,  bool isChecked,  DateTime? checkedAt,  String? checkedByUserId,  int position,  String? sourcePantryItemId,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListItemDto() when $default != null:
return $default(_that.id,_that.channelId,_that.text,_that.quantity,_that.note,_that.section,_that.assigneeUserId,_that.addedByUserId,_that.isChecked,_that.checkedAt,_that.checkedByUserId,_that.position,_that.sourcePantryItemId,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String channelId,  String text,  String? quantity,  String? note,  String? section,  String? assigneeUserId,  String addedByUserId,  bool isChecked,  DateTime? checkedAt,  String? checkedByUserId,  int position,  String? sourcePantryItemId,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _ListItemDto():
return $default(_that.id,_that.channelId,_that.text,_that.quantity,_that.note,_that.section,_that.assigneeUserId,_that.addedByUserId,_that.isChecked,_that.checkedAt,_that.checkedByUserId,_that.position,_that.sourcePantryItemId,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String channelId,  String text,  String? quantity,  String? note,  String? section,  String? assigneeUserId,  String addedByUserId,  bool isChecked,  DateTime? checkedAt,  String? checkedByUserId,  int position,  String? sourcePantryItemId,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ListItemDto() when $default != null:
return $default(_that.id,_that.channelId,_that.text,_that.quantity,_that.note,_that.section,_that.assigneeUserId,_that.addedByUserId,_that.isChecked,_that.checkedAt,_that.checkedByUserId,_that.position,_that.sourcePantryItemId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _ListItemDto implements ListItemDto {
  const _ListItemDto({required this.id, required this.channelId, required this.text, this.quantity, this.note, this.section, this.assigneeUserId, this.addedByUserId = '', this.isChecked = false, this.checkedAt, this.checkedByUserId, this.position = 0, this.sourcePantryItemId, this.createdAt});
  factory _ListItemDto.fromJson(Map<String, dynamic> json) => _$ListItemDtoFromJson(json);

@override final  String id;
@override final  String channelId;
@override final  String text;
@override final  String? quantity;
@override final  String? note;
/// Free-text grouping ("Dairy") - not an entity, just a string the client
/// groups on.
@override final  String? section;
@override final  String? assigneeUserId;
@override@JsonKey() final  String addedByUserId;
@override@JsonKey() final  bool isChecked;
@override final  DateTime? checkedAt;
@override final  String? checkedByUserId;
@override@JsonKey() final  int position;
/// Set when the pantry's restock loop put this line here rather than a
/// person - badged in the UI so nobody has to wonder why milk appeared.
@override final  String? sourcePantryItemId;
@override final  DateTime? createdAt;

/// Create a copy of ListItemDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListItemDtoCopyWith<_ListItemDto> get copyWith => __$ListItemDtoCopyWithImpl<_ListItemDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListItemDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListItemDto&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.text, text) || other.text == text)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.note, note) || other.note == note)&&(identical(other.section, section) || other.section == section)&&(identical(other.assigneeUserId, assigneeUserId) || other.assigneeUserId == assigneeUserId)&&(identical(other.addedByUserId, addedByUserId) || other.addedByUserId == addedByUserId)&&(identical(other.isChecked, isChecked) || other.isChecked == isChecked)&&(identical(other.checkedAt, checkedAt) || other.checkedAt == checkedAt)&&(identical(other.checkedByUserId, checkedByUserId) || other.checkedByUserId == checkedByUserId)&&(identical(other.position, position) || other.position == position)&&(identical(other.sourcePantryItemId, sourcePantryItemId) || other.sourcePantryItemId == sourcePantryItemId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,text,quantity,note,section,assigneeUserId,addedByUserId,isChecked,checkedAt,checkedByUserId,position,sourcePantryItemId,createdAt);

@override
String toString() {
  return 'ListItemDto(id: $id, channelId: $channelId, text: $text, quantity: $quantity, note: $note, section: $section, assigneeUserId: $assigneeUserId, addedByUserId: $addedByUserId, isChecked: $isChecked, checkedAt: $checkedAt, checkedByUserId: $checkedByUserId, position: $position, sourcePantryItemId: $sourcePantryItemId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ListItemDtoCopyWith<$Res> implements $ListItemDtoCopyWith<$Res> {
  factory _$ListItemDtoCopyWith(_ListItemDto value, $Res Function(_ListItemDto) _then) = __$ListItemDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String channelId, String text, String? quantity, String? note, String? section, String? assigneeUserId, String addedByUserId, bool isChecked, DateTime? checkedAt, String? checkedByUserId, int position, String? sourcePantryItemId, DateTime? createdAt
});




}
/// @nodoc
class __$ListItemDtoCopyWithImpl<$Res>
    implements _$ListItemDtoCopyWith<$Res> {
  __$ListItemDtoCopyWithImpl(this._self, this._then);

  final _ListItemDto _self;
  final $Res Function(_ListItemDto) _then;

/// Create a copy of ListItemDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? channelId = null,Object? text = null,Object? quantity = freezed,Object? note = freezed,Object? section = freezed,Object? assigneeUserId = freezed,Object? addedByUserId = null,Object? isChecked = null,Object? checkedAt = freezed,Object? checkedByUserId = freezed,Object? position = null,Object? sourcePantryItemId = freezed,Object? createdAt = freezed,}) {
  return _then(_ListItemDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,section: freezed == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
as String?,assigneeUserId: freezed == assigneeUserId ? _self.assigneeUserId : assigneeUserId // ignore: cast_nullable_to_non_nullable
as String?,addedByUserId: null == addedByUserId ? _self.addedByUserId : addedByUserId // ignore: cast_nullable_to_non_nullable
as String,isChecked: null == isChecked ? _self.isChecked : isChecked // ignore: cast_nullable_to_non_nullable
as bool,checkedAt: freezed == checkedAt ? _self.checkedAt : checkedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,checkedByUserId: freezed == checkedByUserId ? _self.checkedByUserId : checkedByUserId // ignore: cast_nullable_to_non_nullable
as String?,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,sourcePantryItemId: freezed == sourcePantryItemId ? _self.sourcePantryItemId : sourcePantryItemId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
