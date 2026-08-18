import 'dart:async';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:re_highlight/languages/all.dart';
import 'package:re_highlight/re_highlight.dart';
import 'package:re_highlight/styles/atom-one-dark.dart';
import 'package:re_highlight/styles/atom-one-light.dart';

import '../../../../core/format/day_heading.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/widgets/adaptive_progress_indicator.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/profile_resolver.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/mls/mls_coverage_service.dart';
import '../../../../core/mls/mls_sync_service.dart';
import '../../../../core/theme/hex_color.dart';
import '../../../billing/data/entitlement_reader.dart';
import '../../../billing/data/models/entitlement_denial.dart';
import '../../../billing/data/models/entitlement_value.dart';
import '../../../billing/data/upload_preflight.dart';
import '../../../billing/presentation/widgets/entitlement_notice.dart';
import '../../../mls/presentation/widgets/channel_access_banner.dart';
import '../../../mls/presentation/widgets/mls_join_request_review.dart';
import '../../../mls/presentation/widgets/encrypted_badge.dart';
import '../../../conversations/data/conversation_repository.dart';
import '../../../guilds/data/guild_repository.dart';
import '../../../guilds/data/models/channel_dto.dart';
import '../../../guilds/data/models/guild_dto.dart';
import '../../../guilds/data/models/guild_features.dart';
import '../../../guilds/data/models/guild_member_dto.dart';
import '../../../guilds/data/models/role_dto.dart';
import '../../../profile/data/profile_repository.dart';
import '../../../wiki/data/wiki_repository.dart';
import '../../../wiki/data/models/wiki_page_summary_dto.dart';
import '../../bloc/message_thread_bloc.dart';
import '../../data/message_repository.dart';
import '../../data/bot_command_api.dart';
import '../../data/gif_api.dart';
import '../../data/message_content_codec.dart';
import '../../data/system_message_text.dart';
import '../../data/models/attachment_dto.dart';
import '../../data/models/bot_command_dto.dart';
import '../../data/models/message_dto.dart';
import 'bot_command_options_dialog.dart';
import 'gif_picker_sheet.dart';
import 'message_attachment_view.dart';
import 'message_embeds_view.dart';
import 'message_link_launcher.dart';
import 'message_search_screen.dart';
import 'pinned_messages_screen.dart';
import 'reaction_bar.dart';
import 'reaction_picker_sheet.dart';
import '../../../support/data/models/report_dto.dart';
import '../../../support/data/models/report_evidence.dart';
import '../../../support/presentation/widgets/report_sheet.dart';

const _imageExtensions = {'png', 'jpg', 'jpeg', 'gif', 'webp', 'heic', 'bmp'};

/// Client-only commands that don't hit a bot - matches desktop's
/// `COMMANDS` in `commands.ts`.
class _LocalCommand {
  const _LocalCommand({required this.name, required this.description});
  final String name;
  final String description;
}

const _localCommands = [
  _LocalCommand(name: 'shrug', description: 'Adds ¯\\_(ツ)_/¯'),
  _LocalCommand(name: 'gif', description: 'Search for a GIF'),
];

/// One row in the `/`-trigger suggestion overlay - either a local command or
/// a bot-registered one, matching desktop's merged `ComposerCommandItem`
/// list.
sealed class _CommandSuggestion {
  const _CommandSuggestion();
  String get name;
}

class _LocalSuggestion extends _CommandSuggestion {
  const _LocalSuggestion(this.command);
  final _LocalCommand command;
  @override
  String get name => command.name;
}

class _BotSuggestion extends _CommandSuggestion {
  const _BotSuggestion(this.command);
  final BotCommandDto command;
  @override
  String get name => command.name;
}

/// One file the user has attached but not yet (or not successfully)
/// uploaded - tracked as local composer state, mirroring desktop's
/// `AttachedFile`. Mutated in place and surfaced via `setState`.
class _PendingAttachment {
  _PendingAttachment({
    required this.bytes,
    required this.fileName,
    required this.isImage,
  });

  final List<int> bytes;
  final String fileName;
  final bool isImage;
  AttachmentDto? uploaded;
  bool uploading = true;
  bool failed = false;

  /// Why this file will not be sent, when the reason is a ceiling rather than a
  /// failure.
  ///
  /// Distinct from [failed], which is "something went wrong, try again". A
  /// refusal is a decision with a plain explanation behind it and retrying
  /// cannot change it, so it gets its own state and its own sentence instead of
  /// the same error icon as a dropped connection.
  String? refusal;

  bool get isRefused => refusal != null;
}

/// The message list + composer, shared by DM conversations and guild
/// channels alike - this is the concrete payoff of parameterizing
/// `MessageThreadBloc`/`MessageRepository` by conversation-or-channel id
/// instead of writing two near-identical screens.
class ThreadView extends StatefulWidget {
  const ThreadView({
    super.key,
    required this.title,
    required this.myUserId,
    this.actions,
    this.guildId,
    this.mentionableUserIds = const [],
    this.banner,
    this.titleAvatar,
    this.onTitleTap,
  });

  final String title;
  final String myUserId;
  final List<Widget>? actions;

  /// Pinned directly under the app bar, above the message list - used by forum
  /// posts to show their applied tags and archived state, which have no home
  /// in the message stream itself.
  final Widget? banner;

  /// Set only for guild channels - gates bot-command discovery/autocomplete,
  /// since bots (and therefore slash commands) only exist inside guilds.
  final String? guildId;

  /// DM conversation participants (other than the caller) offered as
  /// `@mention` autocomplete candidates. Unused for guild channels, which
  /// source candidates from the guild's member list instead (see
  /// `_loadGuildMembers`).
  final List<String> mentionableUserIds;

  /// Drawn ahead of the title instead of the default DM avatar.
  ///
  /// A group has no single face to lead with, so the caller that knows what
  /// kind of conversation this is supplies the picture rather than this widget
  /// guessing from the first mentionable id - which for a group is whoever the
  /// roster happened to list first.
  final Widget? titleAvatar;

  /// Makes the title row a control. Set for a group DM, where the title is the
  /// only place a handset has to hang "change this group" off.
  final VoidCallback? onTitleTap;

  @override
  State<ThreadView> createState() => _ThreadViewState();
}

