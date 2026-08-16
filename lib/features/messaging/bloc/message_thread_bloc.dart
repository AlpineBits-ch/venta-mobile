import 'dart:async';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/safe_emit.dart';
import '../../../core/di/injector.dart';
import '../../../core/format/api_date_time.dart';
import '../../../core/network/privacy_refusal.dart';
import '../../../core/realtime/realtime_event.dart';
import '../../../core/realtime/realtime_service.dart';
import '../../../core/sound/sound_service.dart';
import '../../privacy/data/privacy_repository.dart';
import '../data/message_api.dart';
import '../data/message_content_codec.dart';
import '../data/message_repository.dart';
import '../data/models/attachment_dto.dart';
import '../data/models/message_dto.dart';
import '../data/models/message_reaction_dto.dart';

/// `MessageDto.flags` bit 2 - suppressed embeds. Mirrored here (rather than
/// only in the DTO's extension) because the optimistic toggle has to set and
/// clear it, not just read it.
const _suppressEmbedsFlag = 1 << 2;

sealed class ThreadEvent extends Equatable {
  const ThreadEvent();

  @override
  List<Object?> get props => [];
}

class ThreadOpened extends ThreadEvent {
  const ThreadOpened();
}

class ThreadLoadMoreRequested extends ThreadEvent {
  const ThreadLoadMoreRequested();
}

class ThreadMessageSubmitted extends ThreadEvent {
  const ThreadMessageSubmitted(
    this.text, {
    this.attachments = const [],
    this.replyToId,
    this.mentionedUserIds = const [],
    this.mentionedRoleIds = const [],
    this.mentionsEveryone = false,
    this.mentionsHere = false,
  });
  final String text;
  final List<AttachmentDto> attachments;
  final String? replyToId;
  final List<String> mentionedUserIds;
  final List<String> mentionedRoleIds;
  final bool mentionsEveryone;
  final bool mentionsHere;

  @override
  List<Object?> get props => [
    text,
    attachments,
    replyToId,
    mentionedUserIds,
    mentionedRoleIds,
    mentionsEveryone,
    mentionsHere,
  ];
}

/// Edits an existing message's content - optimistic-first like reactions,
/// rolled back to [previousText] if the HTTP call fails.
class MessageEditRequested extends ThreadEvent {
  const MessageEditRequested({required this.messageId, required this.newText});
  final String messageId;
  final String newText;

  @override
  List<Object?> get props => [messageId, newText];
}

/// Deletes a message - optimistic-first, reinserted at its original index
/// if the HTTP call fails.
class MessageDeleteRequested extends ThreadEvent {
  const MessageDeleteRequested(this.messageId);
  final String messageId;

  @override
  List<Object?> get props => [messageId];
}

class ThreadTypingNotified extends ThreadEvent {
  const ThreadTypingNotified();
}

/// Toggles the caller's own reaction on a message - adds it if they haven't
/// reacted with this emoji yet, removes it if they have. Applied optimistic-
/// first (mirrors Alpine's `toggleReaction`), rolled back if the HTTP call
/// fails. [emoji] is always the display text (a Unicode glyph, or a custom
/// emoji's name as fallback); [emojiId] is set only for a custom guild
/// emoji, in which case reactions are matched/sent by id rather than name.
class ReactionToggled extends ThreadEvent {
  const ReactionToggled({
    required this.messageId,
    required this.emoji,
    this.emojiId,
  });
  final String messageId;
  final String emoji;
  final String? emojiId;

  @override
  List<Object?> get props => [messageId, emoji, emojiId];
}

/// Toggles a message's pinned state - optimistic-first like reactions,
/// rolled back if the HTTP call fails. Guild-channel gating (`PinMessages`)
/// happens in the UI before this is even dispatched; DMs allow any member.
class MessagePinToggled extends ThreadEvent {
  const MessagePinToggled(this.messageId);
  final String messageId;

  @override
  List<Object?> get props => [messageId];
}

/// Dismisses this message's link previews, or restores them if they were
/// already dismissed. Not a per-viewer preference - it changes the message for
/// everyone who can see it, so the caller gates the action on being the author
/// or holding `DeleteAnyMessage`.
class MessageEmbedsSuppressionToggled extends ThreadEvent {
  const MessageEmbedsSuppressionToggled(this.messageId);
  final String messageId;

  @override
  List<Object?> get props => [messageId];
}

/// Registers a synthetic "the bot is working on it" row while a slash
/// command invocation is in flight - the caller (the composer) has already
/// fired the HTTP invoke; this just reserves the placeholder + starts the
/// await-with-timeout. The real reply resolves it via the normal
/// `guild.MessageCreated` realtime path in [_onMessageReceived] once the bot
/// posts (there's no correlation id from the server - see `BotCommandApi`).
class ThreadBotPlaceholderAdded extends ThreadEvent {
  const ThreadBotPlaceholderAdded({
    required this.tempId,
    required this.botUserId,
  });
  final String tempId;
  final String botUserId;

  @override
  List<Object?> get props => [tempId, botUserId];
}

