import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/format/date_time_format.dart';
import '../../../../core/network/authed_image_headers.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/load_failure_view.dart';
import '../../../../core/widgets/profile_resolver.dart';
import '../../data/message_content_codec.dart';
import '../../data/message_repository.dart';
import '../../data/models/attachment_dto.dart';
import '../../data/models/message_dto.dart';
import 'message_attachment_view.dart';

/// One attachment whose file name matched, plus the message carrying it -
/// the row needs both (author/timestamp come off the message).
class _AttachmentHit {
  const _AttachmentHit(this.message, this.attachment);

  final MessageDto message;
  final AttachmentDto attachment;
}

/// Full-text search within the current conversation/channel - mirrors
/// desktop's `searchMessagesForConversation`/`searchMessagesForChannel`.
/// Results come back in two groups, as on desktop: messages whose text
/// matched, and attachments whose file name matched.
/// Tapping a result pops this screen and hands the message id back as the
/// route's pop value; `ThreadView._openSearch` is what turns that into a
/// scroll. The screen deliberately knows nothing about the thread it was
/// pushed from - it is reachable from a DM and a guild channel alike, and the
/// only thing both have in common is a message id.
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

  /// Attachments in the fetched result set whose file name matches the query,
  /// flattened one row per attachment - desktop derives its attachment group
  /// the same way, off the same server response rather than a second call.
  ///
  /// Note what that means: the server's tsvector is built from message text
  /// only (`MessageSearchEntry.Content`), so a file name is never *why* a
  /// message came back. This surfaces the attachments of messages that already
  /// matched; it is not a file search. Desktop has the same ceiling.
  List<_AttachmentHit> _attachmentHits() {
    final terms = _queryTerms(_lastQuery).map((t) => t.toLowerCase()).toList();
    if (terms.isEmpty) return const [];
    return [
      for (final message in _results)
        for (final attachment in message.attachments)
          if (terms.any(
            (term) => attachment.fileName.toLowerCase().contains(term),
          ))
            _AttachmentHit(message, attachment),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final attachmentHits = _searched
        ? _attachmentHits()
        : const <_AttachmentHit>[];
    return Scaffold(
      appBar: AppBar(
        // See `AppTheme` - the title here is the search field itself, which
        // wants the full bar rather than the narrower centred title slot.
        centerTitle: false,
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
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
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
          ? const Center(child: CircularProgressIndicator.adaptive())
          : _error != null
          ? LoadFailureView(
              message: _error!,
              onRetry: () => _search(_controller.text),
            )
          : !_searched
          ? Center(
              child: Text(
                'Search this conversation',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            )
          // Both groups are derived from the one response, so "nothing
          // matched" has to consider both before it can be said.
          : _results.isEmpty && attachmentHits.isEmpty
          ? Center(
              child: Text(
                'No results',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    // Eager children rather than a builder: the endpoint caps
                    // at 25 results (50 hard limit), and the two groups need
                    // their own headers interleaved.
                    children: [
                      if (_results.isNotEmpty) ...[
                        const _SectionHeader('Messages'),
                        for (final message in _results)
                          _MessageResultTile(
                            message: message,
                            query: _lastQuery,
                          ),
                      ],
                      if (attachmentHits.isNotEmpty) ...[
                        const _SectionHeader('Attachments'),
                        for (final hit in attachmentHits)
                          _AttachmentResultTile(hit: hit, query: _lastQuery),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.xs,
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class _MessageResultTile extends StatelessWidget {
  const _MessageResultTile({required this.message, required this.query});

  final MessageDto message;
  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = MessageContentCodec.decode(message.content);
    return ListTile(
      onTap: () => Navigator.of(context).pop(message.id),
      title: ProfileResolver(
        userId: message.authorId,
        builder: (context, profile) => Text(profile?.userName ?? '…'),
      ),
      subtitle: Text.rich(
        TextSpan(
          children: _highlightedSpans(
            text.isEmpty ? '(attachment)' : text,
            query,
            theme.textTheme.bodySmall,
            theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              backgroundColor: theme.colorScheme.primary.withValues(
                alpha: 0.12,
              ),
            ),
          ),
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: message.createdAt != null
          ? Text(
              formatRelativeDateTime(message.createdAt!),
              style: theme.textTheme.labelSmall,
            )
          : null,
    );
  }
}

/// One matched attachment: thumbnail (images) or type icon, the highlighted
/// file name, and who posted it - mirroring desktop's attachment rows. Taps
/// through to the message carrying the attachment rather than opening the file
/// itself, which is what the row is a search hit *for*: the query matched a
/// file name, and what the reader wants is the conversation around it.
class _AttachmentResultTile extends StatelessWidget {
  const _AttachmentResultTile({required this.hit, required this.query});

  final _AttachmentHit hit;
  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final attachment = hit.attachment;
    // Message-embedded attachments carry no `url`, so the thumbnail has to go
    // through the shared resolver rather than reading a field.
    final thumbnailUrl = resolveAttachmentThumbnailUrl(attachment);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.5);
    return ListTile(
      onTap: () => Navigator.of(context).pop(hit.message.id),
      leading: SizedBox(
        width: 40,
        height: 40,
        child: thumbnailUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.chip),
                child: CachedNetworkImage(
                  imageUrl: thumbnailUrl,
                  // The attachment route is authorized and answers 404 rather
                  // than 401 when it refuses, so an anonymous fetch is
                  // indistinguishable from a deleted file - it just renders as
                  // a broken thumbnail with nothing to trace.
                  httpHeaders: authedImageHeaders(),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.broken_image_outlined, size: 20),
                  ),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadii.chip),
                ),
                child: Icon(_iconFor(attachment.contentType), size: 20),
              ),
      ),
      title: Text.rich(
        TextSpan(
          children: _highlightedSpans(
            attachment.fileName,
            query,
            theme.textTheme.bodyMedium,
            theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              backgroundColor: theme.colorScheme.primary.withValues(
                alpha: 0.12,
              ),
            ),
          ),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: ProfileResolver(
        userId: hit.message.authorId,
        builder: (context, profile) => Text(
          'from ${profile?.userName ?? '…'}',
          style: theme.textTheme.bodySmall?.copyWith(color: muted),
        ),
      ),
      trailing: hit.message.createdAt != null
          ? Text(
              formatRelativeDateTime(hit.message.createdAt!),
              style: theme.textTheme.labelSmall,
            )
          : null,
    );
  }

  /// Same mapping the message list's file chips use - that one is private to
  /// `message_attachment_view.dart`, and only the thumbnail resolver (where
  /// the fallback chain actually matters) is shared.
  IconData _iconFor(String contentType) {
    if (contentType.startsWith('video/')) return Icons.videocam_outlined;
    if (contentType.startsWith('audio/')) return Icons.audiotrack_outlined;
    if (contentType == 'application/pdf') return Icons.picture_as_pdf_outlined;
    if (contentType.contains('zip') || contentType.contains('compressed')) {
      return Icons.folder_zip_outlined;
    }
    if (contentType.startsWith('text/')) return Icons.description_outlined;
    return Icons.insert_drive_file_outlined;
  }
}

/// The bare words of [query], with `websearch_to_tsquery` syntax (quotes,
/// leading `-`) stripped rather than trying to fully replicate Postgres'
/// query parsing.
///
/// Both the highlighter and the attachment filter run off this, so a file
/// name only lands in the attachment group if the row will visibly show why:
/// matching the raw query string instead would miss `"quoted phrases"` and
/// `-negations` that the highlighter happily marks up.
List<String> _queryTerms(String query) => query
    .replaceAll('"', ' ')
    .split(RegExp(r'\s+'))
    .where((t) => t.isNotEmpty && t != '-' && t.toLowerCase() != 'or')
    .map((t) => t.startsWith('-') ? t.substring(1) : t)
    .where((t) => t.isNotEmpty)
    .toSet()
    .toList();

/// Client-side highlight of [query]'s terms within [text] - the search API
/// doesn't return match offsets or a pre-highlighted snippet, just the full
/// `content`, so this does a simple case-insensitive literal-term match.
List<TextSpan> _highlightedSpans(
  String text,
  String query,
  TextStyle? baseStyle,
  TextStyle? highlightStyle,
) {
  final terms = _queryTerms(query).map(RegExp.escape).toList();
  if (terms.isEmpty) return [TextSpan(text: text, style: baseStyle)];

  final pattern = RegExp('(${terms.join('|')})', caseSensitive: false);
  final spans = <TextSpan>[];
  var cursor = 0;
  for (final match in pattern.allMatches(text)) {
    if (match.start > cursor) {
      spans.add(
        TextSpan(text: text.substring(cursor, match.start), style: baseStyle),
      );
    }
    spans.add(
      TextSpan(
        text: text.substring(match.start, match.end),
        style: highlightStyle,
      ),
    );
    cursor = match.end;
  }
  if (cursor < text.length) {
    spans.add(TextSpan(text: text.substring(cursor), style: baseStyle));
  }
  return spans;
}
