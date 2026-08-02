import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../storage/secure_storage_service.dart';
import '../storage/shared_container.dart';
import '../storage/state_file_cipher.dart';

/// Where the key that seals the state files comes from. Injected so tests do not
/// need a keychain.
typedef StateKeyResolver = Future<String?> Function(String userId);

/// Builds the cipher for a resolved key. Injected so tests do not need the
/// native engine loaded.
typedef StateCipherBuilder = StateFileCipher Function(String keyB64);

/// The two pieces of MLS bookkeeping that are this client's own, not the
/// engine's: which MLS group backs which (context, generation), and the
/// plaintext of messages we have already decrypted once.
///
/// Alpine keeps both in Tauri `LazyStore` JSON files and reads them
/// asynchronously. Here they are loaded once into memory and read synchronously
/// - the maps are small, every caller is already inside an async group
/// operation, and threading a `Future` through the decrypt loop for a map lookup
/// made the call sites considerably harder to follow.
///
/// **Both files are sealed on disk.** They used to be plain JSON, which made
/// `mls_message_cache.json` the complete readable history of every encrypted
/// conversation on the handset, sitting in a directory Android's auto-backup
/// includes by default and iOS backs up unconditionally. The key is in the OS
/// keychain, which a device backup does not carry, so a restore onto another
/// handset gets two blobs it cannot open. See [StateFileCipher].
class MlsStore {
  MlsStore({
    Future<Directory> Function()? directory,
    StateKeyResolver? stateKey,
    StateCipherBuilder? cipher,
  }) : _directory = directory ?? resolveRoot,
       _stateKey = stateKey ?? _keyFromKeychain,
       _cipherBuilder = cipher ?? _engineCipher;

  final Future<Directory> Function() _directory;
  final StateKeyResolver _stateKey;
  final StateCipherBuilder _cipherBuilder;

  static Future<String?> _keyFromKeychain(String userId) =>
      SecureStorageService().readOrCreateMlsStateKey(userId);

  static StateFileCipher _engineCipher(String keyB64) =>
      EngineStateFileCipher(stateKeyB64: keyB64);

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

  /// `contextId#generation#messageId` -> base64 plaintext.
  ///
  /// Insertion-ordered, and deliberately relied on: [_saveCache] evicts from the
  /// front, and [cachedMessage] re-inserts on a hit, so the map is an
  /// approximate LRU without carrying a timestamp per entry (which would change
  /// the backup envelope's `messageCache` shape).
  final Map<String, String> _messageCache = {};

  File? _registryFile;
  File? _cacheFile;
  Directory? _dir;

  /// Which account [_dir] belongs to - see [stateDirectory].
  String? _dirUserId;

  /// Which account [init] loaded. Used to catch a second `init` for a different
  /// user, which would otherwise return early and leave this store serving the
  /// first account's registry under the second account's name.
  String? _userId;
  bool _ready = false;

  StateFileCipher? _cipher;
  String? _stateKeyB64;

  /// The key `MlsService` must hand the engine so it can open `mls_state.json`.
  ///
  /// Null means the keychain would not give one up. That is not a reason to
  /// carry on unsealed against a file that *is* sealed - see
  /// `MlsService.init`.
  String? get stateKeyB64 => _stateKeyB64;

  /// True when this account's files are being written sealed.
  bool get isSealed => _cipher != null;

  /// The account whose state is loaded, or null before [init].
  String? get loadedUserId => _userId;

  Timer? _cacheFlush;
  Future<void> _writeChain = Future<void>.value();

  static String _groupKey(String contextId, int generation) =>
      '$contextId#$generation';

  static String _activeKey(String contextId) => '$contextId#active';

  /// Cache key.
  ///
  /// Keyed on the context and generation as well as the id, because `messageId`
  /// is chosen by the **server**. On the id alone, a server that reuses an id it
  /// has seen in another conversation gets this device to render one thread's
  /// plaintext inside another - without breaking any MLS property, because
  /// nothing is decrypted at all on a cache hit.
  static String _cacheKey(String contextId, int? generation, String messageId) =>
      '$contextId#${generation ?? '?'}#$messageId';

  /// Where this account's MLS state lives - the engine's own store as well as
  /// the two files here, so "the MLS state" is one directory to inspect or
  /// delete.
  ///
  /// Scoped per user, not per install. An MLS identity is credentialed to one
  /// account and the groups it holds mean nothing to another, so two accounts
  /// sharing a directory would have the second load the first's groups and sign
  /// as the first's identity. Separate directories also mean switching back to
  /// an account finds its history intact rather than wiped.
  /// The cache is keyed by the user it was resolved for, not merely by "have we
  /// resolved one". A push notification for account B arriving while account A
  /// is loaded used to be handed A's directory, which meant B's engine reading
  /// A's private keys - a confidentiality bug, not a mix-up.
  Future<Directory> stateDirectory(String userId) async {
    final cached = _dir;
    if (cached != null && _dirUserId == userId) return cached;
    final root = await _directory();
    final dir = Directory('${root.path}/mls/${sanitize(userId)}');
    await dir.create(recursive: true);
    // The whole `mls/` tree, not this account's slice of it, and before anything
    // is written into it: on iOS the protection class set here is what newly
    // created files inherit, so doing it after the first write would leave the
    // first write at whatever the default happened to be.
    await SharedContainer.protect(dir.parent.path);
    _dirUserId = userId;
    return _dir = dir;
  }

