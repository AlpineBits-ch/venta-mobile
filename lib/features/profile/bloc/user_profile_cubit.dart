import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../friends/data/models/relationship_model.dart';
import '../../friends/data/relationship_repository.dart';
import '../data/models/profile_dto.dart';
import '../data/profile_repository.dart';

enum UserProfileStatus { loading, loaded, error }

class UserProfileState extends Equatable {
  const UserProfileState({
    this.status = UserProfileStatus.loading,
    this.profile,
    this.relationship,
    this.isActionInProgress = false,
    this.errorMessage,
  });

  final UserProfileStatus status;
  final ProfileDto? profile;

  /// Null means "no relationship yet" (never friended, never requested).
  final RelationshipModel? relationship;
  final bool isActionInProgress;
  final String? errorMessage;

  /// [relationship] and [errorMessage] are always set as given (including
  /// `null`) rather than falling back to the current value — every call
  /// site recomputes the relationship fresh, and `null` there is a
  /// meaningful "no relationship anymore" (e.g. after a revoke/reject), not
  /// "unchanged".
  UserProfileState copyWith({
    UserProfileStatus? status,
    ProfileDto? profile,
    RelationshipModel? relationship,
    bool? isActionInProgress,
    String? errorMessage,
  }) =>
      UserProfileState(
        status: status ?? this.status,
        profile: profile ?? this.profile,
        relationship: relationship,
        isActionInProgress: isActionInProgress ?? false,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props =>
      [status, profile, relationship, isActionInProgress, errorMessage];
}

/// Loads another user's profile plus the caller's relationship to them (so
/// the screen can render Add Friend / Pending / Accept-Reject / Friends
/// appropriately) — the read-only counterpart to `SelfProfileCubit`.
class UserProfileCubit extends Cubit<UserProfileState> {
  UserProfileCubit({
    required this.userId,
    required this.profileRepository,
    required this.relationshipRepository,
  }) : super(const UserProfileState()) {
    _load();
  }

  final String userId;
  final ProfileRepository profileRepository;
  final RelationshipRepository relationshipRepository;

  RelationshipModel? get _cachedRelationship => relationshipRepository.cached
      .where((r) => r.owner.userId == userId || r.target.userId == userId)
      .firstOrNull;

  Future<void> _load() async {
    try {
      final profile = await profileRepository.getByUserId(userId);
      await relationshipRepository.fetch();
      emit(
        state.copyWith(
          status: UserProfileStatus.loaded,
          profile: profile,
          relationship: _cachedRelationship,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: UserProfileStatus.error));
    }
  }

  Future<void> sendFriendRequest() async {
    final profile = state.profile;
    if (profile == null) return;
    emit(state.copyWith(isActionInProgress: true));
    try {
      await relationshipRepository.addFriend(profile.userName);
      emit(state.copyWith(isActionInProgress: false, relationship: _cachedRelationship));
    } catch (_) {
      emit(
        state.copyWith(
          isActionInProgress: false,
          errorMessage: 'Could not send a friend request.',
        ),
      );
    }
  }

  Future<void> acceptRequest() async {
    final relationship = state.relationship;
    if (relationship == null) return;
    emit(state.copyWith(isActionInProgress: true));
    try {
      await relationshipRepository.accept(relationship.id);
      emit(state.copyWith(isActionInProgress: false, relationship: _cachedRelationship));
    } catch (_) {
      emit(
        state.copyWith(isActionInProgress: false, errorMessage: 'Could not accept that request.'),
      );
    }
  }

  /// Declines an incoming request or cancels one the caller sent, depending
  /// on [RelationshipModel.status] — the two map to different API calls.
  Future<void> rejectOrRevokeRequest() async {
    final relationship = state.relationship;
    if (relationship == null) return;
    emit(state.copyWith(isActionInProgress: true));
    try {
      if (relationship.status == RelationshipStatus.pendingIncoming) {
        await relationshipRepository.reject(relationship.id);
      } else {
        await relationshipRepository.revoke(relationship.id);
      }
      emit(state.copyWith(isActionInProgress: false, relationship: _cachedRelationship));
    } catch (_) {
      emit(
        state.copyWith(isActionInProgress: false, errorMessage: 'Could not update that request.'),
      );
    }
  }
}
