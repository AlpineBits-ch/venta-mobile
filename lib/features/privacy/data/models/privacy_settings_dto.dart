import 'package:freezed_annotation/freezed_annotation.dart';

part 'privacy_settings_dto.freezed.dart';
part 'privacy_settings_dto.g.dart';

/// Who may open a DM with you.
enum DirectMessagePolicy {
  @JsonValue('Everyone')
  everyone,
  @JsonValue('FriendsAndServerMembers')
  friendsAndServerMembers,
  @JsonValue('Friends')
  friends,
  @JsonValue('Nobody')
  nobody,
}

/// Who may send you a friend request.
enum FriendRequestPolicy {
  @JsonValue('Everyone')
  everyone,
  @JsonValue('FriendsOfFriends')
  friendsOfFriends,
  @JsonValue('ServerMembers')
  serverMembers,
  @JsonValue('Nobody')
  nobody,
}

/// Who may see one profile field.
///
/// Named `Visibility` server-side; renamed here because Flutter exports a
/// widget by that name from `material.dart`, and every screen that renders one
/// of these also imports that. The wire values are unchanged.
enum ProfileVisibility {
  @JsonValue('Everyone')
  everyone,
  @JsonValue('Friends')
  friends,
  @JsonValue('Nobody')
  nobody,
}

enum ExplicitContentFilter {
  @JsonValue('Off')
  off,
  @JsonValue('UnknownSenders')
  unknownSenders,
  @JsonValue('Everyone')
  everyone,
}

extension DirectMessagePolicyX on DirectMessagePolicy {
  String get label => switch (this) {
    DirectMessagePolicy.everyone => 'Everyone',
    DirectMessagePolicy.friendsAndServerMembers => 'Friends and server members',
    DirectMessagePolicy.friends => 'Friends only',
    DirectMessagePolicy.nobody => 'Nobody',
  };

  String get description => switch (this) {
    DirectMessagePolicy.everyone =>
      'Anyone on this instance can start a conversation with you.',
    DirectMessagePolicy.friendsAndServerMembers =>
      'Friends, plus people who share a server with you - per-server '
          'exceptions live under Server message privacy.',
    DirectMessagePolicy.friends => 'Only people on your friends list.',
    DirectMessagePolicy.nobody =>
      'Nobody new. Conversations you are already in keep working.',
  };
}

extension FriendRequestPolicyX on FriendRequestPolicy {
  String get label => switch (this) {
    FriendRequestPolicy.everyone => 'Everyone',
    FriendRequestPolicy.friendsOfFriends => 'Friends of friends',
    FriendRequestPolicy.serverMembers => 'People in my servers',
    FriendRequestPolicy.nobody => 'Nobody',
  };
}

extension ProfileVisibilityX on ProfileVisibility {
  String get label => switch (this) {
    ProfileVisibility.everyone => 'Everyone',
    ProfileVisibility.friends => 'Friends',
    ProfileVisibility.nobody => 'Nobody',
  };
}

extension ExplicitContentFilterX on ExplicitContentFilter {
  String get label => switch (this) {
    ExplicitContentFilter.off => 'Do not filter',
    ExplicitContentFilter.unknownSenders => 'Filter from people I don\'t know',
    ExplicitContentFilter.everyone => 'Filter from everyone',
  };
}

/// The account's privacy record - one row server-side, one screen here.
///
/// Every default below is the **restrictive** one, and deliberately so: this
/// object is also what `PrivacyRepository` hands out when the settings cannot be
/// fetched at all, and a client that guesses "Everyone" on a failed request is a
/// client that quietly undoes the setting it failed to read. The three
/// data-use consents default false for the same reason - a default must never
/// be able to represent consent nobody gave.
///
/// Note that these defaults are *not* the server's defaults for a fresh
/// account (`DiscoverableByUsername`, `ShareActivity`, read receipts and typing
/// are all true there). Nothing here is written back unless the user touches a
/// control, so the two never fight: a real fetch replaces this wholesale.
@freezed
sealed class PrivacySettingsDto with _$PrivacySettingsDto {
  const factory PrivacySettingsDto({
    // Data use - consent, opt-in only.
    @Default(false) bool allowDataCollection,
    @Default(false) bool allowPersonalization,
    @Default(false) bool allowVoiceRecordingInClips,

    // Contactability.
    @Default(DirectMessagePolicy.friends)
    @JsonKey(unknownEnumValue: DirectMessagePolicy.friends)
    DirectMessagePolicy directMessagePolicy,
    @Default(FriendRequestPolicy.nobody)
    @JsonKey(unknownEnumValue: FriendRequestPolicy.nobody)
    FriendRequestPolicy friendRequestPolicy,

    // Discoverability.
    @Default(false) bool discoverableByUsername,
    @Default(false) bool discoverableByEmail,
    @Default(false) bool discoverableByPhone,

    // Profile field visibility.
    @Default(ProfileVisibility.nobody)
    @JsonKey(unknownEnumValue: ProfileVisibility.nobody)
    ProfileVisibility mutualServersVisibility,
    @Default(ProfileVisibility.nobody)
    @JsonKey(unknownEnumValue: ProfileVisibility.nobody)
    ProfileVisibility mutualFriendsVisibility,
    @Default(ProfileVisibility.nobody)
    @JsonKey(unknownEnumValue: ProfileVisibility.nobody)
    ProfileVisibility connectionsVisibility,
    @Default(ProfileVisibility.nobody)
    @JsonKey(unknownEnumValue: ProfileVisibility.nobody)
    ProfileVisibility birthdayVisibility,

    // Presence and activity.
    @Default(false) bool shareActivity,
    @Default(false) bool allowPositionalVoiceCapture,

    // Messaging behaviour.
    @Default(false) bool sendReadReceipts,
    @Default(false) bool sendTypingIndicators,

    /// `null` keeps messages forever. Applies only to messages *you* sent.
    int? dmRetentionDays,

    // Safety.
    @Default(ExplicitContentFilter.unknownSenders)
    @JsonKey(unknownEnumValue: ExplicitContentFilter.unknownSenders)
    ExplicitContentFilter explicitContentFilter,

    // Push.
    @Default(true) bool hidePushContent,

    /// Bumped by the server on every write. Only carried so a stale response
    /// arriving after a newer one can be recognised, never rendered.
    @Default(0) int version,

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
    @Default(false) bool isMinor,
  }) = _PrivacySettingsDto;

  factory PrivacySettingsDto.fromJson(Map<String, dynamic> json) =>
      _$PrivacySettingsDtoFromJson(json);
}

extension PrivacySettingsDtoX on PrivacySettingsDto {
  /// The floors from T1-11, evaluated client-side purely for presentation.
  ///
  /// The server is the enforcement point and refuses a write that breaches one
  /// with `403 minor_restriction` whatever this says - see `privacyRefusalOf`.
  /// This exists only so the screen can grey the control out and explain
  /// itself, instead of offering a switch that always bounces back.
  bool lockedForMinor(String field) {
    if (!isMinor) return false;
    return const {
      'allowPersonalization',
      'discoverableByEmail',
      'discoverableByPhone',
      'allowVoiceRecordingInClips',
      // `Everyone` is refused; the rest of the scale stays available, so the
      // control is shown enabled and the option itself is what's withheld.
      'directMessagePolicy',
      'explicitContentFilter',
    }.contains(field);
  }
}
