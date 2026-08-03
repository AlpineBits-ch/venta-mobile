import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/mls/mls_service.dart';
import '../../../core/realtime/realtime_event.dart';
import '../../../core/realtime/realtime_service.dart';
import '../../messaging/data/message_decryptor.dart';
import '../../messaging/data/models/message_dto.dart';
import 'inbox_api.dart';
import 'models/inbox_mention_dto.dart';
import 'models/inbox_message_dto.dart';
import 'models/inbox_summary_dto.dart';
import 'models/inbox_unread_dto.dart';

/// One `inbox.MentionAdded` - somebody mentioned the caller somewhere.
///
/// Carries no message body, only where it happened; the Mentions tab refetches
/// its head rather than trying to synthesise a row from this.
typedef InboxMentionAdded = ({
  String messageId,
  String? channelId,
  String? guildId,
  String? conversationId,
  String authorId,
  InboxMentionKind kind,
});

/// One `inbox.ReadStateChanged` - another of this account's devices acked a
/// channel, or all of them.
///
/// Never fired for this device's own writes: the hub sends it to the acking
/// user's *other* devices, which is why [InboxRepository.markChannelRead] and
/// friends update local state themselves instead of waiting for one.
typedef InboxReadStateChanged = ({String? channelId, bool all});

/// A run of [InboxApi.getUnread] with the empty-page rule already applied.
///
/// [nextCursor] non-null means there is more to fetch, whatever [groups]
/// contains - including nothing.
typedef InboxUnreadResult = ({
  List<InboxUnreadGroupDto> groups,
  String? nextCursor,
  bool previewsUnavailable,
});

/// The same for [InboxApi.getMentions].
typedef InboxMentionsResult = ({
  List<InboxMentionDto> mentions,
  String? nextCursor,
});

/// What one channel is carrying, for a sidebar that only needs the numbers.
typedef InboxChannelUnread = ({int unreadCount, int mentionCount});

/// The inbox's REST endpoints plus the two hub events that keep the badge
/// honest, with the two things every caller would otherwise have to get right
/// itself: following cursors past empty pages, and decrypting previews.
class InboxRepository {
  InboxRepository({
    required this.api,
    required RealtimeService realtimeService,
    required MlsService mls,
  }) : _decryptor = MessageDecryptor(mls) {
    _realtimeSub = realtimeService.events
        .where(
          (e) => const {
            'inbox.MentionAdded',
            'inbox.ReadStateChanged',
          }.contains(e.name),
        )
        .listen(_handleRealtimeEvent);
  }

  final InboxApi api;
  final MessageDecryptor _decryptor;
  late final StreamSubscription<RealtimeEvent> _realtimeSub;

  /// How many pages the cursor is followed through before giving up on a round.
  ///
  /// Muting and permission filtering happen *after* a page is taken, so an
  /// account that has muted a lot can return several empty pages in a row.
  /// Following them is required - an empty page with a cursor means "keep
  /// going", not "you're done" - but following them unboundedly would let one
  /// pull-to-refresh walk the caller's entire history. On the bound, the cursor
  /// is handed back so the UI can offer to keep looking rather than claiming an
  /// empty inbox.
  static const _maxEmptyPageFollowUps = 8;

  /// The page bound for [unreadByChannel], which walks the whole list rather
  /// than stopping at the first page that produced something.
  static const _maxUnreadScanPages = 4;

  /// Coalesces the authoritative summary refetch behind the optimistic badge
  /// updates - a burst of mentions in a busy channel is one round-trip, not
  /// one per message.
  static const _summaryRefreshDelay = Duration(seconds: 3);

  final _summary = ValueNotifier<InboxSummaryDto>(const InboxSummaryDto());
  final _mentionAddedController =
      StreamController<InboxMentionAdded>.broadcast();
  final _readStateController =
      StreamController<InboxReadStateChanged>.broadcast();
  Timer? _summaryRefreshTimer;

