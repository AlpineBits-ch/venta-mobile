// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inbox_unread_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InboxUnreadGroupDto {

 InboxBreadcrumbDto get breadcrumb;/// What the list is ordered by. Ids are not - they only sort by creation
/// time if they were minted after the ULID change, so nothing anywhere in
/// this feature compares two ids to work out which is newer.
 DateTime? get lastActivityAt;/// Best-effort. See the class comment.
 int get unreadCount;/// Exact.
 int get mentionCount;/// Oldest first, at most five.
 List<InboxMessageDto> get previews;/// Whether there are unread messages above [previews]' oldest entry.
 bool get previewsTruncated;
/// Create a copy of InboxUnreadGroupDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InboxUnreadGroupDtoCopyWith<InboxUnreadGroupDto> get copyWith => _$InboxUnreadGroupDtoCopyWithImpl<InboxUnreadGroupDto>(this as InboxUnreadGroupDto, _$identity);

  /// Serializes this InboxUnreadGroupDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InboxUnreadGroupDto&&(identical(other.breadcrumb, breadcrumb) || other.breadcrumb == breadcrumb)&&(identical(other.lastActivityAt, lastActivityAt) || other.lastActivityAt == lastActivityAt)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.mentionCount, mentionCount) || other.mentionCount == mentionCount)&&const DeepCollectionEquality().equals(other.previews, previews)&&(identical(other.previewsTruncated, previewsTruncated) || other.previewsTruncated == previewsTruncated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,breadcrumb,lastActivityAt,unreadCount,mentionCount,const DeepCollectionEquality().hash(previews),previewsTruncated);

@override
String toString() {
  return 'InboxUnreadGroupDto(breadcrumb: $breadcrumb, lastActivityAt: $lastActivityAt, unreadCount: $unreadCount, mentionCount: $mentionCount, previews: $previews, previewsTruncated: $previewsTruncated)';
}


}

