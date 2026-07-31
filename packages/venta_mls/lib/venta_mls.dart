/// MLS (RFC 9420) group operations, backed by openmls.
///
/// This is the mobile counterpart of Alpine's `MlsService` Tauri surface. Same
/// operations, same argument names, same result shapes - both clients drive the
/// same Rust engine, and a divergence here is a divergence in the wire format.
///
/// Nothing in this package knows about the server, conversations or channels.
/// Ordering rules (commits apply in epoch order; a commit is staged, published,
/// then merged; a Welcome is acknowledged only after its join succeeded) live in
/// the app's `MlsSyncService`, because they are transport rules rather than
/// crypto ones.
library;

import 'dart:async';

import 'src/ffi.dart';
import 'src/models.dart';

export 'src/errors.dart';
export 'src/models.dart';

class VentaMls {
  VentaMls({MlsFfi? ffi}) : _ffi = ffi ?? MlsFfi.instance();

  final MlsFfi _ffi;

  /// How many key packages to build before yielding to the event loop.
  ///
  /// A full replenish asks for up to 100, and each one is an X25519 keygen plus
  /// a signature. Done in one go that is a visible stall on a mid-range handset,
  /// and it happens on launch - the worst possible moment to drop frames.
  static const _keyPackageChunk = 10;

  // ---------------------------------------------------------------------------
  // Storage
  // ---------------------------------------------------------------------------

  /// Points the engine at [directory] and restores anything already there.
  ///
  /// Returns true when state was restored, false when starting fresh. Call once
  /// per process before any group operation; calling it again with the same
  /// directory is a no-op rather than a reload, so a second isolate in the same
  /// process cannot pull the file in over live state.
  ///
  /// [readOnly] loads the state and then leaves the engine unable to save.
  /// That is for a *separate process* reading along - an iOS notification
  /// service extension - where writing back would eventually replace whatever
  /// the app committed in the meantime with an older copy.
  Future<bool> initStorage(String directory, {bool readOnly = false}) async =>
      _ffi.invoke('initStorage', {'dir': directory, 'readOnly': readOnly})
          as bool;

  /// Deletes the persisted state file and drops all in-memory group state.
  /// Recovery path for a corrupt store - the caller must clear its own group
  /// registry too, or it will keep pointing at groups that no longer exist.
  Future<void> clearStorage() async => _ffi.invoke('clearStorage');

  /// Full state as an AES-256-GCM blob, for cloud backup. [encryptionKeyB64]
  /// must decode to exactly 32 bytes.
  Future<String> exportState(String encryptionKeyB64) async =>
      _ffi.invoke('exportState', {'encryptionKeyB64': encryptionKeyB64})
          as String;

  /// Restores a blob from [exportState], replacing all current group state.
  /// Signing keys are separate - reload them with [loadSigningKey] afterwards.
  Future<void> importState(String encryptedB64, String encryptionKeyB64) async =>
      _ffi.invoke('importState', {
        'encryptedB64': encryptedB64,
        'encryptionKeyB64': encryptionKeyB64,
      });

  // ---------------------------------------------------------------------------
  // Signing keys
  // ---------------------------------------------------------------------------

  /// Loads a signing key into the engine and returns an opaque handle.
  ///
  /// Call once per session unlock; every group operation afterwards takes the
  /// handle, so the private key bytes cross the FFI boundary exactly once.
  /// [identity] is the user id - it becomes this device's BasicCredential and is
  /// what other members see as the sender.
  Future<String> loadSigningKey({
    required String signingPublicKeyB64,
    required String signingPrivateKeyB64,
    required String identity,
  }) async =>
      _ffi.invoke('loadSigningKey', {
            'signingPublicKeyB64': signingPublicKeyB64,
            'signingPrivateKeyB64': signingPrivateKeyB64,
            'identity': identity,
          })
          as String;

  /// Drops a signing key from the engine. Call on lock, sign-out or device
  /// de-registration.
  Future<void> unloadSigningKey(String keyHandle) async =>
      _ffi.invoke('unloadSigningKey', {'keyHandle': keyHandle});

