import 'package:flutter/material.dart';

import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/profile_resolver.dart';
import '../../data/message_content_codec.dart';
import '../../data/message_repository.dart';
import '../../data/models/message_dto.dart';

/// Full-text search within the current conversation/channel - mirrors
/// desktop's `searchMessagesForConversation`/`searchMessagesForChannel`.
/// Results are read-only (author + decoded snippet + timestamp); jumping
/// the live thread view to the exact message isn't wired up yet since
/// `ThreadView` has no scroll-to-index infra (same limitation as the
/// reply-quote row, which is tap-inert for the same reason).
class MessageSearchScreen extends StatefulWidget {
  const MessageSearchScreen({
    super.key,
    required this.repository,
    this.isEncrypted = false,
  });

  final MessageRepository repository;

  /// True for an MLS-encrypted DM - the server can't read ciphertext, so
  /// nothing is indexed there. Skips the network round-trip entirely and
  /// shows an explicit "not available" state instead of an empty-results one.
  final bool isEncrypted;

  @override
  State<MessageSearchScreen> createState() => _MessageSearchScreenState();
}

class _MessageSearchScreenState extends State<MessageSearchScreen> {
  final _controller = TextEditingController();
  List<MessageDto> _results = const [];
  bool _loading = false;
  bool _searched = false;
  String? _error;
  String _lastQuery = '';

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
          _lastQuery = trimmed;
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
          autofocus: !widget.isEncrypted,
          enabled: !widget.isEncrypted,
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
            onPressed: widget.isEncrypted
                ? null
                : () => _search(_controller.text),
          ),
        ],
      ),
      body: widget.isEncrypted
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 32,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      "Search isn't available in encrypted conversations",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : _loading
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
                  subtitle: Text.rich(
                    TextSpan(
                      children: _highlightedSpans(
                        text.isEmpty ? '(attachment)' : text,
                        _lastQuery,
                        theme.textTheme.bodySmall,
                        theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          backgroundColor: theme.colorScheme.primary
                              .withValues(alpha: 0.12),
                        ),
                      ),
                    ),
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

/// Client-side highlight of [query]'s terms within [text] - the search API
/// doesn't return match offsets or a pre-highlighted snippet, just the full
/// `content`, so this does a simple case-insensitive literal-term match.
/// Strips `websearch_to_tsquery` syntax (quotes, leading `-`) down to bare
/// words rather than trying to fully replicate Postgres' query parsing.
List<TextSpan> _highlightedSpans(
  String text,
  String query,
  TextStyle? baseStyle,
  TextStyle? highlightStyle,
) {
  final terms = query
      .replaceAll('"', ' ')
      .split(RegExp(r'\s+'))
      .where((t) => t.isNotEmpty && t != '-' && t.toLowerCase() != 'or')
      .map((t) => t.startsWith('-') ? t.substring(1) : t)
      .where((t) => t.isNotEmpty)
      .map(RegExp.escape)
      .toSet()
      .toList();
  if (terms.isEmpty) return [TextSpan(text: text, style: baseStyle)];

  final pattern = RegExp('(${terms.join('|')})', caseSensitive: false);
  final spans = <TextSpan>[];
  var cursor = 0;
  for (final match in pattern.allMatches(text)) {
    if (match.start > cursor) {
      spans.add(TextSpan(text: text.substring(cursor, match.start), style: baseStyle));
    }
    spans.add(
      TextSpan(text: text.substring(match.start, match.end), style: highlightStyle),
    );
    cursor = match.end;
  }
  if (cursor < text.length) {
    spans.add(TextSpan(text: text.substring(cursor), style: baseStyle));
  }
  return spans;
}
