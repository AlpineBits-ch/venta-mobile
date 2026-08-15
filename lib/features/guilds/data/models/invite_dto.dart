import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';
import 'guild_dto.dart';
import 'welcome_screen_dto.dart';

part 'invite_dto.freezed.dart';
part 'invite_dto.g.dart';

enum InviteType {
  @JsonValue('OneTime')
  oneTime,
  @JsonValue('Permanent')
  permanent,

  /// A kind this build has never heard of. Present for the same reason
  /// [InviteState.unknown] is: `$enumDecode` throws rather than degrades, and
  /// one unrecognised value on one row fails the whole list.
  unknown,
}

/// Where an invite is in its life, **as the server computed it**.
///
/// Every read path derives this now - `Revoked` if it was withdrawn, `Expired`
/// if it lapsed or ran out of uses, `Active` otherwise. Both clients used to
/// re-derive expiry from `expiresAt < now` because nothing ever wrote `Expired`
/// to the row; that derivation is gone, and this field is the single answer.
/// The one case it could never have got right is a consumed one-time invite,
/// which has no `maxUses` to compare against.
enum InviteState {
  @JsonValue('Active')
  active,
  @JsonValue('Expired')
  expired,

  /// Taken away by a moderator. Terminal, and distinct from [expired]: one is
  /// a link that ran its course, the other is a link somebody withdrew.
  @JsonValue('Revoked')
  revoked,

  /// A state this build has never heard of.
  ///
  /// This member is load-bearing rather than defensive-by-habit. `Revoked` was
  /// added to an existing field, and without an `unknownEnumValue` fallback the
  /// generated `$enumDecode` throws on it - which fails `InviteDto.fromJson`,
  /// which fails the whole invite list, which renders as "Could not load
  /// invites." with nothing to say why. A value added after this release must
  /// cost one unlabelled row, not the screen.
  unknown,
}

/// What an invite is an invite *to*, beyond the guild itself.
enum InviteTargetType {
  @JsonValue('None')
  none,
  @JsonValue('VoiceChannel')
  voiceChannel,
  unknown,
}

@freezed
sealed class InviteDto with _$InviteDto {
  @ApiDateTimeConverter()
  const factory InviteDto({
    required String id,
    @JsonKey(unknownEnumValue: InviteType.unknown)
    required InviteType type,
    @JsonKey(unknownEnumValue: InviteState.unknown)
    required InviteState state,
    required String guildId,
    GuildDto? guild,
    required String code,
    DateTime? expiresAt,
    int? maxUses,
    @Default(0) int useCount,

    /// The channel a joiner lands on. Advisory unless [targetType] says
    /// otherwise - and also what decides whether a channel moderator may
    /// revoke this invite, so it is read by the settings screen's gating.
    String? channelId,

    /// Who created it, as a **user id**. Guild does not own usernames or
    /// avatars, so this resolves through the same profile cache message
    /// authors do. Null for every invite minted before attribution existed and
    /// for anything a system path created.
    String? inviterId,

    /// The membership this invite grants ends when the member goes offline,
    /// unless they are given a role.
    @Default(false) bool temporary,
    @JsonKey(unknownEnumValue: InviteTargetType.unknown)
    @Default(InviteTargetType.none)
    InviteTargetType targetType,
    String? targetUserId,
    DateTime? revokedAt,

    /// The guild's welcome splash, present only when it has one and it's
    /// enabled. Carried inline here because the dedicated welcome-screen
    /// endpoint is members-only and whoever is looking at an invite isn't one
    /// yet.
    WelcomeScreenDto? welcomeScreen,
  }) = _InviteDto;

  factory InviteDto.fromJson(Map<String, dynamic> json) =>
      _$InviteDtoFromJson(json);
}

/// The body `POST /invites/{id}/redeem` now answers its `202` with.
///
/// Every field is additive - the route used to answer `Accepted()` with nothing
/// at all - so a parse failure here must never cost the join that already
/// happened. See [RedeemResultDto.fromResponse].
@freezed
sealed class RedeemResultDto with _$RedeemResultDto {
  const factory RedeemResultDto({
    required String guildId,
    String? channelId,
    @JsonKey(unknownEnumValue: InviteTargetType.unknown)
    @Default(InviteTargetType.none)
    InviteTargetType targetType,
    String? targetUserId,

    /// Connect to [channelId] as voice after joining.
    ///
    /// **Use this, not [targetType].** It is false when the target channel has
    /// been deleted or has stopped being a voice channel since the link was
    /// made. The join still succeeds in that case and only the landing is
    /// dropped, so deriving "should I connect" from [targetType] means trying
    /// to join a room that is not there.
    @Default(false) bool joinVoice,

    /// The guild gates new members behind a rules screen.
    @Default(false) bool onboardingRequired,

    /// The membership ends when this account goes offline, unless it is given
    /// a role. Worth a line of UI at join time: a member who is not told will
    /// simply find themselves gone.
    @Default(false) bool temporaryMembership,
  }) = _RedeemResultDto;

  factory RedeemResultDto.fromJson(Map<String, dynamic> json) =>
      _$RedeemResultDtoFromJson(json);
}

extension InviteStateX on InviteState {
  /// Whether this link still admits anybody.
  bool get isUsable => this == InviteState.active;

  /// One word for the badge, or null for an [InviteState.active] invite, which
  /// wants no badge at all.
  ///
  /// **Revoked and expired read differently on purpose.** One is a link that
  /// ran its course and one is a link somebody took away, and an owner looking
  /// at an audit list wants to know which. A state this build has never heard of
  /// gets a neutral word rather than being folded into either.
  String? get badgeLabel => switch (this) {
    InviteState.active => null,
    InviteState.expired => 'Expired',
    InviteState.revoked => 'Revoked',
    InviteState.unknown => 'Inactive',
  };
}

extension InviteDtoX on InviteDto {
  /// Whether a channel moderator could revoke this without `ManageGuild`.
  ///
  /// `DELETE /invites/{id}` takes `ManageGuild` anywhere in the guild **or**
  /// `ManageChannel` on the specific channel the invite lands on - the second
  /// being how a moderator withdraws a link into their own channel without
  /// being handed the guild. An invite naming no channel therefore has no
  /// channel to hold `ManageChannel` on, and only `ManageGuild` will do.
  bool get isRevocableByChannelModerator =>
      channelId != null && channelId!.isNotEmpty;
}
