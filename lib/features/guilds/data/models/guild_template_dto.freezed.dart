// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'guild_template_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GuildTemplateDto {

 String get id; String get name; String? get description; DateTime get createdAt;
/// Create a copy of GuildTemplateDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuildTemplateDtoCopyWith<GuildTemplateDto> get copyWith => _$GuildTemplateDtoCopyWithImpl<GuildTemplateDto>(this as GuildTemplateDto, _$identity);

  /// Serializes this GuildTemplateDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuildTemplateDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,createdAt);

@override
String toString() {
  return 'GuildTemplateDto(id: $id, name: $name, description: $description, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $GuildTemplateDtoCopyWith<$Res>  {
  factory $GuildTemplateDtoCopyWith(GuildTemplateDto value, $Res Function(GuildTemplateDto) _then) = _$GuildTemplateDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, DateTime createdAt
});




}
/// @nodoc
class _$GuildTemplateDtoCopyWithImpl<$Res>
    implements $GuildTemplateDtoCopyWith<$Res> {
  _$GuildTemplateDtoCopyWithImpl(this._self, this._then);

  final GuildTemplateDto _self;
  final $Res Function(GuildTemplateDto) _then;

/// Create a copy of GuildTemplateDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [GuildTemplateDto].
extension GuildTemplateDtoPatterns on GuildTemplateDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuildTemplateDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuildTemplateDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuildTemplateDto value)  $default,){
final _that = this;
switch (_that) {
case _GuildTemplateDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuildTemplateDto value)?  $default,){
final _that = this;
switch (_that) {
case _GuildTemplateDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuildTemplateDto() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _GuildTemplateDto():
return $default(_that.id,_that.name,_that.description,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _GuildTemplateDto() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GuildTemplateDto implements GuildTemplateDto {
  const _GuildTemplateDto({required this.id, required this.name, this.description, required this.createdAt});
  factory _GuildTemplateDto.fromJson(Map<String, dynamic> json) => _$GuildTemplateDtoFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override final  DateTime createdAt;

/// Create a copy of GuildTemplateDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuildTemplateDtoCopyWith<_GuildTemplateDto> get copyWith => __$GuildTemplateDtoCopyWithImpl<_GuildTemplateDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GuildTemplateDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuildTemplateDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,createdAt);

@override
String toString() {
  return 'GuildTemplateDto(id: $id, name: $name, description: $description, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$GuildTemplateDtoCopyWith<$Res> implements $GuildTemplateDtoCopyWith<$Res> {
  factory _$GuildTemplateDtoCopyWith(_GuildTemplateDto value, $Res Function(_GuildTemplateDto) _then) = __$GuildTemplateDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, DateTime createdAt
});




}
/// @nodoc
class __$GuildTemplateDtoCopyWithImpl<$Res>
    implements _$GuildTemplateDtoCopyWith<$Res> {
  __$GuildTemplateDtoCopyWithImpl(this._self, this._then);

  final _GuildTemplateDto _self;
  final $Res Function(_GuildTemplateDto) _then;

/// Create a copy of GuildTemplateDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? createdAt = null,}) {
  return _then(_GuildTemplateDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$TemplateChannelDto {

 String get name; String get type; String? get description; int get position;
/// Create a copy of TemplateChannelDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TemplateChannelDtoCopyWith<TemplateChannelDto> get copyWith => _$TemplateChannelDtoCopyWithImpl<TemplateChannelDto>(this as TemplateChannelDto, _$identity);

  /// Serializes this TemplateChannelDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TemplateChannelDto&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&(identical(other.position, position) || other.position == position));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,type,description,position);

@override
String toString() {
  return 'TemplateChannelDto(name: $name, type: $type, description: $description, position: $position)';
}


}

/// @nodoc
abstract mixin class $TemplateChannelDtoCopyWith<$Res>  {
  factory $TemplateChannelDtoCopyWith(TemplateChannelDto value, $Res Function(TemplateChannelDto) _then) = _$TemplateChannelDtoCopyWithImpl;
@useResult
$Res call({
 String name, String type, String? description, int position
});




}
/// @nodoc
class _$TemplateChannelDtoCopyWithImpl<$Res>
    implements $TemplateChannelDtoCopyWith<$Res> {
  _$TemplateChannelDtoCopyWithImpl(this._self, this._then);

  final TemplateChannelDto _self;
  final $Res Function(TemplateChannelDto) _then;

/// Create a copy of TemplateChannelDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? type = null,Object? description = freezed,Object? position = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TemplateChannelDto].
extension TemplateChannelDtoPatterns on TemplateChannelDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TemplateChannelDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TemplateChannelDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TemplateChannelDto value)  $default,){
final _that = this;
switch (_that) {
case _TemplateChannelDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TemplateChannelDto value)?  $default,){
final _that = this;
switch (_that) {
case _TemplateChannelDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String type,  String? description,  int position)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TemplateChannelDto() when $default != null:
return $default(_that.name,_that.type,_that.description,_that.position);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String type,  String? description,  int position)  $default,) {final _that = this;
switch (_that) {
case _TemplateChannelDto():
return $default(_that.name,_that.type,_that.description,_that.position);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String type,  String? description,  int position)?  $default,) {final _that = this;
switch (_that) {
case _TemplateChannelDto() when $default != null:
return $default(_that.name,_that.type,_that.description,_that.position);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TemplateChannelDto implements TemplateChannelDto {
  const _TemplateChannelDto({required this.name, required this.type, this.description, this.position = 0});
  factory _TemplateChannelDto.fromJson(Map<String, dynamic> json) => _$TemplateChannelDtoFromJson(json);

@override final  String name;
@override final  String type;
@override final  String? description;
@override@JsonKey() final  int position;

/// Create a copy of TemplateChannelDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TemplateChannelDtoCopyWith<_TemplateChannelDto> get copyWith => __$TemplateChannelDtoCopyWithImpl<_TemplateChannelDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TemplateChannelDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TemplateChannelDto&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&(identical(other.position, position) || other.position == position));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,type,description,position);

@override
String toString() {
  return 'TemplateChannelDto(name: $name, type: $type, description: $description, position: $position)';
}


}

/// @nodoc
abstract mixin class _$TemplateChannelDtoCopyWith<$Res> implements $TemplateChannelDtoCopyWith<$Res> {
  factory _$TemplateChannelDtoCopyWith(_TemplateChannelDto value, $Res Function(_TemplateChannelDto) _then) = __$TemplateChannelDtoCopyWithImpl;
@override @useResult
$Res call({
 String name, String type, String? description, int position
});




}
/// @nodoc
class __$TemplateChannelDtoCopyWithImpl<$Res>
    implements _$TemplateChannelDtoCopyWith<$Res> {
  __$TemplateChannelDtoCopyWithImpl(this._self, this._then);

  final _TemplateChannelDto _self;
  final $Res Function(_TemplateChannelDto) _then;

/// Create a copy of TemplateChannelDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? type = null,Object? description = freezed,Object? position = null,}) {
  return _then(_TemplateChannelDto(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TemplateCategoryDto {

 String get name; int get position; List<TemplateChannelDto> get channels;
/// Create a copy of TemplateCategoryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TemplateCategoryDtoCopyWith<TemplateCategoryDto> get copyWith => _$TemplateCategoryDtoCopyWithImpl<TemplateCategoryDto>(this as TemplateCategoryDto, _$identity);

  /// Serializes this TemplateCategoryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TemplateCategoryDto&&(identical(other.name, name) || other.name == name)&&(identical(other.position, position) || other.position == position)&&const DeepCollectionEquality().equals(other.channels, channels));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,position,const DeepCollectionEquality().hash(channels));

@override
String toString() {
  return 'TemplateCategoryDto(name: $name, position: $position, channels: $channels)';
}


}

/// @nodoc
abstract mixin class $TemplateCategoryDtoCopyWith<$Res>  {
  factory $TemplateCategoryDtoCopyWith(TemplateCategoryDto value, $Res Function(TemplateCategoryDto) _then) = _$TemplateCategoryDtoCopyWithImpl;
@useResult
$Res call({
 String name, int position, List<TemplateChannelDto> channels
});




}
/// @nodoc
class _$TemplateCategoryDtoCopyWithImpl<$Res>
    implements $TemplateCategoryDtoCopyWith<$Res> {
  _$TemplateCategoryDtoCopyWithImpl(this._self, this._then);

  final TemplateCategoryDto _self;
  final $Res Function(TemplateCategoryDto) _then;

/// Create a copy of TemplateCategoryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? position = null,Object? channels = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,channels: null == channels ? _self.channels : channels // ignore: cast_nullable_to_non_nullable
as List<TemplateChannelDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [TemplateCategoryDto].
extension TemplateCategoryDtoPatterns on TemplateCategoryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TemplateCategoryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TemplateCategoryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TemplateCategoryDto value)  $default,){
final _that = this;
switch (_that) {
case _TemplateCategoryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TemplateCategoryDto value)?  $default,){
final _that = this;
switch (_that) {
case _TemplateCategoryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  int position,  List<TemplateChannelDto> channels)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TemplateCategoryDto() when $default != null:
return $default(_that.name,_that.position,_that.channels);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  int position,  List<TemplateChannelDto> channels)  $default,) {final _that = this;
switch (_that) {
case _TemplateCategoryDto():
return $default(_that.name,_that.position,_that.channels);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  int position,  List<TemplateChannelDto> channels)?  $default,) {final _that = this;
switch (_that) {
case _TemplateCategoryDto() when $default != null:
return $default(_that.name,_that.position,_that.channels);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TemplateCategoryDto implements TemplateCategoryDto {
  const _TemplateCategoryDto({required this.name, this.position = 0, final  List<TemplateChannelDto> channels = const []}): _channels = channels;
  factory _TemplateCategoryDto.fromJson(Map<String, dynamic> json) => _$TemplateCategoryDtoFromJson(json);

@override final  String name;
@override@JsonKey() final  int position;
 final  List<TemplateChannelDto> _channels;
@override@JsonKey() List<TemplateChannelDto> get channels {
  if (_channels is EqualUnmodifiableListView) return _channels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_channels);
}


/// Create a copy of TemplateCategoryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TemplateCategoryDtoCopyWith<_TemplateCategoryDto> get copyWith => __$TemplateCategoryDtoCopyWithImpl<_TemplateCategoryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TemplateCategoryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TemplateCategoryDto&&(identical(other.name, name) || other.name == name)&&(identical(other.position, position) || other.position == position)&&const DeepCollectionEquality().equals(other._channels, _channels));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,position,const DeepCollectionEquality().hash(_channels));

@override
String toString() {
  return 'TemplateCategoryDto(name: $name, position: $position, channels: $channels)';
}


}

/// @nodoc
abstract mixin class _$TemplateCategoryDtoCopyWith<$Res> implements $TemplateCategoryDtoCopyWith<$Res> {
  factory _$TemplateCategoryDtoCopyWith(_TemplateCategoryDto value, $Res Function(_TemplateCategoryDto) _then) = __$TemplateCategoryDtoCopyWithImpl;
@override @useResult
$Res call({
 String name, int position, List<TemplateChannelDto> channels
});




}
/// @nodoc
class __$TemplateCategoryDtoCopyWithImpl<$Res>
    implements _$TemplateCategoryDtoCopyWith<$Res> {
  __$TemplateCategoryDtoCopyWithImpl(this._self, this._then);

  final _TemplateCategoryDto _self;
  final $Res Function(_TemplateCategoryDto) _then;

/// Create a copy of TemplateCategoryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? position = null,Object? channels = null,}) {
  return _then(_TemplateCategoryDto(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,channels: null == channels ? _self._channels : channels // ignore: cast_nullable_to_non_nullable
as List<TemplateChannelDto>,
  ));
}


}


/// @nodoc
mixin _$TemplateRoleDto {

 String get name; String get color; int get position; int get permissions;
/// Create a copy of TemplateRoleDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TemplateRoleDtoCopyWith<TemplateRoleDto> get copyWith => _$TemplateRoleDtoCopyWithImpl<TemplateRoleDto>(this as TemplateRoleDto, _$identity);

  /// Serializes this TemplateRoleDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TemplateRoleDto&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&(identical(other.position, position) || other.position == position)&&(identical(other.permissions, permissions) || other.permissions == permissions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,color,position,permissions);

@override
String toString() {
  return 'TemplateRoleDto(name: $name, color: $color, position: $position, permissions: $permissions)';
}


}

/// @nodoc
abstract mixin class $TemplateRoleDtoCopyWith<$Res>  {
  factory $TemplateRoleDtoCopyWith(TemplateRoleDto value, $Res Function(TemplateRoleDto) _then) = _$TemplateRoleDtoCopyWithImpl;
@useResult
$Res call({
 String name, String color, int position, int permissions
});




}
/// @nodoc
class _$TemplateRoleDtoCopyWithImpl<$Res>
    implements $TemplateRoleDtoCopyWith<$Res> {
  _$TemplateRoleDtoCopyWithImpl(this._self, this._then);

  final TemplateRoleDto _self;
  final $Res Function(TemplateRoleDto) _then;

/// Create a copy of TemplateRoleDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? color = null,Object? position = null,Object? permissions = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TemplateRoleDto].
extension TemplateRoleDtoPatterns on TemplateRoleDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TemplateRoleDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TemplateRoleDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TemplateRoleDto value)  $default,){
final _that = this;
switch (_that) {
case _TemplateRoleDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TemplateRoleDto value)?  $default,){
final _that = this;
switch (_that) {
case _TemplateRoleDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String color,  int position,  int permissions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TemplateRoleDto() when $default != null:
return $default(_that.name,_that.color,_that.position,_that.permissions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String color,  int position,  int permissions)  $default,) {final _that = this;
switch (_that) {
case _TemplateRoleDto():
return $default(_that.name,_that.color,_that.position,_that.permissions);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String color,  int position,  int permissions)?  $default,) {final _that = this;
switch (_that) {
case _TemplateRoleDto() when $default != null:
return $default(_that.name,_that.color,_that.position,_that.permissions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TemplateRoleDto implements TemplateRoleDto {
  const _TemplateRoleDto({required this.name, required this.color, this.position = 0, this.permissions = 0});
  factory _TemplateRoleDto.fromJson(Map<String, dynamic> json) => _$TemplateRoleDtoFromJson(json);

@override final  String name;
@override final  String color;
@override@JsonKey() final  int position;
@override@JsonKey() final  int permissions;

/// Create a copy of TemplateRoleDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TemplateRoleDtoCopyWith<_TemplateRoleDto> get copyWith => __$TemplateRoleDtoCopyWithImpl<_TemplateRoleDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TemplateRoleDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TemplateRoleDto&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&(identical(other.position, position) || other.position == position)&&(identical(other.permissions, permissions) || other.permissions == permissions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,color,position,permissions);

@override
String toString() {
  return 'TemplateRoleDto(name: $name, color: $color, position: $position, permissions: $permissions)';
}


}

/// @nodoc
abstract mixin class _$TemplateRoleDtoCopyWith<$Res> implements $TemplateRoleDtoCopyWith<$Res> {
  factory _$TemplateRoleDtoCopyWith(_TemplateRoleDto value, $Res Function(_TemplateRoleDto) _then) = __$TemplateRoleDtoCopyWithImpl;
@override @useResult
$Res call({
 String name, String color, int position, int permissions
});




}
/// @nodoc
class __$TemplateRoleDtoCopyWithImpl<$Res>
    implements _$TemplateRoleDtoCopyWith<$Res> {
  __$TemplateRoleDtoCopyWithImpl(this._self, this._then);

  final _TemplateRoleDto _self;
  final $Res Function(_TemplateRoleDto) _then;

/// Create a copy of TemplateRoleDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? color = null,Object? position = null,Object? permissions = null,}) {
  return _then(_TemplateRoleDto(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TemplateSnapshotDto {

 List<TemplateRoleDto> get roles; List<TemplateCategoryDto> get categories; List<TemplateChannelDto> get uncategorizedChannels;
/// Create a copy of TemplateSnapshotDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TemplateSnapshotDtoCopyWith<TemplateSnapshotDto> get copyWith => _$TemplateSnapshotDtoCopyWithImpl<TemplateSnapshotDto>(this as TemplateSnapshotDto, _$identity);

  /// Serializes this TemplateSnapshotDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TemplateSnapshotDto&&const DeepCollectionEquality().equals(other.roles, roles)&&const DeepCollectionEquality().equals(other.categories, categories)&&const DeepCollectionEquality().equals(other.uncategorizedChannels, uncategorizedChannels));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(roles),const DeepCollectionEquality().hash(categories),const DeepCollectionEquality().hash(uncategorizedChannels));

@override
String toString() {
  return 'TemplateSnapshotDto(roles: $roles, categories: $categories, uncategorizedChannels: $uncategorizedChannels)';
}


}

/// @nodoc
abstract mixin class $TemplateSnapshotDtoCopyWith<$Res>  {
  factory $TemplateSnapshotDtoCopyWith(TemplateSnapshotDto value, $Res Function(TemplateSnapshotDto) _then) = _$TemplateSnapshotDtoCopyWithImpl;
@useResult
$Res call({
 List<TemplateRoleDto> roles, List<TemplateCategoryDto> categories, List<TemplateChannelDto> uncategorizedChannels
});




}
/// @nodoc
class _$TemplateSnapshotDtoCopyWithImpl<$Res>
    implements $TemplateSnapshotDtoCopyWith<$Res> {
  _$TemplateSnapshotDtoCopyWithImpl(this._self, this._then);

  final TemplateSnapshotDto _self;
  final $Res Function(TemplateSnapshotDto) _then;

/// Create a copy of TemplateSnapshotDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? roles = null,Object? categories = null,Object? uncategorizedChannels = null,}) {
  return _then(_self.copyWith(
roles: null == roles ? _self.roles : roles // ignore: cast_nullable_to_non_nullable
as List<TemplateRoleDto>,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<TemplateCategoryDto>,uncategorizedChannels: null == uncategorizedChannels ? _self.uncategorizedChannels : uncategorizedChannels // ignore: cast_nullable_to_non_nullable
as List<TemplateChannelDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [TemplateSnapshotDto].
extension TemplateSnapshotDtoPatterns on TemplateSnapshotDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TemplateSnapshotDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TemplateSnapshotDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TemplateSnapshotDto value)  $default,){
final _that = this;
switch (_that) {
case _TemplateSnapshotDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TemplateSnapshotDto value)?  $default,){
final _that = this;
switch (_that) {
case _TemplateSnapshotDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TemplateRoleDto> roles,  List<TemplateCategoryDto> categories,  List<TemplateChannelDto> uncategorizedChannels)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TemplateSnapshotDto() when $default != null:
return $default(_that.roles,_that.categories,_that.uncategorizedChannels);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TemplateRoleDto> roles,  List<TemplateCategoryDto> categories,  List<TemplateChannelDto> uncategorizedChannels)  $default,) {final _that = this;
switch (_that) {
case _TemplateSnapshotDto():
return $default(_that.roles,_that.categories,_that.uncategorizedChannels);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TemplateRoleDto> roles,  List<TemplateCategoryDto> categories,  List<TemplateChannelDto> uncategorizedChannels)?  $default,) {final _that = this;
switch (_that) {
case _TemplateSnapshotDto() when $default != null:
return $default(_that.roles,_that.categories,_that.uncategorizedChannels);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TemplateSnapshotDto implements TemplateSnapshotDto {
  const _TemplateSnapshotDto({final  List<TemplateRoleDto> roles = const [], final  List<TemplateCategoryDto> categories = const [], final  List<TemplateChannelDto> uncategorizedChannels = const []}): _roles = roles,_categories = categories,_uncategorizedChannels = uncategorizedChannels;
  factory _TemplateSnapshotDto.fromJson(Map<String, dynamic> json) => _$TemplateSnapshotDtoFromJson(json);

 final  List<TemplateRoleDto> _roles;
@override@JsonKey() List<TemplateRoleDto> get roles {
  if (_roles is EqualUnmodifiableListView) return _roles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roles);
}

 final  List<TemplateCategoryDto> _categories;
@override@JsonKey() List<TemplateCategoryDto> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

 final  List<TemplateChannelDto> _uncategorizedChannels;
@override@JsonKey() List<TemplateChannelDto> get uncategorizedChannels {
  if (_uncategorizedChannels is EqualUnmodifiableListView) return _uncategorizedChannels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_uncategorizedChannels);
}


/// Create a copy of TemplateSnapshotDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TemplateSnapshotDtoCopyWith<_TemplateSnapshotDto> get copyWith => __$TemplateSnapshotDtoCopyWithImpl<_TemplateSnapshotDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TemplateSnapshotDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TemplateSnapshotDto&&const DeepCollectionEquality().equals(other._roles, _roles)&&const DeepCollectionEquality().equals(other._categories, _categories)&&const DeepCollectionEquality().equals(other._uncategorizedChannels, _uncategorizedChannels));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_roles),const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_uncategorizedChannels));

@override
String toString() {
  return 'TemplateSnapshotDto(roles: $roles, categories: $categories, uncategorizedChannels: $uncategorizedChannels)';
}


}

/// @nodoc
abstract mixin class _$TemplateSnapshotDtoCopyWith<$Res> implements $TemplateSnapshotDtoCopyWith<$Res> {
  factory _$TemplateSnapshotDtoCopyWith(_TemplateSnapshotDto value, $Res Function(_TemplateSnapshotDto) _then) = __$TemplateSnapshotDtoCopyWithImpl;
@override @useResult
$Res call({
 List<TemplateRoleDto> roles, List<TemplateCategoryDto> categories, List<TemplateChannelDto> uncategorizedChannels
});




}
/// @nodoc
class __$TemplateSnapshotDtoCopyWithImpl<$Res>
    implements _$TemplateSnapshotDtoCopyWith<$Res> {
  __$TemplateSnapshotDtoCopyWithImpl(this._self, this._then);

  final _TemplateSnapshotDto _self;
  final $Res Function(_TemplateSnapshotDto) _then;

/// Create a copy of TemplateSnapshotDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? roles = null,Object? categories = null,Object? uncategorizedChannels = null,}) {
  return _then(_TemplateSnapshotDto(
roles: null == roles ? _self._roles : roles // ignore: cast_nullable_to_non_nullable
as List<TemplateRoleDto>,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<TemplateCategoryDto>,uncategorizedChannels: null == uncategorizedChannels ? _self._uncategorizedChannels : uncategorizedChannels // ignore: cast_nullable_to_non_nullable
as List<TemplateChannelDto>,
  ));
}


}


/// @nodoc
mixin _$GuildTemplateDetailDto {

 String get id; String get name; String? get description; String get creatorUserId; DateTime get createdAt; int get usageCount; TemplateSnapshotDto get snapshot;
/// Create a copy of GuildTemplateDetailDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuildTemplateDetailDtoCopyWith<GuildTemplateDetailDto> get copyWith => _$GuildTemplateDetailDtoCopyWithImpl<GuildTemplateDetailDto>(this as GuildTemplateDetailDto, _$identity);

  /// Serializes this GuildTemplateDetailDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuildTemplateDetailDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.creatorUserId, creatorUserId) || other.creatorUserId == creatorUserId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.usageCount, usageCount) || other.usageCount == usageCount)&&(identical(other.snapshot, snapshot) || other.snapshot == snapshot));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,creatorUserId,createdAt,usageCount,snapshot);

@override
String toString() {
  return 'GuildTemplateDetailDto(id: $id, name: $name, description: $description, creatorUserId: $creatorUserId, createdAt: $createdAt, usageCount: $usageCount, snapshot: $snapshot)';
}


}

/// @nodoc
abstract mixin class $GuildTemplateDetailDtoCopyWith<$Res>  {
  factory $GuildTemplateDetailDtoCopyWith(GuildTemplateDetailDto value, $Res Function(GuildTemplateDetailDto) _then) = _$GuildTemplateDetailDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, String creatorUserId, DateTime createdAt, int usageCount, TemplateSnapshotDto snapshot
});


$TemplateSnapshotDtoCopyWith<$Res> get snapshot;

}
/// @nodoc
class _$GuildTemplateDetailDtoCopyWithImpl<$Res>
    implements $GuildTemplateDetailDtoCopyWith<$Res> {
  _$GuildTemplateDetailDtoCopyWithImpl(this._self, this._then);

  final GuildTemplateDetailDto _self;
  final $Res Function(GuildTemplateDetailDto) _then;

/// Create a copy of GuildTemplateDetailDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? creatorUserId = null,Object? createdAt = null,Object? usageCount = null,Object? snapshot = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,creatorUserId: null == creatorUserId ? _self.creatorUserId : creatorUserId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,usageCount: null == usageCount ? _self.usageCount : usageCount // ignore: cast_nullable_to_non_nullable
as int,snapshot: null == snapshot ? _self.snapshot : snapshot // ignore: cast_nullable_to_non_nullable
as TemplateSnapshotDto,
  ));
}
/// Create a copy of GuildTemplateDetailDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TemplateSnapshotDtoCopyWith<$Res> get snapshot {
  
  return $TemplateSnapshotDtoCopyWith<$Res>(_self.snapshot, (value) {
    return _then(_self.copyWith(snapshot: value));
  });
}
}


/// Adds pattern-matching-related methods to [GuildTemplateDetailDto].
extension GuildTemplateDetailDtoPatterns on GuildTemplateDetailDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuildTemplateDetailDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuildTemplateDetailDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuildTemplateDetailDto value)  $default,){
final _that = this;
switch (_that) {
case _GuildTemplateDetailDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuildTemplateDetailDto value)?  $default,){
final _that = this;
switch (_that) {
case _GuildTemplateDetailDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String creatorUserId,  DateTime createdAt,  int usageCount,  TemplateSnapshotDto snapshot)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuildTemplateDetailDto() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.creatorUserId,_that.createdAt,_that.usageCount,_that.snapshot);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String creatorUserId,  DateTime createdAt,  int usageCount,  TemplateSnapshotDto snapshot)  $default,) {final _that = this;
switch (_that) {
case _GuildTemplateDetailDto():
return $default(_that.id,_that.name,_that.description,_that.creatorUserId,_that.createdAt,_that.usageCount,_that.snapshot);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  String creatorUserId,  DateTime createdAt,  int usageCount,  TemplateSnapshotDto snapshot)?  $default,) {final _that = this;
switch (_that) {
case _GuildTemplateDetailDto() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.creatorUserId,_that.createdAt,_that.usageCount,_that.snapshot);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GuildTemplateDetailDto implements GuildTemplateDetailDto {
  const _GuildTemplateDetailDto({required this.id, required this.name, this.description, required this.creatorUserId, required this.createdAt, this.usageCount = 0, required this.snapshot});
  factory _GuildTemplateDetailDto.fromJson(Map<String, dynamic> json) => _$GuildTemplateDetailDtoFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override final  String creatorUserId;
@override final  DateTime createdAt;
@override@JsonKey() final  int usageCount;
@override final  TemplateSnapshotDto snapshot;

/// Create a copy of GuildTemplateDetailDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuildTemplateDetailDtoCopyWith<_GuildTemplateDetailDto> get copyWith => __$GuildTemplateDetailDtoCopyWithImpl<_GuildTemplateDetailDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GuildTemplateDetailDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuildTemplateDetailDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.creatorUserId, creatorUserId) || other.creatorUserId == creatorUserId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.usageCount, usageCount) || other.usageCount == usageCount)&&(identical(other.snapshot, snapshot) || other.snapshot == snapshot));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,creatorUserId,createdAt,usageCount,snapshot);

@override
String toString() {
  return 'GuildTemplateDetailDto(id: $id, name: $name, description: $description, creatorUserId: $creatorUserId, createdAt: $createdAt, usageCount: $usageCount, snapshot: $snapshot)';
}


}

/// @nodoc
abstract mixin class _$GuildTemplateDetailDtoCopyWith<$Res> implements $GuildTemplateDetailDtoCopyWith<$Res> {
  factory _$GuildTemplateDetailDtoCopyWith(_GuildTemplateDetailDto value, $Res Function(_GuildTemplateDetailDto) _then) = __$GuildTemplateDetailDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, String creatorUserId, DateTime createdAt, int usageCount, TemplateSnapshotDto snapshot
});


