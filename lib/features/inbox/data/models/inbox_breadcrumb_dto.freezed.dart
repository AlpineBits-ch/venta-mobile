// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inbox_breadcrumb_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InboxBreadcrumbDto {

 String get guildId; String get guildName;/// A fixed path that *redirects* to a presigned URL, not a stored value -
/// and a `404` when the guild has no icon, which is the ordinary case.
/// `InboxGuildIcon` draws the name initial underneath and lets the image
/// cover it only when it really loads, so a 404 degrades to the fallback
/// instead of a blank square. Absolutised against the current server by
/// `InboxApi` - the wire value is server-relative.
 String? get guildIconUrl;/// The small variant, which is what the inbox is sized for.
 String? get guildIconThumbnailUrl;/// Null when the channel is uncategorised.
 String? get categoryId; String? get categoryName; String get channelId; String get channelName;/// Int on this endpoint, where `ChannelDto.type` is a string - see
/// [InboxBreadcrumbDtoX.channelKind] for the mapping.
 int get channelType;/// Set for threads and forum posts; [channelName] is then the post's own
/// title and this names the forum it lives in.
 String? get parentChannelId; String? get parentChannelName;
/// Create a copy of InboxBreadcrumbDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InboxBreadcrumbDtoCopyWith<InboxBreadcrumbDto> get copyWith => _$InboxBreadcrumbDtoCopyWithImpl<InboxBreadcrumbDto>(this as InboxBreadcrumbDto, _$identity);

  /// Serializes this InboxBreadcrumbDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InboxBreadcrumbDto&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.guildName, guildName) || other.guildName == guildName)&&(identical(other.guildIconUrl, guildIconUrl) || other.guildIconUrl == guildIconUrl)&&(identical(other.guildIconThumbnailUrl, guildIconThumbnailUrl) || other.guildIconThumbnailUrl == guildIconThumbnailUrl)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.channelName, channelName) || other.channelName == channelName)&&(identical(other.channelType, channelType) || other.channelType == channelType)&&(identical(other.parentChannelId, parentChannelId) || other.parentChannelId == parentChannelId)&&(identical(other.parentChannelName, parentChannelName) || other.parentChannelName == parentChannelName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,guildId,guildName,guildIconUrl,guildIconThumbnailUrl,categoryId,categoryName,channelId,channelName,channelType,parentChannelId,parentChannelName);

@override
String toString() {
  return 'InboxBreadcrumbDto(guildId: $guildId, guildName: $guildName, guildIconUrl: $guildIconUrl, guildIconThumbnailUrl: $guildIconThumbnailUrl, categoryId: $categoryId, categoryName: $categoryName, channelId: $channelId, channelName: $channelName, channelType: $channelType, parentChannelId: $parentChannelId, parentChannelName: $parentChannelName)';
}


}

