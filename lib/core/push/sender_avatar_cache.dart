import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Downloads a sender's avatar to a file the notification APIs can point at.
///
/// Both platforms want a *path*, not bytes and not a URL: Android's
/// `BitmapFilePathAndroidIcon`/`FilePathAndroidBitmap` and iOS's
/// `UNNotificationAttachment` each take one. `cached_network_image`, which the
/// rest of the app uses, is no help here - it is a widget-layer cache and this
/// runs in a background isolate with no widget tree.
///
/// Every failure returns null and the notification simply goes out without a
/// picture. A missing avatar is not worth delaying, let alone dropping, a
/// message notification.
class SenderAvatarCache {
  const SenderAvatarCache._();

  /// Long enough that a conversation's worth of notifications reuses one
  /// download, short enough that changing your picture shows up the same day.
  static const _maxAge = Duration(hours: 12);

  /// Avatars are small; anything this size is not one, and decoding it in a
  /// background isolate with a tight memory budget is how the notification gets
  /// killed instead of shown.
  static const _maxBytes = 2 * 1024 * 1024;

  static const _timeout = Duration(seconds: 6);

  /// Null when [url] is null, unreachable, or does not look like an image.
  ///
  /// The backend hands out an avatar URL for every profile whether or not one
  /// was ever uploaded - it 404s for anyone without a picture - so "no image"
  /// arrives here as a failed fetch rather than a null URL, and is handled the
  /// same way.
  static Future<String?> fetch(String? url) async {
    if (url == null || url.isEmpty) return null;

    try {
      final file = await _fileFor(url);

      if (await file.exists()) {
        final age = DateTime.now().difference(await file.lastModified());
        if (age < _maxAge && await file.length() > 0) return file.path;
      }

      final client = HttpClient()..connectionTimeout = _timeout;
      try {
        final request = await client.getUrl(Uri.parse(url)).timeout(_timeout);
        final response = await request.close().timeout(_timeout);
        if (response.statusCode != HttpStatus.ok) return null;
        if (response.contentLength > _maxBytes) return null;

        final bytes = await consolidateHttpClientResponseBytes(
          response,
        ).timeout(_timeout);
        if (bytes.isEmpty || bytes.length > _maxBytes) return null;

        // Written through a temp file: the notification service extension and
        // the app can both be fetching the same avatar, and a half-written file
        // handed to the platform is a broken image rather than none.
        final tmp = File('${file.path}.tmp');
        await tmp.writeAsBytes(bytes, flush: true);
        await tmp.rename(file.path);
        return file.path;
      } finally {
        client.close(force: true);
      }
    } catch (e) {
      debugPrint('SenderAvatarCache: could not fetch $url: $e');
      return null;
    }
  }

  static Future<File> _fileFor(String url) async {
    final root = Directory(
      '${(await getTemporaryDirectory()).path}/venta_avatars',
    );
    if (!await root.exists()) await root.create(recursive: true);
    // The URL is per-profile and stable, so its hash is a stable file name. No
    // extension: both platforms sniff the content rather than trusting one.
    return File('${root.path}/${url.hashCode.toUnsigned(32)}');
  }
}
