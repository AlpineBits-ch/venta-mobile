// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OnboardingPromptOptionDto {

/// Omitted to create; round-trip the server-assigned `onbo_...` to update
/// in place. Dropping an id you were given deletes the option.
@JsonKey(includeIfNull: false) String? get id; String get title; String? get description;/// A unicode emoji, or a guild emoji id.
 String? get emoji; List<String> get roleIds; List<String> get channelIds; int get position;/// Whether the calling member currently has this option picked - present
/// only on `.../onboarding/prompts`, never sent back on a write.
@JsonKey(includeToJson: false) bool get selected;
/// Create a copy of OnboardingPromptOptionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingPromptOptionDtoCopyWith<OnboardingPromptOptionDto> get copyWith => _$OnboardingPromptOptionDtoCopyWithImpl<OnboardingPromptOptionDto>(this as OnboardingPromptOptionDto, _$identity);

  /// Serializes this OnboardingPromptOptionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingPromptOptionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&const DeepCollectionEquality().equals(other.roleIds, roleIds)&&const DeepCollectionEquality().equals(other.channelIds, channelIds)&&(identical(other.position, position) || other.position == position)&&(identical(other.selected, selected) || other.selected == selected));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,emoji,const DeepCollectionEquality().hash(roleIds),const DeepCollectionEquality().hash(channelIds),position,selected);

@override
String toString() {
  return 'OnboardingPromptOptionDto(id: $id, title: $title, description: $description, emoji: $emoji, roleIds: $roleIds, channelIds: $channelIds, position: $position, selected: $selected)';
}


}

/// @nodoc
abstract mixin class $OnboardingPromptOptionDtoCopyWith<$Res>  {
  factory $OnboardingPromptOptionDtoCopyWith(OnboardingPromptOptionDto value, $Res Function(OnboardingPromptOptionDto) _then) = _$OnboardingPromptOptionDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) String? id, String title, String? description, String? emoji, List<String> roleIds, List<String> channelIds, int position,@JsonKey(includeToJson: false) bool selected
});




}
/// @nodoc
class _$OnboardingPromptOptionDtoCopyWithImpl<$Res>
    implements $OnboardingPromptOptionDtoCopyWith<$Res> {
  _$OnboardingPromptOptionDtoCopyWithImpl(this._self, this._then);

  final OnboardingPromptOptionDto _self;
  final $Res Function(OnboardingPromptOptionDto) _then;

/// Create a copy of OnboardingPromptOptionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? title = null,Object? description = freezed,Object? emoji = freezed,Object? roleIds = null,Object? channelIds = null,Object? position = null,Object? selected = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,emoji: freezed == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String?,roleIds: null == roleIds ? _self.roleIds : roleIds // ignore: cast_nullable_to_non_nullable
as List<String>,channelIds: null == channelIds ? _self.channelIds : channelIds // ignore: cast_nullable_to_non_nullable
as List<String>,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [OnboardingPromptOptionDto].
extension OnboardingPromptOptionDtoPatterns on OnboardingPromptOptionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnboardingPromptOptionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnboardingPromptOptionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnboardingPromptOptionDto value)  $default,){
final _that = this;
switch (_that) {
case _OnboardingPromptOptionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnboardingPromptOptionDto value)?  $default,){
final _that = this;
switch (_that) {
case _OnboardingPromptOptionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? id,  String title,  String? description,  String? emoji,  List<String> roleIds,  List<String> channelIds,  int position, @JsonKey(includeToJson: false)  bool selected)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingPromptOptionDto() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.emoji,_that.roleIds,_that.channelIds,_that.position,_that.selected);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? id,  String title,  String? description,  String? emoji,  List<String> roleIds,  List<String> channelIds,  int position, @JsonKey(includeToJson: false)  bool selected)  $default,) {final _that = this;
switch (_that) {
case _OnboardingPromptOptionDto():
return $default(_that.id,_that.title,_that.description,_that.emoji,_that.roleIds,_that.channelIds,_that.position,_that.selected);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  String? id,  String title,  String? description,  String? emoji,  List<String> roleIds,  List<String> channelIds,  int position, @JsonKey(includeToJson: false)  bool selected)?  $default,) {final _that = this;
switch (_that) {
case _OnboardingPromptOptionDto() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.emoji,_that.roleIds,_that.channelIds,_that.position,_that.selected);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OnboardingPromptOptionDto implements OnboardingPromptOptionDto {
  const _OnboardingPromptOptionDto({@JsonKey(includeIfNull: false) this.id, this.title = '', this.description, this.emoji, final  List<String> roleIds = const <String>[], final  List<String> channelIds = const <String>[], this.position = 0, @JsonKey(includeToJson: false) this.selected = false}): _roleIds = roleIds,_channelIds = channelIds;
  factory _OnboardingPromptOptionDto.fromJson(Map<String, dynamic> json) => _$OnboardingPromptOptionDtoFromJson(json);

/// Omitted to create; round-trip the server-assigned `onbo_...` to update
/// in place. Dropping an id you were given deletes the option.
@override@JsonKey(includeIfNull: false) final  String? id;
@override@JsonKey() final  String title;
@override final  String? description;
/// A unicode emoji, or a guild emoji id.
@override final  String? emoji;
 final  List<String> _roleIds;
@override@JsonKey() List<String> get roleIds {
  if (_roleIds is EqualUnmodifiableListView) return _roleIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roleIds);
}

 final  List<String> _channelIds;
@override@JsonKey() List<String> get channelIds {
  if (_channelIds is EqualUnmodifiableListView) return _channelIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_channelIds);
}

