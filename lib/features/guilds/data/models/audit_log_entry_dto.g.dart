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
      rawActionType: json['actionType'] as String? ?? '',
      targetId: json['targetId'] as String?,
      metadata: json['metadata'] as String?,
      createdAt: _$JsonConverterFromJson<String, DateTime>(
        json['createdAt'],
        const ApiDateTimeConverter().fromJson,
      ),
    );

Map<String, dynamic> _$AuditLogEntryDtoToJson(_AuditLogEntryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'guildId': instance.guildId,
      'actorUserId': instance.actorUserId,
      'actionType': _$AuditActionTypeEnumMap[instance.actionType]!,
      'targetId': instance.targetId,
      'metadata': instance.metadata,
      'createdAt': _$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const ApiDateTimeConverter().toJson,
      ),
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
  AuditActionType.categoryUpdated: 'CategoryUpdated',
  AuditActionType.guildUpdated: 'GuildUpdated',
  AuditActionType.guildDeleted: 'GuildDeleted',
  AuditActionType.inviteCreated: 'InviteCreated',
  AuditActionType.inviteDeleted: 'InviteDeleted',
  AuditActionType.botInstalled: 'BotInstalled',
  AuditActionType.botUninstalled: 'BotUninstalled',
  AuditActionType.guildImportedFromDiscord: 'GuildImportedFromDiscord',
  AuditActionType.guildSyncedFromDiscord: 'GuildSyncedFromDiscord',
  AuditActionType.messagePinned: 'MessagePinned',
  AuditActionType.messageUnpinned: 'MessageUnpinned',
  AuditActionType.emojiCreated: 'EmojiCreated',
  AuditActionType.emojiDeleted: 'EmojiDeleted',
  AuditActionType.autoModConfigUpdated: 'AutoModConfigUpdated',
  AuditActionType.autoModMessageBlocked: 'AutoModMessageBlocked',
  AuditActionType.onboardingConfigUpdated: 'OnboardingConfigUpdated',
  AuditActionType.scheduledEventCreated: 'ScheduledEventCreated',
  AuditActionType.scheduledEventUpdated: 'ScheduledEventUpdated',
  AuditActionType.scheduledEventCancelled: 'ScheduledEventCancelled',
  AuditActionType.scheduledEventDeleted: 'ScheduledEventDeleted',
  AuditActionType.templateCreated: 'TemplateCreated',
  AuditActionType.guildCreatedFromTemplate: 'GuildCreatedFromTemplate',
  AuditActionType.channelFollowCreated: 'ChannelFollowCreated',
  AuditActionType.channelFollowRemoved: 'ChannelFollowRemoved',
  AuditActionType.unknown: 'unknown',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