@override $TemplateSnapshotDtoCopyWith<$Res> get snapshot;

}
/// @nodoc
class __$GuildTemplateDetailDtoCopyWithImpl<$Res>
    implements _$GuildTemplateDetailDtoCopyWith<$Res> {
  __$GuildTemplateDetailDtoCopyWithImpl(this._self, this._then);

  final _GuildTemplateDetailDto _self;
  final $Res Function(_GuildTemplateDetailDto) _then;

/// Create a copy of GuildTemplateDetailDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? creatorUserId = null,Object? createdAt = null,Object? usageCount = null,Object? snapshot = null,}) {
  return _then(_GuildTemplateDetailDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,creatorUserId: null == creatorUserId ? _self.creatorUserId : creatorUserId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,usageCount: null == usageCount ? _self.usageCount : usageCount // ignore: cast_nullable_to_non_nullable
as int,snapshot: null == snapshot ? _self.snapshot : snapshot // ignore: cast_nullable_to_non_nullable
as TemplateSnapshotDto,
  ));
}

/// Create a copy of GuildTemplateDetailDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TemplateSnapshotDtoCopyWith<$Res> get snapshot {
  
  return $TemplateSnapshotDtoCopyWith<$Res>(_self.snapshot, (value) {
    return _then(_self.copyWith(snapshot: value));
  });
}
}

// dart format on
