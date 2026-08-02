import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/format/api_date_time.dart';
import '../../../core/mls/mls_service.dart';
import '../../../core/mls/mls_sync_service.dart';
import '../../../core/realtime/realtime_event.dart';
import '../../../core/realtime/realtime_service.dart';
import 'message_api.dart';
import 'message_decryptor.dart';
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
  const RemoteMessageUpdated({
    required this.messageId,
    required this.content,
    this.isUndecryptable = false,
    this.isUnverifiedPlaintext = false,
  });
  final String messageId;
  final String content;

  /// The edit arrived as ciphertext this device could not open. The old text is
  /// stale and the new text is unknown, so the row has to say so rather than
  /// keep showing either.
  final bool isUndecryptable;

  /// The edit arrived as cleartext in a context this device holds a live MLS
  /// group for - see [MessageDto.isUnverifiedPlaintext].
  final bool isUnverifiedPlaintext;
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
    this.emojiId,
  });
  final String messageId;
  final String emoji;
  final String userId;
  final String? emojiId;
}

class RemoteReactionRemoved extends MessageRepositoryEvent {
  const RemoteReactionRemoved({
    required this.messageId,
    required this.emoji,
    required this.userId,
    this.emojiId,
  });
  final String messageId;
  final String emoji;
  final String userId;
  final String? emojiId;
}

class RemoteMessagePinned extends MessageRepositoryEvent {
  const RemoteMessagePinned({
    required this.messageId,
    required this.pinnedById,
    required this.pinnedAt,
  });
  final String messageId;
  final String pinnedById;
  final DateTime pinnedAt;
}

class RemoteMessageUnpinned extends MessageRepositoryEvent {
  const RemoteMessageUnpinned(this.messageId);
  final String messageId;
}

/// One instance per open thread (unlike the app-lifetime singleton
/// repositories) - messages are inherently scoped to a single thread and
/// there's no benefit to sharing state across threads that aren't open at
/// the same time. Owned and disposed by `MessageThreadBloc`.
///
/// Parameterized by *either* [conversationId] (DM) *or* [channelId] (guild
/// channel) - exactly one must be set. This is the shared-kernel seam the
/// Phase 1 plan called out: guild channel messaging in Phase 2 reuses this
/// unchanged, just constructed with `channelId` instead.
class MessageRepository {
  MessageRepository({
    required this.api,
    required RealtimeService realtimeService,
    required this.mls,
    required this.mlsSync,
    this.conversationId,
    this.channelId,
  }) : assert(
         (conversationId == null) != (channelId == null),
         'Exactly one of conversationId/channelId must be set.',
       ),
       _realtimeService = realtimeService,
       _decryptor = MessageDecryptor(mls) {
    final prefix = isChannel ? 'guild.' : 'conversation.';
    _realtimeSub = realtimeService.events
        .where((e) => e.name.startsWith(prefix))
        .listen(_handleRealtimeEvent);

    // Messages that arrived ahead of the commit that made them readable. They
    // rendered as "can't be decrypted" at the time; this is what turns those
    // rows back into text once the catch-up lands, rather than leaving them
    // unreadable forever.
    _replaySub = mlsSync.replayedMessages
        .where((e) => e.contextId == _contextId)
        .listen(
          (e) => _eventsController.add(
            RemoteMessageUpdated(
              messageId: e.messageId,
              content: e.plaintextB64,
            ),
          ),
        );
  }

  final MessageApi api;
  final MlsService mls;
  final MlsSyncService mlsSync;
  final String? conversationId;
  final String? channelId;
  final RealtimeService _realtimeService;
  final MessageDecryptor _decryptor;
  late final StreamSubscription<RealtimeEvent> _realtimeSub;
  late final StreamSubscription<MlsMessageReplayed> _replaySub;

  /// Whether this thread is end-to-end encrypted as far as this device knows.
  /// Read by the composer and the header badge.
  bool get isEncrypted => mls.isEncrypted(_contextId);

  bool get isChannel => channelId != null;

