// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inbox_summary_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InboxSummaryDto {

 int get unreadChannelCount; int get mentionCount;/// Household rows waiting on the caller - the Waiting tab. Capped the same
/// way the others are, and reported here so the header badge needs one
/// request rather than two.
 int get taskCount;/// The real numbers are higher than reported. Counting further would be an
/// unbounded scan for a number that renders as `99+` either way.
 bool get capped;
/// Create a copy of InboxSummaryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InboxSummaryDtoCopyWith<InboxSummaryDto> get copyWith => _$InboxSummaryDtoCopyWithImpl<InboxSummaryDto>(this as InboxSummaryDto, _$identity);

  /// Serializes this InboxSummaryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InboxSummaryDto&&(identical(other.unreadChannelCount, unreadChannelCount) || other.unreadChannelCount == unreadChannelCount)&&(identical(other.mentionCount, mentionCount) || other.mentionCount == mentionCount)&&(identical(other.taskCount, taskCount) || other.taskCount == taskCount)&&(identical(other.capped, capped) || other.capped == capped));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,unreadChannelCount,mentionCount,taskCount,capped);

@override
String toString() {
  return 'InboxSummaryDto(unreadChannelCount: $unreadChannelCount, mentionCount: $mentionCount, taskCount: $taskCount, capped: $capped)';
}


}

/// @nodoc
abstract mixin class $InboxSummaryDtoCopyWith<$Res>  {
  factory $InboxSummaryDtoCopyWith(InboxSummaryDto value, $Res Function(InboxSummaryDto) _then) = _$InboxSummaryDtoCopyWithImpl;
@useResult
$Res call({
 int unreadChannelCount, int mentionCount, int taskCount, bool capped
});




}
/// @nodoc
class _$InboxSummaryDtoCopyWithImpl<$Res>
    implements $InboxSummaryDtoCopyWith<$Res> {
  _$InboxSummaryDtoCopyWithImpl(this._self, this._then);

  final InboxSummaryDto _self;
  final $Res Function(InboxSummaryDto) _then;

/// Create a copy of InboxSummaryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? unreadChannelCount = null,Object? mentionCount = null,Object? taskCount = null,Object? capped = null,}) {
  return _then(_self.copyWith(
unreadChannelCount: null == unreadChannelCount ? _self.unreadChannelCount : unreadChannelCount // ignore: cast_nullable_to_non_nullable
as int,mentionCount: null == mentionCount ? _self.mentionCount : mentionCount // ignore: cast_nullable_to_non_nullable
as int,taskCount: null == taskCount ? _self.taskCount : taskCount // ignore: cast_nullable_to_non_nullable
as int,capped: null == capped ? _self.capped : capped // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [InboxSummaryDto].
extension InboxSummaryDtoPatterns on InboxSummaryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InboxSummaryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InboxSummaryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InboxSummaryDto value)  $default,){
final _that = this;
switch (_that) {
case _InboxSummaryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InboxSummaryDto value)?  $default,){
final _that = this;
switch (_that) {
case _InboxSummaryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int unreadChannelCount,  int mentionCount,  int taskCount,  bool capped)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InboxSummaryDto() when $default != null:
return $default(_that.unreadChannelCount,_that.mentionCount,_that.taskCount,_that.capped);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int unreadChannelCount,  int mentionCount,  int taskCount,  bool capped)  $default,) {final _that = this;
switch (_that) {
case _InboxSummaryDto():
return $default(_that.unreadChannelCount,_that.mentionCount,_that.taskCount,_that.capped);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int unreadChannelCount,  int mentionCount,  int taskCount,  bool capped)?  $default,) {final _that = this;
switch (_that) {
case _InboxSummaryDto() when $default != null:
return $default(_that.unreadChannelCount,_that.mentionCount,_that.taskCount,_that.capped);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InboxSummaryDto implements InboxSummaryDto {
  const _InboxSummaryDto({this.unreadChannelCount = 0, this.mentionCount = 0, this.taskCount = 0, this.capped = false});
  factory _InboxSummaryDto.fromJson(Map<String, dynamic> json) => _$InboxSummaryDtoFromJson(json);

@override@JsonKey() final  int unreadChannelCount;
@override@JsonKey() final  int mentionCount;
/// Household rows waiting on the caller - the Waiting tab. Capped the same
/// way the others are, and reported here so the header badge needs one
/// request rather than two.
@override@JsonKey() final  int taskCount;
/// The real numbers are higher than reported. Counting further would be an
/// unbounded scan for a number that renders as `99+` either way.
@override@JsonKey() final  bool capped;

/// Create a copy of InboxSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InboxSummaryDtoCopyWith<_InboxSummaryDto> get copyWith => __$InboxSummaryDtoCopyWithImpl<_InboxSummaryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InboxSummaryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InboxSummaryDto&&(identical(other.unreadChannelCount, unreadChannelCount) || other.unreadChannelCount == unreadChannelCount)&&(identical(other.mentionCount, mentionCount) || other.mentionCount == mentionCount)&&(identical(other.taskCount, taskCount) || other.taskCount == taskCount)&&(identical(other.capped, capped) || other.capped == capped));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,unreadChannelCount,mentionCount,taskCount,capped);

@override
String toString() {
  return 'InboxSummaryDto(unreadChannelCount: $unreadChannelCount, mentionCount: $mentionCount, taskCount: $taskCount, capped: $capped)';
}


}

/// @nodoc
abstract mixin class _$InboxSummaryDtoCopyWith<$Res> implements $InboxSummaryDtoCopyWith<$Res> {
  factory _$InboxSummaryDtoCopyWith(_InboxSummaryDto value, $Res Function(_InboxSummaryDto) _then) = __$InboxSummaryDtoCopyWithImpl;
@override @useResult
$Res call({
 int unreadChannelCount, int mentionCount, int taskCount, bool capped
});




}
/// @nodoc
class __$InboxSummaryDtoCopyWithImpl<$Res>
    implements _$InboxSummaryDtoCopyWith<$Res> {
  __$InboxSummaryDtoCopyWithImpl(this._self, this._then);

  final _InboxSummaryDto _self;
  final $Res Function(_InboxSummaryDto) _then;

/// Create a copy of InboxSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? unreadChannelCount = null,Object? mentionCount = null,Object? taskCount = null,Object? capped = null,}) {
  return _then(_InboxSummaryDto(
unreadChannelCount: null == unreadChannelCount ? _self.unreadChannelCount : unreadChannelCount // ignore: cast_nullable_to_non_nullable
as int,mentionCount: null == mentionCount ? _self.mentionCount : mentionCount // ignore: cast_nullable_to_non_nullable
as int,taskCount: null == taskCount ? _self.taskCount : taskCount // ignore: cast_nullable_to_non_nullable
as int,capped: null == capped ? _self.capped : capped // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
