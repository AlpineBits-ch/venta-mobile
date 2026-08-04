// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blocked_user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BlockedUserDto _$BlockedUserDtoFromJson(Map<String, dynamic> json) =>
    _BlockedUserDto(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      relationshipId: json['relationshipId'] as String?,
      profileId: json['profileId'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      blockedAt: _$JsonConverterFromJson<String, DateTime>(
        json['blockedAt'],
        const ApiDateTimeConverter().fromJson,
      ),
    );

Map<String, dynamic> _$BlockedUserDtoToJson(_BlockedUserDto instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'userName': instance.userName,
      'relationshipId': instance.relationshipId,
      'profileId': instance.profileId,
      'avatarUrl': instance.avatarUrl,
      'blockedAt': _$JsonConverterToJson<String, DateTime>(
        instance.blockedAt,
        const ApiDateTimeConverter().toJson,
      ),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
