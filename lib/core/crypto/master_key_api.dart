import 'package:dio/dio.dart';

import '../network/api_client.dart';

/// The wrapped account master key, exactly as the server stores it on
/// `ApplicationUser.EncryptedMasterKey`.
///
/// Opaque to the server: it holds the ciphertext, the salt, the IV and the
/// Argon2 parameters, and nothing that can derive the key. The parameters travel
/// with the envelope rather than being assumed, so a key wrapped under older
/// ones still opens after they are raised.
class EncryptedMasterKeyDto {
  const EncryptedMasterKeyDto({
    required this.cipherText,
    required this.salt,
    required this.iv,
    required this.argon2Iterations,
    required this.argon2Memory,
    required this.argon2Parallelism,
    required this.version,
  });

  factory EncryptedMasterKeyDto.fromJson(Map<String, dynamic> json) =>
      EncryptedMasterKeyDto(
        cipherText: json['cipherText'] as String? ?? '',
        salt: json['salt'] as String? ?? '',
        iv: json['iv'] as String? ?? '',
        argon2Iterations: (json['argon2Iterations'] as num?)?.toInt() ?? 3,
        argon2Memory: (json['argon2Memory'] as num?)?.toInt() ?? 65536,
        argon2Parallelism: (json['argon2Parallelism'] as num?)?.toInt() ?? 1,
        version: (json['version'] as num?)?.toInt() ?? 1,
      );

  factory EncryptedMasterKeyDto.fromEngine(Map<String, Object?> json) =>
      EncryptedMasterKeyDto.fromJson(Map<String, dynamic>.from(json));

  final String cipherText;
  final String salt;
  final String iv;
  final int argon2Iterations;
  final int argon2Memory;
  final int argon2Parallelism;

  /// Bumping this invalidates every backup blob sealed under the previous one -
  /// see contract §C.1's orphan handling.
  final int version;

  Map<String, Object?> toJson() => {
    'cipherText': cipherText,
    'salt': salt,
    'iv': iv,
    'argon2Iterations': argon2Iterations,
    'argon2Memory': argon2Memory,
    'argon2Parallelism': argon2Parallelism,
    'version': version,
  };

  bool get isUsable => cipherText.isNotEmpty && salt.isNotEmpty && iv.isNotEmpty;
}

/// The account's recovery-key state: both wrappings of the one master key, plus
/// what the server knows about whether either still opens.
///
/// Contract §C.1.1. The master key is wrapped twice under independently-derived
/// keys, so a password reset - which invalidates the password wrapping and
/// nothing else - is survivable.
class RecoveryKeyStateDto {
  const RecoveryKeyStateDto({
    required this.version,
    required this.passwordWrapping,
    required this.recoveryCodeWrapping,
    required this.passwordWrappingInvalidatedAt,
    required this.encryptedHistoryRecoverable,
  });

  factory RecoveryKeyStateDto.fromJson(Map<String, dynamic> json) {
    // The legacy `POST /users/master` shape put the password wrapping at the top
    // level. Reading both keeps an account that predates §C.1.1 openable.
    final nested = json['passwordWrapping'];
    final password = nested is Map
        ? EncryptedMasterKeyDto.fromJson(Map<String, dynamic>.from(nested))
        : EncryptedMasterKeyDto.fromJson(json);
    final recovery = json['recoveryCodeWrapping'];

    return RecoveryKeyStateDto(
      version: (json['version'] as num?)?.toInt() ?? password.version,
      passwordWrapping: password.isUsable ? password : null,
      recoveryCodeWrapping: recovery is Map
          ? EncryptedMasterKeyDto.fromJson(Map<String, dynamic>.from(recovery))
          : null,
      passwordWrappingInvalidatedAt: DateTime.tryParse(
        json['passwordWrappingInvalidatedAt'] as String? ?? '',
      ),
      // Absent means a server that predates the flag; assume recoverable rather
      // than alarming every user during a deploy skew.
      encryptedHistoryRecoverable:
          json['encryptedHistoryRecoverable'] as bool? ?? true,
    );
  }

  final int version;

  /// Null once a password reset has invalidated it.
  final EncryptedMasterKeyDto? passwordWrapping;

  /// Null on an account created before §C.1.1 - which is every existing one, and
  /// each is a single password reset away from losing everything.
  final EncryptedMasterKeyDto? recoveryCodeWrapping;

  /// When a password reset made the password wrapping undecryptable. The client
  /// owes a re-wrap from the recovery code on next unlock.
  final DateTime? passwordWrappingInvalidatedAt;

  /// **False is a completed loss, not a warning about the future**: a reset
  /// invalidated the password wrapping and there was no recovery-code wrapping
  /// to fall back on, so every backup blob and the account identity key are
  /// already gone. Surfaced as such.
  final bool encryptedHistoryRecoverable;

  bool get hasRecoveryCodeWrapping => recoveryCodeWrapping != null;

  /// True when the password wrapping needs rebuilding from the recovery code.
  bool get needsPasswordRewrap =>
      passwordWrappingInvalidatedAt != null || passwordWrapping == null;
}