/// The invoke HTTP call itself failed before the server could even accept
/// it - resolves the placeholder as failed immediately rather than waiting
/// out the full timeout.
class ThreadBotPlaceholderFailed extends ThreadEvent {
  const ThreadBotPlaceholderFailed(this.tempId);
  final String tempId;

  @override
  List<Object?> get props => [tempId];
}

class _BotPlaceholderTimedOut extends ThreadEvent {
  const _BotPlaceholderTimedOut(this.tempId);
  final String tempId;

  @override
  List<Object?> get props => [tempId];
}

class _MessageReceived extends ThreadEvent {
  const _MessageReceived(this.message);
  final MessageDto message;

  @override
  List<Object?> get props => [message];
}

/// A bot reply only this user was sent, which the server never stored.
///
/// Carried as its own event rather than folded into [_MessageReceived] because
/// the two end differently: this one is never marked read (there is no row to
/// mark) and lands already flagged, so nothing downstream offers edit, delete,
/// pin or reply on it.
class _EphemeralMessageReceived extends ThreadEvent {
  const _EphemeralMessageReceived(this.message);
  final MessageDto message;

  @override
  List<Object?> get props => [message];
}

class _MessageUpdatedRemote extends ThreadEvent {
  const _MessageUpdatedRemote({
    required this.messageId,
    this.content,
    this.embedsJson,
    this.flags,
    this.editedAt,
    this.isAuthorEdit = true,
    this.isUndecryptable = false,
    this.isUnverifiedPlaintext = false,
  });
  final String messageId;

  /// Null leaves the text alone - see [RemoteMessageUpdated.content].
  final String? content;
  final String? embedsJson;
  final int? flags;
  final DateTime? editedAt;
  final bool isAuthorEdit;
  final bool isUndecryptable;
  final bool isUnverifiedPlaintext;

  @override
  List<Object?> get props => [
    messageId,
    content,
    embedsJson,
    flags,
    editedAt,
    isAuthorEdit,
    isUndecryptable,
    isUnverifiedPlaintext,
  ];
}

class _MessageDeletedRemote extends ThreadEvent {
  const _MessageDeletedRemote(this.messageId);
  final String messageId;

  @override
  List<Object?> get props => [messageId];
}

class _UserTypingRemote extends ThreadEvent {
  const _UserTypingRemote(this.userId);
  final String userId;

  @override
  List<Object?> get props => [userId];
}

class _ReactionAddedRemote extends ThreadEvent {
  const _ReactionAddedRemote({
    required this.messageId,
    required this.emoji,
    required this.userId,
    this.emojiId,
  });
  final String messageId;
  final String emoji;
  final String userId;
  final String? emojiId;

  @override
  List<Object?> get props => [messageId, emoji, userId, emojiId];
}

class _ReactionRemovedRemote extends ThreadEvent {
  const _ReactionRemovedRemote({
    required this.messageId,
    required this.emoji,
    required this.userId,
    this.emojiId,
  });
  final String messageId;
  final String emoji;
  final String userId;
  final String? emojiId;

  @override
  List<Object?> get props => [messageId, emoji, userId, emojiId];
}

class _MessagePinnedRemote extends ThreadEvent {
  const _MessagePinnedRemote({
    required this.messageId,
    required this.pinnedById,
    required this.pinnedAt,
  });
  final String messageId;
  final String pinnedById;
  final DateTime pinnedAt;

  @override
  List<Object?> get props => [messageId, pinnedById, pinnedAt];
}

class _MessageUnpinnedRemote extends ThreadEvent {
  const _MessageUnpinnedRemote(this.messageId);
  final String messageId;

  @override
  List<Object?> get props => [messageId];
}

class _TypingExpired extends ThreadEvent {
  const _TypingExpired(this.userId);
  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// One cohesive state, not a sealed union: "loading older page", "have a
/// pending send", and "someone is typing" are all simultaneously true in a
/// real thread, so a mutually-exclusive union fits worse here than in
/// Auth/Friends - a deliberate deviation, documented for future maintainers.
class ThreadState extends Equatable {
  const ThreadState({
    this.messages = const [],
    this.isLoadingInitial = true,
    this.isLoadingMore = false,
    this.hasMoreOlder = true,
    this.pendingSendIds = const {},
    this.failedSendIds = const {},
    this.typingUserIds = const {},
    this.error,
  });

  /// Newest-first, feeds a `ListView.builder(reverse: true, ...)` directly.
  final List<MessageDto> messages;
  final bool isLoadingInitial;
  final bool isLoadingMore;
  final bool hasMoreOlder;
  final Set<String> pendingSendIds;
  final Set<String> failedSendIds;
  final Set<String> typingUserIds;
  final String? error;

  ThreadState copyWith({
    List<MessageDto>? messages,
    bool? isLoadingInitial,
    bool? isLoadingMore,
    bool? hasMoreOlder,
    Set<String>? pendingSendIds,
    Set<String>? failedSendIds,
    Set<String>? typingUserIds,
    String? error,
  }) => ThreadState(
    messages: messages ?? this.messages,
    isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    hasMoreOlder: hasMoreOlder ?? this.hasMoreOlder,
    pendingSendIds: pendingSendIds ?? this.pendingSendIds,
    failedSendIds: failedSendIds ?? this.failedSendIds,
    typingUserIds: typingUserIds ?? this.typingUserIds,
    error: error,
  );

