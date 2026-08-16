// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_ring_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VoiceRingDto _$VoiceRingDtoFromJson(Map<String, dynamic> json) =>
    _VoiceRingDto(
      ringId: json['ringId'] as String,
      guildId: json['guildId'] as String,
      channelId: json['channelId'] as String,
      channelName: json['channelName'] as String?,
      inviterId: json['inviterId'] as String,
      targetUserId: json['targetUserId'] as String,
      status:
          $enumDecodeNullable(
            _$VoiceRingStatusEnumMap,
            json['status'],
            unknownValue: VoiceRingStatus.unknown,
          ) ??
          VoiceRingStatus.pending,
      reason: $enumDecodeNullable(
        _$VoiceRingReasonEnumMap,
        json['reason'],
        unknownValue: VoiceRingReason.unknown,
      ),
      createdAt: _$JsonConverterFromJson<String, DateTime>(
        json['createdAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      expiresAt: _$JsonConverterFromJson<String, DateTime>(
        json['expiresAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      expiresInSeconds: (json['expiresInSeconds'] as num?)?.toInt() ?? 0,
      resolvedByDeviceId: json['resolvedByDeviceId'] as String?,
    );

Map<String, dynamic> _$VoiceRingDtoToJson(_VoiceRingDto instance) =>
    <String, dynamic>{
      'ringId': instance.ringId,
      'guildId': instance.guildId,
      'channelId': instance.channelId,
      'channelName': instance.channelName,
      'inviterId': instance.inviterId,
      'targetUserId': instance.targetUserId,
      'status': _$VoiceRingStatusEnumMap[instance.status]!,
      'reason': _$VoiceRingReasonEnumMap[instance.reason],
      'createdAt': _$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const ApiDateTimeConverter().toJson,
      ),
      'expiresAt': _$JsonConverterToJson<String, DateTime>(
        instance.expiresAt,
        const ApiDateTimeConverter().toJson,
      ),
      'expiresInSeconds': instance.expiresInSeconds,
      'resolvedByDeviceId': instance.resolvedByDeviceId,
    };

const _$VoiceRingStatusEnumMap = {
  VoiceRingStatus.pending: 'Pending',
  VoiceRingStatus.accepted: 'Accepted',
  VoiceRingStatus.declined: 'Declined',
  VoiceRingStatus.cancelled: 'Cancelled',
  VoiceRingStatus.expired: 'Expired',
  VoiceRingStatus.unknown: 'unknown',
};

const _$VoiceRingReasonEnumMap = {
  VoiceRingReason.inviterCancelled: 'InviterCancelled',
  VoiceRingReason.inviterLeft: 'InviterLeft',
  VoiceRingReason.superseded: 'Superseded',
  VoiceRingReason.targetJoined: 'TargetJoined',
  VoiceRingReason.channelGone: 'ChannelGone',
  VoiceRingReason.timedOut: 'TimedOut',
  VoiceRingReason.unknown: 'unknown',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_VoiceInviteSentDto _$VoiceInviteSentDtoFromJson(Map<String, dynamic> json) =>
    _VoiceInviteSentDto(
      conversationId: json['conversationId'] as String? ?? '',
    );

Map<String, dynamic> _$VoiceInviteSentDtoToJson(_VoiceInviteSentDto instance) =>
    <String, dynamic>{'conversationId': instance.conversationId};

_VoiceRingRefusalDto _$VoiceRingRefusalDtoFromJson(Map<String, dynamic> json) =>
    _VoiceRingRefusalDto(
      reason:
          $enumDecodeNullable(
            _$VoiceRingRefusalEnumMap,
            json['reason'],
            unknownValue: VoiceRingRefusal.unknown,
          ) ??
          VoiceRingRefusal.unknown,
      retryAfterSeconds: (json['retryAfterSeconds'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$VoiceRingRefusalDtoToJson(
  _VoiceRingRefusalDto instance,
) => <String, dynamic>{
  'reason': _$VoiceRingRefusalEnumMap[instance.reason]!,
  'retryAfterSeconds': instance.retryAfterSeconds,
};

const _$VoiceRingRefusalEnumMap = {
  VoiceRingRefusal.targetCannotJoinChannel: 'TargetCannotJoinChannel',
  VoiceRingRefusal.unavailable: 'Unavailable',
  VoiceRingRefusal.targetAlreadyInChannel: 'TargetAlreadyInChannel',
  VoiceRingRefusal.recentlyDeclined: 'RecentlyDeclined',
  VoiceRingRefusal.inviterFlooding: 'InviterFlooding',
  VoiceRingRefusal.targetSaturated: 'TargetSaturated',
  VoiceRingRefusal.recipientPolicy: 'RecipientPolicy',
  VoiceRingRefusal.unknown: 'unknown',
};

_VoiceRingInvitationDto _$VoiceRingInvitationDtoFromJson(
  Map<String, dynamic> json,
) => _VoiceRingInvitationDto(
  ringId: json['ringId'] as String,
  guildId: json['guildId'] as String,
  channelId: json['channelId'] as String,
  channelName: json['channelName'] as String?,
  inviterId: json['inviterId'] as String,
  inviterName: json['inviterName'] as String?,
  inviterAvatarUrl: json['inviterAvatarUrl'] as String?,
  targetUserId: json['targetUserId'] as String,
  createdAt: _$JsonConverterFromJson<String, DateTime>(
    json['createdAt'],
    const ApiDateTimeConverter().fromJson,
  ),
  expiresAt: _$JsonConverterFromJson<String, DateTime>(
    json['expiresAt'],
    const ApiDateTimeConverter().fromJson,
  ),
  expiresInSeconds: (json['expiresInSeconds'] as num?)?.toInt() ?? 0,
  participantUserIds:
      (json['participantUserIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
);

Map<String, dynamic> _$VoiceRingInvitationDtoToJson(
  _VoiceRingInvitationDto instance,
) => <String, dynamic>{
  'ringId': instance.ringId,
  'guildId': instance.guildId,
  'channelId': instance.channelId,
  'channelName': instance.channelName,
  'inviterId': instance.inviterId,
  'inviterName': instance.inviterName,
  'inviterAvatarUrl': instance.inviterAvatarUrl,
  'targetUserId': instance.targetUserId,
  'createdAt': _$JsonConverterToJson<String, DateTime>(
    instance.createdAt,
    const ApiDateTimeConverter().toJson,
  ),
  'expiresAt': _$JsonConverterToJson<String, DateTime>(
    instance.expiresAt,
    const ApiDateTimeConverter().toJson,
  ),
  'expiresInSeconds': instance.expiresInSeconds,
  'participantUserIds': instance.participantUserIds,
};

_VoiceRingResolvedDto _$VoiceRingResolvedDtoFromJson(
  Map<String, dynamic> json,
) => _VoiceRingResolvedDto(
  ringId: json['ringId'] as String,
  guildId: json['guildId'] as String,
  channelId: json['channelId'] as String,
  inviterId: json['inviterId'] as String,
  targetUserId: json['targetUserId'] as String,
  status:
      $enumDecodeNullable(
        _$VoiceRingStatusEnumMap,
        json['status'],
        unknownValue: VoiceRingStatus.unknown,
      ) ??
      VoiceRingStatus.unknown,
  reason: $enumDecodeNullable(
    _$VoiceRingReasonEnumMap,
    json['reason'],
    unknownValue: VoiceRingReason.unknown,
  ),
  resolvedAt: _$JsonConverterFromJson<String, DateTime>(
    json['resolvedAt'],
    const ApiDateTimeConverter().fromJson,
  ),
  resolvedByDeviceId: json['resolvedByDeviceId'] as String?,
);

Map<String, dynamic> _$VoiceRingResolvedDtoToJson(
  _VoiceRingResolvedDto instance,
) => <String, dynamic>{
  'ringId': instance.ringId,
  'guildId': instance.guildId,
  'channelId': instance.channelId,
  'inviterId': instance.inviterId,
  'targetUserId': instance.targetUserId,
  'status': _$VoiceRingStatusEnumMap[instance.status]!,
  'reason': _$VoiceRingReasonEnumMap[instance.reason],
  'resolvedAt': _$JsonConverterToJson<String, DateTime>(
    instance.resolvedAt,
    const ApiDateTimeConverter().toJson,
  ),
  'resolvedByDeviceId': instance.resolvedByDeviceId,
};

_VoiceRingDismissedDto _$VoiceRingDismissedDtoFromJson(
  Map<String, dynamic> json,
) => _VoiceRingDismissedDto(
  ringId: json['ringId'] as String,
  deviceId: json['deviceId'] as String,
  status:
      $enumDecodeNullable(
        _$VoiceRingStatusEnumMap,
        json['status'],
        unknownValue: VoiceRingStatus.unknown,
      ) ??
      VoiceRingStatus.unknown,
  reason: $enumDecodeNullable(
    _$VoiceRingReasonEnumMap,
    json['reason'],
    unknownValue: VoiceRingReason.unknown,
  ),
);

Map<String, dynamic> _$VoiceRingDismissedDtoToJson(
  _VoiceRingDismissedDto instance,
) => <String, dynamic>{
  'ringId': instance.ringId,
  'deviceId': instance.deviceId,
  'status': _$VoiceRingStatusEnumMap[instance.status]!,
  'reason': _$VoiceRingReasonEnumMap[instance.reason],
};
