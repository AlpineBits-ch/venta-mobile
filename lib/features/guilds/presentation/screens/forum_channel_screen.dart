import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../data/guild_repository.dart';
import '../../data/models/channel_dto.dart';

/// A Forum channel's post list - each "post" is a `Thread`-typed channel
/// parented to this Forum, created via [GuildRepository.createThread].
/// Opening a post just opens it as a normal channel (`ChannelScreen`), same
/// as any other thread - a forum post has no message list UI of its own.
class ForumChannelScreen extends StatefulWidget {
  const ForumChannelScreen({
    super.key,
    required this.guildId,
    required this.channelId,
  });

  final String guildId;
  final String channelId;

  @override
  State<ForumChannelScreen> createState() => _ForumChannelScreenState();
}

class _ForumChannelScreenState extends State<ForumChannelScreen> {
  List<ChannelDto>? _posts;
  bool _loading = true;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final posts = await getIt<GuildRepository>().getThreads(
        widget.channelId,
      );
      if (mounted) {
        setState(() {
          _posts = posts;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _title() {
    final channel = getIt<GuildRepository>()
        .cachedById(widget.guildId)
        ?.channels
        .where((c) => c.id == widget.channelId)
        .firstOrNull;
    return channel?.name ?? 'Forum';
  }

  Future<void> _createPost() async {
    final input = await showDialog<_NewPostInput>(
      context: context,
      builder: (context) => const _CreatePostDialog(),
    );
    if (input == null || input.name.trim().isEmpty || !mounted) return;
    setState(() => _creating = true);
    try {
      final thread = await getIt<GuildRepository>().createThread(
        widget.channelId,
        name: input.name.trim(),
        content: input.content.trim().isEmpty ? null : input.content.trim(),
      );
      await _load();
      if (mounted) {
        context.push(RoutePaths.serverChannelPath(widget.guildId, thread.id));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not create post.')));
      }
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final posts = _posts;
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(
          fallbackLocation: RoutePaths.serverPath(widget.guildId),
        ),
        title: Text(_title()),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : posts == null || posts.isEmpty
          ? Center(
              child: Text(
                'No posts yet - be the first!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
                itemCount: posts.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return ListTile(
                    leading: const Icon(Icons.forum_outlined),
                    title: Text(post.name),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(
                      RoutePaths.serverChannelPath(widget.guildId, post.id),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _creating ? null : _createPost,
        tooltip: 'New post',
        child: _creating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add),
      ),
    );
  }
}

class _NewPostInput {
  const _NewPostInput({required this.name, this.content = ''});
  final String name;
  final String content;
}

class _CreatePostDialog extends StatefulWidget {
  const _CreatePostDialog();

  @override
  State<_CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<_CreatePostDialog> {
  final _nameController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New post'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: AppSpacing.s),
          TextField(
            controller: _contentController,
            minLines: 2,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Message (optional)'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            _NewPostInput(
              name: _nameController.text,
              content: _contentController.text,
            ),
          ),
          child: const Text('Post'),
        ),
      ],
    );
  }
}
