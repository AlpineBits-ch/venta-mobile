import '../../../core/network/api_client.dart';
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

  Future<RelationshipModel> createFriendRequest(String username) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      client.url('/api/v1/social/relationships'),
      data: {'username': username},
    );
    return RelationshipModel.fromJson(response.data!);
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
}
