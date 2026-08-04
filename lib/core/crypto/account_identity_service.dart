import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:venta_mls/venta_mls.dart';

import '../storage/secure_storage_service.dart';
import 'master_key_api.dart';
import 'master_key_service.dart';

/// A device certificate as it travels with a device's key packages.
///
/// `sign(accountIdentityKey, "venta.device-cert.v1" || deviceId ||
/// deviceSignatureKey || issuedAt || expiresAt)`, with every field
/// length-prefixed so one signature cannot be made to vouch for two different
/// statements.
class DeviceCertificate {
  const DeviceCertificate({
    required this.deviceId,
    required this.deviceSignatureKey,
    required this.issuedAt,
    required this.expiresAt,
    required this.certificate,
  });

  factory DeviceCertificate.fromJson(Map<String, dynamic> json) =>
      DeviceCertificate(
        deviceId: json['deviceId'] as String? ?? '',
        deviceSignatureKey: json['deviceSignatureKey'] as String? ?? '',
        issuedAt: DateTime.fromMillisecondsSinceEpoch(
          ((json['issuedAt'] as num?)?.toInt() ?? 0) * 1000,
          isUtc: true,
        ),
        expiresAt: DateTime.fromMillisecondsSinceEpoch(
          ((json['expiresAt'] as num?)?.toInt() ?? 0) * 1000,
          isUtc: true,
        ),
        certificate: json['certificate'] as String? ?? '',
      );

  final String deviceId;
  final String deviceSignatureKey;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final String certificate;

  Map<String, Object?> toJson() => {
    'deviceId': deviceId,
    'deviceSignatureKey': deviceSignatureKey,
    'issuedAt': issuedAt.toUtc().millisecondsSinceEpoch ~/ 1000,
    'expiresAt': expiresAt.toUtc().millisecondsSinceEpoch ~/ 1000,
    'certificate': certificate,
  };

  bool get isExpired => DateTime.now().toUtc().isAfter(expiresAt);
}

/// The account identity key (contract §H.2) and the device certificates it
/// issues.
///
/// This is the piece that makes full-loss recovery possible at all. §G's
/// admission proof is verified against the account *master* key, which only the
/// owner's own devices hold - so "I dropped my only phone in a lake, get me back
/// in" deadlocks: there is no device left to verify anything. A long-lived
/// account identity key, restorable from the backup envelope, lets a peer check
/// offline that a device really belongs to an account with none of that
/// account's devices online, and with no trust in the server, which never holds
/// the private half.
///
/// §I.2 governs when it appears: existing accounts have none, it can only be
/// generated once an upgraded client has the master key, and it cannot issue
/// certificates for the user's *other* devices - they self-issue when they
/// upgrade. Expect a long tail, which is exactly why §I.1's enforcement is
/// three-state.
class AccountIdentityService {
  AccountIdentityService({
    required this.api,
    required this.masterKeys,
    required this.secureStorage,
    VentaMls? engine,
  }) : _engine = engine ?? VentaMls();

  final MasterKeyApi api;
  final MasterKeyService masterKeys;
  final SecureStorageService secureStorage;
  final VentaMls _engine;

  /// Suggested by §H.2. Long enough that reissue is rare, short enough that a
  /// stolen certificate for a device that has since been removed stops working.
  static const certificateLifetime = Duration(days: 180);

  String? _publicKey;
  String? _privateKey;
  int _version = 1;

  /// True once this device holds the account identity key and can therefore
  /// issue certificates and enforce §H.4.
  bool get isAvailable => _privateKey != null;

  String? get publicKey => _publicKey;

  /// Which version of the account identity key this device holds. Travels on
  /// every certificate so a peer can tell which key to verify against.
  int get version => _version;

