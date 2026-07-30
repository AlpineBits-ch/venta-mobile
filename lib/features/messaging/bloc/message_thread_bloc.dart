import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/sound/sound_service.dart';
import '../data/message_api.dart';
import '../data/message_content_codec.dart';
import '../data/message_repository.dart';
import '../data/models/attachment_dto.dart';
import '../data/models/message_dto.dart';
import '../data/models/message_reaction_dto.dart';

sealed class ThreadEvent extends Equatable {
  const ThreadEvent();

  @override
  List<Object?> get props => [];
}

class ThreadOpened extends ThreadEvent {
  const ThreadOpened();
}

class ThreadLoadMoreRequested extends ThreadEvent {
  const ThreadLoadMoreRequested();
}

class ThreadMessageSubmitted extends ThreadEvent {
  const ThreadMessageSubmitted(
    this.text, {
    this.attachments = const [],
    this.replyToId,
    this.mentionedUserIds = const [],
    this.mentionedRoleIds = const [],
    this.mentionsEveryone = false,
    this.mentionsHere = false,
  });
  final String text;
  final List<AttachmentDto> attachments;
  final String? replyToId;
  final List<String> mentionedUserIds;
  final List<String> mentionedRoleIds;
  final bool mentionsEveryone;
  final bool mentionsHere;

  @override
  List<Object?> get props => [
    text,
    attachments,
    replyToId,
    mentionedUserIds,
    mentionedRoleIds,
    mentionsEveryone,
    mentionsHere,
  ];
}

/// Edits an existing message's content - optimistic-first like reactions,
/// rolled back to [previousText] if the HTTP call fails.
class MessageEditRequested extends ThreadEvent {
  const MessageEditRequested({required this.messageId, required this.newText});
  final String messageId;
  final String newText;

  @override
  List<Object?> get props => [messageId, newText];
}

/// Deletes a message - optimistic-first, reinserted at its original index
/// if the HTTP call fails.
class MessageDeleteRequested extends ThreadEvent {
  const MessageDeleteRequested(this.messageId);
  final String messageId;

  @override
  List<Object?> get props => [messageId];
}

class ThreadTypingNotified extends ThreadEvent {
  const ThreadTypingNotified();
}

/// Toggles the caller's own reaction on a message - adds it if they haven't
/// reacted with this emoji yet, removes it if they have. Applied optimistic-
/// first (mirrors Alpine's `toggleReaction`), rolled back if the HTTP call
/// fails. [emoji] is always the display text (a Unicode glyph, or a custom
/// emoji's name as fallback); [emojiId] is set only for a custom guild
/// emoji, in which case reactions are matched/sent by id rather than name.
class ReactionToggled extends ThreadEvent {
  const ReactionToggled({
    required this.messageId,
    required this.emoji,
    this.emojiId,
  });
  final String messageId;
  final String emoji;
  final String? emojiId;

  @override
  List<Object?> get props => [messageId, emoji, emojiId];
}

/// Toggles a message's pinned state - optimistic-first like reactions,
/// rolled back if the HTTP call fails. Guild-channel gating (`PinMessages`)
/// happens in the UI before this is even dispatched; DMs allow any member.
class MessagePinToggled extends ThreadEvent {
  const MessagePinToggled(this.messageId);
  final String messageId;

  @override
  List<Object?> get props => [messageId];
}

/// Registers a synthetic "the bot is working on it" row while a slash
/// command invocation is in flight - the caller (the composer) has already
/// fired the HTTP invoke; this just reserves the placeholder + starts the
/// await-with-timeout. The real reply resolves it via the normal
/// `guild.MessageCreated` realtime path in [_onMessageReceived] once the bot
/// posts (there's no correlation id from the server - see `BotCommandApi`).
class ThreadBotPlaceholderAdded extends ThreadEvent {
  const ThreadBotPlaceholderAdded({
    required this.tempId,
    required this.botUserId,
  });
  final String tempId;
  final String botUserId;

