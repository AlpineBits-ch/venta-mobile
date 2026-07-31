import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';

part 'mls_dtos.freezed.dart';
part 'mls_dtos.g.dart';

/// Wire shapes for the server's MLS transport, matching Alpine's `mls.dto.ts`.
///
/// A *context* is a conversation or a guild channel. Both carry MLS groups and
/// the endpoints are symmetric apart from who is allowed to call them, so
/// nothing below distinguishes the two - `isChannel` only ever picks a URL.
///
/// Every field the server models as `byte[]` is a base64 `String` here, which is
/// exactly what `System.Text.Json` puts on the wire and exactly what the engine
/// wants back.

/// One Welcome addressed to one device. Travels with the commit that adds that
/// device, so a device can never hold a leaf whose Welcome was lost on the way.
@freezed
sealed class DeviceWelcomeDto with _$DeviceWelcomeDto {
  const factory DeviceWelcomeDto({
    required String deviceId,
    required String userId,

    /// Base64 TLS-serialized MLS Welcome.
    required String welcome,
  }) = _DeviceWelcomeDto;

  factory DeviceWelcomeDto.fromJson(Map<String, dynamic> json) =>
      _$DeviceWelcomeDtoFromJson(json);
}

@freezed
sealed class PendingWelcomeDto with _$PendingWelcomeDto {
  @ApiDateTimeConverter()
  const factory PendingWelcomeDto({
    required String id,
    required String contextId,
    String? conversationId,
    String? channelId,
    required String userId,
    required String deviceId,
    required String welcome,

    /// Which encryption era of the context this Welcome admits us to.
    required int generation,

    /// Epoch the joining device lands on - where its commit catch-up starts.
    required int epoch,
    DateTime? consumedAt,
    DateTime? createdAt,
  }) = _PendingWelcomeDto;

  factory PendingWelcomeDto.fromJson(Map<String, dynamic> json) =>
      _$PendingWelcomeDtoFromJson(json);

  const PendingWelcomeDto._();

  bool get isChannel => channelId != null && channelId!.isNotEmpty;
}

@freezed
sealed class MlsCommitDto with _$MlsCommitDto {
  @ApiDateTimeConverter()
  const factory MlsCommitDto({
    required String id,
    required String contextId,
    String? conversationId,
    String? channelId,
    required int generation,

    /// Group epoch *after* this commit is applied.
    required int epoch,
    required String commit,
    required String senderUserId,
    required String senderDeviceId,
    DateTime? createdAt,
  }) = _MlsCommitDto;

  factory MlsCommitDto.fromJson(Map<String, dynamic> json) =>
      _$MlsCommitDtoFromJson(json);
}

@freezed
sealed class PublishMlsCommitDto with _$PublishMlsCommitDto {
  const factory PublishMlsCommitDto({
    required int epoch,
    required String commit,
    required String senderDeviceId,

    /// Always sent. Omitting it makes the server assume the live generation,
    /// which is exactly wrong if encryption was toggled while we were building.
    int? generation,

    /// Refreshed GroupInfo so a device that falls too far behind can rejoin by
    /// external commit.
    String? groupInfo,
    @Default(<DeviceWelcomeDto>[]) List<DeviceWelcomeDto> welcomes,

    /// Join requests this commit admits. The server closes them only once the
    /// commit lands, never on approval - an approval that never produced a
    /// commit must leave the request open for someone else to act on.
    @Default(<String>[]) List<String> fulfilledJoinRequestIds,
  }) = _PublishMlsCommitDto;

  factory PublishMlsCommitDto.fromJson(Map<String, dynamic> json) =>
      _$PublishMlsCommitDtoFromJson(json);
}

@freezed
sealed class MlsCommitPublishedDto with _$MlsCommitPublishedDto {
  const factory MlsCommitPublishedDto({
    required String contextId,
    String? conversationId,
    required int generation,
    required int epoch,
  }) = _MlsCommitPublishedDto;

  factory MlsCommitPublishedDto.fromJson(Map<String, dynamic> json) =>
      _$MlsCommitPublishedDtoFromJson(json);
}

enum MlsGenerationState {
  @JsonValue('Active')
  active,
  @JsonValue('Terminated')
  terminated,
}

