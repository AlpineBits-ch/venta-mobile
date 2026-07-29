import 'dart:async';

import '../../../core/realtime/realtime_event.dart';
import '../../../core/realtime/realtime_service.dart';
import 'message_api.dart';
import 'models/attachment_dto.dart';
import 'models/message_dto.dart';

sealed class MessageRepositoryEvent {
  const MessageRepositoryEvent();
}

class RemoteMessageReceived extends MessageRepositoryEvent {
  const RemoteMessageReceived(this.message);
  final MessageDto message;
}

class RemoteMessageUpdated extends MessageRepositoryEvent {
  const RemoteMessageUpdated({required this.messageId, required this.content});
  final String messageId;
  final String content;
}

class RemoteMessageDeleted extends MessageRepositoryEvent {
  const RemoteMessageDeleted(this.messageId);
  final String messageId;
}

class RemoteUserTyping extends MessageRepositoryEvent {
  const RemoteUserTyping(this.userId);
  final String userId;
}

class RemoteReactionAdded extends MessageRepositoryEvent {
  const RemoteReactionAdded({
    required this.messageId,
    required this.emoji,
    required this.userId,
  });
  final String messageId;
  final String emoji;
  final String userId;
}

class RemoteReactionRemoved extends MessageRepositoryEvent {
  const RemoteReactionRemoved({
    required this.messageId,
    required this.emoji,
    required this.userId,
  });
  final String messageId;
  final String emoji;
  final String userId;
}

/// One instance per open thread (unlike the app-lifetime singleton
/// repositories) — messages are inherently scoped to a single thread and
/// there's no benefit to sharing state across threads that aren't open at
/// the same time. Owned and disposed by `MessageThreadBloc`.
///
/// Parameterized by *either* [conversationId] (DM) *or* [channelId] (guild
/// channel) — exactly one must be set. This is the shared-kernel seam the
/// Phase 1 plan called out: guild channel messaging in Phase 2 reuses this
/// unchanged, just constructed with `channelId` instead.
class MessageRepository {
  MessageRepository({
    required this.api,
    required RealtimeService realtimeService,
    this.conversationId,
    this.channelId,
  }) : assert(
         (conversationId == null) != (channelId == null),
         'Exactly one of conversationId/channelId must be set.',
       ),
       _realtimeService = realtimeService {
    final prefix = isChannel ? 'guild.' : 'conversation.';
    _realtimeSub = realtimeService.events
        .where((e) => e.name.startsWith(prefix))
        .listen(_handleRealtimeEvent);
  }

  final MessageApi api;
  final String? conversationId;
  final String? channelId;
  final RealtimeService _realtimeService;
  late final StreamSubscription<RealtimeEvent> _realtimeSub;

  bool get isChannel => channelId != null;
  String get _contextId => (channelId ?? conversationId)!;
  String get _contextKey => isChannel ? 'channelId' : 'conversationId';
  String get _methodPrefix => isChannel ? 'guild' : 'conversation';

  final _eventsController =
      StreamController<MessageRepositoryEvent>.broadcast();
  Stream<MessageRepositoryEvent> get events => _eventsController.stream;

  void _handleRealtimeEvent(RealtimeEvent event) {
    final payload = event.objectPayload;
    if (payload[_contextKey] != _contextId) return;

    switch (event.name) {
      case 'conversation.MessageCreated' || 'guild.MessageCreated':
        _eventsController.add(
          RemoteMessageReceived(
            MessageDto(
              id: payload['messageId'] as String,
              content: payload['content'] as String,
              conversationId: payload['conversationId'] as String?,
              channelId: payload['channelId'] as String?,
              authorId: payload['authorId'] as String,
              createdAt: DateTime.now(),
              inReplyTo: payload['inReplyTo'] as String?,
              mentions:
                  (payload['mentions'] as List?)?.cast<String>() ?? const [],
              roleMentions:
                  (payload['roleMentions'] as List?)?.cast<String>() ??
                  const [],
              mentionsEveryone: payload['mentionsEveryone'] as bool? ?? false,
              mentionsHere: payload['mentionsHere'] as bool? ?? false,
              attachments:
                  (payload['attachments'] as List?)
                      ?.map(
                        (a) => AttachmentDto.fromJson(
                          (a as Map).cast<String, dynamic>(),
                        ),
                      )
                      .toList() ??
                  const [],
              authorIdType: payload['authorIdType'] == 'Bot'
                  ? MessageAuthorType.bot
                  : MessageAuthorType.standard,
            ),
          ),
        );
      case 'conversation.MessageUpdated' || 'guild.MessageUpdated':
        _eventsController.add(
          RemoteMessageUpdated(
            messageId: payload['messageId'] as String,
            content: payload['content'] as String,
          ),
        );
      case 'conversation.MessageDeleted' || 'guild.MessageDeleted':
        _eventsController.add(
          RemoteMessageDeleted(payload['messageId'] as String),
        );
      case 'conversation.UserTyping' || 'guild.UserTyping':
        _eventsController.add(RemoteUserTyping(payload['userId'] as String));
      case 'conversation.ReactionCreated' || 'guild.ReactionCreated':
        _eventsController.add(
          RemoteReactionAdded(
            messageId: payload['messageId'] as String,
            emoji: payload['emoji'] as String,
            userId: payload['userId'] as String,
          ),
        );
      case 'conversation.ReactionRemoved' || 'guild.ReactionRemoved':
        _eventsController.add(
          RemoteReactionRemoved(
            messageId: payload['messageId'] as String,
            emoji: payload['emoji'] as String,
            userId: payload['userId'] as String,
          ),
        );
    }
  }

