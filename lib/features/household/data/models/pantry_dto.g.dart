// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pantry_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PantryItemDto _$PantryItemDtoFromJson(Map<String, dynamic> json) =>
    _PantryItemDto(
      id: json['id'] as String,
      channelId: json['channelId'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] as String?,
      lowThreshold: (json['lowThreshold'] as num?)?.toDouble(),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      isLow: json['isLow'] as bool? ?? false,
      restockedAt: json['restockedAt'] == null
          ? null
          : DateTime.parse(json['restockedAt'] as String),
      addedByUserId: json['addedByUserId'] as String? ?? '',
    );

Map<String, dynamic> _$PantryItemDtoToJson(_PantryItemDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'channelId': instance.channelId,
      'name': instance.name,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'lowThreshold': instance.lowThreshold,
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'isLow': instance.isLow,
      'restockedAt': instance.restockedAt?.toIso8601String(),
      'addedByUserId': instance.addedByUserId,
    };

_PantryConfigDto _$PantryConfigDtoFromJson(Map<String, dynamic> json) =>
    _PantryConfigDto(
      channelId: json['channelId'] as String? ?? '',
      restockListChannelId: json['restockListChannelId'] as String?,
      expiryWarningDays: (json['expiryWarningDays'] as num?)?.toInt() ?? 3,
    );

Map<String, dynamic> _$PantryConfigDtoToJson(_PantryConfigDto instance) =>
    <String, dynamic>{
      'channelId': instance.channelId,
      'restockListChannelId': instance.restockListChannelId,
      'expiryWarningDays': instance.expiryWarningDays,
    };
