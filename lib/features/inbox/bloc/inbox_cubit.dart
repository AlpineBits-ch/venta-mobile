import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/safe_emit.dart';
import '../data/inbox_repository.dart';
import '../data/models/inbox_mention_dto.dart';
import '../data/models/inbox_unread_dto.dart';

enum InboxTabStatus { loading, loaded, failed }

/// Which mention kinds the Mentions tab asks for. Everything defaults on,
/// matching the endpoint's own defaults.
class InboxMentionFilters extends Equatable {
  const InboxMentionFilters({
    this.since = InboxMentionSince.week,
    this.includeEveryone = true,
    this.includeRoles = true,
    this.includeDms = true,
    this.guildScoped = false,
  });

  final InboxMentionSince since;
  final bool includeEveryone;
  final bool includeRoles;
  final bool includeDms;

  /// Restrict to the guild the inbox was opened from. Only offered when there
  /// is one - see `InboxScreen`.
  final bool guildScoped;

  InboxMentionFilters copyWith({
    InboxMentionSince? since,
    bool? includeEveryone,
    bool? includeRoles,
    bool? includeDms,
    bool? guildScoped,
  }) => InboxMentionFilters(
    since: since ?? this.since,
    includeEveryone: includeEveryone ?? this.includeEveryone,
    includeRoles: includeRoles ?? this.includeRoles,
    includeDms: includeDms ?? this.includeDms,
    guildScoped: guildScoped ?? this.guildScoped,
  );

  @override
  List<Object?> get props => [
    since,
    includeEveryone,
    includeRoles,
    includeDms,
    guildScoped,
  ];
}

class InboxState extends Equatable {
  const InboxState({
    this.unreadStatus = InboxTabStatus.loading,
    this.groups = const [],
    this.unreadCursor,
    this.loadingMoreUnread = false,
    this.previewsUnavailable = false,
    this.mentionStatus = InboxTabStatus.loading,
    this.mentions = const [],
    this.mentionCursor,
    this.loadingMoreMentions = false,
    this.filters = const InboxMentionFilters(),
    this.dismissing = const {},
    this.markingRead = const {},
    this.hasNewMentions = false,
    this.markingAllRead = false,
  });

  final InboxTabStatus unreadStatus;
  final List<InboxUnreadGroupDto> groups;

  /// Non-null means there is more to fetch - including when [groups] is empty,
  /// which is what "an empty page with a cursor means keep going" looks like
  /// once it reaches the UI.
  final String? unreadCursor;
  final bool loadingMoreUnread;

  /// The message service was unreachable. Groups, counts and breadcrumbs are
  /// still correct - only the bodies are missing.
  final bool previewsUnavailable;

  final InboxTabStatus mentionStatus;
  final List<InboxMentionDto> mentions;
  final String? mentionCursor;
  final bool loadingMoreMentions;
  final InboxMentionFilters filters;

  /// Message ids with a dismiss in flight.
  final Set<String> dismissing;

  /// Channel ids with a mark-as-read in flight.
  final Set<String> markingRead;

  /// A mention arrived over the hub while this list was open. Surfaced as a
  /// "refresh" affordance rather than spliced in: the list is keyset-paged and
  /// the caller may be halfway down it.
  final bool hasNewMentions;
  final bool markingAllRead;

  bool get hasMoreUnread => unreadCursor != null;
  bool get hasMoreMentions => mentionCursor != null;

  InboxState copyWith({
    InboxTabStatus? unreadStatus,
    List<InboxUnreadGroupDto>? groups,
    String? unreadCursor,
    bool clearUnreadCursor = false,
    bool? loadingMoreUnread,
    bool? previewsUnavailable,
    InboxTabStatus? mentionStatus,
    List<InboxMentionDto>? mentions,
    String? mentionCursor,
    bool clearMentionCursor = false,
    bool? loadingMoreMentions,
    InboxMentionFilters? filters,
    Set<String>? dismissing,
    Set<String>? markingRead,
    bool? hasNewMentions,
    bool? markingAllRead,
  }) => InboxState(
    unreadStatus: unreadStatus ?? this.unreadStatus,
    groups: groups ?? this.groups,
    unreadCursor: clearUnreadCursor
        ? null
        : (unreadCursor ?? this.unreadCursor),
    loadingMoreUnread: loadingMoreUnread ?? this.loadingMoreUnread,
    previewsUnavailable: previewsUnavailable ?? this.previewsUnavailable,
    mentionStatus: mentionStatus ?? this.mentionStatus,
    mentions: mentions ?? this.mentions,
    mentionCursor: clearMentionCursor
        ? null
        : (mentionCursor ?? this.mentionCursor),
    loadingMoreMentions: loadingMoreMentions ?? this.loadingMoreMentions,
    filters: filters ?? this.filters,
    dismissing: dismissing ?? this.dismissing,
    markingRead: markingRead ?? this.markingRead,
    hasNewMentions: hasNewMentions ?? this.hasNewMentions,
    markingAllRead: markingAllRead ?? this.markingAllRead,
  );

