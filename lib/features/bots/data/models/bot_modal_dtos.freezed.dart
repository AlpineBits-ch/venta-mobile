// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bot_modal_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BotComponentDto {

/// Absent or unreadable means 0, which matches no known type and therefore
/// renders as unsupported - see `toModalField`.
@JsonKey(readValue: readBotPayloadKey) int get type;/// Set only on an action row, which is the sole container type.
@JsonKey(readValue: readBotPayloadKey) List<BotComponentDto> get components;/// The bot's own handle for this component, echoed back verbatim when the
/// user answers. A text input without one is unanswerable: there is nothing
/// to key the typed value on.
@JsonKey(name: 'custom_id', readValue: readBotPayloadKey) String? get customId;@JsonKey(readValue: readBotPayloadKey) String? get label;/// Button style 1-5; on a text input, 1 is single-line and 2 is a paragraph
/// box.
@JsonKey(readValue: readBotPayloadKey) int? get style;@JsonKey(readValue: readBotPayloadKey) String? get placeholder;/// Whatever the bot prefilled the field with.
@JsonKey(readValue: readBotPayloadKey) String? get value;/// Named around the keyword: `required` is a Dart modifier and cannot be a
/// parameter name here, so the wire name is pinned with [JsonKey] instead.
@JsonKey(name: 'required', readValue: readBotPayloadKey) bool get isRequired;@JsonKey(name: 'min_length', readValue: readBotPayloadKey) int? get minLength;@JsonKey(name: 'max_length', readValue: readBotPayloadKey) int? get maxLength;
/// Create a copy of BotComponentDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BotComponentDtoCopyWith<BotComponentDto> get copyWith => _$BotComponentDtoCopyWithImpl<BotComponentDto>(this as BotComponentDto, _$identity);

  /// Serializes this BotComponentDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BotComponentDto&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.components, components)&&(identical(other.customId, customId) || other.customId == customId)&&(identical(other.label, label) || other.label == label)&&(identical(other.style, style) || other.style == style)&&(identical(other.placeholder, placeholder) || other.placeholder == placeholder)&&(identical(other.value, value) || other.value == value)&&(identical(other.isRequired, isRequired) || other.isRequired == isRequired)&&(identical(other.minLength, minLength) || other.minLength == minLength)&&(identical(other.maxLength, maxLength) || other.maxLength == maxLength));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(components),customId,label,style,placeholder,value,isRequired,minLength,maxLength);

@override
String toString() {
  return 'BotComponentDto(type: $type, components: $components, customId: $customId, label: $label, style: $style, placeholder: $placeholder, value: $value, isRequired: $isRequired, minLength: $minLength, maxLength: $maxLength)';
}


}