  @override
  List<Object?> get props => [tempId, botUserId];
}

/// The invoke HTTP call itself failed before the server could even accept
/// it - resolves the placeholder as failed immediately rather than waiting
/// out the full timeout.
class ThreadBotPlaceholderFailed extends ThreadEvent {
  const ThreadBotPlaceholderFailed(this.tempId);
  final String tempId;

  @override
  List<Object?> get props => [tempId];
}

class _BotPlaceholderTimedOut extends ThreadEvent {
  const _BotPlaceholderTimedOut(this.tempId);
  final String tempId;

  @override
  List<Object?> get props => [tempId];
}

class _MessageReceived extends ThreadEvent {
  const _MessageReceived(this.message);
  final MessageDto message;

  @override
  List<Object?> get props => [message];
}

class _MessageUpdatedRemote extends ThreadEvent {
  const _MessageUpdatedRemote({required this.messageId, required this.content});
  final String messageId;
  final String content;

  @override
  List<Object?> get props => [messageId, content];
}

class _MessageDeletedRemote extends ThreadEvent {
  const _MessageDeletedRemote(this.messageId);
  final String messageId;

  @override
  List<Object?> get props => [messageId];
}

class _UserTypingRemote extends ThreadEvent {
  const _UserTypingRemote(this.userId);
  final String userId;

  @override
  List<Object?> get props => [userId];
}

class _ReactionAddedRemote extends ThreadEvent {
  const _ReactionAddedRemote({
    required this.messageId,
    required this.emoji,
    required this.userId,
    this.emojiId,
  });
  final String messageId;
  final String emoji;
  final String userId;
  final String? emojiId;

  @override
  List<Object?> get props => [messageId, emoji, userId, emojiId];
}

class _ReactionRemovedRemote extends ThreadEvent {
  const _ReactionRemovedRemote({
    required this.messageId,
    required this.emoji,
    required this.userId,
    this.emojiId,
  });
  final String messageId;
  final String emoji;
  final String userId;
  final String? emojiId;

  @override
  List<Object?> get props => [messageId, emoji, userId, emojiId];
}

class _MessagePinnedRemote extends ThreadEvent {
  const _MessagePinnedRemote({
    required this.messageId,
    required this.pinnedById,
    required this.pinnedAt,
  });
  final String messageId;
  final String pinnedById;
  final DateTime pinnedAt;

  @override
  List<Object?> get props => [messageId, pinnedById, pinnedAt];
}

class _MessageUnpinnedRemote extends ThreadEvent {
  const _MessageUnpinnedRemote(this.messageId);
  final String messageId;

  @override
  List<Object?> get props => [messageId];
}

class _TypingExpired extends ThreadEvent {
  const _TypingExpired(this.userId);
  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// One cohesive state, not a sealed union: "loading older page", "have a
/// pending send", and "someone is typing" are all simultaneously true in a
/// real thread, so a mutually-exclusive union fits worse here than in
/// Auth/Friends - a deliberate deviation, documented for future maintainers.
class ThreadState extends Equatable {
  const ThreadState({
    this.messages = const [],
    this.isLoadingInitial = true,
    this.isLoadingMore = false,
    this.hasMoreOlder = true,
    this.pendingSendIds = const {},
    this.failedSendIds = const {},
    this.typingUserIds = const {},
    this.error,
  });

  /// Newest-first, feeds a `ListView.builder(reverse: true, ...)` directly.
  final List<MessageDto> messages;
  final bool isLoadingInitial;
  final bool isLoadingMore;
  final bool hasMoreOlder;
  final Set<String> pendingSendIds;
  final Set<String> failedSendIds;
  final Set<String> typingUserIds;
  final String? error;

