// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bot_command_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BotCommandOptionDto {

 String get name; String? get description; BotCommandOptionType get type; bool get required;
/// Create a copy of BotCommandOptionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BotCommandOptionDtoCopyWith<BotCommandOptionDto> get copyWith => _$BotCommandOptionDtoCopyWithImpl<BotCommandOptionDto>(this as BotCommandOptionDto, _$identity);

  /// Serializes this BotCommandOptionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BotCommandOptionDto&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.required, required) || other.required == required));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,description,type,required);

@override
String toString() {
  return 'BotCommandOptionDto(name: $name, description: $description, type: $type, required: $required)';
}


}

/// @nodoc
abstract mixin class $BotCommandOptionDtoCopyWith<$Res>  {
  factory $BotCommandOptionDtoCopyWith(BotCommandOptionDto value, $Res Function(BotCommandOptionDto) _then) = _$BotCommandOptionDtoCopyWithImpl;
@useResult
$Res call({
 String name, String? description, BotCommandOptionType type, bool required
});




}
/// @nodoc
class _$BotCommandOptionDtoCopyWithImpl<$Res>
    implements $BotCommandOptionDtoCopyWith<$Res> {
  _$BotCommandOptionDtoCopyWithImpl(this._self, this._then);

  final BotCommandOptionDto _self;
  final $Res Function(BotCommandOptionDto) _then;

/// Create a copy of BotCommandOptionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? description = freezed,Object? type = null,Object? required = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as BotCommandOptionType,required: null == required ? _self.required : required // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [BotCommandOptionDto].
extension BotCommandOptionDtoPatterns on BotCommandOptionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BotCommandOptionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BotCommandOptionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BotCommandOptionDto value)  $default,){
final _that = this;
switch (_that) {
case _BotCommandOptionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BotCommandOptionDto value)?  $default,){
final _that = this;
switch (_that) {
case _BotCommandOptionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String? description,  BotCommandOptionType type,  bool required)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BotCommandOptionDto() when $default != null:
return $default(_that.name,_that.description,_that.type,_that.required);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String? description,  BotCommandOptionType type,  bool required)  $default,) {final _that = this;
switch (_that) {
case _BotCommandOptionDto():
return $default(_that.name,_that.description,_that.type,_that.required);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String? description,  BotCommandOptionType type,  bool required)?  $default,) {final _that = this;
switch (_that) {
case _BotCommandOptionDto() when $default != null:
return $default(_that.name,_that.description,_that.type,_that.required);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BotCommandOptionDto implements BotCommandOptionDto {
  const _BotCommandOptionDto({required this.name, this.description, this.type = BotCommandOptionType.string, this.required = false});
  factory _BotCommandOptionDto.fromJson(Map<String, dynamic> json) => _$BotCommandOptionDtoFromJson(json);

@override final  String name;
@override final  String? description;
@override@JsonKey() final  BotCommandOptionType type;
@override@JsonKey() final  bool required;

/// Create a copy of BotCommandOptionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BotCommandOptionDtoCopyWith<_BotCommandOptionDto> get copyWith => __$BotCommandOptionDtoCopyWithImpl<_BotCommandOptionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BotCommandOptionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BotCommandOptionDto&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.required, required) || other.required == required));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,description,type,required);

@override
String toString() {
  return 'BotCommandOptionDto(name: $name, description: $description, type: $type, required: $required)';
}


}

/// @nodoc
abstract mixin class _$BotCommandOptionDtoCopyWith<$Res> implements $BotCommandOptionDtoCopyWith<$Res> {
  factory _$BotCommandOptionDtoCopyWith(_BotCommandOptionDto value, $Res Function(_BotCommandOptionDto) _then) = __$BotCommandOptionDtoCopyWithImpl;
@override @useResult
$Res call({
 String name, String? description, BotCommandOptionType type, bool required
});




}
/// @nodoc
class __$BotCommandOptionDtoCopyWithImpl<$Res>
    implements _$BotCommandOptionDtoCopyWith<$Res> {
  __$BotCommandOptionDtoCopyWithImpl(this._self, this._then);

  final _BotCommandOptionDto _self;
  final $Res Function(_BotCommandOptionDto) _then;

/// Create a copy of BotCommandOptionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? description = freezed,Object? type = null,Object? required = null,}) {
  return _then(_BotCommandOptionDto(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as BotCommandOptionType,required: null == required ? _self.required : required // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$BotCommandDto {

 String get botUserId; String get botName; String get name; String? get description; List<BotCommandOptionDto> get options; String? get scope;
/// Create a copy of BotCommandDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BotCommandDtoCopyWith<BotCommandDto> get copyWith => _$BotCommandDtoCopyWithImpl<BotCommandDto>(this as BotCommandDto, _$identity);

  /// Serializes this BotCommandDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BotCommandDto&&(identical(other.botUserId, botUserId) || other.botUserId == botUserId)&&(identical(other.botName, botName) || other.botName == botName)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.options, options)&&(identical(other.scope, scope) || other.scope == scope));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,botUserId,botName,name,description,const DeepCollectionEquality().hash(options),scope);

@override
String toString() {
  return 'BotCommandDto(botUserId: $botUserId, botName: $botName, name: $name, description: $description, options: $options, scope: $scope)';
}


}

/// @nodoc
abstract mixin class $BotCommandDtoCopyWith<$Res>  {
  factory $BotCommandDtoCopyWith(BotCommandDto value, $Res Function(BotCommandDto) _then) = _$BotCommandDtoCopyWithImpl;
@useResult
$Res call({
 String botUserId, String botName, String name, String? description, List<BotCommandOptionDto> options, String? scope
});




}
/// @nodoc
class _$BotCommandDtoCopyWithImpl<$Res>
    implements $BotCommandDtoCopyWith<$Res> {
  _$BotCommandDtoCopyWithImpl(this._self, this._then);

  final BotCommandDto _self;
  final $Res Function(BotCommandDto) _then;

/// Create a copy of BotCommandDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? botUserId = null,Object? botName = null,Object? name = null,Object? description = freezed,Object? options = null,Object? scope = freezed,}) {
  return _then(_self.copyWith(
botUserId: null == botUserId ? _self.botUserId : botUserId // ignore: cast_nullable_to_non_nullable
as String,botName: null == botName ? _self.botName : botName // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as List<BotCommandOptionDto>,scope: freezed == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BotCommandDto].
extension BotCommandDtoPatterns on BotCommandDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BotCommandDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BotCommandDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BotCommandDto value)  $default,){
final _that = this;
switch (_that) {
case _BotCommandDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BotCommandDto value)?  $default,){
final _that = this;
switch (_that) {
case _BotCommandDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String botUserId,  String botName,  String name,  String? description,  List<BotCommandOptionDto> options,  String? scope)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BotCommandDto() when $default != null:
return $default(_that.botUserId,_that.botName,_that.name,_that.description,_that.options,_that.scope);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String botUserId,  String botName,  String name,  String? description,  List<BotCommandOptionDto> options,  String? scope)  $default,) {final _that = this;
switch (_that) {
case _BotCommandDto():
return $default(_that.botUserId,_that.botName,_that.name,_that.description,_that.options,_that.scope);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String botUserId,  String botName,  String name,  String? description,  List<BotCommandOptionDto> options,  String? scope)?  $default,) {final _that = this;
switch (_that) {
case _BotCommandDto() when $default != null:
return $default(_that.botUserId,_that.botName,_that.name,_that.description,_that.options,_that.scope);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BotCommandDto implements BotCommandDto {
  const _BotCommandDto({required this.botUserId, required this.botName, required this.name, this.description, final  List<BotCommandOptionDto> options = const <BotCommandOptionDto>[], this.scope}): _options = options;
  factory _BotCommandDto.fromJson(Map<String, dynamic> json) => _$BotCommandDtoFromJson(json);

@override final  String botUserId;
@override final  String botName;
@override final  String name;
@override final  String? description;
 final  List<BotCommandOptionDto> _options;
@override@JsonKey() List<BotCommandOptionDto> get options {
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_options);
}

@override final  String? scope;

/// Create a copy of BotCommandDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BotCommandDtoCopyWith<_BotCommandDto> get copyWith => __$BotCommandDtoCopyWithImpl<_BotCommandDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BotCommandDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BotCommandDto&&(identical(other.botUserId, botUserId) || other.botUserId == botUserId)&&(identical(other.botName, botName) || other.botName == botName)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._options, _options)&&(identical(other.scope, scope) || other.scope == scope));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,botUserId,botName,name,description,const DeepCollectionEquality().hash(_options),scope);

@override
String toString() {
  return 'BotCommandDto(botUserId: $botUserId, botName: $botName, name: $name, description: $description, options: $options, scope: $scope)';
}


}

/// @nodoc
abstract mixin class _$BotCommandDtoCopyWith<$Res> implements $BotCommandDtoCopyWith<$Res> {
  factory _$BotCommandDtoCopyWith(_BotCommandDto value, $Res Function(_BotCommandDto) _then) = __$BotCommandDtoCopyWithImpl;
@override @useResult
$Res call({
 String botUserId, String botName, String name, String? description, List<BotCommandOptionDto> options, String? scope
});




}
/// @nodoc
class __$BotCommandDtoCopyWithImpl<$Res>
    implements _$BotCommandDtoCopyWith<$Res> {
  __$BotCommandDtoCopyWithImpl(this._self, this._then);

  final _BotCommandDto _self;
  final $Res Function(_BotCommandDto) _then;

/// Create a copy of BotCommandDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? botUserId = null,Object? botName = null,Object? name = null,Object? description = freezed,Object? options = null,Object? scope = freezed,}) {
  return _then(_BotCommandDto(
botUserId: null == botUserId ? _self.botUserId : botUserId // ignore: cast_nullable_to_non_nullable
as String,botName: null == botName ? _self.botName : botName // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,options: null == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<BotCommandOptionDto>,scope: freezed == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
