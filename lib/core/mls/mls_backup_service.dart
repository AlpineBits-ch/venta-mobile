import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:venta_mls/venta_mls.dart';

import '../../features/mls/data/mls_api.dart';
import '../crypto/account_identity_service.dart';
import '../device/device_id_service.dart';
import '../storage/secure_storage_service.dart';
import 'mls_backup_api.dart';
import 'mls_service.dart';

/// The outcome of opening a `.venta-keys` envelope, in the terms the UI needs.
class BackupRestoreResult {
  const BackupRestoreResult({
    required this.engineRestored,
    required this.groupsToRejoin,
    required this.messagesRestored,
    required this.accountIdentityRestored,
  });

  /// True only for same-device recovery. When false the groups in the registry
  /// exist by name but not by key, and the caller owes a re-join per context.
  final bool engineRestored;

  /// Contexts whose registry entry came across without the group behind it.
  final List<String> groupsToRejoin;

  final int messagesRestored;

  /// Whether the envelope carried the account identity key. Without it a
  /// restored handset can issue no device certificate, so every peer running
  /// §H.4 enforcement would propose removing its leaf.
  final bool accountIdentityRestored;
}

/// Export, import and cloud backup of everything this device needs to be itself
/// again. Contract §D, §C.2 and §H.6.
///
/// The envelope is assembled Rust-side. Two reasons, and the second is the one
/// that matters: the signing keypair lives in the engine's signer table and has
/// deliberately not crossed the FFI boundary in the clear since unlock, and
/// building the JSON here would put it back on the Dart heap for nothing. More
/// importantly it is what keeps the bytes identical to Alpine's, which is the
/// entire point of §D - a file written on a phone has to open on a desktop.
///
/// What it covers, and why each piece is not optional:
///
/// * the **Ed25519 signing key**, which lives in the keychain and the engine's
///   memory but never in provider storage, so `export_state` alone omitted it;
/// * the **device id**, because the keychain entries are named after it;
/// * the **group registry**, without which the restored groups are unaddressable
///   and every context reads as unencrypted;
/// * the **plaintext message cache**, the only readable copy of history, since
///   MLS decrypts from the wire exactly once;
/// * the **account identity key** (§H.2), without which a restored device can
///   prove nothing to anyone.
class MlsBackupService {
  MlsBackupService({
    required this.mls,
    required this.api,
    required this.mlsApi,
    required this.identity,
    required this.secureStorage,
    required this.deviceIdService,
    required this.appVersion,
    VentaMls? engine,
  }) : _engine = engine ?? VentaMls();

  final MlsService mls;
  final MlsBackupApi api;
  final MlsApi mlsApi;
  final AccountIdentityService identity;
  final SecureStorageService secureStorage;
  final DeviceIdService deviceIdService;
  final String appVersion;
  final VentaMls _engine;

  /// §H.6: automatic and periodic, not a button. A backup that exists only when
  /// the user remembers to press something will not be there when the lake
  /// happens. Debounced to at most one an hour because the engine store is
  /// rewritten in full on every send, receive and commit.
  static const _minimumInterval = Duration(hours: 1);

  /// §H.6: warn past this. Stated in the UI rather than implied by a timestamp
  /// nobody reads.
  static const staleAfter = Duration(days: 7);

  static const fileExtension = 'venta-keys';

  DateTime? _lastAutoBackup;
  String? _etag;

  /// Last successful cloud backup, for the settings screen's freshness line.
  final ValueNotifier<DateTime?> lastBackupAt = ValueNotifier<DateTime?>(null);

  bool get isStale {
    final at = lastBackupAt.value;
    return at == null || DateTime.now().difference(at) > staleAfter;
  }

  // ---------------------------------------------------------------------------
  // Building the envelope
  // ---------------------------------------------------------------------------

