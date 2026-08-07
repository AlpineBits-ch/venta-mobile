// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MaintenanceAssetDto _$MaintenanceAssetDtoFromJson(Map<String, dynamic> json) =>
    _MaintenanceAssetDto(
      id: json['id'] as String,
      channelId: json['channelId'] as String,
      name: json['name'] as String? ?? '',
      location: json['location'] as String?,
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      serialNumber: json['serialNumber'] as String?,
      purchasedAt: _$JsonConverterFromJson<String, DateTime>(
        json['purchasedAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      warrantyUntil: _$JsonConverterFromJson<String, DateTime>(
        json['warrantyUntil'],
        const ApiDateTimeConverter().fromJson,
      ),
      vendorName: json['vendorName'] as String?,
      vendorPhone: json['vendorPhone'] as String?,
      vendorEmail: json['vendorEmail'] as String?,
      notes: json['notes'] as String?,
      serviceIntervalDays: (json['serviceIntervalDays'] as num?)?.toInt(),
      lastServicedAt: _$JsonConverterFromJson<String, DateTime>(
        json['lastServicedAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      nextServiceAt: _$JsonConverterFromJson<String, DateTime>(
        json['nextServiceAt'],
        const ApiDateTimeConverter().fromJson,
      ),
      status:
          $enumDecodeNullable(
            _$AssetStatusEnumMap,
            json['status'],
            unknownValue: AssetStatus.ok,
          ) ??
          AssetStatus.ok,
      statusNote: json['statusNote'] as String?,
      isServiceOverdue: json['isServiceOverdue'] as bool? ?? false,
      isWarrantyExpiring: json['isWarrantyExpiring'] as bool? ?? false,
      addedByUserId: json['addedByUserId'] as String? ?? '',
    );

Map<String, dynamic> _$MaintenanceAssetDtoToJson(
  _MaintenanceAssetDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'channelId': instance.channelId,
  'name': instance.name,
  'location': instance.location,
  'brand': instance.brand,
  'model': instance.model,
  'serialNumber': instance.serialNumber,
  'purchasedAt': _$JsonConverterToJson<String, DateTime>(
    instance.purchasedAt,
    const ApiDateTimeConverter().toJson,
  ),
  'warrantyUntil': _$JsonConverterToJson<String, DateTime>(
    instance.warrantyUntil,
    const ApiDateTimeConverter().toJson,
  ),
  'vendorName': instance.vendorName,
  'vendorPhone': instance.vendorPhone,
  'vendorEmail': instance.vendorEmail,
  'notes': instance.notes,
  'serviceIntervalDays': instance.serviceIntervalDays,
  'lastServicedAt': _$JsonConverterToJson<String, DateTime>(
    instance.lastServicedAt,
    const ApiDateTimeConverter().toJson,
  ),
  'nextServiceAt': _$JsonConverterToJson<String, DateTime>(
    instance.nextServiceAt,
    const ApiDateTimeConverter().toJson,
  ),
  'status': _$AssetStatusEnumMap[instance.status]!,
  'statusNote': instance.statusNote,
  'isServiceOverdue': instance.isServiceOverdue,
  'isWarrantyExpiring': instance.isWarrantyExpiring,
  'addedByUserId': instance.addedByUserId,
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

const _$AssetStatusEnumMap = {
  AssetStatus.ok: 'Ok',
  AssetStatus.needsAttention: 'NeedsAttention',
  AssetStatus.broken: 'Broken',
  AssetStatus.outOfService: 'OutOfService',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_MaintenanceRecordDto _$MaintenanceRecordDtoFromJson(
  Map<String, dynamic> json,
) => _MaintenanceRecordDto(
  id: json['id'] as String,
  assetId: json['assetId'] as String?,
  channelId: json['channelId'] as String,
  title: json['title'] as String? ?? '',
  description: json['description'] as String?,
  performedAt: const ApiDateTimeConverter().fromJson(
    json['performedAt'] as String,
  ),
  performedByUserId: json['performedByUserId'] as String? ?? '',
  vendorName: json['vendorName'] as String?,
  costMinor: (json['costMinor'] as num?)?.toInt(),
  currency: json['currency'] as String?,
  expenseId: json['expenseId'] as String?,
);

Map<String, dynamic> _$MaintenanceRecordDtoToJson(
  _MaintenanceRecordDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'assetId': instance.assetId,
  'channelId': instance.channelId,
  'title': instance.title,
  'description': instance.description,
  'performedAt': const ApiDateTimeConverter().toJson(instance.performedAt),
  'performedByUserId': instance.performedByUserId,
  'vendorName': instance.vendorName,
  'costMinor': instance.costMinor,
  'currency': instance.currency,
  'expenseId': instance.expenseId,
};

_MaintenanceRecordPageDto _$MaintenanceRecordPageDtoFromJson(
  Map<String, dynamic> json,
) => _MaintenanceRecordPageDto(
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => MaintenanceRecordDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <MaintenanceRecordDto>[],
  nextCursor: json['nextCursor'] as String?,
);

Map<String, dynamic> _$MaintenanceRecordPageDtoToJson(
  _MaintenanceRecordPageDto instance,
) => <String, dynamic>{
  'items': instance.items,
  'nextCursor': instance.nextCursor,
};

_MaintenanceAttentionDto _$MaintenanceAttentionDtoFromJson(
  Map<String, dynamic> json,
) => _MaintenanceAttentionDto(
  asset: MaintenanceAssetDto.fromJson(json['asset'] as Map<String, dynamic>),
  reasons:
      (json['reasons'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
);

Map<String, dynamic> _$MaintenanceAttentionDtoToJson(
  _MaintenanceAttentionDto instance,
) => <String, dynamic>{'asset': instance.asset, 'reasons': instance.reasons};
