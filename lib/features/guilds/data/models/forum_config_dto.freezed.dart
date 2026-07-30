// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'forum_config_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ForumConfigDto {

 String? get channelId;/// Posts must carry at least one tag. Enforced at write time only - it's
/// never applied retroactively to posts that predate it.
 bool get requireTag; ForumSortOrder get defaultSortOrder; ForumLayout get defaultLayout; String? get defaultReactionEmojiId; String? get defaultReactionEmojiName;/// Copied onto each new post at creation; changing it leaves existing
/// posts alone.
 int get defaultThreadSlowModeSeconds;/// One of [autoArchiveChoices] - 3 days by default.
 int get defaultAutoArchiveMinutes;
/// Create a copy of ForumConfigDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ForumConfigDtoCopyWith<ForumConfigDto> get copyWith => _$ForumConfigDtoCopyWithImpl<ForumConfigDto>(this as ForumConfigDto, _$identity);

  /// Serializes this ForumConfigDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ForumConfigDto&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.requireTag, requireTag) || other.requireTag == requireTag)&&(identical(other.defaultSortOrder, defaultSortOrder) || other.defaultSortOrder == defaultSortOrder)&&(identical(other.defaultLayout, defaultLayout) || other.defaultLayout == defaultLayout)&&(identical(other.defaultReactionEmojiId, defaultReactionEmojiId) || other.defaultReactionEmojiId == defaultReactionEmojiId)&&(identical(other.defaultReactionEmojiName, defaultReactionEmojiName) || other.defaultReactionEmojiName == defaultReactionEmojiName)&&(identical(other.defaultThreadSlowModeSeconds, defaultThreadSlowModeSeconds) || other.defaultThreadSlowModeSeconds == defaultThreadSlowModeSeconds)&&(identical(other.defaultAutoArchiveMinutes, defaultAutoArchiveMinutes) || other.defaultAutoArchiveMinutes == defaultAutoArchiveMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,channelId,requireTag,defaultSortOrder,defaultLayout,defaultReactionEmojiId,defaultReactionEmojiName,defaultThreadSlowModeSeconds,defaultAutoArchiveMinutes);

@override
String toString() {
  return 'ForumConfigDto(channelId: $channelId, requireTag: $requireTag, defaultSortOrder: $defaultSortOrder, defaultLayout: $defaultLayout, defaultReactionEmojiId: $defaultReactionEmojiId, defaultReactionEmojiName: $defaultReactionEmojiName, defaultThreadSlowModeSeconds: $defaultThreadSlowModeSeconds, defaultAutoArchiveMinutes: $defaultAutoArchiveMinutes)';
}


}