  ThreadState copyWith({
    List<MessageDto>? messages,
    bool? isLoadingInitial,
    bool? isLoadingMore,
    bool? hasMoreOlder,
    Set<String>? pendingSendIds,
    Set<String>? failedSendIds,
    Set<String>? typingUserIds,
    String? error,
  }) => ThreadState(
    messages: messages ?? this.messages,
    isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    hasMoreOlder: hasMoreOlder ?? this.hasMoreOlder,
    pendingSendIds: pendingSendIds ?? this.pendingSendIds,
    failedSendIds: failedSendIds ?? this.failedSendIds,
    typingUserIds: typingUserIds ?? this.typingUserIds,
    error: error,
  );

  @override
  List<Object?> get props => [
    messages,
    isLoadingInitial,
    isLoadingMore,
    hasMoreOlder,
    pendingSendIds,
    failedSendIds,
    typingUserIds,
    error,
  ];
}

class MessageThreadBloc extends Bloc<ThreadEvent, ThreadState> {
  MessageThreadBloc({
    required this.repository,
    required this.myUserId,
    required this.soundService,
  }) : super(const ThreadState()) {
    on<ThreadOpened>(_onOpened);
    on<ThreadLoadMoreRequested>(_onLoadMoreRequested);
    on<ThreadMessageSubmitted>(_onMessageSubmitted);
    on<MessageEditRequested>(_onMessageEditRequested);
    on<MessageDeleteRequested>(_onMessageDeleteRequested);
    on<ThreadTypingNotified>(_onTypingNotified);
    on<ReactionToggled>(_onReactionToggled);
    on<MessagePinToggled>(_onMessagePinToggled);
    on<ThreadBotPlaceholderAdded>(_onBotPlaceholderAdded);
    on<ThreadBotPlaceholderFailed>(_onBotPlaceholderFailed);
    on<_BotPlaceholderTimedOut>(_onBotPlaceholderTimedOut);
    on<_MessageReceived>(_onMessageReceived);
    on<_MessageUpdatedRemote>(_onMessageUpdatedRemote);
    on<_MessageDeletedRemote>(_onMessageDeletedRemote);
    on<_UserTypingRemote>(_onUserTypingRemote);
    on<_TypingExpired>(_onTypingExpired);
    on<_ReactionAddedRemote>(_onReactionAddedRemote);
    on<_ReactionRemovedRemote>(_onReactionRemovedRemote);
    on<_MessagePinnedRemote>(_onMessagePinnedRemote);
    on<_MessageUnpinnedRemote>(_onMessageUnpinnedRemote);

    _repoSub = repository.events.listen((event) {
      switch (event) {
        case RemoteMessageReceived():
          add(_MessageReceived(event.message));
        case RemoteMessageUpdated():
          add(
            _MessageUpdatedRemote(
              messageId: event.messageId,
              content: event.content,
            ),
          );
        case RemoteMessageDeleted():
          add(_MessageDeletedRemote(event.messageId));
        case RemoteUserTyping():
          add(_UserTypingRemote(event.userId));
        case RemoteReactionAdded():
          add(
            _ReactionAddedRemote(
              messageId: event.messageId,
              emoji: event.emoji,
              userId: event.userId,
              emojiId: event.emojiId,
            ),
          );
        case RemoteReactionRemoved():
          add(
            _ReactionRemovedRemote(
              messageId: event.messageId,
              emoji: event.emoji,
              userId: event.userId,
              emojiId: event.emojiId,
            ),
          );
        case RemoteMessagePinned():
          add(
            _MessagePinnedRemote(
              messageId: event.messageId,
              pinnedById: event.pinnedById,
              pinnedAt: event.pinnedAt,
            ),
          );
        case RemoteMessageUnpinned():
          add(_MessageUnpinnedRemote(event.messageId));
      }
    });

    add(const ThreadOpened());
  }

  final MessageRepository repository;
  final String myUserId;
  final SoundService soundService;
  late final StreamSubscription<MessageRepositoryEvent> _repoSub;
  final Map<String, Timer> _typingTimers = {};
  int _tempIdCounter = 0;