class _ThreadViewState extends State<ThreadView> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  /// Whether the reader has scrolled far enough back that the newest message
  /// is no longer what they are looking at - which is what raises the
  /// jump-to-present pill.
  ///
  /// A [ValueNotifier] rather than `setState`: this changes on every scroll
  /// frame, and rebuilding the whole thread - composer, suggestion overlays and
  /// a list of decrypted bubbles - to fade one pill in would be the most
  /// expensive thing on the screen.
  final _viewingOlder = ValueNotifier(false);
  final _imagePicker = ImagePicker();
  final List<_PendingAttachment> _pendingAttachments = [];
  List<BotCommandDto> _botCommands = const [];
  String? _commandQuery;
  MessageDto? _replyTarget;
  String? _editingMessageId;
  final _editController = TextEditingController();
  final Map<String, MessageDto> _resolvedReplies = {};
  final Set<String> _resolvingReplyIds = {};
  final Map<String, String> _resolvedMentionNames = {};
  final Set<String> _resolvingMentionIds = {};
  List<GuildMemberDto> _guildMembers = const [];
  String? _mentionQuery;
  int _mentionStart = -1;
  _SuggestionTrigger _mentionTrigger = _SuggestionTrigger.user;

  /// This guild's wiki pages, for the `[[` overlay - fetched lazily, see
  /// [_ensureWikiPages].
  List<WikiPageSummaryDto> _wikiPages = const [];

  /// The guild [_wikiPages] was filled for, so a guild switch cannot serve the
  /// previous one's pages.
  String? _wikiPagesGuildId;

  /// One anchor per rendered message, so a jump has something to
  /// `ensureVisible` on. Keyed by message id and never cleared while the
  /// screen lives - the entries cost a key each and outlive the row being
  /// recycled, which is the whole point of keeping them here.
  final Map<String, GlobalKey> _messageKeys = {};

  /// The message a jump just landed on, tinted for [_highlightDuration] so the
  /// reader can find it among a screenful of others. Alpine flashes the row
  /// for the same reason.
  String? _highlightedMessageId;
  Timer? _highlightTimer;

  /// Guards against a second jump starting while one is still paging - two
  /// interleaved `ThreadLoadMoreRequested` walks would fight over the scroll
  /// position and neither would arrive.
  bool _jumping = false;

  /// The message the "new messages" line is drawn above, or null for no line.
  ///
  /// Snapshotted once per screen (see [_snapshotFirstUnread]) rather than
  /// recomputed: the bloc marks the thread read the moment it opens, so a live
  /// value would erase the divider a heartbeat after drawing it.
  String? _firstUnreadId;
  bool _firstUnreadSnapshotTaken = false;

  static const _highlightDuration = Duration(seconds: 2);

  /// How many older pages a jump will pull in before giving up.
  ///
  /// Bounded on purpose. The alternative to a bound is walking an entire
  /// channel's history to reach a pin from two years ago, on a handset, over
  /// mobile data - fifty pages of messages fetched and decrypted to scroll to
  /// one of them. Ten pages is roughly five hundred messages, which covers
  /// every reply quote and effectively every search hit; past that the jump
  /// says so rather than spinning.
  static const _maxJumpPages = 10;

  /// Whether the caller may pin/unpin messages here - always true for DMs
  /// (any conversation member may pin), gated on the `PinMessages` guild
  /// permission for channels. Starts `false` for guild channels so the Pin
  /// action doesn't flash on then disappear once the permission check lands.
  bool _canPinMessages = false;

  /// Whether the caller may dismiss *anybody's* link previews here. The author
  /// may always dismiss their own, and a DM is the author only - so this stays
  /// false outside guild channels rather than defaulting true the way
  /// [_canPinMessages] does.
  bool _canDeleteAnyMessage = false;

  /// Whether this thread is end-to-end encrypted. Kept in state rather than read
  /// from the repository on every build because it changes underneath us - a
  /// moderator can flip a channel while it is open, and the header badge and the
  /// search action both have to follow.
  bool _isEncrypted = false;
  StreamSubscription<MlsContextChanged>? _mlsSub;

  /// What the *server* says, as opposed to what this device can do about it.
  ///
  /// The two differ for anyone who joined a guild after a channel was encrypted:
  /// the context is encrypted, but this device holds no group keys and so can
  /// neither read nor send. That state needs saying out loud rather than
  /// presenting as an empty channel.
  bool _serverEncrypted = false;

  /// The server's per-device answer, cross-checked against local group state.
  ///
  /// Covers the gap the two flags above leave: they are both about the
  /// *context*, and a state call that failed or a device this account has other
  /// hardware on can leave [_serverEncrypted] false while this handset is
  /// genuinely outside a live group.
  bool _uncoveredHere = false;

  bool get _lockedOutOfEncryption =>
      (_serverEncrypted && !_isEncrypted) || _uncoveredHere;

  @override
  void initState() {
    super.initState();
    _canPinMessages = widget.guildId == null;
    _textController.addListener(_onTextChanged);
    _scrollController.addListener(_onScroll);
    _loadBotCommands();
    _loadGuildMembers();
    _loadChannelPermissions();
    _watchEncryptionState();
  }

  Future<void> _watchEncryptionState() async {
    final repository = context.read<MessageThreadBloc>().repository;
    _isEncrypted = repository.isEncrypted;

    _mlsSub = getIt<MlsSyncService>().contextChanged
        .where((e) => e.contextId == repository.contextId)
        .listen((_) => _syncEncryptedFlag(repository));

    // Reconcile with the server on open. Encryption may have been toggled while
    // this device was away, and acting on a stale view means either sending
    // plaintext into an encrypted room or encrypting to a group that is gone -
    // the server refuses both, so without this the first send just fails.
    try {
      final state = await getIt<MlsSyncService>().refreshState(
        repository.contextId,
        repository.isChannel,
      );
      if (mounted) _serverEncrypted = state.encrypted;
      // A re-key makes every cached coverage verdict wrong rather than stale,
      // and this call already carries the live generation.
      getIt<MlsCoverageService>().noteGeneration(
        repository.contextId,
        state.activeGeneration,
      );
    } catch (e) {
      debugPrint('ThreadView: could not refresh MLS state: $e');
    }
    _syncEncryptedFlag(repository);
    await _refreshCoverage(repository);
  }

  /// Asks which of this account's devices can read the context, once per
  /// context per session - the service caches, and nothing here is on a timer.
  ///
  /// Skipped entirely while nothing suggests the context is encrypted, so a
  /// plaintext DM costs no request.
  Future<void> _refreshCoverage(MessageRepository repository) async {
    if (!_serverEncrypted && !_isEncrypted) return;
    final view = await getIt<MlsCoverageService>().view(
      repository.contextId,
      isChannel: repository.isChannel,
    );
    if (!mounted || view.lockedOutHere == _uncoveredHere) return;
    setState(() => _uncoveredHere = view.lockedOutHere);
  }

  void _syncEncryptedFlag(MessageRepository repository) {
    if (!mounted) return;
    final encrypted = repository.isEncrypted;
    // Holding the group is proof the context is encrypted, so this keeps the
    // two flags consistent when the change arrived over the wire rather than
    // from our own refresh.
    if (encrypted) _serverEncrypted = true;
    // Holding the group settles the per-device question too. Without this the
    // notice would survive the Welcome that answered it, since the server's
    // verdict is only refetched when the thread is next opened.
    if (encrypted && _uncoveredHere) {
      setState(() => _uncoveredHere = false);
    }
    if (_isEncrypted == encrypted) return;
    setState(() => _isEncrypted = encrypted);
  }

  /// Decides, once, where the "new messages" line goes.
  ///
  /// **Once**, because the thread is marked read the instant it opens (see
  /// `MessageThreadBloc._markRead`). A value recomputed on every state would
  /// therefore be erased by the very act of looking at it, and a divider that
  /// vanishes as you read is worse than none: it moves while your eye is on
  /// it. Alpine snapshots for exactly this reason.
  ///
  /// **Conversations only.** The read cursor this reads is
  /// `ConversationMemberDto.lastReadMessageId`, which the server sends on the
  /// conversation itself. There is no equivalent for a guild channel anywhere
  /// in this client: `GET /guilds/{id}/me` carries a `readState` array whose
  /// counts were zeroed permanently by the inbox release (see
  /// `GuildSelfPermissions`), and the inbox endpoints answer with per-channel
  /// *counts* rather than a boundary id. A divider placed N rows from the top
  /// off a count would be wrong the moment the count and the loaded page
  /// disagreed, which is most of the time - so a channel gets no divider
  /// rather than one that lies.
  void _snapshotFirstUnread(ThreadState state) {
    if (_firstUnreadSnapshotTaken || state.messages.isEmpty) return;
    _firstUnreadSnapshotTaken = true;

    final conversationId = context
        .read<MessageThreadBloc>()
        .repository
        .conversationId;
    if (conversationId == null) return;

    final conversation = getIt<ConversationRepository>().cached
        .where((c) => c.id == conversationId)
        .firstOrNull;
    final lastReadId = conversation?.members
        .where((m) => m.userId == widget.myUserId)
        .firstOrNull
        ?.lastReadMessageId;
    if (lastReadId == null) return;

    // Optimistic rows have no place in this index maths: they are not what the
    // read cursor was measured against, and one of them sitting between the
    // cursor and the first real unread message would move the line by a row.
    final confirmed = [
      for (final m in state.messages)
        if (!m.isPending && !m.isFailed && !m.isEphemeral) m,
    ];
    // Newest-first, so the message *after* the last-read one chronologically
    // is the one *before* it here. Index 0 means the last thing read is also
    // the newest thing there is - nothing unread, no line.
    final readIndex = confirmed.indexWhere((m) => m.id == lastReadId);
    if (readIndex <= 0) return;
    _firstUnreadId = confirmed[readIndex - 1].id;
  }

  /// Scrolls the timeline to [messageId] and flashes it on arrival.
  ///
  /// Reached from all three of the places Alpine wires a jump from - the reply
  /// quote, a search result and the pinned panel - and it has to handle the
  /// case all three make likely: the target is not loaded. A pin or a search
  /// hit can be arbitrarily far back, and Alpine simply does nothing at all
  /// there, which is a dead tap with no explanation. This pages older history
  /// in until the message turns up, [_maxJumpPages] at most, and says so
  /// plainly if it never does.
  Future<void> _jumpToMessage(String messageId) async {
    if (_jumping) return;
    _jumping = true;
    try {
      final bloc = context.read<MessageThreadBloc>();
      var pagesLoaded = 0;
      while (!bloc.state.messages.any((m) => m.id == messageId)) {
        if (!bloc.state.hasMoreOlder || pagesLoaded >= _maxJumpPages) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('That message is too far back to open from here.'),
            ),
          );
          return;
        }
        pagesLoaded++;
        bloc.add(const ThreadLoadMoreRequested());
        // The bloc flips `isLoadingMore` on and back off around the fetch, so
        // the trailing edge is the page landing. The timeout is the failure
        // case the flag cannot express: the request errored and the bloc went
        // quiet, and without it this loop would wait forever.
        await bloc.stream
            .firstWhere((s) => !s.isLoadingMore)
            .timeout(const Duration(seconds: 15), onTimeout: () => bloc.state);
        if (!mounted) return;
      }

      await _scrollToMessage(messageId, bloc);
      if (!mounted) return;
      _highlightTimer?.cancel();
      setState(() => _highlightedMessageId = messageId);
      _highlightTimer = Timer(_highlightDuration, () {
        if (mounted) setState(() => _highlightedMessageId = null);
      });
    } finally {
      _jumping = false;
    }
  }

  /// Walks the scroll position to wherever [messageId] is rendered.
  ///
  /// Two steps, because neither alone works on a lazily built list. Only rows
  /// near the viewport exist as widgets at all, so `ensureVisible` has nothing
  /// to aim at until the target is close - and the offset it would need cannot
  /// be computed exactly, because the extents of the rows in between have
  /// never been measured. So this estimates proportionally, lets a frame
  /// build, and re-checks; the estimate improves each time as more real
  /// extents replace the list's averages, and the last hop is handed to
  /// `ensureVisible` to land precisely.
  Future<void> _scrollToMessage(
    String messageId,
    MessageThreadBloc bloc,
  ) async {
    for (var attempt = 0; attempt < 12; attempt++) {
      final anchorContext = _messageKeys[messageId]?.currentContext;
      // `mounted` on the anchor rather than on this State: the key survives
      // its row being recycled out of the viewport, so a stale context is a
      // real possibility here and not a formality.
      if (anchorContext != null && anchorContext.mounted) {
        await Scrollable.ensureVisible(
          anchorContext,
          alignment: 0.5,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
        return;
      }
      if (!_scrollController.hasClients) return;
      final index = bloc.state.messages.indexWhere((m) => m.id == messageId);
      if (index < 0) return;

      final position = _scrollController.position;
      // `reverse: true` means offset grows *backwards* in time, so a higher
      // index - an older message - is a larger offset. The + 0.5 aims at the
      // middle of the row rather than its leading edge.
      final target =
          (position.maxScrollExtent *
                  (index + 0.5) /
                  bloc.state.messages.length)
              .clamp(position.minScrollExtent, position.maxScrollExtent);
      if ((target - position.pixels).abs() < 1) return;
      await _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
    }
  }

  /// How far back the reader has to be before the pill appears.
  ///
  /// Deliberately much further than the distance at which a list still counts
  /// as "at the bottom". A pill that springs up because a fat thumb nudged the
  /// list forty pixels is noise, and it would appear over the very message the
  /// reader was looking at.
  static const _viewingOlderThreshold = 400.0;

  /// Above this, the jump hard-cuts to [_smoothJumpDistance] first, so the
  /// animated part is the same length whether the reader is a screen back or
  /// two thousand messages back. Animating the whole way from deep history is
  /// a smear of unreadable rows and a lot of pointless layout.
  static const _smoothJumpDistance = 600.0;

  /// `reverse: true` puts the newest message at offset zero, so distance from
  /// the present *is* [ScrollPosition.pixels] - no arithmetic against
  /// `maxScrollExtent`, which grows as older pages load and would make the
  /// threshold mean something different on every page.
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    _viewingOlder.value =
        _scrollController.position.pixels > _viewingOlderThreshold;
  }

  Future<void> _jumpToPresent() async {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels > _smoothJumpDistance) {
      _scrollController.jumpTo(_smoothJumpDistance);
    }
    await _scrollController.animateTo(
      position.minScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    _mlsSub?.cancel();
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _editController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _viewingOlder.dispose();
    super.dispose();
  }

  void _startReply(MessageDto message) {
    setState(() {
      _replyTarget = message;
      _editingMessageId = null;
    });
  }

  void _cancelReply() => setState(() => _replyTarget = null);

  void _startEdit(MessageDto message) {
    setState(() {
      _editingMessageId = message.id;
      _editController.text = MessageContentCodec.decode(message.content);
      _replyTarget = null;
    });
  }

  void _cancelEdit() => setState(() => _editingMessageId = null);

  void _saveEdit(String messageId) {
    final text = _editController.text.trim();
    setState(() => _editingMessageId = null);
    if (text.isEmpty) return;
    context.read<MessageThreadBloc>().add(
      MessageEditRequested(messageId: messageId, newText: text),
    );
  }

  Future<void> _confirmDelete(MessageDto message) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text(
          'This cannot be undone. Are you sure you want to delete this message?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    context.read<MessageThreadBloc>().add(MessageDeleteRequested(message.id));
  }

  /// Long-press action sheet - Reply / Pin / Edit / Delete, mirroring the
  /// message actions already established for other pickers in this composer
  /// (bottom sheet with a leading icon per row).
  Future<void> _showMessageActions(MessageDto message) async {
    // Nothing on this sheet has anything to act on for an ephemeral reply:
    // reply, edit, delete, pin, publish, preview suppression and report all
    // name a message id the server never stored, so every one of them 404s.
    // The long-press is already withheld in `_MessageBubble`; this is the
    // second lock, because the sheet is what would do the damage and a future
    // caller should not be able to reach it by accident.
    if (message.isEphemeral) return;
    final isMine = message.authorId == widget.myUserId;
    // Dismissing a preview changes the message for everyone who can see it,
    // so it is gated exactly the way the server gates it - the author, or
    // `DeleteAnyMessage` in this channel. Offering it any wider renders a
    // button that 403s.
    //
    // Only offered where there is something to act on: a card to dismiss, or a
    // dismissal to undo. "Restore preview" on a message that never had one
    // would promise a card that is never coming.
    final canSuppressEmbeds =
        (isMine || _canDeleteAnyMessage) &&
        (message.embeds.isNotEmpty || message.hasSuppressedEmbeds);
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () => Navigator.pop(context, 'reply'),
            ),
            if (_canPinMessages)
              ListTile(
                leading: Icon(
                  message.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                ),
                title: Text(message.isPinned ? 'Unpin' : 'Pin'),
                onTap: () => Navigator.pop(context, 'pin'),
              ),
            if (_isAnnouncementChannel && _canPinMessages)
              ListTile(
                leading: const Icon(Icons.campaign_outlined),
                title: const Text('Publish'),
                onTap: () => Navigator.pop(context, 'publish'),
              ),
            if (canSuppressEmbeds)
              ListTile(
                leading: Icon(
                  message.hasSuppressedEmbeds
                      ? Icons.link_rounded
                      : Icons.link_off_rounded,
                ),
                title: Text(
                  message.hasSuppressedEmbeds
                      ? 'Restore link preview'
                      : 'Remove link preview',
                ),
                subtitle: const Text('Applies for everyone'),
                onTap: () => Navigator.pop(context, 'embeds'),
              ),
            if (isMine) ...[
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit'),
                onTap: () => Navigator.pop(context, 'edit'),
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  'Delete',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () => Navigator.pop(context, 'delete'),
              ),
            ],
            // Last, and never on your own message - the server refuses a
            // self-report, and offering it is the client promising something it
            // knows will bounce.
            if (!isMine)
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: const Text('Report message'),
                onTap: () => Navigator.pop(context, 'report'),
              ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case 'reply':
        _startReply(message);
      case 'pin':
        context.read<MessageThreadBloc>().add(MessagePinToggled(message.id));
      case 'publish':
        await _publishMessage(message);
      case 'embeds':
        context.read<MessageThreadBloc>().add(
          MessageEmbedsSuppressionToggled(message.id),
        );
      case 'edit':
        _startEdit(message);
      case 'delete':
        await _confirmDelete(message);
      case 'report':
        await _reportMessage(message);
    }
  }

  /// Files a report on [message], with a snapshot of the conversation around it.
  ///
  /// The snapshot is built from what this screen already has rather than from a
  /// fresh fetch, deliberately: it is meant to be what the *reporter saw*, and
  /// re-reading the thread would attach a version of it edited or deleted since.
  Future<void> _reportMessage(MessageDto message) async {
    final repository = context.read<MessageThreadBloc>().repository;
    // The bloc holds newest-first; the snapshot reads as a conversation.
    final chronological = [
      for (final m in context.read<MessageThreadBloc>().state.messages.reversed)
        // Client-only synthetics were never on anybody's screen as messages.
        //
        // An ephemeral bot reply belongs in the same bucket and is the one that
        // actually matters: it is a real, readable row on *this* screen, so
        // without this line it would go to a moderator as evidence naming an id
        // the server has no record of - a message they cannot look up, in a
        // window that claims to be what the reporter saw. Alpine drops the same
        // three flags before it builds its window.
        if (!m.isEphemeral && !m.isBotCommandPlaceholder && !m.isPending)
          EvidenceMessage(
            id: m.id,
            authorId: m.authorId,
            // Never ciphertext. A message this device holds no keys for is
            // unreadable to the moderator too, and sending the base64 would
            // look like content.
            content: m.isUndecryptable
                ? null
                : MessageContentCodec.decode(m.content),
            sentAt: m.createdAt,
            reported: m.id == message.id,
            attachments: [for (final a in m.attachments) _attachmentSummary(a)],
          ),
    ];

    final evidenceMessages = ReportEvidence.window(chronological, message.id);
    final evidence = ReportEvidence.build(
      // The wire key is `conversationId` for a channel too - a channel report
      // carries the message id as its subject, which is what the server
      // resolves the context from.
      conversationId: repository.contextId,
      // Read from the context's actual state, never assumed. `_serverEncrypted`
      // is what the server says rather than what this device can decrypt, and
      // it is the flag that tells a moderator whether the stored message could
      // corroborate any of this.
      encrypted: _serverEncrypted,
      capturedAt: DateTime.now().toUtc(),
      messages: evidenceMessages,
    );

    if (!mounted) return;
    await showReportSheet(
      context,
      ReportTarget(
        targetUserId: message.authorId,
        subjectKind: ReportSubjectKind.message,
        subjectId: message.id,
        title: 'Report message',
        displayName: getIt<ProfileRepository>()
            .cachedByUserId(message.authorId)
            ?.userName,
        evidence: evidence,
        evidenceMessages: evidenceMessages,
      ),
    );
  }

  /// An attachment reduced to a line a moderator can read - never the bytes.
  static String _attachmentSummary(AttachmentDto attachment) {
    final size = attachment.sizeBytes;
    // `sizeBytes` is absent on the shape embedded in a message (see
    // `AttachmentDto`), so the type alone is the honest answer there rather
    // than a fabricated "0 B".
    if (size == null || size <= 0) return attachment.contentType;
    final mb = size / (1024 * 1024);
    final label = mb >= 1
        ? '${mb.toStringAsFixed(1)} MB'
        : '${(size / 1024).toStringAsFixed(1)} KB';
    return '${attachment.contentType}, $label';
  }

  Future<void> _loadChannelPermissions() async {
    final guildId = widget.guildId;
    if (guildId == null) return;
    try {
      final repository = getIt<GuildRepository>();
      final self = await repository.getOwnMember(guildId);
      final ownerId = repository.cachedById(guildId)?.ownerId;
      final effective = ownerId != null
          ? self.effectivePermissions(ownerId)
          : self.permissions;
      if (mounted) {
        setState(() {
          _canPinMessages = effective.has('PinMessages');
          _canDeleteAnyMessage = effective.has('DeleteAnyMessage');
        });
      }
    } catch (_) {
      // Leave it hidden - still enforced server-side on every pin attempt.
    }
  }

  /// Opens the pinned panel and, if the user picks a row, jumps the timeline
  /// to it.
  ///
  /// The screen is pushed rather than shown as a side panel the way Alpine
  /// does it, so "tap a result" has to mean "pop back and scroll" - the result
  /// travels back as the route's pop value, which keeps the panel ignorant of
  /// the thread it came from.
  Future<void> _openPinnedMessages() async {
    final repository = context.read<MessageThreadBloc>().repository;
    final messageId = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => PinnedMessagesScreen(repository: repository),
      ),
    );
    if (messageId == null || !mounted) return;
    await _jumpToMessage(messageId);
  }

  /// Cache-then-fetch lookup for a reply reference, same idea as
  /// `ProfileResolver` - checks the already-loaded page first, then the
  /// local resolve cache, then fetches once (guarded against duplicate
  /// in-flight fetches) and rebuilds when it lands.
  MessageDto? _resolveReply(String id) {
    final bloc = context.read<MessageThreadBloc>();
    final loaded = bloc.state.messages.where((m) => m.id == id).firstOrNull;
    if (loaded != null) return loaded;
    final cached = _resolvedReplies[id];
    if (cached != null) return cached;
    if (_resolvingReplyIds.add(id)) {
      bloc.repository
          .getMessageById(id)
          .then((msg) {
            if (mounted) setState(() => _resolvedReplies[id] = msg);
          })
          .catchError((_) {});
    }
    return null;
  }

  /// Cache-then-fetch a mentioned user's display name, same idiom as
  /// [_resolveReply] and `ProfileResolver` - used to tell a real `@mention`
  /// (someone actually tagged in `message.mentions`) apart from someone
  /// merely typing an `@`-prefixed word.
  String? _resolveMentionName(String userId) {
    final repository = getIt<ProfileRepository>();
    final cached = repository.cachedByUserId(userId);
    if (cached != null) return cached.userName;
    final resolved = _resolvedMentionNames[userId];
    if (resolved != null) return resolved;
    if (_resolvingMentionIds.add(userId)) {
      repository
          .getByUserId(userId)
          .then((profile) {
            if (mounted) {
              setState(() => _resolvedMentionNames[userId] = profile.userName);
            }
          })
          .catchError((_) {});
    }
    return null;
  }

  Future<void> _loadBotCommands() async {
    final guildId = widget.guildId;
    if (guildId == null) return;
    try {
      final commands = await getIt<BotCommandApi>().getCommands(guildId);
      if (mounted) setState(() => _botCommands = commands);
    } catch (_) {
      // Autocomplete just won't offer bot commands - not worth surfacing.
    }
  }

  Future<void> _loadGuildMembers() async {
    final guildId = widget.guildId;
    if (guildId == null) return;
    try {
      final members = await getIt<GuildRepository>().getMembers(guildId);
      if (mounted) setState(() => _guildMembers = members);
    } catch (_) {
      // Autocomplete just won't offer @mention candidates - not worth
      // surfacing, same tolerance as the bot-command load above.
    }
  }

  /// Display name → user id for everyone `@mention` autocomplete (and the
  /// final send-time mention scan) should consider - guild members for a
  /// channel, the other DM participant(s) otherwise.
  Map<String, String> get _mentionCandidateNames {
    final names = <String, String>{};
    if (widget.guildId != null) {
      for (final member in _guildMembers) {
        final name =
            member.profile?.userName ??
            getIt<ProfileRepository>().cachedByUserId(member.userId)?.userName;
        if (name != null) names[name] = member.userId;
      }
    } else {
      for (final userId in widget.mentionableUserIds) {
        final name = _resolveMentionName(userId);
        if (name != null) names[name] = userId;
      }
    }
    return names;
  }

  /// Role name → role id, for `@role` autocomplete/rendering - guild
  /// channels only, excludes the implicit `@everyone` role (that's handled
  /// as its own literal broadcast token, not a "mention this role").
  Map<String, String> get _roleCandidateNames {
    final guildId = widget.guildId;
    if (guildId == null) return const {};
    final roles = getIt<GuildRepository>().cachedById(guildId)?.roles ?? [];
    return {
      for (final role in roles)
        if (role.type != RoleType.everyone) role.name: role.id,
    };
  }

  List<ChannelDto> get _guildChannels {
    final guildId = widget.guildId;
    if (guildId == null) return const [];
    return getIt<GuildRepository>().cachedById(guildId)?.channels ?? const [];
  }

  ChannelDto? get _currentChannel {
    final channelId = context.read<MessageThreadBloc>().repository.channelId;
    if (channelId == null) return null;
    return _guildChannels.where((c) => c.id == channelId).firstOrNull;
  }

  bool get _isAnnouncementChannel =>
      _currentChannel?.type == ChannelType.announcement;

  /// A forum post a moderator has locked: still readable, but closed to new
  /// messages. Distinct from archived, which stays writable (posting is what
  /// revives it), so only this one kills the composer.
  bool get _isLockedPost => _currentChannel?.isLocked ?? false;

  Future<void> _publishMessage(MessageDto message) async {
    try {
      final published = await context
          .read<MessageThreadBloc>()
          .repository
          .publishMessage(message.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              published == 0
                  ? 'Published - nobody follows this channel yet.'
                  : 'Published to $published channel${published == 1 ? '' : 's'}.',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not publish that message.')),
        );
      }
    }
  }

  Future<void> _followChannel() async {
    final sourceChannelId = _currentChannel?.id;
    if (sourceChannelId == null) return;
    final target = await showModalBottomSheet<ChannelDto>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => const _FollowChannelSheet(),
    );
    if (target == null || !mounted) return;
    try {
      await getIt<GuildRepository>().followChannel(
        sourceChannelId: sourceChannelId,
        targetChannelId: target.id,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('#${target.name} will now receive posts.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not follow - you may not manage that channel\'s server.',
            ),
          ),
        );
      }
    }
  }

  /// Channel name → channel id for `#channel` autocomplete - text channels
  /// win a same-named tie with a voice channel, matching the render-side
  /// tie-break in `_MessageBody` (and Alpine's own `#general` resolution).
  Map<String, String> get _channelCandidateNames {
    final names = <String, String>{};
    for (final channel in _guildChannels) {
      names.putIfAbsent(channel.name, () => channel.id);
      if (channel.type == ChannelType.text) names[channel.name] = channel.id;
    }
    return names;
  }

  /// Which overlay the text before the cursor is asking for, if any - the
  /// mobile counterpart of desktop's `detectTrigger`/`overlayType`.
  ///
  /// Every branch is anchored at the cursor, which is what makes them mutually
  /// exclusive without needing a precedence rule between the single-character
  /// ones: a run that reaches the caret can only have started with one sigil.
  /// The order below is desktop's, and `[[` is tested first for the reason
  /// recorded there - a page title may contain any of the other triggers, so
  /// `[[a:b` is a page query and not an emoji shortcode, and a two-character
  /// opener cannot be reached by accident the way a bare colon can.
  ({_SuggestionTrigger trigger, String query, int start})? _detectTrigger(
    String text,
    int cursor,
  ) {
    if (cursor <= 0 || cursor > text.length) return null;
    final before = text.substring(0, cursor);

    final wiki = RegExp(r'\[\[([^\[\]\n]{0,64})$').firstMatch(before);
    if (wiki != null) {
      return (
        trigger: _SuggestionTrigger.wiki,
        query: wiki.group(1)!,
        start: before.lastIndexOf('[['),
      );
    }

    // `@` and `#` keep the whitespace-or-start rule they already had, so an
    // email address and a C `#include` still do not open a menu.
    for (final (sigil, trigger) in const [
      ('@', _SuggestionTrigger.user),
      ('#', _SuggestionTrigger.channel),
    ]) {
      final index = before.lastIndexOf(sigil);
      if (index == -1) continue;
      final after = before.substring(index + 1);
      final precededOk =
          index == 0 || RegExp(r'\s').hasMatch(before[index - 1]);
      if (precededOk && RegExp(r'^\w*$').hasMatch(after)) {
        return (trigger: trigger, query: after, start: index);
      }
    }

    // At least one character after the colon and at most 32, matching desktop.
    // A bare `:` opening the menu would put an overlay over the composer every
    // time somebody typed a sentence with a colon in it.
    final emoji = RegExp(r'(?:^|[^\w]):([\w-]{1,32})$').firstMatch(before);
    if (emoji != null) {
      return (
        trigger: _SuggestionTrigger.emoji,
        query: emoji.group(1)!,
        start: before.lastIndexOf(':'),
      );
    }

    return null;
  }

  void _onTextChanged() {
    final text = _textController.text;
    // Deliberately still the whole-text form rather than desktop's
    // whitespace-anchored one: selecting a command here *replaces* the
    // composer (it fires a bot invocation or opens the GIF sheet) rather than
    // inserting a chip, so offering it mid-sentence would throw away what was
    // already typed.
    final commandMatch = RegExp(r'^/(\w*)$').firstMatch(text);
    final commandQuery = commandMatch?.group(1);

    final detected = _detectTrigger(text, _textController.selection.baseOffset);
    final mentionQuery = detected?.query;
    final mentionStart = detected?.start ?? -1;
    final mentionTrigger = detected?.trigger ?? _SuggestionTrigger.user;

    // The wiki page list is fetched here rather than on open, and only once a
    // `[[` has actually been typed - see [_ensureWikiPages].
    if (mentionTrigger == _SuggestionTrigger.wiki) _ensureWikiPages();

    if (commandQuery != _commandQuery ||
        mentionQuery != _mentionQuery ||
        mentionStart != _mentionStart ||
        mentionTrigger != _mentionTrigger) {
      setState(() {
        _commandQuery = commandQuery;
        _mentionQuery = mentionQuery;
        _mentionStart = mentionStart;
        _mentionTrigger = mentionTrigger;
      });
    }
  }

  /// Loads this guild's page listing, once, the first time somebody types `[[`
  /// in it - mirroring desktop's `ensureWikiPages`.
  ///
  /// Not done when the thread opens: most messages contain no wiki link, and
  /// fetching a page tree for every channel anybody taps through would be a
  /// request per switch for a menu that never opens.
  ///
  /// [_wikiPagesGuildId] is the watermark that makes a guild switch safe. It
  /// is set *before* the request goes out and re-checked when it lands, so a
  /// second switch while one is in flight cannot file one guild's pages under
  /// another guild's name - which would offer a page the reader has no access
  /// to and produce a link that 404s for everyone in the room.
  Future<void> _ensureWikiPages() async {
    final guildId = widget.guildId;
    if (guildId == null || _wikiPagesGuildId == guildId) return;
    _wikiPagesGuildId = guildId;
    _wikiPages = const [];

    // A guild with the module off keeps the watermark and returns, so the menu
    // simply never appears and nothing retries on every keystroke.
    final guild = getIt<GuildRepository>().cachedById(guildId);
    if (guild == null || !guild.hasFeature(GuildFeature.wiki)) return;

    try {
      final wiki = await getIt<WikiRepository>().getWiki(guildId);
      if (!mounted || _wikiPagesGuildId != guildId) return;
      setState(() => _wikiPages = wiki.pages);
    } catch (_) {
      // Same tolerance as the bot-command and member loads: autocomplete just
      // won't offer pages.
    }
  }

  List<_CommandSuggestion> get _suggestions {
    final query = _commandQuery;
    if (query == null) return const [];
    return [
      for (final c in _localCommands)
        if (c.name.startsWith(query)) _LocalSuggestion(c),
      for (final c in _botCommands)
        if (c.name.startsWith(query)) _BotSuggestion(c),
    ];
  }

  List<_MentionSuggestionEntry> get _mentionSuggestions {
    final query = _mentionQuery;
    if (query == null) return const [];
    final lower = query.toLowerCase();
    switch (_mentionTrigger) {
      case _SuggestionTrigger.channel:
        final channelEntries = [
          for (final entry in _channelCandidateNames.entries)
            if (entry.key.toLowerCase().startsWith(lower))
              _ChannelMentionEntry(name: entry.key, channelId: entry.value),
        ]..sort((a, b) => a.name.compareTo(b.name));
        return channelEntries.take(8).toList();

      case _SuggestionTrigger.emoji:
        // Substring rather than prefix, matching desktop - `:joy` has to reach
        // "face with tears of joy", which no prefix match ever would.
        return [
          for (final entry in emojiShortcodeIndex)
            if (entry.shortcode.contains(lower))
              _EmojiSuggestionEntry(
                name: entry.shortcode,
                emoji: entry.emoji,
                description: entry.name,
              ),
        ].take(12).toList();

      case _SuggestionTrigger.wiki:
        // Title *or* tag, and pinned pages first so a bare `[[` offers the
        // pages the guild has decided matter rather than whatever order the
        // listing happened to return.
        final matches =
            [
              for (final page in _wikiPages)
                if (lower.isEmpty ||
                    page.title.toLowerCase().contains(lower) ||
                    page.tags.any((t) => t.toLowerCase().contains(lower)))
                  page,
            ]..sort((a, b) {
              if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
              return a.title.compareTo(b.title);
            });
        return [
          for (final page in matches.take(8))
            _WikiPageSuggestionEntry(name: page.title, page: page),
        ];

      case _SuggestionTrigger.user:
        final entries = [
          for (final entry in _mentionCandidateNames.entries)
            if (entry.key.toLowerCase().startsWith(lower))
              _UserMentionEntry(name: entry.key, userId: entry.value),
          for (final entry in _roleCandidateNames.entries)
            if (entry.key.toLowerCase().startsWith(lower))
              _RoleMentionEntry(name: entry.key, roleId: entry.value),
        ]..sort((a, b) => a.name.compareTo(b.name));
        return entries.take(8).toList();
    }
  }

  /// Replaces the trigger run with whatever the tapped row stands for.
  ///
  /// The four cases differ in what actually lands in the text, which is the
  /// whole point of keeping this in one place: a mention and a channel insert
  /// the sigil back (they are re-scanned at send time by [_extractMentions]),
  /// an emoji inserts the glyph and drops the colon entirely, and a wiki page
  /// inserts a bare URL.
  void _selectMention(_MentionSuggestionEntry entry) {
    final text = _textController.text;
    final end =
        _mentionStart +
        _mentionTrigger.sigil.length +
        (_mentionQuery?.length ?? 0);
    final replacement = switch (entry) {
      _EmojiSuggestionEntry(emoji: final emoji) => '$emoji ',
      // Bare, never bracketed. The server recognises this shape in-process and
      // answers with a `venta.wiki_page` embed, so wrapping it in the
      // no-preview brackets would suppress the very card it exists to get.
      _WikiPageSuggestionEntry(page: final page) =>
        '${wikiShareLink(page.guildId, page.id)} ',
      _ => '${_mentionTrigger.sigil}${entry.name} ',
    };
    _textController.text = text.replaceRange(_mentionStart, end, replacement);
    _textController.selection = TextSelection.collapsed(
      offset: _mentionStart + replacement.length,
    );
    setState(() {
      _mentionQuery = null;
      _mentionStart = -1;
    });
  }

  /// Re-scans the final submitted text for `@name`/`@everyone`/`@here`
  /// runs matching a known candidate, rather than trusting autocomplete-
  /// insertion bookkeeping - robust to the user editing/removing an
  /// inserted mention afterwards. `@everyone`/`@here` are flagged whenever
  /// they literally appear (no rich "chip" editor here to gate on an
  /// explicit selection like desktop's composer does) - the server is
  /// still the source of truth on whether the sender may actually notify.
  _ExtractedMentions _extractMentions(String text) {
    final userNames = _mentionCandidateNames;
    final roleNames = _roleCandidateNames;
    final userIds = <String>{};
    if (userNames.isNotEmpty) {
      final sorted = userNames.keys.toList()
        ..sort((a, b) => b.length - a.length);
      final pattern = RegExp('@(?:${sorted.map(RegExp.escape).join('|')})\\b');
      for (final match in pattern.allMatches(text)) {
        final id = userNames[match[0]!.substring(1)];
        if (id != null) userIds.add(id);
      }
    }
    final roleIds = <String>{};
    if (roleNames.isNotEmpty) {
      final sorted = roleNames.keys.toList()
        ..sort((a, b) => b.length - a.length);
      final pattern = RegExp('@(?:${sorted.map(RegExp.escape).join('|')})\\b');
      for (final match in pattern.allMatches(text)) {
        final id = roleNames[match[0]!.substring(1)];
        if (id != null) roleIds.add(id);
      }
    }
    return _ExtractedMentions(
      userIds: userIds.toList(),
      roleIds: roleIds.toList(),
      everyone: RegExp(r'@everyone\b').hasMatch(text),
      here: RegExp(r'@here\b').hasMatch(text),
    );
  }

  void _selectSuggestion(_CommandSuggestion suggestion) {
    switch (suggestion) {
      case _LocalSuggestion(command: final command):
        if (command.name == 'shrug') {
          _textController.text = '¯\\_(ツ)_/¯';
          _textController.selection = TextSelection.collapsed(
            offset: _textController.text.length,
          );
        } else {
          _textController.clear();
          unawaited(_pickGif());
        }
      case _BotSuggestion(command: final command):
        _textController.clear();
        unawaited(_invokeBotCommand(command));
    }
  }

  Future<void> _invokeBotCommand(BotCommandDto command) async {
    var options = const <InvokeCommandOption>[];
    if (command.options.isNotEmpty) {
      final chosen = await showBotCommandOptionsDialog(context, command);
      if (chosen == null) return;
      options = chosen;
    }
    if (!mounted) return;
    final bloc = context.read<MessageThreadBloc>();
    final guildId = widget.guildId;
    final channelId = bloc.repository.channelId;
    if (guildId == null || channelId == null) return;

    final tempId = 'bot-pending-${DateTime.now().microsecondsSinceEpoch}';
    bloc.add(
      ThreadBotPlaceholderAdded(tempId: tempId, botUserId: command.botUserId),
    );
    try {
      await getIt<BotCommandApi>().invoke(
        guildId: guildId,
        channelId: channelId,
        botUserId: command.botUserId,
        commandName: command.name,
        options: options,
      );
    } catch (_) {
      bloc.add(ThreadBotPlaceholderFailed(tempId));
    }
  }

  void _submit() {
    final text = _textController.text;
    if (_pendingAttachments.any((p) => p.uploading)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Still uploading - hang on a moment.')),
      );
      return;
    }
    // A refused file has no `uploaded` and is simply not among them. The
    // message still sends with everything that did upload - refusing the batch
    // because one file was too large is the rollback the contract exists to
    // stop, and it punishes four files for the fifth.
    final attachments = [
      for (final pending in _pendingAttachments)
        if (pending.uploaded != null) pending.uploaded!,
    ];
    if (text.trim().isEmpty && attachments.isEmpty) return;
    final extracted = _extractMentions(text);
    context.read<MessageThreadBloc>().add(
      ThreadMessageSubmitted(
        text,
        attachments: attachments,
        replyToId: _replyTarget?.id,
        mentionedUserIds: extracted.userIds,
        mentionedRoleIds: extracted.roleIds,
        mentionsEveryone: extracted.everyone,
        mentionsHere: extracted.here,
      ),
    );
    _textController.clear();
    setState(() {
      _pendingAttachments.clear();
      _replyTarget = null;
    });
  }

  /// Adds one file to the strip and starts it, unless it will not fit.
  ///
  /// The size check happens here rather than inside [_upload] so an oversized
  /// file never becomes a transfer at all. On a handset that matters more than
  /// on a desktop: the round trip it saves is minutes of somebody's mobile data
  /// spent to be told no at the end of it.
  ///
  /// **Per file, never per batch.** An oversized file is refused on its own and
  /// leaves the rest of the strip uploading, because the alternative - rolling
  /// the batch back - punishes four files for the fifth.
  Future<void> _addPendingAttachment({
    required List<int> bytes,
    required String fileName,
    required bool isImage,
  }) async {
    final pending = _PendingAttachment(
      bytes: bytes,
      fileName: fileName,
      isImage: isImage,
    );
    setState(() => _pendingAttachments.add(pending));

    final oversized = checkUploadSize(
      fileName: fileName,
      sizeBytes: bytes.length,
      ceiling: await getIt<EntitlementReader>().uploadCeiling(
        guildId: widget.guildId,
      ),
    );
    if (!mounted) return;
    if (oversized != null) {
      setState(() {
        pending.uploading = false;
        pending.refusal = oversized.sentence;
      });
      return;
    }

    await _upload(pending);
  }

  Future<void> _upload(_PendingAttachment pending) async {
    try {
      final attachment = await context
          .read<MessageThreadBloc>()
          .repository
          .uploadAttachment(bytes: pending.bytes, fileName: pending.fileName);
      if (!mounted) return;
      setState(() {
        pending.uploaded = attachment;
        pending.uploading = false;
      });
    } catch (e) {
      if (!mounted) return;
      // The ceiling can move between the check above and the transfer, and the
      // check can have been skipped entirely because the lookup failed. The
      // server's own refusal is the enforcement, and it carries the same
      // explanation - so it renders as a refusal rather than as the generic
      // "that didn't upload", which would send somebody into a retry loop
      // against a decision.
      final denial = entitlementDenialOf(e);
      setState(() {
        pending.uploading = false;
        if (denial == null) {
          pending.failed = true;
        } else {
          pending.refusal = _refusalSentence(pending, denial);
        }
      });
    }
  }

  /// The server's refusal, in the same two-facts-and-no-advice shape the
  /// pre-flight uses, plus the one thing the pre-flight cannot know: which side
  /// applied the limit.
  ///
  /// The attribution is only ever the server's own. A pre-flight check reads
  /// two paired ceilings and takes the lower without being told which won, so
  /// it says nothing about whose limit it was - guessing there is how a member
  /// paying for their own plan gets told their server limited them.
  static String _refusalSentence(
    _PendingAttachment pending,
    EntitlementDenial denial,
  ) {
    final ceiling = denial.ceiling;
    final size = formatByteCeiling(pending.bytes.length);
    return ceiling == null
        ? '${pending.fileName} is $size. ${denial.sentence}'
        : '${pending.fileName} is $size, and files here are capped at '
              '$ceiling. ${denial.sentence}';
  }

  void _removePendingAttachment(_PendingAttachment pending) {
    setState(() => _pendingAttachments.remove(pending));
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await _imagePicker.pickImage(source: source, imageQuality: 85);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    await _addPendingAttachment(
      bytes: bytes,
      fileName: file.name,
      isImage: true,
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(withData: true);
    final file = result?.files.firstOrNull;
    if (file == null || file.bytes == null) return;
    final ext = file.extension?.toLowerCase();
    await _addPendingAttachment(
      bytes: file.bytes!,
      fileName: file.name,
      isImage: ext != null && _imageExtensions.contains(ext),
    );
  }

  Future<void> _openSearch() async {
    final repository = context.read<MessageThreadBloc>().repository;
    // Guild channels can be encrypted too now, so this reads the live MLS state
    // rather than the conversation DTO - which is a cached list that says
    // nothing about channels and can lag a toggle in either direction.
    //
    // The server indexes only plaintext, so search in an encrypted context comes
    // back empty rather than erroring; showing an explicit "not available" beats
    // an empty-results screen the user reads as "nothing matched".
    // Same pop-value handoff as `_openPinnedMessages`.
    final messageId = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => MessageSearchScreen(
          repository: repository,
          isEncrypted: _isEncrypted,
        ),
      ),
    );
    if (messageId == null || !mounted) return;
    await _jumpToMessage(messageId);
  }

  /// Guild channels reuse the existing full `GuildMembersScreen` outright
  /// (kick/ban/role management already lives there); DM/group conversations
  /// get a lightweight read-only sheet since there's no equivalent screen
  /// for that side yet and it doesn't need one - just names and avatars.
  void _openMembers() {
    final guildId = widget.guildId;
    if (guildId != null) {
      context.push(RoutePaths.serverMembersPath(guildId));
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.m,
                  AppSpacing.m,
                  AppSpacing.m,
                  AppSpacing.s,
                ),
                child: Text(
                  'Members',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: UserAvatar(userId: widget.myUserId, radius: 18),
                title: const Text('You'),
              ),
              for (final userId in widget.mentionableUserIds)
                ListTile(
                  leading: UserAvatar(userId: userId, radius: 18),
                  title: ProfileResolver(
                    userId: userId,
                    builder: (context, profile) =>
                        Text(profile?.userName ?? '…'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickGif() async {
    final url = await showGifPickerSheet(context);
    if (url == null || !mounted) return;
    context.read<MessageThreadBloc>().add(ThreadMessageSubmitted(url));
  }

  /// Inserts an emoji glyph into the composer at the cursor - reuses the
  /// same picker sheet the reaction bar's "+" already opens, just applied to
  /// the text field instead of toggling a reaction.
  Future<void> _pickEmojiForComposer() async {
    // No guildId here - custom emoji have no rendering story in composed
    // text yet (see the emoji feature's known limitations), so this stays
    // Unicode-only.
    final picked = await showReactionPickerSheet(context);
    if (picked == null || !mounted) return;
    final emoji = picked.emoji;
    final selection = _textController.selection;
    final text = _textController.text;
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;
    _textController.text = text.replaceRange(start, end, emoji);
    _textController.selection = TextSelection.collapsed(
      offset: start + emoji.length,
    );
  }

  Future<void> _showAttachMenu() async {
    // Read before the sheet opens rather than inside it: it is cached for as
    // long as the server says it may be, so this is a round trip on the first
    // open of a session and nothing after that. Null when the lookup has not
    // landed or the ceiling is unlimited, and the sheet simply says nothing -
    // a limit stated as "unknown" is worse than one not stated at all.
    final ceiling = uploadCeilingLine(
      await getIt<EntitlementReader>().uploadCeiling(guildId: widget.guildId),
    );
    if (!mounted) return;

    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Photo Library'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('File'),
              onTap: () => Navigator.pop(context, 'file'),
            ),
            ListTile(
              leading: const Icon(Icons.gif_box_outlined),
              title: const Text('GIF'),
              onTap: () => Navigator.pop(context, 'gif'),
            ),
            // Last, quiet, and where somebody is looking at the moment they
            // choose a file - which is the only moment the number is useful.
            if (ceiling != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.m,
                  AppSpacing.xs,
                  AppSpacing.m,
                  AppSpacing.m,
                ),
                child: Text(
                  ceiling,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    if (!mounted || choice == null) return;
    switch (choice) {
      case 'gallery':
        await _pickImage(ImageSource.gallery);
      case 'camera':
        await _pickImage(ImageSource.camera);
      case 'file':
        await _pickFile();
      case 'gif':
        await _pickGif();
    }
  }

  /// The app bar's title, and - for a group - the way into its settings.
  ///
  /// The pencil is drawn rather than left implicit: a title that silently
  /// happens to be tappable is a control nobody finds, and this is the only
  /// route to renaming a group on a handset.
  Widget _titleRow() {
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Guild channels are titled "#channel-name", which already carries its
        // own identity - only DMs get a leading avatar, matching Discord's
        // conversation header.
        if (widget.titleAvatar != null) ...[
          widget.titleAvatar!,
          const SizedBox(width: AppSpacing.s),
        ] else if (widget.guildId == null &&
            widget.mentionableUserIds.isNotEmpty) ...[
          UserAvatar(
            userId: widget.mentionableUserIds.first,
            radius: AppRadii.avatarSmall,
            showStatus: true,
          ),
          const SizedBox(width: AppSpacing.s),
        ],
        Flexible(child: Text(widget.title, overflow: TextOverflow.ellipsis)),
        if (widget.onTitleTap != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Icon(
            Icons.edit_outlined,
            size: 14,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ],
        if (_isEncrypted) ...[
          const SizedBox(width: AppSpacing.s),
          const EncryptedBadge(showLabel: true, size: 14),
        ],
      ],
    );

    final onTap = widget.onTitleTap;
    if (onTap == null) return row;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.chip),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xs,
        ),
        child: row,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(
          fallbackLocation: widget.guildId != null
              ? RoutePaths.serverPath(widget.guildId!)
              : RoutePaths.home,
        ),
        // See `AppTheme` - custom `Row` title, not a candidate for the iOS
        // centred nav title.
        centerTitle: false,
        title: _titleRow(),
        actions: [
          if (_isAnnouncementChannel)
            IconButton(
              icon: const Icon(Icons.rss_feed),
              tooltip: 'Follow Channel',
              onPressed: _followChannel,
            ),
          IconButton(
            icon: const Icon(Icons.push_pin_outlined),
            tooltip: 'Pinned Messages',
            onPressed: _openPinnedMessages,
          ),
          IconButton(icon: const Icon(Icons.search), onPressed: _openSearch),
          IconButton(
            icon: const Icon(Icons.people_outline),
            onPressed: _openMembers,
          ),
          ...?widget.actions,
        ],
      ),
      body: Column(
        children: [
          ?widget.banner,
          // Conversations too, since contract §B. A conversation's roster is
          // fixed at creation, but its group members are *devices* - a handset
          // registered after the DM existed was never welcomed to it, and until
          // there was a join-request route for one it had no way in and nobody
          // could give it one.
          if (_lockedOutOfEncryption)
            ChannelAccessBanner(
              key: ValueKey(
                context.read<MessageThreadBloc>().repository.contextId,
              ),
              contextId: context.read<MessageThreadBloc>().repository.contextId,
              isChannel: widget.guildId != null,
            ),
          // The other side of the same coin, and the reason a real report said
          // "neither mobile or anything else shows a prompt": a request against
          // a *conversation* had nowhere to be reviewed at all, because the only
          // queue in the app lived behind guild channel settings. Shown whenever
          // the context is encrypted, including to a device that is itself
          // locked out - it will say it cannot act rather than pretending the
          // request is not there.
          if (_serverEncrypted || _isEncrypted)
            MlsJoinRequestReview(
              key: ValueKey(
                'review-${context.read<MessageThreadBloc>().repository.contextId}',
              ),
              contextId: context.read<MessageThreadBloc>().repository.contextId,
              isChannel: widget.guildId != null,
            ),
          Expanded(
            // The pill is an overlay rather than a `Column` child: as a sibling
            // it would take vertical space and shove the list up by its own
            // height every time it appeared, which is exactly the jolt it
            // exists to spare the reader. Scoped to this `Expanded` so it
            // floats over the list and not over the composer.
            child: Stack(
              children: [
                BlocBuilder<MessageThreadBloc, ThreadState>(
                  builder: (context, state) {
                    final Widget child;
                    if (state.isLoadingInitial) {
                      child = const Center(
                        key: ValueKey('loading'),
                        child: CircularProgressIndicator.adaptive(),
                      );
                    } else if (state.messages.isEmpty) {
                      child = Center(
                        key: const ValueKey('empty'),
                        child: Text(
                          'No messages yet - say hi!',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      );
                    } else {
                      // Taken here rather than in a listener because it has to be
                      // settled *before* the first frame that shows the list -
                      // computing it afterwards would draw the timeline once
                      // without a divider and then move it, which reads as a
                      // glitch on the one screen where position is the message.
                      // It writes only a field nothing else has read yet, so it
                      // does not need (and must not do) a `setState` from build.
                      _snapshotFirstUnread(state);
                      child = NotificationListener<ScrollNotification>(
                        key: const ValueKey('loaded'),
                        onNotification: (notification) {
                          if (notification.metrics.pixels >=
                              notification.metrics.maxScrollExtent - 200) {
                            context.read<MessageThreadBloc>().add(
                              const ThreadLoadMoreRequested(),
                            );
                          }
                          return false;
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.m,
                            vertical: AppSpacing.s,
                          ),
                          itemCount: state.messages.length,
                          itemBuilder: (context, index) {
                            final message = state.messages[index];
                            // The anchor a jump scrolls to. `putIfAbsent` because
                            // the key has to survive the row being scrolled out
                            // and rebuilt - a fresh key each build would make
                            // `currentContext` null exactly when the jump needs it.
                            final anchor = _messageKeys.putIfAbsent(
                              message.id,
                              GlobalKey.new,
                            );
                            // Reversed list: the visually-previous message - the
                            // older one - is the *next* index, not the previous
                            // one. Hoisted above the system-row branch because
                            // both the day boundary and the grouping check below
                            // need it, and a system row heads a new day just like
                            // any other.
                            final previous = index + 1 < state.messages.length
                                ? state.messages[index + 1]
                                : null;
                            // First row of a local calendar day, which includes
                            // the oldest row of the loaded window: a window that
                            // opens mid-conversation still says which day it
                            // opens on. A message whose stamp is missing heads
                            // nothing - there is no date to head it with.
                            final startsDay = startsNewDay(
                              previous?.createdAt,
                              message.createdAt,
                            );

                            // Both dividers sit at the *top* of the row they
                            // belong to. `reverse` flips the order rows are laid
                            // out in, not the direction a row's own column runs,
                            // so this still lands between the last message read
                            // and the first one that was not.
                            //
                            // Date first, then unread: crossing midnight and
                            // crossing the read mark are two different statements,
                            // and the day the unread run starts on belongs above
                            // the line that says it is unread.
                            Widget withDivider(Widget row) {
                              final isUnreadMark = message.id == _firstUnreadId;
                              if (!startsDay && !isUnreadMark) return row;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (startsDay)
                                    _DateDivider(date: message.createdAt!),
                                  if (isUnreadMark) const _UnreadDivider(),
                                  row,
                                ],
                              );
                            }

                            // Deliberately the shared predicate rather than the
                            // five-way check that used to be inlined here: a voice
                            // invite is a server-written message too, and the only
                            // thing keeping it out of this branch is the reasoning
                            // recorded on `isSystemRow`. Spelling the list out
                            // twice is how the two drift apart.
                            if (message.isSystemRow) {
                              return KeyedSubtree(
                                key: anchor,
                                child: withDivider(
                                  _SystemMessageRow(
                                    message: message,
                                    myUserId: widget.myUserId,
                                  ),
                                ),
                              );
                            }

                            final isMe = message.authorId == widget.myUserId;
                            final failed = state.failedSendIds.contains(
                              message.id,
                            );
                            final showHeader =
                                previous == null ||
                                previous.authorId != message.authorId ||
                                // A date divider between two messages means they
                                // are not one group, however close the stamps: a
                                // grouped continuation hanging under a day
                                // boundary reads as a message from the wrong day.
                                startsDay ||
                                // Never grouped, however many the bot sends in a
                                // row: the header row is where "Only you can see
                                // this" lives, and a grouped continuation would
                                // drop the one line that says the rest of the
                                // channel cannot read it.
                                message.isEphemeral ||
                                (message.createdAt != null &&
                                    previous.createdAt != null &&
                                    message.createdAt!
                                            .difference(previous.createdAt!)
                                            .abs() >
                                        const Duration(minutes: 7));
                            return KeyedSubtree(
                              key: anchor,
                              child: withDivider(
                                _MessageBubble(
                                  message: message,
                                  showHeader: showHeader,
                                  isMe: isMe,
                                  failed: failed,
                                  isHighlighted:
                                      _highlightedMessageId == message.id,
                                  myUserId: widget.myUserId,
                                  isEditing: _editingMessageId == message.id,
                                  editController: _editController,
                                  onSaveEdit: () => _saveEdit(message.id),
                                  onCancelEdit: _cancelEdit,
                                  replyToWidget: message.inReplyTo != null
                                      ? _ReplyQuoteRow(
                                          replyTo: _resolveReply(
                                            message.inReplyTo!,
                                          ),
                                          // A reply quote is one of the three places a
                                          // jump starts from, and the only one that
                                          // does not go through a screen first.
                                          onTap: () => _jumpToMessage(
                                            message.inReplyTo!,
                                          ),
                                        )
                                      : null,
                                  resolveMentionName: _resolveMentionName,
                                  guildId: widget.guildId,
                                  onReactionToggle: (emoji, emojiId) =>
                                      context.read<MessageThreadBloc>().add(
                                        ReactionToggled(
                                          messageId: message.id,
                                          emoji: emoji,
                                          emojiId: emojiId,
                                        ),
                                      ),
                                  onAddReaction: () async {
                                    final picked =
                                        await showReactionPickerSheet(
                                          context,
                                          guildId: widget.guildId,
                                        );
                                    if (picked == null || !context.mounted) {
                                      return;
                                    }
                                    context.read<MessageThreadBloc>().add(
                                      ReactionToggled(
                                        messageId: message.id,
                                        emoji: picked.emoji,
                                        emojiId: picked.emojiId,
                                      ),
                                    );
                                  },
                                  onLongPress: () =>
                                      _showMessageActions(message),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: child,
                    );
                  },
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: AppSpacing.s,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _viewingOlder,
                    builder: (context, viewingOlder, child) => IgnorePointer(
                      // Faded rather than removed, so the pill does not take
                      // taps in the moment it is invisible - and so a reader
                      // who overshoots and comes straight back does not see it
                      // flash.
                      ignoring: !viewingOlder,
                      child: AnimatedOpacity(
                        opacity: viewingOlder ? 1 : 0,
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeOut,
                        child: child,
                      ),
                    ),
                    child: Center(
                      child: _JumpToPresentPill(onTap: _jumpToPresent),
                    ),
                  ),
                ),
              ],
            ),
          ),
          BlocBuilder<MessageThreadBloc, ThreadState>(
            buildWhen: (previous, current) =>
                previous.typingUserIds != current.typingUserIds,
            builder: (context, state) {
              if (state.typingUserIds.isEmpty) {
                return const SizedBox(height: 20);
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    state.typingUserIds.length == 1
                        ? 'Typing…'
                        : 'Several people are typing…',
                    style: theme.textTheme.labelSmall,
                  ),
                ),
              );
            },
          ),
          if (_suggestions.isNotEmpty)
            _CommandSuggestionList(
              suggestions: _suggestions,
              onSelect: _selectSuggestion,
            )
          else if (_mentionSuggestions.isNotEmpty)
            _MentionSuggestionList(
              suggestions: _mentionSuggestions,
              onSelect: _selectMention,
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocBuilder<MessageThreadBloc, ThreadState>(
                    buildWhen: (previous, current) =>
                        previous.error != current.error,
                    builder: (context, state) {
                      if (state.error == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.s),
                        child: Text(
                          state.error!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      );
                    },
                  ),
                  if (_replyTarget != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.s),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppRadii.chip),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.reply,
                            size: 16,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: ProfileResolver(
                              userId: _replyTarget!.authorId,
                              builder: (context, profile) => Text(
                                'Replying to ${profile?.userName ?? '…'}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _cancelReply,
                            child: const Icon(Icons.close, size: 16),
                          ),
                        ],
                      ),
                    ),
                  if (_pendingAttachments.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.s),
                      child: SizedBox(
                        height: 72,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _pendingAttachments.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: AppSpacing.xs),
                          itemBuilder: (context, index) {
                            final pending = _pendingAttachments[index];
                            return _PendingAttachmentChip(
                              pending: pending,
                              onRemove: () => _removePendingAttachment(pending),
                            );
                          },
                        ),
                      ),
                    ),
                  // One line per refused file, directly under the thumbnail it
                  // is about and above the box the message is being typed in.
                  // A snackbar was the obvious alternative and is the wrong
                  // one: it is gone in four seconds, and the file it was about
                  // is still sitting in the strip.
                  //
                  // Named per file rather than summarised, because a batch can
                  // hold one file that is too large and three that are fine,
                  // and "some files were refused" makes the user work out
                  // which.
                  for (final pending in _pendingAttachments)
                    if (pending.refusal case final String refusal)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.s),
                        child: EntitlementNotice(
                          message: refusal,
                          icon: Icons.info_outline,
                        ),
                      ),
                  if (_isLockedPost)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.m,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(
                          AppRadii.composerPill,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 18,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s),
                          Expanded(
                            child: Text(
                              'This post is locked. Nobody can send new '
                              'messages here.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(
                          AppRadii.composerPill,
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: _showAttachMenu,
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              minLines: 1,
                              maxLines: 5,
                              textInputAction: TextInputAction.send,
                              autofillHints: const [],
                              onChanged: (_) => context
                                  .read<MessageThreadBloc>()
                                  .add(const ThreadTypingNotified()),
                              onSubmitted: (_) => _submit(),
                              decoration: const InputDecoration(
                                hintText: 'Message',
                                filled: false,
                                isCollapsed: true,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _pickEmojiForComposer,
                            icon: const Icon(Icons.emoji_emotions_outlined),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          IconButton.filled(
                            onPressed: _submit,
                            icon: const Icon(Icons.send_rounded),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Which sigil opened the suggestion overlay - the mobile equivalent of
/// desktop's `overlayType`, minus `command`, which is still its own state
/// because selecting one replaces the composer rather than editing it.
enum _SuggestionTrigger {
  user('@'),
  channel('#'),
  emoji(':'),
  wiki('[[');

  const _SuggestionTrigger(this.sigil);

  /// What the user typed to open the overlay. Its length is what
  /// `_selectMention` replaces from, which is why `[[` cannot be assumed to be
  /// one character.
  final String sigil;
}

/// One row offered by the `@`-trigger autocomplete - either a real user
/// (avatar leading) or a role (colored dot leading), merged into one list
/// sorted by name.
sealed class _MentionSuggestionEntry {
  const _MentionSuggestionEntry(this.name);
  final String name;
}

class _UserMentionEntry extends _MentionSuggestionEntry {
  const _UserMentionEntry({required String name, required this.userId})
    : super(name);
  final String userId;
}

class _RoleMentionEntry extends _MentionSuggestionEntry {
  const _RoleMentionEntry({required String name, required this.roleId})
    : super(name);
  final String roleId;
}

class _ChannelMentionEntry extends _MentionSuggestionEntry {
  const _ChannelMentionEntry({required String name, required this.channelId})
    : super(name);
  final String channelId;
}

/// One `:shortcode:` candidate. [name] is the shortcode (no colons - they are
/// added back for display only), [emoji] the glyph that is actually inserted.
class _EmojiSuggestionEntry extends _MentionSuggestionEntry {
  const _EmojiSuggestionEntry({
    required String name,
    required this.emoji,
    required this.description,
  }) : super(name);

  final String emoji;

  /// The dataset's human-readable name, shown trailing so two similar glyphs
  /// under one shortcode stem are still tellable apart.
  final String description;
}

/// One `[[page]]` candidate. [name] is the title shown; the URL that actually
/// lands in the message is derived from the page in `_selectMention`.
class _WikiPageSuggestionEntry extends _MentionSuggestionEntry {
  const _WikiPageSuggestionEntry({required String name, required this.page})
    : super(name);
  final WikiPageSummaryDto page;
}

/// The link a `[[page]]` selection puts in the message.
///
/// **Bare, not bracketed.** The server recognises this shape by host and
/// attaches a `venta.wiki_page` embed in-process, so the card comes from the
/// embed rather than from anything scanning the body - which is also why
/// nothing on the render side looks for it. Wrapping it in the sender's
/// no-preview brackets would suppress the card it exists to produce.
String wikiShareLink(String guildId, String pageId) =>
    'https://venta.gg/wiki/$guildId/$pageId';

/// One searchable emoji, keyed by a shortcode.
typedef EmojiShortcode = ({String shortcode, String emoji, String name});

/// Every emoji in the picker's dataset, indexed by a shortcode derived from
/// its name.
///
/// Built off `emoji_picker_flutter`'s `defaultEmojiSet` - the same table the
/// reaction picker and the composer's emoji button already use - rather than
/// shipping a second one. That dataset has **no shortcode ids** the way
/// desktop's emoji-mart data does, only display names, so the shortcode is
/// derived: "Face With Tears of Joy" becomes `face_with_tears_of_joy`.
///
/// The practical consequence is that the two clients do not accept exactly the
/// same shortcodes - desktop knows `:joy:`, this knows `:face_with_tears_of_joy:`
/// - which is survivable only because the match is a substring one, so `:joy`
/// still finds it here. It never affects what is sent: both insert the native
/// glyph, and no shortcode ever reaches the wire.
///
/// Built once, on first use, and never rebuilt - the dataset is a compile-time
/// constant.
final List<EmojiShortcode> emojiShortcodeIndex = [
  for (final category in defaultEmojiSet)
    for (final emoji in category.emoji)
      (
        shortcode: emoji.name
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
            .replaceAll(RegExp(r'^_+|_+$'), ''),
        emoji: emoji.emoji,
        name: emoji.name,
      ),
];

/// Extracted from the composer's final text at submit time - see
/// `_ThreadViewState._extractMentions`.
class _ExtractedMentions {
  const _ExtractedMentions({
    required this.userIds,
    required this.roleIds,
    required this.everyone,
    required this.here,
  });
  final List<String> userIds;
  final List<String> roleIds;
  final bool everyone;
  final bool here;
}

/// The `@`-trigger autocomplete dropdown - same overlay treatment as
/// [_CommandSuggestionList], offering guild members/roles or DM
/// participants.
class _MentionSuggestionList extends StatelessWidget {
  const _MentionSuggestionList({
    required this.suggestions,
    required this.onSelect,
  });

  final List<_MentionSuggestionEntry> suggestions;
  final ValueChanged<_MentionSuggestionEntry> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final entry = suggestions[index];
          return ListTile(
            dense: true,
            leading: switch (entry) {
              _UserMentionEntry(userId: final userId) => UserAvatar(
                userId: userId,
                radius: 12,
              ),
              _RoleMentionEntry() => const Icon(
                Icons.shield_outlined,
                size: 20,
              ),
              _ChannelMentionEntry() => const Icon(Icons.tag, size: 20),
              _EmojiSuggestionEntry(emoji: final emoji) => Text(
                emoji,
                style: const TextStyle(fontSize: 20),
              ),
              _WikiPageSuggestionEntry() => const Icon(
                Icons.menu_book_outlined,
                size: 20,
              ),
            },
            // The colons are put back for the emoji row only, so the shortcode
            // reads the way it is typed - the glyph beside it already says
            // what it resolves to.
            title: Text(switch (entry) {
              _EmojiSuggestionEntry() => ':${entry.name}:',
              _ => entry.name,
            }),
            subtitle: switch (entry) {
              _EmojiSuggestionEntry(description: final description) => Text(
                description,
              ),
              _WikiPageSuggestionEntry(page: final page) =>
                page.tags.isEmpty ? null : Text(page.tags.join(', ')),
              _ => null,
            },
            trailing: switch (entry) {
              _WikiPageSuggestionEntry(page: final page) when page.isPinned =>
                const Icon(Icons.push_pin, size: 14),
              _ => null,
            },
            onTap: () => onSelect(entry),
          );
        },
      ),
    );
  }
}

