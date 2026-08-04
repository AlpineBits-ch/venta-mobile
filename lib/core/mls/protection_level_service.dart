import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:venta_mls/venta_mls.dart';

import '../crypto/account_identity_service.dart';
import '../crypto/master_key_api.dart';
import '../crypto/master_key_service.dart';
import '../network/api_client.dart';
import '../storage/secure_storage_service.dart';

/// How an account admits a new device. Contract §G.
enum ProtectionLevel {
  /// Automatic, on proof of the account master key. The default, because
  /// requiring a human to approve every device strands anyone who reinstalls at
  /// 2am with no second device to hand.
  ///
  /// Honest limitation: it reduces to the password's strength. It still defends
  /// against a malicious server and a network attacker, because the proof is
  /// verified locally against a key the server never holds.
  trustedSignIn,

  /// Automatic proof **plus** a human approving on an existing device. Also
  /// defends against someone who knows the password - and makes losing every
  /// device and the recovery code unrecoverable, which the UI must say out loud
  /// before anyone opts in.
  verifiedDevices,
}

extension ProtectionLevelWire on ProtectionLevel {
  String get wireName => switch (this) {
    ProtectionLevel.trustedSignIn => 'TrustedSignIn',
    ProtectionLevel.verifiedDevices => 'VerifiedDevices',
  };

  String get label => switch (this) {
    ProtectionLevel.trustedSignIn => 'Trusted sign-in',
    ProtectionLevel.verifiedDevices => 'Verified devices',
  };
}

/// A protection level plus the assertion that proves the account chose it.
class ProtectionLevelState {
  const ProtectionLevelState({
    required this.level,
    required this.version,
    required this.updatedAt,
    required this.verified,
  });

  final ProtectionLevel level;
  final int version;
  final String updatedAt;

  /// False when the assertion could not be checked against the account identity
  /// key. Callers must treat an unverified level as [ProtectionLevel.verifiedDevices]
  /// - see [ProtectionLevelService.effectiveLevel].
  final bool verified;
}

/// Reads, verifies and enforces the account's protection level (contract §G.3).
///
/// The level must **not** be a plain server-side boolean. If it were, a server
/// could silently downgrade a `VerifiedDevices` account to `TrustedSignIn` and
/// then auto-admit its own device, which defeats the strict tier entirely. So it
/// travels as an assertion signed by the account identity key, every client
/// checks it independently, and an unsigned or wrongly-signed level is
/// **rejected rather than defaulted**.
///
/// Everything here fails **closed**: when the level cannot be verified, the
/// effective level is the stricter one. That is the opposite of
/// [MlsPolicyService], and deliberately so - guessing strict here costs a user
/// one extra approval tap, while guessing strict there destroys groups.
class ProtectionLevelService {
  ProtectionLevelService({
    required this.client,
    required this.identity,
    required this.masterKeyApi,
    required this.masterKeys,
    required this.secureStorage,
    VentaMls? engine,
  }) : _engine = engine ?? VentaMls();

  final ApiClient client;
  final AccountIdentityService identity;
  final MasterKeyApi masterKeyApi;

  /// Consulted before entering VerifiedDevices: that tier's only recovery
  /// credential is the recovery code, so an account without one must not be
  /// allowed in.
  final MasterKeyService masterKeys;
  final SecureStorageService secureStorage;
  final VentaMls _engine;

  final ValueNotifier<ProtectionLevelState?> state =
      ValueNotifier<ProtectionLevelState?>(null);

  /// True when a level arrived that this device could not verify, or that
  /// downgraded without this device taking part. §G.3 says warn loudly.
  final ValueNotifier<String?> warning = ValueNotifier<String?>(null);

  /// What to actually enforce.
  ///
  /// Unverified means strict. A client that cannot check the assertion has no
  /// way to tell "the account chose the relaxed tier" from "someone removed the
  /// evidence that it chose the strict one".
  ProtectionLevel get effectiveLevel {
    final current = state.value;
    if (current == null || !current.verified) {
      return ProtectionLevel.verifiedDevices;
    }
    return current.level;
  }