  /// FIFO queue of pending placeholder temp-ids per bot user id - a bot's
  /// next `MessageCreated` resolves its oldest still-pending placeholder.
  final Map<String, List<String>> _pendingBotTempIdsByBot = {};
  final Map<String, Timer> _botTimeoutTimers = {};

  Future<void> _onOpened(ThreadOpened event, Emitter<ThreadState> emit) async {
    try {
      final page = await repository.fetchPage();
      final sorted = _sortNewestFirst(page);
      emit(
        state.copyWith(
          messages: sorted,
          isLoadingInitial: false,
          hasMoreOlder: page.length >= 50,
        ),
      );
      unawaited(_markRead());
    } catch (_) {
      emit(
        state.copyWith(
          isLoadingInitial: false,
          error: 'Could not load messages.',
        ),
      );
    }
  }

  Future<void> _onLoadMoreRequested(
    ThreadLoadMoreRequested event,
    Emitter<ThreadState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasMoreOlder) return;
    emit(state.copyWith(isLoadingMore: true));
    try {
      final page = await repository.fetchPage(offset: state.messages.length);
      final merged = _sortNewestFirst([...state.messages, ...page]);
      emit(
        state.copyWith(
          messages: merged,
          isLoadingMore: false,
          hasMoreOlder: page.length >= 50,
        ),
      );
    } catch (_) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onMessageSubmitted(
    ThreadMessageSubmitted event,
    Emitter<ThreadState> emit,
  ) async {
    final text = event.text.trim();
    if (text.isEmpty && event.attachments.isEmpty) return;

    final tempId = 'pending-${_tempIdCounter++}';
    final optimistic = repository.buildOptimistic(
      id: tempId,
      authorId: myUserId,
      encodedContent: MessageContentCodec.encode(text),
      attachments: event.attachments,
      inReplyTo: event.replyToId,
      mentions: event.mentionedUserIds,
      roleMentions: event.mentionedRoleIds,
      mentionsEveryone: event.mentionsEveryone,
      mentionsHere: event.mentionsHere,
    );
    emit(
      state.copyWith(
        messages: [optimistic, ...state.messages],
        pendingSendIds: {...state.pendingSendIds, tempId},
      ),
    );

    try {
      final sent = await repository.send(
        plaintextContent: text,
        attachments: event.attachments,
        inReplyTo: event.replyToId,
        mentions: event.mentionedUserIds,
        roleMentions: event.mentionedRoleIds,
        mentionsEveryone: event.mentionsEveryone,
        mentionsHere: event.mentionsHere,
      );
      emit(
        state.copyWith(
          messages: [
            for (final m in state.messages)
              if (m.id == tempId) sent else m,
          ],
          pendingSendIds: {...state.pendingSendIds}..remove(tempId),
        ),
      );
    } on AutoModBlockedException catch (e) {
      // Retrying identical blocked content would just fail again, so drop
      // the optimistic bubble entirely rather than leaving a permanently
      // "failed, tap to retry" message sitting in the thread.
      emit(
        state.copyWith(
          messages: [
            for (final m in state.messages)
              if (m.id != tempId) m,
          ],
          pendingSendIds: {...state.pendingSendIds}..remove(tempId),
          error: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          pendingSendIds: {...state.pendingSendIds}..remove(tempId),
          failedSendIds: {...state.failedSendIds, tempId},
        ),
      );
    }
  }

  Future<void> _onTypingNotified(
    ThreadTypingNotified event,
    Emitter<ThreadState> emit,
  ) async {
    await repository.sendTypingIndicator();
  }

