// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InviteDto _$InviteDtoFromJson(Map<String, dynamic> json) => _InviteDto(
  id: json['id'] as String,
  type: $enumDecode(
    _$InviteTypeEnumMap,
    json['type'],
    unknownValue: InviteType.unknown,
  ),
  state: $enumDecode(
    _$InviteStateEnumMap,
    json['state'],
    unknownValue: InviteState.unknown,
  ),
  guildId: json['guildId'] as String,
  guild: json['guild'] == null
      ? null
      : GuildDto.fromJson(json['guild'] as Map<String, dynamic>),
  code: json['code'] as String,
  expiresAt: _$JsonConverterFromJson<String, DateTime>(
    json['expiresAt'],
    const ApiDateTimeConverter().fromJson,
  ),
  maxUses: (json['maxUses'] as num?)?.toInt(),
  useCount: (json['useCount'] as num?)?.toInt() ?? 0,
  channelId: json['channelId'] as String?,
  inviterId: json['inviterId'] as String?,
  temporary: json['temporary'] as bool? ?? false,
  targetType:
      $enumDecodeNullable(
        _$InviteTargetTypeEnumMap,
        json['targetType'],
        unknownValue: InviteTargetType.unknown,
      ) ??
      InviteTargetType.none,
  targetUserId: json['targetUserId'] as String?,
  revokedAt: _$JsonConverterFromJson<String, DateTime>(
    json['revokedAt'],
    const ApiDateTimeConverter().fromJson,
  ),
  welcomeScreen: json['welcomeScreen'] == null
      ? null
      : WelcomeScreenDto.fromJson(
          json['welcomeScreen'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$InviteDtoToJson(_InviteDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$InviteTypeEnumMap[instance.type]!,
      'state': _$InviteStateEnumMap[instance.state]!,
      'guildId': instance.guildId,
      'guild': instance.guild,
      'code': instance.code,
      'expiresAt': _$JsonConverterToJson<String, DateTime>(
        instance.expiresAt,
        const ApiDateTimeConverter().toJson,
      ),
      'maxUses': instance.maxUses,
      'useCount': instance.useCount,
      'channelId': instance.channelId,
      'inviterId': instance.inviterId,
      'temporary': instance.temporary,
      'targetType': _$InviteTargetTypeEnumMap[instance.targetType]!,
      'targetUserId': instance.targetUserId,
      'revokedAt': _$JsonConverterToJson<String, DateTime>(
        instance.revokedAt,
        const ApiDateTimeConverter().toJson,
      ),
      'welcomeScreen': instance.welcomeScreen,
    };

const _$InviteTypeEnumMap = {
  InviteType.oneTime: 'OneTime',
  InviteType.permanent: 'Permanent',
  InviteType.unknown: 'unknown',
};

const _$InviteStateEnumMap = {
  InviteState.active: 'Active',
  InviteState.expired: 'Expired',
  InviteState.revoked: 'Revoked',
  InviteState.unknown: 'unknown',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

const _$InviteTargetTypeEnumMap = {
  InviteTargetType.none: 'None',
  InviteTargetType.voiceChannel: 'VoiceChannel',
  InviteTargetType.unknown: 'unknown',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_RedeemResultDto _$RedeemResultDtoFromJson(Map<String, dynamic> json) =>
    _RedeemResultDto(
      guildId: json['guildId'] as String,
      channelId: json['channelId'] as String?,
      targetType:
          $enumDecodeNullable(
            _$InviteTargetTypeEnumMap,
            json['targetType'],
            unknownValue: InviteTargetType.unknown,
          ) ??
          InviteTargetType.none,
      targetUserId: json['targetUserId'] as String?,
      joinVoice: json['joinVoice'] as bool? ?? false,
      onboardingRequired: json['onboardingRequired'] as bool? ?? false,
      temporaryMembership: json['temporaryMembership'] as bool? ?? false,
    );

Map<String, dynamic> _$RedeemResultDtoToJson(_RedeemResultDto instance) =>
    <String, dynamic>{
      'guildId': instance.guildId,
      'channelId': instance.channelId,
      'targetType': _$InviteTargetTypeEnumMap[instance.targetType]!,
      'targetUserId': instance.targetUserId,
      'joinVoice': instance.joinVoice,
      'onboardingRequired': instance.onboardingRequired,
      'temporaryMembership': instance.temporaryMembership,
    };
