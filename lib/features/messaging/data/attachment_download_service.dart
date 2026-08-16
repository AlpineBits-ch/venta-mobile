import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/network/api_client.dart';

/// What a finished save attempt actually did.
///
/// Two values and not a `bool`, because the two non-error outcomes read very
/// differently at the call site: [saved] earns a confirmation, [cancelled] must
/// stay silent - the user dismissed the dialog, they know they did, and telling
/// them so is noise. Failure is not in here at all; it is thrown, so a caller
/// cannot forget to handle it (which is the bug Alpine's
/// `AttachmentDownloadService` also avoids by rejecting rather than returning a
/// third enum member).
enum AttachmentSaveResult {
  /// The user picked a destination and the bytes landed there. On both hosts
  /// this is a fact rather than a hope: the dialog reports its own cancellation
  /// and the write is confirmed before the path comes back.
  saved,

  /// The save dialog was dismissed. Not an error.
  cancelled,
}

/// Saving a chat attachment to a file the user chooses.
///
/// **Why this exists at all.** Mobile used to "download" an attachment by
/// handing its bare URL to the OS browser with `launchUrl`. Messaging's
/// `AttachmentController` carries `[Authorize]` at the *class* level - it was
/// moved there from the upload action alone, because every read route had been
/// reachable with nothing but a leaked id - and its read guard answers **404,
/// not 401**. A browser tab carries no bearer, so that route now answers "no
/// such attachment" to a file that plainly exists, and the user gets an error
/// page or a blank tab with nothing to trace. The bytes have to come down
/// through [ApiClient], whose `AuthInterceptor` is the only thing in this app
/// that stamps the header. See `authedImageHeaders`, which fixes the same trap
/// for `CachedNetworkImage`; this is the download half of it.
///
/// Mirrors Alpine's `AttachmentDownloadService`, including the part that hurts:
/// there, `FileSaver.saveLazy` asks for a destination *before* fetching, so
/// backing out of the dialog costs nothing. Here that ordering is only
/// available on one of the two hosts - see [save].
class AttachmentDownloadService {
  AttachmentDownloadService({required this.client});

  /// The authenticated client. The whole point: its `AuthInterceptor` is what
  /// makes the attachment route answer with the file instead of a 404.
  final ApiClient client;

  /// True where `FilePicker.saveFile` writes the file itself and therefore
  /// demands the bytes up front, false where it hands back a path to write to.
  ///
  /// Read from [Platform] rather than `defaultTargetPlatform` because this is a
  /// statement about the *plugin implementation* running in this process, not
  /// about the design language: the Android and iOS `saveFile` channels take a
  /// `ByteArray`, the desktop ones return a path from a native dialog. Only
  /// `android/` and `ios/` are configured runners in this repo today, so the
  /// false branch is unreachable in a current build - it is written and kept
  /// because it is the branch a desktop target would take on day one, and
  /// because it is the branch that does not buffer.
  static bool get _saverNeedsBytesUpFront =>
      Platform.isAndroid || Platform.isIOS;

  /// Asks where to put the file and puts it there. Returns
  /// [AttachmentSaveResult.cancelled] when the dialog was dismissed; throws
  /// (a [DioException] for a refused download, a `PlatformException` or
  /// [FileSystemException] for a refused write) when it went wrong.
  ///
  /// [url] is passed in already resolved rather than built from an id here.
  /// Message-embedded attachments carry no `url` and standalone ones do, and
  /// `resolveAttachmentDownloadUrl` is the single place that fallback chain
  /// lives - it sits in the presentation layer next to the views that share it,
  /// and a data-layer service reaching back up into presentation to call it
  /// would be the wrong direction for the sake of one string.
  ///
  /// **The ordering differs by host, and it is not a detail.** On desktop the
  /// dialog comes first and the download only runs once there is somewhere to
  /// put it, exactly like Alpine's `saveLazy` - dismissing it costs no
  /// bandwidth. On Android and iOS `FilePicker.saveFile` *is* the write (see
  /// [_saverNeedsBytesUpFront]), so the bytes have to exist before it is
  /// opened, and a dismissed dialog throws away a completed download. That is
  /// forced by the plugin's channel signature, not chosen; Alpine documents the
  /// mirror image of it for web, where the browser has no cancel signal at all.
  Future<AttachmentSaveResult> save({
    required String url,
    required String fileName,
  }) async {
    return _saverNeedsBytesUpFront
        ? _saveByBytes(url: url, fileName: fileName)
        : _saveByPath(url: url, fileName: fileName);
  }

