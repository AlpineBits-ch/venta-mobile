// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'privacy_settings_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PrivacySettingsDto {

 bool get allowDataCollection; bool get allowPersonalization; bool get allowVoiceRecordingInClips;@JsonKey(unknownEnumValue: DirectMessagePolicy.friends) DirectMessagePolicy get directMessagePolicy;@JsonKey(unknownEnumValue: FriendRequestPolicy.nobody) FriendRequestPolicy get friendRequestPolicy; bool get discoverableByUsername; bool get discoverableByEmail; bool get discoverableByPhone;@JsonKey(unknownEnumValue: ProfileVisibility.nobody) ProfileVisibility get mutualServersVisibility;@JsonKey(unknownEnumValue: ProfileVisibility.nobody) ProfileVisibility get mutualFriendsVisibility;@JsonKey(unknownEnumValue: ProfileVisibility.nobody) ProfileVisibility get connectionsVisibility;@JsonKey(unknownEnumValue: ProfileVisibility.nobody) ProfileVisibility get birthdayVisibility; bool get shareActivity; bool get allowPositionalVoiceCapture; bool get sendReadReceipts; bool get sendTypingIndicators;/// `null` keeps messages forever. Applies only to messages *you* sent.
 int? get dmRetentionDays;@JsonKey(unknownEnumValue: ExplicitContentFilter.unknownSenders) ExplicitContentFilter get explicitContentFilter; bool get hidePushContent;/// Bumped by the server on every write. Only carried so a stale response
/// arriving after a newer one can be recognised, never rendered.
 int get version;/// Set when the account is under the jurisdictional age.
///
/// **Not currently sent.** The deployed contract has no minor flag: the
/// floors are applied by *clamping the values this endpoint returns*, which
/// on the wire is indistinguishable from an adult who picked those values.
/// The field is kept because the alternative is inferring age from the
/// clamped values, which would grey out an adult's deliberate choices;
/// `PrivacySettingsScreen` instead learns a floor from the first
/// `403 minor_restriction` and locks that one control.
///
/// The clamping is also why nothing here may be read-modify-written: a
/// minor's `GET` hands back floored values, and sending them straight back
/// is a write the server refuses.
 bool get isMinor;
/// Create a copy of PrivacySettingsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrivacySettingsDtoCopyWith<PrivacySettingsDto> get copyWith => _$PrivacySettingsDtoCopyWithImpl<PrivacySettingsDto>(this as PrivacySettingsDto, _$identity);

  /// Serializes this PrivacySettingsDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrivacySettingsDto&&(identical(other.allowDataCollection, allowDataCollection) || other.allowDataCollection == allowDataCollection)&&(identical(other.allowPersonalization, allowPersonalization) || other.allowPersonalization == allowPersonalization)&&(identical(other.allowVoiceRecordingInClips, allowVoiceRecordingInClips) || other.allowVoiceRecordingInClips == allowVoiceRecordingInClips)&&(identical(other.directMessagePolicy, directMessagePolicy) || other.directMessagePolicy == directMessagePolicy)&&(identical(other.friendRequestPolicy, friendRequestPolicy) || other.friendRequestPolicy == friendRequestPolicy)&&(identical(other.discoverableByUsername, discoverableByUsername) || other.discoverableByUsername == discoverableByUsername)&&(identical(other.discoverableByEmail, discoverableByEmail) || other.discoverableByEmail == discoverableByEmail)&&(identical(other.discoverableByPhone, discoverableByPhone) || other.discoverableByPhone == discoverableByPhone)&&(identical(other.mutualServersVisibility, mutualServersVisibility) || other.mutualServersVisibility == mutualServersVisibility)&&(identical(other.mutualFriendsVisibility, mutualFriendsVisibility) || other.mutualFriendsVisibility == mutualFriendsVisibility)&&(identical(other.connectionsVisibility, connectionsVisibility) || other.connectionsVisibility == connectionsVisibility)&&(identical(other.birthdayVisibility, birthdayVisibility) || other.birthdayVisibility == birthdayVisibility)&&(identical(other.shareActivity, shareActivity) || other.shareActivity == shareActivity)&&(identical(other.allowPositionalVoiceCapture, allowPositionalVoiceCapture) || other.allowPositionalVoiceCapture == allowPositionalVoiceCapture)&&(identical(other.sendReadReceipts, sendReadReceipts) || other.sendReadReceipts == sendReadReceipts)&&(identical(other.sendTypingIndicators, sendTypingIndicators) || other.sendTypingIndicators == sendTypingIndicators)&&(identical(other.dmRetentionDays, dmRetentionDays) || other.dmRetentionDays == dmRetentionDays)&&(identical(other.explicitContentFilter, explicitContentFilter) || other.explicitContentFilter == explicitContentFilter)&&(identical(other.hidePushContent, hidePushContent) || other.hidePushContent == hidePushContent)&&(identical(other.version, version) || other.version == version)&&(identical(other.isMinor, isMinor) || other.isMinor == isMinor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,allowDataCollection,allowPersonalization,allowVoiceRecordingInClips,directMessagePolicy,friendRequestPolicy,discoverableByUsername,discoverableByEmail,discoverableByPhone,mutualServersVisibility,mutualFriendsVisibility,connectionsVisibility,birthdayVisibility,shareActivity,allowPositionalVoiceCapture,sendReadReceipts,sendTypingIndicators,dmRetentionDays,explicitContentFilter,hidePushContent,version,isMinor]);

