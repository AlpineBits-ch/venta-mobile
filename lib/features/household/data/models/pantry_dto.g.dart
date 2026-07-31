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
      expiresAt: _$JsonConverterFromJson<String, DateTime>(
        json['expiresAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      isLow: json['isLow'] as bool? ?? false,
      restockedAt: _$JsonConverterFromJson<String, DateTime>(
        json['restockedAt'],
        const ApiDateTimeConverter().fromJson,
      ),
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
      'expiresAt': _$JsonConverterToJson<String, DateTime>(
        instance.expiresAt,
        const ApiDateTimeConverter().toJson,
      ),
      'isLow': instance.isLow,
      'restockedAt': _$JsonConverterToJson<String, DateTime>(
        instance.restockedAt,
        const ApiDateTimeConverter().toJson,
      ),
      'addedByUserId': instance.addedByUserId,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

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
