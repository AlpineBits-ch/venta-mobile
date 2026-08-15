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

 String get id;@JsonKey(unknownEnumValue: InviteType.unknown) InviteType get type;@JsonKey(unknownEnumValue: InviteState.unknown) InviteState get state; String get guildId; GuildDto? get guild; String get code; DateTime? get expiresAt; int? get maxUses; int get useCount;/// The channel a joiner lands on. Advisory unless [targetType] says
/// otherwise - and also what decides whether a channel moderator may
/// revoke this invite, so it is read by the settings screen's gating.
 String? get channelId;/// Who created it, as a **user id**. Guild does not own usernames or
/// avatars, so this resolves through the same profile cache message
/// authors do. Null for every invite minted before attribution existed and
/// for anything a system path created.
 String? get inviterId;/// The membership this invite grants ends when the member goes offline,
/// unless they are given a role.
 bool get temporary;@JsonKey(unknownEnumValue: InviteTargetType.unknown) InviteTargetType get targetType; String? get targetUserId; DateTime? get revokedAt;/// The guild's welcome splash, present only when it has one and it's
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InviteDto&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.state, state) || other.state == state)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.guild, guild) || other.guild == guild)&&(identical(other.code, code) || other.code == code)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.maxUses, maxUses) || other.maxUses == maxUses)&&(identical(other.useCount, useCount) || other.useCount == useCount)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.inviterId, inviterId) || other.inviterId == inviterId)&&(identical(other.temporary, temporary) || other.temporary == temporary)&&(identical(other.targetType, targetType) || other.targetType == targetType)&&(identical(other.targetUserId, targetUserId) || other.targetUserId == targetUserId)&&(identical(other.revokedAt, revokedAt) || other.revokedAt == revokedAt)&&(identical(other.welcomeScreen, welcomeScreen) || other.welcomeScreen == welcomeScreen));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,state,guildId,guild,code,expiresAt,maxUses,useCount,channelId,inviterId,temporary,targetType,targetUserId,revokedAt,welcomeScreen);

@override
String toString() {
  return 'InviteDto(id: $id, type: $type, state: $state, guildId: $guildId, guild: $guild, code: $code, expiresAt: $expiresAt, maxUses: $maxUses, useCount: $useCount, channelId: $channelId, inviterId: $inviterId, temporary: $temporary, targetType: $targetType, targetUserId: $targetUserId, revokedAt: $revokedAt, welcomeScreen: $welcomeScreen)';
}


}

