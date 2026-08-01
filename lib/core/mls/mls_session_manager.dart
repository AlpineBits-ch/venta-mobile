import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../features/auth/data/auth_repository.dart';
import '../device/device_api.dart';
import '../device/device_id_service.dart';
import '../storage/secure_storage_service.dart';
import 'mls_service.dart';
import 'mls_sync_service.dart';

/// The MLS half of an authenticated session's start-up.
///
/// Alpine spreads this across `main-page.component`'s launch sequence and a
/// device-registration modal. Mobile has no modal to show - the identity is
/// minted silently on first authenticated launch, because there is nothing to
/// ask the user and a dialog that says "setting up encryption" is a dialog
/// nobody can act on.
///
/// Split into two phases on purpose, and `injector.dart` calls them either side
/// of device registration:
///
/// * [prepareIdentity] mints or unlocks the signing key. It has to run *before*
///   registration, because the key it produces is what registration publishes as
///   this device's `identityPublicKey`.
/// * [sync] uploads key packages and joins pending groups. It has to run
///   *after*, because both endpoints reject a device the server does not know.
class MlsSessionManager {
  MlsSessionManager({
    required this.mls,
    required this.sync_,
    required this.deviceApi,
    required this.deviceIdService,
    required this.authRepository,
    required this.secureStorage,
  });

  final MlsService mls;
  final MlsSyncService sync_;
  final DeviceApi deviceApi;
  final DeviceIdService deviceIdService;
  final AuthRepository authRepository;
  final SecureStorageService secureStorage;

  /// Mints or unlocks this installation's MLS identity.
  ///
  /// Never throws: an account that cannot set up encryption should still be able
  /// to read its plaintext conversations. Everything downstream checks
  /// [MlsService.isUnlocked] rather than assuming this worked.
  Future<void> prepareIdentity() async {
    try {
      final userId = authRepository.currentUserId;
      if (userId == null) {
        debugPrint('MLS: no signed-in user id, cannot set up encryption yet');
        return;
      }

      // A wipe means the private halves of every key package the server is still
      // handing out are gone. Contract §A: reset the server's stock *before*
      // anything re-uploads, or every Welcome sealed to one of them is
      // undecryptable by the device it was addressed to - silently, forever.
      if (await mls.init(userId)) await resetServerKeyPackages();

      if (await mls.unlock()) return;

      // No identity in the keychain. Whether that is a first run or lost keys
      // depends entirely on whether the engine restored groups, and
      // `createIdentity` refuses the second case rather than minting over live
      // group state - a device that did would believe it was unlocked while
      // every message it sent was rejected and none it received could be read.
      final batch = await mls.createIdentity();

      // The device's published identity key *is* the MLS signing key from here
      // on. Writing it before registration is what gets a fresh install
      // registered with the real key rather than the random placeholder.
      //
      // A device already registered under the placeholder keeps it: the only way
      // to change a registered row's key is to delete and re-create it, which
      // revokes that device's login sessions - signing the user out to correct a
      // field the server stores and never reads is not a trade worth making.
      await secureStorage.writeDeviceIdentityKey(batch.signingPublicKey);
      await deviceIdService.refreshIdentityPublicKey();

      // A fresh signing keypair on an existing `clientDeviceId` is the other
      // half of contract §A: the server's key packages name the *old* key, so
      // they are dead and must go before the replenish that follows.
      await resetServerKeyPackages();
    } on MlsIdentityConflictException catch (e) {
      // Deliberately not recovered from here. `MlsService.recoverWithFreshIdentity`
      // is the user-initiated path, behind the "re-link this device" affordance,
      // because taking it silently destroys every encrypted message this account
      // holds on this handset.
      debugPrint('MLS: $e - waiting for the user to restore a backup or re-link');
    } catch (e, stack) {
      debugPrint('MLS: identity setup failed: $e');
      debugPrintStack(stackTrace: stack);
    }
  }

