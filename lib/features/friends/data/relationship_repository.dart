import 'dart:async';

import '../../../core/realtime/realtime_event.dart';
import '../../../core/realtime/realtime_service.dart';
import '../../privacy/data/models/blocked_user_dto.dart';
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

/// REST relationship list merged with the realtime `social.*` events.
///
/// All four carry the recipient's own view - `relationshipId`, `status`
/// (`PendingIncoming`/`PendingOutgoing`/`Friends`/`None`) and the *other*
/// party's `userId`/`profileId`/`userName` - and go to both sides. That's
/// still not enough to patch the cache in place: a [RelationshipModel] holds
/// both parties, and the event omits your own side, so a patched row would
/// have to invent it (and `None` has no [RelationshipStatus] to map to).
/// Refetching one list on a hand-initiated, infrequent event is the honest
/// trade.
class RelationshipRepository {
  RelationshipRepository({
    required this.api,
    required RealtimeService realtimeService,
  }) {
    _realtimeSub = realtimeService.events
        .where(
          (e) => const {
            // Sent to the target *and* the initiator, so a request shows up
            // on the receiving end without a restart, and your own outgoing
            // one appears on your other devices.
            'social.FriendRequestCreated',
            'social.FriendRequestAccepted',
            // Rejection and removal/revocation reach both sides too - these
            // had no event at all before, so a rejected or unfriended row
            // used to sit there until the app was restarted.
            'social.FriendRequestRejected',
            'social.FriendRemoved',
            // Transitional: the deployed backend still sends this one, and
            // will until the `social.*` change ships. Drop it after that -
            // both do the same refetch, so overlapping is harmless.
            'conversation.FriendRequestAccepted',
          }.contains(e.name),
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

  /// Drops the cached friends/requests on a session change - see
  /// `resetSessionScopedCaches()`. Emits so the friends screen empties
  /// instead of showing the previous account's relationships.
  void clear() {
    _cache = [];
    _blockedUserIds = null;
    _relationshipsController.add(_cache);
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

  /// Blocks [userId] and refetches, because a block is not a local edit to one
  /// row: server-side it also drops an existing friendship and cancels a
  /// pending request in either direction, so the relationship list this device
  /// holds is wrong in more places than the one that was acted on.
  Future<void> block(String userId) async {
    await api.block(userId);
    _blockedUserIds?.add(userId);
    await fetch();
  }

  /// Unblocking does **not** restore the friendship the block removed - the
  /// pair go back to strangers, which is what the UI has to say.
  Future<void> unblock(String userId) async {
    await api.unblock(userId);
    _blockedUserIds?.remove(userId);
    await fetch();
  }

  /// One page of the caller's block list, for the screen that renders it.
  ///
  /// Not cached: that screen is the one place a stale copy would have someone
  /// believing they blocked a person they didn't, and it is reached rarely
  /// enough to always be worth a round-trip. [isBlocked] below is the cached
  /// path, and answers a different question.
  Future<BlockedUsersPage> fetchBlocked({int? limit, String? cursor}) =>
      api.getBlocked(limit: limit, cursor: cursor);

  /// Every blocked user id, or null until [_loadBlockedIds] has run once.
  Set<String>? _blockedUserIds;

  Future<Set<String>>? _blockedIdsInFlight;

  /// Whether the caller has blocked [userId].
  ///
  /// Reads a session-cached set rather than the paged list, and walks every
  /// page once to build it. Scanning only the first page would answer "no" for
  /// anyone past the 50th block - and that answer reaches the profile screen as
  /// an Add Friend button the server refuses, which looks like breakage rather
  /// than like the block the user themselves put there.
  ///
  /// Kept correct afterwards by [block]/[unblock] rather than by refetching:
  /// those are the only ways the set changes for this account, and a block made
  /// on another device is not worth a page walk per profile opened.
  Future<bool> isBlocked(String userId) async {
    final cached = _blockedUserIds;
    if (cached != null) return cached.contains(userId);
    return (await _loadBlockedIds()).contains(userId);
  }

  Future<Set<String>> _loadBlockedIds() {
    final existing = _blockedIdsInFlight;
    if (existing != null) return existing;
    final request = _walkBlockedIds();
    _blockedIdsInFlight = request;
    return request.whenComplete(() => _blockedIdsInFlight = null);
  }

  Future<Set<String>> _walkBlockedIds() async {
    final ids = <String>{};
    String? cursor;
    // Bounded: 100 per page against a 429 budget shared with everything else
    // the app is doing. Twenty pages is two thousand blocked accounts, well
    // past any real list, and stopping is better than looping on a server that
    // returns a cursor forever.
    for (var page = 0; page < 20; page++) {
      final result = await api.getBlocked(limit: 100, cursor: cursor);
      ids.addAll(result.blocked.map((b) => b.userId));
      if (!result.hasMore) break;
      cursor = result.nextCursor;
    }
    _blockedUserIds = ids;
    return ids;
  }

  void dispose() => _realtimeSub.cancel();
}