  /// Loads the identity key, generating one if the account has none.
  ///
  /// Returns false when it could not be established - overwhelmingly because the
  /// master key is not unlocked on this device yet, which §I.2 says is the
  /// ordinary state of every existing account. A false here means "treat this
  /// account as Observe and do not offer VerifiedDevices", never "fail".
  ///
  /// [password] is the account password, and it is what makes generation
  /// possible at all: the server gates `PUT users/identity-key` on it for a
  /// *first* publication as well as a rotation, because whoever publishes first
  /// is who every peer pins. Without one this can still adopt a key already in
  /// the keychain - which is the whole of the cold-start path - but it cannot
  /// establish a new one.
  Future<bool> ensure({
    required String userId,
    required String deviceId,
    String? password,
  }) async {
    final cached = await secureStorage.readAccountIdentity(
      deviceId: deviceId,
      userId: userId,
    );
    if (cached != null) {
      final (publicKey, privateKey) = cached;

      // What the account actually publishes decides whether the cached private
      // half is the account's identity key or a stranded one.
      PublishedIdentityKey? published;
      var reachable = true;
      try {
        published = await api.fetchIdentityKey(userId);
      } catch (e) {
        reachable = false;
        debugPrint(
          'AccountIdentityService: could not read the published identity key: $e',
        );
      }

      if (published != null && published.publicKey != publicKey) {
        // Another device published a different key - this one raced it, or
        // restored from a backup older than a rotation. Certificates issued from
        // here would not verify against what peers pin, and an *invalid*
        // certificate is a security warning at every phase (§I.1), so issuing
        // one is worse than issuing none.
        debugPrint(
          'AccountIdentityService: the account publishes an identity key this '
          'device does not hold - not issuing certificates against the local one',
        );
        _publicKey = published.publicKey;
        _privateKey = null;
        _version = published.version;
        return false;
      }

      _publicKey = publicKey;
      _privateKey = privateKey;
      _version = published?.version ?? _version;

      // The published half may be missing even when the local one is not - a
      // device that generated the key offline, or an upload that failed. Peers
      // can verify nothing until it is up there.
      if (reachable && published == null) {
        if (password == null) {
          debugPrint(
            'AccountIdentityService: this device holds an unpublished identity '
            'key and has no password to publish it with; peers cannot verify it '
            'until the next sign-in',
          );
        } else {
          try {
            await api.uploadIdentityKey(
              identityPublicKey: publicKey,
              password: password,
              version: _version,
              deviceId: deviceId,
            );
          } catch (e) {
            debugPrint(
              'AccountIdentityService: could not publish the identity key: $e',
            );
          }
        }
      }
      return true;
    }

    final masterKey = await masterKeys.peek(userId: userId, deviceId: deviceId);
    if (masterKey == null) {
      debugPrint(
        'AccountIdentityService: no master key on this device yet, so no '
        'account identity key can be established',
      );
      return false;
    }

    // Published already? Then the private half is in someone else's keychain or
    // in a backup, and this device must not mint a second one - a competing
    // identity key would look to every peer exactly like the safety-number
    // change §H.5 exists to warn about.
    try {
      final published = await api.fetchIdentityKey(userId);
      if (published != null) {
        debugPrint(
          'AccountIdentityService: the account already has an identity key this '
          'device does not hold - restore a backup rather than rotating',
        );
        _publicKey = published.publicKey;
        _version = published.version;
        return false;
      }
    } catch (e) {
      // Fail closed on the *generation* decision: minting a rotation because a
      // GET timed out is far worse than doing nothing this launch.
      debugPrint(
        'AccountIdentityService: could not check for an identity key: $e',
      );
      return false;
    }

    if (password == null) {
      // Generating one we cannot publish would leave this device holding a key
      // no peer has pinned, and would race whichever device publishes first.
      // Deferring costs a launch; the §I.1 long tail already assumes one.
      debugPrint(
        'AccountIdentityService: the account has no identity key and no '
        'password is available to publish one, so none is being minted',
      );
      return false;
    }

    final identity = await _engine.generateAccountIdentity();
    // Published *before* it is cached. A key in the keychain that the account
    // does not publish is the state the mismatch branch above has to clean up
    // after, so the ordering that avoids creating it is the cheaper one.
    await api.uploadIdentityKey(
      identityPublicKey: identity.publicKey,
      password: password,
      version: 1,
      deviceId: deviceId,
    );
    await secureStorage.writeAccountIdentity(
      deviceId: deviceId,
      userId: userId,
      publicKey: identity.publicKey,
      privateKey: identity.privateKey,
    );
    _publicKey = identity.publicKey;
    _privateKey = identity.privateKey;
    _version = 1;
    return true;
  }