  /// Seals this device's state under [passphrase].
  ///
  /// [includeMessageCache] defaults to false, and the cloud path must leave it
  /// that way (§H.6). It is the plaintext of every message this device has read
  /// - the single most sensitive thing in the file, and also the thing users
  /// most want restored, so the trade is made explicit rather than for them.
  Future<String> buildEnvelope({
    required String userId,
    required String passphrase,
    bool includeMessageCache = false,
  }) async {
    final keyHandle = mls.keyHandle.value;
    if (keyHandle == null) {
      throw StateError(
        'The MLS session is locked, so there is no signing key to back up.',
      );
    }

    final deviceId = deviceIdService.deviceId;
    final accountIdentity = await secureStorage.readAccountIdentity(
      deviceId: deviceId,
      userId: userId,
    );

    return _engine.exportBackup(
      passphrase: passphrase,
      userId: userId,
      deviceId: deviceId,
      appVersion: appVersion,
      keyHandle: keyHandle,
      groupRegistry: mls.store.snapshot,
      messageCache: includeMessageCache ? mls.store.messageCacheSnapshot : null,
      accountIdentityPublicKeyB64: accountIdentity?.$1,
      accountIdentityPrivateKeyB64: accountIdentity?.$2,
    );
  }

  // ---------------------------------------------------------------------------
  // Local file
  // ---------------------------------------------------------------------------

  /// Writes a `.venta-keys` file wherever the user chooses. Returns the path, or
  /// null if they backed out.
  Future<String?> exportToFile({
    required String userId,
    required String passphrase,
    bool includeMessageCache = false,
  }) async {
    final envelope = await buildEnvelope(
      userId: userId,
      passphrase: passphrase,
      includeMessageCache: includeMessageCache,
    );
    final bytes = Uint8List.fromList(utf8.encode(envelope));
    final stamp = DateTime.now().toUtc().toIso8601String().split('T').first;

    // `bytes:` as well as a name, because on Android and iOS `saveFile` cannot
    // write the file itself without them - it hands the path back and nothing
    // lands there.
    return FilePicker.saveFile(
      dialogTitle: 'Save your encryption keys',
      fileName: 'venta-keys-$stamp.$fileExtension',
      bytes: bytes,
    );
  }

  /// Reads a `.venta-keys` file the user picks. Returns null if they backed out.
  Future<String?> pickEnvelope() async {
    final picked = await FilePicker.pickFiles(
      dialogTitle: 'Choose your key backup',
      type: FileType.any,
      withData: true,
    );
    final file = picked?.files.singleOrNull;
    if (file == null) return null;

    final bytes = file.bytes;
    if (bytes != null) return utf8.decode(bytes);

    final path = file.path;
    if (path == null) return null;
    return File(path).readAsString();
  }

  // ---------------------------------------------------------------------------
  // Cloud
  // ---------------------------------------------------------------------------

  /// Uploads the envelope, excluding the message cache.
  ///
  /// Never includes plaintext history by default: §H.6 makes that opt-in on the
  /// local-file path only, because a cloud copy of every message you have read
  /// is a bigger at-rest exposure than the ciphertext on the server it came
  /// from.
  Future<void> uploadToCloud({
    required String userId,
    required String passphrase,
    required int recoveryKeyVersion,
  }) async {
    final envelope = await buildEnvelope(
      userId: userId,
      passphrase: passphrase,
    );
    final meta = await api.upload(
      deviceId: deviceIdService.deviceId,
      envelope: envelope,
      recoveryKeyVersion: recoveryKeyVersion,
      etag: _etag,
    );
    _etag = meta.etag;
    _lastAutoBackup = DateTime.now();
    lastBackupAt.value = meta.updatedAt ?? DateTime.now();
  }

  /// The §H.6 cadence hook. Call after anything that materially changes engine
  /// state - a join, a commit, a generation change - and let the debounce decide.
  ///
  /// Silent on failure by design: a backup that could not be taken is not a
  /// reason to interrupt whatever the user was doing, and the settings screen's
  /// staleness warning is where it surfaces instead.
  Future<void> backUpIfStale({
    required String userId,
    required String passphrase,
    required int recoveryKeyVersion,
  }) async {
    final last = _lastAutoBackup;
    if (last != null && DateTime.now().difference(last) < _minimumInterval) {
      return;
    }
    // Stamped before the work: a failing upload should hold the next attempt off
    // for the interval rather than retrying on every commit.
    _lastAutoBackup = DateTime.now();
    try {
      await uploadToCloud(
        userId: userId,
        passphrase: passphrase,
        recoveryKeyVersion: recoveryKeyVersion,
      );
    } catch (e) {
      debugPrint('MlsBackupService: automatic backup failed: $e');
    }
  }

