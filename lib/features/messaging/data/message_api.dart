import '../../../core/network/api_client.dart';
import 'models/message_dto.dart';

class MessageApi {
  MessageApi({required this.client});

  final ApiClient client;

  Future<MessageDto> create({
    required String content,
    String? conversationId,
    String? channelId,
    String? inReplyTo,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      client.url('/api/v1/messaging/messaging'),
      data: {
        'content': content,
        'conversationId': conversationId,
        'channelId': channelId,
        'attachments': <String>[],
        'inReplyTo': inReplyTo,
        'mentions': <String>[],
        'encryptionState': 'Plain',
      },
    );
    return MessageDto.fromJson(response.data!);
  }

  Future<List<MessageDto>> getForConversation(
    String conversationId, {
    int offset = 0,
    int limit = 50,
  }) async {
    final response = await client.dio.get<List<dynamic>>(
      client.url(
        '/api/v1/messaging/messaging/conversations/$conversationId/messages?offset=$offset&limit=$limit',
      ),
    );
    return response.data!
        .map((json) => MessageDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<MessageDto>> getForChannel(
    String channelId, {
    int offset = 0,
    int limit = 50,
  }) async {
    final response = await client.dio.get<List<dynamic>>(
      client.url(
        '/api/v1/messaging/messaging/channels/$channelId/messages?offset=$offset&limit=$limit',
      ),
    );
    return response.data!
        .map((json) => MessageDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
