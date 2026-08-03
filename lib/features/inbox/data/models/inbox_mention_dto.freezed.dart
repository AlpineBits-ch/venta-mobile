// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inbox_mention_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InboxMentionDto {

 String get messageId;/// Deliberately the raw wire string rather than a `DateTime`.
///
/// The mention index is keyed on this exact value and the dismiss endpoint
/// requires it back verbatim - a re-serialised timestamp that differs by a
/// trailing `Z` or a dropped millisecond matches no row, and the `DELETE`
/// then succeeds while deleting nothing. Parse it for display via
/// [InboxMentionDtoX.createdAt]; send [createdAtRaw].
@JsonKey(name: 'createdAt') String get createdAtRaw;@JsonKey(unknownEnumValue: InboxMentionKind.direct) InboxMentionKind get kind;/// Set when [kind] is [InboxMentionKind.role].
 String? get roleId; String? get roleName; String get authorId;/// Null for a DM mention, where [conversationId] is set instead.
 InboxBreadcrumbDto? get breadcrumb; String? get conversationId; InboxMessageDto? get message;
/// Create a copy of InboxMentionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InboxMentionDtoCopyWith<InboxMentionDto> get copyWith => _$InboxMentionDtoCopyWithImpl<InboxMentionDto>(this as InboxMentionDto, _$identity);

  /// Serializes this InboxMentionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InboxMentionDto&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.createdAtRaw, createdAtRaw) || other.createdAtRaw == createdAtRaw)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.roleId, roleId) || other.roleId == roleId)&&(identical(other.roleName, roleName) || other.roleName == roleName)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.breadcrumb, breadcrumb) || other.breadcrumb == breadcrumb)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,messageId,createdAtRaw,kind,roleId,roleName,authorId,breadcrumb,conversationId,message);

@override
String toString() {
  return 'InboxMentionDto(messageId: $messageId, createdAtRaw: $createdAtRaw, kind: $kind, roleId: $roleId, roleName: $roleName, authorId: $authorId, breadcrumb: $breadcrumb, conversationId: $conversationId, message: $message)';
}


}

/// @nodoc
abstract mixin class $InboxMentionDtoCopyWith<$Res>  {
  factory $InboxMentionDtoCopyWith(InboxMentionDto value, $Res Function(InboxMentionDto) _then) = _$InboxMentionDtoCopyWithImpl;
@useResult
$Res call({
 String messageId,@JsonKey(name: 'createdAt') String createdAtRaw,@JsonKey(unknownEnumValue: InboxMentionKind.direct) InboxMentionKind kind, String? roleId, String? roleName, String authorId, InboxBreadcrumbDto? breadcrumb, String? conversationId, InboxMessageDto? message
});


$InboxBreadcrumbDtoCopyWith<$Res>? get breadcrumb;$InboxMessageDtoCopyWith<$Res>? get message;

}
/// @nodoc
class _$InboxMentionDtoCopyWithImpl<$Res>
    implements $InboxMentionDtoCopyWith<$Res> {
  _$InboxMentionDtoCopyWithImpl(this._self, this._then);

  final InboxMentionDto _self;
  final $Res Function(InboxMentionDto) _then;

/// Create a copy of InboxMentionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? messageId = null,Object? createdAtRaw = null,Object? kind = null,Object? roleId = freezed,Object? roleName = freezed,Object? authorId = null,Object? breadcrumb = freezed,Object? conversationId = freezed,Object? message = freezed,}) {
  return _then(_self.copyWith(
messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,createdAtRaw: null == createdAtRaw ? _self.createdAtRaw : createdAtRaw // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as InboxMentionKind,roleId: freezed == roleId ? _self.roleId : roleId // ignore: cast_nullable_to_non_nullable
as String?,roleName: freezed == roleName ? _self.roleName : roleName // ignore: cast_nullable_to_non_nullable
as String?,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,breadcrumb: freezed == breadcrumb ? _self.breadcrumb : breadcrumb // ignore: cast_nullable_to_non_nullable
as InboxBreadcrumbDto?,conversationId: freezed == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as InboxMessageDto?,
  ));
}
/// Create a copy of InboxMentionDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InboxBreadcrumbDtoCopyWith<$Res>? get breadcrumb {
    if (_self.breadcrumb == null) {
    return null;
  }

  return $InboxBreadcrumbDtoCopyWith<$Res>(_self.breadcrumb!, (value) {
    return _then(_self.copyWith(breadcrumb: value));
  });
}/// Create a copy of InboxMentionDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InboxMessageDtoCopyWith<$Res>? get message {
    if (_self.message == null) {
    return null;
  }

  return $InboxMessageDtoCopyWith<$Res>(_self.message!, (value) {
    return _then(_self.copyWith(message: value));
  });
}
}