  Future<String?> downloadFromCloud() =>
      api.download(deviceIdService.deviceId);

  Future<BackupMetaDto?> cloudMeta() => api.meta(deviceIdService.deviceId);

  // ---------------------------------------------------------------------------
  // Restore
  // ---------------------------------------------------------------------------

  /// Opens an envelope and applies exactly what is safe to apply.
  ///
  /// The engine's ratchet state comes across **only** when the envelope's device
  /// id matches this device's. Two devices sharing one leaf derive the same
  /// sender-ratchet keys, so openmls treats the repeat as a replay and at least
  /// one of them becomes unable to send; forward secrecy for that leaf is gone;
  /// and an Update from one leaves the other holding keys the group believes
  /// were rotated. Enforced in the engine rather than here, and asserted in
  /// `a_backup_restored_on_a_different_device_skips_the_engine`.
  ///
  /// A `userId` mismatch is refused outright rather than merged.
  Future<BackupRestoreResult> restore({
    required String userId,
    required String envelope,
    required String passphrase,
  }) async {
    final deviceId = deviceIdService.deviceId;

    final result = await _engine.importBackup(
      blob: envelope,
      passphrase: passphrase,
      userId: userId,
      deviceId: deviceId,
    );

    // The keychain is what survives a reinstall of the app but not of the OS, so
    // the signing key goes back there as well as into the engine - otherwise the
    // next launch finds no identity, sees groups, and lands in
    // `MlsIdentityStatus.keysMissing`.
    await _restoreSigningKey(userId: userId, deviceId: deviceId, result: result);

    if (result.accountIdentityPublicKey case final public?) {
      if (result.accountIdentityPrivateKey case final private?) {
        await identity.adoptRestored(
          userId: userId,
          deviceId: deviceId,
          publicKey: public,
          privateKey: private,
        );
      }
    }

    await mls.store.restoreRegistry(result.groupRegistry);
    if (result.messageCache.isNotEmpty) {
      await mls.store.restoreMessageCache(result.messageCache);
    }

    // Registry entries whose groups did not come across. On a new device that is
    // all of them, and each one needs a re-join - by external commit where the
    // server still holds a GroupInfo, by join request otherwise.
    final groupsToRejoin = result.engineRestored
        ? const <String>[]
        : result.groupRegistry.keys
              .where((k) => k.endsWith('#active'))
              .map((k) => k.substring(0, k.length - '#active'.length))
              .toList();

    return BackupRestoreResult(
      engineRestored: result.engineRestored,
      groupsToRejoin: groupsToRejoin,
      messagesRestored: result.messageCache.length,
      accountIdentityRestored: result.accountIdentityPublicKey != null,
    );
  }

  /// Puts the restored signing key where the *next* launch will look for it.
  ///
  /// The engine already loaded it and handed back a live handle, so the session
  /// works immediately. But `MlsService.unlock` reads the keychain on every cold
  /// start, and a restore that only loaded the key into memory would work until
  /// the app was next killed and then be indistinguishable from lost keys - the
  /// exact state `MlsIdentityStatus.keysMissing` exists to name.
  Future<void> _restoreSigningKey({
    required String userId,
    required String deviceId,
    required MlsBackupImportResult result,
  }) async {
    await secureStorage.writeMlsIdentity(
      deviceId: deviceId,
      userId: userId,
      publicKey: result.signingPublicKey,
      privateKey: result.signingPrivateKey,
    );
    mls.adoptRestoredSession(
      keyHandle: result.keyHandle,
      signaturePublicKey: result.signingPublicKey,
    );
  }
}