/// The `/`-trigger autocomplete dropdown - merges local and bot commands
/// into one flat list, matching desktop's suggestion overlay.
class _CommandSuggestionList extends StatelessWidget {
  const _CommandSuggestionList({
    required this.suggestions,
    required this.onSelect,
  });

  final List<_CommandSuggestion> suggestions;
  final ValueChanged<_CommandSuggestion> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return switch (suggestion) {
            _LocalSuggestion(command: final command) => ListTile(
              dense: true,
              leading: const Icon(Icons.terminal, size: 18),
              title: Text('/${command.name}'),
              subtitle: Text(command.description),
              onTap: () => onSelect(suggestion),
            ),
            _BotSuggestion(command: final command) => ListTile(
              dense: true,
              leading: const Icon(Icons.smart_toy_outlined, size: 18),
              title: Text('/${command.name}'),
              subtitle: Text(command.description ?? command.botName),
              trailing: Text(
                command.botName,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              onTap: () => onSelect(suggestion),
            ),
          };
        },
      ),
    );
  }
}

/// One thumbnail/chip in the composer's pending-attachment strip - shows an
/// upload spinner while in flight, an error icon on failure, and a remove
/// button always.
class _PendingAttachmentChip extends StatelessWidget {
  const _PendingAttachmentChip({required this.pending, required this.onRemove});