/// Adds pattern-matching-related methods to [InboxMentionDto].
extension InboxMentionDtoPatterns on InboxMentionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InboxMentionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InboxMentionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InboxMentionDto value)  $default,){
final _that = this;
switch (_that) {
case _InboxMentionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InboxMentionDto value)?  $default,){
final _that = this;
switch (_that) {
case _InboxMentionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String messageId, @JsonKey(name: 'createdAt')  String createdAtRaw, @JsonKey(unknownEnumValue: InboxMentionKind.direct)  InboxMentionKind kind,  String? roleId,  String? roleName,  String authorId,  InboxBreadcrumbDto? breadcrumb,  String? conversationId,  InboxMessageDto? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InboxMentionDto() when $default != null:
return $default(_that.messageId,_that.createdAtRaw,_that.kind,_that.roleId,_that.roleName,_that.authorId,_that.breadcrumb,_that.conversationId,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String messageId, @JsonKey(name: 'createdAt')  String createdAtRaw, @JsonKey(unknownEnumValue: InboxMentionKind.direct)  InboxMentionKind kind,  String? roleId,  String? roleName,  String authorId,  InboxBreadcrumbDto? breadcrumb,  String? conversationId,  InboxMessageDto? message)  $default,) {final _that = this;
switch (_that) {
case _InboxMentionDto():
return $default(_that.messageId,_that.createdAtRaw,_that.kind,_that.roleId,_that.roleName,_that.authorId,_that.breadcrumb,_that.conversationId,_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String messageId, @JsonKey(name: 'createdAt')  String createdAtRaw, @JsonKey(unknownEnumValue: InboxMentionKind.direct)  InboxMentionKind kind,  String? roleId,  String? roleName,  String authorId,  InboxBreadcrumbDto? breadcrumb,  String? conversationId,  InboxMessageDto? message)?  $default,) {final _that = this;
switch (_that) {
case _InboxMentionDto() when $default != null:
return $default(_that.messageId,_that.createdAtRaw,_that.kind,_that.roleId,_that.roleName,_that.authorId,_that.breadcrumb,_that.conversationId,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InboxMentionDto implements InboxMentionDto {
  const _InboxMentionDto({this.messageId = '', @JsonKey(name: 'createdAt') this.createdAtRaw = '', @JsonKey(unknownEnumValue: InboxMentionKind.direct) this.kind = InboxMentionKind.direct, this.roleId, this.roleName, this.authorId = '', this.breadcrumb, this.conversationId, this.message});
  factory _InboxMentionDto.fromJson(Map<String, dynamic> json) => _$InboxMentionDtoFromJson(json);

@override@JsonKey() final  String messageId;
/// Deliberately the raw wire string rather than a `DateTime`.
///
/// The mention index is keyed on this exact value and the dismiss endpoint
/// requires it back verbatim - a re-serialised timestamp that differs by a
/// trailing `Z` or a dropped millisecond matches no row, and the `DELETE`
/// then succeeds while deleting nothing. Parse it for display via
/// [InboxMentionDtoX.createdAt]; send [createdAtRaw].
@override@JsonKey(name: 'createdAt') final  String createdAtRaw;
@override@JsonKey(unknownEnumValue: InboxMentionKind.direct) final  InboxMentionKind kind;
/// Set when [kind] is [InboxMentionKind.role].
@override final  String? roleId;
@override final  String? roleName;
@override@JsonKey() final  String authorId;
/// Null for a DM mention, where [conversationId] is set instead.
@override final  InboxBreadcrumbDto? breadcrumb;
@override final  String? conversationId;
@override final  InboxMessageDto? message;

/// Create a copy of InboxMentionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InboxMentionDtoCopyWith<_InboxMentionDto> get copyWith => __$InboxMentionDtoCopyWithImpl<_InboxMentionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InboxMentionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InboxMentionDto&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.createdAtRaw, createdAtRaw) || other.createdAtRaw == createdAtRaw)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.roleId, roleId) || other.roleId == roleId)&&(identical(other.roleName, roleName) || other.roleName == roleName)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.breadcrumb, breadcrumb) || other.breadcrumb == breadcrumb)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,messageId,createdAtRaw,kind,roleId,roleName,authorId,breadcrumb,conversationId,message);

@override
String toString() {
  return 'InboxMentionDto(messageId: $messageId, createdAtRaw: $createdAtRaw, kind: $kind, roleId: $roleId, roleName: $roleName, authorId: $authorId, breadcrumb: $breadcrumb, conversationId: $conversationId, message: $message)';
}


}

/// @nodoc
abstract mixin class _$InboxMentionDtoCopyWith<$Res> implements $InboxMentionDtoCopyWith<$Res> {
  factory _$InboxMentionDtoCopyWith(_InboxMentionDto value, $Res Function(_InboxMentionDto) _then) = __$InboxMentionDtoCopyWithImpl;
@override @useResult
$Res call({
 String messageId,@JsonKey(name: 'createdAt') String createdAtRaw,@JsonKey(unknownEnumValue: InboxMentionKind.direct) InboxMentionKind kind, String? roleId, String? roleName, String authorId, InboxBreadcrumbDto? breadcrumb, String? conversationId, InboxMessageDto? message
});


@override $InboxBreadcrumbDtoCopyWith<$Res>? get breadcrumb;@override $InboxMessageDtoCopyWith<$Res>? get message;

}
/// @nodoc
class __$InboxMentionDtoCopyWithImpl<$Res>
    implements _$InboxMentionDtoCopyWith<$Res> {
  __$InboxMentionDtoCopyWithImpl(this._self, this._then);

  final _InboxMentionDto _self;
  final $Res Function(_InboxMentionDto) _then;

/// Create a copy of InboxMentionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? messageId = null,Object? createdAtRaw = null,Object? kind = null,Object? roleId = freezed,Object? roleName = freezed,Object? authorId = null,Object? breadcrumb = freezed,Object? conversationId = freezed,Object? message = freezed,}) {
  return _then(_InboxMentionDto(
messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,createdAtRaw: null == createdAtRaw ? _self.createdAtRaw : createdAtRaw // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as InboxMentionKind,roleId: freezed == roleId ? _self.roleId : roleId // ignore: cast_nullable_to_non_nullable
as String?,roleName: freezed == roleName ? _self.roleName : roleName // ignore: cast_nullable_to_non_nullable
as String?,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,breadcrumb: freezed == breadcrumb ? _self.breadcrumb : breadcrumb // ignore: cast_nullable_to_non_nullable
as InboxBreadcrumbDto?,conversationId: freezed == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as InboxMessageDto?,
  ));
}

/// Create a copy of InboxMentionDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InboxBreadcrumbDtoCopyWith<$Res>? get breadcrumb {
    if (_self.breadcrumb == null) {
    return null;
  }

  return $InboxBreadcrumbDtoCopyWith<$Res>(_self.breadcrumb!, (value) {
    return _then(_self.copyWith(breadcrumb: value));
  });
}/// Create a copy of InboxMentionDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InboxMessageDtoCopyWith<$Res>? get message {
    if (_self.message == null) {
    return null;
  }

  return $InboxMessageDtoCopyWith<$Res>(_self.message!, (value) {
    return _then(_self.copyWith(message: value));
  });
}
}


/// @nodoc
mixin _$InboxMentionPageDto {

 List<InboxMentionDto> get mentions; String? get nextCursor;
/// Create a copy of InboxMentionPageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InboxMentionPageDtoCopyWith<InboxMentionPageDto> get copyWith => _$InboxMentionPageDtoCopyWithImpl<InboxMentionPageDto>(this as InboxMentionPageDto, _$identity);

  /// Serializes this InboxMentionPageDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InboxMentionPageDto&&const DeepCollectionEquality().equals(other.mentions, mentions)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(mentions),nextCursor);

@override
String toString() {
  return 'InboxMentionPageDto(mentions: $mentions, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class $InboxMentionPageDtoCopyWith<$Res>  {
  factory $InboxMentionPageDtoCopyWith(InboxMentionPageDto value, $Res Function(InboxMentionPageDto) _then) = _$InboxMentionPageDtoCopyWithImpl;
@useResult
$Res call({
 List<InboxMentionDto> mentions, String? nextCursor
});




}
/// @nodoc
class _$InboxMentionPageDtoCopyWithImpl<$Res>
    implements $InboxMentionPageDtoCopyWith<$Res> {
  _$InboxMentionPageDtoCopyWithImpl(this._self, this._then);

  final InboxMentionPageDto _self;
  final $Res Function(InboxMentionPageDto) _then;

/// Create a copy of InboxMentionPageDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mentions = null,Object? nextCursor = freezed,}) {
  return _then(_self.copyWith(
mentions: null == mentions ? _self.mentions : mentions // ignore: cast_nullable_to_non_nullable
as List<InboxMentionDto>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [InboxMentionPageDto].
extension InboxMentionPageDtoPatterns on InboxMentionPageDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InboxMentionPageDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InboxMentionPageDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InboxMentionPageDto value)  $default,){
final _that = this;
switch (_that) {
case _InboxMentionPageDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InboxMentionPageDto value)?  $default,){
final _that = this;
switch (_that) {
case _InboxMentionPageDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<InboxMentionDto> mentions,  String? nextCursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InboxMentionPageDto() when $default != null:
return $default(_that.mentions,_that.nextCursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<InboxMentionDto> mentions,  String? nextCursor)  $default,) {final _that = this;
switch (_that) {
case _InboxMentionPageDto():
return $default(_that.mentions,_that.nextCursor);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<InboxMentionDto> mentions,  String? nextCursor)?  $default,) {final _that = this;
switch (_that) {
case _InboxMentionPageDto() when $default != null:
return $default(_that.mentions,_that.nextCursor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InboxMentionPageDto implements InboxMentionPageDto {
  const _InboxMentionPageDto({final  List<InboxMentionDto> mentions = const <InboxMentionDto>[], this.nextCursor}): _mentions = mentions;
  factory _InboxMentionPageDto.fromJson(Map<String, dynamic> json) => _$InboxMentionPageDtoFromJson(json);

 final  List<InboxMentionDto> _mentions;
@override@JsonKey() List<InboxMentionDto> get mentions {
  if (_mentions is EqualUnmodifiableListView) return _mentions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mentions);
}

@override final  String? nextCursor;

/// Create a copy of InboxMentionPageDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InboxMentionPageDtoCopyWith<_InboxMentionPageDto> get copyWith => __$InboxMentionPageDtoCopyWithImpl<_InboxMentionPageDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InboxMentionPageDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InboxMentionPageDto&&const DeepCollectionEquality().equals(other._mentions, _mentions)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_mentions),nextCursor);

@override
String toString() {
  return 'InboxMentionPageDto(mentions: $mentions, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class _$InboxMentionPageDtoCopyWith<$Res> implements $InboxMentionPageDtoCopyWith<$Res> {
  factory _$InboxMentionPageDtoCopyWith(_InboxMentionPageDto value, $Res Function(_InboxMentionPageDto) _then) = __$InboxMentionPageDtoCopyWithImpl;
@override @useResult
$Res call({
 List<InboxMentionDto> mentions, String? nextCursor
});




}
/// @nodoc
class __$InboxMentionPageDtoCopyWithImpl<$Res>
    implements _$InboxMentionPageDtoCopyWith<$Res> {
  __$InboxMentionPageDtoCopyWithImpl(this._self, this._then);

  final _InboxMentionPageDto _self;
  final $Res Function(_InboxMentionPageDto) _then;

/// Create a copy of InboxMentionPageDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mentions = null,Object? nextCursor = freezed,}) {
  return _then(_InboxMentionPageDto(
mentions: null == mentions ? _self._mentions : mentions // ignore: cast_nullable_to_non_nullable
as List<InboxMentionDto>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
