import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/safe_emit.dart';
import '../../../core/network/privacy_refusal.dart';
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
    this.isBlocked = false,
    this.isActionInProgress = false,
    this.errorMessage,
  });

  final UserProfileStatus status;
  final ProfileDto? profile;

  /// Null means "no relationship yet" (never friended, never requested).
  final RelationshipModel? relationship;

  /// Whether *this* user has blocked the profile being viewed.
  ///
  /// Never the other direction. Being blocked is deliberately indistinguishable
  /// from not being friends, and there is no field on any response that would
  /// let this screen know - which is the intended design, not a gap.
  final bool isBlocked;

  final bool isActionInProgress;
  final String? errorMessage;

  /// [relationship] and [errorMessage] are always set as given (including
  /// `null`) rather than falling back to the current value - every call
  /// site recomputes the relationship fresh, and `null` there is a
  /// meaningful "no relationship anymore" (e.g. after a revoke/reject), not
  /// "unchanged".
  UserProfileState copyWith({
    UserProfileStatus? status,
    ProfileDto? profile,
    RelationshipModel? relationship,
    bool? isBlocked,
    bool? isActionInProgress,
    String? errorMessage,
  }) => UserProfileState(
    status: status ?? this.status,
    profile: profile ?? this.profile,
    relationship: relationship,
    isBlocked: isBlocked ?? this.isBlocked,
    isActionInProgress: isActionInProgress ?? false,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [
    status,
    profile,
    relationship,
    isBlocked,
    isActionInProgress,
    errorMessage,
  ];
}

/// Loads another user's profile plus the caller's relationship to them (so
/// the screen can render Add Friend / Pending / Accept-Reject / Friends
/// appropriately) - the read-only counterpart to `SelfProfileCubit`.
class UserProfileCubit extends Cubit<UserProfileState>
    with SafeEmit<UserProfileState> {
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
      // Block state is its own list, not a relationship row - you can block
      // someone you have no relationship with, so there is no row to read it
      // off. Guarded separately from the two loads above: failing to read it
      // costs the menu its correct Block/Unblock label, and must not cost the
      // page its profile.
      var blocked = false;
      try {
        blocked = await relationshipRepository.isBlocked(userId);
      } catch (_) {
        // Leaves the menu offering "Block", which a block already in place
        // answers with a harmless idempotent write.
      }
      emitIfOpen(
        state.copyWith(
          status: UserProfileStatus.loaded,
          profile: profile,
          relationship: _cachedRelationship,
          isBlocked: blocked,
        ),
      );
    } catch (_) {
      emitIfOpen(state.copyWith(status: UserProfileStatus.error));
    }
  }

  /// Blocks the profile being viewed. Confirmed at the call site - this is not
  /// reversible into the friendship it removes.
  Future<void> block() async {
    emitIfOpen(state.copyWith(isActionInProgress: true));
    try {
      await relationshipRepository.block(userId);
      emitIfOpen(
        state.copyWith(
          isActionInProgress: false,
          // Cleared, not recomputed: the server drops the friendship and any
          // pending request as part of the block, so whatever row the refetch
          // inside `block` produced is not a relationship this screen should
          // offer actions on.
          relationship: null,
          isBlocked: true,
        ),
      );
    } catch (_) {
      emitIfOpen(
        state.copyWith(
          isActionInProgress: false,
          relationship: _cachedRelationship,
          errorMessage: 'Could not block this account.',
        ),
      );
    }
  }

  Future<void> unblock() async {
    emitIfOpen(state.copyWith(isActionInProgress: true));
    try {
      await relationshipRepository.unblock(userId);
      emitIfOpen(
        state.copyWith(
          isActionInProgress: false,
          relationship: _cachedRelationship,
          isBlocked: false,
        ),
      );
    } catch (_) {
      emitIfOpen(
        state.copyWith(
          isActionInProgress: false,
          relationship: _cachedRelationship,
          errorMessage: 'Could not unblock this account.',
        ),
      );
    }
  }

  Future<void> sendFriendRequest() async {
    final profile = state.profile;
    if (profile == null) return;
    emitIfOpen(state.copyWith(isActionInProgress: true));
    try {
      await relationshipRepository.addFriend(profile.userName);
      emitIfOpen(
        state.copyWith(
          isActionInProgress: false,
          relationship: _cachedRelationship,
        ),
      );
    } on PrivacyRefusalException catch (e) {
      // The target's friend-request policy, or a block. Which of the two is
      // deliberately not distinguishable here - see `PrivacyRefusal.message`.
      emitIfOpen(
        state.copyWith(isActionInProgress: false, errorMessage: e.message),
      );
    } catch (_) {
      emitIfOpen(
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
    emitIfOpen(state.copyWith(isActionInProgress: true));
    try {
      await relationshipRepository.accept(relationship.id);
      emitIfOpen(
        state.copyWith(
          isActionInProgress: false,
          relationship: _cachedRelationship,
        ),
      );
    } catch (_) {
      emitIfOpen(
        state.copyWith(
          isActionInProgress: false,
          errorMessage: 'Could not accept that request.',
        ),
      );
    }
  }

  /// Declines an incoming request or cancels one the caller sent, depending
  /// on [RelationshipModel.status] - the two map to different API calls.
  Future<void> rejectOrRevokeRequest() async {
    final relationship = state.relationship;
    if (relationship == null) return;
    emitIfOpen(state.copyWith(isActionInProgress: true));
    try {
      if (relationship.status == RelationshipStatus.pendingIncoming) {
        await relationshipRepository.reject(relationship.id);
      } else {
        await relationshipRepository.revoke(relationship.id);
      }
      emitIfOpen(
        state.copyWith(
          isActionInProgress: false,
          relationship: _cachedRelationship,
        ),
      );
    } catch (_) {
      emitIfOpen(
        state.copyWith(
          isActionInProgress: false,
          errorMessage: 'Could not update that request.',
        ),
      );
    }
  }
}