  /// Fetches and verifies the current level for [userId].
  ///
  /// Two properties, both of which the first version of this got wrong (§L.6):
  ///
  /// 1. **A monotonic version floor.** "Enforce the last validly-signed level
  ///    you have seen" is unimplementable without one. A genuinely-signed *older*
  ///    assertion verifies perfectly, so a server that keeps the assertion from
  ///    the day before the upgrade can roll the account back to `TrustedSignIn`
  ///    and then auto-admit its own device. Anything below the remembered
  ///    version is refused as tampering regardless of signature validity.
  /// 2. **A 200 with nothing in it fails closed.** An empty body used to leave
  ///    `reachable` true, which produced `verified: true` on a `TrustedSignIn`
  ///    fallback - the exact downgrade the tier exists to prevent, available by
  ///    returning `200 {}`. Only a 404, and only on a device that has never seen
  ///    a signed assertion, means "this account has not set a level".
  Future<ProtectionLevelState> refresh({
    required String userId,
    required String deviceId,
  }) async {
    final remembered = await _readRemembered(
      userId: userId,
      deviceId: deviceId,
    );

    Map<String, dynamic>? body;
    var unset = false;
    try {
      final response = await client.dio.get<Map<String, dynamic>>(
        client.url('/api/v1/identity/protection-level'),
      );
      body = response.data;
      if (body == null || body['signedAssertion'] == null) {
        // A 200 that asserts nothing. Not "the account has no level" - that is
        // a 404 - so it is treated as a failure to read rather than as an
        // answer.
        debugPrint(
          'ProtectionLevelService: the endpoint answered 200 with no assertion',
        );
        body = null;
      }
    } on DioException catch (e) {
      // 404 is "this account has never set a level", which is not a failure to
      // verify - there is nothing asserted, so there is nothing to have been
      // tampered with. §G.5 says new and existing accounts start on
      // TrustedSignIn, and treating an unset account as strict would demand a
      // manual approval nobody was ever told to expect.
      //
      // Only believed on a device that has never seen a *signed* level. Once one
      // has been seen, "there is no level" is a claim that contradicts something
      // this device verified, and the floor wins.
      unset = e.response?.statusCode == 404 && remembered == null;
      if (e.response?.statusCode == 404 && remembered != null) {
        warning.value = _rollbackWarning;
      }
    } catch (e) {
      debugPrint('ProtectionLevelService: could not read the level: $e');
    }

    if (body == null) {
      // Whatever this device last saw *signed* is the floor. A server that
      // removes the endpoint, or that answers with nothing, must not thereby
      // relax an account that opted into the strict tier.
      final fallback =
          remembered ??
          ProtectionLevelState(
            level: ProtectionLevel.trustedSignIn,
            version: 0,
            updatedAt: '',
            // Verified only in the "the account has demonstrably not set one"
            // sense - a real 404 on a device with no floor. Anything else stays
            // unverified, so `effectiveLevel` reads strict.
            verified: unset,
          );
      state.value = fallback;
      return fallback;
    }

    final level = _parseLevel(body['level']);
    final version = (body['version'] as num?)?.toInt() ?? 0;
    final updatedAt = body['updatedAt'] as String? ?? '';
    final assertion = body['signedAssertion'] as String? ?? '';

    // The floor, checked before the signature and independent of it. A replayed
    // older assertion is genuinely signed - that is the whole attack - so
    // verifying it first and rejecting afterwards would be the same code with a
    // pointless Ed25519 verification in it.
    if (remembered != null && version < remembered.version) {
      debugPrint(
        'ProtectionLevelService: refusing version $version, below the '
        '${remembered.version} this device has already seen signed',
      );
      warning.value = _rollbackWarning;
      state.value = remembered;
      return remembered;
    }

    final verified = await _verify(
      userId: userId,
      level: level,
      version: version,
      updatedAt: updatedAt,
      assertion: assertion,
    );

    // A downgrade this device did not participate in. §G.3: warn loudly rather
    // than applying it quietly. Note this is a *legitimate* downgrade path -
    // signed, at a higher version - which the tier permits with re-auth; the
    // warning exists so it cannot happen quietly.
    if (remembered != null &&
        remembered.level == ProtectionLevel.verifiedDevices &&
        level == ProtectionLevel.trustedSignIn) {
      warning.value =
          'This account\'s device protection was lowered from '
          '"${ProtectionLevel.verifiedDevices.label}" to '
          '"${ProtectionLevel.trustedSignIn.label}". If that was not you, one of '
          'your devices - or the server - has been tampered with.';
    }

    if (!verified) {
      warning.value =
          'This account\'s device protection setting could not be verified, so '
          'this device is enforcing the strictest one. New devices will need '
          'approving here.';

      // Unverified never becomes the answer while a verified floor exists.
      // Returning the unverified state would still read strict through
      // `effectiveLevel`, but it would also discard the version this device has
      // seen, and the next fetch would then accept anything at or above zero.
      if (remembered != null) {
        state.value = remembered;
        return remembered;
      }
    }

    final resolved = ProtectionLevelState(
      level: level,
      version: version,
      updatedAt: updatedAt,
      verified: verified,
    );

    // Only a *verified* level is remembered. Persisting an unverified one would
    // let a single bad response become this device's new floor.
    if (verified) {
      await _remember(userId: userId, deviceId: deviceId, state: resolved);
    }

    state.value = resolved;
    return resolved;
  }

  static const _rollbackWarning =
      'This account\'s device protection setting was replaced with an older '
      'one. That is not something a client does; either the server is '
      'misbehaving or somebody is trying to lower this account\'s protection. '
      'This device is enforcing what it last saw signed.';

