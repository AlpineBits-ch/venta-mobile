import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/profile_dto.dart';
import '../data/profile_repository.dart';

enum SelfProfileStatus { loading, loaded, error }

class SelfProfileState extends Equatable {
  const SelfProfileState({
    this.status = SelfProfileStatus.loading,
    this.profile,
    this.isSaving = false,
    this.errorMessage,
  });

  final SelfProfileStatus status;
  final ProfileDto? profile;
  final bool isSaving;
  final String? errorMessage;

  SelfProfileState copyWith({
    SelfProfileStatus? status,
    ProfileDto? profile,
    bool? isSaving,
    String? errorMessage,
  }) => SelfProfileState(
    status: status ?? this.status,
    profile: profile ?? this.profile,
    isSaving: isSaving ?? false,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [status, profile, isSaving, errorMessage];
}

class SelfProfileCubit extends Cubit<SelfProfileState> {
  SelfProfileCubit({required this.repository})
    : super(const SelfProfileState()) {
    // The profile page and the edit page each own a cubit, and the persistent
    // user banner writes straight to the repository - listening here keeps
    // whichever of them is on screen current no matter who made the change.
    _selfSub = repository.selfStream.listen(
      (profile) => emit(
        state.copyWith(status: SelfProfileStatus.loaded, profile: profile),
      ),
    );
    final cached = repository.cachedSelf;
    if (cached != null) {
      emit(state.copyWith(status: SelfProfileStatus.loaded, profile: cached));
    }
    _load();
  }

  final ProfileRepository repository;
  late final StreamSubscription<ProfileDto> _selfSub;

  Future<void> _load() async {
    try {
      final profile = await repository.getSelf();
      emit(state.copyWith(status: SelfProfileStatus.loaded, profile: profile));
    } catch (_) {
      emit(state.copyWith(status: SelfProfileStatus.error));
    }
  }

  Future<void> setStatus(OnlineStatus status) async {
    try {
      final profile = await repository.setSelfStatus(status);
      emit(state.copyWith(status: SelfProfileStatus.loaded, profile: profile));
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Could not update status.'));
    }
  }

  Future<void> updateProfile({
    String? bio,
    String? accentColor,
    ProfileFont? font,
  }) async {
    emit(state.copyWith(isSaving: true));
    try {
      final profile = await repository.updateProfile(
        bio: bio,
        accentColor: accentColor,
        font: font,
      );
      emit(
        state.copyWith(
          status: SelfProfileStatus.loaded,
          profile: profile,
          isSaving: false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'Could not save your profile.',
        ),
      );
    }
  }

  Future<void> uploadAvatar(String filePath) async {
    emit(state.copyWith(isSaving: true));
    try {
      final profile = await repository.uploadAvatar(filePath);
      emit(
        state.copyWith(
          status: SelfProfileStatus.loaded,
          profile: profile,
          isSaving: false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'Could not upload that image.',
        ),
      );
    }
  }

  Future<void> uploadBanner(String filePath) async {
    emit(state.copyWith(isSaving: true));
    try {
      final profile = await repository.uploadBanner(filePath);
      emit(
        state.copyWith(
          status: SelfProfileStatus.loaded,
          profile: profile,
          isSaving: false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'Could not upload that image.',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    unawaited(_selfSub.cancel());
    return super.close();
  }

  Future<void> removeAvatar() async {
    emit(state.copyWith(isSaving: true));
    try {
      final profile = await repository.removeAvatar();
      emit(
        state.copyWith(
          status: SelfProfileStatus.loaded,
          profile: profile,
          isSaving: false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'Could not remove your avatar.',
        ),
      );
    }
  }
}