/// @nodoc
abstract mixin class $BotComponentDtoCopyWith<$Res>  {
  factory $BotComponentDtoCopyWith(BotComponentDto value, $Res Function(BotComponentDto) _then) = _$BotComponentDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(readValue: readBotPayloadKey) int type,@JsonKey(readValue: readBotPayloadKey) List<BotComponentDto> components,@JsonKey(name: 'custom_id', readValue: readBotPayloadKey) String? customId,@JsonKey(readValue: readBotPayloadKey) String? label,@JsonKey(readValue: readBotPayloadKey) int? style,@JsonKey(readValue: readBotPayloadKey) String? placeholder,@JsonKey(readValue: readBotPayloadKey) String? value,@JsonKey(name: 'required', readValue: readBotPayloadKey) bool isRequired,@JsonKey(name: 'min_length', readValue: readBotPayloadKey) int? minLength,@JsonKey(name: 'max_length', readValue: readBotPayloadKey) int? maxLength
});




}
/// @nodoc
class _$BotComponentDtoCopyWithImpl<$Res>
    implements $BotComponentDtoCopyWith<$Res> {
  _$BotComponentDtoCopyWithImpl(this._self, this._then);

  final BotComponentDto _self;
  final $Res Function(BotComponentDto) _then;

/// Create a copy of BotComponentDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? components = null,Object? customId = freezed,Object? label = freezed,Object? style = freezed,Object? placeholder = freezed,Object? value = freezed,Object? isRequired = null,Object? minLength = freezed,Object? maxLength = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,components: null == components ? _self.components : components // ignore: cast_nullable_to_non_nullable
as List<BotComponentDto>,customId: freezed == customId ? _self.customId : customId // ignore: cast_nullable_to_non_nullable
as String?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,style: freezed == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as int?,placeholder: freezed == placeholder ? _self.placeholder : placeholder // ignore: cast_nullable_to_non_nullable
as String?,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,isRequired: null == isRequired ? _self.isRequired : isRequired // ignore: cast_nullable_to_non_nullable
as bool,minLength: freezed == minLength ? _self.minLength : minLength // ignore: cast_nullable_to_non_nullable
as int?,maxLength: freezed == maxLength ? _self.maxLength : maxLength // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [BotComponentDto].
extension BotComponentDtoPatterns on BotComponentDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BotComponentDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BotComponentDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BotComponentDto value)  $default,){
final _that = this;
switch (_that) {
case _BotComponentDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BotComponentDto value)?  $default,){
final _that = this;
switch (_that) {
case _BotComponentDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(readValue: readBotPayloadKey)  int type, @JsonKey(readValue: readBotPayloadKey)  List<BotComponentDto> components, @JsonKey(name: 'custom_id', readValue: readBotPayloadKey)  String? customId, @JsonKey(readValue: readBotPayloadKey)  String? label, @JsonKey(readValue: readBotPayloadKey)  int? style, @JsonKey(readValue: readBotPayloadKey)  String? placeholder, @JsonKey(readValue: readBotPayloadKey)  String? value, @JsonKey(name: 'required', readValue: readBotPayloadKey)  bool isRequired, @JsonKey(name: 'min_length', readValue: readBotPayloadKey)  int? minLength, @JsonKey(name: 'max_length', readValue: readBotPayloadKey)  int? maxLength)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BotComponentDto() when $default != null:
return $default(_that.type,_that.components,_that.customId,_that.label,_that.style,_that.placeholder,_that.value,_that.isRequired,_that.minLength,_that.maxLength);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(readValue: readBotPayloadKey)  int type, @JsonKey(readValue: readBotPayloadKey)  List<BotComponentDto> components, @JsonKey(name: 'custom_id', readValue: readBotPayloadKey)  String? customId, @JsonKey(readValue: readBotPayloadKey)  String? label, @JsonKey(readValue: readBotPayloadKey)  int? style, @JsonKey(readValue: readBotPayloadKey)  String? placeholder, @JsonKey(readValue: readBotPayloadKey)  String? value, @JsonKey(name: 'required', readValue: readBotPayloadKey)  bool isRequired, @JsonKey(name: 'min_length', readValue: readBotPayloadKey)  int? minLength, @JsonKey(name: 'max_length', readValue: readBotPayloadKey)  int? maxLength)  $default,) {final _that = this;
switch (_that) {
case _BotComponentDto():
return $default(_that.type,_that.components,_that.customId,_that.label,_that.style,_that.placeholder,_that.value,_that.isRequired,_that.minLength,_that.maxLength);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(readValue: readBotPayloadKey)  int type, @JsonKey(readValue: readBotPayloadKey)  List<BotComponentDto> components, @JsonKey(name: 'custom_id', readValue: readBotPayloadKey)  String? customId, @JsonKey(readValue: readBotPayloadKey)  String? label, @JsonKey(readValue: readBotPayloadKey)  int? style, @JsonKey(readValue: readBotPayloadKey)  String? placeholder, @JsonKey(readValue: readBotPayloadKey)  String? value, @JsonKey(name: 'required', readValue: readBotPayloadKey)  bool isRequired, @JsonKey(name: 'min_length', readValue: readBotPayloadKey)  int? minLength, @JsonKey(name: 'max_length', readValue: readBotPayloadKey)  int? maxLength)?  $default,) {final _that = this;
switch (_that) {
case _BotComponentDto() when $default != null:
return $default(_that.type,_that.components,_that.customId,_that.label,_that.style,_that.placeholder,_that.value,_that.isRequired,_that.minLength,_that.maxLength);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BotComponentDto implements BotComponentDto {
  const _BotComponentDto({@JsonKey(readValue: readBotPayloadKey) this.type = 0, @JsonKey(readValue: readBotPayloadKey) final  List<BotComponentDto> components = const <BotComponentDto>[], @JsonKey(name: 'custom_id', readValue: readBotPayloadKey) this.customId, @JsonKey(readValue: readBotPayloadKey) this.label, @JsonKey(readValue: readBotPayloadKey) this.style, @JsonKey(readValue: readBotPayloadKey) this.placeholder, @JsonKey(readValue: readBotPayloadKey) this.value, @JsonKey(name: 'required', readValue: readBotPayloadKey) this.isRequired = false, @JsonKey(name: 'min_length', readValue: readBotPayloadKey) this.minLength, @JsonKey(name: 'max_length', readValue: readBotPayloadKey) this.maxLength}): _components = components;
  factory _BotComponentDto.fromJson(Map<String, dynamic> json) => _$BotComponentDtoFromJson(json);

/// Absent or unreadable means 0, which matches no known type and therefore
/// renders as unsupported - see `toModalField`.
@override@JsonKey(readValue: readBotPayloadKey) final  int type;
/// Set only on an action row, which is the sole container type.
 final  List<BotComponentDto> _components;
/// Set only on an action row, which is the sole container type.
@override@JsonKey(readValue: readBotPayloadKey) List<BotComponentDto> get components {
  if (_components is EqualUnmodifiableListView) return _components;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_components);
}

/// The bot's own handle for this component, echoed back verbatim when the
/// user answers. A text input without one is unanswerable: there is nothing
/// to key the typed value on.
@override@JsonKey(name: 'custom_id', readValue: readBotPayloadKey) final  String? customId;
@override@JsonKey(readValue: readBotPayloadKey) final  String? label;
/// Button style 1-5; on a text input, 1 is single-line and 2 is a paragraph
/// box.
@override@JsonKey(readValue: readBotPayloadKey) final  int? style;
@override@JsonKey(readValue: readBotPayloadKey) final  String? placeholder;
/// Whatever the bot prefilled the field with.
@override@JsonKey(readValue: readBotPayloadKey) final  String? value;
/// Named around the keyword: `required` is a Dart modifier and cannot be a
/// parameter name here, so the wire name is pinned with [JsonKey] instead.
@override@JsonKey(name: 'required', readValue: readBotPayloadKey) final  bool isRequired;
@override@JsonKey(name: 'min_length', readValue: readBotPayloadKey) final  int? minLength;
@override@JsonKey(name: 'max_length', readValue: readBotPayloadKey) final  int? maxLength;

/// Create a copy of BotComponentDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BotComponentDtoCopyWith<_BotComponentDto> get copyWith => __$BotComponentDtoCopyWithImpl<_BotComponentDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BotComponentDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BotComponentDto&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._components, _components)&&(identical(other.customId, customId) || other.customId == customId)&&(identical(other.label, label) || other.label == label)&&(identical(other.style, style) || other.style == style)&&(identical(other.placeholder, placeholder) || other.placeholder == placeholder)&&(identical(other.value, value) || other.value == value)&&(identical(other.isRequired, isRequired) || other.isRequired == isRequired)&&(identical(other.minLength, minLength) || other.minLength == minLength)&&(identical(other.maxLength, maxLength) || other.maxLength == maxLength));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(_components),customId,label,style,placeholder,value,isRequired,minLength,maxLength);

@override
String toString() {
  return 'BotComponentDto(type: $type, components: $components, customId: $customId, label: $label, style: $style, placeholder: $placeholder, value: $value, isRequired: $isRequired, minLength: $minLength, maxLength: $maxLength)';
}


}

/// @nodoc
abstract mixin class _$BotComponentDtoCopyWith<$Res> implements $BotComponentDtoCopyWith<$Res> {
  factory _$BotComponentDtoCopyWith(_BotComponentDto value, $Res Function(_BotComponentDto) _then) = __$BotComponentDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(readValue: readBotPayloadKey) int type,@JsonKey(readValue: readBotPayloadKey) List<BotComponentDto> components,@JsonKey(name: 'custom_id', readValue: readBotPayloadKey) String? customId,@JsonKey(readValue: readBotPayloadKey) String? label,@JsonKey(readValue: readBotPayloadKey) int? style,@JsonKey(readValue: readBotPayloadKey) String? placeholder,@JsonKey(readValue: readBotPayloadKey) String? value,@JsonKey(name: 'required', readValue: readBotPayloadKey) bool isRequired,@JsonKey(name: 'min_length', readValue: readBotPayloadKey) int? minLength,@JsonKey(name: 'max_length', readValue: readBotPayloadKey) int? maxLength
});




}
/// @nodoc
class __$BotComponentDtoCopyWithImpl<$Res>
    implements _$BotComponentDtoCopyWith<$Res> {
  __$BotComponentDtoCopyWithImpl(this._self, this._then);

  final _BotComponentDto _self;
  final $Res Function(_BotComponentDto) _then;

/// Create a copy of BotComponentDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? components = null,Object? customId = freezed,Object? label = freezed,Object? style = freezed,Object? placeholder = freezed,Object? value = freezed,Object? isRequired = null,Object? minLength = freezed,Object? maxLength = freezed,}) {
  return _then(_BotComponentDto(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,components: null == components ? _self._components : components // ignore: cast_nullable_to_non_nullable
as List<BotComponentDto>,customId: freezed == customId ? _self.customId : customId // ignore: cast_nullable_to_non_nullable
as String?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,style: freezed == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as int?,placeholder: freezed == placeholder ? _self.placeholder : placeholder // ignore: cast_nullable_to_non_nullable
as String?,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,isRequired: null == isRequired ? _self.isRequired : isRequired // ignore: cast_nullable_to_non_nullable
as bool,minLength: freezed == minLength ? _self.minLength : minLength // ignore: cast_nullable_to_non_nullable
as int?,maxLength: freezed == maxLength ? _self.maxLength : maxLength // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$BotModalOpenDto {

@JsonKey(readValue: readBotPayloadKey) String? get guildId;@JsonKey(readValue: readBotPayloadKey) String get channelId;@JsonKey(readValue: readBotPayloadKey) String get botUserId;@JsonKey(readValue: readBotPayloadKey) String? get customId;@JsonKey(readValue: readBotPayloadKey) String? get title;@JsonKey(readValue: readBotPayloadKey) List<BotComponentDto> get components;
/// Create a copy of BotModalOpenDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BotModalOpenDtoCopyWith<BotModalOpenDto> get copyWith => _$BotModalOpenDtoCopyWithImpl<BotModalOpenDto>(this as BotModalOpenDto, _$identity);

  /// Serializes this BotModalOpenDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BotModalOpenDto&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.botUserId, botUserId) || other.botUserId == botUserId)&&(identical(other.customId, customId) || other.customId == customId)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.components, components));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,guildId,channelId,botUserId,customId,title,const DeepCollectionEquality().hash(components));

@override
String toString() {
  return 'BotModalOpenDto(guildId: $guildId, channelId: $channelId, botUserId: $botUserId, customId: $customId, title: $title, components: $components)';
}


}

/// @nodoc
abstract mixin class $BotModalOpenDtoCopyWith<$Res>  {
  factory $BotModalOpenDtoCopyWith(BotModalOpenDto value, $Res Function(BotModalOpenDto) _then) = _$BotModalOpenDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(readValue: readBotPayloadKey) String? guildId,@JsonKey(readValue: readBotPayloadKey) String channelId,@JsonKey(readValue: readBotPayloadKey) String botUserId,@JsonKey(readValue: readBotPayloadKey) String? customId,@JsonKey(readValue: readBotPayloadKey) String? title,@JsonKey(readValue: readBotPayloadKey) List<BotComponentDto> components
});




}
/// @nodoc
class _$BotModalOpenDtoCopyWithImpl<$Res>
    implements $BotModalOpenDtoCopyWith<$Res> {
  _$BotModalOpenDtoCopyWithImpl(this._self, this._then);

  final BotModalOpenDto _self;
  final $Res Function(BotModalOpenDto) _then;

/// Create a copy of BotModalOpenDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? guildId = freezed,Object? channelId = null,Object? botUserId = null,Object? customId = freezed,Object? title = freezed,Object? components = null,}) {
  return _then(_self.copyWith(
guildId: freezed == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String?,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,botUserId: null == botUserId ? _self.botUserId : botUserId // ignore: cast_nullable_to_non_nullable
as String,customId: freezed == customId ? _self.customId : customId // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,components: null == components ? _self.components : components // ignore: cast_nullable_to_non_nullable
as List<BotComponentDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [BotModalOpenDto].
extension BotModalOpenDtoPatterns on BotModalOpenDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BotModalOpenDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BotModalOpenDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BotModalOpenDto value)  $default,){
final _that = this;
switch (_that) {
case _BotModalOpenDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BotModalOpenDto value)?  $default,){
final _that = this;
switch (_that) {
case _BotModalOpenDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(readValue: readBotPayloadKey)  String? guildId, @JsonKey(readValue: readBotPayloadKey)  String channelId, @JsonKey(readValue: readBotPayloadKey)  String botUserId, @JsonKey(readValue: readBotPayloadKey)  String? customId, @JsonKey(readValue: readBotPayloadKey)  String? title, @JsonKey(readValue: readBotPayloadKey)  List<BotComponentDto> components)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BotModalOpenDto() when $default != null:
return $default(_that.guildId,_that.channelId,_that.botUserId,_that.customId,_that.title,_that.components);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(readValue: readBotPayloadKey)  String? guildId, @JsonKey(readValue: readBotPayloadKey)  String channelId, @JsonKey(readValue: readBotPayloadKey)  String botUserId, @JsonKey(readValue: readBotPayloadKey)  String? customId, @JsonKey(readValue: readBotPayloadKey)  String? title, @JsonKey(readValue: readBotPayloadKey)  List<BotComponentDto> components)  $default,) {final _that = this;
switch (_that) {
case _BotModalOpenDto():
return $default(_that.guildId,_that.channelId,_that.botUserId,_that.customId,_that.title,_that.components);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(readValue: readBotPayloadKey)  String? guildId, @JsonKey(readValue: readBotPayloadKey)  String channelId, @JsonKey(readValue: readBotPayloadKey)  String botUserId, @JsonKey(readValue: readBotPayloadKey)  String? customId, @JsonKey(readValue: readBotPayloadKey)  String? title, @JsonKey(readValue: readBotPayloadKey)  List<BotComponentDto> components)?  $default,) {final _that = this;
switch (_that) {
case _BotModalOpenDto() when $default != null:
return $default(_that.guildId,_that.channelId,_that.botUserId,_that.customId,_that.title,_that.components);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BotModalOpenDto extends BotModalOpenDto {
  const _BotModalOpenDto({@JsonKey(readValue: readBotPayloadKey) this.guildId, @JsonKey(readValue: readBotPayloadKey) this.channelId = '', @JsonKey(readValue: readBotPayloadKey) this.botUserId = '', @JsonKey(readValue: readBotPayloadKey) this.customId, @JsonKey(readValue: readBotPayloadKey) this.title, @JsonKey(readValue: readBotPayloadKey) final  List<BotComponentDto> components = const <BotComponentDto>[]}): _components = components,super._();
  factory _BotModalOpenDto.fromJson(Map<String, dynamic> json) => _$BotModalOpenDtoFromJson(json);

@override@JsonKey(readValue: readBotPayloadKey) final  String? guildId;
@override@JsonKey(readValue: readBotPayloadKey) final  String channelId;
@override@JsonKey(readValue: readBotPayloadKey) final  String botUserId;
@override@JsonKey(readValue: readBotPayloadKey) final  String? customId;
@override@JsonKey(readValue: readBotPayloadKey) final  String? title;
 final  List<BotComponentDto> _components;
@override@JsonKey(readValue: readBotPayloadKey) List<BotComponentDto> get components {
  if (_components is EqualUnmodifiableListView) return _components;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_components);
}


/// Create a copy of BotModalOpenDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BotModalOpenDtoCopyWith<_BotModalOpenDto> get copyWith => __$BotModalOpenDtoCopyWithImpl<_BotModalOpenDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BotModalOpenDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BotModalOpenDto&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.botUserId, botUserId) || other.botUserId == botUserId)&&(identical(other.customId, customId) || other.customId == customId)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._components, _components));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,guildId,channelId,botUserId,customId,title,const DeepCollectionEquality().hash(_components));

@override
String toString() {
  return 'BotModalOpenDto(guildId: $guildId, channelId: $channelId, botUserId: $botUserId, customId: $customId, title: $title, components: $components)';
}


}

/// @nodoc
abstract mixin class _$BotModalOpenDtoCopyWith<$Res> implements $BotModalOpenDtoCopyWith<$Res> {
  factory _$BotModalOpenDtoCopyWith(_BotModalOpenDto value, $Res Function(_BotModalOpenDto) _then) = __$BotModalOpenDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(readValue: readBotPayloadKey) String? guildId,@JsonKey(readValue: readBotPayloadKey) String channelId,@JsonKey(readValue: readBotPayloadKey) String botUserId,@JsonKey(readValue: readBotPayloadKey) String? customId,@JsonKey(readValue: readBotPayloadKey) String? title,@JsonKey(readValue: readBotPayloadKey) List<BotComponentDto> components
});




}
/// @nodoc
class __$BotModalOpenDtoCopyWithImpl<$Res>
    implements _$BotModalOpenDtoCopyWith<$Res> {
  __$BotModalOpenDtoCopyWithImpl(this._self, this._then);

  final _BotModalOpenDto _self;
  final $Res Function(_BotModalOpenDto) _then;

/// Create a copy of BotModalOpenDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? guildId = freezed,Object? channelId = null,Object? botUserId = null,Object? customId = freezed,Object? title = freezed,Object? components = null,}) {
  return _then(_BotModalOpenDto(
guildId: freezed == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String?,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,botUserId: null == botUserId ? _self.botUserId : botUserId // ignore: cast_nullable_to_non_nullable
as String,customId: freezed == customId ? _self.customId : customId // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,components: null == components ? _self._components : components // ignore: cast_nullable_to_non_nullable
as List<BotComponentDto>,
  ));
}


}

// dart format on
