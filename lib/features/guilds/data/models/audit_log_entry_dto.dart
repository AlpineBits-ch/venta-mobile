import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';

part 'audit_log_entry_dto.freezed.dart';
part 'audit_log_entry_dto.g.dart';

/// Full list confirmed against `Guild.Domain.Enums.AuditActionType` (40
/// values as of 2026-07-30) - some (`InviteCreated`/`InviteDeleted`) are
/// declared server-side but never actually emitted yet, so they just won't
/// appear in practice.
///
/// Serialized as strings: `Guild.Application`'s `AddControllers().AddJsonOptions`
/// registers a `JsonStringEnumConverter`, so these `@JsonValue`s must match
/// the C# member names exactly. Anything unmatched lands on [unknown], and
/// `AuditLogEntryDto.rawActionType` preserves the original string so the UI
/// can still name it.
enum AuditActionType {
  @JsonValue('MemberBanned')
  memberBanned,
  @JsonValue('MemberUnbanned')
  memberUnbanned,
  @JsonValue('MemberKicked')
  memberKicked,
  @JsonValue('MemberMuted')
  memberMuted,
  @JsonValue('MemberUnmuted')
  memberUnmuted,
  @JsonValue('MemberLeft')
  memberLeft,
  @JsonValue('RoleCreated')
  roleCreated,
  @JsonValue('RoleUpdated')
  roleUpdated,
  @JsonValue('RoleDeleted')
  roleDeleted,
  @JsonValue('RolePositionsChanged')
  rolePositionsChanged,
  @JsonValue('ChannelCreated')
  channelCreated,
  @JsonValue('ChannelDeleted')
  channelDeleted,
  @JsonValue('ChannelUpdated')
  channelUpdated,
  @JsonValue('ChannelPermissionChanged')
  channelPermissionChanged,
  @JsonValue('CategoryCreated')
  categoryCreated,
  @JsonValue('CategoryDeleted')
  categoryDeleted,
  @JsonValue('CategoryUpdated')
  categoryUpdated,
  @JsonValue('GuildUpdated')
  guildUpdated,
  @JsonValue('GuildDeleted')
  guildDeleted,
  @JsonValue('InviteCreated')
  inviteCreated,
  @JsonValue('InviteDeleted')
  inviteDeleted,
  @JsonValue('BotInstalled')
  botInstalled,
  @JsonValue('BotUninstalled')
  botUninstalled,
  @JsonValue('GuildImportedFromDiscord')
  guildImportedFromDiscord,
  @JsonValue('GuildSyncedFromDiscord')
  guildSyncedFromDiscord,
  @JsonValue('MessagePinned')
  messagePinned,
  @JsonValue('MessageUnpinned')
  messageUnpinned,
  @JsonValue('EmojiCreated')
  emojiCreated,
  @JsonValue('EmojiDeleted')
  emojiDeleted,
  @JsonValue('AutoModConfigUpdated')
  autoModConfigUpdated,
  @JsonValue('AutoModMessageBlocked')
  autoModMessageBlocked,
  @JsonValue('OnboardingConfigUpdated')
  onboardingConfigUpdated,
  @JsonValue('ScheduledEventCreated')
  scheduledEventCreated,
  @JsonValue('ScheduledEventUpdated')
  scheduledEventUpdated,
  @JsonValue('ScheduledEventCancelled')
  scheduledEventCancelled,
  @JsonValue('ScheduledEventDeleted')
  scheduledEventDeleted,
  @JsonValue('TemplateCreated')
  templateCreated,
  @JsonValue('GuildCreatedFromTemplate')
  guildCreatedFromTemplate,
  @JsonValue('ChannelFollowCreated')
  channelFollowCreated,
  @JsonValue('ChannelFollowRemoved')
  channelFollowRemoved,
  unknown,
}

@freezed
sealed class AuditLogEntryDto with _$AuditLogEntryDto {
  @ApiDateTimeConverter()
  const factory AuditLogEntryDto({
    required String id,
    required String guildId,
    required String actorUserId,
    @JsonKey(unknownEnumValue: AuditActionType.unknown)
    required AuditActionType actionType,

    /// The server's raw `actionType` string, kept alongside the parsed enum.
    ///
    /// `unknownEnumValue` throws away what it couldn't match, so every action
    /// this client doesn't know about collapsed into a single indistinguishable
    /// [AuditActionType.unknown] - and the log rendered "did something" for all
    /// of them. Holding the original string lets the UI still say *which*
    /// action it was, and means server-side additions degrade to a readable
    /// label instead of requiring a client release to be legible at all.
    @JsonKey(name: 'actionType', includeToJson: false)
    @Default('')
    String rawActionType,
    String? targetId,

    /// Raw JSON string, shape varies per [actionType] - parsed defensively.
    String? metadata,
    DateTime? createdAt,
  }) = _AuditLogEntryDto;

  factory AuditLogEntryDto.fromJson(Map<String, dynamic> json) =>
      _$AuditLogEntryDtoFromJson(json);
}
