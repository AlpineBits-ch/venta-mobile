// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'decision_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DecisionOptionDto {

 String get id; String get title; int get position; int get supportCount;/// Somebody vetoed this option. It cannot win no matter what
/// [supportCount] says.
 bool get isBlocked;
/// Create a copy of DecisionOptionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DecisionOptionDtoCopyWith<DecisionOptionDto> get copyWith => _$DecisionOptionDtoCopyWithImpl<DecisionOptionDto>(this as DecisionOptionDto, _$identity);

  /// Serializes this DecisionOptionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DecisionOptionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.position, position) || other.position == position)&&(identical(other.supportCount, supportCount) || other.supportCount == supportCount)&&(identical(other.isBlocked, isBlocked) || other.isBlocked == isBlocked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,position,supportCount,isBlocked);

@override
String toString() {
  return 'DecisionOptionDto(id: $id, title: $title, position: $position, supportCount: $supportCount, isBlocked: $isBlocked)';
}


}

/// @nodoc
abstract mixin class $DecisionOptionDtoCopyWith<$Res>  {
  factory $DecisionOptionDtoCopyWith(DecisionOptionDto value, $Res Function(DecisionOptionDto) _then) = _$DecisionOptionDtoCopyWithImpl;
@useResult
$Res call({
 String id, String title, int position, int supportCount, bool isBlocked
});




}
/// @nodoc
class _$DecisionOptionDtoCopyWithImpl<$Res>
    implements $DecisionOptionDtoCopyWith<$Res> {
  _$DecisionOptionDtoCopyWithImpl(this._self, this._then);

  final DecisionOptionDto _self;
  final $Res Function(DecisionOptionDto) _then;

/// Create a copy of DecisionOptionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? position = null,Object? supportCount = null,Object? isBlocked = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,supportCount: null == supportCount ? _self.supportCount : supportCount // ignore: cast_nullable_to_non_nullable
as int,isBlocked: null == isBlocked ? _self.isBlocked : isBlocked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DecisionOptionDto].
extension DecisionOptionDtoPatterns on DecisionOptionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DecisionOptionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DecisionOptionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DecisionOptionDto value)  $default,){
final _that = this;
switch (_that) {
case _DecisionOptionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DecisionOptionDto value)?  $default,){
final _that = this;
switch (_that) {
case _DecisionOptionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  int position,  int supportCount,  bool isBlocked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DecisionOptionDto() when $default != null:
return $default(_that.id,_that.title,_that.position,_that.supportCount,_that.isBlocked);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  int position,  int supportCount,  bool isBlocked)  $default,) {final _that = this;
switch (_that) {
case _DecisionOptionDto():
return $default(_that.id,_that.title,_that.position,_that.supportCount,_that.isBlocked);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  int position,  int supportCount,  bool isBlocked)?  $default,) {final _that = this;
switch (_that) {
case _DecisionOptionDto() when $default != null:
return $default(_that.id,_that.title,_that.position,_that.supportCount,_that.isBlocked);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DecisionOptionDto implements DecisionOptionDto {
  const _DecisionOptionDto({required this.id, this.title = '', this.position = 0, this.supportCount = 0, this.isBlocked = false});
  factory _DecisionOptionDto.fromJson(Map<String, dynamic> json) => _$DecisionOptionDtoFromJson(json);

@override final  String id;
@override@JsonKey() final  String title;
@override@JsonKey() final  int position;
@override@JsonKey() final  int supportCount;
/// Somebody vetoed this option. It cannot win no matter what
/// [supportCount] says.
@override@JsonKey() final  bool isBlocked;

/// Create a copy of DecisionOptionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DecisionOptionDtoCopyWith<_DecisionOptionDto> get copyWith => __$DecisionOptionDtoCopyWithImpl<_DecisionOptionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DecisionOptionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DecisionOptionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.position, position) || other.position == position)&&(identical(other.supportCount, supportCount) || other.supportCount == supportCount)&&(identical(other.isBlocked, isBlocked) || other.isBlocked == isBlocked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,position,supportCount,isBlocked);

@override
String toString() {
  return 'DecisionOptionDto(id: $id, title: $title, position: $position, supportCount: $supportCount, isBlocked: $isBlocked)';
}


}

/// @nodoc
abstract mixin class _$DecisionOptionDtoCopyWith<$Res> implements $DecisionOptionDtoCopyWith<$Res> {
  factory _$DecisionOptionDtoCopyWith(_DecisionOptionDto value, $Res Function(_DecisionOptionDto) _then) = __$DecisionOptionDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, int position, int supportCount, bool isBlocked
});




}
/// @nodoc
class __$DecisionOptionDtoCopyWithImpl<$Res>
    implements _$DecisionOptionDtoCopyWith<$Res> {
  __$DecisionOptionDtoCopyWithImpl(this._self, this._then);

  final _DecisionOptionDto _self;
  final $Res Function(_DecisionOptionDto) _then;

/// Create a copy of DecisionOptionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? position = null,Object? supportCount = null,Object? isBlocked = null,}) {
  return _then(_DecisionOptionDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,supportCount: null == supportCount ? _self.supportCount : supportCount // ignore: cast_nullable_to_non_nullable
as int,isBlocked: null == isBlocked ? _self.isBlocked : isBlocked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$DecisionBlockDto {

 String get userId; String? get optionId; String get reason;
/// Create a copy of DecisionBlockDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DecisionBlockDtoCopyWith<DecisionBlockDto> get copyWith => _$DecisionBlockDtoCopyWithImpl<DecisionBlockDto>(this as DecisionBlockDto, _$identity);

  /// Serializes this DecisionBlockDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DecisionBlockDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.optionId, optionId) || other.optionId == optionId)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,optionId,reason);

@override
String toString() {
  return 'DecisionBlockDto(userId: $userId, optionId: $optionId, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $DecisionBlockDtoCopyWith<$Res>  {
  factory $DecisionBlockDtoCopyWith(DecisionBlockDto value, $Res Function(DecisionBlockDto) _then) = _$DecisionBlockDtoCopyWithImpl;
@useResult
$Res call({
 String userId, String? optionId, String reason
});




}
/// @nodoc
class _$DecisionBlockDtoCopyWithImpl<$Res>
    implements $DecisionBlockDtoCopyWith<$Res> {
  _$DecisionBlockDtoCopyWithImpl(this._self, this._then);

  final DecisionBlockDto _self;
  final $Res Function(DecisionBlockDto) _then;

/// Create a copy of DecisionBlockDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? optionId = freezed,Object? reason = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,optionId: freezed == optionId ? _self.optionId : optionId // ignore: cast_nullable_to_non_nullable
as String?,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DecisionBlockDto].
extension DecisionBlockDtoPatterns on DecisionBlockDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DecisionBlockDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DecisionBlockDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DecisionBlockDto value)  $default,){
final _that = this;
switch (_that) {
case _DecisionBlockDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DecisionBlockDto value)?  $default,){
final _that = this;
switch (_that) {
case _DecisionBlockDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String? optionId,  String reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DecisionBlockDto() when $default != null:
return $default(_that.userId,_that.optionId,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String? optionId,  String reason)  $default,) {final _that = this;
switch (_that) {
case _DecisionBlockDto():
return $default(_that.userId,_that.optionId,_that.reason);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String? optionId,  String reason)?  $default,) {final _that = this;
switch (_that) {
case _DecisionBlockDto() when $default != null:
return $default(_that.userId,_that.optionId,_that.reason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DecisionBlockDto implements DecisionBlockDto {
  const _DecisionBlockDto({this.userId = '', this.optionId, this.reason = ''});
  factory _DecisionBlockDto.fromJson(Map<String, dynamic> json) => _$DecisionBlockDtoFromJson(json);

@override@JsonKey() final  String userId;
@override final  String? optionId;
@override@JsonKey() final  String reason;

/// Create a copy of DecisionBlockDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DecisionBlockDtoCopyWith<_DecisionBlockDto> get copyWith => __$DecisionBlockDtoCopyWithImpl<_DecisionBlockDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DecisionBlockDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DecisionBlockDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.optionId, optionId) || other.optionId == optionId)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,optionId,reason);

@override
String toString() {
  return 'DecisionBlockDto(userId: $userId, optionId: $optionId, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$DecisionBlockDtoCopyWith<$Res> implements $DecisionBlockDtoCopyWith<$Res> {
  factory _$DecisionBlockDtoCopyWith(_DecisionBlockDto value, $Res Function(_DecisionBlockDto) _then) = __$DecisionBlockDtoCopyWithImpl;
@override @useResult
$Res call({
 String userId, String? optionId, String reason
});




}
/// @nodoc
class __$DecisionBlockDtoCopyWithImpl<$Res>
    implements _$DecisionBlockDtoCopyWith<$Res> {
  __$DecisionBlockDtoCopyWithImpl(this._self, this._then);

  final _DecisionBlockDto _self;
  final $Res Function(_DecisionBlockDto) _then;

/// Create a copy of DecisionBlockDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? optionId = freezed,Object? reason = null,}) {
  return _then(_DecisionBlockDto(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,optionId: freezed == optionId ? _self.optionId : optionId // ignore: cast_nullable_to_non_nullable
as String?,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$DecisionDto {

 String get id; String get channelId; String get title; String? get description; String get createdByUserId; DateTime? get closesAt;/// Non-abstain votes needed before anything can carry.
 int? get quorum;@JsonKey(unknownEnumValue: DecisionStatus.open) DecisionStatus get status; String? get outcomeOptionId; List<DecisionOptionDto> get options; List<DecisionBlockDto> get blocks; String? get myVoteOptionId;@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) VoteKind? get myVoteKind;
/// Create a copy of DecisionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DecisionDtoCopyWith<DecisionDto> get copyWith => _$DecisionDtoCopyWithImpl<DecisionDto>(this as DecisionDto, _$identity);

  /// Serializes this DecisionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DecisionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId)&&(identical(other.closesAt, closesAt) || other.closesAt == closesAt)&&(identical(other.quorum, quorum) || other.quorum == quorum)&&(identical(other.status, status) || other.status == status)&&(identical(other.outcomeOptionId, outcomeOptionId) || other.outcomeOptionId == outcomeOptionId)&&const DeepCollectionEquality().equals(other.options, options)&&const DeepCollectionEquality().equals(other.blocks, blocks)&&(identical(other.myVoteOptionId, myVoteOptionId) || other.myVoteOptionId == myVoteOptionId)&&(identical(other.myVoteKind, myVoteKind) || other.myVoteKind == myVoteKind));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,title,description,createdByUserId,closesAt,quorum,status,outcomeOptionId,const DeepCollectionEquality().hash(options),const DeepCollectionEquality().hash(blocks),myVoteOptionId,myVoteKind);

@override
String toString() {
  return 'DecisionDto(id: $id, channelId: $channelId, title: $title, description: $description, createdByUserId: $createdByUserId, closesAt: $closesAt, quorum: $quorum, status: $status, outcomeOptionId: $outcomeOptionId, options: $options, blocks: $blocks, myVoteOptionId: $myVoteOptionId, myVoteKind: $myVoteKind)';
}


}

/// @nodoc
abstract mixin class $DecisionDtoCopyWith<$Res>  {
  factory $DecisionDtoCopyWith(DecisionDto value, $Res Function(DecisionDto) _then) = _$DecisionDtoCopyWithImpl;
@useResult
$Res call({
 String id, String channelId, String title, String? description, String createdByUserId, DateTime? closesAt, int? quorum,@JsonKey(unknownEnumValue: DecisionStatus.open) DecisionStatus status, String? outcomeOptionId, List<DecisionOptionDto> options, List<DecisionBlockDto> blocks, String? myVoteOptionId,@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) VoteKind? myVoteKind
});




}
/// @nodoc
class _$DecisionDtoCopyWithImpl<$Res>
    implements $DecisionDtoCopyWith<$Res> {
  _$DecisionDtoCopyWithImpl(this._self, this._then);

  final DecisionDto _self;
  final $Res Function(DecisionDto) _then;

/// Create a copy of DecisionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? channelId = null,Object? title = null,Object? description = freezed,Object? createdByUserId = null,Object? closesAt = freezed,Object? quorum = freezed,Object? status = null,Object? outcomeOptionId = freezed,Object? options = null,Object? blocks = null,Object? myVoteOptionId = freezed,Object? myVoteKind = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,createdByUserId: null == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String,closesAt: freezed == closesAt ? _self.closesAt : closesAt // ignore: cast_nullable_to_non_nullable
as DateTime?,quorum: freezed == quorum ? _self.quorum : quorum // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DecisionStatus,outcomeOptionId: freezed == outcomeOptionId ? _self.outcomeOptionId : outcomeOptionId // ignore: cast_nullable_to_non_nullable
as String?,options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as List<DecisionOptionDto>,blocks: null == blocks ? _self.blocks : blocks // ignore: cast_nullable_to_non_nullable
as List<DecisionBlockDto>,myVoteOptionId: freezed == myVoteOptionId ? _self.myVoteOptionId : myVoteOptionId // ignore: cast_nullable_to_non_nullable
as String?,myVoteKind: freezed == myVoteKind ? _self.myVoteKind : myVoteKind // ignore: cast_nullable_to_non_nullable
as VoteKind?,
  ));
}

}


/// Adds pattern-matching-related methods to [DecisionDto].
extension DecisionDtoPatterns on DecisionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DecisionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DecisionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DecisionDto value)  $default,){
final _that = this;
switch (_that) {
case _DecisionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DecisionDto value)?  $default,){
final _that = this;
switch (_that) {
case _DecisionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String channelId,  String title,  String? description,  String createdByUserId,  DateTime? closesAt,  int? quorum, @JsonKey(unknownEnumValue: DecisionStatus.open)  DecisionStatus status,  String? outcomeOptionId,  List<DecisionOptionDto> options,  List<DecisionBlockDto> blocks,  String? myVoteOptionId, @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)  VoteKind? myVoteKind)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DecisionDto() when $default != null:
return $default(_that.id,_that.channelId,_that.title,_that.description,_that.createdByUserId,_that.closesAt,_that.quorum,_that.status,_that.outcomeOptionId,_that.options,_that.blocks,_that.myVoteOptionId,_that.myVoteKind);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String channelId,  String title,  String? description,  String createdByUserId,  DateTime? closesAt,  int? quorum, @JsonKey(unknownEnumValue: DecisionStatus.open)  DecisionStatus status,  String? outcomeOptionId,  List<DecisionOptionDto> options,  List<DecisionBlockDto> blocks,  String? myVoteOptionId, @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)  VoteKind? myVoteKind)  $default,) {final _that = this;
switch (_that) {
case _DecisionDto():
return $default(_that.id,_that.channelId,_that.title,_that.description,_that.createdByUserId,_that.closesAt,_that.quorum,_that.status,_that.outcomeOptionId,_that.options,_that.blocks,_that.myVoteOptionId,_that.myVoteKind);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String channelId,  String title,  String? description,  String createdByUserId,  DateTime? closesAt,  int? quorum, @JsonKey(unknownEnumValue: DecisionStatus.open)  DecisionStatus status,  String? outcomeOptionId,  List<DecisionOptionDto> options,  List<DecisionBlockDto> blocks,  String? myVoteOptionId, @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)  VoteKind? myVoteKind)?  $default,) {final _that = this;
switch (_that) {
case _DecisionDto() when $default != null:
return $default(_that.id,_that.channelId,_that.title,_that.description,_that.createdByUserId,_that.closesAt,_that.quorum,_that.status,_that.outcomeOptionId,_that.options,_that.blocks,_that.myVoteOptionId,_that.myVoteKind);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _DecisionDto implements DecisionDto {
  const _DecisionDto({required this.id, required this.channelId, this.title = '', this.description, this.createdByUserId = '', this.closesAt, this.quorum, @JsonKey(unknownEnumValue: DecisionStatus.open) this.status = DecisionStatus.open, this.outcomeOptionId, final  List<DecisionOptionDto> options = const <DecisionOptionDto>[], final  List<DecisionBlockDto> blocks = const <DecisionBlockDto>[], this.myVoteOptionId, @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) this.myVoteKind}): _options = options,_blocks = blocks;
  factory _DecisionDto.fromJson(Map<String, dynamic> json) => _$DecisionDtoFromJson(json);

@override final  String id;
@override final  String channelId;
@override@JsonKey() final  String title;
@override final  String? description;
@override@JsonKey() final  String createdByUserId;
@override final  DateTime? closesAt;
/// Non-abstain votes needed before anything can carry.
@override final  int? quorum;
@override@JsonKey(unknownEnumValue: DecisionStatus.open) final  DecisionStatus status;
@override final  String? outcomeOptionId;
 final  List<DecisionOptionDto> _options;
@override@JsonKey() List<DecisionOptionDto> get options {
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_options);
}

 final  List<DecisionBlockDto> _blocks;
@override@JsonKey() List<DecisionBlockDto> get blocks {
  if (_blocks is EqualUnmodifiableListView) return _blocks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blocks);
}

