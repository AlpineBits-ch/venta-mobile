/// Result shapes returned by the engine. Field-for-field with Alpine's
/// `mls.service.ts` interfaces - the JSON they decode from is produced by the
/// same Rust structs.
library;

class KeyPackageResult {
  const KeyPackageResult({required this.keyPackage, required this.initPrivateKey});

  factory KeyPackageResult.fromJson(Map<String, dynamic> json) =>
      KeyPackageResult(
        keyPackage: json['keyPackage'] as String,
        initPrivateKey: json['initPrivateKey'] as String,
      );

  /// TLS-serialized KeyPackage, base64. This is what gets uploaded.
  final String keyPackage;

  /// HPKE init private key, base64. Held by the engine's own storage; exposed
  /// only because Alpine's shape has it.
  final String initPrivateKey;
}

class MlsKeyPackageBatch {
  const MlsKeyPackageBatch({
    required this.signingPublicKey,
    required this.signingPrivateKey,
    required this.keyPackages,
    required this.keyHandle,
  });

  factory MlsKeyPackageBatch.fromJson(Map<String, dynamic> json) =>
      MlsKeyPackageBatch(
        signingPublicKey: json['signingPublicKey'] as String,
        signingPrivateKey: json['signingPrivateKey'] as String,
        keyPackages: (json['keyPackages'] as List<dynamic>)
            .map((e) => KeyPackageResult.fromJson(e as Map<String, dynamic>))
            .toList(),
        keyHandle: json['keyHandle'] as String,
      );

  /// Ed25519 public key, base64. Also what the device registration publishes as
  /// its `identityPublicKey`.
  final String signingPublicKey;

  /// Ed25519 private key, base64. Goes straight into the OS keychain and is
  /// never held in Dart longer than it takes to store it.
  final String signingPrivateKey;

  final List<KeyPackageResult> keyPackages;

  /// Opaque handle for this session's group operations - the private key bytes
  /// do not cross the FFI boundary again.
  final String keyHandle;
}

class MlsMemberInfo {
  const MlsMemberInfo({
    required this.leafIndex,
    required this.identity,
    required this.encryptionKey,
    required this.signatureKey,
  });

  factory MlsMemberInfo.fromJson(Map<String, dynamic> json) => MlsMemberInfo(
    leafIndex: json['leafIndex'] as int,
    identity: json['identity'] as String,
    encryptionKey: json['encryptionKey'] as String,
    signatureKey: json['signatureKey'] as String,
  );

  final int leafIndex;

  /// The member's user id - what the BasicCredential carries.
  final String identity;
  final String encryptionKey;
  final String signatureKey;
}

class MlsGroupInfo {
  const MlsGroupInfo({
    required this.groupId,
    required this.epoch,
    required this.ownLeafIndex,
    required this.members,
  });

