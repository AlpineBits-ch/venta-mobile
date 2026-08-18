import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/mls/mls_sync_service.dart';
import '../../../core/format/api_date_time.dart';
import '../../../core/realtime/realtime_event.dart';
import '../../../core/realtime/realtime_service.dart';
import 'conversation_api.dart';
import 'conversation_prefs.dart';
import 'models/conversation_dto.dart';

/// REST conversation list merged with realtime structural events
/// (`ConversationCreated`/`ConversationDeleted`/`MemberLeft`). Message
/// content updates are the message thread's concern, not this list's.
class ConversationRepository {
  ConversationRepository({
    required this.api,
    required this.mlsSync,
    required RealtimeService realtimeService,
  }) {
    _realtimeSub = realtimeService.events
        .where(
          (e) =>
              e.name == 'conversation.ConversationCreated' ||
              e.name == 'conversation.ConversationDeleted' ||
              e.name == 'conversation.MemberLeft' ||
              e.name == _conversationUpdated,
        )
        .listen(_handleEvent);
  }

  static const _conversationUpdated = 'conversation.ConversationUpdated';

  final ConversationApi api;
  final MlsSyncService mlsSync;
  late final StreamSubscription<RealtimeEvent> _realtimeSub;

  final _conversationsController =
      StreamController<List<ConversationDto>>.broadcast();
  List<ConversationDto> _cache = [];

  Stream<List<ConversationDto>> get conversationsStream =>
      _conversationsController.stream;
  List<ConversationDto> get cached => _cache;

  Future<List<ConversationDto>> fetch() async {
    final list = await api.list();
    _cache = list;
    _conversationsController.add(list);
    return list;
  }

  /// A rename or an icon change carries the new values outright, so it is
  /// applied to the held conversation rather than answered with a refetch of
  /// the whole list. Everything else is structural and needs the list again.
  ///
  /// Read case-insensitively: the hub is not consistent about property casing
  /// and one PascalCase payload would otherwise clear the name of every group
  /// it touched - `null` reads as "the name was removed", which is a real
  /// thing this event says.
  void _handleEvent(RealtimeEvent event) {
    if (event.name != _conversationUpdated) {
      unawaited(_refresh());
      return;
    }

    final id = event.stringField('conversationId');
    if (id == null) return;
    final held = _cache.where((c) => c.id == id).firstOrNull;
    // Not a conversation this account holds - or one it has not fetched yet,
    // in which case the list read that discovers it will carry these fields.
    if (held == null) return;

    final rawIconUpdatedAt = event.stringField('iconUpdatedAt');
    replaceCached(
      held.copyWith(
        name: event.stringField('name'),
        iconUpdatedAt: rawIconUpdatedAt == null
            ? null
            : parseApiDateTime(rawIconUpdatedAt),
      ),
    );
  }

  /// Swaps one conversation in the held list and republishes it.
  ///
  /// The list is what Home renders, so a mutation that does not land here is
  /// invisible until something else refetches - which is why every write path
  /// ends in this rather than in the caller keeping its own copy.
  void replaceCached(ConversationDto updated) {
    final index = _cache.indexWhere((c) => c.id == updated.id);
    if (index == -1) {
      _cache = [..._cache, updated];
    } else {
      _cache = [..._cache]..[index] = updated;
    }
    _conversationsController.add(_cache);
  }

  /// Renames a group, or clears the name when [name] is null or blank.
  Future<ConversationDto> rename(String id, String? name) async {
    final trimmed = name?.trim();
    final updated = await api.update(
      id,
      name: trimmed == null || trimmed.isEmpty ? null : trimmed,
    );
    replaceCached(updated);
    return updated;
  }

  Future<ConversationDto> setIcon(
    String id, {
    required List<int> bytes,
    required String fileName,
  }) async {
    final updated = await api.uploadIcon(id, bytes: bytes, fileName: fileName);
    replaceCached(updated);
    return updated;
  }

  Future<ConversationDto> removeIcon(String id) async {
    final updated = await api.removeIcon(id);
    replaceCached(updated);
    return updated;
  }

  Future<void> _refresh() async {
    try {
      await fetch();
    } catch (_) {
      // Best-effort - the user can still pull-to-refresh.
    }
  }

  /// Only meaningful for 1:1 DMs (exactly 2 members).
  ConversationDto? findDirectMessageWith(String otherUserId) {
    for (final conversation in _cache) {
      if (conversation.members.length == 2 &&
          conversation.members.any((m) => m.userId == otherUserId)) {
        return conversation;
      }
    }
    return null;
  }

  Future<ConversationDto> createOrOpenDirectMessage(String otherUserId) async {
    final existing = findDirectMessageWith(otherUserId);
    if (existing != null) return existing;
    final created = await api.create(memberUserIds: [otherUserId]);
    await fetch();
    return created;
  }

  /// "Close DM" - drops the conversation off Home.
  ///
  /// The server broadcasts `ConversationDeleted`, which the realtime listener
  /// above turns into a refetch anyway; the [fetch] here is just so the row
  /// disappears without waiting on the socket.
  Future<void> close(String conversationId) async {
    // Leave the MLS group *first*. Leaving drops this device's keys immediately,
    // so even if the delete below fails we have already given up the ability to
    // read anything sent afterwards - which is the half that matters for our own
    // forward secrecy. Doing it after would leave the keys behind on every
    // failed request.
    //
    // A plaintext conversation has no group and this is a no-op.
    try {
      await mlsSync.leaveContext(conversationId, false);
    } catch (e) {
      debugPrint('Could not leave the MLS group for $conversationId: $e');
    }

    await api.delete(conversationId);
    ConversationPrefs.forget(conversationId);
    await fetch();
  }

  /// Drops the cached DM list on a session change - see
  /// `resetSessionScopedCaches()`. Emits so anything already listening
  /// (the Home list) empties instead of showing the previous account's DMs.
  void clear() {
    _cache = [];
    _conversationsController.add(_cache);
  }

  void dispose() => _realtimeSub.cancel();
}