@freezed
sealed class MlsGenerationDto with _$MlsGenerationDto {
  @ApiDateTimeConverter()
  const factory MlsGenerationDto({
    required String id,
    required String contextId,
    required int generation,
    String? mlsGroupId,
    String? mlsGroupInfo,
    required int epoch,
    @JsonKey(unknownEnumValue: MlsGenerationState.active)
    required MlsGenerationState state,
    DateTime? activatedAt,
    String? activatedByUserId,
    DateTime? terminatedAt,
    String? terminatedByUserId,
  }) = _MlsGenerationDto;

  factory MlsGenerationDto.fromJson(Map<String, dynamic> json) =>
      _$MlsGenerationDtoFromJson(json);
}

@freezed
sealed class MlsContextStateDto with _$MlsContextStateDto {
  const factory MlsContextStateDto({
    required String contextId,
    @Default(false) bool encrypted,
    int? activeGeneration,
    int? epoch,
    String? mlsGroupId,
    String? mlsGroupInfo,

    /// Every era the context has had, oldest first - including terminated ones,
    /// whose messages are still in the history. Without them, a stretch we
    /// cannot decrypt is indistinguishable from corruption.
    @Default(<MlsGenerationDto>[]) List<MlsGenerationDto> generations,
  }) = _MlsContextStateDto;

  factory MlsContextStateDto.fromJson(Map<String, dynamic> json) =>
      _$MlsContextStateDtoFromJson(json);

  const MlsContextStateDto._();

  /// Past eras whose messages are still in the timeline. What the settings
  /// screen counts when it explains unreadable history.
  int get terminatedGenerationCount =>
      generations.where((g) => g.state == MlsGenerationState.terminated).length;
}

@freezed
sealed class EnableMlsDto with _$EnableMlsDto {
  const factory EnableMlsDto({
    required String mlsGroupId,
    required int epoch,
    String? mlsGroupInfo,
    @Default(<DeviceWelcomeDto>[]) List<DeviceWelcomeDto> welcomes,
  }) = _EnableMlsDto;

  factory EnableMlsDto.fromJson(Map<String, dynamic> json) =>
      _$EnableMlsDtoFromJson(json);
}

@freezed
sealed class MlsToggleResultDto with _$MlsToggleResultDto {
  const factory MlsToggleResultDto({
    required String contextId,
    @Default(false) bool encrypted,
    int? generation,

    /// Set on disable: messages from this era stay ciphertext, readable only by
    /// devices that still hold that group's keys.
    int? terminatedGeneration,
    @Default(false) bool alreadyInRequestedState,
  }) = _MlsToggleResultDto;

  factory MlsToggleResultDto.fromJson(Map<String, dynamic> json) =>
      _$MlsToggleResultDtoFromJson(json);
}

/// 409 body when a commit is out of step with the group.
@freezed
sealed class MlsEpochConflictDto with _$MlsEpochConflictDto {
  const factory MlsEpochConflictDto({
    @Default(0) int currentEpoch,
    @Default(0) int rejectedEpoch,
    @Default(0) int currentGeneration,
    @Default(0) int rejectedGeneration,
    @Default('') String reason,
  }) = _MlsEpochConflictDto;

  factory MlsEpochConflictDto.fromJson(Map<String, dynamic> json) =>
      _$MlsEpochConflictDtoFromJson(json);
}

/// 409 body when a toggle is refused - already in that state, or still inside
/// the server's 30-second cooldown.
@freezed
sealed class MlsToggleConflictDto with _$MlsToggleConflictDto {
  const factory MlsToggleConflictDto({
    @Default('') String contextId,
    @Default(false) bool encrypted,
    @Default('') String reason,
    int? retryAfterSeconds,
  }) = _MlsToggleConflictDto;

  factory MlsToggleConflictDto.fromJson(Map<String, dynamic> json) =>
      _$MlsToggleConflictDtoFromJson(json);
}

@freezed
sealed class AckWelcomesResultDto with _$AckWelcomesResultDto {
  const factory AckWelcomesResultDto({@Default(0) int acknowledged}) =
      _AckWelcomesResultDto;

  factory AckWelcomesResultDto.fromJson(Map<String, dynamic> json) =>
      _$AckWelcomesResultDtoFromJson(json);
}

/// A consumed key package for one of an invitee's devices.
@freezed
sealed class MlsDeviceTokenDto with _$MlsDeviceTokenDto {
  const factory MlsDeviceTokenDto({
    required String deviceId,
    required String userId,
    required String token,
  }) = _MlsDeviceTokenDto;

  factory MlsDeviceTokenDto.fromJson(Map<String, dynamic> json) =>
      _$MlsDeviceTokenDtoFromJson(json);
}