  /// Folds a user id down to something that can only ever name a directory
  /// *inside* the intended one.
  ///
  /// `.` is **not** in the allowed set, so `..` cannot survive. It used to be,
  /// under a comment claiming traversal safety: a server-supplied
  /// `recipientUserId` of `..` resolved to the parent of every account's
  /// directory, and `../<other user>` to somebody else's. User ids are opaque
  /// prefixed strings today, which is a reason the bug was unreachable in
  /// practice and not a reason the guard should have been wrong.
  ///
  /// Must match `MlsNotificationDecryptor.sanitize` in Swift exactly, or the
  /// iOS extension looks in a directory the app never wrote to.
  @visibleForTesting
  static String sanitize(String userId) =>
      userId.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');

  /// Loads both files. Safe to call more than once for the same account; only
  /// the first does work.
  ///
  /// A call for a *different* account resets first rather than returning early.
  /// The background push isolate initialises whichever account a notification
  /// names, and the early return used to hand it the loaded account's registry
  /// and plaintext cache.
  Future<void> init(String userId) async {
    if (_ready && _userId == userId) return;
    if (_ready) await reset();
    _userId = userId;
    final dir = await stateDirectory(userId);
    _registryFile = File('${dir.path}/mls_group_registry.json');
    _cacheFile = File('${dir.path}/mls_message_cache.json');

    _stateKeyB64 = await _stateKey(userId);
    final key = _stateKeyB64;
    _cipher = key == null ? null : _cipherBuilder(key);
    if (_cipher == null) {
      debugPrint(
        'MlsStore: no keychain key for $userId, so nothing will be persisted '
        'this launch - see MlsStateNotSealable. Reading whatever is already '
        'there still works if it is unsealed.',
      );
    }

    final registry = await _read(_registryFile!);
    final cache = await _read(_cacheFile!);
    _registry.addAll(registry.values);
    for (final entry in cache.values.entries) {
      final value = entry.value;
      if (value is String) _messageCache[entry.key] = value;
    }
    _ready = true;

    // Written before this build, or before the keychain had a key. Sealing them
    // now rather than on the next incidental write is the whole migration: the
    // plaintext copy is what a device backup would carry away, so it should not
    // survive the first launch that can replace it.
    if (_cipher != null && (registry.wasUnsealed || cache.wasUnsealed)) {
      if (registry.wasUnsealed) await _saveRegistry();
      if (cache.wasUnsealed) await _saveCache();
    }
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
    _dirUserId = null;
    _userId = null;
    _cipher = null;
    _stateKeyB64 = null;
    _sealedButUnreadable.clear();
    _ready = false;
  }

  Future<_LoadedFile> _read(File file) async {
    try {
      if (!await file.exists()) return const _LoadedFile({}, false);
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return const _LoadedFile({}, false);

      final sealed = StateFileCipher.isSealed(bytes);
      final cipher = _cipher;
      if (sealed && cipher == null) {
        // Refusing beats starting empty. An empty cache is not a fresh start -
        // it is every message on this device becoming unreadable, permanently,
        // because MLS hands the plaintext over exactly once.
        debugPrint(
          'MlsStore: ${file.path} is sealed and no key is available - leaving '
          'it alone rather than replacing it with an empty one',
        );
        _sealedButUnreadable.add(file.path);
        return const _LoadedFile({}, false);
      }

      final plaintext = sealed ? await cipher!.open(bytes) : bytes;
      final decoded = jsonDecode(utf8.decode(plaintext));
      if (decoded is! Map) return const _LoadedFile({}, false);
      _sealedButUnreadable.remove(file.path);
      return _LoadedFile(Map<String, Object>.from(decoded), !sealed);
    } catch (e) {
      // A corrupt registry is recoverable - the Welcomes can be re-fetched and
      // the groups re-joined. Refusing to start is not.
      //
      // A sealed file that would not open is a different thing, and is latched:
      // the key is wrong or missing, the contents are irreplaceable, and the one
      // thing that must not happen is this process writing an empty file over
      // them.
      debugPrint('MlsStore: could not read ${file.path}: $e');
      try {
        if (StateFileCipher.isSealed(await file.readAsBytes())) {
          _sealedButUnreadable.add(file.path);
        }
      } catch (_) {
        // Unreadable for an ordinary reason. Nothing to latch.
      }
      return const _LoadedFile({}, false);
    }
  }