  /// The header badge's source of truth. Kept current from the hub between
  /// fetches, so nothing has to poll [refreshSummary] on a timer.
  ValueListenable<InboxSummaryDto> get summary => _summary;

  Stream<InboxMentionAdded> get mentionAdded => _mentionAddedController.stream;

  Stream<InboxReadStateChanged> get readStateChanged =>
      _readStateController.stream;

  // ---------------------------------------------------------------- reading

  /// One "page" of unread channels from the caller's point of view - which may
  /// be several of the server's, see [_maxEmptyPageFollowUps].
  Future<InboxUnreadResult> loadUnread({String? cursor, int limit = 10}) async {
    final groups = <InboxUnreadGroupDto>[];
    var next = cursor;
    var previewsUnavailable = false;

    for (var round = 0; round < _maxEmptyPageFollowUps; round++) {
      final page = await api.getUnread(cursor: next, limit: limit);
      groups.addAll(page.groups);
      previewsUnavailable = previewsUnavailable || page.previewsUnavailable;
      next = page.nextCursor;
      // Stop on the first page that produced anything, or when the cursor runs
      // out. Only a genuinely empty page with more behind it goes round again.
      if (groups.isNotEmpty || next == null) break;
    }

    return (
      groups: await _decryptGroups(groups),
      nextCursor: next,
      previewsUnavailable: previewsUnavailable,
    );
  }

  /// Same shape as [loadUnread]. Deleted messages are skipped server-side, so
  /// a short page here is ordinary and says nothing about whether more exist.
  Future<InboxMentionsResult> loadMentions({
    String? guildId,
    InboxMentionSince since = InboxMentionSince.week,
    bool includeEveryone = true,
    bool includeRoles = true,
    bool includeDms = true,
    int limit = 25,
    String? cursor,
  }) async {
    final mentions = <InboxMentionDto>[];
    var next = cursor;

    for (var round = 0; round < _maxEmptyPageFollowUps; round++) {
      final page = await api.getMentions(
        guildId: guildId,
        since: since,
        includeEveryone: includeEveryone,
        includeRoles: includeRoles,
        includeDms: includeDms,
        limit: limit,
        cursor: next,
      );
      mentions.addAll(page.mentions);
      next = page.nextCursor;
      if (mentions.isNotEmpty || next == null) break;
    }

    return (mentions: await _decryptMentions(mentions), nextCursor: next);
  }

  /// Per-channel unread and mention counts, for the guild channel list's
  /// badges.
  ///
  /// This is where those counts live now. They used to be seeded from
  /// `readState[].mentionCount` on `GET /guilds/{id}/me`, which the
  /// 2026-08-03 inbox release zeroed out permanently - see
  /// `GuildSelfPermissions`. Reading them here is not a workaround; the inbox
  /// endpoints are the authoritative source, and unlike the old counter these
  /// are computed on read and exact.
  ///
  /// [guildId] filters client-side rather than asking the server, because the
  /// unread endpoint has no guild parameter - it is an account-wide view by
  /// design. Bounded at [_maxUnreadScanPages] pages: a sidebar wants the
  /// channels you actually have unread messages in, and walking an entire
  /// account's backlog to badge one guild's list would be a poor trade.
  ///
  /// Skips previews entirely (`limit` is about groups, and the bodies are
  /// simply ignored) and never decrypts - nothing here needs message text.
  ///
  /// Muted channels are absent by design: the endpoint filters them, and a
  /// muted channel is one you asked not to be badged about.
  Future<Map<String, InboxChannelUnread>> unreadByChannel({
    String? guildId,
  }) async {
    final counts = <String, InboxChannelUnread>{};
    String? cursor;
    for (var page = 0; page < _maxUnreadScanPages; page++) {
      final result = await api.getUnread(cursor: cursor, limit: 25);
      for (final group in result.groups) {
        if (guildId != null && group.breadcrumb.guildId != guildId) continue;
        counts[group.breadcrumb.channelId] = (
          unreadCount: group.unreadCount,
          mentionCount: group.mentionCount,
        );
      }
      cursor = result.nextCursor;
      // An empty page with a cursor still means "keep going" here, same as
      // everywhere else - the loop condition is the cursor, never the count.
      if (cursor == null) break;
    }
    return counts;
  }

