import 'dart:async';

import '../../../core/realtime/realtime_event.dart';
import '../../../core/realtime/realtime_service.dart';
import 'models/relationship_model.dart';
import 'relationship_api.dart';

extension RelationshipModelX on RelationshipModel {
  /// The API returns `status` already relative to the querying user
  /// (e.g. `pendingIncoming` means incoming *to me*), but `owner`/`target`
  /// are absolute - this picks whichever side isn't me, for display.
  ///
  /// Compares against `owner.userId`, not the top-level `ownerId` - the
  /// latter is the Social service's profile id (`prfl_...`), a different
  /// namespace than `myUserId` (the Identity JWT `sub`), so it never
  /// matched and this always fell back to `owner`, showing yourself as
  /// every friend.
  MinimalProfileId otherParty(String myUserId) =>
      owner.userId == myUserId ? target : owner;
}

/// REST relationship list merged with realtime friend-request events. The
/// hub only sends a display name on those events (not enough to patch one
/// entry), so a received/accepted event just triggers a full refetch.
class RelationshipRepository {
  RelationshipRepository({
    required this.api,
    required RealtimeService realtimeService,
  }) {
    _realtimeSub = realtimeService.events
        .where(
          (e) =>
              e.name == 'conversation.FriendRequestReceived' ||
              e.name == 'conversation.FriendRequestAccepted',
        )
        .listen((_) => _refresh());
  }

  final RelationshipApi api;
  late final StreamSubscription<RealtimeEvent> _realtimeSub;

  final _relationshipsController =
      StreamController<List<RelationshipModel>>.broadcast();
  List<RelationshipModel> _cache = [];

  Stream<List<RelationshipModel>> get relationshipsStream =>
      _relationshipsController.stream;
  List<RelationshipModel> get cached => _cache;

  Future<List<RelationshipModel>> fetch() async {
    final list = await api.getRelationships();
    _cache = list;
    _relationshipsController.add(list);
    return list;
  }

  Future<void> _refresh() async {
    try {
      await fetch();
    } catch (_) {
      // Best-effort - the user can still pull-to-refresh.
    }
  }

  Future<void> addFriend(String username) async {
    await api.createFriendRequest(username);
    await fetch();
  }

  Future<void> accept(String id) async {
    await api.accept(id);
    await fetch();
  }

  Future<void> reject(String id) async {
    await api.reject(id);
    await fetch();
  }

  Future<void> revoke(String id) async {
    await api.revoke(id);
    await fetch();
  }

  void dispose() => _realtimeSub.cancel();
}
