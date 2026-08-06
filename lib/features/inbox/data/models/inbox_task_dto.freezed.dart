// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inbox_task_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InboxTaskDto {

@JsonKey(unknownEnumValue: InboxTaskKind.unknown) InboxTaskKind get kind;/// The occurrence, decision or list item. What to deep-link on.
 String get targetId; InboxBreadcrumbDto get breadcrumb; String get title; String get subtitle;/// Null for a list assignment, which has no deadline.
 DateTime? get dueAt;/// **Respects the chore's grace period** - two hours late inside a 24-hour
/// grace is not overdue, so this is never re-derived from [dueAt] here. A
/// decision is overdue the moment it closes.
 bool get isOverdue;
/// Create a copy of InboxTaskDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InboxTaskDtoCopyWith<InboxTaskDto> get copyWith => _$InboxTaskDtoCopyWithImpl<InboxTaskDto>(this as InboxTaskDto, _$identity);

  /// Serializes this InboxTaskDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InboxTaskDto&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.breadcrumb, breadcrumb) || other.breadcrumb == breadcrumb)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.isOverdue, isOverdue) || other.isOverdue == isOverdue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,targetId,breadcrumb,title,subtitle,dueAt,isOverdue);

@override
String toString() {
  return 'InboxTaskDto(kind: $kind, targetId: $targetId, breadcrumb: $breadcrumb, title: $title, subtitle: $subtitle, dueAt: $dueAt, isOverdue: $isOverdue)';
}


}

/// @nodoc
abstract mixin class $InboxTaskDtoCopyWith<$Res>  {
  factory $InboxTaskDtoCopyWith(InboxTaskDto value, $Res Function(InboxTaskDto) _then) = _$InboxTaskDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: InboxTaskKind.unknown) InboxTaskKind kind, String targetId, InboxBreadcrumbDto breadcrumb, String title, String subtitle, DateTime? dueAt, bool isOverdue
});


$InboxBreadcrumbDtoCopyWith<$Res> get breadcrumb;

}
/// @nodoc
class _$InboxTaskDtoCopyWithImpl<$Res>
    implements $InboxTaskDtoCopyWith<$Res> {
  _$InboxTaskDtoCopyWithImpl(this._self, this._then);

  final InboxTaskDto _self;
  final $Res Function(InboxTaskDto) _then;

/// Create a copy of InboxTaskDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? targetId = null,Object? breadcrumb = null,Object? title = null,Object? subtitle = null,Object? dueAt = freezed,Object? isOverdue = null,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as InboxTaskKind,targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,breadcrumb: null == breadcrumb ? _self.breadcrumb : breadcrumb // ignore: cast_nullable_to_non_nullable
as InboxBreadcrumbDto,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isOverdue: null == isOverdue ? _self.isOverdue : isOverdue // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of InboxTaskDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InboxBreadcrumbDtoCopyWith<$Res> get breadcrumb {
  
  return $InboxBreadcrumbDtoCopyWith<$Res>(_self.breadcrumb, (value) {
    return _then(_self.copyWith(breadcrumb: value));
  });
}
}