  final _PendingAttachment pending;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.chip),
            child: SizedBox(
              width: 64,
              height: 64,
              child: pending.isImage
                  ? Image.memory(
                      Uint8List.fromList(pending.bytes),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        pending.fileName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
            ),
          ),
          if (pending.uploading)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.black38,
                child: Center(
                  child: AdaptiveProgressIndicator(
                    size: 20,
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          if (pending.failed)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.black38,
                child: Icon(Icons.error_outline, color: Colors.white),
              ),
            ),
          // Deliberately not the error icon. Nothing went wrong here and
          // nothing is worth retrying - the file does not fit, the sentence
          // under the strip says why, and the only useful action is the remove
          // button this chip already has.
          if (pending.isRefused)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.black45,
                child: Icon(Icons.block_outlined, color: Colors.white),
              ),
            ),
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: const Icon(Icons.close, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A URL the sender wrapped in angle brackets to opt out of a link preview.
///
/// `<https://example.com>` is the convention the *server* reads when deciding
/// whether to unfurl, so the brackets are load-bearing and have to survive on
/// the wire. They are only ever taken off for display - showing them leaks the
/// mechanic into the conversation as punctuation nobody typed on purpose.
final _noPreviewBracketPattern = RegExp(r'<(https?://[^\s<>]+)>');

/// [content] as it should be *shown*, with the sender's no-preview brackets
/// taken off. Mirrors Alpine's `displayContent`.
///
/// **Display only.** `_ThreadViewState._startEdit` loads the raw body, so an
/// edit round-trips the brackets instead of silently re-enabling a preview the
/// sender had suppressed - which would be the client overriding a decision the
/// sender made deliberately, without ever saying so.
String stripNoPreviewBrackets(String content) =>
    content.replaceAllMapped(_noPreviewBracketPattern, (m) => m[1]!);

/// Regional-indicator code points, which pair up into flags.
///
/// Excluded from the jumbo treatment because a flag is two of these and the
/// pair renders as one glyph - a "three emoji" message of flags is six code
/// points, and blowing it up to 2.5x is a wall rather than an expression.
bool _isRegionalIndicator(int codePoint) =>
    codePoint >= 0x1F1E6 && codePoint <= 0x1F1FF;

/// Matches a run made up only of emoji, variation selectors and ZWJs - the
/// same pattern Alpine's `isOnlyEmoji` tests with, deliberately including its
/// quirk that `\p{Emoji}` also covers ASCII digits and `#`/`*`. Divergence
/// there would mean "1" renders large on one client and small on the other.
final _onlyEmojiPattern = RegExp(
  // `valid_regexps` parses this without `unicode: true` and so rejects
  // `\p{...}`, which is only legal in unicode mode. The pattern is valid -
  // `isOnlyEmojiMessage` is covered by tests - and the lint is what is wrong.
  // ignore: valid_regexps
  r'^(\p{Emoji_Presentation}|\p{Emoji}\uFE0F?|\u200D)+$',
  unicode: true,
);

/// Whether [content] is emoji and nothing else, and therefore renders large.
///
/// The cap is on UTF-16 code units rather than glyphs, matching Alpine - a
/// long line of emoji is a wall at 2.5x however few "characters" it is, and
/// counting graphemes here would only move the wall further out.
///
/// Only U+0020 is stripped before the test, again matching Alpine: a message
/// with a newline in it is a *layout*, not a single expression, and stays at
/// body size.
bool isOnlyEmojiMessage(String content) {
  final stripped = content.trim().replaceAll(' ', '');
  if (stripped.isEmpty || stripped.length > 30) return false;
  for (final codePoint in stripped.runes) {
    if (_isRegionalIndicator(codePoint)) return false;
  }
  return _onlyEmojiPattern.hasMatch(stripped);
}

/// highlight.js' grammars, ported to Dart - the same ones Alpine's
/// `markdown.pipe.ts` highlights with, which is what keeps a block that
/// colours on desktop from arriving grey here.
///
/// Built once and lazily: the whole registry is a few hundred grammars, and a
/// thread with no code in it should never pay to construct them. Registration
/// carries each grammar's aliases too, so ```` ```js ```` resolves to
/// javascript exactly as it does on desktop.
final Highlight _highlighter = Highlight()
  ..registerLanguages(builtinAllLanguages);

/// Renders a fenced code block with syntax highlighting, falling back to plain
/// monospace text for a language nothing recognises - the same two-branch
/// shape as Alpine's `renderCodeBlock`, which highlights only when
/// `hljs.getLanguage(lang)` answers and escapes the text otherwise.
///
/// Never guesses. `re_highlight` offers auto-detection and Alpine deliberately
/// does not use it: a three-line snippet is ambiguous between half a dozen
/// languages, and a wrong guess miscolours the text with total confidence.
class MessageCodeBlockBuilder extends MarkdownElementBuilder {
  MessageCodeBlockBuilder({required this.theme});

  final ThemeData theme;

  @override
  bool isBlockElement() => true;

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    // `markdown` nests the body one level down as `<pre><code class=
    // "language-x">`, so both the text and the info string live on the child.
    final code = element.children?.whereType<md.Element>().firstOrNull;
    final source = (code ?? element).textContent;
    final className = code?.attributes['class'] ?? '';
    final language = className.startsWith('language-')
        ? className.substring('language-'.length)
        : null;

    final baseStyle = (preferredStyle ?? theme.textTheme.bodySmall)?.copyWith(
      fontFamily: 'monospace',
      // The stylesheet's own code colour would fight the highlighter's, and
      // the highlighter only styles the spans it recognises - so the
      // unrecognised remainder has to come from the same palette or a block
      // renders half in one scheme and half in the other.
      color: _codeTheme['root']?.color ?? theme.colorScheme.onSurface,
    );

    TextSpan? highlighted;
    if (language != null && _highlighter.getLanguage(language) != null) {
      final renderer = TextSpanRenderer(baseStyle, _codeTheme);
      _highlighter.highlight(code: source, language: language).render(renderer);
      highlighted = renderer.span;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xs,
      ),
      // Code does not wrap - a wrapped line is a different program to read.
      // Alpine's `pre` scrolls horizontally for the same reason.
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text.rich(
          highlighted ?? TextSpan(text: source, style: baseStyle),
        ),
      ),
    );
  }

  /// The highlighter's own palette rather than one assembled from
  /// `colorScheme`.
  ///
  /// Token colours are not a theme decision this app gets to make: they are
  /// keyed by highlight.js scope names (`keyword`, `string`, `comment`, …),
  /// there are around forty of them, and inventing a mapping onto four or five
  /// scheme roles would collapse most of them into the same colour and defeat
  /// the point. This is a shipped highlight.js theme, which is the same source
  /// Alpine's own palette was derived from.
  Map<String, TextStyle> get _codeTheme => theme.brightness == Brightness.dark
      ? atomOneDarkTheme
      : atomOneLightTheme;
}

