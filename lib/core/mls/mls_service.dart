import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:venta_mls/venta_mls.dart';

import '../device/device_id_service.dart';
import '../storage/secure_storage_service.dart';
import 'mls_failure_log.dart';
import 'mls_store.dart';

/// Where this device's MLS identity stands, for the UI to branch on.
enum MlsIdentityStatus {
  /// [MlsService.init] has not run, or has not been asked to unlock yet.
  unknown,

  /// A signing key is loaded and the device can read and send.
  unlocked,

  /// No identity and no groups - a first run. [MlsService.createIdentity] is
  /// the next step and needs no confirmation.
  needsSetup,

  /// The engine restored groups but the keychain holds no matching identity.
  ///
  /// Minting a fresh keypair here would leave the device holding groups it can
  /// neither sign for nor decrypt, while every check that gates the composer
  /// says it is unlocked. See [MlsService.createIdentity].
  keysMissing,
}

/// Thrown when minting an identity would overwrite live group state.
///
/// The engine holds groups whose leaves name a signing key this device can no
/// longer produce. The two honest answers are to restore a backup, or to accept
/// the loss explicitly - never to mint quietly and let the user discover it when
/// nobody can read their messages.
class MlsIdentityConflictException implements Exception {
  const MlsIdentityConflictException(this.groupCount);

  final int groupCount;

  @override
  String toString() =>
      'MlsIdentityConflictException: this device holds $groupCount MLS '
      'group(s) but its signing key is gone';
}

/// This device's MLS identity and group state - the mobile counterpart of
/// Alpine's `MlsService`.
///
/// Holds three things that belong together: the engine, the (context,
/// generation) -> group mapping, and the session's signing key handle. Transport
/// and ordering live in `MlsSyncService`; nothing here talks to the server.
class MlsService {
  MlsService({
    required this.store,
    required this.secureStorage,
    required this.deviceIdService,
    VentaMls? engine,
    MlsFailureLog? failures,
  }) : _engine = engine ?? VentaMls(),
       failures = failures ?? MlsFailureLog.shared;

  final MlsStore store;
  final SecureStorageService secureStorage;
  final DeviceIdService deviceIdService;
  final VentaMls _engine;

  /// Counted decrypt/join failures, shared with the decryptor and the sync
  /// service so one place decides whether a context is readable.
  final MlsFailureLog failures;

  /// Where the identity stands. Watched by the "this device can't read your
  /// messages" affordance, which is the only way [MlsIdentityStatus.keysMissing]
  /// ever reaches the user - nothing else about that state is visible.
  final ValueNotifier<MlsIdentityStatus> identityStatus =
      ValueNotifier<MlsIdentityStatus>(MlsIdentityStatus.unknown);

  /// The current session's signing key handle, or null while locked.
  ///
  /// A `ValueNotifier` rather than a plain field so the composer and the channel
  /// settings screen can disable themselves the moment the session locks -
  /// offering to send into an encrypted context with no key produces a message
  /// that fails after the user has already written it.
  final ValueNotifier<String?> keyHandle = ValueNotifier<String?>(null);

  bool get isUnlocked => keyHandle.value != null;

  /// True once [init] has run and the engine has a state directory.
  bool get isReady => _userId != null;

  /// The account this state belongs to. An MLS identity is credentialed to one
  /// user, so everything below is scoped by it.
  String? _userId;