  Future<void> _onReactionToggled(
    ReactionToggled event,
    Emitter<ThreadState> emit,
  ) async {
    final hasOwn = state.messages.any(
      (m) =>
          m.id == event.messageId &&
          m.reactions.any(
            (r) =>
                _sameReaction(r, event.emoji, event.emojiId) &&
                r.userId == myUserId,
          ),
    );

    emit(
      state.copyWith(
        messages: _withReactions(
          event.messageId,
          (reactions) => hasOwn
              ? reactions
                    .where(
                      (r) =>
                          !(_sameReaction(r, event.emoji, event.emojiId) &&
                              r.userId == myUserId),
                    )
                    .toList()
              : [
                  ...reactions,
                  MessageReactionDto(
                    messageId: event.messageId,
                    emoji: event.emoji,
                    emojiId: event.emojiId,
                    userId: myUserId,
                    createdAt: DateTime.now(),
                  ),
                ],
        ),
      ),
    );

    try {
      if (hasOwn) {
        await repository.removeReaction(event.messageId, event.emoji);
      } else {
        await repository.addReaction(
          event.messageId,
          event.emoji,
          emojiId: event.emojiId,
        );
      }
    } catch (_) {
      // Roll back to the pre-toggle state.
      emit(
        state.copyWith(
          messages: _withReactions(
            event.messageId,
            (reactions) => hasOwn
                ? [
                    ...reactions,
                    MessageReactionDto(
                      messageId: event.messageId,
                      emoji: event.emoji,
                      emojiId: event.emojiId,
                      userId: myUserId,
                      createdAt: DateTime.now(),
                    ),
                  ]
                : reactions
                      .where(
                        (r) =>
                            !(_sameReaction(r, event.emoji, event.emojiId) &&
                                r.userId == myUserId),
                      )
                      .toList(),
          ),
        ),
      );
    }
  }

  Future<void> _onMessagePinToggled(
    MessagePinToggled event,
    Emitter<ThreadState> emit,
  ) async {
    final previous = state.messages
        .where((m) => m.id == event.messageId)
        .firstOrNull;
    if (previous == null) return;
    final wasPinned = previous.isPinned;

    emit(
      state.copyWith(
        messages: _updateMessage(
          event.messageId,
          (m) => wasPinned
              ? m.copyWith(isPinned: false, pinnedAt: null, pinnedById: null)
              : m.copyWith(
                  isPinned: true,
                  pinnedAt: DateTime.now(),
                  pinnedById: myUserId,
                ),
        ),
      ),
    );

    try {
      if (wasPinned) {
        await repository.unpinMessage(event.messageId);
      } else {
        await repository.pinMessage(event.messageId);
      }
    } catch (_) {
      emit(
        state.copyWith(
          messages: _updateMessage(event.messageId, (_) => previous),
        ),
      );
    }
  }

  void _onMessagePinnedRemote(
    _MessagePinnedRemote event,
    Emitter<ThreadState> emit,
  ) {
    emit(
      state.copyWith(
        messages: _updateMessage(
          event.messageId,
          (m) => m.copyWith(
            isPinned: true,
            pinnedAt: event.pinnedAt,
            pinnedById: event.pinnedById,
          ),
        ),
      ),
    );
  }

  void _onMessageUnpinnedRemote(
    _MessageUnpinnedRemote event,
    Emitter<ThreadState> emit,
  ) {
    emit(
      state.copyWith(
        messages: _updateMessage(
          event.messageId,
          (m) => m.copyWith(isPinned: false, pinnedAt: null, pinnedById: null),
        ),
      ),
    );
  }

  /// True when [reaction] represents the same reaction as [emoji]/[emojiId]
  /// - custom guild emoji are matched by id (the `emoji` field is just a
  /// text fallback and can collide across different custom emoji with the
  /// same name), Unicode reactions by the literal glyph.
  bool _sameReaction(
    MessageReactionDto reaction,
    String emoji,
    String? emojiId,
  ) => emojiId != null
      ? reaction.emojiId == emojiId
      : reaction.emoji == emoji && reaction.emojiId == null;