  /// Files this process found sealed and could not open.
  ///
  /// Writes to them are refused for the rest of the session. Their contents
  /// cannot be reconstructed - MLS hands each plaintext over exactly once - so
  /// overwriting them with what this process happens to hold is permanent loss,
  /// caused by a key that may simply be unavailable this launch.
  final Set<String> _sealedButUnreadable = {};

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

  /// How many (context, generation) groups this device is registered in.
  ///
  /// Counts the group mappings only - the `#active` pointers share the map but
  /// are bookkeeping, not membership. Used to tell "first run on this handset"
  /// apart from "the signing key is gone but the groups are not", which look
  /// identical from the keychain's side.
  int get groupCount => _registry.values.whereType<String>().length;

  /// The raw registry, for the backup envelope's `groupRegistry` field.
  Map<String, Object> get snapshot => Map<String, Object>.unmodifiable(_registry);

  /// The decrypted history, for the backup envelope's `messageCache` field.
  Map<String, String> get messageCacheSnapshot =>
      Map<String, String>.unmodifiable(_messageCache);

  /// Merges a restored registry in. Existing entries win: whatever this device
  /// joined since the backup was taken is newer than the backup.
  ///
  /// Throws [MlsStateNotSealable] rather than merging into memory and quietly
  /// failing to persist. A restore that reports success and lands nothing on
  /// disk is worse than one that fails: the user believes their history is back
  /// and finds out otherwise on the next launch.
  Future<void> restoreRegistry(Map<String, Object> entries) {
    _requireSealable('the group registry');
    for (final entry in entries.entries) {
      _registry.putIfAbsent(entry.key, () => entry.value);
    }
    return _saveRegistry();
  }

  /// Merges restored plaintext in. Same rule, and for the same reason as
  /// [reloadMessageCache]: a message read off the wire since the backup cannot
  /// be read again, so the in-memory copy is the only one.
  Future<void> restoreMessageCache(Map<String, String> entries) {
    _requireSealable('the decrypted message history');
    for (final entry in entries.entries) {
      _messageCache.putIfAbsent(entry.key, () => entry.value);
    }
    return flush();
  }