  Future<InboxSummaryDto> refreshSummary() async {
    final summary = await api.getSummary();
    _summary.value = summary;
    return summary;
  }

  // ---------------------------------------------------------------- writing

  /// Marks one channel read up to its head.
  ///
  /// [mentionCount] is what that channel was contributing to the badge, so the
  /// badge can drop by the right amount immediately instead of waiting for the
  /// refetch - the summary endpoint reports totals, not per-channel numbers, so
  /// there is nothing to subtract after the fact.
  Future<void> markChannelRead(String channelId, {int mentionCount = 0}) async {
    await api.markChannelRead(channelId);
    _applyLocalRead(mentionCount: mentionCount);
  }

  Future<void> markAllRead() async {
    await api.markAllRead();
    _summaryRefreshTimer?.cancel();
    _summary.value = const InboxSummaryDto();
  }

  Future<void> dismissMention(InboxMentionDto mention) async {
    await api.dismissMention(
      messageId: mention.messageId,
      // Verbatim, never a re-serialised DateTime - the index is keyed on this
      // exact string and a mismatch deletes nothing while still returning 204.
      createdAt: mention.createdAtRaw,
    );
    if (!mention.kind.isDismissible) return;
    final current = _summary.value;
    _summary.value = current.copyWith(
      mentionCount: (current.mentionCount - 1).clamp(0, current.mentionCount),
    );
  }

  /// Drops the badge on a session change - see `resetSessionScopedCaches()`.
  /// The next account's inbox has nothing to do with this one's, and a stale
  /// count on the header is the first thing anybody would notice.
  void clear() {
    _summaryRefreshTimer?.cancel();
    _summary.value = const InboxSummaryDto();
  }

  void dispose() {
    _summaryRefreshTimer?.cancel();
    unawaited(_realtimeSub.cancel());
    unawaited(_mentionAddedController.close());
    unawaited(_readStateController.close());
    _summary.dispose();
  }

  // --------------------------------------------------------------- realtime

  void _handleRealtimeEvent(RealtimeEvent event) {
    switch (event.name) {
      case 'inbox.MentionAdded':
        final messageId = event.stringField('messageId');
        if (messageId == null) return;
        final current = _summary.value;
        // Optimistic so the badge moves in the same beat the notification
        // arrives; the debounced refetch below is what makes it *right*.
        if (!current.capped) {
          _summary.value = current.copyWith(
            mentionCount: current.mentionCount + 1,
          );
        }
        _mentionAddedController.add((
          messageId: messageId,
          channelId: event.stringField('channelId'),
          guildId: event.stringField('guildId'),
          conversationId: event.stringField('conversationId'),
          authorId: event.stringField('authorId') ?? '',
          kind: _parseKind(event.stringField('kind')),
        ));
        _scheduleSummaryRefresh();

      case 'inbox.ReadStateChanged':
        // Read-all sends `{ all: true }` with no channel id at all - looking
        // for one and finding null would read as a malformed event and get
        // dropped, leaving every badge on this device lit.
        final all = event.field('all') == true;
        if (all) {
          _summaryRefreshTimer?.cancel();
          _summary.value = const InboxSummaryDto();
        } else {
          _applyLocalRead(mentionCount: _asInt(event.field('mentionCount')));
          _scheduleSummaryRefresh();
        }
        _readStateController.add((
          channelId: event.stringField('channelId'),
          all: all,
        ));
    }
  }