/// Formats a local time as e.g. "3:45 PM" without pulling in `intl` for one
/// call site.
String _formatMessageTime(DateTime dt) {
  final local = dt.toLocal();
  final hour24 = local.hour;
  final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = hour24 < 12 ? 'AM' : 'PM';
  return '$hour12:$minute $period';
}

/// The floating "jump to present" control, raised while the reader is looking
/// at older messages.
///
/// One tappable pill rather than Alpine's label-plus-button pair. That split
/// works on a desktop header where there is room to say "Viewing older
/// messages" beside it; on a handset the pill is sitting on top of the very
/// messages it is describing, so it earns its space by being the smallest
/// thing that is unambiguously a button.
class _JumpToPresentPill extends StatelessWidget {
  const _JumpToPresentPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(AppRadii.composerPill),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.s,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_downward_rounded,
                size: 16,
                color: theme.colorScheme.onSurface,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Jump to present',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The day heading drawn above the first message of each local calendar day.
///
/// Deliberately quieter than [_UnreadDivider]: that one is the scheme's "look
/// here" register and there must be no doubt which of the two a reader is
/// looking at when both land on the same row. This is a hairline and a muted
/// label - structure rather than an alert.
class _DateDivider extends StatelessWidget {
  const _DateDivider({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final line = theme.colorScheme.onSurface.withValues(alpha: 0.12);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Row(
        children: [
          Expanded(child: Divider(height: 1, color: line)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
            child: Text(
              formatDayHeading(date, DateTime.now()),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Divider(height: 1, color: line)),
        ],
      ),
    );
  }
}

/// The "new messages" line, drawn above the first message that arrived after
/// this account last read the conversation - see
/// `_ThreadViewState._snapshotFirstUnread` for where the position comes from
/// and why it is taken exactly once.
///
/// Uses the error role rather than a colour of its own: it is the scheme's
/// "look here" register, which is what Alpine's rose line is too, and this
/// screen has no other token that reads as a boundary.
class _UnreadDivider extends StatelessWidget {
  const _UnreadDivider();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.error;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s, bottom: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Divider(height: 1, color: color.withValues(alpha: 0.35)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
            child: Text(
              'NEW MESSAGES',
              style: theme.textTheme.labelSmall?.copyWith(
                color: color.withValues(alpha: 0.75),
                fontWeight: FontWeight.bold,
                letterSpacing: 0.7,
              ),
            ),
          ),
          Expanded(
            child: Divider(height: 1, color: color.withValues(alpha: 0.35)),
          ),
        ],
      ),
    );
  }
}

