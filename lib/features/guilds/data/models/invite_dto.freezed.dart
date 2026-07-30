// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invite_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InviteDto {

 String get id; InviteType get type; InviteState get state; String get guildId; GuildDto? get guild; String get code; String? get expiresAt; int? get maxUses; int get useCount;/// The guild's welcome splash, present only when it has one and it's
/// enabled. Carried inline here because the dedicated welcome-screen
/// endpoint is members-only and whoever is looking at an invite isn't one
/// yet.
 WelcomeScreenDto? get welcomeScreen;
/// Create a copy of InviteDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InviteDtoCopyWith<InviteDto> get copyWith => _$InviteDtoCopyWithImpl<InviteDto>(this as InviteDto, _$identity);

  /// Serializes this InviteDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InviteDto&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.state, state) || other.state == state)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.guild, guild) || other.guild == guild)&&(identical(other.code, code) || other.code == code)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.maxUses, maxUses) || other.maxUses == maxUses)&&(identical(other.useCount, useCount) || other.useCount == useCount)&&(identical(other.welcomeScreen, welcomeScreen) || other.welcomeScreen == welcomeScreen));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,state,guildId,guild,code,expiresAt,maxUses,useCount,welcomeScreen);

@override
String toString() {
  return 'InviteDto(id: $id, type: $type, state: $state, guildId: $guildId, guild: $guild, code: $code, expiresAt: $expiresAt, maxUses: $maxUses, useCount: $useCount, welcomeScreen: $welcomeScreen)';
}


}

/// @nodoc
abstract mixin class $InviteDtoCopyWith<$Res>  {
  factory $InviteDtoCopyWith(InviteDto value, $Res Function(InviteDto) _then) = _$InviteDtoCopyWithImpl;
@useResult
$Res call({
 String id, InviteType type, InviteState state, String guildId, GuildDto? guild, String code, String? expiresAt, int? maxUses, int useCount, WelcomeScreenDto? welcomeScreen
});


$GuildDtoCopyWith<$Res>? get guild;$WelcomeScreenDtoCopyWith<$Res>? get welcomeScreen;

}
/// @nodoc
class _$InviteDtoCopyWithImpl<$Res>
    implements $InviteDtoCopyWith<$Res> {
  _$InviteDtoCopyWithImpl(this._self, this._then);

  final InviteDto _self;
  final $Res Function(InviteDto) _then;

/// Create a copy of InviteDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? state = null,Object? guildId = null,Object? guild = freezed,Object? code = null,Object? expiresAt = freezed,Object? maxUses = freezed,Object? useCount = null,Object? welcomeScreen = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as InviteType,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as InviteState,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,guild: freezed == guild ? _self.guild : guild // ignore: cast_nullable_to_non_nullable
as GuildDto?,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String?,maxUses: freezed == maxUses ? _self.maxUses : maxUses // ignore: cast_nullable_to_non_nullable
as int?,useCount: null == useCount ? _self.useCount : useCount // ignore: cast_nullable_to_non_nullable
as int,welcomeScreen: freezed == welcomeScreen ? _self.welcomeScreen : welcomeScreen // ignore: cast_nullable_to_non_nullable
as WelcomeScreenDto?,
  ));
}
/// Create a copy of InviteDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GuildDtoCopyWith<$Res>? get guild {
    if (_self.guild == null) {
    return null;
  }

  return $GuildDtoCopyWith<$Res>(_self.guild!, (value) {
    return _then(_self.copyWith(guild: value));
  });
}/// Create a copy of InviteDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WelcomeScreenDtoCopyWith<$Res>? get welcomeScreen {
    if (_self.welcomeScreen == null) {
    return null;
  }

  return $WelcomeScreenDtoCopyWith<$Res>(_self.welcomeScreen!, (value) {
    return _then(_self.copyWith(welcomeScreen: value));
  });
}
}