  factory MlsGroupInfo.fromJson(Map<String, dynamic> json) => MlsGroupInfo(
    groupId: json['groupId'] as String,
    epoch: (json['epoch'] as num).toInt(),
    ownLeafIndex: json['ownLeafIndex'] as int,
    members: (json['members'] as List<dynamic>)
        .map((e) => MlsMemberInfo.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  final String groupId;
  final int epoch;
  final int ownLeafIndex;
  final List<MlsMemberInfo> members;
}

/// A staged commit. [commit] goes to every current member; [welcome], when
/// present, goes only to the devices the commit adds.
class MlsCommitOut {
  const MlsCommitOut({
    required this.commit,
    required this.welcome,
    required this.epoch,
    this.groupInfo,
  });

  factory MlsCommitOut.fromJson(Map<String, dynamic> json) => MlsCommitOut(
    commit: json['commit'] as String,
    welcome: json['welcome'] as String?,
    epoch: (json['epoch'] as num).toInt(),
    groupInfo: json['groupInfo'] as String?,
  );

  final String commit;
  final String? welcome;

  /// Epoch this commit establishes once merged.
  final int epoch;

  /// GroupInfo for the epoch this commit **establishes**, produced by the
  /// commit itself.
  ///
  /// Publish this rather than calling [VentaMls.exportGroupInfo]. An exported
  /// GroupInfo can only describe the epoch the group is on *now*, and a commit
  /// is deliberately not merged until the server accepts it — so every
  /// published GroupInfo used to be one epoch stale, and a device recovering by
  /// external commit landed behind the group it was rejoining.
  final String? groupInfo;
}

/// `buffered` means the message is from an epoch this device has not reached
/// yet. It is held rather than dropped — the wire copy decrypts exactly once —
/// and [VentaMls.drainPendingMessages] returns it once the missing commits have
/// been applied.
enum MlsMessageKind { application, commit, proposal, buffered }

class MlsProcessedMessage {
  const MlsProcessedMessage({
    required this.kind,
    required this.plaintext,
    required this.selfRemoved,
    required this.addedMembers,
    required this.removedLeafIndices,
    required this.senderIdentity,
    required this.epoch,
  });

  factory MlsProcessedMessage.fromJson(Map<String, dynamic> json) =>
      MlsProcessedMessage(
        kind: switch (json['kind'] as String) {
          'application' => MlsMessageKind.application,
          'commit' => MlsMessageKind.commit,
          'buffered' => MlsMessageKind.buffered,
          _ => MlsMessageKind.proposal,
        },
        plaintext: json['plaintext'] as String?,
        selfRemoved: json['selfRemoved'] as bool? ?? false,
        addedMembers: (json['addedMembers'] as List<dynamic>? ?? const [])
            .map((e) => MlsMemberInfo.fromJson(e as Map<String, dynamic>))
            .toList(),
        removedLeafIndices:
            (json['removedLeafIndices'] as List<dynamic>? ?? const [])
                .map((e) => e as int)
                .toList(),
        senderIdentity: json['senderIdentity'] as String?,
        epoch: (json['epoch'] as num?)?.toInt(),
      );

  final MlsMessageKind kind;

  /// Decrypted bytes, base64. Only set for [MlsMessageKind.application].
  final String? plaintext;

  /// True when the commit removed *this* device from the group.
  final bool selfRemoved;

  final List<MlsMemberInfo> addedMembers;
  final List<int> removedLeafIndices;
  final String? senderIdentity;

  /// Epoch after applying the commit. Only set for [MlsMessageKind.commit].
  final int? epoch;
}

class MlsSendOut {
  const MlsSendOut({required this.ciphertext, required this.epoch});

  factory MlsSendOut.fromJson(Map<String, dynamic> json) => MlsSendOut(
    ciphertext: json['ciphertext'] as String,
    epoch: (json['epoch'] as num).toInt(),
  );

  final String ciphertext;
  final int epoch;
}

/// What a reviewer is shown before vouching for someone's admission to an
/// encrypted context.
class MlsKeyPackageInfo {
  const MlsKeyPackageInfo({
    required this.identity,
    required this.signaturePublicKey,
    required this.signatureKeyFingerprint,
    required this.keyPackageHash,
  });

  factory MlsKeyPackageInfo.fromJson(Map<String, dynamic> json) =>
      MlsKeyPackageInfo(
        identity: json['identity'] as String,
        signaturePublicKey: json['signaturePublicKey'] as String,
        signatureKeyFingerprint: json['signatureKeyFingerprint'] as String,
        keyPackageHash: json['keyPackageHash'] as String,
      );

  /// The user id this package claims, from its BasicCredential.
  final String identity;

  /// Long-lived Ed25519 signature key, base64.
  final String signaturePublicKey;

  /// Human-comparable fingerprint of the *signature* key, in five-character
  /// groups.
  ///
  /// Stable across every key package a device mints, which is what makes it
  /// usable out of band — a per-package value would differ on every request and
  /// two people could never agree on it over a call.
  final String signatureKeyFingerprint;

  /// SHA-256 of the key package bytes, hex. Binds an approval to these exact
  /// bytes.
  final String keyPackageHash;
}

class MlsRejoinOut {
  const MlsRejoinOut({required this.groupInfo, required this.externalCommit});

  factory MlsRejoinOut.fromJson(Map<String, dynamic> json) => MlsRejoinOut(
    groupInfo: MlsGroupInfo.fromJson(json['groupInfo'] as Map<String, dynamic>),
    externalCommit: json['externalCommit'] as String,
  );

  final MlsGroupInfo groupInfo;
  final String externalCommit;
}

/// An account's long-lived Ed25519 identity key (contract §H.2).
///
/// Not the device signing key. This one belongs to the *account*, is wrapped
/// under the recovery key and travels in the backup envelope, and is what lets a
/// peer verify offline that a device genuinely belongs to an account — with none
/// of that account's devices online, and without trusting the server, which
/// never holds the private half.
class MlsAccountIdentity {
  const MlsAccountIdentity({required this.publicKey, required this.privateKey});

  factory MlsAccountIdentity.fromJson(Map<String, dynamic> json) =>
      MlsAccountIdentity(
        publicKey: json['publicKey'] as String,
        privateKey: json['privateKey'] as String,
      );

  final String publicKey;
  final String privateKey;
}

/// What opening a `.venta-keys` envelope produced (contract §D).
class MlsBackupImportResult {
  const MlsBackupImportResult({
    required this.userId,
    required this.deviceId,
    required this.createdAt,
    required this.appVersion,
    required this.identity,
    required this.keyHandle,
    required this.signingPublicKey,
    required this.signingPrivateKey,
    required this.engineRestored,
    required this.groupRegistry,
    required this.messageCache,
    required this.accountIdentityPublicKey,
    required this.accountIdentityPrivateKey,
  });

  factory MlsBackupImportResult.fromJson(Map<String, dynamic> json) =>
      MlsBackupImportResult(
        userId: json['userId'] as String,
        deviceId: json['deviceId'] as String,
        createdAt: json['createdAt'] as String? ?? '',
        appVersion: json['appVersion'] as String? ?? '',
        identity: json['identity'] as String,
        keyHandle: json['keyHandle'] as String,
        signingPublicKey: json['signingPublicKey'] as String,
        signingPrivateKey: json['signingPrivateKey'] as String,
        engineRestored: json['engineRestored'] as bool? ?? false,
        groupRegistry: Map<String, Object>.from(
          (json['groupRegistry'] as Map?) ?? const {},
        ),
        messageCache: Map<String, String>.from(
          (json['messageCache'] as Map?) ?? const {},
        ),
        accountIdentityPublicKey: json['accountIdentityPublicKey'] as String?,
        accountIdentityPrivateKey: json['accountIdentityPrivateKey'] as String?,
      );

  final String userId;

  /// The device the backup was taken on — **not** necessarily this one.
  final String deviceId;
  final String createdAt;
  final String appVersion;

  /// The BasicCredential identity the restored signing key carries.
  final String identity;

  /// Session handle for the restored signing key, immediately usable.
  final String keyHandle;

  /// The restored signing keypair. Handed back because this client keeps it in
  /// the OS keychain rather than in the engine's store — a restore that only
  /// loaded it into memory would work until the app was next killed, and then
  /// look exactly like lost keys.
  final String signingPublicKey;
  final String signingPrivateKey;

  /// False on a new device, where cloning ratchet state would be unsafe. When
  /// false the caller owes a re-join per encrypted context — the registry came
  /// across, but the groups it names did not.
  final bool engineRestored;

  final Map<String, Object> groupRegistry;
  final Map<String, String> messageCache;

  /// Present only when the envelope carried an account identity key. Absent for
  /// blobs written before §H, and for accounts that never had one — which §I.2
  /// says is the normal state until an upgraded client unlocks them.
  final String? accountIdentityPublicKey;
  final String? accountIdentityPrivateKey;
}

/// A message that arrived early and became readable once its commit was applied.
///
/// MLS decrypts a message from the wire exactly once, so an early arrival that
/// was simply dropped is gone for good. `pending_messages` was declared,
/// retained and cleared in both engines but never actually written to, so the
/// promised buffer did not exist.
class MlsReplayedMessage {
  const MlsReplayedMessage({
    required this.messageId,
    required this.plaintext,
    required this.senderIdentity,
    required this.epoch,
  });

  factory MlsReplayedMessage.fromJson(Map<String, dynamic> json) =>
      MlsReplayedMessage(
        messageId: json['messageId'] as String?,
        plaintext: json['plaintext'] as String,
        senderIdentity: json['senderIdentity'] as String?,
        epoch: (json['epoch'] as num).toInt(),
      );

  /// The id supplied when the message was first handed to
  /// [VentaMls.processMessage], so the caller can match it back to the row it
  /// rendered as undecryptable.
  final String? messageId;

  /// Decrypted bytes, base64.
  final String plaintext;
  final String? senderIdentity;
  final int epoch;
}
