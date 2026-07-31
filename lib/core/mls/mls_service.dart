import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:venta_mls/venta_mls.dart';

import '../device/device_id_service.dart';
import '../storage/secure_storage_service.dart';
import 'mls_store.dart';

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
  }) : _engine = engine ?? VentaMls();

  final MlsStore store;
  final SecureStorageService secureStorage;
  final DeviceIdService deviceIdService;
  final VentaMls _engine;

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
  Future<void> init(String userId) async {
    if (_userId == userId) return;
    // A different account than the one currently loaded - drop its state before
    // touching this one's, or the two share a registry.
    if (_userId != null) await reset();

    await store.init(userId);
    try {
      final dir = await store.stateDirectory(userId);
      await _engine.initStorage(dir.path);
    } catch (e) {
      debugPrint(
        'MlsService: engine state corrupt, wiping and starting fresh: $e',
      );
      try {
        await _engine.clearStorage();
      } catch (inner) {
        debugPrint('MlsService: could not clear engine storage: $inner');
      }
      await store.clearRegistry();
    }
    _userId = userId;
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
    if (stored == null) return false;

    final (publicKey, privateKey, identity) = stored;
    if (identity != userId) {
      // Keys stored against a different account. Loading them would sign this
      // user's messages under someone else's credential, which every other
      // member of the group would reject - minting fresh is the only correct
      // answer, and returning false is what asks for that.
      debugPrint('MlsService: stored identity is for another account, ignoring');
      return false;
    }

    _signaturePublicKey = publicKey;
    keyHandle.value = await _engine.loadSigningKey(
      signingPublicKeyB64: publicKey,
      signingPrivateKeyB64: privateKey,
      identity: identity,
    );
    return true;
  }

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
  Future<MlsKeyPackageBatch> createIdentity({int keyPackageCount = 10}) async {
    final userId = _userId;
    if (userId == null) {
      throw StateError('MlsService.init(userId) must run before createIdentity()');
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
    return batch;
  }

  /// Unloads this account's state so another can be loaded. Called on sign-out
  /// and sign-in; nothing on disk is deleted.
  Future<void> reset() async {
    await lock();
    await store.reset();
    _userId = null;
    _signaturePublicKey = null;
  }

  /// Closes the session, leaving the persisted state alone.
  ///
  /// Sign-out only. The groups and the identity survive, because the next login
  /// on this handset is overwhelmingly the same person and re-joining every
  /// group would burn a key package per group for nothing.
  Future<void> lock() async {
    final handle = keyHandle.value;
    keyHandle.value = null;
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

  String? cachedMessage(String messageId) => store.cachedMessage(messageId);

  void cacheMessage(String messageId, String plaintextB64) =>
      store.cacheMessage(messageId, plaintextB64);

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

  Future<MlsProcessedMessage> processMessage({
    required String groupIdB64,
    required String messageB64,
  }) => _engine.processMessage(groupIdB64: groupIdB64, messageB64: messageB64);

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