@override final  String? myVoteOptionId;
@override@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) final  VoteKind? myVoteKind;

/// Create a copy of DecisionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DecisionDtoCopyWith<_DecisionDto> get copyWith => __$DecisionDtoCopyWithImpl<_DecisionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DecisionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DecisionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId)&&(identical(other.closesAt, closesAt) || other.closesAt == closesAt)&&(identical(other.quorum, quorum) || other.quorum == quorum)&&(identical(other.status, status) || other.status == status)&&(identical(other.outcomeOptionId, outcomeOptionId) || other.outcomeOptionId == outcomeOptionId)&&const DeepCollectionEquality().equals(other._options, _options)&&const DeepCollectionEquality().equals(other._blocks, _blocks)&&(identical(other.myVoteOptionId, myVoteOptionId) || other.myVoteOptionId == myVoteOptionId)&&(identical(other.myVoteKind, myVoteKind) || other.myVoteKind == myVoteKind));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channelId,title,description,createdByUserId,closesAt,quorum,status,outcomeOptionId,const DeepCollectionEquality().hash(_options),const DeepCollectionEquality().hash(_blocks),myVoteOptionId,myVoteKind);

@override
String toString() {
  return 'DecisionDto(id: $id, channelId: $channelId, title: $title, description: $description, createdByUserId: $createdByUserId, closesAt: $closesAt, quorum: $quorum, status: $status, outcomeOptionId: $outcomeOptionId, options: $options, blocks: $blocks, myVoteOptionId: $myVoteOptionId, myVoteKind: $myVoteKind)';
}


}