  // ---------------------------------------------------------------------------
  // Key packages
  // ---------------------------------------------------------------------------

  /// Mints a fresh Ed25519 identity plus [count] key packages.
  ///
  /// Once per device registration. The caller stores `signingPrivateKey` in the
  /// keychain, publishes `signingPublicKey` as the device's identity key, and
  /// uploads each `keyPackage`.
  Future<MlsKeyPackageBatch> generateKeyPackages({
    required String identity,
    required int count,
  }) async {
    final first = MlsKeyPackageBatch.fromJson(
      _ffi.invoke('generateKeyPackages', {
            'identity': identity,
            'count': count < _keyPackageChunk ? count : _keyPackageChunk,
          })
          as Map<String, dynamic>,
    );

    // The identity keypair is minted by the first call, so the remainder are
    // topped up through the handle rather than by generating a second identity.
    final remaining = count - first.keyPackages.length;
    if (remaining <= 0) return first;

    final rest = await generateAdditionalKeyPackages(
      keyHandle: first.keyHandle,
      count: remaining,
    );

    return MlsKeyPackageBatch(
      signingPublicKey: first.signingPublicKey,
      signingPrivateKey: first.signingPrivateKey,
      keyPackages: [...first.keyPackages, ...rest],
      keyHandle: first.keyHandle,
    );
  }

  /// More key packages for an identity that already exists. This is the
  /// replenish path - it must not rotate the signing key, or every device
  /// already in a group with this one stops recognising its credential.
  Future<List<KeyPackageResult>> generateAdditionalKeyPackages({
    required String keyHandle,
    required int count,
  }) async {
    final results = <KeyPackageResult>[];
    var outstanding = count;
    while (outstanding > 0) {
      final batch = outstanding < _keyPackageChunk
          ? outstanding
          : _keyPackageChunk;
      final raw =
          _ffi.invoke('generateKeyPackagesWithHandle', {
                'keyHandle': keyHandle,
                'count': batch,
              })
              as List<dynamic>;
      results.addAll(
        raw.map((e) => KeyPackageResult.fromJson(e as Map<String, dynamic>)),
      );
      outstanding -= batch;
      // Let the frame land before the next chunk.
      if (outstanding > 0) await Future<void>.delayed(Duration.zero);
    }
    return results;
  }

  // ---------------------------------------------------------------------------
  // Group lifecycle
  // ---------------------------------------------------------------------------

  /// Creates a group with a caller-chosen id. The id is opaque bytes, base64.
  Future<MlsGroupInfo> createGroup({
    required String groupIdB64,
    required String keyHandle,
  }) async => _serialized(
    groupIdB64,
    () => MlsGroupInfo.fromJson(
      _ffi.invoke('createGroup', {
            'groupIdB64': groupIdB64,
            'keyHandle': keyHandle,
          })
          as Map<String, dynamic>,
    ),
  );

  /// Stages a commit adding [keyPackagesB64].
  ///
  /// Not applied locally: publish it first, then [mergePendingCommit] if the
  /// server took it or [clearPendingCommit] if it did not. Applying a commit the
  /// server refused forks this device off the group permanently.
  Future<MlsCommitOut> addMembers({
    required String groupIdB64,
    required String keyHandle,
    required List<String> keyPackagesB64,
  }) async => _serialized(
    groupIdB64,
    () => MlsCommitOut.fromJson(
      _ffi.invoke('addMembers', {
            'groupIdB64': groupIdB64,
            'keyHandle': keyHandle,
            'keyPackagesB64': keyPackagesB64,
          })
          as Map<String, dynamic>,
    ),
  );

  /// Joins a group from a Welcome. Same staging caveat does not apply - a
  /// Welcome is not a commit and admits only this device.
  Future<MlsGroupInfo> joinGroup({
    required String welcomeB64,
    required String keyHandle,
  }) async => MlsGroupInfo.fromJson(
    _ffi.invoke('joinGroup', {
          'welcomeB64': welcomeB64,
          'keyHandle': keyHandle,
        })
        as Map<String, dynamic>,
  );

