import 'package:freezed_annotation/freezed_annotation.dart';

part 'audit_log_entry_dto.freezed.dart';
part 'audit_log_entry_dto.g.dart';

/// Full list confirmed against `Guild.Domain.Enums.AuditActionType` - some
/// values (`InviteCreated`/`InviteDeleted`) are declared server-side but
/// never actually emitted yet, so they just won't appear in practice.
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
  unknown,
}

@freezed
sealed class AuditLogEntryDto with _$AuditLogEntryDto {
  const factory AuditLogEntryDto({
    required String id,
    required String guildId,
    required String actorUserId,
    @JsonKey(unknownEnumValue: AuditActionType.unknown)
    required AuditActionType actionType,
    String? targetId,

    /// Raw JSON string, shape varies per [actionType] - parsed defensively.
    String? metadata,
    DateTime? createdAt,
  }) = _AuditLogEntryDto;

  factory AuditLogEntryDto.fromJson(Map<String, dynamic> json) =>
      _$AuditLogEntryDtoFromJson(json);
}