@override@JsonKey() final  int position;
/// Whether the calling member currently has this option picked - present
/// only on `.../onboarding/prompts`, never sent back on a write.
@override@JsonKey(includeToJson: false) final  bool selected;

/// Create a copy of OnboardingPromptOptionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingPromptOptionDtoCopyWith<_OnboardingPromptOptionDto> get copyWith => __$OnboardingPromptOptionDtoCopyWithImpl<_OnboardingPromptOptionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OnboardingPromptOptionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingPromptOptionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&const DeepCollectionEquality().equals(other._roleIds, _roleIds)&&const DeepCollectionEquality().equals(other._channelIds, _channelIds)&&(identical(other.position, position) || other.position == position)&&(identical(other.selected, selected) || other.selected == selected));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,emoji,const DeepCollectionEquality().hash(_roleIds),const DeepCollectionEquality().hash(_channelIds),position,selected);

@override
String toString() {
  return 'OnboardingPromptOptionDto(id: $id, title: $title, description: $description, emoji: $emoji, roleIds: $roleIds, channelIds: $channelIds, position: $position, selected: $selected)';
}


}

/// @nodoc
abstract mixin class _$OnboardingPromptOptionDtoCopyWith<$Res> implements $OnboardingPromptOptionDtoCopyWith<$Res> {
  factory _$OnboardingPromptOptionDtoCopyWith(_OnboardingPromptOptionDto value, $Res Function(_OnboardingPromptOptionDto) _then) = __$OnboardingPromptOptionDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) String? id, String title, String? description, String? emoji, List<String> roleIds, List<String> channelIds, int position,@JsonKey(includeToJson: false) bool selected
});




}
/// @nodoc
class __$OnboardingPromptOptionDtoCopyWithImpl<$Res>
    implements _$OnboardingPromptOptionDtoCopyWith<$Res> {
  __$OnboardingPromptOptionDtoCopyWithImpl(this._self, this._then);

  final _OnboardingPromptOptionDto _self;
  final $Res Function(_OnboardingPromptOptionDto) _then;

/// Create a copy of OnboardingPromptOptionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? title = null,Object? description = freezed,Object? emoji = freezed,Object? roleIds = null,Object? channelIds = null,Object? position = null,Object? selected = null,}) {
  return _then(_OnboardingPromptOptionDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,emoji: freezed == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String?,roleIds: null == roleIds ? _self._roleIds : roleIds // ignore: cast_nullable_to_non_nullable
as List<String>,channelIds: null == channelIds ? _self._channelIds : channelIds // ignore: cast_nullable_to_non_nullable
as List<String>,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$OnboardingPromptDto {

/// Omitted to create; round-trip the server-assigned `onbp_...` to update
/// in place. Dropping an id you were given deletes the prompt *and every
/// member's answer to it*.
@JsonKey(includeIfNull: false) String? get id; String get title; OnboardingPromptType get type;/// `true` = radio buttons, `false` = checkboxes.
 bool get singleSelect;/// Must be answered before onboarding can be finished. `required` is a
/// Dart modifier keyword, hence the renamed field.
@JsonKey(name: 'required') bool get isRequired;/// `false` = only offered in Channels & Roles, never in the join flow.
 bool get inOnboarding; int get position; List<OnboardingPromptOptionDto> get options;
/// Create a copy of OnboardingPromptDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingPromptDtoCopyWith<OnboardingPromptDto> get copyWith => _$OnboardingPromptDtoCopyWithImpl<OnboardingPromptDto>(this as OnboardingPromptDto, _$identity);

  /// Serializes this OnboardingPromptDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingPromptDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.singleSelect, singleSelect) || other.singleSelect == singleSelect)&&(identical(other.isRequired, isRequired) || other.isRequired == isRequired)&&(identical(other.inOnboarding, inOnboarding) || other.inOnboarding == inOnboarding)&&(identical(other.position, position) || other.position == position)&&const DeepCollectionEquality().equals(other.options, options));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,type,singleSelect,isRequired,inOnboarding,position,const DeepCollectionEquality().hash(options));

@override
String toString() {
  return 'OnboardingPromptDto(id: $id, title: $title, type: $type, singleSelect: $singleSelect, isRequired: $isRequired, inOnboarding: $inOnboarding, position: $position, options: $options)';
}


}

/// @nodoc
abstract mixin class $OnboardingPromptDtoCopyWith<$Res>  {
  factory $OnboardingPromptDtoCopyWith(OnboardingPromptDto value, $Res Function(OnboardingPromptDto) _then) = _$OnboardingPromptDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) String? id, String title, OnboardingPromptType type, bool singleSelect,@JsonKey(name: 'required') bool isRequired, bool inOnboarding, int position, List<OnboardingPromptOptionDto> options
});




}
/// @nodoc
class _$OnboardingPromptDtoCopyWithImpl<$Res>
    implements $OnboardingPromptDtoCopyWith<$Res> {
  _$OnboardingPromptDtoCopyWithImpl(this._self, this._then);

  final OnboardingPromptDto _self;
  final $Res Function(OnboardingPromptDto) _then;

/// Create a copy of OnboardingPromptDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? title = null,Object? type = null,Object? singleSelect = null,Object? isRequired = null,Object? inOnboarding = null,Object? position = null,Object? options = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OnboardingPromptType,singleSelect: null == singleSelect ? _self.singleSelect : singleSelect // ignore: cast_nullable_to_non_nullable
as bool,isRequired: null == isRequired ? _self.isRequired : isRequired // ignore: cast_nullable_to_non_nullable
as bool,inOnboarding: null == inOnboarding ? _self.inOnboarding : inOnboarding // ignore: cast_nullable_to_non_nullable
as bool,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as List<OnboardingPromptOptionDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [OnboardingPromptDto].
extension OnboardingPromptDtoPatterns on OnboardingPromptDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnboardingPromptDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnboardingPromptDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnboardingPromptDto value)  $default,){
final _that = this;
switch (_that) {
case _OnboardingPromptDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnboardingPromptDto value)?  $default,){
final _that = this;
switch (_that) {
case _OnboardingPromptDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? id,  String title,  OnboardingPromptType type,  bool singleSelect, @JsonKey(name: 'required')  bool isRequired,  bool inOnboarding,  int position,  List<OnboardingPromptOptionDto> options)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingPromptDto() when $default != null:
return $default(_that.id,_that.title,_that.type,_that.singleSelect,_that.isRequired,_that.inOnboarding,_that.position,_that.options);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? id,  String title,  OnboardingPromptType type,  bool singleSelect, @JsonKey(name: 'required')  bool isRequired,  bool inOnboarding,  int position,  List<OnboardingPromptOptionDto> options)  $default,) {final _that = this;
switch (_that) {
case _OnboardingPromptDto():
return $default(_that.id,_that.title,_that.type,_that.singleSelect,_that.isRequired,_that.inOnboarding,_that.position,_that.options);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  String? id,  String title,  OnboardingPromptType type,  bool singleSelect, @JsonKey(name: 'required')  bool isRequired,  bool inOnboarding,  int position,  List<OnboardingPromptOptionDto> options)?  $default,) {final _that = this;
switch (_that) {
case _OnboardingPromptDto() when $default != null:
return $default(_that.id,_that.title,_that.type,_that.singleSelect,_that.isRequired,_that.inOnboarding,_that.position,_that.options);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OnboardingPromptDto implements OnboardingPromptDto {
  const _OnboardingPromptDto({@JsonKey(includeIfNull: false) this.id, this.title = '', this.type = OnboardingPromptType.multipleChoice, this.singleSelect = false, @JsonKey(name: 'required') this.isRequired = false, this.inOnboarding = true, this.position = 0, final  List<OnboardingPromptOptionDto> options = const <OnboardingPromptOptionDto>[]}): _options = options;
  factory _OnboardingPromptDto.fromJson(Map<String, dynamic> json) => _$OnboardingPromptDtoFromJson(json);

/// Omitted to create; round-trip the server-assigned `onbp_...` to update
/// in place. Dropping an id you were given deletes the prompt *and every
/// member's answer to it*.
@override@JsonKey(includeIfNull: false) final  String? id;
@override@JsonKey() final  String title;
@override@JsonKey() final  OnboardingPromptType type;
/// `true` = radio buttons, `false` = checkboxes.
@override@JsonKey() final  bool singleSelect;
/// Must be answered before onboarding can be finished. `required` is a
/// Dart modifier keyword, hence the renamed field.
@override@JsonKey(name: 'required') final  bool isRequired;
/// `false` = only offered in Channels & Roles, never in the join flow.
@override@JsonKey() final  bool inOnboarding;
@override@JsonKey() final  int position;
 final  List<OnboardingPromptOptionDto> _options;
@override@JsonKey() List<OnboardingPromptOptionDto> get options {
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_options);
}


/// Create a copy of OnboardingPromptDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingPromptDtoCopyWith<_OnboardingPromptDto> get copyWith => __$OnboardingPromptDtoCopyWithImpl<_OnboardingPromptDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OnboardingPromptDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingPromptDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.singleSelect, singleSelect) || other.singleSelect == singleSelect)&&(identical(other.isRequired, isRequired) || other.isRequired == isRequired)&&(identical(other.inOnboarding, inOnboarding) || other.inOnboarding == inOnboarding)&&(identical(other.position, position) || other.position == position)&&const DeepCollectionEquality().equals(other._options, _options));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,type,singleSelect,isRequired,inOnboarding,position,const DeepCollectionEquality().hash(_options));

@override
String toString() {
  return 'OnboardingPromptDto(id: $id, title: $title, type: $type, singleSelect: $singleSelect, isRequired: $isRequired, inOnboarding: $inOnboarding, position: $position, options: $options)';
}


}

/// @nodoc
abstract mixin class _$OnboardingPromptDtoCopyWith<$Res> implements $OnboardingPromptDtoCopyWith<$Res> {
  factory _$OnboardingPromptDtoCopyWith(_OnboardingPromptDto value, $Res Function(_OnboardingPromptDto) _then) = __$OnboardingPromptDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) String? id, String title, OnboardingPromptType type, bool singleSelect,@JsonKey(name: 'required') bool isRequired, bool inOnboarding, int position, List<OnboardingPromptOptionDto> options
});




}
/// @nodoc
class __$OnboardingPromptDtoCopyWithImpl<$Res>
    implements _$OnboardingPromptDtoCopyWith<$Res> {
  __$OnboardingPromptDtoCopyWithImpl(this._self, this._then);

  final _OnboardingPromptDto _self;
  final $Res Function(_OnboardingPromptDto) _then;

/// Create a copy of OnboardingPromptDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? title = null,Object? type = null,Object? singleSelect = null,Object? isRequired = null,Object? inOnboarding = null,Object? position = null,Object? options = null,}) {
  return _then(_OnboardingPromptDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OnboardingPromptType,singleSelect: null == singleSelect ? _self.singleSelect : singleSelect // ignore: cast_nullable_to_non_nullable
as bool,isRequired: null == isRequired ? _self.isRequired : isRequired // ignore: cast_nullable_to_non_nullable
as bool,inOnboarding: null == inOnboarding ? _self.inOnboarding : inOnboarding // ignore: cast_nullable_to_non_nullable
as bool,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,options: null == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<OnboardingPromptOptionDto>,
  ));
}


}