/// Discord-style row: avatar + author name (bold, a step above body size)
/// shown once per consecutive run of same-author messages - [showHeader]
/// is false for subsequent messages in that run, which just indent under
/// where the name was instead of repeating the avatar/name.
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.showHeader,
    required this.isMe,
    required this.failed,
    required this.myUserId,
    required this.onReactionToggle,
    required this.onAddReaction,
    required this.onLongPress,
    required this.resolveMentionName,
    required this.guildId,
    this.isEditing = false,
    this.isHighlighted = false,
    this.editController,
    this.onSaveEdit,
    this.onCancelEdit,
    this.replyToWidget,
  });

  final MessageDto message;
  final bool showHeader;
  final bool isMe;
  final bool failed;

  /// A jump just landed here. Flashes a tint that decays to nothing, which is
  /// what tells the reader which of thirty near-identical rows they asked for.
  final bool isHighlighted;
  final String myUserId;
  final void Function(String emoji, String? emojiId) onReactionToggle;
  final VoidCallback onAddReaction;
  final VoidCallback onLongPress;
  final String? Function(String userId) resolveMentionName;
  final String? guildId;
  final bool isEditing;
  final TextEditingController? editController;
  final VoidCallback? onSaveEdit;
  final VoidCallback? onCancelEdit;
  final Widget? replyToWidget;

  /// Width the avatar occupies (diameter) plus the gap before the text
  /// column - grouped messages indent by this same amount so the text
  /// lines up under the name instead of the avatar.
  static const _leadingWidth = AppRadii.avatarMedium * 2 + AppSpacing.s;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = MessageContentCodec.decode(message.content);
    final isGifMessage = message.attachments.isEmpty && isKlipyGifUrl(text);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ?replyToWidget,
        if (showHeader)
          Row(
            children: [
              Flexible(
                child: ProfileResolver(
                  userId: message.authorId,
                  builder: (context, profile) => Text(
                    profile?.userName ?? '…',
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              if (message.authorIdType == MessageAuthorType.bot) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadii.badge),
                  ),
                  child: Text(
                    'BOT',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
              // Said out loud rather than left to be inferred: an ephemeral
              // reply looks exactly like a message the rest of the channel can
              // read, and acting on that assumption is how someone answers a
              // bot in public thinking they answered it privately. Beside the
              // BOT badge, because the two facts belong together - this is a
              // bot's answer, and it is only yours.
              if (message.isEphemeral) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.visibility_off_outlined,
                  size: 11,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 3),
                Text(
                  'Only you can see this',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
              if (message.createdAt != null) ...[
                const SizedBox(width: 6),
                Text(
                  _formatMessageTime(message.createdAt!),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
              if (message.isPinned) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.push_pin,
                  size: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ],
              // Per-message rather than per-thread on purpose: an encrypted
              // context has plaintext history above the point it was turned on,
              // and the header badge alone would claim that stretch is sealed
              // too. Alpine marks the individual message for the same reason.
              if (message.encryptionState ==
                  MessageEncryptionState.encrypted) ...[
                const SizedBox(width: 6),
                const EncryptedBadge(),
              ],
            ],
          ),
        if (isEditing)
          _MessageEditField(
            controller: editController!,
            onSave: onSaveEdit!,
            onCancel: onCancelEdit!,
          )
        else
          _MessageBody(
            message: message,
            text: text,
            isGifMessage: isGifMessage,
            theme: theme,
            resolveMentionName: resolveMentionName,
            guildId: guildId,
          ),
        MessageReactionBar(
          reactions: message.reactions,
          myUserId: myUserId,
          guildId: guildId,
          onToggle: onReactionToggle,
          onAddPressed: onAddReaction,
        ),
        if (message.isPending || failed)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              message.isBotCommandPlaceholder
                  ? (failed ? "Didn't respond" : 'Thinking…')
                  : (failed ? 'Failed to send' : 'Sending…'),
              style: theme.textTheme.labelSmall,
            ),
          ),
      ],
    );

    // A decay rather than a steady tint: the flash has to be noticeable on
    // arrival and gone by the time the reader starts reading, or it becomes a
    // permanent-looking selection nobody asked for. Alpine's `msg-flash`
    // animation does the same thing over the same two seconds.
    Widget flash(Widget child) => !isHighlighted
        ? child
        : TweenAnimationBuilder<double>(
            key: ValueKey('flash-${message.id}'),
            tween: Tween(begin: 1, end: 0),
            duration: const Duration(seconds: 2),
            curve: Curves.easeOut,
            builder: (context, t, inner) => DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15 * t),
                borderRadius: BorderRadius.circular(AppRadii.chip),
              ),
              child: inner,
            ),
            child: child,
          );

    return flash(
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.push(RoutePaths.userProfilePath(message.authorId)),
        onLongPress:
            message.isPending ||
                message.isBotCommandPlaceholder ||
                // No server-side row, so every action on the sheet would 404 -
                // see `_ThreadViewState._showMessageActions`, which refuses the
                // same message again.
                message.isEphemeral
            ? null
            : onLongPress,
        child: Padding(
          padding: EdgeInsets.only(top: showHeader ? 14 : 3),
          child: showHeader
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserAvatar(
                      userId: message.authorId,
                      radius: AppRadii.avatarMedium,
                      showStatus: true,
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(child: content),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.only(left: _leadingWidth),
                  child: content,
                ),
        ),
      ),
    );
  }
}

