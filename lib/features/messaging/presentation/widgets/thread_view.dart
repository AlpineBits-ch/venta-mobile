import 'dart:async';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/profile_resolver.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/hex_color.dart';
import '../../../guilds/data/guild_repository.dart';
import '../../../guilds/data/models/channel_dto.dart';
import '../../../guilds/data/models/guild_member_dto.dart';
import '../../../guilds/data/models/role_dto.dart';
import '../../../invites/presentation/widgets/invite_dialog.dart';
import '../../../profile/data/profile_repository.dart';
import '../../bloc/message_thread_bloc.dart';
import '../../data/bot_command_api.dart';
import '../../data/gif_api.dart';
import '../../data/message_content_codec.dart';
import '../../data/models/attachment_dto.dart';
import '../../data/models/bot_command_dto.dart';
import '../../data/models/message_dto.dart';
import 'bot_command_options_dialog.dart';
import 'gif_picker_sheet.dart';
import 'message_attachment_view.dart';
import 'message_search_screen.dart';
import 'reaction_bar.dart';
import 'reaction_picker_sheet.dart';

const _imageExtensions = {'png', 'jpg', 'jpeg', 'gif', 'webp', 'heic', 'bmp'};

final _inviteUrlRe = RegExp(r'https://venta\.gg/invite/([A-Za-z0-9_-]+)');

/// Flavor-text rotations for join/leave system messages — kept verbatim from
/// desktop's locale strings (`MESSAGE.SYSTEM.GUILD_MEMBER_JOIN/LEAVE.*`) so
/// the same server-assigned `systemMessageVariant` index reads identically
/// on both clients.
const _joinVariants = [
  '%USER% joined the server',
  '%USER% just showed up',
  'Welcome, %USER%. Say hi!',
  '%USER% joined. Everyone, look busy!',
  '%USER% slid into the server',
  '%USER% arrived',
  "Glad you're here, %USER%",
  'A wild %USER% appeared',
  '%USER% hopped into the server',
  'Everyone welcome %USER%!',
];

const _leaveVariants = [
  '%USER% left the server',
  '%USER% wandered off',
  '%USER% has left the building',
  '%USER% is gone',
  '%USER% slipped away',
  "%USER% left. We'll miss you!",
  '%USER% has left the party',
  '%USER% disappeared',
  '%USER% said goodbye',
  '%USER% is no longer with us',
];

/// Client-only commands that don't hit a bot — matches desktop's
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

/// One row in the `/`-trigger suggestion overlay — either a local command or
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
/// uploaded — tracked as local composer state, mirroring desktop's
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
}

/// The message list + composer, shared by DM conversations and guild
/// channels alike — this is the concrete payoff of parameterizing
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
  });

  final String title;
  final String myUserId;
  final List<Widget>? actions;

  /// Set only for guild channels — gates bot-command discovery/autocomplete,
  /// since bots (and therefore slash commands) only exist inside guilds.
  final String? guildId;

  /// DM conversation participants (other than the caller) offered as
  /// `@mention` autocomplete candidates. Unused for guild channels, which
  /// source candidates from the guild's member list instead (see
  /// `_loadGuildMembers`).
  final List<String> mentionableUserIds;

  @override
  State<ThreadView> createState() => _ThreadViewState();
}

