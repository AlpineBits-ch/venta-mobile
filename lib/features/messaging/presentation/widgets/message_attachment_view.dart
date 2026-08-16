import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/network/authed_image_headers.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../data/attachment_download_service.dart';
import '../../data/message_api.dart';
import '../../data/models/attachment_dto.dart';
import 'audio_attachment_player.dart';

/// Message-embedded attachments never carry a `url` (only optionally a
/// `thumbnailUrl` for images) - the full-file/download link must be built
/// client-side from the id. Standalone attachments (fresh off the upload
/// poll) already have both populated directly by the server.
///
/// Public because [AudioAttachmentPlayer] fetches the bytes itself and must
/// resolve the same address this file's other views do - one resolver, so an
/// embedded attachment's missing `url` is handled in exactly one place.
String resolveAttachmentDownloadUrl(AttachmentDto attachment) =>
    attachment.url ?? getIt<MessageApi>().downloadUrl(attachment.id);

/// A displayable thumbnail URL for [attachment], or null when it isn't an
/// image. Public because forum post cards preview the first message's image
/// and must resolve it exactly the way the message list does - the fallback
/// chain matters (embedded attachments carry no `url`).
String? resolveAttachmentThumbnailUrl(AttachmentDto attachment) {
  if (attachment.thumbnailUrl != null) return attachment.thumbnailUrl;
  if (attachment.url != null) return attachment.url;
  if (attachment.isImage) {
    return getIt<MessageApi>().thumbnailUrl(attachment.id);
  }
  return null;
}

String? _resolveThumbnail(AttachmentDto attachment) =>
    resolveAttachmentThumbnailUrl(attachment);

/// Downloads [attachment] through the authenticated client and saves it where
/// the user chooses, reporting the outcome the way the rest of this feature
/// does.
///
/// **This replaced `launchUrl`, it does not sit beside it.** Every view here
/// used to hand the raw attachment URL to the OS browser and call that a
/// download. The route is `[Authorize]`d and answers `404` - not `401` - to an
/// anonymous caller, so that affordance has not downloaded anything since the
/// guard moved to the controller class; it produces a browser tab showing an
/// error, or nothing at all. There is no version of "open externally" that
/// works for an attachment, because nothing outside `ApiClient` can put a
/// bearer on the request, so keeping the control around under honester wording
/// would only be a button that still fails. (Ordinary links in message text are
/// a different thing entirely and still open externally - see
/// `MessageLinkLauncher`.)
///
/// Public because the audio player shows the same control in its own header
/// row, and one save path means one set of wording and one set of failure
/// behaviour. The in-flight latch is *not* here: it belongs to whichever
/// control is being disabled, and [AttachmentSaveButton] is the usual one.
Future<void> saveAttachment(
  BuildContext context,
  AttachmentDto attachment,
) async {
  // Resolved before the first await, not after. `ScaffoldMessenger.of` walks up
  // from this element, and a message row is destroyed and rebuilt constantly by
  // the list it lives in - a download outliving its row would otherwise be
  // reporting through a deactivated context. The messenger itself lives above
  // the route and survives all of that.
  final messenger = ScaffoldMessenger.of(context);
  try {
    final result = await getIt<AttachmentDownloadService>().save(
      url: resolveAttachmentDownloadUrl(attachment),
      fileName: attachment.fileName,
    );
    // Nothing at all is said about a dismissed dialog. The user cancelled; they
    // know they cancelled, and a "cancelled" toast is a notification that the
    // app did what it was told.
    if (result == AttachmentSaveResult.cancelled) return;
    messenger.showSnackBar(
      SnackBar(content: Text('Saved ${attachment.fileName}.')),
    );
  } catch (e) {
    // Reported rather than swallowed, and with whatever reason the failure
    // actually carries - the same choice `AudioAttachmentPlayer` makes, because
    // a bare "couldn't download" on a route that answers 404 for both "deleted"
    // and "not signed in" is untraceable.
    messenger.showSnackBar(
      SnackBar(
        content: Text("Couldn't download that file (${_failureDetail(e)})."),
      ),
    );
  }
}

/// As much of a reason as the failure actually carries: a status code when the
/// download was refused, the exception's type otherwise. Mirrors
/// `_AudioAttachmentPlayerState._detail`.
String _failureDetail(Object error) {
  if (error is DioException) {
    final status = error.response?.statusCode;
    return status != null ? 'HTTP $status' : error.type.name;
  }
  if (error is TimeoutException) return 'timed out';
  if (error is FileSystemException) return 'storage';
  return error.runtimeType.toString();
}

/// A download control that latches while its save is in flight.
///
/// The latch is the point, and it is the same one Alpine's message component
/// holds as `downloading()`: the save dialog is modal to the window but not to
/// the handler that opened it, so a second press behind it opens a second
/// dialog over the first - and on mobile it also starts a second download of a
/// file already coming down. Disabled *and* visibly spinning, because a control
/// that only goes dead reads as broken during the seconds a large attachment
/// takes.
///
/// Public because the audio player's header row uses it too.
class AttachmentSaveButton extends StatefulWidget {
  const AttachmentSaveButton({
    super.key,
    required this.attachment,
    this.iconSize = 20,
    this.compact = false,
  });

