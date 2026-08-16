import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';

part 'voice_ring_dto.freezed.dart';
part 'voice_ring_dto.g.dart';

/// Where a ring is in its 60-second life.
///
/// `Pending` is the only non-terminal one, and exactly one transition out of it
/// ever happens - decided server-side under a lock, whoever races for it.
enum VoiceRingStatus {
  @JsonValue('Pending')
  pending,
  @JsonValue('Accepted')
  accepted,
  @JsonValue('Declined')
  declined,
  @JsonValue('Cancelled')
  cancelled,
  @JsonValue('Expired')
  expired,
  unknown,
}

/// Why a ring stopped being pending, when the status alone does not say.
///
/// One event carries every ending rather than one event name per ending, so a
/// client that meets a reason it has never heard of can always fall back on the
/// status. That is what [unknown] is for - it is a fallback, not a state.
enum VoiceRingReason {
  /// The inviter pressed cancel.
  @JsonValue('InviterCancelled')
  inviterCancelled,

  /// The inviter left the voice channel. The invitation said "come and join
  /// me", and they are no longer there for it to be true.
  @JsonValue('InviterLeft')
  inviterLeft,

  /// The same inviter rang you into a different channel. One person cannot hold
  /// you to two invitations at once, so the older gives way.
  @JsonValue('Superseded')
  superseded,

  /// You joined that channel by ordinary means. Not an accept - you may never
  /// have seen the card.
  @JsonValue('TargetJoined')
  targetJoined,

  /// The channel was deleted, stopped being voice, or you lost access to it.
  @JsonValue('ChannelGone')
  channelGone,

  /// Nobody answered inside 60 seconds.
  @JsonValue('TimedOut')
  timedOut,

  unknown,
}

/// How hard to knock, sent as `delivery` on the send.
///
/// The server defaults to [both] for the sake of clients that predate the
/// field. This client always says which it wants: a request that spells out
/// what it means does not quietly change meaning if that default ever does.
enum VoiceRingDelivery {
  /// The invitation goes in the DM and nowhere else. Nothing rings, nothing
  /// expires, and there is no ring id to accept, decline or cancel - the card
  /// in the conversation is the whole of it.
  message('Message'),

  /// The ephemeral ring alone, leaving no record once it lapses.
  ring('Ring'),

  /// The ring now, and the card that outlives it.
  both('Both');

  const VoiceRingDelivery(this.wire);

  /// Sent as-is. Not a [JsonValue] because this is only ever written, never
  /// parsed - no response carries it back.
  final String wire;
}

/// Why sending a ring or an invitation was refused.
///
/// Note what is **not** here: there is no "blocked". A block in either direction
/// comes back as [unavailable], deliberately indistinguishable from every other
/// reason this person cannot be reached, because naming it would turn the
/// endpoint into a block detector.
enum VoiceRingRefusal {
  @JsonValue('TargetCannotJoinChannel')
  targetCannotJoinChannel,
  @JsonValue('Unavailable')
  unavailable,
  @JsonValue('TargetAlreadyInChannel')
  targetAlreadyInChannel,

  /// This person turned you down recently. `retryAfterSeconds` can be up to 24
  /// hours.
  @JsonValue('RecentlyDeclined')
  recentlyDeclined,

  /// You have sent too many rings - 6 in 5 minutes, to anybody.
  @JsonValue('InviterFlooding')
  inviterFlooding,

  /// They have been rung too many times by too many people - 4 in 5 minutes.
  /// Not your fault and still your `429`.
  @JsonValue('TargetSaturated')
  targetSaturated,

  /// **Only a [VoiceRingDelivery.message] invitation can meet this**, and it
  /// meets it often: the recipient does not accept direct messages from this
  /// sender, and the product default is friends-only while two people sharing a
  /// server are frequently not friends.
  ///
  /// A ring never has this failure, because a ring does not need a conversation
  /// - it is delivered to their devices, not into a DM.
  @JsonValue('RecipientPolicy')
  recipientPolicy,
  unknown,
}

