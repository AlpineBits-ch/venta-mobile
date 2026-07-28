// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log_entry_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuditLogEntryDto _$AuditLogEntryDtoFromJson(Map<String, dynamic> json) =>
    _AuditLogEntryDto(
      id: json['id'] as String,
      guildId: json['guildId'] as String,
      actorUserId: json['actorUserId'] as String,
      actionType: $enumDecode(
        _$AuditActionTypeEnumMap,
        json['actionType'],
        unknownValue: AuditActionType.unknown,
      ),
      targetId: json['targetId'] as String?,
      metadata: json['metadata'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AuditLogEntryDtoToJson(_AuditLogEntryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'guildId': instance.guildId,
      'actorUserId': instance.actorUserId,
      'actionType': _$AuditActionTypeEnumMap[instance.actionType]!,
      'targetId': instance.targetId,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$AuditActionTypeEnumMap = {
  AuditActionType.memberBanned: 'MemberBanned',
  AuditActionType.memberUnbanned: 'MemberUnbanned',
  AuditActionType.memberKicked: 'MemberKicked',
  AuditActionType.memberMuted: 'MemberMuted',
  AuditActionType.memberUnmuted: 'MemberUnmuted',
  AuditActionType.memberLeft: 'MemberLeft',
  AuditActionType.roleCreated: 'RoleCreated',
  AuditActionType.roleUpdated: 'RoleUpdated',
  AuditActionType.roleDeleted: 'RoleDeleted',
  AuditActionType.rolePositionsChanged: 'RolePositionsChanged',
  AuditActionType.channelCreated: 'ChannelCreated',
  AuditActionType.channelDeleted: 'ChannelDeleted',
  AuditActionType.channelUpdated: 'ChannelUpdated',
  AuditActionType.channelPermissionChanged: 'ChannelPermissionChanged',
  AuditActionType.categoryCreated: 'CategoryCreated',
  AuditActionType.categoryDeleted: 'CategoryDeleted',
  AuditActionType.guildUpdated: 'GuildUpdated',
  AuditActionType.guildDeleted: 'GuildDeleted',
  AuditActionType.inviteCreated: 'InviteCreated',
  AuditActionType.inviteDeleted: 'InviteDeleted',
  AuditActionType.botInstalled: 'BotInstalled',
  AuditActionType.botUninstalled: 'BotUninstalled',
  AuditActionType.guildImportedFromDiscord: 'GuildImportedFromDiscord',
  AuditActionType.guildSyncedFromDiscord: 'GuildSyncedFromDiscord',
  AuditActionType.unknown: 'unknown',
};
