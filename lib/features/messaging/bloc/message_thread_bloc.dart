import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  const ThreadMessageSubmitted(this.text, {this.attachments = const []});
  final String text;
  final List<AttachmentDto> attachments;

  @override
  List<Object?> get props => [text, attachments];
}

class ThreadTypingNotified extends ThreadEvent {
  const ThreadTypingNotified();
}

/// Toggles the caller's own reaction on a message — adds it if they haven't
/// reacted with this emoji yet, removes it if they have. Applied optimistic-
/// first (mirrors Alpine's `toggleReaction`), rolled back if the HTTP call
/// fails.
class ReactionToggled extends ThreadEvent {
  const ReactionToggled({required this.messageId, required this.emoji});
  final String messageId;
  final String emoji;

  @override
  List<Object?> get props => [messageId, emoji];
}

/// Registers a synthetic "the bot is working on it" row while a slash
/// command invocation is in flight — the caller (the composer) has already
/// fired the HTTP invoke; this just reserves the placeholder + starts the
/// await-with-timeout. The real reply resolves it via the normal
/// `guild.MessageCreated` realtime path in [_onMessageReceived] once the bot
/// posts (there's no correlation id from the server — see `BotCommandApi`).
class ThreadBotPlaceholderAdded extends ThreadEvent {
  const ThreadBotPlaceholderAdded({required this.tempId, required this.botUserId});
  final String tempId;
  final String botUserId;

  @override
  List<Object?> get props => [tempId, botUserId];
}

/// The invoke HTTP call itself failed before the server could even accept
/// it — resolves the placeholder as failed immediately rather than waiting
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
  const _ReactionAddedRemote({required this.messageId, required this.emoji, required this.userId});
  final String messageId;
  final String emoji;
  final String userId;

  @override
  List<Object?> get props => [messageId, emoji, userId];
}

class _ReactionRemovedRemote extends ThreadEvent {
  const _ReactionRemovedRemote({
    required this.messageId,
    required this.emoji,
    required this.userId,
  });
  final String messageId;
  final String emoji;
  final String userId;

