import 'package:freezed_annotation/freezed_annotation.dart';

part 'relationship_model.freezed.dart';
part 'relationship_model.g.dart';

enum RelationshipStatus {
  @JsonValue('PendingIncoming')
  pendingIncoming,
  @JsonValue('PendingOutgoing')
  pendingOutgoing,
  @JsonValue('Friends')
  friends,
  @JsonValue('Blocked')
  blocked,
}

@freezed
sealed class MinimalProfileId with _$MinimalProfileId {
  const factory MinimalProfileId({
    required String id,
    required String userName,
    required String userId,
  }) = _MinimalProfileId;

  factory MinimalProfileId.fromJson(Map<String, dynamic> json) =>
      _$MinimalProfileIdFromJson(json);
}

@freezed
sealed class RelationshipModel with _$RelationshipModel {
  const factory RelationshipModel({
    required String id,
    required String ownerId,
    required MinimalProfileId owner,
    required String targetId,
    required MinimalProfileId target,
    required RelationshipStatus status,
  }) = _RelationshipModel;

  factory RelationshipModel.fromJson(Map<String, dynamic> json) =>
      _$RelationshipModelFromJson(json);
}
