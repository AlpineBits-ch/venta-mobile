import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The directory this app's *other* binaries can also read.
///
/// On iOS the notification service extension that decrypts push notifications is
/// a separate process with its own sandbox: it cannot see the app's Application
/// Support directory at all. The App Group container is the only place both can
/// reach, so that is where MLS state has to live for background decryption to be
/// possible.
///
/// On Android there is nothing to solve - the FCM background isolate runs inside
/// the app's own process and sees the same file system - so [directory] resolves
/// to null and callers fall back to their normal location.
class SharedContainer {
  const SharedContainer._();

  static const _channel = MethodChannel('venta/shared_container');

  /// Cached as a future so two concurrent lookups resolve to the same answer
  /// rather than the second seeing a half-set flag and reporting no container.
  static Future<Directory?>? _lookup;

  /// Null when this platform has (and needs) no shared container, and also when
  /// the App Group is not configured on the build - an app signed without the
  /// entitlement must keep working, it just cannot decrypt in the extension.
  ///
  /// The method channel is answered by `AppDelegate`, so this only works from an
  /// isolate with the app's plugin registrar. That is the only isolate that asks:
  /// iOS decrypts notifications in the extension, not in a Dart background
  /// isolate.
  static Future<Directory?> directory() => _lookup ??= _resolve();

  static Future<Directory?> _resolve() async {
    if (!Platform.isIOS) return null;

    try {
      final path = await _channel.invokeMethod<String>('containerPath');
      if (path == null || path.isEmpty) return null;
      final dir = Directory(path);
      if (!await dir.exists()) await dir.create(recursive: true);
      return dir;
    } catch (e) {
      debugPrint('SharedContainer: no app group container available: $e');
      return null;
    }
  }

  @visibleForTesting
  static void resetForTest() => _lookup = null;
}