  /// Nothing may be persisted without a key to seal it under - see [_write].
  ///
  /// Checked before the in-memory merge rather than after, so a refused restore
  /// leaves this store exactly as it found it.
  void _requireSealable(String what) {
    if (_cipher == null) throw MlsStateNotSealable(what);
  }

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
    return _erase(_registryFile);
  }

  // ---------------------------------------------------------------------------
  // Plaintext cache
  //
  // Not an optimisation - it is the only way most of this succeeds. MLS ratchets
  // forward and never backward, so a message can be decrypted from the wire
  // exactly once, on the device that was in the group at the time. Paging back
  // through history therefore reads from here or not at all.
  // ---------------------------------------------------------------------------

  /// Hard ceiling on retained plaintext.
  ///
  /// This used to be unbounded, on the reasoning that eviction turns readable
  /// history into "cannot decrypt" - which is true, and was the right call while
  /// the file was the only copy of anything. Two things changed it: the file is
  /// now sealed, so the argument that it is cheap to keep no longer has to carry
  /// the argument that it is safe to keep; and §H.6 caps the backup blob at
  /// 16 MiB, which an unbounded cache reaches and then silently stops backing
  /// anything up at all.
  ///
  /// Eviction is approximate-LRU rather than oldest-message: paging back through
  /// history *inserts* old messages last, so evicting by insertion order alone
  /// would throw away what the user is reading right now. [cachedMessage]
  /// re-inserts on a hit, which is what makes the front of the map the least
  /// recently *used* rather than the least recently written.
  static const maxCachedMessages = 20000;

  /// Plaintext for a message, or null.
  ///
  /// [generation] is part of the key; passing the wrong one is a miss, not a
  /// wrong answer.
  String? cachedMessage({
    required String contextId,
    required int? generation,
    required String messageId,
  }) {
    final key = _cacheKey(contextId, generation, messageId);
    final hit = _messageCache.remove(key);
    if (hit != null) {
      // Re-inserted at the back: this is what the eviction order means by
      // "recently used".
      _messageCache[key] = hit;
      return hit;
    }

    // Written before the key carried the context and generation. Read, then
    // promoted to the composite key on the next write so the legacy shape drains
    // away rather than being carried forever.
    return _messageCache[messageId];
  }

  /// Records decrypted content. Writes are coalesced: loading one page of
  /// history decrypts fifty messages, and fifty whole-file writes for it is the
  /// kind of thing that makes scrolling stutter.
  void cacheMessage({
    required String contextId,
    required int? generation,
    required String messageId,
    required String plaintextB64,
  }) {
    final key = _cacheKey(contextId, generation, messageId);
    // The bare-id entry this replaces, if any. Dropped rather than left to age
    // out: two keys for one message is two copies of the plaintext.
    final hadLegacy = _messageCache.remove(messageId) != null;
    if (_messageCache[key] == plaintextB64 && !hadLegacy) return;
    _messageCache[key] = plaintextB64;
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
    return _erase(_cacheFile);
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
    for (final entry in (await _read(file)).values.entries) {
      final value = entry.value;
      if (value is String) _messageCache.putIfAbsent(entry.key, () => value);
    }
  }

  // ---------------------------------------------------------------------------

  Future<void> _saveRegistry() =>
      _write(_registryFile, Map<String, Object>.from(_registry));

  Future<void> _saveCache() {
    _prune();
    return _write(_cacheFile, Map<String, Object>.from(_messageCache), merge: true);
  }

  void _prune() {
    if (_messageCache.length <= maxCachedMessages) return;
    final surplus = _messageCache.length - maxCachedMessages;
    for (final key in _messageCache.keys.take(surplus).toList()) {
      _messageCache.remove(key);
    }
    debugPrint('MlsStore: pruned $surplus of the least recently read messages');
  }

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
    if (_sealedButUnreadable.contains(file.path)) {
      debugPrint(
        'MlsStore: not writing ${file.path} - this process could not open it, '
        'and what is in there cannot be recovered from anywhere else',
      );
      return Future<void>.value();
    }

    // No key, no write. `mls_message_cache.json` is the plaintext of every
    // message this device has ever decrypted and the registry names every group
    // it is in, and a directory that a backup carries off the handset is the one
    // place neither may sit in the clear. This used to fall back to writing them
    // unsealed, which is the same branch the engine had at `write_state_file`
    // and the same reasoning against it: history that stops persisting while the
    // keychain is unavailable is recoverable, and history written out in the
    // clear is not.
    //
    // Captured rather than re-read inside the task: `reset()` can null it while
    // a write is queued, and a write must not change shape between being
    // decided on and being performed.
    final cipher = _cipher;
    if (cipher == null) {
      debugPrint(
        'MlsStore: not writing ${file.path} - there is no key to seal it with. '
        'Nothing decrypted this launch will be remembered.',
      );
      return Future<void>.value();
    }

    final task = _writeChain.then((_) async {
      try {
        var payload = data;
        if (merge) {
          final existing = await _read(file);
          // Ours wins on conflict - same message, same plaintext, and if they
          // ever differ the one this process just decrypted is the fresher read.
          payload = {...existing.values, ...data};
        }
        final bytes = await cipher.seal(utf8.encode(jsonEncode(payload)));

        final tmp = File('${file.path}.tmp');
        await tmp.writeAsBytes(bytes, flush: true);
        await tmp.rename(file.path);
      } catch (e) {
        debugPrint('MlsStore: could not write ${file.path}: $e');
      }
    });
    _writeChain = task;
    return task;
  }

  /// Removes a file instead of writing an empty one over it.
  ///
  /// Same end state, and the only version that still works with no key: [_write]
  /// refuses without one, so a "clear" built on it would empty the in-memory
  /// copy and leave the real contents sitting on disk. Routed through the write
  /// chain so it cannot land in the middle of a queued save.
  Future<void> _erase(File? file) {
    if (file == null) return Future<void>.value();
    final task = _writeChain.then((_) async {
      try {
        if (await file.exists()) await file.delete();
        // Whatever could not be opened is gone now, so the latch that protected
        // it has nothing left to protect.
        _sealedButUnreadable.remove(file.path);
      } catch (e) {
        debugPrint('MlsStore: could not remove ${file.path}: $e');
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

/// Something asked the store to persist while it has no key to seal with.
///
/// A named type because the two kinds of caller want opposite things from the
/// refusal. An ordinary save can only log it and carry on - the alternative is
/// crashing the app because the keychain is having a bad launch. A backup
/// restore has to fail outright, because "your history is back" and "your
/// history is in memory until you close the app" are not the same claim.
class MlsStateNotSealable implements Exception {
  const MlsStateNotSealable(this.what);

  /// What was being written, for the message.
  final String what;

  @override
  String toString() =>
      'MlsStateNotSealable: refusing to write $what with no state key. It would '
      'have to go to disk unsealed, in the directory a device backup carries '
      'off the handset.';
}

/// A file that was read, plus whether it was still in the unsealed shape.
class _LoadedFile {
  const _LoadedFile(this.values, this.wasUnsealed);

  final Map<String, Object> values;

  /// True when the bytes on disk were plain JSON, so the caller owes a rewrite.
  final bool wasUnsealed;
}
