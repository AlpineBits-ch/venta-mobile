import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../storage/shared_container.dart';

/// The two pieces of MLS bookkeeping that are this client's own, not the
/// engine's: which MLS group backs which (context, generation), and the
/// plaintext of messages we have already decrypted once.
///
/// Alpine keeps both in Tauri `LazyStore` JSON files and reads them
/// asynchronously. Here they are loaded once into memory and read synchronously
/// - the maps are small, every caller is already inside an async group
/// operation, and threading a `Future` through the decrypt loop for a map lookup
/// made the call sites considerably harder to follow.
class MlsStore {
  MlsStore({Future<Directory> Function()? directory})
    : _directory = directory ?? resolveRoot;

  final Future<Directory> Function() _directory;

  /// Where `mls/` lives.
  ///
  /// The App Group container when there is one, because on iOS the notification
  /// service extension is a separate process and that container is the only
  /// directory both it and the app can open. Application Support otherwise.
  ///
  /// Installs that predate the move have their state in the old place, so it is
  /// carried across the first time rather than abandoned - leaving it behind
  /// would look exactly like every encrypted conversation losing its history.
  static Future<Directory> resolveRoot() async {
    final legacy = await getApplicationSupportDirectory();
    final shared = await SharedContainer.directory();
    if (shared == null) return legacy;

    try {
      final from = Directory('${legacy.path}/mls');
      final to = Directory('${shared.path}/mls');
      if (await from.exists() && !await to.exists()) {
        try {
          await from.rename(to.path);
        } on FileSystemException {
          // rename(2) refuses to cross file systems. The App Group container is
          // normally on the same volume as Application Support, but "normally"
          // is not worth every encrypted conversation on the device.
          await _copyTree(from, to);
          await from.delete(recursive: true);
        }
      }
    } catch (e) {
      // A failed migration must not be fatal: the engine will start fresh in the
      // shared container and re-join from Welcomes, which costs history on this
      // device but leaves the app usable.
      debugPrint('MlsStore: could not migrate state to the shared container: $e');
    }
    return shared;
  }

  static Future<void> _copyTree(Directory from, Directory to) async {
    await to.create(recursive: true);
    await for (final entity in from.list(recursive: true)) {
      final relative = entity.path.substring(from.path.length);
      if (entity is Directory) {
        await Directory('${to.path}$relative').create(recursive: true);
      } else if (entity is File) {
        await entity.copy('${to.path}$relative');
      }
    }
  }

  /// `contextId#generation` -> base64 MLS group id, plus `contextId#active` ->
  /// generation. Mirrors Alpine's key layout.
  final Map<String, Object> _registry = {};

  /// messageId -> base64 plaintext.
  final Map<String, String> _messageCache = {};

  File? _registryFile;
  File? _cacheFile;
  Directory? _dir;
  bool _ready = false;

  Timer? _cacheFlush;
  Future<void> _writeChain = Future<void>.value();

  static String _groupKey(String contextId, int generation) =>
      '$contextId#$generation';

  static String _activeKey(String contextId) => '$contextId#active';

  /// Where this account's MLS state lives - the engine's own store as well as
  /// the two files here, so "the MLS state" is one directory to inspect or
  /// delete.
  ///
  /// Scoped per user, not per install. An MLS identity is credentialed to one
  /// account and the groups it holds mean nothing to another, so two accounts
  /// sharing a directory would have the second load the first's groups and sign
  /// as the first's identity. Separate directories also mean switching back to
  /// an account finds its history intact rather than wiped.
  Future<Directory> stateDirectory(String userId) async {
    final cached = _dir;
    if (cached != null) return cached;
    final root = await _directory();
    final dir = Directory('${root.path}/mls/${_sanitize(userId)}');
    await dir.create(recursive: true);
    return _dir = dir;
  }

  /// User ids are opaque prefixed strings today, but a path separator arriving
  /// inside one would write outside the intended directory.
  static String _sanitize(String userId) =>
      userId.replaceAll(RegExp(r'[^A-Za-z0-9_.-]'), '_');

  /// Loads both files. Safe to call more than once; only the first does work.
  Future<void> init(String userId) async {
    if (_ready) return;
    final dir = await stateDirectory(userId);
    _registryFile = File('${dir.path}/mls_group_registry.json');
    _cacheFile = File('${dir.path}/mls_message_cache.json');

    _registry.addAll(await _read(_registryFile!));
    for (final entry in (await _read(_cacheFile!)).entries) {
      final value = entry.value;
      if (value is String) _messageCache[entry.key] = value;
    }
    _ready = true;
  }

  /// Drops the in-memory view so the next [init] loads a different account's
  /// state. The files stay where they are - see [stateDirectory].
  Future<void> reset() async {
    await flush();
    _registry.clear();
    _messageCache.clear();
    _registryFile = null;
    _cacheFile = null;
    _dir = null;
    _ready = false;
  }