  /// Adopts an identity key restored from a backup envelope (§H.3, row 3).
  ///
  /// This is what a wiped handset does before it external-commits its way back
  /// into every group: without the private half it can issue no certificate, and
  /// §H.4 says every peer would then propose removing its leaf.
  Future<void> adoptRestored({
    required String userId,
    required String deviceId,
    required String publicKey,
    required String privateKey,
  }) async {
    await secureStorage.writeAccountIdentity(
      deviceId: deviceId,
      userId: userId,
      publicKey: publicKey,
      privateKey: privateKey,
    );
    _publicKey = publicKey;
    _privateKey = privateKey;
  }

  /// Issues a certificate for **this** device.
  ///
  /// Never for another: a device holding the account identity key could
  /// technically sign for any device id, but a certificate is a statement that
  /// this signing key is on that device, and only that device knows it. Other
  /// devices self-issue when they upgrade (§I.2).
  Future<DeviceCertificate?> issueForThisDevice({
    required String userId,
    required String deviceId,
    required String deviceSignatureKey,
  }) async {
    final privateKey = _privateKey;
    if (privateKey == null) return null;

    final issuedAt = DateTime.now().toUtc();
    final expiresAt = issuedAt.add(certificateLifetime);
    final certificate = await _engine.issueDeviceCertificate(
      accountIdentityPrivateKeyB64: privateKey,
      userId: userId,
      deviceId: deviceId,
      deviceSignatureKeyB64: deviceSignatureKey,
      issuedAt: issuedAt,
      expiresAt: expiresAt,
    );
    return DeviceCertificate(
      deviceId: deviceId,
      deviceSignatureKey: deviceSignatureKey,
      issuedAt: issuedAt,
      expiresAt: expiresAt,
      certificate: certificate,
    );
  }

  /// Checks a certificate against the account identity key **pinned** for
  /// [ownerUserId], TOFU-style, and against the leaf it is supposed to vouch
  /// for.
  ///
  /// Pinned, not fetched-and-trusted: verifying against whatever key the server
  /// hands back would let it substitute its own and vouch for a leaf it
  /// injected, which is precisely the attack §H.4 exists to stop. A key that
  /// differs from the pin is reported as [CertificateVerdict.identityChanged] so
  /// the caller can raise a safety-number warning instead of quietly accepting.
  ///
  /// [leafDeviceId] and [leafSignatureKey] are the values taken from the leaf
  /// under examination, and they are **required**. This used to verify the
  /// certificate against the certificate's own self-reported fields, which asks
  /// "did somebody sign this?" and not "does this vouch for the leaf in front of
  /// me". Certificates are public, so a server replaying any genuine certificate
  /// for the account against a leaf it had injected passed - at full
  /// enforcement, at 100% coverage. See §L.2.
  Future<CertificateVerdict> verify({
    required String ownerUserId,
    required DeviceCertificate? certificate,
    required String leafDeviceId,
    required String leafSignatureKey,
  }) async {
    if (certificate == null || certificate.certificate.isEmpty) {
      return CertificateVerdict.missing;
    }

    // The binding, before anything expensive. A certificate that names another
    // device, or another signing key, says nothing about this leaf however
    // valid its signature is.
    if (certificate.deviceId != leafDeviceId ||
        !_sameKey(certificate.deviceSignatureKey, leafSignatureKey)) {
      debugPrint(
        'AccountIdentityService: a certificate for '
        '${certificate.deviceId} was presented for leaf $leafDeviceId',
      );
      return CertificateVerdict.wrongLeaf;
    }

    final pinned = await secureStorage.readPinnedIdentityKey(ownerUserId);
    String? identityKey = pinned;

    if (identityKey == null) {
      // First contact. Trust on first use, then never again - the same bargain
      // Signal makes with a safety number.
      try {
        identityKey = (await api.fetchIdentityKey(ownerUserId))?.publicKey;
      } catch (e) {
        debugPrint(
          'AccountIdentityService: could not fetch $ownerUserId\'s identity key: $e',
        );
        return CertificateVerdict.unknownIssuer;
      }
      if (identityKey == null) return CertificateVerdict.unknownIssuer;
      await secureStorage.writePinnedIdentityKey(
        peerUserId: ownerUserId,
        identityPublicKey: identityKey,
      );
    }

    if (certificate.isExpired) return CertificateVerdict.expired;

    // Verified against the values from the **leaf**, not the certificate's own
    // copies of them. They are equal by the check above, and passing the leaf's
    // is what keeps that check load-bearing rather than decorative.
    final valid = await _engine.verifyDeviceCertificate(
      accountIdentityPublicKeyB64: identityKey,
      userId: ownerUserId,
      deviceId: leafDeviceId,
      deviceSignatureKeyB64: leafSignatureKey,
      issuedAt: certificate.issuedAt,
      expiresAt: certificate.expiresAt,
      certificateB64: certificate.certificate,
    );
    if (valid) return CertificateVerdict.valid;

    // Signed by *something*, just not by the key we pinned. Either the account
    // rotated its identity key (§H.5, which needs re-verification out of band)
    // or someone is forging. Both need a human, and neither may be auto-accepted.
    if (pinned != null) return CertificateVerdict.identityChanged;
    return CertificateVerdict.invalid;
  }