  @override
  List<Object?> get props => [
    unreadStatus,
    groups,
    unreadCursor,
    loadingMoreUnread,
    previewsUnavailable,
    mentionStatus,
    mentions,
    mentionCursor,
    loadingMoreMentions,
    filters,
    dismissing,
    markingRead,
    hasNewMentions,
    markingAllRead,
  ];
}

/// Drives both inbox tabs from one place, because the popout opens both at
/// once and renders whichever lands first - two cubits would mean two loading
/// spinners racing each other in one `TabBarView`.
class InboxCubit extends Cubit<InboxState> with SafeEmit<InboxState> {
  InboxCubit({required this.repository, this.guildId})
    : super(const InboxState()) {
    _mentionSub = repository.mentionAdded.listen((_) {
      emitIfOpen(state.copyWith(hasNewMentions: true));
    });
    // Another of this account's devices acked something. Dropping the group
    // here is what makes a second client's badge and list agree with this one.
    _readSub = repository.readStateChanged.listen((event) {
      if (event.all) {
        emitIfOpen(state.copyWith(groups: const []));
        return;
      }
      final channelId = event.channelId;
      if (channelId == null) return;
      emitIfOpen(
        state.copyWith(
          groups: [
            for (final group in state.groups)
              if (group.breadcrumb.channelId != channelId) group,
          ],
        ),
      );
    });
    load();
  }

  final InboxRepository repository;

  /// The guild the inbox was opened from, if any - the Mentions tab can scope
  /// itself to it. The Unread tab is always account-wide.
  final String? guildId;

  late final StreamSubscription<InboxMentionAdded> _mentionSub;
  late final StreamSubscription<InboxReadStateChanged> _readSub;
  Timer? _previewRetryTimer;

  /// How many times previews are retried behind a rendered list before leaving
  /// the "previews unavailable" notice standing. The groups are already right;
  /// this is only chasing bodies.
  static const _maxPreviewRetries = 3;
  static const _previewRetryDelay = Duration(seconds: 6);
  int _previewRetries = 0;

  /// Both tabs in parallel - neither waits on the other.
  Future<void> load() async {
    _previewRetryTimer?.cancel();
    _previewRetries = 0;
    emitIfOpen(
      state.copyWith(
        unreadStatus: InboxTabStatus.loading,
        mentionStatus: InboxTabStatus.loading,
        hasNewMentions: false,
      ),
    );
    await Future.wait([_loadUnread(), _loadMentions()]);
    unawaited(_refreshSummaryQuietly());
  }

  Future<void> refreshUnread() => _loadUnread();

  Future<void> refreshMentions() => _loadMentions();

  Future<void> _loadUnread() async {
    try {
      final result = await repository.loadUnread();
      emitIfOpen(
        state.copyWith(
          unreadStatus: InboxTabStatus.loaded,
          groups: result.groups,
          unreadCursor: result.nextCursor,
          clearUnreadCursor: result.nextCursor == null,
          previewsUnavailable: result.previewsUnavailable,
          loadingMoreUnread: false,
        ),
      );
      _schedulePreviewRetry(result.previewsUnavailable);
    } catch (_) {
      emitIfOpen(
        state.copyWith(
          unreadStatus: InboxTabStatus.failed,
          loadingMoreUnread: false,
        ),
      );
    }
  }

  Future<void> _loadMentions() async {
    final filters = state.filters;
    try {
      final result = await repository.loadMentions(
        guildId: filters.guildScoped ? guildId : null,
        since: filters.since,
        includeEveryone: filters.includeEveryone,
        includeRoles: filters.includeRoles,
        includeDms: filters.includeDms,
      );
      // The filters may have moved on while this was in flight; that request's
      // own run will land after it.
      if (state.filters != filters) return;
      emitIfOpen(
        state.copyWith(
          mentionStatus: InboxTabStatus.loaded,
          mentions: result.mentions,
          mentionCursor: result.nextCursor,
          clearMentionCursor: result.nextCursor == null,
          loadingMoreMentions: false,
          hasNewMentions: false,
        ),
      );
    } catch (_) {
      emitIfOpen(
        state.copyWith(
          mentionStatus: InboxTabStatus.failed,
          loadingMoreMentions: false,
        ),
      );
    }
  }

  Future<void> loadMoreUnread() async {
    final cursor = state.unreadCursor;
    if (cursor == null || state.loadingMoreUnread) return;
    emitIfOpen(state.copyWith(loadingMoreUnread: true));
    try {
      final result = await repository.loadUnread(cursor: cursor);
      emitIfOpen(
        state.copyWith(
          groups: [...state.groups, ...result.groups],
          unreadCursor: result.nextCursor,
          clearUnreadCursor: result.nextCursor == null,
          previewsUnavailable:
              state.previewsUnavailable || result.previewsUnavailable,
          loadingMoreUnread: false,
        ),
      );
    } catch (_) {
      // The cursor is kept, so the "load more" affordance stays and this is
      // retryable - a failed page is not the end of the list.
      emitIfOpen(state.copyWith(loadingMoreUnread: false));
    }
  }

