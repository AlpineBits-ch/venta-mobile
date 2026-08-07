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
      barcode: json['barcode'] as String?,
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
      'barcode': instance.barcode,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_ScanResultDto _$ScanResultDtoFromJson(Map<String, dynamic> json) =>
    _ScanResultDto(
      item: PantryItemDto.fromJson(json['item'] as Map<String, dynamic>),
      created: json['created'] as bool? ?? false,
      learned: json['learned'] as bool? ?? false,
    );

Map<String, dynamic> _$ScanResultDtoToJson(_ScanResultDto instance) =>
    <String, dynamic>{
      'item': instance.item,
      'created': instance.created,
      'learned': instance.learned,
    };

_PantryBarcodeDto _$PantryBarcodeDtoFromJson(Map<String, dynamic> json) =>
    _PantryBarcodeDto(
      barcode: json['barcode'] as String? ?? '',
      name: json['name'] as String? ?? '',
      unit: json['unit'] as String?,
      defaultQuantity: (json['defaultQuantity'] as num?)?.toDouble() ?? 1,
      lowThreshold: (json['lowThreshold'] as num?)?.toDouble(),
      timesSeen: (json['timesSeen'] as num?)?.toInt() ?? 0,
      lastUsedAt: _$JsonConverterFromJson<String, DateTime>(
        json['lastUsedAt'],
        const ApiDateTimeConverter().fromJson,
      ),
    );

Map<String, dynamic> _$PantryBarcodeDtoToJson(_PantryBarcodeDto instance) =>
    <String, dynamic>{
      'barcode': instance.barcode,
      'name': instance.name,
      'unit': instance.unit,
      'defaultQuantity': instance.defaultQuantity,
      'lowThreshold': instance.lowThreshold,
      'timesSeen': instance.timesSeen,
      'lastUsedAt': _$JsonConverterToJson<String, DateTime>(
        instance.lastUsedAt,
        const ApiDateTimeConverter().toJson,
      ),
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