/// @nodoc
mixin _$OnboardingConfigDto {

 bool get enabled; OnboardingMode get mode; String? get rulesText; List<String> get defaultChannelIds; List<OnboardingPromptDto> get prompts;
/// Create a copy of OnboardingConfigDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingConfigDtoCopyWith<OnboardingConfigDto> get copyWith => _$OnboardingConfigDtoCopyWithImpl<OnboardingConfigDto>(this as OnboardingConfigDto, _$identity);

  /// Serializes this OnboardingConfigDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingConfigDto&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.rulesText, rulesText) || other.rulesText == rulesText)&&const DeepCollectionEquality().equals(other.defaultChannelIds, defaultChannelIds)&&const DeepCollectionEquality().equals(other.prompts, prompts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,mode,rulesText,const DeepCollectionEquality().hash(defaultChannelIds),const DeepCollectionEquality().hash(prompts));

@override
String toString() {
  return 'OnboardingConfigDto(enabled: $enabled, mode: $mode, rulesText: $rulesText, defaultChannelIds: $defaultChannelIds, prompts: $prompts)';
}


}

/// @nodoc
abstract mixin class $OnboardingConfigDtoCopyWith<$Res>  {
  factory $OnboardingConfigDtoCopyWith(OnboardingConfigDto value, $Res Function(OnboardingConfigDto) _then) = _$OnboardingConfigDtoCopyWithImpl;
@useResult
$Res call({
 bool enabled, OnboardingMode mode, String? rulesText, List<String> defaultChannelIds, List<OnboardingPromptDto> prompts
});




}
/// @nodoc
class _$OnboardingConfigDtoCopyWithImpl<$Res>
    implements $OnboardingConfigDtoCopyWith<$Res> {
  _$OnboardingConfigDtoCopyWithImpl(this._self, this._then);

  final OnboardingConfigDto _self;
  final $Res Function(OnboardingConfigDto) _then;

/// Create a copy of OnboardingConfigDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? mode = null,Object? rulesText = freezed,Object? defaultChannelIds = null,Object? prompts = null,}) {
  return _then(_self.copyWith(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as OnboardingMode,rulesText: freezed == rulesText ? _self.rulesText : rulesText // ignore: cast_nullable_to_non_nullable
as String?,defaultChannelIds: null == defaultChannelIds ? _self.defaultChannelIds : defaultChannelIds // ignore: cast_nullable_to_non_nullable
as List<String>,prompts: null == prompts ? _self.prompts : prompts // ignore: cast_nullable_to_non_nullable
as List<OnboardingPromptDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [OnboardingConfigDto].
extension OnboardingConfigDtoPatterns on OnboardingConfigDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnboardingConfigDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnboardingConfigDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnboardingConfigDto value)  $default,){
final _that = this;
switch (_that) {
case _OnboardingConfigDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnboardingConfigDto value)?  $default,){
final _that = this;
switch (_that) {
case _OnboardingConfigDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  OnboardingMode mode,  String? rulesText,  List<String> defaultChannelIds,  List<OnboardingPromptDto> prompts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingConfigDto() when $default != null:
return $default(_that.enabled,_that.mode,_that.rulesText,_that.defaultChannelIds,_that.prompts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  OnboardingMode mode,  String? rulesText,  List<String> defaultChannelIds,  List<OnboardingPromptDto> prompts)  $default,) {final _that = this;
switch (_that) {
case _OnboardingConfigDto():
return $default(_that.enabled,_that.mode,_that.rulesText,_that.defaultChannelIds,_that.prompts);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  OnboardingMode mode,  String? rulesText,  List<String> defaultChannelIds,  List<OnboardingPromptDto> prompts)?  $default,) {final _that = this;
switch (_that) {
case _OnboardingConfigDto() when $default != null:
return $default(_that.enabled,_that.mode,_that.rulesText,_that.defaultChannelIds,_that.prompts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OnboardingConfigDto implements OnboardingConfigDto {
  const _OnboardingConfigDto({this.enabled = false, this.mode = OnboardingMode.standard, this.rulesText, final  List<String> defaultChannelIds = const <String>[], final  List<OnboardingPromptDto> prompts = const <OnboardingPromptDto>[]}): _defaultChannelIds = defaultChannelIds,_prompts = prompts;
  factory _OnboardingConfigDto.fromJson(Map<String, dynamic> json) => _$OnboardingConfigDtoFromJson(json);

@override@JsonKey() final  bool enabled;
@override@JsonKey() final  OnboardingMode mode;
@override final  String? rulesText;
 final  List<String> _defaultChannelIds;
@override@JsonKey() List<String> get defaultChannelIds {
  if (_defaultChannelIds is EqualUnmodifiableListView) return _defaultChannelIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_defaultChannelIds);
}

 final  List<OnboardingPromptDto> _prompts;
@override@JsonKey() List<OnboardingPromptDto> get prompts {
  if (_prompts is EqualUnmodifiableListView) return _prompts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_prompts);
}


/// Create a copy of OnboardingConfigDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingConfigDtoCopyWith<_OnboardingConfigDto> get copyWith => __$OnboardingConfigDtoCopyWithImpl<_OnboardingConfigDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OnboardingConfigDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingConfigDto&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.rulesText, rulesText) || other.rulesText == rulesText)&&const DeepCollectionEquality().equals(other._defaultChannelIds, _defaultChannelIds)&&const DeepCollectionEquality().equals(other._prompts, _prompts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,mode,rulesText,const DeepCollectionEquality().hash(_defaultChannelIds),const DeepCollectionEquality().hash(_prompts));

@override
String toString() {
  return 'OnboardingConfigDto(enabled: $enabled, mode: $mode, rulesText: $rulesText, defaultChannelIds: $defaultChannelIds, prompts: $prompts)';
}


}

/// @nodoc
abstract mixin class _$OnboardingConfigDtoCopyWith<$Res> implements $OnboardingConfigDtoCopyWith<$Res> {
  factory _$OnboardingConfigDtoCopyWith(_OnboardingConfigDto value, $Res Function(_OnboardingConfigDto) _then) = __$OnboardingConfigDtoCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, OnboardingMode mode, String? rulesText, List<String> defaultChannelIds, List<OnboardingPromptDto> prompts
});




}
/// @nodoc
class __$OnboardingConfigDtoCopyWithImpl<$Res>
    implements _$OnboardingConfigDtoCopyWith<$Res> {
  __$OnboardingConfigDtoCopyWithImpl(this._self, this._then);

  final _OnboardingConfigDto _self;
  final $Res Function(_OnboardingConfigDto) _then;

/// Create a copy of OnboardingConfigDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? mode = null,Object? rulesText = freezed,Object? defaultChannelIds = null,Object? prompts = null,}) {
  return _then(_OnboardingConfigDto(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as OnboardingMode,rulesText: freezed == rulesText ? _self.rulesText : rulesText // ignore: cast_nullable_to_non_nullable
as String?,defaultChannelIds: null == defaultChannelIds ? _self._defaultChannelIds : defaultChannelIds // ignore: cast_nullable_to_non_nullable
as List<String>,prompts: null == prompts ? _self._prompts : prompts // ignore: cast_nullable_to_non_nullable
as List<OnboardingPromptDto>,
  ));
}


}


