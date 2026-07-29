import 'package:flutter/material.dart';

import '../../../../core/widgets/profile_resolver.dart';
import '../../data/message_content_codec.dart';
import '../../data/message_repository.dart';
import '../../data/models/message_dto.dart';

/// Full-text search within the current conversation/channel — mirrors
/// desktop's `searchMessagesForConversation`/`searchMessagesForChannel`.
/// Results are read-only (author + decoded snippet + timestamp); jumping
/// the live thread view to the exact message isn't wired up yet since
/// `ThreadView` has no scroll-to-index infra (same limitation as the
/// reply-quote row, which is tap-inert for the same reason).
class MessageSearchScreen extends StatefulWidget {
  const MessageSearchScreen({super.key, required this.repository});

  final MessageRepository repository;

  @override
  State<MessageSearchScreen> createState() => _MessageSearchScreenState();
}

class _MessageSearchScreenState extends State<MessageSearchScreen> {
  final _controller = TextEditingController();
  List<MessageDto> _results = const [];
  bool _loading = false;
  bool _searched = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _results = const [];
        _searched = false;
        _error = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await widget.repository.search(trimmed);
      if (mounted) {
        setState(() {
          _results = results;
          _loading = false;
          _searched = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _searched = true;
          _error = 'Search failed.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onSubmitted: _search,
          decoration: const InputDecoration(
            hintText: 'Search messages',
            border: InputBorder.none,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _search(_controller.text),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : !_searched
          ? Center(
              child: Text(
                'Search this conversation',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            )
          : _results.isEmpty
          ? Center(
              child: Text(
                'No results',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            )
          : ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final message = _results[index];
                final text = MessageContentCodec.decode(message.content);
                return ListTile(
                  title: ProfileResolver(
                    userId: message.authorId,
                    builder: (context, profile) =>
                        Text(profile?.userName ?? '…'),
                  ),
                  subtitle: Text(
                    text.isEmpty ? '(attachment)' : text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: message.createdAt != null
                      ? Text(
                          message.createdAt!.toLocal().toString().split(
                            '.',
                          )[0],
                          style: theme.textTheme.labelSmall,
                        )
                      : null,
                );
              },
            ),
    );
  }
}