  /// Stages a commit removing members by leaf index.
  Future<MlsCommitOut> removeMembers({
    required String groupIdB64,
    required String keyHandle,
    required List<int> leafIndices,
  }) async => _serialized(
    groupIdB64,
    () => MlsCommitOut.fromJson(
      _ffi.invoke('removeMembers', {
            'groupIdB64': groupIdB64,
            'keyHandle': keyHandle,
            'leafIndices': leafIndices,
          })
          as Map<String, dynamic>,
    ),
  );

  /// Leaves the group.
  ///
  /// MLS does not let a member commit their own removal, so this is a Remove
  /// *proposal* despite the field being called `commit` - publish it like one
  /// and a remaining member turns it into a commit via [commitPendingProposals].
  /// `epoch` is meaningless here and comes back as 0.
  ///
  /// Local state is dropped immediately: this device loses access the moment it
  /// asks to leave, whether or not anyone ever commits the proposal.
  Future<MlsCommitOut> leaveGroup({
    required String groupIdB64,
    required String keyHandle,
  }) async => _serialized(
    groupIdB64,
    () => MlsCommitOut.fromJson(
      _ffi.invoke('leaveGroup', {
            'groupIdB64': groupIdB64,
            'keyHandle': keyHandle,
          })
          as Map<String, dynamic>,
    ),
  );

  /// Commits whatever proposals are queued - in practice the Remove proposal a
  /// departing member left behind. Without this the group keeps encrypting to
  /// someone who has already thrown their keys away.
  Future<MlsCommitOut> commitPendingProposals({
    required String groupIdB64,
    required String keyHandle,
  }) async => _serialized(
    groupIdB64,
    () => MlsCommitOut.fromJson(
      _ffi.invoke('commitPendingProposals', {
            'groupIdB64': groupIdB64,
            'keyHandle': keyHandle,
          })
          as Map<String, dynamic>,
    ),
  );

  /// Applies a staged commit the server accepted. Returns the resulting epoch.
  /// Safe to retry - merging with nothing staged is a no-op.
  Future<int> mergePendingCommit(String groupIdB64) async => _serialized(
    groupIdB64,
    () =>
        (_ffi.invoke('mergePendingCommit', {'groupIdB64': groupIdB64}) as num)
            .toInt(),
  );

  /// Throws away a staged commit the server refused, leaving the group where it
  /// was. This is the losing side of a concurrent-commit race.
  Future<void> clearPendingCommit(String groupIdB64) async => _serialized(
    groupIdB64,
    () => _ffi.invoke('clearPendingCommit', {'groupIdB64': groupIdB64}),
  );

  /// Forgets a group entirely. Call after being removed, after [leaveGroup], or
  /// for erasure - never merely because a context stopped being encrypted, since
  /// that context's old messages still need these keys.
  Future<void> deleteGroup(String groupIdB64) async {
    _ffi.invoke('deleteGroup', {'groupIdB64': groupIdB64});
    _queues.remove(groupIdB64);
  }

  // ---------------------------------------------------------------------------
  // Recovery
  // ---------------------------------------------------------------------------

  /// GroupInfo for external-commit recovery. Publish it with every commit: a
  /// group whose stored GroupInfo is older than its retained commits cannot be
  /// rejoined by a device that fell too far behind.
  Future<String> exportGroupInfo({
    required String groupIdB64,
    required String keyHandle,
  }) async =>
      _ffi.invoke('exportGroupInfo', {
            'groupIdB64': groupIdB64,
            'keyHandle': keyHandle,
          })
          as String;

  /// Rejoins by external commit after missing more commits than the server
  /// retains. The returned `externalCommit` must be published to the group.
  Future<MlsRejoinOut> rejoinGroup({
    required String groupInfoB64,
    required String keyHandle,
  }) async => MlsRejoinOut.fromJson(
    _ffi.invoke('rejoinGroup', {
          'groupInfoB64': groupInfoB64,
          'keyHandle': keyHandle,
        })
        as Map<String, dynamic>,
  );

  // ---------------------------------------------------------------------------
  // Messaging
  // ---------------------------------------------------------------------------