/// @nodoc
abstract mixin class $InviteDtoCopyWith<$Res>  {
  factory $InviteDtoCopyWith(InviteDto value, $Res Function(InviteDto) _then) = _$InviteDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(unknownEnumValue: InviteType.unknown) InviteType type,@JsonKey(unknownEnumValue: InviteState.unknown) InviteState state, String guildId, GuildDto? guild, String code, DateTime? expiresAt, int? maxUses, int useCount, String? channelId, String? inviterId, bool temporary,@JsonKey(unknownEnumValue: InviteTargetType.unknown) InviteTargetType targetType, String? targetUserId, DateTime? revokedAt, WelcomeScreenDto? welcomeScreen
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? state = null,Object? guildId = null,Object? guild = freezed,Object? code = null,Object? expiresAt = freezed,Object? maxUses = freezed,Object? useCount = null,Object? channelId = freezed,Object? inviterId = freezed,Object? temporary = null,Object? targetType = null,Object? targetUserId = freezed,Object? revokedAt = freezed,Object? welcomeScreen = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as InviteType,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as InviteState,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,guild: freezed == guild ? _self.guild : guild // ignore: cast_nullable_to_non_nullable
as GuildDto?,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,maxUses: freezed == maxUses ? _self.maxUses : maxUses // ignore: cast_nullable_to_non_nullable
as int?,useCount: null == useCount ? _self.useCount : useCount // ignore: cast_nullable_to_non_nullable
as int,channelId: freezed == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String?,inviterId: freezed == inviterId ? _self.inviterId : inviterId // ignore: cast_nullable_to_non_nullable
as String?,temporary: null == temporary ? _self.temporary : temporary // ignore: cast_nullable_to_non_nullable
as bool,targetType: null == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as InviteTargetType,targetUserId: freezed == targetUserId ? _self.targetUserId : targetUserId // ignore: cast_nullable_to_non_nullable
as String?,revokedAt: freezed == revokedAt ? _self.revokedAt : revokedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,welcomeScreen: freezed == welcomeScreen ? _self.welcomeScreen : welcomeScreen // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(unknownEnumValue: InviteType.unknown)  InviteType type, @JsonKey(unknownEnumValue: InviteState.unknown)  InviteState state,  String guildId,  GuildDto? guild,  String code,  DateTime? expiresAt,  int? maxUses,  int useCount,  String? channelId,  String? inviterId,  bool temporary, @JsonKey(unknownEnumValue: InviteTargetType.unknown)  InviteTargetType targetType,  String? targetUserId,  DateTime? revokedAt,  WelcomeScreenDto? welcomeScreen)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InviteDto() when $default != null:
return $default(_that.id,_that.type,_that.state,_that.guildId,_that.guild,_that.code,_that.expiresAt,_that.maxUses,_that.useCount,_that.channelId,_that.inviterId,_that.temporary,_that.targetType,_that.targetUserId,_that.revokedAt,_that.welcomeScreen);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(unknownEnumValue: InviteType.unknown)  InviteType type, @JsonKey(unknownEnumValue: InviteState.unknown)  InviteState state,  String guildId,  GuildDto? guild,  String code,  DateTime? expiresAt,  int? maxUses,  int useCount,  String? channelId,  String? inviterId,  bool temporary, @JsonKey(unknownEnumValue: InviteTargetType.unknown)  InviteTargetType targetType,  String? targetUserId,  DateTime? revokedAt,  WelcomeScreenDto? welcomeScreen)  $default,) {final _that = this;
switch (_that) {
case _InviteDto():
return $default(_that.id,_that.type,_that.state,_that.guildId,_that.guild,_that.code,_that.expiresAt,_that.maxUses,_that.useCount,_that.channelId,_that.inviterId,_that.temporary,_that.targetType,_that.targetUserId,_that.revokedAt,_that.welcomeScreen);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(unknownEnumValue: InviteType.unknown)  InviteType type, @JsonKey(unknownEnumValue: InviteState.unknown)  InviteState state,  String guildId,  GuildDto? guild,  String code,  DateTime? expiresAt,  int? maxUses,  int useCount,  String? channelId,  String? inviterId,  bool temporary, @JsonKey(unknownEnumValue: InviteTargetType.unknown)  InviteTargetType targetType,  String? targetUserId,  DateTime? revokedAt,  WelcomeScreenDto? welcomeScreen)?  $default,) {final _that = this;
switch (_that) {
case _InviteDto() when $default != null:
return $default(_that.id,_that.type,_that.state,_that.guildId,_that.guild,_that.code,_that.expiresAt,_that.maxUses,_that.useCount,_that.channelId,_that.inviterId,_that.temporary,_that.targetType,_that.targetUserId,_that.revokedAt,_that.welcomeScreen);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@ApiDateTimeConverter()
class _InviteDto implements InviteDto {
  const _InviteDto({required this.id, @JsonKey(unknownEnumValue: InviteType.unknown) required this.type, @JsonKey(unknownEnumValue: InviteState.unknown) required this.state, required this.guildId, this.guild, required this.code, this.expiresAt, this.maxUses, this.useCount = 0, this.channelId, this.inviterId, this.temporary = false, @JsonKey(unknownEnumValue: InviteTargetType.unknown) this.targetType = InviteTargetType.none, this.targetUserId, this.revokedAt, this.welcomeScreen});
  factory _InviteDto.fromJson(Map<String, dynamic> json) => _$InviteDtoFromJson(json);

@override final  String id;
@override@JsonKey(unknownEnumValue: InviteType.unknown) final  InviteType type;
@override@JsonKey(unknownEnumValue: InviteState.unknown) final  InviteState state;
@override final  String guildId;
@override final  GuildDto? guild;
@override final  String code;
@override final  DateTime? expiresAt;
@override final  int? maxUses;
@override@JsonKey() final  int useCount;
/// The channel a joiner lands on. Advisory unless [targetType] says
/// otherwise - and also what decides whether a channel moderator may
/// revoke this invite, so it is read by the settings screen's gating.
@override final  String? channelId;
/// Who created it, as a **user id**. Guild does not own usernames or
/// avatars, so this resolves through the same profile cache message
/// authors do. Null for every invite minted before attribution existed and
/// for anything a system path created.
@override final  String? inviterId;
/// The membership this invite grants ends when the member goes offline,
/// unless they are given a role.
@override@JsonKey() final  bool temporary;
@override@JsonKey(unknownEnumValue: InviteTargetType.unknown) final  InviteTargetType targetType;
@override final  String? targetUserId;
@override final  DateTime? revokedAt;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InviteDto&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.state, state) || other.state == state)&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.guild, guild) || other.guild == guild)&&(identical(other.code, code) || other.code == code)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.maxUses, maxUses) || other.maxUses == maxUses)&&(identical(other.useCount, useCount) || other.useCount == useCount)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.inviterId, inviterId) || other.inviterId == inviterId)&&(identical(other.temporary, temporary) || other.temporary == temporary)&&(identical(other.targetType, targetType) || other.targetType == targetType)&&(identical(other.targetUserId, targetUserId) || other.targetUserId == targetUserId)&&(identical(other.revokedAt, revokedAt) || other.revokedAt == revokedAt)&&(identical(other.welcomeScreen, welcomeScreen) || other.welcomeScreen == welcomeScreen));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,state,guildId,guild,code,expiresAt,maxUses,useCount,channelId,inviterId,temporary,targetType,targetUserId,revokedAt,welcomeScreen);