/// @nodoc
mixin _$OnboardingStatusDto {

 bool get enabled; bool get completed; String? get rulesText; List<String> get defaultChannelIds;/// Only prompts with `inOnboarding: true`.
 List<OnboardingPromptDto> get prompts;
/// Create a copy of OnboardingStatusDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingStatusDtoCopyWith<OnboardingStatusDto> get copyWith => _$OnboardingStatusDtoCopyWithImpl<OnboardingStatusDto>(this as OnboardingStatusDto, _$identity);

  /// Serializes this OnboardingStatusDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingStatusDto&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.rulesText, rulesText) || other.rulesText == rulesText)&&const DeepCollectionEquality().equals(other.defaultChannelIds, defaultChannelIds)&&const DeepCollectionEquality().equals(other.prompts, prompts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,completed,rulesText,const DeepCollectionEquality().hash(defaultChannelIds),const DeepCollectionEquality().hash(prompts));

@override
String toString() {
  return 'OnboardingStatusDto(enabled: $enabled, completed: $completed, rulesText: $rulesText, defaultChannelIds: $defaultChannelIds, prompts: $prompts)';
}


}

/// @nodoc
abstract mixin class $OnboardingStatusDtoCopyWith<$Res>  {
  factory $OnboardingStatusDtoCopyWith(OnboardingStatusDto value, $Res Function(OnboardingStatusDto) _then) = _$OnboardingStatusDtoCopyWithImpl;
@useResult
$Res call({
 bool enabled, bool completed, String? rulesText, List<String> defaultChannelIds, List<OnboardingPromptDto> prompts
});




}
/// @nodoc
class _$OnboardingStatusDtoCopyWithImpl<$Res>
    implements $OnboardingStatusDtoCopyWith<$Res> {
  _$OnboardingStatusDtoCopyWithImpl(this._self, this._then);

  final OnboardingStatusDto _self;
  final $Res Function(OnboardingStatusDto) _then;

/// Create a copy of OnboardingStatusDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? completed = null,Object? rulesText = freezed,Object? defaultChannelIds = null,Object? prompts = null,}) {
  return _then(_self.copyWith(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,rulesText: freezed == rulesText ? _self.rulesText : rulesText // ignore: cast_nullable_to_non_nullable
as String?,defaultChannelIds: null == defaultChannelIds ? _self.defaultChannelIds : defaultChannelIds // ignore: cast_nullable_to_non_nullable
as List<String>,prompts: null == prompts ? _self.prompts : prompts // ignore: cast_nullable_to_non_nullable
as List<OnboardingPromptDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [OnboardingStatusDto].
extension OnboardingStatusDtoPatterns on OnboardingStatusDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnboardingStatusDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnboardingStatusDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnboardingStatusDto value)  $default,){
final _that = this;
switch (_that) {
case _OnboardingStatusDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnboardingStatusDto value)?  $default,){
final _that = this;
switch (_that) {
case _OnboardingStatusDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  bool completed,  String? rulesText,  List<String> defaultChannelIds,  List<OnboardingPromptDto> prompts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingStatusDto() when $default != null:
return $default(_that.enabled,_that.completed,_that.rulesText,_that.defaultChannelIds,_that.prompts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  bool completed,  String? rulesText,  List<String> defaultChannelIds,  List<OnboardingPromptDto> prompts)  $default,) {final _that = this;
switch (_that) {
case _OnboardingStatusDto():
return $default(_that.enabled,_that.completed,_that.rulesText,_that.defaultChannelIds,_that.prompts);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  bool completed,  String? rulesText,  List<String> defaultChannelIds,  List<OnboardingPromptDto> prompts)?  $default,) {final _that = this;
switch (_that) {
case _OnboardingStatusDto() when $default != null:
return $default(_that.enabled,_that.completed,_that.rulesText,_that.defaultChannelIds,_that.prompts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OnboardingStatusDto implements OnboardingStatusDto {
  const _OnboardingStatusDto({this.enabled = false, this.completed = true, this.rulesText, final  List<String> defaultChannelIds = const <String>[], final  List<OnboardingPromptDto> prompts = const <OnboardingPromptDto>[]}): _defaultChannelIds = defaultChannelIds,_prompts = prompts;
  factory _OnboardingStatusDto.fromJson(Map<String, dynamic> json) => _$OnboardingStatusDtoFromJson(json);

@override@JsonKey() final  bool enabled;
@override@JsonKey() final  bool completed;
@override final  String? rulesText;
 final  List<String> _defaultChannelIds;
@override@JsonKey() List<String> get defaultChannelIds {
  if (_defaultChannelIds is EqualUnmodifiableListView) return _defaultChannelIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_defaultChannelIds);
}

/// Only prompts with `inOnboarding: true`.
 final  List<OnboardingPromptDto> _prompts;
/// Only prompts with `inOnboarding: true`.
@override@JsonKey() List<OnboardingPromptDto> get prompts {
  if (_prompts is EqualUnmodifiableListView) return _prompts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_prompts);
}


/// Create a copy of OnboardingStatusDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingStatusDtoCopyWith<_OnboardingStatusDto> get copyWith => __$OnboardingStatusDtoCopyWithImpl<_OnboardingStatusDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OnboardingStatusDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingStatusDto&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.rulesText, rulesText) || other.rulesText == rulesText)&&const DeepCollectionEquality().equals(other._defaultChannelIds, _defaultChannelIds)&&const DeepCollectionEquality().equals(other._prompts, _prompts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,completed,rulesText,const DeepCollectionEquality().hash(_defaultChannelIds),const DeepCollectionEquality().hash(_prompts));

@override
String toString() {
  return 'OnboardingStatusDto(enabled: $enabled, completed: $completed, rulesText: $rulesText, defaultChannelIds: $defaultChannelIds, prompts: $prompts)';
}


}

/// @nodoc
abstract mixin class _$OnboardingStatusDtoCopyWith<$Res> implements $OnboardingStatusDtoCopyWith<$Res> {
  factory _$OnboardingStatusDtoCopyWith(_OnboardingStatusDto value, $Res Function(_OnboardingStatusDto) _then) = __$OnboardingStatusDtoCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, bool completed, String? rulesText, List<String> defaultChannelIds, List<OnboardingPromptDto> prompts
});




}
/// @nodoc
class __$OnboardingStatusDtoCopyWithImpl<$Res>
    implements _$OnboardingStatusDtoCopyWith<$Res> {
  __$OnboardingStatusDtoCopyWithImpl(this._self, this._then);

  final _OnboardingStatusDto _self;
  final $Res Function(_OnboardingStatusDto) _then;

/// Create a copy of OnboardingStatusDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? completed = null,Object? rulesText = freezed,Object? defaultChannelIds = null,Object? prompts = null,}) {
  return _then(_OnboardingStatusDto(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,rulesText: freezed == rulesText ? _self.rulesText : rulesText // ignore: cast_nullable_to_non_nullable
as String?,defaultChannelIds: null == defaultChannelIds ? _self._defaultChannelIds : defaultChannelIds // ignore: cast_nullable_to_non_nullable
as List<String>,prompts: null == prompts ? _self._prompts : prompts // ignore: cast_nullable_to_non_nullable
as List<OnboardingPromptDto>,
  ));
}


}


