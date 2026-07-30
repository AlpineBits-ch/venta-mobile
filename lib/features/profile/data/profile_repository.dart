import 'dart:async';

import '../../../core/realtime/realtime_service.dart';
import 'profile_api.dart';
import 'models/profile_dto.dart';

/// Caches profiles by user id (the id most other DTOs reference - messages,
/// relationships, conversation members) so features can resolve a display
/// name/avatar without a network round trip once it's been seen once.
/// Also the sole listener for `presence.*` realtime events.
class ProfileRepository {
  ProfileRepository({
    required this.api,
    required RealtimeService realtimeService,
  }) {
    realtimeService.events.where((e) => e.name == 'presence.UserOnline').listen(
      (e) {
        updateOnlineStatus(e.stringPayload, OnlineStatus.online);
      },
    );
    realtimeService.events
        .where((e) => e.name == 'presence.UserOffline')
        .listen((e) {
          updateOnlineStatus(e.stringPayload, OnlineStatus.offline);
        });
  }

  final ProfileApi api;

  final Map<String, ProfileDto> _byUserId = {};
  ProfileDto? _self;

  final _selfController = StreamController<ProfileDto>.broadcast();

  ProfileDto? get cachedSelf => _self;
  ProfileDto? cachedByUserId(String userId) => _byUserId[userId];

  /// Every change to the signed-in user's own profile - avatar, banner, bio,
  /// status. The persistent user banner in `AppShell` and any open profile
  /// screen both listen here, so a status set from one surface shows up on
  /// the other without either knowing the other exists.
  Stream<ProfileDto> get selfStream => _selfController.stream;

  ProfileDto _cacheSelf(ProfileDto profile) {
    _self = profile;
    _byUserId[profile.userId] = profile;
    _selfController.add(profile);
    return profile;
  }

  Future<ProfileDto> getSelf() async => _cacheSelf(await api.getSelf());

  Future<ProfileDto> setSelfStatus(OnlineStatus status) async =>
      _cacheSelf(await api.setSelfStatus(status));

  Future<ProfileDto> getByUserId(
    String userId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = _byUserId[userId];
      if (cached != null) return cached;
    }
    final profile = await api.getByUserId(userId);
    _byUserId[userId] = profile;
    return profile;
  }

  Future<ProfileDto> updateProfile({
    String? bio,
    String? accentColor,
    ProfileFont? font,
  }) async {
    final current = _self;
    if (current == null) throw StateError('Self profile not loaded yet.');
    await api.updateProfile(
      profileId: current.id,
      bio: bio,
      accentColor: accentColor,
      font: font,
    );
    return getSelf();
  }

  Future<ProfileDto> uploadAvatar(String filePath) async {
    final current = _self;
    if (current == null) throw StateError('Self profile not loaded yet.');
    await api.uploadAvatar(profileId: current.id, filePath: filePath);
    return getSelf();
  }

  Future<ProfileDto> uploadBanner(String filePath) async {
    final current = _self;
    if (current == null) throw StateError('Self profile not loaded yet.');
    await api.uploadBanner(profileId: current.id, filePath: filePath);
    return getSelf();
  }

  Future<ProfileDto> removeAvatar() async {
    final current = _self;
    if (current == null) throw StateError('Self profile not loaded yet.');
    await api.removeAvatar(current.id);
    return getSelf();
  }

  void updateOnlineStatus(String userId, OnlineStatus status) {
    final cached = _byUserId[userId];
    if (cached == null) return;
    final updated = cached.copyWith(onlineStatus: status);
    _byUserId[userId] = updated;
    // Presence events cover *every* user including ourselves, and the two
    // caches must not drift - `_self` is what the user banner renders.
    if (_self?.userId == userId) {
      _self = updated;
      _selfController.add(updated);
    }
  }
}