  /// Desktop: pick a path, then stream straight into it.
  ///
  /// Nothing is ever held in memory - `Dio.download` writes chunk by chunk -
  /// and `deleteOnError` (dio's default) removes a half-written file rather
  /// than leaving a truncated one at a name the user chose and will trust.
  Future<AttachmentSaveResult> _saveByPath({
    required String url,
    required String fileName,
  }) async {
    final path = await FilePicker.saveFile(
      dialogTitle: 'Save attachment',
      fileName: fileName,
    );
    if (path == null) return AttachmentSaveResult.cancelled;
    await client.dio.download(url, path);
    return AttachmentSaveResult.saved;
  }

  /// Android/iOS: stage the download on disk, then hand the bytes over.
  ///
  /// **Why a temp file and not `ResponseType.bytes`.** Both end with the whole
  /// file in RAM - the plugin's `saveFile` takes a `Uint8List` over the method
  /// channel and there is no streaming variant, so one full copy is the floor
  /// no matter what we do. But `ResponseType.bytes` is worse than the floor:
  /// dio accumulates every chunk in a `BytesBuilder` and then concatenates them
  /// into one new buffer, so a 200 MB video peaks at roughly *twice* its size
  /// before the transfer is even finished. `Dio.download` writes to disk as it
  /// goes at constant memory, and reading the staged file back gives exactly
  /// one copy, allocated at its final length. On a phone that difference is the
  /// difference between a big download and an OOM kill.
  ///
  /// It is still one copy, and a large enough attachment will still not fit -
  /// that ceiling belongs to `file_picker`, and closing it means a plugin that
  /// can be handed a path instead of a buffer. The staging file is deleted
  /// either way; it lives in the temp directory so that a kill mid-save leaves
  /// the platform holding the cleanup, which it already does.
  Future<AttachmentSaveResult> _saveByBytes({
    required String url,
    required String fileName,
  }) async {
    final staged = await _stagingFile();
    try {
      await client.dio.download(url, staged.path);
      final bytes = await staged.readAsBytes();
      // `bytes:` as well as a name, because on Android and iOS `saveFile`
      // cannot write the file without them - it opens the same dialog, creates
      // the document and returns a path with nothing at it. (`MlsBackupService`
      // learned this the same way.)
      final path = await FilePicker.saveFile(
        dialogTitle: 'Save attachment',
        fileName: fileName,
        bytes: bytes,
      );
      return path == null
          ? AttachmentSaveResult.cancelled
          : AttachmentSaveResult.saved;
    } finally {
      // Best effort, and deliberately swallowed: a leftover byte-for-byte copy
      // in a cache directory the OS evicts is not worth turning a successful
      // save into a failure over.
      try {
        if (await staged.exists()) await staged.delete();
      } catch (_) {}
    }
  }

  /// A private scratch path for one save.
  ///
  /// Named per attempt (`hashCode` plus a timestamp) rather than per
  /// attachment: two saves of the same file can legitimately overlap - the
  /// chip's latch is per-widget and the same attachment can be on screen in a
  /// message and in its own viewer - and two downloads interleaved into one
  /// scratch name would produce a corrupt file under a name the user chose.
  Future<File> _stagingFile() async {
    final root = Directory(
      '${(await getTemporaryDirectory()).path}/venta_downloads',
    );
    if (!await root.exists()) await root.create(recursive: true);
    final stamp = DateTime.now().microsecondsSinceEpoch;
    return File('${root.path}/$hashCode-$stamp.part');
  }
}
