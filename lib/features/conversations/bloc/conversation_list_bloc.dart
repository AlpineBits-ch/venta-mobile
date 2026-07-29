import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/conversation_repository.dart';
import '../data/models/conversation_dto.dart';

sealed class ConversationListEvent extends Equatable {
  const ConversationListEvent();

  @override
  List<Object?> get props => [];
}

class ConversationListLoadRequested extends ConversationListEvent {
  const ConversationListLoadRequested();
}

class _ConversationsUpdated extends ConversationListEvent {
  const _ConversationsUpdated(this.conversations);
  final List<ConversationDto> conversations;

  @override
  List<Object?> get props => [conversations];
}

enum ConversationListStatus { loading, loaded, error }

class ConversationListState extends Equatable {
  const ConversationListState({
    this.status = ConversationListStatus.loading,
    this.conversations = const [],
  });

  final ConversationListStatus status;
  final List<ConversationDto> conversations;

  ConversationListState copyWith({
    ConversationListStatus? status,
    List<ConversationDto>? conversations,
  }) => ConversationListState(
    status: status ?? this.status,
    conversations: conversations ?? this.conversations,
  );

  @override
  List<Object?> get props => [status, conversations];
}

class ConversationListBloc
    extends Bloc<ConversationListEvent, ConversationListState> {
  ConversationListBloc({required this.repository})
    : super(const ConversationListState()) {
    on<ConversationListLoadRequested>(_onLoadRequested);
    on<_ConversationsUpdated>(_onConversationsUpdated);

    _subscription = repository.conversationsStream.listen(
      (list) => add(_ConversationsUpdated(list)),
    );
    add(const ConversationListLoadRequested());
  }

  final ConversationRepository repository;
  late final StreamSubscription<List<ConversationDto>> _subscription;

  Future<void> _onLoadRequested(
    ConversationListLoadRequested event,
    Emitter<ConversationListState> emit,
  ) async {
    try {
      await repository.fetch();
    } catch (_) {
      emit(state.copyWith(status: ConversationListStatus.error));
    }
  }

  void _onConversationsUpdated(
    _ConversationsUpdated event,
    Emitter<ConversationListState> emit,
  ) {
    emit(
      state.copyWith(
        status: ConversationListStatus.loaded,
        conversations: event.conversations,
      ),
    );
  }

  @override
  Future<void> close() {
    unawaited(_subscription.cancel());
    return super.close();
  }
}