/// @nodoc
abstract mixin class $ForumConfigDtoCopyWith<$Res>  {
  factory $ForumConfigDtoCopyWith(ForumConfigDto value, $Res Function(ForumConfigDto) _then) = _$ForumConfigDtoCopyWithImpl;
@useResult
$Res call({
 String? channelId, bool requireTag, ForumSortOrder defaultSortOrder, ForumLayout defaultLayout, String? defaultReactionEmojiId, String? defaultReactionEmojiName, int defaultThreadSlowModeSeconds, int defaultAutoArchiveMinutes
});




}
/// @nodoc
class _$ForumConfigDtoCopyWithImpl<$Res>
    implements $ForumConfigDtoCopyWith<$Res> {
  _$ForumConfigDtoCopyWithImpl(this._self, this._then);

  final ForumConfigDto _self;
  final $Res Function(ForumConfigDto) _then;

/// Create a copy of ForumConfigDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? channelId = freezed,Object? requireTag = null,Object? defaultSortOrder = null,Object? defaultLayout = null,Object? defaultReactionEmojiId = freezed,Object? defaultReactionEmojiName = freezed,Object? defaultThreadSlowModeSeconds = null,Object? defaultAutoArchiveMinutes = null,}) {
  return _then(_self.copyWith(
channelId: freezed == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String?,requireTag: null == requireTag ? _self.requireTag : requireTag // ignore: cast_nullable_to_non_nullable
as bool,defaultSortOrder: null == defaultSortOrder ? _self.defaultSortOrder : defaultSortOrder // ignore: cast_nullable_to_non_nullable
as ForumSortOrder,defaultLayout: null == defaultLayout ? _self.defaultLayout : defaultLayout // ignore: cast_nullable_to_non_nullable
as ForumLayout,defaultReactionEmojiId: freezed == defaultReactionEmojiId ? _self.defaultReactionEmojiId : defaultReactionEmojiId // ignore: cast_nullable_to_non_nullable
as String?,defaultReactionEmojiName: freezed == defaultReactionEmojiName ? _self.defaultReactionEmojiName : defaultReactionEmojiName // ignore: cast_nullable_to_non_nullable
as String?,defaultThreadSlowModeSeconds: null == defaultThreadSlowModeSeconds ? _self.defaultThreadSlowModeSeconds : defaultThreadSlowModeSeconds // ignore: cast_nullable_to_non_nullable
as int,defaultAutoArchiveMinutes: null == defaultAutoArchiveMinutes ? _self.defaultAutoArchiveMinutes : defaultAutoArchiveMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ForumConfigDto].
extension ForumConfigDtoPatterns on ForumConfigDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ForumConfigDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ForumConfigDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ForumConfigDto value)  $default,){
final _that = this;
switch (_that) {
case _ForumConfigDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ForumConfigDto value)?  $default,){
final _that = this;
switch (_that) {
case _ForumConfigDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? channelId,  bool requireTag,  ForumSortOrder defaultSortOrder,  ForumLayout defaultLayout,  String? defaultReactionEmojiId,  String? defaultReactionEmojiName,  int defaultThreadSlowModeSeconds,  int defaultAutoArchiveMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ForumConfigDto() when $default != null:
return $default(_that.channelId,_that.requireTag,_that.defaultSortOrder,_that.defaultLayout,_that.defaultReactionEmojiId,_that.defaultReactionEmojiName,_that.defaultThreadSlowModeSeconds,_that.defaultAutoArchiveMinutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? channelId,  bool requireTag,  ForumSortOrder defaultSortOrder,  ForumLayout defaultLayout,  String? defaultReactionEmojiId,  String? defaultReactionEmojiName,  int defaultThreadSlowModeSeconds,  int defaultAutoArchiveMinutes)  $default,) {final _that = this;
switch (_that) {
case _ForumConfigDto():
return $default(_that.channelId,_that.requireTag,_that.defaultSortOrder,_that.defaultLayout,_that.defaultReactionEmojiId,_that.defaultReactionEmojiName,_that.defaultThreadSlowModeSeconds,_that.defaultAutoArchiveMinutes);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? channelId,  bool requireTag,  ForumSortOrder defaultSortOrder,  ForumLayout defaultLayout,  String? defaultReactionEmojiId,  String? defaultReactionEmojiName,  int defaultThreadSlowModeSeconds,  int defaultAutoArchiveMinutes)?  $default,) {final _that = this;
switch (_that) {
case _ForumConfigDto() when $default != null:
return $default(_that.channelId,_that.requireTag,_that.defaultSortOrder,_that.defaultLayout,_that.defaultReactionEmojiId,_that.defaultReactionEmojiName,_that.defaultThreadSlowModeSeconds,_that.defaultAutoArchiveMinutes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ForumConfigDto implements ForumConfigDto {
  const _ForumConfigDto({this.channelId, this.requireTag = false, this.defaultSortOrder = ForumSortOrder.latestActivity, this.defaultLayout = ForumLayout.list, this.defaultReactionEmojiId, this.defaultReactionEmojiName, this.defaultThreadSlowModeSeconds = 0, this.defaultAutoArchiveMinutes = 4320});
  factory _ForumConfigDto.fromJson(Map<String, dynamic> json) => _$ForumConfigDtoFromJson(json);

@override final  String? channelId;
/// Posts must carry at least one tag. Enforced at write time only - it's
/// never applied retroactively to posts that predate it.
@override@JsonKey() final  bool requireTag;
@override@JsonKey() final  ForumSortOrder defaultSortOrder;
@override@JsonKey() final  ForumLayout defaultLayout;
@override final  String? defaultReactionEmojiId;
@override final  String? defaultReactionEmojiName;
/// Copied onto each new post at creation; changing it leaves existing
/// posts alone.
@override@JsonKey() final  int defaultThreadSlowModeSeconds;
/// One of [autoArchiveChoices] - 3 days by default.
@override@JsonKey() final  int defaultAutoArchiveMinutes;

/// Create a copy of ForumConfigDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ForumConfigDtoCopyWith<_ForumConfigDto> get copyWith => __$ForumConfigDtoCopyWithImpl<_ForumConfigDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ForumConfigDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ForumConfigDto&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.requireTag, requireTag) || other.requireTag == requireTag)&&(identical(other.defaultSortOrder, defaultSortOrder) || other.defaultSortOrder == defaultSortOrder)&&(identical(other.defaultLayout, defaultLayout) || other.defaultLayout == defaultLayout)&&(identical(other.defaultReactionEmojiId, defaultReactionEmojiId) || other.defaultReactionEmojiId == defaultReactionEmojiId)&&(identical(other.defaultReactionEmojiName, defaultReactionEmojiName) || other.defaultReactionEmojiName == defaultReactionEmojiName)&&(identical(other.defaultThreadSlowModeSeconds, defaultThreadSlowModeSeconds) || other.defaultThreadSlowModeSeconds == defaultThreadSlowModeSeconds)&&(identical(other.defaultAutoArchiveMinutes, defaultAutoArchiveMinutes) || other.defaultAutoArchiveMinutes == defaultAutoArchiveMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,channelId,requireTag,defaultSortOrder,defaultLayout,defaultReactionEmojiId,defaultReactionEmojiName,defaultThreadSlowModeSeconds,defaultAutoArchiveMinutes);

@override
String toString() {
  return 'ForumConfigDto(channelId: $channelId, requireTag: $requireTag, defaultSortOrder: $defaultSortOrder, defaultLayout: $defaultLayout, defaultReactionEmojiId: $defaultReactionEmojiId, defaultReactionEmojiName: $defaultReactionEmojiName, defaultThreadSlowModeSeconds: $defaultThreadSlowModeSeconds, defaultAutoArchiveMinutes: $defaultAutoArchiveMinutes)';
}


}

/// @nodoc
abstract mixin class _$ForumConfigDtoCopyWith<$Res> implements $ForumConfigDtoCopyWith<$Res> {
  factory _$ForumConfigDtoCopyWith(_ForumConfigDto value, $Res Function(_ForumConfigDto) _then) = __$ForumConfigDtoCopyWithImpl;
@override @useResult
$Res call({
 String? channelId, bool requireTag, ForumSortOrder defaultSortOrder, ForumLayout defaultLayout, String? defaultReactionEmojiId, String? defaultReactionEmojiName, int defaultThreadSlowModeSeconds, int defaultAutoArchiveMinutes
});




}
/// @nodoc
class __$ForumConfigDtoCopyWithImpl<$Res>
    implements _$ForumConfigDtoCopyWith<$Res> {
  __$ForumConfigDtoCopyWithImpl(this._self, this._then);

  final _ForumConfigDto _self;
  final $Res Function(_ForumConfigDto) _then;

/// Create a copy of ForumConfigDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? channelId = freezed,Object? requireTag = null,Object? defaultSortOrder = null,Object? defaultLayout = null,Object? defaultReactionEmojiId = freezed,Object? defaultReactionEmojiName = freezed,Object? defaultThreadSlowModeSeconds = null,Object? defaultAutoArchiveMinutes = null,}) {
  return _then(_ForumConfigDto(
channelId: freezed == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String?,requireTag: null == requireTag ? _self.requireTag : requireTag // ignore: cast_nullable_to_non_nullable
as bool,defaultSortOrder: null == defaultSortOrder ? _self.defaultSortOrder : defaultSortOrder // ignore: cast_nullable_to_non_nullable
as ForumSortOrder,defaultLayout: null == defaultLayout ? _self.defaultLayout : defaultLayout // ignore: cast_nullable_to_non_nullable
as ForumLayout,defaultReactionEmojiId: freezed == defaultReactionEmojiId ? _self.defaultReactionEmojiId : defaultReactionEmojiId // ignore: cast_nullable_to_non_nullable
as String?,defaultReactionEmojiName: freezed == defaultReactionEmojiName ? _self.defaultReactionEmojiName : defaultReactionEmojiName // ignore: cast_nullable_to_non_nullable
as String?,defaultThreadSlowModeSeconds: null == defaultThreadSlowModeSeconds ? _self.defaultThreadSlowModeSeconds : defaultThreadSlowModeSeconds // ignore: cast_nullable_to_non_nullable
as int,defaultAutoArchiveMinutes: null == defaultAutoArchiveMinutes ? _self.defaultAutoArchiveMinutes : defaultAutoArchiveMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