  /// This device's long-lived signature public key, base64, held from unlock so
  /// the fingerprint can be derived without touching the engine's key store.
  String? _signaturePublicKey;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Loads [userId]'s persisted engine state and group registry.
  ///
  /// A store the engine cannot load is wiped rather than propagated: it means
  /// groups are listed whose key material is missing, and every operation
  /// against them would fail forever. Wiping costs the encrypted history on this
  /// device and re-joins from fresh Welcomes; not wiping costs a client that
  /// never works again.
  /// Returns true when local state had to be wiped.
  ///
  /// The caller **must** act on that: the server is still handing out key
  /// packages whose private halves were just destroyed, so every Welcome sealed
  /// to one is undecryptable by the device it was addressed to. See contract
  /// §A - `DELETE api/v1/devices/client/{deviceId}/key-packages` has to run
  /// before anything re-uploads. `MlsSessionManager.prepareIdentity` is the one
  /// place that knows how to do that.
  Future<bool> init(String userId) async {
    if (_userId == userId) return false;
    // A different account than the one currently loaded - drop its state before
    // touching this one's, or the two share a registry.
    if (_userId != null) await reset();

    await store.init(userId);
    var wiped = false;
    try {
      final dir = await store.stateDirectory(userId);
      await _engine.initStorage(dir.path, stateKeyB64: store.stateKeyB64);
    } catch (e) {
      // A sealed state file that this device cannot open is **not** corruption.
      // The keychain is unavailable this launch - a Keystore fault, a
      // misprovisioned access group - and the key may well be back on the next
      // one. Wiping here would destroy every group on the handset to work around
      // something transient, and the wipe is irreversible where the fault is not.
      if (looksSealedWithoutKey(e)) {
        debugPrint(
          'MlsService: the MLS state file is sealed and its key is not '
          'available - leaving it alone. Encryption is unavailable this launch.',
        );
        identityStatus.value = MlsIdentityStatus.keysMissing;
        _userId = userId;
        return false;
      }

      debugPrint(
        'MlsService: engine state corrupt, wiping and starting fresh: $e',
      );
      try {
        await _engine.clearStorage();
      } catch (inner) {
        debugPrint('MlsService: could not clear engine storage: $inner');
      }
      await store.clearRegistry();
      wiped = true;
    }
    _userId = userId;
    return wiped;
  }

  /// Whether an `initStorage` failure is "the file is sealed and the key is not
  /// here" rather than "the file is broken".
  ///
  /// Substring-matching English prose to decide whether to wipe every group on
  /// the handset is not what this should be - the engine ought to return a code.
  /// It is not that today, so the substrings are pinned by a test against the
  /// literals in `packages/venta_mls/rust/src/mls.rs`, which is the only thing
  /// standing between a reworded error message and an irreversible wipe. Exposed
  /// for that test.
  @visibleForTesting
  static bool looksSealedWithoutKey(Object error) {
    final message = error.toString();
    return message.contains('sealed') || message.contains('state key');
  }

  /// Restores the signing key from the keychain and opens the session.
  ///
  /// Returns false when this account has no MLS identity on this device yet,
  /// which is the signal to call [createIdentity]. Deliberately not an
  /// exception: a first run on a handset is the normal path, not a failure.
  Future<bool> unlock() async {
    final userId = _userId;
    if (userId == null) {
      throw StateError('MlsService.init(userId) must run before unlock()');
    }

    final stored = await secureStorage.readMlsIdentity(
      deviceId: deviceIdService.deviceId,
      userId: userId,
    );
    if (stored == null) {
      identityStatus.value = _statusForMissingIdentity();
      return false;
    }

    final (publicKey, privateKey, identity) = stored;
    if (identity != userId) {
      // Keys stored against a different account. Loading them would sign this
      // user's messages under someone else's credential, which every other
      // member of the group would reject - minting fresh is the only correct
      // answer, and returning false is what asks for that.
      debugPrint('MlsService: stored identity is for another account, ignoring');
      identityStatus.value = _statusForMissingIdentity();
      return false;
    }

    _signaturePublicKey = publicKey;
    keyHandle.value = await _engine.loadSigningKey(
      signingPublicKeyB64: publicKey,
      signingPrivateKeyB64: privateKey,
      identity: identity,
    );
    identityStatus.value = MlsIdentityStatus.unlocked;
    return true;
  }

  /// How many (context, generation) groups this device's registry lists.
  ///
  /// The registry rather than the engine because it is already in memory and
  /// the two are kept in step - a group in the engine with no registry entry is
  /// unaddressable anyway, so it cannot be the thing worth protecting.
  int get heldGroupCount => store.groupCount;

  MlsIdentityStatus _statusForMissingIdentity() => heldGroupCount > 0
      ? MlsIdentityStatus.keysMissing
      : MlsIdentityStatus.needsSetup;