/// @nodoc
abstract mixin class $InboxUnreadGroupDtoCopyWith<$Res>  {
  factory $InboxUnreadGroupDtoCopyWith(InboxUnreadGroupDto value, $Res Function(InboxUnreadGroupDto) _then) = _$InboxUnreadGroupDtoCopyWithImpl;
@useResult
$Res call({
 InboxBreadcrumbDto breadcrumb, DateTime? lastActivityAt, int unreadCount, int mentionCount, List<InboxMessageDto> previews, bool previewsTruncated
});


$InboxBreadcrumbDtoCopyWith<$Res> get breadcrumb;

}
/// @nodoc
class _$InboxUnreadGroupDtoCopyWithImpl<$Res>
    implements $InboxUnreadGroupDtoCopyWith<$Res> {
  _$InboxUnreadGroupDtoCopyWithImpl(this._self, this._then);

  final InboxUnreadGroupDto _self;
  final $Res Function(InboxUnreadGroupDto) _then;

/// Create a copy of InboxUnreadGroupDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? breadcrumb = null,Object? lastActivityAt = freezed,Object? unreadCount = null,Object? mentionCount = null,Object? previews = null,Object? previewsTruncated = null,}) {
  return _then(_self.copyWith(
breadcrumb: null == breadcrumb ? _self.breadcrumb : breadcrumb // ignore: cast_nullable_to_non_nullable
as InboxBreadcrumbDto,lastActivityAt: freezed == lastActivityAt ? _self.lastActivityAt : lastActivityAt // ignore: cast_nullable_to_non_nullable
as DateTime?,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,mentionCount: null == mentionCount ? _self.mentionCount : mentionCount // ignore: cast_nullable_to_non_nullable
as int,previews: null == previews ? _self.previews : previews // ignore: cast_nullable_to_non_nullable
as List<InboxMessageDto>,previewsTruncated: null == previewsTruncated ? _self.previewsTruncated : previewsTruncated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of InboxUnreadGroupDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InboxBreadcrumbDtoCopyWith<$Res> get breadcrumb {
  
  return $InboxBreadcrumbDtoCopyWith<$Res>(_self.breadcrumb, (value) {
    return _then(_self.copyWith(breadcrumb: value));
  });
}
}


/// Adds pattern-matching-related methods to [InboxUnreadGroupDto].
extension InboxUnreadGroupDtoPatterns on InboxUnreadGroupDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InboxUnreadGroupDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InboxUnreadGroupDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InboxUnreadGroupDto value)  $default,){
final _that = this;
switch (_that) {
case _InboxUnreadGroupDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InboxUnreadGroupDto value)?  $default,){
final _that = this;
switch (_that) {
case _InboxUnreadGroupDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( InboxBreadcrumbDto breadcrumb,  DateTime? lastActivityAt,  int unreadCount,  int mentionCount,  List<InboxMessageDto> previews,  bool previewsTruncated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InboxUnreadGroupDto() when $default != null:
return $default(_that.breadcrumb,_that.lastActivityAt,_that.unreadCount,_that.mentionCount,_that.previews,_that.previewsTruncated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( InboxBreadcrumbDto breadcrumb,  DateTime? lastActivityAt,  int unreadCount,  int mentionCount,  List<InboxMessageDto> previews,  bool previewsTruncated)  $default,) {final _that = this;
switch (_that) {
case _InboxUnreadGroupDto():
return $default(_that.breadcrumb,_that.lastActivityAt,_that.unreadCount,_that.mentionCount,_that.previews,_that.previewsTruncated);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( InboxBreadcrumbDto breadcrumb,  DateTime? lastActivityAt,  int unreadCount,  int mentionCount,  List<InboxMessageDto> previews,  bool previewsTruncated)?  $default,) {final _that = this;
switch (_that) {
case _InboxUnreadGroupDto() when $default != null:
return $default(_that.breadcrumb,_that.lastActivityAt,_that.unreadCount,_that.mentionCount,_that.previews,_that.previewsTruncated);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _InboxUnreadGroupDto implements InboxUnreadGroupDto {
  const _InboxUnreadGroupDto({this.breadcrumb = const InboxBreadcrumbDto(), this.lastActivityAt, this.unreadCount = 0, this.mentionCount = 0, final  List<InboxMessageDto> previews = const <InboxMessageDto>[], this.previewsTruncated = false}): _previews = previews;
  factory _InboxUnreadGroupDto.fromJson(Map<String, dynamic> json) => _$InboxUnreadGroupDtoFromJson(json);

@override@JsonKey() final  InboxBreadcrumbDto breadcrumb;
/// What the list is ordered by. Ids are not - they only sort by creation
/// time if they were minted after the ULID change, so nothing anywhere in
/// this feature compares two ids to work out which is newer.
@override final  DateTime? lastActivityAt;
/// Best-effort. See the class comment.
@override@JsonKey() final  int unreadCount;
/// Exact.
@override@JsonKey() final  int mentionCount;
/// Oldest first, at most five.
 final  List<InboxMessageDto> _previews;
/// Oldest first, at most five.
@override@JsonKey() List<InboxMessageDto> get previews {
  if (_previews is EqualUnmodifiableListView) return _previews;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_previews);
}

/// Whether there are unread messages above [previews]' oldest entry.
@override@JsonKey() final  bool previewsTruncated;

/// Create a copy of InboxUnreadGroupDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InboxUnreadGroupDtoCopyWith<_InboxUnreadGroupDto> get copyWith => __$InboxUnreadGroupDtoCopyWithImpl<_InboxUnreadGroupDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InboxUnreadGroupDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InboxUnreadGroupDto&&(identical(other.breadcrumb, breadcrumb) || other.breadcrumb == breadcrumb)&&(identical(other.lastActivityAt, lastActivityAt) || other.lastActivityAt == lastActivityAt)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.mentionCount, mentionCount) || other.mentionCount == mentionCount)&&const DeepCollectionEquality().equals(other._previews, _previews)&&(identical(other.previewsTruncated, previewsTruncated) || other.previewsTruncated == previewsTruncated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,breadcrumb,lastActivityAt,unreadCount,mentionCount,const DeepCollectionEquality().hash(_previews),previewsTruncated);

@override
String toString() {
  return 'InboxUnreadGroupDto(breadcrumb: $breadcrumb, lastActivityAt: $lastActivityAt, unreadCount: $unreadCount, mentionCount: $mentionCount, previews: $previews, previewsTruncated: $previewsTruncated)';
}


}

/// @nodoc
abstract mixin class _$InboxUnreadGroupDtoCopyWith<$Res> implements $InboxUnreadGroupDtoCopyWith<$Res> {
  factory _$InboxUnreadGroupDtoCopyWith(_InboxUnreadGroupDto value, $Res Function(_InboxUnreadGroupDto) _then) = __$InboxUnreadGroupDtoCopyWithImpl;
@override @useResult
$Res call({
 InboxBreadcrumbDto breadcrumb, DateTime? lastActivityAt, int unreadCount, int mentionCount, List<InboxMessageDto> previews, bool previewsTruncated
});


@override $InboxBreadcrumbDtoCopyWith<$Res> get breadcrumb;

}
/// @nodoc
class __$InboxUnreadGroupDtoCopyWithImpl<$Res>
    implements _$InboxUnreadGroupDtoCopyWith<$Res> {
  __$InboxUnreadGroupDtoCopyWithImpl(this._self, this._then);

  final _InboxUnreadGroupDto _self;
  final $Res Function(_InboxUnreadGroupDto) _then;

/// Create a copy of InboxUnreadGroupDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? breadcrumb = null,Object? lastActivityAt = freezed,Object? unreadCount = null,Object? mentionCount = null,Object? previews = null,Object? previewsTruncated = null,}) {
  return _then(_InboxUnreadGroupDto(
breadcrumb: null == breadcrumb ? _self.breadcrumb : breadcrumb // ignore: cast_nullable_to_non_nullable
as InboxBreadcrumbDto,lastActivityAt: freezed == lastActivityAt ? _self.lastActivityAt : lastActivityAt // ignore: cast_nullable_to_non_nullable
as DateTime?,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,mentionCount: null == mentionCount ? _self.mentionCount : mentionCount // ignore: cast_nullable_to_non_nullable
as int,previews: null == previews ? _self._previews : previews // ignore: cast_nullable_to_non_nullable
as List<InboxMessageDto>,previewsTruncated: null == previewsTruncated ? _self.previewsTruncated : previewsTruncated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of InboxUnreadGroupDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InboxBreadcrumbDtoCopyWith<$Res> get breadcrumb {
  
  return $InboxBreadcrumbDtoCopyWith<$Res>(_self.breadcrumb, (value) {
    return _then(_self.copyWith(breadcrumb: value));
  });
}
}


/// @nodoc
mixin _$InboxUnreadPageDto {

 List<InboxUnreadGroupDto> get groups; String? get nextCursor;/// The message service could not be reached. **The groups, counts and
/// breadcrumbs are still correct** - they come from a different service -
/// so this is a `200` to render without bodies, not an error. Retrying the
/// same request is reasonable, and `InboxCubit` does exactly that in the
/// background.
 bool get previewsUnavailable;
/// Create a copy of InboxUnreadPageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InboxUnreadPageDtoCopyWith<InboxUnreadPageDto> get copyWith => _$InboxUnreadPageDtoCopyWithImpl<InboxUnreadPageDto>(this as InboxUnreadPageDto, _$identity);

  /// Serializes this InboxUnreadPageDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InboxUnreadPageDto&&const DeepCollectionEquality().equals(other.groups, groups)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.previewsUnavailable, previewsUnavailable) || other.previewsUnavailable == previewsUnavailable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(groups),nextCursor,previewsUnavailable);

@override
String toString() {
  return 'InboxUnreadPageDto(groups: $groups, nextCursor: $nextCursor, previewsUnavailable: $previewsUnavailable)';
}


}

/// @nodoc
abstract mixin class $InboxUnreadPageDtoCopyWith<$Res>  {
  factory $InboxUnreadPageDtoCopyWith(InboxUnreadPageDto value, $Res Function(InboxUnreadPageDto) _then) = _$InboxUnreadPageDtoCopyWithImpl;
@useResult
$Res call({
 List<InboxUnreadGroupDto> groups, String? nextCursor, bool previewsUnavailable
});




}
/// @nodoc
class _$InboxUnreadPageDtoCopyWithImpl<$Res>
    implements $InboxUnreadPageDtoCopyWith<$Res> {
  _$InboxUnreadPageDtoCopyWithImpl(this._self, this._then);

  final InboxUnreadPageDto _self;
  final $Res Function(InboxUnreadPageDto) _then;

/// Create a copy of InboxUnreadPageDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? groups = null,Object? nextCursor = freezed,Object? previewsUnavailable = null,}) {
  return _then(_self.copyWith(
groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<InboxUnreadGroupDto>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,previewsUnavailable: null == previewsUnavailable ? _self.previewsUnavailable : previewsUnavailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [InboxUnreadPageDto].
extension InboxUnreadPageDtoPatterns on InboxUnreadPageDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InboxUnreadPageDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InboxUnreadPageDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InboxUnreadPageDto value)  $default,){
final _that = this;
switch (_that) {
case _InboxUnreadPageDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InboxUnreadPageDto value)?  $default,){
final _that = this;
switch (_that) {
case _InboxUnreadPageDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<InboxUnreadGroupDto> groups,  String? nextCursor,  bool previewsUnavailable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InboxUnreadPageDto() when $default != null:
return $default(_that.groups,_that.nextCursor,_that.previewsUnavailable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<InboxUnreadGroupDto> groups,  String? nextCursor,  bool previewsUnavailable)  $default,) {final _that = this;
switch (_that) {
case _InboxUnreadPageDto():
return $default(_that.groups,_that.nextCursor,_that.previewsUnavailable);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<InboxUnreadGroupDto> groups,  String? nextCursor,  bool previewsUnavailable)?  $default,) {final _that = this;
switch (_that) {
case _InboxUnreadPageDto() when $default != null:
return $default(_that.groups,_that.nextCursor,_that.previewsUnavailable);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InboxUnreadPageDto implements InboxUnreadPageDto {
  const _InboxUnreadPageDto({final  List<InboxUnreadGroupDto> groups = const <InboxUnreadGroupDto>[], this.nextCursor, this.previewsUnavailable = false}): _groups = groups;
  factory _InboxUnreadPageDto.fromJson(Map<String, dynamic> json) => _$InboxUnreadPageDtoFromJson(json);

 final  List<InboxUnreadGroupDto> _groups;
@override@JsonKey() List<InboxUnreadGroupDto> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}

@override final  String? nextCursor;
/// The message service could not be reached. **The groups, counts and
/// breadcrumbs are still correct** - they come from a different service -
/// so this is a `200` to render without bodies, not an error. Retrying the
/// same request is reasonable, and `InboxCubit` does exactly that in the
/// background.
@override@JsonKey() final  bool previewsUnavailable;

/// Create a copy of InboxUnreadPageDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InboxUnreadPageDtoCopyWith<_InboxUnreadPageDto> get copyWith => __$InboxUnreadPageDtoCopyWithImpl<_InboxUnreadPageDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InboxUnreadPageDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InboxUnreadPageDto&&const DeepCollectionEquality().equals(other._groups, _groups)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.previewsUnavailable, previewsUnavailable) || other.previewsUnavailable == previewsUnavailable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_groups),nextCursor,previewsUnavailable);

@override
String toString() {
  return 'InboxUnreadPageDto(groups: $groups, nextCursor: $nextCursor, previewsUnavailable: $previewsUnavailable)';
}


}

/// @nodoc
abstract mixin class _$InboxUnreadPageDtoCopyWith<$Res> implements $InboxUnreadPageDtoCopyWith<$Res> {
  factory _$InboxUnreadPageDtoCopyWith(_InboxUnreadPageDto value, $Res Function(_InboxUnreadPageDto) _then) = __$InboxUnreadPageDtoCopyWithImpl;
@override @useResult
$Res call({
 List<InboxUnreadGroupDto> groups, String? nextCursor, bool previewsUnavailable
});




}
/// @nodoc
class __$InboxUnreadPageDtoCopyWithImpl<$Res>
    implements _$InboxUnreadPageDtoCopyWith<$Res> {
  __$InboxUnreadPageDtoCopyWithImpl(this._self, this._then);

  final _InboxUnreadPageDto _self;
  final $Res Function(_InboxUnreadPageDto) _then;

/// Create a copy of InboxUnreadPageDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? groups = null,Object? nextCursor = freezed,Object? previewsUnavailable = null,}) {
  return _then(_InboxUnreadPageDto(
groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<InboxUnreadGroupDto>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,previewsUnavailable: null == previewsUnavailable ? _self.previewsUnavailable : previewsUnavailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