  /// One channel left the unread set. [mentionCount] is how many mentions went
  /// with it.
  void _applyLocalRead({required int mentionCount}) {
    final current = _summary.value;
    _summary.value = current.copyWith(
      unreadChannelCount: (current.unreadChannelCount - 1).clamp(
        0,
        current.unreadChannelCount,
      ),
      mentionCount: (current.mentionCount - mentionCount).clamp(
        0,
        current.mentionCount,
      ),
    );
  }

  void _scheduleSummaryRefresh() {
    _summaryRefreshTimer?.cancel();
    _summaryRefreshTimer = Timer(_summaryRefreshDelay, () {
      refreshSummary().catchError((Object e, StackTrace st) {
        debugPrint('inbox summary refresh failed: $e\n$st');
        return _summary.value;
      });
    });
  }

  static InboxMentionKind _parseKind(String? raw) => switch (raw) {
    'Here' => InboxMentionKind.here,
    'Everyone' => InboxMentionKind.everyone,
    'Role' => InboxMentionKind.role,
    // Direct, and anything unrecognised: the most specific kind is the safe
    // default, since it's the one that renders as "mentioned you".
    _ => InboxMentionKind.direct,
  };

  static int _asInt(Object? raw) => switch (raw) {
    final int value => value,
    final num value => value.toInt(),
    final String value => int.tryParse(value) ?? 0,
    _ => 0,
  };

  // ------------------------------------------------------------- decryption

  /// Opens whatever previews this device holds keys for.
  ///
  /// The server never decrypts, so an encrypted channel's previews arrive as
  /// ciphertext and there is no server-side text to fall back on - the row
  /// either says what was said or says it can't. Routed through the same
  /// [MessageDecryptor] the timeline uses rather than a lighter path of its
  /// own: the author-vs-credential check and the plaintext cache both matter
  /// here, and the cache means opening the channel afterwards is free.
  Future<List<InboxUnreadGroupDto>> _decryptGroups(
    List<InboxUnreadGroupDto> groups,
  ) async {
    final result = <InboxUnreadGroupDto>[];
    for (final group in groups) {
      if (!group.previews.any((p) => p.isEncrypted)) {
        result.add(group);
        continue;
      }
      final previews = <InboxMessageDto>[];
      for (final preview in group.previews) {
        previews.add(
          await _decryptPreview(preview, group.breadcrumb.channelId),
        );
      }
      result.add(group.copyWith(previews: previews));
    }
    return result;
  }

  Future<List<InboxMentionDto>> _decryptMentions(
    List<InboxMentionDto> mentions,
  ) async {
    final result = <InboxMentionDto>[];
    for (final mention in mentions) {
      final message = mention.message;
      final contextId = mention.contextId;
      if (message == null || !message.isEncrypted || contextId == null) {
        result.add(mention);
        continue;
      }
      result.add(
        mention.copyWith(message: await _decryptPreview(message, contextId)),
      );
    }
    return result;
  }

  Future<InboxMessageDto> _decryptPreview(
    InboxMessageDto preview,
    String contextId,
  ) async {
    if (!preview.isEncrypted || contextId.isEmpty) return preview;
    final decrypted = await _decryptor.decrypt(
      MessageDto(
        id: preview.id,
        content: preview.content,
        // `MessageDecryptor` keys on `conversationId ?? channelId` and MLS
        // contexts are one id space, so a DM's conversation id is at home in
        // this field too.
        channelId: contextId,
        authorId: preview.authorId,
        createdAt: preview.createdAt,
        encryptionState: MessageEncryptionState.encrypted,
        mlsGeneration: preview.mlsGeneration,
      ),
    );
    return preview.copyWith(
      content: decrypted.content,
      // Replaced, not merely checked: the decryptor swaps in the credential
      // openmls authenticated, and that is the only value the row's name and
      // avatar may be resolved from.
      authorId: decrypted.authorId,
      isUndecryptable: decrypted.isUndecryptable,
    );
  }
}
