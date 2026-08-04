import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/privacy_refusal.dart';
import '../../privacy/data/models/blocked_user_dto.dart';
import 'models/relationship_model.dart';

class RelationshipApi {
  RelationshipApi({required this.client});

  final ApiClient client;

  Future<List<RelationshipModel>> getRelationships() async {
    final response = await client.dio.get<List<dynamic>>(
      client.url('/api/v1/social/relationships'),
    );
    return response.data!
        .map((json) => RelationshipModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Throws [PrivacyRefusalException] when the target's friend-request policy
  /// or a block refuses it.
  ///
  /// A refusal deliberately does not say whether the account exists: a
  /// distinguishable "no such user" turns this endpoint into a username oracle,
  /// which is why the server answers both the same way and why nothing here
  /// tries to tell them apart.
  Future<RelationshipModel> createFriendRequest(String username) async {
    try {
      final response = await client.dio.post<Map<String, dynamic>>(
        client.url('/api/v1/social/relationships'),
        data: {'username': username},
      );
      return RelationshipModel.fromJson(response.data!);
    } on DioException catch (e) {
      final refusal = privacyRefusalOf(e);
      if (refusal != null) throw refusal;
      rethrow;
    }
  }

  Future<RelationshipModel> accept(String id) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      client.url('/api/v1/social/relationships/$id/accept'),
    );
    return RelationshipModel.fromJson(response.data!);
  }

  Future<RelationshipModel> reject(String id) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      client.url('/api/v1/social/relationships/$id/reject'),
    );
    return RelationshipModel.fromJson(response.data!);
  }

  Future<RelationshipModel> revoke(String id) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      client.url('/api/v1/social/relationships/$id/revoke'),
    );
    return RelationshipModel.fromJson(response.data!);
  }

  // ── Blocking ────────────────────────────────────────────────────────────
  //
  // Keyed by *user* id, unlike the four verbs above, which take a relationship
  // id. That is not an inconsistency to paper over: you can block someone you
  // have no relationship row with at all, so there is no id to pass.

  /// Blocks [userId]. Removes an existing friendship and cancels a pending
  /// request in either direction, all server-side.
  ///
  /// Answers `204` with no body - the block is not itself a readable
  /// relationship state for the other party, so there is nothing to return.
  Future<void> block(String userId) async {
    await client.dio.post<void>(
      client.url('/api/v1/social/relationships/$userId/block'),
    );
  }

  /// Idempotent: unblocking someone who isn't blocked is a `204`, not an error.
  /// Does **not** restore a friendship the block removed.
  Future<void> unblock(String userId) async {
    await client.dio.delete<void>(
      client.url('/api/v1/social/relationships/$userId/block'),
    );
  }

  /// One keyset page of the caller's own block list.
  ///
  /// [limit] is capped at 100 server-side and defaults to 50; a malformed
  /// [cursor] is a `400`, so the cursor is only ever one this endpoint handed
  /// back. A bare array is still accepted as well as the paged envelope - the
  /// two are indistinguishable at the type level and every sibling list on this
  /// service is bare, so tolerating both costs one `switch` and removes a whole
  /// class of "the block list is empty" bug.
  Future<BlockedUsersPage> getBlocked({int? limit, String? cursor}) async {
    final response = await client.dio.get<dynamic>(
      client.url('/api/v1/social/relationships/blocked'),
      queryParameters: {'limit': ?limit, 'cursor': ?cursor},
    );
    final data = response.data;
    final rows = switch (data) {
      List<dynamic>() => data,
      Map<String, dynamic>() =>
        (data['blocked'] ?? data['items'] ?? data['results']) as List<dynamic>?,
      _ => null,
    };
    return BlockedUsersPage(
      blocked: (rows ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(BlockedUserDto.fromJson)
          .toList(),
      nextCursor: data is Map<String, dynamic>
          ? data['nextCursor'] as String?
          : null,
    );
  }
}