  final AttachmentDto attachment;
  final double iconSize;

  /// Squeezes the button into a message-row header rather than an app bar.
  final bool compact;

  @override
  State<AttachmentSaveButton> createState() => _AttachmentSaveButtonState();
}

class _AttachmentSaveButtonState extends State<AttachmentSaveButton> {
  bool _saving = false;

  Future<void> _run() async {
    setState(() => _saving = true);
    try {
      await saveAttachment(context, widget.attachment);
    } finally {
      // The widget can be gone by now - the download outlives a row scrolled
      // out of the list - and setting state on a dead element is a crash, not a
      // no-op. Nothing is lost by skipping it: the latch dies with the widget.
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      // Null rather than a guard inside the handler, so the control is visibly
      // disabled and not merely inert when pressed.
      onPressed: _saving ? null : _run,
      visualDensity: widget.compact ? VisualDensity.compact : null,
      tooltip: 'Download',
      icon: _saving
          ? SizedBox.square(
              dimension: widget.iconSize,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                // The ambient icon colour, not the indicator's default of
                // `colorScheme.primary`: this button also sits in the viewer's
                // black app bar, where the surrounding icons are white and a
                // primary-coloured spinner would be the one thing that isn't.
                color: IconTheme.of(context).color,
              ),
            )
          : Icon(Icons.download_rounded, size: widget.iconSize),
    );
  }
}

/// Renders one message's attachments: images as tappable thumbnails (opens
/// a full-screen viewer), audio as an inline player, everything else as a
/// file chip that downloads and saves on tap. Matches desktop's
/// image-preview + audio-player + file-chip split.
class MessageAttachmentsView extends StatelessWidget {
  const MessageAttachmentsView({super.key, required this.attachments});

  final List<AttachmentDto> attachments;

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      // The players want the row's width, and a `Wrap` hands its children an
      // unbounded one - so the width is measured here and given to them
      // explicitly, rather than moving audio out into a second run and
      // reordering an attachment list the server ordered on purpose.
      child: LayoutBuilder(
        builder: (context, constraints) => Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final attachment in attachments)
              if (attachment.isImage)
                _ImageAttachment(attachment: attachment)
              else if (attachment.contentType.startsWith('audio/'))
                SizedBox(
                  // `min` and not the row width alone: an unbounded parent
                  // would hand a player an infinite one, and the cap is the
                  // only width that is always a number.
                  width: math.min(constraints.maxWidth, audioPlayerMaxWidth),
                  child: AudioAttachmentPlayer(
                    attachment: attachment,
                    url: resolveAttachmentDownloadUrl(attachment),
                  ),
                )
              else
                _FileAttachment(attachment: attachment),
          ],
        ),
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
            // The attachment routes are authorized and answer 404 - not 401 -
            // when they refuse, so without these an ordinary thumbnail is
            // indistinguishable from a deleted one.
            httpHeaders: authedImageHeaders(),
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
    final url = resolveAttachmentDownloadUrl(attachment);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(attachment.fileName, overflow: TextOverflow.ellipsis),
        actions: [
          // Was "open in browser", which handed the bare URL to the OS
          // browser and got a 404 back - see [saveAttachment]. The bar's
          // `foregroundColor` reaches the spinner as well as the icon, because
          // the button reads its colour off the ambient icon theme.
          AttachmentSaveButton(attachment: attachment, iconSize: 24),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          child: CachedNetworkImage(
            imageUrl: url,
            httpHeaders: authedImageHeaders(),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

/// A non-image, non-audio attachment: tap to download and save.
///
/// Stateful only for the in-flight latch. The chip is one tap target rather
/// than a label beside a button, so the latch has to live on the chip itself -
/// [AttachmentSaveButton] is the same behaviour where the control is an icon.
class _FileAttachment extends StatefulWidget {
  const _FileAttachment({required this.attachment});

  final AttachmentDto attachment;

  @override
  State<_FileAttachment> createState() => _FileAttachmentState();
}

class _FileAttachmentState extends State<_FileAttachment> {
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await saveAttachment(context, widget.attachment);
    } finally {
      // A row can be scrolled out of the list and disposed while its download
      // is still running; the latch dies with it, and setting state on a dead
      // element would be a crash rather than a no-op.
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final attachment = widget.attachment;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.chip),
      // Null while a save is in flight: the trailing spinner says a download is
      // running, and a second tap behind the save dialog would open a second
      // dialog over the first.
      onTap: _saving ? null : _save,
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
            // Same box either way, so the chip doesn't resize mid-download and
            // shove the rest of the `Wrap` around.
            SizedBox.square(
              dimension: 16,
              child: _saving
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : const Icon(Icons.download_rounded, size: 16),
            ),
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