/// @nodoc
abstract mixin class $InboxBreadcrumbDtoCopyWith<$Res>  {
  factory $InboxBreadcrumbDtoCopyWith(InboxBreadcrumbDto value, $Res Function(InboxBreadcrumbDto) _then) = _$InboxBreadcrumbDtoCopyWithImpl;
@useResult
$Res call({
 String guildId, String guildName, String? guildIconUrl, String? guildIconThumbnailUrl, String? categoryId, String? categoryName, String channelId, String channelName, int channelType, String? parentChannelId, String? parentChannelName
});




}
/// @nodoc
class _$InboxBreadcrumbDtoCopyWithImpl<$Res>
    implements $InboxBreadcrumbDtoCopyWith<$Res> {
  _$InboxBreadcrumbDtoCopyWithImpl(this._self, this._then);

  final InboxBreadcrumbDto _self;
  final $Res Function(InboxBreadcrumbDto) _then;

/// Create a copy of InboxBreadcrumbDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? guildId = null,Object? guildName = null,Object? guildIconUrl = freezed,Object? guildIconThumbnailUrl = freezed,Object? categoryId = freezed,Object? categoryName = freezed,Object? channelId = null,Object? channelName = null,Object? channelType = null,Object? parentChannelId = freezed,Object? parentChannelName = freezed,}) {
  return _then(_self.copyWith(
guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,guildName: null == guildName ? _self.guildName : guildName // ignore: cast_nullable_to_non_nullable
as String,guildIconUrl: freezed == guildIconUrl ? _self.guildIconUrl : guildIconUrl // ignore: cast_nullable_to_non_nullable
as String?,guildIconThumbnailUrl: freezed == guildIconThumbnailUrl ? _self.guildIconThumbnailUrl : guildIconThumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,channelName: null == channelName ? _self.channelName : channelName // ignore: cast_nullable_to_non_nullable
as String,channelType: null == channelType ? _self.channelType : channelType // ignore: cast_nullable_to_non_nullable
as int,parentChannelId: freezed == parentChannelId ? _self.parentChannelId : parentChannelId // ignore: cast_nullable_to_non_nullable
as String?,parentChannelName: freezed == parentChannelName ? _self.parentChannelName : parentChannelName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [InboxBreadcrumbDto].
extension InboxBreadcrumbDtoPatterns on InboxBreadcrumbDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InboxBreadcrumbDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InboxBreadcrumbDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InboxBreadcrumbDto value)  $default,){
final _that = this;
switch (_that) {
case _InboxBreadcrumbDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InboxBreadcrumbDto value)?  $default,){
final _that = this;
switch (_that) {
case _InboxBreadcrumbDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String guildId,  String guildName,  String? guildIconUrl,  String? guildIconThumbnailUrl,  String? categoryId,  String? categoryName,  String channelId,  String channelName,  int channelType,  String? parentChannelId,  String? parentChannelName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InboxBreadcrumbDto() when $default != null:
return $default(_that.guildId,_that.guildName,_that.guildIconUrl,_that.guildIconThumbnailUrl,_that.categoryId,_that.categoryName,_that.channelId,_that.channelName,_that.channelType,_that.parentChannelId,_that.parentChannelName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String guildId,  String guildName,  String? guildIconUrl,  String? guildIconThumbnailUrl,  String? categoryId,  String? categoryName,  String channelId,  String channelName,  int channelType,  String? parentChannelId,  String? parentChannelName)  $default,) {final _that = this;
switch (_that) {
case _InboxBreadcrumbDto():
return $default(_that.guildId,_that.guildName,_that.guildIconUrl,_that.guildIconThumbnailUrl,_that.categoryId,_that.categoryName,_that.channelId,_that.channelName,_that.channelType,_that.parentChannelId,_that.parentChannelName);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String guildId,  String guildName,  String? guildIconUrl,  String? guildIconThumbnailUrl,  String? categoryId,  String? categoryName,  String channelId,  String channelName,  int channelType,  String? parentChannelId,  String? parentChannelName)?  $default,) {final _that = this;
switch (_that) {
case _InboxBreadcrumbDto() when $default != null:
return $default(_that.guildId,_that.guildName,_that.guildIconUrl,_that.guildIconThumbnailUrl,_that.categoryId,_that.categoryName,_that.channelId,_that.channelName,_that.channelType,_that.parentChannelId,_that.parentChannelName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InboxBreadcrumbDto implements InboxBreadcrumbDto {
  const _InboxBreadcrumbDto({this.guildId = '', this.guildName = '', this.guildIconUrl, this.guildIconThumbnailUrl, this.categoryId, this.categoryName, this.channelId = '', this.channelName = '', this.channelType = 0, this.parentChannelId, this.parentChannelName});
  factory _InboxBreadcrumbDto.fromJson(Map<String, dynamic> json) => _$InboxBreadcrumbDtoFromJson(json);

@override@JsonKey() final  String guildId;
@override@JsonKey() final  String guildName;
/// A fixed path that *redirects* to a presigned URL, not a stored value -
/// and a `404` when the guild has no icon, which is the ordinary case.
/// `InboxGuildIcon` draws the name initial underneath and lets the image
/// cover it only when it really loads, so a 404 degrades to the fallback
/// instead of a blank square. Absolutised against the current server by
/// `InboxApi` - the wire value is server-relative.
@override final  String? guildIconUrl;
/// The small variant, which is what the inbox is sized for.
@override final  String? guildIconThumbnailUrl;
/// Null when the channel is uncategorised.
@override final  String? categoryId;
@override final  String? categoryName;
@override@JsonKey() final  String channelId;
@override@JsonKey() final  String channelName;
/// Int on this endpoint, where `ChannelDto.type` is a string - see
/// [InboxBreadcrumbDtoX.channelKind] for the mapping.
@override@JsonKey() final  int channelType;
/// Set for threads and forum posts; [channelName] is then the post's own
/// title and this names the forum it lives in.
@override final  String? parentChannelId;
@override final  String? parentChannelName;

/// Create a copy of InboxBreadcrumbDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InboxBreadcrumbDtoCopyWith<_InboxBreadcrumbDto> get copyWith => __$InboxBreadcrumbDtoCopyWithImpl<_InboxBreadcrumbDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InboxBreadcrumbDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InboxBreadcrumbDto&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.guildName, guildName) || other.guildName == guildName)&&(identical(other.guildIconUrl, guildIconUrl) || other.guildIconUrl == guildIconUrl)&&(identical(other.guildIconThumbnailUrl, guildIconThumbnailUrl) || other.guildIconThumbnailUrl == guildIconThumbnailUrl)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.channelName, channelName) || other.channelName == channelName)&&(identical(other.channelType, channelType) || other.channelType == channelType)&&(identical(other.parentChannelId, parentChannelId) || other.parentChannelId == parentChannelId)&&(identical(other.parentChannelName, parentChannelName) || other.parentChannelName == parentChannelName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,guildId,guildName,guildIconUrl,guildIconThumbnailUrl,categoryId,categoryName,channelId,channelName,channelType,parentChannelId,parentChannelName);

@override
String toString() {
  return 'InboxBreadcrumbDto(guildId: $guildId, guildName: $guildName, guildIconUrl: $guildIconUrl, guildIconThumbnailUrl: $guildIconThumbnailUrl, categoryId: $categoryId, categoryName: $categoryName, channelId: $channelId, channelName: $channelName, channelType: $channelType, parentChannelId: $parentChannelId, parentChannelName: $parentChannelName)';
}


}

/// @nodoc
abstract mixin class _$InboxBreadcrumbDtoCopyWith<$Res> implements $InboxBreadcrumbDtoCopyWith<$Res> {
  factory _$InboxBreadcrumbDtoCopyWith(_InboxBreadcrumbDto value, $Res Function(_InboxBreadcrumbDto) _then) = __$InboxBreadcrumbDtoCopyWithImpl;
@override @useResult
$Res call({
 String guildId, String guildName, String? guildIconUrl, String? guildIconThumbnailUrl, String? categoryId, String? categoryName, String channelId, String channelName, int channelType, String? parentChannelId, String? parentChannelName
});




}
/// @nodoc
class __$InboxBreadcrumbDtoCopyWithImpl<$Res>
    implements _$InboxBreadcrumbDtoCopyWith<$Res> {
  __$InboxBreadcrumbDtoCopyWithImpl(this._self, this._then);

  final _InboxBreadcrumbDto _self;
  final $Res Function(_InboxBreadcrumbDto) _then;

/// Create a copy of InboxBreadcrumbDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? guildId = null,Object? guildName = null,Object? guildIconUrl = freezed,Object? guildIconThumbnailUrl = freezed,Object? categoryId = freezed,Object? categoryName = freezed,Object? channelId = null,Object? channelName = null,Object? channelType = null,Object? parentChannelId = freezed,Object? parentChannelName = freezed,}) {
  return _then(_InboxBreadcrumbDto(
guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,guildName: null == guildName ? _self.guildName : guildName // ignore: cast_nullable_to_non_nullable
as String,guildIconUrl: freezed == guildIconUrl ? _self.guildIconUrl : guildIconUrl // ignore: cast_nullable_to_non_nullable
as String?,guildIconThumbnailUrl: freezed == guildIconThumbnailUrl ? _self.guildIconThumbnailUrl : guildIconThumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,channelName: null == channelName ? _self.channelName : channelName // ignore: cast_nullable_to_non_nullable
as String,channelType: null == channelType ? _self.channelType : channelType // ignore: cast_nullable_to_non_nullable
as int,parentChannelId: freezed == parentChannelId ? _self.parentChannelId : parentChannelId // ignore: cast_nullable_to_non_nullable
as String?,parentChannelName: freezed == parentChannelName ? _self.parentChannelName : parentChannelName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
