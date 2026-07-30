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
  checkedAt: json['checkedAt'] == null
      ? null
      : DateTime.parse(json['checkedAt'] as String),
  checkedByUserId: json['checkedByUserId'] as String?,
  position: (json['position'] as num?)?.toInt() ?? 0,
  sourcePantryItemId: json['sourcePantryItemId'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
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
      'checkedAt': instance.checkedAt?.toIso8601String(),
      'checkedByUserId': instance.checkedByUserId,
      'position': instance.position,
      'sourcePantryItemId': instance.sourcePantryItemId,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
