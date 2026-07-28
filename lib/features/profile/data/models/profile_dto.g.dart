// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProfileDto _$ProfileDtoFromJson(Map<String, dynamic> json) => _ProfileDto(
  id: json['id'] as String,
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  bio: json['bio'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  bannerUrl: json['bannerUrl'] as String?,
  accentColor: json['accentColor'] as String?,
  font:
      $enumDecodeNullable(_$ProfileFontEnumMap, json['font']) ??
      ProfileFont.defaultFont,
  onlineStatus:
      $enumDecodeNullable(_$OnlineStatusEnumMap, json['onlineStatus']) ??
      OnlineStatus.offline,
);

Map<String, dynamic> _$ProfileDtoToJson(_ProfileDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'bio': instance.bio,
      'avatarUrl': instance.avatarUrl,
      'bannerUrl': instance.bannerUrl,
      'accentColor': instance.accentColor,
      'font': _$ProfileFontEnumMap[instance.font]!,
      'onlineStatus': _$OnlineStatusEnumMap[instance.onlineStatus]!,
    };

const _$ProfileFontEnumMap = {
  ProfileFont.defaultFont: 'Default',
  ProfileFont.serif: 'Serif',
  ProfileFont.monospace: 'Monospace',
  ProfileFont.rounded: 'Rounded',
  ProfileFont.display: 'Display',
  ProfileFont.handwritten: 'Handwritten',
};

const _$OnlineStatusEnumMap = {
  OnlineStatus.offline: 'Offline',
  OnlineStatus.hidden: 'Hidden',
  OnlineStatus.online: 'Online',
  OnlineStatus.idle: 'Idle',
  OnlineStatus.doNotDisturb: 'DoNotDisturb',
};