/// A ring as an HTTP caller sees it.
@freezed
sealed class VoiceRingDto with _$VoiceRingDto {
  @ApiDateTimeConverter()
  const factory VoiceRingDto({
    required String ringId,
    required String guildId,
    required String channelId,

    /// Null on the response to your own send - you sent it, you know the
    /// channel. Populated on the catch-up read and on the realtime event, where
    /// the reader may not.
    String? channelName,
    required String inviterId,
    required String targetUserId,
    @JsonKey(unknownEnumValue: VoiceRingStatus.unknown)
    @Default(VoiceRingStatus.pending)
    VoiceRingStatus status,
    @JsonKey(unknownEnumValue: VoiceRingReason.unknown) VoiceRingReason? reason,
    DateTime? createdAt,
    DateTime? expiresAt,

    /// **Count down from this, not from [expiresAt].** A handset whose clock is
    /// a few minutes out is ordinary rather than exotic, and trusting an
    /// absolute deadline there draws an invitation that is already dead or one
    /// that never lapses.
    @Default(0) int expiresInSeconds,

    /// The device that answered, or null for a resolution nobody pressed a
    /// button for. If it is this device, it already knows.
    String? resolvedByDeviceId,
  }) = _VoiceRingDto;

  factory VoiceRingDto.fromJson(Map<String, dynamic> json) =>
      _$VoiceRingDtoFromJson(json);
}

/// The answer to a [VoiceRingDelivery.message] invitation.
///
/// **Deliberately not a [VoiceRingDto].** No ring is created, so there is no id
/// to accept or cancel, no status to watch and no instant to count down to -
/// there is nothing for the ring cubit to hold and nothing for its ticker to
/// tick. What comes back is where the card landed, which may be a conversation
/// that did not exist a moment ago.
@freezed
sealed class VoiceInviteSentDto with _$VoiceInviteSentDto {
  const factory VoiceInviteSentDto({@Default('') String conversationId}) =
      _VoiceInviteSentDto;

  factory VoiceInviteSentDto.fromJson(Map<String, dynamic> json) =>
      _$VoiceInviteSentDtoFromJson(json);
}

/// The one shape every refusal uses. `retryAfterSeconds` is zero for anything
/// waiting will not fix.
@freezed
sealed class VoiceRingRefusalDto with _$VoiceRingRefusalDto {
  const factory VoiceRingRefusalDto({
    @JsonKey(unknownEnumValue: VoiceRingRefusal.unknown)
    @Default(VoiceRingRefusal.unknown)
    VoiceRingRefusal reason,
    @Default(0) int retryAfterSeconds,
  }) = _VoiceRingRefusalDto;

  factory VoiceRingRefusalDto.fromJson(Map<String, dynamic> json) =>
      _$VoiceRingRefusalDtoFromJson(json);
}

/// `guild.VoiceRingIncoming` and `guild.VoiceRingSent` - the same payload, and
/// which of the two you get says whether you are being asked or have asked.
@freezed
sealed class VoiceRingInvitationDto with _$VoiceRingInvitationDto {
  @ApiDateTimeConverter()
  const factory VoiceRingInvitationDto({
    required String ringId,
    required String guildId,
    required String channelId,
    String? channelName,
    required String inviterId,

    /// Can be null if the profile lookup failed. [inviterId] never is - resolve
    /// the person from that rather than trusting the frozen copy.
    String? inviterName,
    String? inviterAvatarUrl,
    required String targetUserId,
    DateTime? createdAt,
    DateTime? expiresAt,
    @Default(0) int expiresInSeconds,

    /// Who is already in the channel, so the card can show faces. Safe to
    /// render: the server only sends this ring to somebody who has `ViewChannel`
    /// on the channel.
    @Default(<String>[]) List<String> participantUserIds,
  }) = _VoiceRingInvitationDto;

  factory VoiceRingInvitationDto.fromJson(Map<String, dynamic> json) =>
      _$VoiceRingInvitationDtoFromJson(json);
}

