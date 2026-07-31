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
  });

  factory MlsCommitOut.fromJson(Map<String, dynamic> json) => MlsCommitOut(
    commit: json['commit'] as String,
    welcome: json['welcome'] as String?,
    epoch: (json['epoch'] as num).toInt(),
  );

  final String commit;
  final String? welcome;

  /// Epoch this commit establishes once merged.
  final int epoch;
}

enum MlsMessageKind { application, commit, proposal }

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