/// A device with no key package left. It was not added to the group and will
/// never be able to read the context, so callers surface these rather than
/// reporting a clean success.
@freezed
sealed class UnreachableDeviceDto with _$UnreachableDeviceDto {
  const factory UnreachableDeviceDto({
    required String userId,
    required String deviceId,
    String? deviceName,
  }) = _UnreachableDeviceDto;

  factory UnreachableDeviceDto.fromJson(Map<String, dynamic> json) =>
      _$UnreachableDeviceDtoFromJson(json);
}

@freezed
sealed class ConsumeTokensResultDto with _$ConsumeTokensResultDto {
  const factory ConsumeTokensResultDto({
    @Default(<MlsDeviceTokenDto>[]) List<MlsDeviceTokenDto> deviceTokens,
    @Default(<UnreachableDeviceDto>[])
    List<UnreachableDeviceDto> unreachableDevices,
  }) = _ConsumeTokensResultDto;

  factory ConsumeTokensResultDto.fromJson(Map<String, dynamic> json) =>
      _$ConsumeTokensResultDtoFromJson(json);
}

enum MlsJoinRequestState {
  @JsonValue('Pending')
  pending,
  @JsonValue('Denied')
  denied,
  @JsonValue('Fulfilled')
  fulfilled,
  @JsonValue('Cancelled')
  cancelled,
}

/// A device asking to be let into an encrypted context.
///
/// The server cannot admit anyone - it holds no group keys, so only a current
/// member can produce an Add commit. Admission is therefore a request that
/// members review, and the approval that meets the threshold is what makes that
/// member's client mint the Welcome.
@freezed
sealed class MlsJoinRequestDto with _$MlsJoinRequestDto {
  @ApiDateTimeConverter()
  const factory MlsJoinRequestDto({
    required String id,
    required String contextId,
    String? channelId,
    String? conversationId,
    required int generation,
    required String requesterUserId,

    /// Admission is per device, not per user - each device holds its own leaf,
    /// so a user's second device needs its own request.
    required String requesterDeviceId,

    /// SHA-256 of the key package that would be added.
    required String keyPackageHash,

    /// The requester's long-lived identity fingerprint, for out-of-band
    /// comparison. Stable across all their key packages, which is what makes it
    /// readable aloud - a key-package hash changes on every request.
    required String signatureKeyFingerprint,
    @JsonKey(unknownEnumValue: MlsJoinRequestState.pending)
    required MlsJoinRequestState state,
    DateTime? createdAt,
    DateTime? expiresAt,
    @Default(0) int requiredApprovals,

    /// Who has already vouched. Lets a reviewer see they have approved, and see
    /// who else did - a second opinion is only worth something if you can tell
    /// whose it was.
    @Default(<String>[]) List<String> approverUserIds,
  }) = _MlsJoinRequestDto;

  factory MlsJoinRequestDto.fromJson(Map<String, dynamic> json) =>
      _$MlsJoinRequestDtoFromJson(json);
}

@freezed
sealed class MlsJoinRequestApprovalResultDto
    with _$MlsJoinRequestApprovalResultDto {
  const factory MlsJoinRequestApprovalResultDto({
    required String requestId,
    @Default(0) int approvals,
    @Default(0) int requiredApprovals,

    /// True when this approval completed the threshold and the caller should now
    /// mint the Add commit.
    @Default(false) bool thresholdMet,

    /// The exact bytes to add. Present only once [thresholdMet].
    String? keyPackage,
    @Default('') String keyPackageHash,
    @Default(0) int generation,
  }) = _MlsJoinRequestApprovalResultDto;

  factory MlsJoinRequestApprovalResultDto.fromJson(Map<String, dynamic> json) =>
      _$MlsJoinRequestApprovalResultDtoFromJson(json);
}

/// How many key packages this device should generate and upload. Returned by
/// the one call every client makes on launch, which doubles as the server's
/// housekeeping hook.
@freezed
sealed class GenerateKeyPackagesDto with _$GenerateKeyPackagesDto {
  const factory GenerateKeyPackagesDto({
    @Default(0) int count,

    /// True when the server holds no last-resort package for this device. That
    /// package is the floor that keeps a device addable after its single-use
    /// supply runs dry - without one it is silently left out of new groups.
    @Default(false) bool needsLastResort,
  }) = _GenerateKeyPackagesDto;

  factory GenerateKeyPackagesDto.fromJson(Map<String, dynamic> json) =>
      _$GenerateKeyPackagesDtoFromJson(json);
}
