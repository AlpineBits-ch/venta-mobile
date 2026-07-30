// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_follower_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChannelFollowerDto _$ChannelFollowerDtoFromJson(Map<String, dynamic> json) =>
    _ChannelFollowerDto(
      id: json['id'] as String,
      targetChannelId: json['targetChannelId'] as String,
    );

Map<String, dynamic> _$ChannelFollowerDtoToJson(_ChannelFollowerDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'targetChannelId': instance.targetChannelId,
    };
