import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../data/message_api.dart';
import '../../data/models/attachment_dto.dart';

/// Message-embedded attachments never carry a `url` (only optionally a
/// `thumbnailUrl` for images) - the full-file/download link must be built
/// client-side from the id. Standalone attachments (fresh off the upload
/// poll) already have both populated directly by the server.
String _resolveUrl(AttachmentDto attachment) =>
    attachment.url ?? getIt<MessageApi>().downloadUrl(attachment.id);

String? _resolveThumbnail(AttachmentDto attachment) {
  if (attachment.thumbnailUrl != null) return attachment.thumbnailUrl;
  if (attachment.url != null) return attachment.url;
  if (attachment.isImage)
    return getIt<MessageApi>().thumbnailUrl(attachment.id);
  return null;
}

/// Renders one message's attachments: images as tappable thumbnails (opens
/// a full-screen viewer), everything else as a file chip that opens
/// externally on tap. Matches desktop's image-preview + file-chip split.
class MessageAttachmentsView extends StatelessWidget {
  const MessageAttachmentsView({super.key, required this.attachments});

  final List<AttachmentDto> attachments;

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          for (final attachment in attachments)
            attachment.isImage
                ? _ImageAttachment(attachment: attachment)
                : _FileAttachment(attachment: attachment),
        ],
      ),
    );
  }
}

class _ImageAttachment extends StatelessWidget {
  const _ImageAttachment({required this.attachment});

  final AttachmentDto attachment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final previewUrl = _resolveThumbnail(attachment);
    if (previewUrl == null) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _ImageViewerScreen(attachment: attachment),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.chip),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 240, maxWidth: 280),
          child: CachedNetworkImage(
            imageUrl: previewUrl,
            fit: BoxFit.contain,
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
      ),
    );
  }
}

class _ImageViewerScreen extends StatelessWidget {
  const _ImageViewerScreen({required this.attachment});

  final AttachmentDto attachment;

  @override
  Widget build(BuildContext context) {
    final url = _resolveUrl(attachment);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(attachment.fileName, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () =>
                launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class _FileAttachment extends StatelessWidget {
  const _FileAttachment({required this.attachment});

  final AttachmentDto attachment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = _resolveUrl(attachment);
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.chip),
      onTap: () =>
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadii.chip),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_iconFor(attachment.contentType), size: 20),
            const SizedBox(width: AppSpacing.xs),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: Text(
                attachment.fileName,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(Icons.download_rounded, size: 16),
          ],
        ),
      ),
    );
  }

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
