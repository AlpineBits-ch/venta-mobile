// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guild_member_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RoleMembershipDto _$RoleMembershipDtoFromJson(Map<String, dynamic> json) =>
    _RoleMembershipDto(
      role: RoleDto.fromJson(json['role'] as Map<String, dynamic>),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$RoleMembershipDtoToJson(_RoleMembershipDto instance) =>
    <String, dynamic>{
      'role': instance.role,
      'expiresAt': instance.expiresAt?.toIso8601String(),
    };

_GuildMemberDto _$GuildMemberDtoFromJson(Map<String, dynamic> json) =>
    _GuildMemberDto(
      id: json['id'] as String,
      guildId: json['guildId'] as String,
      userId: json['userId'] as String,
      permissions: json['permissions'] as String? ?? '',
      status:
          $enumDecodeNullable(_$OnlineStatusEnumMap, json['status']) ??
          OnlineStatus.offline,
      type:
          $enumDecodeNullable(_$MemberTypeEnumMap, json['type']) ??
          MemberType.standard,
      nickname: json['nickname'] as String?,
      profile: json['profile'] == null
          ? null
          : ProfileDto.fromJson(json['profile'] as Map<String, dynamic>),
      roleMembers:
          (json['roleMembers'] as List<dynamic>?)
              ?.map(
                (e) => RoleMembershipDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <RoleMembershipDto>[],
    );

Map<String, dynamic> _$GuildMemberDtoToJson(_GuildMemberDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'guildId': instance.guildId,
      'userId': instance.userId,
      'permissions': instance.permissions,
      'status': _$OnlineStatusEnumMap[instance.status]!,
      'type': _$MemberTypeEnumMap[instance.type]!,
      'nickname': instance.nickname,
      'profile': instance.profile,
      'roleMembers': instance.roleMembers,
    };

const _$OnlineStatusEnumMap = {
  OnlineStatus.offline: 'Offline',
  OnlineStatus.hidden: 'Hidden',
  OnlineStatus.online: 'Online',
  OnlineStatus.idle: 'Idle',
  OnlineStatus.doNotDisturb: 'DoNotDisturb',
};

const _$MemberTypeEnumMap = {
  MemberType.standard: 'Default',
  MemberType.bot: 'Bot',
};