/// Adds pattern-matching-related methods to [InviteDto].
extension InviteDtoPatterns on InviteDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InviteDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InviteDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InviteDto value)  $default,){
final _that = this;
switch (_that) {
case _InviteDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InviteDto value)?  $default,){
final _that = this;
switch (_that) {
case _InviteDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  InviteType type,  InviteState state,  String guildId,  GuildDto? guild,  String code,  String? expiresAt,  int? maxUses,  int useCount,  WelcomeScreenDto? welcomeScreen)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InviteDto() when $default != null:
return $default(_that.id,_that.type,_that.state,_that.guildId,_that.guild,_that.code,_that.expiresAt,_that.maxUses,_that.useCount,_that.welcomeScreen);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  InviteType type,  InviteState state,  String guildId,  GuildDto? guild,  String code,  String? expiresAt,  int? maxUses,  int useCount,  WelcomeScreenDto? welcomeScreen)  $default,) {final _that = this;
switch (_that) {
case _InviteDto():
return $default(_that.id,_that.type,_that.state,_that.guildId,_that.guild,_that.code,_that.expiresAt,_that.maxUses,_that.useCount,_that.welcomeScreen);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  InviteType type,  InviteState state,  String guildId,  GuildDto? guild,  String code,  String? expiresAt,  int? maxUses,  int useCount,  WelcomeScreenDto? welcomeScreen)?  $default,) {final _that = this;
switch (_that) {
case _InviteDto() when $default != null:
return $default(_that.id,_that.type,_that.state,_that.guildId,_that.guild,_that.code,_that.expiresAt,_that.maxUses,_that.useCount,_that.welcomeScreen);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InviteDto implements InviteDto {
  const _InviteDto({required this.id, required this.type, required this.state, required this.guildId, this.guild, required this.code, this.expiresAt, this.maxUses, this.useCount = 0, this.welcomeScreen});
  factory _InviteDto.fromJson(Map<String, dynamic> json) => _$InviteDtoFromJson(json);

@override final  String id;
@override final  InviteType type;
@override final  InviteState state;
@override final  String guildId;
@override final  GuildDto? guild;
@override final  String code;
@override final  String? expiresAt;
@override final  int? maxUses;
@override@JsonKey() final  int useCount;
/// The guild's welcome splash, present only when it has one and it's
/// enabled. Carried inline here because the dedicated welcome-screen
/// endpoint is members-only and whoever is looking at an invite isn't one
/// yet.
@override final  WelcomeScreenDto? welcomeScreen;

/// Create a copy of InviteDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InviteDtoCopyWith<_InviteDto> get copyWith => __$InviteDtoCopyWithImpl<_InviteDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InviteDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InviteDto&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.state, state) || other.state == state)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.guild, guild) || other.guild == guild)&&(identical(other.code, code) || other.code == code)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.maxUses, maxUses) || other.maxUses == maxUses)&&(identical(other.useCount, useCount) || other.useCount == useCount)&&(identical(other.welcomeScreen, welcomeScreen) || other.welcomeScreen == welcomeScreen));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,state,guildId,guild,code,expiresAt,maxUses,useCount,welcomeScreen);

@override
String toString() {
  return 'InviteDto(id: $id, type: $type, state: $state, guildId: $guildId, guild: $guild, code: $code, expiresAt: $expiresAt, maxUses: $maxUses, useCount: $useCount, welcomeScreen: $welcomeScreen)';
}


}

/// @nodoc
abstract mixin class _$InviteDtoCopyWith<$Res> implements $InviteDtoCopyWith<$Res> {
  factory _$InviteDtoCopyWith(_InviteDto value, $Res Function(_InviteDto) _then) = __$InviteDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, InviteType type, InviteState state, String guildId, GuildDto? guild, String code, String? expiresAt, int? maxUses, int useCount, WelcomeScreenDto? welcomeScreen
});


@override $GuildDtoCopyWith<$Res>? get guild;@override $WelcomeScreenDtoCopyWith<$Res>? get welcomeScreen;

}
/// @nodoc
class __$InviteDtoCopyWithImpl<$Res>
    implements _$InviteDtoCopyWith<$Res> {
  __$InviteDtoCopyWithImpl(this._self, this._then);

  final _InviteDto _self;
  final $Res Function(_InviteDto) _then;

/// Create a copy of InviteDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? state = null,Object? guildId = null,Object? guild = freezed,Object? code = null,Object? expiresAt = freezed,Object? maxUses = freezed,Object? useCount = null,Object? welcomeScreen = freezed,}) {
  return _then(_InviteDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as InviteType,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as InviteState,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,guild: freezed == guild ? _self.guild : guild // ignore: cast_nullable_to_non_nullable
as GuildDto?,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String?,maxUses: freezed == maxUses ? _self.maxUses : maxUses // ignore: cast_nullable_to_non_nullable
as int?,useCount: null == useCount ? _self.useCount : useCount // ignore: cast_nullable_to_non_nullable
as int,welcomeScreen: freezed == welcomeScreen ? _self.welcomeScreen : welcomeScreen // ignore: cast_nullable_to_non_nullable
as WelcomeScreenDto?,
  ));
}

/// Create a copy of InviteDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GuildDtoCopyWith<$Res>? get guild {
    if (_self.guild == null) {
    return null;
  }

  return $GuildDtoCopyWith<$Res>(_self.guild!, (value) {
    return _then(_self.copyWith(guild: value));
  });
}/// Create a copy of InviteDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WelcomeScreenDtoCopyWith<$Res>? get welcomeScreen {
    if (_self.welcomeScreen == null) {
    return null;
  }

  return $WelcomeScreenDtoCopyWith<$Res>(_self.welcomeScreen!, (value) {
    return _then(_self.copyWith(welcomeScreen: value));
  });
}
}

// dart format on