  Future<List<MessageDto>> fetchPage({int offset = 0, int limit = 50}) =>
      isChannel
      ? api.getForChannel(_contextId, offset: offset, limit: limit)
      : api.getForConversation(_contextId, offset: offset, limit: limit);

  /// The server always base64-wraps whatever `Content` it stores when
  /// echoing/broadcasting it back (confirmed empirically — see the Phase 1
  /// messaging debug session), so the client sends raw plaintext here and
  /// only ever decodes, never encodes, for the wire. `MessageContentCodec`
  /// stays the single seam for both, ready for MLS ciphertext later.
  Future<MessageDto> send({
    required String plaintextContent,
    String? inReplyTo,
    List<AttachmentDto> attachments = const [],
    List<String> mentions = const [],
    List<String> roleMentions = const [],
    bool mentionsEveryone = false,
    bool mentionsHere = false,
  }) {
    return api.create(
      content: plaintextContent,
      conversationId: conversationId,
      channelId: channelId,
      inReplyTo: inReplyTo,
      attachments: attachments.map((a) => a.id).toList(),
      mentions: mentions,
      roleMentions: roleMentions,
      mentionsEveryone: mentionsEveryone,
      mentionsHere: mentionsHere,
    );
  }

  /// Uploads and waits for processing on one file, for the composer's
  /// attachment picker — the returned [AttachmentDto] already has its final
  /// `url`, so it can be used directly both in the optimistic local message
  /// and as the id passed to [send].
  Future<AttachmentDto> uploadAttachment({
    required List<int> bytes,
    required String fileName,
  }) async {
    final id = await api.uploadAttachment(bytes: bytes, fileName: fileName);
    return api.pollAttachment(id);
  }

  /// Builds the optimistic local entry with the right context id filled in
  /// — callers (`MessageThreadBloc`) shouldn't need to know which mode
  /// they're in.
  MessageDto buildOptimistic({
    required String id,
    required String authorId,
    required String encodedContent,
    List<AttachmentDto> attachments = const [],
    String? inReplyTo,
    List<String> mentions = const [],
    List<String> roleMentions = const [],
    bool mentionsEveryone = false,
    bool mentionsHere = false,
  }) {
    return MessageDto(
      id: id,
      content: encodedContent,
      conversationId: conversationId,
      channelId: channelId,
      authorId: authorId,
      createdAt: DateTime.now(),
      isPending: true,
      attachments: attachments,
      inReplyTo: inReplyTo,
      mentions: mentions,
      roleMentions: roleMentions,
      mentionsEveryone: mentionsEveryone,
      mentionsHere: mentionsHere,
    );
  }

  Future<List<MessageDto>> search(String query) => isChannel
      ? api.searchChannel(_contextId, query)
      : api.searchConversation(_contextId, query);

  Future<MessageDto> editMessage(String messageId, String plaintextContent) =>
      api.update(messageId: messageId, content: plaintextContent);

  Future<void> deleteMessage(String messageId) => api.delete(messageId);

  /// Used to resolve a reply reference that's scrolled out of the currently
  /// loaded page — mirrors Alpine's `MessageStore.getOrFetchMessage`.
  Future<MessageDto> getMessageById(String messageId) => isChannel
      ? api.getChannelMessage(channelId: _contextId, messageId: messageId)
      : api.getConversationMessage(
          conversationId: _contextId,
          messageId: messageId,
        );

  Future<void> addReaction(String messageId, String emoji) => api.addReaction(
    messageId: messageId,
    emoji: emoji,
    conversationId: conversationId,
    channelId: channelId,
  );

  Future<void> removeReaction(String messageId, String emoji) =>
      api.removeReaction(
        messageId: messageId,
        emoji: emoji,
        contextId: _contextId,
      );

  Future<void> sendTypingIndicator() =>
      _realtimeService.invoke('$_methodPrefix.StartTyping', args: [_contextId]);

  Future<void> updateLastRead(String messageId) => _realtimeService.invoke(
    '$_methodPrefix.UpdateLastRead',
    args: [
      {_contextKey: _contextId, 'id': messageId},
    ],
  );

  void dispose() {
    _realtimeSub.cancel();
    _eventsController.close();
  }
}