  Future<void> _onMessageEditRequested(
    MessageEditRequested event,
    Emitter<ThreadState> emit,
  ) async {
    final previous = state.messages
        .where((m) => m.id == event.messageId)
        .firstOrNull;
    if (previous == null) return;

    emit(
      state.copyWith(
        messages: [
          for (final m in state.messages)
            if (m.id == event.messageId)
              m.copyWith(content: MessageContentCodec.encode(event.newText))
            else
              m,
        ],
      ),
    );

    try {
      final updated = await repository.editMessage(
        event.messageId,
        event.newText,
      );
      emit(
        state.copyWith(
          messages: [
            for (final m in state.messages)
              if (m.id == event.messageId) updated else m,
          ],
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          messages: [
            for (final m in state.messages)
              if (m.id == event.messageId) previous else m,
          ],
        ),
      );
    }
  }

  Future<void> _onMessageDeleteRequested(
    MessageDeleteRequested event,
    Emitter<ThreadState> emit,
  ) async {
    final index = state.messages.indexWhere((m) => m.id == event.messageId);
    if (index == -1) return;
    final removed = state.messages[index];

    emit(
      state.copyWith(
        messages: [
          for (final m in state.messages)
            if (m.id != event.messageId) m,
        ],
      ),
    );

    try {
      await repository.deleteMessage(event.messageId);
    } catch (_) {
      final restored = [...state.messages];
      restored.insert(index.clamp(0, restored.length), removed);
      emit(state.copyWith(messages: restored));
    }
  }

  void _onReactionAddedRemote(
    _ReactionAddedRemote event,
    Emitter<ThreadState> emit,
  ) {
    emit(
      state.copyWith(
        messages: _withReactions(event.messageId, (reactions) {
          if (reactions.any(
            (r) =>
                _sameReaction(r, event.emoji, event.emojiId) &&
                r.userId == event.userId,
          )) {
            return reactions;
          }
          return [
            ...reactions,
            MessageReactionDto(
              messageId: event.messageId,
              emoji: event.emoji,
              emojiId: event.emojiId,
              userId: event.userId,
              createdAt: DateTime.now(),
            ),
          ];
        }),
      ),
    );
  }

  void _onReactionRemovedRemote(
    _ReactionRemovedRemote event,
    Emitter<ThreadState> emit,
  ) {
    emit(
      state.copyWith(
        messages: _withReactions(
          event.messageId,
          (reactions) => reactions
              .where(
                (r) =>
                    !(_sameReaction(r, event.emoji, event.emojiId) &&
                        r.userId == event.userId),
              )
              .toList(),
        ),
      ),
    );
  }

  /// Returns [state.messages] with [messageId]'s `reactions` list replaced by
  /// running [update] over its current reactions - a no-op if the message
  /// isn't currently loaded (e.g. it scrolled out of the fetched page).
  List<MessageDto> _withReactions(
    String messageId,
    List<MessageReactionDto> Function(List<MessageReactionDto>) update,
  ) {
    return [
      for (final m in state.messages)
        if (m.id == messageId)
          m.copyWith(reactions: update(m.reactions))
        else
          m,
    ];
  }

  /// Returns [state.messages] with [messageId] replaced by running [update]
  /// over it - a no-op if the message isn't currently loaded.
  List<MessageDto> _updateMessage(
    String messageId,
    MessageDto Function(MessageDto) update,
  ) {
    return [
      for (final m in state.messages)
        if (m.id == messageId) update(m) else m,
    ];
  }

  void _onBotPlaceholderAdded(
    ThreadBotPlaceholderAdded event,
    Emitter<ThreadState> emit,
  ) {
    final placeholder = MessageDto(
      id: event.tempId,
      content: '',
      conversationId: repository.conversationId,
      channelId: repository.channelId,
      authorId: event.botUserId,
      createdAt: DateTime.now(),
      isPending: true,
      isBotCommandPlaceholder: true,
      authorIdType: MessageAuthorType.bot,
    );
    emit(
      state.copyWith(
        messages: [placeholder, ...state.messages],
        pendingSendIds: {...state.pendingSendIds, event.tempId},
      ),
    );
    _pendingBotTempIdsByBot
        .putIfAbsent(event.botUserId, () => [])
        .add(event.tempId);
    _botTimeoutTimers[event.tempId] = Timer(
      const Duration(seconds: 10),
      () => add(_BotPlaceholderTimedOut(event.tempId)),
    );
  }