/// Transport for the account master key and the account identity key.
///
/// Both are per account rather than per device, both are stored wrapped, and the
/// server can read neither - which is what lets contract §G verify a device
/// admission without trusting it, and §H verify a device certificate with none
/// of the account's devices online.
class MasterKeyApi {
  MasterKeyApi({required this.client});

  final ApiClient client;

  String get _base => '/api/v1/identity';

  /// Both wrappings plus the recoverability flags (contract §C.1.1).
  ///
  /// Null when this account never set one up, which is the ordinary state of an
  /// account that predates encryption rather than an error - `MasterKeyService`
  /// mints one on the next unlock.
  Future<RecoveryKeyStateDto?> fetchRecoveryKey() async {
    try {
      final response = await client.dio.get<Map<String, dynamic>>(
        client.url('/api/v1/backup/recovery-key'),
      );
      final data = response.data;
      if (data == null || data.isEmpty) return null;
      return RecoveryKeyStateDto.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode != 404) rethrow;
    }

    // Fall back to the legacy single-wrapping route so a client that ships ahead
    // of the server still unlocks. An account read this way has no
    // recovery-code wrapping by definition.
    final legacy = await fetch();
    if (legacy == null) return null;
    return RecoveryKeyStateDto(
      version: legacy.version,
      passwordWrapping: legacy,
      recoveryCodeWrapping: null,
      passwordWrappingInvalidatedAt: null,
      encryptedHistoryRecoverable: true,
    );
  }

  /// Stores both wrappings. They seal the same bytes, so they share [version].
  Future<void> putRecoveryKey({
    required int version,
    required EncryptedMasterKeyDto passwordWrapping,
    required EncryptedMasterKeyDto recoveryCodeWrapping,
    bool acknowledgeOrphans = false,
  }) async {
    await client.dio.put<void>(
      client.url('/api/v1/backup/recovery-key'),
      queryParameters: {if (acknowledgeOrphans) 'acknowledgeOrphans': true},
      data: {
        'version': version,
        ...passwordWrapping.toJson(),
        'recoveryCodeWrapping': recoveryCodeWrapping.toJson(),
      },
    );
  }

  /// Replaces the password wrapping after a reset, from a master key recovered
  /// through the recovery code.
  ///
  /// Deliberately carries **no password check**: producing a valid wrapping *is*
  /// the proof, and requiring the password would gate recovery on the very thing
  /// that was just reset. Re-wraps rather than rotates, so blobs already sealed
  /// under this master key stay readable - [version] must match, and the server
  /// answers 409 otherwise.
  Future<void> rewrapPassword({
    required int version,
    required EncryptedMasterKeyDto passwordWrapping,
  }) async {
    await client.dio.post<void>(
      client.url('/api/v1/backup/recovery-key/rewrap-password'),
      data: {'version': version, ...passwordWrapping.toJson()},
    );
  }

  /// The legacy single-wrapping read, for [fetchRecoveryKey]'s fallback only.
  Future<EncryptedMasterKeyDto?> fetch() async {
    try {
      final response = await client.dio.get<Map<String, dynamic>>(
        client.url('$_base/users/master'),
      );
      final data = response.data;
      if (data == null || data.isEmpty) return null;
      final dto = EncryptedMasterKeyDto.fromJson(data);
      return dto.isUsable ? dto : null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// The legacy write, which stores the **password wrapping only**.
  ///
  /// An account written this way is one password reset from losing every backup
  /// blob and its account identity key, with no other way to find that out -
  /// which is why the response's `hasRecoveryCodeWrapping` is returned rather
  /// than discarded. Prefer [putRecoveryKey].
  Future<bool> upload(EncryptedMasterKeyDto envelope) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      client.url('$_base/users/master'),
      data: envelope.toJson(),
    );
    return response.data?['hasRecoveryCodeWrapping'] as bool? ?? false;
  }

  /// The **public** half of the account identity key (contract §H.2).
  ///
  /// Fetched for peers as well as for self: this is the value a peer TOFU-pins,
  /// the way Signal pins a safety number, and it is what makes a device
  /// certificate mean anything.
  Future<String?> fetchIdentityKey(String userId) async {
    try {
      final response = await client.dio.get<Map<String, dynamic>>(
        client.url('$_base/users/${Uri.encodeComponent(userId)}/identity-key'),
      );
      final key = response.data?['identityPublicKey'] as String?;
      return (key == null || key.isEmpty) ? null : key;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Publishes this account's identity public key. The private half never
  /// leaves the client unwrapped.
  Future<void> uploadIdentityKey({
    required String identityPublicKey,
    String? wrappedPrivateKey,
    String? continuitySignature,
  }) async {
    await client.dio.put<void>(
      client.url('$_base/users/identity-key'),
      data: {
        'identityPublicKey': identityPublicKey,
        // Wrapped under the master key, so the server stores it and cannot read
        // it. Without this a full-loss recovery has nothing to restore from -
        // see §H.1.
        'wrappedPrivateKey': ?wrappedPrivateKey,
        // §H.5: signed by the outgoing key where possible, so peers can verify
        // continuity automatically instead of being asked to re-verify a safety
        // number they have no way to check.
        'continuitySignature': ?continuitySignature,
      },
    );
  }
}