/// @nodoc
abstract mixin class _$DecisionDtoCopyWith<$Res> implements $DecisionDtoCopyWith<$Res> {
  factory _$DecisionDtoCopyWith(_DecisionDto value, $Res Function(_DecisionDto) _then) = __$DecisionDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String channelId, String title, String? description, String createdByUserId, DateTime? closesAt, int? quorum,@JsonKey(unknownEnumValue: DecisionStatus.open) DecisionStatus status, String? outcomeOptionId, List<DecisionOptionDto> options, List<DecisionBlockDto> blocks, String? myVoteOptionId,@JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue) VoteKind? myVoteKind
});




}
/// @nodoc
class __$DecisionDtoCopyWithImpl<$Res>
    implements _$DecisionDtoCopyWith<$Res> {
  __$DecisionDtoCopyWithImpl(this._self, this._then);

  final _DecisionDto _self;
  final $Res Function(_DecisionDto) _then;

/// Create a copy of DecisionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? channelId = null,Object? title = null,Object? description = freezed,Object? createdByUserId = null,Object? closesAt = freezed,Object? quorum = freezed,Object? status = null,Object? outcomeOptionId = freezed,Object? options = null,Object? blocks = null,Object? myVoteOptionId = freezed,Object? myVoteKind = freezed,}) {
  return _then(_DecisionDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,createdByUserId: null == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String,closesAt: freezed == closesAt ? _self.closesAt : closesAt // ignore: cast_nullable_to_non_nullable
as DateTime?,quorum: freezed == quorum ? _self.quorum : quorum // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DecisionStatus,outcomeOptionId: freezed == outcomeOptionId ? _self.outcomeOptionId : outcomeOptionId // ignore: cast_nullable_to_non_nullable
as String?,options: null == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<DecisionOptionDto>,blocks: null == blocks ? _self._blocks : blocks // ignore: cast_nullable_to_non_nullable
as List<DecisionBlockDto>,myVoteOptionId: freezed == myVoteOptionId ? _self.myVoteOptionId : myVoteOptionId // ignore: cast_nullable_to_non_nullable
as String?,myVoteKind: freezed == myVoteKind ? _self.myVoteKind : myVoteKind // ignore: cast_nullable_to_non_nullable
as VoteKind?,
  ));
}


}

// dart format on
