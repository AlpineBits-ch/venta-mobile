import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import 'models/attachment_dto.dart';
import 'models/message_dto.dart';

/// Thrown by [MessageApi.create] on a `403 automod_blocked` - guild-channel
/// sends only, a guild's auto-moderation rejected this message instead of
/// creating it. [reason] is `'blocked_word'` or `'rate_limited'`.
class AutoModBlockedException implements Exception {
  AutoModBlockedException(this.reason);

  final String reason;

  String get message => switch (reason) {
    'blocked_word' => 'Your message contains a word that isn\'t allowed here.',
    'rate_limited' =>
      'You\'re sending messages too quickly - try again in '
          'a moment.',
    _ => 'That message was blocked by this server\'s auto-moderation.',
  };
}

/// Thrown when a send's encryption does not match the context's.
///
/// Always a stale view rather than a real failure: it means encryption was
/// toggled while this client was composing. The caller refreshes its MLS state
/// and sends again - the server is refusing to store plaintext in a room
/// everyone believes is encrypted, or ciphertext nobody joining later can read.
class MlsSendConflictException implements Exception {
  const MlsSendConflictException({
    required this.contextId,
    required this.encrypted,
    required this.activeGeneration,
    required this.reason,
  });

  final String contextId;

  /// What the context's state actually is.
  final bool encrypted;
  final int? activeGeneration;
  final String reason;

  @override
  String toString() => 'MlsSendConflictException($reason)';
}

class MessageApi {
  MessageApi({required this.client});

  final ApiClient client;

  /// Posts a message.
  ///
  /// [content] is plaintext for a plain send and base64 MLS ciphertext for an
  /// encrypted one; [encrypted] is what tells the server which it is, and the
  /// server refuses a mismatch against the context's actual state rather than
  /// storing readable content in a room everyone believes is encrypted. That
  /// refusal is a [MlsSendConflictException], which the caller answers by
  /// refreshing its MLS state and retrying - not by surfacing an error.
  Future<MessageDto> create({
    required String content,
    String? conversationId,
    String? channelId,
    String? inReplyTo,
    List<String> attachments = const [],
    List<String> mentions = const [],
    List<String> roleMentions = const [],
    bool mentionsEveryone = false,
    bool mentionsHere = false,
    bool encrypted = false,
    int? mlsGeneration,
    int? mlsEpoch,
    String? senderDeviceId,
  }) async {
    try {
      final response = await client.dio.post<Map<String, dynamic>>(
        client.url('/api/v1/messaging/messaging'),
        data: {
          'content': content,
          'conversationId': conversationId,
          'channelId': channelId,
          'attachments': attachments,
          'inReplyTo': inReplyTo,
          'mentions': mentions,
          'roleMentions': roleMentions,
          'mentionsEveryone': mentionsEveryone,
          'mentionsHere': mentionsHere,
          'encryptionState': encrypted ? 'Encrypted' : 'Plain',
          'mlsGeneration': ?mlsGeneration,
          'mlsEpoch': ?mlsEpoch,
          'senderDeviceId': ?senderDeviceId,
        },
      );
      return MessageDto.fromJson(response.data!);
    } on DioException catch (e) {
      final data = e.response?.data;
      if (e.response?.statusCode == 403 &&
          data is Map &&
          data['error'] == 'automod_blocked') {
        throw AutoModBlockedException(data['reason']?.toString() ?? '');
      }
      if (e.response?.statusCode == 409 && data is Map) {
        throw MlsSendConflictException(
          contextId: data['contextId']?.toString() ?? '',
          encrypted: data['encrypted'] as bool? ?? false,
          activeGeneration: data['activeGeneration'] as int?,
          reason: data['reason']?.toString() ?? '',
        );
      }
      rethrow;
    }
  }

