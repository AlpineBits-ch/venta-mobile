// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ban_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BanDto {

 String get id; String get guildId; String get bannedUserId; String? get bannedByUserId; String? get reason; DateTime? get createdAt;
/// Create a copy of BanDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BanDtoCopyWith<BanDto> get copyWith => _$BanDtoCopyWithImpl<BanDto>(this as BanDto, _$identity);

  /// Serializes this BanDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BanDto&&(identical(other.id, id) || other.id == id)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.bannedUserId, bannedUserId) || other.bannedUserId == bannedUserId)&&(identical(other.bannedByUserId, bannedByUserId) || other.bannedByUserId == bannedByUserId)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,guildId,bannedUserId,bannedByUserId,reason,createdAt);

@override
String toString() {
  return 'BanDto(id: $id, guildId: $guildId, bannedUserId: $bannedUserId, bannedByUserId: $bannedByUserId, reason: $reason, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $BanDtoCopyWith<$Res>  {
  factory $BanDtoCopyWith(BanDto value, $Res Function(BanDto) _then) = _$BanDtoCopyWithImpl;
@useResult
$Res call({
 String id, String guildId, String bannedUserId, String? bannedByUserId, String? reason, DateTime? createdAt
});




}
/// @nodoc
class _$BanDtoCopyWithImpl<$Res>
    implements $BanDtoCopyWith<$Res> {
  _$BanDtoCopyWithImpl(this._self, this._then);

  final BanDto _self;
  final $Res Function(BanDto) _then;

/// Create a copy of BanDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? guildId = null,Object? bannedUserId = null,Object? bannedByUserId = freezed,Object? reason = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,bannedUserId: null == bannedUserId ? _self.bannedUserId : bannedUserId // ignore: cast_nullable_to_non_nullable
as String,bannedByUserId: freezed == bannedByUserId ? _self.bannedByUserId : bannedByUserId // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [BanDto].
extension BanDtoPatterns on BanDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BanDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BanDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BanDto value)  $default,){
final _that = this;
switch (_that) {
case _BanDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BanDto value)?  $default,){
final _that = this;
switch (_that) {
case _BanDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String guildId,  String bannedUserId,  String? bannedByUserId,  String? reason,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BanDto() when $default != null:
return $default(_that.id,_that.guildId,_that.bannedUserId,_that.bannedByUserId,_that.reason,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String guildId,  String bannedUserId,  String? bannedByUserId,  String? reason,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _BanDto():
return $default(_that.id,_that.guildId,_that.bannedUserId,_that.bannedByUserId,_that.reason,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String guildId,  String bannedUserId,  String? bannedByUserId,  String? reason,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _BanDto() when $default != null:
return $default(_that.id,_that.guildId,_that.bannedUserId,_that.bannedByUserId,_that.reason,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BanDto implements BanDto {
  const _BanDto({required this.id, required this.guildId, required this.bannedUserId, this.bannedByUserId, this.reason, this.createdAt});
  factory _BanDto.fromJson(Map<String, dynamic> json) => _$BanDtoFromJson(json);

@override final  String id;
@override final  String guildId;
@override final  String bannedUserId;
@override final  String? bannedByUserId;
@override final  String? reason;
@override final  DateTime? createdAt;

/// Create a copy of BanDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BanDtoCopyWith<_BanDto> get copyWith => __$BanDtoCopyWithImpl<_BanDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BanDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BanDto&&(identical(other.id, id) || other.id == id)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.bannedUserId, bannedUserId) || other.bannedUserId == bannedUserId)&&(identical(other.bannedByUserId, bannedByUserId) || other.bannedByUserId == bannedByUserId)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,guildId,bannedUserId,bannedByUserId,reason,createdAt);

@override
String toString() {
  return 'BanDto(id: $id, guildId: $guildId, bannedUserId: $bannedUserId, bannedByUserId: $bannedByUserId, reason: $reason, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BanDtoCopyWith<$Res> implements $BanDtoCopyWith<$Res> {
  factory _$BanDtoCopyWith(_BanDto value, $Res Function(_BanDto) _then) = __$BanDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String guildId, String bannedUserId, String? bannedByUserId, String? reason, DateTime? createdAt
});




}
/// @nodoc
class __$BanDtoCopyWithImpl<$Res>
    implements _$BanDtoCopyWith<$Res> {
  __$BanDtoCopyWithImpl(this._self, this._then);

  final _BanDto _self;
  final $Res Function(_BanDto) _then;

/// Create a copy of BanDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? guildId = null,Object? bannedUserId = null,Object? bannedByUserId = freezed,Object? reason = freezed,Object? createdAt = freezed,}) {
  return _then(_BanDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,bannedUserId: null == bannedUserId ? _self.bannedUserId : bannedUserId // ignore: cast_nullable_to_non_nullable
as String,bannedByUserId: freezed == bannedByUserId ? _self.bannedByUserId : bannedByUserId // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