/// @nodoc
mixin _$OnboardingResponseDto {

 String get promptId; List<String> get optionIds;
/// Create a copy of OnboardingResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingResponseDtoCopyWith<OnboardingResponseDto> get copyWith => _$OnboardingResponseDtoCopyWithImpl<OnboardingResponseDto>(this as OnboardingResponseDto, _$identity);

  /// Serializes this OnboardingResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingResponseDto&&(identical(other.promptId, promptId) || other.promptId == promptId)&&const DeepCollectionEquality().equals(other.optionIds, optionIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,promptId,const DeepCollectionEquality().hash(optionIds));

@override
String toString() {
  return 'OnboardingResponseDto(promptId: $promptId, optionIds: $optionIds)';
}


}

/// @nodoc
abstract mixin class $OnboardingResponseDtoCopyWith<$Res>  {
  factory $OnboardingResponseDtoCopyWith(OnboardingResponseDto value, $Res Function(OnboardingResponseDto) _then) = _$OnboardingResponseDtoCopyWithImpl;
@useResult
$Res call({
 String promptId, List<String> optionIds
});




}
/// @nodoc
class _$OnboardingResponseDtoCopyWithImpl<$Res>
    implements $OnboardingResponseDtoCopyWith<$Res> {
  _$OnboardingResponseDtoCopyWithImpl(this._self, this._then);

  final OnboardingResponseDto _self;
  final $Res Function(OnboardingResponseDto) _then;

/// Create a copy of OnboardingResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? promptId = null,Object? optionIds = null,}) {
  return _then(_self.copyWith(
promptId: null == promptId ? _self.promptId : promptId // ignore: cast_nullable_to_non_nullable
as String,optionIds: null == optionIds ? _self.optionIds : optionIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [OnboardingResponseDto].
extension OnboardingResponseDtoPatterns on OnboardingResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnboardingResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnboardingResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnboardingResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _OnboardingResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnboardingResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _OnboardingResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String promptId,  List<String> optionIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingResponseDto() when $default != null:
return $default(_that.promptId,_that.optionIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String promptId,  List<String> optionIds)  $default,) {final _that = this;
switch (_that) {
case _OnboardingResponseDto():
return $default(_that.promptId,_that.optionIds);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String promptId,  List<String> optionIds)?  $default,) {final _that = this;
switch (_that) {
case _OnboardingResponseDto() when $default != null:
return $default(_that.promptId,_that.optionIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OnboardingResponseDto implements OnboardingResponseDto {
  const _OnboardingResponseDto({required this.promptId, final  List<String> optionIds = const <String>[]}): _optionIds = optionIds;
  factory _OnboardingResponseDto.fromJson(Map<String, dynamic> json) => _$OnboardingResponseDtoFromJson(json);

@override final  String promptId;
 final  List<String> _optionIds;
@override@JsonKey() List<String> get optionIds {
  if (_optionIds is EqualUnmodifiableListView) return _optionIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_optionIds);
}


/// Create a copy of OnboardingResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingResponseDtoCopyWith<_OnboardingResponseDto> get copyWith => __$OnboardingResponseDtoCopyWithImpl<_OnboardingResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OnboardingResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingResponseDto&&(identical(other.promptId, promptId) || other.promptId == promptId)&&const DeepCollectionEquality().equals(other._optionIds, _optionIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,promptId,const DeepCollectionEquality().hash(_optionIds));

@override
String toString() {
  return 'OnboardingResponseDto(promptId: $promptId, optionIds: $optionIds)';
}


}

/// @nodoc
abstract mixin class _$OnboardingResponseDtoCopyWith<$Res> implements $OnboardingResponseDtoCopyWith<$Res> {
  factory _$OnboardingResponseDtoCopyWith(_OnboardingResponseDto value, $Res Function(_OnboardingResponseDto) _then) = __$OnboardingResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 String promptId, List<String> optionIds
});




}
/// @nodoc
class __$OnboardingResponseDtoCopyWithImpl<$Res>
    implements _$OnboardingResponseDtoCopyWith<$Res> {
  __$OnboardingResponseDtoCopyWithImpl(this._self, this._then);

  final _OnboardingResponseDto _self;
  final $Res Function(_OnboardingResponseDto) _then;

/// Create a copy of OnboardingResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? promptId = null,Object? optionIds = null,}) {
  return _then(_OnboardingResponseDto(
promptId: null == promptId ? _self.promptId : promptId // ignore: cast_nullable_to_non_nullable
as String,optionIds: null == optionIds ? _self._optionIds : optionIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$PendingMemberDto {

 String get memberId; String get userId; String? get nickname; DateTime? get joinedAt;
/// Create a copy of PendingMemberDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingMemberDtoCopyWith<PendingMemberDto> get copyWith => _$PendingMemberDtoCopyWithImpl<PendingMemberDto>(this as PendingMemberDto, _$identity);

  /// Serializes this PendingMemberDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingMemberDto&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,memberId,userId,nickname,joinedAt);

@override
String toString() {
  return 'PendingMemberDto(memberId: $memberId, userId: $userId, nickname: $nickname, joinedAt: $joinedAt)';
}


}

/// @nodoc
abstract mixin class $PendingMemberDtoCopyWith<$Res>  {
  factory $PendingMemberDtoCopyWith(PendingMemberDto value, $Res Function(PendingMemberDto) _then) = _$PendingMemberDtoCopyWithImpl;
@useResult
$Res call({
 String memberId, String userId, String? nickname, DateTime? joinedAt
});




}
/// @nodoc
class _$PendingMemberDtoCopyWithImpl<$Res>
    implements $PendingMemberDtoCopyWith<$Res> {
  _$PendingMemberDtoCopyWithImpl(this._self, this._then);

  final PendingMemberDto _self;
  final $Res Function(PendingMemberDto) _then;

/// Create a copy of PendingMemberDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? memberId = null,Object? userId = null,Object? nickname = freezed,Object? joinedAt = freezed,}) {
  return _then(_self.copyWith(
memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,nickname: freezed == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String?,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PendingMemberDto].
extension PendingMemberDtoPatterns on PendingMemberDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PendingMemberDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PendingMemberDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PendingMemberDto value)  $default,){
final _that = this;
switch (_that) {
case _PendingMemberDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PendingMemberDto value)?  $default,){
final _that = this;
switch (_that) {
case _PendingMemberDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String memberId,  String userId,  String? nickname,  DateTime? joinedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PendingMemberDto() when $default != null:
return $default(_that.memberId,_that.userId,_that.nickname,_that.joinedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String memberId,  String userId,  String? nickname,  DateTime? joinedAt)  $default,) {final _that = this;
switch (_that) {
case _PendingMemberDto():
return $default(_that.memberId,_that.userId,_that.nickname,_that.joinedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String memberId,  String userId,  String? nickname,  DateTime? joinedAt)?  $default,) {final _that = this;
switch (_that) {
case _PendingMemberDto() when $default != null:
return $default(_that.memberId,_that.userId,_that.nickname,_that.joinedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PendingMemberDto implements PendingMemberDto {
  const _PendingMemberDto({required this.memberId, required this.userId, this.nickname, this.joinedAt});
  factory _PendingMemberDto.fromJson(Map<String, dynamic> json) => _$PendingMemberDtoFromJson(json);

@override final  String memberId;
@override final  String userId;
@override final  String? nickname;
@override final  DateTime? joinedAt;

/// Create a copy of PendingMemberDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PendingMemberDtoCopyWith<_PendingMemberDto> get copyWith => __$PendingMemberDtoCopyWithImpl<_PendingMemberDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PendingMemberDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PendingMemberDto&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,memberId,userId,nickname,joinedAt);

@override
String toString() {
  return 'PendingMemberDto(memberId: $memberId, userId: $userId, nickname: $nickname, joinedAt: $joinedAt)';
}


}

/// @nodoc
abstract mixin class _$PendingMemberDtoCopyWith<$Res> implements $PendingMemberDtoCopyWith<$Res> {
  factory _$PendingMemberDtoCopyWith(_PendingMemberDto value, $Res Function(_PendingMemberDto) _then) = __$PendingMemberDtoCopyWithImpl;
@override @useResult
$Res call({
 String memberId, String userId, String? nickname, DateTime? joinedAt
});




}
/// @nodoc
class __$PendingMemberDtoCopyWithImpl<$Res>
    implements _$PendingMemberDtoCopyWith<$Res> {
  __$PendingMemberDtoCopyWithImpl(this._self, this._then);

  final _PendingMemberDto _self;
  final $Res Function(_PendingMemberDto) _then;

/// Create a copy of PendingMemberDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? memberId = null,Object? userId = null,Object? nickname = freezed,Object? joinedAt = freezed,}) {
  return _then(_PendingMemberDto(
memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,nickname: freezed == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String?,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