/// Just the GIF/text/attachment body of a message - split out so
/// [_MessageBubble] doesn't duplicate it between its headered and
/// grouped-continuation layouts.
class _MessageBody extends StatelessWidget {
  const _MessageBody({
    required this.message,
    required this.text,
    required this.isGifMessage,
    required this.theme,
    required this.resolveMentionName,
    required this.guildId,
  });

  final MessageDto message;
  final String text;
  final bool isGifMessage;
  final ThemeData theme;
  final String? Function(String userId) resolveMentionName;
  final String? guildId;

  @override
  Widget build(BuildContext context) {
    // Ciphertext we hold no keys for. Rendering `text` here would put base64 in
    // the timeline - the decryptor already decided this cannot be read, so say
    // that instead of showing the user the bytes.
    if (message.isUndecryptable) return const UndecryptableMessageBody();

    // Display only. `_ThreadViewState._startEdit` deliberately loads the raw
    // body instead, so an edit round-trips the sender's brackets rather than
    // silently re-enabling the preview they suppressed.
    final displayText = stripNoPreviewBrackets(text);

    // There was a `MessageType.invite` branch here that scanned the body for an
    // invite URL and drew its own card. It never once fired: the type exists in
    // the enum and is plumbed end to end, and nothing has ever produced it. It
    // stays in the enum (the value is a persisted ordinal, so removing it would
    // renumber every other message type on every stored row) and it stays
    // unproduced - a message containing an invite is an ordinary message with
    // prose around the link, and typing it `Invite` would suppress every other
    // preview on it.
    //
    // The card belongs to the link, not to the message. The server recognises
    // its own links now and ships a `venta.invite` embed, which arrives through
    // `MessageEmbedsView` at the bottom of this column like every other card.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cleartext in an encrypted thread. Shown, because genuine cleartext
        // history exists above an encryption switch-on, but never shown as if it
        // were sealed - that is the whole of the server-injection path.
        if (message.isUnverifiedPlaintext) const UnverifiedPlaintextNotice(),
        if (isGifMessage)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.chip),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240, maxWidth: 280),
              child: CachedNetworkImage(
                imageUrl: text,
                fit: BoxFit.contain,
                fadeInDuration: const Duration(milliseconds: 200),
                placeholder: (context, url) => Container(
                  width: 120,
                  height: 120,
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
                errorWidget: (context, url, error) => Container(
                  width: 120,
                  height: 120,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.broken_image_outlined),
                ),
              ),
            ),
          )
        // A voice invite's whole readable content is its card, which
        // `MessageEmbedsView` at the bottom of this column already draws.
        // `content` is a plain-English sentence for a client that does not
        // understand the type - rendering it here prints the card's own
        // sentence directly above the card. See `MessageDtoX`.
        else if (message.isVoiceChannelInvite)
          const SizedBox.shrink()
        // An emoji-only message renders at 2.5x, matching Alpine's
        // `isOnlyEmoji` branch. Off the raw body rather than [displayText]:
        // the bracket strip cannot change the answer, and Alpine reads the raw
        // one for the same reason.
        else if (isOnlyEmojiMessage(text))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                // `leading-none` on Alpine's wrapper - a 2.5x glyph on the
                // default 1.4-ish line height leaves a band of dead space
                // above and below it that reads as a layout bug.
                fontSize: (theme.textTheme.bodyMedium?.fontSize ?? 14) * 2.5,
                height: 1,
              ),
            ),
          )
        else if (displayText.isNotEmpty)
          Builder(
            builder: (context) {
              final userNames = <String, String>{};
              for (final userId in message.mentions) {
                final name = resolveMentionName(userId);
                if (name != null) userNames[name] = userId;
              }
              final roles = guildId != null
                  ? getIt<GuildRepository>().cachedById(guildId!)?.roles ?? []
                  : const <RoleDto>[];
              final roleNames = <String, String>{};
              final roleColors = <String, Color>{};
              for (final roleId in message.roleMentions) {
                final role = roles.where((r) => r.id == roleId).firstOrNull;
                if (role == null) continue;
                roleNames[role.name] = role.id;
                if (role.color != null) {
                  roleColors[role.id] = parseHexColor(role.color!);
                }
              }
              final channels = guildId != null
                  ? getIt<GuildRepository>().cachedById(guildId!)?.channels ??
                        []
                  : const <ChannelDto>[];
              final channelNames = <String, String>{};
              for (final channel in channels) {
                channelNames.putIfAbsent(channel.name, () => channel.id);
                if (channel.type == ChannelType.text) {
                  channelNames[channel.name] = channel.id;
                }
              }
              return MarkdownBody(
                data: displayText,
                softLineBreak: true,
                shrinkWrap: true,
                extensionSet:
                    md.ExtensionSet(md.ExtensionSet.gitHubWeb.blockSyntaxes, [
                      _MentionSyntax(
                        userNames: userNames,
                        roleNames: roleNames,
                        channelNames: channelNames,
                        everyone: message.mentionsEveryone,
                        here: message.mentionsHere,
                      ),
                      ...md.ExtensionSet.gitHubWeb.inlineSyntaxes,
                    ]),
                builders: {
                  'mention': _MentionElementBuilder(
                    theme: theme,
                    guildId: guildId,
                    roleColors: roleColors,
                  ),
                  // Registered on `pre` rather than `code`, which is also the
                  // inline-code tag - a builder there would repaint every
                  // `like this` run as a one-line program.
                  'pre': MessageCodeBlockBuilder(theme: theme),
                },
                styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                  p: theme.textTheme.bodyMedium,
                  blockSpacing: 4,
                  codeblockDecoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadii.chip),
                  ),
                ),
                onTapLink: (text, href, title) =>
                    openMessageLink(context, href),
              );
            },
          ),
        // Driven off `editedAt`, never `updatedAt`: the latter also moves when
        // a link preview attaches or a pin lands, which would label every
        // message containing a link as edited a second after it was posted.
        if (message.isEdited)
          Text(
            '(edited)',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
            ),
          ),
        MessageAttachmentsView(attachments: message.attachments),
        // Below the attachments, matching the order the server lists them in.
        // Absent on arrival and filled in seconds later by a `MessageUpdated`
        // once the unfurl completes - which is why nothing here waits for it.
        MessageEmbedsView(embeds: message.embeds),
      ],
    );
  }
}