  /// Mints this account's MLS identity on this device, plus its first key
  /// packages.
  ///
  /// The identity is the account's user id: it becomes the BasicCredential every
  /// group member sees as the sender, matching what Alpine publishes. Using the
  /// device id instead would mean neither client recognises the other's
  /// messages.
  ///
  /// The returned batch's `signingPublicKey` is what device registration
  /// publishes as its `identityPublicKey`.
  ///
  /// **No key packages by default.** The ten this used to mint were never
  /// uploaded and never freed: they sat in the engine's store, which is
  /// re-serialized in full on every send, receive and commit, so they made every
  /// later operation slower forever in exchange for nothing. The replenish path
  /// mints exactly what the server asks for, moments later, and that is the only
  /// caller whose packages anyone can ever consume.
  ///
  /// Throws [MlsIdentityConflictException] when the engine already holds groups.
  /// A keychain miss on a device that is in groups is not a first run - it is
  /// lost keys, and minting over them produces a device that believes it is
  /// unlocked while every message it sends is rejected and none it receives can
  /// be read. [force] is the explicit "I accept losing them" path, and belongs
  /// behind a confirmation rather than in a launch sequence.
  Future<MlsKeyPackageBatch> createIdentity({
    int keyPackageCount = 0,
    bool force = false,
  }) async {
    final userId = _userId;
    if (userId == null) {
      throw StateError('MlsService.init(userId) must run before createIdentity()');
    }

    final held = heldGroupCount;
    if (held > 0 && !force) {
      identityStatus.value = MlsIdentityStatus.keysMissing;
      throw MlsIdentityConflictException(held);
    }

    final batch = await _engine.generateKeyPackages(
      identity: userId,
      count: keyPackageCount,
    );
    await secureStorage.writeMlsIdentity(
      deviceId: deviceIdService.deviceId,
      userId: userId,
      publicKey: batch.signingPublicKey,
      privateKey: batch.signingPrivateKey,
    );
    _signaturePublicKey = batch.signingPublicKey;
    keyHandle.value = batch.keyHandle;
    identityStatus.value = MlsIdentityStatus.unlocked;
    return batch;
  }

  /// Adopts the session a backup import already opened inside the engine.
  ///
  /// `importBackup` loads the restored signing key itself and hands back a live
  /// handle, so re-loading it here would leave two handles for one key. This
  /// only brings the Dart-side view into line.
  void adoptRestoredSession({
    required String keyHandle,
    required String signaturePublicKey,
  }) {
    _signaturePublicKey = signaturePublicKey;
    this.keyHandle.value = keyHandle;
    identityStatus.value = MlsIdentityStatus.unlocked;
  }

  /// Accepts the loss in [MlsIdentityStatus.keysMissing] and starts over.
  ///
  /// Wipes the engine, the group registry and the decrypted history, then mints
  /// a fresh identity. Every encrypted message this account holds on this
  /// handset becomes permanently unreadable, which is why it is a separate,
  /// user-initiated call rather than a fallback inside [createIdentity].
  ///
  /// The caller still owes contract §A: the server's key-package stock for this
  /// device is now private-key-less and has to be reset before re-uploading.
  Future<MlsKeyPackageBatch> recoverWithFreshIdentity() async {
    try {
      await _engine.clearStorage();
    } catch (e) {
      debugPrint('MlsService: could not clear engine storage: $e');
    }
    await store.clearRegistry();
    await store.clearMessageCache();
    failures.clear();
    return createIdentity(force: true);
  }

  /// Unloads this account's state so another can be loaded. Called on sign-out
  /// and sign-in; nothing on disk is deleted.
  Future<void> reset() async {
    await lock();
    await store.reset();
    _userId = null;
    _signaturePublicKey = null;
    identityStatus.value = MlsIdentityStatus.unknown;
    failures.clear();
  }

  /// Closes the session, leaving the persisted state alone.
  ///
  /// Sign-out only. The groups and the identity survive, because the next login
  /// on this handset is overwhelmingly the same person and re-joining every
  /// group would burn a key package per group for nothing.
  Future<void> lock() async {
    final handle = keyHandle.value;
    keyHandle.value = null;
    if (identityStatus.value == MlsIdentityStatus.unlocked) {
      identityStatus.value = MlsIdentityStatus.unknown;
    }
    if (handle == null) return;
    try {
      await _engine.unloadSigningKey(handle);
    } catch (e) {
      debugPrint('MlsService: could not unload signing key: $e');
    }
  }