  @override
  List<Object?> get props => [messageId, emoji, userId];
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
/// Auth/Friends — a deliberate deviation, documented for future maintainers.
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
  }) =>
      ThreadState(
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
  MessageThreadBloc({required this.repository, required this.myUserId})
      : super(const ThreadState()) {
    on<ThreadOpened>(_onOpened);
    on<ThreadLoadMoreRequested>(_onLoadMoreRequested);
    on<ThreadMessageSubmitted>(_onMessageSubmitted);
    on<ThreadTypingNotified>(_onTypingNotified);
    on<ReactionToggled>(_onReactionToggled);
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

    _repoSub = repository.events.listen((event) {
      switch (event) {
        case RemoteMessageReceived():
          add(_MessageReceived(event.message));
        case RemoteMessageUpdated():
          add(_MessageUpdatedRemote(messageId: event.messageId, content: event.content));
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
            ),
          );
        case RemoteReactionRemoved():
          add(
            _ReactionRemovedRemote(
              messageId: event.messageId,
              emoji: event.emoji,
              userId: event.userId,
            ),
          );
      }
    });

    add(const ThreadOpened());
  }

  final MessageRepository repository;
  final String myUserId;
  late final StreamSubscription<MessageRepositoryEvent> _repoSub;
  final Map<String, Timer> _typingTimers = {};
  int _tempIdCounter = 0;

  /// FIFO queue of pending placeholder temp-ids per bot user id — a bot's
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
      emit(state.copyWith(isLoadingInitial: false, error: 'Could not load messages.'));
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
        state.copyWith(messages: merged, isLoadingMore: false, hasMoreOlder: page.length >= 50),
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
      );
      emit(
        state.copyWith(
          messages: [for (final m in state.messages) if (m.id == tempId) sent else m],
          pendingSendIds: {...state.pendingSendIds}..remove(tempId),
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

  Future<void> _onTypingNotified(ThreadTypingNotified event, Emitter<ThreadState> emit) async {
    await repository.sendTypingIndicator();
  }

  Future<void> _onReactionToggled(ReactionToggled event, Emitter<ThreadState> emit) async {
    final hasOwn = state.messages.any(
      (m) =>
          m.id == event.messageId &&
          m.reactions.any((r) => r.emoji == event.emoji && r.userId == myUserId),
    );

    emit(
      state.copyWith(
        messages: _withReactions(
          event.messageId,
          (reactions) => hasOwn
              ? reactions.where((r) => !(r.emoji == event.emoji && r.userId == myUserId)).toList()
              : [
                  ...reactions,
                  MessageReactionDto(
                    messageId: event.messageId,
                    emoji: event.emoji,
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
        await repository.addReaction(event.messageId, event.emoji);
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
                      userId: myUserId,
                      createdAt: DateTime.now(),
                    ),
                  ]
                : reactions
                    .where((r) => !(r.emoji == event.emoji && r.userId == myUserId))
                    .toList(),
          ),
        ),
      );
    }
  }

  void _onReactionAddedRemote(_ReactionAddedRemote event, Emitter<ThreadState> emit) {
    emit(
      state.copyWith(
        messages: _withReactions(event.messageId, (reactions) {
          if (reactions.any((r) => r.emoji == event.emoji && r.userId == event.userId)) {
            return reactions;
          }
          return [
            ...reactions,
            MessageReactionDto(
              messageId: event.messageId,
              emoji: event.emoji,
              userId: event.userId,
              createdAt: DateTime.now(),
            ),
          ];
        }),
      ),
    );
  }

  void _onReactionRemovedRemote(_ReactionRemovedRemote event, Emitter<ThreadState> emit) {
    emit(
      state.copyWith(
        messages: _withReactions(
          event.messageId,
          (reactions) =>
              reactions.where((r) => !(r.emoji == event.emoji && r.userId == event.userId)).toList(),
        ),
      ),
    );
  }

  /// Returns [state.messages] with [messageId]'s `reactions` list replaced by
  /// running [update] over its current reactions — a no-op if the message
  /// isn't currently loaded (e.g. it scrolled out of the fetched page).
  List<MessageDto> _withReactions(
    String messageId,
    List<MessageReactionDto> Function(List<MessageReactionDto>) update,
  ) {
    return [
      for (final m in state.messages)
        if (m.id == messageId) m.copyWith(reactions: update(m.reactions)) else m,
    ];
  }

  void _onBotPlaceholderAdded(ThreadBotPlaceholderAdded event, Emitter<ThreadState> emit) {
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
    _pendingBotTempIdsByBot.putIfAbsent(event.botUserId, () => []).add(event.tempId);
    _botTimeoutTimers[event.tempId] = Timer(
      const Duration(seconds: 10),
      () => add(_BotPlaceholderTimedOut(event.tempId)),
    );
  }

  void _onBotPlaceholderFailed(ThreadBotPlaceholderFailed event, Emitter<ThreadState> emit) {
    _failBotPlaceholder(event.tempId, emit);
  }

  void _onBotPlaceholderTimedOut(_BotPlaceholderTimedOut event, Emitter<ThreadState> emit) {
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
    // _onMessageSubmitted — the hub echo just needs to be ignored.
    if (state.messages.any((m) => m.id == event.message.id)) return;

    final botQueue = _pendingBotTempIdsByBot[event.message.authorId];
    if (botQueue != null && botQueue.isNotEmpty) {
      final tempId = botQueue.removeAt(0);
      _botTimeoutTimers.remove(tempId)?.cancel();
      emit(
        state.copyWith(
          messages: [
            event.message,
            for (final m in state.messages) if (m.id != tempId) m,
          ],
          pendingSendIds: {...state.pendingSendIds}..remove(tempId),
        ),
      );
      return;
    }

    emit(state.copyWith(messages: [event.message, ...state.messages]));
    if (event.message.authorId != myUserId) {
      unawaited(_markRead());
    }
  }

  void _onMessageUpdatedRemote(_MessageUpdatedRemote event, Emitter<ThreadState> emit) {
    emit(
      state.copyWith(
        messages: [
          for (final m in state.messages)
            if (m.id == event.messageId) m.copyWith(content: event.content) else m,
        ],
      ),
    );
  }

  void _onMessageDeletedRemote(_MessageDeletedRemote event, Emitter<ThreadState> emit) {
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
    emit(state.copyWith(typingUserIds: {...state.typingUserIds}..remove(event.userId)));
  }

  Future<void> _markRead() async {
    if (state.messages.isEmpty) return;
    await repository.updateLastRead(state.messages.first.id);
  }

  List<MessageDto> _sortNewestFirst(List<MessageDto> messages) {
    final sorted = [...messages];
    sorted.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
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