  @override
  List<Object?> get props => [
    messages,
    isLoadingInitial,
    isLoadingMore,
    hasMoreOlder,
    pendingSendIds,
    failedSendIds,
    typingUserIds,
    error,
  ];
}

class MessageThreadBloc extends Bloc<ThreadEvent, ThreadState> {
  MessageThreadBloc({
    required this.repository,
    required this.myUserId,
    required this.soundService,
    required this.privacy,

    /// The hub, for the one message event that does not come through
    /// [repository]. Optional so the screens that build this bloc - and the
    /// tests that build it with no injector configured at all - need no
    /// change; see [_resolveRealtimeService].
    RealtimeService? realtimeService,
  }) : super(const ThreadState()) {
    on<ThreadOpened>(_onOpened);
    on<ThreadLoadMoreRequested>(_onLoadMoreRequested);
    on<ThreadMessageSubmitted>(_onMessageSubmitted);
    on<MessageEditRequested>(_onMessageEditRequested);
    on<MessageDeleteRequested>(_onMessageDeleteRequested);
    on<ThreadTypingNotified>(_onTypingNotified);
    on<ReactionToggled>(_onReactionToggled);
    on<MessagePinToggled>(_onMessagePinToggled);
    on<MessageEmbedsSuppressionToggled>(_onMessageEmbedsSuppressionToggled);
    on<ThreadBotPlaceholderAdded>(_onBotPlaceholderAdded);
    on<ThreadBotPlaceholderFailed>(_onBotPlaceholderFailed);
    on<_BotPlaceholderTimedOut>(_onBotPlaceholderTimedOut);
    on<_MessageReceived>(_onMessageReceived);
    on<_EphemeralMessageReceived>(_onEphemeralMessageReceived);
    on<_MessageUpdatedRemote>(_onMessageUpdatedRemote);
    on<_MessageDeletedRemote>(_onMessageDeletedRemote);
    on<_UserTypingRemote>(_onUserTypingRemote);
    on<_TypingExpired>(_onTypingExpired);
    on<_ReactionAddedRemote>(_onReactionAddedRemote);
    on<_ReactionRemovedRemote>(_onReactionRemovedRemote);
    on<_MessagePinnedRemote>(_onMessagePinnedRemote);
    on<_MessageUnpinnedRemote>(_onMessageUnpinnedRemote);

    _repoSub = repository.events.listen((event) {
      switch (event) {
        case RemoteMessageReceived():
          add(_MessageReceived(event.message));
        case RemoteMessageUpdated():
          add(
            _MessageUpdatedRemote(
              messageId: event.messageId,
              content: event.content,
              embedsJson: event.embedsJson,
              flags: event.flags,
              editedAt: event.editedAt,
              isAuthorEdit: event.isAuthorEdit,
              isUndecryptable: event.isUndecryptable,
              isUnverifiedPlaintext: event.isUnverifiedPlaintext,
            ),
          );
        case RemoteMessageDeleted():
          add(_MessageDeletedRemote(event.messageId));
        case RemoteUserTyping():
          add(_UserTypingRemote(event.userId));
        case RemoteReactionAdded():
          add(
            _ReactionAddedRemote(
              messageId: event.messageId,
              emoji: event.emoji,
              userId: event.userId,
              emojiId: event.emojiId,
            ),
          );
        case RemoteReactionRemoved():
          add(
            _ReactionRemovedRemote(
              messageId: event.messageId,
              emoji: event.emoji,
              userId: event.userId,
              emojiId: event.emojiId,
            ),
          );
        case RemoteMessagePinned():
          add(
            _MessagePinnedRemote(
              messageId: event.messageId,
              pinnedById: event.pinnedById,
              pinnedAt: event.pinnedAt,
            ),
          );
        case RemoteMessageUnpinned():
          add(_MessageUnpinnedRemote(event.messageId));
      }
    });

    // `guild.EphemeralMessageCreated` is read straight off the hub rather than
    // through [MessageRepository] like every other message event, because it is
    // not a message that repository could ever fetch, decrypt, edit or write
    // back: there is no row behind it. It exists in this thread's list for as
    // long as the thread is open, and nowhere else.
    _ephemeralSub = (realtimeService ?? _resolveRealtimeService())?.events
        .where((e) => e.name == 'guild.EphemeralMessageCreated')
        .listen(_handleEphemeralEvent);

    add(const ThreadOpened());
  }

  /// The hub, when this build has one.
  ///
  /// Resolved from the injector rather than taken as a required argument so the
  /// two screens that construct this bloc keep working unchanged - and so a
  /// test that constructs it with no DI configured gets null instead of an
  /// exception. Null simply means this thread never sees an ephemeral reply,
  /// which is the same outcome as a channel no bot ever answers in.
  static RealtimeService? _resolveRealtimeService() =>
      getIt.isRegistered<RealtimeService>() ? getIt<RealtimeService>() : null;

