import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/profile_resolver.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../bloc/message_thread_bloc.dart';
import '../../data/message_content_codec.dart';
import '../../data/models/message_dto.dart';

/// The message list + composer, shared by DM conversations and guild
/// channels alike — this is the concrete payoff of parameterizing
/// `MessageThreadBloc`/`MessageRepository` by conversation-or-channel id
/// instead of writing two near-identical screens.
class ThreadView extends StatefulWidget {
  const ThreadView({super.key, required this.title, required this.myUserId, this.actions});

  final String title;
  final String myUserId;
  final List<Widget>? actions;

  @override
  State<ThreadView> createState() => _ThreadViewState();
}

class _ThreadViewState extends State<ThreadView> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _textController.text;
    if (text.trim().isEmpty) return;
    context.read<MessageThreadBloc>().add(ThreadMessageSubmitted(text));
    _textController.clear();
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
                if (state.isLoadingInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet — say hi!',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                    ),
                  );
                }
                return NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 200) {
                      context.read<MessageThreadBloc>().add(const ThreadLoadMoreRequested());
                    }
                    return false;
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      final isMe = message.authorId == widget.myUserId;
                      final failed = state.failedSendIds.contains(message.id);
                      return _MessageBubble(message: message, isMe: isMe, failed: failed);
                    },
                  ),
                );
              },
            ),
          ),
          BlocBuilder<MessageThreadBloc, ThreadState>(
            buildWhen: (previous, current) => previous.typingUserIds != current.typingUserIds,
            builder: (context, state) {
              if (state.typingUserIds.isEmpty) return const SizedBox(height: 20);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    state.typingUserIds.length == 1 ? 'Typing…' : 'Several people are typing…',
                    style: theme.textTheme.labelSmall,
                  ),
                ),
              );
            },
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.send,
                      onChanged: (_) =>
                          context.read<MessageThreadBloc>().add(const ThreadTypingNotified()),
                      onSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(hintText: 'Message'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  IconButton.filled(
                    onPressed: _submit,
                    icon: const Icon(Icons.send_rounded),
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

/// Discord-style row: avatar on the left, author name (bold, a step above
/// body size) above the message text on the right — plain text, no bubble.
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMe, required this.failed});

  final MessageDto message;
  final bool isMe;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = MessageContentCodec.decode(message.content);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push(RoutePaths.userProfilePath(message.authorId)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(userId: message.authorId, radius: AppRadii.avatarMedium),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileResolver(
                    userId: message.authorId,
                    builder: (context, profile) => Text(
                      profile?.userName ?? '…',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(text, style: theme.textTheme.bodyMedium),
                  if (message.isPending || failed)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        failed ? 'Failed to send' : 'Sending…',
                        style: theme.textTheme.labelSmall,
                      ),
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