/// Matches `@user`, `@role`, `@everyone`/`@here`, and `#channel` - but only
/// when the name is one of the message's actual known references (resolved
/// user/role names, or the message's own `mentionsEveryone`/`mentionsHere`
/// flags), mirroring Alpine's distinction between a real mention and
/// someone merely typing an `@`/`#`-prefixed word. Every alternative is
/// always present in the built pattern (as a dead, never-matching branch
/// when its category is empty) so `Match.namedGroup` never hits an
/// undeclared group.
class _MentionSyntax extends md.InlineSyntax {
  _MentionSyntax({
    required this.userNames,
    required this.roleNames,
    required this.channelNames,
    required this.everyone,
    required this.here,
  }) : super(_buildPattern(userNames, roleNames, channelNames, everyone, here));

  final Map<String, String> userNames;
  final Map<String, String> roleNames;
  final Map<String, String> channelNames;
  final bool everyone;
  final bool here;

  static String _group(String name, String prefix, Iterable<String> words) {
    if (words.isEmpty) return '$prefix(?<$name>(?!x)x)';
    final sorted = words.toList()..sort((a, b) => b.length - a.length);
    final escaped = sorted.map(RegExp.escape).join('|');
    return '$prefix(?<$name>$escaped)\\b';
  }

  static String _buildPattern(
    Map<String, String> userNames,
    Map<String, String> roleNames,
    Map<String, String> channelNames,
    bool everyone,
    bool here,
  ) {
    final broadcastWords = [if (everyone) 'everyone', if (here) 'here'];
    return [
      _group('user', '@', userNames.keys),
      _group('role', '@', roleNames.keys),
      _group('bcast', '@', broadcastWords),
      _group('channel', '#', channelNames.keys),
    ].join('|');
  }

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final regExpMatch = match as RegExpMatch;
    final user = regExpMatch.namedGroup('user');
    final role = regExpMatch.namedGroup('role');
    final bcast = regExpMatch.namedGroup('bcast');
    final channel = regExpMatch.namedGroup('channel');
    final String kind;
    final String raw;
    final String refId;
    if (user != null) {
      kind = 'user';
      raw = '@$user';
      refId = userNames[user] ?? '';
    } else if (role != null) {
      kind = 'role';
      raw = '@$role';
      refId = roleNames[role] ?? '';
    } else if (bcast != null) {
      kind = 'bcast';
      raw = '@$bcast';
      refId = '';
    } else {
      kind = 'channel';
      raw = '#$channel';
      refId = channelNames[channel] ?? '';
    }
    final element = md.Element.text('mention', raw);
    element.attributes['kind'] = kind;
    element.attributes['refId'] = refId;
    parser.addNode(element);
    return true;
  }
}

class _MentionElementBuilder extends MarkdownElementBuilder {
  _MentionElementBuilder({
    required this.theme,
    required this.guildId,
    required this.roleColors,
  });

  final ThemeData theme;
  final String? guildId;
  final Map<String, Color> roleColors;

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final kind = element.attributes['kind'];
    final refId = element.attributes['refId'] ?? '';
    final Color fg = switch (kind) {
      'role' => roleColors[refId] ?? theme.colorScheme.primary,
      'bcast' => theme.colorScheme.error,
      _ => theme.colorScheme.primary,
    };
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        color: fg.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        element.textContent,
        style: (preferredStyle ?? theme.textTheme.bodyMedium)?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    if (kind != 'channel' || guildId == null || refId.isEmpty) return chip;
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () =>
            context.push(RoutePaths.serverChannelPath(guildId!, refId)),
        child: chip,
      ),
    );
  }
}

/// Inline text-edit affordance shown in place of [_MessageBody] while a
/// message is being edited - Enter saves, Shift+Enter inserts a newline,
/// matching the composer's own submit-on-enter convention.
class _MessageEditField extends StatelessWidget {
  const _MessageEditField({
    required this.controller,
    required this.onSave,
    required this.onCancel,
  });

  final TextEditingController controller;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          autofocus: true,
          minLines: 1,
          maxLines: 5,
          textInputAction: TextInputAction.send,
          autofillHints: const [],
          onSubmitted: (_) => onSave(),
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s,
              vertical: 8,
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.chip),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.chip),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(onPressed: onCancel, child: const Text('Cancel')),
              const SizedBox(width: 4),
              FilledButton(onPressed: onSave, child: const Text('Save')),
            ],
          ),
        ),
      ],
    );
  }
}

/// Quoted reference to the message being replied to, shown above the
/// header of the replying message - matches desktop's reply-reference row
/// (author name + snippet). Shows an italic placeholder while the
/// referenced message is still being resolved or if it's gone.
class _ReplyQuoteRow extends StatelessWidget {
  const _ReplyQuoteRow({required this.replyTo, this.onTap});

  final MessageDto? replyTo;

  /// Jumps the timeline to the quoted message. Wired even while [replyTo] is
  /// still resolving: the id is known from the moment the row is built, and
  /// the jump only ever needed the id - refusing the tap until the preview
  /// text arrives would make the row feel broken for the second it takes.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
    );
    final target = replyTo;
    return GestureDetector(
      onTap: onTap,
      // The row is mostly whitespace, and a hit test that only counted the
      // glyphs would miss most taps aimed at it.
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Row(
          children: [
            Icon(
              Icons.reply,
              size: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
            ),
            const SizedBox(width: 4),
            if (target == null)
              Text(
                'Original message',
                style: mutedStyle?.copyWith(fontStyle: FontStyle.italic),
              )
            else
              Flexible(
                child: ProfileResolver(
                  userId: target.authorId,
                  builder: (context, profile) {
                    final snippet = MessageContentCodec.decode(target.content);
                    return Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${profile?.userName ?? '…'}  ',
                            style: mutedStyle?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: snippet.isEmpty ? '(attachment)' : snippet,
                            style: mutedStyle,
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Centered flavor-text row for join/leave/call/generic system events - no
/// avatar, no reactions, no long-press actions, matching desktop's
/// visually-distinct `SystemMessageComponent`.
class _SystemMessageRow extends StatelessWidget {
  const _SystemMessageRow({required this.message, required this.myUserId});

  final MessageDto message;

  /// Only the call rows use it, to say "you called" rather than naming the
  /// person reading the line.
  final String myUserId;

  bool get _isCall =>
      message.type == MessageType.callEnded ||
      message.type == MessageType.callMissed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
      fontStyle: FontStyle.italic,
    );

    if (message.type == MessageType.system) {
      return _centered(
        Text(
          MessageContentCodec.decode(message.content),
          style: style,
          textAlign: TextAlign.center,
        ),
      );
    }

    return _centered(
      ProfileResolver(
        userId: message.authorId,
        builder: (context, profile) {
          final userName = profile?.userName ?? '…';
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isCall) ...[
                Icon(
                  message.type == MessageType.callMissed
                      ? Icons.phone_missed
                      : Icons.call,
                  size: 14,
                  color: message.type == MessageType.callMissed
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              Flexible(
                child: Text(
                  _isCall
                      ? _callText(userName)
                      : systemJoinLeaveText(
                          leaving: message.type == MessageType.guildMemberLeave,
                          variant: message.systemMessageVariant,
                          userName: userName,
                        ),
                  style: style,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _centered(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Center(child: child),
  );

  /// The author of a call row is always whoever *placed* the call, which is
  /// what makes "you missed a call from X" answerable without a second lookup.
  String _callText(String userName) {
    final caller = message.authorId == myUserId ? 'You' : userName;
    if (message.type == MessageType.callMissed) {
      return message.authorId == myUserId
          ? 'You called - no answer'
          : 'Missed call from $userName';
    }
    final duration = _formatDuration(
      MessageContentCodec.decode(message.content),
    );
    return duration == null ? '$caller called' : '$caller called - $duration';
  }

  /// Content is whole seconds as plain text. Anything else - an empty body, a
  /// value from a server that changed the format - renders as a bare "called"
  /// rather than as a broken duration.
  ///
  /// The largest two units only, matching Alpine's `formatDuration`: `45s`,
  /// `3m 4s`, `1h 2m`. Without the hour branch a seventy-minute call read
  /// "70m 14s", which is both wrong-looking and harder to take in than the
  /// number it is trying to convey. Seconds are dropped rather than rounded
  /// into the minutes once there are hours - on a call that long the second is
  /// noise, and rounding would make two adjacent calls of the same length
  /// print differently.
  String? _formatDuration(String raw) {
    final seconds = int.tryParse(raw.trim());
    if (seconds == null || seconds < 0) return null;
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainder = seconds % 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    if (minutes > 0) return '${minutes}m ${remainder}s';
    return '${remainder}s';
  }
}

/// "Which of your channels should receive this?" picker for
/// [_ThreadViewState._followChannel] - flat list across every guild the
/// client has cached, since there's no cross-server directory endpoint to
/// query against (server enforces `ManageChannel` on whichever one is
/// picked, so an unauthorized pick just surfaces as an error afterward
/// rather than being filtered out here).
class _FollowChannelSheet extends StatelessWidget {
  const _FollowChannelSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final guilds = getIt<GuildRepository>().cached;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Text(
                'Follow into which channel?',
                style: theme.textTheme.titleSmall,
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final guild in guilds)
                    for (final channel in guild.channels)
                      if (channel.type == ChannelType.text ||
                          channel.type == ChannelType.announcement)
                        ListTile(
                          leading: const Icon(Icons.tag),
                          title: Text('#${channel.name}'),
                          subtitle: Text(guild.name),
                          onTap: () => Navigator.of(context).pop(channel),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