  Future<void> loadMoreMentions() async {
    final cursor = state.mentionCursor;
    if (cursor == null || state.loadingMoreMentions) return;
    final filters = state.filters;
    emitIfOpen(state.copyWith(loadingMoreMentions: true));
    try {
      final result = await repository.loadMentions(
        guildId: filters.guildScoped ? guildId : null,
        since: filters.since,
        includeEveryone: filters.includeEveryone,
        includeRoles: filters.includeRoles,
        includeDms: filters.includeDms,
        cursor: cursor,
      );
      if (state.filters != filters) return;
      emitIfOpen(
        state.copyWith(
          mentions: [...state.mentions, ...result.mentions],
          mentionCursor: result.nextCursor,
          clearMentionCursor: result.nextCursor == null,
          loadingMoreMentions: false,
        ),
      );
    } catch (_) {
      emitIfOpen(state.copyWith(loadingMoreMentions: false));
    }
  }

  void setFilters(InboxMentionFilters filters) {
    if (filters == state.filters) return;
    emitIfOpen(
      state.copyWith(
        filters: filters,
        mentionStatus: InboxTabStatus.loading,
        mentions: const [],
        clearMentionCursor: true,
      ),
    );
    unawaited(_loadMentions());
  }

  /// Marks a channel read and drops it from the list.
  ///
  /// Optimistic: the row disappears immediately and is put back if the write
  /// fails, because the alternative is a check button that appears to do
  /// nothing for the length of a round-trip.
  Future<bool> markGroupRead(InboxUnreadGroupDto group) async {
    final channelId = group.breadcrumb.channelId;
    if (channelId.isEmpty || state.markingRead.contains(channelId)) return true;
    final previous = state.groups;
    emitIfOpen(
      state.copyWith(
        markingRead: {...state.markingRead, channelId},
        groups: [
          for (final candidate in previous)
            if (candidate.breadcrumb.channelId != channelId) candidate,
        ],
      ),
    );
    try {
      await repository.markChannelRead(
        channelId,
        mentionCount: group.mentionCount,
      );
      emitIfOpen(
        state.copyWith(markingRead: {...state.markingRead}..remove(channelId)),
      );
      return true;
    } catch (_) {
      emitIfOpen(
        state.copyWith(
          groups: previous,
          markingRead: {...state.markingRead}..remove(channelId),
        ),
      );
      return false;
    }
  }

  Future<bool> markAllRead() async {
    if (state.markingAllRead) return true;
    emitIfOpen(state.copyWith(markingAllRead: true));
    try {
      await repository.markAllRead();
      emitIfOpen(
        state.copyWith(
          groups: const [],
          clearUnreadCursor: true,
          markingAllRead: false,
        ),
      );
      return true;
    } catch (_) {
      emitIfOpen(state.copyWith(markingAllRead: false));
      return false;
    }
  }

  /// Removes one mention row. Idempotent server-side, so a double-tap is
  /// harmless; the in-flight set only exists to stop the row animating twice.
  Future<bool> dismissMention(InboxMentionDto mention) async {
    if (state.dismissing.contains(mention.messageId)) return true;
    final previous = state.mentions;
    emitIfOpen(
      state.copyWith(
        dismissing: {...state.dismissing, mention.messageId},
        mentions: [
          for (final candidate in previous)
            if (candidate.messageId != mention.messageId) candidate,
        ],
      ),
    );
    try {
      await repository.dismissMention(mention);
      emitIfOpen(
        state.copyWith(
          dismissing: {...state.dismissing}..remove(mention.messageId),
        ),
      );
      return true;
    } catch (_) {
      emitIfOpen(
        state.copyWith(
          mentions: previous,
          dismissing: {...state.dismissing}..remove(mention.messageId),
        ),
      );
      return false;
    }
  }

  /// Refetches the unread page in the background purely to pick up message
  /// bodies - the list stays on screen throughout, because the groups it is
  /// showing were never the thing that failed.
  void _schedulePreviewRetry(bool unavailable) {
    _previewRetryTimer?.cancel();
    if (!unavailable || _previewRetries >= _maxPreviewRetries) return;
    _previewRetryTimer = Timer(_previewRetryDelay, () async {
      _previewRetries++;
      try {
        final result = await repository.loadUnread();
        if (result.previewsUnavailable) {
          _schedulePreviewRetry(true);
          return;
        }
        emitIfOpen(
          state.copyWith(
            groups: result.groups,
            unreadCursor: result.nextCursor,
            clearUnreadCursor: result.nextCursor == null,
            previewsUnavailable: false,
          ),
        );
      } catch (_) {
        _schedulePreviewRetry(true);
      }
    });
  }

  Future<void> _refreshSummaryQuietly() async {
    try {
      await repository.refreshSummary();
    } catch (_) {
      // The badge keeps whatever the hub last told it - a failed summary is
      // not worth a visible error on a screen that just rendered its contents.
    }
  }

  @override
  Future<void> close() {
    _previewRetryTimer?.cancel();
    unawaited(_mentionSub.cancel());
    unawaited(_readSub.cancel());
    return super.close();
  }
}