  /// The channel or conversation id, whichever this thread is. Also the MLS
  /// context id - the server keys groups, commits and Welcomes off the same
  /// value.
  String get contextId => _contextId;
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
        _emitReceived(
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
              encryptionState: payload['encryptionState'] == 'Encrypted'
                  ? MessageEncryptionState.encrypted
                  : MessageEncryptionState.plain,
              // The server's `MessageCreated` contract carries `mlsGeneration`
              // but the send endpoint does not populate it, so in practice this
              // arrives null and the decryptor falls back to the generation this
              // device believes is live. Read anyway: the fallback is wrong for
              // a message that arrives moments after a toggle, and the day the
              // backend fills the field in, this starts being right for free.
              mlsGeneration: (payload['mlsGeneration'] as num?)?.toInt(),
              mlsEpoch: (payload['mlsEpoch'] as num?)?.toInt(),
              senderDeviceId: payload['senderDeviceId'] as String?,
            ),
        );
      case 'conversation.MessageUpdated' || 'guild.MessageUpdated':
        // Never emitted verbatim. `content` here is whatever the server chose
        // to broadcast, and rendering it straight into an end-to-end encrypted
        // thread - with no decrypt, no encryption-state check and no indicator -
        // let the server rewrite any message in any conversation to any text.
        _emitUpdated(
          payload['messageId'] as String,
          payload['content'] as String,
        );
      case 'conversation.MessageDeleted' || 'guild.MessageDeleted':
        _eventsController.add(
          RemoteMessageDeleted(payload['messageId'] as String),
        );
      // A moderator purge. The server has no per-message delete event for
      // guilds - bulk is the only shape it sends - so without this a purged
      // channel keeps showing every message until it's reopened.
      case 'guild.MessagesBulkDeleted':
        for (final id in (payload['messageIds'] as List? ?? const [])) {
          if (id is String) _eventsController.add(RemoteMessageDeleted(id));
        }
      case 'conversation.UserTyping' || 'guild.UserTyping':
        _eventsController.add(RemoteUserTyping(payload['userId'] as String));
      case 'conversation.ReactionCreated' || 'guild.ReactionCreated':
        _eventsController.add(
          RemoteReactionAdded(
            messageId: payload['messageId'] as String,
            emoji: payload['emoji'] as String,
            userId: payload['userId'] as String,
            emojiId: payload['emojiId'] as String?,
          ),
        );
      case 'conversation.ReactionRemoved' || 'guild.ReactionRemoved':
        _eventsController.add(
          RemoteReactionRemoved(
            messageId: payload['messageId'] as String,
            emoji: payload['emoji'] as String,
            userId: payload['userId'] as String,
            emojiId: payload['emojiId'] as String?,
          ),
        );
      case 'conversation.MessagePinned' || 'guild.MessagePinned':
        _eventsController.add(
          RemoteMessagePinned(
            messageId: payload['messageId'] as String,
            pinnedById: payload['pinnedById'] as String,
            pinnedAt: parseApiDateTime(payload['pinnedAt'] as String),
          ),
        );
      case 'conversation.MessageUnpinned' || 'guild.MessageUnpinned':
        _eventsController.add(
          RemoteMessageUnpinned(payload['messageId'] as String),
        );
    }
  }

  /// Decryption is chained rather than fired off per event so messages reach
  /// the bloc in the order they arrived. Two ciphertexts decrypting at
  /// different speeds would otherwise be able to swap places in the timeline.
  Future<void> _decryptChain = Future<void>.value();

  void _emitReceived(MessageDto message) {
    // An MLS member cannot decrypt their own application message - the engine
    // refuses it - so the echo of something this device just sent would render
    // as "can't be decrypted" if it beat the REST response back. Dropping it is
    // safe and not a special case: `MessageThreadBloc` already ignores the echo
    // of our own sends, because the REST response is what confirms them.
    //
    // Only encrypted sends carry `senderDeviceId`, so plain messages are
    // untouched by this.
    final ownDeviceId = mls.deviceIdService.deviceIdOrNull;
    if (message.senderDeviceId != null &&
        message.senderDeviceId == ownDeviceId) {
      return;
    }

    _decryptChain = _decryptChain.then((_) async {
      try {
        _eventsController.add(
          RemoteMessageReceived(await _decryptor.decrypt(message)),
        );
      } catch (e) {
        debugPrint('MessageRepository: failed to decrypt ${message.id}: $e');
        _eventsController.add(
          RemoteMessageReceived(message.copyWith(isUndecryptable: true)),
        );
      }
    });
  }

  /// An edit, put through the same treatment as an arrival.
  ///
  /// Chained behind the decrypt queue for the same reason arrivals are: an edit
  /// that decrypts faster than the message it edits would apply to a row that is
  /// not there yet.
  void _emitUpdated(String messageId, String wireContent) {
    _decryptChain = _decryptChain.then((_) async {
      try {
        final result = await _decryptor.decryptEdit(
          contextId: _contextId,
          messageId: messageId,
          wireContent: wireContent,
        );
        _eventsController.add(
          RemoteMessageUpdated(
            messageId: messageId,
            content: result.content,
            isUndecryptable: result.isUndecryptable,
            isUnverifiedPlaintext: result.isUnverifiedPlaintext,
          ),
        );
      } catch (e) {
        debugPrint('MessageRepository: failed to decrypt edit of $messageId: $e');
        _eventsController.add(
          RemoteMessageUpdated(
            messageId: messageId,
            content: wireContent,
            isUndecryptable: true,
          ),
        );
      }
    });
  }

  Future<List<MessageDto>> fetchPage({int offset = 0, int limit = 50}) async {
    final page = isChannel
        ? await api.getForChannel(_contextId, offset: offset, limit: limit)
        : await api.getForConversation(_contextId, offset: offset, limit: limit);
    return _decryptor.decryptAll(page);
  }

  /// The server always base64-wraps whatever `Content` it stores when
  /// echoing/broadcasting it back (confirmed empirically - see the Phase 1
  /// messaging debug session), so a plain send passes raw plaintext here and
  /// only ever decodes, never encodes, for the wire.
  ///
  /// An encrypted send is the other branch: the content is sealed to the
  /// context's MLS group first and what goes up is base64 ciphertext.
  Future<MessageDto> send({
    required String plaintextContent,
    String? inReplyTo,
    List<AttachmentDto> attachments = const [],
    List<String> mentions = const [],
    List<String> roleMentions = const [],
    bool mentionsEveryone = false,
    bool mentionsHere = false,
  }) {
    final rest = _SendFields(
      inReplyTo: inReplyTo,
      attachments: attachments.map((a) => a.id).toList(),
      mentions: mentions,
      roleMentions: roleMentions,
      mentionsEveryone: mentionsEveryone,
      mentionsHere: mentionsHere,
    );

    if (!isEncrypted) return _sendPlain(plaintextContent, rest);
    return _sendEncrypted(plaintextContent, rest);
  }

  Future<MessageDto> _sendPlain(String plaintext, _SendFields rest) =>
      api.create(
        content: plaintext,
        conversationId: conversationId,
        channelId: channelId,
        inReplyTo: rest.inReplyTo,
        attachments: rest.attachments,
        mentions: rest.mentions,
        roleMentions: rest.roleMentions,
        mentionsEveryone: rest.mentionsEveryone,
        mentionsHere: rest.mentionsHere,
      );

  /// Encrypts and posts, retrying once against refreshed state.
  ///
  /// The server refuses a message whose encryption does not match the context's
  /// - which is exactly what happens when encryption was toggled while this
  /// client was composing. That is a stale view, not a real failure, so it
  /// re-reads the state and sends again rather than surfacing an error the user
  /// can do nothing about.
  Future<MessageDto> _sendEncrypted(String plaintext, _SendFields rest) async {
    Future<MessageDto> attempt() async {
      final generation = mls.knownGeneration(_contextId);
      if (generation == null) {
        // Encryption was turned off under us between the check and here.
        return _sendPlain(plaintext, rest);
      }

      final groupId = mls.groupId(_contextId, generation);
      if (groupId == null) {
        throw StateError(
          'No MLS group for $_contextId generation $generation - this device '
          'has not been admitted to it',
        );
      }

      final plaintextB64 = base64Encode(utf8.encode(plaintext));
      final sealed = await mls.encrypt(
        groupIdB64: groupId,
        plaintextB64: plaintextB64,
      );

      final confirmed = await api.create(
        content: sealed.ciphertext,
        conversationId: conversationId,
        channelId: channelId,
        inReplyTo: rest.inReplyTo,
        attachments: rest.attachments,
        mentions: rest.mentions,
        roleMentions: rest.roleMentions,
        mentionsEveryone: rest.mentionsEveryone,
        mentionsHere: rest.mentionsHere,
        encrypted: true,
        mlsGeneration: generation,
        mlsEpoch: sealed.epoch,
        senderDeviceId: mls.deviceIdService.deviceIdOrNull,
      );

      // Keep the plaintext for display. The server stores ciphertext and MLS
      // ratchets forward only, so this is the one moment we can cache it -
      // after this, our own message is as unreadable to us as anyone else's.
      mls.cacheMessage(
        contextId: _contextId,
        generation: generation,
        messageId: confirmed.id,
        plaintextB64: plaintextB64,
      );
      return confirmed.copyWith(content: plaintextB64);
    }

    try {
      return await attempt();
    } on MlsSendConflictException {
      await mlsSync.refreshState(_contextId, isChannel);
      return attempt();
    }
  }

  /// Uploads and waits for processing on one file, for the composer's
  /// attachment picker - the returned [AttachmentDto] already has its final
  /// `url`, so it can be used directly both in the optimistic local message
  /// and as the id passed to [send].
  Future<int> publishMessage(String messageId) => api.publishMessage(messageId);

  Future<AttachmentDto> uploadAttachment({
    required List<int> bytes,
    required String fileName,
  }) async {
    final id = await api.uploadAttachment(bytes: bytes, fileName: fileName);
    return api.pollAttachment(id);
  }

  /// Builds the optimistic local entry with the right context id filled in
  /// - callers (`MessageThreadBloc`) shouldn't need to know which mode
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

  /// Server-side full-text search, which only ever indexes plaintext - an
  /// encrypted context always comes back empty rather than erroring. `ThreadView`
  /// is what refuses to open the search screen there in the first place.
  Future<List<MessageDto>> search(String query) async {
    final results = isChannel
        ? await api.searchChannel(_contextId, query)
        : await api.searchConversation(_contextId, query);
    return _decryptor.decryptAll(results);
  }

  /// Edits a message, sealing the new text when the thread is encrypted.
  ///
  /// This used to post the replacement in **cleartext** regardless. The server
  /// keeps the row's `EncryptionState`, so the edit was stored as an encrypted
  /// message whose content was readable plaintext - every other member's client
  /// would try to decrypt it and fail, and the server got the new text of any
  /// message in any E2EE conversation for free.
  ///
  /// [mlsGeneration] is the generation the *original* message was sealed under.
  /// The row keeps its own `mlsGeneration`, so sealing under whatever is live
  /// now would produce ciphertext every reader resolves to the wrong group after
  /// encryption has been toggled. Falling back to the live generation is only
  /// for callers that do not have the original to hand.
  Future<MessageDto> editMessage(
    String messageId,
    String plaintextContent, {
    int? mlsGeneration,
  }) async {
    final generation = mlsGeneration ?? mls.knownGeneration(_contextId);
    final groupId = generation == null
        ? null
        : mls.groupId(_contextId, generation);

    if (!isEncrypted || groupId == null) {
      // Genuinely a cleartext thread, or an edit of cleartext history from
      // before encryption was switched on.
      return api.update(messageId: messageId, content: plaintextContent);
    }

    final plaintextB64 = base64Encode(utf8.encode(plaintextContent));
    final sealed = await mls.encrypt(
      groupIdB64: groupId,
      plaintextB64: plaintextB64,
    );
    final confirmed = await api.update(
      messageId: messageId,
      content: sealed.ciphertext,
    );

    // Overwrites the pre-edit plaintext. MLS reads a message off the wire once,
    // and this device is the one that just produced the new text, so if it is
    // not written here it is gone.
    mls.cacheMessage(
      contextId: _contextId,
      generation: generation,
      messageId: messageId,
      plaintextB64: plaintextB64,
    );
    return confirmed.copyWith(content: plaintextB64);
  }

  Future<void> deleteMessage(String messageId) => api.delete(messageId);

  /// Used to resolve a reply reference that's scrolled out of the currently
  /// loaded page - mirrors Alpine's `MessageStore.getOrFetchMessage`.
  Future<MessageDto> getMessageById(String messageId) async {
    final message = isChannel
        ? await api.getChannelMessage(
            channelId: _contextId,
            messageId: messageId,
          )
        : await api.getConversationMessage(
            conversationId: _contextId,
            messageId: messageId,
          );
    return _decryptor.decrypt(message);
  }

  Future<void> addReaction(String messageId, String emoji, {String? emojiId}) =>
      api.addReaction(
        messageId: messageId,
        emoji: emojiId != null ? null : emoji,
        emojiId: emojiId,
        conversationId: conversationId,
        channelId: channelId,
      );

  Future<void> removeReaction(String messageId, String emoji) =>
      api.removeReaction(
        messageId: messageId,
        emoji: emoji,
        contextId: _contextId,
        channelId: channelId,
      );

  /// Idempotent - pinning an already-pinned message just returns its
  /// current pin state.
  Future<void> pinMessage(String messageId) => api.pinMessage(messageId);

  Future<void> unpinMessage(String messageId) => api.unpinMessage(messageId);

  Future<List<MessageDto>> getPinnedMessages() async {
    final pinned = isChannel
        ? await api.getPinnedMessages(channelId: _contextId)
        : await api.getPinnedMessages(conversationId: _contextId);
    return _decryptor.decryptAll(pinned);
  }

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
    _replaySub.cancel();
    _eventsController.close();
  }
}

/// Everything about a send that is the same whether or not it is encrypted.
/// Bundled so the two branches cannot drift apart in which fields they forward.
class _SendFields {
  const _SendFields({
    required this.inReplyTo,
    required this.attachments,
    required this.mentions,
    required this.roleMentions,
    required this.mentionsEveryone,
    required this.mentionsHere,
  });

  final String? inReplyTo;
  final List<String> attachments;
  final List<String> mentions;
  final List<String> roleMentions;
  final bool mentionsEveryone;
  final bool mentionsHere;
}