  void _onBotPlaceholderFailed(
    ThreadBotPlaceholderFailed event,
    Emitter<ThreadState> emit,
  ) {
    _failBotPlaceholder(event.tempId, emit);
  }

  void _onBotPlaceholderTimedOut(
    _BotPlaceholderTimedOut event,
    Emitter<ThreadState> emit,
  ) {
    _failBotPlaceholder(event.tempId, emit);
  }

  void _failBotPlaceholder(String tempId, Emitter<ThreadState> emit) {
    if (!state.pendingSendIds.contains(tempId)) return;
    _botTimeoutTimers.remove(tempId)?.cancel();
    for (final queue in _pendingBotTempIdsByBot.values) {
      queue.remove(tempId);
    }
    emit(
      state.copyWith(
        pendingSendIds: {...state.pendingSendIds}..remove(tempId),
        failedSendIds: {...state.failedSendIds, tempId},
      ),
    );
  }

  void _onMessageReceived(_MessageReceived event, Emitter<ThreadState> emit) {
    // Our own message already landed via the REST response in
    // _onMessageSubmitted - the hub echo just needs to be ignored.
    if (state.messages.any((m) => m.id == event.message.id)) return;

    final botQueue = _pendingBotTempIdsByBot[event.message.authorId];
    if (botQueue != null && botQueue.isNotEmpty) {
      final tempId = botQueue.removeAt(0);
      _botTimeoutTimers.remove(tempId)?.cancel();
      emit(
        state.copyWith(
          messages: [
            event.message,
            for (final m in state.messages)
              if (m.id != tempId) m,
          ],
          pendingSendIds: {...state.pendingSendIds}..remove(tempId),
        ),
      );
      return;
    }

    emit(state.copyWith(messages: [event.message, ...state.messages]));
    if (event.message.authorId != myUserId) {
      unawaited(soundService.playNewMessage());
      unawaited(_markRead());
    }
  }

  void _onMessageUpdatedRemote(
    _MessageUpdatedRemote event,
    Emitter<ThreadState> emit,
  ) {
    emit(
      state.copyWith(
        messages: [
          for (final m in state.messages)
            if (m.id == event.messageId)
              m.copyWith(content: event.content)
            else
              m,
        ],
      ),
    );
  }

  void _onMessageDeletedRemote(
    _MessageDeletedRemote event,
    Emitter<ThreadState> emit,
  ) {
    emit(
      state.copyWith(
        messages: state.messages.where((m) => m.id != event.messageId).toList(),
      ),
    );
  }

  void _onUserTypingRemote(_UserTypingRemote event, Emitter<ThreadState> emit) {
    if (event.userId == myUserId) return;
    _typingTimers[event.userId]?.cancel();
    _typingTimers[event.userId] = Timer(
      const Duration(seconds: 5),
      () => add(_TypingExpired(event.userId)),
    );
    emit(state.copyWith(typingUserIds: {...state.typingUserIds, event.userId}));
  }

  void _onTypingExpired(_TypingExpired event, Emitter<ThreadState> emit) {
    emit(
      state.copyWith(
        typingUserIds: {...state.typingUserIds}..remove(event.userId),
      ),
    );
  }

  Future<void> _markRead() async {
    if (state.messages.isEmpty) return;
    await repository.updateLastRead(state.messages.first.id);
  }

  List<MessageDto> _sortNewestFirst(List<MessageDto> messages) {
    final sorted = [...messages];
    sorted.sort(
      (a, b) =>
          (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
    );
    return sorted;
  }

  @override
  Future<void> close() {
    unawaited(_repoSub.cancel());
    for (final timer in _typingTimers.values) {
      timer.cancel();
    }
    for (final timer in _botTimeoutTimers.values) {
      timer.cancel();
    }
    repository.dispose();
    return super.close();
  }
}