  /// Two base64 strings naming the same key.
  ///
  /// Compared as decoded bytes rather than as strings: base64 is not canonical
  /// (padding, whitespace, and the URL-safe alphabet all round-trip to the same
  /// key), and a comparison that a differently-encoded copy of the *right* key
  /// fails is a comparison that gets relaxed the first time it misfires.
  static bool _sameKey(String a, String b) {
    if (a == b) return a.isNotEmpty;
    try {
      final left = base64Decode(base64.normalize(a));
      final right = base64Decode(base64.normalize(b));
      if (left.isEmpty || left.length != right.length) return false;
      for (var i = 0; i < left.length; i++) {
        if (left[i] != right[i]) return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// On sign-out and account switch.
  Future<void> reset({String? userId, String? deviceId}) async {
    _publicKey = null;
    _privateKey = null;
    _version = 1;
    if (userId != null && deviceId != null) {
      await secureStorage.clearAccountIdentity(
        deviceId: deviceId,
        userId: userId,
      );
    }
  }
}

/// What checking a device certificate concluded.
///
/// [missing] and [invalid] are deliberately distinct: no device in the field has
/// a certificate yet, so §I.1 tolerates [missing] during rollout - while
/// [invalid] cannot happen by accident and is a security warning at every phase.
enum CertificateVerdict {
  valid,

  /// No certificate was presented. The ordinary state of a device that has not
  /// upgraded yet.
  missing,

  /// Present, signed by the pinned key, but past its expiry.
  expired,

  /// Present but does not verify, and we had no previous pin to compare against.
  invalid,

  /// Present, genuine, and **about a different leaf**.
  ///
  /// Certificates are public: a server can fetch a real one for the account and
  /// present it alongside a leaf it injected. Nothing about the signature is
  /// wrong, which is exactly why this is its own verdict - it is always an
  /// attack, never a rollout artefact, and it must not be filed under
  /// "certificate missing" and tolerated during `Observe`.
  wrongLeaf,

  /// Present, does not verify against the **pinned** key. Either an identity-key
  /// rotation or forgery - a human decides which.
  identityChanged,

  /// The account has published no identity key, so nothing can be verified. §I.2
  /// says this is normal until an upgraded client unlocks that account.
  unknownIssuer,
}