  /// Encrypts [plaintextB64] to the group.
  Future<MlsSendOut> sendMessage({
    required String groupIdB64,
    required String keyHandle,
    required String plaintextB64,
  }) async => _serialized(
    groupIdB64,
    () => MlsSendOut.fromJson(
      _ffi.invoke('sendMessage', {
            'groupIdB64': groupIdB64,
            'keyHandle': keyHandle,
            'plaintextB64': plaintextB64,
          })
          as Map<String, dynamic>,
    ),
  );

  /// Processes an incoming MLS message - application data, a commit, or a
  /// proposal. Commits are merged and the group advances; proposals are queued.
  ///
  /// Throws [MlsErrorKind.wrongEpoch] for a message from a future epoch: fetch
  /// the missing commits and retry rather than discarding it.
  Future<MlsProcessedMessage> processMessage({
    required String groupIdB64,
    required String messageB64,
  }) async => _serialized(
    groupIdB64,
    () => MlsProcessedMessage.fromJson(
      _ffi.invoke('processMessage', {
            'groupIdB64': groupIdB64,
            'messageB64': messageB64,
          })
          as Map<String, dynamic>,
    ),
  );

  // ---------------------------------------------------------------------------
  // Queries
  // ---------------------------------------------------------------------------

  /// The fingerprint for a signature public key, without a key package.
  ///
  /// For showing a device its *own* fingerprint. Minting a package just to
  /// inspect it would write a fresh init keypair into the engine's store on
  /// every call — permanently, since nothing ever consumes it — and the store is
  /// rewritten in full on every save, so the cost lands on every later encrypt
  /// and decrypt too. Same value either way; the Rust tests pin that.
  Future<String> fingerprintForSignatureKey(String signaturePublicKeyB64) async =>
      _ffi.invoke('fingerprintForSignatureKey', {
            'signingPublicKeyB64': signaturePublicKeyB64,
          })
          as String;

  /// Inspects a key package before vouching for it, or before adding it.
  ///
  /// Validated, not merely parsed — a reviewer must never be shown an identity
  /// lifted from something that would be refused at add time, or be talked into
  /// approving one whose signature does not actually check out.
  Future<MlsKeyPackageInfo> inspectKeyPackage(String keyPackageB64) async =>
      MlsKeyPackageInfo.fromJson(
        _ffi.invoke('inspectKeyPackage', {'keyPackageB64': keyPackageB64})
            as Map<String, dynamic>,
      );

  Future<List<MlsMemberInfo>> getMembers(String groupIdB64) async =>
      (_ffi.invoke('getMembers', {'groupIdB64': groupIdB64}) as List<dynamic>)
          .map((e) => MlsMemberInfo.fromJson(e as Map<String, dynamic>))
          .toList();

  Future<MlsGroupInfo> getGroupInfo(String groupIdB64) async =>
      MlsGroupInfo.fromJson(
        _ffi.invoke('getGroupInfo', {'groupIdB64': groupIdB64})
            as Map<String, dynamic>,
      );

  /// True when [senderIdentity] is in the group's current roster.
  ///
  /// Worth calling after decrypting an application message: a compromised
  /// server can replay a valid ciphertext with a spoofed credential, and the
  /// roster is what catches that.
  Future<bool> verifySenderInRoster({
    required String senderIdentity,
    required String groupIdB64,
  }) async {
    final members = await getMembers(groupIdB64);
    return members.any((m) => m.identity == senderIdentity);
  }

  // ---------------------------------------------------------------------------

  final _queues = <String, Future<void>>{};

  /// Serialises [op] behind any in-flight work on the same group.
  ///
  /// The engine locks internally, so this is not about data races - it is about
  /// ordering. Two interleaved operations on one group can stage a commit and
  /// then merge the other one's, and MLS gives no way back from that.
  Future<T> _serialized<T>(String groupId, T Function() op) {
    final previous = _queues[groupId] ?? Future<void>.value();
    final task = previous.then((_) => op(), onError: (_, _) => op());
    _queues[groupId] = task.then((_) {}, onError: (_, _) {});
    return task;
  }
}