  /// Turns the hub payload into something the thread can render.
  ///
  /// Guild-only by construction: the event carries a `channelId` and nothing
  /// else to match on, so a DM thread (whose [MessageRepository.channelId] is
  /// null) never accepts one.
  void _handleEphemeralEvent(RealtimeEvent event) {
    final channelId = event.stringField('channelId');
    if (channelId == null || channelId != repository.channelId) return;

    final id = event.stringField('id');
    final authorId = event.stringField('authorId');
    if (id == null || authorId == null) return;

    final embeds = event.field('embeds');

    add(
      _EphemeralMessageReceived(
        MessageDto(
          id: id,
          // **Re-encoded, not passed through.** This is the one message event
          // whose `content` is already text - every other body on this socket
          // is base64(utf8(...)) - while the bubble decodes unconditionally. A
          // plain sentence that happens to be valid base64 ("test" is) would
          // render as mojibake, and one that is not would survive only on
          // `MessageContentCodec.decode`'s tolerant fallback. Encoding here
          // puts it on the same footing as every other body in the list.
          content: MessageContentCodec.encode(
            event.stringField('content') ?? '',
          ),
          channelId: channelId,
          authorId: authorId,
          createdAt:
              tryParseApiDateTime(event.field('createdAt')) ?? DateTime.now(),
          // A bot reply by definition, which is what earns the BOT badge - the
          // author is an app, not a member anybody could look up.
          authorIdType: MessageAuthorType.bot,
          // Never ciphertext: it was never stored, so there is no generation or
          // epoch it could have been sealed under.
          encryptionState: MessageEncryptionState.plain,
          // Cards the bot wrote, arriving inline rather than as a later update -
          // there is no row for an unfurl to attach to afterwards. Stored as the
          // same JSON *string* the wire uses everywhere else, so `embeds` reads
          // identically here to a persisted message's.
          embedsJson: (embeds is List && embeds.isNotEmpty)
              ? jsonEncode(embeds)
              : null,
          // Server-chosen cleartext in a context this device holds a live MLS
          // group for is exactly what this flag describes, so it is set for what
          // it is rather than exempted for being a bot's. In a plaintext channel
          // it stays false, which is every ephemeral reply outside an encrypted
          // one - so this adds no chrome to the ordinary case.
          isUnverifiedPlaintext: repository.isEncrypted,
          isEphemeral: true,
        ),
      ),
    );
  }

  final MessageRepository repository;
  final String myUserId;
  final SoundService soundService;

  /// Read for the typing-indicator setting only. The server is the enforcement
  /// point for every privacy control in this thread; this is here so the
  /// indicator stops the moment the switch is flipped rather than at whatever
  /// point the socket next reconnects.
  final PrivacyRepository privacy;
  late final StreamSubscription<MessageRepositoryEvent> _repoSub;
  StreamSubscription<RealtimeEvent>? _ephemeralSub;
  final Map<String, Timer> _typingTimers = {};
  int _tempIdCounter = 0;

  /// FIFO queue of pending placeholder temp-ids per bot user id - a bot's
  /// next `MessageCreated` resolves its oldest still-pending placeholder.
  final Map<String, List<String>> _pendingBotTempIdsByBot = {};
  final Map<String, Timer> _botTimeoutTimers = {};

  Future<void> _onOpened(ThreadOpened event, Emitter<ThreadState> emit) async {
    try {
      final page = await repository.fetchPage();
      final sorted = _sortNewestFirst(page);
      emit.ifOpen(
        state.copyWith(
          messages: sorted,
          isLoadingInitial: false,
          hasMoreOlder: page.length >= 50,
        ),
      );
      unawaited(_markRead());
    } catch (_) {
      emit.ifOpen(
        state.copyWith(
          isLoadingInitial: false,
          error: 'Could not load messages.',
        ),
      );
    }
  }

