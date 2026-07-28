import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/relationship_model.dart';
import '../data/relationship_repository.dart';

sealed class FriendsEvent extends Equatable {
  const FriendsEvent();

  @override
  List<Object?> get props => [];
}

class FriendsLoadRequested extends FriendsEvent {
  const FriendsLoadRequested();
}

class FriendAddSubmitted extends FriendsEvent {
  const FriendAddSubmitted(this.username);
  final String username;

  @override
  List<Object?> get props => [username];
}

class FriendAcceptRequested extends FriendsEvent {
  const FriendAcceptRequested(this.relationshipId);
  final String relationshipId;

  @override
  List<Object?> get props => [relationshipId];
}

class FriendRejectRequested extends FriendsEvent {
  const FriendRejectRequested(this.relationshipId);
  final String relationshipId;

  @override
  List<Object?> get props => [relationshipId];
}

class FriendRevokeRequested extends FriendsEvent {
  const FriendRevokeRequested(this.relationshipId);
  final String relationshipId;

  @override
  List<Object?> get props => [relationshipId];
}

class _RelationshipsUpdated extends FriendsEvent {
  const _RelationshipsUpdated(this.relationships);
  final List<RelationshipModel> relationships;

  @override
  List<Object?> get props => [relationships];
}

enum FriendsStatus { loading, loaded, error }

class FriendsState extends Equatable {
  const FriendsState({
    this.status = FriendsStatus.loading,
    this.friends = const [],
    this.pendingIncoming = const [],
    this.pendingOutgoing = const [],
    this.blocked = const [],
    this.actionError,
  });

  final FriendsStatus status;
  final List<RelationshipModel> friends;
  final List<RelationshipModel> pendingIncoming;
  final List<RelationshipModel> pendingOutgoing;
  final List<RelationshipModel> blocked;
  final String? actionError;

  FriendsState copyWith({
    FriendsStatus? status,
    List<RelationshipModel>? friends,
    List<RelationshipModel>? pendingIncoming,
    List<RelationshipModel>? pendingOutgoing,
    List<RelationshipModel>? blocked,
    String? actionError,
  }) =>
      FriendsState(
        status: status ?? this.status,
        friends: friends ?? this.friends,
        pendingIncoming: pendingIncoming ?? this.pendingIncoming,
        pendingOutgoing: pendingOutgoing ?? this.pendingOutgoing,
        blocked: blocked ?? this.blocked,
        actionError: actionError,
      );

  @override
  List<Object?> get props => [
        status,
        friends,
        pendingIncoming,
        pendingOutgoing,
        blocked,
        actionError,
      ];
}

class FriendsBloc extends Bloc<FriendsEvent, FriendsState> {
  FriendsBloc({required this.repository}) : super(const FriendsState()) {
    on<FriendsLoadRequested>(_onLoadRequested);
    on<FriendAddSubmitted>(_onAddSubmitted);
    on<FriendAcceptRequested>(_onAcceptRequested);
    on<FriendRejectRequested>(_onRejectRequested);
    on<FriendRevokeRequested>(_onRevokeRequested);
    on<_RelationshipsUpdated>(_onRelationshipsUpdated);

    _subscription = repository.relationshipsStream.listen(
      (list) => add(_RelationshipsUpdated(list)),
    );
    add(const FriendsLoadRequested());
  }

  final RelationshipRepository repository;
  late final StreamSubscription<List<RelationshipModel>> _subscription;

  Future<void> _onLoadRequested(FriendsLoadRequested event, Emitter<FriendsState> emit) async {
    try {
      await repository.fetch();
    } catch (_) {
      emit(state.copyWith(status: FriendsStatus.error));
    }
  }

  void _onRelationshipsUpdated(_RelationshipsUpdated event, Emitter<FriendsState> emit) {
    final byStatus = <RelationshipStatus, List<RelationshipModel>>{};
    for (final relationship in event.relationships) {
      (byStatus[relationship.status] ??= []).add(relationship);
    }
    emit(
      state.copyWith(
        status: FriendsStatus.loaded,
        friends: byStatus[RelationshipStatus.friends] ?? const [],
        pendingIncoming: byStatus[RelationshipStatus.pendingIncoming] ?? const [],
        pendingOutgoing: byStatus[RelationshipStatus.pendingOutgoing] ?? const [],
        blocked: byStatus[RelationshipStatus.blocked] ?? const [],
        actionError: null,
      ),
    );
  }

  Future<void> _onAddSubmitted(FriendAddSubmitted event, Emitter<FriendsState> emit) async {
    try {
      await repository.addFriend(event.username);
    } catch (_) {
      emit(state.copyWith(actionError: 'Could not find or add "${event.username}".'));
    }
  }

  Future<void> _onAcceptRequested(FriendAcceptRequested event, Emitter<FriendsState> emit) async {
    try {
      await repository.accept(event.relationshipId);
    } catch (_) {
      emit(state.copyWith(actionError: 'Could not accept that request.'));
    }
  }

  Future<void> _onRejectRequested(FriendRejectRequested event, Emitter<FriendsState> emit) async {
    try {
      await repository.reject(event.relationshipId);
    } catch (_) {
      emit(state.copyWith(actionError: 'Could not reject that request.'));
    }
  }

  Future<void> _onRevokeRequested(FriendRevokeRequested event, Emitter<FriendsState> emit) async {
    try {
      await repository.revoke(event.relationshipId);
    } catch (_) {
      emit(state.copyWith(actionError: 'Could not remove that friend.'));
    }
  }

  @override
  Future<void> close() {
    unawaited(_subscription.cancel());
    return super.close();
  }
}
