// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relationship_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MinimalProfileId _$MinimalProfileIdFromJson(Map<String, dynamic> json) =>
    _MinimalProfileId(
      id: json['id'] as String,
      userName: json['userName'] as String,
      userId: json['userId'] as String,
    );

Map<String, dynamic> _$MinimalProfileIdToJson(_MinimalProfileId instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userName': instance.userName,
      'userId': instance.userId,
    };

_RelationshipModel _$RelationshipModelFromJson(Map<String, dynamic> json) =>
    _RelationshipModel(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      owner: MinimalProfileId.fromJson(json['owner'] as Map<String, dynamic>),
      targetId: json['targetId'] as String,
      target: MinimalProfileId.fromJson(json['target'] as Map<String, dynamic>),
      status: $enumDecode(_$RelationshipStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$RelationshipModelToJson(_RelationshipModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ownerId': instance.ownerId,
      'owner': instance.owner,
      'targetId': instance.targetId,
      'target': instance.target,
      'status': _$RelationshipStatusEnumMap[instance.status]!,
    };

const _$RelationshipStatusEnumMap = {
  RelationshipStatus.pendingIncoming: 'PendingIncoming',
  RelationshipStatus.pendingOutgoing: 'PendingOutgoing',
  RelationshipStatus.friends: 'Friends',
  RelationshipStatus.blocked: 'Blocked',
};