/// Adds pattern-matching-related methods to [InboxTaskDto].
extension InboxTaskDtoPatterns on InboxTaskDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InboxTaskDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InboxTaskDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InboxTaskDto value)  $default,){
final _that = this;
switch (_that) {
case _InboxTaskDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InboxTaskDto value)?  $default,){
final _that = this;
switch (_that) {
case _InboxTaskDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: InboxTaskKind.unknown)  InboxTaskKind kind,  String targetId,  InboxBreadcrumbDto breadcrumb,  String title,  String subtitle,  DateTime? dueAt,  bool isOverdue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InboxTaskDto() when $default != null:
return $default(_that.kind,_that.targetId,_that.breadcrumb,_that.title,_that.subtitle,_that.dueAt,_that.isOverdue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: InboxTaskKind.unknown)  InboxTaskKind kind,  String targetId,  InboxBreadcrumbDto breadcrumb,  String title,  String subtitle,  DateTime? dueAt,  bool isOverdue)  $default,) {final _that = this;
switch (_that) {
case _InboxTaskDto():
return $default(_that.kind,_that.targetId,_that.breadcrumb,_that.title,_that.subtitle,_that.dueAt,_that.isOverdue);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: InboxTaskKind.unknown)  InboxTaskKind kind,  String targetId,  InboxBreadcrumbDto breadcrumb,  String title,  String subtitle,  DateTime? dueAt,  bool isOverdue)?  $default,) {final _that = this;
switch (_that) {
case _InboxTaskDto() when $default != null:
return $default(_that.kind,_that.targetId,_that.breadcrumb,_that.title,_that.subtitle,_that.dueAt,_that.isOverdue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _InboxTaskDto implements InboxTaskDto {
  const _InboxTaskDto({@JsonKey(unknownEnumValue: InboxTaskKind.unknown) this.kind = InboxTaskKind.unknown, this.targetId = '', this.breadcrumb = const InboxBreadcrumbDto(), this.title = '', this.subtitle = '', this.dueAt, this.isOverdue = false});
  factory _InboxTaskDto.fromJson(Map<String, dynamic> json) => _$InboxTaskDtoFromJson(json);

@override@JsonKey(unknownEnumValue: InboxTaskKind.unknown) final  InboxTaskKind kind;
/// The occurrence, decision or list item. What to deep-link on.
@override@JsonKey() final  String targetId;
@override@JsonKey() final  InboxBreadcrumbDto breadcrumb;
@override@JsonKey() final  String title;
@override@JsonKey() final  String subtitle;
/// Null for a list assignment, which has no deadline.
@override final  DateTime? dueAt;
/// **Respects the chore's grace period** - two hours late inside a 24-hour
/// grace is not overdue, so this is never re-derived from [dueAt] here. A
/// decision is overdue the moment it closes.
@override@JsonKey() final  bool isOverdue;

/// Create a copy of InboxTaskDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InboxTaskDtoCopyWith<_InboxTaskDto> get copyWith => __$InboxTaskDtoCopyWithImpl<_InboxTaskDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InboxTaskDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InboxTaskDto&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.breadcrumb, breadcrumb) || other.breadcrumb == breadcrumb)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.isOverdue, isOverdue) || other.isOverdue == isOverdue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,targetId,breadcrumb,title,subtitle,dueAt,isOverdue);

@override
String toString() {
  return 'InboxTaskDto(kind: $kind, targetId: $targetId, breadcrumb: $breadcrumb, title: $title, subtitle: $subtitle, dueAt: $dueAt, isOverdue: $isOverdue)';
}


}

/// @nodoc
abstract mixin class _$InboxTaskDtoCopyWith<$Res> implements $InboxTaskDtoCopyWith<$Res> {
  factory _$InboxTaskDtoCopyWith(_InboxTaskDto value, $Res Function(_InboxTaskDto) _then) = __$InboxTaskDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: InboxTaskKind.unknown) InboxTaskKind kind, String targetId, InboxBreadcrumbDto breadcrumb, String title, String subtitle, DateTime? dueAt, bool isOverdue
});


@override $InboxBreadcrumbDtoCopyWith<$Res> get breadcrumb;

}
/// @nodoc
class __$InboxTaskDtoCopyWithImpl<$Res>
    implements _$InboxTaskDtoCopyWith<$Res> {
  __$InboxTaskDtoCopyWithImpl(this._self, this._then);

  final _InboxTaskDto _self;
  final $Res Function(_InboxTaskDto) _then;

/// Create a copy of InboxTaskDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? targetId = null,Object? breadcrumb = null,Object? title = null,Object? subtitle = null,Object? dueAt = freezed,Object? isOverdue = null,}) {
  return _then(_InboxTaskDto(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as InboxTaskKind,targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,breadcrumb: null == breadcrumb ? _self.breadcrumb : breadcrumb // ignore: cast_nullable_to_non_nullable
as InboxBreadcrumbDto,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isOverdue: null == isOverdue ? _self.isOverdue : isOverdue // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of InboxTaskDto
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
mixin _$InboxTaskPageDto {

 List<InboxTaskDto> get tasks; bool get truncated;
/// Create a copy of InboxTaskPageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InboxTaskPageDtoCopyWith<InboxTaskPageDto> get copyWith => _$InboxTaskPageDtoCopyWithImpl<InboxTaskPageDto>(this as InboxTaskPageDto, _$identity);

  /// Serializes this InboxTaskPageDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InboxTaskPageDto&&const DeepCollectionEquality().equals(other.tasks, tasks)&&(identical(other.truncated, truncated) || other.truncated == truncated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(tasks),truncated);

@override
String toString() {
  return 'InboxTaskPageDto(tasks: $tasks, truncated: $truncated)';
}


}

/// @nodoc
abstract mixin class $InboxTaskPageDtoCopyWith<$Res>  {
  factory $InboxTaskPageDtoCopyWith(InboxTaskPageDto value, $Res Function(InboxTaskPageDto) _then) = _$InboxTaskPageDtoCopyWithImpl;
@useResult
$Res call({
 List<InboxTaskDto> tasks, bool truncated
});




}
/// @nodoc
class _$InboxTaskPageDtoCopyWithImpl<$Res>
    implements $InboxTaskPageDtoCopyWith<$Res> {
  _$InboxTaskPageDtoCopyWithImpl(this._self, this._then);

  final InboxTaskPageDto _self;
  final $Res Function(InboxTaskPageDto) _then;

/// Create a copy of InboxTaskPageDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tasks = null,Object? truncated = null,}) {
  return _then(_self.copyWith(
tasks: null == tasks ? _self.tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<InboxTaskDto>,truncated: null == truncated ? _self.truncated : truncated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [InboxTaskPageDto].
extension InboxTaskPageDtoPatterns on InboxTaskPageDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InboxTaskPageDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InboxTaskPageDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InboxTaskPageDto value)  $default,){
final _that = this;
switch (_that) {
case _InboxTaskPageDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InboxTaskPageDto value)?  $default,){
final _that = this;
switch (_that) {
case _InboxTaskPageDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<InboxTaskDto> tasks,  bool truncated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InboxTaskPageDto() when $default != null:
return $default(_that.tasks,_that.truncated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<InboxTaskDto> tasks,  bool truncated)  $default,) {final _that = this;
switch (_that) {
case _InboxTaskPageDto():
return $default(_that.tasks,_that.truncated);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<InboxTaskDto> tasks,  bool truncated)?  $default,) {final _that = this;
switch (_that) {
case _InboxTaskPageDto() when $default != null:
return $default(_that.tasks,_that.truncated);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InboxTaskPageDto implements InboxTaskPageDto {
  const _InboxTaskPageDto({final  List<InboxTaskDto> tasks = const <InboxTaskDto>[], this.truncated = false}): _tasks = tasks;
  factory _InboxTaskPageDto.fromJson(Map<String, dynamic> json) => _$InboxTaskPageDtoFromJson(json);

 final  List<InboxTaskDto> _tasks;
@override@JsonKey() List<InboxTaskDto> get tasks {
  if (_tasks is EqualUnmodifiableListView) return _tasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tasks);
}

@override@JsonKey() final  bool truncated;

/// Create a copy of InboxTaskPageDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InboxTaskPageDtoCopyWith<_InboxTaskPageDto> get copyWith => __$InboxTaskPageDtoCopyWithImpl<_InboxTaskPageDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InboxTaskPageDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InboxTaskPageDto&&const DeepCollectionEquality().equals(other._tasks, _tasks)&&(identical(other.truncated, truncated) || other.truncated == truncated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_tasks),truncated);

@override
String toString() {
  return 'InboxTaskPageDto(tasks: $tasks, truncated: $truncated)';
}


}

/// @nodoc
abstract mixin class _$InboxTaskPageDtoCopyWith<$Res> implements $InboxTaskPageDtoCopyWith<$Res> {
  factory _$InboxTaskPageDtoCopyWith(_InboxTaskPageDto value, $Res Function(_InboxTaskPageDto) _then) = __$InboxTaskPageDtoCopyWithImpl;
@override @useResult
$Res call({
 List<InboxTaskDto> tasks, bool truncated
});




}
/// @nodoc
class __$InboxTaskPageDtoCopyWithImpl<$Res>
    implements _$InboxTaskPageDtoCopyWith<$Res> {
  __$InboxTaskPageDtoCopyWithImpl(this._self, this._then);

  final _InboxTaskPageDto _self;
  final $Res Function(_InboxTaskPageDto) _then;

/// Create a copy of InboxTaskPageDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tasks = null,Object? truncated = null,}) {
  return _then(_InboxTaskPageDto(
tasks: null == tasks ? _self._tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<InboxTaskDto>,truncated: null == truncated ? _self.truncated : truncated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