class _ThreadViewState extends State<ThreadView> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
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
  String _mentionTrigger = '@';

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _loadBotCommands();
    _loadGuildMembers();
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _editController.dispose();
    _scrollController.dispose();
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

  /// Long-press action sheet — Reply / Edit / Delete, mirroring the message
  /// actions already established for other pickers in this composer (bottom
  /// sheet with a leading icon per row).
  Future<void> _showMessageActions(MessageDto message) async {
    final isMine = message.authorId == widget.myUserId;
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
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case 'reply':
        _startReply(message);
      case 'edit':
        _startEdit(message);
      case 'delete':
        await _confirmDelete(message);
    }
  }

  /// Cache-then-fetch lookup for a reply reference, same idea as
  /// `ProfileResolver` — checks the already-loaded page first, then the
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
  /// [_resolveReply] and `ProfileResolver` — used to tell a real `@mention`
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
      // Autocomplete just won't offer bot commands — not worth surfacing.
    }
  }

  Future<void> _loadGuildMembers() async {
    final guildId = widget.guildId;
    if (guildId == null) return;
    try {
      final members = await getIt<GuildRepository>().getMembers(guildId);
      if (mounted) setState(() => _guildMembers = members);
    } catch (_) {
      // Autocomplete just won't offer @mention candidates — not worth
      // surfacing, same tolerance as the bot-command load above.
    }
  }

  /// Display name → user id for everyone `@mention` autocomplete (and the
  /// final send-time mention scan) should consider — guild members for a
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

  /// Role name → role id, for `@role` autocomplete/rendering — guild
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

  /// Channel name → channel id for `#channel` autocomplete — text channels
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

  void _onTextChanged() {
    final text = _textController.text;
    final commandMatch = RegExp(r'^/(\w*)$').firstMatch(text);
    final commandQuery = commandMatch?.group(1);

    String? mentionQuery;
    var mentionStart = -1;
    var mentionTrigger = '@';
    final cursor = _textController.selection.baseOffset;
    if (cursor > 0) {
      final before = text.substring(0, cursor);
      final atIndex = before.lastIndexOf('@');
      final hashIndex = before.lastIndexOf('#');
      final triggerIndex = atIndex > hashIndex ? atIndex : hashIndex;
      if (triggerIndex != -1) {
        final afterTrigger = before.substring(triggerIndex + 1);
        final precededOk =
            triggerIndex == 0 ||
            RegExp(r'\s').hasMatch(before[triggerIndex - 1]);
        if (precededOk && RegExp(r'^\w*$').hasMatch(afterTrigger)) {
          mentionQuery = afterTrigger;
          mentionStart = triggerIndex;
          mentionTrigger = before[triggerIndex];
        }
      }
    }

    if (commandQuery != _commandQuery ||
        mentionQuery != _mentionQuery ||
        mentionStart != _mentionStart) {
      setState(() {
        _commandQuery = commandQuery;
        _mentionQuery = mentionQuery;
        _mentionStart = mentionStart;
        _mentionTrigger = mentionTrigger;
      });
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
    if (_mentionTrigger == '#') {
      final channelEntries =
          [
              for (final entry in _channelCandidateNames.entries)
                if (entry.key.toLowerCase().startsWith(lower))
                  _ChannelMentionEntry(
                    name: entry.key,
                    channelId: entry.value,
                  ),
            ]
            ..sort((a, b) => a.name.compareTo(b.name));
      return channelEntries.take(8).toList();
    }
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

  void _selectMention(String name) {
    final text = _textController.text;
    final end = _mentionStart + 1 + (_mentionQuery?.length ?? 0);
    final replacement = '$_mentionTrigger$name ';
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
  /// insertion bookkeeping — robust to the user editing/removing an
  /// inserted mention afterwards. `@everyone`/`@here` are flagged whenever
  /// they literally appear (no rich "chip" editor here to gate on an
  /// explicit selection like desktop's composer does) — the server is
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
        const SnackBar(content: Text('Still uploading — hang on a moment.')),
      );
      return;
    }
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

  void _addPendingAttachment({
    required List<int> bytes,
    required String fileName,
    required bool isImage,
  }) {
    final pending = _PendingAttachment(
      bytes: bytes,
      fileName: fileName,
      isImage: isImage,
    );
    setState(() => _pendingAttachments.add(pending));
    _upload(pending);
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
    } catch (_) {
      if (!mounted) return;
      setState(() {
        pending.uploading = false;
        pending.failed = true;
      });
    }
  }

  void _removePendingAttachment(_PendingAttachment pending) {
    setState(() => _pendingAttachments.remove(pending));
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await _imagePicker.pickImage(source: source, imageQuality: 85);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    _addPendingAttachment(bytes: bytes, fileName: file.name, isImage: true);
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(withData: true);
    final file = result?.files.firstOrNull;
    if (file == null || file.bytes == null) return;
    final ext = file.extension?.toLowerCase();
    _addPendingAttachment(
      bytes: file.bytes!,
      fileName: file.name,
      isImage: ext != null && _imageExtensions.contains(ext),
    );
  }

  void _openSearch() {
    final repository = context.read<MessageThreadBloc>().repository;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MessageSearchScreen(repository: repository),
      ),
    );
  }

  /// Guild channels reuse the existing full `GuildMembersScreen` outright
  /// (kick/ban/role management already lives there); DM/group conversations
  /// get a lightweight read-only sheet since there's no equivalent screen
  /// for that side yet and it doesn't need one — just names and avatars.
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

  /// Inserts an emoji glyph into the composer at the cursor — reuses the
  /// same picker sheet the reaction bar's "+" already opens, just applied to
  /// the text field instead of toggling a reaction.
  Future<void> _pickEmojiForComposer() async {
    final emoji = await showReactionPickerSheet(context);
    if (emoji == null || !mounted) return;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
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
          Expanded(
            child: BlocBuilder<MessageThreadBloc, ThreadState>(
              builder: (context, state) {
                final Widget child;
                if (state.isLoadingInitial) {
                  child = const Center(
                    key: ValueKey('loading'),
                    child: CircularProgressIndicator(),
                  );
                } else if (state.messages.isEmpty) {
                  child = Center(
                    key: const ValueKey('empty'),
                    child: Text(
                      'No messages yet — say hi!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  );
                } else {
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

                        if (message.type == MessageType.system ||
                            message.type == MessageType.guildMemberJoin ||
                            message.type == MessageType.guildMemberLeave) {
                          return _SystemMessageRow(message: message);
                        }

                        final isMe = message.authorId == widget.myUserId;
                        final failed = state.failedSendIds.contains(message.id);
                        // Reversed list: the visually-previous message (same
                        // author check, for Discord-style grouping) is the
                        // *next* index, not the previous one.
                        final previous = index + 1 < state.messages.length
                            ? state.messages[index + 1]
                            : null;
                        final showHeader =
                            previous == null ||
                            previous.authorId != message.authorId ||
                            (message.createdAt != null &&
                                previous.createdAt != null &&
                                message.createdAt!
                                        .difference(previous.createdAt!)
                                        .abs() >
                                    const Duration(minutes: 7));
                        return _MessageBubble(
                          message: message,
                          showHeader: showHeader,
                          isMe: isMe,
                          failed: failed,
                          myUserId: widget.myUserId,
                          isEditing: _editingMessageId == message.id,
                          editController: _editController,
                          onSaveEdit: () => _saveEdit(message.id),
                          onCancelEdit: _cancelEdit,
                          replyToWidget: message.inReplyTo != null
                              ? _ReplyQuoteRow(
                                  replyTo: _resolveReply(message.inReplyTo!),
                                )
                              : null,
                          resolveMentionName: _resolveMentionName,
                          guildId: widget.guildId,
                          onReactionToggle: (emoji) =>
                              context.read<MessageThreadBloc>().add(
                                ReactionToggled(
                                  messageId: message.id,
                                  emoji: emoji,
                                ),
                              ),
                          onAddReaction: () async {
                            final emoji = await showReactionPickerSheet(
                              context,
                            );
                            if (emoji == null || !context.mounted) return;
                            context.read<MessageThreadBloc>().add(
                              ReactionToggled(
                                messageId: message.id,
                                emoji: emoji,
                              ),
                            );
                          },
                          onLongPress: () => _showMessageActions(message),
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
          ),
          BlocBuilder<MessageThreadBloc, ThreadState>(
            buildWhen: (previous, current) =>
                previous.typingUserIds != current.typingUserIds,
            builder: (context, state) {
              if (state.typingUserIds.isEmpty)
                return const SizedBox(height: 20);
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
              onSelect: (entry) => _selectMention(entry.name),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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

/// One row offered by the `@`-trigger autocomplete — either a real user
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

/// Extracted from the composer's final text at submit time — see
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

/// The `@`-trigger autocomplete dropdown — same overlay treatment as
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
            },
            title: Text(entry.name),
            onTap: () => onSelect(entry),
          );
        },
      ),
    );
  }
}

/// The `/`-trigger autocomplete dropdown — merges local and bot commands
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

/// One thumbnail/chip in the composer's pending-attachment strip — shows an
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
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
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

/// Discord-style row: avatar + author name (bold, a step above body size)
/// shown once per consecutive run of same-author messages — [showHeader]
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
    this.editController,
    this.onSaveEdit,
    this.onCancelEdit,
    this.replyToWidget,
  });

  final MessageDto message;
  final bool showHeader;
  final bool isMe;
  final bool failed;
  final String myUserId;
  final ValueChanged<String> onReactionToggle;
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
  /// column — grouped messages indent by this same amount so the text
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
        if (replyToWidget != null) replyToWidget!,
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
              if (message.createdAt != null) ...[
                const SizedBox(width: 6),
                Text(
                  _formatMessageTime(message.createdAt!),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
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

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push(RoutePaths.userProfilePath(message.authorId)),
      onLongPress: message.isPending || message.isBotCommandPlaceholder
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
    );
  }
}

