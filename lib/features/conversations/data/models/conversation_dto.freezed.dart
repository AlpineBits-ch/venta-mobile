// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConversationMemberDto {

 String get id; String get userId; String get cachedUserName; String? get lastReadMessageId; int get mentionCount;
/// Create a copy of ConversationMemberDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConversationMemberDtoCopyWith<ConversationMemberDto> get copyWith => _$ConversationMemberDtoCopyWithImpl<ConversationMemberDto>(this as ConversationMemberDto, _$identity);

  /// Serializes this ConversationMemberDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConversationMemberDto&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.cachedUserName, cachedUserName) || other.cachedUserName == cachedUserName)&&(identical(other.lastReadMessageId, lastReadMessageId) || other.lastReadMessageId == lastReadMessageId)&&(identical(other.mentionCount, mentionCount) || other.mentionCount == mentionCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,cachedUserName,lastReadMessageId,mentionCount);

@override
String toString() {
  return 'ConversationMemberDto(id: $id, userId: $userId, cachedUserName: $cachedUserName, lastReadMessageId: $lastReadMessageId, mentionCount: $mentionCount)';
}


}

/// @nodoc
abstract mixin class $ConversationMemberDtoCopyWith<$Res>  {
  factory $ConversationMemberDtoCopyWith(ConversationMemberDto value, $Res Function(ConversationMemberDto) _then) = _$ConversationMemberDtoCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String cachedUserName, String? lastReadMessageId, int mentionCount
});




}
/// @nodoc
class _$ConversationMemberDtoCopyWithImpl<$Res>
    implements $ConversationMemberDtoCopyWith<$Res> {
  _$ConversationMemberDtoCopyWithImpl(this._self, this._then);

  final ConversationMemberDto _self;
  final $Res Function(ConversationMemberDto) _then;

/// Create a copy of ConversationMemberDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? cachedUserName = null,Object? lastReadMessageId = freezed,Object? mentionCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,cachedUserName: null == cachedUserName ? _self.cachedUserName : cachedUserName // ignore: cast_nullable_to_non_nullable
as String,lastReadMessageId: freezed == lastReadMessageId ? _self.lastReadMessageId : lastReadMessageId // ignore: cast_nullable_to_non_nullable
as String?,mentionCount: null == mentionCount ? _self.mentionCount : mentionCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ConversationMemberDto].
extension ConversationMemberDtoPatterns on ConversationMemberDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConversationMemberDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConversationMemberDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConversationMemberDto value)  $default,){
final _that = this;
switch (_that) {
case _ConversationMemberDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConversationMemberDto value)?  $default,){
final _that = this;
switch (_that) {
case _ConversationMemberDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String cachedUserName,  String? lastReadMessageId,  int mentionCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConversationMemberDto() when $default != null:
return $default(_that.id,_that.userId,_that.cachedUserName,_that.lastReadMessageId,_that.mentionCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String cachedUserName,  String? lastReadMessageId,  int mentionCount)  $default,) {final _that = this;
switch (_that) {
case _ConversationMemberDto():
return $default(_that.id,_that.userId,_that.cachedUserName,_that.lastReadMessageId,_that.mentionCount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String cachedUserName,  String? lastReadMessageId,  int mentionCount)?  $default,) {final _that = this;
switch (_that) {
case _ConversationMemberDto() when $default != null:
return $default(_that.id,_that.userId,_that.cachedUserName,_that.lastReadMessageId,_that.mentionCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConversationMemberDto implements ConversationMemberDto {
  const _ConversationMemberDto({required this.id, required this.userId, required this.cachedUserName, this.lastReadMessageId, this.mentionCount = 0});
  factory _ConversationMemberDto.fromJson(Map<String, dynamic> json) => _$ConversationMemberDtoFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String cachedUserName;
@override final  String? lastReadMessageId;
@override@JsonKey() final  int mentionCount;

/// Create a copy of ConversationMemberDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConversationMemberDtoCopyWith<_ConversationMemberDto> get copyWith => __$ConversationMemberDtoCopyWithImpl<_ConversationMemberDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConversationMemberDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConversationMemberDto&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.cachedUserName, cachedUserName) || other.cachedUserName == cachedUserName)&&(identical(other.lastReadMessageId, lastReadMessageId) || other.lastReadMessageId == lastReadMessageId)&&(identical(other.mentionCount, mentionCount) || other.mentionCount == mentionCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,cachedUserName,lastReadMessageId,mentionCount);

@override
String toString() {
  return 'ConversationMemberDto(id: $id, userId: $userId, cachedUserName: $cachedUserName, lastReadMessageId: $lastReadMessageId, mentionCount: $mentionCount)';
}


}

/// @nodoc
abstract mixin class _$ConversationMemberDtoCopyWith<$Res> implements $ConversationMemberDtoCopyWith<$Res> {
  factory _$ConversationMemberDtoCopyWith(_ConversationMemberDto value, $Res Function(_ConversationMemberDto) _then) = __$ConversationMemberDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String cachedUserName, String? lastReadMessageId, int mentionCount
});




}
/// @nodoc
class __$ConversationMemberDtoCopyWithImpl<$Res>
    implements _$ConversationMemberDtoCopyWith<$Res> {
  __$ConversationMemberDtoCopyWithImpl(this._self, this._then);

  final _ConversationMemberDto _self;
  final $Res Function(_ConversationMemberDto) _then;

/// Create a copy of ConversationMemberDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? cachedUserName = null,Object? lastReadMessageId = freezed,Object? mentionCount = null,}) {
  return _then(_ConversationMemberDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,cachedUserName: null == cachedUserName ? _self.cachedUserName : cachedUserName // ignore: cast_nullable_to_non_nullable
as String,lastReadMessageId: freezed == lastReadMessageId ? _self.lastReadMessageId : lastReadMessageId // ignore: cast_nullable_to_non_nullable
as String?,mentionCount: null == mentionCount ? _self.mentionCount : mentionCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ConversationDto {

 String get id; String? get name; List<ConversationMemberDto> get members; ConversationEncryption get encryptionState;
/// Create a copy of ConversationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConversationDtoCopyWith<ConversationDto> get copyWith => _$ConversationDtoCopyWithImpl<ConversationDto>(this as ConversationDto, _$identity);

  /// Serializes this ConversationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConversationDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.members, members)&&(identical(other.encryptionState, encryptionState) || other.encryptionState == encryptionState));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(members),encryptionState);

@override
String toString() {
  return 'ConversationDto(id: $id, name: $name, members: $members, encryptionState: $encryptionState)';
}


}

/// @nodoc
abstract mixin class $ConversationDtoCopyWith<$Res>  {
  factory $ConversationDtoCopyWith(ConversationDto value, $Res Function(ConversationDto) _then) = _$ConversationDtoCopyWithImpl;
@useResult
$Res call({
 String id, String? name, List<ConversationMemberDto> members, ConversationEncryption encryptionState
});




}
/// @nodoc
class _$ConversationDtoCopyWithImpl<$Res>
    implements $ConversationDtoCopyWith<$Res> {
  _$ConversationDtoCopyWithImpl(this._self, this._then);

  final ConversationDto _self;
  final $Res Function(ConversationDto) _then;

/// Create a copy of ConversationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = freezed,Object? members = null,Object? encryptionState = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as List<ConversationMemberDto>,encryptionState: null == encryptionState ? _self.encryptionState : encryptionState // ignore: cast_nullable_to_non_nullable
as ConversationEncryption,
  ));
}

}


/// Adds pattern-matching-related methods to [ConversationDto].
extension ConversationDtoPatterns on ConversationDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConversationDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConversationDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConversationDto value)  $default,){
final _that = this;
switch (_that) {
case _ConversationDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConversationDto value)?  $default,){
final _that = this;
switch (_that) {
case _ConversationDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? name,  List<ConversationMemberDto> members,  ConversationEncryption encryptionState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConversationDto() when $default != null:
return $default(_that.id,_that.name,_that.members,_that.encryptionState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? name,  List<ConversationMemberDto> members,  ConversationEncryption encryptionState)  $default,) {final _that = this;
switch (_that) {
case _ConversationDto():
return $default(_that.id,_that.name,_that.members,_that.encryptionState);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? name,  List<ConversationMemberDto> members,  ConversationEncryption encryptionState)?  $default,) {final _that = this;
switch (_that) {
case _ConversationDto() when $default != null:
return $default(_that.id,_that.name,_that.members,_that.encryptionState);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConversationDto implements ConversationDto {
  const _ConversationDto({required this.id, this.name, required final  List<ConversationMemberDto> members, required this.encryptionState}): _members = members;
  factory _ConversationDto.fromJson(Map<String, dynamic> json) => _$ConversationDtoFromJson(json);

@override final  String id;
@override final  String? name;
 final  List<ConversationMemberDto> _members;
@override List<ConversationMemberDto> get members {
  if (_members is EqualUnmodifiableListView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_members);
}

@override final  ConversationEncryption encryptionState;

/// Create a copy of ConversationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConversationDtoCopyWith<_ConversationDto> get copyWith => __$ConversationDtoCopyWithImpl<_ConversationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConversationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConversationDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._members, _members)&&(identical(other.encryptionState, encryptionState) || other.encryptionState == encryptionState));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_members),encryptionState);

@override
String toString() {
  return 'ConversationDto(id: $id, name: $name, members: $members, encryptionState: $encryptionState)';
}


}

/// @nodoc
abstract mixin class _$ConversationDtoCopyWith<$Res> implements $ConversationDtoCopyWith<$Res> {
  factory _$ConversationDtoCopyWith(_ConversationDto value, $Res Function(_ConversationDto) _then) = __$ConversationDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String? name, List<ConversationMemberDto> members, ConversationEncryption encryptionState
});




}
/// @nodoc
class __$ConversationDtoCopyWithImpl<$Res>
    implements _$ConversationDtoCopyWith<$Res> {
  __$ConversationDtoCopyWithImpl(this._self, this._then);

  final _ConversationDto _self;
  final $Res Function(_ConversationDto) _then;

/// Create a copy of ConversationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? members = null,Object? encryptionState = null,}) {
  return _then(_ConversationDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,members: null == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as List<ConversationMemberDto>,encryptionState: null == encryptionState ? _self.encryptionState : encryptionState // ignore: cast_nullable_to_non_nullable
as ConversationEncryption,
  ));
}


}

// dart format on
