// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ListItemDto _$ListItemDtoFromJson(Map<String, dynamic> json) => _ListItemDto(
  id: json['id'] as String,
  channelId: json['channelId'] as String,
  text: json['text'] as String,
  quantity: json['quantity'] as String?,
  note: json['note'] as String?,
  section: json['section'] as String?,
  assigneeUserId: json['assigneeUserId'] as String?,
  addedByUserId: json['addedByUserId'] as String? ?? '',
  isChecked: json['isChecked'] as bool? ?? false,
  checkedAt: _$JsonConverterFromJson<String, DateTime>(
    json['checkedAt'],
    const ApiDateTimeConverter().fromJson,
  ),
  checkedByUserId: json['checkedByUserId'] as String?,
  position: (json['position'] as num?)?.toInt() ?? 0,
  sourcePantryItemId: json['sourcePantryItemId'] as String?,
  createdAt: _$JsonConverterFromJson<String, DateTime>(
    json['createdAt'],
    const ApiDateTimeConverter().fromJson,
  ),
);

Map<String, dynamic> _$ListItemDtoToJson(_ListItemDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'channelId': instance.channelId,
      'text': instance.text,
      'quantity': instance.quantity,
      'note': instance.note,
      'section': instance.section,
      'assigneeUserId': instance.assigneeUserId,
      'addedByUserId': instance.addedByUserId,
      'isChecked': instance.isChecked,
      'checkedAt': _$JsonConverterToJson<String, DateTime>(
        instance.checkedAt,
        const ApiDateTimeConverter().toJson,
      ),
      'checkedByUserId': instance.checkedByUserId,
      'position': instance.position,
      'sourcePantryItemId': instance.sourcePantryItemId,
      'createdAt': _$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
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
