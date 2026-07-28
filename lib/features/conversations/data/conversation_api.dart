import '../../../core/network/api_client.dart';
import 'models/conversation_dto.dart';

class ConversationApi {
  ConversationApi({required this.client});

  final ApiClient client;

  Future<ConversationDto> create({String? name, required List<String> memberUserIds}) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      client.url('/api/v1/messaging/conversations'),
      data: {
        'name': name,
        'members': memberUserIds.map((id) => {'userId': id}).toList(),
        'encryption': 'Plain',
        'deviceWelcomes': <Object>[],
      },
    );
    return ConversationDto.fromJson(response.data!);
  }

  Future<List<ConversationDto>> list({int offset = 0, int limit = 50}) async {
    final response = await client.dio.get<List<dynamic>>(
      client.url('/api/v1/messaging/conversations?offset=$offset&limit=$limit'),
    );
    return response.data!
        .map((json) => ConversationDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<ConversationDto> getById(String id) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      client.url('/api/v1/messaging/conversations/$id'),
    );
    return ConversationDto.fromJson(response.data!);
  }

  Future<void> delete(String id) async {
    await client.dio.delete<void>(client.url('/api/v1/messaging/conversations/$id'));
  }
}