  /// Forgets everything for the current account: identity, groups, decrypted
  /// history.
  ///
  /// For "forget this device" and account deletion. Every encrypted message this
  /// account holds on this handset becomes permanently unreadable here, which is
  /// the point.
  Future<void> forgetEverything() async {
    final userId = _userId;
    await lock();
    try {
      await _engine.clearStorage();
    } catch (e) {
      debugPrint('MlsService: could not clear engine storage: $e');
    }
    await store.clearRegistry();
    await store.clearMessageCache();
    if (userId != null) {
      await secureStorage.clearMlsIdentity(
        deviceId: deviceIdService.deviceId,
        userId: userId,
      );
    }
    await store.reset();
    failures.clear();
    identityStatus.value = MlsIdentityStatus.unknown;
    _userId = null;
  }

  // ---------------------------------------------------------------------------
  // Group registry (delegates - callers should not reach past this into store)
  // ---------------------------------------------------------------------------

  String? groupId(String contextId, int generation) =>
      store.groupId(contextId, generation);

  int? knownGeneration(String contextId) => store.knownGeneration(contextId);

  String? activeGroupId(String contextId) => store.activeGroupId(contextId);

  Future<void> registerGroup({
    required String contextId,
    required int generation,
    required String mlsGroupId,
  }) => store.registerGroup(
    contextId: contextId,
    generation: generation,
    mlsGroupId: mlsGroupId,
  );

  Future<void> clearActiveGeneration(String contextId) =>
      store.clearActiveGeneration(contextId);

  /// Plaintext already read for a message, or null.
  ///
  /// Keyed on the context and generation as well as the id: `messageId` is the
  /// **server's** value, and on the id alone a server that reuses one it has
  /// seen elsewhere gets this device to render another thread's plaintext here,
  /// without decrypting anything at all.
  String? cachedMessage({
    required String contextId,
    required int? generation,
    required String messageId,
  }) => store.cachedMessage(
    contextId: contextId,
    generation: generation,
    messageId: messageId,
  );

  void cacheMessage({
    required String contextId,
    required int? generation,
    required String messageId,
    required String plaintextB64,
  }) => store.cacheMessage(
    contextId: contextId,
    generation: generation,
    messageId: messageId,
    plaintextB64: plaintextB64,
  );

  /// Whether this context is encrypted as far as this device knows.
  bool isEncrypted(String contextId) => activeGroupId(contextId) != null;

  // ---------------------------------------------------------------------------
  // Engine
  // ---------------------------------------------------------------------------

  /// 16 random bytes, base64 - matching Alpine's group id generation. The bytes
  /// are opaque to MLS; only their uniqueness matters.
  String newGroupId() {
    final random = Random.secure();
    return base64Encode(List<int>.generate(16, (_) => random.nextInt(256)));
  }

  Future<MlsGroupInfo> createGroup(String groupIdB64) =>
      _engine.createGroup(groupIdB64: groupIdB64, keyHandle: _requireHandle());

  Future<MlsCommitOut> addMembers({
    required String groupIdB64,
    required List<String> keyPackagesB64,
  }) => _engine.addMembers(
    groupIdB64: groupIdB64,
    keyHandle: _requireHandle(),
    keyPackagesB64: keyPackagesB64,
  );

  Future<MlsGroupInfo> joinGroup(String welcomeB64) =>
      _engine.joinGroup(welcomeB64: welcomeB64, keyHandle: _requireHandle());

  Future<MlsCommitOut> removeMembers({
    required String groupIdB64,
    required List<int> leafIndices,
  }) => _engine.removeMembers(
    groupIdB64: groupIdB64,
    keyHandle: _requireHandle(),
    leafIndices: leafIndices,
  );

  Future<MlsCommitOut> leaveGroup(String groupIdB64) =>
      _engine.leaveGroup(groupIdB64: groupIdB64, keyHandle: _requireHandle());

  Future<MlsCommitOut> commitPendingProposals(String groupIdB64) => _engine
      .commitPendingProposals(
        groupIdB64: groupIdB64,
        keyHandle: _requireHandle(),
      );

