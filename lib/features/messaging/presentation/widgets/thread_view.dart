import 'dart:async';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/profile_resolver.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../core/di/injector.dart';
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
import 'reaction_bar.dart';
import 'reaction_picker_sheet.dart';

const _imageExtensions = {'png', 'jpg', 'jpeg', 'gif', 'webp', 'heic', 'bmp'};

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
  });

  final String title;
  final String myUserId;
  final List<Widget>? actions;

  /// Set only for guild channels — gates bot-command discovery/autocomplete,
  /// since bots (and therefore slash commands) only exist inside guilds.
  final String? guildId;

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

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _loadBotCommands();
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  void _onTextChanged() {
    final match = RegExp(r'^/(\w*)$').firstMatch(_textController.text);
    final query = match?.group(1);
    if (query != _commandQuery) setState(() => _commandQuery = query);
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
    context.read<MessageThreadBloc>().add(
      ThreadMessageSubmitted(text, attachments: attachments),
    );
    _textController.clear();
    setState(_pendingAttachments.clear);
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

  Future<void> _pickGif() async {
    final url = await showGifPickerSheet(context);
    if (url == null || !mounted) return;
    context.read<MessageThreadBloc>().add(ThreadMessageSubmitted(url));
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
      appBar: AppBar(title: Text(widget.title), actions: widget.actions),
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
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            onChanged: (_) => context
                                .read<MessageThreadBloc>()
                                .add(const ThreadTypingNotified()),
                            onSubmitted: (_) => _submit(),
                            decoration: const InputDecoration.collapsed(
                              hintText: 'Message',
                            ),
                          ),
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
  });

  final MessageDto message;
  final bool showHeader;
  final bool isMe;
  final bool failed;
  final String myUserId;
  final ValueChanged<String> onReactionToggle;
  final VoidCallback onAddReaction;

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
        _MessageBody(
          message: message,
          text: text,
          isGifMessage: isGifMessage,
          theme: theme,
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
          : onAddReaction,
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
  });

  final MessageDto message;
  final String text;
  final bool isGifMessage;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
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
          Text(text, style: theme.textTheme.bodyMedium),
        MessageAttachmentsView(attachments: message.attachments),
      ],
    );
  }
}
