import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/message_content_codec.dart';
import '../data/message_repository.dart';
import '../data/models/message_dto.dart';

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
  const ThreadMessageSubmitted(this.text);
  final String text;

  @override
  List<Object?> get props => [text];
}

class ThreadTypingNotified extends ThreadEvent {
  const ThreadTypingNotified();
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
    on<_MessageReceived>(_onMessageReceived);
    on<_MessageUpdatedRemote>(_onMessageUpdatedRemote);
    on<_MessageDeletedRemote>(_onMessageDeletedRemote);
    on<_UserTypingRemote>(_onUserTypingRemote);
    on<_TypingExpired>(_onTypingExpired);

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
      }
    });

    add(const ThreadOpened());
  }

  final MessageRepository repository;
  final String myUserId;
  late final StreamSubscription<MessageRepositoryEvent> _repoSub;
  final Map<String, Timer> _typingTimers = {};
  int _tempIdCounter = 0;

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
    if (text.isEmpty) return;

    final tempId = 'pending-${_tempIdCounter++}';
    final optimistic = repository.buildOptimistic(
      id: tempId,
      authorId: myUserId,
      encodedContent: MessageContentCodec.encode(text),
    );
    emit(
      state.copyWith(
        messages: [optimistic, ...state.messages],
        pendingSendIds: {...state.pendingSendIds, tempId},
      ),
    );

    try {
      final sent = await repository.send(plaintextContent: text);
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

  void _onMessageReceived(_MessageReceived event, Emitter<ThreadState> emit) {
    // Our own message already landed via the REST response in
    // _onMessageSubmitted — the hub echo just needs to be ignored.
    if (state.messages.any((m) => m.id == event.message.id)) return;
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
    repository.dispose();
    return super.close();
  }
}