  Future<Map<String, Object>> _read(File file) async {
    try {
      if (!await file.exists()) return {};
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) return {};
      return Map<String, Object>.from(decoded);
    } catch (e) {
      // A corrupt registry is recoverable - the Welcomes can be re-fetched and
      // the groups re-joined. Refusing to start is not.
      debugPrint('MlsStore: could not read ${file.path}: $e');
      return {};
    }
  }

  // ---------------------------------------------------------------------------
  // Group registry
  //
  // Keyed by (context, generation) rather than by context alone. Encryption can
  // be switched off and back on, and each stretch is a distinct MLS group whose
  // epochs restart at zero - keying by context would have the second group
  // overwrite the first, and every message from the first era would then be
  // decrypted against the wrong keys.
  // ---------------------------------------------------------------------------

  String? groupId(String contextId, int generation) =>
      _registry[_groupKey(contextId, generation)] as String?;

  /// The generation this device last saw as live for the context.
  int? knownGeneration(String contextId) {
    final value = _registry[_activeKey(contextId)];
    return value is int ? value : null;
  }

  /// Group id for whichever generation this device believes is live.
  String? activeGroupId(String contextId) {
    final generation = knownGeneration(contextId);
    if (generation == null) return null;
    return groupId(contextId, generation);
  }

  Future<void> registerGroup({
    required String contextId,
    required int generation,
    required String mlsGroupId,
  }) {
    _registry[_groupKey(contextId, generation)] = mlsGroupId;
    _registry[_activeKey(contextId)] = generation;
    return _saveRegistry();
  }

  /// Records that a context is no longer encrypted, without forgetting the
  /// group that encrypted it - the messages from that era are still in the
  /// history and still need its keys.
  Future<void> clearActiveGeneration(String contextId) {
    _registry.remove(_activeKey(contextId));
    return _saveRegistry();
  }

  /// Drops every group mapping. Only for recovering from a wiped engine store:
  /// on its own this makes every encrypted message unreadable.
  Future<void> clearRegistry() {
    _registry.clear();
    return _saveRegistry();
  }

  // ---------------------------------------------------------------------------
  // Plaintext cache
  //
  // Not an optimisation - it is the only way most of this succeeds. MLS ratchets
  // forward and never backward, so a message can be decrypted from the wire
  // exactly once, on the device that was in the group at the time. Paging back
  // through history therefore reads from here or not at all.
  //
  // Deliberately unbounded. An eviction policy would silently turn readable
  // history into "cannot decrypt", which is indistinguishable to the user from
  // data loss; at roughly a hundred bytes per message the file stays small
  // enough that the trade is not close.
  // ---------------------------------------------------------------------------

  String? cachedMessage(String messageId) => _messageCache[messageId];

  /// Records decrypted content. Writes are coalesced: loading one page of
  /// history decrypts fifty messages, and fifty whole-file writes for it is the
  /// kind of thing that makes scrolling stutter.
  void cacheMessage(String messageId, String plaintextB64) {
    if (_messageCache[messageId] == plaintextB64) return;
    _messageCache[messageId] = plaintextB64;
    _cacheFlush?.cancel();
    _cacheFlush = Timer(const Duration(milliseconds: 400), _saveCache);
  }

  /// Flushes any pending cache write. Call when the app is backgrounded - the
  /// debounce window is short, but being killed inside it costs real content.
  Future<void> flush() {
    _cacheFlush?.cancel();
    _cacheFlush = null;
    return _saveCache();
  }

  Future<void> clearMessageCache() {
    _messageCache.clear();
    return _write(_cacheFile, const {});
  }

  /// Picks up plaintext another process decrypted while this one was not
  /// looking.
  ///
  /// Push notifications are decrypted outside the app - in Android's FCM
  /// background isolate, or in the iOS notification service extension - and MLS
  /// only lets a message be read off the wire once. Without this, a message the
  /// notification showed in full would come back "cannot decrypt" the moment the
  /// user opened the conversation it came from.
  ///
  /// Entries already in memory win: they were written by the isolate that owns
  /// the debounced pending write, and the file may not have caught up yet.
  Future<void> reloadMessageCache() async {
    final file = _cacheFile;
    if (file == null) return;
    for (final entry in (await _read(file)).entries) {
      final value = entry.value;
      if (value is String) _messageCache.putIfAbsent(entry.key, () => value);
    }
  }

  // ---------------------------------------------------------------------------

  Future<void> _saveRegistry() =>
      _write(_registryFile, Map<String, Object>.from(_registry));

  Future<void> _saveCache() =>
      _write(_cacheFile, Map<String, Object>.from(_messageCache), merge: true);

  /// Writes go through a temp file and a rename, chained so two overlapping
  /// saves cannot interleave and leave a half-written file. Android kills
  /// backgrounded apps freely and a truncated cache is lost message content.
  ///
  /// [merge] re-reads the file first and writes the union. Two processes hold
  /// this file - the app and whatever decrypted the last notification - and each
  /// one writes it whole, so a plain overwrite means whichever saves second
  /// deletes the other's decrypted messages. They can never be recovered: the
  /// ciphertext they came from is only readable once.
  Future<void> _write(File? file, Map<String, Object> data, {bool merge = false}) {
    if (file == null) return Future<void>.value();
    final task = _writeChain.then((_) async {
      try {
        var payload = data;
        if (merge) {
          final existing = await _read(file);
          // Ours wins on conflict - same message, same plaintext, and if they
          // ever differ the one this process just decrypted is the fresher read.
          payload = {...existing, ...data};
        }
        final tmp = File('${file.path}.tmp');
        await tmp.writeAsString(jsonEncode(payload), flush: true);
        await tmp.rename(file.path);
      } catch (e) {
        debugPrint('MlsStore: could not write ${file.path}: $e');
      }
    });
    _writeChain = task;
    return task;
  }

  @visibleForTesting
  void dispose() {
    _cacheFlush?.cancel();
    _cacheFlush = null;
  }
}
