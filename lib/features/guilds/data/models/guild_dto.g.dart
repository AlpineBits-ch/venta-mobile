// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guild_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GuildDto _$GuildDtoFromJson(Map<String, dynamic> json) => _GuildDto(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  ownerId: json['ownerId'] as String,
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => CategoryDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CategoryDto>[],
  channels:
      (json['channels'] as List<dynamic>?)
          ?.map((e) => ChannelDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ChannelDto>[],
  roles:
      (json['roles'] as List<dynamic>?)
          ?.map((e) => RoleDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <RoleDto>[],
  bannerUrl: json['bannerUrl'] as String?,
  iconUrl: json['iconUrl'] as String?,
  systemChannelId: json['systemChannelId'] as String?,
  verificationLevel:
      $enumDecodeNullable(
        _$VerificationLevelEnumMap,
        json['verificationLevel'],
        unknownValue: VerificationLevel.none,
      ) ??
      VerificationLevel.none,
);

Map<String, dynamic> _$GuildDtoToJson(_GuildDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'ownerId': instance.ownerId,
  'categories': instance.categories,
  'channels': instance.channels,
  'roles': instance.roles,
  'bannerUrl': instance.bannerUrl,
  'iconUrl': instance.iconUrl,
  'systemChannelId': instance.systemChannelId,
  'verificationLevel': _$VerificationLevelEnumMap[instance.verificationLevel]!,
};

const _$VerificationLevelEnumMap = {
  VerificationLevel.none: 'None',
  VerificationLevel.low: 'Low',
  VerificationLevel.medium: 'Medium',
  VerificationLevel.high: 'High',
};
