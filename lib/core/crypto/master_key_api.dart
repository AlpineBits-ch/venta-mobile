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
    this.kdf = 'argon2id',
    this.publicVerifier,
  });

  /// The **engine** shape: what `venta_mls`'s `EncryptedMasterKey` serialises
  /// to, and what the legacy `POST users/master` route happens to use as well.
  ///
  /// Distinct from [fromWire] on purpose. `GET/PUT backup/recovery-key` names
  /// the same three Argon2 parameters `iterations`/`memoryKiB`/`parallelism`,
  /// and reading that body through this constructor silently fell back to the
  /// compiled-in defaults - which is exactly the "hardcoded on the reading side"
  /// failure contract §D warns about, invisible until a key wrapped under
  /// different parameters refuses to open.
  factory EncryptedMasterKeyDto.fromJson(Map<String, dynamic> json) =>
      EncryptedMasterKeyDto(
        cipherText: json['cipherText'] as String? ?? '',
        salt: json['salt'] as String? ?? '',
        iv: json['iv'] as String? ?? '',
        argon2Iterations: (json['argon2Iterations'] as num?)?.toInt() ?? 3,
        argon2Memory: (json['argon2Memory'] as num?)?.toInt() ?? 65536,
        argon2Parallelism: (json['argon2Parallelism'] as num?)?.toInt() ?? 1,
        version: (json['version'] as num?)?.toInt() ?? 1,
        kdf: json['kdf'] as String? ?? 'argon2id',
        publicVerifier: json['publicVerifier'] as String?,
      );

  factory EncryptedMasterKeyDto.fromEngine(Map<String, Object?> json) =>
      EncryptedMasterKeyDto.fromJson(Map<String, dynamic>.from(json));

  /// The **wire** shape of `backup/recovery-key`: `MasterKeyWrappingDto`
  /// server-side, which carries no version of its own - both wrappings of one
  /// key share the envelope's.
  factory EncryptedMasterKeyDto.fromWire(
    Map<String, dynamic> json, {
    required int version,
  }) => EncryptedMasterKeyDto(
    cipherText: json['cipherText'] as String? ?? '',
    salt: json['salt'] as String? ?? '',
    iv: json['iv'] as String? ?? '',
    // The `argon2*` fallbacks keep a body written by the legacy route readable
    // through the same type; they are not the primary names here.
    argon2Iterations: _int(json, const ['iterations', 'argon2Iterations'], 3),
    argon2Memory: _int(json, const ['memoryKiB', 'argon2Memory'], 65536),
    argon2Parallelism: _int(json, const ['parallelism', 'argon2Parallelism'], 1),
    version: version,
    kdf: json['kdf'] as String? ?? 'argon2id',
    publicVerifier: json['publicVerifier'] as String?,
  );

  final String cipherText;
  final String salt;
  final String iv;
  final int argon2Iterations;
  final int argon2Memory;
  final int argon2Parallelism;
  final String kdf;

  /// Derived from the master key - never from the password - so the server can
  /// confirm that two wrappings seal the same bytes without ever holding them.
  ///
  /// **Null from this client.** No engine on any of the three repos derives one
  /// yet, and inventing a construction here unilaterally is how §C.1.2 happened.
  /// It is carried through reads and writes so a value the server already stores
  /// is echoed back unchanged rather than being dropped and re-established.
  final String? publicVerifier;

  /// Bumping this invalidates every backup blob sealed under the previous one -
  /// see contract §C.1's orphan handling.
  final int version;

  /// The engine shape, which the legacy `POST users/master` route happens to
  /// share. Fed straight to `decryptMasterKey`, so the field set is what the
  /// Rust struct expects and nothing else.
  Map<String, Object?> toJson() => {
    'cipherText': cipherText,
    'salt': salt,
    'iv': iv,
    'argon2Iterations': argon2Iterations,
    'argon2Memory': argon2Memory,
    'argon2Parallelism': argon2Parallelism,
    'version': version,
    // §L.11. Omitted rather than sent as null when absent, so an envelope read
    // back from an account that predates the field round-trips unchanged - and
    // so the legacy first write establishes it where the engine produced one.
    if (publicVerifier != null) 'publicVerifier': publicVerifier,
  };

  /// The `backup/recovery-key` wire shape.
  Map<String, Object?> toWire() => {
    'kdf': kdf,
    'iterations': argon2Iterations,
    'memoryKiB': argon2Memory,
    'parallelism': argon2Parallelism,
    'salt': salt,
    'iv': iv,
    'cipherText': cipherText,
    if (publicVerifier != null) 'publicVerifier': publicVerifier,
  };

  bool get isUsable => cipherText.isNotEmpty && salt.isNotEmpty && iv.isNotEmpty;

  /// First of [names] that carries a number, else [fallback].
  ///
  /// A fallback rather than a throw because a wrapping that cannot be parsed is
  /// still worth carrying - but note that a *wrong* parameter here does not
  /// silently produce garbage: Argon2 derives a different wrap key and the AEAD
  /// refuses, so this fails closed.
  static int _int(Map<String, dynamic> json, List<String> names, int fallback) {
    for (final name in names) {
      final value = json[name];
      if (value is num) return value.toInt();
    }
    return fallback;
  }
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
    final version = (json['version'] as num?)?.toInt() ?? 1;

    // `RecoveryKeyDto` server-side: the password wrapping is flattened onto the
    // envelope, the recovery-code one is nested. The `passwordWrapping` branch
    // is kept for the legacy `POST users/master` shape, which nests nothing but
    // which some deployments still answer with.
    final nested = json['passwordWrapping'];
    final password = nested is Map
        ? EncryptedMasterKeyDto.fromWire(
            Map<String, dynamic>.from(nested),
            version: version,
          )
        : EncryptedMasterKeyDto.fromWire(json, version: version);
    final recovery = json['recoveryCodeWrapping'];

    return RecoveryKeyStateDto(
      version: version,
      passwordWrapping: password.isUsable ? password : null,
      recoveryCodeWrapping: recovery is Map
          ? EncryptedMasterKeyDto.fromWire(
              Map<String, dynamic>.from(recovery),
              version: version,
            )
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

  /// Every identity-service route goes through the gateway's `/api/v1/identity`
  /// prefix, which YARP rewrites to `/api/v1` before it reaches the service.
  /// These three used to be spelled `/api/v1/backup/...`, which matches no
  /// gateway route at all - so the whole of §C.1.1 answered 404 in production
  /// while passing every unit test, because the tests mock the API.
  String get _recoveryKey => client.url('$_base/backup/recovery-key');

  /// Both wrappings plus the recoverability flags (contract §C.1.1).
  ///
  /// Null when this account never set one up, which is the ordinary state of an
  /// account that predates encryption rather than an error - `MasterKeyService`
  /// mints one on the next unlock.
  Future<RecoveryKeyStateDto?> fetchRecoveryKey() async {
    try {
      final response = await client.dio.get<Map<String, dynamic>>(
        _recoveryKey,
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
  ///
  /// [password] is not optional server-side: writing this envelope is what makes
  /// every backup blob readable, so it is gated on proving the account rather
  /// than merely holding a token for it (§C.1, "requires re-authentication").
  ///
  /// At an **unchanged** version this is the §J.2 additive path - the password
  /// wrapping must be echoed back byte-identical and only the recovery-code side
  /// is new. At a **higher** version it is a rotation, which orphans blobs and
  /// which the server refuses without a `publicVerifier`. This client never
  /// rotates, so it never establishes key material through here.
  Future<void> putRecoveryKey({
    required int version,
    required EncryptedMasterKeyDto passwordWrapping,
    required EncryptedMasterKeyDto recoveryCodeWrapping,
    required String password,
    bool acknowledgeOrphans = false,
  }) async {
    await client.dio.put<void>(
      _recoveryKey,
      queryParameters: {if (acknowledgeOrphans) 'acknowledgeOrphans': true},
      data: {
        'version': version,
        'password': password,
        ...passwordWrapping.toWire(),
        'recoveryCodeWrapping': recoveryCodeWrapping.toWire(),
      },
    );
  }

  /// Replaces the password wrapping after a reset, from a master key recovered
  /// through the recovery code.
  ///
  /// Re-wraps rather than rotates, so blobs already sealed under this master key
  /// stay readable - [version] must match, and the server answers 409 otherwise.
  ///
  /// **Contract §J.2 says this route deliberately carries no credential** on the
  /// reasoning that producing a valid wrapping is itself the proof. It does not:
  /// nothing verified the wrapping, so the route was an unauthenticated
  /// destructive write, and §L.8 closed it. Exactly one of [password] or
  /// [rewrapTicket] is now required - the ticket being what the reset itself
  /// hands back, for the journey where there is no usable password by
  /// definition.
  Future<void> rewrapPassword({
    required int version,
    required EncryptedMasterKeyDto passwordWrapping,
    String? password,
    String? rewrapTicket,
  }) async {
    await client.dio.post<void>(
      '$_recoveryKey/rewrap-password',
      data: {
        'version': version,
        'passwordWrapping': passwordWrapping.toWire(),
        if (password != null) 'password': password,
        if (rewrapTicket != null) 'rewrapTicket': rewrapTicket,
      },
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

  /// The **public** half of the account identity key (contract §H.2), with the
  /// version it was published at.
  ///
  /// Fetched for peers as well as for self: this is the value a peer TOFU-pins,
  /// the way Signal pins a safety number, and it is what makes a device
  /// certificate mean anything.
  ///
  /// Null means "this account has published none" - a 404, which §I.2 says is
  /// the ordinary state of every account in the field.
  Future<PublishedIdentityKey?> fetchIdentityKey(String userId) async {
    try {
      final response = await client.dio.get<Map<String, dynamic>>(
        client.url('$_base/users/${Uri.encodeComponent(userId)}/identity-key'),
      );
      // `AccountIdentityKeyDto.PublicKey`, camel-cased by the serializer. This
      // used to read `identityPublicKey`, a name the server has never sent, so
      // it answered null for accounts that *did* have a key - which is the one
      // answer that licenses minting a second one.
      final key = response.data?['publicKey'] as String?;
      if (key == null || key.isEmpty) return null;
      return PublishedIdentityKey(
        publicKey: key,
        version: (response.data?['version'] as num?)?.toInt() ?? 1,
        rotationSignature: response.data?['rotationSignature'] as String?,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Publishes this account's identity public key, or rotates it. The private
  /// half never leaves the client unwrapped.
  ///
  /// [version] must exceed the stored one, so a first publication is 1.
  ///
  /// **[password] is required for a first publication too**, which §J.2's
  /// "first publication needs no password" does not say. Whoever publishes first
  /// is who every peer TOFU-pins and what every device certificate chains to, so
  /// it is the same power as a rotation acquired for less - the server gates
  /// both. The consequence for this client is that the identity key can only be
  /// established at a moment the password is in hand.
  Future<void> uploadIdentityKey({
    required String identityPublicKey,
    required String password,
    int version = 1,
    String? deviceId,
    String? continuitySignature,
  }) async {
    await client.dio.put<void>(
      client.url('$_base/users/identity-key'),
      data: {
        'publicKey': identityPublicKey,
        'version': version,
        'password': password,
        // Audit only - the server records the session-derived device anyway and
        // treats this as a hint.
        'deviceId': ?deviceId,
        // §H.5: signed by the outgoing key where possible, so peers can verify
        // continuity automatically instead of being asked to re-verify a safety
        // number they have no way to check.
        'rotationSignature': ?continuitySignature,
      },
    );
  }
}

/// An account identity key as the server serves it (§H.2).
class PublishedIdentityKey {
  const PublishedIdentityKey({
    required this.publicKey,
    required this.version,
    this.rotationSignature,
  });

  final String publicKey;

  /// Monotonic, so a peer can tell a rotation from a replay of a superseded key.
  final int version;

  /// Present when the outgoing key signed the incoming one. Absent means peers
  /// must re-verify out of band rather than auto-accept (§H.5).
  final String? rotationSignature;
}