  /// Sets the level, signing the assertion with the account identity key.
  ///
  /// Fails when this device holds no identity key: §I.2 says an account without
  /// one cannot enter `VerifiedDevices`, and the UI must explain that rather
  /// than failing opaquely.
  ///
  /// Also refuses `VerifiedDevices` on an account with no recovery-code wrapping
  /// (§H.7 with §C.1.1). That tier names the recovery code as the *only*
  /// credential — a server-assisted password reset explicitly cannot restore
  /// E2EE — so entering it without one promises a recovery path that does not
  /// exist, and the first password reset would be silent, total loss.
  Future<bool> setLevel({
    required String userId,
    required String deviceId,
    required ProtectionLevel level,
  }) async {
    if (!identity.isAvailable) {
      debugPrint(
        'ProtectionLevelService: no account identity key, so the level cannot '
        'be signed',
      );
      return false;
    }

    if (level == ProtectionLevel.verifiedDevices &&
        masterKeys.status.value != MasterKeyStatus.ready) {
      debugPrint(
        'ProtectionLevelService: this account has no usable recovery-code '
        'wrapping (${masterKeys.status.value.name}), so VerifiedDevices would '
        'promise a recovery path that does not exist',
      );
      return false;
    }

    // Above the floor, not merely above whatever is in memory. A device that has
    // not refreshed this session would otherwise sign version 1, which its own
    // rollback check would then refuse on the next read.
    final remembered = await _readRemembered(
      userId: userId,
      deviceId: deviceId,
    );
    final floor = [
      state.value?.version ?? 0,
      remembered?.version ?? 0,
    ].reduce((a, b) => a > b ? a : b);
    final version = floor + 1;
    final updatedAt = DateTime.now().toUtc().toIso8601String();

    final assertion = await _engine.signProtectionLevel(
      accountIdentityPrivateKeyB64: await _privateKey(
        userId: userId,
        deviceId: deviceId,
      ),
      userId: userId,
      level: level.wireName,
      version: version,
      updatedAt: updatedAt,
    );

    await client.dio.put<void>(
      client.url('/api/v1/identity/protection-level'),
      data: {
        'level': level.wireName,
        'signedAssertion': assertion,
        'version': version,
        'updatedAt': updatedAt,
      },
    );

    final resolved = ProtectionLevelState(
      level: level,
      version: version,
      updatedAt: updatedAt,
      verified: true,
    );
    await _remember(userId: userId, deviceId: deviceId, state: resolved);
    state.value = resolved;
    warning.value = null;
    return true;
  }

  Future<bool> _verify({
    required String userId,
    required ProtectionLevel level,
    required int version,
    required String updatedAt,
    required String assertion,
  }) async {
    if (assertion.isEmpty) return false;
    String? publicKey = identity.publicKey;
    publicKey ??= await _fetchIdentityKey(userId);
    if (publicKey == null) return false;

    try {
      return await _engine.verifyProtectionLevel(
        accountIdentityPublicKeyB64: publicKey,
        userId: userId,
        level: level.wireName,
        version: version,
        updatedAt: updatedAt,
        assertionB64: assertion,
      );
    } catch (e) {
      debugPrint('ProtectionLevelService: verification failed: $e');
      return false;
    }
  }

  Future<String?> _fetchIdentityKey(String userId) async {
    try {
      return (await masterKeyApi.fetchIdentityKey(userId))?.publicKey;
    } catch (e) {
      debugPrint('ProtectionLevelService: could not read the identity key: $e');
      return null;
    }
  }

  Future<String> _privateKey({
    required String userId,
    required String deviceId,
  }) async {
    final stored = await secureStorage.readAccountIdentity(
      deviceId: deviceId,
      userId: userId,
    );
    if (stored == null) {
      throw StateError('No account identity key on this device');
    }
    return stored.$2;
  }

  Future<ProtectionLevelState?> _readRemembered({
    required String userId,
    required String deviceId,
  }) async {
    final raw = await secureStorage.readProtectionLevel(
      deviceId: deviceId,
      userId: userId,
    );
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return ProtectionLevelState(
        level: _parseLevel(json['level']),
        version: (json['version'] as num?)?.toInt() ?? 0,
        updatedAt: json['updatedAt'] as String? ?? '',
        verified: true,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _remember({
    required String userId,
    required String deviceId,
    required ProtectionLevelState state,
  }) => secureStorage.writeProtectionLevel(
    deviceId: deviceId,
    userId: userId,
    value: jsonEncode({
      'level': state.level.wireName,
      'version': state.version,
      'updatedAt': state.updatedAt,
    }),
  );

  /// Unknown values read as the **strict** level, the opposite of
  /// [MlsPolicyService]. A level this build does not recognise is more likely a
  /// stricter one added later than a relaxation, and being wrong the other way
  /// would auto-admit devices on an account that asked us not to.
  static ProtectionLevel _parseLevel(Object? raw) => switch (raw) {
    'TrustedSignIn' || 'trustedSignIn' => ProtectionLevel.trustedSignIn,
    _ => ProtectionLevel.verifiedDevices,
  };
}