@override
String toString() {
  return 'InviteDto(id: $id, type: $type, state: $state, guildId: $guildId, guild: $guild, code: $code, expiresAt: $expiresAt, maxUses: $maxUses, useCount: $useCount, channelId: $channelId, inviterId: $inviterId, temporary: $temporary, targetType: $targetType, targetUserId: $targetUserId, revokedAt: $revokedAt, welcomeScreen: $welcomeScreen)';
}


}

/// @nodoc
abstract mixin class _$InviteDtoCopyWith<$Res> implements $InviteDtoCopyWith<$Res> {
  factory _$InviteDtoCopyWith(_InviteDto value, $Res Function(_InviteDto) _then) = __$InviteDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(unknownEnumValue: InviteType.unknown) InviteType type,@JsonKey(unknownEnumValue: InviteState.unknown) InviteState state, String guildId, GuildDto? guild, String code, DateTime? expiresAt, int? maxUses, int useCount, String? channelId, String? inviterId, bool temporary,@JsonKey(unknownEnumValue: InviteTargetType.unknown) InviteTargetType targetType, String? targetUserId, DateTime? revokedAt, WelcomeScreenDto? welcomeScreen
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? state = null,Object? guildId = null,Object? guild = freezed,Object? code = null,Object? expiresAt = freezed,Object? maxUses = freezed,Object? useCount = null,Object? channelId = freezed,Object? inviterId = freezed,Object? temporary = null,Object? targetType = null,Object? targetUserId = freezed,Object? revokedAt = freezed,Object? welcomeScreen = freezed,}) {
  return _then(_InviteDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as InviteType,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as InviteState,guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,guild: freezed == guild ? _self.guild : guild // ignore: cast_nullable_to_non_nullable
as GuildDto?,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,maxUses: freezed == maxUses ? _self.maxUses : maxUses // ignore: cast_nullable_to_non_nullable
as int?,useCount: null == useCount ? _self.useCount : useCount // ignore: cast_nullable_to_non_nullable
as int,channelId: freezed == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String?,inviterId: freezed == inviterId ? _self.inviterId : inviterId // ignore: cast_nullable_to_non_nullable
as String?,temporary: null == temporary ? _self.temporary : temporary // ignore: cast_nullable_to_non_nullable
as bool,targetType: null == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as InviteTargetType,targetUserId: freezed == targetUserId ? _self.targetUserId : targetUserId // ignore: cast_nullable_to_non_nullable
as String?,revokedAt: freezed == revokedAt ? _self.revokedAt : revokedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,welcomeScreen: freezed == welcomeScreen ? _self.welcomeScreen : welcomeScreen // ignore: cast_nullable_to_non_nullable
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


/// @nodoc
mixin _$RedeemResultDto {

 String get guildId; String? get channelId;@JsonKey(unknownEnumValue: InviteTargetType.unknown) InviteTargetType get targetType; String? get targetUserId;/// Connect to [channelId] as voice after joining.
///
/// **Use this, not [targetType].** It is false when the target channel has
/// been deleted or has stopped being a voice channel since the link was
/// made. The join still succeeds in that case and only the landing is
/// dropped, so deriving "should I connect" from [targetType] means trying
/// to join a room that is not there.
 bool get joinVoice;/// The guild gates new members behind a rules screen.
 bool get onboardingRequired;/// The membership ends when this account goes offline, unless it is given
/// a role. Worth a line of UI at join time: a member who is not told will
/// simply find themselves gone.
 bool get temporaryMembership;
/// Create a copy of RedeemResultDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RedeemResultDtoCopyWith<RedeemResultDto> get copyWith => _$RedeemResultDtoCopyWithImpl<RedeemResultDto>(this as RedeemResultDto, _$identity);

  /// Serializes this RedeemResultDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RedeemResultDto&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.targetType, targetType) || other.targetType == targetType)&&(identical(other.targetUserId, targetUserId) || other.targetUserId == targetUserId)&&(identical(other.joinVoice, joinVoice) || other.joinVoice == joinVoice)&&(identical(other.onboardingRequired, onboardingRequired) || other.onboardingRequired == onboardingRequired)&&(identical(other.temporaryMembership, temporaryMembership) || other.temporaryMembership == temporaryMembership));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,guildId,channelId,targetType,targetUserId,joinVoice,onboardingRequired,temporaryMembership);

@override
String toString() {
  return 'RedeemResultDto(guildId: $guildId, channelId: $channelId, targetType: $targetType, targetUserId: $targetUserId, joinVoice: $joinVoice, onboardingRequired: $onboardingRequired, temporaryMembership: $temporaryMembership)';
}


}

/// @nodoc
abstract mixin class $RedeemResultDtoCopyWith<$Res>  {
  factory $RedeemResultDtoCopyWith(RedeemResultDto value, $Res Function(RedeemResultDto) _then) = _$RedeemResultDtoCopyWithImpl;
@useResult
$Res call({
 String guildId, String? channelId,@JsonKey(unknownEnumValue: InviteTargetType.unknown) InviteTargetType targetType, String? targetUserId, bool joinVoice, bool onboardingRequired, bool temporaryMembership
});




}
/// @nodoc
class _$RedeemResultDtoCopyWithImpl<$Res>
    implements $RedeemResultDtoCopyWith<$Res> {
  _$RedeemResultDtoCopyWithImpl(this._self, this._then);

  final RedeemResultDto _self;
  final $Res Function(RedeemResultDto) _then;

/// Create a copy of RedeemResultDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? guildId = null,Object? channelId = freezed,Object? targetType = null,Object? targetUserId = freezed,Object? joinVoice = null,Object? onboardingRequired = null,Object? temporaryMembership = null,}) {
  return _then(_self.copyWith(
guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,channelId: freezed == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String?,targetType: null == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as InviteTargetType,targetUserId: freezed == targetUserId ? _self.targetUserId : targetUserId // ignore: cast_nullable_to_non_nullable
as String?,joinVoice: null == joinVoice ? _self.joinVoice : joinVoice // ignore: cast_nullable_to_non_nullable
as bool,onboardingRequired: null == onboardingRequired ? _self.onboardingRequired : onboardingRequired // ignore: cast_nullable_to_non_nullable
as bool,temporaryMembership: null == temporaryMembership ? _self.temporaryMembership : temporaryMembership // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RedeemResultDto].
extension RedeemResultDtoPatterns on RedeemResultDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RedeemResultDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RedeemResultDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RedeemResultDto value)  $default,){
final _that = this;
switch (_that) {
case _RedeemResultDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RedeemResultDto value)?  $default,){
final _that = this;
switch (_that) {
case _RedeemResultDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String guildId,  String? channelId, @JsonKey(unknownEnumValue: InviteTargetType.unknown)  InviteTargetType targetType,  String? targetUserId,  bool joinVoice,  bool onboardingRequired,  bool temporaryMembership)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RedeemResultDto() when $default != null:
return $default(_that.guildId,_that.channelId,_that.targetType,_that.targetUserId,_that.joinVoice,_that.onboardingRequired,_that.temporaryMembership);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String guildId,  String? channelId, @JsonKey(unknownEnumValue: InviteTargetType.unknown)  InviteTargetType targetType,  String? targetUserId,  bool joinVoice,  bool onboardingRequired,  bool temporaryMembership)  $default,) {final _that = this;
switch (_that) {
case _RedeemResultDto():
return $default(_that.guildId,_that.channelId,_that.targetType,_that.targetUserId,_that.joinVoice,_that.onboardingRequired,_that.temporaryMembership);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String guildId,  String? channelId, @JsonKey(unknownEnumValue: InviteTargetType.unknown)  InviteTargetType targetType,  String? targetUserId,  bool joinVoice,  bool onboardingRequired,  bool temporaryMembership)?  $default,) {final _that = this;
switch (_that) {
case _RedeemResultDto() when $default != null:
return $default(_that.guildId,_that.channelId,_that.targetType,_that.targetUserId,_that.joinVoice,_that.onboardingRequired,_that.temporaryMembership);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RedeemResultDto implements RedeemResultDto {
  const _RedeemResultDto({required this.guildId, this.channelId, @JsonKey(unknownEnumValue: InviteTargetType.unknown) this.targetType = InviteTargetType.none, this.targetUserId, this.joinVoice = false, this.onboardingRequired = false, this.temporaryMembership = false});
  factory _RedeemResultDto.fromJson(Map<String, dynamic> json) => _$RedeemResultDtoFromJson(json);

@override final  String guildId;
@override final  String? channelId;
@override@JsonKey(unknownEnumValue: InviteTargetType.unknown) final  InviteTargetType targetType;
@override final  String? targetUserId;
/// Connect to [channelId] as voice after joining.
///
/// **Use this, not [targetType].** It is false when the target channel has
/// been deleted or has stopped being a voice channel since the link was
/// made. The join still succeeds in that case and only the landing is
/// dropped, so deriving "should I connect" from [targetType] means trying
/// to join a room that is not there.
@override@JsonKey() final  bool joinVoice;
/// The guild gates new members behind a rules screen.
@override@JsonKey() final  bool onboardingRequired;
/// The membership ends when this account goes offline, unless it is given
/// a role. Worth a line of UI at join time: a member who is not told will
/// simply find themselves gone.
@override@JsonKey() final  bool temporaryMembership;

/// Create a copy of RedeemResultDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RedeemResultDtoCopyWith<_RedeemResultDto> get copyWith => __$RedeemResultDtoCopyWithImpl<_RedeemResultDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RedeemResultDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RedeemResultDto&&(identical(other.guildId, guildId) || other.guildId == guildId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.targetType, targetType) || other.targetType == targetType)&&(identical(other.targetUserId, targetUserId) || other.targetUserId == targetUserId)&&(identical(other.joinVoice, joinVoice) || other.joinVoice == joinVoice)&&(identical(other.onboardingRequired, onboardingRequired) || other.onboardingRequired == onboardingRequired)&&(identical(other.temporaryMembership, temporaryMembership) || other.temporaryMembership == temporaryMembership));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,guildId,channelId,targetType,targetUserId,joinVoice,onboardingRequired,temporaryMembership);

@override
String toString() {
  return 'RedeemResultDto(guildId: $guildId, channelId: $channelId, targetType: $targetType, targetUserId: $targetUserId, joinVoice: $joinVoice, onboardingRequired: $onboardingRequired, temporaryMembership: $temporaryMembership)';
}


}

/// @nodoc
abstract mixin class _$RedeemResultDtoCopyWith<$Res> implements $RedeemResultDtoCopyWith<$Res> {
  factory _$RedeemResultDtoCopyWith(_RedeemResultDto value, $Res Function(_RedeemResultDto) _then) = __$RedeemResultDtoCopyWithImpl;
@override @useResult
$Res call({
 String guildId, String? channelId,@JsonKey(unknownEnumValue: InviteTargetType.unknown) InviteTargetType targetType, String? targetUserId, bool joinVoice, bool onboardingRequired, bool temporaryMembership
});




}
/// @nodoc
class __$RedeemResultDtoCopyWithImpl<$Res>
    implements _$RedeemResultDtoCopyWith<$Res> {
  __$RedeemResultDtoCopyWithImpl(this._self, this._then);

  final _RedeemResultDto _self;
  final $Res Function(_RedeemResultDto) _then;

/// Create a copy of RedeemResultDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? guildId = null,Object? channelId = freezed,Object? targetType = null,Object? targetUserId = freezed,Object? joinVoice = null,Object? onboardingRequired = null,Object? temporaryMembership = null,}) {
  return _then(_RedeemResultDto(
guildId: null == guildId ? _self.guildId : guildId // ignore: cast_nullable_to_non_nullable
as String,channelId: freezed == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String?,targetType: null == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as InviteTargetType,targetUserId: freezed == targetUserId ? _self.targetUserId : targetUserId // ignore: cast_nullable_to_non_nullable
as String?,joinVoice: null == joinVoice ? _self.joinVoice : joinVoice // ignore: cast_nullable_to_non_nullable
as bool,onboardingRequired: null == onboardingRequired ? _self.onboardingRequired : onboardingRequired // ignore: cast_nullable_to_non_nullable
as bool,temporaryMembership: null == temporaryMembership ? _self.temporaryMembership : temporaryMembership // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