  Future<void> _onLoadMoreRequested(
    ThreadLoadMoreRequested event,
    Emitter<ThreadState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasMoreOlder) return;
    emit.ifOpen(state.copyWith(isLoadingMore: true));
    try {
      final page = await repository.fetchPage(offset: state.messages.length);
      final merged = _sortNewestFirst([...state.messages, ...page]);
      emit.ifOpen(
        state.copyWith(
          messages: merged,
          isLoadingMore: false,
          hasMoreOlder: page.length >= 50,
        ),
      );
    } catch (_) {
      emit.ifOpen(state.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onMessageSubmitted(
    ThreadMessageSubmitted event,
    Emitter<ThreadState> emit,
  ) async {
    final text = event.text.trim();
    if (text.isEmpty && event.attachments.isEmpty) return;

    final tempId = 'pending-${_tempIdCounter++}';
    final optimistic = repository.buildOptimistic(
      id: tempId,
      authorId: myUserId,
      encodedContent: MessageContentCodec.encode(text),
      attachments: event.attachments,
      inReplyTo: event.replyToId,
      mentions: event.mentionedUserIds,
      roleMentions: event.mentionedRoleIds,
      mentionsEveryone: event.mentionsEveryone,
      mentionsHere: event.mentionsHere,
    );
    emit.ifOpen(
      state.copyWith(
        messages: [optimistic, ...state.messages],
        pendingSendIds: {...state.pendingSendIds, tempId},
      ),
    );

    try {
      final sent = await repository.send(
        plaintextContent: text,
        attachments: event.attachments,
        inReplyTo: event.replyToId,
        mentions: event.mentionedUserIds,
        roleMentions: event.mentionedRoleIds,
        mentionsEveryone: event.mentionsEveryone,
        mentionsHere: event.mentionsHere,
      );
      emit.ifOpen(
        state.copyWith(
          messages: [
            for (final m in state.messages)
              if (m.id == tempId) sent else m,
          ],
          pendingSendIds: {...state.pendingSendIds}..remove(tempId),
        ),
      );
    } on AutoModBlockedException catch (e) {
      // Retrying identical blocked content would just fail again, so drop
      // the optimistic bubble entirely rather than leaving a permanently
      // "failed, tap to retry" message sitting in the thread.
      emit.ifOpen(
        state.copyWith(
          messages: [
            for (final m in state.messages)
              if (m.id != tempId) m,
          ],
          pendingSendIds: {...state.pendingSendIds}..remove(tempId),
          error: e.message,
        ),
      );
    } on PrivacyRefusalException catch (e) {
      // The recipient's DM policy, or a block. Same treatment as automod when
      // it is a decision - the send will never succeed and a retry affordance
      // would be a lie. `lookupUnavailable` is the exception: nothing was
      // decided, so the bubble stays as a failed send the user can retry.
      emit.ifOpen(
        state.copyWith(
          messages: [
            for (final m in state.messages)
              if (e.isRetryable || m.id != tempId) m,
          ],
          pendingSendIds: {...state.pendingSendIds}..remove(tempId),
          failedSendIds: e.isRetryable
              ? {...state.failedSendIds, tempId}
              : state.failedSendIds,
          error: e.message,
        ),
      );
    } catch (_) {
      emit.ifOpen(
        state.copyWith(
          pendingSendIds: {...state.pendingSendIds}..remove(tempId),
          failedSendIds: {...state.failedSendIds, tempId},
        ),
      );
    }
  }

  Future<void> _onTypingNotified(
    ThreadTypingNotified event,
    Emitter<ThreadState> emit,
  ) async {
    if (!privacy.shouldSendTypingIndicators) return;
    await repository.sendTypingIndicator();
  }

  Future<void> _onReactionToggled(
    ReactionToggled event,
    Emitter<ThreadState> emit,
  ) async {
    final hasOwn = state.messages.any(
      (m) =>
          m.id == event.messageId &&
          m.reactions.any(
            (r) =>
                _sameReaction(r, event.emoji, event.emojiId) &&
                r.userId == myUserId,
          ),
    );

    emit.ifOpen(
      state.copyWith(
        messages: _withReactions(
          event.messageId,
          (reactions) => hasOwn
              ? reactions
                    .where(
                      (r) =>
                          !(_sameReaction(r, event.emoji, event.emojiId) &&
                              r.userId == myUserId),
                    )
                    .toList()
              : [
                  ...reactions,
                  MessageReactionDto(
                    messageId: event.messageId,
                    emoji: event.emoji,
                    emojiId: event.emojiId,
                    userId: myUserId,
                    createdAt: DateTime.now(),
                  ),
                ],
        ),
      ),
    );

    try {
      if (hasOwn) {
        await repository.removeReaction(event.messageId, event.emoji);
      } else {
        await repository.addReaction(
          event.messageId,
          event.emoji,
          emojiId: event.emojiId,
        );
      }
    } catch (_) {
      // Roll back to the pre-toggle state.
      emit.ifOpen(
        state.copyWith(
          messages: _withReactions(
            event.messageId,
            (reactions) => hasOwn
                ? [
                    ...reactions,
                    MessageReactionDto(
                      messageId: event.messageId,
                      emoji: event.emoji,
                      emojiId: event.emojiId,
                      userId: myUserId,
                      createdAt: DateTime.now(),
                    ),
                  ]
                : reactions
                      .where(
                        (r) =>
                            !(_sameReaction(r, event.emoji, event.emojiId) &&
                                r.userId == myUserId),
                      )
                      .toList(),
          ),
        ),
      );
    }
  }

  Future<void> _onMessagePinToggled(
    MessagePinToggled event,
    Emitter<ThreadState> emit,
  ) async {
    final previous = state.messages
        .where((m) => m.id == event.messageId)
        .firstOrNull;
    if (previous == null) return;
    final wasPinned = previous.isPinned;

    emit.ifOpen(
      state.copyWith(
        messages: _updateMessage(
          event.messageId,
          (m) => wasPinned
              ? m.copyWith(isPinned: false, pinnedAt: null, pinnedById: null)
              : m.copyWith(
                  isPinned: true,
                  pinnedAt: DateTime.now(),
                  pinnedById: myUserId,
                ),
        ),
      ),
    );

    try {
      if (wasPinned) {
        await repository.unpinMessage(event.messageId);
      } else {
        await repository.pinMessage(event.messageId);
      }
    } catch (_) {
      emit.ifOpen(
        state.copyWith(
          messages: _updateMessage(event.messageId, (_) => previous),
        ),
      );
    }
  }

  void _onMessagePinnedRemote(
    _MessagePinnedRemote event,
    Emitter<ThreadState> emit,
  ) {
    emit.ifOpen(
      state.copyWith(
        messages: _updateMessage(
          event.messageId,
          (m) => m.copyWith(
            isPinned: true,
            pinnedAt: event.pinnedAt,
            pinnedById: event.pinnedById,
          ),
        ),
      ),
    );
  }

  void _onMessageUnpinnedRemote(
    _MessageUnpinnedRemote event,
    Emitter<ThreadState> emit,
  ) {
    emit.ifOpen(
      state.copyWith(
        messages: _updateMessage(
          event.messageId,
          (m) => m.copyWith(isPinned: false, pinnedAt: null, pinnedById: null),
        ),
      ),
    );
  }

  /// True when [reaction] represents the same reaction as [emoji]/[emojiId]
  /// - custom guild emoji are matched by id (the `emoji` field is just a
  /// text fallback and can collide across different custom emoji with the
  /// same name), Unicode reactions by the literal glyph.
  bool _sameReaction(
    MessageReactionDto reaction,
    String emoji,
    String? emojiId,
  ) => emojiId != null
      ? reaction.emojiId == emojiId
      : reaction.emoji == emoji && reaction.emojiId == null;

  Future<void> _onMessageEditRequested(
    MessageEditRequested event,
    Emitter<ThreadState> emit,
  ) async {
    final previous = state.messages
        .where((m) => m.id == event.messageId)
        .firstOrNull;
    if (previous == null) return;

    emit.ifOpen(
      state.copyWith(
        messages: [
          for (final m in state.messages)
            if (m.id == event.messageId)
              m.copyWith(content: MessageContentCodec.encode(event.newText))
            else
              m,
        ],
      ),
    );

    try {
      final updated = await repository.editMessage(
        event.messageId,
        event.newText,
        // The row keeps the generation it was first sealed under, so the edit
        // has to be sealed under the same one or every reader resolves it to
        // the wrong group.
        mlsGeneration: previous.mlsGeneration,
      );
      emit.ifOpen(
        state.copyWith(
          messages: [
            for (final m in state.messages)
              if (m.id == event.messageId) updated else m,
          ],
        ),
      );
    } catch (_) {
      emit.ifOpen(
        state.copyWith(
          messages: [
            for (final m in state.messages)
              if (m.id == event.messageId) previous else m,
          ],
        ),
      );
    }
  }

  Future<void> _onMessageDeleteRequested(
    MessageDeleteRequested event,
    Emitter<ThreadState> emit,
  ) async {
    final index = state.messages.indexWhere((m) => m.id == event.messageId);
    if (index == -1) return;
    final removed = state.messages[index];

    emit.ifOpen(
      state.copyWith(
        messages: [
          for (final m in state.messages)
            if (m.id != event.messageId) m,
        ],
      ),
    );

    try {
      await repository.deleteMessage(event.messageId);
    } catch (_) {
      final restored = [...state.messages];
      restored.insert(index.clamp(0, restored.length), removed);
      emit.ifOpen(state.copyWith(messages: restored));
    }
  }

  void _onReactionAddedRemote(
    _ReactionAddedRemote event,
    Emitter<ThreadState> emit,
  ) {
    emit.ifOpen(
      state.copyWith(
        messages: _withReactions(event.messageId, (reactions) {
          if (reactions.any(
            (r) =>
                _sameReaction(r, event.emoji, event.emojiId) &&
                r.userId == event.userId,
          )) {
            return reactions;
          }
          return [
            ...reactions,
            MessageReactionDto(
              messageId: event.messageId,
              emoji: event.emoji,
              emojiId: event.emojiId,
              userId: event.userId,
              createdAt: DateTime.now(),
            ),
          ];
        }),
      ),
    );
  }

  void _onReactionRemovedRemote(
    _ReactionRemovedRemote event,
    Emitter<ThreadState> emit,
  ) {
    emit.ifOpen(
      state.copyWith(
        messages: _withReactions(
          event.messageId,
          (reactions) => reactions
              .where(
                (r) =>
                    !(_sameReaction(r, event.emoji, event.emojiId) &&
                        r.userId == event.userId),
              )
              .toList(),
        ),
      ),
    );
  }

  /// Returns [state.messages] with [messageId]'s `reactions` list replaced by
  /// running [update] over its current reactions - a no-op if the message
  /// isn't currently loaded (e.g. it scrolled out of the fetched page).
  List<MessageDto> _withReactions(
    String messageId,
    List<MessageReactionDto> Function(List<MessageReactionDto>) update,
  ) {
    return [
      for (final m in state.messages)
        if (m.id == messageId)
          m.copyWith(reactions: update(m.reactions))
        else
          m,
    ];
  }

  /// Returns [state.messages] with [messageId] replaced by running [update]
  /// over it - a no-op if the message isn't currently loaded.
  List<MessageDto> _updateMessage(
    String messageId,
    MessageDto Function(MessageDto) update,
  ) {
    return [
      for (final m in state.messages)
        if (m.id == messageId) update(m) else m,
    ];
  }

  void _onBotPlaceholderAdded(
    ThreadBotPlaceholderAdded event,
    Emitter<ThreadState> emit,
  ) {
    final placeholder = MessageDto(
      id: event.tempId,
      content: '',
      conversationId: repository.conversationId,
      channelId: repository.channelId,
      authorId: event.botUserId,
      createdAt: DateTime.now(),
      isPending: true,
      isBotCommandPlaceholder: true,
      authorIdType: MessageAuthorType.bot,
    );
    emit.ifOpen(
      state.copyWith(
        messages: [placeholder, ...state.messages],
        pendingSendIds: {...state.pendingSendIds, event.tempId},
      ),
    );
    _pendingBotTempIdsByBot
        .putIfAbsent(event.botUserId, () => [])
        .add(event.tempId);
    _botTimeoutTimers[event.tempId] = Timer(
      const Duration(seconds: 10),
      () => add(_BotPlaceholderTimedOut(event.tempId)),
    );
  }

  void _onBotPlaceholderFailed(
    ThreadBotPlaceholderFailed event,
    Emitter<ThreadState> emit,
  ) {
    _failBotPlaceholder(event.tempId, emit);
  }

  void _onBotPlaceholderTimedOut(
    _BotPlaceholderTimedOut event,
    Emitter<ThreadState> emit,
  ) {
    _failBotPlaceholder(event.tempId, emit);
  }

  void _failBotPlaceholder(String tempId, Emitter<ThreadState> emit) {
    if (!state.pendingSendIds.contains(tempId)) return;
    _botTimeoutTimers.remove(tempId)?.cancel();
    for (final queue in _pendingBotTempIdsByBot.values) {
      queue.remove(tempId);
    }
    emit.ifOpen(
      state.copyWith(
        pendingSendIds: {...state.pendingSendIds}..remove(tempId),
        failedSendIds: {...state.failedSendIds, tempId},
      ),
    );
  }

  void _onMessageReceived(_MessageReceived event, Emitter<ThreadState> emit) {
    // Our own message already landed via the REST response in
    // _onMessageSubmitted - the hub echo just needs to be ignored.
    if (state.messages.any((m) => m.id == event.message.id)) return;

    final tempId = _takeBotPlaceholder(event.message.authorId);
    if (tempId != null) {
      emit.ifOpen(
        state.copyWith(
          messages: [
            event.message,
            for (final m in state.messages)
              if (m.id != tempId) m,
          ],
          pendingSendIds: {...state.pendingSendIds}..remove(tempId),
        ),
      );
      return;
    }

    emit.ifOpen(state.copyWith(messages: [event.message, ...state.messages]));
    if (event.message.authorId != myUserId) {
      unawaited(soundService.playNewMessage());
      unawaited(_markRead());
    }
  }

  /// A bot reply only this user was sent, which the server never stored.
  ///
  /// Inserted like any other message so the thread renders it in place, and
  /// flagged so nothing offers to edit, delete, pin or reply to something with
  /// no server-side row to act on. Deliberately **not** marked read and not
  /// counted towards the pagination offset: that offset is a cursor into
  /// server-side history, and shifting it by a message history does not contain
  /// would make the next page skip a real one.
  void _onEphemeralMessageReceived(
    _EphemeralMessageReceived event,
    Emitter<ThreadState> emit,
  ) {
    if (state.messages.any((m) => m.id == event.message.id)) return;

    // A slash command answered ephemerally is the ordinary case, not an exotic
    // one - so it resolves its placeholder exactly as a stored reply would.
    // Without this the placeholder sits spinning for its full timeout and then
    // marks itself failed, directly beside the reply that did arrive.
    final tempId = _takeBotPlaceholder(event.message.authorId);

    emit.ifOpen(
      state.copyWith(
        messages: [
          event.message,
          for (final m in state.messages)
            if (m.id != tempId) m,
        ],
        pendingSendIds: tempId == null
            ? null
            : ({...state.pendingSendIds}..remove(tempId)),
      ),
    );
    // No sound and no read marker: this is the answer to something this user
    // just did, and there is no row on the server for a read cursor to point at.
  }

  /// Claims the oldest still-pending placeholder for [botUserId], if there is
  /// one, and stops its timeout. Returns the temp id whose row the arriving
  /// reply replaces, or null when this bot has nothing outstanding.
  String? _takeBotPlaceholder(String botUserId) {
    final queue = _pendingBotTempIdsByBot[botUserId];
    if (queue == null || queue.isEmpty) return null;
    final tempId = queue.removeAt(0);
    _botTimeoutTimers.remove(tempId)?.cancel();
    return tempId;
  }

  void _onMessageUpdatedRemote(
    _MessageUpdatedRemote event,
    Emitter<ThreadState> emit,
  ) {
    emit.ifOpen(
      state.copyWith(
        messages: _updateMessage(event.messageId, (m) {
          // An update the author did not cause - a link preview attaching, a
          // suppression - must not disturb the text, the edit marker, or the
          // decryption flags that describe the text. Those updates carry no
          // body at all today; refusing one that does is the same call this
          // file already makes everywhere else, since a server-chosen body on a
          // channel nobody edited is exactly the injection path.
          final content = event.isAuthorEdit ? event.content : null;
          if (content == null) {
            return m.copyWith(
              embedsJson: event.embedsJson ?? m.embedsJson,
              flags: event.flags ?? m.flags,
            );
          }
          return m.copyWith(
            content: content,
            embedsJson: event.embedsJson ?? m.embedsJson,
            flags: event.flags ?? m.flags,
            // Only ever set from `editedAt`. `updatedAt` moves for a preview or
            // a pin, and driving the marker off it labels every message
            // containing a link as edited a second after it was posted.
            editedAt: event.editedAt ?? m.editedAt,
            // Carried across, not dropped. An edit this device could not
            // open leaves the row showing "can't be decrypted" rather than
            // the text it used to hold, which is now stale, or the bytes the
            // server sent, which is the injection.
            isUndecryptable: event.isUndecryptable,
            isUnverifiedPlaintext: event.isUnverifiedPlaintext,
          );
        }),
      ),
    );
  }

  /// Dismisses or restores a message's link previews - for everyone, not just
  /// this viewer.
  ///
  /// Optimistic on the flag alone: dropping the cards immediately would make an
  /// unauthorised attempt (which the server answers `403`) look like it worked,
  /// and the real card state arrives moments later on a `MessageUpdated`.
  Future<void> _onMessageEmbedsSuppressionToggled(
    MessageEmbedsSuppressionToggled event,
    Emitter<ThreadState> emit,
  ) async {
    final previous = state.messages
        .where((m) => m.id == event.messageId)
        .firstOrNull;
    if (previous == null) return;
    final suppress = !previous.hasSuppressedEmbeds;

    emit.ifOpen(
      state.copyWith(
        messages: _updateMessage(
          event.messageId,
          (m) => m.copyWith(
            flags: suppress
                ? m.flags | _suppressEmbedsFlag
                : m.flags & ~_suppressEmbedsFlag,
            embedsJson: suppress ? null : m.embedsJson,
          ),
        ),
      ),
    );

    try {
      await repository.setEmbedsSuppressed(
        messageId: event.messageId,
        suppress: suppress,
      );
    } catch (_) {
      emit.ifOpen(
        state.copyWith(
          messages: _updateMessage(event.messageId, (_) => previous),
        ),
      );
    }
  }

  void _onMessageDeletedRemote(
    _MessageDeletedRemote event,
    Emitter<ThreadState> emit,
  ) {
    emit.ifOpen(
      state.copyWith(
        messages: state.messages.where((m) => m.id != event.messageId).toList(),
      ),
    );
  }

  void _onUserTypingRemote(_UserTypingRemote event, Emitter<ThreadState> emit) {
    if (event.userId == myUserId) return;
    // Reciprocal: someone who withholds their own typing indicator does not get
    // to watch everyone else's. Without that the setting is a way to take
    // without giving, which is what makes it unusable in practice - and the
    // server applies the same rule, so this only closes the gap for events
    // already in flight when the switch was flipped.
    if (!privacy.shouldRenderTypingIndicators) return;
    _typingTimers[event.userId]?.cancel();
    _typingTimers[event.userId] = Timer(
      const Duration(seconds: 5),
      () => add(_TypingExpired(event.userId)),
    );
    emit.ifOpen(
      state.copyWith(typingUserIds: {...state.typingUserIds, event.userId}),
    );
  }

  void _onTypingExpired(_TypingExpired event, Emitter<ThreadState> emit) {
    emit.ifOpen(
      state.copyWith(
        typingUserIds: {...state.typingUserIds}..remove(event.userId),
      ),
    );
  }

  /// Moves the read cursor to the newest message the server actually has.
  ///
  /// The head of the list is not always that: an ephemeral bot reply sits in
  /// this list and in no table, so pointing the cursor at its id would name a
  /// row that does not exist - and a read state the next launch cannot resolve
  /// is worse than one that is a message behind.
  Future<void> _markRead() async {
    final newest = state.messages
        .where((m) => !m.isEphemeral && !m.isBotCommandPlaceholder)
        .firstOrNull;
    if (newest == null) return;
    await repository.updateLastRead(newest.id);
  }

  List<MessageDto> _sortNewestFirst(List<MessageDto> messages) {
    final sorted = [...messages];
    sorted.sort(
      (a, b) =>
          (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
    );
    return sorted;
  }

  @override
  Future<void> close() {
    unawaited(_repoSub.cancel());
    unawaited(_ephemeralSub?.cancel());
    for (final timer in _typingTimers.values) {
      timer.cancel();
    }
    for (final timer in _botTimeoutTimers.values) {
      timer.cancel();
    }
    repository.dispose();
    return super.close();
  }
}