@override
String toString() {
  return 'PrivacySettingsDto(allowDataCollection: $allowDataCollection, allowPersonalization: $allowPersonalization, allowVoiceRecordingInClips: $allowVoiceRecordingInClips, directMessagePolicy: $directMessagePolicy, friendRequestPolicy: $friendRequestPolicy, discoverableByUsername: $discoverableByUsername, discoverableByEmail: $discoverableByEmail, discoverableByPhone: $discoverableByPhone, mutualServersVisibility: $mutualServersVisibility, mutualFriendsVisibility: $mutualFriendsVisibility, connectionsVisibility: $connectionsVisibility, birthdayVisibility: $birthdayVisibility, shareActivity: $shareActivity, allowPositionalVoiceCapture: $allowPositionalVoiceCapture, sendReadReceipts: $sendReadReceipts, sendTypingIndicators: $sendTypingIndicators, dmRetentionDays: $dmRetentionDays, explicitContentFilter: $explicitContentFilter, hidePushContent: $hidePushContent, version: $version, isMinor: $isMinor)';
}


}

/// @nodoc
abstract mixin class $PrivacySettingsDtoCopyWith<$Res>  {
  factory $PrivacySettingsDtoCopyWith(PrivacySettingsDto value, $Res Function(PrivacySettingsDto) _then) = _$PrivacySettingsDtoCopyWithImpl;
@useResult
$Res call({
 bool allowDataCollection, bool allowPersonalization, bool allowVoiceRecordingInClips,@JsonKey(unknownEnumValue: DirectMessagePolicy.friends) DirectMessagePolicy directMessagePolicy,@JsonKey(unknownEnumValue: FriendRequestPolicy.nobody) FriendRequestPolicy friendRequestPolicy, bool discoverableByUsername, bool discoverableByEmail, bool discoverableByPhone,@JsonKey(unknownEnumValue: ProfileVisibility.nobody) ProfileVisibility mutualServersVisibility,@JsonKey(unknownEnumValue: ProfileVisibility.nobody) ProfileVisibility mutualFriendsVisibility,@JsonKey(unknownEnumValue: ProfileVisibility.nobody) ProfileVisibility connectionsVisibility,@JsonKey(unknownEnumValue: ProfileVisibility.nobody) ProfileVisibility birthdayVisibility, bool shareActivity, bool allowPositionalVoiceCapture, bool sendReadReceipts, bool sendTypingIndicators, int? dmRetentionDays,@JsonKey(unknownEnumValue: ExplicitContentFilter.unknownSenders) ExplicitContentFilter explicitContentFilter, bool hidePushContent, int version, bool isMinor
});




}
/// @nodoc
class _$PrivacySettingsDtoCopyWithImpl<$Res>
    implements $PrivacySettingsDtoCopyWith<$Res> {
  _$PrivacySettingsDtoCopyWithImpl(this._self, this._then);

  final PrivacySettingsDto _self;
  final $Res Function(PrivacySettingsDto) _then;

/// Create a copy of PrivacySettingsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? allowDataCollection = null,Object? allowPersonalization = null,Object? allowVoiceRecordingInClips = null,Object? directMessagePolicy = null,Object? friendRequestPolicy = null,Object? discoverableByUsername = null,Object? discoverableByEmail = null,Object? discoverableByPhone = null,Object? mutualServersVisibility = null,Object? mutualFriendsVisibility = null,Object? connectionsVisibility = null,Object? birthdayVisibility = null,Object? shareActivity = null,Object? allowPositionalVoiceCapture = null,Object? sendReadReceipts = null,Object? sendTypingIndicators = null,Object? dmRetentionDays = freezed,Object? explicitContentFilter = null,Object? hidePushContent = null,Object? version = null,Object? isMinor = null,}) {
  return _then(_self.copyWith(
allowDataCollection: null == allowDataCollection ? _self.allowDataCollection : allowDataCollection // ignore: cast_nullable_to_non_nullable
as bool,allowPersonalization: null == allowPersonalization ? _self.allowPersonalization : allowPersonalization // ignore: cast_nullable_to_non_nullable
as bool,allowVoiceRecordingInClips: null == allowVoiceRecordingInClips ? _self.allowVoiceRecordingInClips : allowVoiceRecordingInClips // ignore: cast_nullable_to_non_nullable
as bool,directMessagePolicy: null == directMessagePolicy ? _self.directMessagePolicy : directMessagePolicy // ignore: cast_nullable_to_non_nullable
as DirectMessagePolicy,friendRequestPolicy: null == friendRequestPolicy ? _self.friendRequestPolicy : friendRequestPolicy // ignore: cast_nullable_to_non_nullable
as FriendRequestPolicy,discoverableByUsername: null == discoverableByUsername ? _self.discoverableByUsername : discoverableByUsername // ignore: cast_nullable_to_non_nullable
as bool,discoverableByEmail: null == discoverableByEmail ? _self.discoverableByEmail : discoverableByEmail // ignore: cast_nullable_to_non_nullable
as bool,discoverableByPhone: null == discoverableByPhone ? _self.discoverableByPhone : discoverableByPhone // ignore: cast_nullable_to_non_nullable
as bool,mutualServersVisibility: null == mutualServersVisibility ? _self.mutualServersVisibility : mutualServersVisibility // ignore: cast_nullable_to_non_nullable
as ProfileVisibility,mutualFriendsVisibility: null == mutualFriendsVisibility ? _self.mutualFriendsVisibility : mutualFriendsVisibility // ignore: cast_nullable_to_non_nullable
as ProfileVisibility,connectionsVisibility: null == connectionsVisibility ? _self.connectionsVisibility : connectionsVisibility // ignore: cast_nullable_to_non_nullable
as ProfileVisibility,birthdayVisibility: null == birthdayVisibility ? _self.birthdayVisibility : birthdayVisibility // ignore: cast_nullable_to_non_nullable
as ProfileVisibility,shareActivity: null == shareActivity ? _self.shareActivity : shareActivity // ignore: cast_nullable_to_non_nullable
as bool,allowPositionalVoiceCapture: null == allowPositionalVoiceCapture ? _self.allowPositionalVoiceCapture : allowPositionalVoiceCapture // ignore: cast_nullable_to_non_nullable
as bool,sendReadReceipts: null == sendReadReceipts ? _self.sendReadReceipts : sendReadReceipts // ignore: cast_nullable_to_non_nullable
as bool,sendTypingIndicators: null == sendTypingIndicators ? _self.sendTypingIndicators : sendTypingIndicators // ignore: cast_nullable_to_non_nullable
as bool,dmRetentionDays: freezed == dmRetentionDays ? _self.dmRetentionDays : dmRetentionDays // ignore: cast_nullable_to_non_nullable
as int?,explicitContentFilter: null == explicitContentFilter ? _self.explicitContentFilter : explicitContentFilter // ignore: cast_nullable_to_non_nullable
as ExplicitContentFilter,hidePushContent: null == hidePushContent ? _self.hidePushContent : hidePushContent // ignore: cast_nullable_to_non_nullable
as bool,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,isMinor: null == isMinor ? _self.isMinor : isMinor // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PrivacySettingsDto].
extension PrivacySettingsDtoPatterns on PrivacySettingsDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrivacySettingsDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrivacySettingsDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrivacySettingsDto value)  $default,){
final _that = this;
switch (_that) {
case _PrivacySettingsDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrivacySettingsDto value)?  $default,){
final _that = this;
switch (_that) {
case _PrivacySettingsDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool allowDataCollection,  bool allowPersonalization,  bool allowVoiceRecordingInClips, @JsonKey(unknownEnumValue: DirectMessagePolicy.friends)  DirectMessagePolicy directMessagePolicy, @JsonKey(unknownEnumValue: FriendRequestPolicy.nobody)  FriendRequestPolicy friendRequestPolicy,  bool discoverableByUsername,  bool discoverableByEmail,  bool discoverableByPhone, @JsonKey(unknownEnumValue: ProfileVisibility.nobody)  ProfileVisibility mutualServersVisibility, @JsonKey(unknownEnumValue: ProfileVisibility.nobody)  ProfileVisibility mutualFriendsVisibility, @JsonKey(unknownEnumValue: ProfileVisibility.nobody)  ProfileVisibility connectionsVisibility, @JsonKey(unknownEnumValue: ProfileVisibility.nobody)  ProfileVisibility birthdayVisibility,  bool shareActivity,  bool allowPositionalVoiceCapture,  bool sendReadReceipts,  bool sendTypingIndicators,  int? dmRetentionDays, @JsonKey(unknownEnumValue: ExplicitContentFilter.unknownSenders)  ExplicitContentFilter explicitContentFilter,  bool hidePushContent,  int version,  bool isMinor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrivacySettingsDto() when $default != null:
return $default(_that.allowDataCollection,_that.allowPersonalization,_that.allowVoiceRecordingInClips,_that.directMessagePolicy,_that.friendRequestPolicy,_that.discoverableByUsername,_that.discoverableByEmail,_that.discoverableByPhone,_that.mutualServersVisibility,_that.mutualFriendsVisibility,_that.connectionsVisibility,_that.birthdayVisibility,_that.shareActivity,_that.allowPositionalVoiceCapture,_that.sendReadReceipts,_that.sendTypingIndicators,_that.dmRetentionDays,_that.explicitContentFilter,_that.hidePushContent,_that.version,_that.isMinor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool allowDataCollection,  bool allowPersonalization,  bool allowVoiceRecordingInClips, @JsonKey(unknownEnumValue: DirectMessagePolicy.friends)  DirectMessagePolicy directMessagePolicy, @JsonKey(unknownEnumValue: FriendRequestPolicy.nobody)  FriendRequestPolicy friendRequestPolicy,  bool discoverableByUsername,  bool discoverableByEmail,  bool discoverableByPhone, @JsonKey(unknownEnumValue: ProfileVisibility.nobody)  ProfileVisibility mutualServersVisibility, @JsonKey(unknownEnumValue: ProfileVisibility.nobody)  ProfileVisibility mutualFriendsVisibility, @JsonKey(unknownEnumValue: ProfileVisibility.nobody)  ProfileVisibility connectionsVisibility, @JsonKey(unknownEnumValue: ProfileVisibility.nobody)  ProfileVisibility birthdayVisibility,  bool shareActivity,  bool allowPositionalVoiceCapture,  bool sendReadReceipts,  bool sendTypingIndicators,  int? dmRetentionDays, @JsonKey(unknownEnumValue: ExplicitContentFilter.unknownSenders)  ExplicitContentFilter explicitContentFilter,  bool hidePushContent,  int version,  bool isMinor)  $default,) {final _that = this;
switch (_that) {
case _PrivacySettingsDto():
return $default(_that.allowDataCollection,_that.allowPersonalization,_that.allowVoiceRecordingInClips,_that.directMessagePolicy,_that.friendRequestPolicy,_that.discoverableByUsername,_that.discoverableByEmail,_that.discoverableByPhone,_that.mutualServersVisibility,_that.mutualFriendsVisibility,_that.connectionsVisibility,_that.birthdayVisibility,_that.shareActivity,_that.allowPositionalVoiceCapture,_that.sendReadReceipts,_that.sendTypingIndicators,_that.dmRetentionDays,_that.explicitContentFilter,_that.hidePushContent,_that.version,_that.isMinor);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool allowDataCollection,  bool allowPersonalization,  bool allowVoiceRecordingInClips, @JsonKey(unknownEnumValue: DirectMessagePolicy.friends)  DirectMessagePolicy directMessagePolicy, @JsonKey(unknownEnumValue: FriendRequestPolicy.nobody)  FriendRequestPolicy friendRequestPolicy,  bool discoverableByUsername,  bool discoverableByEmail,  bool discoverableByPhone, @JsonKey(unknownEnumValue: ProfileVisibility.nobody)  ProfileVisibility mutualServersVisibility, @JsonKey(unknownEnumValue: ProfileVisibility.nobody)  ProfileVisibility mutualFriendsVisibility, @JsonKey(unknownEnumValue: ProfileVisibility.nobody)  ProfileVisibility connectionsVisibility, @JsonKey(unknownEnumValue: ProfileVisibility.nobody)  ProfileVisibility birthdayVisibility,  bool shareActivity,  bool allowPositionalVoiceCapture,  bool sendReadReceipts,  bool sendTypingIndicators,  int? dmRetentionDays, @JsonKey(unknownEnumValue: ExplicitContentFilter.unknownSenders)  ExplicitContentFilter explicitContentFilter,  bool hidePushContent,  int version,  bool isMinor)?  $default,) {final _that = this;
switch (_that) {
case _PrivacySettingsDto() when $default != null:
return $default(_that.allowDataCollection,_that.allowPersonalization,_that.allowVoiceRecordingInClips,_that.directMessagePolicy,_that.friendRequestPolicy,_that.discoverableByUsername,_that.discoverableByEmail,_that.discoverableByPhone,_that.mutualServersVisibility,_that.mutualFriendsVisibility,_that.connectionsVisibility,_that.birthdayVisibility,_that.shareActivity,_that.allowPositionalVoiceCapture,_that.sendReadReceipts,_that.sendTypingIndicators,_that.dmRetentionDays,_that.explicitContentFilter,_that.hidePushContent,_that.version,_that.isMinor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PrivacySettingsDto implements PrivacySettingsDto {
  const _PrivacySettingsDto({this.allowDataCollection = false, this.allowPersonalization = false, this.allowVoiceRecordingInClips = false, @JsonKey(unknownEnumValue: DirectMessagePolicy.friends) this.directMessagePolicy = DirectMessagePolicy.friends, @JsonKey(unknownEnumValue: FriendRequestPolicy.nobody) this.friendRequestPolicy = FriendRequestPolicy.nobody, this.discoverableByUsername = false, this.discoverableByEmail = false, this.discoverableByPhone = false, @JsonKey(unknownEnumValue: ProfileVisibility.nobody) this.mutualServersVisibility = ProfileVisibility.nobody, @JsonKey(unknownEnumValue: ProfileVisibility.nobody) this.mutualFriendsVisibility = ProfileVisibility.nobody, @JsonKey(unknownEnumValue: ProfileVisibility.nobody) this.connectionsVisibility = ProfileVisibility.nobody, @JsonKey(unknownEnumValue: ProfileVisibility.nobody) this.birthdayVisibility = ProfileVisibility.nobody, this.shareActivity = false, this.allowPositionalVoiceCapture = false, this.sendReadReceipts = false, this.sendTypingIndicators = false, this.dmRetentionDays, @JsonKey(unknownEnumValue: ExplicitContentFilter.unknownSenders) this.explicitContentFilter = ExplicitContentFilter.unknownSenders, this.hidePushContent = true, this.version = 0, this.isMinor = false});
  factory _PrivacySettingsDto.fromJson(Map<String, dynamic> json) => _$PrivacySettingsDtoFromJson(json);

@override@JsonKey() final  bool allowDataCollection;
@override@JsonKey() final  bool allowPersonalization;
@override@JsonKey() final  bool allowVoiceRecordingInClips;
@override@JsonKey(unknownEnumValue: DirectMessagePolicy.friends) final  DirectMessagePolicy directMessagePolicy;
@override@JsonKey(unknownEnumValue: FriendRequestPolicy.nobody) final  FriendRequestPolicy friendRequestPolicy;
@override@JsonKey() final  bool discoverableByUsername;
@override@JsonKey() final  bool discoverableByEmail;
@override@JsonKey() final  bool discoverableByPhone;
@override@JsonKey(unknownEnumValue: ProfileVisibility.nobody) final  ProfileVisibility mutualServersVisibility;
@override@JsonKey(unknownEnumValue: ProfileVisibility.nobody) final  ProfileVisibility mutualFriendsVisibility;
@override@JsonKey(unknownEnumValue: ProfileVisibility.nobody) final  ProfileVisibility connectionsVisibility;
@override@JsonKey(unknownEnumValue: ProfileVisibility.nobody) final  ProfileVisibility birthdayVisibility;
@override@JsonKey() final  bool shareActivity;
@override@JsonKey() final  bool allowPositionalVoiceCapture;
@override@JsonKey() final  bool sendReadReceipts;
@override@JsonKey() final  bool sendTypingIndicators;
/// `null` keeps messages forever. Applies only to messages *you* sent.
@override final  int? dmRetentionDays;
@override@JsonKey(unknownEnumValue: ExplicitContentFilter.unknownSenders) final  ExplicitContentFilter explicitContentFilter;
@override@JsonKey() final  bool hidePushContent;
/// Bumped by the server on every write. Only carried so a stale response
/// arriving after a newer one can be recognised, never rendered.
@override@JsonKey() final  int version;
/// Set when the account is under the jurisdictional age.
///
/// **Not currently sent.** The deployed contract has no minor flag: the
/// floors are applied by *clamping the values this endpoint returns*, which
/// on the wire is indistinguishable from an adult who picked those values.
/// The field is kept because the alternative is inferring age from the
/// clamped values, which would grey out an adult's deliberate choices;
/// `PrivacySettingsScreen` instead learns a floor from the first
/// `403 minor_restriction` and locks that one control.
///
/// The clamping is also why nothing here may be read-modify-written: a
/// minor's `GET` hands back floored values, and sending them straight back
/// is a write the server refuses.
@override@JsonKey() final  bool isMinor;

/// Create a copy of PrivacySettingsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrivacySettingsDtoCopyWith<_PrivacySettingsDto> get copyWith => __$PrivacySettingsDtoCopyWithImpl<_PrivacySettingsDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PrivacySettingsDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrivacySettingsDto&&(identical(other.allowDataCollection, allowDataCollection) || other.allowDataCollection == allowDataCollection)&&(identical(other.allowPersonalization, allowPersonalization) || other.allowPersonalization == allowPersonalization)&&(identical(other.allowVoiceRecordingInClips, allowVoiceRecordingInClips) || other.allowVoiceRecordingInClips == allowVoiceRecordingInClips)&&(identical(other.directMessagePolicy, directMessagePolicy) || other.directMessagePolicy == directMessagePolicy)&&(identical(other.friendRequestPolicy, friendRequestPolicy) || other.friendRequestPolicy == friendRequestPolicy)&&(identical(other.discoverableByUsername, discoverableByUsername) || other.discoverableByUsername == discoverableByUsername)&&(identical(other.discoverableByEmail, discoverableByEmail) || other.discoverableByEmail == discoverableByEmail)&&(identical(other.discoverableByPhone, discoverableByPhone) || other.discoverableByPhone == discoverableByPhone)&&(identical(other.mutualServersVisibility, mutualServersVisibility) || other.mutualServersVisibility == mutualServersVisibility)&&(identical(other.mutualFriendsVisibility, mutualFriendsVisibility) || other.mutualFriendsVisibility == mutualFriendsVisibility)&&(identical(other.connectionsVisibility, connectionsVisibility) || other.connectionsVisibility == connectionsVisibility)&&(identical(other.birthdayVisibility, birthdayVisibility) || other.birthdayVisibility == birthdayVisibility)&&(identical(other.shareActivity, shareActivity) || other.shareActivity == shareActivity)&&(identical(other.allowPositionalVoiceCapture, allowPositionalVoiceCapture) || other.allowPositionalVoiceCapture == allowPositionalVoiceCapture)&&(identical(other.sendReadReceipts, sendReadReceipts) || other.sendReadReceipts == sendReadReceipts)&&(identical(other.sendTypingIndicators, sendTypingIndicators) || other.sendTypingIndicators == sendTypingIndicators)&&(identical(other.dmRetentionDays, dmRetentionDays) || other.dmRetentionDays == dmRetentionDays)&&(identical(other.explicitContentFilter, explicitContentFilter) || other.explicitContentFilter == explicitContentFilter)&&(identical(other.hidePushContent, hidePushContent) || other.hidePushContent == hidePushContent)&&(identical(other.version, version) || other.version == version)&&(identical(other.isMinor, isMinor) || other.isMinor == isMinor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,allowDataCollection,allowPersonalization,allowVoiceRecordingInClips,directMessagePolicy,friendRequestPolicy,discoverableByUsername,discoverableByEmail,discoverableByPhone,mutualServersVisibility,mutualFriendsVisibility,connectionsVisibility,birthdayVisibility,shareActivity,allowPositionalVoiceCapture,sendReadReceipts,sendTypingIndicators,dmRetentionDays,explicitContentFilter,hidePushContent,version,isMinor]);

@override
String toString() {
  return 'PrivacySettingsDto(allowDataCollection: $allowDataCollection, allowPersonalization: $allowPersonalization, allowVoiceRecordingInClips: $allowVoiceRecordingInClips, directMessagePolicy: $directMessagePolicy, friendRequestPolicy: $friendRequestPolicy, discoverableByUsername: $discoverableByUsername, discoverableByEmail: $discoverableByEmail, discoverableByPhone: $discoverableByPhone, mutualServersVisibility: $mutualServersVisibility, mutualFriendsVisibility: $mutualFriendsVisibility, connectionsVisibility: $connectionsVisibility, birthdayVisibility: $birthdayVisibility, shareActivity: $shareActivity, allowPositionalVoiceCapture: $allowPositionalVoiceCapture, sendReadReceipts: $sendReadReceipts, sendTypingIndicators: $sendTypingIndicators, dmRetentionDays: $dmRetentionDays, explicitContentFilter: $explicitContentFilter, hidePushContent: $hidePushContent, version: $version, isMinor: $isMinor)';
}


}

/// @nodoc
abstract mixin class _$PrivacySettingsDtoCopyWith<$Res> implements $PrivacySettingsDtoCopyWith<$Res> {
  factory _$PrivacySettingsDtoCopyWith(_PrivacySettingsDto value, $Res Function(_PrivacySettingsDto) _then) = __$PrivacySettingsDtoCopyWithImpl;
@override @useResult
$Res call({
 bool allowDataCollection, bool allowPersonalization, bool allowVoiceRecordingInClips,@JsonKey(unknownEnumValue: DirectMessagePolicy.friends) DirectMessagePolicy directMessagePolicy,@JsonKey(unknownEnumValue: FriendRequestPolicy.nobody) FriendRequestPolicy friendRequestPolicy, bool discoverableByUsername, bool discoverableByEmail, bool discoverableByPhone,@JsonKey(unknownEnumValue: ProfileVisibility.nobody) ProfileVisibility mutualServersVisibility,@JsonKey(unknownEnumValue: ProfileVisibility.nobody) ProfileVisibility mutualFriendsVisibility,@JsonKey(unknownEnumValue: ProfileVisibility.nobody) ProfileVisibility connectionsVisibility,@JsonKey(unknownEnumValue: ProfileVisibility.nobody) ProfileVisibility birthdayVisibility, bool shareActivity, bool allowPositionalVoiceCapture, bool sendReadReceipts, bool sendTypingIndicators, int? dmRetentionDays,@JsonKey(unknownEnumValue: ExplicitContentFilter.unknownSenders) ExplicitContentFilter explicitContentFilter, bool hidePushContent, int version, bool isMinor
});




}
/// @nodoc
class __$PrivacySettingsDtoCopyWithImpl<$Res>
    implements _$PrivacySettingsDtoCopyWith<$Res> {
  __$PrivacySettingsDtoCopyWithImpl(this._self, this._then);

  final _PrivacySettingsDto _self;
  final $Res Function(_PrivacySettingsDto) _then;

/// Create a copy of PrivacySettingsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? allowDataCollection = null,Object? allowPersonalization = null,Object? allowVoiceRecordingInClips = null,Object? directMessagePolicy = null,Object? friendRequestPolicy = null,Object? discoverableByUsername = null,Object? discoverableByEmail = null,Object? discoverableByPhone = null,Object? mutualServersVisibility = null,Object? mutualFriendsVisibility = null,Object? connectionsVisibility = null,Object? birthdayVisibility = null,Object? shareActivity = null,Object? allowPositionalVoiceCapture = null,Object? sendReadReceipts = null,Object? sendTypingIndicators = null,Object? dmRetentionDays = freezed,Object? explicitContentFilter = null,Object? hidePushContent = null,Object? version = null,Object? isMinor = null,}) {
  return _then(_PrivacySettingsDto(
allowDataCollection: null == allowDataCollection ? _self.allowDataCollection : allowDataCollection // ignore: cast_nullable_to_non_nullable
as bool,allowPersonalization: null == allowPersonalization ? _self.allowPersonalization : allowPersonalization // ignore: cast_nullable_to_non_nullable
as bool,allowVoiceRecordingInClips: null == allowVoiceRecordingInClips ? _self.allowVoiceRecordingInClips : allowVoiceRecordingInClips // ignore: cast_nullable_to_non_nullable
as bool,directMessagePolicy: null == directMessagePolicy ? _self.directMessagePolicy : directMessagePolicy // ignore: cast_nullable_to_non_nullable
as DirectMessagePolicy,friendRequestPolicy: null == friendRequestPolicy ? _self.friendRequestPolicy : friendRequestPolicy // ignore: cast_nullable_to_non_nullable
as FriendRequestPolicy,discoverableByUsername: null == discoverableByUsername ? _self.discoverableByUsername : discoverableByUsername // ignore: cast_nullable_to_non_nullable
as bool,discoverableByEmail: null == discoverableByEmail ? _self.discoverableByEmail : discoverableByEmail // ignore: cast_nullable_to_non_nullable
as bool,discoverableByPhone: null == discoverableByPhone ? _self.discoverableByPhone : discoverableByPhone // ignore: cast_nullable_to_non_nullable
as bool,mutualServersVisibility: null == mutualServersVisibility ? _self.mutualServersVisibility : mutualServersVisibility // ignore: cast_nullable_to_non_nullable
as ProfileVisibility,mutualFriendsVisibility: null == mutualFriendsVisibility ? _self.mutualFriendsVisibility : mutualFriendsVisibility // ignore: cast_nullable_to_non_nullable
as ProfileVisibility,connectionsVisibility: null == connectionsVisibility ? _self.connectionsVisibility : connectionsVisibility // ignore: cast_nullable_to_non_nullable
as ProfileVisibility,birthdayVisibility: null == birthdayVisibility ? _self.birthdayVisibility : birthdayVisibility // ignore: cast_nullable_to_non_nullable
as ProfileVisibility,shareActivity: null == shareActivity ? _self.shareActivity : shareActivity // ignore: cast_nullable_to_non_nullable
as bool,allowPositionalVoiceCapture: null == allowPositionalVoiceCapture ? _self.allowPositionalVoiceCapture : allowPositionalVoiceCapture // ignore: cast_nullable_to_non_nullable
as bool,sendReadReceipts: null == sendReadReceipts ? _self.sendReadReceipts : sendReadReceipts // ignore: cast_nullable_to_non_nullable
as bool,sendTypingIndicators: null == sendTypingIndicators ? _self.sendTypingIndicators : sendTypingIndicators // ignore: cast_nullable_to_non_nullable
as bool,dmRetentionDays: freezed == dmRetentionDays ? _self.dmRetentionDays : dmRetentionDays // ignore: cast_nullable_to_non_nullable
as int?,explicitContentFilter: null == explicitContentFilter ? _self.explicitContentFilter : explicitContentFilter // ignore: cast_nullable_to_non_nullable
as ExplicitContentFilter,hidePushContent: null == hidePushContent ? _self.hidePushContent : hidePushContent // ignore: cast_nullable_to_non_nullable
as bool,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,isMinor: null == isMinor ? _self.isMinor : isMinor // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
