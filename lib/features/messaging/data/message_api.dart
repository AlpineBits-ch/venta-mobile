import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import 'models/attachment_dto.dart';
import 'models/message_dto.dart';

class MessageApi {
  MessageApi({required this.client});

  final ApiClient client;

  Future<MessageDto> create({
    required String content,
    String? conversationId,
    String? channelId,
    String? inReplyTo,
    List<String> attachments = const [],
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      client.url('/api/v1/messaging/messaging'),
      data: {
        'content': content,
        'conversationId': conversationId,
        'channelId': channelId,
        'attachments': attachments,
        'inReplyTo': inReplyTo,
        'mentions': <String>[],
        'encryptionState': 'Plain',
      },
    );
    return MessageDto.fromJson(response.data!);
  }

  /// Uploads one file and returns its attachment id — call [pollAttachment]
  /// afterwards to wait for server-side processing before referencing the id
  /// in `create()`. One file per request (matches the desktop client): the
  /// server accepts a collection under the `files` field but only the first
  /// entry's id is reliably ours to track when sent one at a time.
  Future<String> uploadAttachment({
    required List<int> bytes,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      'files': MultipartFile.fromBytes(bytes, filename: fileName),
    });
    final response = await client.dio.post<List<dynamic>>(
      client.url('/api/v1/messaging/attachments'),
      data: formData,
    );
    return (response.data!.first as Map<String, dynamic>)['attachmentId'] as String;
  }

  Future<AttachmentDto> getAttachmentStatus(String attachmentId) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      client.url('/api/v1/messaging/attachments/$attachmentId'),
    );
    return AttachmentDto.fromJson(response.data!);
  }

  /// Polls until the server finishes processing the upload (thumbnailing
  /// etc), matching `FileService.pollFileStatus` on desktop. The server only
  /// reports `Pending`/`Complete` — no `Failed` state exists — so a stuck
  /// upload is bounded by [timeout] rather than an error state that never
  /// arrives.
  Future<AttachmentDto> pollAttachment(
    String attachmentId, {
    Duration timeout = const Duration(seconds: 60),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (true) {
      final status = await getAttachmentStatus(attachmentId);
      if (status.state == AttachmentState.complete) return status;
      if (DateTime.now().isAfter(deadline)) {
        throw Exception('Attachment processing timed out.');
      }
      await Future<void>.delayed(const Duration(seconds: 2));
    }
  }

  String downloadUrl(String attachmentId) =>
      client.url('/api/v1/messaging/attachments/$attachmentId/download');

  String thumbnailUrl(String attachmentId) =>
      client.url('/api/v1/messaging/attachments/$attachmentId/thumbnail');

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