/// Just the GIF/text/attachment body of a message — split out so
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
    if (message.type == MessageType.invite) {
      final match = _inviteUrlRe.firstMatch(text);
      final code = match?.group(1) ?? text.trim();
      if (code.isNotEmpty) return _InviteMessageCard(code: code);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        else if (text.isNotEmpty)
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
                data: text,
                softLineBreak: true,
                shrinkWrap: true,
                extensionSet: md.ExtensionSet(
                  md.ExtensionSet.gitHubWeb.blockSyntaxes,
                  [
                    _MentionSyntax(
                      userNames: userNames,
                      roleNames: roleNames,
                      channelNames: channelNames,
                      everyone: message.mentionsEveryone,
                      here: message.mentionsHere,
                    ),
                    ...md.ExtensionSet.gitHubWeb.inlineSyntaxes,
                  ],
                ),
                builders: {
                  'mention': _MentionElementBuilder(
                    theme: theme,
                    guildId: guildId,
                    roleColors: roleColors,
                  ),
                },
                styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                  p: theme.textTheme.bodyMedium,
                  blockSpacing: 4,
                  codeblockDecoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadii.chip),
                  ),
                ),
                onTapLink: (text, href, title) {
                  if (href == null) return;
                  launchUrl(
                    Uri.parse(href),
                    mode: LaunchMode.externalApplication,
                  );
                },
              );
            },
          ),
        MessageAttachmentsView(attachments: message.attachments),
      ],
    );
  }
}