  /// Uploads one file and returns its attachment id - call [pollAttachment]
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
    return (response.data!.first as Map<String, dynamic>)['attachmentId']
        as String;
  }

  Future<AttachmentDto> getAttachmentStatus(String attachmentId) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      client.url('/api/v1/messaging/attachments/$attachmentId'),
    );
    return AttachmentDto.fromJson(response.data!);
  }

  /// Polls until the server finishes processing the upload (thumbnailing
  /// etc), matching `FileService.pollFileStatus` on desktop. The server only
  /// reports `Pending`/`Complete` - no `Failed` state exists - so a stuck
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

  Future<MessageDto> update({
    required String messageId,
    required String content,
  }) async {
    final response = await client.dio.put<Map<String, dynamic>>(
      client.url('/api/v1/messaging/messaging/$messageId'),
      data: {'content': content},
    );
    return MessageDto.fromJson(response.data!);
  }

  Future<void> delete(String messageId) {
    return client.dio.delete<void>(
      client.url('/api/v1/messaging/messaging/$messageId'),
    );
  }

  /// Copies [messageId] into every channel currently following its
  /// (Announcement) channel. Returns the number of channels it landed in -
  /// `0` is a valid response, it just means nobody follows that channel yet.
  Future<int> publishMessage(String messageId) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      client.url('/api/v1/messaging/messaging/$messageId/publish'),
    );
    return response.data!['published'] as int;
  }

  /// Uses Postgres `websearch_to_tsquery` server-side, so plain search-engine
  /// syntax works: quoted phrases, `-exclude`, `or`. Only `Plain`-encryption
  /// messages are indexed - MLS-encrypted conversations always come back
  /// empty (the server can't read ciphertext), not an error.
  Future<List<MessageDto>> searchConversation(
    String conversationId,
    String query, {
    int limit = 25,
  }) async {
    final response = await client.dio.get<List<dynamic>>(
      client.url(
        '/api/v1/messaging/messaging/search?query=${Uri.encodeQueryComponent(query)}&conversationId=$conversationId&limit=$limit',
      ),
    );
    return response.data!
        .map((json) => MessageDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<MessageDto>> searchChannel(
    String channelId,
    String query, {
    int limit = 25,
  }) async {
    final response = await client.dio.get<List<dynamic>>(
      client.url(
        '/api/v1/messaging/messaging/search?query=${Uri.encodeQueryComponent(query)}&channelId=$channelId&limit=$limit',
      ),
    );
    return response.data!
        .map((json) => MessageDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Idempotent - pinning an already-pinned message just returns its
  /// current pin state.
  Future<void> pinMessage(String messageId) {
    return client.dio.post<void>(
      client.url('/api/v1/messaging/messaging/$messageId/pin'),
    );
  }

  Future<void> unpinMessage(String messageId) {
    return client.dio.delete<void>(
      client.url('/api/v1/messaging/messaging/$messageId/pin'),
    );
  }

  /// Exactly one of [channelId]/[conversationId] must be set. Returns up to
  /// 50, most-recently-pinned first.
  Future<List<MessageDto>> getPinnedMessages({
    String? channelId,
    String? conversationId,
  }) async {
    final query = channelId != null
        ? 'channelId=$channelId'
        : 'conversationId=$conversationId';
    final response = await client.dio.get<List<dynamic>>(
      client.url('/api/v1/messaging/messaging/pins?$query'),
    );
    return response.data!
        .map((json) => MessageDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<MessageDto> getConversationMessage({
    required String conversationId,
    required String messageId,
  }) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      client.url(
        '/api/v1/messaging/messaging/conversations/$conversationId/messages/$messageId',
      ),
    );
    return MessageDto.fromJson(response.data!);
  }

  Future<MessageDto> getChannelMessage({
    required String channelId,
    required String messageId,
  }) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      client.url(
        '/api/v1/messaging/messaging/channels/$channelId/messages/$messageId',
      ),
    );
    return MessageDto.fromJson(response.data!);
  }

  String downloadUrl(String attachmentId) =>
      client.url('/api/v1/messaging/attachments/$attachmentId/download');

  String thumbnailUrl(String attachmentId) =>
      client.url('/api/v1/messaging/attachments/$attachmentId/thumbnail');

  /// `conversationId` is sent even for a channel reaction (as `''`) to match
  /// the request shape the server expects - mirrors Alpine's
  /// `CreateReactionDto`. Exactly one of [emoji]/[emojiId] should be set:
  /// [emojiId] for a custom guild emoji (server resolves and fills in the
  /// name), [emoji] for a plain Unicode reaction. Custom emoji only work in
  /// guild channels - passing [emojiId] with [conversationId] is rejected
  /// server-side with a 400.
  Future<void> addReaction({
    required String messageId,
    String? emoji,
    String? emojiId,
    String? conversationId,
    String? channelId,
  }) {
    return client.dio.post<void>(
      client.url('/api/v1/messaging/messages/$messageId/reactions'),
      data: {
        'conversationId': conversationId ?? '',
        if (emojiId != null) 'emojiId': emojiId else 'reaction': emoji,
        if (channelId != null) 'channelId': channelId,
      },
    );
  }

  /// `contextId` is the conversationId or channelId the message belongs to
  /// - mirrors Alpine's `RemoveReactionDto`. Dio's `delete` accepts a body
  /// via `data`, matching the server's DELETE-with-body contract. [channelId]
  /// is what lets a guild-channel removal broadcast to other members in
  /// realtime (previously silently missing for all channel reactions).
  Future<void> removeReaction({
    required String messageId,
    required String emoji,
    required String contextId,
    String? channelId,
  }) {
    return client.dio.delete<void>(
      client.url('/api/v1/messaging/messages/$messageId/reactions'),
      data: {
        'reaction': emoji,
        'contextId': contextId,
        if (channelId != null) 'channelId': channelId,
      },
    );
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