  Future<int> mergePendingCommit(String groupIdB64) =>
      _engine.mergePendingCommit(groupIdB64);

  Future<void> clearPendingCommit(String groupIdB64) =>
      _engine.clearPendingCommit(groupIdB64);

  Future<void> deleteGroup(String groupIdB64) =>
      _engine.deleteGroup(groupIdB64);

  Future<String> exportGroupInfo(String groupIdB64) => _engine.exportGroupInfo(
    groupIdB64: groupIdB64,
    keyHandle: _requireHandle(),
  );

  Future<MlsRejoinOut> rejoinGroup(String groupInfoB64) =>
      _engine.rejoinGroup(groupInfoB64: groupInfoB64, keyHandle: _requireHandle());

  Future<MlsSendOut> encrypt({
    required String groupIdB64,
    required String plaintextB64,
  }) => _engine.sendMessage(
    groupIdB64: groupIdB64,
    keyHandle: _requireHandle(),
    plaintextB64: plaintextB64,
  );

  /// [messageId] is forwarded so a message that arrives before the commit that
  /// makes it readable can be matched back to its row when
  /// [drainPendingMessages] replays it, and so the same message arriving twice
  /// is buffered once.
  Future<MlsProcessedMessage> processMessage({
    required String groupIdB64,
    required String messageB64,
    String? messageId,
  }) => _engine.processMessage(
    groupIdB64: groupIdB64,
    messageB64: messageB64,
    messageId: messageId,
  );

  /// Replays every buffered early message the group has now caught up to.
  ///
  /// Had no caller at all until the security review: messages from a future
  /// epoch were buffered correctly and then never looked at again, so they were
  /// counted as decrypt failures instead - and three of those flip
  /// [MlsFailureLog.cannotRead], which puts "Re-link this device" on screen. The
  /// advice was wrong and the action destroys history.
  Future<List<MlsReplayedMessage>> drainPendingMessages(String groupIdB64) =>
      _engine.drainPendingMessages(groupIdB64);

  Future<MlsGroupInfo> getGroupInfo(String groupIdB64) =>
      _engine.getGroupInfo(groupIdB64);

  Future<List<MlsMemberInfo>> getMembers(String groupIdB64) =>
      _engine.getMembers(groupIdB64);

  /// Validates a key package and reports the identity it claims plus its
  /// fingerprint. Used on both sides of a join request - by the requester to
  /// show its own fingerprint, and by the approver to check the bytes the server
  /// handed back are the ones that were reviewed.
  Future<MlsKeyPackageInfo> inspectKeyPackage(String keyPackageB64) =>
      _engine.inspectKeyPackage(keyPackageB64);

  /// This device's own identity fingerprint, for reading out to a reviewer.
  ///
  /// Derived from the signing key held since unlock, not from a freshly minted
  /// key package. Minting one costs ~2.5KB of key material written permanently
  /// into the engine's store that nothing will ever consume, and the store is
  /// rewritten in full on every save - so a caller that asked per rebuild would
  /// make every later encrypt and decrypt slower, forever.
  Future<String?> ownFingerprint() async {
    final publicKey = _signaturePublicKey;
    if (publicKey == null) return null;
    return _engine.fingerprintForSignatureKey(publicKey);
  }

  Future<bool> verifySenderInRoster({
    required String senderIdentity,
    required String groupIdB64,
  }) => _engine.verifySenderInRoster(
    senderIdentity: senderIdentity,
    groupIdB64: groupIdB64,
  );

  /// More key packages for the existing identity - the replenish path. Must not
  /// rotate the signing key: every device already in a group with this one keyed
  /// off the current credential.
  Future<List<KeyPackageResult>> generateKeyPackages(int count) =>
      _engine.generateAdditionalKeyPackages(
        keyHandle: _requireHandle(),
        count: count,
      );

  String _requireHandle() {
    final handle = keyHandle.value;
    if (handle == null) {
      throw const MlsException(
        MlsErrorKind.keyNotFound,
        'the MLS session is locked - no signing key loaded',
      );
    }
    return handle;
  }
}