  /// Contract §A. Idempotent, and best-effort: a device that could not clear its
  /// stale stock is no worse off than before this existed, and the next launch
  /// tries again.
  Future<void> resetServerKeyPackages() async {
    final deviceId = deviceIdService.deviceIdOrNull;
    if (deviceId == null) return;
    try {
      final deleted = await deviceApi.resetKeyPackages(deviceId);
      debugPrint('MLS: cleared $deleted stale key packages for this device');
    } catch (e) {
      debugPrint('MLS: could not reset this device\'s key packages: $e');
    }
  }

  /// Tops the server's key package supply back up and joins anything this
  /// device was invited to while it was away.
  ///
  /// Both halves are best-effort and independent: failing to replenish means
  /// this device eventually cannot be added to new groups, failing to join means
  /// some contexts are unreadable. Neither is worth blocking launch over, and
  /// both retry on the next start.
  Future<void> sync() async {
    if (!mls.isUnlocked) return;

    try {
      await replenishKeyPackages();
    } catch (e) {
      debugPrint('MLS: key package replenishment failed: $e');
    }

    try {
      await sync_.processPendingWelcomes();
    } catch (e) {
      debugPrint('MLS: failed to process pending Welcomes at launch: $e');
    }
  }

  /// Asks the server how many key packages it wants and uploads exactly that
  /// many.
  ///
  /// The count is the server's to decide - it is the one that knows how many
  /// have been consumed, expired or swept. A client guessing would either starve
  /// itself out of new groups or fill the table.
  /// Shortest gap between two replenish checks.
  ///
  /// The check itself is one GET that usually uploads nothing, but it also
  /// drives the server's sweep of expired and long-consumed rows, so firing it
  /// on every resume would be rude for no benefit. An hour is far below the rate
  /// at which a device can plausibly drain a hundred packages.
  static const _minimumInterval = Duration(hours: 1);

  DateTime? _lastReplenish;

  /// Tops the supply up if it has not been checked recently.
  ///
  /// Alpine replenishes only at launch, which suits a client that is closed and
  /// reopened. A phone app can stay resident for days while every group it is
  /// added to consumes another package - so once the supply drains, this device
  /// would silently stop being addable to new conversations until the next cold
  /// start. Resuming from background is the trigger desktop does not have.
  Future<void> replenishIfStale() async {
    final last = _lastReplenish;
    if (last != null && DateTime.now().difference(last) < _minimumInterval) {
      return;
    }
    try {
      await replenishKeyPackages();
    } catch (e) {
      debugPrint('MLS: key package replenishment failed: $e');
    }
  }

  Future<void> replenishKeyPackages() async {
    final deviceId = deviceIdService.deviceIdOrNull;
    if (deviceId == null || !mls.isUnlocked) return;

    // Stamped before the work, not after: a failure should still hold the next
    // attempt off for the interval rather than retrying on every resume.
    _lastReplenish = DateTime.now();

    final needed = await deviceApi.keyPackagesToGenerate(deviceId);
    final upload = <KeyPackageUpload>[];

    if (needed.count > 0) {
      final packages = await mls.generateKeyPackages(needed.count);
      upload.addAll(
        packages.map((p) => KeyPackageUpload(keyPackage: p.keyPackage)),
      );
    }

    if (needed.needsLastResort) {
      final packages = await mls.generateKeyPackages(1);
      if (packages.isNotEmpty) {
        upload.add(
          KeyPackageUpload(
            keyPackage: packages.first.keyPackage,
            isLastResort: true,
          ),
        );
      }
    }

    if (upload.isEmpty) return;
    await deviceApi.uploadKeyPackages(
      clientDeviceId: deviceId,
      keyPackages: upload,
    );
  }

  /// Closes the session's MLS state without destroying it. Sign-out only - see
  /// [MlsService.lock].
  Future<void> stop() => mls.lock();
}