/// Matches `@user`, `@role`, `@everyone`/`@here`, and `#channel` — but only
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
  }) : super(
         _buildPattern(userNames, roleNames, channelNames, everyone, here),
       );

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
/// message is being edited — Enter saves, Shift+Enter inserts a newline,
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
/// header of the replying message — matches desktop's reply-reference row
/// (author name + snippet). Shows an italic placeholder while the
/// referenced message is still being resolved or if it's gone.
class _ReplyQuoteRow extends StatelessWidget {
  const _ReplyQuoteRow({required this.replyTo});

  final MessageDto? replyTo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
    );
    final target = replyTo;
    return Padding(
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
    );
  }
}

/// Centered flavor-text row for join/leave/generic system events — no
/// avatar, no reactions, no long-press actions, matching desktop's
/// visually-distinct `SystemMessageComponent`.
class _SystemMessageRow extends StatelessWidget {
  const _SystemMessageRow({required this.message});

  final MessageDto message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
      fontStyle: FontStyle.italic,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Center(
        child: message.type == MessageType.system
            ? Text(
                MessageContentCodec.decode(message.content),
                style: style,
                textAlign: TextAlign.center,
              )
            : ProfileResolver(
                userId: message.authorId,
                builder: (context, profile) {
                  final variants = message.type == MessageType.guildMemberLeave
                      ? _leaveVariants
                      : _joinVariants;
                  final index = message.systemMessageVariant ?? 0;
                  final template =
                      index >= 0 && index < variants.length
                      ? variants[index]
                      : variants[0];
                  final name = profile?.userName ?? '…';
                  return Text(
                    template.replaceAll('%USER%', name),
                    style: style,
                    textAlign: TextAlign.center,
                  );
                },
              ),
      ),
    );
  }
}

/// Compact inline card for an invite-type message — reuses the existing
/// [InviteDialog] for preview/join instead of duplicating that flow here.
class _InviteMessageCard extends StatelessWidget {
  const _InviteMessageCard({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.card),
        onTap: () =>
            showDialog(context: context, builder: (_) => InviteDialog(code: code)),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.s,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.chip),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.groups_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              const Text('Server Invite — tap to view'),
            ],
          ),
        ),
      ),
    );
  }
}