/// `guild.VoiceRingResolved` - one event for every way a ring ends.
@freezed
sealed class VoiceRingResolvedDto with _$VoiceRingResolvedDto {
  @ApiDateTimeConverter()
  const factory VoiceRingResolvedDto({
    required String ringId,
    required String guildId,
    required String channelId,
    required String inviterId,
    required String targetUserId,
    @JsonKey(unknownEnumValue: VoiceRingStatus.unknown)
    @Default(VoiceRingStatus.unknown)
    VoiceRingStatus status,
    @JsonKey(unknownEnumValue: VoiceRingReason.unknown) VoiceRingReason? reason,
    DateTime? resolvedAt,
    String? resolvedByDeviceId,
  }) = _VoiceRingResolvedDto;

  factory VoiceRingResolvedDto.fromJson(Map<String, dynamic> json) =>
      _$VoiceRingResolvedDtoFromJson(json);
}

/// `guild.VoiceRingDismissed` - addressed to exactly one device of the target.
///
/// Sent when a device answers a ring that was already resolved, typically a
/// laptop a second after the phone. The ring itself is untouched: the user has
/// already answered it somewhere else, and this device only needs to know.
///
/// There is no takeover event to pair with this. A ring holds no media session
/// and no roster slot, so a superseded device has nothing to tear down.
@freezed
sealed class VoiceRingDismissedDto with _$VoiceRingDismissedDto {
  const factory VoiceRingDismissedDto({
    required String ringId,
    required String deviceId,
    @JsonKey(unknownEnumValue: VoiceRingStatus.unknown)
    @Default(VoiceRingStatus.unknown)
    VoiceRingStatus status,
    @JsonKey(unknownEnumValue: VoiceRingReason.unknown) VoiceRingReason? reason,
  }) = _VoiceRingDismissedDto;

  factory VoiceRingDismissedDto.fromJson(Map<String, dynamic> json) =>
      _$VoiceRingDismissedDtoFromJson(json);
}

extension VoiceRingReasonX on VoiceRingReason? {
  /// What the target is told when the card comes down for a reason worth
  /// naming, or null when it should simply close.
  ///
  /// Most endings are silent on purpose. A decline needs no confirmation - the
  /// user knows what they pressed - and an expiry needs none either, because
  /// nothing happened.
  String? get targetNotice => switch (this) {
    VoiceRingReason.inviterLeft => 'They left the channel.',
    VoiceRingReason.channelGone => 'That channel is no longer available.',
    _ => null,
  };
}

extension VoiceRingRefusalX on VoiceRingRefusal {
  /// What to show the inviter, in their words rather than the wire's.
  String get message => switch (this) {
    VoiceRingRefusal.targetCannotJoinChannel =>
      'They do not have access to this channel.',

    // Deliberately not "you are blocked". The server does not say which
    // direction a block runs in, or whether a block is what this is at all,
    // and inventing the specific reason here would give away exactly what it
    // withheld.
    VoiceRingRefusal.unavailable => 'You cannot invite this person.',

    VoiceRingRefusal.targetAlreadyInChannel => 'They are already in here.',

    // No countdown: `retryAfterSeconds` can be 24 hours, and "later" is kinder
    // than a timer and just as true.
    VoiceRingRefusal.recentlyDeclined =>
      'They declined an invitation recently. You can try again later.',

    VoiceRingRefusal.inviterFlooding =>
      'You have sent a lot of invitations just now. Try again shortly.',
    VoiceRingRefusal.targetSaturated =>
      'They have had a lot of invitations just now.',

    // Their setting rather than ours, and worth saying plainly: it is the one
    // refusal the sender can do something about, by becoming a friend. Waiting
    // will not fix it, so there is no "try again later" here.
    VoiceRingRefusal.recipientPolicy => 'They do not accept messages from you.',

    VoiceRingRefusal.unknown => 'Could not send that invitation.',
  };
}
